import { useId } from 'react'

// Gráfica de «Resultados recientes» (Figma 97:2097): rejilla 50/75/100 %, línea morada,
// área degradada y el último punto resaltado con su valor.
export default function LineChart({ data, width = 602, height = 192, ticks = [50, 75, 100], min = 40, max = 100, color = '#5646db', label }) {
  const id = useId()
  if (!data?.length) {
    return (
      <p className="empty-note" role="img" aria-label={label}>
        Todavía no hay resultados suficientes para la gráfica.
      </p>
    )
  }
  const left = width * 0.0556
  const right = width * (1 - 0.025)
  const top = height * 0.0696
  const tickBottom = height * 0.7362
  const scaleY = (v) => top + ((max - v) / (max - ticks[0])) * (tickBottom - top)
  const base = scaleY(min)
  const step = data.length > 1 ? (right - left) / (data.length - 1) : 0
  const pts = data.map((d, i) => [left + i * step, scaleY(d.value)])
  const line = pts.map(([x, y], i) => `${i ? 'L' : 'M'}${x.toFixed(1)} ${y.toFixed(1)}`).join(' ')
  const area = `${line} L${right.toFixed(1)} ${base.toFixed(1)} L${left.toFixed(1)} ${base.toFixed(1)} Z`
  const last = pts[pts.length - 1]

  return (
    <svg viewBox={`0 0 ${width} ${height}`} className="line-chart" role="img" aria-label={label} style={{ width: '100%', height: 'auto', display: 'block', overflow: 'visible' }}>
      <defs>
        <linearGradient id={`${id}-fill`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor={color} stopOpacity="0.28" />
          <stop offset="1" stopColor={color} stopOpacity="0" />
        </linearGradient>
      </defs>
      {ticks.map((t) => (
        <g key={t}>
          <line x1={left} x2={right} y1={scaleY(t)} y2={scaleY(t)} stroke="#e6e8f0" strokeWidth="0.84" />
          <text x={left - 6} y={scaleY(t) + 3.5} textAnchor="end" fontSize="10" fontWeight="700" fill="#5e6283">
            {t}%
          </text>
        </g>
      ))}
      <path d={area} fill={`url(#${id}-fill)`} />
      <path d={line} fill="none" stroke={color} strokeWidth="1.7" strokeLinejoin="round" strokeLinecap="round" />
      {pts.slice(0, -1).map(([x, y], i) => (
        <circle key={i} cx={x} cy={y} r="2.9" fill="#fff" stroke={color} strokeWidth="1.25" />
      ))}
      <circle cx={last[0]} cy={last[1]} r="4.6" fill={color} stroke="#fff" strokeWidth="1" />
      <text x={last[0]} y={last[1] - 9} textAnchor="middle" fontSize="10" fontWeight="700" fill="#15173a">
        {data[data.length - 1].value}%
      </text>
      {data.map((d, i) => (
        <text key={d.label} x={left + i * step} y={height * 0.965} textAnchor="middle" fontSize="10" fontWeight="700" fill="#5e6283">
          {d.label}
        </text>
      ))}
    </svg>
  )
}
