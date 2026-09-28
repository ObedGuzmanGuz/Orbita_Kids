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
    id: "segmentos", numero: 1, titulo: "Segmentos de clientes", categoria: "Personas", color: "blue",
    pregunta: "¿Para quién creamos valor?",
    resumen: ["Niños de primaria: usuarios finales", "Docentes: acompañamiento educativo", "Escuelas: posibles clientes"],
    contexto: ["Una comunidad educativa", "Las familias acompañan como usuarias indirectas."],
    significado: "Son los grupos de personas u organizaciones a quienes se dirige la propuesta. Usar la plataforma y pagar por ella pueden corresponder a actores distintos.",
    incluye: "Usuarios, necesidades educativas y responsables de decidir o financiar la adopción.",
    preguntas: ["¿Quién resuelve las actividades?", "¿Quién acompaña el aprendizaje?", "¿Quién decide y paga una licencia?"],
    aplicacion: "Los niños de primeros grados de primaria serían los usuarios finales. Los docentes asignarían ejercicios y consultarían avances. Las escuelas o instituciones serían posibles clientes de un plan institucional. Padres y tutores acompañarían el aprendizaje de manera indirecta; no se propone una interfaz familiar en la primera versión.",
    ejemplo: "Una escuela podría contratar el servicio para un grupo. La docente asignaría sumas y cada estudiante practicaría desde la aplicación móvil.",
    relacion: "Las necesidades de cada usuario orientan la propuesta de valor; el cliente institucional determina cómo se plantean los ingresos.",
    relacionados: ["valor", "ingresos", "relaciones"]
  },
  {
    id: "valor", numero: 2, titulo: "Propuesta de valor", categoria: "Valor", color: "green",
    pregunta: "¿Qué ofrecemos?",
    resumen: ["Matemáticas interactivas", "Refuerzo adaptado a los errores", "Seguimiento del progreso"],
    contexto: ["Aprender es la misión", "La exploración espacial motiva; el aprendizaje guía cada actividad."],
    significado: "Es el beneficio que la plataforma ofrece para atender una necesidad concreta de sus usuarios.",
    incluye: "La dificultad que se busca resolver, los beneficios educativos y las características que hacen útil la solución.",
    preguntas: ["¿Qué dificultad matemática queremos atender?", "¿Cómo cambia la ayuda cuando hay errores?", "¿Qué información necesita el docente?"],
    aplicacion: "Órbita Kids propone reforzar sumas con actividades visuales y selección de respuestas, tres niveles y reglas de adaptación. Los errores frecuentes activarían ejercicios más sencillos o mayor apoyo visual; al mejorar, aumentaría la dificultad. Personajes, planetas y reparación de la nave darían contexto al avance. La PWA permitiría identificar necesidades de refuerzo. Se buscarían instrucciones claras y controles accesibles, sin prometer resultados educativos aún no evaluados.",
    ejemplo: "Como regla ilustrativa por validar: tras tres errores consecutivos, ofrecer una suma menor con objetos contables; tras cuatro aciertos, volver a intentar el siguiente nivel. El ajuste nunca bajaría del nivel 1 ni superaría el 3.",
    relacion: "Responde a los segmentos de usuarios y requiere contenido educativo, reglas de adaptación y seguimiento docente.",
    relacionados: ["segmentos", "recursos", "actividades"]
  },
  {
    id: "canales", numero: 3, titulo: "Canales", categoria: "Personas", color: "blue",
    pregunta: "¿Cómo llegamos a las aulas?",
    resumen: ["App móvil para estudiantes", "PWA para docentes", "Sitio web y demostraciones escolares"],
    significado: "Son los medios para dar a conocer la propuesta, facilitar su adopción y entregar el servicio.",
    incluye: "Puntos de descubrimiento, acceso a la plataforma y distribución de su experiencia educativa.",
    preguntas: ["¿Cómo conocerá la escuela el proyecto?", "¿Dónde practicarán los estudiantes?", "¿Cómo accederá el docente?"],
    aplicacion: "Se proponen demostraciones y pilotos con instituciones para presentar el proyecto. Un sitio web explicaría su alcance. La app Flutter sería el canal de práctica del estudiante, y la PWA React permitiría al docente acceder desde el navegador. La disponibilidad de dispositivos y conectividad tendría que revisarse con cada escuela.",
    ejemplo: "Después de una demostración escolar, una docente accedería a la PWA para asignar una actividad que su grupo resolvería en la app móvil.",
    relacion: "Los canales conectan los segmentos con la propuesta de valor y requieren acompañamiento para la adopción.",
    relacionados: ["segmentos", "valor", "relaciones"]
  },
  {
    id: "relaciones", numero: 4, titulo: "Relaciones con clientes", categoria: "Personas", color: "pink",
    pregunta: "¿Cómo acompañamos?",
    resumen: ["Retroalimentación al estudiante", "Reportes para el docente", "Orientación y soporte escolar"],
    significado: "Describe cómo se acompaña a los usuarios y se mantiene una relación útil con los clientes a lo largo del tiempo.",
    incluye: "Orientación inicial, seguimiento, retroalimentación y mecanismos para atender dudas y mejorar el servicio.",
    preguntas: ["¿Qué ayuda recibe el niño al equivocarse?", "¿Cómo interpreta el docente el progreso?", "¿Cómo se atienden dudas de la escuela?"],
    aplicacion: "El estudiante recibiría retroalimentación clara y ejercicios ajustados a su desempeño. El docente consultaría resultados, errores y progreso para orientar el refuerzo. Las instituciones contarían con una guía inicial y un canal de soporte. Sus comentarios ayudarían a mejorar actividades e instrucciones.",
    ejemplo: "Si una estudiante acumula errores en sumas, recibiría apoyo visual. Su docente identificaría esa dificultad en el reporte y asignaría práctica adicional.",
    relacion: "El acompañamiento utiliza los canales y convierte los resultados de las actividades en seguimiento educativo.",
    relacionados: ["canales", "actividades", "segmentos"]
  },
  {
    id: "ingresos", numero: 5, titulo: "Fuentes de ingresos", categoria: "Sostenibilidad", color: "yellow",
    pregunta: "¿Cómo sostener la propuesta?",
    resumen: ["Licencia o suscripción escolar", "Plan institucional con más herramientas", "Acceso gratuito limitado para conocerla"],
    significado: "Son las formas en que el proyecto podría recibir pagos por el valor que entrega.",
    incluye: "Quién pagaría, por qué servicio y bajo qué modalidad. El acceso gratuito debe distinguirse de una fuente de ingresos.",
    preguntas: ["¿Qué servicio pagaría una institución?", "¿Qué incluiría el acceso gratuito?", "¿Los ingresos cubrirían los costos?"],
    aplicacion: "Se plantea una licencia institucional mediante suscripción escolar como opción principal, con gestión de grupos y herramientas adicionales de seguimiento. Un plan gratuito limitado permitiría conocer las actividades básicas, pero no produciría ingresos directos. Precios, límites y periodicidad se definirían después de validar necesidades y costos. No se contempla publicidad dirigida a niños ni venta de sus datos.",
    ejemplo: "Una escuela podría probar actividades básicas sin costo y después contratar un plan institucional para administrar más grupos y consultar reportes ampliados.",
    relacion: "La disposición de las instituciones a pagar debe contrastarse con la propuesta de valor y la estructura de costos.",
    relacionados: ["segmentos", "valor", "costos"]
  },
  {
    id: "recursos", numero: 6, titulo: "Recursos clave", categoria: "Operación", color: "violet",
    pregunta: "¿Qué necesitamos?",
    resumen: ["App, PWA, API y base de datos", "Banco de sumas y reglas adaptativas", "Equipo técnico y diseño educativo"],
    significado: "Son los activos y capacidades necesarios para construir y entregar la propuesta de valor.",
    incluye: "Tecnología, contenido, conocimiento pedagógico y personas que hacen posible el servicio.",
    preguntas: ["¿Qué contenido necesita la primera versión?", "¿Qué datos permiten ajustar el refuerzo?", "¿Qué equipo mantendrá la plataforma?"],
    aplicacion: "Se propone Flutter con Dart para estudiantes y React para la PWA docente, conectados a una API REST con FastAPI. PostgreSQL almacenaría usuarios y roles de docentes y estudiantes, grupos, actividades, resultados, progreso, errores y niveles. La API aplicaría reglas de adaptación y permisos de acceso; las interfaces no accederían directamente a la base de datos. También se necesita un banco de sumas, diseño visual y un equipo de desarrollo con orientación educativa.",
    ejemplo: "La app enviaría el resultado de una suma a FastAPI; la API registraría el intento en PostgreSQL y devolvería una actividad adecuada al nivel. El docente consultaría el progreso de su grupo desde React.",
    relacion: "Los recursos permiten realizar las actividades clave y generan costos de desarrollo, contenido e infraestructura.",
    relacionados: ["actividades", "valor", "costos"]
  },
  {
    id: "actividades", numero: 7, titulo: "Actividades clave", categoria: "Operación", color: "violet",
    pregunta: "¿Qué debemos hacer bien?",
    resumen: ["Crear y revisar actividades de sumas", "Desarrollar y probar la plataforma", "Evaluar y mejorar el refuerzo"],
    significado: "Son las tareas esenciales que el equipo debe realizar para que la propuesta funcione y siga siendo útil.",
    incluye: "Producción de contenido, desarrollo, evaluación del aprendizaje y operación continua.",
    preguntas: ["¿Cómo se revisa una actividad antes de publicarla?", "¿Qué errores indican necesidad de refuerzo?", "¿Cómo se comprobará la utilidad educativa?"],
    aplicacion: "Crear sumas en tres niveles y dos tipos de actividad; revisar instrucciones y apoyos visuales con docentes; desarrollar Flutter, React y la API; probar las reglas de adaptación y el registro del progreso. Los pilotos permitirían revisar errores frecuentes y claridad de las actividades. El mantenimiento atendería fallos, actualizaciones y soporte.",
    ejemplo: "El equipo detectaría que las instrucciones de una suma visual causan confusión, las revisaría con docentes y probaría la actividad corregida antes de incorporarla nuevamente.",
    relacion: "Estas tareas utilizan recursos, pueden apoyarse en socios educativos y generan costos recurrentes.",
    relacionados: ["recursos", "socios", "costos"]
  },
  {
    id: "socios", numero: 8, titulo: "Socios clave", categoria: "Operación", color: "violet",
    pregunta: "¿Con quién colaborar?",
    resumen: ["Escuelas para posibles pilotos", "Docentes y especialistas en pedagogía", "Proveedores de infraestructura"],
    contexto: ["Alianzas por construir", "Colaboraciones propuestas; no hay convenios confirmados."],
    significado: "Son los actores externos cuya colaboración puede aportar conocimientos, recursos o acceso al entorno educativo.",
    incluye: "Colaboradores potenciales, su aportación y el propósito de la relación. No toda relación es una alianza formal.",
    preguntas: ["¿Quién puede revisar el contenido educativo?", "¿Dónde se podría realizar un piloto?", "¿Qué servicios conviene contratar externamente?"],
    aplicacion: "Escuelas y docentes podrían apoyar pilotos y retroalimentación. Especialistas educativos y profesionales de pedagogía podrían revisar el nivel de las sumas y las reglas de refuerzo. Proveedores tecnológicos permitirían alojar la API y la base de datos como servicios contratados. Estas relaciones son propuestas, sin empresas ni acuerdos confirmados.",
    ejemplo: "Se propondría a una escuela revisar un conjunto de sumas con sus docentes y evaluar un piloto acotado antes de considerar una adopción institucional.",
    relacion: "La colaboración aporta recursos y ayuda a revisar las actividades. Una escuela puede ser colaboradora de un piloto y, por separado, posible cliente.",
    relacionados: ["actividades", "recursos", "segmentos"]
  },
  {
    id: "costos", numero: 9, titulo: "Estructura de costos", categoria: "Sostenibilidad", color: "yellow",
    pregunta: "¿En qué debemos invertir?",
    resumen: ["Desarrollo y diseño educativo", "Alojamiento, base de datos y soporte", "Contenido, pruebas y mantenimiento"],
    significado: "Reúne los gastos necesarios para crear, operar y mejorar el servicio.",
    incluye: "Costos iniciales y recurrentes, además de los gastos que podrían crecer con el número de usuarios.",
    preguntas: ["¿Qué se requiere antes del primer piloto?", "¿Qué gastos se repetirían cada mes?", "¿Qué costos crecerían con más grupos?"],
    aplicacion: "La inversión inicial incluiría desarrollo móvil y web, API, diseño de personajes, interfaz y banco de actividades. La operación requeriría alojamiento, PostgreSQL, copias de seguridad, mantenimiento, pruebas y soporte. El contenido educativo necesitaría revisión periódica. El uso de infraestructura y la atención a escuelas podrían aumentar al incorporar grupos. No se asignan montos sin un presupuesto validado.",
    ejemplo: "Para un piloto se presupuestaría el desarrollo de las actividades y su revisión. Después se estimaría el costo mensual de alojar la API, mantener la base de datos y atender dudas docentes.",
    relacion: "Los recursos y las actividades explican los gastos; la propuesta de ingresos debe permitir sostenerlos.",
    relacionados: ["recursos", "actividades", "ingresos"]
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
    <article class="canvas-card card-${bloque.id}" id="bloque-${bloque.id}">
      <div class="card-top"><span class="card-icon" aria-hidden="true"><svg viewBox="0 0 24 24">${iconos[bloque.id]}</svg></span><span class="card-number" aria-hidden="true">${String(bloque.numero).padStart(2, "0")}</span></div>
      <h3 id="titulo-${bloque.id}">${escapar(bloque.titulo)}</h3>
      <p class="card-question">${escapar(bloque.pregunta)}</p>
      <ul class="card-summary">${bloque.resumen.map(texto => `<li>${escapar(texto)}</li>`).join("")}</ul>
      ${bloque.contexto ? `<p class="card-context"><span>${escapar(bloque.contexto[0])}</span>${escapar(bloque.contexto[1])}</p>` : ""}
      <button class="card-open" type="button" data-block="${bloque.id}" aria-haspopup="dialog" aria-controls="detail-dialog" aria-label="Ver detalle: ${escapar(bloque.titulo)}"><span>Ver detalle</span><span class="arrow" aria-hidden="true">↗</span></button>
    </article>
  `).join("");
}

function seccion(letra, titulo, contenido, clase = "") {
  return `<section class="detail-section ${clase}" aria-labelledby="seccion-${letra}"><h3 id="seccion-${letra}"><span class="section-letter" aria-hidden="true">${letra}</span>${titulo}</h3>${contenido}</section>`;
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
  content.innerHTML = [
    seccion("A", "¿Qué significa?", `<p>${escapar(bloque.significado)}</p>`),
    seccion("B", "¿Qué debe incluir este bloque?", `<p>${escapar(bloque.incluye)}</p>`),
    seccion("C", "Preguntas para comprenderlo", lista(bloque.preguntas)),
    seccion("D", "Aplicación en Órbita Kids", `<p>${escapar(bloque.aplicacion)}</p>`, "detail-application"),
    seccion("E", "Ejemplo sencillo", `<p>${escapar(bloque.ejemplo)}</p>`, "detail-example"),
    seccion("F", "Relación con otros bloques", `<p>${escapar(bloque.relacion)}</p><div class="relation-buttons">${bloque.relacionados.map(id => {
      const relacionado = bloques.find(item => item.id === id);
      return `<button type="button" data-related="${id}" aria-label="Consultar ${escapar(relacionado.titulo)}">${escapar(relacionado.titulo)} <span aria-hidden="true">↗</span></button>`;
    }).join("")}</div>`, "detail-relations")
  ].join("");

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
  dialog.scrollTop = 0;
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
dialog.addEventListener("pointerdown", evento => { inicioEnFondo = evento.target === dialog && estaFuera(evento); });
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
