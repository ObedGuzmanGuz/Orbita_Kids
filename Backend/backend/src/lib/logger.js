import pino from 'pino';

import { config } from '../config/env.js';

export const logger = pino({
  level: config.logLevel,
  // Nunca registrar tokens ni datos que la app considera sensibles.
  redact: ['req.headers.authorization', 'req.headers.cookie'],
});
