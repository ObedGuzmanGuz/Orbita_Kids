# 🪐 Órbita Kids

**Órbita Kids** es un proyecto educativo que propone reforzar el aprendizaje de **matemáticas en niños de los primeros grados de primaria**, mediante actividades interactivas y una aventura espacial.

El estudiante podrá elegir un personaje, explorar planetas, superar misiones y reparar su nave mientras practica matemáticas. La experiencia combinará apoyos visuales, recompensas y ejercicios ajustados a su desempeño.

La propuesta contempla una **aplicación móvil para estudiantes** y una **aplicación web progresiva (PWA) para docentes**, conectadas mediante una API.

---

## 📌 Problemática

Los estudiantes pueden presentar diferentes ritmos de aprendizaje y dificultades al resolver operaciones matemáticas. Por ello, una misma actividad no siempre ofrece el apoyo adecuado para todos.

Además, los docentes necesitan información que les permita identificar los errores frecuentes y orientar las actividades de refuerzo.

Órbita Kids propone atender estas necesidades mediante ejercicios graduados, retroalimentación y seguimiento del progreso, como complemento del trabajo en el aula.

---

## 💡 Justificación

El proyecto busca ofrecer una forma visual e interactiva de practicar matemáticas, utilizando una temática espacial que motive al estudiante a continuar.

La adaptación de ejercicios permitirá ajustar el apoyo según su desempeño, mientras que la PWA facilitará al docente la consulta de resultados y la asignación de actividades.

**La tecnología apoyará el acompañamiento docente y la práctica educativa.** Los beneficios de la propuesta deberán evaluarse mediante pruebas con usuarios.

---

## 🎯 Objetivo general

Desarrollar una plataforma educativa integrada por una aplicación móvil y una PWA docente que apoye el aprendizaje de sumas en estudiantes de los primeros grados de primaria, mediante actividades interactivas, adaptación básica de dificultad y seguimiento del progreso.

## ✅ Objetivos específicos

1. Diseñar actividades de sumas organizadas en **tres niveles de dificultad**.
2. Incorporar **dos tipos de actividades**: sumas con apoyo visual y selección de respuestas.
3. Implementar reglas que ajusten la dificultad y los apoyos según los errores y avances del estudiante.
4. Integrar personajes, planetas, misiones y recompensas visuales que acompañen la práctica.
5. Registrar los intentos, resultados y avances para consultar el progreso.
6. Desarrollar una PWA que permita administrar grupos, asignar actividades e identificar necesidades de refuerzo.
7. Conectar la aplicación móvil y la PWA mediante una API REST y una base de datos.
8. Evaluar el funcionamiento y la claridad de las actividades mediante pruebas técnicas y sesiones con usuarios.

---

## 👥 ¿A quién va dirigido?

| Público | Participación en el proyecto |
| --- | --- |
| **Estudiantes de los primeros grados de primaria** | Resolver actividades, recibir apoyos y avanzar por los niveles. |
| **Docentes** | Organizar grupos, asignar ejercicios y consultar resultados. |
| **Escuelas e instituciones educativas** | Evaluar la adopción de la plataforma como herramienta complementaria. |
| **Padres, madres y tutores** | Acompañar indirectamente la práctica y motivar al estudiante. |

La primera versión **no contempla una interfaz específica para las familias**.

---

## 🚀 ¿Cómo funcionará?

### 👨‍🚀 Aplicación para estudiantes

La aplicación móvil, propuesta en **Flutter y Dart**, permitirá:

- Elegir un personaje.
- Resolver sumas con apoyo visual o selección de respuestas.
- Recorrer un mapa de planetas y niveles.
- Completar misiones relacionadas con la reparación de una nave.
- Obtener recompensas visuales.
- Consultar el avance.
- Recibir actividades ajustadas a su desempeño.

### 👩‍🏫 PWA para docentes

La aplicación web progresiva, propuesta en **React**, permitirá:

- Administrar grupos y estudiantes.
- Asignar actividades matemáticas.
- Consultar resultados y progreso.
- Identificar errores frecuentes.
- Reconocer actividades que requieren mayor práctica.
- Orientar el refuerzo educativo con base en los resultados.

### 🧠 Adaptación de actividades

La primera versión utilizará **reglas programadas** para ajustar los ejercicios.

Cuando un estudiante presente dificultades, el sistema podrá ofrecer sumas más sencillas, apoyos visuales o actividades adicionales de refuerzo. Cuando mejore su desempeño, podrá avanzar progresivamente dentro de los tres niveles.

Los criterios de ajuste deberán definirse y probarse con apoyo docente. **Esta adaptación básica no requiere un modelo de inteligencia artificial.**

### 🔄 Flujo de uso previsto

1. El docente organiza su grupo y asigna actividades.
2. El estudiante accede a la aplicación y realiza una misión.
3. El sistema registra los intentos y resultados.
4. Las reglas determinan si corresponde mantener el nivel, ofrecer refuerzo o avanzar.
5. El estudiante recibe retroalimentación y visualiza su progreso.
6. El docente consulta los resultados y decide qué reforzar.

---

## 📚 Alcance de la primera versión

| Elemento | Alcance previsto |
| --- | --- |
| Tema matemático | Sumas. |
| Dificultad | Tres niveles. |
| Actividades | Apoyo visual y selección de respuestas. |
| Personalización | Selección de personaje. |
| Experiencia | Mapa de planetas, misiones y recompensas visuales. |
| Adaptación | Reglas básicas según el desempeño. |
| Seguimiento | Registro de intentos, errores, resultados y progreso. |
| Herramientas docentes | Grupos, asignación de actividades y consulta de avances. |

### Fuera del alcance inicial

- Otros temas matemáticos, como multiplicación o división.
- Chatbot o adaptación mediante inteligencia artificial.
- Interfaz para familiares.
- Funciones multijugador.
- Diagnóstico de dificultades de aprendizaje.

Estas funciones no forman parte de los compromisos de la primera versión.

---

## ⭐ Propuesta de valor

Órbita Kids combinará:

- **Práctica matemática con apoyos visuales.**
- **Dificultad ajustable mediante reglas.**
- **Una aventura espacial que represente el avance.**
- **Información útil para el acompañamiento docente.**

La intención es que cada misión tenga un propósito educativo y que los elementos de juego acompañen el aprendizaje.

---

## 🛠️ Tecnologías propuestas

![Flutter](https://img.shields.io/badge/Flutter-Mobile-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white)
![React](https://img.shields.io/badge/React-PWA-61DAFB?logo=react&logoColor=black)
![FastAPI](https://img.shields.io/badge/FastAPI-API-009688?logo=fastapi&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-4169E1?logo=postgresql&logoColor=white)
![Git](https://img.shields.io/badge/Git-Version_Control-F05032?logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Repository-181717?logo=github&logoColor=white)

| Tecnología | Uso previsto |
| --- | --- |
| **Flutter y Dart** | Aplicación móvil del estudiante. |
| **React** | PWA para docentes. |
| **FastAPI** | API REST y lógica del servicio. |
| **PostgreSQL** | Almacenamiento de usuarios, grupos, actividades, intentos y progreso. |
| **Git y GitHub** | Control de versiones y colaboración. |
| **HTML, CSS y JavaScript** | Sitio del Business Model Canvas interactivo. |
| **GitHub Pages** | Publicación del Canvas y su presentación web. |

La aplicación móvil y la PWA se comunicarán con **FastAPI**. La API gestionará el acceso a **PostgreSQL**, evitando conexiones directas desde las interfaces a la base de datos.

**GitHub Pages alojará el Canvas estático; la API y la base de datos requerirán un entorno de ejecución propio.**

---

## 🧪 Evaluación del proyecto

Para comprobar la propuesta se plantea evaluar:

- **Funcionamiento:** asignación de actividades, registro de resultados y consulta del progreso.
- **Adaptación:** cambios de dificultad dentro de los límites establecidos.
- **Usabilidad:** claridad de instrucciones, controles y navegación.
- **Contenido educativo:** revisión de ejercicios y apoyos con docentes.
- **Utilidad:** observaciones de estudiantes y docentes durante pruebas piloto.

Los resultados permitirán corregir problemas y ajustar la propuesta. No se consideran demostradas mejoras de aprendizaje antes de realizar esta evaluación.

---

## 🌎 ODS 4 — Educación de calidad

Órbita Kids se relaciona con el **Objetivo de Desarrollo Sostenible 4**, al proponer herramientas digitales de apoyo para la práctica de matemáticas y el acompañamiento docente.

Su contribución prevista se centra en ofrecer ejercicios graduados, apoyos visuales y seguimiento que ayuden a reconocer necesidades de refuerzo.

🔗 [Consultar ODS 4 — Naciones Unidas](https://sdgs.un.org/goals/goal4)

---

## 🧩 Business Model Canvas

El proyecto cuenta con un **Business Model Canvas interactivo** que presenta sus nueve bloques:

1. Segmentos de clientes.
2. Propuesta de valor.
3. Canales.
4. Relaciones con clientes.
5. Fuentes de ingresos.
6. Recursos clave.
7. Actividades clave.
8. Socios clave.
9. Estructura de costos.

Cada bloque incluye su significado, una ilustración y una sección destacada de **Aplicación en Órbita Kids**, con elementos concretos del proyecto.

El sitio incorpora un planeta giratorio, bordes con una estela luminosa suave, fichas desplegables, navegación por teclado, diseño adaptable y una sección ilustrada del ODS 4.

📂 **[Ver carpeta del Business Model Canvas](Practica04/)**

🚀 **[Ver Canvas interactivo en GitHub Pages](https://obedguzmanguz.github.io/Orbita_Kids/Practica04/)**

📄 **[Consultar documentación del Canvas](Practica04/README.md)**

> Los ingresos, precios y alianzas del modelo son propuestas por validar. No representan ventas ni convenios confirmados.

---

## 📍 Estado del proyecto

Actualmente, el trabajo presentado se concentra en la **definición de Órbita Kids y su Business Model Canvas interactivo**.

La aplicación móvil, la PWA docente, la API y la base de datos forman parte del desarrollo previsto. Las funciones descritas en este documento representan el alcance propuesto y no deben interpretarse como funcionalidades ya terminadas.

---

## 👥 Integrantes del equipo

- Obed Guzmán Flores
- Yazmin Gutierrez Hernandez
- Citlalli Perez Dionicio
- Michelle Castro Otero
- Jennifer Bautista Barrios

---

<p align="center">
  🪐 <strong>Órbita Kids</strong><br>
  Aprender matemáticas también puede ser una aventura.
</p>