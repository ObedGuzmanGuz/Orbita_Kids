import { useEffect, useRef, useState } from 'react'
import { Link, NavLink, Navigate, Outlet, useLocation, useNavigate, useOutletContext } from 'react-router-dom'
import Icon from '../components/Icon'
import AppSearch from '../components/AppSearch'
import Splash from '../components/Splash'
import { useApp } from '../state/AppState'
import appIcon from '../assets/img/app-icon.png'
import './app-shell.css'

// Íconos: [inactivo, activo] según la «Barra lateral» de cada pantalla en Figma.
const NAVS = {
  docente: {
    tag: 'DOCENTE',
    roleLabel: 'Docente',
    eyebrow: 'Docente',
    main: [
      { to: '/docente', end: true, label: 'Inicio', icons: ['081', '054'] },
      { to: '/docente/grupos', label: 'Mis grupos', icons: ['055', '067'], also: ['/docente/estudiantes'] },
      { to: '/docente/actividades', label: 'Actividades', icons: ['056', '069'] },
      { to: '/docente/resultados', label: 'Resultados', icons: ['057', '094'] },
      { to: '/docente/avisos', label: 'Avisos', icons: ['058', '098'], badge: 'notices' },
    ],
  },
  institucion: {
    tag: 'INSTITUCIÓN',
    roleLabel: 'Dirección',
    eyebrow: 'Institución',
    main: [
      { to: '/institucion', end: true, label: 'Inicio', icons: ['081', '102'] },
      { to: '/institucion/docentes', label: 'Docentes', icons: ['055', '109'] },
      { to: '/institucion/grupos', label: 'Grupos y códigos', icons: ['103', '110'] },
      { to: '/institucion/licencia', label: 'Licencia y plan', icons: ['104', '108'] },
      { to: '/institucion/reportes', label: 'Reportes', icons: ['057', '118'] },
      { to: '/institucion/avisos', label: 'Avisos', icons: ['058', '058'], badge: 'notices' },
      { to: '/institucion/configuracion', label: 'Configuración', icons: ['105', '122'] },
    ],
  },
}

const TEAM = (base) => [
  { to: `${base}/sincronizacion`, label: 'Sincronización', icons: ['059', '126'] },
  { to: `${base}/ayuda`, label: 'Ayuda', icons: ['060', '140'] },
]

// Avisos sin leer del espacio (calculados con los datos de la cuenta).
function useUnread(space) {
  const { teacher, institution } = useApp()
  return (space === 'institucion' ? institution : teacher).notices.filter((n) => n.unread).length
}

function NavItem({ item }) {
  const { pathname } = useLocation()
  const extra = item.also?.some((p) => pathname.startsWith(p))
  return (
    <NavLink to={item.to} end={item.end} className={({ isActive }) => `side-link${isActive || extra ? ' is-active' : ''}`}>
      {({ isActive }) => (
        <>
          <Icon n={item.icons[isActive || extra ? 1 : 0]} />
          <span>{item.label}</span>
          {item.badge ? <span className="badge side-link__badge">{item.badge}</span> : null}
        </>
      )}
    </NavLink>
  )
}

function Sidebar({ space, open, onClose }) {
  const { installed, online, canInstall, promptInstall } = useApp()
  const unread = useUnread(space)
  const nav = NAVS[space]
  const base = space === 'docente' ? '/docente' : '/institucion'
  const navigate = useNavigate()

  const status = online
    ? installed
      ? 'En línea · app instalada'
      : 'En línea'
    : installed
      ? 'Sin conexión · app instalada'
      : 'Sin conexión'

  const install = async () => {
    if (canInstall) await promptInstall()
    else navigate('/instalar')
  }

  return (
    <aside className={`sidebar sidebar--${space}${open ? ' is-open' : ''}`} aria-label="Navegación de la app">
      <Link to={base} className="side-brand" onClick={onClose}>
        <img src={appIcon} alt="" className="side-brand__icon" />
        <span className="side-brand__text">
          <span className="side-brand__name">
            Órbita <em>Kids</em>
          </span>
          <span className="side-brand__tag">{nav.tag}</span>
        </span>
      </Link>
      <nav className="side-nav" onClick={onClose}>
        {nav.main.map((item) => (
          <NavItem key={item.to} item={item.badge === 'notices' ? { ...item, badge: unread } : item} />
        ))}
      </nav>
      <p className="side-section">Equipo</p>
      <nav className="side-nav" onClick={onClose}>
        {TEAM(base).map((item) => (
          <NavItem key={item.to} item={item} />
        ))}
      </nav>

      <div className="side-bottom">
        {!installed && (
          <div className="side-install">
            <p className="side-install__title">
              <Icon n="050" />
              App de escritorio
            </p>
            <p className="side-install__text">Ábrela en su propia ventana y úsala sin conexión.</p>
            <button type="button" className="btn btn--light btn--sm" onClick={install}>
              Instalar
            </button>
          </div>
        )}
        <p className={`side-status${online ? '' : ' is-offline'}`}>
          <span className="dot" />
          {status}
        </p>
      </div>
    </aside>
  )
}

function AccountMenu({ onClose }) {
  const { user } = useApp()
  const ref = useRef(null)

  useEffect(() => {
    const onDown = (e) => {
      if (ref.current && !ref.current.contains(e.target) && !e.target.closest('.account-btn')) onClose()
    }
    const onKey = (e) => e.key === 'Escape' && onClose()
    document.addEventListener('mousedown', onDown)
    document.addEventListener('keydown', onKey)
    return () => {
      document.removeEventListener('mousedown', onDown)
      document.removeEventListener('keydown', onKey)
    }
  }, [onClose])

  return (
    <div className="account-menu" ref={ref} role="menu">
      <div className="account-menu__who">
        <span className="avatar" style={{ background: user.color }}>{user.initials}</span>
        <span>
          <strong>{user.name}</strong>
          <small>{user.email}</small>
        </span>
      </div>
      <hr />
      <Link to="/cuenta/perfil" className="account-menu__item" role="menuitem" onClick={onClose}>
        <Icon n="077" />
        Perfil y configuración
      </Link>
      <Link to="/cuenta/seguridad" className="account-menu__item" role="menuitem" onClick={onClose}>
        <Icon n="078" />
        Seguridad y sesiones
      </Link>
      <Link to="/cuenta/ayuda" className="account-menu__item" role="menuitem" onClick={onClose}>
        <Icon n="079" style={{ marginTop: 1 }} />
        Ayuda
      </Link>
      <hr />
      <Link to="/cuenta/cerrar-sesion" className="account-menu__item is-danger" role="menuitem" onClick={onClose}>
        <Icon n="080" />
        Cerrar sesión
      </Link>
    </div>
  )
}

export function SyncChip({ base }) {
  const { online, queue, lastSync, syncing } = useApp()
  if (!online) {
    return (
      <Link to={`${base}/sin-conexion`} className="chip chip--warning header-chip">
        <Icon n="127" />
        Sin conexión · datos de {lastSync}
      </Link>
    )
  }
  if (syncing) {
    return (
      <span className="chip header-chip">
        <Icon n="059" className="spin" />
        Sincronizando…
      </span>
    )
  }
  if (queue.length) {
    return (
      <span className="chip chip--warning header-chip">
        <Icon n="059" />
        {queue.length} {queue.length === 1 ? 'cambio' : 'cambios'} en cola
      </span>
    )
  }
  return (
    <span className="chip chip--success header-chip">
      <Icon n="062" />
      Sincronizado {lastSync}
    </span>
  )
}

export function AppHeader({ title, eyebrow, search = true }) {
  const { user, session, school } = useApp()
  useEffect(() => {
    document.title = `${title} · Órbita Kids`
  }, [title])
  const [menu, setMenu] = useState(false)
  const ctx = useOutletContext()
  const space = ctx?.space || session?.space || 'docente'
  const base = space === 'docente' ? '/docente' : '/institucion'
  const roleLabel = NAVS[space].roleLabel
  const unread = useUnread(space)
  const defaultEyebrow = space === 'docente' && school?.name ? `Docente · ${school.name}` : NAVS[space].eyebrow

  return (
    <header className="app-header">
      <button type="button" className="app-header__menu" aria-label="Abrir menú" onClick={() => document.dispatchEvent(new CustomEvent('toggle-sidebar'))}>
        <span />
        <span />
        <span />
      </button>
      <div className="app-header__title">
        <p>{eyebrow || defaultEyebrow}</p>
        <h1>{title}</h1>
      </div>
      {search && <AppSearch space={space} />}
      <SyncChip base={base} />
      <Link to={`${base}/avisos`} className="app-header__bell" aria-label={unread ? `Avisos (${unread} sin leer)` : 'Avisos'}>
        <Icon n="063" />
        {unread > 0 && <span className="app-header__bell-dot" />}
      </Link>
      <button type="button" className="account-btn" aria-haspopup="menu" aria-expanded={menu} onClick={() => setMenu((v) => !v)}>
        <span className="avatar" style={{ background: user.color }}>{user.initials}</span>
        <span className="account-btn__text">
          <strong>{user.short}</strong>
          <small>{roleLabel}</small>
        </span>
        <Icon n="064" />
      </button>
      {menu && <AccountMenu onClose={() => setMenu(false)} />}
    </header>
  )
}

export function TitleBar({ title }) {
  return (
    <div className="titlebar">
      <img src={appIcon} alt="" />
      <strong>Órbita Kids</strong>
      <span>{title}</span>
    </div>
  )
}

export default function AppShell({ space }) {
  const { session, installed, hydrated, user, data, online, syncNow, syncError } = useApp()
  const [open, setOpen] = useState(false)
  const location = useLocation()

  useEffect(() => {
    const toggle = () => setOpen((v) => !v)
    document.addEventListener('toggle-sidebar', toggle)
    return () => document.removeEventListener('toggle-sidebar', toggle)
  }, [])

  if (!session) return <Navigate to="/login" replace state={{ from: location.pathname + location.search }} />
  if (!hydrated || !user) return <Splash text="Abriendo tus datos cifrados…" />
  if (space && !user.spaces.includes(space)) return <Navigate to={`/${user.spaces[0]}`} replace />
  if (!data) {
    return online && !syncError ? (
      <Splash text="Descargando tus datos…" />
    ) : (
      <Splash
        text={online ? `No pudimos descargar tus datos: ${syncError}` : 'Este equipo todavía no tiene tus datos. Conéctate a Internet una vez para descargarlos.'}
        action={{ label: 'Reintentar', onClick: () => syncNow() }}
      />
    )
  }
  const current = space || session.space || 'docente'

  return (
    <div className={`app app--${current}${installed ? ' is-installed' : ''}`}>
      <TitleBar title={current === 'docente' ? 'Docente' : 'Institución'} />
      <Sidebar space={current} open={open} onClose={() => setOpen(false)} />
      {open && <div className="sidebar-scrim" onClick={() => setOpen(false)} />}
      <div className="app-main">
        <Outlet context={{ space: current }} />
      </div>
    </div>
  )
}
