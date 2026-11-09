import { useNavigate } from 'react-router-dom'
import { useApp } from '../state/AppState'
import appIcon from '../assets/img/app-icon.png'

// «Aviso · Instala Órbita Kids en tu computadora» (Figma 97:2020). Solo en el navegador.
export default function InstallBanner() {
  const { installed, installBannerHidden, hideInstallBanner, canInstall, promptInstall } = useApp()
  const navigate = useNavigate()
  if (installed || installBannerHidden) return null

  const install = async () => {
    if (canInstall) await promptInstall()
    else navigate('/instalar')
  }

  return (
    <div className="install-banner" role="region" aria-label="Instalar la app">
      <img src={appIcon} alt="" />
      <div className="install-banner__text">
        <strong>Instala Órbita Kids en tu computadora</strong>
        <span>Se abre en su propia ventana y funciona sin conexión.</span>
      </div>
      <button type="button" className="btn btn--light btn--sm" onClick={install}>
        Instalar
      </button>
      <button type="button" className="install-banner__later" onClick={hideInstallBanner}>
        Ahora no
      </button>
    </div>
  )
}
