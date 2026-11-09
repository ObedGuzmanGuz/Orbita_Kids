import { useState } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import Icon from '../../components/Icon'
import Dialog from '../../components/Dialog'
import { AppHeader } from '../../layouts/AppShell'
import { useApp } from '../../state/AppState'
import './teacher.css'

const MODES = [
  { key: 'visual', title: 'Sumas con apoyo visual', text: 'Objetos para contar y teclado' },
  { key: 'select', title: 'Selección de respuestas', text: '4 opciones grandes' },
  { key: 'both', title: 'Visual + selección', text: 'Combina las dos' },
]

const LEVELS = [
  { value: 1, label: 'Nivel 1 · Despegue', hint: 'Sumas con resultado hasta 5.' },
  { value: 2, label: 'Nivel 2 · Órbita baja', hint: 'Sumas con resultado hasta 10.' },
  { value: 3, label: 'Nivel 3 · Órbita media', hint: 'Sumas con resultado hasta 20.' },
  { value: 4, label: 'Nivel 4 · Órbita alta', hint: 'Sumas que pasan de 10, con apoyo para agrupar.' },
]

const newActivityId = () => `act-${Math.random().toString(36).slice(2, 10)}`

function inAWeek() {
  const d = new Date(Date.now() + 7 * 86400000)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

function shortDate(iso) {
  if (!iso) return 'sin fecha'
  const d = new Date(`${iso}T12:00:00`)
  return d.toLocaleDateString('es-MX', { day: 'numeric', month: 'short' }).replace('.', '')
}

export default function CreateActivity() {
  const [params] = useSearchParams()
  const navigate = useNavigate()
  const { online, submit, toast, teacher } = useApp()
  const activeGroups = teacher.groups.filter((g) => g.status === 'active')
  // ?borrador=<id> retoma un borrador guardado en la cuenta.
  const draft = teacher.activities.find((a) => a.id === params.get('borrador') && a.status === 'draft')

  const [activityId] = useState(() => draft?.id || newActivityId())
  const [form, setForm] = useState(() =>
    draft
      ? {
          name: draft.name === 'Borrador sin nombre' ? '' : draft.name,
          group: draft.groupId,
          recipients: draft.recipients,
          mode: draft.mode,
          level: draft.level,
          count: draft.count,
          due: draft.dueIso || inAWeek(),
          instructions: draft.instructions,
        }
      : {
          name: '',
          group: params.get('grupo') || activeGroups[0]?.id || '',
          recipients: 'all',
          mode: 'visual',
          level: 2,
          count: 8,
          due: inAWeek(),
          instructions: 'Cuenta los objetos antes de responder.',
        },
  )
  const [error, setError] = useState('')
  const [confirm, setConfirm] = useState(false)

  const set = (key) => (value) => setForm((f) => ({ ...f, [key]: value }))
  const group = activeGroups.find((g) => g.id === form.group) || activeGroups[0]
  const level = LEVELS.find((l) => l.value === Number(form.level)) || LEVELS[1]
  const mode = MODES.find((m) => m.key === form.mode)

  const tryPublish = () => {
    if (form.name.trim().replace(/[^\p{L}]/gu, '').length < 3) {
      setError('Escribe un nombre de al menos 3 letras.')
      document.getElementById('activity-name')?.focus()
      return
    }
    setError('')
    setConfirm(true)
  }

  const payload = () => ({
    activityId,
    groupId: group.id,
    name: form.name.trim(),
    mode: form.mode,
    level: Number(form.level),
    count: form.count,
    due: form.due,
    instructions: form.instructions,
    recipients: form.recipients,
  })

  const publish = () => {
    setConfirm(false)
    submit('publish-activity', payload(), { title: `Publicar «${form.name.trim()}»`, icon: '093' })
    toast(online ? `«${form.name.trim()}» publicada para ${group.name}` : 'Sin conexión: la publicación quedó en cola y se enviará al reconectar.')
    navigate('/docente/actividades')
  }

  const saveDraft = () => {
    if (!group) return
    submit('save-draft', payload(), { title: `Borrador «${form.name.trim() || 'sin nombre'}»`, icon: '133' })
    toast(online ? 'Borrador guardado en tu cuenta' : 'Borrador guardado en este equipo. Se subirá a tu cuenta al reconectar.')
  }

  if (!group) {
    return (
      <>
        <AppHeader title="Crear actividad" eyebrow="Actividades" />
        <div className="page">
          <section className="card empty-state">
            <h3 className="card__title">Necesitas un grupo activo</h3>
            <p className="card__note">Las actividades se publican para un grupo. Pide uno a la dirección desde «Mis grupos».</p>
            <Link to="/docente/grupos" className="btn btn--primary">
              Ir a Mis grupos
            </Link>
          </section>
        </div>
      </>
    )
  }

  return (
    <>
      <AppHeader title="Crear actividad" eyebrow="Actividades" />
      <div className="page">
        <Link to="/docente/actividades" className="back-link">
          <Icon n="017" />
          Actividades
        </Link>
        <div className="page-head" style={{ marginTop: 2 }}>
          <div className="page-head__text">
            <h2 className="page-title">Crear actividad</h2>
            <p className="page-sub">Se publica en la app móvil del grupo.</p>
          </div>
        </div>

        <div className="create-grid">
          <form
            className="card create-form"
            onSubmit={(e) => {
              e.preventDefault()
              tryPublish()
            }}
            noValidate
          >
            <div className="field">
              <label className="field__label" htmlFor="activity-name">
                Nombre de la actividad
              </label>
              <input
                id="activity-name"
                className={`input${error ? ' input--error' : ''}`}
                placeholder="Ej. Estrellas hasta 10"
                value={form.name}
                onChange={(e) => {
                  set('name')(e.target.value)
                  if (error) setError('')
                }}
                aria-invalid={!!error}
                aria-describedby={error ? 'activity-name-error' : undefined}
              />
              {error && (
                <p className="field__error" id="activity-name-error">
                  {error}
                </p>
              )}
            </div>

            <div className="create-row">
              <div className="field">
                <label className="field__label" htmlFor="activity-group">
                  Grupo
                </label>
                <select id="activity-group" className="input" value={form.group} onChange={(e) => set('group')(e.target.value)}>
                  {activeGroups.map((g) => (
                    <option key={g.id} value={g.id}>
                      {g.name} · {g.students} estudiantes
                    </option>
                  ))}
                </select>
              </div>
              <fieldset className="field">
                <legend className="field__label">Destinatarios</legend>
                <div className="pills" style={{ marginTop: 6 }}>
                  <button type="button" className="pill" aria-pressed={form.recipients === 'all'} onClick={() => set('recipients')('all')}>
                    Todo el grupo
                  </button>
                  <button type="button" className="pill" aria-pressed={form.recipients === 'some'} onClick={() => set('recipients')('some')}>
                    Algunos estudiantes
                  </button>
                </div>
              </fieldset>
            </div>

            <fieldset className="field">
              <legend className="field__label">Modalidad</legend>
              <div className="mode-options" role="radiogroup">
                {MODES.map((m) => (
                  <button key={m.key} type="button" role="radio" aria-checked={form.mode === m.key} className="mode-option" onClick={() => set('mode')(m.key)}>
                    <strong>{m.title}</strong>
                    <span>{m.text}</span>
                  </button>
                ))}
              </div>
            </fieldset>

            <div className="create-row create-row--3">
              <div className="field">
                <label className="field__label" htmlFor="activity-level">
                  Nivel
                </label>
                <select id="activity-level" className="input" value={form.level} onChange={(e) => set('level')(Number(e.target.value))}>
                  {LEVELS.map((l) => (
                    <option key={l.value} value={l.value}>
                      {l.label}
                    </option>
                  ))}
                </select>
                <p className="field__hint" style={{ fontWeight: 600 }}>{level.hint}</p>
              </div>
              <div className="field">
                <span className="field__label" id="count-label">
                  Ejercicios
                </span>
                <div className="stepper" role="group" aria-labelledby="count-label">
                  <button type="button" aria-label="Menos ejercicios" onClick={() => set('count')(Math.max(3, form.count - 1))}>
                    −
                  </button>
                  <output aria-live="polite">{form.count}</output>
                  <button type="button" aria-label="Más ejercicios" onClick={() => set('count')(Math.min(20, form.count + 1))}>
                    +
                  </button>
                </div>
              </div>
              <div className="field">
                <label className="field__label" htmlFor="activity-due">
                  Entrega
                </label>
                <input id="activity-due" type="date" className="input" value={form.due} onChange={(e) => set('due')(e.target.value)} />
              </div>
            </div>

            <div className="field">
              <label className="field__label" htmlFor="activity-instructions">
                Instrucciones para el estudiante
              </label>
              <textarea id="activity-instructions" className="input" rows={3} value={form.instructions} onChange={(e) => set('instructions')(e.target.value)} />
            </div>
          </form>

          <div className="create-side">
            <section className="card">
              <h3 className="card__title" style={{ marginBottom: 16 }}>
                Vista previa en la app del estudiante
              </h3>
              <div className="phone-preview">
                <div className="phone-preview__screen">
                  <p className="phone-preview__eyebrow">DE MI MAESTRA</p>
                  <p className="phone-preview__title">{form.name.trim() || 'Nombre de la actividad'}</p>
                  <div className="phone-preview__tags">
                    <span className="tag tag--primary">{mode.title}</span>
                    <span className="tag tag--warning">Nivel {level.value}</span>
                    <span className="tag tag--success">Disponible sin Internet</span>
                  </div>
                  <p className="phone-preview__meta">
                    {form.count} ejercicios · entrega {shortDate(form.due)}
                  </p>
                  <span className="phone-preview__cta">Empezar</span>
                </div>
              </div>
              <p className="card__note" style={{ marginTop: 14 }}>
                La verán {form.recipients === 'all' ? `${group.students} estudiantes` : 'los estudiantes que elijas'} de {group.name}.
              </p>
            </section>
            <section className="card publish-card">
              <button type="button" className="btn btn--primary btn--lg btn--block" onClick={tryPublish}>
                <Icon n="093" />
                Publicar
              </button>
              <button type="button" className="btn btn--block publish-card__draft" onClick={saveDraft}>
                Guardar borrador
              </button>
              <p className="card__note">Publicar pide confirmación. El borrador se guarda en este equipo y en tu cuenta.</p>
            </section>
          </div>
        </div>
      </div>

      {confirm && (
        <Dialog title={`¿Publicar «${form.name.trim()}»?`} onClose={() => setConfirm(false)}>
          <p className="dialog__text">
            {group.students} estudiantes de {group.name} la verán en la app móvil al sincronizar. Podrás cerrarla cuando quieras.
          </p>
          <div className="dialog__actions">
            <button type="button" className="btn btn--outline" onClick={() => setConfirm(false)} data-close>
              Cancelar
            </button>
            <button type="button" className="btn btn--primary" onClick={publish}>
              <Icon n="093" />
              Publicar
            </button>
          </div>
        </Dialog>
      )}
    </>
  )
}
