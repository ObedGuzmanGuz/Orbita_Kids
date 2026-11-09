# 🪐 Modelo de datos — Órbita Kids

**Documentación de la base de datos de una propuesta educativa para reforzar las matemáticas en los primeros grados de primaria.**

## 🗄️ ¿Qué contiene esta carpeta?

Esta carpeta reúne todo lo necesario para entender, revisar y crear la base de datos de Órbita Kids:

- 📖 **Diccionario de datos:** describe cada tabla y cada campo del modelo.
- 🔗 **Diagrama entidad-relación (MER):** muestra cómo se relacionan las tablas.
- 🧾 **Script SQL:** crea la base de datos completa, con comentarios y restricciones.

## 📊 ¿Qué es un diccionario de datos?

Un **diccionario de datos** es un documento que describe la estructura de una base de datos. Para cada campo indica su tipo, si es llave, si acepta valores nulos y qué información guarda.

En Órbita Kids, el diccionario sirve como referencia común para el equipo de la app móvil, la PWA y la API, de modo que todos usen los mismos nombres y reglas.

## 🎯 ¿Para qué sirve?

Esta documentación permite:

- Comprender qué información guarda la plataforma y cómo se organiza.
- Mantener nombres, tipos y reglas consistentes entre la app, la PWA y la API.
- Crear la base de datos completa con un solo script.
- Detectar posibles errores de diseño antes de programar.
- Facilitar que nuevas personas del equipo conozcan el modelo.

## 🚀 ¿De qué trata Órbita Kids?

**Órbita Kids** es una plataforma educativa propuesta para apoyar el aprendizaje de matemáticas mediante una experiencia de **exploración espacial**. Los estudiantes eligen un personaje, resuelven sumas, recorren planetas, reparan su nave y reciben recompensas visuales. Los docentes administran grupos, asignan actividades y consultan resultados desde una PWA.

### Qué guarda la base de datos

- 👤 **Usuarios y roles:** estudiantes, docentes y dirección.
- 🏫 **Instituciones, grupos y asignaciones** creados por los docentes.
- 🪐 **Contenido educativo:** planetas, niveles, misiones y banco de actividades.
- 📈 **Seguimiento:** intentos, errores, progreso por misión y uso de apoyos visuales.
- 🏅 **Recompensas** obtenidas por cada estudiante.

> La plataforma educativa se presenta como una propuesta en desarrollo. Este modelo corresponde a la primera versión y puede cambiar durante la implementación.

## 🧩 Tablas del modelo

El modelo tiene **19 tablas**, organizadas en cuatro áreas:

| Área | Tablas | ¿Qué guardan? |
| --- | --- | --- |
| **👥 Usuarios e instituciones** | `ROL`, `USUARIO`, `INSTITUCION`, `DOCENTE`, `ESTUDIANTE`, `PERSONAJE` | Cuentas, roles, escuelas, perfiles de docente y estudiante, y personajes elegibles. |
| **🏫 Grupos y tareas** | `GRUPO`, `GRUPO_ESTUDIANTE`, `ASIGNACION`, `ASIGNACION_ACTIVIDAD` | Grupos de cada docente, estudiantes inscritos y actividades asignadas con su fecha límite. |
| **🪐 Contenido educativo** | `PLANETA`, `NIVEL`, `MISION`, `TIPO_ACTIVIDAD`, `ACTIVIDAD` | Mapa espacial, niveles de dificultad, misiones y banco de sumas. |
| **📈 Seguimiento y recompensas** | `INTENTO`, `PROGRESO`, `RECOMPENSA`, `ESTUDIANTE_RECOMPENSA` | Cada respuesta del estudiante, su avance por misión y las recompensas ganadas. |

## 🧠 Decisiones de diseño

- 🔐 **Las contraseñas no se guardan aquí.** La autenticación la gestiona Keycloak; la tabla `USUARIO` solo guarda el identificador (`keycloak_id`).
- 🧬 **Docente y estudiante son especializaciones de usuario.** Sus tablas usan el mismo `id_usuario` como llave primaria y foránea.
- 🧒 **Datos mínimos de menores.** Del estudiante solo se guardan grado y edad, y el correo es opcional.
- 📴 **Modo offline-first.** Los intentos incluyen el campo `sincronizado` para saber si ya se enviaron al servidor.
- 🧩 **Reglas de adaptación.** `INTENTO` registra el uso de apoyo visual y `PROGRESO` guarda el nivel actual, con lo que las reglas programadas pueden ofrecer ayuda o ejercicios más sencillos.
- 🧮 **Opciones en JSON.** Las actividades de selección de respuesta guardan sus opciones en un campo `JSON`.

### Reglas de integridad principales

| Regla | Dónde se aplica |
| --- | --- |
| El grado va de 1 a 4 y la edad de 6 a 9. | `ESTUDIANTE` |
| El nivel de dificultad es 1, 2 o 3. | `NIVEL` |
| La respuesta correcta debe ser `sumando_a + sumando_b`. | `ACTIVIDAD` |
| El ciclo escolar tiene formato `2026-2027`. | `GRUPO` |
| Un estudiante tiene un solo progreso por misión. | `PROGRESO` |
| La fecha límite no puede ser anterior a la asignación. | `ASIGNACION` |
| Los contadores de aciertos y errores no pueden ser negativos. | `PROGRESO` |

## 💻 ¿Cómo consultar el diccionario?

El diccionario está disponible en dos formatos:

1. **Excel (`.xlsx`):** una tabla general con todos los campos, ideal para filtrar y editar.
2. **Página HTML:** una vista por tabla con índice, claves resaltadas y comentarios, lista para leer en el navegador o imprimir como PDF.

Cada campo incluye:

- **Tabla y campo.**
- **Tipo de dato.**
- **Clave:** PK (primaria), FK (foránea) o UQ (único).
- **¿Acepta nulo?**
- **Descripción y comentarios.**

## ▶️ Crear la base de datos

1. Instala **MySQL 8.0.16 o superior**. Las versiones anteriores ignoran las restricciones `CHECK`.
2. Ejecuta el script con el cliente que prefieras:
   - **Terminal:** `mysql -u root -p < orbita_kids_schema.sql`
   - **MySQL Workbench:** *File → Open SQL Script* y ejecutar con el rayo ⚡.
   - **DBeaver:** abrir el script y ejecutarlo completo con `Alt + X`.
3. Se creará el esquema `orbita_kids` con las 19 tablas y los datos iniciales de los catálogos (roles y tipos de actividad).

> ⚠️ El script comienza con `DROP SCHEMA IF EXISTS orbita_kids`. Si ya tienes datos en un esquema con ese nombre, comenta esa línea antes de ejecutarlo.

Si usas **MariaDB** (por ejemplo, con XAMPP), cambia `utf8mb4_0900_ai_ci` por `utf8mb4_unicode_ci` en la creación del esquema.

## 📂 Estructura de archivos

| Archivo | Contenido |
| --- | --- |
| `README.md` | Presentación del modelo, tablas e instrucciones de uso. |
| `DiccionarioDeDatos_OrbitaKids.xlsx` | Diccionario de datos en hoja de cálculo. |
| `DiccionarioDeDatos_OrbitaKids.html` | Diccionario de datos en formato web, con una vista por tabla. |
| `DiagramaMER.png` | Diagrama entidad-relación del modelo. |
| `orbita_kids_schema.sql` | Script que crea el esquema, con comentarios, llaves y restricciones. |

## 🛠️ Tecnologías

![MySQL](https://img.shields.io/badge/MySQL-4479A1?logo=mysql&logoColor=white)
![Keycloak](https://img.shields.io/badge/Keycloak-4D4D4D?logo=keycloak&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=white)

| Componente | Tecnología | Función |
| --- | --- | --- |
| Base de datos | MySQL 8 (InnoDB, `utf8mb4`) | Almacena usuarios, grupos, actividades, intentos y progreso. |
| Autenticación | Keycloak | Gestiona cuentas y contraseñas fuera de la base de datos. |
| Aplicación del estudiante | Flutter y Dart | Consume los datos mediante la API. |
| PWA del docente | React | Administra grupos, asignaciones y resultados. |
| API | FastAPI | Comunica las aplicaciones con la base de datos. |

## 👥 Integrantes del equipo

- Obed Guzmán Flores
- Yazmin Gutierrez Hernandez
- Citlalli Perez Dionicio
- Michelle Castro Otero
- Jennifer Bautista Barrios

## 📚 Referencias

- [Documentación de MySQL 8.0](https://dev.mysql.com/doc/refman/8.0/en/)
- [Restricciones CHECK en MySQL](https://dev.mysql.com/doc/refman/8.0/en/create-table-check-constraints.html)
- [Documentación de Keycloak](https://www.keycloak.org/documentation)

**Última actualización:** noviembre de 2026.

---

<p align="center">
  🪐 <strong>Órbita Kids</strong><br>
  Modelo de datos
</p>