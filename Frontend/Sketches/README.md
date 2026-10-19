# 🪐 Sketches de Órbita Kids

Esta carpeta contiene los sketches de Órbita Kids, una plataforma educativa
orientada al aprendizaje infantil mediante actividades interactivas,
movimiento, exploración del entorno y seguimiento del progreso.

Los sketches son representaciones visuales iniciales de las pantallas y
recorridos de la aplicación. Su objetivo es mostrar de forma rápida la idea
general de cada vista, la distribución aproximada de sus elementos y la
secuencia de navegación, sin definir todavía la interfaz visual o técnica
definitiva.

## 🎯 Propósito

Los sketches permiten explorar y comunicar ideas antes de pasar a etapas más
detalladas de diseño y desarrollo. En Órbita Kids sirven para:

- Visualizar las pantallas principales de la plataforma.
- Explorar diferentes formas de organizar el contenido.
- Representar los recorridos de estudiantes y profesores.
- Identificar las acciones más importantes de cada vista.
- Detectar problemas de navegación de manera temprana.
- Alinear al equipo sobre la experiencia que se quiere construir.
- Servir como punto de partida para los wireframes y la implementación.

Los sketches no representan necesariamente el diseño final. Son una guía
flexible que puede modificarse conforme se validen las necesidades de los
usuarios y del proyecto.

## 👥 Perfiles incluidos

Los sketches están organizados para dos perfiles principales:

### Estudiante

Incluyen las vistas relacionadas con el aprendizaje, las actividades y el
bienestar del estudiante:

- Bienvenida, acceso y perfil infantil.
- Inicio, cursos y lecciones.
- Videos y quizzes.
- Retos físicos, circuitos y pausas activas.
- Exploración del entorno y experimentos.
- Lecturas sin pantalla y actividades familiares.
- Registro de actividades y diario.
- Equilibrio digital, logros y perfil.

### Profesor

Incluyen las vistas necesarias para acompañar, organizar y revisar el
aprendizaje:

- Acceso e inicio.
- Grupos y avance de alumnos.
- Creación y asignación de actividades.
- Biblioteca offline.
- Retos físicos, rutas del entorno y pausas programadas.
- Rutinas de aula y protocolos de seguridad.
- Validación de retos y retroalimentación.
- Rúbricas, mensajes a familias y reportes.
- Imprimibles, uso de pantalla y ajustes.

## 📱 Plataformas

Cada perfil cuenta con sketches para dos contextos de uso:

- **Móvil:** pensado para interacciones breves, actividades dinámicas y
  navegación desde pantallas pequeñas.
- **Web/PWA:** pensado para consultar más información, organizar actividades,
  visualizar avances y administrar grupos o contenidos.

Esta separación permite explorar cómo cambia la distribución de una pantalla
según el dispositivo, manteniendo el objetivo de cada función.

## 🔄 Recorridos principales

Los sketches muestran recorridos generales para entender cómo se conectan las
vistas:

### Recorrido del estudiante

1. Conoce la plataforma desde la pantalla de bienvenida.
2. Accede a su cuenta y configura o consulta su perfil.
3. Entra al inicio para revisar cursos, lecciones y retos.
4. Realiza actividades de aprendizaje, movimiento o exploración.
5. Registra su experiencia y consulta sus logros o progreso.

### Recorrido del profesor

1. Accede a la plataforma docente.
2. Consulta sus grupos y el avance de los estudiantes.
3. Crea, selecciona o asigna actividades.
4. Organiza retos, pausas y materiales para el aula.
5. Valida entregas y proporciona retroalimentación.
6. Revisa reportes para dar seguimiento al aprendizaje.

Las imágenes de vista general permiten observar estos recorridos de manera
conjunta por perfil y plataforma.

## 🗂️ Organización de los recursos

```text
Sketches/
├── assets/
│   ├── Estudiante/
│   │   ├── Movil/           # Sketches del estudiante para móvil
│   │   └── Web_PWA/        # Sketches del estudiante para Web/PWA
│   ├── Profesor/
│   │   ├── Movil/           # Sketches del profesor para móvil
│   │   └── Web_PWA/        # Sketches del profesor para Web/PWA
│   ├── VISTA_GENERAL_*.jpg  # Recorridos completos por perfil y plataforma
│   ├── logo_aplicacion.png
│   └── logo_empresa.png
├── catalogo.json            # Descripción y conexión de las pantallas
├── catalogo.js              # Datos utilizados por el visualizador
├── index.html               # Visualizador de sketches
├── app.js                   # Lógica del visualizador
├── styles.css               # Estilos del visualizador
└── README.md                # Este documento
```

Los sketches se encuentran principalmente en formato PNG. Las imágenes siguen
una numeración que representa su posición dentro del recorrido y un nombre que
indica la función de la pantalla, por ejemplo:

```text
assets/Estudiante/Movil/01_bienvenida.png
assets/Profesor/Web_PWA/05_asignar_contenido.png
```

## 📚 Catálogo de pantallas

El archivo [`catalogo.json`](./catalogo.json) organiza la información de los
sketches. Cada registro puede incluir:

- Perfil y plataforma.
- Número de paso dentro del recorrido.
- Identificador y título de la pantalla.
- Descripción de la experiencia.
- Acciones principales.
- Pantallas relacionadas.
- Categoría funcional.
- Archivo de imagen correspondiente.

El catálogo facilita la consulta de las pantallas y permite que el
visualizador las presente de forma ordenada e interactiva.

## 💡 Importancia para Órbita Kids

Los sketches son importantes porque ayudan a construir una experiencia
educativa antes de invertir tiempo en detalles de implementación:

- **Permiten pensar en el usuario:** ayudan a revisar si la experiencia es
  comprensible para estudiantes y profesores.
- **Aclaran la navegación:** muestran qué pantallas necesita cada recorrido y
  cómo se conectan.
- **Facilitan la comunicación:** ofrecen una representación común para el
  equipo de diseño, desarrollo y contenido.
- **Ayudan a priorizar:** permiten distinguir las acciones y contenidos
  esenciales de cada vista.
- **Favorecen la adaptación multiplataforma:** permiten comparar las
  necesidades de móvil y Web/PWA.
- **Reducen cambios tardíos:** los problemas de estructura pueden detectarse
  antes de construir la interfaz.
- **Conectan la propuesta educativa con la experiencia digital:** hacen visible
  la relación entre lecciones, retos, movimiento, familia y progreso.

## ✅ Uso de los sketches durante el proyecto

Para consultar o actualizar estos recursos se recomienda:

1. Identificar el perfil y la plataforma de la pantalla.
2. Revisar la imagen correspondiente dentro de `assets`.
3. Consultar su descripción y acciones en
   [`catalogo.json`](./catalogo.json).
4. Verificar que la pantalla forme parte de un recorrido comprensible.
5. Comparar la vista con las necesidades del usuario y el objetivo educativo.
6. Actualizar el catálogo cuando se agregue, elimine o reorganice una pantalla.
7. Utilizar las decisiones validadas como base para los wireframes.

## 🔗 Recursos relacionados

- [Visualizador de sketches](./index.html)
- [Catálogo de sketches](./catalogo.json)
- [Wireframes de Órbita Kids](../Wireframes)
- [Documentación general del frontend](../readme.md)
- [Repositorio de Órbita Kids](https://github.com/ObedGuzmanGuz/Orbita_Kids)

---

Los sketches son una referencia inicial y evolutiva de Órbita Kids. Pueden
ajustarse conforme avance la validación de la experiencia y se definan los
wireframes y la interfaz final.
