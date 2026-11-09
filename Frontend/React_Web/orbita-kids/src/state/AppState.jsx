import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react'
import { ApiError, api, flushOutbox, newChangeId, ping, readOutbox } from './api'
import * as vault from './vault'
import { applyAll, applyLocal } from './optimistic'
import { PREF_KEYS, readPreferences, writePreferences } from './preferences'
import { whenLabel } from './format'

const AppStateContext = createContext(null)

// localStorage solo guarda quién tiene la sesión abierta y en qué espacio.
// Los datos, el perfil y la cola de cambios viven cifrados por cuenta en IndexedDB (ver vault.js).
const STORAGE_KEY = 'orbita-kids:v2'
const LOGIN_NOTICE = 'orbita-kids:login-notice'
const PENDING_LOGOUT = 'orbita-kids:pending-logout'

function readStore() {
  try {
    localStorage.removeItem('orbita-kids:v1') // versión anterior, sin backend
    return JSON.parse(localStorage.getItem(STORAGE_KEY)) || {}
  } catch {
    return {}
  }
}

function writeStore(data) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data))
  } catch {
    /* almacenamiento no disponible: la app sigue funcionando en memoria */
  }
}

function storage(kind, action, key, value) {
  try {
    const store = kind === 'session' ? sessionStorage : localStorage
    if (action === 'get') return store.getItem(key)
    if (action === 'set') store.setItem(key, value)
    if (action === 'remove') store.removeItem(key)
  } catch {
    /* sin almacenamiento */
  }
  return null
}

function isStandaloneDisplay() {
  if (typeof window === 'undefined') return false
  return (
    window.matchMedia?.('(display-mode: standalone)').matches ||
    window.matchMedia?.('(display-mode: window-controls-overlay)').matches ||
    window.navigator.standalone === true
  )
}

const EMPTY_TEACHER = { groups: [], students: [], activities: [], reports: {}, insights: { weekly: [], delta: 0 }, needSupport: [], notices: [] }
const EMPTY_INSTITUTION = {
  school: {},
  settings: {},
  license: { used: 0, total: 0, plan: '', cycle: '' },
  teachers: [],
  groups: [],
  gradeProgress: [],
  weeklySessions: [],
  groupScores: [],
  errorTopics: [],
  openGroups: [],
  pending: [],
  notices: [],
}

export function AppStateProvider({ children }) {
  const [initial] = useState(readStore)

  // Conexión: real (navigator.onLine + una comprobación al servidor) o simulada desde la demostración.
  const [deviceOnline, setDeviceOnline] = useState(() => navigator.onLine)
  const [reachable, setReachable] = useState(true)
  const [simulateOffline, setSimulateOffline] = useState(false)
  const networkOnline = deviceOnline && reachable
  const online = networkOnline && !simulateOffline

  // Sesión y datos de la cuenta.
  const [session, setSession] = useState(initial.session || null)
  const [hydrated, setHydrated] = useState(!initial.session)
  const [user, setUser] = useState(null)
  const [data, setData] = useState(null)
  const [queue, setQueueState] = useState([])
  const [lastSyncAt, setLastSyncAt] = useState(null)
  const [syncing, setSyncing] = useState(false)
  const [syncError, setSyncError] = useState(null)

  // Instalación de la PWA.
  const [installEvent, setInstallEvent] = useState(null)
  const [installed, setInstalled] = useState(() => isStandaloneDisplay())
  const [installBannerHidden, setInstallBannerHidden] = useState(!!initial.installBannerHidden)

  // Avisos breves en pantalla.
  const [toasts, setToasts] = useState([])

  // Copias síncronas para las funciones asíncronas (no esperan a que React vuelva a pintar).
  const keyRef = useRef(null)
  const sessionRef = useRef(initial.session || null)
  const queueRef = useRef([])
  const onlineRef = useRef(online)
  const syncRef = useRef(null)
  const lastSyncRef = useRef(0)

  useEffect(() => {
    onlineRef.current = online
  }, [online])

  useEffect(() => {
    writeStore({ session, installBannerHidden })
  }, [session, installBannerHidden])

  const toast = useCallback((message, options = {}) => {
    const id = Math.random().toString(36).slice(2)
    setToasts((list) => [...list, { id, message, ...options }])
    setTimeout(() => setToasts((list) => list.filter((t) => t.id !== id)), options.duration || 4200)
  }, [])

  const dismissToast = useCallback((id) => setToasts((list) => list.filter((t) => t.id !== id)), [])

  const persist = useCallback((name, value) => {
    const account = sessionRef.current?.account
    if (account && keyRef.current) vault.save(keyRef.current, account, name, value).catch(() => {})
  }, [])

  const setQueue = useCallback(
    (next) => {
      queueRef.current = next
      setQueueState(next)
      persist('queue', next)
    },
    [persist],
  )

  // Datos del servidor + los cambios que todavía no confirma.
  const applySnapshot = useCallback(
    (snap) => {
      const at = Date.now()
      lastSyncRef.current = at
      setData(applyAll(snap, queueRef.current))
      setUser(snap.user)
      setLastSyncAt(at)
      persist('data', snap)
      persist('profile', snap.user)
      persist('meta', { lastSyncAt: at })
    },
    [persist],
  )

  const resetLocal = useCallback(() => {
    keyRef.current = null
    sessionRef.current = null
    queueRef.current = []
    setSession(null)
    setUser(null)
    setData(null)
    setQueueState([])
    setLastSyncAt(null)
    setSyncError(null)
  }, [])

  // El servidor dijo que la sesión ya no vale: se guarda la cola cifrada y se pide entrar otra vez.
  const expire = useCallback(
    async (message) => {
      const account = sessionRef.current?.account
      const pending = queueRef.current.length
      if (account) await vault.lock(account).catch(() => {})
      storage(
        'session',
        'set',
        LOGIN_NOTICE,
        message ||
          (pending
            ? `Tu sesión terminó. Vuelve a entrar: ${pending === 1 ? 'tu cambio pendiente se enviará' : `tus ${pending} cambios pendientes se enviarán`} al entrar.`
            : 'Tu sesión terminó. Vuelve a entrar.'),
      )
      resetLocal()
    },
    [resetLocal],
  )

  // Envía la cola (si hay) y trae los datos al día. Solo hay una sincronización a la vez.
  const syncNow = useCallback(() => {
    if (syncRef.current) return syncRef.current
    if (!sessionRef.current || !keyRef.current) return Promise.resolve(false)
    const task = (async () => {
      setSyncing(true)
      try {
        const pending = queueRef.current
        let snap
        if (pending.length) {
          const res = await api('/sync', {
            method: 'POST',
            body: { changes: pending.map(({ id, type, payload, title, icon, createdAt }) => ({ id, type, payload, title, icon, createdAt })) },
          })
          // Solo salen de la cola los cambios que el servidor contestó.
          const answered = new Map(res.results.map((r) => [r.id, r]))
          setQueue(queueRef.current.filter((c) => !answered.has(c.id)))
          for (const c of pending) {
            const r = answered.get(c.id)
            if (r?.status === 'rejected') toast(`No se aplicó «${c.title}»: ${r.error}`, { tone: 'danger', duration: 8000 })
          }
          snap = res.data
        } else {
          snap = await api('/data')
        }
        applySnapshot(snap)
        setReachable(true)
        setSyncError(null)
        return true
      } catch (error) {
        if (!(error instanceof ApiError)) {
          setSyncError('No pudimos leer la respuesta del servidor.')
        } else if (error.status === 401) {
          await expire()
        } else if (error.code === 'disabled') {
          await vault.lock(sessionRef.current?.account).catch(() => {})
          resetLocal()
          toast(error.message, { tone: 'danger', duration: 8000 })
        } else if (error.offline) {
          setReachable(false)
        } else {
          setSyncError(error.message)
        }
        return false
      } finally {
        setSyncing(false)
        syncRef.current = null
      }
    })()
    syncRef.current = task
    return task
  }, [applySnapshot, expire, resetLocal, setQueue, toast])

  // Al abrir la app: se leen del equipo los datos cifrados de la cuenta (funciona sin red).
  useEffect(() => {
    const account = initial.session?.account
    if (!account) return
    let cancelled = false
    ;(async () => {
      const key = await vault.getKey(account).catch(() => null)
      const [profile, snap, saved, meta] = key
        ? await Promise.all(['profile', 'data', 'queue', 'meta'].map((name) => vault.load(key, account, name).catch(() => undefined)))
        : []
      if (cancelled) return
      if (!key || !profile) {
        sessionRef.current = null
        setSession(null)
        setHydrated(true)
        return
      }
      keyRef.current = key
      queueRef.current = saved || []
      lastSyncRef.current = meta?.lastSyncAt || 0
      setQueueState(saved || [])
      setUser(profile)
      setData(snap ? applyAll(snap, saved || []) : null)
      setLastSyncAt(meta?.lastSyncAt || null)
      setHydrated(true)
    })()
    return () => {
      cancelled = true
    }
  }, [initial])

  // ——— Conexión ———
  const checkConnection = useCallback(async () => {
    const ok = await ping()
    setReachable(ok)
    return ok
  }, [])

  useEffect(() => {
    const goOnline = () => {
      setDeviceOnline(true)
      checkConnection()
    }
    const goOffline = () => setDeviceOnline(false)
    const onFocus = () => {
      checkConnection()
      // Al volver a la ventana se traen datos frescos si pasó más de medio minuto.
      if (onlineRef.current && Date.now() - lastSyncRef.current > 30000) syncNow()
    }
    window.addEventListener('online', goOnline)
    window.addEventListener('offline', goOffline)
    window.addEventListener('focus', onFocus)
    const first = setTimeout(checkConnection, 0)
    return () => {
      window.removeEventListener('online', goOnline)
      window.removeEventListener('offline', goOffline)
      window.removeEventListener('focus', onFocus)
      clearTimeout(first)
    }
  }, [checkConnection, syncNow])

  // Sin red se vuelve a probar cada 5 s (si el Wi-Fi sigue conectado no llega el evento «online»); con red, cada 30 s.
  useEffect(() => {
    const timer = setInterval(checkConnection, reachable ? 30000 : 5000)
    return () => clearInterval(timer)
  }, [reachable, checkConnection])

  // Con sesión y red: se valida la sesión, se envía la cola y se traen datos frescos.
  const account = session?.account
  const prevOnline = useRef(online)
  useEffect(() => {
    const cameBack = online && !prevOnline.current
    prevOnline.current = online
    if (!hydrated || !account || !online) return
    const t = setTimeout(() => {
      if (cameBack && queueRef.current.length) {
        const n = queueRef.current.length
        toast(`Conexión recuperada. Enviando ${n} ${n === 1 ? 'cambio' : 'cambios'}…`)
      }
      syncNow()
    }, 0)
    return () => clearTimeout(t)
  }, [hydrated, account, online, syncNow, toast])

  // Cada cambio nuevo se envía en cuanto hay red (agrupando los que se hacen casi al mismo tiempo).
  useEffect(() => {
    if (!hydrated || !online || queue.length === 0) return
    const t = setTimeout(() => syncNow(), 250)
    return () => clearTimeout(t)
  }, [hydrated, online, queue.length, syncNow])

  // Pendientes de cuando no había red: cerrar la sesión en el servidor y enviar formularios del sitio.
  useEffect(() => {
    if (!online) return
    if (storage('local', 'get', PENDING_LOGOUT)) {
      api('/auth/logout', { method: 'POST' })
        .then(() => storage('local', 'remove', PENDING_LOGOUT))
        .catch(() => {})
    }
    if (readOutbox().length) {
      flushOutbox().then((sent) => {
        if (sent) toast(sent === 1 ? 'Enviamos la solicitud que dejaste sin conexión.' : `Enviamos ${sent} solicitudes que dejaste sin conexión.`)
      })
    }
  }, [online, toast])

  // ——— Instalación ———
  useEffect(() => {
    const onPrompt = (event) => {
      event.preventDefault()
      setInstallEvent(event)
    }
    const onInstalled = () => {
      setInstalled(true)
      setInstallEvent(null)
    }
    window.addEventListener('beforeinstallprompt', onPrompt)
    window.addEventListener('appinstalled', onInstalled)
    const media = window.matchMedia?.('(display-mode: standalone)')
    const onMedia = () => setInstalled(isStandaloneDisplay())
    media?.addEventListener?.('change', onMedia)
    return () => {
      window.removeEventListener('beforeinstallprompt', onPrompt)
      window.removeEventListener('appinstalled', onInstalled)
      media?.removeEventListener?.('change', onMedia)
    }
  }, [])

  const promptInstall = useCallback(async () => {
    if (!installEvent) return 'unavailable'
    installEvent.prompt()
    const choice = await installEvent.userChoice
    setInstallEvent(null)
    if (choice.outcome === 'accepted') setInstalled(true)
    return choice.outcome
  }, [installEvent])

  // ——— Cambios ———
  // Todo cambio entra a la cola con un id único. Si hay red se envía enseguida; si no, espera a que vuelva.
  const submit = useCallback(
    (type, payload = {}, meta = {}) => {
      const change = {
        id: newChangeId(),
        type,
        payload,
        title: meta.title || type,
        icon: meta.icon || '133',
        createdAt: Date.now(),
        offline: !onlineRef.current,
      }
      setQueue([...queueRef.current, change])
      setData((d) => applyLocal(d, change))
      if (type === 'update-preferences') setUser((u) => (u ? { ...u, prefs: { ...u.prefs, ...payload } } : u))
      return change
    },
    [setQueue],
  )

  // ——— Sesión ———
  // Recibe la respuesta del servidor al iniciar sesión ({ user, dataKey }) y abre el almacén de esa cuenta.
  const completeSignIn = useCallback(
    async (res, space) => {
      const account = res.user.id
      const key = await vault.unlock(account, res.dataKey)
      const [saved, snap, meta] = await Promise.all(['queue', 'data', 'meta'].map((name) => vault.load(key, account, name).catch(() => undefined)))
      const restored = saved || []
      const next = { account, space: space && res.user.spaces.includes(space) ? space : res.user.spaces[0] || 'docente' }
      keyRef.current = key
      sessionRef.current = next
      queueRef.current = restored
      lastSyncRef.current = meta?.lastSyncAt || 0
      setQueueState(restored)
      setSession(next)
      setUser(res.user)
      setData(snap ? applyAll(snap, restored) : null)
      setLastSyncAt(meta?.lastSyncAt || null)
      setHydrated(true)
      vault.save(key, account, 'profile', res.user).catch(() => {})
      storage('session', 'remove', LOGIN_NOTICE)
      storage('local', 'remove', PENDING_LOGOUT)

      // Las preferencias guardadas en la cuenta se aplican en este equipo.
      const remote = Object.fromEntries(PREF_KEYS.filter((k) => k in (res.user.prefs || {})).map((k) => [k, res.user.prefs[k]]))
      if (Object.keys(remote).length) writePreferences({ ...readPreferences(), ...remote })

      if (restored.length) {
        toast(`Recuperamos ${restored.length} ${restored.length === 1 ? 'cambio pendiente' : 'cambios pendientes'} de tu sesión anterior. Enviando…`)
      }
      await syncNow()
      return next
    },
    [syncNow, toast],
  )

  const chooseSpace = useCallback((space) => {
    if (!sessionRef.current) return
    const next = { ...sessionRef.current, space }
    sessionRef.current = next
    setSession(next)
  }, [])

  const signOut = useCallback(async () => {
    const account = sessionRef.current?.account
    const pending = queueRef.current.length
    let serverClosed = true
    try {
      await api('/auth/logout', { method: 'POST' })
    } catch {
      serverClosed = false
      storage('local', 'set', PENDING_LOGOUT, '1') // se cierra en el servidor en cuanto haya red
    }
    if (account) {
      // Con cambios pendientes se conservan cifrados (sin la llave nadie puede leerlos); si no, se borra todo.
      await (pending ? vault.lock(account) : vault.wipe(account)).catch(() => {})
    }
    resetLocal()
    return { pending, serverClosed }
  }, [resetLocal])

  // Borra la copia local de los datos (no la cola) y la vuelve a descargar si hay red.
  const clearOfflineData = useCallback(async () => {
    const account = sessionRef.current?.account
    if (!account) return
    await vault.remove(account, 'data').catch(() => {})
    await vault.remove(account, 'meta').catch(() => {})
    if (onlineRef.current) await syncNow()
  }, [syncNow])

  const value = useMemo(
    () => ({
      online,
      networkOnline,
      checkConnection,
      simulateOffline,
      setSimulateOffline,
      session,
      hydrated,
      user,
      data,
      teacher: data?.docente || EMPTY_TEACHER,
      institution: data?.institucion || EMPTY_INSTITUTION,
      school: data?.school || null,
      history: data?.changes || [],
      completeSignIn,
      chooseSpace,
      signOut,
      clearOfflineData,
      persistent: vault.isPersistent,
      installed,
      canInstall: !!installEvent,
      promptInstall,
      installBannerHidden,
      hideInstallBanner: () => setInstallBannerHidden(true),
      queue,
      submit,
      syncing,
      syncNow,
      syncError,
      lastSyncAt,
      lastSync: whenLabel(lastSyncAt),
      toasts,
      toast,
      dismissToast,
    }),
    [
      online,
      networkOnline,
      checkConnection,
      simulateOffline,
      session,
      hydrated,
      user,
      data,
      completeSignIn,
      chooseSpace,
      signOut,
      clearOfflineData,
      installed,
      installEvent,
      promptInstall,
      installBannerHidden,
      queue,
      submit,
      syncing,
      syncNow,
      syncError,
      lastSyncAt,
      toasts,
      toast,
      dismissToast,
    ],
  )

  return <AppStateContext.Provider value={value}>{children}</AppStateContext.Provider>
}

// eslint-disable-next-line react-refresh/only-export-components
export function useApp() {
  const ctx = useContext(AppStateContext)
  if (!ctx) throw new Error('useApp debe usarse dentro de <AppStateProvider>')
  return ctx
}

// eslint-disable-next-line react-refresh/only-export-components
export function readLoginNotice() {
  const text = storage('session', 'get', LOGIN_NOTICE)
  storage('session', 'remove', LOGIN_NOTICE)
  return text
}
