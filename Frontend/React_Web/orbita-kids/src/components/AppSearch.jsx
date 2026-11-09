import { useEffect, useMemo, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import Icon from './Icon'
import { useApp } from '../state/AppState'

const normalize = (text) =>
  String(text || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')

// Búsqueda del encabezado: busca en los datos de la cuenta (también sin conexión). Atajos: «/» o Ctrl+K.
export default function AppSearch({ space }) {
  const { teacher, institution } = useApp()
  const navigate = useNavigate()
  const [query, setQuery] = useState('')
  const [open, setOpen] = useState(false)
  const [active, setActive] = useState(0)
  const inputRef = useRef(null)
  const boxRef = useRef(null)

  const index = useMemo(() => {
    if (space === 'institucion') {
      return [
        ...institution.teachers.map((t) => ({ id: `t-${t.id}`, kind: 'Docente', title: t.name, sub: t.email, to: `/institucion/docentes?q=${encodeURIComponent(t.name)}`, icon: '109' })),
        ...institution.groups.map((g) => ({ id: `g-${g.id}`, kind: 'Grupo', title: g.name, sub: `${g.teacher} · ${g.code}`, to: `/institucion/grupos?grado=${g.grade}`, icon: '110' })),
      ]
    }
    const groupName = Object.fromEntries(teacher.groups.map((g) => [g.id, g.status === 'archived' ? `${g.name} · ciclo anterior` : g.name]))
    return [
      ...teacher.students.map((s) => ({ id: `s-${s.id}`, kind: 'Estudiante', title: s.name, sub: groupName[s.group], to: `/docente/estudiantes/${s.id}`, icon: '068' })),
      ...teacher.groups.map((g) => ({ id: `g-${g.id}`, kind: 'Grupo', title: g.name, sub: `${g.students} estudiantes · ${g.code}`, to: `/docente/grupos/${g.id}`, icon: '067' })),
      ...teacher.activities.map((a) => ({
        id: `a-${a.id}`,
        kind: a.status === 'draft' ? 'Borrador' : 'Actividad',
        title: a.name,
        sub: `${a.group} · ${a.kind}`,
        to: a.status === 'draft' ? `/docente/actividades/nueva?borrador=${a.id}` : `/docente/resultados?grupo=${a.groupId}`,
        icon: '069',
      })),
    ]
  }, [space, teacher, institution])

  const term = normalize(query.trim())
  const results = term ? index.filter((r) => normalize(`${r.title} ${r.sub}`).includes(term)).slice(0, 8) : []
  const showing = open && !!term

  useEffect(() => {
    const onKey = (e) => {
      const typing = /^(input|textarea|select)$/i.test(e.target.tagName) || e.target.isContentEditable
      if ((e.key === '/' && !typing) || (e.key.toLowerCase() === 'k' && (e.ctrlKey || e.metaKey))) {
        e.preventDefault()
        inputRef.current?.focus()
      }
    }
    const onDown = (e) => {
      if (boxRef.current && !boxRef.current.contains(e.target)) setOpen(false)
    }
    document.addEventListener('keydown', onKey)
    document.addEventListener('mousedown', onDown)
    return () => {
      document.removeEventListener('keydown', onKey)
      document.removeEventListener('mousedown', onDown)
    }
  }, [])

  const go = (r) => {
    setOpen(false)
    setQuery('')
    inputRef.current?.blur()
    navigate(r.to)
  }

  const onKeyDown = (e) => {
    if (e.key === 'ArrowDown') {
      e.preventDefault()
      setOpen(true)
      setActive((i) => Math.min(results.length - 1, i + 1))
    } else if (e.key === 'ArrowUp') {
      e.preventDefault()
      setActive((i) => Math.max(0, i - 1))
    } else if (e.key === 'Enter') {
      e.preventDefault()
      if (results[active]) go(results[active])
    } else if (e.key === 'Escape') {
      setOpen(false)
      inputRef.current?.blur()
    }
  }

  return (
    <div className="app-search app-header__search" ref={boxRef}>
      <div className="input input--sm" role="search">
        <Icon n="061" />
        <input
          ref={inputRef}
          value={query}
          onChange={(e) => {
            setQuery(e.target.value)
            setActive(0)
            setOpen(true)
          }}
          onFocus={() => setOpen(true)}
          onKeyDown={onKeyDown}
          placeholder={space === 'institucion' ? 'Buscar docente o grupo' : 'Buscar estudiante o grupo'}
          aria-label="Buscar"
          role="combobox"
          aria-expanded={showing}
          aria-controls="app-search-results"
          aria-autocomplete="list"
          aria-activedescendant={showing && results[active] ? `search-${results[active].id}` : undefined}
        />
        {!query && (
          <kbd className="app-search__kbd" aria-hidden>
            /
          </kbd>
        )}
      </div>
      {showing && (
        <ul className="app-search__results" id="app-search-results" role="listbox" aria-label="Resultados">
          {results.length === 0 && <li className="app-search__empty">Sin resultados para «{query.trim()}».</li>}
          {results.map((r, i) => (
            <li
              key={r.id}
              id={`search-${r.id}`}
              role="option"
              aria-selected={i === active}
              className={`app-search__item${i === active ? ' is-active' : ''}`}
              onMouseDown={(e) => {
                e.preventDefault()
                go(r)
              }}
              onMouseEnter={() => setActive(i)}
            >
              <span className="icon-box">
                <Icon n={r.icon} />
              </span>
              <span className="app-search__text">
                <strong>{r.title}</strong>
                {r.sub && <small>{r.sub}</small>}
              </span>
              <span className="app-search__kind">{r.kind}</span>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
