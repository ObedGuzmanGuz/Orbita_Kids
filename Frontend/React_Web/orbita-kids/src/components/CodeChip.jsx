import Icon from './Icon'
import { useApp } from '../state/AppState'

export function CodeChip({ code, muted }) {
  return <span className={`code-chip${muted ? ' is-muted' : ''}`}>{code}</span>
}

export function CopyButton({ text, label = 'Copiar', done = 'Código copiado' }) {
  const { toast } = useApp()
  const copy = async () => {
    try {
      await navigator.clipboard.writeText(text)
    } catch {
      /* el portapapeles puede no estar disponible; el aviso se muestra igual */
    }
    toast(`${done}: ${text}`)
  }
  return (
    <button type="button" className="btn btn--ghost btn--sm copy-btn" onClick={copy}>
      <Icon n="083" />
      {label}
    </button>
  )
}
