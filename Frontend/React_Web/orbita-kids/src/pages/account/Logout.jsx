import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import Icon from '../../components/Icon'
import CenteredPanel from '../../components/CenteredPanel'
import { useApp } from '../../state/AppState'

// 34 · Cerrar sesión (con cambios pendientes)
export default function Logout() {
  const { queue, signOut, installed, session, online, toast } = useApp()
  const navigate = useNavigate()
  const [busy, setBusy] = useState(false)
  const pending = queue.length

  const leave = async () => {
    setBusy(true)
    const result = await signOut()
    if (!result.serverClosed) toast('Sin conexión: el servidor cerrará la sesión en cuanto vuelva Internet.')
    navigate('/login', { replace: true })
  }

  return (
    <CenteredPanel icon="142" title="¿Cerrar sesión?" windowTitle="Cerrar sesión">
      {pending > 0 && (
        <div className="notice notice--warning" style={{ color: 'var(--warning)' }}>
          <Icon n="143" />
          <span>
            Tienes {pending} {pending === 1 ? 'cambio' : 'cambios'} sin sincronizar. Quedan protegidos en este equipo y se envían la próxima vez que entres
            con esta cuenta.
          </span>
        </div>
      )}
      <ul className="panel__list">
        <li>Se cierra la sesión en esta app.</li>
        <li>{online ? 'También se cierra en el servidor.' : 'El servidor la cerrará en cuanto vuelva Internet.'}</li>
        <li>
          {pending > 0
            ? 'Los datos de la cuenta quedan cifrados en este equipo; sin volver a entrar nadie puede leerlos.'
            : 'Se borran de este equipo los datos de la cuenta.'}
        </li>
        <li>{installed ? 'La app sigue instalada; la próxima vez pedirá iniciar sesión.' : 'La próxima vez que abras Órbita Kids te pedirá iniciar sesión.'}</li>
      </ul>
      <div className="panel__actions">
        <button type="button" className="btn btn--primary btn--lg" onClick={leave} disabled={busy}>
          {busy ? 'Cerrando…' : 'Cerrar sesión'}
        </button>
        <button type="button" className="btn btn--lg" style={{ flex: '0 0 auto', color: 'var(--ink)' }} onClick={() => (session ? navigate(-1) : navigate('/'))}>
          Quedarme
        </button>
      </div>
    </CenteredPanel>
  )
}
