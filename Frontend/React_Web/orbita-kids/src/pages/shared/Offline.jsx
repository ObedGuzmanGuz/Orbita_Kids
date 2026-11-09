import { useNavigate, useOutletContext } from 'react-router-dom'
import Icon from '../../components/Icon'
import { AppHeader } from '../../layouts/AppShell'
import { useApp } from '../../state/AppState'
import './shared.css'

const WORKS = [
  'Consultar grupos, estudiantes y resultados',
  'Crear y editar borradores de actividades',
  'Leer avisos ya descargados',
  'Cambiar preferencias',
]
const WAITS = ['Publicar actividades', 'Solicitar grupos', 'Exportar reportes', 'Iniciar sesión en un equipo nuevo']

// 29 · Sin conexión en la app
export default function Offline() {
  const { online, queue, lastSync, toast, checkConnection, simulateOffline } = useApp()
  const { space } = useOutletContext()
  const navigate = useNavigate()
  const base = space === 'institucion' ? '/institucion' : '/docente'

  const retry = async () => {
    const reachable = await checkConnection()
    if (reachable && !simulateOffline) {
      toast('Conexión recuperada')
      navigate(base)
    } else {
      toast('Todavía sin conexión. Reintentaremos solos en cuanto vuelva Internet.')
    }
  }

  return (
    <>
      <AppHeader title={online ? 'Conexión' : 'Sin conexión'} eyebrow="Sincronización" />
      <div className="page">
        <div className="page-head offline-head">
          <span className="offline-head__icon">
            <Icon n="128" />
          </span>
          <div className="page-head__text">
            <h2 className="page-title">{online ? 'Estás en línea' : 'Estás sin conexión'}</h2>
            <p className="page-sub">Última sincronización: {lastSync}. {online ? 'Todo está al día.' : 'Sigues trabajando con estos datos.'}</p>
          </div>
          <button type="button" className="btn btn--secondary" onClick={() => navigate(`${base}/sincronizacion`)}>
            <Icon n="129" />
            Ver pendientes ({queue.length})
          </button>
          <button type="button" className="btn btn--primary" onClick={retry}>
            Reintentar
          </button>
        </div>

        <div className="split-2">
          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Funciona sin conexión</h3>
              <span className="tag tag--success" style={{ marginLeft: 'auto' }}>Disponible</span>
            </div>
            <ul>
              {WORKS.map((t) => (
                <li key={t} className="list-row">
                  <span className="icon-box" style={{ background: 'var(--success-bg)' }}>
                    <Icon n="130" />
                  </span>
                  <span className="list-row__title">{t}</span>
                </li>
              ))}
            </ul>
          </section>
          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Espera a que vuelva Internet</h3>
              <span className="tag tag--warning" style={{ marginLeft: 'auto' }}>En cola</span>
            </div>
            <ul>
              {WAITS.map((t) => (
                <li key={t} className="list-row">
                  <span className="icon-box" style={{ background: 'var(--warning-bg)' }}>
                    <Icon n="131" />
                  </span>
                  <span className="list-row__title">{t}</span>
                </li>
              ))}
            </ul>
          </section>
        </div>

        <section className="card how-it-works">
          <span className="icon-box" style={{ background: 'var(--primary-bg)' }}>
            <Icon n="132" />
          </span>
          <p>
            <strong>Cómo lo hace:</strong> el service worker guarda la app en caché para abrirla sin red. Los datos sincronizados viven en
            IndexedDB de este equipo, cifrados por cuenta. Cada cambio hecho sin conexión recibe un identificador único y entra a una cola
            que se envía sola al reconectar; el servidor usa ese identificador para no aplicar nunca un cambio dos veces.
          </p>
        </section>
      </div>
    </>
  )
}
