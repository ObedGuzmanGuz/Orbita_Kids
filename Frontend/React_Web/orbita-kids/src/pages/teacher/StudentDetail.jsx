import { Link, Navigate, useParams } from 'react-router-dom'
import Icon from '../../components/Icon'
import LineChart from '../../components/LineChart'
import { CodeChip } from '../../components/CodeChip'
import { AppHeader } from '../../layouts/AppShell'
import { Stat } from './TeacherHome'
import { useApp } from '../../state/AppState'
import { whenLabel } from '../../state/format'
import { STATUS } from '../../data/catalog'
import './teacher.css'

// Detalle con los datos del prototipo (Diego L.); el resto de estudiantes usa valores derivados.
const DETAIL = {
  'diego-l': {
    history: [50, 48, 53, 60, 56, 61],
    review: 3,
    errors: [
      { label: 'Sumas que pasan de 10', times: 6 },
      { label: 'Volver a contar el primer grupo', times: 3 },
    ],
    tip: 'Recomendación: «Sumas con apoyo visual», nivel 2. Regla R2: tras 2 errores seguidos se activa el apoyo con objetos.',
  },
}

const MISSIONS = ['Recoge estrellas', 'Revisa el tablero', 'Cuenta los cometas', 'Enciende las luces', 'Repara la antena']
const ATTEMPTS = [
  { id: 'int-3f4f7…', date: '28 oct', ok: 5 },
  { id: 'int-ad131…', date: '27 oct', ok: 5 },
  { id: 'int-b62b4…', date: '24 oct', ok: 3 },
  { id: 'int-d8033…', date: '22 oct', ok: 3 },
  { id: 'int-42b13…', date: '21 oct', ok: 3 },
]

function detailFor(student) {
  if (DETAIL[student.id]) return DETAIL[student.id]
  const s = student.score
  return {
    history: [s - 9, s - 7, s - 5, s - 3, s - 2, s].map((v) => Math.max(40, Math.min(100, v))),
    review: student.status === 'support' ? 2 : 0,
    errors: [
      { label: 'Sumas que pasan de 10', times: student.status === 'support' ? 5 : 2 },
      { label: 'Volver a contar el primer grupo', times: student.status === 'support' ? 3 : 1 },
    ],
    tip:
      student.status === 'support'
        ? 'Recomendación: «Sumas con apoyo visual», nivel 2. Regla R2: tras 2 errores seguidos se activa el apoyo con objetos.'
        : 'Va a buen ritmo. Puedes asignarle «Sumas hasta 20» para seguir avanzando.',
  }
}

export default function StudentDetail() {
  const { studentId } = useParams()
  const { online, submit, toast, teacher } = useApp()
  const student = teacher.students.find((s) => s.id === studentId)
  if (!student) return <Navigate to="/docente/grupos" replace />

  const group = teacher.groups.find((g) => g.id === student.group)
  const d = detailFor(student)
  const maxTimes = 8
  const history = ['S1', 'S2', 'S3', 'S4', 'S5', 'S6'].map((label, i) => ({ label, value: d.history[i] }))

  const assign = () => {
    submit('assign-reinforcement', { studentId: student.id, topic: 'Sumas con apoyo visual' }, { title: `Refuerzo para ${student.name}`, icon: '089' })
    toast(online ? `Refuerzo «Sumas con apoyo visual» asignado a ${student.name}` : 'Guardado sin conexión. Se enviará solo al reconectar.')
  }

  return (
    <>
      <AppHeader title={student.name} eyebrow={`Mis grupos · ${group.name}`} />
      <div className="page">
        <Link to={`/docente/grupos/${group.id}`} className="back-link">
          <Icon n="017" />
          {group.name}
        </Link>
        <div className="page-head student-head">
          <span className="avatar avatar--profile" style={{ background: student.color }}>{student.initials}</span>
          <div className="page-head__text">
            <h2 className="page-title">{student.name}</h2>
            <p className="page-sub">
              {group.name} · última actividad {student.last.toLowerCase()}
              {student.reinforcement && ` · refuerzo asignado ${whenLabel(student.reinforcement.at)}`}
            </p>
          </div>
          <span className={`tag ${STATUS[student.status].tag} student-head__tag`}>{STATUS[student.status].label}</span>
          <button type="button" className="btn btn--primary" onClick={assign}>
            <Icon n="089" />
            Asignar refuerzo
          </button>
        </div>

        <div className="stats">
          <Stat icon="084" value={`${student.score}%`} label="aciertos" />
          <Stat icon="090" value={student.attempts} label="intentos registrados" />
          <Stat icon="070" value={student.pending} label="actividades pendientes" />
          <Stat icon="086" value={d.review} label="respuestas por revisar" />
        </div>

        <div className="home-grid student-grid">
          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Evolución de 6 semanas</h3>
            </div>
            <LineChart data={history} label={`Evolución de aciertos de ${student.name}`} />
            <p className="card__note" style={{ marginTop: 6 }}>
              Se compara solo con su propio avance. Sin rankings.
            </p>
          </section>
          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Errores frecuentes</h3>
            </div>
            <ul className="error-bars">
              {d.errors.map((e) => (
                <li key={e.label}>
                  <p>
                    <span>{e.label}</span>
                    <strong>{e.times} veces</strong>
                  </p>
                  <div className="progress">
                    <div className="progress__bar" style={{ width: `${(e.times / maxTimes) * 100}%`, background: '#c27c0e' }} />
                  </div>
                </li>
              ))}
            </ul>
            <p className="tip">
              <Icon n="092" />
              <span>{d.tip}</span>
            </p>
          </section>
        </div>

        <section className="card" style={{ marginTop: 20 }}>
          <div className="card__head">
            <h3 className="card__title">Intentos recientes</h3>
            <span className="card__note" style={{ marginLeft: 'auto' }}>
              Cada intento tiene un identificador único para sincronizar sin duplicados.
            </span>
          </div>
          <div className="table-wrap">
            <table className="table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Misión</th>
                  <th>Fecha</th>
                  <th className="num">Correctas</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                {ATTEMPTS.map((a, i) => (
                  <tr key={a.id}>
                    <td>
                      <CodeChip code={a.id} />
                    </td>
                    <td className="cell-title">{MISSIONS[i]}</td>
                    <td>{a.date}</td>
                    <td className="num">{a.ok} de 5</td>
                    <td>
                      <span className="tag tag--success">Confirmado</span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </>
  )
}
