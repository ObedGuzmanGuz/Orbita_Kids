// Datos iniciales de la demostración: los mismos del prototipo de Figma, ahora guardados en la base de datos.
import { hashPassword, newDataKey } from './security.js'

export const DEMO_PASSWORD = 'orbita'
export const DEMO_OTP = '246810'
export const SCHOOL_ID = 'primaria-demo'
export const CYCLE = '2026-27'

const USERS = [
  { id: 'ana', username: 'ana.rios', email: 'ana.rios@escuela.example', name: 'Ana Ríos', short: 'Mtra. Ana', initials: 'AR', color: '#3fbcc6', role_label: 'Docente', spaces: ['docente'] },
  { id: 'laura', username: 'laura.mendez', email: 'laura.mendez@escuela.example', name: 'Laura Méndez', short: 'Lic. Laura', initials: 'LM', color: '#e0a53a', role_label: 'Dirección', spaces: ['docente', 'institucion'], two_factor: 1 },
  // Raúl tiene una invitación pendiente: todavía no puede entrar con contraseña.
  { id: 'raul', username: 'raul.dominguez', email: 'raul.dominguez@escuela.example', name: 'Raúl Domínguez', short: 'Mtro. Raúl', initials: 'RD', color: '#d6668a', role_label: 'Docente', spaces: ['docente'], status: 'invited', noPassword: true },
  { id: 'est-luna-m', username: 'luna.m', email: 'luna.m@alumnos.escuela.example', name: 'Luna M.', short: 'Luna', initials: 'LM', color: '#746be8', role_label: 'Estudiante', kind: 'student', spaces: [] },
  { id: 'est-luna-astro', username: 'luna.astro', email: 'luna.astro@alumnos.escuela.example', name: 'Luna Astro', short: 'Luna', initials: 'LA', color: '#746be8', role_label: 'Estudiante', kind: 'student', spaces: [] },
]

const STAFF = [
  { id: 'ana', user_id: 'ana', name: 'Ana Ríos', initials: 'AR', color: '#3fbcc6', email: 'ana.rios@escuela.example', status: 'active', last: 'Hoy 8:15' },
  { id: 'laura', user_id: 'laura', name: 'Laura Méndez', initials: 'LM', color: '#e0a53a', email: 'laura.mendez@escuela.example', status: 'active', last: 'Hoy 7:52', director: 1 },
  { id: 'jorge', name: 'Jorge Salas', initials: 'JS', color: '#746be8', email: 'jorge.salas@escuela.example', status: 'active', last: 'Ayer' },
  { id: 'patricia', name: 'Patricia Núñez', initials: 'PN', color: '#4dbb98', email: 'patricia.nunez@escuela.example', status: 'active', last: 'Hace 3 días' },
  { id: 'ivan', name: 'Iván Ortega', initials: 'IO', color: '#a35bd6', email: 'ivan.ortega@escuela.example', status: 'active', last: 'Hoy 9:03' },
  { id: 'sofia', name: 'Sofía Cárdenas', initials: 'SC', color: '#5776e0', email: 'sofia.cardenas@escuela.example', status: 'request', note: 'Pidió acceso como docente el 28 oct' },
  { id: 'raul', user_id: 'raul', name: 'Raúl Domínguez', initials: 'RD', color: '#d6668a', email: 'raul.dominguez@escuela.example', status: 'invited', note: 'Invitación enviada el 27 oct' },
]

// size/score solo para los grupos cuya lista se genera; 2° A, 2° B y 3° A tienen lista escrita a mano.
const GROUPS = [
  { id: '1a', name: '1° A', grade: 1, teacher: 'jorge', seats: 20, code: 'ORB-1A5D', until: '31 jul 2027', status: 'active', size: 15, score: 74, completed: 18 },
  { id: '1b', name: '1° B', grade: 1, teacher: 'jorge', seats: 20, code: 'ORB-1B4T', until: '4 nov 2026', status: 'expiring', size: 14, score: 69, completed: 14 },
  { id: '1c', name: '1° C', grade: 1, teacher: 'patricia', seats: 20, code: 'ORB-1C8W', until: '31 jul 2027', status: 'active', size: 15, score: 71, completed: 16 },
  { id: '2a', name: '2° A', grade: 2, teacher: 'ana', seats: 15, code: 'ORB-2A7K', until: '31 jul 2027', status: 'active', completed: 13 },
  { id: '2b', name: '2° B', grade: 2, teacher: 'ana', seats: 15, code: 'ORB-2B3M', until: '31 jul 2027', status: 'active', completed: 11 },
  { id: '2c', name: '2° C', grade: 2, teacher: 'ivan', seats: 15, code: 'ORB-2C6H', until: '31 jul 2027', status: 'active', size: 13, score: 70, completed: 12 },
  { id: '3a', name: '3° A', grade: 3, teacher: 'ana', seats: 15, code: 'ORB-3A9Q', until: '31 jul 2027', status: 'active', completed: 15 },
  { id: '3b', name: '3° B', grade: 3, teacher: 'laura', seats: 15, code: 'ORB-3B2R', until: '31 jul 2027', status: 'active', size: 14, score: 80, completed: 17 },
  { id: '3c', name: '3° C', grade: 3, teacher: 'ivan', seats: 15, code: 'ORB-3C7N', until: '31 jul 2027', status: 'full', size: 14, score: 73, completed: 13, join_requests: 1 },
  // Grupo del ciclo anterior de la Mtra. Ana.
  { id: '1c-2025', name: '1° C', grade: 1, teacher: 'ana', seats: 20, code: 'ORB-1C2P', until: '31 jul 2026', status: 'archived', size: 20, score: 75, completed: 40, cycle: '2025-26', archived: true },
]

// [nombre, color, aciertos, intentos, pendientes, estado, última actividad, tema de apoyo]
const ROSTERS = {
  '2a': [
    ['Luna M.', '#746be8', 84, 26, 2, 'idle', 'Hace 7 días'],
    ['Mateo R.', '#3fbcc6', 88, 51, 2, 'ok', 'Hace 6 días'],
    ['Sofía G.', '#4dbb98', 72, 50, 2, 'idle', 'Hace 8 días'],
    ['Diego L.', '#e0a53a', 61, 26, 0, 'support', 'Hace 3 días', 'Sumas que pasan de 10'],
    ['Valeria P.', '#a35bd6', 65, 59, 2, 'support', 'Hace 6 días', 'Volver a contar el primer grupo'],
    ['Emiliano C.', '#5776e0', 78, 29, 2, 'ok', 'Hace 3 días'],
    ['Camila H.', '#746be8', 68, 56, 1, 'idle', 'Hace 7 días'],
    ['Santiago T.', '#3fbcc6', 89, 83, 1, 'ok', 'Hoy'],
    ['Regina V.', '#4dbb98', 81, 43, 2, 'idle', 'Hace 7 días'],
    ['Iker S.', '#e0a53a', 81, 47, 2, 'ok', 'Hace 1 día'],
    ['Ximena D.', '#a35bd6', 71, 32, 0, 'ok', 'Hoy'],
    ['Leonardo F.', '#5776e0', 58, 59, 0, 'support', 'Hace 3 días', 'Volver a contar el primer grupo'],
  ],
  '2b': [
    ['Renata A.', '#d6668a', 62, 38, 2, 'support', 'Hace 2 días', 'Sumas que pasan de 10'],
    ['Tomás B.', '#4f9e6b', 64, 44, 1, 'support', 'Hace 3 días', 'Volver a contar el primer grupo'],
    ['Julia C.', '#5776e0', 82, 41, 1, 'ok', 'Hoy'],
    ['Andrés D.', '#a35bd6', 71, 35, 2, 'ok', 'Hace 1 día'],
    ['Paula E.', '#e0a53a', 79, 47, 0, 'ok', 'Hoy'],
    ['Gael F.', '#746be8', 68, 29, 2, 'idle', 'Hace 7 días'],
    ['Mía G.', '#3fbcc6', 88, 52, 0, 'ok', 'Hace 2 días'],
    ['Bruno H.', '#4dbb98', 73, 39, 1, 'ok', 'Hace 1 día'],
    ['Elena I.', '#5776e0', 80, 45, 1, 'ok', 'Hoy'],
    ['Hugo J.', '#a35bd6', 73, 32, 0, 'idle', 'Hace 7 días'],
  ],
  '3a': [
    ['Fernanda U.', '#a35bd6', 60, 47, 2, 'support', 'Hace 2 días', 'Sumas que pasan de 10'],
    ['Abril T.', '#746be8', 61, 51, 1, 'support', 'Hace 1 día', 'Sumas que pasan de 10'],
    ['Daniel K.', '#5776e0', 88, 44, 1, 'ok', 'Hoy'],
    ['Sara L.', '#3fbcc6', 92, 52, 0, 'ok', 'Hoy'],
    ['Pablo M.', '#e0a53a', 79, 38, 2, 'idle', 'Hace 7 días'],
    ['Lucía N.', '#4dbb98', 90, 49, 0, 'ok', 'Hace 1 día'],
    ['Marco O.', '#a35bd6', 83, 41, 1, 'ok', 'Hace 2 días'],
    ['Ana P.', '#746be8', 86, 46, 1, 'ok', 'Hoy'],
    ['Rodrigo Q.', '#5776e0', 81, 43, 1, 'idle', 'Hace 7 días'],
    ['Natalia R.', '#3fbcc6', 87, 48, 0, 'ok', 'Hace 3 días'],
    ['Joaquín S.', '#e0a53a', 84, 39, 0, 'ok', 'Hace 1 día'],
  ],
}

const REPORTS = {
  '2a': {
    trend: '▲ 14 pts',
    weekly: [61, 64, 66, 71, 72, 75],
    errors: [
      { label: 'Volver a contar el primer grupo', count: 7 },
      { label: 'Sumar decenas con unidades', count: 7 },
      { label: 'Sumas que pasan de 10', count: 5 },
      { label: 'Respuestas con un número de más', count: 4 },
    ],
  },
  '2b': {
    trend: '▲ 9 pts',
    weekly: [65, 66, 69, 70, 72, 74],
    errors: [
      { label: 'Sumas que pasan de 10', count: 5 },
      { label: 'Volver a contar el primer grupo', count: 4 },
      { label: 'Respuestas con un número de más', count: 2 },
    ],
  },
  '3a': {
    trend: '▲ 11 pts',
    weekly: [70, 73, 75, 77, 79, 81],
    errors: [
      { label: 'Sumar decenas con unidades', count: 4 },
      { label: 'Sumas que pasan de 10', count: 3 },
    ],
  },
}

const ACTIVITIES = [
  { id: 'estrellas-10', teacher: 'ana', group: '2a', name: 'Estrellas hasta 10', mode: 'visual', level: 2, count: 8, due: '2026-10-31', status: 'active', done: 9 },
  { id: 'seleccion-rapida', teacher: 'ana', group: '2b', name: 'Selección rápida', mode: 'select', level: 2, count: 10, due: '2026-11-02', status: 'active', done: 6 },
  { id: 'sumas-20', teacher: 'ana', group: '2a', name: 'Sumas hasta 20', mode: 'select', level: 4, count: 10, due: '2026-11-03', status: 'active', done: 4 },
  { id: 'decenas-orbita', teacher: 'ana', group: '3a', name: 'Decenas en órbita', mode: 'visual', level: 5, count: 12, due: '2026-10-24', status: 'closed', done: 11 },
  { id: 'repaso-semana', teacher: 'ana', group: '3a', name: 'Repaso de la semana', mode: 'select', level: 3, count: 8, due: '2026-11-11', status: 'scheduled', done: 0 },
  { id: 'cometas-10', teacher: 'laura', group: '3b', name: 'Cometas de 10 en 10', mode: 'visual', level: 3, count: 8, due: '2026-11-05', status: 'active', done: 12 },
  { id: 'decenas-3b', teacher: 'laura', group: '3b', name: 'Sumas con decenas', mode: 'select', level: 4, count: 10, due: '2026-11-12', status: 'active', done: 5 },
]

const NOTICES = [
  { id: 'n1', user: 'ana', space: 'docente', icon: '072', title: '9 de 12 entregaron «Estrellas hasta 10»', meta: '2° A · hace 1 h', to: '/docente/actividades', unread: 1 },
  { id: 'n2', user: 'ana', space: 'docente', icon: '073', title: 'Diego L. necesita apoyo en sumas que pasan de 10', meta: '2° A · hoy 8:15', to: '/docente/estudiantes/diego-l', unread: 1 },
  { id: 'n3', user: 'ana', space: 'docente', icon: '074', title: 'Se sincronizaron 6 intentos de 2° B', meta: 'Ayer 18:40', to: '/docente/sincronizacion', unread: 1 },
  { id: 'n4', user: 'ana', space: 'docente', icon: '100', title: 'La dirección aprobó tu grupo 3° A para el ciclo 2026-27', meta: '27 oct', to: '/docente/grupos', unread: 0 },
  { id: 'l1', user: 'laura', space: 'docente', icon: '072', title: '12 de 14 entregaron «Cometas de 10 en 10»', meta: '3° B · hace 2 h', to: '/docente/actividades', unread: 1 },
  { id: 'l2', user: 'laura', space: 'docente', icon: '074', title: 'Se sincronizaron 9 intentos de 3° B', meta: 'Ayer 17:20', to: '/docente/sincronizacion', unread: 0 },
  { id: 'i1', user: 'laura', space: 'institucion', icon: '112', title: 'Sofía Cárdenas pidió acceso como docente', meta: 'Docentes · 28 oct', to: '/institucion/docentes?filtro=solicitudes', unread: 1 },
  { id: 'i2', user: 'laura', space: 'institucion', icon: '113', title: 'El código ORB-1B4T vence el 4 nov', meta: '1° B · Jorge Salas', to: '/institucion/grupos', unread: 1 },
  { id: 'i3', user: 'laura', space: 'institucion', icon: '114', title: 'La licencia llegó al 79 %', meta: 'Licencia y plan · ayer', to: '/institucion/licencia', unread: 1 },
  { id: 'i4', user: 'laura', space: 'institucion', icon: '100', title: 'Se aprobó el grupo 3° A para el ciclo 2026-27', meta: '27 oct', to: '/institucion/grupos', unread: 0 },
]

const SCHOOL_REPORT = {
  weeklySessions: [212, 248, 231, 266, 290, 305],
  errorTopics: [
    { label: 'Sumas que pasan de 10', value: 41 },
    { label: 'Sumar decenas con unidades', value: 27 },
    { label: 'Volver a contar el primer grupo', value: 19 },
    { label: 'Confundir +1 y +2', value: 13 },
  ],
  openGroups: ['1° A', '1° B', '2° C', '3° C'],
}

// Listas generadas de forma determinista para los grupos que el prototipo no detalla.
const FIRST_NAMES = [
  'Mariana', 'Emilio', 'Valentina', 'Sebastián', 'Isabella', 'Matías', 'Daniela', 'Nicolás', 'Victoria', 'Gabriel',
  'Jimena', 'Adrián', 'Luciana', 'Alejandro', 'Romina', 'Maximiliano', 'Constanza', 'Julián', 'Montserrat', 'Aarón',
  'Paulina', 'Ángel', 'Frida', 'Samuel', 'Andrea', 'Leonel', 'Carolina', 'Damián', 'Alexa', 'Rafael',
  'Danna', 'Ricardo', 'Itzel', 'Óscar', 'Abigail', 'Fernando', 'Melissa', 'Arturo', 'Karla', 'Ernesto',
]
const LAST_INITIALS = 'ABCDEFGHIJKLMNOPRSTUVZ'
const COLORS = ['#5776e0', '#a35bd6', '#e0a53a', '#746be8', '#3fbcc6', '#4dbb98', '#d6668a', '#4f9e6b']
const OFFSETS = [6, -6, 11, -11, 3, -3, 8, -8, 1, -1, 13, -13, 4, -4, 9, -9, 2, -2, 5, -5]
const TOPICS = ['Sumas que pasan de 10', 'Volver a contar el primer grupo', 'Sumar decenas con unidades']
const LASTS = ['Hoy', 'Hace 1 día', 'Hace 2 días', 'Hace 3 días']

const slug = (text) =>
  text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
const initialsOf = (name) =>
  name
    .split(/\s+/)
    .map((p) => p[0])
    .join('')
    .toUpperCase()

function generateRoster(group) {
  const salt = group.id.split('').reduce((n, c) => n + c.charCodeAt(0), 0)
  const used = new Set()
  const offsets = OFFSETS.slice(0, group.size - (group.size % 2))
  if (group.size % 2) offsets.push(0)
  return offsets.map((offset, i) => {
    let k = (salt * 7 + i * 11) % FIRST_NAMES.length
    let name = `${FIRST_NAMES[k]} ${LAST_INITIALS[(salt + i * 5) % LAST_INITIALS.length]}.`
    while (used.has(name)) {
      k = (k + 1) % FIRST_NAMES.length
      name = `${FIRST_NAMES[k]} ${LAST_INITIALS[(salt + i * 5) % LAST_INITIALS.length]}.`
    }
    used.add(name)
    const score = group.score + offset
    const status = group.archived ? 'ok' : offset <= -8 ? 'support' : i % 4 === 3 ? 'idle' : 'ok'
    return {
      name,
      color: COLORS[(salt + i) % COLORS.length],
      score,
      attempts: 20 + ((i * 17 + salt) % 55),
      pending: group.archived ? 0 : i % 3,
      status,
      last: group.archived ? 'Jul 2026' : status === 'support' ? 'Hace 3 días' : status === 'idle' ? 'Hace 7 días' : LASTS[i % LASTS.length],
      topic: status === 'support' ? TOPICS[i % TOPICS.length] : null,
    }
  })
}

function generatedReport(group) {
  const s = group.score
  const weekly = [s - 8, s - 6, s - 5, s - 3, s - 1, s]
  return {
    trend: `▲ ${weekly[5] - weekly[0]} pts`,
    weekly,
    errors: [
      { label: 'Sumas que pasan de 10', count: 4 },
      { label: 'Sumar decenas con unidades', count: 3 },
      { label: 'Volver a contar el primer grupo', count: 2 },
    ],
  }
}

export async function seed(db) {
  const now = Date.now()
  const passwordHash = await hashPassword(DEMO_PASSWORD)
  const insert = (sql) => db.prepare(sql)

  db.exec('BEGIN')
  try {
    insert('INSERT INTO schools (id, name, plan, cycle, seats_total, settings) VALUES (?, ?, ?, ?, ?, ?)').run(
      SCHOOL_ID,
      'Primaria Demo Órbita',
      'Plan Escuela',
      CYCLE,
      150,
      JSON.stringify({ displayName: 'Escuela Primaria Demo Órbita', timezone: 'America/Mexico_City', autoApprove: false, twoStep: true, idleLogout: true }),
    )

    const addUser = insert(`INSERT INTO users (id, school_id, username, email, name, short, initials, color, role_label, kind, status, spaces, password_hash, two_factor, data_key, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
    for (const u of USERS) {
      addUser.run(u.id, SCHOOL_ID, u.username, u.email, u.name, u.short, u.initials, u.color, u.role_label, u.kind || 'staff', u.status || 'active', JSON.stringify(u.spaces), u.noPassword ? null : passwordHash, u.two_factor || 0, newDataKey(), now)
    }

    const addStaff = insert('INSERT INTO staff (id, school_id, user_id, name, initials, color, email, status, note, last, director, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
    for (const t of STAFF) {
      addStaff.run(t.id, SCHOOL_ID, t.user_id || null, t.name, t.initials, t.color, t.email, t.status, t.note || null, t.last || '—', t.director || 0, now)
    }

    const addGroup = insert(`INSERT INTO class_groups (id, school_id, teacher_id, name, short, level, grade, code, seats, until, status, cycle, join_requests, completed, report)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
    const addStudent = insert('INSERT INTO students (id, group_id, name, initials, color, score, attempts, pending, status, last, topic) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')
    for (const g of GROUPS) {
      const cycle = g.cycle || CYCLE
      const level = `${g.grade}.º de primaria${cycle === CYCLE ? '' : ` · ciclo ${cycle}`}`
      const report = REPORTS[g.id] || generatedReport(g)
      addGroup.run(g.id, SCHOOL_ID, g.teacher, g.name, g.name.replace(' ', ''), level, g.grade, g.code, g.seats, g.until, g.status, cycle, g.join_requests || 0, g.completed, JSON.stringify({ month: 'Octubre 2026', ...report }))

      const roster = ROSTERS[g.id]
        ? ROSTERS[g.id].map(([name, color, score, attempts, pending, status, last, topic]) => ({ name, color, score, attempts, pending, status, last, topic }))
        : generateRoster(g)
      for (const s of roster) {
        const id = ROSTERS[g.id] ? slug(s.name) : `${slug(s.name)}-${g.id}`
        addStudent.run(id, g.id, s.name, initialsOf(s.name), s.color, s.score, s.attempts, s.pending, s.status, s.last, s.topic || null)
      }
    }

    const sizes = Object.fromEntries(db.prepare('SELECT group_id, COUNT(*) AS n FROM students GROUP BY group_id').all().map((r) => [r.group_id, r.n]))
    const addActivity = insert(`INSERT INTO activities (id, teacher_id, group_id, name, mode, level, count, due, status, done, total, instructions, recipients, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'all', ?, ?)`)
    ACTIVITIES.forEach((a, i) => {
      const created = now - (i + 1) * 86400000 // la primera de la lista es la más reciente
      addActivity.run(a.id, a.teacher, a.group, a.name, a.mode, a.level, a.count, a.due, a.status, a.done, sizes[a.group], 'Cuenta los objetos antes de responder.', created, created)
    })

    const addNotice = insert('INSERT INTO notices (id, user_id, space, icon, title, meta, to_path, unread, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)')
    NOTICES.forEach((n, i) => addNotice.run(n.id, n.user, n.space, n.icon, n.title, n.meta, n.to, n.unread, now - i * 3600000))

    insert('INSERT INTO invitations (token, staff_id, invited_by, groups, expires) VALUES (?, ?, ?, ?, ?)').run(
      'inv-raul-demo',
      'raul',
      'Laura Méndez · Dirección',
      JSON.stringify(['1a', '1b']),
      '3 nov',
    )

    const addReport = insert('INSERT INTO reports (scope, data) VALUES (?, ?)')
    addReport.run('teacher:ana', JSON.stringify({ weekly: [63, 66, 68, 71, 73, 76] }))
    addReport.run('teacher:laura', JSON.stringify({ weekly: [72, 74, 75, 77, 78, 80] }))
    addReport.run(`school:${SCHOOL_ID}`, JSON.stringify(SCHOOL_REPORT))
    db.exec('COMMIT')
  } catch (error) {
    db.exec('ROLLBACK')
    throw error
  }
}
