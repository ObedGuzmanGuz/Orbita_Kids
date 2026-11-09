// Aplica en orden los archivos de db/migrations que aún no se han aplicado.
// Uso: npm run db:migrate
import { readdir, readFile } from 'node:fs/promises';
import { join } from 'node:path';
import mysql from 'mysql2/promise';

import { config } from '../src/config/env.js';

const dir = join(import.meta.dirname, '..', 'db', 'migrations');

const conn = await mysql.createConnection({ ...config.db, multipleStatements: true, timezone: 'Z' });
try {
  await conn.query(`CREATE TABLE IF NOT EXISTS schema_migrations (
    name VARCHAR(255) NOT NULL PRIMARY KEY,
    applied_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
  )`);
  const [rows] = await conn.query('SELECT name FROM schema_migrations');
  const applied = new Set(rows.map((r) => r.name));
  const files = (await readdir(dir)).filter((f) => f.endsWith('.sql')).sort();

  let count = 0;
  for (const file of files) {
    if (applied.has(file)) continue;
    console.log(`→ ${file}`);
    // MySQL no revierte DDL en transacción: si una migración falla a medias,
    // hay que corregirla a mano antes de volver a correr.
    await conn.query(await readFile(join(dir, file), 'utf8'));
    await conn.query('INSERT INTO schema_migrations (name) VALUES (?)', [file]);
    count++;
  }
  console.log(count ? `${count} migración(es) aplicada(s).` : 'La base ya está al día.');
} finally {
  await conn.end();
}
