import { useState } from 'react'
import { Navigate, useLocation, useNavigate, useParams } from 'react-router-dom'
import CenteredPanel from '../../components/CenteredPanel'
import { useApp } from '../../state/AppState'
import { api } from '../../state/api'
import './auth.css'

// 07a–07d · Estados de acceso
const STATES = {
  estudiante: {
    icon: '027',
    title: 'Esta app es para docentes e instituciones',
    text: 'Los estudiantes juegan sus misiones en la app móvil Órbita Kids, en el teléfono o la tableta de la escuela. Ahí está tu progreso.',
    primary: { label: 'Volver al inicio de sesión', to: '/login' },
    secondary: { label: 'Cómo instalar la app móvil', toast: 'Busca «Órbita Kids» en la tienda de apps del teléfono o la tableta.' },
    code: 'AUTH_ROLE_STUDENT',
  },
  'sin-rol': {
    icon: '028',
    title: 'Tu cuenta aún no tiene un rol',
    text: 'Entraste correctamente, pero ninguna institución te ha dado acceso como docente. Pide a tu dirección que te invite o envía una solicitud.',
    primary: { label: 'Solicitar acceso', request: true, to: '/acceso/pendiente' },
    secondary: { label: 'Volver', to: '/login' },
    code: 'AUTH_NO_ROLE',
  },
  pendiente: {
    icon: '029',
    title: 'Tu solicitud está en revisión',
    text: 'La dirección de Primaria Demo Órbita debe aprobarla. Te avisaremos por correo. No necesitas volver a pedirla.',
    primary: { label: 'Entendido', to: '/' },
    secondary: { label: 'Ayuda', to: '/#preguntas' },
    code: 'AUTH_PENDING_APPROVAL',
  },
  bloqueada: {
    icon: '030',
    title: 'Cuenta bloqueada 15 minutos',
    text: 'Hubo 3 intentos con contraseña incorrecta. Espera 15 minutos o recupera tu contraseña. Los métodos de Google y Microsoft siguen disponibles.',
    primary: { label: 'Recuperar contraseña', to: '/recuperar' },
    secondary: { label: 'Volver', to: '/login' },
    code: 'AUTH_LOCKED_3_ATTEMPTS',
  },
}

export default function AccessState() {
  const { state } = useParams()
  const navigate = useNavigate()
  const location = useLocation()
  const { toast } = useApp()
  const [busy, setBusy] = useState(false)
  const s = STATES[state]
  if (!s) return <Navigate to="/login" replace />

  // «Solicitar acceso» crea la solicitud en el servidor; la dirección la ve en «Docentes».
  const request = async (action) => {
    const identity = location.state?.identity
    if (!identity) {
      toast('Vuelve a entrar con tu cuenta de Google o Microsoft para pedir acceso.')
      navigate('/login')
      return
    }
    setBusy(true)
    try {
      await api('/auth/access-request', { method: 'POST', body: { identity } })
      navigate(action.to, { replace: true })
    } catch (err) {
      toast(err.offline ? 'Necesitas conexión para enviar la solicitud.' : err.message)
    } finally {
      setBusy(false)
    }
  }

  const run = (action) => (action.request ? request(action) : action.toast ? toast(action.toast) : navigate(action.to))

  return (
    <CenteredPanel icon={s.icon} iconBg="transparent" title={s.title} text={s.text} windowTitle="Estados de acceso">
      <div className="panel__actions panel__actions--stack">
        <button type="button" className="btn btn--primary btn--lg" onClick={() => run(s.primary)} disabled={busy}>
          {busy ? 'Enviando…' : s.primary.label}
        </button>
        <button type="button" className="btn btn--outline btn--lg" onClick={() => run(s.secondary)}>
          {s.secondary.label}
        </button>
      </div>
      <p className="state-code">
        Código: <code>{s.code}</code>
      </p>
    </CenteredPanel>
  )
}
