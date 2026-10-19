# Órbita Kids · Wireframes con medidas

## Contenido
- **80 wireframes en blanco y negro con cotas**: 20 móviles y 20 Web/PWA del Estudiante, y 20 móviles y 20 Web/PWA del Profesor.
  - Móvil → **Flutter**, lienzo base **375 × 812 dp** (barra de estado 44 · AppBar 56 · contenido 648 · NavigationBar 64; padding 16, gap 12, radio 12, botón h48).
  - Web/PWA → **React + Vite**, lienzo base **1280 × 800 px** (Header 80 · Sidebar 260 · Main 1020 con padding 24 → útil 972; grilla 12 col de 59 px, gap 24, radio 12, botón 120 × 48).
- `assets/wireframes/{Rol}/{Plataforma}/NN_nombre.png` y `.svg` (el SVG es vectorial y editable).
- `assets/` conserva los **sketches originales**; se pueden comparar con el botón "Sketch original".
- `assets/VISTA_GENERAL_*.jpg`: 4 vistas generales regeneradas con los wireframes.
- `index.html`, `app.js`, `styles.css`, `catalogo.js`, `catalogo.json`: aplicación navegable (sin servicios externos), actualizada.
- `tools/`: generador de wireframes en Python (ver abajo).

## Cómo leer las cotas
- Líneas con flechas = medidas del marco y de cada bloque (izquierda en móvil, derecha en web).
- Texto gris pequeño dentro de cada componente = `ancho×alto` (solo del primer elemento si se repite).
- Pie de cada imagen = tokens (padding, gap, radio, tamaño de botón).
- Si el contenido supera el área útil, se indica "el contenido continúa (scroll)" con su altura total.

## Uso
1. Extrae todo el contenido del zip y abre `index.html` en Chrome o Edge, sin moverlo de la carpeta.
2. Elige **rol** y **vista** (App móvil / Web-PWA), luego una pantalla.
3. Alterna **Wireframe + medidas / Sketch original** sobre la imagen central. El panel derecho y el modal muestran la tabla de **medidas y componentes** con el widget sugerido (React o Flutter).
4. **Ver diagrama**: secuencia UML actualizada. El actor de la app refleja la tecnología (`App Flutter` / `PWA React + Vite`) y cada paso muestra el wireframe y sus medidas.

## Regenerar los wireframes
```
pip install cairosvg
cd tools && python3 build.py          # reescribe assets/wireframes/*
```
Edita `tools/specs.py` (contenido de cada pantalla) y vuelve a ejecutar. Después de cambiar medidas, actualiza `catalogo.js/json` con `tools/out.json`.

Nota: las acciones representan el comportamiento esperado de un prototipo conceptual, no un backend funcional.
