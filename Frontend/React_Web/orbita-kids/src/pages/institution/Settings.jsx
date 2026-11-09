import { useState } from 'react'
import Icon from '../../components/Icon'
import { AppHeader } from '../../layouts/AppShell'
import { CheckToggle } from '../teacher/Notices'
import { useApp } from '../../state/AppState'
import '../shared/shared.css'
import './institution.css'

// 28 · Configuración institucional
export default function Settings() {
  const { online, submit, toast, institution } = useApp()
  const settings = institution.settings
  const [form, setForm] = useState(() => ({
    name: settings.displayName || `Escuela ${institution.school.name}`,
    cycle: settings.cycleLabel || institution.school.cycle || '2026-27',
    tz: settings.timezone || 'America/Mexico_City',
  }))
  const [rules, setRules] = useState(() => ({ autoApprove: !!settings.autoApprove, twoStep: settings.twoStep ?? true, idleLogout: settings.idleLogout ?? true }))
  const [dirty, setDirty] = useState(false)

  const setField = (k) => (e) => {
    setForm((f) => ({ ...f, [k]: e.target.value }))
    setDirty(true)
  }
  const setRule = (k) => (v) => {
    setRules((r) => ({ ...r, [k]: v }))
    setDirty(true)
  }

  const save = () => {
    if (form.name.trim().length < 3) return toast('Escribe el nombre de la escuela (al menos 3 letras).')
    submit('update-settings', { displayName: form.name.trim(), cycleLabel: form.cycle, timezone: form.tz, ...rules }, { title: 'Configuración institucional', icon: '135' })
    toast(online ? 'Cambios guardados. Aplican a todos los docentes.' : 'Sin conexión: los cambios se guardarán al reconectar.')
    setDirty(false)
  }

  return (
    <>
      <AppHeader title="Configuración" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Configuración institucional</h2>
            <p className="page-sub">Afecta a todos los docentes de la escuela.</p>
          </div>
          <button type="button" className="btn btn--primary" onClick={save} disabled={!dirty}>
            Guardar cambios
          </button>
        </div>

        <div className="inst-split">
          <section className="card help-form">
            <h3 className="card__title">Institución</h3>
            <div className="field">
              <label className="field__label" htmlFor="cfg-name">
                Nombre
              </label>
              <input id="cfg-name" className="input" value={form.name} onChange={setField('name')} />
            </div>
            <div className="create-row">
              <div className="field">
                <label className="field__label" htmlFor="cfg-cycle">
                  Ciclo escolar
                </label>
                <select id="cfg-cycle" className="input" value={form.cycle} onChange={setField('cycle')}>
                  <option value="2026-27">2026-27 · agosto a julio</option>
                  <option value="2027-28">2027-28 · agosto a julio</option>
                </select>
              </div>
              <div className="field">
                <label className="field__label" htmlFor="cfg-tz">
                  Zona horaria
                </label>
                <select id="cfg-tz" className="input" value={form.tz} onChange={setField('tz')}>
                  <option value="America/Mexico_City">Ciudad de México (UTC−6)</option>
                  <option value="America/Tijuana">Tijuana (UTC−8)</option>
                  <option value="America/Cancun">Cancún (UTC−5)</option>
                  <option value="America/Hermosillo">Hermosillo (UTC−7)</option>
                </select>
              </div>
            </div>
          </section>

          <section className="card">
            <h3 className="card__title" style={{ marginBottom: 6 }}>
              Inicio de sesión
            </h3>
            <ul>
              <li className="list-row">
                <span className="icon-box" style={{ background: '#fff' }}>
                  <Icon n="123" />
                </span>
                <span className="list-row__body">
                  <span className="list-row__title" style={{ display: 'block' }}>Google Workspace for Education</span>
                  <span className="list-row__sub">OIDC · dominio @escuela.example</span>
                </span>
                <span className="tag tag--success">Conectado</span>
                <button type="button" className="btn btn--ghost btn--sm" onClick={() => toast('Conexión con Google verificada')}>
                  Probar
                </button>
              </li>
              <li className="list-row">
                <span className="icon-box" style={{ background: '#fff' }}>
                  <Icon n="124" />
                </span>
                <span className="list-row__body">
                  <span className="list-row__title" style={{ display: 'block' }}>Microsoft Entra ID</span>
                  <span className="list-row__sub">SAML 2.0</span>
                </span>
                <span className="tag">No configurado</span>
                <button type="button" className="btn btn--sm" style={{ color: 'var(--ink)' }} onClick={() => toast('Te enviamos la guía de configuración SAML por correo')}>
                  Configurar
                </button>
              </li>
              <li className="list-row">
                <span className="icon-box">
                  <Icon n="125" />
                </span>
                <span className="list-row__body">
                  <span className="list-row__title" style={{ display: 'block' }}>Cuentas Órbita Kids</span>
                  <span className="list-row__sub">Usuario y contraseña administrados</span>
                </span>
                <span className="tag tag--success">Conectado</span>
              </li>
            </ul>
          </section>

          <section className="card">
            <h3 className="card__title" style={{ marginBottom: 6 }}>
              Reglas de acceso
            </h3>
            <ul className="settings-list">
              <li>
                <span>
                  <strong>Aprobar solos a docentes del dominio</strong>
                  <small>Si está apagado, la dirección aprueba cada solicitud</small>
                </span>
                <CheckToggle checked={rules.autoApprove} onChange={setRule('autoApprove')} label="Aprobar solos a docentes del dominio" />
              </li>
              <li>
                <span>
                  <strong>Verificación en dos pasos para la dirección</strong>
                  <small>Obligatoria para el rol Institución</small>
                </span>
                <CheckToggle checked={rules.twoStep} onChange={setRule('twoStep')} label="Verificación en dos pasos para la dirección" />
              </li>
              <li>
                <span>
                  <strong>Cerrar sesión tras 8 h sin actividad</strong>
                  <small>También en la app instalada</small>
                </span>
                <CheckToggle checked={rules.idleLogout} onChange={setRule('idleLogout')} label="Cerrar sesión tras 8 h sin actividad" />
              </li>
            </ul>
          </section>

          <section className="card">
            <h3 className="card__title" style={{ marginBottom: 6 }}>
              Datos y privacidad
            </h3>
            <ul className="settings-list">
              <li>
                <span>
                  <strong>Conservar datos de estudiantes</strong>
                  <small>Hasta fin de ciclo + 1 año</small>
                </span>
                <button type="button" className="btn btn--sm" style={{ color: 'var(--ink)' }} onClick={() => toast('Solo puede cambiarlo la dirección con el aviso de privacidad actualizado.')}>
                  Cambiar
                </button>
              </li>
              <li>
                <span>
                  <strong>Exportar todos los datos</strong>
                  <small>Archivo CSV por grupo, en 24 h</small>
                </span>
                <button type="button" className="btn btn--sm" style={{ color: 'var(--ink)' }} onClick={() => toast('Solicitud registrada. Te enviaremos el enlace de descarga en 24 h.')}>
                  Solicitar
                </button>
              </li>
              <li>
                <span>
                  <strong>Aviso de privacidad</strong>
                  <small>Versión 1.2 · aceptado por la dirección</small>
                </span>
                <a href="#privacidad" className="btn btn--ghost btn--sm">
                  Leer
                </a>
              </li>
            </ul>
          </section>
        </div>
      </div>
    </>
  )
}
