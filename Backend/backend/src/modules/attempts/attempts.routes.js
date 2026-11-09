import { Router } from 'express';
import { z } from 'zod';

import { insertOnce, sendReceived } from '../../db/idempotent.js';
import { isoDate, parse, syncId } from '../../lib/http.js';
import { requireRole } from '../../middleware/auth.js';
import { activityInGroup } from '../activities/activities.repository.js';

/** Payload que arma `FinishMission` en la app. */
const attemptBody = z
  .object({
    missionId: z.string().min(1).max(64),
    assigned: z.boolean().default(false),
    level: z.number().int().min(1).max(6),
    firstTry: z.number().int().min(0).max(1000),
    total: z.number().int().min(1).max(1000),
    attempts: z.number().int().min(0).max(10000),
    attemptIds: z.array(z.string().max(64)).max(1000).default([]),
    stars: z.number().int().min(0).max(3),
    support: z.boolean().default(false),
    rule: z.string().max(16).nullable().default(null),
    notifyTeacher: z.boolean().default(false),
    finishedAt: isoDate,
  })
  .refine((a) => a.firstTry <= a.total, { path: ['firstTry'], message: 'firstTry no puede ser mayor que total' });

export const attemptsRouter = Router();

/** Resultado de misión (cola `attempt`). Idempotente por `id`. */
attemptsRouter.post('/', requireRole('student'), async (req, res) => {
  const id = syncId(req);
  const a = parse(attemptBody, req.body);
  const { id: studentId, groupId } = req.user;
  // En tareas asignadas la app usa el ID de la actividad como `missionId`.
  const activityId = a.assigned ? await activityInGroup(a.missionId, groupId) : null;

  const result = await insertOnce({
    table: 'attempts',
    id,
    userColumn: 'student_id',
    userId: studentId,
    sql: `INSERT INTO attempts (id, student_id, group_id, mission_id, activity_id, level, first_try, total,
            attempts, stars, support, rule, notify_teacher, attempt_ids, finished_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    params: [
      id,
      studentId,
      groupId,
      a.missionId,
      activityId,
      a.level,
      a.firstTry,
      a.total,
      a.attempts,
      a.stars,
      a.support,
      a.rule,
      a.notifyTeacher,
      JSON.stringify(a.attemptIds),
      a.finishedAt,
    ],
  });
  sendReceived(res, id, result);
});
