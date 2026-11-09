import { Router } from 'express';
import { z } from 'zod';

import { notFound, preconditionFailed } from '../../lib/errors.js';
import { parse, parseIfMatch, setVersion } from '../../lib/http.js';
import { profileOf, updateProfile } from './me.repository.js';

const lookPart = z.string().min(1).max(32);

const profileBody = z.object({
  // Pantalla de registro: «Usa solo tu nombre o un apodo».
  name: z.string().trim().min(1).max(40).optional(),
  look: z
    .object({
      character: lookPart,
      helmet: lookPart,
      suit: lookPart,
      accessory: lookPart,
      expression: lookPart,
    })
    .optional(),
});

async function sendProfile(req, res) {
  const profile = await profileOf(req.user.id);
  if (!profile) throw notFound('Usuario no encontrado');
  setVersion(res, profile.version);
  res.json(profile);
}

async function editProfile(req, res) {
  const changes = parse(profileBody, req.body);
  const ok = await updateProfile(req.user.id, changes, parseIfMatch(req.get('If-Match')));
  if (!ok) throw preconditionFailed('Tu perfil cambió en otro dispositivo. No se sobrescribió.');
  await sendProfile(req, res);
}

export const meRouter = Router();

meRouter.get('/', sendProfile);
meRouter.patch('/', editProfile);
// La cola de la app siempre envía POST {id, ...payload}; `id` es el del registro
// de la cola, no del usuario, y se ignora.
meRouter.post('/', editProfile);
