# Órbita Kids · Frontend móvil

App móvil educativa de matemáticas para primaria (Flutter · Keycloak · offline first). Esta carpeta reúne los cuatro entregables de la app móvil, todos generados a partir del mismo prototipo para que coincidan entre sí.

| Carpeta | Contenido | Archivos |
|---|---|---|
| [`sketches/`](sketches/README.md) | Bocetos de baja fidelidad a lápiz, uno por pantalla y estado | 130 PNG |
| [`wireframes/`](wireframes/README.md) | Wireframes con rejilla, medidas en dp y acciones numeradas | 130 PNG + 130 SVG |
| [`prototipo/`](prototipo/README.md) | Prototipo interactivo en HTML y capturas de alta fidelidad | 1 HTML + 130 PNG |
| [`diagrama_de_secuencia/`](diagrama_de_secuencia/README.md) | 7 diagramas de secuencia UML de los flujos principales | SVG, PNG y Mermaid |

## Cifras

- **60 pantallas** y **130 estados** (cada estado que provoca una acción tiene su propio sketch, wireframe y captura).
- **928 acciones** numeradas en total.
- **7 diagramas de secuencia** con **138 mensajes**.

## Cómo se relacionan los archivos

Los tres primeros entregables usan **el mismo número y el mismo nombre de archivo** para cada estado, así que es fácil compararlos:

```
sketches/04_estudiante/059_15a_home-estudiante_inicio-con-mision-actual.png
wireframes/04_estudiante/059_15a_home-estudiante_inicio-con-mision-actual.png
prototipo/capturas/04_estudiante/059_15a_home-estudiante_inicio-con-mision-actual.png
```

El nombre se lee así: `orden_código-de-pantalla_pantalla_estado`. El código (por ejemplo `15a`) es el de la ficha de la pantalla en el prototipo; la letra distingue los estados de una misma pantalla.

## Estructura

```
Frontend/Movil/
├── README.md
├── sketches/
│   ├── README.md
│   └── <sección>/NNN_código_pantalla_estado.png
├── wireframes/
│   ├── README.md
│   └── <sección>/NNN_….png  +  <sección>/svg/NNN_….svg
├── prototipo/
│   ├── README.md
│   ├── Órbita_Kids_Prototipo.html
│   └── capturas/<sección>/NNN_….png
└── diagrama_de_secuencia/
    ├── README.md
    ├── png/   (claro y oscuro)
    ├── svg/   (claro y oscuro)
    └── mermaid/  (código editable .mmd)
```

## Nota

Es un prototipo académico: no se conecta a Keycloak, Google, Facebook ni al backend reales. Los datos son de demostración.
