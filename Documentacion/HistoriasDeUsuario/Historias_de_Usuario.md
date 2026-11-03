# Historias de Usuario — Órbita Kids

## Introducción

Órbita Kids propone reforzar el aprendizaje de sumas en niños de 6 a 9 años mediante una aventura espacial. La experiencia conecta actividades matemáticas, personajes, planetas, misiones y recompensas con herramientas docentes de organización y seguimiento.

Este documento reúne 20 historias identificadas en la documentación y los prototipos del repositorio. La revisión del 3 de noviembre de 2026 encontró prototipos HTML con interacciones locales y datos de demostración; no identificó proyectos operativos Flutter/React ni servicios de backend que permitan considerar entregada la plataforma integrada.

## Objetivo del documento

Establecer un catálogo trazable de necesidades funcionales, expresadas desde la perspectiva de los usuarios y acompañadas de criterios verificables, para apoyar la planeación, el desarrollo y la evaluación del proyecto universitario de Ingeniería en Desarrollo y Gestión de Software.

## Alcance

Se incluyen siete módulos: autenticación y usuarios; exploración y aprendizaje; gestión docente; administración institucional; funcionalidades sin conexión; accesibilidad y bienestar; e información y soporte.

El [README principal](../../README.md) delimita el MVP educativo: sumas, tres niveles, dos modalidades, personaje, aventura, adaptación mediante reglas, registro de desempeño y herramientas docentes. Los prototipos amplían esta propuesta. Para organizar la revisión se clasifican **HU-001 a HU-012 y HU-018 como MVP**, y **HU-013 a HU-017, HU-019 y HU-020 como complementarias**. Esta clasificación es una propuesta documental, no una decisión aprobada del equipo. En HU-018 se propone priorizar la accesibilidad básica como requisito transversal.

Las opciones avanzadas de personalización, los proveedores federados adicionales y la verificación institucional en dos pasos requieren priorización propia, aunque aparezcan dentro de historias generales. Las funciones institucionales y offline no se incorporan automáticamente al compromiso inicial.

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

Estas agrupaciones permiten mantener el catálogo universitario sin duplicar necesidades. Durante la planeación de iteraciones podrán dividirse en tareas o historias menores, preservando trazabilidad y sin asumir que deban implementarse completas en una sola iteración. HU-020 agrupa orientación y contacto; el envío de una solicitud es un escenario distinto de la consulta de ayuda.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), pantallas de acceso y `register`; [prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html), `loginAs()` y estados de acceso; [SD-02: acceso federado](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-02_inicio_de_sesion_federado_con_keycloak.mmd); [SD-03: registro](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-03_registro_de_estudiante_con_codigo_de_grupo.mmd).

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `recover`, `security`, desbloqueo y `logout`; [catálogo móvil](../../Frontend/Movil/prototipo/README.md), estados 12–14 y cierre; [SD-02](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-02_inicio_de_sesion_federado_con_keycloak.mmd); [SD-07: cierre seguro](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-07_cerrar_sesion_de_forma_segura.mmd). MFA institucional es una variante complementaria descrita en [SD-W04](../../Frontend/Web/diagrama_de_secuencia/mermaid/SD-W04_direccion_entra_con_verificacion_en_dos_pasos.mmd).

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `avatar`, `sprofile`, `tprofile`, `editProfile`, `avSave()`; [README principal](../../README.md), selección de personaje; [catálogo móvil](../../Frontend/Movil/prototipo/README.md). El MVP cubre selección básica; accesorios adicionales requieren priorización.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `PLANETS`, `MISSIONS`, `map`, `mission`, `nextMission()`; [catálogo móvil](../../Frontend/Movil/prototipo/README.md), pantallas 15–19; [README principal](../../README.md), alcance. La cantidad definitiva de niveles queda pendiente de validación.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `genItems()`, `visual`, `choice`, `checkVisual()`, `pick()`, `quitRun()`; [SD-04: resolver misión](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-04_resolver_una_mision_offline_first.mmd). El registro detallado persistente sigue pendiente; el prototipo conserva principalmente contadores e identificadores.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `nextItem()`, `results`, `refuerzo()` y reglas del panel de arquitectura; [SD-04](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-04_resolver_una_mision_offline_first.mmd); [adaptación en GUI](../GUI/Practica_Sketches/readme.md). Umbrales, niveles y lugar de ejecución de reglas pendientes de aprobación.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `results`, `planetUnlocked()`, `doneCount()`, estrellas, piezas y banderas de guardado; [SD-04](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-04_resolver_una_mision_offline_first.mmd); [catálogo móvil](../../Frontend/Movil/prototipo/README.md), pantalla 22.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `progress`, `freshState()`, `sessAcc` e historial; [roles de usuario](../DiagramaRolesUsuario/readme.md); [README principal](../../README.md), seguimiento.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `groups`, `group` y acción `newGroup`; [prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html), grupos y `sendReq`; [roles](../DiagramaRolesUsuario/readme.md). La creación directa frente a solicitud institucional requiere validación; HU-014 concentra licencias y códigos.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `groupCode`, `register`, `CODE_STATES`; [SD-03](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-03_registro_de_estudiante_con_codigo_de_grupo.mmd). HU-001 utiliza este proceso; no documenta una segunda creación de cuenta.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `create`, `activities`, `assigned`, `startMission()`; [prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html), `FORMS.act`, `confirmPublish`; [SD-06](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-06_docente_publica_una_actividad_y_revisa_el_progreso.mmd). Hay discrepancias de cantidad, destinatarios y publicación que deben resolverse antes de aceptar la implementación.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `student`, `reports` y avisos R4; [prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html), detalle y reportes; [SD-06](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-06_docente_publica_una_actividad_y_revisa_el_progreso.mmd). La exportación simulada no se considera parte entregada de esta historia.

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

**Referencias:** [Prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html), `teachers`, `FORMS.invite`, `approve`, `reject`, `deactivate`; [catálogo web](../../Frontend/Web/prototipo/README.md), pantalla 24; [roles originales](../DiagramaRolesUsuario/readme.md). La institucionalización del rol y su matriz de permisos requieren validación.

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
5. Solicitar cambio de plan registra una solicitud y su confirmación; no se muestra como pago, contratación o ampliación ya aplicada.

**Referencias:** [Prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html), `igroups`, `license`, `makeCode`, `renew`, `addSeats`, `archive`, `sendPlanReq`; [Canvas](../ModelBusinesCanvas/README.md), licencias como hipótesis comercial. La conservación histórica y límites deben verificarse en la implementación; las acciones locales no los garantizan.

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

**Referencias:** [Prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html), `ireports`; [catálogo web](../../Frontend/Web/prototipo/README.md), pantalla 27; [README web](../../Frontend/Web/README.md), experiencia institucional. El alcance definitivo y las fórmulas de agregación requieren validación.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `downloads`, `connection`, disponibilidad local y `setNet()`; [SD-01](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-01_arranque_y_restauracion_de_sesion.mmd); [SD-04](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-04_resolver_una_mision_offline_first.mmd). La descarga y persistencia durables están documentadas, pero el HTML simula disponibilidad y conserva progreso principalmente en memoria.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `enqueue()`, `runSync()`, `sync`; [prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html), cola y `syncNow`; [SD-05](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-05_sincronizacion_al_reconectar.mmd); [SD-W03](../../Frontend/Web/diagrama_de_secuencia/mermaid/SD-W03_asignar_apoyo_sin_conexion_y_sincronizar.mmd). La idempotencia y comunicación real están pendientes; los temporizadores del prototipo no las verifican.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `settings`, `theme`, `PREF_DEF`, `loadPrefs()`, `savePrefs()`, `applyPrefs()`, `speak()`; [prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html), preferencias `big`, `rm` y tema; [README móvil](../../Frontend/Movil/README.md), accesibilidad. Su priorización transversal en el MVP es propuesta de este catálogo; el audio y controles específicos deben validarse por plataforma.

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

**Referencias:** [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `pause`, `pauseDetail`, `pauseDoing`, `pauseDone`, reglas R5; [SD-04](../../Frontend/Movil/diagrama_de_secuencia/mermaid/SD-04_resolver_una_mision_offline_first.mmd); [catálogo móvil](../../Frontend/Movil/prototipo/README.md), sección bienestar. La medición de tiempo real requiere definición; el prototipo incrementa minutos de forma aproximada.

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

**Referencias:** [Prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html), `site`, `explore`, `help`, `FORMS.contact`, `FORMS.report`; [prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html), `help`, `plans`; [Canvas](../ModelBusinesCanvas/README.md). Los formularios actuales simulan confirmaciones y no acreditan un servicio de atención operativo.

## Observaciones pendientes

Estas observaciones conservan contradicciones o vacíos de las fuentes. Deben validarse con el equipo y, cuando corresponda, con docentes antes de aprobar los criterios afectados.

| ID | Observación y evidencia | Historias afectadas |
|---|---|---|
| OP-01 | El README principal y GUI definen tres niveles; `LEVELS` de los prototipos representa seis y el móvil contiene seis planetas con 18 misiones. No se adopta una cantidad definitiva nueva. | HU-004 a HU-007, HU-011 |
| OP-02 | Roles documentales consideran a la escuela un actor externo sin interfaz; el prototipo web incorpora dirección con permisos operativos. | HU-001, HU-013 a HU-015 |
| OP-03 | El canal docente principal es PWA, pero el prototipo móvil y SD-06 también representan gestión docente en Flutter. La paridad de plataformas no está acordada. | HU-009, HU-011, HU-012, HU-018 |
| OP-04 | La arquitectura y README principal mencionan MySQL; GUI y Canvas conservan PostgreSQL. No se cambia la arquitectura ni se selecciona tecnología desde este catálogo. | Persistencia de todas las historias |
| OP-05 | El documento de arquitectura centraliza reglas en FastAPI; SD-04 representa un motor local. Además, una descripción de estudiante del prototipo web llama R2 al apoyo tras errores, mientras móvil y secuencias lo llaman R1. | HU-005, HU-006, HU-012 |
| OP-06 | Umbrales R1–R5 y estrellas son propuestas. Deben definirse cálculo, límites e interpretación pedagógica, especialmente con pocas preguntas; recomendación R2 y desbloqueo por completar misiones no son equivalentes. | HU-006, HU-007, HU-012, HU-019 |
| OP-07 | SD-05 móvil aplica la versión del servidor en conflicto; SD-W03 web pide elegir versión. Los contratos propuestos usan `/sync` y `/cambios`, respectivamente. Se requiere una política compartida por tipo de dato. | HU-017 |
| OP-08 | El formulario móvil permite 5–20 ejercicios, pero `startMission()` limita tareas a seis. El formulario web y el móvil tampoco muestran idénticos controles de destinatarios. | HU-005, HU-011 |
| OP-09 | SD-06 sugiere que el borrador se publica al reconectar; las interfaces separan guardar y confirmar publicación. Sin decisión del equipo, no se presupone publicación automática. | HU-011, HU-017 |
| OP-10 | El flujo «Crear grupo» convive con solicitudes a dirección y códigos emitidos por la escuela. Deben precisarse creación directa, autorización y permisos de archivo por rol. | HU-009, HU-014 |
| OP-11 | Las colas, descargas y progreso de los HTML son simulaciones en memoria; `localStorage` móvil guarda preferencias. Faltan persistencia durable, confirmaciones reales, aislamiento verificado y pruebas de idempotencia. | HU-002, HU-008, HU-016, HU-017, HU-020 |
| OP-12 | El prototipo móvil suma cuatro minutos por misión; R5 habla de 20 minutos de aprendizaje. La definición de tiempo activo y tratamiento de pausas debe precisarse. | HU-019 |
| OP-13 | Bloqueo, códigos, verificación, proveedores federados y MFA se representan con datos de demostración. Deben aprobarse política de seguridad y métodos por plataforma sin reutilizar valores fijos. | HU-001, HU-002, HU-013 |
| OP-14 | El nombre «PWA» y los diálogos de instalación no acreditan manifest, service worker o actualización segura. SD-W02 respalda estos requisitos, cuyo desglose de entrega queda pendiente fuera de las 20 historias principales. | Plataforma docente; ayuda de HU-020 |

## Consideraciones sobre funcionalidades futuras

La clasificación complementaria no implica ausencia de valor ni exclusión permanente: indica que la función está respaldada, pero su entrega inicial no está confirmada. Ninguna de las 20 historias se clasifica como futura porque todas tienen representación en los prototipos revisados.

El README principal excluye del alcance inicial otros temas matemáticos, chatbot o adaptación con IA, interfaz familiar, multijugador y diagnóstico de dificultades de aprendizaje. «Nuevas Galaxias» aparece como expansión anunciada. No se crean historias detalladas para estas funciones porque no existe especificación suficiente para comprometer criterios de aceptación.

La instalación y actualización real de la PWA, la exportación de reportes y los canales adicionales de notificaciones cuentan con referencias, pero requieren desglose y priorización posterior. Las licencias son hipótesis comerciales; no se incorpora pago en línea, facturación automática ni precios obligatorios.

## Referencias a la documentación del proyecto

| Fuente | Uso en el catálogo |
|---|---|
| [README principal](../../README.md) | Objetivo educativo, MVP, exclusiones y tecnologías propuestas. |
| [Arquitectura](../DiagramaDeArquitectura/readme.md) | Responsabilidades, identidad, backend y persistencia previstos. |
| [Roles de usuario](../DiagramaRolesUsuario/readme.md) e [interacción de roles](../DiagramaRolesUsuario/practica-05.js) | Actores y límites originales del alcance. |
| [GUI: navegación y sketches](../GUI/Practica_Sketches/readme.md) | Flujos, adaptación y relación prevista con API. |
| [README móvil](../../Frontend/Movil/README.md) y [README web](../../Frontend/Web/README.md) | Organización de productos y entregables. |
| [Prototipo móvil](../../Frontend/Movil/Órbita_Kids_Prototipo.html) y [prototipo web](../../Frontend/Web/Órbita_Kids_PWA_v3.html) | Pantallas, validaciones, reglas y acciones locales. |
| [Catálogo móvil](../../Frontend/Movil/prototipo/README.md) y [catálogo web](../../Frontend/Web/prototipo/README.md) | Estados y escenarios representados. |
| [Secuencias móviles](../../Frontend/Movil/diagrama_de_secuencia/README.md) y [secuencias web](../../Frontend/Web/diagrama_de_secuencia/README.md) | Interacciones y condiciones de integración previstas. |
| [Canvas](../ModelBusinesCanvas/README.md) | Supuestos institucionales, comerciales y de adopción. |

Los HTML enlazados se pueden localizar desde GitHub; su navegación interactiva requiere abrirlos en un navegador. La revisión previa no identificó otro catálogo formal de historias en la carpeta existente, cuyo README estaba vacío. Los criterios aquí escritos están pendientes de validación; las capturas y demostraciones no sustituyen pruebas de aceptación ni prueban la implementación de los servicios finales.
