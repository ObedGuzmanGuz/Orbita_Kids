# Órbita Kids · Sketches interactivos

## Contenido
- 80 sketches en blanco y negro: 20 móviles y 20 Web/PWA del Estudiante, y 20 móviles y 20 Web/PWA del Profesor.
- `index.html`: interfaz de tres columnas con roles principales y dos vistas desplegadas por rol.
- `app.js`, `styles.css`, `catalogo.js`, `catalogo.json` y `assets/`: aplicación navegable sin servicios externos.

## Uso
1. Extrae todo el contenido de `Sketches.zip`.
2. Abre `Sketches/index.html` en Chrome o Edge, sin moverlo fuera de la carpeta.
3. Selecciona el **rol** (Estudiante / Profesor) y luego una de sus **vistas** (App móvil / Web/PWA).
4. Selecciona un sketch para consultar la vista central y las acciones; pulsa sobre la imagen para abrir el modal con detalle y navegación anterior/siguiente.
5. Pulsa **Ver diagrama** para abrir por separado la secuencia UML con casos de uso, estrellas, actores, flechas y reproducción paso a paso. Ciérrala para volver a los sketches.

También se incluye `Sketches_Vista_Previa.html` por separado: permite abrir directamente una versión autónoma con imágenes integradas.

Nota: las acciones representan el comportamiento esperado de un prototipo conceptual, no un backend funcional.

## Búsqueda mejorada
- Buscar por título, descripción, categorías, palabras clave y acciones.
- Ignora mayúsculas, tildes y reconoce variaciones comunes.
- La vista central cambia al primer resultado relevante.
- `Enter` selecciona el primer resultado, flechas arriba/abajo recorren coincidencias, `Esc` limpia, `/` enfoca el buscador.
- La búsqueda respeta el rol y la plataforma elegidos.
