// ============================================================
//  DATOS DE DESARROLLO — NO SON DATOS REALES
// ============================================================
// Equivalen a `DemoData` de la app: nombres y escuelas ficticias. Todos los
// usuarios tienen ID `dev-*` (Keycloak nunca emite esos `sub`), así que el
// script puede borrarlos y volver a crearlos sin tocar cuentas reales.
// Uso: npm run db:seed   (con AUTH_MODE=dev: Authorization: Bearer dev:dev-ana-rios)
import { randomUUID } from 'node:crypto';
import mysql from 'mysql2/promise';

import { config } from '../src/config/env.js';

if (config.env === 'production') {
  console.error('db:seed no se ejecuta en producción.');
  process.exit(1);
}

const DAY = 24 * 60 * 60 * 1000;
const now = new Date();
const daysFromNow = (d) => new Date(now.getTime() + d * DAY);
const midnight = (d) => {
  const x = daysFromNow(d);
  return new Date(Date.UTC(x.getUTCFullYear(), x.getUTCMonth(), x.getUTCDate()));
};

/** Generador congruencial (misma idea que DemoData) para datos repetibles. */
function rng(seed) {
  let s = seed >>> 0 || 1;
  return () => {
    s = (Math.imul(s, 1664525) + 1013904223) >>> 0;
    return s / 4294967296;
  };
}

const INST_1 = '00000000-0000-4000-8000-000000000001';
const INST_2 = '00000000-0000-4000-8000-000000000002';
const LIC_1 = '00000000-0000-4000-8000-000000000101';
const LIC_2 = '00000000-0000-4000-8000-000000000102';
const G = {
  g2a: '00000000-0000-4000-8000-000000000201',
  g2b: '00000000-0000-4000-8000-000000000202',
  g3a: '00000000-0000-4000-8000-000000000203',
  g1c: '00000000-0000-4000-8000-000000000204',
  old: '00000000-0000-4000-8000-000000000205',
  full: '00000000-0000-4000-8000-000000000206',
};

const groups = [
  { id: G.g2a, name: '2° A', grade: '2.º de primaria', code: 'ORB-2A7K', inst: INST_1, lic: LIC_1, status: 'active', exp: daysFromNow(180) },
  { id: G.g2b, name: '2° B', grade: '2.º de primaria', code: 'ORB-2B3M', inst: INST_1, lic: LIC_1, status: 'active', exp: daysFromNow(180) },
  { id: G.g3a, name: '3° A', grade: '3.º de primaria', code: 'ORB-3A9Q', inst: INST_1, lic: LIC_1, status: 'active', exp: daysFromNow(180) },
  { id: G.g1c, name: '1° C', grade: '1.º de primaria · ciclo 2025-26', code: 'ORB-1C2P', inst: INST_1, lic: LIC_1, status: 'archived', exp: null },
  { id: G.old, name: '2° C', grade: '2.º de primaria', code: 'ORB-OLD1', inst: INST_1, lic: LIC_1, status: 'active', exp: daysFromNow(-10) },
  { id: G.full, name: '1° A', grade: '1.º de primaria', code: 'ORB-FULL', inst: INST_2, lic: LIC_2, status: 'active', exp: daysFromNow(180) },
];

const studentNames = {
  [G.g2a]: ['Mateo R.', 'Sofía G.', 'Diego L.', 'Valeria P.', 'Emiliano C.', 'Camila H.'],
  [G.g2b]: ['Renata A.', 'Gael M.', 'Natalia B.', 'Thiago R.'],
  [G.g3a]: ['Andrea S.', 'Nicolás P.', 'Mariana L.'],
  [G.g1c]: ['Hugo A.', 'Alma B.'],
  [G.full]: ['Pablo C.'],
};

const look = { character: 'luna', helmet: 'morado', suit: 'clasico', accessory: 'antena', expression: 'smile' };
const users = [
  { id: 'dev-ana-rios', role: 'teacher', name: 'Ana', username: 'ana.rios', email: 'ana.rios@escuela.example', inst: INST_1, group: null },
  { id: 'dev-luna-astro', role: 'student', name: 'Luna', username: 'luna.astro', email: null, inst: null, group: G.g2a },
  // Estudiante sin grupo: sirve para probar /v1/group-codes/redeem.
  { id: 'dev-nuevo', role: 'student', name: 'Astronauta', username: 'nuevo.astro', email: null, inst: null, group: null },
];
for (const [groupId, names] of Object.entries(studentNames)) {
  names.forEach((name, i) => {
    users.push({ id: `dev-s-${groupId.slice(-3)}-${i}`, role: 'student', name, username: null, email: null, inst: null, group: groupId });
  });
}

const activities = [
  { id: randomUUID(), group: G.g2a, name: 'Estrellas hasta 10', type: 'visual', level: 2, count: 8, assigned: midnight(-9), due: midnight(2), status: 'active', instructions: 'Cuenta los objetos antes de responder.' },
  { id: randomUUID(), group: G.g2a, name: 'Sumas hasta 20', type: 'choice', level: 4, count: 6, assigned: midnight(-2), due: midnight(5), status: 'active', instructions: 'Puedes usar tus dedos o dibujos para contar.' },
  { id: randomUUID(), group: G.g2b, name: 'Selección rápida', type: 'choice', level: 2, count: 10, assigned: midnight(-7), due: midnight(3), status: 'active', instructions: 'Lee la suma con calma y elige una opción.' },
  { id: randomUUID(), group: G.g3a, name: 'Decenas en órbita', type: 'visual', level: 5, count: 8, assigned: midnight(-18), due: midnight(-7), status: 'active', instructions: 'Las barras son decenas y los puntos, unidades.' },
  { id: randomUUID(), group: G.g3a, name: 'Repaso de la semana', type: 'choice', level: 3, count: 10, assigned: midnight(4), due: midnight(11), status: 'scheduled', instructions: 'Repaso de sumas hasta 20.' },
];

const conn = await mysql.createConnection({ ...config.db, timezone: 'Z' });
try {
  await conn.beginTransaction();

  // Limpieza de una corrida anterior (solo filas de desarrollo).
  await conn.query(`DELETE FROM attempts WHERE student_id LIKE 'dev-%'`);
  await conn.query(`DELETE FROM activities WHERE teacher_id LIKE 'dev-%'`);
  await conn.query(`DELETE FROM plan_requests WHERE user_id LIKE 'dev-%'`);
  await conn.query(`DELETE FROM support_reports WHERE user_id LIKE 'dev-%'`);
  await conn.query(`UPDATE users SET group_id = NULL WHERE id LIKE 'dev-%'`);
  await conn.query(`DELETE FROM school_groups WHERE teacher_id LIKE 'dev-%'`);
  await conn.query(`DELETE FROM users WHERE id LIKE 'dev-%'`);
  await conn.query(`DELETE FROM licenses WHERE id IN (?)`, [[LIC_1, LIC_2]]);
  await conn.query(`DELETE FROM institutions WHERE id IN (?)`, [[INST_1, INST_2]]);

  await conn.query(`INSERT INTO institutions (id, name, idp_alias) VALUES ?`, [
    [
      [INST_1, 'Escuela Primaria Demo Órbita', null],
      [INST_2, 'Colegio Demo Horizonte', null],
    ],
  ]);
  await conn.query(`INSERT INTO licenses (id, institution_id, plan_id, seats, starts_at, ends_at) VALUES ?`, [
    [
      [LIC_1, INST_1, 'escuela', 150, midnight(-60), null],
      // Un solo lugar, ya ocupado por «Pablo C.» → ORB-FULL responde «sin lugares».
      [LIC_2, INST_2, 'aula', 1, midnight(-60), null],
    ],
  ]);

  // Primero sin grupo (FK circular usuarios ↔ grupos).
  await conn.query(`INSERT INTO users (id, role, name, username, email, institution_id, look) VALUES ?`, [
    users.map((u) => [u.id, u.role, u.name, u.username, u.email, u.inst, u.role === 'student' ? JSON.stringify(look) : null]),
  ]);
  await conn.query(
    `INSERT INTO school_groups (id, teacher_id, institution_id, license_id, name, grade, code, code_expires_at, status) VALUES ?`,
    [groups.map((g) => [g.id, 'dev-ana-rios', g.inst, g.lic, g.name, g.grade, g.code, g.exp, g.status])],
  );
  for (const u of users.filter((x) => x.group)) {
    await conn.query(`UPDATE users SET group_id = ? WHERE id = ?`, [u.group, u.id]);
  }
  await conn.query(
    `INSERT INTO activities (id, teacher_id, group_id, name, type, level, count, instructions, assigned_at, due_at, status) VALUES ?`,
    [activities.map((a) => [a.id, 'dev-ana-rios', a.group, a.name, a.type, a.level, a.count, a.instructions, a.assigned, a.due, a.status])],
  );

  // Intentos de las últimas 5 semanas con un nivel de aciertos por estudiante.
  const attempts = [];
  const r = rng(29);
  for (const u of users.filter((x) => x.role === 'student' && x.group && x.group !== G.full)) {
    const base = u.id === 'dev-luna-astro' ? 0.84 : u.name === 'Diego L.' ? 0.6 : 0.58 + r() * 0.38;
    const lastDay = u.name === 'Camila H.' ? 12 : Math.floor(r() * 5); // Camila: sin actividad reciente
    const n = 4 + Math.floor(r() * 6);
    for (let i = 0; i < n; i++) {
      const total = 6;
      const firstTry = Math.max(0, Math.min(total, Math.round(total * (base + (r() - 0.5) * 0.2))));
      const finishedAt = daysFromNow(-(lastDay + Math.floor(r() * 30)) - r());
      const assignedActivity = i === 0 ? activities.find((a) => a.group === u.group && a.status === 'active') : null;
      attempts.push([
        randomUUID(), u.id, u.group, assignedActivity?.id ?? `m${1 + Math.floor(r() * 18)}`, assignedActivity?.id ?? null,
        assignedActivity?.level ?? 2, firstTry, total, total + (total - firstTry), firstTry >= 5 ? 3 : firstTry >= 3 ? 2 : 1,
        false, null, false, JSON.stringify([]), finishedAt,
      ]);
    }
  }
  await conn.query(
    `INSERT INTO attempts (id, student_id, group_id, mission_id, activity_id, level, first_try, total, attempts, stars,
       support, rule, notify_teacher, attempt_ids, finished_at) VALUES ?`,
    [attempts],
  );

  await conn.commit();
  console.log(`Listo: ${users.length} usuarios, ${groups.length} grupos, ${activities.length} actividades, ${attempts.length} intentos.`);
  console.log('Docente:    Authorization: Bearer dev:dev-ana-rios');
  console.log('Estudiante: Authorization: Bearer dev:dev-luna-astro  (sin grupo: dev:dev-nuevo)');
} catch (err) {
  await conn.rollback();
  throw err;
} finally {
  await conn.end();
}
