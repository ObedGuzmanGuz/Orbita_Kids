import { useApp } from '../state/AppState'

export default function Toasts() {
  const { toasts, dismissToast } = useApp()
  return (
    <div className="toast-stack" role="status" aria-live="polite">
      {toasts.map((t) => (
        <div key={t.id} className="toast">
          <span style={{ flex: 1 }}>{t.message}</span>
          {t.action && (
            <button
              type="button"
              className="btn btn--light btn--sm"
              onClick={() => {
                t.action.onClick()
                dismissToast(t.id)
              }}
            >
              {t.action.label}
            </button>
          )}
          <button type="button" aria-label="Cerrar aviso" onClick={() => dismissToast(t.id)} style={{ color: 'var(--on-night-3)', fontSize: 18, lineHeight: 1 }}>
            ×
          </button>
        </div>
      ))}
    </div>
  )
}
