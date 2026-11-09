import { useEffect, useState } from 'react'
import { useRegisterSW } from 'virtual:pwa-register/react'
import Icon from './Icon'
import { TitleBar } from '../layouts/AppShell'
import { useApp } from '../state/AppState'
import './centered-panel.css'

const NEWS = [
  'Exportar resultados del grupo en PDF.',
  'Filtro «Sin actividad reciente» en la tabla de estudiantes.',
  'Mejoras de lectura con texto grande.',
]

function hasDraft() {
  try {
    return !!localStorage.getItem('orbita-kids:draft-activity')
  } catch {
    return false
  }
}

// 14 · Nueva versión disponible. Se conecta al service worker real (registerType: 'prompt').
export default function UpdatePrompt() {
  const { toast } = useApp()
  const [nextVersion, setNextVersion] = useState(null)
  const [later, setLater] = useState(false)
  const {
    needRefresh: [needRefresh],
    offlineReady: [offlineReady, setOfflineReady],
    updateServiceWorker,
  } = useRegisterSW({
    onRegisteredSW(_url, registration) {
      // Revisa si hay versión nueva cada hora mientras la app está abierta.
      if (registration) setInterval(() => registration.update().catch(() => {}), 60 * 60 * 1000)
    },
  })

  useEffect(() => {
    if (offlineReady) {
      toast('Lista para usarse sin conexión.')
      setOfflineReady(false)
    }
  }, [offlineReady, setOfflineReady, toast])

  useEffect(() => {
    if (!needRefresh) return
    fetch(`/version.json?t=${Date.now()}`, { cache: 'no-store' })
      .then((r) => r.json())
      .then((v) => setNextVersion(v.version))
      .catch(() => {})
  }, [needRefresh])

  if (!needRefresh || later) return null

  return (
    <div className="update-overlay" role="dialog" aria-modal="true" aria-labelledby="update-title">
      <TitleBar title="Versión nueva" />
      <div className="panel" style={{ width: 'min(560px, 100%)' }}>
        <span className="panel__icon" style={{ background: 'var(--primary-bg)' }}>
          <Icon n="052" />
        </span>
        <h1 className="panel__title" id="update-title">
          Hay una versión nueva
        </h1>
        <p className="panel__text">
          Versión {__APP_VERSION__} → <strong>{nextVersion || 'nueva'}</strong> · descargada en segundo plano
        </p>
        <div className="card" style={{ marginTop: 18, textAlign: 'left', padding: 16 }}>
          <h2 className="card__title" style={{ fontSize: 16 }}>
            Novedades
          </h2>
          <ul className="update-news">
            {NEWS.map((n) => (
              <li key={n}>{n}</li>
            ))}
          </ul>
        </div>
        {hasDraft() && (
          <div className="notice notice--info" style={{ color: 'var(--primary-ink)', fontWeight: 600 }}>
            <Icon n="053" />
            Tienes un borrador abierto. Lo guardamos antes de actualizar.
          </div>
        )}
        <div className="panel__actions">
          <button type="button" className="btn btn--primary btn--lg" onClick={() => updateServiceWorker(true)}>
            Actualizar ahora
          </button>
          <button type="button" className="btn btn--outline btn--lg" onClick={() => setLater(true)}>
            Al cerrar la app
          </button>
        </div>
        <p className="panel__note">La app nunca se recarga sola mientras escribes.</p>
      </div>
    </div>
  )
}
