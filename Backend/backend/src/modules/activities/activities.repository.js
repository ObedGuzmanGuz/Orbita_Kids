import { query } from '../../db/pool.js';
import { effectiveStatus } from '../../domain/activities.js';

function toActivity(r, done, now) {
  return {
    id: r.id,
    name: r.name,
    groupId: r.group_id,
    type: r.type,
    level: r.level,
    count: r.count,
    assigned: r.assigned_at.toISOString(),
    due: r.due_at.toISOString(),
    status: effectiveStatus({ status: r.status, assignedAt: r.assigned_at, dueAt: r.due_at }, now),
    done,
    instructions: r.instructions,
    version: r.version,
  };
}

/** Cuántos estudiantes distintos terminaron cada actividad. */
async function doneCounts(ids) {
  if (ids.length === 0) return new Map();
  const rows = await query(
    `SELECT activity_id, COUNT(DISTINCT student_id) AS n FROM attempts
     WHERE activity_id IN (?) GROUP BY activity_id`,
    [ids],
  );
  return new Map(rows.map((r) => [r.activity_id, Number(r.n)]));
}

async function withDone(rows, now = new Date()) {
  const counts = await doneCounts(rows.map((r) => r.id));
  return rows.map((r) => toActivity(r, counts.get(r.id) ?? 0, now));
}

export async function listForTeacher(teacherId, groupId) {
  const rows = await query(
    `SELECT a.* FROM activities a
     WHERE a.teacher_id = ? AND (? IS NULL OR a.group_id = ?)
     ORDER BY a.due_at DESC`,
    [teacherId, groupId ?? null, groupId ?? null],
  );
  return withDone(rows);
}

/** Actividades visibles para un estudiante: las publicadas de su grupo. */
export async function listForStudent(studentId, groupId) {
  if (!groupId) return [];
  const rows = await query(
    `SELECT a.*, EXISTS (SELECT 1 FROM attempts t WHERE t.activity_id = a.id AND t.student_id = ?) AS mine
     FROM activities a
     WHERE a.group_id = ? AND a.status IN ('scheduled', 'active', 'closed')
     ORDER BY a.due_at`,
    [studentId, groupId],
  );
  const now = new Date();
  const list = await withDone(rows, now);
  return list
    .map((a, i) => ({ ...a, completedByMe: Boolean(rows[i].mine) }))
    .filter((a) => a.status !== 'scheduled');
}

export async function findForUpdate(conn, id) {
  const [[r]] = await conn.query(`SELECT * FROM activities WHERE id = ? FOR UPDATE`, [id]);
  return r ?? null;
}

export async function findActivity(id) {
  const [r] = await query(`SELECT * FROM activities WHERE id = ?`, [id]);
  if (!r) return null;
  const [a] = await withDone([r]);
  return a;
}

export async function insertActivity(conn, teacherId, a) {
  await conn.query(
    `INSERT INTO activities (id, teacher_id, group_id, name, type, level, count, instructions, assigned_at, due_at, status)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [a.id, teacherId, a.groupId, a.name, a.type, a.level, a.count, a.instructions, a.assigned, a.due, a.status],
  );
}

export async function updateActivity(conn, a) {
  await conn.query(
    `UPDATE activities
     SET group_id = ?, name = ?, type = ?, level = ?, count = ?, instructions = ?,
         assigned_at = ?, due_at = ?, status = ?, version = version + 1
     WHERE id = ?`,
    [a.groupId, a.name, a.type, a.level, a.count, a.instructions, a.assigned, a.due, a.status, a.id],
  );
}

/** `true` si la fila ya tiene exactamente estos datos (reintento de la cola). */
export function sameContent(row, a) {
  return (
    row.group_id === a.groupId &&
    row.name === a.name &&
    row.type === a.type &&
    row.level === a.level &&
    row.count === a.count &&
    row.instructions === a.instructions &&
    row.assigned_at.getTime() === a.assigned.getTime() &&
    row.due_at.getTime() === a.due.getTime() &&
    row.status === a.status
  );
}

/** Actividad del grupo del estudiante (para enlazar un intento de tarea). */
export async function activityInGroup(id, groupId) {
  if (!groupId) return null;
  const [r] = await query(`SELECT id FROM activities WHERE id = ? AND group_id = ?`, [id, groupId]);
  return r?.id ?? null;
}
