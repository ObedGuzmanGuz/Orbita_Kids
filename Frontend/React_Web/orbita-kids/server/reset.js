// Borra la base de datos de demostración. La próxima vez que arranque el servidor se crea de nuevo con los datos iniciales.
import { rmSync } from 'node:fs'
import { DEFAULT_DB_PATH } from './db.js'

const path = process.env.DB_PATH || DEFAULT_DB_PATH
for (const suffix of ['', '-wal', '-shm']) rmSync(path + suffix, { force: true })
console.log(`Base de datos reiniciada: ${path}`)
