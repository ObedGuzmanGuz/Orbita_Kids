import { useState } from 'react'
import { Link } from 'react-router-dom'
import Icon from '../../components/Icon'
import appIcon from '../../assets/img/app-icon.png'
import './site-pages.css'

const SUPPORT = [
  { id: 'lf', initials: 'LF', name: 'Leonardo F.', group: '2.º A', topic: 'Volver a contar el primer grupo', score: 58 },
  { id: 'fu', initials: 'FU', name: 'Fernanda U.', group: '3.º A', topic: 'Sumas que pasan de 10', score: 60 },
  { id: 'dl', initials: 'DL', name: 'Diego L.', group: '2.º A', topic: 'Sumas que pasan de 10', score: 61 },
  { id: 'at', initials: 'AT', name: 'Abril T.', group: '3.º A', topic: 'Sumas que pasan de 10', score: 61 },
]
const WEEK = [
  { day: 'Mar', n: 3, title: 'Sumas hasta 10', meta: '2.º A, 8 de 12 entregas' },
  { day: 'Jue', n: 5, title: 'Sumas que pasan de 10', meta: '3.º A, 3 de 11 entregas' },
  { day: 'Vie', n: 6, title: 'Repaso de decenas', meta: '2.º B, sin empezar' },
]
const GROUPS = [
  { name: '2.º A', students: 12, score: 75, support: 3, spark: [63, 66, 68, 71, 73, 76] },
  { name: '2.º B', students: 10, score: 74, support: 4, spark: [66, 65, 69, 70, 72, 74] },
  { name: '3.º A', students: 11, score: 81, support: 2, spark: [72, 74, 76, 77, 79, 81] },
]
const PENDING = [
  { id: 'p1', title: 'Sofía Cárdenas pidió acceso', meta: 'Docente, 28 de octubre', action: 'Aprobar', done: 'Aprobada' },
  { id: 'p2', title: 'El código ORB-1B4T vence el 4 de noviembre', meta: '1.º B, Jorge Salas', action: 'Renovar', done: 'Renovado' },
  { id: 'p3', title: '3.º C no tiene lugares libres', meta: '14 de 15 ocupados, 1 solicitud de ingreso', action: 'Ajustar', done: 'Ajustado' },
]
const NAV = {
  teacher: ['Inicio', 'Mis grupos', 'Actividades', 'Resultados', 'Avisos'],
  director: ['Inicio', 'Docentes', 'Grupos y códigos', 'Licencia y plan', 'Reportes', 'Configuración'],
}

function Spark({ values }) {
  const w = 84
  const h = 22
  const min = Math.min(...values) - 2
  const max = Math.max(...values) + 2
  const pts = values.map((v, i) => [(i / (values.length - 1)) * (w - 4) + 2, h - ((v - min) / (max - min)) * (h - 4) - 2])
  const d = pts.map(([x, y], i) => `${i ? 'L' : 'M'}${x.toFixed(1)} ${y.toFixed(1)}`).join(' ')
  const [lx, ly] = pts[pts.length - 1]
  return (
    <svg width={w} height={h} viewBox={`0 0 ${w} ${h}`} aria-hidden>
      <path d={d} fill="none" stroke="#5646db" strokeWidth="1.4" strokeLinecap="round" />
      <circle cx={lx} cy={ly} r="2.6" fill="#5646db" />
    </svg>
  )
}

// 35a/35b/35c · Explorar sin cuenta (demostración interactiva; nada se guarda)
export default function Explore() {
  const [view, setView] = useState('teacher')
  const [offline, setOffline] = useState(false)
  const [assigned, setAssigned] = useState({})
  const [resolved, setResolved] = useState({})
  const [queue, setQueue] = useState(0)
  const teacher = view === 'teacher'

  const act = (setter, id) => {
    setter((s) => ({ ...s, [id]: offline ? 'queued' : 'done' }))
    if (offline) setQueue((n) => n + 1)
  }

  const toggleOffline = () => {
    setOffline((was) => {
      if (was && queue > 0) {
        // Al reconectar, la cola se envía sola.
        setAssigned((s) => Object.fromEntries(Object.entries(s).map(([k]) => [k, 'done'])))
        setResolved((s) => Object.fromEntries(Object.entries(s).map(([k]) => [k, 'done'])))
        setQueue(0)
      }
      return !was
    })
  }

  const steps = teacher
    ? ['Asigna apoyo a un estudiante.', 'Activa «Simular sin conexión» y vuelve a hacerlo: el cambio queda en cola.', 'Cambia a la vista de dirección.']
    : ['Resuelve un pendiente de la escuela.', 'Activa «Simular sin conexión» y vuelve a hacerlo: el cambio queda en cola.', 'Regresa a la vista docente.']

  return (
    <section className="container site-page explore">
      <div className="explore__head">
        <div>
          <h1 className="site-h2 site-h2--lg">Explora Órbita Kids sin crear cuenta</h1>
          <p className="site-lead" style={{ maxWidth: 420, marginTop: 10 }}>
            Estás en una escuela de demostración. Prueba lo que quieras: nada de lo que hagas aquí se guarda.
          </p>
        </div>
        <div className="explore__controls">
          <div className="segmented" role="tablist" aria-label="Vista">
            <button type="button" role="tab" aria-selected={teacher} onClick={() => setView('teacher')}>
              Como docente
            </button>
            <button type="button" role="tab" aria-selected={!teacher} onClick={() => setView('director')}>
              Como dirección
            </button>
          </div>
          <button type="button" role="switch" aria-checked={offline} className={`sim-switch${offline ? ' is-on' : ''}`} onClick={toggleOffline}>
            <span className="sim-switch__track">
              <span className="sim-switch__knob" />
            </span>
            Simular sin conexión
          </button>
        </div>
      </div>

      <ol className="explore__steps">
        {steps.map((s, i) => (
          <li key={s}>
            <span>{i + 1}</span>
            {s}
          </li>
        ))}
      </ol>

      <div className="demo">
        <div className="demo__bar">
          <p className="demo__crumb">
            {teacher ? 'Docente' : 'Dirección'} <span>/</span> <strong>Inicio</strong>
          </p>
          <span className="demo__search">
            <Icon n="144" />
            {teacher ? 'Buscar estudiante o grupo' : 'Buscar docente o grupo'}
            <kbd>Ctrl K</kbd>
          </span>
          {offline ? (
            <span className="chip chip--warning">
              <Icon n="149" />
              Sin conexión, {queue} {queue === 1 ? 'cambio' : 'cambios'} en cola
            </span>
          ) : (
            <span className="chip chip--success">
              <Icon n="145" />
              Sincronizado hoy 8:15
            </span>
          )}
          <span className="avatar" style={{ background: teacher ? '#0b7480' : '#e0a53a', width: 30, height: 30, fontSize: 12 }}>
            {teacher ? 'AR' : 'LM'}
          </span>
        </div>
        {offline && (
          <p className="demo__offline">
            <Icon n="150" />
            Sin conexión. Puedes seguir trabajando; tus cambios se envían al reconectar.
          </p>
        )}
        <div className="demo__body">
          <aside className="demo__side">
            <p className="demo__brand">
              <img src={appIcon} alt="" />
              <span>
                Órbita Kids
                <small style={{ color: teacher ? 'var(--teal)' : '#8a5200' }}>{teacher ? 'Docente' : 'Dirección'}</small>
              </span>
            </p>
            <ul>
              {NAV[view].map((item, i) => (
                <li key={item} className={i === 0 ? 'is-active' : ''}>
                  {item}
                  {item === 'Avisos' && <span className="demo__count">3</span>}
                </li>
              ))}
            </ul>
          </aside>

          {teacher ? (
            <div className="demo__main">
              <div className="demo__hello">
                <div>
                  <h2>Buenos días, Ana</h2>
                  <p>Lunes 2 de noviembre, Primaria Demo Órbita</p>
                  <p className="demo__kpis">
                    <strong>3</strong> grupos <strong>33</strong> estudiantes <strong>15</strong> entregas por revisar
                  </p>
                </div>
                <Link to="/demo/docente?to=/docente/resultados" className="btn btn--secondary btn--sm">
                  Ver resultados
                </Link>
                <Link to="/demo/docente?to=/docente/actividades/nueva" className="btn btn--primary btn--sm">
                  <Icon n="066" />
                  Crear actividad
                </Link>
              </div>
              <div className="demo__grid">
                <section className="demo-card">
                  <header>
                    <h3>Necesitan apoyo</h3>
                    <span>9 en total</span>
                  </header>
                  <ul>
                    {SUPPORT.map((s) => (
                      <li key={s.id} className="demo-row">
                        <span className="demo-row__avatar">{s.initials}</span>
                        <span className="demo-row__body">
                          <strong>
                            {s.name} <em>{s.group}</em>
                          </strong>
                          <small>{s.topic}</small>
                        </span>
                        <span className="demo-row__bar">
                          <span style={{ width: `${s.score - 30}%` }} />
                        </span>
                        <span className="demo-row__pct">{s.score} %</span>
                        {assigned[s.id] ? (
                          <span className={`demo-done${assigned[s.id] === 'queued' ? ' is-queued' : ''}`}>
                            <Icon n="151" />
                            {assigned[s.id] === 'queued' ? 'En cola' : 'Apoyo asignado'}
                          </span>
                        ) : (
                          <button type="button" className="btn btn--outline btn--sm demo-row__btn" onClick={() => act(setAssigned, s.id)}>
                            Asignar apoyo
                          </button>
                        )}
                      </li>
                    ))}
                  </ul>
                </section>
                <section className="demo-card">
                  <header>
                    <h3>Esta semana</h3>
                  </header>
                  <ul>
                    {WEEK.map((w) => (
                      <li key={w.day} className="demo-week">
                        <span>
                          <small>{w.day}</small>
                          {w.n}
                        </span>
                        <span>
                          <strong>{w.title}</strong>
                          <small>{w.meta}</small>
                        </span>
                      </li>
                    ))}
                  </ul>
                </section>
              </div>
              <section className="demo-card" style={{ marginTop: 14 }}>
                <header>
                  <h3>Tus grupos</h3>
                </header>
                <div className="table-wrap">
                  <table className="table demo-table">
                    <thead>
                      <tr>
                        <th>Grupo</th>
                        <th>Estudiantes</th>
                        <th>Aciertos</th>
                        <th>Últimas 6 semanas</th>
                        <th>Necesitan apoyo</th>
                      </tr>
                    </thead>
                    <tbody>
                      {GROUPS.map((g) => (
                        <tr key={g.name}>
                          <td className="cell-title">{g.name}</td>
                          <td>{g.students}</td>
                          <td className="cell-title">{g.score} %</td>
                          <td>
                            <Spark values={g.spark} />
                          </td>
                          <td style={{ color: 'var(--warning)', fontWeight: 600 }}>
                            <span className="dot" style={{ color: '#c27c0e', width: 6, height: 6, marginRight: 6 }} />
                            {g.support}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </section>
            </div>
          ) : (
            <div className="demo__main">
              <div className="demo__hello">
                <div>
                  <h2>Escuela Primaria Demo Órbita</h2>
                  <p>Plan Escuela, ciclo 2026-27</p>
                  <p className="demo__kpis">
                    <strong>5</strong> docentes activos <strong>9</strong> grupos <strong>74 %</strong> de aciertos promedio
                  </p>
                </div>
                <Link to="/demo/institucion?to=/institucion/grupos?generar=1" className="btn btn--secondary btn--sm">
                  Generar código
                </Link>
                <Link to="/demo/institucion?to=/institucion/docentes" className="btn btn--primary btn--sm">
                  Invitar docente
                </Link>
              </div>
              <div className="demo__grid">
                <section className="demo-card">
                  <header>
                    <h3>Lugares de la licencia</h3>
                  </header>
                  <p className="demo-license">
                    <strong>118</strong> de 150 usados
                  </p>
                  <div className="progress" style={{ margin: '10px 0 8px' }}>
                    <div className="progress__bar" style={{ width: '79%', background: '#c27c0e' }} />
                  </div>
                  <p className="card__note">Te avisamos al llegar al 80 %. Quedan 32 lugares.</p>
                </section>
                <section className="demo-card">
                  <header>
                    <h3>Aciertos por grado</h3>
                  </header>
                  <ul className="error-bars">
                    {[
                      ['1.º grado', 71],
                      ['2.º grado', 73],
                      ['3.º grado', 77],
                    ].map(([label, v]) => (
                      <li key={label}>
                        <p>
                          <span>{label}</span>
                          <strong>{v}%</strong>
                        </p>
                        <div className="progress">
                          <div className="progress__bar" style={{ width: `${v}%`, background: '#c27c0e' }} />
                        </div>
                      </li>
                    ))}
                  </ul>
                </section>
              </div>
              <section className="demo-card" style={{ marginTop: 14 }}>
                <header>
                  <h3>Pendientes</h3>
                </header>
                <ul>
                  {PENDING.map((p) => (
                    <li key={p.id} className="demo-row">
                      <span className="demo-row__body">
                        <strong>{p.title}</strong>
                        <small>{p.meta}</small>
                      </span>
                      {resolved[p.id] ? (
                        <span className={`demo-done${resolved[p.id] === 'queued' ? ' is-queued' : ''}`}>
                          <Icon n="151" />
                          {resolved[p.id] === 'queued' ? 'En cola' : p.done}
                        </span>
                      ) : (
                        <button type="button" className="btn btn--outline btn--sm demo-row__btn" onClick={() => act(setResolved, p.id)}>
                          {p.action}
                        </button>
                      )}
                    </li>
                  ))}
                </ul>
              </section>
            </div>
          )}
        </div>
      </div>

      <div className="explore__cta">
        <div>
          <h2>¿Quieres usarlo con tu grupo?</h2>
          <p>Entra con la cuenta de tu escuela. Si tu escuela todavía no usa Órbita Kids, pide información para la dirección.</p>
        </div>
        <Link to="/contacto" className="hero__login">
          Solicitar información
        </Link>
        <Link to="/login" className="btn btn--xl hero__cta" style={{ fontSize: 16 }}>
          Iniciar sesión
        </Link>
      </div>
    </section>
  )
}
