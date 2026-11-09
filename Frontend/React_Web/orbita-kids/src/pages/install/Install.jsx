import { Link, useNavigate } from 'react-router-dom'
import Icon from '../../components/Icon'
import CenteredPanel from '../../components/CenteredPanel'
import { useApp } from '../../state/AppState'
import windowArt from '../../assets/img/install-window.svg'
import './install.css'

const PERKS = [
  ['037', 'Su propia ventana, sin pestañas ni barra de direcciones'],
  ['038', 'Abre sin Internet con lo último sincronizado'],
  ['039', 'Se actualiza sola en segundo plano'],
  ['040', 'Avisos de escritorio, solo si los activas'],
  ['041', 'Ocupa menos de 20 MB'],
]

// 11a/11b · Instalar la app (el diálogo 11b lo muestra el navegador con beforeinstallprompt)
export default function Install() {
  const { installed, canInstall, promptInstall, session, toast } = useApp()
  const navigate = useNavigate()

  const install = async () => {
    if (!canInstall) {
      navigate('/instalar/navegadores')
      return
    }
    const outcome = await promptInstall()
    if (outcome === 'accepted') toast('Órbita Kids se está instalando…')
  }

  const later = () => navigate(session ? `/${session.space}` : '/')

  return (
    <CenteredPanel width={820} windowTitle="Instalar la app">
      <div className="install">
        <div className="install__copy">
          <span className="tag tag--primary">App de escritorio · PWA</span>
          <h1 className="install__title">Instala Órbita Kids en tu computadora</h1>
          <p className="install__lead">Es la misma app web, pero se abre en su propia ventana, desde el menú Inicio o el Dock.</p>
          <ul className="install__perks">
            {PERKS.map(([icon, text]) => (
              <li key={icon}>
                <span className="icon-box" style={{ width: 28, height: 28, borderRadius: 8, background: 'var(--primary-bg)' }}>
                  <Icon n={icon} />
                </span>
                {text}
              </li>
            ))}
          </ul>
          {installed ? (
            <div className="notice notice--success" style={{ marginTop: 20 }}>
              <span>
                <strong className="notice__title">Ya está instalada en este equipo.</strong>{' '}
                <span className="notice__text">Ábrela desde el menú Inicio, el Dock o el iniciador.</span>
              </span>
            </div>
          ) : (
            <div className="install__actions">
              <button type="button" className="btn btn--primary btn--lg" onClick={install}>
                <Icon n="042" />
                Instalar app
              </button>
              <button type="button" className="btn btn--ghost btn--lg" onClick={later}>
                Ahora no
              </button>
            </div>
          )}
          <Link to="/instalar/navegadores" className="link install__help">
            ¿No ves el botón? Instrucciones por navegador
          </Link>
        </div>
        <figure className="install__figure">
          <img src={windowArt} alt="Vista previa de la ventana de Órbita Kids instalada" width="331.2" height="217.3" />
          <figcaption>Así se verá: ventana propia con el color de Órbita Kids.</figcaption>
        </figure>
      </div>
    </CenteredPanel>
  )
}
