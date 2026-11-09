import { useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import Icon from '../../components/Icon'
import LineChart from '../../components/LineChart'
import { AppHeader } from '../../layouts/AppShell'
import { Stat } from './TeacherHome'
import { useApp } from '../../state/AppState'
import './teacher.css'

const csvCell = (value) => (/[",\n]/.test(String(value)) ? `"${String(value).replace(/"/g, '""')}"` : value)

function downloadCsv(group, report, roster) {
  const lines = [
    ['Grupo', 'Mes', 'Aciertos promedio', 'Entregas completadas', 'Pendientes', 'Intentos'].join(','),
    [group.name, report.month, `${report.score}%`, report.completed, report.pending, report.attempts].join(','),
    '',
    ['Estudiante', 'Aciertos', 'Intentos', 'Pendientes', 'Última actividad'].join(','),
    ...roster.map((s) => [s.name, `${s.score}%`, s.attempts, s.pending, s.last].map(csvCell).join(',')),
  ]
  const blob = new Blob(['﻿' + lines.join('\n')], { type: 'text/csv;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `orbita-kids-${group.id}-${report.month.toLowerCase().replace(' ', '-')}.csv`
  a.click()
  URL.revokeObjectURL(url)
}

export default function Results() {
  const { online, submit, toast, teacher } = useApp()
  const [params] = useSearchParams()
  const groups = teacher.groups.filter((g) => g.status === 'active')
  const [picked, setGroupId] = useState(params.get('grupo'))
  const group = groups.find((g) => g.id === picked) || groups[0]
  const groupId = group?.id
  const report = teacher.reports[groupId]

  if (!group || !report) {
    return (
      <>
        <AppHeader title="Resultados" />
        <div className="page">
          <section className="card empty-state">
            <h3 className="card__title">Aún no hay resultados</h3>
            <p className="card__note">Cuando tengas un grupo activo y tus estudiantes jueguen sus misiones, aquí verás su avance.</p>
          </section>
        </div>
      </>
    )
  }

  const roster = teacher.students.filter((s) => s.group === groupId)
  const maxErr = Math.max(10, ...report.errors.map((e) => e.count))
  const weekly = report.weekly.map((value, i) => ({ label: `S${i + 1}`, value }))

  const assign = (s) => {
    submit('assign-reinforcement', { studentId: s.id, topic: s.topic || 'Sumas con apoyo visual' }, { title: `Refuerzo para ${s.name}`, icon: '089' })
    toast(online ? `Refuerzo asignado a ${s.name}` : 'Sin conexión: el refuerzo quedó en cola.')
  }

  return (
    <>
      <AppHeader title="Resultados" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Resultados y reportes</h2>
            <p className="page-sub">
              {report.month} · {group.name}
            </p>
          </div>
          <div className="pills" role="group" aria-label="Grupo">
            {groups.map((g) => (
              <button key={g.id} type="button" className="pill" aria-pressed={g.id === groupId} onClick={() => setGroupId(g.id)}>
                {g.name}
              </button>
            ))}
          </div>
          <button type="button" className="btn btn--secondary" onClick={() => downloadCsv(group, report, roster)}>
            <Icon n="095" />
            CSV
          </button>
          <button type="button" className="btn btn--secondary" onClick={() => window.print()}>
            <Icon n="096" />
            PDF
          </button>
        </div>

        <div className="stats">
          <div className="stat">
            <span className="stat__icon">
              <Icon n="084" />
            </span>
            <p className="stat__value">{report.score}%</p>
            <p className="stat__label">aciertos promedio</p>
            <span className="tag tag--success" style={{ display: 'flex', marginTop: 10 }}>{report.trend}</span>
          </div>
          <Stat icon="085" value={report.completed} label="entregas completadas" />
          <Stat icon="070" value={report.pending} label="pendientes" />
          <Stat icon="090" value={report.attempts} label="intentos" />
        </div>

        <div className="home-grid results-grid">
          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Evolución del grupo</h3>
            </div>
            <LineChart data={weekly} label={`Evolución de aciertos de ${group.name}`} />
          </section>
          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Errores frecuentes</h3>
            </div>
            <ul className="error-bars">
              {report.errors.map((e) => (
                <li key={e.label}>
                  <p>
                    <span>{e.label}</span>
                    <strong>{e.count} est.</strong>
                  </p>
                  <div className="progress">
                    <div className="progress__bar" style={{ width: `${(e.count / maxErr) * 100}%`, background: '#c27c0e' }} />
                  </div>
                </li>
              ))}
            </ul>
          </section>
        </div>

        <div className="home-grid results-grid results-grid--b">
          <section className="card">
            <div className="card__head" style={{ marginBottom: 2 }}>
              <h3 className="card__title">Necesitan refuerzo</h3>
              <span className="tag tag--warning" style={{ marginLeft: 'auto' }}>{report.support.length}</span>
            </div>
            <ul>
              {report.support.map((s) => (
                <li key={s.name} className="list-row">
                  <span className="avatar" style={{ background: s.color }}>{s.initials}</span>
                  <Link to={`/docente/estudiantes/${s.id}`} className="list-row__body">
                    <span className="list-row__title" style={{ display: 'block' }}>{s.name}</span>
                    <span className="list-row__sub">
                      {s.topic} · {s.score}% de aciertos
                    </span>
                  </Link>
                  <button type="button" className="btn btn--secondary btn--sm" onClick={() => assign(s)}>
                    Asignar
                  </button>
                </li>
              ))}
            </ul>
          </section>
          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Participación por actividad</h3>
            </div>
            <ul className="error-bars">
              {report.participation.map((p) => (
                <li key={p.label}>
                  <p>
                    <span>{p.label}</span>
                    <strong>
                      {p.done} de {p.total}
                    </strong>
                  </p>
                  <div className="progress">
                    <div className="progress__bar" style={{ width: `${(p.done / p.total) * 100}%` }} />
                  </div>
                </li>
              ))}
            </ul>
          </section>
        </div>
      </div>
    </>
  )
}
