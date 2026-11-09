import { useEffect, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import Icon from '../../components/Icon'
import Dialog from '../../components/Dialog'
import CenteredPanel from '../../components/CenteredPanel'
import { useApp } from '../../state/AppState'
import { api } from '../../state/api'
import './auth.css'

// Invitación de demostración que ya existe en la base de datos (la de Raúl Domínguez).
const DEMO_TOKEN = 'inv-raul-demo'

// 10 · Aceptar invitación (enlace del correo)
export default function Invitation() {
  const navigate = useNavigate()
  const [params] = useSearchParams()
  const token = params.get('token') || DEMO_TOKEN
  const { online, completeSignIn, toast } = useApp()
  const [invite, setInvite] = useState(null)
  const [failure, setFailure] = useState('')
  const [reject, setReject] = useState(false)
  const [creating, setCreating] = useState(false)
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)

  useEffect(() => {
    let cancelled = false
    api(`/invitations/${encodeURIComponent(token)}`)
      .then((data) => !cancelled && setInvite(data))
      .catch((err) => !cancelled && setFailure(err.offline ? 'Necesitas conexión para abrir la invitación.' : err.message))
    return () => {
      cancelled = true
    }
  }, [token, online])

  const accept = async (method) => {
    if (!online) return toast('Necesitas conexión para aceptar la invitación.')
    if (method === 'password' && password.length < 8) {
      setError('La contraseña necesita al menos 8 caracteres.')
      return
    }
    setBusy(true)
    try {
      const res = await api(`/invitations/${encodeURIComponent(token)}/accept`, { method: 'POST', body: { method, password: method === 'password' ? password : undefined } })
      await completeSignIn(res, 'docente')
      toast(`Invitación aceptada. ¡Te damos la bienvenida a ${invite.school}!`)
      navigate('/docente', { replace: true })
    } catch (err) {
      if (method === 'password') setError(err.message)
      else toast(err.message)
    } finally {
      setBusy(false)
    }
  }

  const decline = async () => {
    try {
      await api(`/invitations/${encodeURIComponent(token)}/reject`, { method: 'POST' })
      toast('Rechazaste la invitación.')
      navigate('/')
    } catch (err) {
      toast(err.offline ? 'Necesitas conexión para rechazar la invitación.' : err.message)
    }
  }

  if (!invite) {
    return (
      <CenteredPanel icon="035" iconBg="#fbefd9" title={failure ? 'No pudimos abrir la invitación' : 'Abriendo invitación…'} text={failure || 'Un momento.'} windowTitle="Invitación">
        {failure && (
          <div className="panel__actions">
            <button type="button" className="btn btn--primary btn--lg" onClick={() => navigate('/login')}>
              Ir a iniciar sesión
            </button>
          </div>
        )}
      </CenteredPanel>
    )
  }

  const inviter = invite.invitedBy.split(' · ')[0]

  return (
    <CenteredPanel width={820} windowTitle="Invitación">
      <div className="panel--left">
        <div className="panel-head">
          <span className="panel__icon" style={{ margin: 0, background: '#fbefd9' }}>
            <Icon n="035" />
          </span>
          <div>
            <p className="panel__eyebrow" style={{ color: 'var(--muted)' }}>INVITACIÓN</p>
            <h1 className="panel__title">{invite.school} te invita como docente</h1>
          </div>
        </div>

        <div className="invite-card">
          <p className="row" style={{ flexWrap: 'wrap', gap: 8 }}>
            <strong style={{ color: 'var(--ink)' }}>{invite.name}</strong>
            <span>{invite.email}</span>
            <span className="tag tag--warning" style={{ marginLeft: 'auto' }}>Vence el {invite.expires}</span>
          </p>
          <p>Invitó: {invite.invitedBy}</p>
          {invite.groups.length > 0 && (
            <p className="row" style={{ gap: 8, flexWrap: 'wrap' }}>
              <strong style={{ color: 'var(--ink)' }}>Grupos:</strong>
              {invite.groups.map((g) => (
                <span key={g} className="tag tag--teal">
                  {g}
                </span>
              ))}
            </p>
          )}
        </div>

        <p className="login__sub" style={{ marginTop: 18 }}>
          Elige cómo vas a entrar. Debe ser con el correo invitado.
        </p>
        <div className="invite-actions">
          <button type="button" className="provider" onClick={() => accept('google')} disabled={busy}>
            <Icon n="018" />
            Aceptar con Google
          </button>
          <button type="button" className="provider" onClick={() => accept('microsoft')} disabled={busy}>
            <Icon n="019" />
            Aceptar con Microsoft
          </button>
          <button type="button" className="provider" onClick={() => setCreating(true)} disabled={busy}>
            <Icon n="036" />
            Crear cuenta Órbita Kids
          </button>
        </div>
        <p className="panel__note">
          Al aceptar, la institución verá tu nombre, correo y último acceso. Los datos de tus estudiantes solo los ves tú y la dirección de forma agregada.
        </p>
        <button type="button" className="btn btn--ghost btn--sm" style={{ color: 'var(--danger)', marginTop: 12, paddingLeft: 2 }} onClick={() => setReject(true)}>
          Rechazar invitación
        </button>
      </div>

      {creating && (
        <Dialog title="Crea tu contraseña" onClose={() => setCreating(false)}>
          <form
            onSubmit={(e) => {
              e.preventDefault()
              accept('password')
            }}
            noValidate
          >
            <p className="dialog__text">Entrarás con {invite.email} y esta contraseña. Usa al menos 8 caracteres.</p>
            <div className="field" style={{ marginTop: 14 }}>
              <label className="field__label" htmlFor="invite-password">
                Contraseña nueva
              </label>
              <input
                id="invite-password"
                type="password"
                className={`input${error ? ' input--error' : ''}`}
                autoComplete="new-password"
                value={password}
                autoFocus
                aria-invalid={!!error}
                aria-describedby={error ? 'invite-password-error' : undefined}
                onChange={(e) => {
                  setPassword(e.target.value)
                  setError('')
                }}
              />
              {error && (
                <p className="field__error" id="invite-password-error" role="alert">
                  {error}
                </p>
              )}
            </div>
            <div className="dialog__actions">
              <button type="button" className="btn btn--outline" onClick={() => setCreating(false)} data-close>
                Cancelar
              </button>
              <button type="submit" className="btn btn--primary" disabled={busy}>
                {busy ? 'Creando…' : 'Crear cuenta y entrar'}
              </button>
            </div>
          </form>
        </Dialog>
      )}

      {reject && (
        <Dialog title="¿Rechazar la invitación?" onClose={() => setReject(false)}>
          <p className="dialog__text">Le avisaremos a {inviter}. Si cambias de opinión, pídele una invitación nueva.</p>
          <div className="dialog__actions">
            <button type="button" className="btn btn--outline" onClick={() => setReject(false)} data-close>
              Cancelar
            </button>
            <button type="button" className="btn btn--danger" onClick={decline}>
              Rechazar
            </button>
          </div>
        </Dialog>
      )}
    </CenteredPanel>
  )
}
