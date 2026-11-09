import { useMemo, useState } from 'react'
import { Link, Navigate, useNavigate, useParams, useSearchParams } from 'react-router-dom'
import Icon from '../../components/Icon'
import { CodeChip, CopyButton } from '../../components/CodeChip'
import LineChart from '../../components/LineChart'
import { AppHeader } from '../../layouts/AppShell'
import { Stat } from './TeacherHome'
import { STATUS } from '../../data/catalog'
import { useApp } from '../../state/AppState'
import './teacher.css'

const FILTERS = [
  { key: 'all', label: 'Todos' },
  { key: 'support', label: 'Necesita apoyo' },
  { key: 'idle', label: 'Sin actividad reciente' },
  { key: 'ok', label: 'Al día' },
]

export default function GroupDetail() {
  const { groupId } = useParams()
  const [params, setParams] = useSearchParams()
  const navigate = useNavigate()
  const [tab, setTab] = useState('students')
  const [query, setQuery] = useState(params.get('q') || '')
  const filter = params.get('filtro') === 'apoyo' ? 'support' : params.get('filtro') || 'all'

  const { teacher } = useApp()
  const group = teacher.groups.find((g) => g.id === groupId)
  const roster = useMemo(() => teacher.students.filter((s) => s.group === groupId), [teacher.students, groupId])

  if (!group) return <Navigate to="/docente/grupos" replace />

  const activities = teacher.activities.filter((a) => a.groupId === group.id && a.status !== 'draft')
  const weekly = (teacher.reports[group.id]?.weekly || []).map((value, i) => ({ label: `S${i + 1}`, value }))

  const counts = {
    all: roster.length,
    support: roster.filter((s) => s.status === 'support').length,
    idle: roster.filter((s) => s.status === 'idle').length,
    ok: roster.filter((s) => s.status === 'ok').length,
  }
  const q = query.trim().toLowerCase()
  const rows = roster.filter((s) => (filter === 'all' || s.status === filter) && (!q || s.name.toLowerCase().includes(q)))

  const setFilter = (key) => {
    const next = new URLSearchParams(params)
    if (key === 'all') next.delete('filtro')
    else next.set('filtro', key === 'support' ? 'apoyo' : key)
    setParams(next, { replace: true })
  }

  return (
    <>
      <AppHeader title={group.name} eyebrow="Mis grupos" />
      <div className="page">
        <div className="page-head group-head">
          <div className="page-head__text">
            <Link to="/docente/grupos" className="back-link">
              <Icon n="017" />
              Mis grupos
            </Link>
            <h2 className="page-title">
              {group.name} <span className="group-head__level">· {group.level}</span>
            </h2>
            <p className="group-head__meta">
              <span className="page-sub">{group.students} estudiantes · código</span>
              <CodeChip code={group.code} muted />
              <CopyButton text={group.code} />
            </p>
          </div>
          <Link to={`/docente/actividades/nueva?grupo=${group.id}`} className="btn btn--primary">
            <Icon n="066" />
            Asignar actividad
          </Link>
        </div>

        <div className="stats">
          <Stat icon="084" value={`${group.score}%`} label="aciertos promedio" />
          <Stat icon="085" value={group.completed} label="entregas completadas" />
          <Stat icon="070" value={group.pending} label="pendientes" />
          <Stat icon="086" value={group.support} label="necesitan apoyo" />
        </div>

        <section className="card" style={{ marginTop: 20 }}>
          <div className="underline-tabs" role="tablist">
            <button type="button" role="tab" aria-selected={tab === 'students'} onClick={() => setTab('students')}>
              Estudiantes
            </button>
            <button type="button" role="tab" aria-selected={tab === 'activities'} onClick={() => setTab('activities')}>
              Actividades
            </button>
            <button type="button" role="tab" aria-selected={tab === 'results'} onClick={() => setTab('results')}>
              Resultados
            </button>
          </div>

          {tab === 'students' && (
            <>
              <div className="roster-tools">
                <div className="pills" role="group" aria-label="Filtrar estudiantes">
                  {FILTERS.map((f) => (
                    <button key={f.key} type="button" className="pill" aria-pressed={filter === f.key} onClick={() => setFilter(f.key)}>
                      {f.label} ({counts[f.key]})
                    </button>
                  ))}
                </div>
                <label className="input input--sm roster-search">
                  <Icon n="087" />
                  <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Buscar estudiante" aria-label="Buscar estudiante" />
                </label>
              </div>
              <div className="table-wrap">
                <table className="table roster">
                  <thead>
                    <tr>
                      <th>Estudiante</th>
                      <th>Aciertos</th>
                      <th className="num">Intentos</th>
                      <th className="num">Pendientes</th>
                      <th>Estado</th>
                      <th>Última actividad</th>
                      <th aria-label="Acciones" />
                    </tr>
                  </thead>
                  <tbody>
                    {rows.map((s) => (
                      <tr key={s.id} className="is-clickable" onClick={() => navigate(`/docente/estudiantes/${s.id}`)}>
                        <td>
                          <span className="row" style={{ gap: 10 }}>
                            <span className="avatar avatar--sq" style={{ background: s.color }}>{s.initials}</span>
                            <span className="cell-title">{s.name}</span>
                          </span>
                        </td>
                        <td>
                          <span className="row" style={{ gap: 8 }}>
                            <span className="progress" style={{ width: 112 }}>
                              <span className="progress__bar" style={{ width: `${s.score}%` }} />
                            </span>
                            <span className="cell-title">{s.score}%</span>
                          </span>
                        </td>
                        <td className="num">{s.attempts}</td>
                        <td className="num">{s.pending}</td>
                        <td>
                          <span className={`tag ${STATUS[s.status].tag}`}>{STATUS[s.status].label}</span>
                        </td>
                        <td className="muted">{s.last}</td>
                        <td className="actions">
                          <Link to={`/docente/estudiantes/${s.id}`} className="open-btn" onClick={(e) => e.stopPropagation()}>
                            Abrir
                            <Icon n="088" />
                          </Link>
                        </td>
                      </tr>
                    ))}
                    {rows.length === 0 && (
                      <tr>
                        <td colSpan={7} className="muted" style={{ textAlign: 'center' }}>
                          No hay estudiantes con ese filtro.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </>
          )}

          {tab === 'activities' && (
            <div className="table-wrap" style={{ marginTop: 12 }}>
              <table className="table">
                <thead>
                  <tr>
                    <th>Actividad</th>
                    <th>Entrega</th>
                    <th style={{ width: 200 }}>Participación</th>
                  </tr>
                </thead>
                <tbody>
                  {activities.length === 0 && (
                    <tr>
                      <td colSpan={3} className="muted" style={{ textAlign: 'center' }}>
                        Este grupo no tiene actividades.
                      </td>
                    </tr>
                  )}
                  {activities.map((a) => (
                    <tr key={a.id}>
                      <td>
                        <div className="cell-title">{a.name}</div>
                        <div className="cell-sub">{a.kind}</div>
                      </td>
                      <td>
                        {a.due}
                        {a.status !== 'active' && <span className="cell-sub" style={{ display: 'block' }}>{a.status === 'closed' ? 'Cerrada' : 'Programada'}</span>}
                      </td>
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
          )}

          {tab === 'results' && (
            <div style={{ marginTop: 16 }}>
              <LineChart data={weekly} label={`Aciertos promedio de ${group.name} por semana`} />
              <p className="card__note" style={{ marginTop: 6 }}>
                Aciertos promedio de {group.name} en las últimas 6 semanas.{' '}
                <Link to="/docente/resultados" className="link">
                  Ver reporte completo
                </Link>
              </p>
            </div>
          )}
        </section>
      </div>
    </>
  )
}
