// Utilidades de seguridad: contraseñas con scrypt, tokens aleatorios, cookies y límites de intentos.
import { createHash, randomBytes, randomInt, scrypt as scryptCallback, timingSafeEqual } from 'node:crypto'
import { promisify } from 'node:util'

const scrypt = promisify(scryptCallback)
const SCRYPT = { N: 16384, r: 8, p: 1 }

export async function hashPassword(password) {
  const salt = randomBytes(16)
  const key = await scrypt(password.normalize('NFKC'), salt, 64, SCRYPT)
  return ['scrypt', SCRYPT.N, SCRYPT.r, SCRYPT.p, salt.toString('base64'), key.toString('base64')].join('$')
}

export async function verifyPassword(password, stored) {
  if (!stored) {
    // Misma demora aunque la cuenta no tenga contraseña, para no revelar qué cuentas existen.
    await scrypt('-', randomBytes(16), 64, SCRYPT)
    return false
  }
  const [alg, N, r, p, salt, key] = stored.split('$')
  if (alg !== 'scrypt') return false
  const expected = Buffer.from(key, 'base64')
  const actual = await scrypt(String(password).normalize('NFKC'), Buffer.from(salt, 'base64'), expected.length, {
    N: Number(N),
    r: Number(r),
    p: Number(p),
  })
  return timingSafeEqual(actual, expected)
}

export const sha256 = (value) => createHash('sha256').update(String(value)).digest('hex')
export const newToken = (bytes = 32) => randomBytes(bytes).toString('base64url')
export const newDataKey = () => randomBytes(32).toString('base64')
export const newId = (prefix) => `${prefix}-${randomBytes(4).toString('hex')}`
export const randomDigits = (n) => Array.from({ length: n }, () => randomInt(10)).join('')

export function safeEqual(a, b) {
  const x = Buffer.from(String(a))
  const y = Buffer.from(String(b))
  return x.length === y.length && timingSafeEqual(x, y)
}

export function parseCookies(header = '') {
  const out = {}
  for (const part of header.split(';')) {
    const i = part.indexOf('=')
    if (i < 0) continue
    const name = part.slice(0, i).trim()
    if (name) out[name] = decodeURIComponent(part.slice(i + 1).trim())
  }
  return out
}

export function serializeCookie(name, value, { maxAge, secure, httpOnly = true, sameSite = 'Lax', path = '/' } = {}) {
  const parts = [`${name}=${encodeURIComponent(value)}`, `Path=${path}`, `SameSite=${sameSite}`]
  if (httpOnly) parts.push('HttpOnly')
  if (secure) parts.push('Secure')
  if (maxAge !== undefined) parts.push(`Max-Age=${Math.floor(maxAge)}`)
  return parts.join('; ')
}

// Límite sencillo por IP (ventana fija). Suficiente para frenar a quien prueba contraseñas en masa.
export function rateLimit({ windowMs, max }) {
  const hits = new Map()
  return (req, res, next) => {
    const now = Date.now()
    const key = req.ip || 'local'
    const entry = hits.get(key)
    if (!entry || entry.reset < now) {
      hits.set(key, { count: 1, reset: now + windowMs })
      if (hits.size > 5000) for (const [k, v] of hits) if (v.reset < now) hits.delete(k)
      return next()
    }
    entry.count += 1
    if (entry.count > max) {
      res.set('Retry-After', String(Math.ceil((entry.reset - now) / 1000)))
      return res.status(429).json({ error: 'too_many_requests', message: 'Demasiadas solicitudes. Espera un momento y vuelve a intentar.' })
    }
    next()
  }
}

// Protección CSRF: las escrituras deben venir de esta misma página (cabecera Origin) y en JSON.
export function sameOrigin(req, res, next) {
  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) return next()
  const origin = req.get('origin')
  if (origin) {
    let host = ''
    try {
      host = new URL(origin).host
    } catch {
      /* Origin inválido */
    }
    const allowed = [req.get('host'), req.get('x-forwarded-host')].filter(Boolean)
    if (!allowed.includes(host)) return res.status(403).json({ error: 'bad_origin', message: 'Origen no permitido.' })
  }
  const hasBody = Number(req.get('content-length') || 0) > 0 || !!req.get('transfer-encoding')
  if (hasBody && !req.is('application/json')) {
    return res.status(415).json({ error: 'json_required', message: 'Envía los datos como JSON.' })
  }
  next()
}

export function securityHeaders(req, res, next) {
  res.set({
    'X-Content-Type-Options': 'nosniff',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'X-Frame-Options': 'DENY',
    'Cross-Origin-Opener-Policy': 'same-origin',
    'Permissions-Policy': 'camera=(), microphone=(), geolocation=(), payment=()',
    'Content-Security-Policy': [
      "default-src 'self'",
      "script-src 'self'",
      "style-src 'self' 'unsafe-inline'",
      "img-src 'self' data: blob:",
      "font-src 'self' data:",
      "connect-src 'self'",
      "manifest-src 'self'",
      "worker-src 'self'",
      "frame-ancestors 'none'",
      "base-uri 'self'",
      "form-action 'self'",
    ].join('; '),
  })
  next()
}
