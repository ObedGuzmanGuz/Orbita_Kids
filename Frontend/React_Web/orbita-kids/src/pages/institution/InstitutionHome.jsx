import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Icon from '../../components/Icon'
import { AppHeader } from '../../layouts/AppShell'
import { Stat } from '../teacher/TeacherHome'
import { useApp } from '../../state/AppState'
import InviteTeacherDialog from './InviteTeacherDialog'
import './institution.css'

// 23 · Panel de la institución
export default function InstitutionHome() {
  const navigate = useNavigate()
  const [invite, setInvite] = useState(false)
  const { institution, user } = useApp()
  const { license: LICENSE, gradeProgress: GRADE_PROGRESS, pending: PENDING, weeklySessions: WEEKLY_SESSIONS } = institution
  const maxSessions = Math.max(1, ...WEEKLY_SESSIONS)
  const activeTeachers = institution.teachers.filter((t) => t.status === 'active').length
  const requests = institution.teachers.filter((t) => t.status === 'request').length
  const liveGroups = institution.groups.filter((g) => g.status !== 'archived').length
  const scores = institution.groupScores.map((g) => g.value)
  const average = scores.length ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length) : 0

  return (
    <>
      <AppHeader title="Inicio" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">{institution.settings.displayName || `Escuela ${institution.school.name}`}</h2>
            <p className="page-sub">
              {LICENSE.plan} · {LICENSE.cycle} · {user.short.split(' ')[0]} {user.name}
            </p>
          </div>
          <button type="button" className="btn btn--secondary" onClick={() => navigate('/institucion/grupos?generar=1')}>
            <Icon n="106" />
            Generar código
          </button>
          <button type="button" className="btn btn--primary" onClick={() => setInvite(true)}>
            <Icon n="107" />
            Invitar docente
          </button>
        </div>

        <div className="stats">
          <div className="stat">
            <span className="stat__icon">
              <Icon n="108" />
            </span>
            <p className="stat__value">
              {LICENSE.used} <small className="stat__of">/ {LICENSE.total}</small>
            </p>
            <p className="stat__label">lugares usados</p>
            <div className="progress" style={{ marginTop: 14 }}>
              <div className="progress__bar progress__bar--amber" style={{ width: `${(LICENSE.used / (LICENSE.total || 1)) * 100}%` }} />
            </div>
          </div>
          <div className="stat">
            <span className="stat__icon">
              <Icon n="109" />
            </span>
            <p className="stat__value">{activeTeachers}</p>
            <p className="stat__label">docentes activos</p>
            {requests > 0 && (
              <Link to="/institucion/docentes?filtro=solicitudes" className="tag tag--warning" style={{ display: 'flex', marginTop: 10 }}>
                {requests} {requests === 1 ? 'solicitud' : 'solicitudes'}
              </Link>
            )}
          </div>
          <Stat icon="110" value={liveGroups} label="grupos" />
          <Stat icon="111" value={`${average}%`} label="aciertos promedio" />
        </div>

        <div className="home-grid inst-grid">
          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Avance por grado</h3>
              <Link to="/institucion/reportes" className="link">
                Ver reportes
              </Link>
            </div>
            <ul className="error-bars">
              {GRADE_PROGRESS.map((g) => (
                <li key={g.label}>
                  <p>
                    <span>{g.label}</span>
                    <strong>{g.value}%</strong>
                  </p>
                  <div className="progress">
                    <div className="progress__bar progress__bar--amber" style={{ width: `${g.value}%` }} />
                  </div>
                </li>
              ))}
            </ul>
            <h4 className="inst-subtitle">Sesiones por semana</h4>
            <div className="session-bars" role="img" aria-label={`Sesiones por semana: ${WEEKLY_SESSIONS.join(', ')}`}>
              {WEEKLY_SESSIONS.map((v, i) => (
                <div key={i} className={`session-bars__col${i === WEEKLY_SESSIONS.length - 1 ? ' is-current' : ''}`}>
                  <span className="session-bars__value">{v}</span>
                  <span className="session-bars__bar" style={{ height: `${(v / maxSessions) * 66}px` }} />
                  <span className="session-bars__label">S{i + 1}</span>
                </div>
              ))}
            </div>
          </section>

          <section className="card">
            <div className="card__head" style={{ marginBottom: 2 }}>
              <h3 className="card__title">Pendientes</h3>
              <span className="tag tag--warning" style={{ marginLeft: 'auto' }}>{PENDING.length}</span>
            </div>
            <ul>
              {PENDING.map((p) => (
                <li key={p.title} className="list-row">
                  <span className="icon-box">
                    <Icon n={p.icon} />
                  </span>
                  <span className="list-row__body">
                    <span className="list-row__title" style={{ display: 'block' }}>{p.title}</span>
                    <span className="list-row__sub">{p.meta}</span>
                  </span>
                  <Link to={p.to} className={`btn btn--sm ${p.primary ? 'btn--primary' : 'btn--secondary'}`}>
                    {p.action}
                  </Link>
                </li>
              ))}
            </ul>
          </section>
        </div>
      </div>
      {invite && <InviteTeacherDialog onClose={() => setInvite(false)} />}
    </>
  )
}
