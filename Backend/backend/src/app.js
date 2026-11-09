import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import { pinoHttp } from 'pino-http';

import { config } from './config/env.js';
import { query } from './db/pool.js';
import { logger } from './lib/logger.js';
import { authenticate } from './middleware/auth.js';
import { errorHandler, notFoundHandler } from './middleware/errors.js';
import { activitiesRouter } from './modules/activities/activities.routes.js';
import { attemptsRouter } from './modules/attempts/attempts.routes.js';
import { groupCodesRouter } from './modules/groups/groupCodes.routes.js';
import { groupsRouter, studentsRouter } from './modules/groups/groups.routes.js';
import { meRouter } from './modules/me/me.routes.js';
import { planRequestsRouter, supportReportsRouter } from './modules/requests/requests.routes.js';

export function createApp() {
  const app = express();
  app.disable('x-powered-by');
  // El ETag es la versión del registro (lib/http.js#setVersion), no un hash
  // del cuerpo: la app lo devuelve en If-Match.
  app.set('etag', false);
  app.set('trust proxy', 1);

  app.use(
    pinoHttp({
      logger,
      autoLogging: { ignore: (req) => req.url === '/health' },
      serializers: {
        req: (req) => ({ id: req.id, method: req.method, url: req.url }),
        res: (res) => ({ statusCode: res.statusCode }),
      },
    }),
  );
  app.use(helmet());
  app.use(cors({ origin: config.corsOrigins, exposedHeaders: ['ETag'] }));
  app.use(express.json({ limit: '100kb' }));

  app.get('/health', async (_req, res) => {
    try {
      await query('SELECT 1');
      res.json({ status: 'ok', db: 'ok' });
    } catch {
      res.status(503).json({ status: 'degraded', db: 'unavailable' });
    }
  });

  // Rutas que van en `ApiEndpoints` de la app (con API_BASE_URL = https://…/v1).
  const v1 = express.Router();
  v1.use('/group-codes', groupCodesRouter); // /check es público; /redeem autentica por su cuenta
  v1.use(authenticate);
  v1.use('/me', meRouter);
  v1.use('/attempts', attemptsRouter);
  v1.use('/activities', activitiesRouter);
  v1.use('/groups', groupsRouter);
  v1.use('/students', studentsRouter);
  v1.use('/plan-requests', planRequestsRouter);
  v1.use('/support-reports', supportReportsRouter);
  app.use('/v1', v1);

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
