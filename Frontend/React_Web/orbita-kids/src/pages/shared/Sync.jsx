import Icon from '../../components/Icon'
import { CodeChip } from '../../components/CodeChip'
import { AppHeader } from '../../layouts/AppShell'
import { useApp } from '../../state/AppState'
import { clock, whenLabel } from '../../state/format'
import './shared.css'

// 30 · Sincronización
export default function Sync() {
  const { online, networkOnline, simulateOffline, setSimulateOffline, queue, history, syncing, syncNow, syncError, lastSync, toast, persistent } = useApp()

  const sync = async () => {
    const ok = await syncNow()
    toast(ok ? 'Todo al día.' : 'No se pudo sincronizar. Lo intentaremos de nuevo solos.')
  }

  const subtitle = !online
    ? 'Sin conexión: los cambios esperan cifrados en este equipo.'
    : syncError
      ? `No se pudo sincronizar: ${syncError}`
      : queue.length
        ? 'Hay cambios listos para enviarse.'
        : `Todo sincronizado · ${lastSync}.`

  return (
    <>
      <AppHeader title="Sincronización" />
      <div className="page">
        <div className="page-head">
          <div className="page-head__text">
            <h2 className="page-title">Sincronización</h2>
            <p className="page-sub">{subtitle}</p>
          </div>
          <button
            type="button"
            role="switch"
            aria-checked={simulateOffline}
            className={`sim-switch${simulateOffline ? ' is-on' : ''}`}
            disabled={!networkOnline}
            onClick={() => setSimulateOffline(!simulateOffline)}
            title="Solo para la demostración: simula que el equipo perdió Internet"
          >
            <span className="sim-switch__track">
              <span className="sim-switch__knob" />
            </span>
            Simular sin conexión
          </button>
          <button type="button" className="btn btn--primary" disabled={!online || syncing} onClick={sync}>
            <Icon n="049" className={syncing ? 'spin' : ''} />
            {syncing ? 'Sincronizando…' : 'Sincronizar ahora'}
          </button>
        </div>

        <div className="split-2 split-2--sync">
          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Cambios por enviar</h3>
              <span className="tag tag--warning" style={{ marginLeft: 'auto' }}>{queue.length}</span>
            </div>
            {queue.length === 0 ? (
              <p className="empty-note">No hay cambios pendientes. Lo que hagas sin conexión aparecerá aquí.</p>
            ) : (
              <ul>
                {queue.map((c) => (
                  <li key={c.id} className="list-row">
                    <span className="icon-box">
                      <Icon n={c.icon || '133'} />
                    </span>
                    <span className="list-row__body">
                      <span className="list-row__title" style={{ display: 'block' }}>{c.title}</span>
                      <span className="list-row__sub change-meta">
                        <CodeChip code={c.id} muted /> · {whenLabel(c.createdAt, { capital: true })}
                        {c.offline ? ' · sin conexión' : ''}
                      </span>
                    </span>
                    <span className="tag tag--warning">{syncing && online ? 'Enviando…' : 'Pendiente'}</span>
                  </li>
                ))}
              </ul>
            )}
            {!persistent && (
              <p className="card__note" style={{ marginTop: 10 }}>
                Este navegador no permite guardar datos cifrados (abre la app en https o localhost): la cola se pierde al recargar.
              </p>
            )}
          </section>
          <section className="card">
            <div className="card__head">
              <h3 className="card__title">Confirmados recientemente</h3>
            </div>
            {history.length === 0 && <p className="empty-note">Aún no hay cambios en esta cuenta. Lo que publiques, asignes o marques aparecerá aquí.</p>}
            <ul>
              {history.map((c) => (
                <li key={c.id} className="list-row">
                  <span className="icon-box">
                    <Icon n={c.icon || '134'} />
                  </span>
                  <span className="list-row__body">
                    <span className="list-row__title" style={{ display: 'block' }}>{c.title}</span>
                    <span className="list-row__sub change-meta">
                      <CodeChip code={c.id} muted /> · {whenLabel(c.receivedAt, { capital: true })}
                      {c.createdAt && c.receivedAt - c.createdAt > 60000 ? ` · hecho sin conexión a las ${clock(c.createdAt)}` : ''}
                    </span>
                    {c.status === 'rejected' && c.error && <span className="list-row__sub change-error">{c.error}</span>}
                  </span>
                  {c.status === 'rejected' ? <span className="tag tag--danger">Rechazado</span> : <span className="tag tag--success">Confirmado</span>}
                </li>
              ))}
            </ul>
            <p className="card__note" style={{ marginTop: 10, borderTop: '1px solid var(--border)', paddingTop: 10 }}>
              Solo se retiran de la cola los cambios que el servidor confirmó. Nunca se sobrescribe un dato nuevo con uno viejo.
            </p>
          </section>
        </div>
      </div>
    </>
  )
}
