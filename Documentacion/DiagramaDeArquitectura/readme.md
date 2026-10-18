# 🚀 Órbita Kids — Diagrama de Arquitectura

## 📌 Descripción general

**Órbita Kids** es una plataforma educativa de matemáticas adaptativas con temática espacial, diseñada para que los estudiantes aprendan mediante actividades interactivas, misiones y recompensas, mientras los docentes cuentan con herramientas para administrar grupos, asignar actividades y consultar el progreso académico.

La arquitectura contempla dos interfaces principales que se comunican con un backend centralizado mediante una API REST. De esta manera, ambas plataformas comparten la lógica de negocio y los datos, manteniendo una separación entre la experiencia de aprendizaje y las herramientas de seguimiento docente.

## 🖼️ Diagrama de arquitectura

El siguiente diagrama representa los componentes principales del sistema, sus tecnologías, las conexiones entre plataformas y servicios, así como la infraestructura propuesta para su despliegue.

![Diagrama de arquitectura de Órbita Kids](docs/imagenes/diagrama-arquitectura-orbita-kids.png)

*Figura 1. Arquitectura propuesta para la plataforma educativa Órbita Kids.*

## 🎯 Objetivos de la arquitectura

- Separar la experiencia de aprendizaje de los estudiantes de las herramientas de gestión docente.
- Centralizar la lógica de negocio y el acceso a los datos mediante una API REST.
- Facilitar la autenticación y autorización de los usuarios.
- Mantener una estructura modular que permita agregar funcionalidades posteriormente.
- Favorecer la seguridad, el mantenimiento y la escalabilidad de la plataforma.
- Permitir el seguimiento del progreso y el análisis de los resultados de aprendizaje.

## 👥 Usuarios del sistema

La arquitectura contempla dos roles principales:

### 👨‍🚀 Estudiantes

Utilizan la aplicación móvil para realizar actividades matemáticas dentro de una experiencia educativa con temática espacial.

Principales funcionalidades:

- Elegir un personaje.
- Resolver sumas mediante apoyos visuales o selección de respuestas.
- Recorrer un mapa de planetas y niveles.
- Completar misiones relacionadas con la reparación de una nave.
- Obtener recompensas visuales.
- Consultar su progreso.
- Recibir actividades adaptadas a su desempeño.

### 👩‍🏫 Docentes

Utilizan la aplicación web progresiva para gestionar las actividades y dar seguimiento al aprendizaje de sus estudiantes.

Principales funcionalidades:

- Administrar grupos y estudiantes.
- Asignar actividades matemáticas.
- Consultar resultados e historial de progreso.
- Identificar errores frecuentes.
- Detectar actividades que requieren mayor práctica.
- Consultar reportes para orientar el refuerzo educativo.

## 🧩 Componentes de la arquitectura

### 1. Aplicación móvil — Flutter y Dart

Es la interfaz principal para los estudiantes. Ofrece las actividades matemáticas, la exploración de planetas, las misiones, las recompensas y la consulta del avance.

La aplicación se comunica con el backend mediante solicitudes HTTPS a la API REST.

### 2. Aplicación web progresiva (PWA) — React

Es la interfaz destinada a los docentes. Permite gestionar grupos, organizar actividades y consultar información sobre los resultados y el progreso de los estudiantes.

La PWA utiliza la misma API central que la aplicación móvil. No constituye una segunda aplicación de juego ni una interfaz independiente para padres o tutores.

### 3. Backend — FastAPI y Python

El backend concentra las reglas de negocio y proporciona los servicios que necesitan las dos plataformas.

Responsabilidades principales:

- Exponer endpoints mediante una API REST con respuestas JSON.
- Gestionar usuarios, grupos, actividades e intentos.
- Registrar resultados y progreso.
- Aplicar las reglas de adaptación de actividades según el desempeño.
- Validar la autenticación y los permisos de acceso.
- Consultar y actualizar la información almacenada en la base de datos.
- Proporcionar documentación de la API mediante OpenAPI y Swagger UI.

### 4. Proveedor de identidad — Keycloak

Keycloak se contempla como el proveedor central de identidad para la autenticación y autorización de usuarios.

Funciones previstas:

- Gestionar el inicio de sesión.
- Proporcionar autenticación mediante OAuth 2.0 y OpenID Connect.
- Emitir tokens de acceso JWT.
- Definir roles y permisos para estudiantes y docentes.
- Permitir que el backend valide los tokens y autorice las operaciones solicitadas.

La integración debe configurarse en las plataformas y en FastAPI. La existencia de Keycloak en el diagrama representa una decisión de arquitectura, no necesariamente una funcionalidad ya implementada.

### 5. Base de datos relacional — MySQL

MySQL será el sistema principal para almacenar la información estructurada de la plataforma.

Se contempla utilizarlo para guardar:

- Perfiles de usuarios.
- Grupos y relaciones entre estudiantes y docentes.
- Actividades matemáticas.
- Intentos y resultados.
- Historial de progreso.
- Información necesaria para generar reportes.

Las relaciones entre estas entidades permiten mantener la consistencia de la información y consultar los resultados de manera organizada.

### 6. Caché — Redis (opcional)

Redis puede incorporarse como complemento si las necesidades de rendimiento lo justifican.

Sus posibles usos incluyen:

- Almacenar temporalmente datos consultados con frecuencia.
- Reducir consultas repetitivas a MySQL.
- Gestionar datos temporales o limitación de solicitudes.
- Facilitar el almacenamiento temporal de sesiones o información de corta duración, cuando sea necesario.

**Redis no es indispensable para la primera versión.** Para simplificar el desarrollo, se recomienda comenzar con FastAPI y MySQL y agregar Redis cuando exista una necesidad concreta de rendimiento o gestión de datos temporales.

### 7. Servicios externos

La arquitectura puede integrarse con servicios externos para complementar su funcionamiento:

- **Correo transaccional:** envío de confirmaciones y recuperación de contraseñas.
- **Almacenamiento de archivos:** conservación de imágenes, ilustraciones y recursos multimedia.
- **Analítica de uso:** recopilación de estadísticas generales de utilización, si se requiere.

Estos servicios son complementarios y deben seleccionarse según las necesidades reales del proyecto. No se consideran integraciones implementadas hasta que se configuren y prueben.

### 8. Monitoreo y observabilidad — Grafana y Prometheus

Se contempla el uso de herramientas de monitoreo para observar el estado y el rendimiento del backend.

- **Prometheus:** recopilación y consulta de métricas, como solicitudes, latencia y errores, siempre que la aplicación exponga las métricas correspondientes.
- **Grafana:** creación de paneles visuales para consultar las métricas y detectar posibles problemas.

La integración requiere configuración adicional en FastAPI y en el entorno de despliegue. Ambas herramientas se consideran parte de la infraestructura propuesta.

### 9. Infraestructura y despliegue — Docker

Docker permitirá empaquetar los componentes de la aplicación en contenedores, facilitando la configuración de los entornos de desarrollo y despliegue.

Docker Compose puede utilizarse para coordinar servicios como:

- Backend FastAPI.
- Base de datos MySQL.
- Keycloak.
- Redis, si se incorpora.
- Prometheus y Grafana.

La PWA de React y la aplicación móvil de Flutter pueden requerir procesos de construcción y publicación específicos. Docker no sustituye la compilación ni la distribución de la aplicación móvil.

## 🔄 Flujo general de funcionamiento

1. El estudiante o el docente accede a la plataforma correspondiente.
2. El usuario se autentica mediante el mecanismo de identidad configurado.
3. La aplicación envía solicitudes HTTPS a la API REST de FastAPI.
4. El backend valida la solicitud, los permisos y las reglas de negocio.
5. FastAPI consulta o actualiza los datos de MySQL y utiliza Redis únicamente si está configurado.
6. El backend devuelve una respuesta JSON a la aplicación solicitante.
7. La aplicación móvil presenta las actividades y el avance del estudiante, mientras que la PWA muestra los resultados y reportes disponibles para el docente.
8. Las herramientas de observabilidad recopilan las métricas configuradas para supervisar el funcionamiento del sistema.

## 🔐 Consideraciones de seguridad

- Utilizar HTTPS en los entornos desplegados.
- Validar los tokens de acceso y sus permisos en el backend.
- Aplicar control de acceso según los roles de estudiante y docente.
- Impedir que un usuario consulte o modifique información que no le corresponde.
- Proteger las credenciales y variables de entorno.
- Evitar exponer contraseñas, secretos o tokens en el repositorio.
- Minimizar la información personal almacenada, especialmente por tratarse de una plataforma dirigida a menores.
- Aplicar controles de acceso y políticas de protección de datos apropiadas para la información de los estudiantes.

## 🛠️ Tecnologías principales

| Componente | Tecnología |
|---|---|
| Aplicación móvil | Flutter y Dart |
| PWA para docentes | React |
| Backend / API REST | FastAPI y Python |
| Base de datos principal | MySQL |
| Identidad y autenticación | Keycloak |
| Caché opcional | Redis |
| Monitoreo de métricas | Prometheus |
| Paneles de monitoreo | Grafana |
| Contenedores | Docker |
| Orquestación local | Docker Compose |
| Documentación de API | OpenAPI / Swagger UI |

## 📌 Estado de la arquitectura

Este diagrama representa la **arquitectura tecnológica propuesta** para Órbita Kids. La presencia de una tecnología en el diagrama no significa que su integración esté terminada.

La implementación y validación de cada componente se realizará de manera progresiva, priorizando las funcionalidades educativas, la gestión de grupos y actividades, el almacenamiento de resultados y la comunicación segura entre las plataformas.

## 🚀 Conclusión

La arquitectura de Órbita Kids separa las interfaces de estudiantes y docentes, centraliza las reglas de negocio en FastAPI y utiliza MySQL para almacenar la información estructurada. Keycloak proporciona el mecanismo de identidad previsto, mientras que Docker facilita la preparación del entorno y Grafana junto con Prometheus permiten plantear el monitoreo del sistema.

Esta organización busca mantener una plataforma educativa modular, mantenible y preparada para evolucionar conforme se incorporen nuevas actividades y necesidades de aprendizaje.