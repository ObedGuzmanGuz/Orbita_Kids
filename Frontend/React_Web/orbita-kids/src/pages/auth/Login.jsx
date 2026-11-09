import { useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import Icon from '../../components/Icon'
import { readLoginNotice, useApp } from '../../state/AppState'
import { api } from '../../state/api'
import { TitleBar } from '../../layouts/AppShell'
import appIcon from '../../assets/img/app-icon.png'
import orbits from '../../assets/img/login-orbits.svg'
import { DEMO_PASSWORD, routeForAuthError } from './authFlow'
import './auth.css'

// 04 · Iniciar sesión (métodos, sin conexión, contraseña incorrecta). La contraseña se valida en el servidor.
export default function Login() {
  const { online, completeSignIn } = useApp()
  const navigate = useNavigate()
  const location = useLocation()
  const from = location.state?.from
  const [notice] = useState(readLoginNotice)
  const [user, setUser] = useState('')
  const [password, setPassword] = useState('')
  const [remember, setRemember] = useState(true)
  const [visible, setVisible] = useState(false)
  const [capsLock, setCapsLock] = useState(false)
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)

  const goProvider = (provider) => navigate(`/login/${provider}`, { state: { from } })

  const submit = async (e) => {
    e.preventDefault()
    if (!online || busy) return
    if (!user.trim() || !password) {
      setError('Escribe tu usuario y tu contraseña.')
      return
    }
    setBusy(true)
    setError('')
    try {
      const res = await api('/auth/login', { method: 'POST', body: { username: user.trim(), password, remember } })
      if (res.next === '2fa') {
        navigate('/login/verificacion', { state: { challenge: res.challenge, email: res.email, name: res.name, remember, from } })
        return
      }
      const session = await completeSignIn(res)
      navigate(from || `/${session.space}`, { replace: true })
    } catch (err) {
      const route = routeForAuthError(err)
      if (route) {
        navigate(route)
        return
      }
      if (err.code === 'invalid_credentials') {
        const left = err.body.remaining
        setError(`Usuario o contraseña incorrectos. Te ${left === 1 ? 'queda 1 intento' : `quedan ${left} intentos`}.`)
      } else {
        setError(err.offline ? 'No hay conexión con el servidor. Revisa tu Internet e intenta de nuevo.' : err.message)
      }
    } finally {
      setBusy(false)
    }
  }

  const checkCaps = (e) => setCapsLock(!!e.getModifierState?.('CapsLock'))

  return (
    <div className="login">
      <TitleBar title="Iniciar sesión" />
      <aside className="login__aside">
        <img src={orbits} alt="" className="login__art" />
        <Link to="/" className="site-brand login__brand">
          <img src={appIcon} alt="" className="site-brand__icon" />
          <span>Órbita Kids</span>
        </Link>
        <div className="login__copy">
          <h1>Los mismos grupos que en el teléfono, con espacio para trabajar.</h1>
          <p>Entra con la cuenta de tu escuela. Verás los mismos grupos y resultados que en la app móvil.</p>
          <ul className="login__perks">
            <li>
              <span className="dot" style={{ color: '#5fd0d9' }} />
              Grupos, actividades y resultados para docentes
            </li>
            <li>
              <span className="dot" style={{ color: 'var(--amber)' }} />
              Licencia, docentes y reportes para la dirección
            </li>
            <li>
              <span className="dot" style={{ color: 'var(--primary-soft)' }} />
              Sigue funcionando sin Internet
            </li>
          </ul>
        </div>
        <p className="login__foot">Proyecto académico, 2026</p>
      </aside>

      <main className="login__main" id="contenido">
        <div className="login__form">
          <Link to="/" className="back-link">
            <Icon n="017" />
            Volver al sitio
          </Link>
          <h1 className="login__title">Inicia sesión</h1>
          <p className="login__sub">Para docentes y direcciones de escuela.</p>

          {notice && (
            <div className="notice notice--warning" style={{ marginTop: 16, color: 'var(--warning)', fontWeight: 600 }} role="status">
              <Icon n="021" />
              {notice}
            </div>
          )}
          {!online && (
            <div className="notice notice--warning" style={{ marginTop: 16, color: 'var(--warning)', fontWeight: 600 }} role="alert">
              <Icon n="021" />
              Sin conexión. Para entrar por primera vez en este equipo necesitas Internet.
            </div>
          )}

          <div className="providers">
            <button type="button" className="provider" disabled={!online} onClick={() => goProvider('google')}>
              <Icon n="018" />
              <span>
                <strong>Continuar con Google</strong>
                <small>Google Workspace for Education</small>
              </span>
            </button>
            <button type="button" className="provider" disabled={!online} onClick={() => goProvider('microsoft')}>
              <Icon n="019" />
              <span>
                <strong>Continuar con Microsoft</strong>
                <small>Microsoft 365 y Entra ID</small>
              </span>
            </button>
            <button type="button" className="provider" disabled={!online} onClick={() => navigate('/login/institucion', { state: { from } })}>
              <Icon n="020" />
              <span>
                <strong>Entrar con mi escuela</strong>
                <small>Busca tu escuela</small>
              </span>
            </button>
          </div>

          <p className="login__divider">o con tu cuenta Órbita Kids</p>

          <form className="login__fields" onSubmit={submit} noValidate>
            <div className="field">
              <label className="field__label" htmlFor="login-user">
                Usuario o correo
              </label>
              <input
                id="login-user"
                className="input"
                placeholder="nombre.apellido"
                autoComplete="username"
                autoCapitalize="none"
                spellCheck={false}
                value={user}
                disabled={!online}
                onChange={(e) => {
                  setUser(e.target.value)
                  setError('')
                }}
              />
            </div>
            <div className="field">
              <label className="field__label" htmlFor="login-password">
                Contraseña
              </label>
              <div className="password-field">
                <input
                  id="login-password"
                  type={visible ? 'text' : 'password'}
                  className={`input${error ? ' input--error' : ''}`}
                  autoComplete="current-password"
                  value={password}
                  disabled={!online}
                  aria-invalid={!!error}
                  aria-describedby={error ? 'login-error' : capsLock ? 'login-caps' : undefined}
                  onKeyUp={checkCaps}
                  onKeyDown={checkCaps}
                  onChange={(e) => {
                    setPassword(e.target.value)
                    setError('')
                  }}
                />
                <button
                  type="button"
                  className="password-field__toggle"
                  onClick={() => setVisible((v) => !v)}
                  aria-label={visible ? 'Ocultar contraseña' : 'Mostrar contraseña'}
                  aria-pressed={visible}
                  disabled={!online}
                >
                  {visible ? 'Ocultar' : 'Mostrar'}
                </button>
              </div>
              {capsLock && !error && (
                <p className="field__hint" id="login-caps">
                  Bloq Mayús está activado.
                </p>
              )}
              {error && (
                <p className="field__error" id="login-error" role="alert">
                  <Icon n="022" />
                  {error}
                </p>
              )}
            </div>
            <div className="login__row">
              <label className="checkbox">
                <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} disabled={!online} />
                Recordar este equipo
              </label>
              <Link to="/recuperar" className="link">
                ¿Olvidaste tu contraseña?
              </Link>
            </div>
            <button type="submit" className="btn btn--primary btn--lg btn--block" disabled={!online || busy} aria-busy={busy}>
              {busy ? (
                <>
                  <span className="btn-spinner" aria-hidden />
                  Entrando…
                </>
              ) : (
                'Entrar'
              )}
            </button>
          </form>
          <p className="login__demo">
            Demostración: <code>ana.rios</code> o <code>laura.mendez</code> con la contraseña <code>{DEMO_PASSWORD}</code>.
          </p>

          <div className="login__extra">
            <p>¿Eres estudiante? Tus misiones están en la app móvil Órbita Kids.</p>
            <p>
              ¿Tu escuela todavía no está?{' '}
              <Link to="/contacto" className="link" style={{ fontSize: 14 }}>
                Solicitar información
              </Link>
            </p>
          </div>
        </div>
      </main>
    </div>
  )
}
