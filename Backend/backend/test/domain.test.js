import assert from 'node:assert/strict';
import { describe, it } from 'node:test';

import { effectiveStatus } from '../src/domain/activities.js';
import { profileFromClaims, roleFromClaims } from '../src/domain/claims.js';
import { CODE_PATTERN, codeProblem, generateCode, normalizeCode } from '../src/domain/groupCodes.js';
import { colorFor, startOfWeek, summarizeStudent, weekLabel, weekStarts } from '../src/domain/studentSummary.js';

const DAY = 24 * 60 * 60 * 1000;
// Jueves 29 de octubre de 2026, la fecha de referencia del prototipo.
const now = new Date('2026-10-29T15:00:00Z');
const ago = (d) => new Date(now.getTime() - d * DAY);

describe('códigos de grupo', () => {
  it('normaliza lo que escribe la persona', () => {
    assert.equal(normalizeCode(' orb-2a7k '), 'ORB-2A7K');
    assert.equal(normalizeCode('ORB - 2A7K'), 'ORB-2A7K');
  });

  it('genera códigos con el formato esperado y sin caracteres ambiguos', () => {
    for (let i = 0; i < 200; i++) {
      const c = generateCode();
      assert.match(c, CODE_PATTERN);
      assert.doesNotMatch(c.slice(4), /[01IO]/);
    }
  });

  const active = { status: 'active', codeExpiresAt: new Date(now.getTime() + DAY) };

  it('acepta un grupo activo sin licencia o con lugares', () => {
    assert.equal(codeProblem({ group: active, license: null, seatsUsed: 999, now }), null);
    assert.equal(codeProblem({ group: active, license: { seats: 10, endsAt: null }, seatsUsed: 9, now }), null);
  });

  it('explica cada rechazo', () => {
    assert.equal(codeProblem({ group: null, license: null, seatsUsed: 0, now }), 'notFound');
    assert.equal(codeProblem({ group: { ...active, status: 'archived' }, license: null, seatsUsed: 0, now }), 'archived');
    assert.equal(codeProblem({ group: { ...active, codeExpiresAt: ago(1) }, license: null, seatsUsed: 0, now }), 'expired');
    assert.equal(codeProblem({ group: active, license: { seats: 1, endsAt: null }, seatsUsed: 1, now }), 'full');
    assert.equal(codeProblem({ group: active, license: { seats: 9, endsAt: ago(1) }, seatsUsed: 0, now }), 'licenseEnded');
  });
});

describe('estado de actividades', () => {
  const a = (status, assignedDays, dueDays) => ({
    status,
    assignedAt: new Date(now.getTime() + assignedDays * DAY),
    dueAt: new Date(now.getTime() + dueDays * DAY),
  });

  it('activa la programada al llegar su inicio', () => {
    assert.equal(effectiveStatus(a('scheduled', 1, 5), now), 'scheduled');
    assert.equal(effectiveStatus(a('scheduled', -1, 5), now), 'active');
  });

  it('el día de entrega cuenta completo', () => {
    const dueToday = { status: 'active', assignedAt: ago(5), dueAt: new Date('2026-10-29T00:00:00Z') };
    assert.equal(effectiveStatus(dueToday, now), 'active');
    assert.equal(effectiveStatus(dueToday, new Date('2026-10-30T00:00:00Z')), 'closed');
  });

  it('no toca borradores', () => {
    assert.equal(effectiveStatus(a('draft', -10, -5), now), 'draft');
  });
});

describe('claims de Keycloak', () => {
  const roles = { roleStudent: 'student', roleTeacher: 'teacher' };

  it('docente tiene prioridad sobre estudiante', () => {
    assert.equal(roleFromClaims({ realm_access: { roles: ['student', 'teacher'] } }, roles), 'teacher');
    assert.equal(roleFromClaims({ realm_access: { roles: ['student'] } }, roles), 'student');
    assert.equal(roleFromClaims({ realm_access: { roles: ['offline_access'] } }, roles), null);
    assert.equal(roleFromClaims({}, roles), null);
  });

  it('toma el nombre de given_name o del usuario', () => {
    assert.equal(profileFromClaims({ sub: 'x', given_name: 'Luna' }).name, 'Luna');
    assert.equal(profileFromClaims({ sub: 'x', preferred_username: 'luna.astro' }).name, 'luna.astro');
    assert.equal(profileFromClaims({ sub: 'x' }).name, 'Astronauta');
  });
});

describe('resumen de estudiante', () => {
  const student = { id: 'u1', name: 'Luna M.' };
  const attempt = (days, firstTry, total = 6, notifyTeacher = false) => ({
    firstTry,
    total,
    finishedAt: ago(days),
    notifyTeacher,
  });
  const summary = (attempts, extra = {}) =>
    summarizeStudent({ student, groupId: 'g', groupArchived: false, attempts, pending: 1, now, ...extra });

  it('semanas desde el lunes, con etiquetas como en la app', () => {
    assert.equal(startOfWeek(now).toISOString(), '2026-10-26T00:00:00.000Z');
    const labels = weekStarts(now).map(weekLabel);
    assert.deepEqual(labels, ['21 sep', '28 sep', '5 oct', '12 oct', '19 oct', '26 oct']);
  });

  it('calcula aciertos, errores y operaciones', () => {
    const s = summary([attempt(1, 5), attempt(2, 4)]);
    assert.equal(s.operations, 12);
    assert.equal(s.missed, 3);
    assert.equal(s.accuracy, 75);
    assert.equal(s.lastDays, 1);
    assert.equal(s.status, 'upToDate');
    assert.equal(s.pending, 1);
  });

  it('sin datos no inventa valores', () => {
    const s = summary([]);
    assert.equal(s.accuracy, null);
    assert.equal(s.lastDays, null);
    assert.deepEqual(s.trend, [null, null, null, null, null, null]);
    assert.equal(s.status, 'inactive');
  });

  it('marca «necesita apoyo» por aciertos bajos o aviso R4', () => {
    assert.equal(summary([attempt(1, 3)]).status, 'needsSupport');
    assert.equal(summary([attempt(1, 6, 6, true)]).status, 'needsSupport');
  });

  it('marca inactivo después de 6 días y terminado si el grupo se archivó', () => {
    assert.equal(summary([attempt(8, 6)]).status, 'inactive');
    const s = summary([attempt(1, 6)], { groupArchived: true });
    assert.equal(s.status, 'finished');
    assert.equal(s.pending, 0);
  });

  it('agrupa la tendencia por semana', () => {
    // Semana actual empieza el lunes 26: 3 días antes del jueves 29.
    const s = summary([attempt(1, 6), attempt(5, 3)]);
    assert.equal(s.trend.at(-1), 100);
    assert.equal(s.trend.at(-2), 50);
  });

  it('incluye los últimos 5 intentos, del más nuevo al más viejo', () => {
    const list = [1, 9, 3, 2, 7, 5].map((d, i) => ({ ...attempt(d, 4), id: `t${i}`, missionId: 'm1', activityName: null }));
    const s = summary(list);
    assert.deepEqual(s.recent.map((r) => r.id), ['t0', 't3', 't2', 't5', 't4']);
    assert.equal(s.recent[0].title, null);
    assert.equal(s.recent[0].finishedAt, ago(1).toISOString());
  });

  it('el color del avatar es estable', () => {
    assert.equal(colorFor('u1'), colorFor('u1'));
  });
});
