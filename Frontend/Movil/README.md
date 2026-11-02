<div align="center">

<img align="left" src="../../Logos/Studio_Blamco.jpg" width="90" alt="Órbita Studio"/>
<img align="right" src="../../Logos/Kid_Blanco.jpg" width="80" alt="Órbita Kids"/>

<br>

# 🪐 ` Ó R B I T A · K I D S ` 🚀

### ✨ EXPERIENCIAS QUE ACOMPAÑAN CADA DESCUBRIMIENTO ✨

# 📱 FRONTEND · APLICACIÓN MÓVIL

**ENTREGABLES INTERACTIVOS · EXPERIENCIA DEL ESTUDIANTE**

<br>

<img src="https://img.shields.io/badge/FLUTTER-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/DART-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/KEYCLOAK-4D4D4D?style=for-the-badge&logo=keycloak&logoColor=white" />
<img src="https://img.shields.io/badge/OFFLINE--FIRST-7254B8?style=for-the-badge" />
<img src="https://img.shields.io/badge/MERMAID-FF3670?style=for-the-badge&logo=mermaid&logoColor=white" />

<br><br>

### 🚀 JUEGA · APRENDE · AVANZA

---

</div>

| Carpeta | Contenido | Archivos |
|---|---|---|
| [`sketches/`](sketches/README.md) | Bocetos de baja fidelidad a lápiz, uno por pantalla y estado | 130 PNG |
| [`wireframes/`](wireframes/README.md) | Wireframes con rejilla, medidas en dp y acciones numeradas | 130 PNG + 130 SVG |
| [`prototipo/`](prototipo/README.md) | Prototipo interactivo en HTML y capturas de alta fidelidad | 1 HTML + 130 PNG |
| [`diagrama_de_secuencia/`](diagrama_de_secuencia/README.md) | Diagramas de secuencia UML: 1 diagrama general y 7 de detalle | SVG, PNG y Mermaid |

## Cifras

- **60 pantallas** y **130 estados** (cada estado que provoca una acción tiene su propio sketch, wireframe y captura).
- **928 acciones** numeradas en total.
- **Diagramas de secuencia:** 1 diagrama general y 7 de detalle, con **178 mensajes**.

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
