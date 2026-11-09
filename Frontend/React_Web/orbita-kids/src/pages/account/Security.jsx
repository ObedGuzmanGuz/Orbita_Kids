import { useCallback, useEffect, useState } from 'react'
import Icon from '../../components/Icon'
import { AppHeader } from '../../layouts/AppShell'
import { CheckToggle } from '../teacher/Notices'
import { useApp } from '../../state/AppState'
import { api } from '../../state/api'
import { whenLabel } from '../../state/format'
import '../shared/shared.css'

const METHODS = {
  google: { icon: '123', title: 'Google Workspace for Education', note: 'Tu contraseña se administra en Google. Órbita Kids no la guarda.' },
  microsoft: { icon: '019', title: 'Microsoft 365 · Entra ID', note: 'Tu contraseña se administra en Microsoft. Órbita Kids no la guarda.' },
  password: { icon: '036', title: 'Cuenta Órbita Kids', note: 'El servidor solo guarda una huella (hash scrypt) de tu contraseña, nunca la contraseña.' },
  demo: { icon: '036', title: 'Acceso de demostración', note: 'Entraste con el acceso rápido de «Explorar». En una escuela real se entra con Google, Microsoft o contraseña.' },
}
const METHOD_LABEL = { password: 'contraseña', google: 'Google', microsoft: 'Microsoft', demo: 'demostración' }

// 32 · Seguridad y sesiones
export default function Security() {
  const { user, online, toast, submit } = useApp()
  const [twoStep, setTwoStep] = useState(!!user.twoFactor)
  const [sessions, setSessions] = useState(null)
  const [failed, setFailed] = useState(false)

  const load = useCallback(() => {
    api('/auth/sessions')
      .then((r) => {
        setSessions(r.sessions)
        setFailed(false)
      })
      .catch(() => setFailed(true))
  }, [])

  useEffect(() => {
    if (!online) return
    const t = setTimeout(load, 0)
    return () => clearTimeout(t)
  }, [online, load])

  const close = async (id) => {
    if (!online) return toast('Necesitas conexión para cerrar sesiones en otros equipos.')
    try {
      await api('/auth/sessions/revoke', { method: 'POST', body: { id } })
      toast('Sesión cerrada en ese equipo. Tendrá que volver a entrar.')
      load()
    } catch (err) {
      toast(err.message)
    }
  }

  const closeOthers = async () => {
    if (!online) return toast('Necesitas conexión para cerrar sesiones en otros equipos.')
    try {
      const r = await api('/auth/sessions/revoke', { method: 'POST', body: { others: true } })
      toast(r.closed === 1 ? 'Cerraste 1 sesión en otro equipo.' : `Cerraste ${r.closed} sesiones en otros equipos.`)
      load()
    } catch (err) {
      toast(err.message)
    }
  }

  const current = sessions?.find((s) => s.current)
  const method = METHODS[current?.method] || METHODS.password

  return (
    <>
      <AppHeader title="Seguridad y sesiones" eyebrow="Cuenta" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Seguridad y sesiones</h2>
            <p className="page-sub">Revisa cómo entras y dónde tienes la sesión abierta.</p>
          </div>
        </div>

        <div className="settings-grid">
          <section className="card">
            <h3 className="card__title" style={{ marginBottom: 14 }}>
              Método de acceso
            </h3>
            <div className="row" style={{ alignItems: 'flex-start' }}>
              <span className="icon-box" style={{ width: 44, height: 44, background: '#fff', border: '1px solid var(--border)' }}>
                <Icon n={method.icon} />
              </span>
              <div>
                <p className="list-row__title">{method.title}</p>
                <p className="list-row__sub">{user.email}</p>
              </div>
            </div>
            <p className="card__note" style={{ marginTop: 14 }}>
              {method.note}
            </p>
          </section>
          <section className="card">
            <h3 className="card__title" style={{ marginBottom: 6 }}>
              Verificación en dos pasos
            </h3>
            <ul className="settings-list">
              <li>
                <span>
                  <strong>Pedir un código al entrar</strong>
                  <small>{user.spaces.includes('institucion') ? 'Recomendado para la dirección' : 'Opcional para docentes'}</small>
                </span>
                <CheckToggle
                  checked={twoStep}
                  onChange={(v) => {
                    setTwoStep(v)
                    submit('update-security', { twoFactor: v }, { title: v ? 'Activar verificación en dos pasos' : 'Desactivar verificación en dos pasos', icon: '078' })
                    toast(v ? 'Te pediremos un código de 6 dígitos al entrar.' : 'Verificación en dos pasos desactivada.')
                  }}
                  label="Pedir un código al entrar"
                />
              </li>
            </ul>
          </section>
        </div>

        <section className="card" style={{ marginTop: 20 }}>
          <div className="card__head">
            <h3 className="card__title">Sesiones activas</h3>
            <button
              type="button"
              className="btn btn--danger-outline btn--sm"
              style={{ marginLeft: 'auto' }}
              disabled={!sessions || sessions.length < 2 || !online}
              onClick={closeOthers}
            >
              Cerrar las otras sesiones
            </button>
          </div>
          {!online && !sessions && <p className="empty-note">Necesitas conexión para ver tus sesiones abiertas.</p>}
          {online && failed && <p className="empty-note">No pudimos leer tus sesiones. Intenta de nuevo en un momento.</p>}
          {online && !failed && !sessions && <p className="empty-note">Cargando sesiones…</p>}
          <ul>
            {sessions?.map((s) => (
              <li key={s.id} className="list-row">
                <span className="icon-box">
                  <Icon n={s.mobile ? '139' : s.current ? '137' : '138'} />
                </span>
                <span className="list-row__body">
                  <span className="list-row__title" style={{ display: 'block' }}>
                    {s.browser} · {s.os}
                  </span>
                  <span className="list-row__sub">
                    {s.current ? 'Este equipo · ahora' : `Activa ${whenLabel(s.lastSeenAt)}`} · entró con {METHOD_LABEL[s.method] || s.method}
                  </span>
                </span>
                {s.current ? (
                  <span className="tag tag--success">Esta sesión</span>
                ) : (
                  <button type="button" className="btn btn--ghost btn--sm" style={{ color: 'var(--danger)' }} onClick={() => close(s.id)}>
                    Cerrar
                  </button>
                )}
              </li>
            ))}
          </ul>
        </section>
      </div>
    </>
  )
}
