import { useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import Icon from '../../components/Icon'
import { AppHeader } from '../../layouts/AppShell'
import { useApp } from '../../state/AppState'
import { TEACHER_STATUS } from '../../data/catalog'
import InviteTeacherDialog from './InviteTeacherDialog'
import './institution.css'

const FILTERS = [
  { key: 'all', label: 'Todos' },
  { key: 'active', label: 'Activos' },
  { key: 'request', label: 'Solicitudes', param: 'solicitudes' },
  { key: 'invited', label: 'Invitaciones' },
  { key: 'disabled', label: 'Desactivados' },
]

// 24a · Docentes y solicitudes
export default function Teachers() {
  const { toast, institution, submit, online } = useApp()
  const [params, setParams] = useSearchParams()
  const list = institution.teachers
  const [query, setQuery] = useState(() => params.get('q') || '')
  const [invite, setInvite] = useState(false)
  const filter = FILTERS.find((f) => f.param === params.get('filtro'))?.key || params.get('filtro') || 'all'

  const count = (key) => (key === 'all' ? list.length : list.filter((t) => t.status === key).length)
  const q = query.trim().toLowerCase()
  const rows = list.filter((t) => (filter === 'all' || t.status === filter) && (!q || `${t.name} ${t.email}`.toLowerCase().includes(q)))

  // Cada acción es un cambio con id único: se ve al momento y el servidor la confirma (o la aplica al reconectar).
  const act = (type, payload, title, message) => {
    submit(type, payload, { title, icon: '109' })
    toast(online ? message : `${message} Se enviará al reconectar.`)
  }

  const setFilter = (key) => {
    const f = FILTERS.find((x) => x.key === key)
    setParams(key === 'all' ? {} : { filtro: f.param || key }, { replace: true })
  }

  return (
    <>
      <AppHeader title="Docentes" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Docentes</h2>
            <p className="page-sub">
              {count('active')} activos · {count('request')} solicitud · {count('invited')} invitación
            </p>
          </div>
          <button type="button" className="btn btn--primary" onClick={() => setInvite(true)}>
            <Icon n="107" />
            Invitar docente
          </button>
        </div>

        <div className="roster-tools" style={{ marginTop: 0, marginBottom: 20 }}>
          <div className="pills" role="group" aria-label="Filtrar docentes">
            {FILTERS.map((f) => (
              <button key={f.key} type="button" className="pill" aria-pressed={filter === f.key} onClick={() => setFilter(f.key)}>
                {f.label} ({count(f.key)})
              </button>
            ))}
          </div>
          <label className="input input--sm" style={{ width: 240 }}>
            <Icon n="087" />
            <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Buscar por nombre o correo" aria-label="Buscar por nombre o correo" />
          </label>
        </div>

        <section className="card">
          <div className="table-wrap">
            <table className="table">
              <thead>
                <tr>
                  <th>Docente</th>
                  <th>Grupos</th>
                  <th className="num">Estudiantes</th>
                  <th>Estado</th>
                  <th>Último acceso</th>
                  <th style={{ textAlign: 'right' }}>Acciones</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((t) => (
                  <tr key={t.id}>
                    <td>
                      <span className="row" style={{ gap: 10 }}>
                        <span className="avatar avatar--sq" style={{ background: t.color }}>{t.initials}</span>
                        <span>
                          <span className="cell-title">
                            {t.name} {t.director && <span className="tag tag--warning" style={{ marginLeft: 2 }}>Dirección</span>}
                          </span>
                          <span className="cell-sub" style={{ display: 'block' }}>{t.email}</span>
                        </span>
                      </span>
                    </td>
                    <td className={t.note ? 'cell-sub' : ''} style={{ maxWidth: 200 }}>
                      {t.note || t.groups}
                    </td>
                    <td className="num">{t.students}</td>
                    <td>
                      <span className={`tag ${TEACHER_STATUS[t.status].tag}`}>{TEACHER_STATUS[t.status].label}</span>
                    </td>
                    <td className="muted">{t.last}</td>
                    <td style={{ textAlign: 'right', whiteSpace: 'nowrap' }}>
                      {t.status === 'active' && !t.director && (
                        <button type="button" className="btn btn--ghost btn--sm" onClick={() => act('set-teacher-status', { staffId: t.id, status: 'disabled' }, `Desactivar a ${t.name}`, `${t.name} quedó desactivado. Sus grupos se reasignarán.`)}>
                          Desactivar
                        </button>
                      )}
                      {t.status === 'disabled' && (
                        <button type="button" className="btn btn--ghost btn--sm" onClick={() => act('set-teacher-status', { staffId: t.id, status: 'active' }, `Reactivar a ${t.name}`, `${t.name} está activo otra vez.`)}>
                          Reactivar
                        </button>
                      )}
                      {t.status === 'request' && (
                        <>
                          <button
                            type="button"
                            className="btn btn--primary btn--sm"
                            onClick={() => act('review-teacher', { staffId: t.id, decision: 'approve' }, `Aprobar a ${t.name}`, `Aprobaste a ${t.name}.`)}
                          >
                            Aprobar
                          </button>
                          <button type="button" className="btn btn--sm" style={{ color: 'var(--ink)' }} onClick={() => act('review-teacher', { staffId: t.id, decision: 'reject' }, `Rechazar a ${t.name}`, `Rechazaste la solicitud de ${t.name}.`)}>
                            Rechazar
                          </button>
                        </>
                      )}
                      {t.pending && <span className="cell-sub">En cola…</span>}
                      {t.status === 'invited' && !t.pending && (
                        <button type="button" className="btn btn--sm" style={{ color: 'var(--ink)' }} onClick={() => act('resend-invite', { staffId: t.id }, `Reenviar invitación a ${t.email}`, `Reenviamos la invitación a ${t.email}.`)}>
                          Reenviar
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
                {rows.length === 0 && (
                  <tr>
                    <td colSpan={6} className="muted" style={{ textAlign: 'center' }}>
                      No hay docentes con ese filtro.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </section>
        <p className="card__note" style={{ marginTop: 20 }}>
          Desactivar no borra datos: los grupos se reasignan a otro docente. Solo se aceptan correos @escuela.example.
        </p>
      </div>
      {invite && (
        <InviteTeacherDialog onClose={() => setInvite(false)} />
      )}
    </>
  )
}
