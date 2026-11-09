import { useEffect } from 'react'
import { Link } from 'react-router-dom'
import Icon from './Icon'
import { TitleBar } from '../layouts/AppShell'
import './centered-panel.css'

// «Panel centrado» del prototipo: tarjeta de 560 px centrada sobre fondo claro,
// con ícono opcional, título, texto y acciones.
export default function CenteredPanel({ icon, iconBg, eyebrow, title, text, children, width = 560, windowTitle, back }) {
  const pageTitle = windowTitle || title
  useEffect(() => {
    if (pageTitle) document.title = `${pageTitle} · Órbita Kids`
  }, [pageTitle])
  return (
    <div className="standalone-page">
      <TitleBar title={windowTitle || title} />
      {back && (
        <Link to={back.to} className="back-link standalone-page__back">
          <Icon n="017" />
          {back.label}
        </Link>
      )}
      <main className="panel" style={{ width: `min(${width}px, 100%)` }}>
        {icon && (
          <span className="panel__icon" style={iconBg ? { background: iconBg } : undefined}>
            <Icon n={icon} />
          </span>
        )}
        {eyebrow && <p className="panel__eyebrow">{eyebrow}</p>}
        {title && <h1 className="panel__title">{title}</h1>}
        {text && <p className="panel__text">{text}</p>}
        {children}
      </main>
    </div>
  )
}
