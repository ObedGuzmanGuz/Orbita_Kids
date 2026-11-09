import { useState } from 'react'
import { Navigate, useLocation, useNavigate } from 'react-router-dom'
import Icon from '../../components/Icon'
import CenteredPanel from '../../components/CenteredPanel'
import { useApp } from '../../state/AppState'
import { plural } from '../../state/format'
import './auth.css'

// 09 · Elegir espacio (docente e institución)
export default function ChooseSpace() {
  const location = useLocation()
  const navigate = useNavigate()
  const { session, user, teacher, institution, chooseSpace, toast } = useApp()
  const [remember, setRemember] = useState(false)
  if (!session || !user) return <Navigate to="/login" replace />

  // El servidor manda un resumen al entrar; si se llega aquí desde el menú de la cuenta, se calcula con los datos locales.
  const active = teacher.groups.filter((g) => g.status === 'active')
  const summary = location.state?.spaces || {
    docente: `${active.map((g) => g.name).join(', ') || 'Sin grupos'} · ${plural(active.reduce((n, g) => n + g.students, 0), 'estudiante', 'estudiantes')} · ${plural(teacher.activities.filter((a) => a.status === 'active').length, 'actividad activa', 'actividades activas')}`,
    institucion: `${institution.school?.name || ''} · ${plural(institution.teachers.filter((t) => t.status === 'active').length, 'docente', 'docentes')}`,
  }

  const go = (space) => {
    chooseSpace(space)
    if (remember) toast('Recordaremos tu elección en este equipo.')
    navigate(location.state?.from?.startsWith(`/${space}`) ? location.state.from : `/${space}`, { replace: true })
  }

  return (
    <CenteredPanel width={820} windowTitle="Elegir espacio">
      <div className="panel--left">
        <div className="panel-head">
          <span className="avatar avatar--lg" style={{ background: user.color }}>{user.initials}</span>
          <div>
            <h1 className="panel__title">Hola, {user.name.split(' ')[0]}</h1>
            <p className="login__sub" style={{ marginTop: 0 }}>
              Tienes dos espacios en Órbita Kids. ¿Dónde quieres entrar?
            </p>
          </div>
        </div>
        <div className="spaces">
          <button type="button" className="space-option" onClick={() => go('docente')}>
            <span className="space-option__icon" style={{ background: 'var(--teal-bg)' }}>
              <Icon n="033" />
            </span>
            <span>
              <strong>Docente</strong>
              <small>{summary.docente}</small>
            </span>
          </button>
          <button type="button" className="space-option" onClick={() => go('institucion')}>
            <span className="space-option__icon" style={{ background: '#fbefd9' }}>
              <Icon n="034" />
            </span>
            <span>
              <strong>Institución</strong>
              <small>{summary.institucion}</small>
            </span>
          </button>
        </div>
        <label className="checkbox" style={{ marginTop: 18 }}>
          <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} />
          Recordar mi elección en este equipo
        </label>
        <p className="panel__note">Puedes cambiar de espacio cuando quieras desde tu foto, arriba a la derecha.</p>
      </div>
    </CenteredPanel>
  )
}
