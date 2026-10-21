
"use strict";

// Datos académicos: completa solo los campos que quieras mostrar.
const datosAcademicos = {
  estudiante: "",
  materia: "",
  grupo: "",
  fecha: ""
};

// ============================================================
// MODELO CANVAS DE ÓRBITA KIDS
// Propuesta académica y comercial pendiente de validación.
// Tecnología: Flutter/Dart, React, FastAPI y MySQL.
// Equipo: 5 integrantes, 3 desarrolladores.
// ============================================================

const bloques = [
  {
    id: "segmentos",
    numero: 1,
    titulo: "Segmentos de clientes",
    categoria: "Personas",
    color: "blue",
    pregunta: "¿Para quién creamos valor?",
    resumen: [
      "Niños de 6 a 9 años",
      "Docentes de primaria",
      "Escuelas e instituciones educativas"
    ],
    contexto: [
      "Comunidad educativa",
      "La escuela contrata el servicio y administra los accesos."
    ],
    significado: "Son las personas y organizaciones a las que se dirige Órbita Kids. El usuario de la aplicación no siempre es quien paga por ella.",
    incluye: "Edades, necesidades educativas, usuarios de la plataforma y organizaciones que pueden contratar las licencias.",
    preguntas: [
      "¿Quién utiliza la aplicación móvil?",
      "¿Qué edades tienen los estudiantes?",
      "¿Qué necesitan los docentes?",
      "¿Quién contrata y paga las licencias?"
    ],
    aplicacion: "Órbita Kids se dirige principalmente a niños de 6 a 9 años que cursan los primeros tres grados de primaria. Los estudiantes utilizan la aplicación móvil para practicar matemáticas mediante una experiencia de videojuego. Los docentes utilizan la PWA para administrar grupos, asignar actividades y consultar resultados. Las escuelas son los clientes institucionales potenciales que contratan los planes y distribuyen los accesos.",
    ejemplo: "Una escuela primaria contrata una licencia para 100 estudiantes. El administrador escolar organiza sus grupos, genera códigos de acceso y los entrega a los alumnos. Los docentes consultan el desempeño de sus grupos desde la plataforma web.",
    relacion: "La edad y las necesidades de los estudiantes determinan el contenido educativo. Las necesidades de docentes y escuelas orientan las funciones administrativas y los planes de pago.",
    relacionados: ["valor", "ingresos", "relaciones"],
    elementos: [
      {
        titulo: "Niños de 6 a 7 años",
        descripcion: "Estudiantes de 1.º de primaria que practican sumas sencillas con apoyo visual y actividades guiadas."
      },
      {
        titulo: "Niños de 7 a 8 años",
        descripcion: "Estudiantes de 2.º de primaria que avanzan a ejercicios de sumas de dificultad intermedia."
      },
      {
        titulo: "Niños de 8 a 9 años",
        descripcion: "Estudiantes de 3.º de primaria que practican ejercicios con mayor dificultad y menos apoyo visual."
      },
      {
        titulo: "Docentes",
        descripcion: "Utilizan la PWA para organizar grupos, asignar actividades, revisar resultados e identificar temas que necesitan refuerzo."
      },
      {
        titulo: "Escuelas e instituciones",
        descripcion: "Contratan licencias según la cantidad de estudiantes y las funciones que necesitan. Administran los códigos de acceso de sus alumnos."
      }
    ],
    nota: "El público inicial será de niños de 6 a 9 años, docentes y escuelas de primaria. La meta de crecimiento se validará mediante pilotos y retroalimentación de las instituciones."
  },

  {
    id: "valor",
    numero: 2,
    titulo: "Propuesta de valor",
    categoria: "Valor",
    color: "green",
    pregunta: "¿Qué nos hace diferentes?",
    resumen: [
      "Matemáticas con temática espacial",
      "Práctica progresiva y adaptativa",
      "Seguimiento del aprendizaje"
    ],
    significado: "Es el conjunto de beneficios que diferencia a Órbita Kids y ayuda a resolver las necesidades de sus usuarios.",
    incluye: "La experiencia educativa, las características de la aplicación, los beneficios para estudiantes y las herramientas para docentes.",
    preguntas: [
      "¿Cómo hacemos más atractivas las matemáticas?",
      "¿Cómo ayudamos cuando un niño se equivoca?",
      "¿Qué información recibe el docente?"
    ],
    aplicacion: "Órbita Kids combina la práctica de matemáticas con una aventura espacial. Los niños resuelven ejercicios para avanzar por planetas, completar misiones, reparar su nave y obtener recompensas. La aplicación plantea actividades progresivas y apoyo según el desempeño, mientras que la PWA permite a los docentes consultar resultados y detectar temas que requieren refuerzo.",
    ejemplo: "Un estudiante resuelve una suma para obtener energía para su nave. Si tiene dificultades, la aplicación puede ofrecer apoyo visual y ejercicios más sencillos. El resultado se registra para que el docente pueda revisar su avance.",
    relacion: "La propuesta responde a las necesidades de los niños, docentes y escuelas. Requiere desarrollo de software, contenido matemático, pruebas de usabilidad y evaluación educativa.",
    relacionados: ["segmentos", "recursos", "actividades"],
    elementos: [
      {
        titulo: "Aventura espacial educativa",
        descripcion: "Personajes, planetas, nave y misiones que convierten la práctica matemática en una experiencia interactiva."
      },
      {
        titulo: "Actividades progresivas",
        descripcion: "Ejercicios organizados por dificultad, con apoyos visuales y oportunidades para volver a practicar."
      },
      {
        titulo: "Refuerzo según el desempeño",
        descripcion: "Reglas programadas pueden ofrecer ayuda adicional cuando se detectan errores. Su eficacia deberá probarse con estudiantes."
      },
      {
        titulo: "Seguimiento para docentes",
        descripcion: "La PWA permite consultar resultados, progreso y dificultades frecuentes para orientar el refuerzo."
      },
      {
        titulo: "Acceso administrado por la escuela",
        descripcion: "Códigos individuales y de grupo facilitan la incorporación de alumnos a las licencias institucionales."
      }
    ],
    nota: "La diferenciación propuesta es la combinación de gamificación espacial, práctica progresiva y seguimiento docente. Sus beneficios educativos deberán evaluarse mediante pruebas y pilotos escolares."
  },

  {
    id: "canales",
    numero: 3,
    titulo: "Canales",
    categoria: "Personas",
    color: "blue",
    pregunta: "¿Cómo llegamos a las escuelas?",
    resumen: [
      "Aplicación móvil para estudiantes",
      "PWA para docentes",
      "Redes sociales y contacto escolar"
    ],
    significado: "Son los medios para dar a conocer Órbita Kids, facilitar su contratación y entregar el servicio a los usuarios.",
    incluye: "Canales de difusión, demostraciones, acceso a la plataforma y comunicación con instituciones educativas.",
    preguntas: [
      "¿Cómo conocerán las escuelas el proyecto?",
      "¿Cómo accederán los estudiantes?",
      "¿Cómo se enterarán los clientes de las novedades?"
    ],
    aplicacion: "Órbita Kids utilizará redes sociales, correo electrónico y contacto directo con escuelas para dar a conocer sus funciones y posibles planes de suscripción. La aplicación móvil permitirá a los estudiantes practicar y la PWA permitirá a los docentes administrar grupos y consultar el progreso.",
    ejemplo: "El equipo publica una demostración de una misión matemática en redes sociales. Una escuela solicita información por correo, recibe una demostración de la PWA y, si decide contratar un plan, obtiene acceso a la plataforma para administrar sus grupos.",
    relacion: "Los canales conectan a los clientes con la propuesta de valor. Las demostraciones ayudan a generar confianza y las plataformas digitales permiten utilizar el servicio.",
    relacionados: ["segmentos", "valor", "relaciones"],
    elementos: [
      {
        titulo: "Aplicación móvil en Flutter",
        descripcion: "Canal de aprendizaje para los niños, con actividades matemáticas, misiones, niveles y recompensas."
      },
      {
        titulo: "PWA docente en React",
        descripcion: "Plataforma web para administrar grupos, generar códigos, asignar actividades y revisar resultados."
      },
      {
        titulo: "Redes sociales",
        descripcion: "Facebook, Instagram y YouTube pueden utilizarse para publicar demostraciones, novedades, videos y avances del proyecto."
      },
      {
        titulo: "Correo electrónico",
        descripcion: "Medio para enviar información comercial, instrucciones de acceso, novedades y comunicaciones a las escuelas."
      },
      {
        titulo: "Contacto y demostraciones escolares",
        descripcion: "Presentaciones dirigidas a docentes y directivos para explicar el funcionamiento y recoger opiniones."
      }
    ],
    nota: "Las redes sociales, el correo y las demostraciones son canales propuestos. Su uso comercial dependerá de la preparación del producto y de la disponibilidad de los medios oficiales."
  },

  {
    id: "relaciones",
    numero: 4,
    titulo: "Relaciones con clientes",
    categoria: "Personas",
    color: "pink",
    pregunta: "¿Cómo acompañamos a los usuarios?",
    resumen: [
      "Comunicación de nuevas funciones",
      "Orientación para las escuelas",
      "Soporte y mejora continua"
    ],
    significado: "Describe cómo Órbita Kids mantiene la comunicación y acompaña a los usuarios y clientes durante el uso del servicio.",
    incluye: "Incorporación de escuelas, atención de dudas, anuncios de actualizaciones, retroalimentación y soporte.",
    preguntas: [
      "¿Cómo se informa una nueva funcionalidad?",
      "¿Cómo se atienden las dudas?",
      "¿Cómo se recogen opiniones para mejorar?"
    ],
    aplicacion: "La relación con las escuelas se mantendrá mediante correo electrónico, avisos dentro de la plataforma y publicaciones en redes sociales. Los docentes podrán recibir orientación para organizar grupos y administrar códigos. Los estudiantes recibirán retroalimentación durante sus actividades.",
    ejemplo: "Cuando se publique un nuevo conjunto de ejercicios, el equipo podrá mostrar la novedad en la PWA, enviar un aviso por correo a las escuelas y publicar una demostración. Los docentes podrán enviar comentarios sobre su utilidad.",
    relacion: "La comunicación permite que los clientes conozcan nuevas funciones y que el equipo reciba retroalimentación para mejorar el producto. El soporte requiere tiempo de trabajo y recursos operativos.",
    relacionados: ["canales", "actividades", "segmentos"],
    elementos: [
      {
        titulo: "Avisos dentro de la plataforma",
        descripcion: "Mostrar novedades, cambios importantes y nuevas actividades cuando estén disponibles."
      },
      {
        titulo: "Correo para escuelas",
        descripcion: "Enviar información sobre actualizaciones, renovación de licencias, instrucciones y comunicaciones importantes."
      },
      {
        titulo: "Redes sociales",
        descripcion: "Compartir demostraciones, publicaciones educativas, avances y anuncios de nuevas funcionalidades."
      },
      {
        titulo: "Orientación y soporte",
        descripcion: "Ayudar a docentes y administradores a organizar grupos, entregar códigos y resolver problemas de acceso."
      },
      {
        titulo: "Retroalimentación",
        descripcion: "Recoger sugerencias y reportes de errores para priorizar mejoras de usabilidad y contenido."
      }
    ],
    nota: "Estos mecanismos se plantean para una futura operación del servicio. Los avisos, el correo automatizado y el soporte deberán implementarse y probarse."
  },

  {
    id: "ingresos",
    numero: 5,
    titulo: "Fuentes de ingresos",
    categoria: "Sostenibilidad",
    color: "yellow",
    pregunta: "¿Cómo monetizamos Órbita Kids?",
    resumen: [
      "Funciones básicas gratuitas",
      "Planes por estudiantes y funciones",
      "Licencias mensuales y anuales"
    ],
    significado: "Describe cómo el proyecto podría recibir ingresos mediante el pago de instituciones educativas por el acceso a funciones y capacidades adicionales.",
    incluye: "Modalidades gratuitas y de pago, límites por estudiantes, funcionalidades incluidas, periodos de suscripción y licencias escolares.",
    preguntas: [
      "¿Qué puede utilizar una escuela gratuitamente?",
      "¿Qué funciones justifican un plan de pago?",
      "¿Cómo se administran los pagos y códigos?"
    ],
    aplicacion: "Órbita Kids propone un modelo freemium: las escuelas podrán utilizar permanentemente una versión básica gratuita y contratar planes de pago para administrar más estudiantes y acceder a funciones adicionales. Los planes podrán pagarse mensualmente o anualmente. La escuela pagará la licencia y administrará los códigos individuales y de grupo que se entreguen a sus alumnos.",
    ejemplo: "Una escuela comienza con el plan gratuito para probar las actividades básicas. Si necesita administrar más alumnos, grupos o reportes, contrata un plan superior. Después del pago, la escuela genera o administra los códigos de acceso incluidos en su licencia.",
    relacion: "Los ingresos deben financiar alojamiento, respaldos, mantenimiento, soporte y, en un escenario de crecimiento, la contratación del equipo. Los precios propuestos deberán probarse con instituciones antes de considerarse definitivos.",
    relacionados: ["segmentos", "valor", "costos"],
    elementos: [
      {
        titulo: "Plan gratuito",
        descripcion: "Acceso permanente a funciones básicas, con límites de estudiantes y herramientas para que las escuelas conozcan la plataforma."
      },
      {
        titulo: "Plan Aula — propuesta",
        descripcion: "$799 MXN mensuales o $8,150 MXN anuales, aproximadamente. Propuesta para hasta 50 estudiantes y 5 docentes, con actividades ampliadas y seguimiento del grupo."
      },
      {
        titulo: "Plan Escuela — propuesta",
        descripcion: "$1,799 MXN mensuales o $18,350 MXN anuales, aproximadamente. Propuesta para hasta 150 estudiantes, más grupos y reportes ampliados."
      },
      {
        titulo: "Licencia institucional — propuesta",
        descripcion: "$4,999 MXN mensuales o $50,990 MXN anuales, aproximadamente. Propuesta para hasta 500 estudiantes y funciones de administración ampliadas."
      },
      {
        titulo: "Administración de códigos",
        descripcion: "La escuela contrata la licencia y distribuye códigos individuales o de grupo dentro de los límites del plan contratado."
      }
    ],
    nota: "Los precios son propuestas académicas, no tarifas comerciales confirmadas. Los importes anuales ilustran un descuento cercano al 15 %. Se deben validar la disposición de pago de las escuelas, los costos reales, los impuestos y las condiciones de renovación. Los códigos de acceso no sustituyen el control de licencias."
  },

  {
    id: "recursos",
    numero: 6,
    titulo: "Recursos clave",
    categoria: "Operación",
    color: "violet",
    pregunta: "¿Qué necesitamos para operar?",
    resumen: [
      "Flutter, React, FastAPI y MySQL",
      "VPS y herramientas de desarrollo",
      "Equipo de 5 integrantes"
    ],
    significado: "Son los recursos humanos, tecnológicos y educativos necesarios para construir, desplegar y mantener Órbita Kids.",
    incluye: "Aplicaciones, infraestructura, base de datos, contenido matemático, herramientas de trabajo y responsabilidades del equipo.",
    preguntas: [
      "¿Qué tecnologías utiliza el producto?",
      "¿Qué infraestructura necesitamos?",
      "¿Quién se responsabiliza de cada área?"
    ],
    aplicacion: "Órbita Kids contempla una aplicación móvil para estudiantes desarrollada con Flutter y Dart, una PWA docente con React, una API con FastAPI y una base de datos MySQL. La infraestructura propuesta es un VPS con capacidad ampliable, respaldos y medidas de seguridad. El proyecto cuenta con cinco integrantes, de los cuales tres participan en desarrollo.",
    ejemplo: "La aplicación móvil envía las respuestas a la API de FastAPI. La API valida los datos y los guarda en MySQL. La PWA permite que el docente consulte resultados y gestione grupos. Los servicios se desplegarán en un VPS cuya capacidad se revisará mediante pruebas de carga.",
    relacion: "Los recursos permiten ejecutar las actividades clave y determinan los costos de infraestructura, mantenimiento, desarrollo y soporte.",
    relacionados: ["actividades", "valor", "costos"],
    elementos: [
      {
        titulo: "Yazmin — Frontend y líder de equipo",
        descripcion: "Coordina las tareas del equipo y participa en el desarrollo de interfaces y experiencia de usuario."
      },
      {
        titulo: "Michelle — Backend",
        descripcion: "Participa en el desarrollo de la API, la lógica de negocio y la comunicación con la base de datos."
      },
      {
        titulo: "Obed Guzmán — Backend y documentación",
        descripcion: "Participa en el backend y apoya la documentación técnica, los procedimientos y la entrega del proyecto."
      },
      {
        titulo: "Citlalli — QA",
        descripcion: "Diseña y ejecuta pruebas, registra errores y verifica las correcciones y el funcionamiento de la plataforma."
      },
      {
        titulo: "Jennifer — Documentación",
        descripcion: "Apoya la preparación y organización de documentos, guías y materiales de entrega."
      },
      {
        titulo: "Infraestructura tecnológica",
        descripcion: "Flutter/Dart, React, FastAPI, MySQL, Git/GitHub, Docker y un VPS. Monitoreo y respaldos se incorporarán según las necesidades."
      },
      {
        titulo: "Contenido educativo",
        descripcion: "Ejercicios de sumas, niveles, apoyos visuales, personajes, planetas, recompensas y reglas de refuerzo."
      }
    ],
    nota: "El equipo actual es estudiantil y no tiene salarios asignados en este presupuesto. Los sueldos se calcularán como un escenario futuro de contratación. La infraestructura y las herramientas deberán verificarse antes del despliegue."
  },

  {
    id: "actividades",
    numero: 7,
    titulo: "Actividades clave",
    categoria: "Operación",
    color: "violet",
    pregunta: "¿Qué debemos realizar?",
    resumen: [
      "Desarrollar app, PWA y API",
      "Crear actividades matemáticas",
      "Probar, desplegar y mantener"
    ],
    significado: "Son las tareas fundamentales que el equipo necesita realizar para construir, publicar y mejorar el servicio educativo.",
    incluye: "Diseño, programación, contenido, pruebas, despliegue, seguridad, soporte y actualización de la plataforma.",
    preguntas: [
      "¿Qué debe desarrollar el equipo?",
      "¿Cómo se preparan las actividades educativas?",
      "¿Cómo comprobamos que todo funcione?"
    ],
    aplicacion: "El trabajo comprende diseñar la experiencia espacial, desarrollar la aplicación móvil y la PWA, implementar la API y MySQL, crear ejercicios matemáticos, integrar el sistema de códigos, probar el funcionamiento y mantener el servicio. También se realizarán pilotos para conocer las necesidades de docentes y estudiantes.",
    ejemplo: "El equipo desarrolla una misión de sumas. El estudiante responde en la aplicación, FastAPI registra el resultado en MySQL y la PWA muestra el progreso. QA verifica el registro, los permisos y los reportes antes de liberar la función.",
    relacion: "Las actividades aprovechan los recursos tecnológicos y humanos. Las escuelas y docentes pueden colaborar en pilotos, mientras que los resultados orientan mejoras del producto.",
    relacionados: ["recursos", "socios", "costos"],
    elementos: [
      {
        titulo: "Diseñar la experiencia educativa",
        descripcion: "Definir la historia, los personajes, los planetas, las misiones, los niveles y las recompensas."
      },
      {
        titulo: "Desarrollar la app móvil",
        descripcion: "Implementar con Flutter las actividades, la navegación, los niveles y el progreso de los estudiantes."
      },
      {
        titulo: "Desarrollar la PWA docente",
        descripcion: "Implementar con React la administración de grupos, asignaciones, códigos y reportes."
      },
      {
        titulo: "Construir backend y base de datos",
        descripcion: "Desarrollar con FastAPI y MySQL la autenticación, los permisos, las licencias, los grupos, las actividades y los resultados."
      },
      {
        titulo: "Crear y revisar contenido matemático",
        descripcion: "Preparar sumas por nivel, apoyos visuales y reglas de refuerzo que puedan probarse con docentes."
      },
      {
        titulo: "Realizar pruebas de calidad",
        descripcion: "Comprobar funciones, permisos, códigos, errores, seguridad básica, usabilidad y funcionamiento con distintos dispositivos."
      },
      {
        titulo: "Desplegar y mantener",
        descripcion: "Configurar el VPS, respaldos, monitoreo, actualizaciones, correcciones y soporte."
      },
      {
        titulo: "Ejecutar pilotos escolares",
        descripcion: "Recoger retroalimentación de docentes y evaluar la experiencia antes de ampliar el número de usuarios."
      }
    ],
    nota: "Las actividades se realizarán por etapas. Primero se busca una versión funcional y un piloto; después se ampliará la capacidad de infraestructura y el alcance según los resultados."
  },

  {
    id: "socios",
    numero: 8,
    titulo: "Socios clave",
    categoria: "Operación",
    color: "violet",
    pregunta: "¿Quiénes pueden colaborar?",
    resumen: [
      "Escuelas piloto",
      "Docentes y especialistas pedagógicos",
      "Proveedores tecnológicos"
    ],
    contexto: [
      "Colaboraciones propuestas",
      "Las alianzas deberán establecerse y confirmarse."
    ],
    significado: "Son las organizaciones y personas externas que pueden aportar conocimientos, espacios de prueba o servicios para facilitar el desarrollo y la adopción de Órbita Kids.",
    incluye: "Qué aporta cada colaborador, cómo participa y qué beneficio puede obtener de la relación.",
    preguntas: [
      "¿Quién puede revisar las actividades?",
      "¿Dónde se puede probar el producto?",
      "¿Qué servicios necesitamos contratar?"
    ],
    aplicacion: "Órbita Kids buscará colaborar con escuelas para realizar pilotos, con docentes para revisar la utilidad de las actividades, con especialistas pedagógicos para orientar el contenido y con proveedores tecnológicos para alojar y mantener los servicios.",
    ejemplo: "El equipo contacta a una escuela para presentar la plataforma. Los docentes revisan las actividades, un grupo participa en un piloto y la institución comparte comentarios. Si el servicio resulta útil, la escuela podría evaluar contratar una licencia.",
    relacion: "Los socios pueden facilitar pruebas, revisión educativa y operación tecnológica. Una escuela puede participar primero como colaboradora de un piloto y después decidir si contrata el servicio.",
    relacionados: ["actividades", "recursos", "segmentos"],
    elementos: [
      {
        titulo: "Escuelas de primaria",
        descripcion: "Pueden facilitar pilotos, aportar opiniones sobre la experiencia y evaluar si la plataforma responde a necesidades reales."
      },
      {
        titulo: "Docentes",
        descripcion: "Pueden revisar instrucciones, niveles de dificultad, asignaciones y reportes para mejorar su utilidad educativa."
      },
      {
        titulo: "Especialistas pedagógicos",
        descripcion: "Pueden orientar el diseño de ejercicios, la progresión de dificultad y los apoyos para estudiantes con dificultades."
      },
      {
        titulo: "Proveedores de hosting y dominio",
        descripcion: "Pueden proporcionar el VPS, el dominio y los servicios necesarios para desplegar y mantener la plataforma."
      },
      {
        titulo: "Proveedores de herramientas",
        descripcion: "GitHub y otras herramientas pueden apoyar el control de versiones, la colaboración, las pruebas y el mantenimiento."
      }
    ],
    nota: "Estos son socios y colaboradores potenciales. No se afirma que existan convenios o alianzas comerciales confirmadas. Los servicios de terceros se seleccionarán según costo, seguridad y necesidades del proyecto."
  },

  {
    id: "costos",
    numero: 9,
    titulo: "Estructura de costos",
    categoria: "Sostenibilidad",
    color: "yellow",
    pregunta: "¿Cuánto cuesta desarrollar y operar?",
    resumen: [
      "Piloto: hosting desde ~$274 MXN/mes",
      "Operación inicial: ~$700–$1,500 MXN/mes",
      "Equipo contratado: escenario futuro"
    ],
    significado: "Reúne los gastos necesarios para construir, desplegar y mantener Órbita Kids, distinguiendo los gastos actuales del equipo estudiantil y los costos de una operación comercial futura.",
    incluye: "Hosting, dominio, respaldos, mantenimiento, soporte, personal contratado y otros servicios necesarios.",
    preguntas: [
      "¿Cuánto cuesta la infraestructura?",
      "¿Qué gastos existen actualmente?",
      "¿Cuánto costaría contratar al equipo?",
      "¿Qué ingresos cubrirían esos gastos?"
    ],
    aplicacion: "El equipo actual es estudiantil y cada integrante cuenta con computadora, por lo que no se contempla una compra inicial de cinco equipos ni el pago actual de salarios. Para el piloto se propone presupuestar infraestructura, dominio y servicios auxiliares. En un escenario comercial futuro se deben sumar los salarios, las prestaciones, los impuestos y el mantenimiento del producto.",
    ejemplo: "Para un piloto, un VPS de entrada puede costar alrededor de $274 MXN al mes al precio de renovación publicado. Si el proyecto crece, podría requerir un servidor más potente y servicios adicionales. La contratación de cinco personas debe calcularse como un escenario separado, no como un gasto que el equipo ya esté realizando.",
    relacion: "Los costos dependen de los recursos y las actividades. Los ingresos de los planes de pago deberán cubrir la infraestructura, el mantenimiento y, si el negocio crece, el costo de contratar al equipo.",
    relacionados: ["recursos", "actividades", "ingresos"],
    elementos: [
      {
        titulo: "VPS para el piloto",
        descripcion: "Referencia de mercado: Hostinger KVM 2 se publica en $154.99 MXN al mes en la oferta consultada y se renueva en $273.99 MXN al mes. Incluye 2 vCPU, 8 GB de RAM y 100 GB NVMe. El precio depende del plazo contratado."
      },
      {
        titulo: "Escalamiento de infraestructura",
        descripcion: "Si crece la cantidad de usuarios simultáneos, podría requerirse un VPS superior, una base de datos separada, más almacenamiento o servicios adicionales. Debe decidirse mediante pruebas de carga."
      },
      {
        titulo: "Dominio y servicios auxiliares",
        descripcion: "Presupuesto inicial orientativo de $300–$600 MXN al año para dominio y $100–$300 MXN al mes para servicios auxiliares o respaldos adicionales, según proveedor y configuración. Son estimaciones por cotizar."
      },
      {
        titulo: "Equipo de cómputo",
        descripcion: "Costo inicial estimado de $0 MXN en nuevas computadoras, porque los cinco integrantes ya cuentan con equipo propio. No incluye reparaciones o futuras renovaciones."
      },
      {
        titulo: "Salarios futuros de desarrollo",
        descripcion: "Escenario ilustrativo: Yazmin $18,000, Michelle $20,000 y Obed $18,000 MXN mensuales. Total estimado de los tres puestos de desarrollo: $56,000 MXN al mes."
      },
      {
        titulo: "QA y documentación futuros",
        descripcion: "Escenario ilustrativo: Citlalli $14,000 y Jennifer $12,000 MXN mensuales. Total estimado de ambos puestos: $26,000 MXN al mes."
      },
      {
        titulo: "Costo futuro del equipo",
        descripcion: "Los cinco puestos sumarían aproximadamente $82,000 MXN al mes en remuneraciones ilustrativas, antes de prestaciones, impuestos y otros costos laborales. No son salarios actuales ni cotizaciones de contratación."
      },
      {
        titulo: "Presupuesto operativo del piloto",
        descripcion: "Como referencia académica, reservar aproximadamente $700–$1,500 MXN mensuales para hosting, dominio prorrateado y servicios auxiliares. No incluye sueldos, trabajo adicional contratado, comisiones ni impuestos."
      }
    ],
    nota: "Las cifras son estimaciones para planear el proyecto, salvo el precio de hosting identificado como referencia publicada. No hay compra de equipo ni salarios actuales presupuestados. Los importes deben cotizarse y actualizarse antes de invertir. Un VPS no garantiza capacidad para una cantidad específica de usuarios; se requieren pruebas de carga."
  }
];

// ============================================================
// ICONOS SVG LOCALES
// ============================================================

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

// Ilustraciones originales: se conservan las rutas locales.
const ilustraciones = {
  segmentos: { alt: "Estudiantes, docente y escuela, los públicos de Órbita Kids.", pie: "Niños, docentes y escuelas forman la comunidad educativa." },
  valor: { alt: "Una niña aprende con una tableta junto a planetas y un cohete.", pie: "Aprender, recibir apoyo y avanzar con una misión espacial." },
  canales: { alt: "Un teléfono, una computadora, una escuela y un megáfono.", pie: "La aplicación, la PWA y la difusión conectan con las aulas." },
  relaciones: { alt: "Una docente acompaña a una estudiante con un reporte.", pie: "Acompañamiento, comunicación y seguimiento docente." },
  ingresos: { alt: "Una escuela, una tarjeta de suscripción y monedas.", pie: "Las licencias institucionales pueden sostener el servicio." },
  recursos: { alt: "Computadora, teléfono, base de datos y recursos educativos.", pie: "Tecnología y contenido educativo hacen posible la misión." },
  actividades: { alt: "Una docente y un desarrollador diseñan actividades.", pie: "Diseñar, desarrollar, probar y mejorar." },
  socios: { alt: "Colaboradores, una escuela, un libro y servicios tecnológicos.", pie: "Escuelas, especialistas y proveedores: colaboración por construir." },
  costos: { alt: "Calculadora, monedas, libros y servidores.", pie: "Planificar la inversión y los gastos de operación." }
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

// Escapar texto para insertarlo sin interpretarlo como HTML.
function escapar(texto) {
  return String(texto).replace(/[&<>"']/g, caracter => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;"
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
  document.querySelector("#detail-number").textContent =
    `BLOQUE ${String(bloque.numero).padStart(2, "0")} · ${bloque.categoria.toLocaleUpperCase("es")}`;
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
  const etiquetas = {
    estudiante: "Estudiante",
    materia: "Materia",
    grupo: "Grupo",
    fecha: "Fecha"
  };

  const datos = Object.entries(datosAcademicos).filter(([, valor]) => valor.trim());
  const contenedor = document.querySelector("#academic-data");

  contenedor.hidden = datos.length === 0;
  contenedor.innerHTML = datos.map(([clave, valor]) =>
    `<div><dt>${etiquetas[clave]}</dt><dd>${escapar(valor)}</dd></div>`
  ).join("");
}

grid.addEventListener("click", evento => {
  const boton = evento.target.closest("[data-block]");
  if (boton) {
    mostrarBloque(bloques.findIndex(bloque => bloque.id === boton.dataset.block));
  }
});

content.addEventListener("click", evento => {
  const boton = evento.target.closest("[data-related]");
  if (boton) {
    mostrarBloque(bloques.findIndex(bloque => bloque.id === boton.dataset.related));
  }
});

closeButton.addEventListener("click", () => dialog.close());
previousButton.addEventListener("click", () => mostrarBloque(indiceActual - 1));
nextButton.addEventListener("click", () => mostrarBloque(indiceActual + 1));

// Restaurar el foco en la tarjeta de origen al cerrar el diálogo.
dialog.addEventListener("close", () => {
  document.body.classList.remove("modal-open");

  if (botonOrigen instanceof HTMLElement && botonOrigen.isConnected) {
    botonOrigen.focus({ preventScroll: true });
  }
});

// Cerrar solo si el gesto comienza y termina fuera del diálogo.
function estaFuera(evento) {
  const rect = dialog.getBoundingClientRect();

  return evento.clientX < rect.left ||
    evento.clientX > rect.right ||
    evento.clientY < rect.top ||
    evento.clientY > rect.bottom;
}

dialog.addEventListener("pointerdown", evento => {
  inicioEnFondo = evento.target === dialog && estaFuera(evento);
});

dialog.addEventListener("click", evento => {
  if (inicioEnFondo && evento.target === dialog && estaFuera(evento)) {
    dialog.close();
  }

  inicioEnFondo = false;
});

// Mantener la navegación de Tab dentro del diálogo.
dialog.addEventListener("keydown", evento => {
  if (evento.key !== "Tab") return;

  const controles = [...dialog.querySelectorAll("button:not(:disabled), a[href]")];
  const primero = controles[0];
  const ultimo = controles[controles.length - 1];

  if (!primero || !ultimo) return;

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

// Control de efectos decorativos y preferencia de movimiento reducido.
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
