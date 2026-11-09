import { useCallback, useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../../state/api'
import { useApp } from '../../state/AppState'
import './site-pages.css'

// Estado del servicio: comprueba en vivo el backend y lo que el navegador necesita para trabajar sin conexión.
async function runChecks() {
  const started = performance.now()
  const server = await api(`/health?t=${Date.now()}`, { timeout: 8000 }).catch(() => null)
  const latency = Math.round(performance.now() - started)
  const sw = 'serviceWorker' in navigator ? await navigator.serviceWorker.getRegistration().catch(() => null) : null
  const storage = navigator.storage?.estimate ? await navigator.storage.estimate().catch(() => null) : null
  return {
    at: new Date(),
    items: [
      {
        key: 'api',
        title: 'Servidor (API)',
        ok: !!server?.ok,
        detail: server ? `Responde en ${latency} ms · versión ${server.version}` : 'No responde. La app sigue funcionando con los datos guardados en este equipo.',
      },
      {
        key: 'db',
        title: 'Base de datos',
        ok: !!server?.ok,
        detail: server ? `SQLite · consulta en ${server.dbLatencyMs.toFixed(2)} ms` : 'Sin datos: el servidor no respondió.',
      },
      {
        key: 'sw',
        title: 'Modo sin conexión (service worker)',
        ok: !!sw?.active,
        warn: !sw?.active,
        detail: sw?.active ? 'Activo: la app abre aunque no haya Internet.' : 'Inactivo en este modo (en desarrollo no se registra). Se activa en la versión instalable.',
      },
      {
        key: 'crypto',
        title: 'Almacenamiento cifrado',
        ok: typeof indexedDB !== 'undefined' && !!globalThis.crypto?.subtle,
        detail:
          typeof indexedDB !== 'undefined' && globalThis.crypto?.subtle
            ? `IndexedDB + AES-256${storage ? ` · ${(storage.usage / 1024 / 1024).toFixed(1)} MB usados` : ''}`
            : 'Este navegador no lo permite aquí (usa https o localhost).',
      },
    ],
  }
}

export default function Status() {
  const { online } = useApp()
  const [report, setReport] = useState(null)
  const [checking, setChecking] = useState(false)

  const check = useCallback(async () => {
    setChecking(true)
    setReport(await runChecks())
    setChecking(false)
  }, [])

  useEffect(() => {
    document.title = 'Estado del servicio · Órbita Kids'
    const t = setTimeout(check, 0)
    return () => clearTimeout(t)
  }, [check])

  const problems = report?.items.filter((i) => !i.ok && !i.warn).length ?? 0
  const summary = !report
    ? 'Comprobando…'
    : problems === 0
      ? 'Todos los servicios funcionan'
      : online
        ? 'Hay servicios con problemas'
        : 'Sin conexión: la app sigue funcionando con tus datos guardados'

  return (
    <div className="container site-page status-page">
      <p className="site-eyebrow">Estado del servicio</p>
      <div className={`status-hero${report ? (problems ? ' is-down' : ' is-up') : ''}`}>
        <span className="status-hero__dot" aria-hidden />
        <div>
          <h1 className="site-h2">{summary}</h1>
          <p className="site-lead">
            {report ? `Última comprobación: ${report.at.toLocaleTimeString('es-MX', { hour: 'numeric', minute: '2-digit', second: '2-digit', hour12: false })}` : 'Un momento…'} · versión de
            la app {__APP_VERSION__}
          </p>
        </div>
        <button type="button" className="btn btn--secondary" onClick={check} disabled={checking}>
          {checking ? 'Comprobando…' : 'Volver a comprobar'}
        </button>
      </div>

      <ul className="status-list" aria-live="polite">
        {(report?.items || []).map((i) => (
          <li key={i.key} className={`status-item${i.ok ? ' is-ok' : i.warn ? ' is-warn' : ' is-bad'}`}>
            <span className="status-item__dot" aria-hidden />
            <div>
              <h2>{i.title}</h2>
              <p>{i.detail}</p>
            </div>
            <span className={`tag ${i.ok ? 'tag--success' : i.warn ? 'tag--warning' : 'tag--danger'}`}>{i.ok ? 'Operando' : i.warn ? 'Aviso' : 'Sin servicio'}</span>
          </li>
        ))}
      </ul>

      <p className="card__note" style={{ marginTop: 24 }}>
        ¿Algo no funciona? Revisa la <Link to="/#preguntas" className="link">ayuda</Link> o <Link to="/contacto" className="link">escríbenos</Link>.
      </p>
    </div>
  )
}
