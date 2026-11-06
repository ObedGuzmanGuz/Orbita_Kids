import { conflict } from '../lib/errors.js';
import { isDuplicateKey, query } from './pool.js';

/**
 * Inserta un registro de la cola una sola vez. Si el ID ya existe y es del
 * mismo usuario, es un reintento: devuelve `{ created: false }` (la app lo
 * marca como confirmado). Si es de otro usuario, responde 409.
 */
export async function insertOnce({ table, id, userColumn, userId, sql, params }) {
  try {
    await query(sql, params);
    return { created: true };
  } catch (err) {
    if (!isDuplicateKey(err)) throw err;
    const [row] = await query(`SELECT ${userColumn} AS owner FROM ${table} WHERE id = ?`, [id]);
    if (row && row.owner === userId) return { created: false };
    throw conflict('Ese ID ya se usó para otro registro', 'id_taken');
  }
}

/** Respuesta estándar para la cola: 201 si es nuevo, 200 si ya existía. */
export function sendReceived(res, id, { created }) {
  res.status(created ? 201 : 200).json({ id, status: 'received' });
}
