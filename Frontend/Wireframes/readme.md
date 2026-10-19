# Órbita Kids · Wireframes con medidas

## Contenido
- **80 wireframes con cotas exhaustivas**: 20 móviles y 20 Web/PWA del Estudiante, y 20 móviles y 20 Web/PWA del Profesor. Cada caja, círculo, icono, botón, tarjeta, texto, padding y separación lleva su medida.
  - Móvil → **Flutter**, unidades en **píxeles lógicos (lp = dp)**. Lienzo base **375 × 812 lp** (SafeArea 44 · AppBar 56 · cuerpo 648 · NavigationBar 64; padding 16, gap 12, radio 12, botón h48).
  - Web/PWA → **React + Vite**, unidades en **px CSS → rem (÷16)**. Lienzo base **1280 × 800 px** (Header 80 · Sidebar 260 · Main 1020 con padding 24 → útil 972; grid 12 col de 59 px, gutter 24; radio 12; botón h48).
- `assets/wireframes/{Rol}/{Plataforma}/NN_nombre.png` y `.svg` → wireframe **con medidas** (SVG vectorial y editable).
- `assets/wireframes/{Rol}/{Plataforma}/limpio/NN_nombre.png` → el mismo wireframe **sin medidas**.
- `assets/VISTA_GENERAL_*.jpg`: 4 hojas de contacto con los wireframes con medidas.
- `medidas.html`: **especificación organizada** — unidades, layout base, tokens, escala tipográfica y tabla de todos los elementos de cada pantalla con código CSS (rem) o Flutter.
- `medidas.csv`: todas las medidas en una tabla (rol, pantalla, bloque, elemento, x, y, ancho, alto, radio, padding, tipografía, unidad).
- `tokens/tokens.css`, `tokens/tokens.ts` (React + Vite / Tailwind) y `tokens/app_tokens.dart` (Flutter).
- `index.html`, `app.js`, `styles.css`, `catalogo.js/json`, `medidas.js`: aplicación navegable sin servicios externos.
- `tools/`: generador en Python (ver abajo).

## Cómo leer las cotas
- **Negro, fuera del marco**: lienzo, regiones y alto de cada bloque (en web también en rem).
- **Rojo**: medida de cada elemento.
  - `W×H rN` = ancho × alto y radio · `Ø` = diámetro · `□24` = icono de 24 · `×N` = elemento repetido idéntico (se acota el primero).
  - Flechas rojas cortas = **padding** interno (izquierda/arriba; derecha/abajo solo si difieren) y **separaciones** (gap) entre hermanos y entre bloques.
  - `Aa13/18 B` = font-size 13 / line-height 18 / peso 700.
- Anchos con decimales (127.43, 165.5…) son fracciones del contenedor: `1fr` / `flex: 1` en web, `Expanded` en Flutter.
- Pie de cada imagen = unidades de la plataforma, tokens y leyenda.

## Uso
1. Extrae el zip y abre `index.html` en Chrome o Edge, sin moverlo de la carpeta.
2. Elige **rol** y **vista** (App móvil / Web-PWA) y una pantalla.
3. Alterna **Con medidas / Sin medidas**. El panel derecho resume bloques y unidades; el modal muestra **todos los elementos** con su código; el enlace «Ver todas las medidas» abre `medidas.html` en esa pantalla.
4. **Ver diagrama**: secuencia UML; cada paso muestra el wireframe y sus medidas.

## Regenerar
```
pip install cairosvg pillow
cd tools
python3 build.py          # reescribe assets/wireframes/* (con y sin medidas) y out.json
python3 export_specs.py   # catalogo.js/json, medidas.js, medidas.csv, tokens/
python3 overview.py       # assets/VISTA_GENERAL_*.jpg
```
- `tools/specs.py` = contenido de cada pantalla · `tools/blocks.py` = geometría y tokens de cada componente · `tools/frames.py` = marco (AppBar, NavigationBar, Header, Sidebar), cotas y leyenda.

Nota: las acciones representan el comportamiento esperado de un prototipo conceptual, no un backend funcional.
