import { useState } from 'react'
import { Link } from 'react-router-dom'
import Icon from '../../components/Icon'
import { AppHeader } from '../../layouts/AppShell'
import { useApp } from '../../state/AppState'
import './teacher.css'

export function CheckToggle({ checked, onChange, label }) {
  return (
    <button type="button" role="switch" aria-checked={checked} aria-label={label} className={`check-toggle${checked ? ' is-on' : ''}`} onClick={() => onChange(!checked)}>
      {checked && <Icon n="101" />}
    </button>
  )
}

const PREF_FIELD = { desktop: 'notifyDesktop', email: 'notifyEmail', quiet: 'quietHours' }
const PREF_TITLE = { desktop: 'notificaciones de escritorio', email: 'resumen por correo', quiet: 'horario sin avisos' }

export default function Notices({ space = 'docente' }) {
  const { toast, teacher, institution, user, submit } = useApp()
  const list = (space === 'institucion' ? institution : teacher).notices
  const stored = user?.prefs || {}
  const prefs = {
    app: true,
    desktop: stored.notifyDesktop ?? false,
    email: stored.notifyEmail ?? true,
    quiet: stored.quietHours ?? true,
  }
  const unread = list.filter((n) => n.unread)
  const [busy, setBusy] = useState(false)

  const markRead = (ids) => {
    if (!ids.length) return
    submit('mark-notices-read', { ids }, { title: ids.length === 1 ? 'Aviso marcado como leído' : `Avisos marcados como leídos (${ids.length})`, icon: '134' })
  }

  const setPref = (key) => async (value) => {
    if (key === 'app') return
    if (key === 'desktop' && value) {
      if (!('Notification' in window)) return toast('Este navegador no permite notificaciones de escritorio.')
      setBusy(true)
      const result = await Notification.requestPermission()
      setBusy(false)
      if (result !== 'granted') return toast('El navegador no dio permiso para notificaciones.')
      new Notification('Órbita Kids', { body: 'Las notificaciones de escritorio están activas.', icon: '/pwa-192.png' })
    }
    submit('update-preferences', { [PREF_FIELD[key]]: value }, { title: `Preferencia: ${PREF_TITLE[key]} ${value ? 'activado' : 'desactivado'}`, icon: '135' })
  }

  return (
    <>
      <AppHeader title="Avisos" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Avisos</h2>
            <p className="page-sub">{unread.length ? `${unread.length} sin leer` : 'Todo al día'}</p>
          </div>
          <button type="button" className="btn btn--secondary" disabled={!unread.length} onClick={() => markRead(unread.map((n) => n.id))}>
            <Icon n="099" />
            Marcar todo como leído
          </button>
        </div>

        <div className="notices-grid">
          <section className="card">
            {list.length === 0 && <p className="empty-note">No tienes avisos. Aquí llegarán las entregas, solicitudes y novedades de tus grupos.</p>}
            <ul>
              {list.map((n) => (
                <li key={n.id}>
                  <Link to={n.to} className="list-row notice-row" onClick={() => n.unread && markRead([n.id])}>
                    <span className="icon-box">
                      <Icon n={n.icon} />
                    </span>
                    <span className="list-row__body">
                      <span className="list-row__title" style={{ display: 'block' }}>{n.title}</span>
                      <span className="list-row__sub">{n.meta}</span>
                    </span>
                    {n.unread && <span className="notice-row__dot" aria-label="Sin leer" />}
                  </Link>
                </li>
              ))}
            </ul>
          </section>
          <section className="card">
            <h3 className="card__title" style={{ marginBottom: 8 }}>
              Cómo te avisamos
            </h3>
            <ul className="prefs">
              <li>
                <span>
                  <strong>En la app</strong>
                  <small>Siempre activo</small>
                </span>
                <CheckToggle checked={prefs.app} onChange={setPref('app')} label="En la app" />
              </li>
              <li>
                <span>
                  <strong>Notificaciones de escritorio</strong>
                  <small>Pide permiso al activarlas</small>
                </span>
                <CheckToggle checked={prefs.desktop} onChange={busy ? () => {} : setPref('desktop')} label="Notificaciones de escritorio" />
              </li>
              <li>
                <span>
                  <strong>Resumen por correo</strong>
                  <small>Viernes a las 14:00</small>
                </span>
                <CheckToggle checked={prefs.email} onChange={setPref('email')} label="Resumen por correo" />
              </li>
              <li>
                <span>
                  <strong>Horario sin avisos</strong>
                  <small>20:00 a 7:00</small>
                </span>
                <CheckToggle checked={prefs.quiet} onChange={setPref('quiet')} label="Horario sin avisos" />
              </li>
            </ul>
          </section>
        </div>
      </div>
    </>
  )
}
