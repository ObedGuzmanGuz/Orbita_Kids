# Dashboard Gantt · Órbita Kids

Dashboard estático e interactivo para consultar la planificación del proyecto, el equipo y el historial real de GitHub. Está hecho con HTML, CSS y JavaScript nativos, sin instalar bibliotecas ni necesitar un servidor de aplicación.

## Abrir localmente

Como el navegador debe cargar los archivos JSON locales, utiliza un servidor estático desde la raíz del repositorio:

```powershell
cd Documentacion/Diagrama_Gantt
python -m http.server 8000
```

Después abre <http://localhost:8000>. También puede servirse con cualquier servidor estático. Abrir `index.html` directamente con `file://` no funciona porque `fetch` no puede leer los datos JSON locales en ese modo.

## Publicar en GitHub Pages

El módulo usa enlaces relativos y no requiere build:

1. En GitHub, abre **Settings → Pages** del repositorio.
2. Selecciona la rama de publicación y **Deploy from a branch**.
3. Si publicas desde la raíz de `main`, la página queda en `/Documentacion/Diagrama_Gantt/`.
4. Si publicas desde una carpeta de documentación distinta, conserva `Documentacion/Diagrama_Gantt/` dentro del árbol publicado y verifica que `../../Logos/Logo_Aplicacion.png` siga accesible.

La marca reutiliza el logo y la paleta oficiales del repositorio, copiados dentro de `assets/` para que la carpeta sea publicable por separado. Los diagramas de arquitectura, roles y Service Workflow quedan intactos. El Dashboard Workflow existente es una referencia interna de navegación y presentación interactiva; este Gantt sigue siendo un módulo independiente.

## Vistas e interacciones

- **Resumen:** indicadores, Gantt resumido, commits recientes e integrantes.
- **Cronograma Gantt:** 10 fases, escala por día/semana/mes, filtros por responsable y estado, semana y fecha actuales, dependencias visibles y modal de actividad.
- **Actividades:** búsqueda, responsables, fechas y progreso estimado.
- **Equipo:** cinco integrantes, carga asignada, promedio estimado y commits asociados.
- **Historial de GitHub:** búsqueda y filtros por rama, integrante y periodo; enlaces a cada SHA.
- **Reportes:** estados y carga planificados, commits por integrante y mes, y avance estimado por fase.

La interfaz no tiene botones de actualización en vivo. El snapshot de GitHub se guarda en `data/github-snapshot.json` y muestra su fecha de consulta.

## Iteración visual y retratos

La interfaz conserva el logo y la paleta oficial, con una capa espacial discreta, gradientes por estado, profundidad en paneles y animaciones escalonadas para indicadores, Gantt, dependencias, gráficas y tarjetas. Se respeta `prefers-reduced-motion`.

Las fotos reales del equipo se optimizaron como JPEG cuadrado de 384 × 384 y se utilizan en el sidebar, resumen, Gantt, modal, equipo, commits y reportes:

| Integrante | Archivo |
|---|---|
| Yazmin Gutierrez Hernandez | `assets/perfiles/yazmin.jpg` |
| Michelle Castro Otero | `assets/perfiles/michelle.jpg` |
| Obed Guzmán Flores | `assets/perfiles/obed.jpg` |
| Citlalli Pérez Dionicio | `assets/perfiles/citlalli.jpg` |
| Jennifer Bautista Barrios | `assets/perfiles/jennifer.jpg` |

Los retratos fuente se conservaron en `assets/`. `Clitalli.png` contenía la foto de Citlalli dentro de una captura de visor; el JPEG de perfil es un recorte de esa foto. Si falta una imagen, la interfaz muestra las iniciales como respaldo.

Las referencias visuales disponibles en esta carpeta son `assets/Gantt.png` y `assets/mecagest.png`; ambas se conservaron. El segundo archivo no tiene el nombre `image.png` en esta copia del repositorio.

## Datos y criterio de lectura

| Tipo | Archivo/origen | Uso |
|---|---|---|
| Planificación | `data/plan.json` | Periodo, fechas, responsables, estados base, dependencias y 10 actividades. |
| Estimación | Campo `progress` de `data/plan.json` | Porcentajes iniciales visuales; no se derivan del número de commits ni son mediciones verificadas. |
| GitHub real | `data/github-snapshot.json` | Ramas, SHA, autor de commit, fecha, mensaje y enlaces consultados en la API pública. |

Los estados y porcentajes del cronograma son la estimación inicial solicitada. Las fechas de inicio y fin son las de la planificación aprobada, no registros de ejecución. Un commit evidencia actividad en Git; no demuestra que una fase esté terminada.

## Snapshot de GitHub

Consulta realizada el **2 de noviembre de 2026 (hora de Ciudad de México)** mediante la API pública de GitHub, recorriendo el historial de cada rama consultada. El archivo contiene **6 ramas y 60 SHA únicos**, eliminando duplicados entre ramas. Autores observados tras asociar los nombres de commit con el equipo:

| Integrante | Commits en el snapshot |
|---|---:|
| Obed Guzmán Flores | 27 |
| Yazmin Gutierrez Hernandez | 19 |
| Michelle Castro Otero (`Ktmich2095`) | 11 |
| Citlalli Pérez Dionicio | 1 |
| Jennifer Bautista Barrios | 2 |

La API devolvió dos commits recientes de Jennifer en `fix/documentacion`. La asociación de `Ktmich2095` con Michelle corresponde a la identidad de autor que ya aparecía en el historial consultado del repositorio. La suma por integrante equivale a los SHA únicos del snapshot. El conjunto describe las seis ramas y hasta 100 commits por rama consultados en la fecha de captura; si el repositorio crece más allá de esa ventana, el script necesita paginación adicional.

Para actualizar el snapshot manualmente desde PowerShell:

```powershell
cd Documentacion/Diagrama_Gantt
powershell -ExecutionPolicy Bypass -File .\data\update-github.ps1
```

El script consulta únicamente datos públicos, no utiliza tokens y reemplaza `data/github-snapshot.json` con una nueva captura deduplicada. Comprueba los cambios antes de publicarlos. Las cifras se actualizarán cuando vuelvas a ejecutar el script; la página no se sincroniza sola.

## Estado del proyecto y tecnologías

La documentación del repositorio describe una solución prevista con **Flutter/Dart** para la aplicación móvil, **React** para la PWA docente, **FastAPI/Python** para la API y **MySQL** para persistencia. Las ramas consultadas aportan evidencia de trabajo en sketches/wireframes, diagramas, documentación y el Service Workflow. Las tecnologías de la solución siguen documentadas como propuesta; su presencia en el dashboard no afirma que ya estén desplegadas o integradas.

El dashboard utiliza HTML/CSS/JavaScript y CSS/SVG nativo para diagramas y gráficas. La única dependencia externa opcional es Google Fonts (`DM Sans` y `Space Grotesk`); con conexión restringida se usarán fuentes de sistema. No hay paquetes ni dependencias de runtime.

## Estructura

```text
Documentacion/Diagrama_Gantt/
├── assets/                     # Logo, paleta, referencias visuales y retratos fuente
│   └── perfiles/               # JPEG optimizados, referenciados por data/plan.json
├── data/
│   ├── plan.json               # Cronograma aprobado y estimaciones iniciales
│   ├── github-snapshot.json    # Captura consultada de ramas y commits
│   └── update-github.ps1       # Actualizador del snapshot, sin token
├── index.html
├── script.js
├── styles.css
└── README.md
```
