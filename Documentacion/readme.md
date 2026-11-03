 <div align="center">

# 🚀 ÓRBITA KIDS
### Centro de documentación

**Diseño, planeación y materiales de consulta del proyecto educativo.**

[🏗️ Arquitectura](#-diagrama-de-arquitectura) · [👥 Roles](#-diagrama-de-roles-de-usuario) · [🎨 Interfaz](#-gui-y-práctica-de-sketches) · [💼 Modelo de negocio](#-business-model-canvas)

---

</div>

## 🌌 1. Acerca de esta documentación

La carpeta `Documentacion/` reúne los principales entregables que permiten comprender la estructura, el diseño y la planeación de **Órbita Kids**, una propuesta educativa enfocada en el aprendizaje de matemáticas mediante una experiencia interactiva.

Aquí se encuentran los diagramas técnicos, la definición de roles, los diseños preliminares de las interfaces y el modelo de negocio.

**El objetivo es mantener organizada la información del proyecto y facilitar su consulta** por parte del equipo de desarrollo, docentes y personas interesadas.

## 🧭 2. Índice de contenidos

| Sección | Descripción | Ubicación |
|---|---|---|
| 🏗️ Arquitectura | Organización técnica y componentes del sistema. | `DiagramaDeArquitectura/` |
| 👥 Roles de usuario | Actores, responsabilidades y funcionalidades. | `DiagramaRolesUsuario/` |
| 🎨 GUI y Sketches | Diseños de interfaces y navegación. | `GUI/Practica_Sketches/` |
| 💼 Business Model Canvas | Propuesta y estructura del modelo de negocio. | `ModelBusinesCanvas/` |

## 📁 3. Estructura del directorio

```text
Documentacion/
│
├── DiagramaDeArquitectura/
│   ├── img/
│   │   └── diagramaArquitectura.jpeg
│   └── readme.md
│
├── DiagramaRolesUsuario/
│   ├── index.html
│   ├── practica-05-roles.architecture.json
│   ├── practica-05-roles.visual-check.html
│   ├── practica-05-roles.visual-check.json
│   ├── practica-05.css
│   ├── practica-05.js
│   └── readme.md
│
├── GUI/
│   └── Practica_Sketches/
│       ├── img/
│       │   ├── 1.png
│       │   ├── 2.png
│       │   ├── 3.png
│       │   └── 4.png
│       └── readme.md
│
├── ModelBusinesCanvas/
│   ├── assets/
│   │   ├── imagenes/
│   │   ├── ILUSTRACIONES.md
│   │   └── orbita.svg
│   ├── css/
│   │   └── styles.css
│   ├── js/
│   │   └── app.js
│   ├── index.html
│   └── README.md
│
└── readme.md
```

---

## 🏗️ 4. Diagrama de arquitectura

**Ubicación:** `DiagramaDeArquitectura/`

**Recursos:**
- [📂 Consultar carpeta](DiagramaDeArquitectura/)
- [📄 Leer documentación](DiagramaDeArquitectura/readme.md)
- [🖼️ Visualizar diagrama](DiagramaDeArquitectura/img/diagramaArquitectura.jpeg)

Esta sección presenta la arquitectura técnica propuesta para Órbita Kids y la relación entre sus principales componentes.

### Componentes tecnológicos

| Componente | Tecnología propuesta | Función |
|---|---|---|
| Aplicación móvil | Flutter y Dart | Interfaz para estudiantes. |
| Aplicación web | React | Plataforma para docentes. |
| Backend | FastAPI y Python | Procesamiento de solicitudes y lógica del sistema. |
| Base de datos | Base de datos relacional | Almacenamiento de información. |
| API | API REST | Comunicación entre aplicaciones y servidor. |

También se documentan aspectos como autenticación, despliegue mediante contenedores, almacenamiento y monitoreo.

> **Nota:** El diagrama representa la arquitectura propuesta del proyecto. Su presencia en esta documentación no implica que todos sus componentes estén implementados o integrados.

---

## 👥 5. Diagrama de roles de usuario

**Ubicación:** `DiagramaRolesUsuario/`

**Recursos:**
- [📂 Consultar carpeta](DiagramaRolesUsuario/)
- [🌐 Abrir diagrama interactivo](DiagramaRolesUsuario/index.html)
- [📄 Leer documentación](DiagramaRolesUsuario/readme.md)

Este entregable identifica los actores que participan en Órbita Kids, sus responsabilidades y las funcionalidades relacionadas con cada perfil.

### Roles identificados

| Rol | Responsabilidades |
|---|---|
| 🎓 Estudiante | Resolver actividades, completar misiones y consultar su progreso. |
| 👩‍🏫 Docente | Organizar grupos, asignar actividades y revisar resultados. |
| 🏫 Escuela | Participar en la adopción, demostraciones y posibles pilotos institucionales. |

### Archivos principales

| Archivo | Descripción |
|---|---|
| `index.html` | Página principal del diagrama. |
| `practica-05.css` | Estilos visuales. |
| `practica-05.js` | Funcionalidad e interacciones. |
| `practica-05-roles.architecture.json` | Información estructurada de arquitectura. |
| `practica-05-roles.visual-check.html` | Herramienta auxiliar de revisión visual. |
| `practica-05-roles.visual-check.json` | Datos de revisión visual. |
| `readme.md` | Descripción y documentación de la práctica. |

**Importante:** Los archivos HTML, CSS, JavaScript y JSON deben conservarse juntos para mantener el funcionamiento de la visualización.

---

## 🎨 6. GUI y práctica de sketches

**Ubicación:** `GUI/Practica_Sketches/`

**Recursos:**
- [📂 Consultar carpeta](GUI/Practica_Sketches/)
- [📄 Leer documentación](GUI/Practica_Sketches/readme.md)
- [🎨 Consultar diseños en Figma](https://www.figma.com/design/NJvpRMCpqT1MHrAjRdWY9k/Orbita-Kids?node-id=8-6746&t=Bh7RA2nB0fxz8pHn-1)

Esta sección contiene los bocetos iniciales de las interfaces de Órbita Kids. Se consideran dos entornos principales: la aplicación móvil para estudiantes y la PWA destinada a docentes.

### Evidencias de diseño

| Archivo | Descripción |
|---|---|
| `img/1.png` | Primer sketch de la aplicación estudiantil. |
| `img/2.png` | Segundo sketch de la aplicación estudiantil. |
| `img/3.png` | Primer sketch de la PWA docente. |
| `img/4.png` | Segundo sketch de la PWA docente. |

La documentación complementa los diseños con:

- Mapas de navegación.
- Descripción de pantallas.
- Diagramas de secuencia.
- Relación entre las interfaces y la API.
- Alcances de la propuesta de diseño.

> **Nota:** Los sketches representan una propuesta visual y funcional preliminar. No deben confundirse con pantallas finales de una aplicación completamente implementada.

---

## 💼 7. Business Model Canvas

**Ubicación:** `ModelBusinesCanvas/`

**Recursos:**
- [📂 Consultar carpeta](ModelBusinesCanvas/)
- [🌐 Abrir presentación interactiva](ModelBusinesCanvas/index.html)
- [📄 Leer documentación](ModelBusinesCanvas/README.md)
- [🚀 Consultar publicación en GitHub Pages](https://obedguzmanguz.github.io/Orbita_Kids/Documentacion/ModelBusinesCanvas/)

Este apartado presenta el modelo de negocio de Órbita Kids mediante una página web interactiva que desarrolla los nueve bloques del Business Model Canvas.

### Contenido del modelo

Se describen los siguientes elementos:

1. Segmentos de clientes.
2. Propuesta de valor.
3. Canales de distribución.
4. Relaciones con los clientes.
5. Fuentes de ingresos.
6. Recursos clave.
7. Actividades clave.
8. Socios clave.
9. Estructura de costos.

### Recursos del sitio web

| Archivo o carpeta | Función |
|---|---|
| `index.html` | Estructura y contenido de la página. |
| `css/styles.css` | Diseño visual y adaptación de pantalla. |
| `js/app.js` | Navegación e interacciones. |
| `assets/orbita.svg` | Recurso gráfico del proyecto. |
| `assets/imagenes/` | Ilustraciones utilizadas en el Canvas y ODS 4. |
| `assets/ILUSTRACIONES.md` | Descripción y procedencia de las ilustraciones. |
| `README.md` | Explicación del modelo e instrucciones de consulta. |

### Relación con el ODS 4

El modelo también contempla la relación de Órbita Kids con el **Objetivo de Desarrollo Sostenible 4: Educación de calidad**, mediante una propuesta orientada al aprendizaje inclusivo y al fortalecimiento de las habilidades matemáticas.

> **Nota:** El Canvas representa una propuesta de modelo de negocio y sus hipótesis. No constituye evidencia de ingresos, alianzas o resultados educativos ya validados.

---

## 📚 8. Organización y consulta de materiales

Para facilitar el uso de esta documentación, se recomienda seguir estas indicaciones:

| Tipo de recurso | Cómo consultarlo |
|---|---|
| Archivos Markdown | Abrir los archivos `.md` desde GitHub o un editor de texto. |
| Diagramas interactivos | Abrir el archivo `index.html` en un navegador. |
| Imágenes | Consultar las carpetas `img/` y `assets/imagenes/`. |
| Diseños de interfaz | Acceder al enlace de Figma. |
| Presentaciones web | Abrir el archivo HTML correspondiente. |

### Recomendaciones de mantenimiento

- Mantener una carpeta independiente para cada entregable.
- Incluir un README cuando una sección necesite explicación adicional.
- Conservar las rutas relativas de imágenes, estilos y scripts.
- Utilizar nombres claros y consistentes.
- Actualizar los enlaces cuando se cambien nombres o ubicaciones.
- Diferenciar entre propuestas, prototipos y funcionalidades implementadas.
- Mantener actualizado el índice y la estructura general.

---

<div align="center">

## ✨ ÓRBITA KIDS

**Aprender matemáticas explorando el espacio.** 🚀

*Documentación del proyecto educativo.*

</div>