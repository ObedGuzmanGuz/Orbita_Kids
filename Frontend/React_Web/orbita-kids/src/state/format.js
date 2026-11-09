const MONTHS = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic']

// Formato de 24 h, como en el diseño («8:15», «18:40»).
export function clock(date) {
  return new Date(date).toLocaleTimeString('es-MX', { hour: 'numeric', minute: '2-digit', hour12: false })
}

// «hoy 14:05», «ayer 18:40» o «3 nov 9:12».
export function whenLabel(ts, { capital = false } = {}) {
  if (!ts) return capital ? 'Sin sincronizar' : 'sin sincronizar'
  const d = new Date(ts)
  const days = Math.round((new Date().setHours(0, 0, 0, 0) - new Date(ts).setHours(0, 0, 0, 0)) / 86400000)
  const text = days === 0 ? `hoy ${clock(d)}` : days === 1 ? `ayer ${clock(d)}` : `${d.getDate()} ${MONTHS[d.getMonth()]} ${clock(d)}`
  return capital ? text[0].toUpperCase() + text.slice(1) : text
}

export function shortDate(iso) {
  if (!iso) return 'sin fecha'
  const [, m, d] = iso.split('-').map(Number)
  return `${d} ${MONTHS[m - 1]}`
}

export const plural = (n, one, many) => `${n} ${n === 1 ? one : many}`
