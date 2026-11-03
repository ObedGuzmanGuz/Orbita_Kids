# Documentación de Orbita Kids

Esta carpeta reúne los documentos y materiales visuales que describen el proyecto **Orbita Kids**. Aquí se puede consultar cómo se plantea la arquitectura de la plataforma, qué roles de usuario contempla, cómo se bosqueja su interfaz y cuál es su modelo de negocio.

El contenido incluye documentos de análisis y propuestas, así como páginas HTML interactivas. La presencia de una tecnología o funcionalidad en estos materiales no significa necesariamente que ya esté implementada en la aplicación.

## Contenido

| Carpeta | Qué contiene |
| --- | --- |
| [`DiagramaDeArquitectura/`](DiagramaDeArquitectura/) | Documentación y diagrama de la arquitectura tecnológica propuesta: aplicaciones, API, servicios, datos e infraestructura. La imagen del diagrama se encuentra en `img/`. |
| [`DiagramaRolesUsuario/`](DiagramaRolesUsuario/) | Material de la práctica sobre los actores, roles y funciones de usuario. Incluye una versión visual interactiva en `index.html` y sus archivos de apoyo. |
| [`GUI/`](GUI/) | Material relacionado con la interfaz gráfica de usuario. Actualmente contiene [`Practica_Sketches/`](GUI/Practica_Sketches/), con la explicación de la práctica y sus bocetos en `img/`. |
| [`ModelBusinesCanvas/`](ModelBusinesCanvas/) | Business Model Canvas interactivo de Orbita Kids. Incluye `index.html`, estilos, JavaScript, ilustraciones y un README propio con contexto e instrucciones. |

## ¿Qué debe guardarse aquí?

Guarda en `Documentacion/` los materiales que expliquen, representen o respalden el diseño y la planeación del proyecto, por ejemplo:

- Diagramas de arquitectura, procesos, datos y roles.
- Requisitos, análisis, decisiones y propuestas de diseño.
- Bocetos, wireframes y recursos visuales de la interfaz.
- Modelos de negocio y entregables de prácticas relacionados con el proyecto.
- Instrucciones para consultar documentos o demostraciones interactivas.

Mantén cada tema en su propia subcarpeta. Conserva juntos los archivos que una página necesite para funcionar —por ejemplo, HTML, CSS, JavaScript e imágenes— y agrega un `README.md` en cada sección cuando haga falta explicar su propósito, contenido o forma de consulta. Evita guardar aquí código fuente de la aplicación que pertenezca a las carpetas de desarrollo del proyecto.

## Cómo consultar el contenido

- Los archivos Markdown (`.md`) pueden leerse directamente en GitHub o en un editor de texto.
- Para explorar los materiales interactivos, abre el `index.html` de la carpeta correspondiente en un navegador. Mantén sus carpetas de recursos junto al archivo HTML para que carguen estilos, scripts e imágenes.
- Consulta el README de cada subcarpeta para conocer detalles específicos de ese material.

## Organización actual

```text
Documentacion/
├── DiagramaDeArquitectura/
│   ├── img/
│   └── readme.md
├── DiagramaRolesUsuario/
│   ├── index.html
│   └── archivos de apoyo del diagrama
├── GUI/
│   └── Practica_Sketches/
│       ├── img/
│       └── readme.md
├── ModelBusinesCanvas/
│   ├── assets/
│   ├── css/
│   ├── js/
│   ├── index.html
│   └── README.md
└── readme.md
```

> Algunas carpetas conservan nombres establecidos en entregas anteriores. Si se renombran, hay que actualizar también los enlaces a esas rutas.
