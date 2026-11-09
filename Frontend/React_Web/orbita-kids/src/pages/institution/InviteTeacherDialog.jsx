import { useState } from 'react'
import Icon from '../../components/Icon'
import Dialog from '../../components/Dialog'
import { useApp } from '../../state/AppState'

const DOMAIN = '@escuela.example'

// 24b · Invitar docente
export default function InviteTeacherDialog({ onClose }) {
  const { online, submit: submitChange, toast, institution } = useApp()
  const OPEN_GROUPS = institution.openGroups
  const [email, setEmail] = useState('')
  const [name, setName] = useState('')
  const [groups, setGroups] = useState([])
  const [error, setError] = useState('')

  const toggle = (g) => setGroups((list) => (list.includes(g) ? list.filter((x) => x !== g) : [...list, g]))

  const submit = (e) => {
    e.preventDefault()
    const value = email.trim().toLowerCase()
    if (!value.endsWith(DOMAIN) || value.length <= DOMAIN.length) {
      setError(`Escribe un correo que termine en ${DOMAIN}`)
      return
    }
    if (institution.teachers.some((t) => t.email === value)) {
      setError('Esa persona ya está en la lista de docentes.')
      return
    }
    submitChange('invite-teacher', { email: value, name: name.trim(), groups }, { title: `Invitar a ${value}`, icon: '107' })
    toast(online ? `Invitación enviada a ${value}` : 'Sin conexión: la invitación se enviará al reconectar.')
    onClose()
  }

  return (
    <Dialog title="Invitar docente" onClose={onClose}>
      <p className="dialog__text" style={{ marginTop: 4 }}>
        Recibirá un correo con un enlace válido por 7 días.
      </p>
      <form onSubmit={submit} noValidate className="invite-form">
        <div className="field">
          <label className="field__label" htmlFor="invite-email">
            Correo de la escuela
          </label>
          <span className={`input${error ? ' input--error' : ''}`}>
            <Icon n="031" />
            <input
              id="invite-email"
              type="email"
              placeholder={`nombre${DOMAIN}`}
              value={email}
              onChange={(e) => {
                setEmail(e.target.value)
                setError('')
              }}
              aria-invalid={!!error}
              aria-describedby="invite-email-hint"
            />
          </span>
          <p className={error ? 'field__error' : 'field__hint'} id="invite-email-hint">
            {error || `Solo correos ${DOMAIN}`}
          </p>
        </div>
        <div className="field">
          <label className="field__label" htmlFor="invite-name">
            Nombre
          </label>
          <input id="invite-name" className="input" placeholder="Nombre y apellido" value={name} onChange={(e) => setName(e.target.value)} />
        </div>
        <fieldset className="field" style={{ border: 0, padding: 0, margin: 0 }}>
          <legend className="field__label" style={{ padding: 0 }}>
            Grupos
          </legend>
          <div className="pills" style={{ marginTop: 6 }}>
            {OPEN_GROUPS.map((g) => (
              <button key={g} type="button" className="pill" aria-pressed={groups.includes(g)} onClick={() => toggle(g)}>
                {g}
              </button>
            ))}
          </div>
        </fieldset>
        <div className="dialog__actions">
          <button type="button" className="btn btn--outline" onClick={onClose} data-close>
            Cancelar
          </button>
          <button type="submit" className="btn btn--primary">
            <Icon n="093" />
            Enviar invitación
          </button>
        </div>
      </form>
    </Dialog>
  )
}
