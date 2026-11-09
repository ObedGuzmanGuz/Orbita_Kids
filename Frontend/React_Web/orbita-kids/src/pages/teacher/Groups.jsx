import { Link } from 'react-router-dom'
import Icon from '../../components/Icon'
import { CodeChip, CopyButton } from '../../components/CodeChip'
import { AppHeader } from '../../layouts/AppShell'
import { useApp } from '../../state/AppState'
import './teacher.css'

function GroupCard({ group }) {
  const archived = group.status === 'archived'
  return (
    <article className={`card group-card${archived ? ' is-archived' : ''}`}>
      <header className="group-card__head">
        <span className="group-card__avatar">{group.short}</span>
        <div className="group-card__name">
          <h3>{group.name}</h3>
          <p>{group.level}</p>
        </div>
        <span className={`tag ${archived ? '' : group.role === 'apoyo' ? 'tag--teal' : 'tag--success'}`}>{archived ? 'Archivado' : group.role === 'apoyo' ? 'Apoyo' : 'Activo'}</span>
      </header>
      <dl className="group-card__metrics">
        <div>
          <dt>estudiantes</dt>
          <dd>{group.students}</dd>
        </div>
        <div>
          <dt>aciertos</dt>
          <dd>{group.score}%</dd>
        </div>
        <div>
          <dt>pendientes</dt>
          <dd>{group.pending}</dd>
        </div>
      </dl>
      <div className="progress" aria-hidden>
        <div className="progress__bar" style={{ width: `${group.progress}%` }} />
      </div>
      <footer className="group-card__actions">
        <CodeChip code={group.code} />
        <CopyButton text={group.code} />
        <Link to={`/docente/grupos/${group.id}`} className={`btn btn--sm ${archived ? 'btn--secondary' : 'btn--primary'}`}>
          Abrir
        </Link>
      </footer>
    </article>
  )
}

export default function Groups() {
  const { teacher, submit, online, toast } = useApp()
  const active = teacher.groups.filter((g) => g.status === 'active')
  const archived = teacher.groups.filter((g) => g.status === 'archived')

  const requestGroup = () => {
    submit('request-group', { note: '' }, { title: 'Solicitud de grupo nuevo', icon: '082' })
    toast(online ? 'Solicitud enviada a la dirección. Te avisaremos cuando asigne el grupo.' : 'Sin conexión: la solicitud se enviará al reconectar.')
  }

  return (
    <>
      <AppHeader title="Mis grupos" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Mis grupos</h2>
            <p className="page-sub">
              {active.length} {active.length === 1 ? 'activo' : 'activos'} · {archived.length} {archived.length === 1 ? 'archivado' : 'archivados'} · los códigos los
              asigna la dirección
            </p>
          </div>
          <button type="button" className="btn btn--secondary" onClick={requestGroup}>
            <Icon n="082" />
            Solicitar grupo
          </button>
        </div>

        {active.length === 0 && (
          <section className="card empty-state">
            <span className="empty-state__icon">
              <Icon n="067" />
            </span>
            <h3 className="card__title">Aún no tienes grupos este ciclo</h3>
            <p className="card__note">Pide a la dirección que te asigne uno con el botón «Solicitar grupo».</p>
          </section>
        )}
        <div className="group-grid">
          {active.map((g) => (
            <GroupCard key={g.id} group={g} />
          ))}
        </div>

        {archived.length > 0 && (
          <>
            <h3 className="groups-archived">Archivados</h3>
            <div className="group-grid">
              {archived.map((g) => (
                <GroupCard key={g.id} group={g} />
              ))}
            </div>
          </>
        )}
      </div>
    </>
  )
}
