import { Router } from 'express';
import { z } from 'zod';

import { insertOnce, sendReceived } from '../../db/idempotent.js';
import { parse, syncId } from '../../lib/http.js';

/** `QueuedPlansRepository.requestInfo` en la app. Sin pagos. */
const planRequestBody = z.object({
  plan: z.enum(['free', 'aula', 'escuela', 'inst']),
  period: z.enum(['mensual', 'anual']),
  institution: z.string().trim().min(1).max(160),
  contact: z.string().trim().min(1).max(160),
  students: z.number().int().min(0).max(1_000_000),
  message: z.string().trim().max(2000).default(''),
});

/** Pantalla de Ayuda (`info_screens.dart`): al menos 10 letras. */
const supportReportBody = z.object({
  topic: z.string().trim().min(1).max(80),
  text: z.string().trim().min(10, 'Cuéntanos un poco más (al menos 10 letras).').max(5000),
  version: z.string().max(32).nullable().default(null),
});

export const planRequestsRouter = Router();

planRequestsRouter.post('/', async (req, res) => {
  const id = syncId(req);
  const r = parse(planRequestBody, req.body);
  const result = await insertOnce({
    table: 'plan_requests',
    id,
    userColumn: 'user_id',
    userId: req.user.id,
    sql: `INSERT INTO plan_requests (id, user_id, plan_id, period, institution, contact, students, message)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    params: [id, req.user.id, r.plan, r.period, r.institution, r.contact, r.students, r.message],
  });
  sendReceived(res, id, result);
});

export const supportReportsRouter = Router();

supportReportsRouter.post('/', async (req, res) => {
  const id = syncId(req);
  const r = parse(supportReportBody, req.body);
  const result = await insertOnce({
    table: 'support_reports',
    id,
    userColumn: 'user_id',
    userId: req.user.id,
    sql: `INSERT INTO support_reports (id, user_id, topic, text, app_version) VALUES (?, ?, ?, ?, ?)`,
    params: [id, req.user.id, r.topic, r.text, r.version],
  });
  sendReceived(res, id, result);
});
