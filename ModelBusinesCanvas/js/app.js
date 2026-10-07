"use strict";

// Completa únicamente los datos reales. Los campos vacíos no se muestran.
const datosAcademicos = {
  estudiante: "",
  materia: "",
  grupo: "",
  fecha: ""
};

// Propuesta académica: las aplicaciones, ingresos y alianzas están por validar.
// Los números siguen los nueve bloques; CSS conserva la distribución del Canvas.
const bloques = [
  {
    "id": "segmentos",
    "numero": 1,
    "titulo": "Segmentos de clientes",
    "categoria": "Personas",
    "color": "blue",
    "pregunta": "¿Para quién creamos valor?",
    "resumen": [
      "Niños de 6 a 7 años: 1.º de primaria",
      "Niños de 7 a 8 años: 2.º de primaria",
      "Niños de 8 a 9 años: 3.º de primaria",
      "Docentes y escuelas: acompañamiento y adopción"
    ],
    "contexto": [
      "Una comunidad educativa",
      "Las familias acompañan como usuarias indirectas."
    ],
    "significado": "Son los grupos de personas u organizaciones a quienes se dirige la propuesta. Usar la plataforma y pagar por ella pueden corresponder a actores distintos.",
    "incluye": "Usuarios, necesidades educativas y responsables de decidir o financiar la adopción.",
    "preguntas": [
      "¿Quién resuelve las actividades?",
      "¿Qué edades tienen los estudiantes?",
      "¿Quién acompaña el aprendizaje?",
      "¿Quién decide y paga una licencia?"
    ],
    "aplicacion": "Órbita Kids se dirige principalmente a niños de primeros grados de primaria, específicamente de 6 a 9 años. Los estudiantes utilizan la app móvil para aprender matemáticas mediante actividades y dinámicas de videojuego, mientras que los docentes utilizan la PWA para acompañar y consultar su progreso. Las escuelas son los posibles clientes que pueden contratar la plataforma.",
    "ejemplo": "Un grupo de 1.º de primaria estaría formado principalmente por niños de 6 a 7 años y utilizaría actividades de sumas con mayor apoyo visual. Un grupo de 2.º tendría actividades para niños de 7 a 8 años y un grupo de 3.º para niños de 8 a 9 años, aumentando gradualmente la dificultad.",
    "relacion": "Las necesidades de cada segmento orientan la propuesta de valor; la edad de los estudiantes determina el tipo de contenido, mientras que docentes y escuelas participan en el acompañamiento y adopción de la plataforma.",
    "relacionados": [
      "valor",
      "ingresos",
      "relaciones"
    ],
    "elementos": [
      {
        "titulo": "Niños de 6 a 7 años",
        "descripcion": "Usuarios correspondientes principalmente a 1.º de primaria. Realizan actividades matemáticas con mayor apoyo visual y ejercicios sencillos."
      },
      {
        "titulo": "Niños de 7 a 8 años",
        "descripcion": "Usuarios correspondientes principalmente a 2.º de primaria. Resuelven actividades con un nivel de dificultad intermedio."
      },
      {
        "titulo": "Niños de 8 a 9 años",
        "descripcion": "Usuarios correspondientes principalmente a 3.º de primaria. Realizan ejercicios con menor apoyo visual y mayor dificultad."
      },
      {
        "titulo": "Docentes de primaria",
        "descripcion": "Utilizan la PWA para administrar grupos, asignar actividades, consultar resultados e identificar necesidades de refuerzo."
      },
      {
        "titulo": "Escuelas e instituciones",
        "descripcion": "Posibles clientes que pueden contratar una licencia para utilizar Órbita Kids con sus grupos y docentes."
      },
      {
        "titulo": "Padres y tutores",
        "descripcion": "Acompañan de manera indirecta el uso de la plataforma. La primera versión no incluye una interfaz específica para familias."
      }
    ],
    "nota": "La primera versión está enfocada en niños de 6 a 9 años de los tres primeros grados de primaria. La segmentación puede ampliarse posteriormente según los resultados de los pilotos."
  },
  {
    "id": "valor",
    "numero": 2,
    "titulo": "Propuesta de valor",
    "categoria": "Valor",
    "color": "green",
    "pregunta": "¿Qué ofrecemos?",
    "resumen": [
      "Matemáticas interactivas",
      "Refuerzo adaptado a los errores",
      "Seguimiento del progreso"
    ],
    "contexto": [
      "Aprender es la misión",
      "La exploración espacial motiva; el aprendizaje guía cada actividad."
    ],
    "significado": "Es el beneficio que la plataforma ofrece para atender una necesidad concreta de sus usuarios.",
    "incluye": "La dificultad que se busca resolver, los beneficios educativos y las características que hacen útil la solución.",
    "preguntas": [
      "¿Qué dificultad matemática queremos atender?",
      "¿Cómo cambia la ayuda cuando hay errores?",
      "¿Qué información necesita el docente?"
    ],
    "aplicacion": "La propuesta combina práctica de sumas, apoyo adaptativo y una misión espacial para motivar el aprendizaje, con seguimiento para el docente.",
    "ejemplo": "Como regla ilustrativa por validar: tras tres errores consecutivos, ofrecer una suma menor con objetos contables; tras cuatro aciertos, volver a intentar el siguiente nivel. El ajuste nunca bajaría del nivel 1 ni superaría el 3.",
    "relacion": "Responde a los segmentos de usuarios y requiere contenido educativo, reglas de adaptación y seguimiento docente.",
    "relacionados": [
      "segmentos",
      "recursos",
      "actividades"
    ],
    "elementos": [
      {
        "titulo": "Sumas en tres niveles",
        "descripcion": "Dos tipos de actividad: sumas con apoyo visual y selección de respuestas."
      },
      {
        "titulo": "Refuerzo según el desempeño",
        "descripcion": "Reglas programadas añaden ayuda o reducen la dificultad ante errores; los aciertos permiten avanzar."
      },
      {
        "titulo": "Una misión que muestra el avance",
        "descripcion": "El estudiante elige personaje, recorre planetas, repara su nave y recibe recompensas visuales."
      },
      {
        "titulo": "Información útil para el docente",
        "descripcion": "La PWA muestra el progreso y los ejercicios que requieren más práctica."
      }
    ],
    "nota": "Se buscarán instrucciones claras y controles accesibles. Los beneficios educativos deberán evaluarse con usuarios."
  },
  {
    "id": "canales",
    "numero": 3,
    "titulo": "Canales",
    "categoria": "Personas",
    "color": "blue",
    "pregunta": "¿Cómo llegamos a las aulas?",
    "resumen": [
      "App móvil para estudiantes",
      "PWA para docentes",
      "Sitio web y demostraciones escolares"
    ],
    "significado": "Son los medios para dar a conocer la propuesta, facilitar su adopción y entregar el servicio.",
    "incluye": "Puntos de descubrimiento, acceso a la plataforma y distribución de su experiencia educativa.",
    "preguntas": [
      "¿Cómo conocerá la escuela el proyecto?",
      "¿Dónde practicarán los estudiantes?",
      "¿Cómo accederá el docente?"
    ],
    "aplicacion": "El proyecto llegará a estudiantes y docentes mediante la app móvil y la PWA, apoyadas por una presentación del servicio a las escuelas.",
    "ejemplo": "Después de una demostración escolar, una docente accedería a la PWA para asignar una actividad que su grupo resolvería en la app móvil.",
    "relacion": "Los canales conectan los segmentos con la propuesta de valor y requieren acompañamiento para la adopción.",
    "relacionados": [
      "segmentos",
      "valor",
      "relaciones"
    ],
    "elementos": [
      {
        "titulo": "App móvil en Flutter",
        "descripcion": "Canal de práctica para los niños: actividades, niveles, personaje y progreso."
      },
      {
        "titulo": "PWA docente en React",
        "descripcion": "Acceso desde el navegador para gestionar grupos, asignar ejercicios y consultar resultados."
      },
      {
        "titulo": "Sitio web del proyecto",
        "descripcion": "Presentación de la propuesta, su alcance y las herramientas disponibles."
      },
      {
        "titulo": "Demostraciones y pilotos escolares",
        "descripcion": "Forma propuesta de dar a conocer Órbita Kids y recoger opiniones antes de su adopción."
      }
    ],
    "nota": "La disponibilidad de dispositivos y conexión se revisará con cada institución."
  },
  {
    "id": "relaciones",
    "numero": 4,
    "titulo": "Relaciones con clientes",
    "categoria": "Personas",
    "color": "pink",
    "pregunta": "¿Cómo acompañamos?",
    "resumen": [
      "Retroalimentación al estudiante",
      "Reportes para el docente",
      "Orientación y soporte escolar"
    ],
    "significado": "Describe cómo se acompaña a los usuarios y se mantiene una relación útil con los clientes a lo largo del tiempo.",
    "incluye": "Orientación inicial, seguimiento, retroalimentación y mecanismos para atender dudas y mejorar el servicio.",
    "preguntas": [
      "¿Qué ayuda recibe el niño al equivocarse?",
      "¿Cómo interpreta el docente el progreso?",
      "¿Cómo se atienden dudas de la escuela?"
    ],
    "aplicacion": "Órbita Kids plantea acompañamiento durante la práctica, seguimiento del grupo y orientación a las escuelas que utilicen la plataforma.",
    "ejemplo": "Si una estudiante acumula errores en sumas, recibiría apoyo visual. Su docente identificaría esa dificultad en el reporte y asignaría práctica adicional.",
    "relacion": "El acompañamiento utiliza los canales y convierte los resultados de las actividades en seguimiento educativo.",
    "relacionados": [
      "canales",
      "actividades",
      "segmentos"
    ],
    "elementos": [
      {
        "titulo": "Retroalimentación al estudiante",
        "descripcion": "Mensajes claros, apoyo visual y ejercicios ajustados cuando aparezcan dificultades."
      },
      {
        "titulo": "Seguimiento del docente",
        "descripcion": "Consulta de resultados, errores y progreso para decidir qué reforzar con cada grupo."
      },
      {
        "titulo": "Orientación inicial",
        "descripcion": "Una guía para conocer la app, organizar grupos y comenzar a asignar actividades."
      },
      {
        "titulo": "Soporte y mejora continua",
        "descripcion": "Un canal para dudas y reportes escolares; los comentarios ayudarán a mejorar instrucciones y ejercicios."
      }
    ],
    "nota": "El acompañamiento del docente forma parte central de la propuesta educativa."
  },
  {
    "id": "ingresos",
    "numero": 5,
    "titulo": "Fuentes de ingresos",
    "categoria": "Sostenibilidad",
    "color": "yellow",
    "pregunta": "¿Cómo sostener la propuesta?",
    "resumen": [
      "Versión gratuita con acceso limitado",
      "Plan Aula: $799 MXN al mes",
      "Plan Escuela: $1,499 MXN al mes"
    ],
    "significado": "Son las formas en que el proyecto podría recibir pagos por el valor que entrega a las escuelas y docentes.",
    "incluye": "Quién pagaría, cuánto pagaría y qué servicios recibiría a cambio de utilizar Órbita Kids.",
    "preguntas": [
      "¿Qué institución pagaría por utilizar la plataforma?",
      "¿Qué incluye la versión gratuita?",
      "¿Cuánto cuesta cada modalidad de pago?"
    ],
    "aplicacion": "Órbita Kids plantea un modelo freemium educativo: una versión gratuita con acceso limitado para conocer la plataforma y versiones de pago dirigidas a escuelas que necesiten utilizar más actividades, grupos y herramientas de seguimiento.",
    "ejemplo": "Una escuela podría comenzar con la versión gratuita para conocer la experiencia. Después podría contratar el Plan Aula por $799 MXN al mes para hasta 50 estudiantes y 5 docentes, o el Plan Escuela por $1,499 MXN al mes para hasta 150 estudiantes y más herramientas de seguimiento.",
    "relacion": "Los ingresos deben cubrir los costos de infraestructura, mantenimiento, soporte y actualización del contenido educativo. La versión gratuita funciona como medio de entrada, mientras que las suscripciones representan los ingresos principales.",
    "relacionados": [
      "segmentos",
      "valor",
      "costos"
    ],
    "elementos": [
      {
        "titulo": "Versión gratuita",
        "descripcion": "Acceso limitado a actividades básicas para que docentes y escuelas conozcan el funcionamiento de Órbita Kids antes de contratar un plan."
      },
      {
        "titulo": "Plan Aula",
        "descripcion": "Suscripción de $799 MXN al mes para hasta 50 estudiantes y 5 docentes, con acceso a más actividades y seguimiento del grupo."
      },
      {
        "titulo": "Plan Escuela",
        "descripcion": "Suscripción de $1,499 MXN al mes para hasta 150 estudiantes, más grupos y herramientas ampliadas de seguimiento."
      }
    ],
    "nota": "Los precios son una propuesta inicial para mantener un costo accesible para instituciones educativas. Se podrán ajustar después de validar los costos reales y la aceptación del servicio."
  },
  {
    "id": "recursos",
    "numero": 6,
    "titulo": "Recursos clave",
    "categoria": "Operación",
    "color": "violet",
    "pregunta": "¿Qué necesitamos?",
    "resumen": [
      "App móvil, PWA, API y base de datos",
      "Contenido y recursos del videojuego",
      "Equipo técnico y apoyo educativo"
    ],
    "significado": "Son los activos, conocimientos y capacidades necesarios para construir, operar y mantener Órbita Kids.",
    "incluye": "Tecnología, contenido educativo, diseño, infraestructura y personas encargadas del desarrollo y revisión de la plataforma.",
    "preguntas": [
      "¿Qué tecnología necesita cada usuario?",
      "¿Qué contenido necesita el videojuego?",
      "¿Qué equipo se necesita para mantener la plataforma?"
    ],
    "aplicacion": "Para construir Órbita Kids se necesitan una aplicación móvil para estudiantes, una PWA para docentes, una API, una base de datos, contenido matemático, recursos visuales del videojuego y un equipo encargado del desarrollo y mantenimiento.",
    "ejemplo": "La app móvil desarrollada con Flutter se comunica con FastAPI para registrar las respuestas de los estudiantes. PostgreSQL almacena los resultados y la PWA desarrollada con React permite al docente consultar el progreso de su grupo.",
    "relacion": "Los recursos permiten realizar las actividades clave y determinan parte importante de los costos de desarrollo, infraestructura, contenido y mantenimiento.",
    "relacionados": [
      "actividades",
      "valor",
      "costos"
    ],
    "elementos": [
      {
        "titulo": "Aplicación móvil",
        "descripcion": "Desarrollada con Flutter y Dart para que los estudiantes realicen actividades matemáticas, avancen por planetas y obtengan recompensas."
      },
      {
        "titulo": "PWA para docentes",
        "descripcion": "Desarrollada con React para gestionar grupos, asignar actividades y consultar el desempeño de los estudiantes."
      },
      {
        "titulo": "API y base de datos",
        "descripcion": "FastAPI y PostgreSQL para administrar usuarios, roles, grupos, actividades, intentos, errores, niveles y progreso."
      },
      {
        "titulo": "Contenido matemático",
        "descripcion": "Banco de sumas, actividades, apoyos visuales y reglas de adaptación para los diferentes niveles de aprendizaje."
      },
      {
        "titulo": "Recursos del videojuego",
        "descripcion": "Personajes, planetas, nave espacial, recompensas, ilustraciones, interfaz y demás elementos visuales necesarios para la experiencia."
      },
      {
        "titulo": "Equipo técnico y educativo",
        "descripcion": "Desarrolladores, diseñadores y apoyo docente o pedagógico para crear, revisar y mantener la plataforma."
      }
    ],
    "nota": "Los recursos tecnológicos y educativos deben trabajar en conjunto para ofrecer una experiencia de aprendizaje interactiva y funcional."
  },
  {
    "id": "actividades",
    "numero": 7,
    "titulo": "Actividades clave",
    "categoria": "Operación",
    "color": "violet",
    "pregunta": "¿Qué debemos hacer bien?",
    "resumen": [
      "Desarrollar un videojuego educativo",
      "Crear una app móvil y una PWA",
      "Diseñar y probar actividades matemáticas"
    ],
    "significado": "Son las tareas esenciales que el equipo debe realizar para crear, operar y mejorar Órbita Kids.",
    "incluye": "Diseño del videojuego, desarrollo de las aplicaciones, creación de actividades matemáticas, pruebas, adaptación de dificultad y mantenimiento.",
    "preguntas": [
      "¿De qué trata Órbita Kids?",
      "¿Qué se desarrolla en la app móvil y en la PWA?",
      "¿Cómo se crean y mejoran las actividades?"
    ],
    "aplicacion": "Órbita Kids es un videojuego educativo de matemáticas para niños de primeros grados de primaria. Se compone de una aplicación móvil para estudiantes, donde exploran planetas, resuelven sumas, avanzan por niveles, reparan su nave espacial y reciben recompensas; y una PWA para docentes, donde se administran grupos, se asignan actividades y se consulta el progreso.",
    "ejemplo": "El equipo diseñaría una actividad donde el estudiante debe resolver una suma para obtener energía y continuar su viaje a otro planeta. La respuesta se registra mediante la API, se guarda en PostgreSQL y posteriormente el docente puede revisar el resultado desde la PWA.",
    "relacion": "Estas actividades aprovechan los recursos tecnológicos y educativos, requieren colaboración con docentes y generan costos de desarrollo, operación y mantenimiento.",
    "relacionados": [
      "recursos",
      "socios",
      "costos"
    ],
    "elementos": [
      {
        "titulo": "Diseñar el videojuego educativo",
        "descripcion": "Crear la historia, personajes, planetas, niveles, recompensas y misión principal para que el estudiante aprenda mientras juega."
      },
      {
        "titulo": "Desarrollar la app móvil",
        "descripcion": "Construir con Flutter las actividades matemáticas, navegación, niveles, selección de personaje y progreso del estudiante."
      },
      {
        "titulo": "Desarrollar la PWA docente",
        "descripcion": "Construir con React las herramientas para gestionar grupos, asignar ejercicios y consultar el desempeño de los estudiantes."
      },
      {
        "titulo": "Crear actividades matemáticas",
        "descripcion": "Diseñar ejercicios de sumas con distintos niveles de dificultad y apoyos visuales para los contenidos de primaria."
      },
      {
        "titulo": "Probar y evaluar",
        "descripcion": "Realizar pruebas de funcionamiento y pilotos escolares para identificar errores, dificultades de uso y oportunidades de mejora."
      },
      {
        "titulo": "Mantener y actualizar",
        "descripcion": "Corregir fallos, agregar nuevas actividades, mejorar contenidos y brindar soporte a las instituciones."
      }
    ],
    "nota": "Órbita Kids integra tres componentes principales: un videojuego educativo, una aplicación móvil para estudiantes y una PWA para docentes, conectados mediante una API y una base de datos."
  },
  {
    "id": "socios",
    "numero": 8,
    "titulo": "Socios clave",
    "categoria": "Operación",
    "color": "violet",
    "pregunta": "¿Con quién colaborar?",
    "resumen": [
      "Escuelas para posibles pilotos",
      "Docentes y especialistas en pedagogía",
      "Proveedores de infraestructura"
    ],
    "contexto": [
      "Alianzas por construir",
      "Colaboraciones propuestas; no hay convenios confirmados."
    ],
    "significado": "Son los actores externos cuya colaboración puede aportar conocimientos, recursos o acceso al entorno educativo.",
    "incluye": "Colaboradores potenciales, su aportación y el propósito de la relación. No toda relación es una alianza formal.",
    "preguntas": [
      "¿Quién puede revisar el contenido educativo?",
      "¿Dónde se podría realizar un piloto?",
      "¿Qué servicios conviene contratar externamente?"
    ],
    "aplicacion": "En Órbita Kids, las colaboraciones propuestas se enfocan en probar la plataforma en escuelas, revisar el contenido de sumas y contar con infraestructura tecnológica.",
    "ejemplo": "Se propondría a una escuela revisar un conjunto de sumas con sus docentes y evaluar un piloto acotado antes de considerar una adopción institucional.",
    "relacion": "La colaboración aporta recursos y ayuda a revisar las actividades. Una escuela puede ser colaboradora de un piloto y, por separado, posible cliente.",
    "relacionados": [
      "actividades",
      "recursos",
      "segmentos"
    ],
    "elementos": [
      {
        "titulo": "Escuelas de primaria",
        "descripcion": "Espacios propuestos para realizar pilotos con grupos y obtener retroalimentación sobre el uso de la plataforma."
      },
      {
        "titulo": "Docentes",
        "descripcion": "Revisión de las instrucciones y actividades; observación de las dificultades y avances de los estudiantes."
      },
      {
        "titulo": "Especialistas en pedagogía",
        "descripcion": "Orientación para revisar el nivel de las sumas, los apoyos visuales y las reglas de refuerzo."
      },
      {
        "titulo": "Proveedores tecnológicos",
        "descripcion": "Servicios contratados para alojar la API, la base de datos y las copias de seguridad."
      }
    ],
    "nota": "Son colaboradores potenciales: no hay empresas, convenios ni alianzas confirmadas."
  },
  {
    "id": "costos",
    "numero": 9,
    "titulo": "Estructura de costos",
    "categoria": "Sostenibilidad",
    "color": "yellow",
    "pregunta": "¿En qué debemos invertir?",
    "resumen": [
      "Desarrollo inicial: ~$45,000 MXN",
      "Operación mensual: ~$3,500 MXN",
      "Modelo gratuito y versión de pago"
    ],
    "significado": "Reúne los gastos necesarios para desarrollar, poner en funcionamiento y mantener Órbita Kids como servicio educativo.",
    "incluye": "Costos iniciales de desarrollo y diseño, gastos mensuales de infraestructura, mantenimiento, soporte y actualización del contenido, así como la relación entre la versión gratuita y las versiones de pago.",
    "preguntas": [
      "¿Cuánto cuesta desarrollar la plataforma?",
      "¿Cuánto cuesta mantenerla cada mes?",
      "¿Cómo se relacionan los costos con la versión gratuita y la de pago?"
    ],
    "aplicacion": "Para una primera versión funcional de Órbita Kids se estima una inversión inicial aproximada de $45,000 MXN. Después del lanzamiento, el costo de operación se estima alrededor de $3,500 MXN mensuales. La versión gratuita tendrá un alcance limitado, mientras que los planes de pago ayudarán a cubrir los costos de operación y mantenimiento.",
    "ejemplo": "El desarrollo inicial podría distribuirse aproximadamente en $28,000 MXN para programación y pruebas, $7,000 MXN para diseño y contenido educativo, $4,000 MXN para ilustraciones y recursos visuales y $6,000 MXN para configuración, despliegue y pruebas finales. Mensualmente se estiman $1,000 MXN de infraestructura, $1,500 MXN de mantenimiento y $1,000 MXN de soporte y actualización de contenido.",
    "relacion": "Los costos se originan principalmente por los recursos y actividades necesarias para construir y operar la plataforma. Por ello, los ingresos de los planes de pago deben permitir cubrir el gasto operativo, mientras que la versión gratuita funciona como medio de acceso y demostración.",
    "relacionados": [
      "recursos",
      "actividades",
      "ingresos"
    ],
    "elementos": [
      {
        "titulo": "Desarrollo inicial",
        "descripcion": "Aproximadamente $28,000 MXN para desarrollar la app móvil, PWA, API, base de datos y realizar pruebas."
      },
      {
        "titulo": "Diseño y contenido educativo",
        "descripcion": "Aproximadamente $7,000 MXN para personajes, interfaz, actividades, apoyos visuales y contenido matemático."
      },
      {
        "titulo": "Infraestructura y despliegue",
        "descripcion": "Aproximadamente $6,000 MXN para configuración, publicación, servicios iniciales y pruebas de funcionamiento."
      },
      {
        "titulo": "Ilustraciones y recursos visuales",
        "descripcion": "Aproximadamente $4,000 MXN para personajes, planetas, nave espacial y otros recursos visuales del videojuego."
      },
      {
        "titulo": "Costo mensual de operación",
        "descripcion": "Aproximadamente $3,500 MXN al mes entre alojamiento, base de datos, respaldos, mantenimiento, soporte y actualización de contenido."
      },
      {
        "titulo": "Versión gratuita",
        "descripcion": "Acceso limitado a actividades básicas para que las escuelas conozcan la plataforma sin generar un pago mensual."
      },
      {
        "titulo": "Versión de pago",
        "descripcion": "Los planes de $799 MXN y $1,499 MXN al mes representan la principal fuente de ingresos para cubrir los costos de operación y mantenimiento."
      }
    ],
    "nota": "Estas cantidades son estimaciones académicas para representar un escenario realista. Los costos finales dependerán de los proveedores, cantidad de usuarios y alcance definitivo de la plataforma."
  }
];

// Iconos propios en SVG: pequeños, locales y decorativos.
const iconos = {
  segmentos: '<circle cx="9" cy="7" r="3"/><path d="M3 20v-3a6 6 0 0 1 12 0v3M16 4a3 3 0 0 1 0 6m2 4a5 5 0 0 1 3 5"/>',
  valor: '<path d="m12 3 3 6 6 3-6 3-3 6-3-6-6-3 6-3Z"/>',
  canales: '<rect x="3" y="4" width="12" height="10" rx="2"/><path d="M9 14v4m-4 0h8"/><rect x="16" y="10" width="5" height="10" rx="1"/>',
  relaciones: '<path d="M20 11a8 8 0 0 1-8 8H4l-2 2V11a9 9 0 0 1 18 0Z"/><path d="M7 10h8m-8 4h5"/>',
  ingresos: '<path d="M3 17 9 11l4 3 8-10m-7 0h7v7"/><path d="M4 22h16"/>',
  recursos: '<path d="m12 2 9 5-9 5-9-5Zm-9 10 9 5 9-5M3 17l9 5 9-5"/>',
  actividades: '<rect x="4" y="4" width="16" height="17" rx="2"/><path d="M9 2h6v4H9Zm-2 10 2 2 3-4m2 2h3M7 18h10"/>',
  socios: '<circle cx="5" cy="12" r="3"/><circle cx="18" cy="5" r="3"/><circle cx="18" cy="19" r="3"/><path d="m8 10 7-4m-7 8 7 4"/>',
  costos: '<rect x="3" y="5" width="18" height="15" rx="2"/><path d="M3 9h18m-6 4h6v4h-6Z"/>'
};

// Ilustraciones originales incluidas en el proyecto; funcionan sin conexión.
const ilustraciones = {
  segmentos: { alt: "Dos estudiantes con una tableta, una docente y una escuela, los públicos de Órbita Kids.", pie: "Niños, docentes y escuelas: una comunidad educativa." },
  valor: { alt: "Una niña aprende con una tableta junto a planetas, bloques de conteo y un cohete.", pie: "Aprender, recibir apoyo y avanzar con una misión espacial." },
  canales: { alt: "Un teléfono, una computadora, una escuela y un megáfono representan los canales de acceso.", pie: "La app, la PWA y las demostraciones conectan con las aulas." },
  relaciones: { alt: "Una docente acompaña a una estudiante con mensajes de apoyo y un reporte visual.", pie: "Acompañamiento, retroalimentación y seguimiento docente." },
  ingresos: { alt: "Una escuela, una tarjeta de suscripción y monedas representan una licencia institucional.", pie: "Una suscripción escolar como posibilidad de sostenimiento." },
  recursos: { alt: "Computadora, teléfono, base de datos, libro y bloques educativos como recursos del proyecto.", pie: "Tecnología y contenido educativo para hacer posible la misión." },
  actividades: { alt: "Una docente y un desarrollador diseñan actividades junto a un tablero de trabajo.", pie: "Diseñar, desarrollar, probar y mejorar las actividades." },
  socios: { alt: "Tres colaboradores reúnen una escuela, un libro y servicios tecnológicos sobre una mesa.", pie: "Escuelas, especialistas y proveedores: colaboración por construir." },
  costos: { alt: "Calculadora, monedas, libros y servidores para planificar los gastos del proyecto.", pie: "Prever la inversión inicial y los gastos de operación." }
};

const grid = document.querySelector("#canvas-grid");
const dialog = document.querySelector("#detail-dialog");
const content = document.querySelector("#detail-content");
const closeButton = document.querySelector("#close-dialog");
const previousButton = document.querySelector("#previous-block");
const nextButton = document.querySelector("#next-block");
const vistos = new Set();
let indiceActual = 0;
let botonOrigen = null;
let inicioEnFondo = false;

// Escapar texto permite modificar el contenido sin interpretarlo como HTML.
function escapar(texto) {
  return String(texto).replace(/[&<>"']/g, caracter => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
  })[caracter]);
}

function lista(elementos) {
  return `<ul>${elementos.map(texto => `<li>${escapar(texto)}</li>`).join("")}</ul>`;
}

function renderizarTarjetas() {
  grid.innerHTML = bloques.map(bloque => `
    <article class="canvas-card card-${bloque.id}" id="bloque-${bloque.id}" style="--edge-delay: -${bloque.numero * 1.3}s; --edge-duration: ${11 + bloque.numero % 4}s">
      <svg class="edge-trace" aria-hidden="true" focusable="false"><rect class="edge-halo" pathLength="100"/><rect class="edge-tail" pathLength="100"/><rect class="edge-body" pathLength="100"/><rect class="edge-head" pathLength="100"/></svg>
      <div class="card-top"><span class="card-icon" aria-hidden="true"><svg viewBox="0 0 24 24">${iconos[bloque.id]}</svg></span><span class="card-number" aria-hidden="true">${String(bloque.numero).padStart(2, "0")}</span></div>
      <h3 id="titulo-${bloque.id}">${escapar(bloque.titulo)}</h3>
      <p class="card-question">${escapar(bloque.pregunta)}</p>
      <div class="card-illustration"><img src="assets/imagenes/${bloque.id}.png" alt="${escapar(ilustraciones[bloque.id].alt)}" width="1536" height="1024" loading="lazy" decoding="async"></div>
      <ul class="card-summary">${bloque.resumen.map(texto => `<li>${escapar(texto)}</li>`).join("")}</ul>
      ${bloque.contexto ? `<p class="card-context"><span>${escapar(bloque.contexto[0])}</span>${escapar(bloque.contexto[1])}</p>` : ""}
      <button class="card-open" type="button" data-block="${bloque.id}" aria-haspopup="dialog" aria-controls="detail-dialog" aria-label="Ver detalle: ${escapar(bloque.titulo)}"><span>Ver detalle</span><span class="arrow" aria-hidden="true">↗</span></button>
    </article>
  `).join("");
}

function mostrarBloque(indice) {
  if (indice < 0 || indice >= bloques.length) return;
  indiceActual = indice;
  const bloque = bloques[indice];
  const yaAbierto = dialog.open;
  if (!yaAbierto) botonOrigen = document.activeElement;

  dialog.style.setProperty("--accent", `var(--${bloque.color})`);
  document.querySelector("#detail-number").textContent = `BLOQUE ${String(bloque.numero).padStart(2, "0")} · ${bloque.categoria.toLocaleUpperCase("es")}`;
  document.querySelector("#detail-title").textContent = bloque.titulo;
  document.querySelector("#detail-subtitle").textContent = bloque.pregunta;
  const ilustracion = ilustraciones[bloque.id];
  content.innerHTML = `
    <section class="detail-application" aria-labelledby="application-title">
      <div class="application-heading">
        <span class="project-mark" aria-hidden="true"><img src="assets/orbita.svg" width="32" height="32" alt=""></span>
        <div><p class="panel-eyebrow">NUESTRO PROYECTO</p><h3 id="application-title">Aplicación en Órbita Kids</h3></div>
      </div>
      <p class="application-intro">${escapar(bloque.aplicacion)}</p>
      <div class="application-layout">
        <figure class="detail-illustration">
          <img src="assets/imagenes/${bloque.id}.png" alt="${escapar(ilustracion.alt)}" width="1536" height="1024" decoding="async">
          <figcaption>${escapar(ilustracion.pie)}</figcaption>
        </figure>
        <div class="project-scope">
          <h4>¿Qué engloba en nuestro proyecto?</h4>
          <ul class="project-points">${bloque.elementos.map(elemento => `<li><strong>${escapar(elemento.titulo)}</strong><span>${escapar(elemento.descripcion)}</span></li>`).join("")}</ul>
        </div>
      </div>
      <p class="application-note">${escapar(bloque.nota)}</p>
    </section>
    <section class="concept-panel" aria-labelledby="concept-title">
      <p class="panel-eyebrow">ENTENDER EL CANVAS</p>
      <h3 id="concept-title">¿Qué significa este bloque?</h3>
      <div class="concept-columns">
        <div><p class="concept-definition">${escapar(bloque.significado)}</p><div class="concept-part"><h4>¿Qué debe incluir?</h4><p>${escapar(bloque.incluye)}</p></div></div>
        <div class="concept-questions"><h4>Preguntas para comprenderlo</h4>${lista(bloque.preguntas)}</div>
      </div>
    </section>
    <section class="application-example" aria-labelledby="example-title"><h3 id="example-title">Así se vería en la práctica</h3><p>${escapar(bloque.ejemplo)}</p></section>
    <section class="detail-relations" aria-labelledby="relations-title">
      <h3 id="relations-title">Conexiones con otros bloques</h3>
      <p>${escapar(bloque.relacion)}</p>
      <div class="relation-buttons">${bloque.relacionados.map(id => {
        const relacionado = bloques.find(item => item.id === id);
        return `<button type="button" data-related="${id}" aria-label="Consultar ${escapar(relacionado.titulo)}">${escapar(relacionado.titulo)} <span aria-hidden="true">↗</span></button>`;
      }).join("")}</div>
    </section>`;

  previousButton.disabled = indice === 0;
  nextButton.disabled = indice === bloques.length - 1;
  document.querySelector("#detail-position").textContent = `${indice + 1} de ${bloques.length}`;
  vistos.add(bloque.id);
  document.querySelector(`#bloque-${bloque.id}`).dataset.seen = "true";
  document.querySelector("#read-progress").textContent = `${vistos.size} de ${bloques.length} bloques explorados`;

  if (!yaAbierto) {
    dialog.showModal();
    document.body.classList.add("modal-open");
  }
  closeButton.focus({ preventScroll: true });
  content.scrollTop = 0;
}

function renderizarDatosAcademicos() {
  const etiquetas = { estudiante: "Estudiante", materia: "Materia", grupo: "Grupo", fecha: "Fecha" };
  const datos = Object.entries(datosAcademicos).filter(([, valor]) => valor.trim());
  const contenedor = document.querySelector("#academic-data");
  contenedor.hidden = datos.length === 0;
  contenedor.innerHTML = datos.map(([clave, valor]) => `<div><dt>${etiquetas[clave]}</dt><dd>${escapar(valor)}</dd></div>`).join("");
}

grid.addEventListener("click", evento => {
  const boton = evento.target.closest("[data-block]");
  if (boton) mostrarBloque(bloques.findIndex(bloque => bloque.id === boton.dataset.block));
});

content.addEventListener("click", evento => {
  const boton = evento.target.closest("[data-related]");
  if (boton) mostrarBloque(bloques.findIndex(bloque => bloque.id === boton.dataset.related));
});

closeButton.addEventListener("click", () => dialog.close());
previousButton.addEventListener("click", () => mostrarBloque(indiceActual - 1));
nextButton.addEventListener("click", () => mostrarBloque(indiceActual + 1));

// Escape dispara el cierre nativo. Se restaura el foco en la tarjeta de origen.
dialog.addEventListener("close", () => {
  document.body.classList.remove("modal-open");
  if (botonOrigen instanceof HTMLElement && botonOrigen.isConnected) botonOrigen.focus({ preventScroll: true });
});

// Cerrar solo si el gesto empieza y termina fuera del rectángulo del modal.
function estaFuera(evento) {
  const rect = dialog.getBoundingClientRect();
  return evento.clientX < rect.left || evento.clientX > rect.right || evento.clientY < rect.top || evento.clientY > rect.bottom;
}

dialog.addEventListener("pointerdown", evento => {
  inicioEnFondo = evento.target === dialog && estaFuera(evento);
});

dialog.addEventListener("click", evento => {
  if (inicioEnFondo && evento.target === dialog && estaFuera(evento)) dialog.close();
  inicioEnFondo = false;
});

// Mantener el recorrido de Tab dentro de la ficha, incluidos sus extremos.
dialog.addEventListener("keydown", evento => {
  if (evento.key !== "Tab") return;
  const controles = [...dialog.querySelectorAll("button:not(:disabled), a[href]")];
  const primero = controles[0];
  const ultimo = controles[controles.length - 1];

  if (evento.shiftKey && document.activeElement === primero) {
    evento.preventDefault();
    ultimo.focus();
  } else if (!evento.shiftKey && document.activeElement === ultimo) {
    evento.preventDefault();
    primero.focus();
  }
});

document.querySelector("#print-button").addEventListener("click", () => window.print());

renderizarDatosAcademicos();
renderizarTarjetas();

// Control de los efectos decorativos. La preferencia del sistema tiene prioridad.
const motionButton = document.querySelector("#motion-toggle");
const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

function actualizarPreferenciaMovimiento() {
  motionButton.hidden = reducedMotion.matches;
}

motionButton.addEventListener("click", () => {
  const pausado = document.body.classList.toggle("motion-paused");
  const etiqueta = pausado ? "Reanudar animaciones" : "Pausar animaciones";
  motionButton.setAttribute("aria-pressed", String(pausado));
  motionButton.setAttribute("aria-label", etiqueta);
  motionButton.title = etiqueta;
  motionButton.querySelector(".motion-label").textContent = etiqueta;
  motionButton.querySelector(".motion-icon").textContent = pausado ? "▶" : "Ⅱ";
});

reducedMotion.addEventListener("change", actualizarPreferenciaMovimiento);
actualizarPreferenciaMovimiento();