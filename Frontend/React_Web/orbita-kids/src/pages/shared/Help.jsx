import { useState } from 'react'
import { Link } from 'react-router-dom'
import Icon from '../../components/Icon'
import { CodeChip, CopyButton } from '../../components/CodeChip'
import { AppHeader } from '../../layouts/AppShell'
import { useApp } from '../../state/AppState'
import './shared.css'

const FAQ = [
  {
    q: '¿Cómo instalo la app en mi computadora?',
    a: 'En Chrome o Edge usa el botón Instalar de la barra de direcciones o el de la app. En Safari para macOS: Archivo → Agregar al Dock.',
  },
  {
    q: '¿Qué pasa si me quedo sin Internet?',
    a: 'La app instalada abre igual y muestra lo último sincronizado. Lo que crees se guarda como borrador y se envía al reconectar.',
  },
  { q: '¿Los estudiantes pueden entrar aquí?', a: 'No. Los estudiantes usan la app móvil. Esta app es solo para docentes e instituciones.' },
  {
    q: '¿Cómo comparto el código de un grupo?',
    a: 'Cópialo desde Mis grupos y escríbelo en el pizarrón. Los estudiantes lo escriben en la app móvil.',
  },
  { q: '¿Quién ve los datos de los niños?', a: 'El docente ve el detalle de su grupo. La dirección ve datos agregados. Nadie más.' },
  { q: '¿Cómo desinstalo la app?', a: 'Desde el menú de la ventana de la app (⋯) → Desinstalar, o como cualquier app de tu sistema.' },
]

const EMAIL = 'soporte@orbitakids.example'

// 33 · Ayuda y soporte
export default function Help({ eyebrow = 'Cuenta' }) {
  const { online, submit, toast } = useApp()
  const [open, setOpen] = useState(FAQ.length - 1)
  const [type, setType] = useState('No puedo entrar')
  const [text, setText] = useState('')

  const send = (e) => {
    e.preventDefault()
    if (!text.trim()) {
      toast('Cuéntanos qué pasó antes de enviar el reporte.')
      return
    }
    submit('report-problem', { kind: type, message: text.trim() }, { title: `Reporte: ${type}`, icon: '133' })
    toast(online ? 'Reporte enviado. Te responderemos por correo.' : 'Sin conexión: el reporte se enviará al reconectar.')
    setText('')
  }

  return (
    <>
      <AppHeader title="Ayuda" eyebrow={eyebrow} />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Ayuda y soporte</h2>
            <p className="page-sub">Respuestas rápidas y contacto con el equipo.</p>
          </div>
          <Link to="/instalar/navegadores" className="btn btn--secondary">
            <Icon n="141" />
            Guía de instalación
          </Link>
        </div>

        <div className="help-grid">
          <div className="faq-list">
            {FAQ.map((f, i) => (
              <div key={f.q} className={`faq-item${open === i ? ' is-open' : ''}`}>
                <button type="button" aria-expanded={open === i} onClick={() => setOpen(open === i ? -1 : i)}>
                  {f.q}
                  <Icon n="013" />
                </button>
                {open === i && <p>{f.a}</p>}
              </div>
            ))}
          </div>

          <div className="create-side">
            <form className="card help-form" onSubmit={send}>
              <h3 className="card__title">Reportar un problema</h3>
              <div className="field">
                <label className="field__label" htmlFor="report-type">
                  Tipo
                </label>
                <select id="report-type" className="input" value={type} onChange={(e) => setType(e.target.value)}>
                  <option>No puedo entrar</option>
                  <option>No se sincroniza</option>
                  <option>Un dato está mal</option>
                  <option>Otro</option>
                </select>
              </div>
              <div className="field">
                <label className="field__label" htmlFor="report-text">
                  Qué pasó
                </label>
                <textarea id="report-text" className="input" rows={3} placeholder="Cuéntanos qué estabas haciendo" value={text} onChange={(e) => setText(e.target.value)} />
              </div>
              <button type="submit" className="btn btn--primary btn--block">
                <Icon n="093" />
                Enviar reporte
              </button>
              <p className="card__note">Si no hay Internet, se envía al reconectar.</p>
            </form>
            <section className="card">
              <h3 className="card__title" style={{ marginBottom: 14 }}>
                Contacto
              </h3>
              <p className="row" style={{ gap: 8, flexWrap: 'wrap' }}>
                <CodeChip code={EMAIL} />
                <CopyButton text={EMAIL} done="Correo copiado" />
              </p>
              <p className="card__note" style={{ marginTop: 12 }}>
                Lunes a viernes, 9:00 a 17:00 (hora del centro de México).
              </p>
            </section>
          </div>
        </div>
      </div>
    </>
  )
}
