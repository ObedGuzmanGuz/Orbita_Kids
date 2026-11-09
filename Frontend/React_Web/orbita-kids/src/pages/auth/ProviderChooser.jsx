import { useState } from 'react'
import { useLocation, useNavigate, useParams } from 'react-router-dom'
import Icon from '../../components/Icon'
import { useApp } from '../../state/AppState'
import { api } from '../../state/api'
import { IDP_ACCOUNTS, routeForAuthError } from './authFlow'
import '../../components/centered-panel.css'
import './auth.css'

// 05 · Proveedor de identidad (simulado): elegir identidad de Google o Microsoft
export default function ProviderChooser() {
  const { provider } = useParams()
  const { completeSignIn, toast } = useApp()
  const navigate = useNavigate()
  const location = useLocation()
  const from = location.state?.from
  const isMicrosoft = provider === 'microsoft'
  const [busy, setBusy] = useState(null)

  const pick = async (account) => {
    setBusy(account.email)
    try {
      const res = await api('/auth/sso', { method: 'POST', body: { provider: isMicrosoft ? 'microsoft' : 'google', email: account.email } })
      if (res.next === '2fa') {
        navigate('/login/verificacion', { state: { challenge: res.challenge, email: res.email, name: res.name, remember: true, from } })
        return
      }
      const session = await completeSignIn(res)
      navigate(from || `/${session.space}`, { replace: true })
    } catch (err) {
      const route = routeForAuthError(err)
      if (route) navigate(route, { state: err.code === 'no_role' ? { identity: err.body.identity, email: account.email } : undefined })
      else toast(err.offline ? 'No hay conexión con el servidor.' : err.message)
    } finally {
      setBusy(null)
    }
  }

  return (
    <div className="standalone-page">
      <main className="idp" id="contenido">
        <p className="idp__sim">
          <Icon n="023" />
          Simulación del proveedor. Órbita Kids nunca recibe tu contraseña.
        </p>
        <p className="idp__provider">
          <Icon n={isMicrosoft ? '019' : '024'} style={isMicrosoft ? undefined : { width: 24, height: 24 }} />
          Iniciar sesión con {isMicrosoft ? 'Microsoft' : 'Google'}
        </p>
        <h1>Elige una cuenta</h1>
        <p className="idp__to">
          para continuar a <strong>Órbita Kids</strong> (auth.orbitakids.example)
        </p>
        <div className="idp__accounts">
          {IDP_ACCOUNTS.map((a) => (
            <button key={a.email} type="button" className="idp__account" onClick={() => pick(a)} disabled={!!busy} aria-busy={busy === a.email}>
              <span className="idp__avatar">{a.letter}</span>
              <span>
                <strong>{a.email}</strong>
                <small>{busy === a.email ? 'Conectando…' : a.note}</small>
              </span>
            </button>
          ))}
        </div>
        <div className="idp__foot">
          <span>Keycloak · OIDC con PKCE</span>
          <button type="button" className="btn btn--sm" style={{ color: 'var(--ink)' }} onClick={() => navigate('/login')}>
            Cancelar
          </button>
        </div>
      </main>
    </div>
  )
}
