import { createApp } from './app.js';
import { config } from './config/env.js';
import { pool } from './db/pool.js';
import { logger } from './lib/logger.js';

const server = createApp().listen(config.port, () => {
  logger.info({ port: config.port, auth: config.auth.mode }, 'API de Órbita Kids lista');
  if (config.auth.mode === 'dev') logger.warn('AUTH_MODE=dev: se aceptan tokens "dev:<id>". Solo para desarrollo.');
});

async function shutdown(signal) {
  logger.info({ signal }, 'Cerrando…');
  server.close(async () => {
    await pool.end();
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10_000).unref();
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
