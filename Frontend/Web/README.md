<div align="center">

<img align="left" src="../../Logos/Studio_Blamco.jpg" width="90" alt="Órbita Studio"/>
<img align="right" src="../../Logos/Kid_Blanco.jpg" width="80" alt="Órbita Kids"/>

<br>

# 🪐 ` Ó R B I T A · K I D S ` 🚀

### ✨ EXPERIENCIAS QUE CONECTAN A CADA COMUNIDAD ✨

# 🌐 FRONTEND · APLICACIÓN WEB

**PWA EDUCATIVA · DOCENTES E INSTITUCIONES**

<br>

<img src="https://img.shields.io/badge/REACT-61DAFB?style=for-the-badge&logo=react&logoColor=20232A" />
<img src="https://img.shields.io/badge/VITE-646CFF?style=for-the-badge&logo=vite&logoColor=white" />
<img src="https://img.shields.io/badge/JAVASCRIPT-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black" />
<img src="https://img.shields.io/badge/KEYCLOAK-4D4D4D?style=for-the-badge&logo=keycloak&logoColor=white" />
<img src="https://img.shields.io/badge/PWA-5A0FC8?style=for-the-badge&logo=pwa&logoColor=white" />
<img src="https://img.shields.io/badge/MERMAID-FF3670?style=for-the-badge&logo=mermaid&logoColor=white" />

<br><br>

### 🌍 CONECTA · ACOMPAÑA · CRECE

---

</div>

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
