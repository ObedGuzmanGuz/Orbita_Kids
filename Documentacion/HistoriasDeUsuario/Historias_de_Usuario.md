# Historias de Usuario — Órbita Kids

## Introducción

Órbita Kids propone reforzar el aprendizaje de sumas en niños de 6 a 9 años mediante una aventura espacial. La experiencia conecta actividades matemáticas, personajes, planetas, misiones y recompensas con herramientas docentes de organización y seguimiento.

Este documento reúne 20 historias identificadas en la documentación y los prototipos del repositorio. La revisión del 3 de noviembre de 2026 encontró prototipos HTML con interacciones locales y datos de demostración; no identificó proyectos operativos Flutter/React ni servicios de backend que permitan considerar entregada la plataforma integrada.

## Objetivo del documento

Establecer un catálogo trazable de necesidades funcionales, expresadas desde la perspectiva de los usuarios y acompañadas de criterios verificables, para apoyar la planeación, el desarrollo y la evaluación del proyecto universitario de Ingeniería en Desarrollo y Gestión de Software.

## Actores del sistema

| Actor | Participación y límites |
|---|---|
| Estudiante | Utiliza principalmente la aplicación móvil, realiza sumas y consulta su propio progreso. |
| Docente | Administra sus grupos, asigna actividades y consulta resultados de sus estudiantes. La PWA es el canal principal previsto; el prototipo móvil también representa este perfil. |
| Responsable institucional o dirección | Gestiona docentes, grupos, lugares y reportes de su institución en el prototipo web. Su definición como rol operativo está pendiente de reconciliar con el diagrama de roles. |
| Visitante o invitado | Consulta información, ayuda o una demostración sin acceder a datos académicos privados. No constituye un rol académico autenticado. |
| Adulto responsable | Acompaña y confirma el registro del estudiante. No se identifica una cuenta ni un portal independiente para este actor. |

No se incorpora un administrador global, un portal familiar ni otros perfiles sin especificación suficiente. Keycloak y los proveedores de identidad son sistemas de apoyo, no actores humanos de estas historias.

## Convenciones utilizadas

- **Identificador:** HU-001 a HU-020; permanece estable aunque cambie el título.
- **Prioridad:** alta para acceso, aprendizaje y gestión académica esenciales; media para personalización y capacidades de apoyo; baja para funciones complementarias que no bloquean el ciclo educativo básico. La prioridad se aplica dentro del alcance indicado.
- **Alcance:** MVP para el núcleo inicial; complementaria para capacidades respaldadas que requieren confirmar su planificación; futura para ampliaciones excluidas de la primera versión. No se fuerza una historia futura dentro de este catálogo.
- **Estado actual:** Prototipada cuando existe representación en HTML; Documentada cuando solo hay especificación; Pendiente de implementación cuando no se identifica implementación ni representación funcional suficiente. Un prototipo no acredita integración o funcionamiento en producción.
- **Criterios de aceptación:** requisitos esperados para la implementación final, pendientes de aprobación y pruebas. No describen necesariamente capacidades ya satisfechas por el prototipo.
- **Trazabilidad:** cada historia enlaza fuentes y nombra pantallas, funciones o secuencias específicas. Las rutas se resuelven desde esta carpeta.
- **Datos de demostración:** usuarios, códigos, fechas, precios y métricas precargados no son reglas generales ni credenciales de producción.

### Límites entre historias relacionadas

Se conserva la organización solicitada de 20 historias. HU-001 agrupa alta y acceso como recorrido de incorporación, pero delega la validación y pertenencia al grupo en HU-010. HU-009 cubre la necesidad docente de organizar grupos; HU-014 cubre capacidad, códigos y licencia institucional. HU-005 evalúa respuestas; HU-006 adapta la práctica; HU-007 presenta el cierre y las recompensas; HU-008 consulta el historial. HU-012 presenta información académica al docente y HU-015 la agrega para dirección. HU-016 conserva el trabajo local y HU-017 lo concilia con el servicio remoto. 

### Reglas pedagógicas identificadas

| Regla | Comportamiento representado | Historias |
|---|---|---|
| R1 | Dos errores consecutivos al primer intento activan apoyo visual y sumas más sencillas en lo restante de la misión. | HU-005, HU-006 |
| R2 | Un resultado de al menos 90 % de aciertos al primer intento genera una recomendación de avance. | HU-006 |
| R3 | Un resultado inferior a 60 % genera una propuesta de refuerzo. | HU-006 |
| R4 | Dos misiones consecutivas por debajo de 60 % generan una sugerencia de apoyo para el docente. | HU-012 |
| R5 | Al alcanzar 20 minutos de aprendizaje se sugiere una Pausa Estelar que puede posponerse. | HU-019 |

Los umbrales son propuestas de los prototipos y las secuencias, pendientes de validación pedagógica. La adaptación no requiere inteligencia artificial. El prototipo móvil asigna estrellas con umbrales de 80 % y 60 %, distintos del 90 % de R2; recompensa y recomendación de avance son decisiones diferentes. El detalle de las discrepancias se conserva al final.

## Tabla general de historias de usuario

| ID | Nombre | Actor | Prioridad | Alcance |
|---|---|---|---|---|
| [HU-001](#hu-001) | Registro e inicio de sesión | Estudiante y docente | Alta | MVP |
| [HU-002](#hu-002) | Recuperación de cuenta y seguridad | Usuario con cuenta | Alta | MVP |
| [HU-003](#hu-003) | Gestión del perfil y personalización del astronauta | Estudiante; docente para su perfil | Media | MVP |
| [HU-004](#hu-004) | Exploración de planetas y misiones | Estudiante | Alta | MVP |
| [HU-005](#hu-005) | Resolución de ejercicios de sumas | Estudiante | Alta | MVP |
| [HU-006](#hu-006) | Adaptación de dificultad y refuerzo educativo | Estudiante | Alta | MVP |
| [HU-007](#hu-007) | Resultados, recompensas y desbloqueo de contenido | Estudiante | Alta | MVP |
| [HU-008](#hu-008) | Consulta del progreso de aprendizaje | Estudiante | Alta | MVP |
| [HU-009](#hu-009) | Creación y administración de grupos | Docente | Alta | MVP |
| [HU-010](#hu-010) | Registro y vinculación de estudiantes mediante código | Estudiante acompañado por un adulto | Alta | MVP |
| [HU-011](#hu-011) | Creación y asignación de actividades | Docente | Alta | MVP |
| [HU-012](#hu-012) | Consulta de resultados y seguimiento académico | Docente | Alta | MVP |
| [HU-013](#hu-013) | Administración de docentes y permisos | Responsable institucional | Media | Complementaria |
| [HU-014](#hu-014) | Gestión de grupos y licencias institucionales | Responsable institucional | Media | Complementaria |
| [HU-015](#hu-015) | Consulta de reportes institucionales | Responsable institucional | Media | Complementaria |
| [HU-016](#hu-016) | Descarga y realización de actividades sin internet | Estudiante | Media | Complementaria |
| [HU-017](#hu-017) | Sincronización del progreso | Estudiante y docente | Media | Complementaria |
| [HU-018](#hu-018) | Configuración de accesibilidad y preferencias | Estudiante y docente | Media | MVP |
| [HU-019](#hu-019) | Actividades de descanso mediante Pausa Estelar | Estudiante | Baja | Complementaria |
| [HU-020](#hu-020) | Consulta de información, ayuda y soporte | Visitante y usuario de la plataforma | Baja | Complementaria |

## Historias desarrolladas por módulos

## Módulo 1. Autenticación y usuarios

### HU-001

**Identificador:** HU-001.

**Nombre:** Registro e inicio de sesión.

**Módulo:** 1. Autenticación y usuarios.

**Actor:** Estudiante y docente; dirección únicamente si se aprueba el alcance institucional.

**Prioridad:** Alta.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como estudiante o docente, quiero crear mi cuenta e iniciar sesión para acceder a las funciones correspondientes a mi perfil.

**Criterios de aceptación:**

1. Si faltan campos obligatorios del registro o del acceso con cuenta Órbita Kids, se identifican los campos y no se completa la operación.
2. El alta del estudiante utiliza la validación de HU-010 y la confirmación del adulto; la solicitud docente muestra su estado pendiente cuando requiere autorización, sin conceder permisos anticipadamente.
3. Una identidad válida y autorizada abre el inicio de su rol; una cuenta de estudiante que intenta utilizar el panel web recibe la indicación de acceder a sus misiones desde la aplicación móvil.
4. Las credenciales incorrectas, la cancelación y el error del proveedor muestran un motivo y una opción para reintentar o volver, sin abrir una sesión autorizada.
5. Sin conexión, un nuevo registro o inicio de sesión informa que requiere internet; no se presenta como exitoso. La continuidad de una sesión previamente validada pertenece al alcance de HU-016.

### HU-002

**Identificador:** HU-002.

**Nombre:** Recuperación de cuenta y seguridad.

**Módulo:** 1. Autenticación y usuarios.

**Actor:** Usuario con cuenta de estudiante o docente; dirección en el alcance complementario.

**Prioridad:** Alta.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como usuario con cuenta, quiero recuperar mi acceso y cerrar mi sesión de forma controlada para continuar utilizando la plataforma y proteger mi información.

**Criterios de aceptación:**

1. La recuperación distingue una cuenta Órbita Kids de una cuenta federada; para esta última indica que la contraseña se gestiona con el proveedor correspondiente.
2. Una contraseña nueva que no cumple las reglas mostradas o cuya confirmación difiere produce un error; la confirmación de cambio solo aparece después de completar la recuperación válida.
3. Bajo la política representada de tres intentos fallidos, se informa el bloqueo temporal de 15 minutos; un código incorrecto o vencido no desbloquea la cuenta. Esta política requiere ratificación antes de implementarse.
4. Una sesión vencida impide continuar en secciones protegidas y solicita volver a entrar; los resultados pendientes permanecen asociados a su cuenta.
5. Antes de cerrar sesión se informa la existencia de pendientes y se permite cancelar; al confirmar se abandona el espacio autenticado. Si no hay conexión, se conserva el aislamiento de los pendientes y se informa el cierre remoto diferido.

### HU-003

**Identificador:** HU-003.

**Nombre:** Gestión del perfil y personalización del astronauta.

**Módulo:** 1. Autenticación y usuarios.

**Actor:** Estudiante; docente para sus datos de perfil.

**Prioridad:** Media.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como estudiante, quiero consultar mi perfil y elegir la apariencia de mi astronauta para identificarme en la aventura de aprendizaje.

**Criterios de aceptación:**

1. El perfil presenta el nombre de uso y los datos de la cuenta activa; no permite modificar el perfil de otra persona.
2. Al editar el nombre, un valor de menos de dos caracteres produce un mensaje y no se guarda; para el estudiante se solicita un nombre o apodo conforme al formulario representado.
3. La selección de personaje y opciones disponibles actualiza una vista previa antes de guardar.
4. Al guardar se actualiza el personaje utilizado en la experiencia; seleccionar un elemento bloqueado muestra el requisito de desbloqueo y no lo aplica.

## Módulo 2. Exploración y aprendizaje

### HU-004

**Identificador:** HU-004.

**Nombre:** Exploración de planetas y misiones.

**Módulo:** 2. Exploración y aprendizaje.

**Actor:** Estudiante.

**Prioridad:** Alta.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como estudiante, quiero explorar el mapa y consultar mis misiones para elegir la siguiente actividad de mi aventura.

**Criterios de aceptación:**

1. El mapa distingue contenido disponible, bloqueado y completado para el estudiante activo.
2. Al abrir una misión disponible se muestran su nombre, objetivo, modalidad y dificultad antes de comenzar.
3. Un contenido bloqueado no inicia ejercicios y muestra la condición de acceso representada; el modo invitado conserva sus restricciones y no abre datos privados.
4. La acción de continuar dirige a una misión pendiente disponible; las tareas asignadas por el docente se distinguen de las misiones del recorrido espacial.


### HU-005

**Identificador:** HU-005.

**Nombre:** Resolución de ejercicios de sumas.

**Módulo:** 2. Exploración y aprendizaje.

**Actor:** Estudiante.

**Prioridad:** Alta.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como estudiante, quiero resolver sumas con apoyos visuales o selección de respuestas para practicar las operaciones y comprender mis errores.

**Criterios de aceptación:**

1. La actividad presenta una suma de la modalidad y dificultad seleccionadas; los objetos del apoyo visual corresponden a las cantidades de la operación.
2. En modalidad visual no se comprueba una respuesta vacía; en selección se ofrecen cuatro opciones distintas que incluyen el resultado correcto.
3. Una respuesta correcta muestra retroalimentación positiva; ante un primer error se ofrece ayuda y, tras el segundo error, se muestra la respuesta explicada conforme al flujo prototipado.
4. Cada respuesta evaluada se asocia al estudiante, ejercicio y actividad, distinguiendo acierto al primer intento, intentos y ayuda utilizada para alimentar HU-008 y HU-012.
5. Al finalizar se abre el resumen de HU-007; si el estudiante solicita salir antes de terminar, se advierte que la misión en curso no se guardará y se permite continuar o salir.

### HU-006

**Identificador:** HU-006.

**Nombre:** Adaptación de dificultad y refuerzo educativo.

**Módulo:** 2. Exploración y aprendizaje.

**Actor:** Estudiante.

**Prioridad:** Alta.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como estudiante, quiero recibir apoyos y recomendaciones según mi desempeño para practicar con una dificultad adecuada a mis necesidades.

**Criterios de aceptación:**

1. Aplicando R1 como propuesta, dos errores consecutivos al primer intento activan apoyo visual y sumas más sencillas para los ejercicios restantes, sin cambiar los resultados ya obtenidos.
2. El porcentaje de desempeño se calcula con aciertos al primer intento sobre ejercicios completados; se distingue del total de respuestas emitidas.
3. Con R2 y R3 propuestas, un resultado de al menos 90 % muestra recomendación de avance; uno inferior a 60 % ofrece refuerzo; entre 60 % y menos de 90 % no se muestra ninguna de esas dos recomendaciones.
4. Al aceptar el refuerzo se inicia una práctica más sencilla con apoyo visual; la recomendación no modifica por sí sola los permisos de acceso ni sustituye la regla de desbloqueo de HU-007.

### HU-007

**Identificador:** HU-007.

**Nombre:** Resultados, recompensas y desbloqueo de contenido.

**Módulo:** 2. Exploración y aprendizaje.

**Actor:** Estudiante.

**Prioridad:** Alta.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como estudiante, quiero recibir un resumen y recompensas al completar una misión para reconocer mi esfuerzo y descubrir el contenido que puedo continuar explorando.

**Criterios de aceptación:**

1. El resumen muestra aciertos al primer intento, cantidad de ejercicios e intentos totales de la misión recién terminada.
2. Bajo los umbrales prototipados, se otorgan tres estrellas con al menos 80 %, dos desde 60 % hasta menos de 80 % y una por debajo de 60 %; se muestran las recompensas efectivamente obtenidas.
3. Según el recorrido representado, completar las tres misiones de un planeta permite obtener su pieza y habilitar el siguiente planeta; estos parámetros quedan sujetos a la definición final de niveles.
4. Volver a mostrar el mismo resumen no acredita otra vez las recompensas de esa finalización; repetir y terminar una misión constituye una ejecución diferente.
5. El resumen diferencia resultados pendientes de envío y confirmados; una simulación local no se presenta como confirmación del servidor.

### HU-008

**Identificador:** HU-008.

**Nombre:** Consulta del progreso de aprendizaje.

**Módulo:** 2. Exploración y aprendizaje.

**Actor:** Estudiante.

**Prioridad:** Alta.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como estudiante, quiero consultar mi avance e historial de misiones para reconocer lo que he aprendido y lo que me falta practicar.

**Criterios de aceptación:**

1. La vista presenta misiones completadas frente al total, estrellas e historial correspondientes únicamente al estudiante activo.
2. Cada resultado del historial identifica la misión, fecha y desempeño; al terminar una nueva misión se refleja su resultado en la consulta posterior.
3. Los indicadores y gráficos se calculan a partir del historial disponible y no incorporan datos de demostración como si fueran resultados reales del estudiante.
4. Al consultar información local sin conexión se informa la última sincronización; no se atribuye actualización remota a resultados todavía pendientes.


## Módulo 3. Gestión docente

### HU-009

**Identificador:** HU-009.

**Nombre:** Creación y administración de grupos.

**Módulo:** 3. Gestión docente.

**Actor:** Docente.

**Prioridad:** Alta.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como docente, quiero organizar y consultar mis grupos para administrar las actividades de los estudiantes que tengo a cargo.

**Criterios de aceptación:**

1. La consulta presenta los grupos asignados al docente con nombre, grado, cantidad de estudiantes y estado activo o archivado.
2. La búsqueda por nombre o grado limita los resultados y muestra un mensaje cuando no hay coincidencias.
3. Al abrir un grupo se muestran sus estudiantes y actividades; un docente sin relación autorizada con ese grupo no obtiene sus datos académicos.
4. La solicitud de un nuevo grupo muestra su confirmación o estado pendiente según la autorización institucional representada; no atribuye al docente la emisión autónoma de un código de licencia.

### HU-010

**Identificador:** HU-010.

**Nombre:** Registro y vinculación de estudiantes mediante código.

**Módulo:** 3. Gestión docente.

**Actor:** Estudiante acompañado por un adulto; docente como responsable del grupo receptor.

**Prioridad:** Alta.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como estudiante acompañado por un adulto, quiero validar el código de mi grupo y confirmar mi incorporación para recibir las actividades de mi docente.

**Criterios de aceptación:**

1. El código utiliza el formato representado `ORB-` seguido de cuatro letras o números; un formato distinto muestra un error antes de continuar.
2. La validación requiere conexión y distingue código inexistente, vencido, grupo no disponible y falta de lugares; en esos casos no se confirma la incorporación.
3. Un código válido presenta el grupo, docente y escuela antes de que el estudiante confirme su incorporación.
4. En el registro inicial, la incorporación y ocupación de lugar solo se confirman al completar el alta y la confirmación adulta; un fallo no se muestra como vínculo exitoso.

### HU-011

**Identificador:** HU-011.

**Nombre:** Creación y asignación de actividades.

**Módulo:** 3. Gestión docente.

**Actor:** Docente.

**Prioridad:** Alta.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como docente, quiero preparar y asignar actividades de sumas para orientar la práctica de mi grupo o de estudiantes que necesitan refuerzo.

**Criterios de aceptación:**

1. El formulario permite indicar nombre, grupo, modalidad, dificultad, cantidad de ejercicios y entrega; nombre insuficiente, grupo ausente o fecha inválida impiden publicar y señalan el campo correspondiente.
2. Los destinatarios pertenecen a un grupo autorizado del docente; al seleccionar estudiantes individuales se exige al menos uno y no se incluyen integrantes de otros grupos.
3. Guardar como borrador no entrega la actividad a los estudiantes; publicar requiere confirmación y una respuesta satisfactoria del servicio.
4. Una publicación confirmada aparece como activa y llega a las tareas de los destinatarios cuando se actualizan sus asignaciones; al resolverla se respeta la cantidad de ejercicios publicada.
5. Sin conexión se permite conservar un borrador y se informa que aún no está publicado; el momento de publicación tras reconectar queda sujeto a la observación pendiente sobre confirmación.

### HU-012

**Identificador:** HU-012.

**Nombre:** Consulta de resultados y seguimiento académico.

**Módulo:** 3. Gestión docente.

**Actor:** Docente.

**Prioridad:** Alta.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como docente, quiero consultar el desempeño de mis grupos y estudiantes para identificar dificultades y orientar el refuerzo educativo.

**Criterios de aceptación:**

1. El docente puede consultar resultados por grupo y abrir el detalle de un estudiante perteneciente a sus grupos autorizados.
2. Los reportes distinguen aciertos, intentos, evolución y errores frecuentes a partir de resultados registrados; las cifras del detalle corresponden a la selección realizada.
3. Un filtro sin resultados informa esa condición sin sustituirla por métricas de demostración ni presentar ausencia de datos como desempeño nulo.
4. Bajo R4 propuesta, dos misiones consecutivas con menos de 60 % generan una sugerencia de apoyo; el docente puede preparar refuerzo mediante HU-011.
5. La consulta offline identifica la última actualización disponible y no incorpora como recibidos resultados aún pendientes de sincronización en otro dispositivo.

## Módulo 4. Administración institucional

### HU-013

**Identificador:** HU-013.

**Nombre:** Administración de docentes y permisos.

**Módulo:** 4. Administración institucional.

**Actor:** Responsable institucional o dirección.

**Prioridad:** Media.

**Alcance:** Complementaria.

**Estado actual:** Prototipada.

**Historia de usuario:** Como responsable institucional, quiero revisar solicitudes e invitaciones docentes para autorizar el acceso de quienes participan en mi escuela.

**Criterios de aceptación:**

1. Solo una cuenta con permiso institucional consulta y gestiona docentes de su propia institución; un docente ordinario no obtiene ese permiso por iniciar sesión.
2. La lista distingue solicitudes, invitaciones, cuentas activas y desactivadas; el filtro por estado devuelve únicamente las coincidencias.
3. Invitar requiere un correo del dominio institucional indicado; uno inválido muestra el error y no confirma el envío.
4. Aprobar activa la solicitud seleccionada; rechazar no concede el rol. Desactivar impide el acceso docente sin borrar sus datos académicos y advierte sobre los grupos que requieren reasignación.

### HU-014

**Identificador:** HU-014.

**Nombre:** Gestión de grupos y licencias institucionales.

**Módulo:** 4. Administración institucional.

**Actor:** Responsable institucional o dirección.

**Prioridad:** Media.

**Alcance:** Complementaria.

**Estado actual:** Prototipada.

**Historia de usuario:** Como responsable institucional, quiero administrar grupos, códigos y lugares de mi licencia para organizar la incorporación de estudiantes dentro de la capacidad disponible.

**Criterios de aceptación:**

1. La consulta presenta por grupo docente, lugares utilizados y disponibles, código, vigencia y estado; la licencia muestra plan, periodo y capacidad total.
2. Generar o ajustar lugares de un grupo no permite superar la capacidad disponible de la licencia; una solicitud que excede el límite muestra el motivo y no se confirma.
3. Solo el responsable autorizado genera o renueva códigos institucionales; un código vencido se identifica como tal y no habilita una incorporación en HU-010.
4. Al archivar un grupo se informa el cambio de estado y se actualiza su disponibilidad de lugares, sin presentar la operación como eliminación de resultados históricos.
5. Solicitar cambio de plan registra una solicitud y su confirmación; no se muestra como.

### HU-015

**Identificador:** HU-015.

**Nombre:** Consulta de reportes institucionales.

**Módulo:** 4. Administración institucional.

**Actor:** Responsable institucional o dirección.

**Prioridad:** Media.

**Alcance:** Complementaria.

**Estado actual:** Prototipada.

**Historia de usuario:** Como responsable institucional, quiero consultar resultados agregados de mi escuela para revisar la participación y el avance general de sus grupos.

**Criterios de aceptación:**

1. La vista requiere permiso institucional y limita los datos a la escuela de la cuenta activa.
2. El reporte presenta los indicadores agregados y comparaciones por grupo representados, identificando el contexto o periodo consultado.
3. Los totales y porcentajes corresponden a los registros incluidos en la consulta; no mezclan datos de otras instituciones ni datos de demostración.
4. Si no existen resultados disponibles se informa la ausencia de datos; la consulta agregada no concede por sí misma permisos de administración docente.

## Módulo 5. Funcionalidades sin conexión

### HU-016

**Identificador:** HU-016.

**Nombre:** Descarga y realización de actividades sin internet.

**Módulo:** 5. Funcionalidades sin conexión.

**Actor:** Estudiante con sesión previamente validada.

**Prioridad:** Media.

**Alcance:** Complementaria.

**Estado actual:** Prototipada.

**Historia de usuario:** Como estudiante, quiero descargar mis actividades y realizarlas sin internet para continuar practicando cuando no tenga conexión.

**Criterios de aceptación:**

1. Con conexión se puede solicitar la descarga de contenido disponible; solo se marca como descargado después de completar el proceso.
2. Sin conexión, una sesión previamente validada puede abrir y resolver contenido descargado con un indicador visible de su condición offline.
3. Intentar abrir una misión no descargada informa que requiere conexión para obtenerla y no inicia una actividad incompleta.
4. Los resultados de misiones terminadas permanecen asociados a la cuenta y pendientes de envío incluso después de cerrar y volver a abrir la aplicación; no se muestran como recibidos por el docente.

### HU-017

**Identificador:** HU-017.

**Nombre:** Sincronización del progreso.

**Módulo:** 5. Funcionalidades sin conexión.

**Actor:** Estudiante y docente.

**Prioridad:** Media.

**Alcance:** Complementaria.

**Estado actual:** Prototipada.

**Historia de usuario:** Como usuario, quiero enviar mis cambios pendientes al recuperar la conexión y conocer su estado para mantener actualizado mi trabajo sin duplicar resultados.

**Criterios de aceptación:**

1. Al recuperar conexión se inicia el envío de pendientes de la cuenta autorizada y se distinguen los estados pendiente, enviando, confirmado y error.
2. Cada operación conserva un identificador único; reenviarla después de una interrupción no duplica intentos, resultados ni cambios ya aceptados.
3. Una falla de red o servidor conserva las operaciones para reintento; solo las confirmadas dejan de contarse como pendientes.
4. Un conflicto se identifica y conserva trazabilidad hasta aplicar una resolución confirmada; no se trata como éxito ordinario. La elección de versión requiere resolver la discrepancia entre las secuencias móvil y web.
5. Al completar el envío se actualizan el indicador de pendientes y la última sincronización; los resultados recibidos quedan disponibles en el seguimiento docente y los pendientes de otra cuenta permanecen aislados.

## Módulo 6. Accesibilidad y bienestar

### HU-018

**Identificador:** HU-018.

**Nombre:** Configuración de accesibilidad y preferencias.

**Módulo:** 6. Accesibilidad y bienestar.

**Actor:** Estudiante y docente.

**Prioridad:** Media.

**Alcance:** MVP.

**Estado actual:** Prototipada.

**Historia de usuario:** Como usuario, quiero ajustar la presentación y los apoyos disponibles para utilizar la plataforma según mis preferencias y necesidades de interacción.

**Criterios de aceptación:**

1. Las opciones disponibles en cada plataforma se identifican antes de activarlas; cambiar tema o tamaño de texto actualiza la vista sin alterar las respuestas ni el progreso.
2. En móvil, activar alto contraste o movimiento reducido modifica la presentación correspondiente; en web se aplican las preferencias de texto y movimiento representadas, sin asumir paridad de controles.
3. En móvil, activar lectura y volumen permite escuchar las instrucciones mediante el control correspondiente; desactivar el audio impide la lectura automática.
4. Las preferencias móviles guardadas se recuperan al volver a abrir el prototipo o la aplicación; restaurar ajustes devuelve sus valores iniciales sin borrar el historial académico.

### HU-019

**Identificador:** HU-019.

**Nombre:** Actividades de descanso mediante Pausa Estelar.

**Módulo:** 6. Accesibilidad y bienestar.

**Actor:** Estudiante.

**Prioridad:** Baja.

**Alcance:** Complementaria.

**Estado actual:** Prototipada.

**Historia de usuario:** Como estudiante, quiero consultar y realizar una Pausa Estelar para alternar la práctica matemática con una actividad de descanso fuera de la pantalla.

**Criterios de aceptación:**

1. El catálogo permite consultar actividades y aplicar los filtros representados; abrir una actividad muestra instrucciones y duración antes de iniciarla.
2. Una actividad iniciada muestra su estado y, cuando corresponde, un temporizador; su finalización presenta la confirmación de actividad cumplida.
3. Aplicando R5 propuesta, al alcanzar 20 minutos de aprendizaje se ofrece la pausa y se permite posponerla para continuar la misión.
4. Completar una pausa no modifica aciertos ni dificultad matemática; el reconocimiento de bienestar se distingue del resultado de una misión de sumas.

## Módulo 7. Información y soporte

### HU-020

**Identificador:** HU-020.

**Nombre:** Consulta de información, ayuda y soporte.

**Módulo:** 7. Información y soporte.

**Actor:** Visitante y usuario de la plataforma.

**Prioridad:** Baja.

**Alcance:** Complementaria.

**Estado actual:** Prototipada.

**Historia de usuario:** Como visitante o usuario, quiero consultar información y ayuda o enviar una solicitud de soporte para conocer la plataforma y comunicar las dificultades que encuentre.

**Criterios de aceptación:**

1. El visitante puede consultar presentación, información institucional y demostración sin obtener acceso a datos académicos privados; los planes se identifican como propuestas sujetas a validación.
2. La sección de ayuda permite abrir preguntas y orientación de uso, incluidas las indicaciones de instalación representadas, sin afirmar que la PWA ya está instalada.
3. En contacto institucional, la ausencia de escuela, responsable, correo válido o aceptación requerida señala los campos y evita confirmar el envío.
4. En soporte, un reporte que no cumple la descripción mínima representada muestra el error; una solicitud válida solo se informa como enviada después de su recepción confirmada.
5. Sin conexión se informa que una solicitud permanece pendiente y no se muestra como recibida; su conservación y envío dependen del mecanismo duradero de HU-017.

