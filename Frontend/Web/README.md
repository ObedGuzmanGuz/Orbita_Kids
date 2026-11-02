# Órbita Kids · Frontend web

Espacio para los entregables de la versión web: la **PWA docente**, complementaria a la app móvil y marcada como «en desarrollo» en la arquitectura del proyecto.

Tiene la misma estructura que `../Movil/`:

| Carpeta | Estado |
|---|---|
| [`sketches/`](sketches/README.md) | Pendiente |
| [`wireframes/`](wireframes/README.md) | Pendiente |
| [`prototipo/`](prototipo/README.md) | Pendiente |
| [`diagrama_de_secuencia/`](diagrama_de_secuencia/README.md) | Pendiente |

Lo que ya está definido para la web y se puede reutilizar desde `../Movil/`:

- **Permisos por rol:** desde la PWA el docente ve grupos, estudiantes e intentos, crea y publica actividades, consulta reportes ampliados y crea grupos. El estudiante no usa la PWA.
- **Autenticación:** el mismo Keycloak con Authorization Code + PKCE (diagrama SD-02).
- **Flujo docente:** publicar una actividad y revisar el progreso (diagrama SD-06).
- **Backend:** la misma API REST (FastAPI + MySQL) y una sola fuente de permisos para la app y la PWA.
