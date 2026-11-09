import { useEffect, useState } from 'react'
import Icon from '../../components/Icon'
import Dialog from '../../components/Dialog'
import { AppHeader } from '../../layouts/AppShell'
import { CheckToggle } from '../teacher/Notices'
import { useApp } from '../../state/AppState'
import { usePreferences } from '../../state/preferences'
import '../shared/shared.css'

const PREF_LABEL = { theme: 'tema', largeText: 'texto más grande', reduceMotion: 'reducir movimiento', captureLinks: 'abrir enlaces en la app' }

function formatMB(bytes) {
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`
}

// 31 · Perfil y configuración
export default function Profile() {
  const { user, installed, canInstall, promptInstall, toast, submit, school, online, clearOfflineData } = useApp()
  const [prefs, setLocalPref] = usePreferences()
  // La preferencia se aplica en este equipo y se guarda en la cuenta (llega a tus otros equipos).
  const setPref = (key, value) => {
    setLocalPref(key, value)
    const label = PREF_LABEL[key]
    const detail = typeof value === 'boolean' ? (value ? '' : ' (desactivada)') : ` (${value})`
    submit('update-preferences', { [key]: value }, { title: `Preferencia: ${label}${detail}`, icon: '135' })
  }
  const [usage, setUsage] = useState(null)
  const [confirmClear, setConfirmClear] = useState(false)
  const [editing, setEditing] = useState(false)
  const [visibleName, setVisibleName] = useState(user.short)

  useEffect(() => {
    navigator.storage?.estimate?.().then((e) => setUsage(e)).catch(() => {})
  }, [])

  const clearOffline = async () => {
    setConfirmClear(false)
    await clearOfflineData()
    const e = await navigator.storage?.estimate?.().catch(() => null)
    if (e) setUsage(e)
    toast(online ? 'Borramos la copia sin conexión y descargamos una nueva.' : 'Datos sin conexión borrados. Se volverán a descargar al sincronizar.')
  }

  const used = usage?.usage ?? 18.4 * 1024 * 1024
  const quota = usage?.quota ?? 200 * 1024 * 1024

  return (
    <>
      <AppHeader title="Perfil y configuración" eyebrow="Cuenta" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Perfil y configuración</h2>
            <p className="page-sub">Tus preferencias se guardan en tu cuenta y también aplican en la app móvil.</p>
          </div>
        </div>

        <div className="profile-grid">
          <section className="card profile-card">
            <span className="avatar avatar--profile" style={{ background: user.color }}>{user.initials}</span>
            <h3 className="profile-card__name">{user.name}</h3>
            <p className="card__note">{user.email}</p>
            <span className="tag tag--teal" style={{ marginTop: 12 }}>{user.roleLabel}</span>
            <p className="card__note" style={{ marginTop: 12 }}>
              {school?.name ? `Escuela ${school.name}` : ''}
              <br />
              Google Workspace for Education
            </p>
            <button type="button" className="btn btn--sm profile-card__edit" onClick={() => setEditing(true)}>
              <Icon n="136" />
              Editar nombre visible
            </button>
          </section>

          <div className="create-side" style={{ gap: 20 }}>
            <section className="card">
              <h3 className="card__title" style={{ marginBottom: 6 }}>
                Apariencia y lectura
              </h3>
              <ul className="settings-list">
                <li>
                  <span>
                    <strong>Tema</strong>
                    <small>Claro, oscuro o el del sistema</small>
                  </span>
                  <span className="pills" role="radiogroup" aria-label="Tema">
                    {[
                      ['light', 'Claro'],
                      ['dark', 'Oscuro'],
                      ['system', 'Sistema'],
                    ].map(([key, label]) => (
                      <button
                        key={key}
                        type="button"
                        role="radio"
                        className="pill"
                        aria-checked={prefs.theme === key}
                        aria-pressed={prefs.theme === key}
                        disabled={key === 'dark'}
                        title={key === 'dark' ? 'El tema oscuro llegará en una próxima versión' : undefined}
                        onClick={() => setPref('theme', key)}
                      >
                        {label}
                      </button>
                    ))}
                  </span>
                </li>
                <li>
                  <span>
                    <strong>Texto más grande</strong>
                    <small>Aumenta 10 % el tamaño en toda la app</small>
                  </span>
                  <CheckToggle checked={prefs.largeText} onChange={(v) => setPref('largeText', v)} label="Texto más grande" />
                </li>
                <li>
                  <span>
                    <strong>Reducir movimiento</strong>
                    <small>Quita animaciones y transiciones</small>
                  </span>
                  <CheckToggle checked={prefs.reduceMotion} onChange={(v) => setPref('reduceMotion', v)} label="Reducir movimiento" />
                </li>
              </ul>
            </section>

            <section className="card">
              <h3 className="card__title" style={{ marginBottom: 6 }}>
                App de escritorio
              </h3>
              <ul className="settings-list">
                <li>
                  <span>
                    <strong>Estado</strong>
                    <small>{installed ? `Instalada en este equipo · versión ${__APP_VERSION__}` : 'Sin instalar · la estás usando en el navegador'}</small>
                  </span>
                  {installed ? (
                    <span className="tag tag--success">Activo</span>
                  ) : (
                    <button type="button" className="btn btn--outline btn--sm" onClick={() => (canInstall ? promptInstall() : (window.location.href = '/instalar'))}>
                      Instalar
                    </button>
                  )}
                </li>
                <li>
                  <span>
                    <strong>Abrir enlaces de Órbita Kids en la app</strong>
                    <small>Los enlaces de correos abren la ventana de la app</small>
                  </span>
                  <CheckToggle checked={prefs.captureLinks} onChange={(v) => setPref('captureLinks', v)} label="Abrir enlaces en la app" />
                </li>
                <li>
                  <span style={{ flex: 1 }}>
                    <strong>Datos sin conexión</strong>
                    <small>{formatMB(used)} en este equipo · grupos, resultados y borradores</small>
                    <span className="progress" style={{ display: 'block', maxWidth: 280, marginTop: 6 }}>
                      <span className="progress__bar" style={{ width: `${Math.max(4, Math.min(100, (used / quota) * 100 * 8))}%`, background: 'var(--primary)' }} />
                    </span>
                  </span>
                  <button type="button" className="btn btn--secondary btn--sm" onClick={() => setConfirmClear(true)}>
                    Borrar
                  </button>
                </li>
              </ul>
            </section>
          </div>
        </div>
      </div>

      {confirmClear && (
        <Dialog title="¿Borrar los datos sin conexión?" onClose={() => setConfirmClear(false)}>
          <p className="dialog__text">Se borran los grupos, resultados y borradores guardados en este equipo. Tu cuenta no cambia: todo vuelve al sincronizar.</p>
          <div className="dialog__actions">
            <button type="button" className="btn btn--outline" onClick={() => setConfirmClear(false)} data-close>
              Cancelar
            </button>
            <button type="button" className="btn btn--danger" onClick={clearOffline}>
              Borrar datos
            </button>
          </div>
        </Dialog>
      )}

      {editing && (
        <Dialog title="Nombre visible" onClose={() => setEditing(false)}>
          <form
            onSubmit={(e) => {
              e.preventDefault()
              setEditing(false)
              submit('update-preferences', { visibleName: visibleName.trim() || user.short }, { title: 'Nombre visible', icon: '135' })
              toast(`Ahora te verán como «${visibleName.trim() || user.short}»`)
            }}
          >
            <div className="field" style={{ marginTop: 14 }}>
              <label className="field__label" htmlFor="visible-name">
                Así te ven tus estudiantes y la dirección
              </label>
              <input id="visible-name" className="input" value={visibleName} onChange={(e) => setVisibleName(e.target.value)} maxLength={40} />
            </div>
            <div className="dialog__actions">
              <button type="button" className="btn btn--outline" onClick={() => setEditing(false)} data-close>
                Cancelar
              </button>
              <button type="submit" className="btn btn--primary">
                Guardar
              </button>
            </div>
          </form>
        </Dialog>
      )}
    </>
  )
}
