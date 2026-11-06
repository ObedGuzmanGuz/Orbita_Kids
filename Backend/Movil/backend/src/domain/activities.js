const DAY_MS = 24 * 60 * 60 * 1000;

/**
 * Estado que ve la gente según las fechas: una actividad programada se activa
 * al llegar su inicio y cualquier actividad publicada se cierra al terminar
 * el día de entrega (la app elige fechas con `showDatePicker`, a medianoche).
 * Los borradores no cambian solos.
 */
export function effectiveStatus({ status, assignedAt, dueAt }, now) {
  if (status === 'draft' || status === 'closed') return status;
  if (now.getTime() >= dueAt.getTime() + DAY_MS) return 'closed';
  if (status === 'scheduled' && assignedAt <= now) return 'active';
  return status;
}
