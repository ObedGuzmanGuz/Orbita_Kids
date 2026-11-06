import assert from 'node:assert/strict';
import { describe, it } from 'node:test';

import { HttpError } from '../src/lib/errors.js';
import { isoDate, parseIfMatch, syncId } from '../src/lib/http.js';

const fakeReq = (body, headers = {}) => ({ body, get: (h) => headers[h] });
const ID = '0b6f2c1e-6d3a-4f5e-9a1b-2c3d4e5f6a7b';

describe('If-Match', () => {
  it('lee la versión con o sin comillas', () => {
    assert.equal(parseIfMatch('"3"'), 3);
    assert.equal(parseIfMatch('W/"3"'), 3);
    assert.equal(parseIfMatch('7'), 7);
    assert.equal(parseIfMatch(undefined), null);
    assert.equal(parseIfMatch('*'), null);
  });

  it('rechaza valores que no son versión', () => {
    assert.throws(() => parseIfMatch('"abc"'), HttpError);
  });
});

describe('cuerpo de la cola', () => {
  it('acepta id y Idempotency-Key iguales', () => {
    assert.equal(syncId(fakeReq({ id: ID }, { 'Idempotency-Key': ID })), ID);
    assert.equal(syncId(fakeReq({ id: ID })), ID);
  });

  it('rechaza si no coinciden o el id no es UUID', () => {
    assert.throws(() => syncId(fakeReq({ id: ID }, { 'Idempotency-Key': 'otro' })), HttpError);
    assert.throws(() => syncId(fakeReq({ id: 'a1' })), HttpError);
  });
});

describe('fechas', () => {
  it('acepta la salida de DateTime.toIso8601String() de Dart', () => {
    assert.ok(isoDate.parse('2026-10-20T00:00:00.000Z') instanceof Date);
    assert.equal(isoDate.safeParse('mañana').success, false);
  });

  it('sin zona se toma como UTC (no depende de la zona del servidor)', () => {
    assert.equal(isoDate.parse('2026-10-20T00:00:00.000').toISOString(), '2026-10-20T00:00:00.000Z');
    assert.equal(isoDate.parse('2026-10-20T00:00:00.000-06:00').toISOString(), '2026-10-20T06:00:00.000Z');
  });
});
