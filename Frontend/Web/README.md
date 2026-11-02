# Órbita Kids · Frontend web (PWA)

PWA para **docentes e instituciones**: sitio web público, acceso con Keycloak, app de escritorio instalable, espacio docente, panel de la institución, trabajo sin conexión y cuenta. El estudiante usa la app móvil (`../Movil/`).

| Carpeta | Contenido | Archivos |
|---|---|---|
| [`sketches/`](sketches/README.md) | Bocetos de baja fidelidad, uno por pantalla y estado | 50 PNG |
| [`wireframes/`](wireframes/README.md) | Wireframes a 1280 px con rejilla de 12 columnas y medidas en px CSS | 50 PNG + 50 SVG |
| [`prototipo/`](prototipo/README.md) | Prototipo interactivo `Órbita_Kids_PWA_v3.html` y capturas de cada estado | 1 HTML + 53 PNG |
| [`diagrama_de_secuencia/`](diagrama_de_secuencia/README.md) | 4 diagramas de secuencia de los flujos clave de la PWA | SVG, PNG y Mermaid |

## Cifras

- **35 pantallas** y **53 estados**, en 7 secciones.
- **644 acciones** numeradas en sketches y wireframes.
- **4 diagramas de secuencia** con **58 mensajes**.

Los sketches, los wireframes y las capturas usan el mismo nombre de archivo para cada estado (`orden_código_pantalla_estado`), igual que en `../Movil/`. Los estados 35a (Vista docente), 35b (Vista de dirección), 35c (Asignar sin conexión) de «Explorar sin cuenta» son una demostración dentro del sitio y solo tienen captura, no sketch ni wireframe (así viene en el prototipo).

## Estructura

```
Web/
├── README.md
├── sketches/<sección>/NNN_….png
├── wireframes/<sección>/NNN_….png  +  <sección>/svg/NNN_….svg
├── prototipo/
│   ├── Órbita_Kids_PWA_v3.html
│   └── capturas/<sección>/NNN_….png
└── diagrama_de_secuencia/
    ├── png/  ├── svg/  └── mermaid/
```
