// Almacén local cifrado por cuenta: IndexedDB + AES-GCM (WebCrypto).
//
// · El servidor entrega una llave AES-256 distinta para cada cuenta al iniciar sesión.
// · El navegador la importa como llave NO exportable y la guarda en IndexedDB: ningún script puede leerla en claro.
// · Cada registro (datos, cola de cambios, perfil) se cifra con esa llave y un IV aleatorio.
// · Al cerrar sesión se borra la llave. Si quedaron cambios pendientes, siguen cifrados en el equipo y solo
//   se pueden leer cuando esa misma cuenta vuelve a entrar y el servidor entrega de nuevo su llave.
//
// Si el navegador no ofrece IndexedDB o WebCrypto (por ejemplo, http en una IP de la red local),
// se usa un almacén en memoria: la app funciona, pero no guarda nada entre recargas.

const DB_NAME = 'orbita-kids'
const VERSION = 1
const encoder = new TextEncoder()
const decoder = new TextDecoder()

const supported = typeof indexedDB !== 'undefined' && !!globalThis.crypto?.subtle
const memory = { keys: new Map(), vault: new Map() }
let dbPromise = null

function openDb() {
  dbPromise ||= new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, VERSION)
    request.onupgradeneeded = () => {
      const db = request.result
      if (!db.objectStoreNames.contains('keys')) db.createObjectStore('keys')
      if (!db.objectStoreNames.contains('vault')) db.createObjectStore('vault')
    }
    request.onsuccess = () => resolve(request.result)
    request.onerror = () => reject(request.error)
  })
  return dbPromise
}

async function run(store, mode, action) {
  if (!supported) {
    const map = memory[store]
    return action({
      get: (k) => ({ result: map.get(k) }),
      put: (v, k) => map.set(k, v),
      delete: (k) => (k instanceof Range ? [...map.keys()].filter((x) => k.includes(x)).forEach((x) => map.delete(x)) : map.delete(k)),
    })?.result
  }
  const db = await openDb()
  return new Promise((resolve, reject) => {
    const tx = db.transaction(store, mode)
    const request = action(tx.objectStore(store))
    tx.oncomplete = () => resolve(request?.result)
    tx.onerror = () => reject(tx.error)
    tx.onabort = () => reject(tx.error)
  })
}

class Range {
  constructor(prefix) {
    this.prefix = prefix
  }
  includes(key) {
    return typeof key === 'string' && key.startsWith(this.prefix)
  }
}
const prefixRange = (prefix) => (supported ? IDBKeyRange.bound(prefix, `${prefix}￿`) : new Range(prefix))

function fromBase64(value) {
  const binary = atob(value.replace(/-/g, '+').replace(/_/g, '/'))
  return Uint8Array.from(binary, (c) => c.charCodeAt(0))
}

// Guarda la llave de la cuenta (no exportable) y la devuelve lista para usar.
export async function unlock(account, base64Key) {
  if (!supported) {
    memory.keys.set(account, base64Key)
    return base64Key
  }
  const key = await crypto.subtle.importKey('raw', fromBase64(base64Key), { name: 'AES-GCM' }, false, ['encrypt', 'decrypt'])
  await run('keys', 'readwrite', (s) => s.put(key, account))
  return key
}

export const getKey = (account) => run('keys', 'readonly', (s) => s.get(account))

// Borra la llave: lo cifrado se queda, pero ya no se puede leer en este equipo sin volver a entrar.
export const lock = (account) => run('keys', 'readwrite', (s) => s.delete(account))

// Borra todo lo de la cuenta en este equipo.
export async function wipe(account) {
  await lock(account)
  await run('vault', 'readwrite', (s) => s.delete(prefixRange(`${account}:`)))
}

export async function save(key, account, name, value) {
  if (!key) return
  if (!supported) {
    memory.vault.set(`${account}:${name}`, JSON.stringify(value))
    return
  }
  const iv = crypto.getRandomValues(new Uint8Array(12))
  const data = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv, additionalData: encoder.encode(`${account}:${name}`) },
    key,
    encoder.encode(JSON.stringify(value)),
  )
  await run('vault', 'readwrite', (s) => s.put({ iv, data, savedAt: Date.now() }, `${account}:${name}`))
}

export async function load(key, account, name) {
  if (!key) return undefined
  if (!supported) {
    const raw = memory.vault.get(`${account}:${name}`)
    return raw ? JSON.parse(raw) : undefined
  }
  const record = await run('vault', 'readonly', (s) => s.get(`${account}:${name}`))
  if (!record) return undefined
  try {
    const plain = await crypto.subtle.decrypt({ name: 'AES-GCM', iv: record.iv, additionalData: encoder.encode(`${account}:${name}`) }, key, record.data)
    return JSON.parse(decoder.decode(plain))
  } catch {
    return undefined // otra llave o datos dañados: se descartan y se vuelven a descargar
  }
}

export const remove = (account, name) => run('vault', 'readwrite', (s) => s.delete(`${account}:${name}`))

export const isPersistent = supported
