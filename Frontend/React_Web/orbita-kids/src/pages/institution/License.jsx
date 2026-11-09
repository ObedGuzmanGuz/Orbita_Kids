import { useState } from 'react'
import Icon from '../../components/Icon'
import Dialog from '../../components/Dialog'
import { AppHeader } from '../../layouts/AppShell'
import { useApp } from '../../state/AppState'
import { PLANS } from '../../data/catalog'
import './institution.css'

// 26 · Licencia y plan
export default function License() {
  const { toast, institution, submit, online } = useApp()
  const LICENSE = institution.license
  const SCHOOL = institution.school
  const [change, setChange] = useState(false)
  const [plan, setPlan] = useState('Licencia institucional')
  const pct = Math.round((LICENSE.used / (LICENSE.total || 1)) * 100)

  return (
    <>
      <AppHeader title="Licencia y plan" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Licencia y plan</h2>
            <p className="page-sub">Escuela {SCHOOL.name}</p>
          </div>
          <button type="button" className="btn btn--secondary" onClick={() => toast('Descargando el contrato (PDF)…')}>
            <Icon n="096" />
            Contrato
          </button>
          <button type="button" className="btn btn--primary" onClick={() => setChange(true)}>
            Solicitar cambio de plan
          </button>
        </div>

        <div className="inst-split" style={{ gridTemplateColumns: 'minmax(0, 556fr) minmax(0, 392fr)' }}>
          <section className="card">
            <div className="row" style={{ gap: 8 }}>
              <span className="tag tag--warning">Plan Escuela · Anual</span>
              <span className="tag tag--success">Vigente</span>
            </div>
            <p className="plan-hero" style={{ marginTop: 12 }}>
              <span className="plan-hero__price">$18,350</span>
              <span className="page-sub" style={{ margin: 0 }}>MXN al año</span>
            </p>
            <p className="card__note">Del 1 ago 2026 al 31 jul 2027</p>
            <p className="row" style={{ justifyContent: 'space-between', marginTop: 16, fontWeight: 600, fontSize: 14.5 }}>
              <span>Lugares para estudiantes</span>
              <span>
                {LICENSE.used} de {LICENSE.total} · {pct} %
              </span>
            </p>
            <div className="progress" style={{ marginTop: 8 }}>
              <div className="progress__bar progress__bar--amber" style={{ width: `${pct}%` }} />
            </div>
            <p className="card__note" style={{ marginTop: 6 }}>
              Te avisamos al 80 % y 30 días antes del vencimiento.
            </p>
            <div className="row" style={{ gap: 6, flexWrap: 'wrap', marginTop: 12 }}>
              <span className="tag tag--primary">Todo lo de Aula</span>
              <span className="tag tag--primary">Reportes ampliados</span>
              <span className="tag tag--primary">Panel institucional</span>
            </div>
          </section>
          <section className="card">
            <h3 className="card__title" style={{ marginBottom: 6 }}>
              Cómo se gestiona
            </h3>
            <ul>
              {[
                ['115', 'Por contrato, sin pago en línea', 'La factura la emite Órbita Kids Studios'],
                ['116', 'Renovación anual', 'Vence el 31 jul 2027'],
                ['117', 'Lugares que se liberan', 'Al archivar un grupo vuelven a la licencia'],
              ].map(([icon, title, sub]) => (
                <li key={title} className="list-row">
                  <span className="icon-box">
                    <Icon n={icon} />
                  </span>
                  <span className="list-row__body">
                    <span className="list-row__title" style={{ display: 'block' }}>{title}</span>
                    <span className="list-row__sub">{sub}</span>
                  </span>
                </li>
              ))}
            </ul>
          </section>
        </div>

        <section className="card" style={{ marginTop: 20 }}>
          <div className="card__head">
            <h3 className="card__title">Comparar planes</h3>
            <span className="card__note" style={{ marginLeft: 'auto' }}>
              Propuesta académica sujeta a validación de costos, disposición de pago, impuestos y condiciones comerciales.
            </span>
          </div>
          <div className="table-wrap">
            <table className="table plans-table">
              <thead>
                <tr>
                  <th aria-label="Característica" />
                  {PLANS.headers.map((h) => (
                    <th key={h}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {PLANS.rows.map(([label, ...cells]) => (
                  <tr key={label}>
                    <th scope="row" className="cell-title" style={{ color: 'var(--ink)', fontSize: 14 }}>
                      {label}
                    </th>
                    {cells.map((c, i) => (
                      <td key={i}>{c}</td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      </div>

      {change && (
        <Dialog title="Solicitar cambio de plan" onClose={() => setChange(false)}>
          <p className="dialog__text">Te contactará el equipo de Órbita Kids Studios con una propuesta. Tu plan actual sigue vigente mientras tanto.</p>
          <div className="field" style={{ marginTop: 16 }}>
            <label className="field__label" htmlFor="plan-target">
              Plan que te interesa
            </label>
            <select id="plan-target" className="input" value={plan} onChange={(e) => setPlan(e.target.value)}>
              <option>Aula</option>
              <option>Licencia institucional</option>
              <option>Más lugares en el Plan Escuela</option>
            </select>
          </div>
          <div className="dialog__actions">
            <button type="button" className="btn btn--outline" onClick={() => setChange(false)} data-close>
              Cancelar
            </button>
            <button
              type="button"
              className="btn btn--primary"
              onClick={() => {
                setChange(false)
                submit('request-plan', { plan }, { title: `Solicitud de plan: ${plan}`, icon: '108' })
                toast(online ? `Solicitud enviada: ${plan}` : `Solicitud en cola: ${plan}. Se enviará al reconectar.`)
              }}
            >
              Enviar solicitud
            </button>
          </div>
        </Dialog>
      )}
    </>
  )
}
