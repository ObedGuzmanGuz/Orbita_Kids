# 🪐 Wireframes de Órbita Kids

Esta carpeta contiene los wireframes de Órbita Kids, una plataforma educativa
que acompaña el aprendizaje infantil mediante actividades interactivas,
movimiento, exploración del entorno y seguimiento del progreso.

Los wireframes representan la estructura funcional de las pantallas antes de
su implementación. Permiten visualizar la distribución de la información, la
navegación, las acciones principales y la relación entre las diferentes vistas
de la aplicación.

## 🎯 Propósito

Los wireframes sirven como referencia para diseñar y desarrollar una
experiencia clara, consistente y adecuada para cada tipo de usuario. Permiten:

- Definir la jerarquía y organización del contenido.
- Representar los recorridos principales de la aplicación.
- Identificar las acciones disponibles en cada pantalla.
- Revisar la navegación antes de implementar la interfaz.
- Adaptar la experiencia a dispositivos móviles y Web/PWA.
- Alinear el trabajo de diseño, frontend, backend y contenido.
- Detectar problemas de usabilidad y accesibilidad de forma temprana.

## 👥 Perfiles contemplados

Los wireframes están organizados para dos perfiles principales:

### Estudiante

Representan las pantallas que utiliza el estudiante para aprender, realizar
actividades y consultar su progreso:

- Bienvenida y acceso.
- Perfil infantil e inicio.
- Cursos, rutas de aprendizaje y lecciones.
- Quizzes y actividades breves.
- Retos físicos, pausas activas y exploración del entorno.
- Experimentos, lecturas y actividades familiares.
- Diario, equilibrio digital, logros y perfil.

### Profesor

Representan las herramientas que utiliza el profesor para acompañar,
organizar y evaluar el aprendizaje:

- Inicio, grupos y seguimiento de estudiantes.
- Cursos, actividades y asignación de contenido.
- Biblioteca offline y materiales imprimibles.
- Creación y validación de retos.
- Planificación semanal y pausas activas.
- Rúbricas, retroalimentación y comunicación con familias.
- Reportes, bienestar, uso digital y preferencias.

## 📱 Plataformas

Cada perfil cuenta con wireframes para dos plataformas:

- **Móvil:** prioriza tareas rápidas, navegación sencilla, actividades
  interactivas y uso en diferentes contextos.
- **Web/PWA:** proporciona una vista más amplia para consultar información,
  organizar actividades, revisar avances y administrar grupos o contenidos.

La separación por plataforma permite revisar qué información y controles son
más importantes en cada tamaño de pantalla, manteniendo una experiencia
coherente entre ambas versiones.

## 🔄 Flujos representados

Los wireframes están conectados mediante recorridos que muestran la secuencia
de uso de la aplicación. Entre los principales flujos se encuentran:

### Flujo del estudiante

1. Acceso a la plataforma y configuración del perfil infantil.
2. Consulta del inicio, cursos o ruta de aprendizaje.
3. Selección de una lección o actividad.
4. Realización de quizzes, retos, lecturas o experimentos.
5. Registro de la actividad y consulta de logros o progreso.

### Flujo del profesor

1. Acceso al panel docente.
2. Consulta de grupos y estudiantes.
3. Selección o creación de actividades.
4. Asignación de contenido y retos.
5. Validación de actividades y revisión de resultados.
6. Consulta de reportes y envío de retroalimentación.

Estos recorridos ayudan a comprobar que cada pantalla tenga un propósito claro
y que el usuario pueda avanzar sin pasos innecesarios.

## 🗂️ Organización de los recursos

```text
Wireframes/
├── assets/
│   ├── wireframes/          # Vistas por perfil y plataforma
│   └── VISTA_GENERAL_*.jpg  # Resúmenes visuales de los recorridos
├── tokens/                  # Tokens visuales reutilizables
├── tools/                   # Herramientas de generación y exportación
├── catalogo.json            # Pantallas, acciones y conexiones
├── index.html               # Visualizador de wireframes
└── README.md                # Este documento
```

### Archivos visuales

- Los archivos **PNG** permiten revisar las pantallas como imágenes.
- Los archivos **SVG** conservan una representación escalable y estructurada
  del wireframe.
- Las imágenes `VISTA_GENERAL_*.jpg` muestran una vista resumida de los
  recorridos de cada perfil y plataforma.

### Catálogo

El archivo [`catalogo.json`](./catalogo.json) documenta las vistas incluidas en
los wireframes. Para cada pantalla puede contener:

- Perfil y plataforma.
- Orden dentro del flujo.
- Nombre y descripción.
- Acciones disponibles.
- Siguiente pantalla.
- Categoría funcional.
- Especificaciones de regiones y componentes.

### Tokens y herramientas

La carpeta [`tokens`](./tokens) contiene valores reutilizables para mantener
consistencia en colores, tamaños y estilos. La carpeta [`tools`](./tools)
incluye scripts relacionados con la generación, organización y exportación de
las especificaciones de los wireframes.

## 💡 Importancia en el proyecto

Los wireframes son importantes para Órbita Kids porque ayudan a que la
aplicación responda al propósito educativo y a las necesidades de sus usuarios:

- **Ponen al usuario en el centro:** consideran las necesidades y capacidades
  de estudiantes y profesores.
- **Favorecen una experiencia infantil clara:** permiten revisar que las
  instrucciones, acciones y recorridos sean fáciles de comprender.
- **Conectan aprendizaje y bienestar:** hacen visible la integración de
  lecciones, movimiento, actividades offline y participación familiar.
- **Mantienen consistencia entre plataformas:** ayudan a conservar una
  experiencia coherente en móvil y Web/PWA.
- **Facilitan la accesibilidad:** permiten revisar el orden de la información,
  el tamaño de los controles y la claridad de los mensajes.
- **Reducen riesgos de desarrollo:** los problemas de flujo pueden resolverse
  antes de convertirlos en código.
- **Mejoran la comunicación del equipo:** ofrecen una referencia compartida
  para diseño, frontend, backend, contenido y validación.

## ✅ Uso durante el desarrollo

Antes de implementar o modificar una pantalla, se recomienda:

1. Identificar el perfil y la plataforma correspondientes.
2. Consultar la pantalla en el visualizador o mediante sus archivos PNG/SVG.
3. Revisar en [`catalogo.json`](./catalogo.json) sus acciones y conexiones.
4. Confirmar la jerarquía del contenido y el objetivo de la vista.
5. Verificar el comportamiento esperado en diferentes tamaños de pantalla.
6. Mantener actualizados el wireframe y el catálogo cuando cambie el flujo.

Los wireframes son una guía de diseño y funcionalidad; no representan
necesariamente la interfaz visual final ni sustituyen las pruebas con usuarios.

## 🔗 Recursos relacionados

- [Catálogo de wireframes](./catalogo.json)
- [Visualizador de wireframes](./index.html)
- [Documentación general del frontend](../readme.md)
- [Repositorio de Órbita Kids](https://github.com/ObedGuzmanGuz/Orbita_Kids)

---

Los wireframes son una referencia viva del proyecto. Pueden evolucionar a
medida que se validen las necesidades de los usuarios y se incorporen nuevas
funcionalidades a Órbita Kids.
