# Órbita Kids · Todos los prompts

Modelo de IA: **Claude Opus 5.5 (Anthropic)** · claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact)



---

# App móvil · Órbita_Kids_Prototipo.html / _1.html



---

## Prompt 00 · Prompt maestro (todo en uno)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Logos oficiales en PNG: símbolo, nombre «Órbita Kids», eslogan, logo de la app, ícono de la app (tile) y logotipo «Órbita Kids Studios» (horizontal y completo) |
| **Depende de** | Ninguno (es el punto de partida) |
| **Objetivo** | Generar en una sola conversación el prototipo móvil completo. Úsalo si quieres reproducir el resultado sin pasar por los 18 prompts por separado. |

---

## Prompt (copiar y pegar tal cual)


Actúa como diseñador UX/UI senior y desarrollador front-end. Vas a construir el **prototipo interactivo de alta fidelidad de la app móvil «Órbita Kids»** como **un solo archivo HTML autocontenido** (CSS y JS dentro, imágenes como data URI, sin frameworks; solo puedes cargar rough.js 4.6.6 desde jsDelivr y Google Fonts). Todo en **español de México**.

### 1. Contexto del proyecto
- Órbita Kids es una app educativa para niñas y niños de **1.º a 3.º de primaria (6 a 9 años)** que enseña **sumas** con una aventura espacial. La empresa ficticia que la desarrolla es **Órbita Kids Studios** (proyecto académico 2026).
- Stack que debe reflejar la documentación: **app móvil en Flutter**, autenticación con **Keycloak (OIDC, Authorization Code + PKCE)** federado con Google, Facebook e instituciones (OIDC o SAML 2.0), **API REST en FastAPI**, base de datos **MySQL**, almacenamiento local **SQLite + Keystore**, enfoque **offline first**. Los docentes también tienen una PWA, pero aquí solo diseñas la app móvil (que tiene ambos roles: estudiante y docente).
- Es un prototipo: **no hay conexión real** con Keycloak, Google, Facebook ni backend; todo se simula con datos demostrativos. Solo las preferencias se guardan en localStorage (clave `orbita-kids-prefs-v2`). Fecha de demostración: 29 de octubre de 2026.
- Adjunto los logos oficiales: úsalos tal cual, no los redibujes.

### 2. El «estudio» que envuelve al prototipo
Página oscura («estudio nocturno») con barra superior fija con la marca y **4 pestañas**: **Prototipo · Sketches · Wireframes · Diagrama de secuencia** (navegación por hash #prototipo, #sketches, #wireframes, #secuencia).
- Vista Prototipo: a la izquierda un **índice de pantallas** agrupado por secciones con colores; al centro un **teléfono de 414 × 868** (escala para caber, barra de estado 9:41, botones «↻ Reabrir app», «← Atrás», «Tema: automático»); a la derecha la **ficha de la pantalla actual** (número, nombre, categoría, rol, objetivo, qué hace, acciones, plataforma y enlaces «Sketch y ficha →» y «Wireframe con medidas →»).
- Panel «Ver en acción» con un **recorrido automático** (▶, ‹ ›, ■) que toca botones solo y va de la splash al login, la misión, resultados, Pausa Estelar, offline y docente.
- Panel «Simular condiciones»: Conexión En línea / Sin conexión, Simular error de sincronización, Simular servidor lento, Reducir movimiento, Restablecer prototipo (incluye onboarding).
- Panel «Cómo probar» con: cuenta `luna.astro · orbita123`, código de desbloqueo `482915` (vencido `111111`), códigos de grupo `ORB-2A7K` válido, `ORB-OLD1` vencido, `ORB-FULL` sin lugares, y «Explorar sin cuenta».

### 3. Sistema visual
Paleta: Azul espacial #0D102B, Índigo #191B58, Morado principal #746BE8, Violeta #9186F5, Lavanda #C9C3FF, Amarillo estelar #FFD166 (recompensas y «Continuar misión»), Turquesa #69D6DE (docente), Verde menta #82D9B4 (bienestar), Blanco cósmico #FAF9FF, Texto #292742. Tipografías: **Fredoka** (títulos), **Nunito** (texto), **Caveat** (sketches). Radios 12/18/26. Botones grandes «con volumen», navegación inferior flotante, entrada escalonada al abrir pantalla, opciones de respuesta en píldoras de color (el color nunca comunica el resultado: siempre ícono + texto). Íconos SVG propios de trazo redondeado 2.2. Tema claro, oscuro y automático.

### 4. Pantallas (58 + «Conoce a Orbi»), cada una con su ficha
02 Splash y onboarding: 01 Splash Órbita Kids · 02 Splash Studios · 03 Onboarding (4-5 pasos) · 04 Loading.
03 Autenticación: 05 Inicio de sesión · 06 Google · 07 Facebook · 08 Acceso institucional · 09 Estados de autenticación · 10 Registro · 11 Código de grupo · 12 Recuperar cuenta · 13 Cuenta bloqueada · 14 Código de desbloqueo.
04 Estudiante: 15 Home · 16 Mis actividades · 17 Personaliza tu astronauta · 18 Mapa espacial · 19 Detalle de misión · 20 Sumas con apoyo visual · 21 Selección de respuestas · 22 Resultados · 23 Mi progreso · 24 Avisos · 25 Perfil.
05 Bienestar: 26 Pausa Estelar · 27 Detalle de actividad · 28 Actividad en curso.
06 Docente: 29 Home · 30 Mis grupos · 31 Detalle del grupo · 32 Detalle del estudiante · 33 Crear actividad · 34 Actividades · 35 Resultados y reportes · 36 Avisos · 37 Perfil.
07 Offline: 38 Estado de conexión · 39 Centro de descargas · 40 Sincronización.
08 Configuración: 41 Configuración · 42 Accesibilidad · 43 Apariencia · 44 Editar perfil · 45 Privacidad · 46 Seguridad y sesiones · 47 Ayuda · 48 Términos · 49 Cerrar sesión · 50 Acerca de Órbita Kids · 51 Órbita Kids Studios.
09 Planes y expansión: 52 Planes institucionales · 53 Nuevas Galaxias.
Modo explorar: 54 Entrar sin cuenta · 55 Inicio en modo explorar · 56 Más · 57 Disponible con cuenta · 58 Carga esqueleto. Extra: 59 Conoce a Orbi.

(Los detalles de cada grupo, los datos demostrativos y las reglas están en los prompts 03 a 13; inclúyelos todos.)

### 5. Documentación generada desde la app
- **Sketches de baja fidelidad** (rough.js + Caveat, papel #F7F6F1): uno por pantalla y por cada estado que provoca una acción, dibujados midiendo el DOM real del prototipo; círculos rojos numeran las acciones; cada tarjeta se abre como ficha.
- **Wireframes con medidas Flutter** en dp: lienzo 390 × 844, rejilla de 4 columnas (margen 20, medianil 16), padding, tamaños, espacios y equivalencia en widgets.
- **Diagramas de secuencia UML interactivos**: SD-00 general + SD-01 a SD-07, con reproducción paso a paso, tema claro/oscuro y tabla de mensajes.

Entrégalo como artifact publicado. Si el archivo se vuelve muy grande, avísame y seguimos por partes en esta misma conversación.



---

## Prompt 01 · Contexto del proyecto y estructura del estudio

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Logos oficiales en PNG: símbolo, nombre «Órbita Kids», eslogan, logo de la app, ícono de la app (tile) y logotipo «Órbita Kids Studios» (horizontal y completo) |
| **Depende de** | Ninguno |
| **Objetivo** | Arrancar la conversación: dar contexto y obtener la cáscara del prototipo (estudio con 4 vistas, teléfono, índice y ficha). |

---

## Prompt (copiar y pegar tal cual)


Hola. Estoy haciendo el proyecto integrador de mi carrera: una app educativa llamada **Órbita Kids**, desarrollada por nuestra empresa ficticia **Órbita Kids Studios**. Te adjunto los logos oficiales (no los redibujes, úsalos como imagen).

**Qué es la app:** enseña **sumas** a niñas y niños de 1.º a 3.º de primaria con una aventura espacial: cada planeta es un nivel, cada misión repara una parte de la nave. Tiene dos roles en la misma app móvil: **estudiante** y **docente**. La escuela contrata una licencia y reparte **códigos de grupo**.

**Arquitectura que debe verse reflejada en la documentación:** app móvil en **Flutter**; acceso con **Keycloak** (OIDC + PKCE, navegador del sistema, nunca WebView) federado con **Google, Facebook e instituciones**; **API REST FastAPI**; **MySQL**; en el teléfono **SQLite + Keystore**; la app es **offline first**.

Quiero un **prototipo interactivo de alta fidelidad** en **un solo archivo HTML** (todo inline, sin frameworks, imágenes como data URI). En esta primera vuelta arma la estructura:

1. Una página tipo **«estudio de prototipo nocturno»** (fondo #0A0C20 con degradados radiales índigo) con barra superior fija: marca «Órbita Kids · Prototipo» y pestañas **Prototipo · Sketches · Wireframes · Diagrama de secuencia** (rutas por hash).
2. En **Prototipo**: índice de pantallas a la izquierda (agrupado por secciones con un punto de color), **teléfono de 414 × 868** al centro que se escala para caber en la ventana, y **ficha de la pantalla** a la derecha con: número, nombre, categoría, rol (Público / Estudiante / Docente / Ambos), objetivo, qué hace, acciones y plataforma.
3. Un **motor de pantallas** sencillo: objeto `SCR` con una función `html()` por pantalla, historial para «Atrás», transiciones (deslizar y fundido) y capas para hojas y modales.
4. Debajo del teléfono: «↻ Reabrir app», «← Atrás» y «Tema: automático».
5. En móvil (≤ 760 px) el índice se vuelve un desplegable «Saltar a una pantalla ▾».

Todo en español de México, accesible (foco visible amarillo, `aria-*`, respetar safe areas). Por ahora solo deja las pantallas 01 a 04 de ejemplo; las demás te las paso en los siguientes mensajes.



---

## Prompt 02 · Sistema visual de la marca

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompt 01 |
| **Objetivo** | Fijar paleta, tipografía, componentes e iconografía antes de diseñar pantallas. |

---

## Prompt (copiar y pegar tal cual)


Ahora define el **sistema visual** y aplícalo en todo el prototipo. Agrega también una sección «01 Sistema visual» que lo documente (muestras de color con uso, tipografías, botones, tarjetas e íconos).

**Paleta (nombre · hex · uso):**
- Azul espacial #0D102B · fondos principales, splash, mapa, resultados.
- Azul índigo #191B58 · fondos secundarios, encabezados docentes.
- Morado principal #746BE8 (presionado #5E55D6) · acciones principales.
- Violeta #9186F5 · destacados y progreso.
- Lavanda #C9C3FF · detalles y superficies.
- Amarillo estelar #FFD166 · recompensas y el botón «Continuar misión».
- Turquesa #69D6DE · interacción y experiencia docente.
- Verde menta #82D9B4 · bienestar y actividad física.
- Blanco cósmico #FAF9FF · fondo del tema claro. Texto oscuro #292742.
- Estados: éxito #1F8F5F sobre #E3F7EE, error #C8455E sobre #FDECEF (nunca rojo agresivo para niños).

**Tipografía:** Fredoka 400-700 para títulos (con `text-wrap: balance`), Nunito 400-900 para texto, Caveat para lo manuscrito. Radios 12, 18 y 26 px.

**Componentes:** botones grandes con «volumen» (sombra inferior que se hunde al tocar), botón primario morado, secundario lavanda, recompensa amarillo; tarjetas blancas con borde #E4E1F5; chips y segmentos; navegación inferior **flotante** con 4-5 destinos; hojas inferiores y modales; toasts; teclado numérico grande propio.

**Iconografía:** set de íconos SVG propio, trazo redondeado de 2.2, en un objeto `ICONS` (home, map, rocket, star, planet, user, users, bell, cog, cloud, wifioff, refresh, lock, school, book, brush, leaf, run, target, grid, palette, chart, clip, etc.). Incluye los logos de Google y Facebook en SVG para los botones de acceso.

**Reglas de accesibilidad visual:** contraste AA, objetivos táctiles ≥ 48 dp, el color nunca es el único indicador (siempre ícono + texto), animaciones de entrada escalonada solo al abrir pantalla y desactivadas con «Reducir movimiento».



---

## Prompt 03 · Splash, onboarding y loading (pantallas 01–04)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Logos ya adjuntos |
| **Depende de** | Prompts 01–02 |
| **Objetivo** | Diseñar la bienvenida. |

---

## Prompt (copiar y pegar tal cual)


Diseña las pantallas **01 a 04**, cada una con su ficha:

**01 · Splash Órbita Kids** (rol Público): fondo espacial con estrellas, planeta con brillo, logotipo oficial, eslogan, astronauta infantil que saluda sobre una **luna morada**, cohete en órbita y símbolos matemáticos flotando (+, =, 1, 2, 3). Dura ~2 s; un toque la omite. Lleva a 02.

**02 · Splash Órbita Kids Studios**: logotipo empresarial vertical (símbolo, nombre, STUDIOS, eslogan) sobre fondo casi negro con planeta anillado y cohete. Dura 1.5 s. Después: 03 si es primer acceso, 05 si no hay sesión, 04 si hay sesión guardada.

**03 · Onboarding** (pasos con contador «1 de N», botón Saltar, puntos de progreso con `role="progressbar"`, botón Anterior y Siguiente; el último dice «🚀 Comenzar» en amarillo):
1. **Aprende matemáticas** — Practica sumas con estrellas, planetas y cohetes. (arte: «3 + 2» y estrellas)
2. **Explora nuevos planetas** — Cada planeta es una etapa de tu viaje. (tres planetas)
3. **Completa misiones** — Gana estrellas y repara tu nave. Si te equivocas, te ayudamos. (cohete, «+3 estrellas»)
4. **Muévete fuera de la pantalla** — Descubre, crea y juega en el mundo real con Pausa Estelar. (astronautas saltando y mirando)
Cada paso tiene un botón **«Escuchar»** que lee el texto con la síntesis de voz del navegador.

**04 · Loading**: carga real (no decorativa) con mensaje y submensaje. Cuando viene del login muestra los pasos del flujo de autenticación como lista que se va marcando: Elegiste un método de acceso → Flutter inició el flujo con PKCE → Keycloak redirigió al proveedor → El proveedor validó tu identidad → La respuesta volvió a Keycloak → Keycloak generó sus tokens → La app recibió el código y los tokens → El backend validó permisos y grupos → Se identificó tu rol.



---

## Prompt 04 · Autenticación y seguridad (pantallas 05–14)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 01–03 |
| **Objetivo** | Simular todo el acceso federado con Keycloak, registro, código de grupo, recuperación y bloqueo. |

---

## Prompt (copiar y pegar tal cual)


Diseña el bloque **03 · Autenticación y seguridad** (pantallas 05 a 14). Recuerda: es simulado, pero debe sentirse real y explicar el flujo.

**05 · Inicio de sesión:** botones «Continuar con Google», «Continuar con Facebook», «Acceso institucional» y formulario de cuenta Órbita Kids (usuario + contraseña). Enlaces a Registro, Código de grupo, Recuperar cuenta y «Explorar sin cuenta». Cuenta demo: `luna.astro / orbita123`. **3 intentos fallidos bloquean 15 minutos.**

**06 y 07 · Navegador seguro simulado (Google / Facebook):** una hoja que imita el navegador del sistema con la barra de dirección (`accounts.google.com`, `www.facebook.com`) y un selector de cuentas:
- Google: `ana.rios@escuela.example` (Docente · Google Workspace de la escuela) · `adulto.responsable@correo.example` (adulto que administra la cuenta de Luna, 2° A) · `nuevo.docente@correo.example` (identidad sin cuenta → estado notRegistered) · `ana.personal@correo.example` (mismo correo que una cuenta existente → vincular).
- Facebook: Ana Ríos (Docente) · Adulto responsable de Luna · Perfil sin rol (→ noRole).
- Abajo, «Escenarios alternativos»: Cancelar inicio de sesión, Error del proveedor, Proveedor no disponible, Cuenta bloqueada, Error de comunicación con backend, Se perdió la conexión.

**08 · Acceso institucional:** buscador de escuela con: Escuela Primaria Demo Órbita (Google Workspace for Education · OIDC), Colegio Demo Horizonte (Microsoft Entra ID · SAML 2.0, docente sin licencia activa) e Instituto Demo Cometa (caído → no disponible).

**09 · Estados de autenticación:** una pantalla por resultado con ilustración amable, explicación y cómo seguir: cancelado, error del proveedor, no disponible, bloqueada, backend, sin red, no registrado, sin rol, vinculación de cuentas.

**10 · Registro:** estudiante o docente con datos mínimos; el estudiante lo crea un adulto responsable, con aviso de privacidad.

**11 · Código de grupo:** campo grande con formato `ORB-XXXX`. `ORB-2A7K` válido (2° A, Mtra. Ana Ríos); `ORB-OLD1` «Este código venció. Pide uno nuevo a tu escuela.»; `ORB-1C2P` «Ese grupo ya no está disponible (ciclo terminado).»; `ORB-FULL` «La licencia de tu escuela no tiene lugares disponibles. Avisa a la dirección.»

**12 · Recuperar cuenta:** por correo del adulto o del docente, sin revelar si la cuenta existe.

**13 · Cuenta bloqueada:** cuenta regresiva de 15 min, mensaje que no asusta, opciones para desbloquear.

**14 · Código de desbloqueo:** 6 casillas con avance automático y pegado; `482915` correcto, `111111` vencido.

Cuando el acceso es correcto, pasa por 04 Loading mostrando los pasos del flujo y luego al home según el rol.



---

## Prompt 05 · Experiencia del estudiante y misiones de sumas (15–25)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 01–04 |
| **Objetivo** | Diseñar el núcleo educativo: mapa, misiones, modalidades de suma, reglas adaptativas, resultados y progreso. |

---

## Prompt (copiar y pegar tal cual)


Diseña el bloque **04 · Estudiante** (pantallas 15 a 25) con la estudiante demo **Luna** (grupo 2° A).

**Niveles (6):**
1 Despegue — resultado hasta 5, con objetos · 2 Órbita baja — hasta 10 · 3 Órbita alta — hasta 20 sin pasar la decena (12 + 5) · 4 Cinturón de asteroides — hasta 20 pasando la decena (8 + 5) · 5 Nebulosa — dos cifras sin llevar (23 + 14) · 6 Galaxia — dos cifras llevando (27 + 15).

**Planetas (uno por nivel, cada uno repara una parte de la nave):** Planeta Verde (luces) · Nébula (antena, con anillo) · Saturnia (motor, anillo) · Cometa Azul (alas) · Planeta Rubí (escudo) · Galaxia Final (cabina, anillo).

**18 misiones (3 por planeta, tipo visual / selección / mixta)**, por ejemplo: m1 «Enciende las luces» (visual, 2 + 1), m2 «Cuenta los cometas», m3 «Revisa el tablero», m4 «Recoge estrellas» (5 + 3), m5 «Repara la antena», m6 «Señal a la Tierra», m7 «Anillos de números» (12 + 5)… hasta m18 «Regreso a casa» (55 + 29). Cada una con historia corta, objetivo y dos ejemplos.

**Pantallas:**
- **15 Home:** saludo, botón amarillo «Continuar misión», tareas de la maestra, Pausa Estelar sugerida, estrellas.
- **16 Mis actividades:** separa lo que pide la maestra (actividades activas del grupo con fecha) de las misiones propias.
- **17 Personaliza tu astronauta:** casco, traje, accesorios, pose y expresión; algunas opciones se desbloquean con logros (nunca con compras).
- **18 Mapa espacial:** recorrido vertical con los 6 planetas en zigzag, etiquetas y estado (completado, actual, bloqueado).
- **19 Detalle de misión:** historia, objetivo, modalidad, nivel y ejemplos antes de empezar.
- **20 Sumas con apoyo visual (Modalidad A):** dos grupos de objetos (estrellas, planetas, cohetes) y teclado numérico. Error 1: se numeran los objetos. Error 2: la respuesta se explica. **Regla R1: 2 errores seguidos al primer intento activan apoyo visual extra.** Salir pide confirmación. Funciona sin Internet.
- **21 Selección de respuestas (Modalidad B):** 4 opciones grandes en píldoras; nada se marca antes de responder; tras un error se puede ver una pista con dibujos; la respuesta se revela al segundo intento.
- **22 Resultados:** correctas, intentos, estrellas, insignia, la regla aplicada (**R2** avanzar a la siguiente misión o **R3** misión de refuerzo) y el estado de envío a la base (pendiente/confirmado). **Sin mensajes negativos ni comparaciones.**
- **23 Mi progreso:** evolución de 6 semanas (22 sep a 27 oct), insignias y planetas.
- **24 Avisos:** lo importante sin presión.
- **25 Perfil:** identidad, logros, ajustes.

**Insignias:** Primer despegue, Mecánico estelar, Contador de cometas (10 seguidas), Explorador activo (una Pausa Estelar), Señal recibida (termina Nébula), Paciencia lunar (corrige tras una pista).

Cada intento se guarda primero en local con un **UUID** y entra a la cola de sincronización.



---

## Prompt 06 · Pausa Estelar: bienestar fuera de la pantalla (26–28)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompt 05 |
| **Objetivo** | Diseñar el módulo de actividad física y creatividad. |

---

## Prompt (copiar y pegar tal cual)


Diseña **05 · Bienestar: Pausa Estelar** (pantallas 26, 27 y 28 + el estado «actividad cumplida»). Objetivo: que el niño deje el teléfono y se mueva, explore o cree.

**4 categorías:** Movimiento espacial (muévete como astronauta, verde #4DBB98) · Exploración al aire libre (con un adulto cerca, #3FBCC6) · Creatividad fuera de pantalla (crea con tus manos, #A99BF5) · Retos familiares (para hacer juntos, #E0A53A).

**24 retos**, cada uno con: nombre, ilustración (la mascota haciendo la actividad), duración, descripción, objetivo, materiales, 3 pasos, **nota de seguridad** y **alternativa adaptada** (sentado, en silla de ruedas, desde una ventana, etc.). Ejemplos:
- Saltos lunares · 30 s · 10 saltos suaves · seguridad: descalzo o con tenis, nunca en calcetines · alternativa: subir y bajar talones.
- Equilibrio orbital · 20 s por pie · siempre con apoyo cerca.
- Caminata del rover · 1 min · alternativa: mover los brazos como ruedas.
- Observa las nubes · 5 min · nunca mirar directo al sol.
- Tesoros naturales · 10 min · no arrancar plantas, lavarse las manos.
- Cazadores de formas · Arcoíris del entorno · Explora el jardín · Plantas y animales · Caminata supervisada (15 min).
- Dibuja tu planeta · Cohete de papel · Crea una constelación · Sistema solar casero · Nave reutilizable.
- Caminata en familia (cuenten cosas y súmenlas al final) · Exploradores en familia · Juegos tradicionales (avión, lotería, encantados) · Cuento espacial compartido · Manualidad en familia.
- Despegue espacial · Molino de brazos y piernas · Estiramiento de astronauta.

**26 Pausa Estelar:** pestañas por categoría y tarjetas con duración. **27 Detalle:** todo lo anterior + «Empezar». **28 Actividad en curso:** temporizador grande que invita a dejar el teléfono, pictogramas de movimiento, pausar/terminar; al terminar, estado cumplido con festejo y la insignia «Explorador activo». Respeta «Reducir movimiento».



---

## Prompt 07 · Experiencia del docente (29–37)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 01–05 |
| **Objetivo** | Diseñar el seguimiento docente dentro de la app móvil. |

---

## Prompt (copiar y pegar tal cual)


Diseña **06 · Docente** (pantallas 29 a 37) con la docente demo **Mtra. Ana Ríos** (`ana.rios@escuela.example`, Google Workspace for Education). Tema con acento **turquesa** y encabezados índigo.

**Datos demostrativos:**
- Grupos: 2° A (ORB-2A7K, 12 estudiantes: Luna M., Mateo R., Sofía G., Diego L., Valeria P., Emiliano C., Camila H., Santiago T., Regina V., Iker S., Ximena D., Leonardo F.) · 2° B (ORB-2B3M, 10) · 3° A (ORB-3A9Q, 11) · 1° C (ORB-1C2P, archivado, ciclo 2025-26, 20).
- Genera aciertos, pendientes, tendencia de 6 semanas y estado con un generador pseudoaleatorio con semilla (para que siempre salga igual). Estados: Al día · Necesita apoyo (aciertos < 68 %) · Sin actividad reciente (> 6 días) · Ciclo terminado. Fija a Luna M. en 84 % y a Diego L. en 61 % (necesita apoyo en «Sumas que pasan de 10» y «Volver a contar el primer grupo»).
- Errores frecuentes: Sumas que pasan de 10 · Volver a contar el primer grupo · Confundir +1 y +2 · Sumar decenas con unidades · Respuestas con un número de más.
- Actividades: «Estrellas hasta 10» (2° A, visual, nivel 2, activa) · «Selección rápida» (2° B) · «Sumas hasta 20» (2° A, nivel 4) · «Decenas en órbita» (3° A, cerrada) · «Repaso de la semana» (3° A, programada).

**Pantallas:** 29 Home docente (resumen de grupos, quién necesita apoyo, actividades activas) · 30 Mis grupos · 31 Detalle del grupo (estudiantes con etiqueta de estado, actividades, resultados) · 32 Detalle del estudiante (aciertos, tendencia, errores frecuentes, asignar refuerzo) · 33 Crear actividad (nombre, grupo, destinatarios, modalidad con tarjetas, nivel, cantidad, fecha, instrucciones, vista previa; **sin Internet solo guarda borrador; publicar requiere Internet y confirmación**) · 34 Actividades (Activa, Programada, Cerrada, Borrador) · 35 Resultados y reportes (selector de grupo, cifras, gráfico, errores frecuentes; legible en teléfono, sin tablas anchas) · 36 Avisos · 37 Perfil docente (con acceso a 52 Planes institucionales).



---

## Prompt 08 · Modo offline first y sincronización (38–40)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 05–07 |
| **Objetivo** | Hacer visible el comportamiento sin Internet y la cola de envíos. |

---

## Prompt (copiar y pegar tal cual)


Implementa el **modo offline first** en todo el prototipo y diseña **07 · Offline** (pantallas 38 a 40).

- Indicador de red en la barra de estado del teléfono (nube) que reacciona al interruptor «Conexión: En línea / Sin conexión» del estudio. Tocarlo abre 40 Sincronización si hay pendientes, o 38 si no.
- **38 Estado de conexión:** estado actual, lista de lo que funciona sin Internet (misiones descargadas, Pausa Estelar, progreso local) y lo que requiere conexión (publicar, descargar, iniciar sesión por primera vez), última sincronización. Mensajes amigables para niños.
- **39 Centro de descargas:** barra de almacenamiento y lista: Planeta Verde 12.4 MB (descargado 27 oct), Nébula 14.1 MB, Saturnia 15.8, Cometa Azul 16.2, Planeta Rubí 17.1, Galaxia Final 18.0 (sin descargar), Tareas 0.6 MB (hoy 8:15), Pausa Estelar 3.2 MB (incluida). Descargar requiere Internet; si es pesado, pide ayuda a un adulto.
- **40 Sincronización:** cola de intentos y resultados, cada uno con su **identificador único (UUID)** y estado **pendiente → sincronizando → confirmado / error**. «Sincronizar ahora» y «Reintentar». **Solo se retiran los registros confirmados; nunca se sobrescribe con datos antiguos.**
- Botones del estudio «Simular error de sincronización» (la siguiente sync falla y se puede reintentar) y «Simular servidor lento».
- Si se cierra sesión con pendientes, avisa antes y guarda el cierre remoto para cuando vuelva la red.



---

## Prompt 09 · Configuración, accesibilidad y cuenta (41–51)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 01–08 |
| **Objetivo** | Preferencias reales que persisten y pantallas informativas. |

---

## Prompt (copiar y pegar tal cual)


Diseña **08 · Configuración y accesibilidad** (pantallas 41 a 51). Las preferencias **sí se guardan** en localStorage con la clave `orbita-kids-prefs-v2` y se aplican al instante en toda la app (envuelve lecturas/escrituras en try/catch).

Valores por defecto: `{ theme:'auto', tz:1, hc:false, rm:false, audio:false, sounds:true, vol:70, lang:'es-MX', cb:false, onboarded:false, notif:{act,res,sync,rest,grp: true} }`.

- **41 Configuración:** índice de todo.
- **42 Accesibilidad:** vista previa en vivo, **tamaño de texto** (deslizador en %), **alto contraste**, **reducir movimiento**, **audio / lectura de instrucciones** con botón «Probar lectura» (speechSynthesis es-MX), sonidos y volumen, **refuerzo con símbolos** (para daltonismo), tema y «Restaurar».
- **43 Apariencia:** claro, oscuro o automático.
- **44 Editar perfil:** solo los datos editables.
- **45 Privacidad:** qué datos se guardan, quién los ve (docente del grupo, escuela), que no hay publicidad ni compras.
- **46 Seguridad y sesiones:** método de acceso, sesiones y dispositivos, cerrar otras sesiones.
- **47 Ayuda y soporte**, **48 Términos y condiciones**, **49 Cerrar sesión** (clara, segura, avisa si hay datos sin sincronizar).
- **50 Acerca de Órbita Kids:** qué es y cómo se aprende (niveles, modalidades, reglas R1-R3).
- **51 Órbita Kids Studios:** la empresa y el equipo, con el logotipo oficial.



---

## Prompt 10 · Planes institucionales y Nuevas Galaxias (52–53)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 07 y 09 |
| **Objetivo** | Mostrar el modelo freemium y la expansión futura sin venderla como terminada. |

---

## Prompt (copiar y pegar tal cual)


Diseña **09 · Planes y expansión**:

**52 · Planes institucionales** (desde el perfil docente; informativo, **sin checkout ni cobros en la app**). Selector Mensual / Anual («~15 % de ahorro»):
- **Gratuito** · para conocer la plataforma · funciones básicas permanentes · misiones de sumas, Pausa Estelar, seguimiento básico.
- **Aula** · $799 MXN/mes · $8,150/año · hasta 50 estudiantes y 5 docentes · actividades ampliadas, seguimiento del grupo, reportes básicos.
- **Escuela** (destacado) · $1,799/mes · $18,350/año · hasta 150 estudiantes · todo lo de Aula + reportes ampliados.
- **Licencia institucional** · $4,999/mes · $50,990/año · hasta 500 estudiantes · administración y gestión institucional.
- Nota en amarillo: «Propuesta académica sujeta a validación de costos, disposición de pago, impuestos y condiciones comerciales.»
- Bloques «Administración de códigos» (la escuela contrata, genera códigos, el docente los comparte, el backend valida vigencia y lugares) y «Escuela / institución (actor externo)» (la adopción es una posibilidad, no una venta confirmada).

**53 · Nuevas Galaxias** (próximamente; las sumas siguen siendo la única experiencia disponible): Ciencias · Lectura y comprensión · Matemáticas avanzadas · Pensamiento lógico · Medio ambiente · Arte y creatividad, cada una con planeta de color, descripción y temas.



---

## Prompt 11 · Dirección de arte v3–v4: Orbi y astronautas con volumen

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 03–06 |
| **Objetivo** | Subir la calidad de las ilustraciones SVG. |

---

## Prompt (copiar y pegar tal cual)


Las ilustraciones se ven planas. Haz una **dirección de arte nueva (v3)** y luego **v4**, todo en SVG generado por código:

1. **Planetas con volumen:** iluminación, sombra, superficie según tipo (terra, lava, ocean, crystal, ice, gas, crater) y anillos.
2. **Niño o niña astronauta** con volumen: casco, traje, mochila; **poses** (saludar, saltar, estirar, caminar, equilibrio, explorar, despegar, descansar, brazos, mirar) y **expresiones** (Sonrisa, Alegría, Sorpresa, Pensando). Debe servir para el avatar personalizable (cascos, trajes, accesorios, peinados) y para los pictogramas de Pausa Estelar.
3. **Mascota «Orbi»: un perrito astronauta** en cuatro patas / sentado de frente, con casco que tiene una antena para hablar con la base. Poses: saludar, aprender, explorar, festejar, ejercicio, pensar, señalar.
4. **Escenarios** (espacio, luna morada) e **ilustraciones de estados** (vacío, error, sin conexión, éxito) que reemplacen los íconos genéricos.
5. Un despachador común para no romper el código existente (`mascot()`, `astro()`, `orbi()`).

Orbi aparece en el onboarding, en las pistas, en resultados y en Pausa Estelar. Mantén la paleta del sistema visual.



---

## Prompt 12 · v5: modo explorar sin cuenta y carga esqueleto (54–58)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 04–10 |
| **Objetivo** | Permitir probar la app sin cuenta y simular servidor lento. |

---

## Prompt (copiar y pegar tal cual)


Versión 5. Agrega:

- **54 · Entrar sin cuenta** desde el login («Explorar sin cuenta»): explica qué se puede y qué no.
- **55 · Inicio en modo explorar:** versión limitada del home; se pueden jugar el mapa, misiones de muestra, resultados, Pausa Estelar, avatar, accesibilidad, tema, privacidad, ayuda, términos y acerca de.
- **56 · Más (modo explorar).**
- **57 · Disponible con cuenta:** pantalla amable cuando se toca algo bloqueado (progreso, actividades de la maestra, sincronización…), con botón para iniciar sesión. Nada se guarda en el modo explorar.
- **58 · Carga esqueleto:** cuando «Simular servidor lento» está activo, las pantallas de datos (home, mapa, progreso, actividades, pausa, perfil, avisos, home docente, grupos…) muestran primero un **skeleton** con la forma real del contenido.
- **Compañeros:** en el home y el mapa, mostrar de forma no competitiva que otros del grupo también avanzan (sin rankings).



---

## Prompt 13 · v6: splash más grande y animado, «Conoce a Orbi»

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Logos ya adjuntos |
| **Depende de** | Prompt 11 |
| **Objetivo** | Pulir la primera impresión y presentar a la mascota. |

---

## Prompt (copiar y pegar tal cual)


Versión 6:

1. Haz el **splash 01 más grande y animado**: el logo oficial más protagonista, el niño astronauta **y Orbi saludando desde la luna**, cohete en órbita, estrellas con parpadeo. Respeta «Reducir movimiento».
2. El **onboarding** pasa a 5 pasos: en el primero **Orbi se presenta**, con la pose distinta en cada paso (saludar, aprender, explorar, festejar, ejercicio).
3. Nueva pantalla **59 · Conoce a Orbi** (Bienvenida, público): ficha (Nombre: Orbi · Es: un perrito astronauta · Su trabajo: copiloto de tu nave · Le encanta: contar estrellas y explorar planetas · Su casco: tiene una antena para hablar con la base), **cómo te ayuda** (te da pistas, festeja contigo aunque te equivoques, te recuerda moverte, te muestra el camino en el mapa, te lee en voz alta) y **lo que nunca hace**: te regaña, te apura, te pide comprar algo, te compara con otros niños.
4. Los sketches y wireframes se tienen que **generar desde la app** (siguiente prompt), no dibujarse a mano.



---

## Prompt 14 · Vista Sketches de baja fidelidad

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 01–13 |
| **Objetivo** | Generar los sketches automáticamente desde el DOM del prototipo. |

---

## Prompt (copiar y pegar tal cual)


Construye la vista **Sketches**:

- Usa **rough.js 4.6.6** (`https://cdn.jsdelivr.net/npm/roughjs@4.6.6/bundled/rough.js`) y la letra **Caveat** sobre papel #F7F6F1 con lápiz #3A3A3A.
- **Un sketch por pantalla y por cada estado que provoca una acción** (por ejemplo, error 1 y error 2 de la suma, hoja de confirmación, código inválido).
- Se generan **midiendo el prototipo real**: renderiza cada estado fuera de pantalla, recorre el DOM con `getBoundingClientRect` y guarda cajas, textos (tamaño y peso de letra), imágenes y botones en un arreglo `LAYOUTS`. Así cada caja tiene la misma posición y tamaño que en el prototipo y el wireframe.
- **Círculos rojos numerados** marcan las acciones de la pantalla; al abrir la tarjeta se ve la **ficha** completa: objetivo, qué hace, elementos, acciones numeradas con a dónde llevan, pantallas relacionadas, reglas de navegación y requisito que cubre.
- Encabezado con totales («N sketches · N pantallas · N acciones»), filtro por sección y botón «Abrir todas las fichas».
- Dibuja de forma diferida (solo lo visible) para que no se trabe.



---

## Prompt 15 · Vista Wireframes con medidas Flutter

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompt 14 |
| **Objetivo** | Wireframes medidos en dp listos para pasar a Flutter. |

---

## Prompt (copiar y pegar tal cual)


Construye la vista **Wireframes** con los **mismos estados** que los sketches, medidos sobre la app real en **dp (píxeles lógicos de Flutter)**:

- Bloque «Sistema de medidas en Flutter»: 1 px del prototipo = 1 dp (Flutter multiplica por `devicePixelRatio`); **lienzo de referencia 390 × 844 dp**; área segura superior 47 dp + aire; padding de pantalla como `EdgeInsets.fromLTRB(...)` calculado de las medidas más frecuentes; **rejilla de 4 columnas, margen 20, medianil 16, columna = (ancho − 40 − 48) ÷ 4**.
- Tabla de **medidas fijas medidas en la app**: alto de botón, barra de navegación, encabezado, radios, tamaños de texto más usados.
- Cada wireframe muestra la rejilla en rosa, tamaño de los bloques, espacios entre ellos, márgenes, las **acciones numeradas** y su **equivalencia en widgets** (Scaffold, AppBar, ElevatedButton, ListTile, GridView, BottomNavigationBar…) con medidas relativas.
- Enlaces cruzados: desde la ficha del prototipo «Wireframe con medidas →» salta al wireframe de esa pantalla.



---

## Prompt 16 · Diagramas de secuencia UML interactivos

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 04, 05, 07 y 08 |
| **Objetivo** | Documentar la interacción entre actores y sistemas. |

---

## Prompt (copiar y pegar tal cual)


Construye la vista **Diagrama de secuencia**: diagramas **UML** dibujados en SVG por código, **interactivos**.

**Participantes:** Estudiante (actor) · Docente (actor) · App Flutter (móvil, ambos roles) · Almacenamiento local (SQLite + Keystore) · Keycloak (OIDC · PKCE) · API REST (FastAPI) · Base de datos (MySQL). Incluye solo los que participan en cada diagrama.

**Notación:** mensajes síncronos (flecha llena), respuestas (punteada), asíncronos (flecha abierta), fragmentos **alt, opt, loop, break**, notas, **ref** a otros diagramas y separadores de fase.

**Diagramas:**
- **SD-00 Diagrama general:** inicio de sesión → el docente publica una actividad → el estudiante la resuelve sin Internet → la app sincroniza → el docente revisa el progreso → cierre de sesión. Cada fase con «ref» a su detalle. Precondición: app instalada y licencia vigente. Postcondición: intentos sincronizados, reporte disponible, sesión cerrada.
- **SD-01** Arranque y restauración de sesión · **SD-02** Inicio de sesión federado con Keycloak (Authorization Code + PKCE en el navegador del sistema, `kc_idp_hint`, nunca WebView) · **SD-03** Registro de estudiante con código de grupo · **SD-04** Resolver una misión (offline first, R1/R2/R3) · **SD-05** Sincronización al reconectar (UUID, idempotencia) · **SD-06** Docente publica una actividad y revisa el progreso · **SD-07** Cerrar sesión de forma segura.

**Interactividad:** filtro por diagrama, reproducir paso a paso (▶ con temporizador, ‹ ›), resaltar el mensaje actual con tooltip (quién → quién, tipo, detalle y pantalla del prototipo relacionada), tema oscuro/claro para imprimir, y debajo de cada diagrama una **tabla de mensajes** numerada. Cada mensaje enlaza a la pantalla del prototipo correspondiente.



---

## Prompt 17 · Recorrido «Ver en acción» y simulación de condiciones

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 01–16 |
| **Objetivo** | Que el prototipo se pueda presentar solo en la exposición. |

---

## Prompt (copiar y pegar tal cual)


Agrega al panel del estudio:

**«Ver en acción»**: un recorrido automático, completo y conectado, que **toca los botones solo** (con un indicador de toque visible) y avanza con tiempos por paso. Controles ▶ / ‹ › / ■ y el título y descripción del paso actual. Secuencia:
Splash Órbita Kids (logo, niño y Orbi saludan) → Splash Studios → Onboarding con Orbi (5 pasos) → Conoce a Orbi → ¡Comenzar! → Iniciar sesión con Google (Keycloak abre el navegador seguro) → un adulto elige la cuenta de Luna → loading con los pasos del flujo → home estudiante → mapa → misión → suma con apoyo visual (un error y la ayuda) → selección de respuestas → resultados → Pausa Estelar → ir sin conexión y ver la cola → reconectar y sincronizar → entrar como docente → grupo 2° A → Diego L. → crear actividad → reportes.

**«Simular condiciones»**: Conexión En línea / Sin conexión, Simular error de sincronización, Simular servidor lento (activa el esqueleto), Reducir movimiento y «Restablecer prototipo (incluye onboarding)».

**«Cómo probar»**: las credenciales y códigos de demostración y la aclaración: «Esto es un prototipo: no hay conexión real con Keycloak, Google, Facebook ni el backend. Los datos son demostrativos y se reinician al reabrir la app; solo tus preferencias se guardan en este navegador.»

**Modo revisión:** al saltar a una pantalla desde el índice, inicia una sesión de demostración con el rol que corresponde (Luna o Ana) y arma el historial para que «Atrás» funcione.



---

## Prompt 18 · Correcciones finales y entrega

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_Prototipo.html (idéntico a Órbita_Kids_Prototipo_1.html)` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Todos los anteriores |
| **Objetivo** | Revisión de calidad antes de entregar. |

---

## Prompt (copiar y pegar tal cual)


Revisión final antes de entregar. Corrige y verifica:

1. **El encabezado fijo se pierde al desplazar más de una pantalla** dentro del teléfono: arréglalo (sticky dentro del contenedor con scroll y safe area).
2. Que todas las pantallas del índice abran sin errores en consola y que «Atrás» siempre regrese a algo lógico.
3. Que los sketches, wireframes y diagramas cuadren con la versión final del prototipo (mismos estados y conteo de acciones).
4. Contraste AA en tema claro y oscuro, foco visible y textos alternativos en todas las imágenes.
5. En pantallas angostas (≤ 760 px) el índice es un desplegable y el teléfono ocupa el ancho.
6. Que la vista previa en iframe no truene al cambiar la URL (envuelve `history.replaceState` en try/catch).
7. Título de la página: «Órbita Kids Prototipo».

Publica la versión final como artifact y dame el enlace.



---

# PWA · Órbita_Kids_PWA_v3.html



---

## Prompt 00 · Prompt maestro (todo en uno)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Los mismos logos oficiales (símbolo, logo de la app, logotipo Órbita Kids Studios) |
| **Depende de** | Conviene tener a la mano el prototipo móvil (misma marca y datos) |
| **Objetivo** | Generar en una sola conversación la PWA de escritorio para docentes e instituciones, con sitio web, prototipo, sketches, wireframes y diagramas de secuencia. |

---

## Prompt (copiar y pegar tal cual)


Actúa como diseñador UX/UI senior y desarrollador front-end. Ya tenemos el prototipo móvil de **Órbita Kids** (te adjunto los logos). Ahora necesito el **prototipo de la PWA de escritorio** para **docentes e instituciones**, en **un solo archivo HTML autocontenido** (CSS y JS inline, imágenes como data URI, sin frameworks; solo Google Fonts). Español de México. Título: «Órbita Kids PWA · Prototipo y diagramas».

### 1. Contexto
- Los **estudiantes usan la app móvil Flutter**; la **PWA es para docentes y direcciones** (rol Institución). Si un estudiante intenta entrar, se le explica amablemente que su app es la móvil.
- Mismo backend que el móvil: **Keycloak** (OIDC con PKCE) federado con **Google y Microsoft** e IdP institucional; **API Órbita** compartida; en el navegador **IndexedDB** (datos y cola local) y **service worker con Workbox**.
- Es un prototipo: no hay conexión real; instalación, service worker y modo sin conexión se **simulan**.
- Misma marca y datos que el móvil (grupos, estudiantes, actividades y errores frecuentes).

### 2. Estudio
El mismo «estudio nocturno» del móvil, adaptado a escritorio: barra superior con pestañas **Prototipo · Sketches · Wireframes · Diagramas de secuencia**. En Prototipo, la app vive dentro de una **ventana de escritorio** a lo ancho, con controles arriba: **Ventana** (Navegador / App instalada), **Ancho** (1280 / 1024 / 820), **Conexión** (En línea / Sin conexión), **Tema** (Claro / Oscuro), «← Atrás» y «↻ Empezar de nuevo». Índice de pantallas a la izquierda y ficha debajo (con requisito RF/RNF que cubre). Panel **Recorridos** con «▶ Ver en acción» y panel **Cómo probar**: Docente `ana.rios · orbita123`; Institución (también docente) `laura.mendez · orbita123 · código 482915`; Estudiante (no tiene acceso) `luna.astro · orbita123`.

### 3. Pantallas (35)
01 Sitio web · 02 Planes institucionales · 03 Solicitar información · 35 Explorar sin cuenta · 04 Iniciar sesión · 05 Proveedor de identidad (simulado) · 06 Acceso institucional · 07 Estados de acceso · 08 Verificación en dos pasos · 09 Elegir espacio · 10 Aceptar invitación · 11 Instalar la app · 12 Primer arranque instalada · 13 Instalar en otros navegadores · 14 Nueva versión disponible · 15 Inicio docente · 16 Mis grupos · 17 Detalle del grupo · 18 Detalle del estudiante · 19 Crear actividad · 20 Actividades · 21 Resultados y reportes · 22 Avisos · 23 Inicio institución · 24 Docentes · 25 Grupos y códigos · 26 Licencia y plan · 27 Reportes institucionales · 28 Configuración institucional · 29 Sin conexión · 30 Sincronización · 31 Perfil y configuración · 32 Seguridad y sesiones · 33 Ayuda y soporte · 34 Cerrar sesión.
(El detalle de cada bloque está en los prompts 02 a 08; inclúyelos todos.)

### 4. Visual
Paleta idéntica al móvil (#0D102B, #191B58, #746BE8, #9186F5, #C9C3FF, #FFD166, #69D6DE, #82D9B4) pero con tipografía **Red Hat Display / Red Hat Text / Red Hat Mono** (Caveat para sketches). El sitio público usa la dirección de arte **«Observatorio»** (ver prompt 12). La app tiene tema claro y oscuro con tokens semánticos.

### 5. Documentación
Sketches y wireframes **dibujados desde la geometría real de la ventana** (1280 de ancho), con acciones numeradas, y **4 diagramas de secuencia** interactivos: Explorar sin cuenta e iniciar sesión con Google · Instalar la app de escritorio · Asignar apoyo sin conexión y sincronizar · Dirección entra con verificación en dos pasos.

Publícalo como artifact.



---

## Prompt 01 · Contexto y estudio adaptado a escritorio

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Los mismos logos oficiales (símbolo, logo de la app, logotipo Órbita Kids Studios) |
| **Depende de** | Prototipo móvil terminado |
| **Objetivo** | Arrancar la PWA reutilizando el estudio del móvil. |

---

## Prompt (copiar y pegar tal cual)


Ya terminamos el prototipo móvil de Órbita Kids. Ahora vamos con la **segunda parte del proyecto: la PWA de escritorio para docentes e instituciones**. Te vuelvo a adjuntar los logos.

**Por qué una PWA:** los docentes y la dirección trabajan en computadora; con una PWA no hay que publicar en tiendas, se instala desde el navegador, funciona sin conexión y comparte backend con la app móvil. Los **estudiantes no usan la PWA** (su experiencia es la app móvil Flutter).

Arquitectura para la documentación: **Keycloak** (OIDC + PKCE) con Google, Microsoft e IdP de la escuela; **API Órbita** (el mismo backend del móvil); **IndexedDB** para datos y cola local; **service worker con Workbox** para caché, instalación y actualizaciones.

Haz un **solo archivo HTML** con el mismo «estudio nocturno» del móvil, adaptado a escritorio:
- Barra superior: marca y pestañas **Prototipo · Sketches · Wireframes · Diagramas de secuencia**.
- **Prototipo:** la app se muestra dentro de una **ventana de escritorio** a lo ancho. Arriba de la ventana, controles para simular: **Ventana** Navegador (con barra de dirección `orbitakids.example` e ícono de instalar) / App instalada (ventana propia sin barra), **Ancho** 1280 / 1024 / 820, **Conexión** En línea / Sin conexión, **Tema** Claro / Oscuro, «← Atrás», «↻ Empezar de nuevo».
- Índice de pantallas a la izquierda (agrupado: 01 Sitio web, 02 Acceso, 03 App de escritorio, 04 Docente, 05 Institución, 06 Sin conexión, 07 Cuenta) y **ficha debajo de la ventana** con: objetivo, qué hace, elementos, acciones, relacionadas, navegación/reglas y **requisito (RF/RNF)**.
- Panel «Cómo probar» con las cuentas demo: Docente `ana.rios / orbita123`; Institución que también es docente `laura.mendez / orbita123` con código de verificación `482915`; Estudiante `luna.astro / orbita123` (sin acceso a la PWA).
- Aviso: «Es un prototipo: no hay conexión real con Keycloak, Google, Microsoft ni el backend. La instalación, el service worker y el modo sin conexión se simulan. Los datos son de demostración.»

Tipografía Red Hat Display / Text / Mono; misma paleta que el móvil.



---

## Prompt 02 · Sitio web público, planes, contacto y explorar sin cuenta (01–03, 35)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompt 01 |
| **Objetivo** | Puerta de entrada pública para docentes y direcciones. |

---

## Prompt (copiar y pegar tal cual)


Diseña el **sitio web público** en `orbitakids.example` (pantallas 01, 02, 03 y 35):

- **Navegación:** logo · Inicio · Explorar · Planes · Contacto · Instalar · botón «Iniciar sesión». Pie: logotipo Órbita Kids Studios, «Proyecto académico, 2026», Privacidad, Términos, Ayuda.
- **01 Sitio web:** explica qué hace la app móvil para los niños y qué hace la PWA para docentes e instituciones. La portada muestra **la órbita de un grupo de demostración (2.º A)** en SVG animado: al centro el grupo, anillo interior «Al día» (5 estudiantes), anillo medio «Sin actividad en 3 días» (4) y anillo exterior **«Necesita apoyo»** en ámbar con nombre y porcentaje: Leonardo F. 58 %, Diego L. 61 %, Valeria P. 65 %. Luego: tres maneras de entrar (explorar, docente, institución), cuatro pasos para empezar, preguntas frecuentes y acceso a planes.
- **02 Planes institucionales:** selector Mensual/Anual y las 4 tarjetas (Gratuito, Aula $799, Escuela $1,799 destacado, Licencia institucional $4,999), límites, beneficios y la nota «Propuesta académica sujeta a validación…». **Sin checkout:** cada plan lleva a Solicitar información.
- **03 Solicitar información:** formulario corto (institución, responsable, correo, número de estudiantes, plan de interés, mensaje), validación en línea, aviso de privacidad y confirmación. Sin conexión, el formulario se guarda y se envía al reconectar.
- **35 Explorar sin cuenta:** recorrido con datos de demostración dentro de una ventana de la app, con selector **Docente / Dirección**, interruptor «Simular sin conexión», tres sugerencias de qué probar (asigna apoyo a un estudiante / resuelve un pendiente de la escuela…), indicador orbital de sincronización, cifras, «Necesitan apoyo», «Esta semana», grupos con tendencia y cierre con «Iniciar sesión». **Nada se guarda ni se llama a la API.**



---

## Prompt 03 · Acceso, verificación en dos pasos, espacios e invitaciones (04–10)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompt 02 |
| **Objetivo** | Autenticación federada para docentes y direcciones. |

---

## Prompt (copiar y pegar tal cual)


Diseña el bloque **02 · Acceso** (pantallas 04 a 10):

- **04 Iniciar sesión:** Continuar con Google, Continuar con Microsoft, Acceso institucional y cuenta Órbita Kids. 3 intentos fallidos bloquean 15 min.
- **05 Proveedor de identidad (simulado):** ventana tipo navegador con selector de cuentas de Google o Microsoft (`kc_idp_hint`).
- **06 Acceso institucional:** buscar la escuela (Escuela Primaria Demo Órbita con Google Workspace for Education, otra con Microsoft Entra ID / SAML, y una caída).
- **07 Estados de acceso:** pantallas amables para: es estudiante («Esta app es para docentes e instituciones; los estudiantes juegan en la app móvil»), sin rol («Pide a tu dirección que te invite»), solicitud en revisión, identidad sin cuenta, cancelado («No se compartió ningún dato»), sesión vencida (**8 h sin actividad**, los borradores siguen guardados), sin Internet (el primer inicio requiere conexión), bloqueada 15 min, proveedor de la institución no responde, invitación aceptada.
- **08 Verificación en dos pasos:** 6 casillas con avance automático y pegado, temporizador de reenvío, «Recordar este equipo 30 días». **Obligatoria para el rol Institución**, opcional para docentes. Código demo `482915`.
- **09 Elegir espacio:** solo si la cuenta es Docente e Institución a la vez (Laura Méndez); dos tarjetas y «Recordar mi elección»; se cambia después desde el menú de la cuenta. **El backend decide los roles; la PWA solo muestra los que existen.**
- **10 Aceptar invitación:** llega del correo; muestra institución y grupos asignados y deja elegir método (Google, Microsoft, crear cuenta Órbita Kids) o rechazar. Vence en 7 días y solo funciona con el correo invitado.



---

## Prompt 04 · App de escritorio: instalar, primer arranque, otros navegadores, actualización (11–14)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompt 01 |
| **Objetivo** | Simular el ciclo de vida de una PWA. |

---

## Prompt (copiar y pegar tal cual)


Diseña **03 · App de escritorio** (pantallas 11 a 14) y haz que el control «Ventana: Navegador / App instalada» del estudio cambie de verdad la apariencia:

- **11 Instalar la app:** qué cambia al instalar (ventana propia, ícono en el escritorio, abre sin Internet), vista previa de la ventana y botón **Instalar** que abre el **diálogo del navegador simulado** (`beforeinstallprompt`). Banner de instalación discreto dentro de la app. Solo se ofrece si cumple los criterios y no está instalada.
- **12 Primer arranque instalada:** confirma la instalación, explica dónde encontrar la app (menú inicio / Dock / escritorio) y cambia la ventana a modo app.
- **13 Instalar en otros navegadores:** pasos claros para Chrome, Edge y Safari (Archivo › Agregar al Dock) cuando no hay botón automático.
- **14 Nueva versión disponible:** el service worker descargó una versión nueva; aviso superior con novedades, «Actualizar ahora» o «Más tarde». **Guarda los borradores antes de recargar y nunca recarga sola con un formulario abierto.**



---

## Prompt 05 · Espacio docente en escritorio (15–22)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 01–04 |
| **Objetivo** | Llevar el seguimiento docente a pantalla grande. |

---

## Prompt (copiar y pegar tal cual)


Diseña **04 · Docente** (15 a 22) con la **Mtra. Ana Ríos** y **los mismos datos del prototipo móvil** (grupos 2° A, 2° B, 3° A; Luna M., Diego L., etc.; actividades; errores frecuentes). Layout de escritorio: barra lateral con Inicio · Mis grupos · Actividades · Resultados · Avisos (con contador de no leídos), encabezado con buscador, indicador de sincronización y menú de cuenta; contenido en rejilla de 12 columnas que se adapta a 1280 / 1024 / 820.

- **15 Inicio docente:** cifras de la semana, quién necesita apoyo, actividades activas, avisos.
- **16 Mis grupos** · **17 Detalle del grupo** (estudiantes con estado, actividades, resultados) · **18 Detalle del estudiante** (aciertos, tendencia, errores frecuentes, **asignar apoyo**; datos de menores protegidos).
- **19 Crear actividad:** mismo formulario del móvil en dos columnas con vista previa; **sin conexión guarda borrador y se publica al volver Internet**.
- **20 Actividades** (Activa, Programada, Cerrada, Borrador) · **21 Resultados y reportes** (aquí sí caben tablas y gráficos más amplios).
- **22 Avisos** sin urgencia artificial: «Diego L. necesita apoyo en sumas que pasan de 10» (2° A · hoy 8:15), «Se sincronizaron 6 intentos de 2° B» (ayer 18:40), «La dirección aprobó tu grupo 3° A para el ciclo 2026-27» (27 oct).



---

## Prompt 06 · Espacio institución / dirección (23–28)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 03 y 05 |
| **Objetivo** | Panel de administración de la escuela. |

---

## Prompt (copiar y pegar tal cual)


Diseña **05 · Institución** (23 a 28) para la **Lic. Laura Méndez** (administra y también es docente de 3° B). Barra lateral: Inicio · Docentes · Grupos y códigos · Licencia y plan · Reportes · Avisos · Configuración.

**Datos:** Escuela Primaria Demo Órbita · plan **Escuela anual** del 1 ago 2026 al 31 jul 2027 · **150 lugares** · dominio `escuela.example` · Google Workspace for Education (OIDC).
- Docentes: Ana Ríos (2° A, 2° B, 3° A · 33 estudiantes) · Laura Méndez (3° B · 14 · admin) · Jorge Salas (1° A, 1° B · 29) · Patricia Núñez (1° C · 15) · Iván Ortega (2° C, 3° C · 27).
- Grupos con código, cupo, vigencia y estado: 1° A ORB-1A5D 15/20 · **1° B ORB-1B4T vence 4 nov 2026 («Vence pronto»)** · 1° C ORB-1C8W · 2° A ORB-2A7K 12/15 · 2° B ORB-2B3M · 2° C ORB-2C6H · 3° A ORB-3A9Q · 3° B ORB-3B2R · **3° C ORB-3C7N 14/15 («Sin lugares»)**.
- Pendientes: «Sofía Cárdenas pidió acceso» (Aprobar) · «El código ORB-1B4T vence el 4 de noviembre» (Renovar) · «La licencia llegó al 79 % de lugares usados».

**Pantallas:** 23 Inicio institución (uso de licencia, docentes, grupos, estudiantes, avance por grado, pendientes, actividad reciente) · 24 Docentes (invitar, aprobar, desactivar) · 25 Grupos y códigos (crear grupos y repartir lugares; al archivar un grupo los lugares vuelven a la licencia) · 26 Licencia y plan (vigencia, uso, comparativa; **cambiar de plan se solicita, no hay pago en línea**; avisa al 80 % y 30 días antes de vencer) · 27 Reportes institucionales (por grado y grupo, sin exponer datos individuales innecesarios) · 28 Configuración institucional (datos, proveedor de inicio de sesión con «Probar conexión», dominios permitidos, aprobación de docentes, verificación en dos pasos, ciclo escolar, retención de datos; cambiar el proveedor pide confirmación).

Sin conexión se puede consultar; invitar, aprobar o generar códigos espera a que vuelva Internet.



---

## Prompt 07 · Sin conexión y sincronización (29–30)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 05–06 |
| **Objetivo** | Comportamiento offline de la PWA. |

---

## Prompt (copiar y pegar tal cual)


Diseña **06 · Sin conexión** y haz que el control «Conexión» del estudio afecte a toda la app:

- Banner superior en cada pantalla cuando no hay Internet, con mensaje específico («Puedes guardar el borrador; se publica cuando vuelva Internet»).
- **29 Sin conexión:** qué funciona (consultar grupos, estudiantes y reportes en caché, crear borradores, asignar apoyo) y qué espera a la red (publicar, invitar, aprobar, generar códigos). Opción «Borrar los datos sin conexión» con confirmación.
- **30 Sincronización:** cola de cambios guardados en **IndexedDB** con estado (En cola, Enviando, Confirmado, Error), botón Sincronizar y Reintentar. Al volver la red, el service worker los envía en lote y el backend los aplica **una sola vez** (idempotencia).
- Acciones que requieren red muestran un toast «Sin conexión: … espera a que vuelva Internet».
- Al cerrar sesión con cambios pendientes, avisar antes.



---

## Prompt 08 · Cuenta: perfil, seguridad, ayuda y cierre de sesión (31–34)

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompt 03 |
| **Objetivo** | Completar el bloque de cuenta. |

---

## Prompt (copiar y pegar tal cual)


Diseña **07 · Cuenta** (31 a 34):
- **31 Perfil y configuración:** datos de la cuenta, preferencias (tema, tamaño de texto, reducir movimiento, notificaciones, idioma es-MX) y espacio actual con opción de cambiarlo si tiene dos roles.
- **32 Seguridad y sesiones:** método de acceso, verificación en dos pasos, equipos recordados, sesiones activas y cerrar las demás.
- **33 Ayuda y soporte:** preguntas frecuentes, guía de instalación, contacto.
- **34 Cerrar sesión:** confirmación clara; si hay cambios sin sincronizar, ofrece sincronizar primero; borra tokens y datos sensibles del equipo.

En las fichas asocia cada pantalla a un requisito. Usa esta lista:
RF-01 Sitio público y demostración · RF-02 Presentar la app móvil y la PWA · RF-03 Planes y solicitud de información · RF-04 Inicio de sesión federado · RF-05 Estados de acceso · RF-06 Verificación en dos pasos · RF-07 Elegir espacio por rol · RF-08 Aceptar invitación · RF-09 Instalación como app · RF-10 Inicio docente · RF-11 Grupos · RF-12 Seguimiento del estudiante · RF-13 Crear actividad · RF-14 Gestionar actividades · RF-15 Reportes del grupo · RF-16 Avisos · RF-17 Inicio institución · RF-18 Docentes · RF-19 Grupos y códigos · RF-20 Licencia · RF-21 Altas por invitación · RF-22 Reportes institucionales · RF-23 Configuración institucional · RF-24 Sin conexión y sincronización · RF-25 Perfil · RF-26 Ayuda.
RNF-01 Carga rápida e instalable · RNF-02 Funciona sin conexión · RNF-03 Actualizaciones sin pérdida de trabajo · RNF-04 Seguridad de acceso y sesiones · RNF-05 Privacidad de datos de menores · RNF-06 Integridad de la sincronización · RNF-07 Tolerancia a fallos de red en formularios · RNF-08 Compatibilidad con Chrome, Edge y Safari · RNF-09 Accesibilidad y preferencias.



---

## Prompt 09 · Sketches y wireframes desde la geometría real de la ventana

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 01–08 |
| **Objetivo** | Documentación de baja fidelidad y medidas para escritorio. |

---

## Prompt (copiar y pegar tal cual)


Construye las vistas **Sketches** y **Wireframes** igual que en el móvil, pero para escritorio:

- **Estados capturados:** cada pantalla y cada estado que provoca una acción (diálogo de instalar, banner de nueva versión, código de verificación incorrecto, sin conexión…).
- Se dibujan **desde la geometría real de la ventana** a 1280 px de ancho: renderiza cada estado, mide el DOM y guarda cajas, textos, imágenes y botones en `LAYOUTS`.
- **Sketches:** trazo a mano en SVG con papel #F5F1E6, lápiz #2B2B2B y Caveat; círculos rojos (#C0392B) numeran las acciones; ficha completa al abrir.
- **Wireframes:** rejilla de 12 columnas, márgenes, medianiles, tamaños, espacios, acciones numeradas y comportamiento responsivo (qué cambia en 1024 y 820).
- Filtro por sección y conteo de pantallas y acciones en el encabezado.



---

## Prompt 10 · Diagramas de secuencia de la PWA

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 02–07 |
| **Objetivo** | Documentar los 4 flujos clave de la PWA. |

---

## Prompt (copiar y pegar tal cual)


Construye la vista **Diagramas de secuencia** (UML, SVG, interactivos con reproducción paso a paso y captura de la pantalla relacionada en cada mensaje).

**Participantes:** Docente (actor) · Dirección (actor) · PWA Órbita Kids (navegador o ventana) · Navegador (Chrome, Edge o Safari) · Service worker (Workbox) · IndexedDB (datos y cola local) · Keycloak (OIDC con PKCE) · Google o Microsoft (proveedor de identidad) · API Órbita (backend compartido) · App móvil (estudiante).

**Flujos:**
1. **Explorar sin cuenta e iniciar sesión con Google** — el docente abre orbitakids.example y elige «Explorar sin cuenta»; la PWA carga datos de demostración sin llamar a la API; luego «Iniciar sesión» → «Continuar con Google»; la PWA genera `code_verifier` y `code_challenge`, redirige a `/auth` con `kc_idp_hint=google`, Google autentica, Keycloak devuelve el código, la PWA lo canjea con el verifier y **el rol lo decide el backend**.
2. **Instalar la app de escritorio** — el service worker precarga la app; el navegador dispara `beforeinstallprompt`; el docente confirma; la ventana propia abre desde la caché.
3. **Asignar apoyo sin conexión y sincronizar** — el cambio se guarda en IndexedDB y entra a la cola; al volver la red el service worker envía en lote; el backend aplica cada cambio **una sola vez** y la app móvil del estudiante recibe la actividad.
4. **Dirección entra con verificación en dos pasos** — inicio de sesión, segundo factor obligatorio para Institución, y como Laura también es docente, **elige espacio**.

Cada diagrama con secciones de color, mensajes numerados, autollamadas, tabla de mensajes y botón para abrir la pantalla en el prototipo.



---

## Prompt 11 · Recorridos «Ver en acción»

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Prompts 01–10 |
| **Objetivo** | Que la PWA se presente sola en la exposición. |

---

## Prompt (copiar y pegar tal cual)


Agrega el panel **Recorridos** con «▶ Ver en acción», ‹ › y una lista de pasos agrupados que también se pueden tocar:

1. **Del sitio a la app de escritorio:** Sitio web → Explorar sin cuenta → Explorar (asignar apoyo) → Iniciar sesión → Proveedor de identidad → Inicio docente → Instalar la app (diálogo) → Primer arranque instalada → Inicio docente en ventana propia.
2. **Un día de la docente:** Inicio docente → Detalle del grupo → Detalle del estudiante → Crear actividad → Crear actividad (vista previa) → Actividades → Resultados y reportes.
3. **La dirección administra:** Verificación en dos pasos → Elegir espacio → Inicio institución → Docentes (aprobar solicitud) → Grupos y códigos (renovar código) → Licencia y plan → Reportes institucionales.
4. **Sin Internet:** Sin conexión → Sincronización → Cerrar sesión.

Cada paso usa los estados capturados para que coincida con sketches y wireframes.



---

## Prompt 12 · Rediseño v3 «Observatorio» y pulido final

| Campo | Valor |
|---|---|
| **Modelo de IA** | Claude Opus 5.5 (Anthropic) |
| **Plataforma** | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| **Archivo resultado** | `Órbita_Kids_PWA_v3.html` |
| **Adjuntos** | Ninguno nuevo |
| **Depende de** | Todos los anteriores |
| **Objetivo** | Llevar la PWA a la versión 3 con una dirección visual más madura y entregar. |

---

## Prompt (copiar y pegar tal cual)


La PWA se ve demasiado infantil para docentes y direcciones. Haz la **versión 3** con un **rediseño «Observatorio»**:

1. **Sitio público:** barra nocturna, fondo azul muy oscuro (#0B0D24), líneas finas, la **órbita del grupo** como protagonista (anillos concéntricos que aparecen escalonados, puntos que entran uno a uno, los que necesitan apoyo en ámbar #F2B84B con su porcentaje), marcas de rol con un punto en órbita, tipografía **Red Hat Display/Text** y Red Hat Mono para cifras y códigos. Menos ilustración infantil, más claridad de datos.
2. **App:** tokens semánticos (superficie, texto, línea, acentos violeta/turquesa/ámbar/menta con su versión «ink» para texto) para tema claro y oscuro; tarjetas sobrias, etiquetas de estado con ícono + texto.
3. Mantén la marca: mismos logos y paleta base que el móvil.
4. Revisa contraste AA en ambos temas, foco visible, que los tres anchos (1280/1024/820) no tengan scroll horizontal, que «Atrás» funcione en todo y que sketches, wireframes y recorridos se regeneren con el diseño nuevo.
5. Título de la página: «Órbita Kids PWA · Prototipo y diagramas».

Publica la versión final como artifact.
