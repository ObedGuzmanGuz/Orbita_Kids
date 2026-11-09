// Arma los datos que ve cada persona. Solo incluye lo que su rol le permite ver.
import { json } from './db.js'

export const MODE_LABEL = { visual: 'Sumas con apoyo visual', select: 'Selección de respuestas', both: 'Visual + selección' }
const MONTHS = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic']

export function shortDate(iso) {
  if (!iso) return 'Sin fecha'
  const [, m, d] = iso.split('-').map(Number)
  return `${d} ${MONTHS[m - 1]}`
}

export function todayLabel(date = new Date()) {
  return `${date.getDate()} ${MONTHS[date.getMonth()]}`
}

const avg = (values) => (values.length ? Math.round(values.reduce((a, b) => a + b, 0) / values.length) : 0)
const placeholders = (list) => list.map(() => '?').join(', ')

export function publicUser(row) {
  return {
    id: row.id,
    name: row.name,
    short: row.short,
    initials: row.initials,
    color: row.color,
    email: row.email,
    roleLabel: row.role_label,
    spaces: json(row.spaces, []),
    twoFactor: !!row.two_factor,
    prefs: json(row.prefs, {}),
  }
}

export const staffIdOf = (db, userId) => db.prepare('SELECT id FROM staff WHERE user_id = ?').get(userId)?.id || null

function statsByGroup(students) {
  const out = {}
  for (const s of students) {
    const g = (out[s.group_id] ||= { students: 0, scores: [], pending: 0, support: 0, attempts: 0 })
    g.students += 1
    g.scores.push(s.score)
    g.pending += s.pending
    g.attempts += s.attempts
    if (s.status === 'support') g.support += 1
  }
  for (const g of Object.values(out)) g.score = avg(g.scores)
  return out
}

function activityView(a, groupName) {
  return {
    id: a.id,
    name: a.name,
    kind: MODE_LABEL[a.mode] || a.mode,
    mode: a.mode,
    group: groupName,
    groupId: a.group_id,
    level: a.level,
    count: a.count,
    due: shortDate(a.due),
    dueIso: a.due,
    status: a.status,
    done: a.done,
    total: a.total,
    instructions: a.instructions,
    recipients: a.recipients,
    updatedAt: a.updated_at,
  }
}

function noticesFor(db, userId, space) {
  return db
    .prepare('SELECT * FROM notices WHERE user_id = ? AND space = ? ORDER BY created_at DESC')
    .all(userId, space)
    .map((n) => ({ id: n.id, icon: n.icon, title: n.title, meta: n.meta, to: n.to_path, unread: !!n.unread }))
}

export function teacherData(db, user) {
  const staffId = staffIdOf(db, user.id)
  const groups = db
    .prepare("SELECT * FROM class_groups WHERE teacher_id = ? OR support_teacher_id = ? ORDER BY status = 'archived', rowid")
    .all(staffId, staffId)
  const ids = groups.map((g) => g.id)
  const students = ids.length ? db.prepare(`SELECT * FROM students WHERE group_id IN (${placeholders(ids)}) ORDER BY rowid`).all(...ids) : []
  const activities = ids.length
    ? db.prepare(`SELECT * FROM activities WHERE group_id IN (${placeholders(ids)}) ORDER BY created_at DESC`).all(...ids)
    : []
  const reinforcements = students.length
    ? db.prepare(`SELECT student_id, topic, MAX(created_at) AS at FROM reinforcements WHERE teacher_id = ? GROUP BY student_id`).all(staffId)
    : []
  const lastReinforcement = Object.fromEntries(reinforcements.map((r) => [r.student_id, { topic: r.topic, at: r.at }]))
  const stats = statsByGroup(students)
  const nameOf = Object.fromEntries(groups.map((g) => [g.id, g.name]))

  const groupList = groups.map((g) => {
    const s = stats[g.id] || { students: 0, score: 0, pending: 0, support: 0 }
    return {
      id: g.id,
      name: g.name,
      short: g.short,
      level: g.level,
      students: s.students,
      score: s.score,
      pending: s.pending,
      completed: g.completed,
      support: s.support,
      progress: s.score,
      code: g.code,
      status: g.status === 'archived' ? 'archived' : 'active',
      role: g.teacher_id === staffId ? 'titular' : 'apoyo',
    }
  })

  const studentList = students.map((s) => ({
    id: s.id,
    name: s.name,
    initials: s.initials,
    color: s.color,
    group: s.group_id,
    score: s.score,
    attempts: s.attempts,
    pending: s.pending,
    status: s.status,
    last: s.last,
    topic: s.topic,
    reinforcement: lastReinforcement[s.id] || null,
  }))

  const activityList = activities.map((a) => activityView(a, nameOf[a.group_id]))

  const reports = {}
  for (const g of groups) {
    const r = json(g.report, {})
    const s = stats[g.id] || { score: 0, pending: 0, attempts: 0 }
    reports[g.id] = {
      month: r.month || '',
      trend: r.trend || '',
      weekly: r.weekly || [],
      errors: r.errors || [],
      score: s.score,
      completed: g.completed,
      pending: s.pending,
      attempts: s.attempts,
      support: studentList
        .filter((x) => x.group === g.id && x.status === 'support')
        .sort((a, b) => a.score - b.score)
        .map(({ id, name, initials, color, topic, score }) => ({ id, name, initials, color, topic, score })),
      participation: activityList
        .filter((a) => a.groupId === g.id && a.status !== 'draft')
        .map((a) => ({ label: a.name, done: a.done, total: a.total })),
    }
  }

  const activeIds = new Set(groupList.filter((g) => g.status === 'active').map((g) => g.id))
  const stored = json(db.prepare('SELECT data FROM reports WHERE scope = ?').get(`teacher:${staffId}`)?.data, null)
  const weeks = stored?.weekly || [0, 1, 2, 3, 4, 5].map((i) => avg([...activeIds].map((id) => reports[id].weekly[i]).filter(Number.isFinite)))
  const weekly = weeks.map((value, i) => ({ label: `S${i + 1}`, value }))

  return {
    groups: groupList,
    students: studentList,
    activities: activityList,
    reports,
    insights: { weekly, delta: weeks.length ? weeks[weeks.length - 1] - weeks[0] : 0 },
    needSupport: studentList
      .filter((s) => s.status === 'support' && activeIds.has(s.group))
      .sort((a, b) => a.score - b.score)
      .map((s) => ({ ...s, groupName: nameOf[s.group] })),
    notices: noticesFor(db, user.id, 'docente'),
  }
}

export function institutionData(db, user) {
  const school = db.prepare('SELECT * FROM schools WHERE id = ?').get(user.school_id)
  const groups = db
    .prepare('SELECT g.*, t.name AS teacher_name FROM class_groups g LEFT JOIN staff t ON t.id = g.teacher_id WHERE g.school_id = ? AND g.cycle = ? ORDER BY g.rowid')
    .all(school.id, school.cycle)
  const students = groups.length
    ? db.prepare(`SELECT group_id, score, pending, attempts, status FROM students WHERE group_id IN (${placeholders(groups.map((g) => g.id))})`).all(...groups.map((g) => g.id))
    : []
  const stats = statsByGroup(students)
  const staff = db.prepare('SELECT * FROM staff WHERE school_id = ? ORDER BY rowid').all(school.id)
  const report = json(db.prepare('SELECT data FROM reports WHERE scope = ?').get(`school:${school.id}`)?.data, {})

  const schoolGroups = groups.map((g) => ({
    id: g.id,
    name: g.name,
    grade: g.grade,
    teacher: g.teacher_name || 'Sin docente',
    teacherId: g.teacher_id,
    used: stats[g.id]?.students || 0,
    seats: g.seats,
    code: g.code,
    until: g.until,
    status: g.status,
    joinRequests: g.join_requests,
    score: stats[g.id]?.score || 0,
  }))
  const live = schoolGroups.filter((g) => g.status !== 'archived')
  const used = live.reduce((n, g) => n + g.used, 0)
  const license = { used, total: school.seats_total, plan: school.plan, cycle: `ciclo ${school.cycle}` }

  const teachers = staff.map((t) => {
    const own = live.filter((g) => g.teacherId === t.id)
    return {
      id: t.id,
      name: t.name,
      initials: t.initials,
      color: t.color,
      email: t.email,
      groups: own.map((g) => g.name).join(', ') || (t.status === 'active' ? 'Sin grupo' : ''),
      students: own.reduce((n, g) => n + g.used, 0),
      status: t.status,
      note: t.note || undefined,
      last: t.last,
      director: !!t.director,
    }
  })

  const pending = []
  for (const t of staff.filter((x) => x.status === 'request')) {
    const date = /el (\d+ \w+)$/.exec(t.note || '')?.[1]
    pending.push({ id: `req-${t.id}`, icon: '112', title: `${t.name} pidió acceso`, meta: `Docente${date ? ` · ${date}` : ''}`, action: 'Revisar', primary: true, to: '/institucion/docentes?filtro=solicitudes' })
  }
  for (const g of live.filter((x) => x.status === 'expiring')) {
    pending.push({ id: `exp-${g.id}`, icon: '113', title: `Código ${g.code} vence el ${g.until.replace(/ \d{4}$/, '')}`, meta: `${g.name} · ${g.teacher}`, action: 'Renovar', to: '/institucion/grupos' })
  }
  for (const g of live.filter((x) => x.status === 'full')) {
    const req = g.joinRequests ? ` · ${g.joinRequests} ${g.joinRequests === 1 ? 'solicitud' : 'solicitudes'} de ingreso` : ''
    pending.push({ id: `full-${g.id}`, icon: '073', title: `${g.name} no tiene lugares libres`, meta: `${g.used} de ${g.seats}${req}`, action: 'Ajustar', to: '/institucion/grupos' })
  }
  const pct = Math.round((used / school.seats_total) * 100)
  if (pct >= 75) {
    pending.push({ id: 'license', icon: '114', title: `Licencia al ${pct} %`, meta: pct >= 80 ? 'Considera ampliar el plan' : 'Te avisamos al 80 %', action: 'Ver', to: '/institucion/licencia' })
  }

  return {
    school: { id: school.id, name: school.name, plan: school.plan, cycle: school.cycle },
    settings: json(school.settings, {}),
    license,
    teachers,
    groups: schoolGroups,
    gradeProgress: [1, 2, 3].map((grade) => ({ label: `${grade}.º grado`, value: avg(live.filter((g) => g.grade === grade).map((g) => g.score)) })),
    weeklySessions: report.weeklySessions || [],
    groupScores: live.map((g) => ({ label: `${g.name} · ${g.teacher}`, grade: g.grade, value: g.score })),
    errorTopics: report.errorTopics || [],
    openGroups: report.openGroups || [],
    pending,
    notices: noticesFor(db, user.id, 'institucion'),
  }
}

export function recentChanges(db, userId, limit = 8) {
  return db
    .prepare('SELECT id, title, icon, status, error, created_at, received_at FROM changes WHERE user_id = ? ORDER BY received_at DESC LIMIT ?')
    .all(userId, limit)
    .map((c) => ({ id: c.id, title: c.title, icon: c.icon, status: c.status, error: c.error || undefined, createdAt: c.created_at, receivedAt: c.received_at }))
}

export function snapshot(db, userRow) {
  const user = publicUser(userRow)
  const school = db.prepare('SELECT name, plan, cycle FROM schools WHERE id = ?').get(userRow.school_id)
  const out = { user, school: { name: school.name, plan: school.plan, cycle: school.cycle }, changes: recentChanges(db, user.id), syncedAt: Date.now() }
  if (user.spaces.includes('docente')) out.docente = teacherData(db, userRow)
  if (user.spaces.includes('institucion')) out.institucion = institutionData(db, userRow)
  return out
}

// Resumen corto para la pantalla «Elegir espacio».
export function spaceSummary(db, userRow) {
  const spaces = json(userRow.spaces, [])
  const out = {}
  if (spaces.includes('docente')) {
    const t = teacherData(db, userRow)
    const active = t.groups.filter((g) => g.status === 'active')
    const students = active.reduce((n, g) => n + g.students, 0)
    const acts = t.activities.filter((a) => a.status === 'active').length
    out.docente = `${active.map((g) => g.name).join(', ') || 'Sin grupos'} · ${students} estudiantes · ${acts} ${acts === 1 ? 'actividad activa' : 'actividades activas'}`
  }
  if (spaces.includes('institucion')) {
    const school = db.prepare('SELECT name FROM schools WHERE id = ?').get(userRow.school_id)
    const { active, requests } = db
      .prepare("SELECT SUM(status = 'active') AS active, SUM(status = 'request') AS requests FROM staff WHERE school_id = ?")
      .get(userRow.school_id)
    out.institucion = `${school.name} · ${active} docentes · ${requests} ${requests === 1 ? 'solicitud' : 'solicitudes'}`
  }
  return out
}
