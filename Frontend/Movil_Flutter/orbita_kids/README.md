# Órbita Kids

App Flutter nativa (sin WebView) de **Órbita Kids Studios** para practicar sumas explorando planetas. Implementa las pantallas 01 a 59 del archivo de Figma [Órbita Kids V1 · 03 Mockups](https://www.figma.com/design/PRteYbnQPyx8MJ6Y04NnOb/Orbita-Kids-V1?node-id=2-3), que es la referencia de diseño vigente y amplía el prototipo `Órbita Kids Prototipo.html`. Conserva su identidad: paleta, tipografías Fredoka y Nunito, logotipos, Orbi y los astronautas.

Pantallas agregadas o ajustadas a partir de Figma: 01 Splash (astronauta y Orbi sobre la luna), 03 Onboarding de 5 pasos, 12a Recuperar cuenta, 54 Explorar sin cuenta, 55 Inicio sin cuenta, 56 Más (modo explorar), 57 Disponible con cuenta, 58 Carga esqueleto (inicio, listas y mapa) y 59 Conoce a Orbi.

- Flutter 3.47 · Material 3 · Riverpod 3 · GoRouter · Dio · SharedPreferences · flutter_secure_storage · SQLite (sqflite) · connectivity_plus · flutter_local_notifications · flutter_appauth (OIDC + PKCE) · flutter_tts.
- Roles: **estudiante** y **docente**. La institución solo da contexto (cuentas, grupos, licencias); no hay panel institucional.

## Cómo ejecutar

```bash
flutter pub get
flutter run                       # modo demo (sin configuración)
flutter test                      # 97 pruebas: dominio, arquitectura, widgets, datos y humo
```

### Con el backend (modo demo con servidor)

Para probar la app contra el backend local (`../backend`) sin Keycloak. Se entra con las cuentas demo, pero el progreso, las actividades, los grupos y los reportes van y vienen del servidor. El aviso dice «MODO DEMO CON SERVIDOR».

```bash
# 1) Backend (ver ../backend/README.md): AUTH_MODE=dev y datos sembrados
cd ../backend && docker compose up -d && npm run db:migrate && npm run db:seed && npm run dev

# 2) App en Chrome (el puerto 5000 es el que permite CORS_ORIGINS del backend)
flutter run -d chrome --web-port 5000 \
  --dart-define=API_BASE_URL=http://localhost:3000/v1 \
  --dart-define=API_DEV_AUTH=true

# Prueba de punta a punta (docente publica → estudiante resuelve → reporte)
ORBITA_API=http://localhost:3000/v1 flutter test test/integration
```

`luna.astro` y `ana.rios` se identifican ante el backend como `dev-luna-astro` y `dev-ana-rios` (`Bearer dev:<id>`). `API_DEV_AUTH` solo funciona sin Keycloak y el backend rechaza AUTH_MODE=dev en producción. En un emulador de Android el backend está en `http://10.0.2.2:3000/v1`, y hay que permitir HTTP sin TLS para probar.

### Modo demo

Si no se definen `KEYCLOAK_ISSUER` y `KEYCLOAK_CLIENT_ID`, la app arranca en **modo demo**. Un aviso amarillo «MODO DEMO» aparece en el login, el registro, los perfiles y los selectores de identidad.

| Cuenta demo | Usuario | Contraseña | Rol |
|---|---|---|---|
| Luna (2° A) | `luna.astro` | `orbita123` | Estudiante |
| Ana Ríos | `ana.rios` | `orbita123` | Docente |

- **Google, Facebook e institución:** en demo se abre un selector de identidades ficticias, rotulado como «Simulación». Desde ahí también se pueden probar los escenarios de error.
- **Código de desbloqueo y de verificación:** `482915`.
- **Códigos de grupo:** `ORB-2A7K` (válido), `ORB-OLD1` (vencido), `ORB-1C2P` (grupo archivado), `ORB-FULL` (licencia sin lugares).
- **Datos demo:** viven en `lib/shared/demo/demo_data.dart` y están marcados como ficticios (dominios `*.example`).
- **Sincronización en demo:** como no hay servidor, nada se marca como enviado. Los registros se quedan «pendientes · servidor pendiente».

## Configuración pendiente (`--dart-define`)

La app no contiene secretos: usa un cliente **público** con PKCE.

| Variable | Obligatoria | Ejemplo / valor por defecto | Uso |
|---|---|---|---|
| `KEYCLOAK_ISSUER` | Sí | `https://auth.tu-dominio/realms/orbita` | Discovery OIDC |
| `KEYCLOAK_CLIENT_ID` | Sí | `orbita-kids-app` | Cliente público (sin secreto) |
| `KEYCLOAK_REDIRECT_URI` | No | `com.orbitastudio.orbitakids:/oauthredirect` | Redirect de la app |
| `KEYCLOAK_POST_LOGOUT_REDIRECT_URI` | No | `com.orbitastudio.orbitakids:/logout` | Cierre de sesión remoto |
| `KEYCLOAK_IDP_GOOGLE` | No | `google` | Alias del IdP en Keycloak (`kc_idp_hint`) |
| `KEYCLOAK_IDP_FACEBOOK` | No | `facebook` | Alias del IdP |
| `KEYCLOAK_IDP_INSTITUTION` | No | *(vacío: Keycloak muestra su selector)* | Alias del IdP institucional |
| `KEYCLOAK_ROLE_STUDENT` | No | `student` | Rol de realm para estudiantes |
| `KEYCLOAK_ROLE_TEACHER` | No | `teacher` | Rol de realm para docentes |
| `API_BASE_URL` | No | `https://api.tu-dominio/v1` | Backend de Órbita Kids (`../backend`) |
| `API_DEV_AUTH` | No | `false` | Solo desarrollo, sin Keycloak: cuentas demo contra el backend |

```bash
flutter run \
  --dart-define=KEYCLOAK_ISSUER=https://auth.tu-dominio/realms/orbita \
  --dart-define=KEYCLOAK_CLIENT_ID=orbita-kids-app \
  --dart-define=API_BASE_URL=https://api.tu-dominio/v1
```

### Lo que hay que configurar en Keycloak

1. **Cliente** `orbita-kids-app`: público, *Standard flow* activo, *PKCE S256* obligatorio, *Direct access grants* desactivado. En *Valid redirect URIs* van `com.orbitastudio.orbitakids:/oauthredirect` y `com.orbitastudio.orbitakids:/logout`. Agrega el scope `offline_access` si se quiere una sesión persistente larga.
2. **Roles de realm** `student` y `teacher`, asignados por el backend o la institución. Sin rol, la app muestra «Tu cuenta aún no tiene rol».
3. **Identity providers:** Google (alias `google`), Facebook (alias `facebook`) y el de la institución (Google Workspace for Education por OIDC o Microsoft Entra ID por SAML).
4. **Brute force detection:** actívalo para bloquear la cuenta en la página de Keycloak. El bloqueo de 3 intentos y 15 minutos del formulario de la app solo aplica en modo demo, porque con Keycloak la contraseña se escribe en su página segura.
5. **Registro** (`prompt=create`) y «¿Olvidaste tu contraseña?» habilitados en el realm. Los usa *Crear cuenta* y *Recuperar cuenta*.
6. **Mappers** `given_name`, `email`, `preferred_username` y `realm_access.roles` en el access token.

### Plataformas

- **Android:** el `applicationId` es `com.orbitastudio.orbitakids`. El esquema del redirect está en `android/app/build.gradle.kts` (`manifestPlaceholders["appAuthRedirectScheme"]`) y tiene activado *core library desugaring* (lo pide flutter_local_notifications).
- **iOS:** el esquema `com.orbitastudio.orbitakids` está registrado en `ios/Runner/Info.plist` (`CFBundleURLTypes`). Pendiente: probarlo en macOS y ajustar el *deployment target* que pidan los pods.
- **Pendiente de marca:** el ícono del launcher todavía es el de Flutter; usar `assets/brand/sym.png` para generarlo. La firma de *release* también está pendiente.

## Backend

El backend vive en `../backend` (Node.js + MySQL; contrato completo en su README). Las rutas están en `lib/core/network/api_client.dart` (`ApiEndpoints`), relativas a `API_BASE_URL`. La app usa el servidor solo si hay `API_BASE_URL` y una sesión que el backend reconozca (Keycloak o `API_DEV_AUTH`). Si no, sigue en demo o deja todo pendiente en el teléfono.

| Constante | Ruta | La usa |
|---|---|---|
| `ApiEndpoints.me` | `GET /me` al entrar (grupo e institución) · `POST /me` desde la cola | Auth, Editar perfil |
| `ApiEndpoints.attempts` | `POST /attempts` (idempotente por `Idempotency-Key` = UUID) | Cola de sincronización |
| `ApiEndpoints.activities` | `GET /activities` · `POST /activities` (409/412 ante conflicto) | Docente y estudiante |
| `ApiEndpoints.groupCodes` | `POST /group-codes/check` (público) | Registro de estudiante |
| `ApiEndpoints.groups` | `GET/POST /groups` · `PATCH /groups/:id` · `GET /groups/:id/students` | Docente |
| `ApiEndpoints.students` | `GET /students/:id` (con sus últimos intentos) | Detalle del estudiante |
| `ApiEndpoints.planRequests` | `POST /plan-requests` (sin pagos) | Planes |
| `ApiEndpoints.supportReports` | `POST /support-reports` | Ayuda |
| `ApiEndpoints.sessions` | *pendiente en el backend* (`null`) | Seguridad |
| *(sin definir)* | Desbloqueo con código y reenvío de correos | Bloqueo / desbloqueo |
| *(sin definir)* | Notificaciones push del servidor | Avisos |

Contrato de la cola (`HttpSyncGateway`): un `POST` con `{id, ...payload}`. 2xx confirma el registro. 409/412 lo marcan como conflicto y no se sobrescribe. Un rechazo de datos o permisos (400, 403, 404, 422) también queda en conflicto con el mensaje del servidor, porque reintentarlo no lo arregla. Lo demás (sin red, 401, 5xx) se reintenta con espera exponencial (15 s hasta un máximo de 30 min).

**Sin Internet:** las lecturas del servidor (grupos, estudiantes, actividades) se guardan por cuenta en `api_cache` y se muestran desde ahí. Los borradores y lo publicado que no ha llegado se combinan con la lista del servidor.

**Pendiente en la app:** llamar a `POST /group-codes/redeem` cuando un estudiante con cuenta Keycloak aún no tiene grupo, y mandar el tipo de error de cada ejercicio para llenar «Errores frecuentes».

Con Keycloak configurado pero sin `API_BASE_URL`, las pantallas docentes muestran «se mostrarán cuando el servidor esté disponible» en lugar de datos demo.

## Arquitectura limpia

Cada feature se divide en capas, y las dependencias solo apuntan hacia el dominio:

```
presentation ──▶ domain ◀── data
      ▲                       ▲
      └────── providers/ ─────┘   (dependencias: eligen las implementaciones)
```

| Capa | Contiene | Puede depender de |
|---|---|---|
| `domain/` | Entidades, contratos de repositorio, casos de uso y reglas (Dart puro, sin Flutter ni plugins) | Solo otro `domain/` |
| `data/` | Datasources (SQLite, almacenamiento seguro, Keycloak/AppAuth, Dio, demo) e implementaciones de los repositorios | `domain/`, `core/` y `config/` |
| `presentation/` | `providers/` (estado Riverpod que llama casos de uso), `screens/`, `widgets/` y `routes/` | `domain/`, `providers/` de la feature, `core/` y `config/` (nunca `data/`) |
| `providers/` (raíz de la feature) | Proveedores de dependencias: enlazan contratos con implementaciones y crean los casos de uso | Todo |

`test/architecture/dependency_rule_test.dart` hace cumplir estas reglas. También comprueba que la navegación use `AppRoutes`, que los `GoRoute` vivan en carpetas `routes/` y que los espacios comunes usen los tokens del tema.

```
lib/
  main.dart · bootstrap.dart · app.dart
  config/
    env/          app_config.dart (--dart-define, modo demo)
    providers/    core_providers.dart (infraestructura) · app_overrides.dart (producción)
    routes/       app_routes.dart (catálogo de rutas) · route_guard.dart (sesión y rol) ·
                  app_router.dart (compone las rutas de cada feature)
    themes/       app_colors · app_text_styles · app_spacing (AppSpacing, Gap, AppRadius) ·
                  app_theme (claro/oscuro/alto contraste) · app_themes.dart (exporta todo)
  core/           error · network · storage · notifications · audio ·
                  sync/{domain, data, presentation/providers, providers}
  shared/         domain (entidades, catálogo curricular, ActivitiesRepository) ·
                  data (actividades, demo) · presentation (arte, widgets, gráficos) · providers
  features/
    <feature>/
      domain/        entities/ repositories/ usecases/ (services/)
      data/          datasources/ repositories/
      providers/     <feature>_providers.dart
      presentation/  providers/ screens/ widgets/ routes/
    auth · student · teacher · notifications · plans · settings   (las cuatro carpetas)
    guest · onboarding · pause · offline                          (solo presentation/)
```

- **Repositorios con interfaz (en `domain/`):** `AuthRepository` (Keycloak o demo), `SessionRepository`, `UsersRepository`, `GroupsRepository`, `ActivitiesRepository`, `MissionsRepository`, `ProgressRepository`, `NotificationsRepository`, `PlansRepository` y `SettingsRepository`.
- **Casos de uso con dobles en memoria:** `test/unit/usecases_test.dart` prueba el dominio sin Flutter ni Riverpod.
- **Offline first:** el progreso, los borradores y la cola viven en SQLite (`orbita_kids.db`). Cada registro tiene un UUID y solo sale de la cola cuando el servidor lo confirma (`SyncRules`). Un envío interrumpido vuelve a *pendiente*, los conflictos esperan la decisión de la persona, y el indicador de estado aparece arriba en toda la app.
- **Sesión:** los tokens se guardan cifrados (Keychain/Keystore) y se refrescan antes de vencer. Si Keycloak rechaza el refresh, la app muestra la pantalla «Tu sesión terminó». Sin Internet se abre la sesión guardada. El cierre de sesión retira los tokens, pide el cierre a Keycloak (o lo deja pendiente hasta reconectar) y conserva el progreso pendiente aislado por cuenta.
- **Reglas de adaptación:** R1–R4 en `features/student/domain/services/mission_engine.dart` y `FinishMission`, con pruebas. R5 (sugerir Pausa Estelar a los 20 minutos) respeta el horario sin avisos.
- **Accesibilidad:** tamaño de texto propio que se suma al del sistema, alto contraste, movimiento reducido (también respeta el del sistema), lectura en voz alta, etiquetas `Semantics` en dibujos y gráficos, áreas táctiles de 48 dp o más, y estados con ícono además de color.

## Licencias de recursos

- Fredoka y Nunito: SIL Open Font License (Google Fonts), incluidas en `assets/fonts/`.
- Logotipos de Órbita Kids y Órbita Kids Studios: extraídos del prototipo (`assets/brand/`).
