// Pruebas de la API con una base de datos en memoria: npm test
import assert from 'node:assert/strict'
import { after, before, describe, test } from 'node:test'
import { createApp } from './app.js'
import { openDb } from './db.js'

let server
let base

before(async () => {
  const db = await openDb(':memory:')
  server = createApp(db).listen(0)
  await new Promise((resolve) => server.once('listening', resolve))
  base = `http://localhost:${server.address().port}/api`
})
after(() => server.close())

// Cliente mínimo que guarda la cookie de sesión, como haría el navegador.
function client() {
  let cookie = ''
  return async (path, { method = 'GET', body, headers = {} } = {}) => {
    const res = await fetch(base + path, {
      method,
      headers: { ...(body ? { 'content-type': 'application/json' } : {}), ...(cookie ? { cookie } : {}), ...headers },
      body: body ? JSON.stringify(body) : undefined,
    })
    const set = res.headers.get('set-cookie')
    if (set) cookie = set.split(';')[0]
    return { status: res.status, body: await res.json() }
  }
}

async function signIn(username) {
  const api = client()
  const r = await api('/auth/login', { method: 'POST', body: { username, password: 'orbita' } })
  if (r.body.next === '2fa') await api('/auth/verify', { method: 'POST', body: { challenge: r.body.challenge, code: '246810' } })
  return api
}

describe('acceso', () => {
  test('contraseña incorrecta descuenta intentos y la tercera bloquea', async () => {
    const api = client()
    const a = await api('/auth/login', { method: 'POST', body: { username: 'nadie.existe', password: 'x' } })
    assert.equal(a.status, 401)
    assert.equal(a.body.remaining, 2)
    await api('/auth/login', { method: 'POST', body: { username: 'nadie.existe', password: 'x' } })
    const c = await api('/auth/login', { method: 'POST', body: { username: 'nadie.existe', password: 'x' } })
    assert.equal(c.status, 423)
  })

  test('docente entra y recibe su llave de datos', async () => {
    const api = client()
    const r = await api('/auth/login', { method: 'POST', body: { username: 'ana.rios@escuela.example', password: 'orbita' } })
    assert.equal(r.status, 200)
    assert.equal(r.body.user.short, 'Mtra. Ana')
    assert.equal(Buffer.from(r.body.dataKey, 'base64').length, 32)
    assert.equal((await api('/auth/me')).status, 200)
  })

  test('la dirección pasa por la verificación en dos pasos', async () => {
    const api = client()
    const r = await api('/auth/login', { method: 'POST', body: { username: 'laura.mendez', password: 'orbita' } })
    assert.equal(r.body.next, '2fa')
    const bad = await api('/auth/verify', { method: 'POST', body: { challenge: r.body.challenge, code: '000000' } })
    assert.equal(bad.status, 401)
    const ok = await api('/auth/verify', { method: 'POST', body: { challenge: r.body.challenge, code: '246810' } })
    assert.equal(ok.status, 200)
    assert.match(ok.body.spaces.institucion, /5 docentes · 1 solicitud/)
  })

  test('las cuentas de estudiante no entran al panel', async () => {
    const r = await client()('/auth/login', { method: 'POST', body: { username: 'luna.m', password: 'orbita' } })
    assert.equal(r.status, 403)
    assert.equal(r.body.error, 'student')
  })

  test('cerrar sesión invalida la cookie en el servidor', async () => {
    const api = await signIn('ana.rios')
    await api('/auth/logout', { method: 'POST' })
    assert.equal((await api('/data')).status, 401)
  })
})

describe('datos', () => {
  test('los números del grupo 2° A coinciden con el diseño', async () => {
    const { body } = await (await signIn('ana.rios'))('/data')
    const g = body.docente.groups.find((x) => x.id === '2a')
    assert.deepEqual([g.students, g.score, g.pending, g.support], [12, 75, 16, 3])
    assert.equal(body.docente.reports['2a'].attempts, 561)
    assert.equal(body.institucion, undefined, 'una docente no ve datos de la institución')
  })

  test('la licencia suma a todos los estudiantes del ciclo', async () => {
    const { body } = await (await signIn('laura.mendez'))('/data')
    assert.deepEqual([body.institucion.license.used, body.institucion.license.total], [118, 150])
  })
})

describe('sincronización', () => {
  test('el mismo cambio enviado dos veces se aplica una sola vez', async () => {
    const api = await signIn('ana.rios')
    const change = {
      id: 'chg-test01',
      type: 'publish-activity',
      title: 'Publicar «Prueba»',
      payload: { activityId: 'act-test01', groupId: '2a', name: 'Prueba repetida', mode: 'visual', level: 2, count: 8, due: '2026-11-20', instructions: '' },
    }
    const first = await api('/sync', { method: 'POST', body: { changes: [change] } })
    const second = await api('/sync', { method: 'POST', body: { changes: [change] } })
    assert.equal(first.body.results[0].status, 'applied')
    assert.equal(second.body.results[0].duplicate, true)
    assert.equal(second.body.data.docente.activities.filter((a) => a.name === 'Prueba repetida').length, 1)
  })

  test('un cambio fuera del rol se rechaza', async () => {
    const api = await signIn('ana.rios')
    const r = await api('/sync', { method: 'POST', body: { changes: [{ id: 'chg-test02', type: 'invite-teacher', payload: { email: 'x@escuela.example' } }] } })
    assert.equal(r.body.results[0].status, 'rejected')
  })

  test('un grupo ajeno se rechaza', async () => {
    const api = await signIn('ana.rios')
    const r = await api('/sync', {
      method: 'POST',
      body: { changes: [{ id: 'chg-test03', type: 'publish-activity', payload: { groupId: '3b', name: 'Ajena', mode: 'visual', level: 2, count: 8 } }] },
    })
    assert.equal(r.body.results[0].status, 'rejected')
  })

  test('aprobar una solicitud cambia la plantilla docente', async () => {
    const api = await signIn('laura.mendez')
    const r = await api('/sync', { method: 'POST', body: { changes: [{ id: 'chg-test04', type: 'review-teacher', payload: { staffId: 'sofia', decision: 'approve' } }] } })
    assert.equal(r.body.results[0].status, 'applied')
    assert.equal(r.body.data.institucion.teachers.find((t) => t.id === 'sofia').status, 'active')
  })
})

describe('protecciones', () => {
  test('rechaza escrituras desde otro origen', async () => {
    const api = await signIn('ana.rios')
    const r = await api('/sync', { method: 'POST', body: { changes: [] }, headers: { origin: 'https://otro-sitio.example' } })
    assert.equal(r.status, 403)
  })

  test('el formulario de contacto valida y entrega un folio', async () => {
    const api = client()
    const bad = await api('/contact', { method: 'POST', body: { school: '', email: 'no' } })
    assert.equal(bad.status, 422)
    const ok = await api('/contact', { method: 'POST', body: { school: 'Primaria X', person: 'Dirección', email: 'dir@escuela.mx', privacy: true, folio: 'SOL-2026-1234' } })
    assert.equal(ok.body.folio, 'SOL-2026-1234')
    const again = await api('/contact', { method: 'POST', body: { school: 'Primaria X', person: 'Dirección', email: 'dir@escuela.mx', privacy: true, folio: 'SOL-2026-1234' } })
    assert.equal(again.body.duplicate, true)
  })
})
