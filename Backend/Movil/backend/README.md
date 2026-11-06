# Órbita Kids · Backend

API de Órbita Kids en **Node.js 22 + Express 5 + MySQL 8**. Recibe la cola de sincronización de la app Flutter (`../orbita_kids`), da a los docentes sus grupos y reportes, y valida códigos de grupo contra la licencia.

El backend **no maneja contraseñas**. La app inicia sesión con Keycloak (OIDC + PKCE) y manda el access token como `Authorization: Bearer …`. El backend lo valida con el JWKS del realm y toma el rol de `realm_access.roles`.

## Cómo ejecutar (desarrollo)

```bash
cp .env.example .env          # AUTH_MODE=dev por defecto
docker compose up -d          # MySQL 8.4 en localhost:3306
npm install
npm run db:migrate            # aplica db/migrations/*.sql pendientes
npm run db:seed               # datos ficticios (equivalen a DemoData de la app)
npm run dev                   # http://localhost:3000, se recarga al guardar
npm test                      # pruebas de dominio (no necesitan MySQL)
```

Con `AUTH_MODE=dev` se usa `Authorization: Bearer dev:<id>` con usuarios sembrados:

| Token | Quién |
|---|---|
| `dev:dev-ana-rios` | Docente Ana Ríos (grupos 2° A, 2° B, 3° A…) |
| `dev:dev-luna-astro` | Estudiante Luna, en 2° A |
| `dev:dev-nuevo` | Estudiante sin grupo (para probar `/group-codes/redeem`) |

Códigos de grupo sembrados: `ORB-2A7K` (válido), `ORB-OLD1` (vencido), `ORB-1C2P` (grupo archivado), `ORB-FULL` (licencia sin lugares). Son los mismos que usa el modo demo de la app.

`AUTH_MODE=dev` está prohibido con `NODE_ENV=production`: el proceso no arranca.

## Producción

`AUTH_MODE=keycloak`, `KEYCLOAK_ISSUER=https://auth.tu-dominio/realms/orbita` y `KEYCLOAK_CLIENT_ID=orbita-kids-app` (se compara con el claim `azp`). Los usuarios se crean solos en la tabla `users` con su primer request (el ID es el `sub` de Keycloak). Si el token no trae rol, la respuesta es `403 no_role`.

## Endpoints

Todos van bajo `/v1`. En la app, `API_BASE_URL` sería `https://api.tu-dominio/v1` y cada constante de `ApiEndpoints` toma la ruta de la tabla.

| `ApiEndpoints` | Método y ruta | Rol | Notas |
|---|---|---|---|
| `me` | `GET /me` | todos | Perfil, rol, grupo e institución. `ETag` = versión |
| `me` | `PATCH /me` · `POST /me` | todos | `{name?, look?}`. `POST` es para la cola (`profile`). `If-Match` opcional |
| `attempts` | `POST /attempts` | estudiante | Payload de `FinishMission`. Idempotente por `id` |
| `activities` | `GET /activities` | todos | Docente: las suyas (`?groupId=`). Estudiante: las publicadas de su grupo, con `completedByMe` |
| `activities` | `GET /activities/:id` | todos | |
| `activities` | `POST /activities` | docente | `Activity.toJson()`. Crea o actualiza por `id` |
| `groupCodes` | `POST /group-codes/check` | **público** | `{code}` → `{valid, groupName}` o `{valid: false, reason, error}`. 15 por minuto por IP |
| `groupCodes` | `POST /group-codes/redeem` | estudiante | El estudiante se une al grupo y ocupa un lugar de la licencia |
| `groups` | `GET /groups` · `POST /groups` | docente | El servidor genera el código `ORB-XXXX` |
| `groups` | `GET /groups/:id` · `PATCH /groups/:id` | docente | `{name?, grade?, status?}`. `If-Match` opcional |
| `groups` | `POST /groups/:id/code` | docente | Genera un código nuevo e invalida el anterior |
| `groups` | `GET /groups/:id/students` | docente | `{weeks, items: StudentSummary[]}`, cada uno con sus últimos 5 intentos en `recent` |
| `students` | `GET /students/:id` | docente | Un `StudentSummary` con `weeks` y `recent` |
| `planRequests` | `POST /plan-requests` | todos | Payload de `QueuedPlansRepository`. Idempotente |
| `supportReports` | `POST /support-reports` | todos | `{topic, text, version}`. Idempotente |
| — | `GET /health` | público | `200` si MySQL responde, `503` si no |

### Contrato con la cola de sincronización (`HttpSyncGateway`)

- Cuerpo `{id, ...payload}` con el mismo UUID en `Idempotency-Key` (si no coinciden: `400`).
- **201** registro nuevo · **200** ya existía con ese `id` y del mismo usuario (reintento). La app marca ambos como confirmados.
- **409** el `id` es de otro usuario, la actividad ya cerró o el grupo está archivado · **412** `If-Match` no coincide con la versión actual. La app los marca como conflicto y no sobrescribe.
- **400/403/404/422** son errores de datos o de permisos. La app los deja en conflicto con el mensaje del servidor y no los reintenta. **401** (token vencido) y **5xx** sí se reintentan.
- Errores: `{ "error": { "code", "message", "details"? } }`.

### Reglas que aplica el servidor

- **Actividades:** la programada pasa a activa al llegar su inicio. Cualquiera se cierra al terminar el día de entrega. `done` cuenta a los estudiantes distintos que mandaron un intento de esa actividad (la app usa el ID de la actividad como `missionId` cuando `assigned: true`).
- **Resumen de estudiante:** las últimas 6 semanas (de lunes a domingo). `accuracy` son los aciertos al primer intento. «Necesita apoyo» si `accuracy < 68` o si el último intento trae `notifyTeacher` (R4). «Sin actividad reciente» después de 6 días. «Ciclo terminado» si el grupo está archivado. Si no hay datos, `accuracy`, `lastDays` y cada semana de `trend` vienen en `null`: el reporte no inventa valores.
- **Fechas:** se guardan en UTC. Una fecha sin zona (`DateTime.toIso8601String()` de una fecha local) se toma como UTC para que el día del calendario no cambie.

## Estructura

```
db/migrations/      SQL versionado (tabla schema_migrations)
scripts/            migrate.js · seed.js (datos ficticios, IDs dev-*)
src/
  config/env.js     variables de entorno validadas con zod
  db/               pool mysql2 · inserción idempotente
  domain/           reglas puras y probadas: códigos, resumen, estados, claims
  lib/              errores HTTP, helpers (If-Match, Idempotency-Key, fechas), logger
  middleware/       auth (Keycloak/dev, roles) · manejo de errores
  modules/<área>/   *.routes.js (HTTP + validación) · *.repository.js (SQL)
test/               node:test
```

## Pendiente

**En el backend:**
- `ApiEndpoints.sessions` (listar dispositivos y cerrar otras sesiones): requiere un cliente de servicio con acceso a la Admin API de Keycloak.
- Notificaciones push, desbloqueo con código y reenvío de correos (la README de la app tampoco los define todavía).
- Asociar docentes con su institución: hoy `users.institution_id` se llena a mano o en el seed. Sin institución, los grupos se crean sin licencia y sin límite de lugares.
- Pruebas de integración contra MySQL (hoy se probó a mano con el seed).
- Zona horaria de la escuela: hoy el día de entrega termina a medianoche UTC (las 18:00 en el centro de México).

**En la app** (ya conectada; ver «Con el backend» en `../orbita_kids/README.md`):
- Llamar a `POST /group-codes/redeem` cuando un estudiante con cuenta Keycloak todavía no tiene grupo. Hoy la app solo usa `check`.
- Mandar el tipo de error de cada ejercicio: mientras no llegue, `errors` va vacío y la app muestra «Aún no hay datos».
