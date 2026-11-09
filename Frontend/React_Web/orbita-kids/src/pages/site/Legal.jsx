import { useEffect } from 'react'
import { Link } from 'react-router-dom'
import './site-pages.css'

const UPDATED = '7 de noviembre de 2026'

const PAGES = {
  privacidad: {
    title: 'Aviso de privacidad',
    lead: 'Qué datos usa Órbita Kids, para qué y cómo los protege. Lo escribimos para que se entienda sin ser abogado.',
    sections: [
      {
        id: 'responsable',
        title: 'Quién es responsable',
        body: [
          'Órbita Kids es un proyecto académico (2026). Esta versión funciona con escuelas, personas y datos de demostración: no la uses todavía con datos reales de estudiantes.',
          'Si tu escuela lo adopta en producción, la escuela es responsable de los datos de su comunidad y Órbita Kids los trata por encargo suyo.',
        ],
      },
      {
        id: 'datos',
        title: 'Qué datos usamos',
        list: [
          'Personal docente y dirección: nombre, correo de la escuela, rol y último acceso.',
          'Estudiantes: nombre corto (por ejemplo, «Diego L.»), grupo y su avance en las misiones de sumas. No pedimos fotos, domicilio, CURP ni datos de salud.',
          'Datos técnicos: las sesiones abiertas (navegador, sistema y fecha) para que puedas revisarlas y cerrarlas desde «Seguridad y sesiones».',
        ],
      },
      {
        id: 'para-que',
        title: 'Para qué los usamos',
        list: [
          'Mostrar a cada docente el avance de sus grupos y quién necesita apoyo.',
          'Que la dirección administre docentes, grupos y la licencia.',
          'Mantener tu cuenta segura y sincronizar los cambios que haces sin conexión.',
        ],
        after: 'No vendemos datos, no mostramos publicidad y no hacemos rankings ni perfiles de estudiantes.',
      },
      {
        id: 'proteccion',
        title: 'Cómo los protegemos',
        list: [
          'Contraseñas: el servidor guarda solo una huella cifrada con scrypt, nunca la contraseña.',
          'Sesión: una cookie httpOnly que el código de la página no puede leer. Puedes cerrar tus sesiones en otros equipos cuando quieras.',
          'Sin conexión: lo que la app guarda en tu equipo (IndexedDB) va cifrado con AES-256 y una llave distinta para cada cuenta. Al cerrar sesión la llave se borra.',
          'Conexión: en producción todo viaja por HTTPS.',
        ],
      },
      {
        id: 'cookies',
        title: 'Cookies',
        body: ['Usamos una sola cookie, la de la sesión, necesaria para que la app funcione. No usamos cookies de publicidad ni de rastreo.'],
      },
      {
        id: 'derechos',
        title: 'Tus derechos (ARCO)',
        body: [
          'Puedes pedir acceso, rectificación, cancelación u oposición sobre tus datos, o los de tu hija o hijo, a través de la dirección de tu escuela o desde el formulario de contacto. Respondemos en un máximo de 20 días hábiles.',
        ],
      },
    ],
  },
  terminos: {
    title: 'Términos de uso',
    lead: 'Las reglas para usar Órbita Kids. Si algo no queda claro, escríbenos antes de aceptar.',
    sections: [
      {
        id: 'servicio',
        title: 'El servicio',
        body: [
          'Órbita Kids ofrece a escuelas primarias un panel para docentes y direcciones, y misiones de práctica de sumas para estudiantes de 1.º a 3.º.',
          'Esta versión es un proyecto académico con datos de demostración; no hay un contrato comercial de por medio.',
        ],
      },
      {
        id: 'cuentas',
        title: 'Cuentas',
        list: [
          'Cada docente entra con la cuenta que le da su escuela. No compartas tu contraseña ni tu sesión.',
          'La dirección decide quién tiene acceso y puede desactivar cuentas en cualquier momento.',
          'Si notas una sesión que no reconoces, ciérrala desde «Seguridad y sesiones» y avisa a tu dirección.',
        ],
      },
      {
        id: 'uso',
        title: 'Uso aceptable',
        list: [
          'Usa los datos de estudiantes solo para acompañar su aprendizaje.',
          'No intentes acceder a grupos o escuelas que no te corresponden: el servidor lo rechaza y queda registrado.',
          'No subas información que no sea necesaria para la clase.',
        ],
      },
      {
        id: 'disponibilidad',
        title: 'Disponibilidad',
        body: [
          'Buscamos que el servicio esté siempre disponible y que la app siga funcionando sin Internet, pero puede haber interrupciones. Puedes revisar el estado en la página de estado del servicio.',
        ],
      },
      {
        id: 'cambios',
        title: 'Cambios',
        body: ['Si cambiamos estos términos te avisaremos dentro de la app antes de que apliquen.'],
      },
    ],
  },
}

export default function Legal({ page }) {
  const doc = PAGES[page] || PAGES.privacidad

  useEffect(() => {
    document.title = `${doc.title} · Órbita Kids`
  }, [doc.title])

  return (
    <div className="container site-page legal">
      <header className="legal__head">
        <p className="site-eyebrow">Legal</p>
        <h1 className="site-h2 site-h2--lg">{doc.title}</h1>
        <p className="site-lead">{doc.lead}</p>
        <p className="legal__updated">Última actualización: {UPDATED}</p>
      </header>

      <div className="legal__layout">
        <nav className="legal__toc" aria-label="En esta página">
          <p>En esta página</p>
          <ul>
            {doc.sections.map((s) => (
              <li key={s.id}>
                <a href={`#${s.id}`}>{s.title}</a>
              </li>
            ))}
          </ul>
          <p className="legal__other">
            {page === 'terminos' ? <Link to="/privacidad">Aviso de privacidad</Link> : <Link to="/terminos">Términos de uso</Link>}
          </p>
        </nav>

        <article className="legal__body">
          <aside className="notice notice--info legal__notice">
            <span>
              <strong className="notice__title">Proyecto académico.</strong>{' '}
              <span className="notice__text">Estos textos son un modelo para la demostración. Antes de usar Órbita Kids con datos reales, revísalos con una persona experta en protección de datos.</span>
            </span>
          </aside>
          {doc.sections.map((s) => (
            <section key={s.id} id={s.id} className="legal__section">
              <h2>{s.title}</h2>
              {s.body?.map((p) => (
                <p key={p}>{p}</p>
              ))}
              {s.list && (
                <ul>
                  {s.list.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              )}
              {s.after && <p>{s.after}</p>}
            </section>
          ))}
          <p className="legal__contact">
            ¿Preguntas? <Link to="/contacto" className="link">Escríbenos</Link>.
          </p>
        </article>
      </div>
    </div>
  )
}
