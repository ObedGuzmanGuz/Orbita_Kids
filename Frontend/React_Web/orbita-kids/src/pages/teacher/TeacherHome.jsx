import { Link, useNavigate } from 'react-router-dom'
import Icon from '../../components/Icon'
import LineChart from '../../components/LineChart'
import InstallBanner from '../../components/InstallBanner'
import { AppHeader } from '../../layouts/AppShell'
import { useApp } from '../../state/AppState'
import './teacher.css'

function greeting(date) {
  const h = date.getHours()
  if (h < 12) return 'Buenos días'
  if (h < 19) return 'Buenas tardes'
  return 'Buenas noches'
}

function longDate(date) {
  const text = date.toLocaleDateString('es-MX', { weekday: 'long', day: 'numeric', month: 'long' }).replace(',', '')
  return text.charAt(0).toUpperCase() + text.slice(1)
}

export default function TeacherHome() {
  const { user, teacher, school } = useApp()
  const navigate = useNavigate()
  const now = new Date()

  const active = teacher.groups.filter((g) => g.status === 'active')
  const students = active.reduce((n, g) => n + g.students, 0)
  const running = teacher.activities.filter((a) => a.status === 'active')
  const pendingDeliveries = running.reduce((n, a) => n + Math.max(0, a.total - a.done), 0)
  const weekly = teacher.insights.weekly
  const delta = teacher.insights.delta
  const support = teacher.needSupport
  const supportLink = support[0] ? `/docente/grupos/${support[0].group}?filtro=apoyo` : '/docente/grupos'

  return (
    <>
      <AppHeader title="Inicio" />
      <div className="page">
        <InstallBanner />

        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">
              {greeting(now)}, {user.short}
            </h2>
            <p className="page-sub">
              {longDate(now)} · {school?.name}
            </p>
          </div>
          <Link to="/docente/resultados" className="btn btn--secondary">
            <Icon n="065" />
            Ver resultados
          </Link>
          <Link to="/docente/actividades/nueva" className="btn btn--primary">
            <Icon n="066" />
            Crear actividad
          </Link>
        </div>

        <div className="stats">
          <Stat icon="067" value={active.length} label={active.length === 1 ? 'grupo activo' : 'grupos activos'} />
          <Stat icon="068" value={students} label="estudiantes" />
          <Stat icon="069" value={running.length} label={running.length === 1 ? 'actividad activa' : 'actividades activas'} />
          <Stat icon="070" value={pendingDeliveries} label="entregas pendientes" />
        </div>

        {active.length === 0 ? (
          <section className="card empty-state" style={{ marginTop: 20 }}>
            <span className="empty-state__icon">
              <Icon n="067" />
            </span>
            <h3 className="card__title">Todavía no tienes grupos activos</h3>
            <p className="card__note">Cuando la dirección te asigne un grupo, aquí verás su avance y quién necesita apoyo.</p>
            <Link to="/docente/grupos" className="btn btn--primary">
              Solicitar grupo
            </Link>
          </section>
        ) : (
          <div className="home-grid home-grid--a">
            <section className="card">
              <div className="card__head">
                <h3 className="card__title">Resultados recientes</h3>
                <span className={`tag ${delta >= 0 ? 'tag--success' : 'tag--warning'} home-trend`}>
                  {delta >= 0 ? '▲' : '▼'} {Math.abs(delta)} pts en {weekly.length} semanas
                </span>
                <Link to="/docente/resultados" className="link" style={{ marginLeft: 10 }}>
                  Ver resultados
                </Link>
              </div>
              <LineChart data={weekly} label={`Aciertos promedio por semana: de ${weekly[0]?.value ?? 0} % a ${weekly.at(-1)?.value ?? 0} %`} />
              <p className="card__note" style={{ marginTop: 6 }}>
                Aciertos promedio de {active.length === 1 ? 'tu grupo activo' : `tus ${active.length} grupos activos`}.
              </p>
            </section>

            <section className="card">
              <div className="card__head" style={{ marginBottom: 2 }}>
                <h3 className="card__title">Necesitan apoyo</h3>
                <span className="tag tag--warning" style={{ marginLeft: 'auto' }}>{support.length}</span>
              </div>
              {support.length === 0 ? (
                <p className="empty-note">Nadie necesita apoyo por ahora. ¡Buen trabajo!</p>
              ) : (
                <ul>
                  {support.slice(0, 5).map((s) => (
                    <li key={s.id}>
                      <Link to={`/docente/estudiantes/${s.id}`} className="list-row">
                        <span className="avatar" style={{ background: s.color }}>{s.initials}</span>
                        <span className="list-row__body">
                          <span className="list-row__title">{s.name}</span>
                          <span className="list-row__sub" style={{ display: 'block' }}>
                            {s.groupName} · {s.topic}
                          </span>
                        </span>
                        <span className="list-row__value">{s.score}%</span>
                      </Link>
                    </li>
                  ))}
                </ul>
              )}
              {support.length > 0 && (
                <Link to={supportLink} className="link" style={{ display: 'inline-block', marginTop: 4, fontSize: 14 }}>
                  Ver todos
                </Link>
              )}
            </section>
          </div>
        )}

        <div className="home-grid home-grid--b">
          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Actividades en curso</h3>
              <Link to="/docente/actividades" className="link">Ver todas</Link>
            </div>
            <div className="table-wrap">
              <table className="table">
                <thead>
                  <tr>
                    <th>Actividad</th>
                    <th>Grupo</th>
                    <th>Entrega</th>
                    <th style={{ width: 177 }}>Participación</th>
                  </tr>
                </thead>
                <tbody>
                  {running.length === 0 && (
                    <tr>
                      <td colSpan={4} className="muted" style={{ textAlign: 'center' }}>
                        No hay actividades en curso. <Link to="/docente/actividades/nueva" className="link">Crear actividad</Link>
                      </td>
                    </tr>
                  )}
                  {running.map((a) => (
                    <tr key={a.id} className="is-clickable" onClick={() => navigate('/docente/actividades')}>
                      <td>
                        <div className="cell-title">{a.name}</div>
                        <div className="cell-sub">{a.kind}</div>
                      </td>
                      <td>{a.group}</td>
                      <td>{a.due}</td>
                      <td>
                        <div className="progress-cell">
                          <div className="progress">
                            <div className="progress__bar" style={{ width: `${(a.done / a.total) * 100}%` }} />
                          </div>
                          <span>
                            {a.done} de {a.total}
                          </span>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>

          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Avisos recientes</h3>
              <Link to="/docente/avisos" className="link">Ver avisos</Link>
            </div>
            <ul>
              {teacher.notices.slice(0, 3).map((n) => (
                <li key={n.id}>
                  <Link to={n.to} className="list-row">
                    <span className="icon-box">
                      <Icon n={n.icon} />
                    </span>
                    <span className="list-row__body">
                      <span className="list-row__title" style={{ display: 'block' }}>{n.title}</span>
                      <span className="list-row__sub">{n.meta}</span>
                    </span>
                    {n.unread && <span className="notice-row__dot" aria-label="Sin leer" />}
                  </Link>
                </li>
              ))}
              {teacher.notices.length === 0 && <li className="empty-note">No tienes avisos.</li>}
            </ul>
          </section>
        </div>
      </div>
    </>
  )
}

export function Stat({ icon, value, label, iconBg }) {
  return (
    <div className="stat">
      <span className="stat__icon" style={iconBg ? { background: iconBg } : undefined}>
        <Icon n={icon} />
      </span>
      <p className="stat__value">{value}</p>
      <p className="stat__label">{label}</p>
    </div>
  )
}
