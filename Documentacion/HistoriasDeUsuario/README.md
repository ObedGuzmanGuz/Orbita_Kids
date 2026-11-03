# Historias de usuario — Órbita Kids

## Presentación

Las historias de usuario describen necesidades funcionales desde la perspectiva de quienes utilizan un sistema: quién necesita una función, qué desea realizar y qué beneficio espera obtener. En Órbita Kids permiten relacionar la propuesta educativa con los recorridos de estudiantes, docentes y responsables institucionales.

Esta carpeta reúne un catálogo de **20 historias**, organizado en siete módulos. Cada historia incluye prioridad, alcance, estado de la evidencia, criterios de aceptación y referencias verificables del repositorio.

## Objetivo

Documentar los requisitos funcionales de manera comprensible y comprobable para orientar el diseño, la implementación y las pruebas del proyecto universitario de Ingeniería en Desarrollo y Gestión de Software.

## Alcance

Se contemplan la aplicación móvil de aprendizaje, la plataforma docente y las funciones de administración institucional representadas en los prototipos. El catálogo distingue **13 historias del MVP** y **7 complementarias** como clasificación de trabajo propuesta para revisión. La administración institucional, el funcionamiento sin conexión y otras ampliaciones requieren confirmar su inclusión en la primera entrega.

Las funcionalidades futuras expresamente excluidas del alcance inicial se describen en el documento principal; no se agregan historias sin respaldo para completar la cantidad.

## Organización

| Módulo | Descripción | Historias |
|---|---|---|
| 1. Autenticación y usuarios | Acceso, recuperación, seguridad, perfil y astronauta. | HU-001 a HU-003 |
| 2. Exploración y aprendizaje | Planetas, misiones, sumas, adaptación, recompensas y progreso. | HU-004 a HU-008 |
| 3. Gestión docente | Grupos, incorporación de estudiantes, actividades y seguimiento. | HU-009 a HU-012 |
| 4. Administración institucional | Docentes, permisos, capacidad, licencias y reportes agregados. | HU-013 a HU-015 |
| 5. Funcionalidades sin conexión | Descarga, realización de actividades y sincronización. | HU-016 a HU-017 |
| 6. Accesibilidad y bienestar | Preferencias de uso y Pausa Estelar. | HU-018 a HU-019 |
| 7. Información y soporte | Información pública, ayuda y reporte de problemas. | HU-020 |

## Catálogo de historias

Consulta el [documento completo](Historias_de_Usuario.md) o abre una historia:

| ID | Nombre | Alcance |
|---|---|---|
| [HU-001](Historias_de_Usuario.md#hu-001) | Registro e inicio de sesión | MVP |
| [HU-002](Historias_de_Usuario.md#hu-002) | Recuperación de cuenta y seguridad | MVP |
| [HU-003](Historias_de_Usuario.md#hu-003) | Gestión del perfil y personalización del astronauta | MVP |
| [HU-004](Historias_de_Usuario.md#hu-004) | Exploración de planetas y misiones | MVP |
| [HU-005](Historias_de_Usuario.md#hu-005) | Resolución de ejercicios de sumas | MVP |
| [HU-006](Historias_de_Usuario.md#hu-006) | Adaptación de dificultad y refuerzo educativo | MVP |
| [HU-007](Historias_de_Usuario.md#hu-007) | Resultados, recompensas y desbloqueo de contenido | MVP |
| [HU-008](Historias_de_Usuario.md#hu-008) | Consulta del progreso de aprendizaje | MVP |
| [HU-009](Historias_de_Usuario.md#hu-009) | Creación y administración de grupos | MVP |
| [HU-010](Historias_de_Usuario.md#hu-010) | Registro y vinculación de estudiantes mediante código | MVP |
| [HU-011](Historias_de_Usuario.md#hu-011) | Creación y asignación de actividades | MVP |
| [HU-012](Historias_de_Usuario.md#hu-012) | Consulta de resultados y seguimiento académico | MVP |
| [HU-013](Historias_de_Usuario.md#hu-013) | Administración de docentes y permisos | Complementaria |
| [HU-014](Historias_de_Usuario.md#hu-014) | Gestión de grupos y licencias institucionales | Complementaria |
| [HU-015](Historias_de_Usuario.md#hu-015) | Consulta de reportes institucionales | Complementaria |
| [HU-016](Historias_de_Usuario.md#hu-016) | Descarga y realización de actividades sin internet | Complementaria |
| [HU-017](Historias_de_Usuario.md#hu-017) | Sincronización del progreso | Complementaria |
| [HU-018](Historias_de_Usuario.md#hu-018) | Configuración de accesibilidad y preferencias | MVP |
| [HU-019](Historias_de_Usuario.md#hu-019) | Actividades de descanso mediante Pausa Estelar | Complementaria |
| [HU-020](Historias_de_Usuario.md#hu-020) | Consulta de información, ayuda y soporte | Complementaria |

## Estructura de archivos

| Archivo | Función |
|---|---|
| [README.md](README.md) | Presentación, organización, catálogo y acceso a las fuentes. |
| [Historias_de_Usuario.md](Historias_de_Usuario.md) | Desarrollo de las 20 historias, criterios, reglas pedagógicas y observaciones pendientes. |

## Referencias

- [README principal](../../README.md).
- [Arquitectura](../DiagramaDeArquitectura/readme.md).
- [Roles de usuario](../DiagramaRolesUsuario/readme.md).
- [Navegación y sketches de GUI](../GUI/Practica_Sketches/readme.md).
- [Frontend móvil](../../Frontend/Movil/README.md) y [frontend web](../../Frontend/Web/README.md).
- [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html) y [prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html).
- [Secuencias móviles](../../Frontend/Movil/diagrama_de_secuencia/README.md) y [secuencias web](../../Frontend/Web/diagrama_de_secuencia/README.md).

Los enlaces HTML permiten localizar los archivos en GitHub; para utilizar sus interacciones se deben abrir en un navegador como archivos HTML o desde su publicación estática.

## Estado de la documentación

**Versión de trabajo para revisión — 3 de noviembre de 2026.** Las historias se identificaron mediante revisión de documentación, prototipos y secuencias. Las 20 tienen evidencia de prototipado, por lo que su estado actual es **Prototipada**; las integraciones, la persistencia y los controles de servidor siguen pendientes de implementación y verificación.

Los criterios expresan requisitos esperados y no resultados de pruebas ya aprobadas. No se identificó una suite automatizada que acredite su cumplimiento. La distribución es de **11 prioridades altas, 7 medias y 2 bajas**. Las contradicciones y decisiones abiertas se conservan en las [observaciones del catálogo](Historias_de_Usuario.md#observaciones-pendientes), sin atribuirles una aprobación del equipo.
