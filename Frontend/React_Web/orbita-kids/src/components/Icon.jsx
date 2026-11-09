// Íconos exportados de «Web · Biblioteca de íconos» (Figma).
// Cada SVG conserva su tamaño y color original; se referencian por su número («ícono/054» → n="054").
const files = import.meta.glob('../assets/icons/*.svg', { eager: true, query: '?url', import: 'default' })

const ICONS = {}
for (const [path, url] of Object.entries(files)) {
  const match = path.match(/icono-(\d+)\.svg$/)
  if (match) ICONS[match[1]] = url
}

// Algunos íconos se dibujan ligeramente fuera de su caja en Figma.
const OFFSETS = {
  '011': { marginTop: -1.5 },
  103: { marginLeft: -0.08 },
  106: { marginLeft: -0.08 },
  110: { marginLeft: -0.08 },
  113: { marginLeft: -0.08 },
}

export default function Icon({ n, label, className = '', style }) {
  const src = ICONS[n]
  if (!src) return null
  return (
    <img
      src={src}
      alt={label || ''}
      aria-hidden={label ? undefined : true}
      className={`icon ${className}`}
      style={{ ...OFFSETS[n], ...style }}
      draggable={false}
    />
  )
}
