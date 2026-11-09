import { useEffect, useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import Icon from '../../components/Icon'
import CenteredPanel from '../../components/CenteredPanel'
import { api } from '../../state/api'
import './auth.css'

// 06 · Acceso institucional. El directorio de escuelas y su proveedor de identidad viene del servidor.
export default function InstitutionSearch() {
  const [query, setQuery] = useState('')
  const [list, setList] = useState(null)
  const [failed, setFailed] = useState(false)
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => {
    let cancelled = false
    const t = setTimeout(() => {
      api(`/schools?q=${encodeURIComponent(query.trim())}`)
        .then((r) => {
          if (cancelled) return
          setList(r.schools)
          setFailed(false)
        })
        .catch(() => !cancelled && setFailed(true))
    }, 180)
    return () => {
      cancelled = true
      clearTimeout(t)
    }
  }, [query])

  return (
    <CenteredPanel back={{ to: '/login', label: 'Otros métodos' }} title="Entra con tu institución" text="Busca tu escuela y continúa con su inicio de sesión." windowTitle="Acceso institucional">
      <label className="input" style={{ marginTop: 18 }}>
        <Icon n="025" />
        <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Nombre de la escuela" aria-label="Nombre de la escuela" autoFocus />
      </label>
      <div className="school-list" aria-live="polite">
        {failed && <p className="panel__note">Necesitas conexión para buscar tu escuela.</p>}
        {!failed && list === null && <p className="panel__note">Buscando…</p>}
        {!failed &&
          list?.map((s) => (
            <button key={s.name} type="button" className="school-option" disabled={s.disabled} onClick={() => navigate(`/login/${s.provider}`, { state: location.state })}>
              <Icon n="026" />
              <span>
                <strong>{s.name}</strong>
                <small>{s.idp}</small>
              </span>
              <span className={`tag ${s.disabled ? '' : 'tag--primary'}`}>{s.proto}</span>
            </button>
          ))}
        {!failed && list?.length === 0 && <p className="panel__note">No encontramos esa escuela.</p>}
      </div>
      <p className="panel__note">¿No aparece? Pide a la dirección que configure el inicio de sesión institucional.</p>
    </CenteredPanel>
  )
}
