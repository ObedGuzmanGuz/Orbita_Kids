/**
 * Resumen de un estudiante para el docente (`StudentSummary` en la app),
 * calculado a partir de los intentos que llegan por la cola.
 */

export const WEEKS = 6;
/** Sin actividad por más de estos días → «Sin actividad reciente». */
export const INACTIVE_AFTER_DAYS = 6;
/** Aciertos al primer intento por debajo de esto → «Necesita apoyo». */
export const SUPPORT_BELOW = 68;

const DAY_MS = 24 * 60 * 60 * 1000;
const MONTHS = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/** Colores ARGB de los avatares de iniciales (`DemoData.avatarColors`). */
export const AVATAR_COLORS = [0xff746be8, 0xff3fbcc6, 0xff4dbb98, 0xffe0a53a, 0xffa35bd6, 0xff5776e0];

/** Lunes 00:00 UTC de la semana de `d`. */
export function startOfWeek(d) {
  const day = (d.getUTCDay() + 6) % 7;
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate() - day));
}

/** Inicio de las últimas `n` semanas, de la más antigua a la actual. */
export function weekStarts(now, n = WEEKS) {
  const current = startOfWeek(now);
  return Array.from({ length: n }, (_, i) => new Date(current.getTime() - (n - 1 - i) * 7 * DAY_MS));
}

/** `"22 sep"`, igual que `DemoData.weeks`. */
export function weekLabel(d) {
  return `${d.getUTCDate()} ${MONTHS[d.getUTCMonth()]}`;
}

/** Color estable por estudiante (no cambia al reordenar la lista). */
export function colorFor(id) {
  let h = 0;
  for (const ch of String(id)) h = (h * 31 + ch.codePointAt(0)) >>> 0;
  return AVATAR_COLORS[h % AVATAR_COLORS.length];
}

const percent = (ok, total) => (total > 0 ? Math.round((100 * ok) / total) : null);

/**
 * @param {object} p
 * @param {{id: string, name: string}} p.student
 * @param {string} p.groupId
 * @param {boolean} p.groupArchived
 * @param {{id: string, missionId: string, activityName: string|null, firstTry: number, total: number,
 *   finishedAt: Date, notifyTeacher: boolean}[]} p.attempts
 * @param {number} p.pending  actividades activas del grupo que aún no termina
 * @param {Date} p.now
 *
 * `accuracy`, `trend[i]` y `lastDays` son `null` cuando no hay datos: el
 * reporte no inventa valores.
 */
export function summarizeStudent({ student, groupId, groupArchived, attempts, pending, now }) {
  const starts = weekStarts(now);
  const recent = attempts.filter((a) => a.finishedAt >= starts[0]);

  let ok = 0;
  let total = 0;
  for (const a of recent) {
    ok += a.firstTry;
    total += a.total;
  }

  const trend = starts.map((start, i) => {
    const end = starts[i + 1] ?? new Date(8.64e15);
    let wOk = 0;
    let wTotal = 0;
    for (const a of recent) {
      if (a.finishedAt >= start && a.finishedAt < end) {
        wOk += a.firstTry;
        wTotal += a.total;
      }
    }
    return percent(wOk, wTotal);
  });

  const last = attempts.reduce((m, a) => (!m || a.finishedAt > m.finishedAt ? a : m), null);
  const lastDays = last ? Math.max(0, Math.floor((now - last.finishedAt) / DAY_MS)) : null;
  const accuracy = percent(ok, total);

  let status;
  if (groupArchived) status = 'finished';
  else if (lastDays == null || lastDays > INACTIVE_AFTER_DAYS) status = 'inactive';
  else if ((accuracy != null && accuracy < SUPPORT_BELOW) || last.notifyTeacher) status = 'needsSupport';
  else status = 'upToDate';

  return {
    id: student.id,
    name: student.name,
    groupId,
    accuracy,
    missed: total - ok,
    pending: groupArchived ? 0 : pending,
    operations: total,
    status,
    colorArgb: colorFor(student.id),
    trend,
    // La app todavía no envía el tipo de error de cada ejercicio.
    errors: [],
    lastDays,
    recent: recentAttempts(attempts),
  };
}

export const RECENT_COUNT = 5;

/**
 * Últimos intentos, del más nuevo al más viejo. `title` es el nombre de la
 * actividad asignada; en misiones del catálogo es `null` y la app usa el
 * nombre de su catálogo con `missionId`.
 */
function recentAttempts(attempts) {
  return [...attempts]
    .sort((a, b) => b.finishedAt - a.finishedAt)
    .slice(0, RECENT_COUNT)
    .map((a) => ({
      id: a.id,
      missionId: a.missionId,
      title: a.activityName ?? null,
      firstTry: a.firstTry,
      total: a.total,
      finishedAt: a.finishedAt.toISOString(),
    }));
}
