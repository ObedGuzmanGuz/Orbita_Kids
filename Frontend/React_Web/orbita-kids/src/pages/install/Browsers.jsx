import Icon from '../../components/Icon'
import { useApp } from '../../state/AppState'
import { useNavigate } from 'react-router-dom'
import './install.css'

const BROWSERS = [
  {
    key: 'chromium',
    badge: 'C',
    name: 'Chrome y Edge',
    os: 'Windows, macOS y Linux',
    steps: ['Abre orbitakids.example/app.', 'Haz clic en el ícono Instalar de la barra de direcciones.', 'Confirma con Instalar.'],
  },
  {
    key: 'safari',
    badge: 'S',
    name: 'Safari en macOS',
    os: 'macOS Sonoma o posterior',
    steps: ['Abre orbitakids.example/app.', 'Menú Archivo → Agregar al Dock.', 'Confirma el nombre y haz clic en Agregar.'],
  },
  {
    key: 'chromeos',
    badge: 'CB',
    name: 'Chromebook',
    os: 'ChromeOS',
    steps: ['Abre orbitakids.example/app en Chrome.', 'Usa el ícono Instalar de la barra de direcciones.', 'La app aparece en el iniciador.'],
  },
  {
    key: 'firefox',
    badge: 'F',
    name: 'Firefox',
    os: 'Escritorio',
    steps: ['Firefox no instala apps web de forma estándar.', 'Usa Órbita Kids en una pestaña, con todas sus funciones.', 'Para instalarla, ábrela en Chrome, Edge o Safari.'],
  },
]

function detectBrowser() {
  const ua = navigator.userAgent
  if (/CrOS/.test(ua)) return 'chromeos'
  if (/Firefox\//.test(ua)) return 'firefox'
  if (/Safari\//.test(ua) && !/Chrome|Chromium|Edg\//.test(ua)) return 'safari'
  return 'chromium'
}

// 13 · Instalar en otros navegadores
export default function Browsers() {
  const { canInstall, promptInstall, installed, toast } = useApp()
  const navigate = useNavigate()
  const current = detectBrowser()

  const installNow = async () => {
    if (installed) return toast('Ya tienes la app instalada en este equipo.')
    if (canInstall) return promptInstall()
    navigate('/instalar')
    toast('Tu navegador todavía no ofrece instalar. Sigue los pasos de tu navegador.')
  }

  return (
    <section className="container browsers">
      <div className="page-head">
        <div className="page-head__text">
          <h1 className="page-title">Instalar en otros navegadores</h1>
          <p className="page-sub">Si no apareció el botón Instalar, sigue los pasos de tu navegador.</p>
        </div>
        <button type="button" className="btn btn--primary" onClick={installNow}>
          <Icon n="050" />
          Instalar ahora
        </button>
      </div>
      <div className="browsers__grid">
        {BROWSERS.map((b) => (
          <article key={b.key} className="card browser-card">
            <header>
              <span className="browser-card__badge">{b.badge}</span>
              <span>
                <strong>{b.name}</strong>
                <small>{b.os}</small>
              </span>
              {b.key === current && <span className="tag tag--success">Tu navegador</span>}
            </header>
            <ol>
              {b.steps.map((s) => (
                <li key={s}>{s}</li>
              ))}
            </ol>
          </article>
        ))}
      </div>
      <p className="notice notice--info browsers__note">
        <Icon n="051" />
        En teléfono o tableta, los docentes también pueden usar la app móvil Órbita Kids con la misma cuenta.
      </p>
    </section>
  )
}
