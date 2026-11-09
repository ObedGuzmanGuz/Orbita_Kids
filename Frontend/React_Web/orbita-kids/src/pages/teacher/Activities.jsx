import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Icon from '../../components/Icon'
import { AppHeader } from '../../layouts/AppShell'
import { useApp } from '../../state/AppState'
import { ACTIVITY_STATUS } from '../../data/catalog'
import './teacher.css'

const FILTERS = [
  { key: 'all', label: 'Todas' },
  { key: 'active', label: 'Activas' },
  { key: 'scheduled', label: 'Programadas' },
  { key: 'draft', label: 'Borradores' },
  { key: 'closed', label: 'Cerradas' },
]

export default function Activities() {
  const navigate = useNavigate()
  const { teacher } = useApp()
  const [filter, setFilter] = useState('all')
  const [group, setGroup] = useState('all')
  const all = teacher.activities
  const drafts = all.filter((a) => a.status === 'draft').length
  const groups = teacher.groups.filter((g) => g.status === 'active')

  const count = (key) => (key === 'all' ? all.length : all.filter((a) => a.status === key).length)
  const rows = all.filter((a) => (filter === 'all' || a.status === filter) && (group === 'all' || a.groupId === group))
  const open = (a) => navigate(a.status === 'draft' ? `/docente/actividades/nueva?borrador=${a.id}` : `/docente/resultados?grupo=${a.groupId}`)

  return (
    <>
      <AppHeader title="Actividades" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Actividades</h2>
            <p className="page-sub">
              {count('active')} activas · {drafts} {drafts === 1 ? 'borrador' : 'borradores'}
            </p>
          </div>
          <Link to="/docente/actividades/nueva" className="btn btn--primary">
            <Icon n="066" />
            Crear actividad
          </Link>
        </div>

        <div className="roster-tools" style={{ marginTop: 0 }}>
          <div className="pills" role="group" aria-label="Filtrar actividades">
            {FILTERS.map((f) => (
              <button key={f.key} type="button" className="pill" aria-pressed={filter === f.key} onClick={() => setFilter(f.key)}>
                {f.label} ({count(f.key)})
              </button>
            ))}
          </div>
          <select className="input input--sm" style={{ width: 200 }} value={group} onChange={(e) => setGroup(e.target.value)} aria-label="Grupo">
            <option value="all">Todos los grupos</option>
            {groups.map((g) => (
              <option key={g.id} value={g.id}>
                {g.name}
              </option>
            ))}
          </select>
        </div>

        <section className="card">
          <div className="table-wrap">
            <table className="table">
              <thead>
                <tr>
                  <th>Actividad</th>
                  <th>Grupo</th>
                  <th>Nivel</th>
                  <th>Entrega</th>
                  <th>Estado</th>
                  <th style={{ width: 170 }}>Participación</th>
                  <th aria-label="Acciones" />
                </tr>
              </thead>
              <tbody>
                {rows.map((a) => (
                  <tr key={a.id} className="is-clickable" onClick={() => open(a)}>
                    <td>
                      <div className="cell-title">{a.name}</div>
                      <div className="cell-sub">{a.kind}</div>
                    </td>
                    <td>{a.group}</td>
                    <td>Nivel {a.level}</td>
                    <td>{a.due}</td>
                    <td>
                      {a.pending ? (
                        <span className="tag tag--warning" title="Se enviará al servidor en cuanto haya conexión">
                          En cola
                        </span>
                      ) : (
                        <span className={`tag ${ACTIVITY_STATUS[a.status].tag}`}>{ACTIVITY_STATUS[a.status].label}</span>
                      )}
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
                    <td className="actions">
                      <Link
                        to={a.status === 'draft' ? `/docente/actividades/nueva?borrador=${a.id}` : `/docente/resultados?grupo=${a.groupId}`}
                        className="open-btn"
                        onClick={(e) => e.stopPropagation()}
                      >
                        {a.status === 'draft' ? 'Editar' : 'Abrir'}
                        <Icon n="088" />
                      </Link>
                    </td>
                  </tr>
                ))}
                {rows.length === 0 && (
                  <tr>
                    <td colSpan={7} className="muted" style={{ textAlign: 'center' }}>
                      {filter === 'draft' ? (
                        <>
                          No tienes borradores. <Link to="/docente/actividades/nueva" className="link">Crear actividad</Link>
                        </>
                      ) : (
                        'No hay actividades con ese filtro.'
                      )}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </>
  )
}
