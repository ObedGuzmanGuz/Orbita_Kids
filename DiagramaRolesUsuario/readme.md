# 🚀 Práctica 05 · Diagrama de Roles de Usuario | Órbita Kids

## 📌 Descripción

En esta práctica se desarrolló un **Diagrama de Roles de Usuario** para el proyecto **Órbita Kids**, una plataforma educativa enfocada en el aprendizaje y refuerzo de matemáticas.

El diagrama permite representar de manera visual los diferentes **actores que interactúan con un sistema**, las responsabilidades que tienen y las principales funcionalidades con las que pueden interactuar.

Esta representación ayuda a comprender de una forma más clara cómo se organiza un sistema desde el punto de vista de los usuarios, permitiendo identificar quién utiliza la plataforma, qué acciones puede realizar y cómo se relacionan los diferentes elementos.

---

## 🎯 ¿Para qué sirve un Diagrama de Roles de Usuario?

Un **Diagrama de Roles de Usuario** sirve para identificar y representar los diferentes tipos de usuarios o actores que participan dentro de un sistema.

Su principal objetivo es mostrar de manera sencilla:

- 👥 Los diferentes tipos de usuarios.
- 🔐 Las responsabilidades de cada usuario.
- ⚙️ Las funcionalidades disponibles para cada rol.
- 🔗 La relación entre los usuarios y las funcionalidades.
- 🏫 Los actores externos que tienen relación con el sistema.
- 💻 La interacción general entre los usuarios y la plataforma.

Este tipo de diagrama resulta útil durante el análisis y diseño de software, ya que permite tener una visión general de los usuarios antes de desarrollar las diferentes funcionalidades del sistema.

También facilita la comunicación entre los integrantes de un equipo de desarrollo, ya que permite visualizar de manera sencilla cómo se espera que interactúen los usuarios con la aplicación.

---

## 🧩 Aplicación en el proyecto Órbita Kids

En **Órbita Kids**, el Diagrama de Roles de Usuario permite representar cómo los diferentes actores interactúan con la plataforma educativa.

La plataforma está orientada principalmente al aprendizaje de matemáticas, por lo que se identificaron diferentes roles con responsabilidades específicas.

El sistema cuenta con un núcleo central representado por **Órbita Kids**, alrededor del cual se encuentran los principales roles y funcionalidades de la plataforma.

---

## 👥 Roles identificados

## 🌐 Aplicación en GitHub Pages

🚀 **[Ver el Diagrama de Roles de Usuario de Órbita Kids](https://obedguzmanguz.github.io/Orbita_Kids/DiagramaRolesUsuario/)**


### 👨‍🎓 Estudiante

El estudiante representa al usuario principal de la plataforma educativa.

Entre sus principales actividades se encuentran:

- Utilizar la aplicación móvil.
- Resolver actividades matemáticas.
- Realizar ejercicios de refuerzo.
- Avanzar dentro de la misión espacial.
- Consultar su progreso.
- Interactuar con las actividades disponibles.

El objetivo de este rol es permitir que el estudiante pueda practicar matemáticas de una manera interactiva y relacionada con la temática espacial de Órbita Kids.

---

### 👨‍🏫 Docente

El docente representa al usuario encargado de administrar y dar seguimiento al trabajo de los estudiantes.

Entre sus principales actividades se encuentran:

- Utilizar la PWA docente.
- Administrar grupos.
- Asignar actividades.
- Consultar resultados.
- Dar seguimiento al progreso de los estudiantes.
- Revisar el desempeño de los grupos.

Este rol permite que el docente pueda utilizar la información generada por los estudiantes para realizar un seguimiento de sus actividades y resultados.

---

### 🏫 Escuela / Institución

La escuela o institución representa un actor externo relacionado con la adopción y utilización de la plataforma.

Dentro del contexto del proyecto puede participar en:

- Pilotos de la plataforma.
- Demostraciones.
- Procesos de adopción.
- Licencias.
- Contextos institucionales de utilización.

Este actor permite representar la relación de Órbita Kids con el entorno educativo en el que puede ser utilizada la plataforma.

---

## ⚙️ Funcionalidades principales

El diagrama representa cinco funcionalidades principales de Órbita Kids:

### 1. 🧮 Actividades matemáticas

Permite que los estudiantes puedan realizar diferentes actividades relacionadas con el aprendizaje y práctica de matemáticas.

---

### 2. 🧠 Refuerzo adaptado

Representa las funcionalidades relacionadas con el refuerzo de los conocimientos matemáticos de acuerdo con las necesidades del estudiante.

---

### 3. 🚀 Progreso y misión espacial

Relaciona el avance del estudiante con la temática espacial de Órbita Kids.

Permite representar el progreso que obtiene el estudiante mientras realiza las actividades de la plataforma.

---

### 4. 👥 Grupos y asignaciones

Esta funcionalidad está relacionada principalmente con el rol del docente.

Permite representar la administración de grupos y la asignación de actividades a los estudiantes.

---

### 5. 📊 Resultados y seguimiento

Representa las funcionalidades relacionadas con la consulta de resultados y el seguimiento del progreso de los estudiantes.

Esta sección está principalmente relacionada con las actividades realizadas por el docente dentro de la plataforma.

---

## 🔗 Relación entre los elementos

El diagrama permite visualizar la relación entre los diferentes actores y las funcionalidades de Órbita Kids.

De manera general:

```text
                  🏫 Escuela / Institución
                           │
                           │
                           ▼
                    🚀 ÓRBITA KIDS
                     /           \
                    /             \
                   ▼               ▼
           👨‍🎓 Estudiante      👨‍🏫 Docente
                │                  │
                ▼                  ▼
       Actividades             Grupos y
       matemáticas            asignaciones
                │                  │
                ▼                  ▼
        Refuerzo adaptado    Resultados y
                              seguimiento
                │
                ▼
       🚀 Progreso y misión
             espacial