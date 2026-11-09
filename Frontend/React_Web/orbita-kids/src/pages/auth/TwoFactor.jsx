import { useEffect, useRef, useState } from 'react'
import { Link, Navigate, useLocation, useNavigate } from 'react-router-dom'
import Icon from '../../components/Icon'
import CenteredPanel from '../../components/CenteredPanel'
import { useApp } from '../../state/AppState'
import { api } from '../../state/api'
import { DEMO_OTP, routeForAuthError } from './authFlow'
import './auth.css'

// 08a/08b · Verificación en dos pasos. El código lo comprueba el servidor.
export default function TwoFactor() {
  const location = useLocation()
  const navigate = useNavigate()
  const { completeSignIn, toast } = useApp()
  const state = location.state || {}
  const [digits, setDigits] = useState(['', '', '', '', '', ''])
  const [error, setError] = useState('')
  const [remember, setRemember] = useState(!!state.remember)
  const [wait, setWait] = useState(28)
  const [busy, setBusy] = useState(false)
  const refs = useRef([])

  useEffect(() => {
    if (wait <= 0) return
    const t = setTimeout(() => setWait((w) => w - 1), 1000)
    return () => clearTimeout(t)
  }, [wait])

  if (!state.challenge) return <Navigate to="/login" replace />

  const setDigit = (i, value) => {
    const clean = value.replace(/\D/g, '')
    if (clean.length > 1) {
      // Pegar el código completo
      const next = clean.slice(0, 6).split('')
      setDigits((d) => d.map((_, k) => next[k] ?? ''))
      refs.current[Math.min(5, next.length)]?.focus()
      return
    }
    setDigits((d) => d.map((x, k) => (k === i ? clean : x)))
    setError('')
    if (clean && i < 5) refs.current[i + 1]?.focus()
  }

  const verify = async (e) => {
    e.preventDefault()
    const code = digits.join('')
    if (code.length < 6) {
      setError('Escribe los 6 dígitos.')
      return
    }
    setBusy(true)
    try {
      const res = await api('/auth/verify', { method: 'POST', body: { challenge: state.challenge, code, remember } })
      if (res.user.spaces.length > 1) {
        await completeSignIn(res)
        navigate('/espacio', { state: { spaces: res.spaces, from: state.from }, replace: true })
      } else {
        const session = await completeSignIn(res)
        navigate(state.from || `/${session.space}`, { replace: true })
      }
    } catch (err) {
      const route = routeForAuthError(err)
      if (route) return navigate(route, { replace: true })
      if (err.code === 'invalid_code') {
        const left = err.body.remaining
        setError(`El código no es correcto. Te ${left === 1 ? 'queda 1 intento' : `quedan ${left} intentos`}.`)
        setDigits(['', '', '', '', '', ''])
        refs.current[0]?.focus()
      } else if (err.code === 'expired') {
        toast(err.message)
        navigate('/login', { replace: true })
      } else {
        setError(err.offline ? 'No hay conexión con el servidor. Intenta de nuevo.' : err.message)
      }
    } finally {
      setBusy(false)
    }
  }

  const resend = async () => {
    try {
      await api('/auth/resend', { method: 'POST', body: { challenge: state.challenge } })
      setWait(28)
      toast('Te enviamos un código nuevo.')
    } catch (err) {
      toast(err.message)
    }
  }

  return (
    <CenteredPanel
      icon="032"
      iconBg="var(--warning-bg)"
      title="Verificación en dos pasos"
      text={`Escribe el código de 6 dígitos de tu app de autenticación. También lo enviamos a ${state.email || 'tu correo'}.`}
      width={560}
      windowTitle="Verificación en dos pasos"
    >
      <form onSubmit={verify} noValidate>
        <div className={`otp${error ? ' is-error' : ''}`} role="group" aria-label="Código de 6 dígitos">
          {digits.map((d, i) => (
            <input
              key={i}
              ref={(el) => (refs.current[i] = el)}
              inputMode="numeric"
              autoComplete={i === 0 ? 'one-time-code' : 'off'}
              maxLength={i === 0 ? 6 : 1}
              value={d}
              aria-label={`Dígito ${i + 1}`}
              autoFocus={i === 0}
              disabled={busy}
              onChange={(e) => setDigit(i, e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Backspace' && !d && i > 0) refs.current[i - 1]?.focus()
              }}
            />
          ))}
        </div>
        {error && (
          <p className="field__error" style={{ marginTop: 10, textAlign: 'left' }} role="alert">
            <Icon n="022" />
            {error}
          </p>
        )}
        <label className="checkbox" style={{ marginTop: 16 }}>
          <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} />
          Recordar este equipo 30 días
        </label>
        <button type="submit" className="btn btn--primary btn--lg btn--block" style={{ marginTop: 16 }} disabled={busy} aria-busy={busy}>
          {busy ? (
            <>
              <span className="btn-spinner" aria-hidden />
              Verificando…
            </>
          ) : (
            'Verificar'
          )}
        </button>
        <div className="otp-foot">
          <Link to="/login" className="back-link">
            <Icon n="017" />
            Cancelar
          </Link>
          <button type="button" className="link" disabled={wait > 0} onClick={resend}>
            {wait > 0 ? `Reenviar en 0:${String(wait).padStart(2, '0')}` : 'Reenviar código'}
          </button>
        </div>
        <p className="panel__note">Demostración: el código es {DEMO_OTP}.</p>
      </form>
    </CenteredPanel>
  )
}
