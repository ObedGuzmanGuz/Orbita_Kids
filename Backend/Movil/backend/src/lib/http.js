import { z } from 'zod';

import { badRequest } from './errors.js';

/** Valida `data` con un esquema zod o lanza 400 con el detalle de cada campo. */
export function parse(schema, data) {
  const r = schema.safeParse(data);
  if (r.success) return r.data;
  throw badRequest(
    'Datos inválidos',
    r.error.issues.map((i) => ({ field: i.path.join('.'), message: i.message })),
  );
}

const hasZone = (s) => /(Z|[+-]\d{2}:?\d{2})$/i.test(s);
const withZone = (s) => (s.includes('T') && !hasZone(s) ? `${s}Z` : s);

/**
 * Fecha ISO 8601. Acepta la salida de `DateTime.toIso8601String()` de Dart
 * con o sin zona. Sin zona se toma como UTC, sin importar la zona del
 * servidor: así un día elegido con `showDatePicker` (medianoche local)
 * conserva su fecha de calendario.
 */
export const isoDate = z
  .string()
  .refine((s) => /^\d{4}-\d{2}-\d{2}/.test(s) && !Number.isNaN(Date.parse(withZone(s))), 'Fecha ISO 8601 inválida')
  .transform((s) => new Date(withZone(s)));

export const uuid = z.uuid();

/**
 * Lee `If-Match` (`"3"`, `W/"3"` o `3`). Devuelve el número de versión, o
 * `null` si no viene. `*` también se trata como ausente.
 */
export function parseIfMatch(header) {
  if (header == null) return null;
  const raw = String(header).trim().replace(/^W\//, '').replace(/^"|"$/g, '');
  if (raw === '' || raw === '*') return null;
  const n = Number(raw);
  if (!Number.isInteger(n) || n < 1) throw badRequest('If-Match debe ser la versión entregada en ETag');
  return n;
}

export function setVersion(res, version) {
  res.set('ETag', `"${version}"`);
}

/**
 * Cuerpo de la cola de sincronización: `{id, ...payload}` con el mismo UUID en
 * `Idempotency-Key`. Devuelve el ID verificado.
 */
export function syncId(req) {
  const id = parse(uuid, req.body?.id);
  const key = req.get('Idempotency-Key');
  if (key != null && key !== id) throw badRequest('Idempotency-Key no coincide con el id del cuerpo');
  return id;
}
