# Órbita Kids · Frontend

Entregables de diseño del frontend de Órbita Kids, separados por plataforma. Las dos carpetas tienen la misma estructura.

```
Frontend/
├── README.md
├── Movil/                      App móvil Flutter (estudiante y docente)
│   ├── sketches/               130 sketches de baja fidelidad
│   ├── wireframes/             130 wireframes con medidas Flutter (PNG + SVG)
│   ├── prototipo/              Prototipo interactivo HTML + 130 capturas
│   └── diagrama_de_secuencia/  1 diagrama general + 7 de detalle (PNG, SVG y Mermaid)
└── Web/                        PWA para docentes e instituciones
    ├── sketches/               50 sketches de baja fidelidad
    ├── wireframes/             50 wireframes a 1280 px (PNG + SVG)
    ├── prototipo/              Órbita_Kids_PWA_v3.html + 53 capturas
    └── diagrama_de_secuencia/  4 diagramas (PNG, SVG y Mermaid)
```

| Plataforma | Para quién | Prototipo | Estado |
|---|---|---|---|
| [`Movil/`](Movil/README.md) | Estudiante (rol principal) y docente | `Movil/prototipo/Órbita_Kids_Prototipo.html` | Completo |
| [`Web/`](Web/README.md) | Docente e institución (dirección) | `Web/prototipo/Órbita_Kids_PWA_v3.html` | Completo |

Las dos plataformas comparten Keycloak (Authorization Code + PKCE) y la misma API; el diagrama general `Movil/diagrama_de_secuencia/` (SD-00) muestra cómo encajan.
