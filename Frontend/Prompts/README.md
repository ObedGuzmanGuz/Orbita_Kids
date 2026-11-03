# Órbita Kids · Prompts de creación

Prompts para reproducir los 3 archivos del proyecto con IA. Cada prompt está escrito para pegarse tal cual en la conversación, en el orden indicado, y trae su ficha con el modelo, los adjuntos y lo que debe salir.

## Modelo de IA

| Campo | Valor |
|---|---|
| Modelo | **Claude Opus 5.5 (Anthropic)** |
| Plataforma | claude.ai · chat con Artifacts (página HTML autocontenida publicada como artifact) |
| Formato de salida | Un solo archivo `.html` autocontenido por entregable (CSS y JS inline, imágenes en base64) |
| Idioma | Español de México |
| Librerías externas | rough.js 4.6.6 (sketches del móvil) y Google Fonts (Fredoka, Nunito, Caveat · Red Hat Display/Text/Mono) |

## Archivos y carpetas

| Archivo del proyecto | Carpeta de prompts | Prompts |
|---|---|---|
| `Órbita_Kids_Prototipo.html` | `01_App_movil_Prototipo/` | 00 maestro + 01 a 18 |
| `Órbita_Kids_Prototipo_1.html` | `01_App_movil_Prototipo/` | Es **idéntico byte por byte** al anterior (mismo MD5 `907b3421862d3ea59c48bd1b81a7c07e`), así que se genera con los mismos prompts |
| `Órbita_Kids_PWA_v3.html` | `02_PWA_Docentes_e_Instituciones_v3/` | 00 maestro + 01 a 12 |

## Cómo usarlos

Hay dos formas:

1. **Rápida:** pega el `00_PROMPT_MAESTRO.md` de cada carpeta (y adjunta los logos). Si el modelo corta por tamaño, pídele «continúa» y luego pega los prompts numerados que falten.
2. **Fiel al proceso real (recomendada para documentar):** pega los prompts 01, 02, 03… en orden en **la misma conversación**. Así se reproduce la evolución por versiones (arte v3 y v4, modo explorar v5, splash animado v6, rediseño «Observatorio» v3 de la PWA).

`TODOS_LOS_PROMPTS.md` reúne todos en un solo archivo y `bitacora_de_prompts.csv` es el índice en tabla (útil para el reporte).

## Nota

Los prompts se reconstruyeron a partir del contenido real de los archivos (pantallas, datos demostrativos, reglas, diagramas y comentarios de versión del código), de modo que el resultado coincida con lo entregado. Si en tu proyecto usaste otro modelo de Claude, cambia el campo «Modelo de IA» en cada ficha.
