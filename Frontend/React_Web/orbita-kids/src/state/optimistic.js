// Aplica un cambio a los datos locales en cuanto la persona lo hace (también sin conexión).
// Cuando el servidor responde, sus datos reemplazan a estos y los cambios aún pendientes se vuelven a aplicar encima.

const MODE_LABEL = { visual: 'Sumas con apoyo visual', select: 'Selección de respuestas', both: 'Visual + selección' }
const MONTHS = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic']
const shortDate = (iso) => {
  if (!iso) return 'Sin fecha'
  const [, m, d] = iso.split('-').map(Number)
  return `${d} ${MONTHS[m - 1]}`
}

function patchTeacher(data, fn) {
  if (!data?.docente) return data
  return { ...data, docente: fn(data.docente) }
}
function patchInstitution(data, fn) {
  if (!data?.institucion) return data
  return { ...data, institucion: fn(data.institucion) }
}

function upsertActivity(t, p, status) {
  const group = t.groups.find((g) => g.id === p.groupId)
  const activity = {
    id: p.activityId,
    name: (p.name || '').trim() || 'Borrador sin nombre',
    kind: MODE_LABEL[p.mode] || p.mode,
    mode: p.mode,
    group: group?.name || '',
    groupId: p.groupId,
    level: Number(p.level),
    count: Number(p.count),
    due: shortDate(p.due),
    dueIso: p.due,
    status,
    done: 0,
    total: group?.students || 0,
    instructions: p.instructions || '',
    recipients: p.recipients || 'all',
    updatedAt: Date.now(),
    pending: true,
  }
  const others = t.activities.filter((a) => a.id !== activity.id)
  return { ...t, activities: [activity, ...others] }
}

const REDUCERS = {
  'publish-activity': (d, p) => patchTeacher(d, (t) => upsertActivity(t, p, 'active')),
  'save-draft': (d, p) => patchTeacher(d, (t) => upsertActivity(t, p, 'draft')),
  'delete-draft': (d, p) => patchTeacher(d, (t) => ({ ...t, activities: t.activities.filter((a) => a.id !== p.activityId) })),
  'close-activity': (d, p) => patchTeacher(d, (t) => ({ ...t, activities: t.activities.map((a) => (a.id === p.activityId ? { ...a, status: 'closed' } : a)) })),
  'assign-reinforcement': (d, p) =>
    patchTeacher(d, (t) => ({
      ...t,
      students: t.students.map((s) => (s.id === p.studentId ? { ...s, reinforcement: { topic: p.topic, at: Date.now() } } : s)),
      needSupport: t.needSupport.map((s) => (s.id === p.studentId ? { ...s, reinforcement: { topic: p.topic, at: Date.now() } } : s)),
    })),
  'mark-notices-read': (d, p) => {
    const ids = new Set(p.ids)
    const read = (list) => list.map((n) => (ids.has(n.id) ? { ...n, unread: false } : n))
    return patchInstitution(
      patchTeacher(d, (t) => ({ ...t, notices: read(t.notices) })),
      (i) => ({ ...i, notices: read(i.notices) }),
    )
  },
  'update-preferences': (d, p) => (d?.user ? { ...d, user: { ...d.user, prefs: { ...d.user.prefs, ...p } } } : d),
  'invite-teacher': (d, p) =>
    patchInstitution(d, (i) => {
      const name = p.name?.trim() || p.email.split('@')[0].split('.').map((w) => w[0].toUpperCase() + w.slice(1)).join(' ')
      const teacher = {
        id: `local-${p.email}`,
        name,
        initials: name.split(/\s+/).slice(0, 2).map((w) => w[0]).join('').toUpperCase(),
        color: '#5776e0',
        email: p.email,
        groups: '',
        students: 0,
        status: 'invited',
        note: 'Invitación por enviar',
        last: '—',
        pending: true,
      }
      return { ...i, teachers: [...i.teachers, teacher] }
    }),
  'review-teacher': (d, p) =>
    patchInstitution(d, (i) => ({
      ...i,
      teachers:
        p.decision === 'approve'
          ? i.teachers.map((t) => (t.id === p.staffId ? { ...t, status: 'active', note: undefined, groups: 'Sin grupo', last: 'Ahora' } : t))
          : i.teachers.filter((t) => t.id !== p.staffId),
      pending: i.pending.filter((x) => x.id !== `req-${p.staffId}`),
    })),
  'set-teacher-status': (d, p) => patchInstitution(d, (i) => ({ ...i, teachers: i.teachers.map((t) => (t.id === p.staffId ? { ...t, status: p.status } : t)) })),
  'resend-invite': (d, p) => patchInstitution(d, (i) => ({ ...i, teachers: i.teachers.map((t) => (t.id === p.staffId ? { ...t, note: 'Invitación reenviada' } : t)) })),
  'create-group': (d, p) =>
    patchInstitution(d, (i) => {
      const teacher = i.teachers.find((t) => t.id === p.teacherId)
      const group = { id: `local-${p.code}`, name: p.name, grade: Number(p.name[0]) || 0, teacher: teacher?.name || '', teacherId: p.teacherId, used: 0, seats: Number(p.seats), code: p.code, until: p.until, status: 'active', joinRequests: 0, score: 0, pending: true }
      return { ...i, groups: [...i.groups, group] }
    }),
  'update-group': (d, p) =>
    patchInstitution(d, (i) => ({
      ...i,
      groups: i.groups.map((g) => {
        if (g.id !== p.groupId) return g
        if (p.action === 'archive') return { ...g, status: 'archived' }
        if (p.action === 'restore') return { ...g, status: 'active' }
        if (p.action === 'renew') return { ...g, status: 'active', until: '31 jul 2027' }
        if (p.action === 'add-seats') return { ...g, status: 'active', seats: g.seats + 5 }
        return g
      }),
      pending: i.pending.filter((x) => x.id !== `exp-${p.groupId}` && x.id !== `full-${p.groupId}`),
    })),
  'update-settings': (d, p) => patchInstitution(d, (i) => ({ ...i, settings: { ...i.settings, ...p } })),
}

export function applyLocal(data, change) {
  const reducer = REDUCERS[change.type]
  if (!reducer || !data) return data
  try {
    return reducer(data, change.payload || {})
  } catch {
    return data
  }
}

export const applyAll = (data, changes) => changes.reduce(applyLocal, data)
