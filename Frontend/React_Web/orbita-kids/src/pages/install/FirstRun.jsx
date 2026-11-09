import { useNavigate } from 'react-router-dom'
import Icon from '../../components/Icon'
import CenteredPanel from '../../components/CenteredPanel'
import { useApp } from '../../state/AppState'
import appIcon from '../../assets/img/app-icon.png'
import './install.css'

const FIRST_RUN_KEY = 'orbita-kids:first-run-done'

// 12 · Primer arranque de la app instalada
export default function FirstRun() {
  const { session } = useApp()
  const navigate = useNavigate()

  const done = () => {
    try {
      localStorage.setItem(FIRST_RUN_KEY, '1')
    } catch {
      /* sin almacenamiento */
    }
    navigate(session ? `/${session.space}` : '/login', { replace: true })
  }

  return (
    <CenteredPanel width={760} windowTitle="Bienvenida">
      <img src={appIcon} alt="" className="first-run__icon" />
      <h1 className="panel__title">Órbita Kids ya está en tu computadora</h1>
      <p className="panel__text">Se abrió en su propia ventana. La próxima vez búscala como cualquier app.</p>
      <div className="first-run__grid">
        {[
          ['047', 'Dónde está', 'Menú Inicio en Windows, Dock y Launchpad en macOS, o el iniciador de Chromebook.'],
          ['048', 'Sin conexión', 'Abre aunque no haya Internet y muestra lo último que sincronizaste.'],
          ['049', 'Actualizaciones', 'Se descargan solas. Si hace falta reiniciar, te avisamos.'],
        ].map(([icon, title, text]) => (
          <div key={title} className="first-run__item">
            <span className="icon-box" style={{ background: 'var(--primary-bg)' }}>
              <Icon n={icon} />
            </span>
            <strong>{title}</strong>
            <p>{text}</p>
          </div>
        ))}
      </div>
      <button type="button" className="btn btn--primary btn--lg" style={{ marginTop: 24, minWidth: 220 }} onClick={done}>
        Continuar
      </button>
    </CenteredPanel>
  )
}
