import { Router } from 'express';
import { z } from 'zod';

import { withTransaction } from '../../db/pool.js';
import { effectiveStatus } from '../../domain/activities.js';
import { conflict, notFound, preconditionFailed } from '../../lib/errors.js';
import { isoDate, parse, parseIfMatch, setVersion, syncId } from '../../lib/http.js';
import { requireRole } from '../../middleware/auth.js';
import { findGroup } from '../groups/groups.repository.js';
import {
  findActivity,
  findForUpdate,
  insertActivity,
  listForStudent,
  listForTeacher,
  sameContent,
  updateActivity,
} from './activities.repository.js';

/**
 * `Activity.toJson()` de la app. `done` y `pendingSync` son de la app y se
 * ignoran. Los borradores viven en el teléfono: aquí solo llega lo publicado
 * (o `closed`, para cerrar antes de tiempo).
 */
const activityBody = z
  .object({
    name: z.string().trim().min(1, 'Escribe un nombre para la actividad.').max(80),
    groupId: z.string().min(1, 'Elige el grupo.').max(36),
    type: z.enum(['visual', 'choice', 'mix']),
    level: z.number().int().min(1).max(6),
    count: z.number().int().min(1).max(30),
    assigned: isoDate,
    due: isoDate,
    status: z.enum(['scheduled', 'active', 'closed']),
    instructions: z.string().trim().max(500).default(''),
  })
  .refine((a) => a.due >= a.assigned, { path: ['due'], message: 'La entrega debe ser después del inicio.' });

function send(res, a, status = 200) {
  setVersion(res, a.version);
  res.status(status).json(a);
}

export const activitiesRouter = Router();

activitiesRouter.get('/', async (req, res) => {
  const items =
    req.user.role === 'teacher'
      ? await listForTeacher(req.user.id, req.query.groupId ? String(req.query.groupId) : null)
      : await listForStudent(req.user.id, req.user.groupId);
  res.json({ items });
});

activitiesRouter.get('/:id', async (req, res) => {
  const a = await findActivity(req.params.id);
  const visible =
    a &&
    (req.user.role === 'teacher'
      ? (await findGroup(a.groupId))?.teacherId === req.user.id
      : a.groupId === req.user.groupId && a.status !== 'scheduled');
  if (!visible) throw notFound('Actividad no encontrada');
  send(res, a);
});

/**
 * Publicar o programar (cola `activityDraft`). Idempotente por `id`:
 * - nuevo → 201;
 * - mismo contenido (reintento) → 200 sin cambios;
 * - `If-Match` con otra versión → 412; actividad ya cerrada o de otra persona → 409.
 */
activitiesRouter.post('/', requireRole('teacher'), async (req, res) => {
  const id = syncId(req);
  const a = { id, ...parse(activityBody, req.body) };
  const ifMatch = parseIfMatch(req.get('If-Match'));

  const group = await findGroup(a.groupId);
  if (!group || group.teacherId !== req.user.id) throw notFound('Grupo no encontrado');
  if (group.status === 'archived') throw conflict('Ese grupo está archivado', 'group_archived');

  const created = await withTransaction(async (conn) => {
    const row = await findForUpdate(conn, id);
    if (!row) {
      await insertActivity(conn, req.user.id, a);
      return true;
    }
    if (row.teacher_id !== req.user.id) throw conflict('Ese ID ya se usó para otra actividad', 'id_taken');
    if (ifMatch != null && ifMatch !== row.version) throw preconditionFailed();
    if (sameContent(row, a)) return false;
    const current = effectiveStatus({ status: row.status, assignedAt: row.assigned_at, dueAt: row.due_at }, new Date());
    if (current === 'closed') throw conflict('La actividad ya está cerrada', 'activity_closed');
    await updateActivity(conn, a);
    return false;
  });

  send(res, await findActivity(id), created ? 201 : 200);
});
