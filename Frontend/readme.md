# 🪐 Órbita Kids: sketches y wireframes

Esta carpeta reúne los **sketches** y **wireframes** de Órbita Kids, una
plataforma educativa que busca acompañar el aprendizaje infantil mediante
actividades interactivas, movimiento, exploración del entorno y seguimiento del
progreso.

Estos recursos representan la evolución visual y funcional de la propuesta:
los sketches permiten explorar ideas de manera rápida y los wireframes
organizan esas ideas en pantallas, flujos y componentes que pueden utilizarse
como referencia durante el desarrollo del producto.

## 🎯 Propósito

El objetivo de los sketches y wireframes es convertir las necesidades de los
usuarios en una experiencia clara antes de implementar la interfaz final.
Sirven para:

- Explorar distintas soluciones de navegación y distribución de contenido.
- Visualizar las tareas principales de estudiantes y profesores.
- Detectar problemas de usabilidad en una etapa temprana.
- Alinear al equipo de diseño, desarrollo y contenido.
- Mantener una referencia común durante la construcción de la aplicación.
- Validar que la experiencia funcione en dispositivos móviles y en la versión
  web/PWA.

## ✏️ Sketches

Los sketches son bocetos iniciales de las pantallas y flujos de Órbita Kids.
Se enfocan en la idea general de cada vista, la secuencia de navegación y la
ubicación aproximada de los elementos, sin definir todavía todos los detalles
visuales o técnicos.

En [`../Sketches`](../Sketches) se encuentran las propuestas organizadas por:

- **Perfil:** estudiante y profesor.
- **Plataforma:** móvil y Web/PWA.
- **Pantallas:** bienvenida, acceso, inicio, cursos, lecciones, retos,
  actividades, progreso, reportes y perfil, entre otras.

Los sketches ayudan a responder preguntas como:

- ¿Qué necesita hacer el usuario en cada paso?
- ¿Qué información debe aparecer primero?
- ¿Cómo se relacionan las pantallas entre sí?
- ¿La navegación resulta comprensible para un niño o para un profesor?

## 🧱 Wireframes

Los wireframes son una versión más estructurada de los sketches. Definen con
mayor claridad la jerarquía de la información, las áreas de cada pantalla, las
acciones disponibles, los estados de navegación y la adaptación entre
dispositivos.

Los wireframes de esta carpeta contemplan dos perfiles principales:

### Estudiante

Incluyen experiencias de aprendizaje y bienestar, como:

- Bienvenida y acceso.
- Perfil infantil e inicio.
- Cursos, rutas de aprendizaje y lecciones.
- Quizzes y actividades breves.
- Retos físicos, pausas activas y exploración del entorno.
- Experimentos, lecturas y actividades familiares.
- Diario, equilibrio digital, logros y perfil.

### Profesor

Incluyen herramientas para acompañar y administrar el aprendizaje, como:

- Inicio, grupos y seguimiento de estudiantes.
- Cursos, actividades y asignación de contenido.
- Biblioteca offline y materiales imprimibles.
- Creación y validación de retos.
- Planificación semanal y pausas activas.
- Rúbricas, retroalimentación y comunicación con familias.
- Reportes, bienestar, uso digital y preferencias.

Cada perfil cuenta con propuestas para **móvil** y **Web/PWA**, de modo que las
funciones puedan consultarse y utilizarse en el contexto más adecuado.

## 🗂️ Organización de los recursos

```text
Frontend/
├── Sketches/
│   ├── assets/              # Bocetos visuales en formato PNG
│   ├── catalogo.json       # Catálogo de pantallas y recorridos
│   └── README.md            # Documentación específica de los sketches
└── Wireframes/
    ├── assets/
    │   ├── wireframes/     # Wireframes organizados por perfil y plataforma
    │   └── VISTA_GENERAL_*.jpg
    ├── tokens/             # Tokens visuales reutilizables
    ├── tools/              # Herramientas para generar y exportar recursos
    ├── catalogo.json       # Descripción de pantallas, acciones y conexiones
    ├── index.html          # Visualizador de wireframes
    └── README.md           # Este documento
```

Los recursos pueden encontrarse en formatos PNG y SVG. El archivo
[`catalogo.json`](./catalogo.json) concentra información de las vistas,
incluyendo sus títulos, descripciones, acciones y la pantalla siguiente dentro
del flujo.

## 🔄 Relación entre sketches y wireframes

El proceso recomendado para utilizar estos materiales es:

1. **Explorar:** plantear ideas y alternativas mediante sketches.
2. **Organizar:** seleccionar las propuestas que mejor responden a las
   necesidades de cada usuario.
3. **Estructurar:** convertirlas en wireframes con flujos, jerarquías y
   componentes más definidos.
4. **Validar:** revisar la claridad de la navegación y detectar ajustes antes
   del desarrollo.
5. **Implementar:** utilizar los wireframes como referencia para construir la
   interfaz y sus versiones responsivas.

Los wireframes no sustituyen las pruebas con usuarios ni representan
necesariamente la interfaz visual final. Son una guía para validar la
experiencia, documentar decisiones y reducir cambios costosos durante la
implementación.

## 💡 Importancia para Órbita Kids

Los sketches y wireframes son importantes porque ayudan a que la tecnología
responda al propósito educativo del proyecto:

- **Ponen al usuario en el centro:** consideran las necesidades y capacidades
  de estudiantes y profesores.
- **Favorecen una experiencia infantil clara:** permiten revisar que las
  instrucciones, acciones y recorridos sean fáciles de comprender.
- **Conectan aprendizaje y bienestar:** hacen visible la integración de
  lecciones, movimiento, actividades offline y participación familiar.
- **Mantienen consistencia entre plataformas:** ayudan a conservar una
  experiencia coherente en móvil y Web/PWA.
- **Facilitan la accesibilidad:** permiten revisar desde temprano el orden de la
  información, el tamaño de los controles y la claridad de los mensajes.
- **Reducen riesgos de desarrollo:** los problemas de flujo pueden resolverse
  antes de convertirlos en código.
- **Mejoran la comunicación del equipo:** ofrecen una referencia compartida
  para diseño, frontend, backend, contenido y validación.

## ✅ Recomendaciones de uso

Antes de implementar una pantalla basada en estos recursos, se recomienda:

1. Confirmar el perfil y la plataforma a la que pertenece.
2. Revisar el flujo de navegación en `catalogo.json`.
3. Verificar las acciones principales y los estados esperados.
4. Comprobar que el contenido sea comprensible para el público objetivo.
5. Validar el comportamiento en diferentes tamaños de pantalla.
6. Registrar cualquier cambio importante para mantener actualizada la
   documentación.

## 🔗 Recursos relacionados

- [Bocetos de Órbita Kids](../Sketches)
- [Catálogo de wireframes](./catalogo.json)
- [Visualizador de wireframes](./index.html)
- [Documentación general del frontend](../readme.md)
- [Repositorio de Órbita Kids](https://github.com/ObedGuzmanGuz/Orbita_Kids)

---

Los sketches y wireframes son una referencia viva del proyecto: pueden
evolucionar a medida que se validen las necesidades de los usuarios y se
incorporen nuevas funcionalidades a Órbita Kids.