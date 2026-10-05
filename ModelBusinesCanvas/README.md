# 🪐 Práctica 04 — Business Model Canvas de Órbita Kids

## 🎯 Objetivo de la práctica

Analizar el **modelo de negocio y funcionamiento general de Órbita Kids** mediante un **Business Model Canvas interactivo**, identificando sus elementos principales, propuesta de valor, usuarios, recursos, actividades y posibles fuentes de ingresos.

---

## 🚀 Proyecto analizado

**Órbita Kids** es una plataforma educativa propuesta para reforzar el aprendizaje de matemáticas en niños de los primeros grados de primaria.

La experiencia utiliza una temática de **exploración espacial**, donde los estudiantes avanzan por distintos niveles mientras resuelven actividades matemáticas.

La primera versión del proyecto se enfoca principalmente en:

- ➕ Sumas.
- 🪐 Tres niveles de dificultad.
- 🧩 Dos tipos de actividades.
- 📈 Seguimiento del progreso.
- 🧠 Adaptación básica de ejercicios según el desempeño del estudiante.

Los docentes podrán acompañar el progreso mediante una **PWA**, donde podrán administrar grupos, asignar actividades y consultar las áreas que necesitan mayor refuerzo.

---

## 🧩 ¿Qué contiene la práctica?

La práctica desarrolla los **nueve bloques del Business Model Canvas**:

1. 👥 Segmentos de clientes.
2. 💡 Propuesta de valor.
3. 📢 Canales.
4. 🤝 Relaciones con clientes.
5. 💰 Fuentes de ingresos.
6. 🧰 Recursos clave.
7. ⚙️ Actividades clave.
8. 🔗 Socios clave.
9. 💸 Estructura de costos.

Cada tarjeta incluye una **ilustración original relacionada con su tema**. Al abrirla, **Aplicación en Órbita Kids** ocupa un cuadro destacado de ancho completo, con un resumen y una lista que especifica qué engloba ese bloque en el proyecto. Su imagen queda junto a la lista en escritorio. **¿Qué significa este bloque?** aparece debajo, en una sección independiente.

Cada bloque conserva:

- 📘 Significado del bloque.
- 📋 Información que debe contener.
- ❓ Preguntas guía.
- 🪐 Aplicación en Órbita Kids.
- 💡 Ejemplo sencillo.
- 🔄 Relación con otros bloques.

> Las fuentes de ingresos, socios y algunos elementos del modelo representan **hipótesis de negocio por validar**. Actualmente no se consideran convenios, ventas o alianzas confirmadas.

---

## 💻 Desarrollo

El Canvas fue desarrollado como una **interfaz web interactiva y adaptable**, utilizando tarjetas para representar cada uno de los nueve bloques.

Al seleccionar una tarjeta se abre una ficha con secciones separadas: aplicación concreta al proyecto e imagen, significado del bloque, ejemplo y conexiones. La cabecera y los botones permanecen accesibles mientras se desplaza el contenido. En móvil, la información se acomoda en una sola columna.

Entre sus principales características se encuentran:

- 🖱️ Tarjetas seleccionables.
- 🪟 Fichas con secciones independientes que evitan la superposición al desplazarse.
- 🖼️ Nueve ilustraciones locales, una por bloque, visibles también dentro de cada ficha.
- 🪐 Aplicación en Órbita Kids destacada con mayor tamaño, contraste y un ejemplo.
- 🌎 ODS 4 desplegable con ilustración propia y relación con el proyecto.
- 👥 Sección de integrantes del equipo.
- 🪐 Planeta giratorio y satélites en órbita; los textos permanecen quietos.
- ✨ Una estela luminosa suave recorre el borde del Canvas y de cada tarjeta, siguiendo su color.
- ⏸️ Botón para pausar o reanudar los efectos. Se respeta la preferencia del sistema de reducir movimiento.
- ⌨️ Navegación mediante teclado.
- ❌ Cierre del modal mediante botón.
- ⎋ Cierre utilizando la tecla **Escape**.
- 🖱️ Cierre al seleccionar el área exterior del modal.
- ↔️ Navegación entre diferentes fichas.
- ✅ Indicador de bloques consultados.
- 🖨️ Vista preparada para imprimir el resumen.
- 📱 Diseño adaptable para computadora, tablet y dispositivos móviles.

La práctica puede ejecutarse directamente desde:

[`index.html`](index.html)

No requiere instalación de dependencias. **Extrae primero todo el ZIP** y abre `Practica04/index.html`; no muevas el HTML fuera de su carpeta. La interfaz y sus imágenes funcionan sin conexión; los enlaces de referencia requieren internet.

La sección **ODS 4** se puede desplegar y contraer con un clic, **Enter** o **Espacio**. Las ilustraciones son conceptuales y no representan pantallas de la aplicación terminada.

Los datos académicos opcionales pueden modificarse en:

`js/app.js`

Dentro del objeto:

`datosAcademicos`

Si estos campos permanecen vacíos, no se muestran en la interfaz.

---

## 🛠️ Tecnologías utilizadas

![HTML5](https://img.shields.io/badge/HTML5-Structure-E34F26?logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-Styles-1572B6?logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-Interaction-F7DF1E?logo=javascript&logoColor=black)
![Git](https://img.shields.io/badge/Git-Version%20Control-F05032?logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Repository-181717?logo=github)
![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Deploy-222222?logo=githubpages)

El desarrollo fue apoyado mediante **Codex y Archify** para la organización, construcción y documentación de la práctica.

---

## 🌐 GitHub Pages

La versión publicada de la práctica puede consultarse aquí:

### 🚀 [Abrir Business Model Canvas de Órbita Kids](https://obedguzmanguz.github.io/Orbita_Kids/Practica04/)

La aplicación está preparada para funcionar mediante **GitHub Pages**, utilizando rutas relativas para sus archivos CSS, JavaScript y recursos.

> Si el enlace todavía no muestra la práctica, será necesario publicar primero la rama correspondiente desde la configuración de GitHub Pages.

---

## 📂 Estructura de la práctica

- `index.html`: estructura, ODS desplegable y equipo.
- `css/styles.css`: plantilla original, fichas, adaptación a móvil e impresión.
- `js/app.js`: nueve bloques, imágenes y navegación.
- `assets/orbita.svg`: identidad visual original.
- `assets/imagenes/`: diez imágenes PNG (nueve bloques y ODS 4).
- `assets/ILUSTRACIONES.md`: procedencia y prompts finales de las imágenes.
- `README.md`: instrucciones y documentación.

---

## 🌎 Relación con los ODS

Órbita Kids se relaciona principalmente con:

### 📘 ODS 4 — Educación de calidad

El proyecto busca utilizar herramientas digitales como apoyo para reforzar el aprendizaje de matemáticas en estudiantes de educación primaria.

🔗 [Consultar ODS 4 — Naciones Unidas](https://www.un.org/sustainabledevelopment/es/education/)

---

## 👥 Integrantes del equipo

- Obed Guzmán Flores
- Yazmin Gutierrez Hernandez
- Citlalli Perez Dionicio
- Michelle Castro Otero
- Jennifer Bautista Barrios

---

## 📚 Referencias

- 📊 [Business Model Canvas — Strategyzer](https://www.strategyzer.com/library/the-business-model-canvas)
- 🌎 [ODS 4 — Educación de calidad](https://www.un.org/sustainabledevelopment/es/education/)
- 📖 [Configuración de GitHub Pages](https://docs.github.com/es/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)

**Base conceptual:** septiembre de 2026. **Actualización visual y del equipo:** octubre de 2026.

---

<p align="center">
  🪐 <strong>Órbita Kids</strong><br>
  Business Model Canvas interactivo — Práctica 04
</p>

## Actualización de distribución y movimiento

La aplicación al proyecto enumera elementos específicos de cada bloque: públicos, funciones educativas, canales, acompañamiento, ingresos propuestos, recursos, actividades, socios potenciales y costos. Los precios y acuerdos se mantienen como propuestas por validar.

La zona desplazable de la ficha utiliza flujo normal. Las imágenes, explicaciones, ejemplos y conexiones tienen su propio espacio y no se superponen. Los bordes se animan con trazos SVG locales y el planeta con CSS; no hay dependencias externas.

Para reemplazar una versión previa, extrae el ZIP completo y sustituye la carpeta `Practica04`. Si tu navegador conserva los estilos anteriores, actualiza con **Ctrl + F5**.
