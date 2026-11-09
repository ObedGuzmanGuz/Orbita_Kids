import { useEffect, useState } from 'react'
import { Link, NavLink, Outlet, useLocation } from 'react-router-dom'
import Icon from '../components/Icon'
import { TitleBar } from './AppShell'
import { useApp } from '../state/AppState'
import appIcon from '../assets/img/app-icon.png'
import logoStudios from '../assets/img/logo-studios.png'
import './site.css'

const NAV = [
  { to: '/', label: 'Inicio', end: true },
  { to: '/explorar', label: 'Explorar' },
  { to: '/planes', label: 'Planes' },
  { to: '/contacto', label: 'Contacto' },
  { to: '/instalar', label: 'Instalar' },
]

const FOOTER_COLUMNS = [
  {
    title: 'Producto',
    links: [
      { to: '/#como-funciona', label: 'Cómo funciona' },
      { to: '/explorar', label: 'Explorar la demostración' },
      { to: '/planes', label: 'Planes y precios' },
      { to: '/instalar', label: 'App de escritorio' },
    ],
  },
  {
    title: 'Escuelas',
    links: [
      { to: '/contacto', label: 'Solicitar información' },
      { to: '/login', label: 'Iniciar sesión' },
      { to: '/login/institucion', label: 'Acceso institucional' },
      { to: '/recuperar', label: 'Recuperar contraseña' },
    ],
  },
  {
    title: 'Recursos',
    links: [
      { to: '/#preguntas', label: 'Preguntas frecuentes' },
      { to: '/#sin-internet', label: 'Uso sin Internet' },
      { to: '/instalar/navegadores', label: 'Navegadores compatibles' },
      { to: '/estado', label: 'Estado del servicio' },
    ],
  },
  {
    title: 'Legal',
    links: [
      { to: '/privacidad', label: 'Aviso de privacidad' },
      { to: '/terminos', label: 'Términos de uso' },
    ],
  },
]

export function SiteHeader() {
  const { session, user } = useApp()
  const { pathname, hash } = useLocation()
  const [open, setOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)
  const [lastPath, setLastPath] = useState(pathname + hash)

  // El menú móvil se cierra al cambiar de página.
  if (lastPath !== pathname + hash) {
    setLastPath(pathname + hash)
    setOpen(false)
  }

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  useEffect(() => {
    if (!open) return
    const onKey = (e) => e.key === 'Escape' && setOpen(false)
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [open])

  const signedIn = !!(session && user)

  return (
    <header className={`site-bar${scrolled ? ' is-scrolled' : ''}${open ? ' is-open' : ''}`}>
      <div className="site-bar__inner">
        <Link to="/" className="site-brand" aria-label="Órbita Kids, inicio">
          <img src={appIcon} alt="" className="site-brand__icon" />
          <span>Órbita Kids</span>
        </Link>
        <button
          type="button"
          className="site-menu-btn"
          aria-expanded={open}
          aria-controls="site-nav"
          aria-label={open ? 'Cerrar menú' : 'Abrir menú'}
          onClick={() => setOpen((v) => !v)}
        >
          <span />
          <span />
          <span />
        </button>
        <nav className="site-nav" id="site-nav" aria-label="Principal">
          {NAV.map((item) => (
            <NavLink key={item.to} to={item.to} end={item.end} className="site-nav__link">
              {item.label}
            </NavLink>
          ))}
          {signedIn ? (
            <Link to={`/${session.space}`} className="site-login site-login--app">
              <span className="avatar avatar--xs" style={{ background: user.color }}>
                {user.initials}
              </span>
              Ir a mi panel
            </Link>
          ) : (
            <Link to="/login" className="site-login">
              Iniciar sesión
            </Link>
          )}
        </nav>
      </div>
    </header>
  )
}

function ServiceStatus() {
  const { online } = useApp()
  return (
    <Link to="/estado" className={`footer-status${online ? '' : ' is-offline'}`}>
      <span className="footer-status__dot" aria-hidden />
      {online ? 'Todos los servicios funcionan' : 'Sin conexión · la app sigue funcionando'}
    </Link>
  )
}

export function SiteFooter() {
  const { pathname } = useLocation()
  const showCta = !['/contacto', '/explorar'].includes(pathname)

  return (
    <footer className="site-footer">
      {showCta && (
        <div className="container">
          <section className="footer-cta" aria-labelledby="footer-cta-title">
            <div>
              <p className="footer-cta__eyebrow">Para direcciones y docentes</p>
              <h2 id="footer-cta-title" className="footer-cta__title">
                Lleva Órbita Kids a tu escuela
              </h2>
              <p className="footer-cta__text">Recorre el panel con datos de demostración o pide una propuesta para tu plantel. Te respondemos en menos de 2 días hábiles.</p>
            </div>
            <div className="footer-cta__actions">
              <Link to="/contacto" className="btn btn--xl footer-cta__primary">
                Solicitar información
              </Link>
              <Link to="/explorar" className="btn btn--xl footer-cta__secondary">
                Explorar sin cuenta
              </Link>
            </div>
          </section>
        </div>
      )}

      <div className="container footer-main">
        <div className="footer-brand">
          <Link to="/" className="site-brand" aria-label="Órbita Kids, inicio">
            <img src={appIcon} alt="" className="site-brand__icon" />
            <span>Órbita Kids</span>
          </Link>
          <p className="footer-brand__text">
            Misiones de sumas para 1.º a 3.º de primaria. Las y los docentes ven quién necesita apoyo; la dirección administra la escuela. Funciona aunque falle el
            Internet.
          </p>
          <ul className="footer-badges" aria-label="Características">
            <li>
              <Icon n="005" />
              Sin conexión
            </li>
            <li>
              <Icon n="006" />
              Se instala desde el navegador
            </li>
            <li>
              <Icon n="007" />
              Datos cifrados por cuenta
            </li>
          </ul>
          <ServiceStatus />
        </div>

        <nav className="footer-columns" aria-label="Pie de página">
          {FOOTER_COLUMNS.map((col) => (
            <div key={col.title} className="footer-col">
              <h3 className="footer-col__title">{col.title}</h3>
              <ul>
                {col.links.map((l) => (
                  <li key={l.to}>
                    <Link to={l.to}>{l.label}</Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </nav>
      </div>

      <div className="footer-bottom">
        <div className="container footer-bottom__inner">
          <p>
            © 2026 Órbita Kids · Proyecto académico · Hecho con datos de demostración
          </p>
          <div className="footer-bottom__credits">
            <span>Diseño y desarrollo</span>
            <img src={logoStudios} alt="Órbita Kids Studios" className="footer-bottom__logo" />
          </div>
          <p className="footer-bottom__version">
            <Link to="/estado">Versión {__APP_VERSION__}</Link>
          </p>
        </div>
      </div>
    </footer>
  )
}

export default function SiteLayout() {
  return (
    <div className="site">
      <a href="#contenido" className="skip-link">
        Saltar al contenido
      </a>
      <TitleBar title="Sitio web" />
      <SiteHeader />
      <main className="site-main" id="contenido" tabIndex={-1}>
        <Outlet />
      </main>
      <SiteFooter />
    </div>
  )
}
