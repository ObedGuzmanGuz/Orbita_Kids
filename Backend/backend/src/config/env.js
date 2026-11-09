import { z } from 'zod';

/**
 * Configuración leída de variables de entorno (ver `.env.example`).
 * Si algo falta o es inválido, el proceso se detiene con un mensaje claro.
 */
const schema = z
  .object({
    NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
    PORT: z.coerce.number().int().positive().default(3000),
    LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent']).default('info'),
    CORS_ORIGINS: z.string().default(''),

    DB_HOST: z.string().default('127.0.0.1'),
    DB_PORT: z.coerce.number().int().positive().default(3306),
    DB_USER: z.string().min(1),
    DB_PASSWORD: z.string().default(''),
    DB_NAME: z.string().min(1),
    DB_CONNECTION_LIMIT: z.coerce.number().int().positive().default(10),

    AUTH_MODE: z.enum(['keycloak', 'dev']).default('keycloak'),
    KEYCLOAK_ISSUER: z.string().default(''),
    KEYCLOAK_CLIENT_ID: z.string().default(''),
    KEYCLOAK_ROLE_STUDENT: z.string().default('student'),
    KEYCLOAK_ROLE_TEACHER: z.string().default('teacher'),

    GROUP_CODE_TTL_DAYS: z.coerce.number().int().positive().default(180),
  })
  .superRefine((v, ctx) => {
    if (v.AUTH_MODE === 'dev' && v.NODE_ENV === 'production') {
      ctx.addIssue({ code: 'custom', path: ['AUTH_MODE'], message: 'AUTH_MODE=dev no se permite en producción' });
    }
    if (v.AUTH_MODE === 'keycloak' && !/^https?:\/\//.test(v.KEYCLOAK_ISSUER)) {
      ctx.addIssue({ code: 'custom', path: ['KEYCLOAK_ISSUER'], message: 'Se necesita la URL del realm de Keycloak' });
    }
  });

function load() {
  const parsed = schema.safeParse(process.env);
  if (!parsed.success) {
    const lines = parsed.error.issues.map((i) => `  - ${i.path.join('.')}: ${i.message}`);
    console.error(`Configuración inválida:\n${lines.join('\n')}`);
    process.exit(1);
  }
  const v = parsed.data;
  return Object.freeze({
    env: v.NODE_ENV,
    port: v.PORT,
    logLevel: v.LOG_LEVEL,
    corsOrigins: v.CORS_ORIGINS.split(',').map((s) => s.trim()).filter(Boolean),
    db: {
      host: v.DB_HOST,
      port: v.DB_PORT,
      user: v.DB_USER,
      password: v.DB_PASSWORD,
      database: v.DB_NAME,
      connectionLimit: v.DB_CONNECTION_LIMIT,
    },
    auth: {
      mode: v.AUTH_MODE,
      issuer: v.KEYCLOAK_ISSUER.replace(/\/+$/, ''),
      clientId: v.KEYCLOAK_CLIENT_ID,
      roleStudent: v.KEYCLOAK_ROLE_STUDENT,
      roleTeacher: v.KEYCLOAK_ROLE_TEACHER,
    },
    groupCodeTtlDays: v.GROUP_CODE_TTL_DAYS,
  });
}

export const config = load();
