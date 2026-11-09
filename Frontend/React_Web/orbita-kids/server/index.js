// Backend de Órbita Kids.
//   npm run dev    → API en http://localhost:3001 (Vite la usa desde el puerto 5173 a través de su proxy)
//   npm start      → API + PWA compilada en http://localhost:4173 (antes: npm run build)
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { createApp } from './app.js'
import { DEFAULT_DB_PATH, openDb } from './db.js'

const here = dirname(fileURLToPath(import.meta.url))
const args = process.argv.slice(2)
const dev = args.includes('--dev')
const portArg = args.find((a) => a.startsWith('--port='))?.split('=')[1]
const port = Number(process.env.PORT || portArg || (dev ? 3001 : 4173))

const db = await openDb()
const app = createApp(db, { distDir: dev ? null : join(here, '..', 'dist') })

const server = app.listen(port, () => {
  const where = process.env.DB_PATH || DEFAULT_DB_PATH
  console.log(`Órbita Kids · ${dev ? 'API de desarrollo' : 'API + PWA'} en http://localhost:${port}`)
  console.log(`Base de datos: ${where}`)
})

const shutdown = () => {
  server.close(() => {
    db.close()
    process.exit(0)
  })
  setTimeout(() => process.exit(0), 2000).unref()
}
process.on('SIGINT', shutdown)
process.on('SIGTERM', shutdown)
