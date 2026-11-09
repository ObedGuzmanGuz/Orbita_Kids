import { useState } from 'react'
import Icon from '../../components/Icon'
import CenteredPanel from '../../components/CenteredPanel'
import { useApp } from '../../state/AppState'
import { api } from '../../state/api'
import './auth.css'

// 07e · Recuperar contraseña
export default function RecoverPassword() {
  const { online } = useApp()
  const [email, setEmail] = useState('')
  const [sent, setSent] = useState(false)
  const [error, setError] = useState('')

  const submit = async (e) => {
    e.preventDefault()
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
      setError('Escribe un correo válido.')
      return
    }
    try {
      // El servidor responde igual exista o no la cuenta.
      await api('/auth/recover', { method: 'POST', body: { email: email.trim() } })
    } catch (err) {
      setError(err.offline ? 'Necesitas conexión para pedir el correo de recuperación.' : err.message)
      return
    }
    setSent(true)
  }

  return (
    <CenteredPanel back={{ to: '/login', label: 'Inicio de sesión' }} title="Recuperar contraseña" windowTitle="Recuperar contraseña">
      <div className="panel--left">
        <p className="panel__text" style={{ textAlign: 'center', marginInline: 'auto' }}>
          Solo para cuentas Órbita Kids. Si entras con Google o Microsoft, recupera tu contraseña con ese proveedor.
        </p>
        {sent ? (
          <div className="notice notice--success" role="status">
            <span>
              <strong className="notice__title">Revisa tu correo.</strong>{' '}
              <span className="notice__text">Si {email.trim()} tiene una cuenta, te enviamos instrucciones para crear una contraseña nueva.</span>
            </span>
          </div>
        ) : (
          <form onSubmit={submit} noValidate style={{ marginTop: 18 }}>
            <div className="field">
              <label className="field__label" htmlFor="recover-email">
                Correo de tu cuenta
              </label>
              <span className={`input${error ? ' input--error' : ''}`}>
                <Icon n="031" />
                <input
                  id="recover-email"
                  type="email"
                  placeholder="tu@escuela.example"
                  value={email}
                  onChange={(e) => {
                    setEmail(e.target.value)
                    setError('')
                  }}
                />
              </span>
              {error && <p className="field__error">{error}</p>}
            </div>
            <button type="submit" className="btn btn--primary btn--lg btn--block" style={{ marginTop: 18 }} disabled={!online}>
              Enviar instrucciones
            </button>
            {!online && <p className="panel__note">Necesitas conexión para enviar las instrucciones.</p>}
          </form>
        )}
      </div>
    </CenteredPanel>
  )
}
