import { useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import Icon from '../../components/Icon'
import { useApp } from '../../state/AppState'
import { addToOutbox, api } from '../../state/api'
import './site-pages.css'

const EMPTY = { school: '', person: '', email: '', size: '50 a 150', plan: 'Escuela', message: '', privacy: false }

function validate(f) {
  const e = {}
  if (!f.school.trim()) e.school = 'Escribe el nombre de la escuela.'
  if (!f.person.trim()) e.person = 'Escribe quién es la persona responsable.'
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(f.email.trim())) e.email = 'Escribe un correo válido, por ejemplo direccion@escuela.edu.mx.'
  if (!f.privacy) e.privacy = 'Necesitamos tu aceptación para responder.'
  return e
}

// 03a/03b · Solicitar información
export default function Contact() {
  const [params] = useSearchParams()
  const { online } = useApp()
  const [sending, setSending] = useState(false)
  const [queued, setQueued] = useState(false)
  const [form, setForm] = useState({ ...EMPTY, plan: params.get('plan') || 'Escuela' })
  const [errors, setErrors] = useState({})
  const [folio, setFolio] = useState(null)

  const set = (k) => (e) => {
    const value = e.target.type === 'checkbox' ? e.target.checked : e.target.value
    setForm((f) => ({ ...f, [k]: value }))
    if (errors[k]) setErrors((x) => ({ ...x, [k]: undefined }))
  }

  const submit = async (e) => {
    e.preventDefault()
    if (sending) return
    const found = validate(form)
    setErrors(found)
    if (Object.keys(found).length) {
      document.getElementById(`contact-${Object.keys(found)[0]}`)?.focus()
      return
    }
    const number = `SOL-2026-${String(Math.floor(Math.random() * 9000) + 1000)}`
    // El folio se propone aquí para poder darlo aun sin conexión; el servidor lo respeta si está libre.
    const body = {
      folio: number,
      school: form.school.trim(),
      person: form.person.trim(),
      email: form.email.trim(),
      size: form.size,
      plan: form.plan,
      message: form.message.trim(),
      privacy: form.privacy,
    }
    const keepForLater = () => {
      addToOutbox({ id: number, path: '/contact', body })
      setQueued(true)
      setFolio(number)
      window.scrollTo({ top: 0 })
    }
    if (!online) return keepForLater()
    setSending(true)
    try {
      const res = await api('/contact', { method: 'POST', body })
      setFolio(res.folio)
      window.scrollTo({ top: 0 })
    } catch (err) {
      if (err.offline) keepForLater()
      else if (err.body?.errors) setErrors(err.body.errors)
      else setErrors({ privacy: err.message })
    } finally {
      setSending(false)
    }
  }

  if (folio) {
    return (
      <section className="container site-page contact-done">
        <span className="contact-done__icon">
          <Icon n="014" />
        </span>
        <h1 className="site-h2 site-h2--lg">Recibimos tu solicitud</h1>
        <p className="site-lead">
          Folio <strong className="code-chip" style={{ fontSize: 15 }}>{folio}</strong>. Te escribimos al correo que dejaste en menos de 2 días hábiles.
          {queued && ' Estás sin conexión: la enviaremos en cuanto vuelva Internet.'}
        </p>
        <div className="row" style={{ justifyContent: 'center', marginTop: 24, flexWrap: 'wrap' }}>
          <Link to="/" className="btn btn--outline btn--lg">
            Volver al sitio
          </Link>
          <Link to="/explorar" className="btn btn--primary btn--lg">
            Explorar sin cuenta
          </Link>
        </div>
      </section>
    )
  }

  const field = (key, label, input, hint) => (
    <div className="field">
      <label className="field__label" htmlFor={`contact-${key}`}>
        {label}
      </label>
      {input}
      {errors[key] ? (
        <p className="field__error" id={`contact-${key}-error`}>
          {errors[key]}
        </p>
      ) : (
        hint
      )}
    </div>
  )

  const inputProps = (key) => ({
    id: `contact-${key}`,
    className: `input${errors[key] ? ' input--error' : ''}`,
    value: form[key],
    onChange: set(key),
    'aria-invalid': !!errors[key],
    'aria-describedby': errors[key] ? `contact-${key}-error` : undefined,
  })

  return (
    <section className="container site-page contact">
      <div className="contact__intro">
        <h1 className="site-h2 site-h2--lg">Lleva Órbita Kids a tu escuela</h1>
        <p className="site-lead">Cuéntanos de tu escuela. Te enviamos una propuesta y una cuenta de prueba para la dirección.</p>
        <dl className="contact__facts">
          <dt>Respuesta</dt>
          <dd>En 2 días hábiles, de lunes a viernes de 9:00 a 17:00, hora del centro de México</dd>
          <dt>Correo</dt>
          <dd>
            <a href="mailto:contacto@orbitakids.example">contacto@orbitakids.example</a>
          </dd>
        </dl>
      </div>

      <form className="card contact__form" onSubmit={submit} noValidate>
        {field('school', 'Nombre de la escuela', <input {...inputProps('school')} placeholder="Escuela Primaria Benito Juárez" />)}
        <div className="create-row">
          {field('person', 'Responsable', <input {...inputProps('person')} placeholder="Nombre y cargo" />)}
          {field('email', 'Correo de la escuela', <input {...inputProps('email')} type="email" placeholder="direccion@tuescuela.edu.mx" />)}
        </div>
        <div className="create-row">
          {field(
            'size',
            'Estudiantes aproximados',
            <select {...inputProps('size')}>
              <option>Menos de 50</option>
              <option>50 a 150</option>
              <option>150 a 500</option>
              <option>Más de 500</option>
            </select>,
          )}
          {field(
            'plan',
            'Plan de interés',
            <select {...inputProps('plan')}>
              <option>Gratuito</option>
              <option>Aula</option>
              <option>Escuela</option>
              <option>Licencia institucional</option>
            </select>,
          )}
        </div>
        <div className="field">
          <label className="field__label" htmlFor="contact-message">
            Mensaje <span style={{ fontWeight: 400, color: 'var(--muted)' }}>(opcional)</span>
          </label>
          <textarea {...inputProps('message')} rows={3} placeholder="¿Cuántos grupos y grados tienen?" />
        </div>
        <div>
          <label className="checkbox">
            <input id="contact-privacy" type="checkbox" checked={form.privacy} onChange={set('privacy')} aria-invalid={!!errors.privacy} />
            Acepto el aviso de privacidad. Solo usamos estos datos para responderte.
          </label>
          {errors.privacy && (
            <p className="field__error" style={{ marginTop: 10 }}>
              {errors.privacy}
            </p>
          )}
        </div>
        <div className="row" style={{ gap: 18 }}>
          <button type="submit" className="btn btn--primary" disabled={sending} aria-busy={sending}>
            {sending ? 'Enviando…' : 'Enviar solicitud'}
          </button>
          <Link to="/planes" className="link" style={{ fontSize: 14 }}>
            Ver planes
          </Link>
        </div>
      </form>
    </section>
  )
}
