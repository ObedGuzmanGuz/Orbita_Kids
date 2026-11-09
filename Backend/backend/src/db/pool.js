import mysql from 'mysql2/promise';

import { config } from '../config/env.js';

/** Pool compartido. Las fechas viajan en UTC (`timezone: 'Z'`). */
export const pool = mysql.createPool({
  ...config.db,
  timezone: 'Z',
  charset: 'utf8mb4',
  waitForConnections: true,
  decimalNumbers: true,
});

/** Atajo para consultas: devuelve solo las filas. */
export async function query(sql, params = []) {
  const [rows] = await pool.query(sql, params);
  return rows;
}

/** Ejecuta `fn(conn)` dentro de una transacción; hace rollback si falla. */
export async function withTransaction(fn) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const result = await fn(conn);
    await conn.commit();
    return result;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

export function isDuplicateKey(err) {
  return err?.code === 'ER_DUP_ENTRY';
}
