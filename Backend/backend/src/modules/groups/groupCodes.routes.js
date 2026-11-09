import { Router } from 'express';
import { rateLimit } from 'express-rate-limit';
import { z } from 'zod';

import { pool, withTransaction } from '../../db/pool.js';
import { CODE_MESSAGES, CODE_PATTERN, codeProblem, normalizeCode } from '../../domain/groupCodes.js';
import { HttpError } from '../../lib/errors.js';
import { parse } from '../../lib/http.js';
import { authenticate, requireRole } from '../../middleware/auth.js';
import { groupByCodeForUpdate, joinGroup, licenseForUpdate, seatsUsed } from './groups.repository.js';

const body = z.object({ code: z.string().max(20) });

/**
 * Revisa el código contra el grupo y la licencia. Bloquea las filas para que
 * dos estudiantes no ocupen el último lugar al mismo tiempo.
 */
async function check(conn, rawCode, userId) {
  const code = normalizeCode(rawCode);
  const row = CODE_PATTERN.test(code) ? await groupByCodeForUpdate(conn, code) : null;
  const group = row && { id: row.id, name: row.name, status: row.status, codeExpiresAt: row.code_expires_at };
  const license = row ? await licenseForUpdate(conn, row.license_id) : null;
  const used = row ? await seatsUsed(conn, row.license_id, userId) : 0;
  const reason = codeProblem({ group, license, seatsUsed: used, now: new Date() });
  return { group, reason };
}

// La pantalla 11 valida el código antes de crear la cuenta, así que este
// endpoint es público. El límite evita que se adivinen códigos.
const checkLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 15,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
  message: { error: { code: 'rate_limited', message: 'Demasiados intentos. Espera un minuto.' } },
});

export const groupCodesRouter = Router();

/** `GroupCodeCheck`: `{valid: true, groupName}` o `{valid: false, reason, error}`. */
groupCodesRouter.post('/check', checkLimiter, async (req, res) => {
  const { code } = parse(body, req.body);
  // Solo lectura: en autocommit los bloqueos duran lo que dura cada consulta.
  const { group, reason } = await check(pool, code, null);
  res.json(reason ? { valid: false, reason, error: CODE_MESSAGES[reason] } : { valid: true, groupName: group.name });
});

/** El estudiante autenticado se une al grupo (ocupa un lugar de la licencia). */
groupCodesRouter.post('/redeem', authenticate, requireRole('student'), async (req, res) => {
  const { code } = parse(body, req.body);
  const group = await withTransaction(async (conn) => {
    const r = await check(conn, code, req.user.id);
    if (r.reason) throw new HttpError(422, `code_${r.reason}`, CODE_MESSAGES[r.reason]);
    if (req.user.groupId !== r.group.id) await joinGroup(conn, req.user.id, r.group.id);
    return r.group;
  });
  res.json({ groupId: group.id, groupName: group.name });
});
