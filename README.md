
<div align="center">

<img src="/Logos/Logo_Empresa.png" alt="Logo de Órbita Kids" width="180">

# 🪐 ÓRBITA · KIDS 🚀

### ✨ *CREAMOS EXPERIENCIAS QUE INSPIRAN* ✨

**Plataforma educativa para reforzar el aprendizaje de matemáticas mediante una aventura espacial.**

[Business Model Canvas](https://obedguzmanguz.github.io/Orbita_Kids/Documentacion/ModelBusinesCanvas/) · [Roles de usuario](https://obedguzmanguz.github.io/Orbita_Kids/Documentacion/DiagramaRolesUsuario/) · [Sketches](https://obedguzmanguz.github.io/Orbita_Kids/Frontend/Sketches/) · [Wireframes](https://obedguzmanguz.github.io/Orbita_Kids/Frontend/Wireframes/)

</div>

---

<a id="indice"></a>

## 📑 Índice

Selecciona cualquier sección para ir directamente a ella.

1. [Identidad del proyecto](#identidad-del-proyecto)
2. [Descripción general](#descripcion-general)
3. [Problemática](#problematica)
4. [Justificación](#justificacion)
5. [Objetivos](#objetivos)
6. [Público objetivo](#publico-objetivo)
7. [Propuesta de valor](#propuesta-de-valor)
8. [Solución propuesta y funcionamiento](#solucion-propuesta)
9. [Alcance de la primera versión](#alcance)
10. [Arquitectura del sistema](#arquitectura)
11. [Tecnologías propuestas](#tecnologias)
12. [Roles de usuario](#roles)
13. [Productos y diseño de interfaces](#productos)
    - [Sketches](#sketches)
    - [Wireframes](#wireframes)
    - [Diseño en Figma](#figma)
14. [Business Model Canvas](#business-model-canvas)
15. [Evaluación del proyecto](#evaluacion)
16. [Relación con el ODS 4](#ods-4)
17. [Estado del proyecto](#estado)
18. [Integrantes del equipo](#equipo)

---

<a id="identidad-del-proyecto"></a>

## 🎨 1. Identidad del proyecto

Órbita Kids utiliza una temática espacial para presentar las actividades matemáticas como misiones. Su identidad visual busca transmitir exploración, aprendizaje, creatividad y diversión.

### Logotipos

<table>
  <tr>
    <th align="center">Logo de la empresa</th>
    <th align="center">Logo de la aplicación</th>
  </tr>
  <tr>
    <td align="center">
      <img src="/Logos/Logo_Empresa.png" alt="Logo de la empresa Órbita Kids" width="80%">
    </td>
    <td align="center">
      <img src="/Logos/Logo_Aplicacion.png" alt="Logo de la aplicación Órbita Kids" width="80%">
    </td>
  </tr>
</table>

### Paleta de colores

La paleta visual combina tonos oscuros con colores suaves para mantener una identidad espacial consistente en la documentación y las interfaces.

<div align="center">
  <img src="/Logos/Paleta_Colores.png" alt="Paleta de colores de Órbita Kids" width="80%">
</div>


[Volver al índice](#indice)

---

<a id="descripcion-general"></a>

## 🚀 2. Descripción general

**Órbita Kids** es un proyecto educativo que propone reforzar el aprendizaje de matemáticas en niños de los primeros grados de primaria, especialmente entre los 6 y 9 años, mediante actividades interactivas y una aventura espacial.

El estudiante podrá elegir un personaje, explorar planetas, superar misiones y reparar su nave mientras practica sumas. La experiencia combinará apoyos visuales, recompensas y ejercicios cuya dificultad podrá ajustarse de acuerdo con su desempeño.

La solución contempla dos productos principales:

- **Aplicación móvil para estudiantes:** diseñada para realizar actividades matemáticas mediante una experiencia interactiva.
- **Aplicación web progresiva (PWA) para docentes:** orientada a organizar grupos, asignar actividades y consultar resultados.

Ambos productos se conectarán mediante una API REST, que gestionará la lógica del sistema y el acceso a los datos.

[Volver al índice](#indice)

---

<a id="problematica"></a>

## 📌 3. Problemática

Los estudiantes pueden presentar diferentes ritmos de aprendizaje y dificultades al resolver operaciones matemáticas. Por ello, una misma actividad no siempre proporciona el apoyo adecuado para todos.

Además, los docentes necesitan información que les permita reconocer errores frecuentes, revisar los avances y orientar las actividades de refuerzo.

Órbita Kids propone atender estas necesidades mediante ejercicios graduados, retroalimentación visual y seguimiento del progreso, como complemento del trabajo que se realiza en el aula.

La existencia y magnitud de estas necesidades deberán validarse con docentes y estudiantes durante las pruebas del proyecto.

[Volver al índice](#indice)

---

<a id="justificacion"></a>

## 💡 4. Justificación

El proyecto busca ofrecer una forma visual e interactiva de practicar matemáticas, utilizando una temática espacial que motive al estudiante a continuar con sus actividades.

La adaptación de ejercicios permitirá ajustar la dificultad y los apoyos según el desempeño. Por su parte, la PWA facilitará al docente la consulta de resultados y la asignación de actividades.

La propuesta integra tres elementos:

- **Práctica:** ejercicios de sumas organizados por dificultad.
- **Motivación:** personajes, planetas, misiones y recompensas visuales.
- **Seguimiento:** registro de intentos y resultados para orientar el refuerzo educativo.

La tecnología apoyará el acompañamiento docente y la práctica educativa; sus beneficios deberán evaluarse mediante pruebas con usuarios.

[Volver al índice](#indice)

---

<a id="objetivos"></a>

## 🎯 5. Objetivos

### Objetivo general

Desarrollar una plataforma educativa integrada por una aplicación móvil y una PWA docente que apoye el aprendizaje de sumas en estudiantes de los primeros grados de primaria, mediante actividades interactivas, adaptación básica de dificultad y seguimiento del progreso.

### Objetivos específicos

1. Diseñar actividades de sumas organizadas en **tres niveles de dificultad**.
2. Incorporar **dos tipos de actividades**: sumas con apoyo visual y selección de respuestas.
3. Implementar reglas que ajusten la dificultad y los apoyos según los errores y avances del estudiante.
4. Integrar personajes, planetas, misiones y recompensas visuales que acompañen la práctica.
5. Registrar intentos, resultados y avances para consultar el progreso.
6. Desarrollar una PWA que permita administrar grupos, asignar actividades e identificar necesidades de refuerzo.
7. Conectar la aplicación móvil y la PWA mediante una API REST y una base de datos.
8. Evaluar el funcionamiento y la claridad de las actividades mediante pruebas técnicas y sesiones con usuarios.

[Volver al índice](#indice)

---

<a id="publico-objetivo"></a>

## 👥 6. Público objetivo

| Público | Participación |
|---|---|
| **Estudiantes de primaria, de 6 a 9 años** | Resolver actividades, recibir apoyos y avanzar por los niveles. |
| **Docentes** | Organizar grupos, asignar ejercicios y consultar resultados. |
| **Escuelas e instituciones educativas** | Evaluar la adopción de la plataforma como herramienta complementaria. |

La primera versión no contempla una interfaz específica para las familias. Los estudiantes y docentes serán los usuarios directos de los productos, mientras que las escuelas podrán constituir clientes institucionales si se adopta el modelo de licencias.

[Volver al índice](#indice)

---

<a id="propuesta-de-valor"></a>

## ⭐ 7. Propuesta de valor

Órbita Kids combinará:

- **Práctica matemática con apoyos visuales**, para representar las operaciones de forma más comprensible.
- **Dificultad ajustable mediante reglas**, para ofrecer actividades de refuerzo o permitir avanzar progresivamente.
- **Una aventura espacial**, que representa el progreso mediante planetas, misiones y recompensas.
- **Información para el acompañamiento docente**, que facilite revisar resultados y reconocer qué actividades necesitan reforzarse.

La intención es que cada misión tenga un propósito educativo y que los elementos de juego acompañen el aprendizaje, sin sustituir la enseñanza del docente.

[Volver al índice](#indice)

---

<a id="solucion-propuesta"></a>

## 🪐 8. Solución propuesta y funcionamiento

### 👨‍🚀 Aplicación móvil para estudiantes

La aplicación, propuesta en **Flutter y Dart**, permitirá:

- Elegir un personaje.
- Resolver sumas con apoyo visual o selección de respuestas.
- Recorrer un mapa de planetas y niveles.
- Completar misiones relacionadas con la reparación de una nave.
- Obtener recompensas visuales.
- Consultar el avance.
- Recibir actividades ajustadas a su desempeño.

### 👩‍🏫 Aplicación web progresiva para docentes

La PWA, propuesta en **React**, permitirá:

- Administrar grupos y estudiantes.
- Asignar actividades matemáticas.
- Consultar resultados y progreso.
- Identificar errores frecuentes.
- Reconocer actividades que requieren mayor práctica.
- Orientar el refuerzo educativo con base en los resultados.

### 🧠 Adaptación de actividades

La primera versión utilizará **reglas programadas**, sin requerir un modelo de inteligencia artificial.

Cuando un estudiante presente dificultades, el sistema podrá ofrecer sumas más sencillas, apoyos visuales o actividades adicionales de refuerzo. Cuando mejore su desempeño, podrá avanzar progresivamente dentro de los tres niveles.

Los criterios de ajuste deberán definirse y probarse con apoyo docente.

### 🔄 Flujo de uso previsto

1. El docente organiza su grupo y asigna actividades.
2. El estudiante accede a la aplicación y realiza una misión.
3. El sistema registra los intentos y resultados.
4. Las reglas determinan si corresponde mantener el nivel, ofrecer refuerzo o avanzar.
5. El estudiante recibe retroalimentación y visualiza su progreso.
6. El docente consulta los resultados y decide qué reforzar.

[Volver al índice](#indice)

---

<a id="alcance"></a>

## 📚 9. Alcance de la primera versión

| Elemento | Alcance previsto |
|---|---|
| Tema matemático | Sumas. |
| Dificultad | Tres niveles. |
| Actividades | Apoyo visual y selección de respuestas. |
| Personalización | Selección de personaje. |
| Experiencia | Mapa de planetas, misiones y recompensas visuales. |
| Adaptación | Reglas básicas según el desempeño. |
| Seguimiento | Registro de intentos, errores, resultados y progreso. |
| Herramientas docentes | Grupos, asignación de actividades y consulta de avances. |

### Funciones fuera del alcance inicial

- Otros temas matemáticos, como multiplicación o división.
- Chatbot o adaptación mediante inteligencia artificial.
- Interfaz específica para familiares.
- Funciones multijugador.
- Diagnóstico de dificultades de aprendizaje.

Estas funciones no forman parte de los compromisos de la primera versión y podrán reconsiderarse en futuras etapas.

[Volver al índice](#indice)

---

<a id="arquitectura"></a>

## 🏗️ 10. Arquitectura del sistema



<div align="center">
  <img src="/Documentacion/DiagramaDeArquitectura/img/diagramaArquitectura.jpeg" alt="Diagrama de arquitectura de Órbita Kids" width="90%">
</div>

### Componentes principales

1. **Aplicación móvil:** interfaz para que el estudiante realice actividades.
2. **PWA docente:** interfaz web para administrar grupos y revisar resultados.
3. **API REST con FastAPI:** recibe las solicitudes de las aplicaciones y ejecuta la lógica del sistema.
4. **Base de datos MySQL:** almacenamiento previsto para usuarios, grupos, actividades, intentos y progreso.
5. **Servidor VPS:** entorno propuesto para desplegar los servicios del backend y la base de datos.
6. **Git y GitHub:** control de versiones y colaboración en el desarrollo.

La autenticación, el monitoreo y otros componentes adicionales se incorporarán únicamente cuando el alcance y las necesidades técnicas lo justifiquen.

> **Nota:** el diagrama puede mostrar componentes previstos para autenticación, despliegue y monitoreo. Su presencia en la arquitectura no significa que ya estén implementados.

📂 **[Ver la carpeta del diagrama de arquitectura](Documentacion/DiagramaDeArquitectura/)**

[Volver al índice](#indice)

---

<a id="tecnologias"></a>

## 🛠️ 11. Tecnologías propuestas



| Tecnología | Icono | Uso previsto |
|---|:---:|---|
| **Flutter y Dart** | <img src="https://img.shields.io/badge/Flutter-Mobile-02569B?logo=flutter&logoColor=white" alt="Flutter"> <img src="https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white" alt="Dart"> | Desarrollo de la aplicación móvil para estudiantes. |
| **React** | <img src="https://img.shields.io/badge/React-PWA-61DAFB?logo=react&logoColor=black" alt="React"> | Desarrollo de la aplicación web progresiva (PWA) para docentes. |
| **FastAPI** | <img src="https://img.shields.io/badge/FastAPI-API-009688?logo=fastapi&logoColor=white" alt="FastAPI"> | API REST para conectar las aplicaciones y gestionar la lógica del sistema. |
| **MySQL** | <img src="https://img.shields.io/badge/MySQL-Database-4479A1?logo=mysql&logoColor=white" alt="MySQL"> | Base de datos para usuarios, grupos, actividades, intentos y progreso. |
| **Git y GitHub** | <img src="https://img.shields.io/badge/Git-Version_Control-F05032?logo=git&logoColor=white" alt="Git"> <img src="https://img.shields.io/badge/GitHub-Repository-181717?logo=github&logoColor=white" alt="GitHub"> | Control de versiones, respaldo del código y colaboración del equipo. |
| **HTML, CSS y JavaScript** | <img src="https://img.shields.io/badge/HTML5-Markup-E34F26?logo=html5&logoColor=white" alt="HTML5"> <img src="https://img.shields.io/badge/CSS3-Styles-1572B6?logo=css3&logoColor=white" alt="CSS3"> <img src="https://img.shields.io/badge/JavaScript-Language-F7DF1E?logo=javascript&logoColor=black" alt="JavaScript"> | Desarrollo de la documentación web y del Business Model Canvas interactivo. |
| **GitHub Pages** | <img src="https://img.shields.io/badge/GitHub_Pages-Publishing-222222?logo=githubpages&logoColor=white" alt="GitHub Pages"> | Publicación de páginas estáticas, como el Canvas y la documentación. |
| **Docker y Docker Compose** | <img src="https://img.shields.io/badge/Docker-Containers-2496ED?logo=docker&logoColor=white" alt="Docker"> | Empaquetado y ejecución de servicios cuando se incorporen al despliegue. |
| **VPS** | <img src="https://img.shields.io/badge/VPS-Hosting-6C5CE7" alt="VPS"> | Alojamiento previsto para la API y los servicios de backend. |


La aplicación móvil y la PWA se comunicarán con FastAPI. La API gestionará el acceso a MySQL, evitando conexiones directas desde las interfaces a la base de datos.

**GitHub Pages alojará la documentación estática; la API y la base de datos requerirán un entorno de ejecución propio.**

[Volver al índice](#indice)

---

<a id="roles"></a>

## 👥 12. Roles de usuario

El diagrama de roles permite visualizar los perfiles que interactuarán con Órbita Kids y las responsabilidades que tendrá cada uno dentro de la plataforma.

<div align="center">

[![Diagrama de Roles de usuario](/Logos/DiagramaRoles.png)](https://obedguzmanguz.github.io/Orbita_Kids/Documentacion/DiagramaRolesUsuario/)

**[Abrir el diagrama interactivo de roles de usuario](https://obedguzmanguz.github.io/Orbita_Kids/Documentacion/DiagramaRolesUsuario/)**

</div>

Los roles deben diferenciar los permisos de cada perfil. Por ejemplo, el estudiante realiza actividades y consulta su propio progreso, mientras que el docente administra sus grupos y revisa los resultados correspondientes.

Los permisos definitivos deberán coincidir con la implementación de la aplicación y las reglas de acceso del backend.

[Volver al índice](#indice)

---

<a id="productos"></a>

## 📱 13. Productos y diseño de interfaces

Esta sección reúne los recursos visuales que ayudan a comprender la experiencia propuesta antes de completar la implementación.

<a id="sketches"></a>

### ✏️ Sketches de la aplicación

Los sketches presentan ideas iniciales de las pantallas y los recorridos de usuario. Permiten visualizar cómo podrían interactuar estudiantes y docentes con la plataforma.

🚀 **[Explorar Sketches](https://obedguzmanguz.github.io/Orbita_Kids/Frontend/Sketches/)**

📂 [Ver carpeta de Sketches](Frontend/Sketches/)

[Volver al índice](#indice)

---

<a id="wireframes"></a>

### 📐 Wireframes de la aplicación

Los wireframes muestran la estructura y distribución de las pantallas para estudiantes y docentes, tanto en móvil como en web/PWA. Ayudan a definir la navegación, la jerarquía visual y la ubicación de los elementos antes de implementar las interfaces.

🚀 **[Explorar Wireframes](https://obedguzmanguz.github.io/Orbita_Kids/Frontend/Wireframes/)**

📂 [Ver carpeta de Wireframes](Frontend/Wireframes/)

[Volver al índice](#indice)

---

<a id="figma"></a>

### 🎨 Diseño en Figma

El archivo de Figma sirve como referencia visual para revisar las propuestas de interfaz y mantener coherencia entre las pantallas.

🎨 **[Consultar el diseño en Figma](https://www.figma.com/design/NJvpRMCpqT1MHrAjRdWY9k/Orbita-Kids?node-id=8-6746)**

[Volver al índice](#indice)

---

<a id="business-model-canvas"></a>

## 🧩 14. Business Model Canvas

El proyecto cuenta con un **Business Model Canvas interactivo** que organiza los nueve bloques principales del modelo de negocio:

1. Segmentos de clientes.
2. Propuesta de valor.
3. Canales.
4. Relaciones con clientes.
5. Fuentes de ingresos.
6. Recursos clave.
7. Actividades clave.
8. Socios clave.
9. Estructura de costos.

Cada bloque explica su significado, su relación con los demás elementos y su aplicación al proyecto.

El modelo contempla una posible estrategia de ingresos mediante una versión gratuita y licencias escolares de pago. Los precios, costos, alianzas y previsiones económicas son hipótesis que deberán validarse antes de considerarse resultados reales.

🚀 **[Abrir el Business Model Canvas interactivo](https://obedguzmanguz.github.io/Orbita_Kids/Documentacion/ModelBusinesCanvas/)**

📂 **[Ver carpeta del Business Model Canvas](Practica04/)**

[Volver al índice](#indice)

---

<a id="evaluacion"></a>

## 🧪 15. Evaluación del proyecto

Para comprobar la propuesta se plantea evaluar los siguientes aspectos:

- **Funcionamiento:** asignación de actividades, registro de resultados y consulta del progreso.
- **Adaptación:** cambios de dificultad dentro de los límites establecidos.
- **Usabilidad:** claridad de instrucciones, controles y navegación.
- **Contenido educativo:** revisión de ejercicios y apoyos con docentes.
- **Utilidad:** observaciones de estudiantes y docentes durante pruebas piloto.

Los resultados permitirán corregir problemas y ajustar la propuesta. No se consideran demostradas mejoras de aprendizaje antes de realizar la evaluación.

[Volver al índice](#indice)

---

<a id="ods-4"></a>

## 🌎 16. Relación con el ODS 4: Educación de calidad

Órbita Kids se relaciona con el **Objetivo de Desarrollo Sostenible 4**, que busca promover una educación inclusiva, equitativa y de calidad.

La contribución prevista del proyecto se centra en ofrecer ejercicios graduados, apoyos visuales y seguimiento que ayuden a reconocer necesidades de refuerzo en la práctica matemática.

🔗 **[Consultar ODS 4 — Naciones Unidas](https://sdgs.un.org/goals/goal4)**

[Volver al índice](#indice)

---

<a id="estado"></a>

## 📍 17. Estado del proyecto

El trabajo documentado comprende la definición de la propuesta educativa, la identidad visual, el modelo de negocio, los diagramas y los recursos de diseño de interfaces.

La aplicación móvil, la PWA docente, la API y la base de datos forman parte del desarrollo previsto. Las funciones descritas en este documento representan el alcance propuesto y no deben interpretarse como funcionalidades terminadas si aún no han sido implementadas y probadas.

Las siguientes etapas deberán priorizar la validación del diseño, el desarrollo del producto mínimo viable, las pruebas funcionales y la evaluación con usuarios.

[Volver al índice](#indice)

---

<a id="equipo"></a>

## 👨‍💻 18. Integrantes del proyecto

 <img src="/Logos/Roles_Proyecto.png" alt="Roles del proyecto" width="80%" >


[Volver al índice](#indice)

---

<div align="center">

---

<img src="/Logos/Logo_Aplicacion.png" alt="Logo de Órbita Kids" width="100">

### 🪐 Órbita Kids

*Aprender matemáticas también puede ser una aventura.* 🚀

</div>
