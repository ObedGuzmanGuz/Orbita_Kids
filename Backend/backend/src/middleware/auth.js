import { createRemoteJWKSet, jwtVerify } from 'jose';

import { config } from '../config/env.js';
import { profileFromClaims, roleFromClaims } from '../domain/claims.js';
import { forbidden, unauthorized } from '../lib/errors.js';
import { findUser, upsertFromToken } from '../modules/me/me.repository.js';

const jwks =
  config.auth.mode === 'keycloak'
    ? createRemoteJWKSet(new URL(`${config.auth.issuer}/protocol/openid-connect/certs`))
    : null;

// Evita escribir en `users` en cada request: se refresca cada 5 minutos o si
// cambia el rol.
const SYNC_EVERY_MS = 5 * 60 * 1000;
const lastSynced = new Map();

async function userFromKeycloak(token) {
  let claims;
  try {
    ({ payload: claims } = await jwtVerify(token, jwks, { issuer: config.auth.issuer }));
  } catch {
    throw unauthorized('El token no es válido o ya venció');
  }
  if (claims.typ && claims.typ !== 'Bearer') throw unauthorized('Se esperaba un access token');
  if (config.auth.clientId && claims.azp !== config.auth.clientId) {
    throw unauthorized('El token no fue emitido para esta app');
  }
  const role = roleFromClaims(claims, config.auth);
  if (!role) throw forbidden('Tu cuenta aún no tiene rol', 'no_role');

  const prev = lastSynced.get(claims.sub);
  if (!prev || prev.role !== role || Date.now() - prev.at > SYNC_EVERY_MS) {
    await upsertFromToken({ ...profileFromClaims(claims), role });
    lastSynced.set(claims.sub, { role, at: Date.now() });
  }
  return { user: await findUser(claims.sub), sessionId: claims.sid ?? null };
}

/** Modo dev: `Bearer dev:<id>` de un usuario sembrado. */
async function userFromDevToken(token) {
  if (!token.startsWith('dev:')) throw unauthorized('En modo dev usa "Bearer dev:<id de usuario>"');
  const user = await findUser(token.slice(4));
  if (!user) throw unauthorized('Ese usuario dev no existe. ¿Corriste npm run db:seed?');
  return { user, sessionId: null };
}

/** Exige un token válido y deja el usuario en `req.user`. */
export async function authenticate(req, _res, next) {
  const header = req.get('Authorization') ?? '';
  const [scheme, token] = header.split(' ');
  if (scheme !== 'Bearer' || !token) throw unauthorized();

  const { user, sessionId } =
    config.auth.mode === 'dev' ? await userFromDevToken(token) : await userFromKeycloak(token);
  req.user = user;
  req.sessionId = sessionId;
  next();
}

export const requireRole = (role) => (req, _res, next) => {
  if (req.user?.role !== role) {
    throw forbidden(role === 'teacher' ? 'Solo para docentes' : 'Solo para estudiantes');
  }
  next();
};
