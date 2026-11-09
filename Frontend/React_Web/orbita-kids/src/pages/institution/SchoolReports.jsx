import { useState } from 'react'
import Icon from '../../components/Icon'
import { AppHeader } from '../../layouts/AppShell'
import { Stat } from '../teacher/TeacherHome'
import { useApp } from '../../state/AppState'
import './institution.css'

const GRADES = [
  { key: 0, label: 'Todos' },
  { key: 1, label: '1.º' },
  { key: 2, label: '2.º' },
  { key: 3, label: '3.º' },
]

function exportCsv(rows) {
  const lines = ['Grupo,Docente,Aciertos', ...rows.map((r) => r.label.replace(' · ', ',') + `,${r.value}%`)]
  const blob = new Blob(['﻿' + lines.join('\n')], { type: 'text/csv;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = 'orbita-kids-reporte-institucional.csv'
  a.click()
  URL.revokeObjectURL(url)
}

// 27 · Reportes institucionales (datos agregados)
export default function SchoolReports() {
  const [grade, setGrade] = useState(0)
  const { institution } = useApp()
  const { groupScores: GROUP_SCORES, errorTopics: ERROR_TOPICS } = institution
  const rows = GROUP_SCORES.filter((g) => !grade || g.grade === grade)
  const avg = Math.round(rows.reduce((n, r) => n + r.value, 0) / (rows.length || 1))

  return (
    <>
      <AppHeader title="Reportes" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Reportes institucionales</h2>
            <p className="page-sub">Ciclo 2026-27 · agosto a octubre</p>
          </div>
          <div className="pills" role="group" aria-label="Grado">
            {GRADES.map((g) => (
              <button key={g.key} type="button" className="pill" aria-pressed={grade === g.key} onClick={() => setGrade(g.key)}>
                {g.label}
              </button>
            ))}
          </div>
          <button type="button" className="btn btn--secondary" onClick={() => exportCsv(rows)}>
            <Icon n="095" />
            Exportar CSV
          </button>
        </div>

        <div className="notice notice--info" style={{ marginBottom: 20, alignItems: 'center', color: 'var(--primary-ink)', fontWeight: 600 }}>
          <Icon n="119" />
          Datos agregados por grupo. El detalle de cada estudiante solo lo ve su docente.
        </div>

        <div className="stats">
          <Stat icon="109" value={grade ? rows.length * 13 : 118} label="estudiantes" />
          <Stat icon="111" value={`${avg}%`} label="aciertos promedio" />
          <Stat icon="120" value="86%" label="participación" />
          <Stat icon="121" value={grade ? rows.length * 3 : 23} label="actividades publicadas" />
        </div>

        <div className="home-grid inst-grid">
          <section className="card">
            <h3 className="card__title" style={{ marginBottom: 14 }}>
              Aciertos por grupo
            </h3>
            <ul className="error-bars">
              {rows.map((g) => (
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
          </section>
          <section className="card">
            <h3 className="card__title" style={{ marginBottom: 14 }}>
              Temas con más errores
            </h3>
            <ul className="error-bars">
              {ERROR_TOPICS.map((t) => (
                <li key={t.label}>
                  <p>
                    <span>{t.label}</span>
                    <strong>{t.value}%</strong>
                  </p>
                  <div className="progress">
                    <div className="progress__bar" style={{ width: `${t.value * 2}%`, background: '#c27c0e' }} />
                  </div>
                </li>
              ))}
            </ul>
            <p className="card__note" style={{ marginTop: 14 }}>
              Porcentaje de respuestas incorrectas en cada tema.
            </p>
          </section>
        </div>
      </div>
    </>
  )
}
