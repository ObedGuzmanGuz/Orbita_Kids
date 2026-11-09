import { Router } from 'express';
import { z } from 'zod';

import { config } from '../../config/env.js';
import { notFound, preconditionFailed } from '../../lib/errors.js';
import { parse, parseIfMatch, setVersion } from '../../lib/http.js';
import { requireRole } from '../../middleware/auth.js';
import {
  activeLicenseOf,
  createGroup,
  findGroup,
  findStudent,
  listByTeacher,
  publicGroup,
  regenerateCode,
  studentsOf,
  updateGroup,
} from './groups.repository.js';
import { summarize, trendLabels } from './students.service.js';

const groupName = z.string().trim().min(1).max(40);
// En la app el grado es opcional.
const grade = z.string().trim().max(80);

const createBody = z.object({ name: groupName, grade: grade.default('') });
const updateBody = z
  .object({ name: groupName, grade, status: z.enum(['active', 'archived']) })
  .partial();

/** Grupo del docente autenticado, o 404 (no se revela si existe para otros). */
async function ownGroup(req) {
  const g = await findGroup(req.params.id);
  if (!g || g.teacherId !== req.user.id) throw notFound('Grupo no encontrado');
  return g;
}

function sendGroup(res, g, status = 200) {
  setVersion(res, g.version);
  res.status(status).json(publicGroup(g));
}

export const groupsRouter = Router();
groupsRouter.use(requireRole('teacher'));

groupsRouter.get('/', async (req, res) => {
  const groups = await listByTeacher(req.user.id);
  res.json({ items: groups.map(publicGroup) });
});

groupsRouter.post('/', async (req, res) => {
  const body = parse(createBody, req.body);
  const institutionId = req.user.institutionId;
  const g = await createGroup({
    ...body,
    teacherId: req.user.id,
    institutionId,
    licenseId: await activeLicenseOf(institutionId),
    ttlDays: config.groupCodeTtlDays,
  });
  sendGroup(res, g, 201);
});

groupsRouter.get('/:id', async (req, res) => sendGroup(res, await ownGroup(req)));

groupsRouter.patch('/:id', async (req, res) => {
  const g = await ownGroup(req);
  const ok = await updateGroup(g.id, parse(updateBody, req.body), parseIfMatch(req.get('If-Match')));
  if (!ok) throw preconditionFailed('El grupo cambió en otro dispositivo. No se sobrescribió.');
  sendGroup(res, await findGroup(g.id));
});

/** Nuevo código (invalida el anterior); útil si se compartió por error o venció. */
groupsRouter.post('/:id/code', async (req, res) => {
  const g = await ownGroup(req);
  sendGroup(res, await regenerateCode(g.id, config.groupCodeTtlDays));
});

groupsRouter.get('/:id/students', async (req, res) => {
  const g = await ownGroup(req);
  const now = new Date();
  res.json({ weeks: trendLabels(now), items: await summarize(g, await studentsOf(g.id), now) });
});

export const studentsRouter = Router();
studentsRouter.use(requireRole('teacher'));

studentsRouter.get('/:id', async (req, res) => {
  const s = await findStudent(req.params.id);
  const g = s?.group_id ? await findGroup(s.group_id) : null;
  if (!g || g.teacherId !== req.user.id) throw notFound('Estudiante no encontrado');
  const now = new Date();
  const [summary] = await summarize(g, [s], now);
  res.json({ weeks: trendLabels(now), ...summary });
});
