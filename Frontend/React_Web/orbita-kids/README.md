# Órbita Kids · PWA web + backend

Versión web (React + Vite) del prototipo de Figma **Orbita Kids V1 → 06 · Web · Prototipo**: sitio público, acceso, app de escritorio instalable, espacio docente, espacio de institución, trabajo sin conexión y cuenta. 35 pantallas y 53 estados, más un **backend en Node (Express + SQLite)** que guarda los datos, valida el acceso y recibe la cola de cambios hechos sin conexión.

## Cómo correrla

Requiere **Node 22.13 o más reciente** (usa el SQLite que ya trae Node; no hay que instalar una base de datos).

```bash
npm install
npm run dev        # frontend http://localhost:5173 + API http://localhost:3001 (sin service worker)
npm run preview    # compila y sirve la PWA + API en http://localhost:4173 (aquí sí es instalable y offline)
npm start          # igual que preview, sin volver a compilar (después de npm run build)
npm test           # pruebas de la API (base de datos en memoria)
npm run db:reset   # borra la base de demostración; se vuelve a crear al arrancar
npm run lint
```

Para probar la instalación y el modo sin conexión usa `npm run preview` y ábrela en Chrome o Edge.

## Arquitectura

```text
Navegador (frontend)                                      Servidor (backend)
┌──────────────────────────────────────────┐   /api      ┌───────────────────────────────┐
│ React + React Router (pantallas)         │ ──────────▶ │ Express (server/app.js)       │
│ AppState: sesión, datos, cola de cambios │  JSON +     │  · /api/auth/*  acceso        │
│ IndexedDB cifrado por cuenta (vault.js)  │  cookie     │  · /api/data    datos por rol │
│ Service worker: guarda la app (offline)  │  httpOnly   │  · /api/sync    cola de cambios│
└──────────────────────────────────────────┘             │ SQLite (server/data/*.sqlite) │
                                                         └───────────────────────────────┘
```

- **El service worker es frontend**: corre en el navegador y solo guarda la app (JS, CSS, HTML, íconos y fuentes) para abrirla sin red. Nunca responde las rutas `/api`.
- **Datos sin conexión**: lo que llega de `/api/data` y la cola de cambios se guardan en IndexedDB **cifrados con AES-256-GCM**. Cada cuenta tiene su propia llave, que entrega el servidor al iniciar sesión y se guarda como llave no exportable. Al cerrar sesión la llave se borra; si quedaban cambios pendientes, siguen cifrados en el equipo y se envían la próxima vez que entra esa misma cuenta.
- **Cola de cambios**: todo cambio (publicar una actividad, asignar un refuerzo, aprobar a un docente…) recibe un id `chg-xxxxxx` y entra a la cola. Con red se envía enseguida; sin red espera y se envía solo al reconectar. El servidor guarda cada id: si un cambio llega dos veces, no lo aplica dos veces.
- **Seguridad**: contraseñas con `scrypt`; sesión en cookie `httpOnly` + `SameSite=Lax` (el token se guarda en la base solo como SHA-256); bloqueo 15 min tras 3 intentos; verificación en dos pasos; protección CSRF (origen + JSON); límite de intentos por IP; cabeceras de seguridad y CSP; cada cambio valida que el grupo, estudiante o docente pertenezca a quien lo envía.

## Cuentas de demostración

| Cómo entrar | Resultado |
| --- | --- |
| `ana.rios` / `orbita` o «Continuar con Google» → ana.rios | Docente (Mtra. Ana) |
| `laura.mendez` / `orbita` → código `246810` | Dos pasos → elegir espacio (docente o institución) |
| `luna.m` / `orbita` o la cuenta de estudiante en Google | 07a · Cuenta de estudiante |
| nuevo.docente en Google → «Solicitar acceso» | 07b · Sin rol → 07c · la solicitud le llega a la dirección |
| 3 contraseñas incorrectas | 07d · Cuenta bloqueada 15 minutos (`npm run db:reset` para desbloquear) |
| `/invitacion` | 10 · Aceptar invitación de Raúl Domínguez (Google, Microsoft o contraseña nueva) |

Atajos: `/demo/docente` y `/demo/institucion` abren una sesión de demostración; aceptan `?to=/ruta`. El proveedor de Google/Microsoft y los atajos están **simulados** y solo existen en modo demostración (`DEMO_MODE=0` los apaga); en producción se valida el `id_token` del proveedor (OIDC).

## API

| Método y ruta | Para qué |
| --- | --- |
| `GET /api/health` | Estado del servidor y la base (lo usa la app para saber si hay conexión) |
| `POST /api/auth/login` · `/verify` · `/resend` · `/sso` · `/logout` | Contraseña, dos pasos, proveedor simulado y cierre de sesión |
| `GET /api/auth/me` · `GET /api/auth/sessions` · `POST /api/auth/sessions/revoke` | Sesión actual y sesiones abiertas en otros equipos |
| `POST /api/auth/recover` · `/access-request` | Recuperar contraseña y pedir acceso |
| `GET /api/invitations/:token` · `POST …/accept` · `POST …/reject` | Invitaciones a docentes |
| `GET /api/data` | Todo lo que la cuenta puede ver (docente y/o institución) |
| `POST /api/sync` | Recibe la cola `{ changes: [{ id, type, payload }] }` y devuelve resultados + datos frescos |
| `POST /api/contact` · `GET /api/schools` | Formulario del sitio y directorio de escuelas |

## Pantallas y rutas

| Figma | Ruta |
| --- | --- |
| 01 Portada · 02 Planes · 03a/b Solicitar información · 35a/b/c Explorar sin cuenta | `/` · `/planes` · `/contacto` · `/explorar` |
| Privacidad · Términos · Estado del servicio · 404 (nuevas) | `/privacidad` · `/terminos` · `/estado` · cualquier ruta desconocida |
| 04a/b/c Iniciar sesión · 05 Proveedor · 06 Institución | `/login` · `/login/google` · `/login/microsoft` · `/login/institucion` |
| 07a–d Estados · 07e Recuperar · 08a/b Dos pasos · 09 Espacio · 10 Invitación | `/acceso/:estado` · `/recuperar` · `/login/verificacion` · `/espacio` · `/invitacion` |
| 11a/b Instalar · 12 Primer arranque · 13 Navegadores · 14 Versión nueva | `/instalar` · `/bienvenida` · `/instalar/navegadores` · aviso automático |
| 15a/b/c Inicio docente · 16 Mis grupos · 17a/b Grupo · 18 Estudiante | `/docente` · `/docente/grupos` · `/docente/grupos/2a` · `/docente/estudiantes/diego-l` |
| 19a/b/c Crear actividad · 20 Actividades · 21 Resultados · 22 Avisos | `/docente/actividades/nueva` · `/docente/actividades` · `/docente/resultados` · `/docente/avisos` |
| 23 Institución · 24a/b Docentes · 25a/b Grupos y códigos | `/institucion` · `/institucion/docentes` · `/institucion/grupos` |
| 26 Licencia · 27 Reportes · 28 Configuración | `/institucion/licencia` · `/institucion/reportes` · `/institucion/configuracion` |
| 29 Sin conexión · 30 Sincronización | `/docente/sin-conexion` · `/docente/sincronizacion` |
| 31 Perfil · 32 Seguridad · 33 Ayuda · 34 Cerrar sesión | `/cuenta/perfil` · `/cuenta/seguridad` · `/cuenta/ayuda` · `/cuenta/cerrar-sesion` |

## Qué hace como PWA

- **Instalable** (`vite-plugin-pwa`): manifiesto con íconos, atajos y `window-controls-overlay`. El botón «Instalar» usa el diálogo real del navegador (`beforeinstallprompt`); si no está disponible, lleva a los pasos por navegador.
- **Sin conexión**: el service worker precarga la app, cada pantalla (se descargan por partes) y las fuentes. Los datos de la cuenta se leen de IndexedDB cifrado, así que la app abre y muestra tus grupos aunque no haya Internet. En Sincronización hay un interruptor «Simular sin conexión» para la demostración.
- **Conexión real**: además de `navigator.onLine`, la app consulta `/api/health` (cada 30 s con red y cada 5 s sin ella), porque en las escuelas es común tener Wi-Fi sin Internet.
- **Actualizaciones**: con `registerType: 'prompt'`, cuando hay una versión nueva aparece la pantalla 14 y tú decides cuándo actualizar.
- **Primer arranque**: la app instalada abre `/app`, que muestra la bienvenida (12) la primera vez.

## Estructura

```text
server/            backend (Node + Express + SQLite)
  index.js         arranque (puerto 3001 en desarrollo, 4173 sirviendo dist/)
  app.js           rutas de la API, cookies, CSRF, cabeceras de seguridad
  db.js            esquema de la base de datos
  seed.js          datos iniciales (los del prototipo de Figma)
  data.js          arma los datos que ve cada rol
  changes.js       tipos de cambio que acepta /api/sync y sus validaciones
  security.js      scrypt, tokens, cookies, límites de intentos
  api.test.js      pruebas (npm test)
src/               frontend (React)
  assets/icons/    141 íconos exportados de «Web · Biblioteca de íconos»
  components/      Icon, Dialog, AppSearch, Splash, LineChart, UpdatePrompt, …
  layouts/         SiteLayout (sitio + footer) y AppShell (barra lateral + encabezado)
  pages/           site, auth, install, teacher, institution, shared, account
  data/catalog.js  etiquetas de la interfaz y tabla de planes
  state/           AppState (sesión, datos, cola), api.js, vault.js (IndexedDB cifrado),
                   optimistic.js (cambios al instante), preferences.js, format.js
```

Los datos son de demostración. La base de datos se crea sola en `server/data/orbita.sqlite` la primera vez que arranca el servidor.
