import { useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import Icon from '../../components/Icon'
import Dialog from '../../components/Dialog'
import { CodeChip } from '../../components/CodeChip'
import { AppHeader } from '../../layouts/AppShell'
import { useApp } from '../../state/AppState'
import { GROUP_STATUS } from '../../data/catalog'
import './institution.css'

const GRADES = [
  { key: 0, label: 'Todos los grados' },
  { key: 1, label: '1.º grado' },
  { key: 2, label: '2.º grado' },
  { key: 3, label: '3.º grado' },
]

function randomCode(name) {
  const base = name.replace(/[^0-9A-Za-z]/g, '').toUpperCase().slice(0, 2) || 'XX'
  const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'
  return `ORB-${base}${chars[Math.floor(Math.random() * 9) + 22]}${chars[Math.floor(Math.random() * 22)]}`
}

// 25b · Generar código de grupo
function GenerateCodeDialog({ free, teachers: staff, onClose, onCreate }) {
  const teachers = staff.filter((t) => t.status === 'active' && !t.pending)
  const [name, setName] = useState('2° D')
  const [teacher, setTeacher] = useState(() => teachers.find((t) => t.name === 'Ana Ríos')?.id || teachers[0]?.id || '')
  const [seats, setSeats] = useState(() => Math.max(1, Math.min(15, free)))
  const [until, setUntil] = useState('31 jul 2027')
  const [code] = useState('ORB-2D5S')
  const preview = name === '2° D' ? code : randomCode(name)

  return (
    <Dialog title="Generar código de grupo" onClose={onClose}>
      <form
        className="invite-form"
        onSubmit={(e) => {
          e.preventDefault()
          onCreate({ name: name.trim() || 'Nuevo grupo', teacher, seats, until, code: preview })
        }}
      >
        <div className="create-row">
          <div className="field">
            <label className="field__label" htmlFor="gen-group">
              Grupo
            </label>
            <input id="gen-group" className="input" value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="field">
            <label className="field__label" htmlFor="gen-teacher">
              Docente
            </label>
            <select id="gen-teacher" className="input" value={teacher} onChange={(e) => setTeacher(e.target.value)}>
              {teachers.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.name}
                </option>
              ))}
            </select>
          </div>
        </div>
        <div className="create-row">
          <div className="field">
            <span className="field__label" id="gen-seats">
              Lugares
            </span>
            <div className="stepper" role="group" aria-labelledby="gen-seats">
              <button type="button" aria-label="Menos lugares" onClick={() => setSeats((s) => Math.max(1, s - 1))}>
                −
              </button>
              <output>{seats}</output>
              <button type="button" aria-label="Más lugares" onClick={() => setSeats((s) => Math.min(free, s + 1))}>
                +
              </button>
            </div>
            <p className="field__hint">Quedan {free} libres en la licencia</p>
          </div>
          <div className="field">
            <label className="field__label" htmlFor="gen-until">
              Vigencia
            </label>
            <select id="gen-until" className="input" value={until} onChange={(e) => setUntil(e.target.value)}>
              <option value="31 jul 2027">Hasta fin de ciclo (31 jul 2027)</option>
              <option value="31 ene 2027">Hasta fin de semestre (31 ene 2027)</option>
              <option value="7 dic 2026">30 días (7 dic 2026)</option>
            </select>
          </div>
        </div>
        <div className="notice notice--info" style={{ alignItems: 'center' }}>
          <span className="notice__title" style={{ flex: 1 }}>Código que se generará</span>
          <CodeChip code={preview} />
        </div>
        <div className="dialog__actions" style={{ marginTop: 8 }}>
          <button type="button" className="btn btn--outline" onClick={onClose} data-close>
            Cancelar
          </button>
          <button type="submit" className="btn btn--primary">
            Generar código
          </button>
        </div>
      </form>
    </Dialog>
  )
}

// 25a · Grupos y lugares
export default function SchoolGroups() {
  const { toast, institution, submit, online } = useApp()
  const [params, setParams] = useSearchParams()
  const [grade, setGrade] = useState(() => Number(params.get('grado')) || 0)
  const groups = institution.groups
  const LICENSE = institution.license
  const generating = params.get('generar') === '1'

  const used = groups.filter((g) => g.status !== 'archived').reduce((n, g) => n + g.used, 0)
  const assigned = groups.filter((g) => g.status !== 'archived').reduce((n, g) => n + g.seats, 0)
  const free = Math.max(0, LICENSE.total - used)
  const rows = groups.filter((g) => !grade || g.grade === grade)

  const TITLES = {
    archive: (g) => `Archivar ${g.name}`,
    restore: (g) => `Restaurar ${g.name}`,
    renew: (g) => `Renovar código ${g.code}`,
    'add-seats': (g) => `${g.name}: 5 lugares más`,
  }
  const patch = (id, change, message) => {
    const g = groups.find((x) => x.id === id)
    const action = change.seats ? 'add-seats' : change.until ? 'renew' : change.status === 'archived' ? 'archive' : 'restore'
    submit('update-group', { groupId: id, action }, { title: TITLES[action](g), icon: '110' })
    toast(online ? message : `${message} Se enviará al reconectar.`)
  }

  const copy = async (code) => {
    try {
      await navigator.clipboard.writeText(code)
    } catch {
      /* sin portapapeles */
    }
    toast(`Código copiado: ${code}`)
  }

  return (
    <>
      <AppHeader title="Grupos y códigos" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Grupos y códigos</h2>
            <p className="page-sub">
              {groups.filter((g) => g.status !== 'archived').length} grupos · {used} de {LICENSE.total} lugares usados · {free} libres
            </p>
          </div>
          <button type="button" className="btn btn--primary" onClick={() => setParams({ generar: '1' })}>
            <Icon n="066" />
            Generar código
          </button>
        </div>

        <div className="pills" role="group" aria-label="Grado" style={{ marginBottom: 20 }}>
          {GRADES.map((g) => (
            <button key={g.key} type="button" className="pill" aria-pressed={grade === g.key} onClick={() => setGrade(g.key)}>
              {g.label}
            </button>
          ))}
        </div>

        <section className="card">
          <div className="table-wrap">
            <table className="table">
              <thead>
                <tr>
                  <th>Grupo</th>
                  <th>Docente</th>
                  <th>Lugares</th>
                  <th>Código</th>
                  <th>Vigencia</th>
                  <th>Estado</th>
                  <th style={{ textAlign: 'right' }}>Acciones</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((g) => (
                  <tr key={g.id} style={g.status === 'archived' ? { opacity: 0.6 } : undefined}>
                    <td className="cell-title">{g.name}</td>
                    <td>{g.teacher}</td>
                    <td>
                      {g.used} de {g.seats}
                    </td>
                    <td>
                      <span className="row" style={{ gap: 4 }}>
                        <CodeChip code={g.code} />
                        <button type="button" className="btn btn--ghost btn--sm" style={{ padding: '0 8px' }} aria-label={`Copiar ${g.code}`} onClick={() => copy(g.code)}>
                          <Icon n="083" />
                        </button>
                      </span>
                    </td>
                    <td>{g.until}</td>
                    <td>
                      <span className={`tag ${GROUP_STATUS[g.status].tag}`}>{GROUP_STATUS[g.status].label}</span>
                    </td>
                    <td style={{ textAlign: 'right', whiteSpace: 'nowrap' }}>
                      {g.pending && <span className="cell-sub">En cola…</span>}
                      {g.status === 'active' && !g.pending && (
                        <button type="button" className="btn btn--ghost btn--sm" onClick={() => patch(g.id, { status: 'archived' }, `${g.name} archivado. Sus ${g.seats - g.used} lugares libres vuelven a la licencia.`)}>
                          Archivar
                        </button>
                      )}
                      {g.status === 'archived' && (
                        <button type="button" className="btn btn--ghost btn--sm" onClick={() => patch(g.id, { status: 'active' }, `${g.name} activo otra vez.`)}>
                          Restaurar
                        </button>
                      )}
                      {g.status === 'expiring' && (
                        <button type="button" className="btn btn--primary btn--sm" onClick={() => patch(g.id, { status: 'active', until: '31 jul 2027' }, `Código ${g.code} renovado hasta el 31 jul 2027`)}>
                          Renovar
                        </button>
                      )}
                      {g.status === 'full' && (
                        <button
                          type="button"
                          className="btn btn--secondary btn--sm"
                          disabled={free < 5}
                          onClick={() => patch(g.id, { status: 'active', seats: g.seats + 5 }, `${g.name} ahora tiene ${g.seats + 5} lugares`)}
                        >
                          +5 lugares
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
        <p className="card__note" style={{ marginTop: 20 }}>
          Un código no puede repartir más lugares de los que quedan libres en la licencia. Los estudiantes lo escriben en la app móvil.
          {assigned > LICENSE.total ? '' : ''}
        </p>
      </div>

      {generating && (
        <GenerateCodeDialog
          free={free}
          teachers={institution.teachers}
          onClose={() => setParams({})}
          onCreate={(g) => {
            submit('create-group', { name: g.name, teacherId: g.teacher, seats: g.seats, until: g.until, code: g.code }, { title: `Generar código ${g.code} para ${g.name}`, icon: '106' })
            setParams({})
            toast(online ? `Código ${g.code} generado para ${g.name}` : `Código ${g.code} en cola: se activará al reconectar.`)
          }}
        />
      )}
    </>
  )
}
