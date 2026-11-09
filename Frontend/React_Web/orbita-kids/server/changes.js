// Cambios que envía la app (en línea o desde la cola sin conexión). Cada uno trae un id único generado
// en el navegador: si el mismo cambio llega dos veces, se responde lo mismo sin aplicarlo de nuevo.
import { json, transaction } from './db.js'
import { staffIdOf, todayLabel } from './data.js'
import { newId } from './security.js'

class Rejected extends Error {}
const reject = (message) => {
  throw new Rejected(message)
}

// Validadores pequeños: rechazan con un mensaje que la persona puede entender.
function text(value, { min = 0, max = 200, label = 'el texto' } = {}) {
  const v = typeof value === 'string' ? value.trim() : ''
  if (v.length < min) reject(`Falta ${label}.`)
  if (v.length > max) reject(`${label[0].toUpperCase()}${label.slice(1)} es demasiado largo.`)
  return v
}
function int(value, min, max, label) {
  const n = Number(value)
  if (!Number.isInteger(n) || n < min || n > max) reject(`${label} debe estar entre ${min} y ${max}.`)
  return n
}
function oneOf(value, list, label) {
  if (!list.includes(value)) reject(`${label} no es válido.`)
  return value
}
function isoDate(value) {
  if (value == null || value === '') return null
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value) || Number.isNaN(Date.parse(value))) reject('La fecha no es válida.')
  return value
}
const slugId = (value, prefix) => (typeof value === 'string' && /^[a-z0-9-]{3,40}$/.test(value) ? value : newId(prefix))

function ownGroup(ctx, groupId) {
  const g = ctx.db.prepare('SELECT * FROM class_groups WHERE id = ? AND (teacher_id = ? OR support_teacher_id = ?)').get(groupId, ctx.staffId, ctx.staffId)
  if (!g) reject('No tienes acceso a ese grupo.')
  return g
}
function ownStudent(ctx, studentId) {
  const s = ctx.db.prepare('SELECT * FROM students WHERE id = ?').get(studentId)
  if (!s) reject('El estudiante ya no existe.')
  ownGroup(ctx, s.group_id)
  return s
}
function schoolGroup(ctx, id) {
  const g = ctx.db.prepare('SELECT * FROM class_groups WHERE id = ? AND school_id = ?').get(id, ctx.schoolId)
  if (!g) reject('El grupo ya no existe.')
  return g
}
function schoolStaff(ctx, id) {
  const t = ctx.db.prepare('SELECT * FROM staff WHERE id = ? AND school_id = ?').get(id, ctx.schoolId)
  if (!t) reject('Esa persona ya no está en la escuela.')
  return t
}
function seatsInUse(ctx) {
  return ctx.db
    .prepare(
      `SELECT COUNT(*) AS n FROM students s JOIN class_groups g ON g.id = s.group_id
       WHERE g.school_id = ? AND g.status != 'archived' AND g.cycle = (SELECT cycle FROM schools WHERE id = ?)`,
    )
    .get(ctx.schoolId, ctx.schoolId).n
}
function seatsAssigned(ctx, exceptId = '') {
  return ctx.db
    .prepare("SELECT COALESCE(SUM(seats), 0) AS n FROM class_groups WHERE school_id = ? AND status != 'archived' AND cycle = (SELECT cycle FROM schools WHERE id = ?) AND id != ?")
    .get(ctx.schoolId, ctx.schoolId, exceptId).n
}
function notifyDirectors(ctx, notice) {
  const directors = ctx.db.prepare("SELECT id FROM users WHERE school_id = ? AND spaces LIKE '%institucion%'").all(ctx.schoolId)
  const add = ctx.db.prepare('INSERT INTO notices (id, user_id, space, icon, title, meta, to_path, unread, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?)')
  for (const d of directors) add.run(newId('ntc'), d.id, 'institucion', notice.icon, notice.title, notice.meta, notice.to, ctx.now)
}

function activityFields(ctx, p, { draft }) {
  const group = ownGroup(ctx, p.groupId)
  if (group.status === 'archived') reject('Ese grupo está archivado.')
  const name = draft ? text(p.name, { max: 80, label: 'el nombre' }) || 'Borrador sin nombre' : text(p.name, { min: 3, max: 80, label: 'el nombre' })
  if (!draft && name.replace(/[^\p{L}]/gu, '').length < 3) reject('El nombre necesita al menos 3 letras.')
  const total = ctx.db.prepare('SELECT COUNT(*) AS n FROM students WHERE group_id = ?').get(group.id).n
  return {
    group,
    name,
    mode: oneOf(p.mode, ['visual', 'select', 'both'], 'La modalidad'),
    level: int(p.level, 1, 5, 'El nivel'),
    count: int(p.count, 3, 20, 'El número de ejercicios'),
    due: isoDate(p.due),
    instructions: text(p.instructions, { max: 500, label: 'las instrucciones' }),
    recipients: oneOf(p.recipients || 'all', ['all', 'some'], 'Los destinatarios'),
    total,
  }
}

function saveActivity(ctx, p, status) {
  const f = activityFields(ctx, p, { draft: status === 'draft' })
  const id = slugId(p.activityId, 'act')
  const existing = ctx.db.prepare('SELECT * FROM activities WHERE id = ?').get(id)
  if (existing) {
    if (existing.teacher_id !== ctx.staffId) reject('Esa actividad es de otra persona.')
    if (existing.status !== 'draft') reject('Esa actividad ya estaba publicada.')
    ctx.db
      .prepare('UPDATE activities SET group_id = ?, name = ?, mode = ?, level = ?, count = ?, due = ?, status = ?, total = ?, instructions = ?, recipients = ?, updated_at = ? WHERE id = ?')
      .run(f.group.id, f.name, f.mode, f.level, f.count, f.due, status, f.total, f.instructions, f.recipients, ctx.now, id)
  } else {
    ctx.db
      .prepare(
        `INSERT INTO activities (id, teacher_id, group_id, name, mode, level, count, due, status, done, total, instructions, recipients, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?)`,
      )
      .run(id, ctx.staffId, f.group.id, f.name, f.mode, f.level, f.count, f.due, status, f.total, f.instructions, f.recipients, ctx.now, ctx.now)
  }
  return { activityId: id }
}

const PREF_KEYS = ['largeText', 'reduceMotion', 'captureLinks', 'theme', 'visibleName', 'notifyDesktop', 'notifyEmail', 'quietHours']

export const HANDLERS = {
  // ——— Docente ———
  'publish-activity': { space: 'docente', apply: (ctx, p) => saveActivity(ctx, p, 'active') },
  'save-draft': { space: 'docente', apply: (ctx, p) => saveActivity(ctx, p, 'draft') },
  'delete-draft': {
    space: 'docente',
    apply(ctx, p) {
      ctx.db.prepare("DELETE FROM activities WHERE id = ? AND teacher_id = ? AND status = 'draft'").run(String(p.activityId), ctx.staffId)
    },
  },
  'close-activity': {
    space: 'docente',
    apply(ctx, p) {
      const r = ctx.db.prepare("UPDATE activities SET status = 'closed', updated_at = ? WHERE id = ? AND teacher_id = ? AND status IN ('active', 'scheduled')").run(ctx.now, String(p.activityId), ctx.staffId)
      if (!r.changes) reject('Esa actividad ya no está activa.')
    },
  },
  'assign-reinforcement': {
    space: 'docente',
    apply(ctx, p) {
      const student = ownStudent(ctx, p.studentId)
      const topic = text(p.topic || 'Sumas con apoyo visual', { max: 120, label: 'el tema' })
      ctx.db.prepare('INSERT INTO reinforcements (id, student_id, teacher_id, topic, created_at) VALUES (?, ?, ?, ?, ?)').run(newId('ref'), student.id, ctx.staffId, topic, ctx.now)
    },
  },
  'request-group': {
    space: 'docente',
    apply(ctx, p) {
      const note = text(p.note, { max: 300, label: 'la nota' })
      ctx.db.prepare('INSERT INTO requests (id, kind, data, created_at) VALUES (?, ?, ?, ?)').run(newId('req'), 'group', JSON.stringify({ by: ctx.user.id, note }), ctx.now)
      notifyDirectors(ctx, { icon: '112', title: `${ctx.user.name} solicitó un grupo nuevo`, meta: `Docentes · ${todayLabel()}`, to: '/institucion/grupos' })
    },
  },

  // ——— Cualquier espacio ———
  'update-security': {
    apply(ctx, p) {
      ctx.db.prepare('UPDATE users SET two_factor = ? WHERE id = ?').run(p.twoFactor ? 1 : 0, ctx.user.id)
    },
  },
  'mark-notices-read': {
    apply(ctx, p) {
      const ids = Array.isArray(p.ids) ? p.ids.filter((x) => typeof x === 'string').slice(0, 200) : []
      const mark = ctx.db.prepare('UPDATE notices SET unread = 0 WHERE user_id = ? AND id = ?')
      for (const id of ids) mark.run(ctx.user.id, id)
    },
  },
  'update-preferences': {
    apply(ctx, p) {
      const current = json(ctx.user.prefs, {})
      for (const key of PREF_KEYS) if (key in p) current[key] = typeof p[key] === 'string' ? p[key].slice(0, 60) : !!p[key]
      ctx.db.prepare('UPDATE users SET prefs = ? WHERE id = ?').run(JSON.stringify(current), ctx.user.id)
    },
  },

  // ——— Institución ———
  'invite-teacher': {
    space: 'institucion',
    apply(ctx, p) {
      const email = text(p.email, { min: 5, max: 120, label: 'el correo' }).toLowerCase()
      if (!/^[^\s@]+@escuela\.example$/.test(email)) reject('El correo debe ser de la escuela (@escuela.example).')
      if (ctx.db.prepare('SELECT 1 FROM staff WHERE email = ?').get(email)) reject('Esa persona ya está en la lista de docentes.')
      const local = email.split('@')[0]
      const name = text(p.name, { max: 80, label: 'el nombre' }) || local.split('.').map((w) => w[0].toUpperCase() + w.slice(1)).join(' ')
      const initials = name.split(/\s+/).slice(0, 2).map((w) => w[0]).join('').toUpperCase()
      const id = newId('stf')
      ctx.db
        .prepare('INSERT INTO staff (id, school_id, name, initials, color, email, status, note, last, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
        .run(id, ctx.schoolId, name, initials, '#5776e0', email, 'invited', `Invitación enviada el ${todayLabel()}`, '—', ctx.now)
      const groups = Array.isArray(p.groups) ? p.groups.filter((g) => typeof g === 'string').slice(0, 10) : []
      ctx.db.prepare('INSERT INTO invitations (token, staff_id, invited_by, groups, expires) VALUES (?, ?, ?, ?, ?)').run(newId('inv'), id, `${ctx.user.name} · Dirección`, JSON.stringify(groups), '7 días')
    },
  },
  'review-teacher': {
    space: 'institucion',
    apply(ctx, p) {
      const t = schoolStaff(ctx, p.staffId)
      if (t.status !== 'request') reject('Esa solicitud ya se atendió.')
      if (p.decision === 'approve') ctx.db.prepare("UPDATE staff SET status = 'active', note = NULL, last = 'Ahora' WHERE id = ?").run(t.id)
      else if (p.decision === 'reject') ctx.db.prepare('DELETE FROM staff WHERE id = ?').run(t.id)
      else reject('Decisión no válida.')
    },
  },
  'set-teacher-status': {
    space: 'institucion',
    apply(ctx, p) {
      const t = schoolStaff(ctx, p.staffId)
      const status = oneOf(p.status, ['active', 'disabled'], 'El estado')
      if (t.director) reject('No puedes desactivar a la dirección.')
      if (!['active', 'disabled'].includes(t.status)) reject('Esa persona todavía no tiene una cuenta activa.')
      ctx.db.prepare('UPDATE staff SET status = ? WHERE id = ?').run(status, t.id)
    },
  },
  'resend-invite': {
    space: 'institucion',
    apply(ctx, p) {
      const t = schoolStaff(ctx, p.staffId)
      if (t.status !== 'invited') reject('Esa invitación ya no está pendiente.')
      ctx.db.prepare('UPDATE staff SET note = ? WHERE id = ?').run(`Invitación reenviada el ${todayLabel()}`, t.id)
    },
  },
  'create-group': {
    space: 'institucion',
    apply(ctx, p) {
      const name = text(p.name, { min: 2, max: 20, label: 'el nombre del grupo' })
      const teacher = schoolStaff(ctx, p.teacherId)
      if (teacher.status !== 'active') reject('Elige a un docente activo.')
      const seats = int(p.seats, 1, 40, 'Los lugares')
      const school = ctx.db.prepare('SELECT seats_total, cycle FROM schools WHERE id = ?').get(ctx.schoolId)
      const free = school.seats_total - seatsInUse(ctx)
      if (seats > free) reject(`Solo quedan ${free} lugares libres en la licencia.`)
      let code = typeof p.code === 'string' && /^ORB-[A-Z0-9]{4}$/.test(p.code) ? p.code : null
      const taken = ctx.db.prepare('SELECT 1 FROM class_groups WHERE code = ?')
      const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'
      while (!code || taken.get(code)) code = `ORB-${Array.from({ length: 4 }, () => chars[Math.floor(Math.random() * chars.length)]).join('')}`
      const grade = Number(/^\d/.exec(name)?.[0]) || 0
      ctx.db
        .prepare(
          `INSERT INTO class_groups (id, school_id, teacher_id, name, short, level, grade, code, seats, until, status, cycle, completed, report)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', ?, 0, '{}')`,
        )
        .run(newId('grp'), ctx.schoolId, teacher.id, name, name.replace(' ', ''), `${grade || ''}.º de primaria`, grade, code, seats, text(p.until, { max: 20, label: 'la vigencia' }) || '31 jul 2027', school.cycle)
      return { code }
    },
  },
  'update-group': {
    space: 'institucion',
    apply(ctx, p) {
      const g = schoolGroup(ctx, p.groupId)
      const action = oneOf(p.action, ['archive', 'restore', 'renew', 'add-seats'], 'La acción')
      if (action === 'archive') ctx.db.prepare("UPDATE class_groups SET status = 'archived' WHERE id = ?").run(g.id)
      if (action === 'restore') ctx.db.prepare("UPDATE class_groups SET status = 'active' WHERE id = ?").run(g.id)
      if (action === 'renew') ctx.db.prepare("UPDATE class_groups SET status = 'active', until = '31 jul 2027' WHERE id = ?").run(g.id)
      if (action === 'add-seats') {
        const school = ctx.db.prepare('SELECT seats_total FROM schools WHERE id = ?').get(ctx.schoolId)
        if (school.seats_total - seatsInUse(ctx) < 5) reject('No quedan 5 lugares libres en la licencia.')
        ctx.db.prepare("UPDATE class_groups SET seats = seats + 5, status = 'active' WHERE id = ?").run(g.id)
      }
      return { assigned: seatsAssigned(ctx) }
    },
  },
  'update-settings': {
    space: 'institucion',
    apply(ctx, p) {
      const school = ctx.db.prepare('SELECT settings FROM schools WHERE id = ?').get(ctx.schoolId)
      const settings = json(school.settings, {})
      if ('displayName' in p) settings.displayName = text(p.displayName, { min: 3, max: 100, label: 'el nombre de la escuela' })
      if ('timezone' in p) settings.timezone = oneOf(p.timezone, ['America/Mexico_City', 'America/Cancun', 'America/Monterrey', 'America/Tijuana', 'America/Hermosillo'], 'La zona horaria')
      if ('cycleLabel' in p) settings.cycleLabel = text(p.cycleLabel, { max: 20, label: 'el ciclo' })
      for (const key of ['autoApprove', 'twoStep', 'idleLogout']) if (key in p) settings[key] = !!p[key]
      ctx.db.prepare('UPDATE schools SET settings = ? WHERE id = ?').run(JSON.stringify(settings), ctx.schoolId)
    },
  },
  'request-plan': {
    space: 'institucion',
    apply(ctx, p) {
      const plan = oneOf(p.plan, ['Aula', 'Licencia institucional', 'Más lugares en el Plan Escuela'], 'El plan')
      ctx.db.prepare('INSERT INTO requests (id, kind, data, created_at) VALUES (?, ?, ?, ?)').run(newId('req'), 'plan', JSON.stringify({ by: ctx.user.id, plan }), ctx.now)
    },
  },

  // ——— Soporte (pantalla 33) ———
  'report-problem': {
    apply(ctx, p) {
      const kind = text(p.kind, { min: 3, max: 60, label: 'el tipo de problema' })
      const message = text(p.message, { min: 3, max: 2000, label: 'la descripción' })
      ctx.db.prepare('INSERT INTO requests (id, kind, data, created_at) VALUES (?, ?, ?, ?)').run(newId('sop'), 'support', JSON.stringify({ by: ctx.user.id, kind, message }), ctx.now)
    },
  },
}

export function processChange(db, userRow, change) {
  const id = String(change?.id || '')
  if (!/^chg-[a-z0-9]{4,24}$/.test(id)) return { id, status: 'rejected', error: 'Identificador de cambio inválido.' }

  const seen = db.prepare('SELECT user_id, status, error FROM changes WHERE id = ?').get(id)
  if (seen) {
    if (seen.user_id !== userRow.id) return { id, status: 'rejected', error: 'Identificador repetido.' }
    return { id, status: seen.status, error: seen.error || undefined, duplicate: true }
  }

  const spaces = json(userRow.spaces, [])
  const handler = HANDLERS[change.type]
  const ctx = { db, user: userRow, staffId: staffIdOf(db, userRow.id), schoolId: userRow.school_id, now: Date.now() }
  const payload = change.payload && typeof change.payload === 'object' ? change.payload : {}
  const log = (status, error) =>
    db
      .prepare('INSERT INTO changes (id, user_id, type, payload, title, icon, status, error, created_at, received_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
      .run(id, userRow.id, String(change.type).slice(0, 40), JSON.stringify(payload).slice(0, 4000), String(change.title || change.type).slice(0, 140), String(change.icon || '133').slice(0, 4), status, error, Number(change.createdAt) || null, ctx.now)

  if (!handler || (handler.space && !spaces.includes(handler.space))) {
    const error = handler ? 'Tu cuenta no tiene permiso para este cambio.' : 'Tipo de cambio desconocido.'
    log('rejected', error)
    return { id, status: 'rejected', error }
  }
  try {
    const result = transaction(db, () => {
      const r = handler.apply(ctx, payload)
      log('applied', null)
      return r
    })
    return { id, status: 'applied', result: result || undefined }
  } catch (error) {
    if (!(error instanceof Rejected)) throw error
    log('rejected', error.message)
    return { id, status: 'rejected', error: error.message }
  }
}
