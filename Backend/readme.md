<div align="center">

<img align="left" src="/Logos/Studio_Blamco-removebg-preview.png" width="90" alt="Órbita Studio"/>
<img align="right" src="/Logos/Kid_Blanco-removebg-preview.png" width="80" alt="Órbita Kids"/>

<br>

# 🪐 ` Ó R B I T A · K I D S ` 🚀

### ✨ CREAMOS EXPERIENCIAS QUE INSPIRAN ✨

<br>

# ⚙️ BACKEND · API

**SERVICIOS Y DATOS DE ÓRBITA KIDS**

<br>

## Descripción

La API principal de Órbita Kids vive en [`backend/`](./backend) y está construida con Node.js 22, Express 5 y MySQL 8. Recibe la sincronización de la aplicación Flutter, administra grupos, actividades, estudiantes y reportes, y valida el acceso mediante Keycloak o usuarios de desarrollo.

El backend no almacena contraseñas. En producción valida tokens OIDC mediante el JWKS de Keycloak y aplica los roles `student` y `teacher`.

## Cómo ejecutar

Desde esta carpeta:

```bash
cd backend
cp .env.example .env
docker compose up -d
npm install
npm run db:migrate
npm run db:seed
npm run dev
```

La API queda disponible en `http://localhost:3000`. Las pruebas de dominio se ejecutan con:

```bash
npm test
```

Con `AUTH_MODE=dev` se pueden usar las cuentas ficticias sembradas para probar la integración con Flutter. Este modo está bloqueado cuando `NODE_ENV=production`.

## Módulos principales

- `src/config/`: configuración y variables de entorno validadas con Zod.
- `src/middleware/`: autenticación, autorización por rol y errores HTTP.
- `src/domain/`: reglas de negocio puras y probadas.
- `src/modules/`: rutas y repositorios de usuarios, grupos, actividades, intentos y sincronización.
- `db/migrations/`: migraciones SQL versionadas.
- `scripts/`: migración y carga de datos de demostración.
- `test/`: pruebas con `node:test`.

## Integración

La aplicación Flutter consume las rutas bajo `/v1`, incluyendo `/me`, `/activities`, `/groups`, `/students`, `/attempts`, `/plan-requests` y `/support-reports`. La cola de sincronización usa UUIDs e `Idempotency-Key` para evitar duplicados y conserva los conflictos para que la aplicación pueda resolverlos.

Consulta la documentación completa de endpoints, reglas de negocio y variables de producción en [`backend/README.md`](./backend/README.md).

<br>

### 🪐 ÓRBITA KIDS

**EXPLORA · APRENDE · DESCUBRE**

*Cada descubrimiento comienza con una pregunta.*

<br>

<img src="/Logos/Orbi_y_Teo_saludando_transparente.webp" width="280" alt="Animación de Órbita Kids"/>

<br>

### ✨ ¡GRACIAS POR EXPLORAR CON NOSOTROS! ✨

**DESARROLLADO POR ÓRBITA STUDIO**

<sub>NODE.JS · EXPRESS · MYSQL &nbsp; | &nbsp; API BACKEND</sub>

<br>

<sub>© 2026 Órbita Studio · Todos los derechos reservados.</sub>

</div>