# 🪐 Órbita Kids — Frontend

Frontend de la **PWA para docentes** de Órbita Kids, una plataforma educativa
que apoya la práctica de sumas en estudiantes de los primeros grados de
primaria mediante una experiencia espacial, actividades interactivas y
seguimiento del progreso.

> **Estado actual:** el frontend forma parte del desarrollo previsto del
> proyecto. Las funcionalidades descritas en este documento representan el
> alcance de la PWA y no necesariamente indican que ya estén implementadas.

## 📖 Descripción

La PWA docente permitirá a los profesores administrar la práctica matemática
de sus grupos y consultar información útil para orientar el refuerzo educativo.
La aplicación se comunicará con la API REST del proyecto, desarrollada con
FastAPI, y no tendrá conexión directa con la base de datos.

Desde esta interfaz, el docente podrá:

- Administrar grupos y estudiantes.
- Asignar actividades de sumas.
- Consultar intentos, resultados y progreso.
- Identificar errores frecuentes.
- Reconocer actividades que requieren mayor práctica.
- Dar seguimiento al avance de los estudiantes.

## 🎯 Objetivo del frontend

Proporcionar una interfaz web clara, accesible y adaptable que ayude al
docente a:

1. Organizar a sus estudiantes en grupos.
2. Asignar actividades de acuerdo con los niveles de dificultad.
3. Revisar el desempeño individual y grupal.
4. Detectar necesidades de refuerzo.
5. Tomar decisiones de acompañamiento con base en los resultados registrados.

## 🧩 Alcance funcional

### Gestión docente

- Acceso a la PWA para docentes.
- Visualización de grupos y estudiantes.
- Consulta de la información relevante de cada grupo.

### Asignación de actividades

- Selección de actividades de sumas.
- Asignación de ejercicios a grupos o estudiantes.
- Organización de actividades dentro de los tres niveles de dificultad.

### Seguimiento del progreso

- Consulta de intentos y resultados.
- Visualización del avance de cada estudiante.
- Identificación de respuestas incorrectas y errores frecuentes.
- Detección de actividades que necesitan refuerzo.

### Comunicación con la API

El frontend consumirá los servicios de la API REST para consultar y enviar
información relacionada con:

- Usuarios y roles.
- Grupos y estudiantes.
- Actividades.
- Intentos y respuestas.
- Resultados y progreso.

El flujo general será:

```text
Docente → PWA React → API REST FastAPI → PostgreSQL
                                      ↓
                         Resultados y progreso
```

## 🛠️ Tecnologías

| Tecnología | Uso |
| --- | --- |
| **React** | Construcción de la interfaz de la PWA docente. |
| **JavaScript** | Lógica e interacción de la aplicación. |
| **HTML** | Estructura de las vistas. |
| **CSS** | Estilos, diseño adaptable y presentación visual. |
| **FastAPI** | API REST que conecta el frontend con los datos del proyecto. |
| **PostgreSQL** | Almacenamiento gestionado por la API. |
| **Git y GitHub** | Control de versiones y colaboración. |

## 🚀 Ejecución local

La configuración definitiva de ejecución se documentará cuando se incorpore la
estructura completa de la aplicación React y su archivo `package.json`.

De forma general, el flujo esperado para un proyecto React será:

```bash
# Clonar el repositorio
git clone https://github.com/ObedGuzmanGuz/Orbita_Kids.git

# Entrar al directorio del frontend
cd Orbita_Kids/Frontend

# Instalar dependencias
npm install

# Iniciar el servidor de desarrollo
npm run dev
```

> Los comandos pueden cambiar según la herramienta de construcción que se
> utilice para la versión final del frontend. Consulta los scripts definidos en
> `package.json` cuando estén disponibles.

## 🔐 Configuración de la API

La URL de la API deberá configurarse mediante variables de entorno y no
escribirse directamente en los componentes de React. Por ejemplo:

```env
VITE_API_URL=http://localhost:8000
```

El nombre y el formato de esta variable deberán ajustarse a la herramienta de
construcción elegida para el proyecto.

La API será responsable de:

- Validar las solicitudes.
- Gestionar la autenticación y los permisos.
- Aplicar las reglas de adaptación de actividades.
- Guardar y consultar los datos en PostgreSQL.

## 📱 Experiencia y diseño

La PWA docente debe priorizar:

- Navegación sencilla y consistente.
- Diseño adaptable para computadoras, tabletas y pantallas pequeñas.
- Contraste y tamaños de texto adecuados.
- Mensajes claros para errores, cargas y operaciones exitosas.
- Tablas, tarjetas o indicadores que faciliten la lectura del progreso.
- Accesibilidad mediante teclado y controles comprensibles.
- Coherencia visual con la temática espacial de Órbita Kids sin dificultar la
  consulta de información.

## 🗂️ Organización esperada

La estructura podrá organizarse de la siguiente manera cuando se implemente la
aplicación:

```text
Frontend/
├── public/             # Recursos públicos
├── src/
│   ├── components/     # Componentes reutilizables
│   ├── pages/          # Vistas principales de la PWA
│   ├── services/       # Comunicación con la API
│   ├── hooks/          # Lógica reutilizable de React
│   ├── styles/         # Estilos globales y de la aplicación
│   └── App.jsx         # Componente raíz
├── package.json
└── readme.md
```

Esta organización es una referencia inicial y puede adaptarse a las
necesidades del equipo.

## 🔄 Flujo de uso previsto

1. El docente accede a la PWA.
2. Selecciona un grupo o un estudiante.
3. Asigna una actividad de sumas.
4. El estudiante resuelve la actividad desde la aplicación móvil.
5. La API registra los intentos y resultados.
6. El docente consulta el progreso desde la PWA.
7. Con base en los errores y avances, decide qué actividades reforzar.

## 🧪 Validación

El frontend deberá evaluarse mediante pruebas técnicas y sesiones con usuarios
para comprobar:

- Funcionamiento de la asignación de actividades.
- Correcta consulta de resultados y progreso.
- Claridad de las instrucciones y mensajes.
- Facilidad para navegar entre grupos, estudiantes y actividades.
- Visualización comprensible de errores frecuentes.
- Adaptabilidad a diferentes tamaños de pantalla.
- Accesibilidad y uso mediante teclado.

La utilidad educativa de la plataforma deberá validarse con docentes y
estudiantes. No se consideran demostradas mejoras de aprendizaje antes de
realizar las pruebas correspondientes.

## 🚫 Fuera del alcance inicial

La primera versión del frontend no contempla:

- Una interfaz específica para madres, padres o tutores.
- Chatbot o adaptación mediante inteligencia artificial.
- Actividades de multiplicación, división u otros temas matemáticos.
- Funciones multijugador.
- Diagnóstico clínico o automático de dificultades de aprendizaje.
- Conexión directa del navegador con PostgreSQL.

## 👥 Integrantes

- Obed Guzmán Flores
- Yazmin Gutierrez Hernandez
- Citlalli Perez Dionicio
- Michelle Castro Otero
- Jennifer Bautista Barrios

## 🔗 Recursos del proyecto

- [Repositorio de Órbita Kids](https://github.com/ObedGuzmanGuz/Orbita_Kids)
- [Business Model Canvas](https://obedguzmanguz.github.io/Orbita_Kids/ModelBusinesCanvas/)
- [ODS 4 — Educación de calidad](https://sdgs.un.org/goals/goal4)

---

<p align="center">
  🪐 <strong>Órbita Kids</strong><br>
  Una herramienta docente para acompañar el aprendizaje de matemáticas.
</p>