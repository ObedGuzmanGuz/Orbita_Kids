import { randomInt } from 'node:crypto';

/** Sin 0/O ni 1/I para que se puedan dictar en el salón sin confusión. */
const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

export const CODE_PATTERN = /^ORB-[A-Z0-9]{4}$/;

/** `" orb-2a7k "` → `"ORB-2A7K"`. */
export function normalizeCode(raw) {
  return String(raw ?? '').replace(/\s+/g, '').toUpperCase();
}

export function generateCode(random = randomInt) {
  let s = '';
  for (let i = 0; i < 4; i++) s += ALPHABET[random(ALPHABET.length)];
  return `ORB-${s}`;
}

/** Mensajes para la pantalla 11 (los mismos que usa la app en modo demo). */
export const CODE_MESSAGES = Object.freeze({
  notFound: 'No encontramos ese código. Pide ayuda a tu maestra.',
  expired: 'Este código venció. Pide uno nuevo a tu escuela.',
  archived: 'Ese grupo ya no está disponible: su ciclo escolar terminó.',
  full: 'La licencia de la escuela ya no tiene lugares. Avísale a tu maestra.',
  licenseEnded: 'La licencia de la escuela ya no está vigente. Avísale a tu maestra.',
});

/**
 * Decide si un estudiante puede unirse al grupo. Devuelve `null` si sí, o
 * el motivo (`notFound`, `archived`, `expired`, `licenseEnded`, `full`).
 *
 * @param {object} p
 * @param {{status: string, codeExpiresAt: Date|null}|null} p.group
 * @param {{seats: number, endsAt: Date|null}|null} p.license  null = sin licencia (sin límite)
 * @param {number} p.seatsUsed  estudiantes que ya ocupan lugar en la licencia
 * @param {Date} p.now
 */
export function codeProblem({ group, license, seatsUsed, now }) {
  if (!group) return 'notFound';
  if (group.status === 'archived') return 'archived';
  if (group.codeExpiresAt && group.codeExpiresAt <= now) return 'expired';
  if (license) {
    if (license.endsAt && license.endsAt < now) return 'licenseEnded';
    if (seatsUsed >= license.seats) return 'full';
  }
  return null;
}
