import { useState } from 'react'
import { Link } from 'react-router-dom'
import Icon from '../../components/Icon'
import './site-pages.css'

const PLANS = [
  { name: 'Gratuito', for: 'Para conocer la plataforma', year: 0, month: 0, free: true, features: ['Funciones básicas permanentes', 'Límites por definir', 'Misiones de sumas', 'Pausa Estelar', 'Seguimiento básico'] },
  { name: 'Aula', for: 'Un grupo o un equipo pequeño', year: 8150, month: 799, features: ['Hasta 50 estudiantes', 'Hasta 5 docentes', 'Actividades ampliadas', 'Seguimiento del grupo', 'Reportes básicos'] },
  { name: 'Escuela', for: 'Varios grupos de una escuela', year: 18350, month: 1799, featured: true, features: ['Hasta 150 estudiantes', 'Más grupos', 'Todo lo de Aula', 'Reportes ampliados', 'Panel institucional'] },
  { name: 'Licencia institucional', for: 'Instituciones con varios planteles', year: 50990, month: 4999, features: ['Hasta 500 estudiantes', 'Administración ampliada', 'Inicio de sesión institucional', 'Reportes por plantel'] },
]

const FAQ = [
  ['¿Se puede pagar con tarjeta en la app?', 'No. La PWA solo informa. La institución firma un contrato y recibe su licencia con los lugares para estudiantes.'],
  ['¿Qué pasa si se acaban los lugares?', 'Los estudiantes que ya están siguen jugando. La dirección recibe un aviso al 80 % y puede pedir más lugares.'],
]

const money = (n) => `$${n.toLocaleString('en-US')}`

// 02 · Planes institucionales (comparativa anual / mensual)
export default function Plans() {
  const [annual, setAnnual] = useState(true)
  const [open, setOpen] = useState(-1)

  return (
    <section className="container site-page">
      <div className="site-page__head">
        <div>
          <h1 className="site-h2 site-h2--lg">Planes para tu escuela</h1>
          <p className="site-lead" style={{ maxWidth: 440, marginTop: 10 }}>
            Precios en pesos mexicanos. No hay pago en línea: la contratación se hace con la institución.
          </p>
        </div>
        <div className="tabs billing" role="tablist" aria-label="Periodo">
          <button type="button" role="tab" aria-selected={!annual} onClick={() => setAnnual(false)}>
            Mensual
          </button>
          <button type="button" role="tab" aria-selected={annual} onClick={() => setAnnual(true)}>
            Anual, cerca de 15 % menos
          </button>
        </div>
      </div>

      <div className="plans">
        {PLANS.map((p) => (
          <article key={p.name} className={`plan${p.featured ? ' is-featured' : ''}`}>
            <h2 className="plan__name">{p.name}</h2>
            <p className="plan__for">{p.for}</p>
            <p className="plan__price">
              <strong>{money(annual ? p.year : p.month)}</strong>
              <span>{p.free ? 'siempre' : annual ? 'MXN al año' : 'MXN al mes'}</span>
            </p>
            <ul className="plan__features">
              {p.features.map((f) => (
                <li key={f}>
                  <Icon n="012" />
                  {f}
                </li>
              ))}
            </ul>
            <Link to={`/contacto?plan=${encodeURIComponent(p.name)}`} className={`btn btn--block ${p.featured ? 'btn--primary' : 'plan__cta'}`}>
              Solicitar información
            </Link>
          </article>
        ))}
      </div>
      <p className="plans__legal">Propuesta académica sujeta a validación de costos, disposición de pago, impuestos y condiciones comerciales.</p>

      <div className="faq-list plans__faq">
        {FAQ.map(([q, a], i) => (
          <div key={q} className={`faq-item${open === i ? ' is-open' : ''}`}>
            <button type="button" aria-expanded={open === i} onClick={() => setOpen(open === i ? -1 : i)}>
              {q}
              <Icon n="013" />
            </button>
            {open === i && <p>{a}</p>}
          </div>
        ))}
      </div>
    </section>
  )
}
