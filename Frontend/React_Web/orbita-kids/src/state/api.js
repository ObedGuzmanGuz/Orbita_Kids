// Cliente de la API. Todas las peticiones van al mismo origen (/api), con la cookie de sesión httpOnly.

export class ApiError extends Error {
  constructor(status, body = {}) {
    super(body.message || (status === 0 ? 'No hay conexión con el servidor.' : `El servidor respondió ${status}.`))
    this.status = status // 0 = sin red o servidor apagado
    this.code = body.error || (status === 0 ? 'network' : 'http_error')
    this.body = body
  }
  get offline() {
    return this.status === 0 || this.status === 502 || this.status === 503 || this.status === 504
  }
}

export async function api(path, { method = 'GET', body, timeout = 12000 } = {}) {
  const controller = new AbortController()
  const timer = setTimeout(() => controller.abort(), timeout)
  let res
  try {
    res = await fetch(`/api${path}`, {
      method,
      headers: body === undefined ? undefined : { 'content-type': 'application/json' },
      body: body === undefined ? undefined : JSON.stringify(body),
      credentials: 'same-origin',
      cache: 'no-store',
      signal: controller.signal,
    })
  } catch {
    throw new ApiError(0)
  } finally {
    clearTimeout(timer)
  }
  let data = {}
  try {
    data = await res.json()
  } catch {
    /* respuesta sin JSON (por ejemplo, el proxy sin backend) */
  }
  if (!res.ok) throw new ApiError(res.status, data)
  return data
}

// ¿Responde el backend? navigator.onLine dice «en línea» aunque el Wi-Fi no tenga Internet.
export async function ping() {
  try {
    await api(`/health?t=${Date.now()}`, { timeout: 6000 })
    return true
  } catch {
    return false
  }
}

export const newChangeId = () => {
  const bytes = crypto.getRandomValues(new Uint8Array(3))
  return `chg-${Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('')}`
}

// Solicitudes del sitio público hechas sin conexión (por ejemplo, el formulario de contacto).
const OUTBOX = 'orbita-kids:outbox'

export function readOutbox() {
  try {
    return JSON.parse(localStorage.getItem(OUTBOX)) || []
  } catch {
    return []
  }
}
function writeOutbox(list) {
  try {
    if (list.length) localStorage.setItem(OUTBOX, JSON.stringify(list))
    else localStorage.removeItem(OUTBOX)
  } catch {
    /* sin almacenamiento */
  }
}
export function addToOutbox(item) {
  writeOutbox([...readOutbox().filter((x) => x.id !== item.id), item])
}
export async function flushOutbox() {
  const pending = readOutbox()
  let sent = 0
  for (const item of pending) {
    try {
      await api(item.path, { method: 'POST', body: item.body })
      writeOutbox(readOutbox().filter((x) => x.id !== item.id))
      sent += 1
    } catch (error) {
      if (error.offline) break
      writeOutbox(readOutbox().filter((x) => x.id !== item.id)) // datos inválidos: no se reintenta
    }
  }
  return sent
}
