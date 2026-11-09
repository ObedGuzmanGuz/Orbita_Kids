// API de Órbita Kids (Express). La PWA solo habla con el servidor por /api; el service worker nunca guarda estas respuestas.
import { existsSync } from 'node:fs'
import { join, relative } from 'node:path'
import express from 'express'
import pkg from '../package.json' with { type: 'json' }
import { json } from './db.js'
import { processChange } from './changes.js'
import { publicUser, snapshot, spaceSummary, todayLabel } from './data.js'
import { DEMO_OTP } from './seed.js'
import {
  hashPassword,
  newDataKey,
  newId,
  newToken,
  parseCookies,
  randomDigits,
  rateLimit,
  safeEqual,
  sameOrigin,
  securityHeaders,
  serializeCookie,
  sha256,
  verifyPassword,
} from './security.js'

const COOKIE = 'orbita_sid'
const MINUTE = 60000
const SHORT_SESSION = 12 * 60 * MINUTE
const LONG_SESSION = 30 * 24 * 60 * MINUTE
const LOCK_MS = 15 * MINUTE
const MAX_FAILS = 3

const SCHOOL_DIRECTORY = [
  { name: 'Escuela Primaria Demo Órbita', idp: 'Google Workspace for Education', proto: 'OIDC', provider: 'google' },
  { name: 'Colegio Demo Horizonte', idp: 'Microsoft Entra ID', proto: 'SAML 2.0', provider: 'microsoft' },
  { name: 'Instituto Demo Cometa', idp: 'Proveedor institucional compatible', proto: 'No disponible', disabled: true },
]

const clockLabel = () =>
  new Date().toLocaleTimeString('es-MX', { hour: 'numeric', minute: '2-digit', hour12: false, timeZone: 'America/Mexico_City' })

function maskEmail(email) {
  const [name, domain] = email.split('@')
  return `${name.slice(0, 7)}•••@${domain}`
}

function device(userAgent = '') {
  const ua = userAgent.toLowerCase()
  const os = ua.includes('windows') ? 'Windows' : ua.includes('android') ? 'Android' : /iphone|ipad/.test(ua) ? 'iOS' : ua.includes('mac os') ? 'macOS' : ua.includes('linux') ? 'Linux' : 'Otro sistema'
  const browser = ua.includes('edg/') ? 'Edge' : ua.includes('chrome/') ? 'Chrome' : ua.includes('firefox/') ? 'Firefox' : ua.includes('safari/') ? 'Safari' : 'Navegador'
  return { os, browser, mobile: /android|iphone|ipad|mobile/.test(ua) }
}

export function createApp(db, { distDir = null, demo = process.env.DEMO_MODE !== '0' } = {}) {
  const app = express()
  app.disable('x-powered-by')
  app.set('trust proxy', 'loopback')
  app.use(securityHeaders)

  const ghostFails = new Map() // intentos sobre cuentas que no existen (para no revelar cuáles existen)
  const pendingIdentities = new Map() // identidades del proveedor sin rol, por si piden acceso
  const authLimiter = rateLimit({ windowMs: MINUTE, max: 30 })

  const q = {
    userById: db.prepare('SELECT * FROM users WHERE id = ?'),
    userByLogin: db.prepare('SELECT * FROM users WHERE username = ? OR email = ?'),
    userByEmail: db.prepare('SELECT * FROM users WHERE email = ?'),
    session: db.prepare(
      'SELECT s.id AS sid, s.method, s.expires_at, s.last_seen_at, u.* FROM sessions s JOIN users u ON u.id = s.user_id WHERE s.id = ?',
    ),
    touch: db.prepare('UPDATE sessions SET last_seen_at = ? WHERE id = ?'),
    staffStatus: db.prepare('SELECT status FROM staff WHERE user_id = ?'),
  }

  // ——— Sesión ———
  function startSession(req, res, user, { method, remember }) {
    const token = newToken()
    const now = Date.now()
    const ttl = remember ? LONG_SESSION : SHORT_SESSION
    db.prepare('INSERT INTO sessions (id, user_id, method, user_agent, created_at, last_seen_at, expires_at) VALUES (?, ?, ?, ?, ?, ?, ?)').run(
      sha256(token),
      user.id,
      method,
      (req.get('user-agent') || '').slice(0, 300),
      now,
      now,
      now + ttl,
    )
    db.prepare('UPDATE users SET failed_logins = 0, locked_until = NULL WHERE id = ?').run(user.id)
    db.prepare('UPDATE staff SET last = ? WHERE user_id = ?').run(`Hoy ${clockLabel()}`, user.id)
    db.prepare('DELETE FROM sessions WHERE expires_at < ?').run(now)
    res.append('Set-Cookie', serializeCookie(COOKIE, token, { maxAge: remember ? ttl / 1000 : undefined, secure: req.secure }))
    return { next: 'signin', user: publicUser(user), dataKey: user.data_key, spaces: spaceSummary(db, user) }
  }

  // Después de comprobar la identidad: decide si entra, si falta el segundo paso o si no tiene acceso.
  function finishSignIn(req, res, user, { method, remember }) {
    if (user.kind === 'student') return res.status(403).json({ error: 'student' })
    if (user.status === 'invited') return res.status(403).json({ error: 'invited' })
    if (q.staffStatus.get(user.id)?.status === 'disabled') {
      return res.status(403).json({ error: 'disabled', message: 'Tu cuenta está desactivada. Habla con la dirección de tu escuela.' })
    }
    if (user.two_factor) {
      const code = demo ? DEMO_OTP : randomDigits(6)
      if (!demo) console.log(`[2FA] Código para ${user.email}: ${code}`) // en producción se envía por correo
      const challenge = newToken(18)
      db.prepare('DELETE FROM challenges WHERE user_id = ? OR expires_at < ?').run(user.id, Date.now())
      db.prepare('INSERT INTO challenges (id, user_id, method, code_hash, remember, expires_at) VALUES (?, ?, ?, ?, ?, ?)').run(
        challenge,
        user.id,
        method,
        sha256(code),
        remember ? 1 : 0,
        Date.now() + 10 * MINUTE,
      )
      return res.json({ next: '2fa', challenge, email: maskEmail(user.email), name: user.name })
    }
    return res.json(startSession(req, res, user, { method, remember }))
  }

  const api = express.Router()
  api.use(sameOrigin)
  api.use(express.json({ limit: '200kb' }))
  api.use((req, res, next) => {
    res.set('Cache-Control', 'no-store')
    const raw = parseCookies(req.get('cookie'))[COOKIE]
    if (raw) {
      const row = q.session.get(sha256(raw))
      if (row && row.expires_at > Date.now()) {
        req.session = { id: row.sid, method: row.method }
        req.user = row
        if (Date.now() - row.last_seen_at > MINUTE) q.touch.run(Date.now(), row.sid)
      }
    }
    next()
  })

  const requireUser = (req, res, next) => {
    if (!req.user) return res.status(401).json({ error: 'unauthenticated', message: 'Tu sesión terminó. Vuelve a entrar.' })
    if (q.staffStatus.get(req.user.id)?.status === 'disabled') {
      return res.status(403).json({ error: 'disabled', message: 'Tu cuenta está desactivada. Habla con la dirección de tu escuela.' })
    }
    next()
  }

  // ——— Público ———
  api.get('/health', (req, res) => {
    const started = process.hrtime.bigint()
    const { ok } = db.prepare('SELECT 1 AS ok').get()
    res.json({
      ok: ok === 1,
      version: pkg.version,
      database: 'sqlite',
      dbLatencyMs: Number(process.hrtime.bigint() - started) / 1e6,
      uptimeSeconds: Math.round(process.uptime()),
      time: new Date().toISOString(),
    })
  })

  api.get('/schools', (req, res) => {
    const term = String(req.query.q || '').trim().toLowerCase()
    res.json({ schools: SCHOOL_DIRECTORY.filter((s) => !term || s.name.toLowerCase().includes(term)) })
  })

  api.post('/contact', rateLimit({ windowMs: MINUTE, max: 10 }), (req, res) => {
    const b = req.body || {}
    const clean = (v, max) => (typeof v === 'string' ? v.trim().slice(0, max) : '')
    const form = {
      school: clean(b.school, 120),
      person: clean(b.person, 120),
      email: clean(b.email, 120).toLowerCase(),
      size: clean(b.size, 40),
      plan: clean(b.plan, 40),
      message: clean(b.message, 2000),
    }
    const errors = {}
    if (!form.school) errors.school = 'Escribe el nombre de la escuela.'
    if (!form.person) errors.person = 'Escribe quién es la persona responsable.'
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) errors.email = 'Escribe un correo válido.'
    if (b.privacy !== true) errors.privacy = 'Necesitamos tu aceptación para responder.'
    if (Object.keys(errors).length) return res.status(422).json({ error: 'invalid', errors })

    const year = new Date().getFullYear()
    let folio = typeof b.folio === 'string' && /^SOL-\d{4}-\d{4}$/.test(b.folio) ? b.folio : null
    const existing = folio && db.prepare("SELECT data FROM requests WHERE id = ? AND kind = 'contact'").get(folio)
    if (existing) {
      // El mismo envío llegó dos veces (por ejemplo, desde la cola sin conexión): se responde igual.
      if (json(existing.data, {}).email === form.email) return res.json({ folio, duplicate: true })
      folio = null
    }
    const taken = db.prepare('SELECT 1 FROM requests WHERE id = ?')
    while (!folio || taken.get(folio)) folio = `SOL-${year}-${randomDigits(4)}`
    db.prepare('INSERT INTO requests (id, kind, data, created_at) VALUES (?, ?, ?, ?)').run(folio, 'contact', JSON.stringify(form), Date.now())
    res.status(201).json({ folio })
  })

  // ——— Acceso ———
  api.post('/auth/login', authLimiter, async (req, res) => {
    const { username = '', password = '', remember = false } = req.body || {}
    const login = String(username).trim().toLowerCase()
    const handle = login.replace(/@.*$/, '')
    if (!handle || !password) return res.status(400).json({ error: 'missing', message: 'Escribe tu usuario y tu contraseña.' })
    const user = q.userByLogin.get(handle, login)
    const now = Date.now()
    const state = user ? { fails: user.failed_logins, until: user.locked_until } : ghostFails.get(handle) || { fails: 0, until: null }
    if (state.until && state.until > now) return res.status(423).json({ error: 'locked', until: state.until })

    if (!(await verifyPassword(String(password), user?.password_hash))) {
      const fails = state.fails + 1
      const until = fails >= MAX_FAILS ? now + LOCK_MS : null
      const next = { fails: until ? 0 : fails, until }
      if (user) db.prepare('UPDATE users SET failed_logins = ?, locked_until = ? WHERE id = ?').run(next.fails, next.until, user.id)
      else {
        if (ghostFails.size > 10000) ghostFails.clear()
        ghostFails.set(handle, next)
      }
      if (until) return res.status(423).json({ error: 'locked', until })
      return res.status(401).json({ error: 'invalid_credentials', remaining: MAX_FAILS - fails })
    }
    return finishSignIn(req, res, user, { method: 'password', remember: !!remember })
  })

  api.post('/auth/verify', authLimiter, (req, res) => {
    const { challenge = '', code = '', remember = false } = req.body || {}
    const row = db.prepare('SELECT * FROM challenges WHERE id = ?').get(String(challenge))
    if (!row || row.expires_at < Date.now()) return res.status(410).json({ error: 'expired', message: 'El código venció. Vuelve a iniciar sesión.' })
    if (!safeEqual(sha256(String(code)), row.code_hash)) {
      const attempts = row.attempts + 1
      if (attempts >= MAX_FAILS) {
        db.prepare('DELETE FROM challenges WHERE id = ?').run(row.id)
        db.prepare('UPDATE users SET locked_until = ?, failed_logins = 0 WHERE id = ?').run(Date.now() + LOCK_MS, row.user_id)
        return res.status(423).json({ error: 'locked' })
      }
      db.prepare('UPDATE challenges SET attempts = ? WHERE id = ?').run(attempts, row.id)
      return res.status(401).json({ error: 'invalid_code', remaining: MAX_FAILS - attempts })
    }
    db.prepare('DELETE FROM challenges WHERE id = ?').run(row.id)
    const user = q.userById.get(row.user_id)
    res.json(startSession(req, res, user, { method: row.method, remember: !!(row.remember || remember) }))
  })

  // Acceso directo de los botones de «Explorar» (solo en modo demostración, como el proveedor simulado).
  api.post('/auth/demo', authLimiter, (req, res) => {
    if (!demo) return res.status(404).json({ error: 'not_found' })
    const user = q.userById.get(req.body?.space === 'institucion' ? 'laura' : 'ana')
    res.json(startSession(req, res, user, { method: 'demo', remember: false }))
  })

  api.post('/auth/resend', authLimiter, (req, res) => {
    const r = db.prepare('UPDATE challenges SET expires_at = ? WHERE id = ? AND expires_at > ?').run(Date.now() + 10 * MINUTE, String(req.body?.challenge || ''), Date.now())
    if (!r.changes) return res.status(410).json({ error: 'expired', message: 'El código venció. Vuelve a iniciar sesión.' })
    res.json({ ok: true })
  })

  // Proveedor de identidad SIMULADO (pantalla 05). En producción aquí se valida el id_token firmado
  // por Google o Microsoft (OIDC con PKCE); sin esa validación, este endpoint no debe existir.
  api.post('/auth/sso', authLimiter, (req, res) => {
    if (!demo) return res.status(404).json({ error: 'not_found' })
    const { provider, email = '', remember = true } = req.body || {}
    if (!['google', 'microsoft'].includes(provider)) return res.status(400).json({ error: 'bad_provider' })
    const address = String(email).trim().toLowerCase()
    const user = q.userByEmail.get(address)
    if (!user) {
      const identity = newToken(16)
      if (pendingIdentities.size > 1000) pendingIdentities.clear()
      pendingIdentities.set(identity, { email: address, provider, expires: Date.now() + 15 * MINUTE })
      return res.status(403).json({ error: 'no_role', identity })
    }
    return finishSignIn(req, res, user, { method: provider, remember: !!remember })
  })

  // «Solicitar acceso» desde la pantalla 07b: crea la solicitud que la dirección ve en Docentes.
  api.post('/auth/access-request', authLimiter, (req, res) => {
    const pending = pendingIdentities.get(String(req.body?.identity || ''))
    if (!pending || pending.expires < Date.now()) return res.status(410).json({ error: 'expired', message: 'Vuelve a entrar con tu cuenta para pedir acceso.' })
    pendingIdentities.delete(String(req.body.identity))
    if (!db.prepare('SELECT 1 FROM staff WHERE email = ?').get(pending.email)) {
      const school = db.prepare('SELECT id FROM schools LIMIT 1').get()
      const local = pending.email.split('@')[0]
      const name = local.split(/[._-]/).filter(Boolean).map((w) => w[0].toUpperCase() + w.slice(1)).join(' ')
      const initials = name.split(' ').slice(0, 2).map((w) => w[0]).join('')
      db.prepare('INSERT INTO staff (id, school_id, name, initials, color, email, status, note, last, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)').run(
        newId('stf'),
        school.id,
        name,
        initials,
        '#4f9e6b',
        pending.email,
        'request',
        `Pidió acceso como docente el ${todayLabel()}`,
        '—',
        Date.now(),
      )
      const add = db.prepare('INSERT INTO notices (id, user_id, space, icon, title, meta, to_path, unread, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?)')
      for (const d of db.prepare("SELECT id FROM users WHERE school_id = ? AND spaces LIKE '%institucion%'").all(school.id)) {
        add.run(newId('ntc'), d.id, 'institucion', '112', `${name} pidió acceso como docente`, `Docentes · ${todayLabel()}`, '/institucion/docentes?filtro=solicitudes', Date.now())
      }
    }
    res.json({ ok: true })
  })

  api.post('/auth/recover', authLimiter, (req, res) => {
    const email = String(req.body?.email || '').trim().toLowerCase()
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return res.status(422).json({ error: 'invalid', message: 'Escribe un correo válido.' })
    // Misma respuesta exista o no la cuenta: así no se puede averiguar quién usa Órbita Kids.
    if (q.userByEmail.get(email)) db.prepare('INSERT INTO requests (id, kind, data, created_at) VALUES (?, ?, ?, ?)').run(newId('rec'), 'recover', JSON.stringify({ email }), Date.now())
    res.json({ ok: true })
  })

  api.get('/auth/me', requireUser, (req, res) => {
    res.json({ user: publicUser(req.user), dataKey: req.user.data_key, method: req.session.method })
  })

  api.post('/auth/logout', (req, res) => {
    if (req.session) db.prepare('DELETE FROM sessions WHERE id = ?').run(req.session.id)
    res.append('Set-Cookie', serializeCookie(COOKIE, '', { maxAge: 0, secure: req.secure }))
    res.json({ ok: true })
  })

  api.get('/auth/sessions', requireUser, (req, res) => {
    const rows = db.prepare('SELECT id, method, user_agent, created_at, last_seen_at FROM sessions WHERE user_id = ? AND expires_at > ? ORDER BY last_seen_at DESC').all(req.user.id, Date.now())
    res.json({
      sessions: rows.map((s) => ({
        id: s.id.slice(0, 16),
        method: s.method,
        ...device(s.user_agent || ''),
        createdAt: s.created_at,
        lastSeenAt: s.last_seen_at,
        current: s.id === req.session.id,
      })),
    })
  })

  api.post('/auth/sessions/revoke', requireUser, (req, res) => {
    const { id, others } = req.body || {}
    const result = others
      ? db.prepare('DELETE FROM sessions WHERE user_id = ? AND id != ?').run(req.user.id, req.session.id)
      : db.prepare("DELETE FROM sessions WHERE user_id = ? AND id LIKE ? || '%' AND id != ?").run(req.user.id, String(id || '').replace(/[^a-f0-9]/g, '') || '-', req.session.id)
    res.json({ closed: Number(result.changes) })
  })

  // ——— Invitaciones (pantalla 10) ———
  const invitation = (token) =>
    db
      .prepare('SELECT i.*, s.name, s.email, s.status AS staff_status, s.user_id FROM invitations i JOIN staff s ON s.id = i.staff_id WHERE i.token = ?')
      .get(String(token))

  api.get('/invitations/:token', (req, res) => {
    const inv = invitation(req.params.token)
    if (!inv || inv.status !== 'pending') return res.status(404).json({ error: 'not_found', message: 'La invitación ya no es válida.' })
    const groups = json(inv.groups, [])
    const names = groups.length ? db.prepare(`SELECT id, name FROM class_groups WHERE id IN (${groups.map(() => '?').join(', ')})`).all(...groups) : []
    const school = db.prepare('SELECT name FROM schools LIMIT 1').get()
    res.json({ school: school.name, name: inv.name, email: inv.email, invitedBy: inv.invited_by, expires: inv.expires, groups: names.map((g) => `${g.name} · apoyo`) })
  })

  api.post('/invitations/:token/accept', authLimiter, async (req, res) => {
    const inv = invitation(req.params.token)
    if (!inv || inv.status !== 'pending') return res.status(404).json({ error: 'not_found', message: 'La invitación ya no es válida.' })
    const method = ['google', 'microsoft', 'password'].includes(req.body?.method) ? req.body.method : null
    if (!method) return res.status(400).json({ error: 'bad_method' })
    const password = String(req.body?.password || '')
    if (method === 'password' && password.length < 8) return res.status(422).json({ error: 'weak_password', message: 'La contraseña necesita al menos 8 caracteres.' })
    const hash = method === 'password' ? await hashPassword(password) : null

    let userId = inv.user_id
    db.exec('BEGIN IMMEDIATE')
    try {
      if (!userId) {
        const local = inv.email.split('@')[0]
        userId = newId('usr')
        const initials = inv.name.split(/\s+/).slice(0, 2).map((w) => w[0]).join('').toUpperCase()
        db.prepare(
          `INSERT INTO users (id, school_id, username, email, name, short, initials, color, role_label, spaces, data_key, created_at)
           SELECT ?, school_id, ?, ?, ?, ?, ?, color, 'Docente', '["docente"]', ?, ? FROM staff WHERE id = ?`,
        ).run(userId, local, inv.email, inv.name, inv.name.split(' ')[0], initials, newDataKey(), Date.now(), inv.staff_id)
        db.prepare('UPDATE staff SET user_id = ? WHERE id = ?').run(userId, inv.staff_id)
      }
      db.prepare("UPDATE users SET status = 'active', password_hash = COALESCE(?, password_hash) WHERE id = ?").run(hash, userId)
      db.prepare("UPDATE staff SET status = 'active', note = NULL WHERE id = ?").run(inv.staff_id)
      db.prepare("UPDATE invitations SET status = 'accepted' WHERE token = ?").run(inv.token)
      const setSupport = db.prepare('UPDATE class_groups SET support_teacher_id = ? WHERE id = ? AND support_teacher_id IS NULL')
      for (const g of json(inv.groups, [])) setSupport.run(inv.staff_id, g)
      db.exec('COMMIT')
    } catch (error) {
      db.exec('ROLLBACK')
      throw error
    }
    res.json(startSession(req, res, q.userById.get(userId), { method: method === 'password' ? 'password' : method, remember: true }))
  })

  api.post('/invitations/:token/reject', (req, res) => {
    const inv = invitation(req.params.token)
    if (!inv || inv.status !== 'pending') return res.status(404).json({ error: 'not_found', message: 'La invitación ya no es válida.' })
    db.prepare("UPDATE invitations SET status = 'rejected' WHERE token = ?").run(inv.token)
    db.prepare('UPDATE staff SET note = ? WHERE id = ?').run(`Rechazó la invitación el ${todayLabel()}`, inv.staff_id)
    res.json({ ok: true })
  })

  // ——— Datos y sincronización ———
  api.get('/data', requireUser, (req, res) => res.json(snapshot(db, req.user)))

  api.post('/sync', requireUser, (req, res) => {
    const changes = Array.isArray(req.body?.changes) ? req.body.changes : null
    if (!changes) return res.status(400).json({ error: 'bad_request', message: 'Falta la lista de cambios.' })
    if (changes.length > 100) return res.status(413).json({ error: 'too_many', message: 'Envía como máximo 100 cambios a la vez.' })
    const results = changes.map((c) => processChange(db, req.user, c))
    res.json({ results, data: snapshot(db, q.userById.get(req.user.id)) })
  })

  app.use('/api', api)
  app.use('/api', (req, res) => res.status(404).json({ error: 'not_found', message: 'Esa ruta de la API no existe.' }))

  if (distDir && existsSync(distDir)) serveApp(app, distDir)

  // Errores inesperados: se registran en el servidor y la app recibe un mensaje genérico.
  app.use((error, req, res, next) => {
    if (res.headersSent) return next(error)
    if (error.type === 'entity.parse.failed') return res.status(400).json({ error: 'bad_json', message: 'El cuerpo no es JSON válido.' })
    if (error.type === 'entity.too.large') return res.status(413).json({ error: 'too_large', message: 'La solicitud es demasiado grande.' })
    console.error(error)
    res.status(500).json({ error: 'server_error', message: 'Algo falló en el servidor. Intenta de nuevo.' })
  })

  return app
}

// En producción el mismo servidor entrega la PWA compilada (dist/).
function serveApp(app, dir) {
  const noCache = new Set(['/sw.js', '/registerSW.js', '/manifest.webmanifest', '/version.json', '/index.html'])
  app.use(
    express.static(dir, {
      index: false,
      setHeaders(res, file) {
        const path = `/${relative(dir, file).replaceAll('\\', '/')}`
        if (path.startsWith('/assets/')) res.set('Cache-Control', 'public, max-age=31536000, immutable')
        else if (noCache.has(path)) res.set('Cache-Control', 'no-cache')
        else res.set('Cache-Control', 'public, max-age=3600')
      },
    }),
  )
  // Cualquier otra ruta es una pantalla de la SPA: React Router decide qué mostrar.
  app.get(/^\/(?!api\/).*/, (req, res) => {
    res.set('Cache-Control', 'no-cache')
    res.sendFile(join(dir, 'index.html'))
  })
}
