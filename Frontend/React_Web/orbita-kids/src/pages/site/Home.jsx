import { useEffect } from 'react'
import { Link } from 'react-router-dom'
import Icon from '../../components/Icon'
import { useApp } from '../../state/AppState'
import OrbitFigure from '../../components/OrbitFigure'
import './home.css'

const AUDIENCES = [
  {
    icon: '009',
    title: 'Estudiantes',
    where: 'En el teléfono o la tableta de la escuela',
    text: 'Juegan misiones de sumas por niveles, con pistas cuando se atoran y pausas para moverse. Entran con el código de su grupo.',
  },
  {
    icon: '010',
    title: 'Docentes',
    where: 'En tu computadora',
    text: 'Crean y asignan actividades, ven quién necesita apoyo y exportan los resultados de cada grupo.',
  },
  {
    icon: '011',
    title: 'Dirección',
    where: 'En la computadora de la escuela',
    text: 'Invita docentes, reparte los lugares de la licencia y revisa el avance por grado.',
  },
]

const OFFLINE = [
  {
    icon: '005',
    title: 'Abre sin Internet',
    text: 'La app queda guardada en tu computadora. Si se cae la red, abre con lo último que sincronizaste y puedes seguir revisando grupos y preparando actividades.',
  },
  {
    icon: '007',
    title: 'Tus datos, cifrados',
    text: 'Lo que se guarda en el equipo va cifrado con una llave distinta para cada cuenta. Al cerrar sesión, nadie más puede leerlo, ni en una computadora compartida.',
  },
  {
    icon: '059',
    title: 'Nada se pierde',
    text: 'Cada cambio hecho sin conexión recibe un identificador único y espera en una cola. Al volver Internet se envía solo, y el servidor nunca lo aplica dos veces.',
  },
]

const STEPS = [
  { title: 'La dirección solicita su plan', text: 'Llena el formulario y recibe una propuesta con su licencia.' },
  { title: 'Invita a sus docentes', text: 'Cada docente entra con el correo de la escuela, por Google o Microsoft.' },
  { title: 'Cada grupo recibe su código', text: 'Los códigos salen de la licencia y la dirección los reparte por grado.' },
  { title: 'Los niños empiezan sus misiones', text: 'Entran a la app móvil con el código de su grupo y su avance llega a tu computadora.' },
]

const FAQ = [
  {
    q: '¿Y si en la escuela falla el Internet?',
    a: 'La app abre con lo último que sincronizaste. Puedes revisar tus grupos y preparar actividades; los cambios se envían solos al reconectar, sin perder nada.',
  },
  {
    q: '¿Hay que instalar algo?',
    a: 'Se instala desde Chrome o Edge en un clic, sin tienda de apps. Abre en su propia ventana y se actualiza sola.',
  },
  {
    q: '¿Quién ve los datos de mis estudiantes?',
    a: 'Solo las y los docentes de cada grupo y la dirección de la escuela. No hay rankings ni diagnósticos: la app te dice quién necesita apoyo, no quién va peor.',
  },
  {
    q: '¿Cómo entran los niños?',
    a: 'Desde la app móvil, con el código de grupo que tú compartes. Un adulto les ayuda a entrar la primera vez.',
  },
  {
    q: '¿Dónde se guardan los datos?',
    a: 'En el servidor de Órbita Kids y, para trabajar sin conexión, en tu equipo cifrados por cuenta. Las contraseñas nunca se guardan: el servidor solo conserva una huella cifrada.',
  },
  {
    q: '¿Cuánto cuesta?',
    a: 'Hay un plan gratuito para empezar y planes para grupos, escuelas e instituciones, con precios en pesos mexicanos.',
    link: { to: '/planes', label: 'Ver planes' },
  },
]

export default function Home() {
  const { session, user } = useApp()
  useEffect(() => {
    document.title = 'Órbita Kids · Práctica de sumas para primaria'
  }, [])

  return (
    <>
      <section className="hero">
        <div className="container hero__inner">
          <div className="hero__copy">
            <p className="hero__eyebrow">Para docentes y direcciones de 1.º a 3.º de primaria</p>
            <h1 className="hero__title">Tus estudiantes practican sumas. Tú sabes a quién ayudar primero.</h1>
            <p className="hero__text">
              Las niñas y los niños juegan misiones de sumas en el teléfono. En tu computadora ves su avance, asignas
              actividades y administras la escuela, aunque se caiga el Internet.
            </p>
            <div className="hero__actions">
              <Link to="/explorar" className="btn btn--xl hero__cta">Explorar sin cuenta</Link>
              {session && user ? (
                <Link to={`/${session.space}`} className="hero__login">Hola, {user.short}: ir a mi panel</Link>
              ) : (
                <Link to="/login" className="hero__login">Ya tengo cuenta, iniciar sesión</Link>
              )}
            </div>
            <ul className="hero__perks">
              <li><Icon n="005" />Funciona sin conexión</li>
              <li><Icon n="006" />Se instala desde el navegador</li>
              <li><Icon n="007" style={{ marginTop: 2 }} />Entras con la cuenta de tu escuela</li>
            </ul>
          </div>
          <OrbitFigure />
        </div>
      </section>

      <section className="site-section">
        <div className="container audiences">
          <div className="audiences__intro">
            <h2 className="site-h2 site-h2--lg">Una plataforma, tres maneras de entrar</h2>
            <p className="site-lead">
              Cada persona usa el dispositivo que le acomoda y ve solo lo que necesita. Lo que un estudiante juega en el
              teléfono aparece en tu computadora al sincronizar.
            </p>
          </div>
          <ul className="audiences__list">
            {AUDIENCES.map((a) => (
              <li key={a.title}>
                <Icon n={a.icon} />
                <div>
                  <h3>
                    <span className="audiences__title">{a.title}</span>
                    <span className="audiences__where">{a.where}</span>
                  </h3>
                  <p>{a.text}</p>
                </div>
              </li>
            ))}
          </ul>
        </div>
      </section>

      <section className="site-section offline-band" id="sin-internet" aria-labelledby="sin-internet-title">
        <div className="container">
          <div className="offline-band__head">
            <div>
              <p className="site-eyebrow">Hecho para escuelas reales</p>
              <h2 className="site-h2 site-h2--lg" id="sin-internet-title">
                Funciona aunque falle el Internet
              </h2>
            </div>
            <p className="site-lead">
              En muchas escuelas el Wi-Fi va y viene. Órbita Kids está hecha para eso: sigues trabajando y todo se pone al día solo.
            </p>
          </div>
          <div className="offline-band__grid">
            {OFFLINE.map((f) => (
              <article key={f.title} className="feature-card">
                <span className="feature-card__icon">
                  <Icon n={f.icon} />
                </span>
                <h3>{f.title}</h3>
                <p>{f.text}</p>
              </article>
            ))}
          </div>
          <ol className="sync-story" aria-label="Así se ve en la app">
            <li>
              <span className="chip chip--warning">
                <Icon n="127" />
                Sin conexión · datos de hoy 8:15
              </span>
              <small>Se cae la red: sigues trabajando</small>
            </li>
            <li>
              <span className="chip chip--warning">2 cambios en cola</span>
              <small>Tus cambios esperan, cifrados</small>
            </li>
            <li>
              <span className="chip chip--success">
                <Icon n="062" />
                Sincronizado hoy 8:40
              </span>
              <small>Vuelve Internet: todo se envía solo</small>
            </li>
          </ol>
        </div>
      </section>

      <section className="site-section steps-section" id="como-funciona">
        <div className="container">
          <h2 className="site-h2">Cómo empieza una escuela</h2>
          <ol className="steps">
            {STEPS.map((s, i) => (
              <li key={s.title} className={i === STEPS.length - 1 ? 'is-current' : ''}>
                <div className="steps__marker">
                  <span>{i + 1}</span>
                </div>
                <h3>{s.title}</h3>
                <p>{s.text}</p>
              </li>
            ))}
          </ol>
        </div>
      </section>

      <section className="site-section site-section--tint" id="preguntas">
        <div className="container faq-layout">
          <div className="faq-layout__intro">
            <h2 className="site-h2">Lo que suelen preguntarnos</h2>
            <p className="site-lead">¿Tienes otra duda? Escríbenos y te respondemos en menos de 2 días hábiles.</p>
            <div className="faq__cta">
              <Link to="/explorar" className="btn btn--primary btn--lg">Explorar sin cuenta</Link>
              <Link to="/contacto" className="btn btn--secondary btn--lg">Hacer una pregunta</Link>
            </div>
          </div>
          <div className="faq">
            {FAQ.map((f, i) => (
              <details key={f.q} className="faq__item" open={i === 0}>
                <summary>
                  {f.q}
                  <span className="faq__chevron" aria-hidden />
                </summary>
                <p>
                  {f.a}{' '}
                  {f.link && (
                    <Link to={f.link.to} className="link">
                      {f.link.label}
                    </Link>
                  )}
                </p>
              </details>
            ))}
          </div>
        </div>
      </section>

      <section className="site-section">
        <div className="container plans-teaser">
          <div>
            <h2 className="site-h2">Planes</h2>
            <p className="site-lead">Gratis para empezar. Planes para grupos, escuelas e instituciones, en pesos mexicanos.</p>
          </div>
          <Link to="/planes" className="btn btn--secondary">Ver planes</Link>
        </div>
      </section>
    </>
  )
}
