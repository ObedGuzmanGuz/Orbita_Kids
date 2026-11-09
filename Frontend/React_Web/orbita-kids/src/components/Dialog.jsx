import { useEffect, useRef } from 'react'

// Diálogo modal accesible (Escape cierra, el foco entra al abrir).
export default function Dialog({ title, children, onClose, width = 520, labelledBy }) {
  const ref = useRef(null)

  useEffect(() => {
    const prev = document.activeElement
    const first = ref.current?.querySelector('input, select, textarea, button:not([data-close])')
    first?.focus()
    const onKey = (e) => e.key === 'Escape' && onClose?.()
    document.addEventListener('keydown', onKey)
    return () => {
      document.removeEventListener('keydown', onKey)
      prev?.focus?.()
    }
  }, [onClose])

  return (
    <div className="dialog-backdrop" onMouseDown={(e) => e.target === e.currentTarget && onClose?.()}>
      <div className="dialog" role="dialog" aria-modal="true" aria-labelledby={labelledBy || 'dialog-title'} ref={ref} style={{ width: `min(${width}px, 100%)` }}>
        {title && (
          <h2 className="dialog__title" id="dialog-title">
            {title}
          </h2>
        )}
        {children}
      </div>
    </div>
  )
}
