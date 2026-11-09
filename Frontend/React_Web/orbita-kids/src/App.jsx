import { Suspense, lazy, useEffect, useState } from 'react'
import { BrowserRouter, Navigate, Route, Routes, useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom'
import { AppStateProvider, useApp } from './state/AppState'
import { api } from './state/api'
import { applyPreferences, readPreferences } from './state/preferences'
import SiteLayout from './layouts/SiteLayout'
import AppShell from './layouts/AppShell'
import Toasts from './components/Toasts'
import UpdatePrompt from './components/UpdatePrompt'
import Splash from './components/Splash'

// Cada pantalla se descarga cuando se usa; el service worker las guarda todas para el modo sin conexión.
const Home = lazy(() => import('./pages/site/Home'))
const Plans = lazy(() => import('./pages/site/Plans'))
const Contact = lazy(() => import('./pages/site/Contact'))
const Explore = lazy(() => import('./pages/site/Explore'))
const Legal = lazy(() => import('./pages/site/Legal'))
const Status = lazy(() => import('./pages/site/Status'))
const NotFound = lazy(() => import('./pages/site/NotFound'))
const Login = lazy(() => import('./pages/auth/Login'))
const ProviderChooser = lazy(() => import('./pages/auth/ProviderChooser'))
const InstitutionSearch = lazy(() => import('./pages/auth/InstitutionSearch'))
const AccessState = lazy(() => import('./pages/auth/AccessState'))
const RecoverPassword = lazy(() => import('./pages/auth/RecoverPassword'))
const TwoFactor = lazy(() => import('./pages/auth/TwoFactor'))
const ChooseSpace = lazy(() => import('./pages/auth/ChooseSpace'))
const Invitation = lazy(() => import('./pages/auth/Invitation'))
const Install = lazy(() => import('./pages/install/Install'))
const FirstRun = lazy(() => import('./pages/install/FirstRun'))
const Browsers = lazy(() => import('./pages/install/Browsers'))
const TeacherHome = lazy(() => import('./pages/teacher/TeacherHome'))
const Groups = lazy(() => import('./pages/teacher/Groups'))
const GroupDetail = lazy(() => import('./pages/teacher/GroupDetail'))
const StudentDetail = lazy(() => import('./pages/teacher/StudentDetail'))
const CreateActivity = lazy(() => import('./pages/teacher/CreateActivity'))
const Activities = lazy(() => import('./pages/teacher/Activities'))
const Results = lazy(() => import('./pages/teacher/Results'))
const Notices = lazy(() => import('./pages/teacher/Notices'))
const InstitutionHome = lazy(() => import('./pages/institution/InstitutionHome'))
const Teachers = lazy(() => import('./pages/institution/Teachers'))
const SchoolGroups = lazy(() => import('./pages/institution/SchoolGroups'))
const License = lazy(() => import('./pages/institution/License'))
const SchoolReports = lazy(() => import('./pages/institution/SchoolReports'))
const Settings = lazy(() => import('./pages/institution/Settings'))
const Offline = lazy(() => import('./pages/shared/Offline'))
const Sync = lazy(() => import('./pages/shared/Sync'))
const Help = lazy(() => import('./pages/shared/Help'))
const Profile = lazy(() => import('./pages/account/Profile'))
const Security = lazy(() => import('./pages/account/Security'))
const Logout = lazy(() => import('./pages/account/Logout'))







applyPreferences(readPreferences())

// Lleva arriba al cambiar de pantalla, o al ancla si la URL trae #.
function ScrollManager() {
  const { pathname, hash } = useLocation()
  useEffect(() => {
    if (hash) {
      const el = document.getElementById(hash.slice(1))
      if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'start' })
        return
      }
    }
    window.scrollTo(0, 0)
  }, [pathname, hash])
  return null
}

function readFirstRunDone() {
  try {
    return !!localStorage.getItem('orbita-kids:first-run-done')
  } catch {
    return true
  }
}

// Entrada de la app instalada (start_url del manifiesto).
function AppEntry() {
  const { session } = useApp()
  if (!readFirstRunDone()) return <Navigate to="/bienvenida" replace />
  return <Navigate to={session ? `/${session.space}` : '/login'} replace />
}

// Entrada rápida de demostración: /demo/docente o /demo/institucion (?to=/ruta). Abre una sesión real en el servidor.
function DemoEntry() {
  const { space } = useParams()
  const [params] = useSearchParams()
  const { session, user, online, completeSignIn, chooseSpace } = useApp()
  const navigate = useNavigate()
  const [error, setError] = useState('')
  const to = params.get('to')
  const target = space === 'institucion' ? 'institucion' : 'docente'
  const account = target === 'institucion' ? 'laura' : 'ana'

  useEffect(() => {
    const dest = to && to.startsWith('/') && !to.startsWith('//') ? to : `/${target}`
    if (session?.account === account && user) {
      chooseSpace(target)
      navigate(dest, { replace: true })
      return
    }
    if (!online) return
    let cancelled = false
    api('/auth/demo', { method: 'POST', body: { space: target } })
      .then((res) => completeSignIn(res, target))
      .then(() => !cancelled && navigate(dest, { replace: true }))
      .catch((err) => !cancelled && setError(err.message))
    return () => {
      cancelled = true
    }
  }, [account, target, to, session?.account, user, online, completeSignIn, chooseSpace, navigate])

  return (
    <div className="splash" role="status">
      <span className="splash__orbit" aria-hidden />
      <p>{error || (online ? 'Abriendo la demostración…' : 'Necesitas conexión para abrir la demostración.')}</p>
    </div>
  )
}

function sharedRoutes() {
  return (
    <>
      <Route path="sincronizacion" element={<Sync />} />
      <Route path="sin-conexion" element={<Offline />} />
      <Route path="ayuda" element={<Help eyebrow="Equipo" />} />
    </>
  )
}

export default function App() {
  return (
    <AppStateProvider>
      <BrowserRouter>
        <ScrollManager />
        <Suspense fallback={<Splash text="Cargando…" />}>
        <Routes>
          {/* Sitio público */}
          <Route element={<SiteLayout />}>
            <Route index element={<Home />} />
            <Route path="explorar" element={<Explore />} />
            <Route path="planes" element={<Plans />} />
            <Route path="contacto" element={<Contact />} />
            <Route path="instalar/navegadores" element={<Browsers />} />
            <Route path="privacidad" element={<Legal page="privacidad" />} />
            <Route path="terminos" element={<Legal page="terminos" />} />
            <Route path="estado" element={<Status />} />
            <Route path="*" element={<NotFound />} />
          </Route>

          {/* Acceso */}
          <Route path="login" element={<Login />} />
          <Route path="login/institucion" element={<InstitutionSearch />} />
          <Route path="login/verificacion" element={<TwoFactor />} />
          <Route path="login/:provider" element={<ProviderChooser />} />
          <Route path="acceso/:state" element={<AccessState />} />
          <Route path="recuperar" element={<RecoverPassword />} />
          <Route path="espacio" element={<ChooseSpace />} />
          <Route path="invitacion" element={<Invitation />} />

          {/* App de escritorio */}
          <Route path="app" element={<AppEntry />} />
          <Route path="instalar" element={<Install />} />
          <Route path="bienvenida" element={<FirstRun />} />
          <Route path="demo/:space" element={<DemoEntry />} />

          {/* Docente */}
          <Route path="docente" element={<AppShell space="docente" />}>
            <Route index element={<TeacherHome />} />
            <Route path="grupos" element={<Groups />} />
            <Route path="grupos/:groupId" element={<GroupDetail />} />
            <Route path="estudiantes/:studentId" element={<StudentDetail />} />
            <Route path="actividades" element={<Activities />} />
            <Route path="actividades/nueva" element={<CreateActivity />} />
            <Route path="resultados" element={<Results />} />
            <Route path="avisos" element={<Notices />} />
            {sharedRoutes()}
          </Route>

          {/* Institución */}
          <Route path="institucion" element={<AppShell space="institucion" />}>
            <Route index element={<InstitutionHome />} />
            <Route path="docentes" element={<Teachers />} />
            <Route path="grupos" element={<SchoolGroups />} />
            <Route path="licencia" element={<License />} />
            <Route path="reportes" element={<SchoolReports />} />
            <Route path="configuracion" element={<Settings />} />
            <Route path="avisos" element={<Notices space="institucion" />} />
            {sharedRoutes()}
          </Route>

          {/* Cuenta */}
          <Route path="cuenta" element={<AppShell />}>
            <Route index element={<Navigate to="perfil" replace />} />
            <Route path="perfil" element={<Profile />} />
            <Route path="seguridad" element={<Security />} />
            <Route path="ayuda" element={<Help />} />
          </Route>
          <Route path="cuenta/cerrar-sesion" element={<Logout />} />

        </Routes>
        </Suspense>
        <UpdatePrompt />
        <Toasts />
      </BrowserRouter>
    </AppStateProvider>
  )
}
