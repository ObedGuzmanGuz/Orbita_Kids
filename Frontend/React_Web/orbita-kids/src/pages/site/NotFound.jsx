import { useEffect } from 'react'
import { Link, useLocation } from 'react-router-dom'
import Icon from '../../components/Icon'
import './site-pages.css'

// Página no encontrada (antes cualquier ruta desconocida mandaba a la portada sin decir nada).
export default function NotFound() {
  const { pathname } = useLocation()

  useEffect(() => {
    document.title = 'Página no encontrada · Órbita Kids'
  }, [])

  return (
    <section className="container site-page not-found">
      <div className="not-found__orbit" aria-hidden>
        <span className="not-found__planet" />
        <span className="not-found__ring" />
        <span className="not-found__moon" />
      </div>
      <p className="site-eyebrow">Error 404</p>
      <h1 className="site-h2 site-h2--lg">Esta página se salió de órbita</h1>
      <p className="site-lead">
        No encontramos <code>{pathname}</code>. Tal vez el enlace cambió o se escribió mal.
      </p>
      <div className="not-found__actions">
        <Link to="/" className="btn btn--primary btn--lg">
          Volver al inicio
        </Link>
        <Link to="/explorar" className="btn btn--secondary btn--lg">
          Explorar la demostración
        </Link>
        <Link to="/login" className="btn btn--lg not-found__login">
          <Icon n="017" style={{ transform: 'scaleX(-1)' }} />
          Iniciar sesión
        </Link>
      </div>
    </section>
  )
}
