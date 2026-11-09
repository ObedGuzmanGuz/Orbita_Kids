import { randomUUID } from 'node:crypto';

import { isDuplicateKey, query } from '../../db/pool.js';
import { generateCode } from '../../domain/groupCodes.js';

function toGroup(r) {
  return {
    id: r.id,
    name: r.name,
    grade: r.grade,
    code: r.code,
    status: r.status,
    codeExpiresAt: r.code_expires_at,
    students: Number(r.students ?? 0),
    version: r.version,
    teacherId: r.teacher_id,
    licenseId: r.license_id,
  };
}

const groupSelect = `SELECT g.*,
    (SELECT COUNT(*) FROM users s WHERE s.group_id = g.id AND s.role = 'student') AS students
  FROM school_groups g`;

/** Vista pública del grupo (lo que recibe la app). */
export function publicGroup(g) {
  const { teacherId, licenseId, ...rest } = g;
  return rest;
}

export async function listByTeacher(teacherId) {
  const rows = await query(`${groupSelect} WHERE g.teacher_id = ? ORDER BY g.status, g.name`, [teacherId]);
  return rows.map(toGroup);
}

export async function findGroup(id) {
  const [r] = await query(`${groupSelect} WHERE g.id = ?`, [id]);
  return r ? toGroup(r) : null;
}

/** Licencia vigente más reciente de la institución, o null. */
export async function activeLicenseOf(institutionId) {
  if (!institutionId) return null;
  const [r] = await query(
    `SELECT id FROM licenses
     WHERE institution_id = ? AND starts_at <= UTC_DATE() AND (ends_at IS NULL OR ends_at >= UTC_DATE())
     ORDER BY starts_at DESC LIMIT 1`,
    [institutionId],
  );
  return r?.id ?? null;
}

const codeExpiry = (ttlDays) => new Date(Date.now() + ttlDays * 24 * 60 * 60 * 1000);

/** Inserta con un código nuevo; reintenta si el código aleatorio ya existe. */
export async function createGroup({ teacherId, institutionId, licenseId, name, grade, ttlDays }) {
  const id = randomUUID();
  for (let i = 0; i < 8; i++) {
    try {
      await query(
        `INSERT INTO school_groups (id, teacher_id, institution_id, license_id, name, grade, code, code_expires_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [id, teacherId, institutionId, licenseId, name, grade, generateCode(), codeExpiry(ttlDays)],
      );
      return findGroup(id);
    } catch (err) {
      if (!isDuplicateKey(err)) throw err;
    }
  }
  throw new Error('No se pudo generar un código de grupo único');
}

/** Devuelve `false` si la versión no coincide (412). */
export async function updateGroup(id, { name, grade, status }, expectedVersion) {
  const res = await query(
    `UPDATE school_groups
     SET name = COALESCE(?, name), grade = COALESCE(?, grade), status = COALESCE(?, status),
         version = version + 1
     WHERE id = ? AND (? IS NULL OR version = ?)`,
    [name ?? null, grade ?? null, status ?? null, id, expectedVersion, expectedVersion],
  );
  return res.affectedRows === 1;
}

export async function regenerateCode(id, ttlDays) {
  for (let i = 0; i < 8; i++) {
    try {
      await query(
        `UPDATE school_groups SET code = ?, code_expires_at = ?, version = version + 1 WHERE id = ?`,
        [generateCode(), codeExpiry(ttlDays), id],
      );
      return findGroup(id);
    } catch (err) {
      if (!isDuplicateKey(err)) throw err;
    }
  }
  throw new Error('No se pudo generar un código de grupo único');
}

// ---------- Estudiantes y su actividad ----------

export async function studentsOf(groupId) {
  return query(`SELECT id, name FROM users WHERE group_id = ? AND role = 'student' ORDER BY name`, [groupId]);
}

export async function findStudent(id) {
  const [r] = await query(`SELECT id, name, group_id FROM users WHERE id = ? AND role = 'student'`, [id]);
  return r ?? null;
}

export async function attemptsOf(studentIds) {
  if (studentIds.length === 0) return [];
  const rows = await query(
    `SELECT t.id, t.student_id, t.mission_id, a.name AS activity_name, t.first_try, t.total,
            t.finished_at, t.notify_teacher
     FROM attempts t LEFT JOIN activities a ON a.id = t.activity_id
     WHERE t.student_id IN (?) ORDER BY t.finished_at`,
    [studentIds],
  );
  return rows.map((r) => ({
    id: r.id,
    missionId: r.mission_id,
    activityName: r.activity_name,
    studentId: r.student_id,
    firstTry: r.first_try,
    total: r.total,
    finishedAt: r.finished_at,
    notifyTeacher: Boolean(r.notify_teacher),
  }));
}

/** Actividades publicadas del grupo (para calcular pendientes). */
export async function publishedActivitiesOf(groupId) {
  const rows = await query(
    `SELECT id, status, assigned_at, due_at FROM activities
     WHERE group_id = ? AND status IN ('scheduled', 'active')`,
    [groupId],
  );
  return rows.map((r) => ({ id: r.id, status: r.status, assignedAt: r.assigned_at, dueAt: r.due_at }));
}

/** Pares (actividad, estudiante) con al menos un intento. */
export async function completions(activityIds) {
  if (activityIds.length === 0) return [];
  return query(
    `SELECT DISTINCT activity_id, student_id FROM attempts WHERE activity_id IN (?)`,
    [activityIds],
  );
}

// ---------- Códigos de grupo (con bloqueo, dentro de una transacción) ----------

export async function groupByCodeForUpdate(conn, code) {
  const [[r]] = await conn.query(`SELECT * FROM school_groups WHERE code = ? FOR UPDATE`, [code]);
  return r ?? null;
}

export async function licenseForUpdate(conn, licenseId) {
  if (!licenseId) return null;
  const [[r]] = await conn.query(`SELECT seats, ends_at FROM licenses WHERE id = ? FOR UPDATE`, [licenseId]);
  return r ? { seats: r.seats, endsAt: r.ends_at } : null;
}

/** Estudiantes que ocupan lugar en la licencia, sin contar a `exceptUserId`. */
export async function seatsUsed(conn, licenseId, exceptUserId) {
  if (!licenseId) return 0;
  const [[r]] = await conn.query(
    `SELECT COUNT(*) AS n FROM users u JOIN school_groups g ON g.id = u.group_id
     WHERE g.license_id = ? AND g.status = 'active' AND u.role = 'student' AND u.id <> ?`,
    [licenseId, exceptUserId ?? ''],
  );
  return Number(r.n);
}

export async function joinGroup(conn, userId, groupId) {
  await conn.query(`UPDATE users SET group_id = ?, version = version + 1 WHERE id = ?`, [groupId, userId]);
}
