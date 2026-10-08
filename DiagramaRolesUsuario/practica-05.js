const fichas = [
  {
    id: "student", titulo: "Estudiante", tipo: "Rol principal · Usuario principal", color: "blue",
    subtitulo: "App móvil · Aprendizaje y misión espacial",
    descripcion: "Utiliza la aplicación móvil para resolver actividades matemáticas, avanzar en la misión espacial y consultar su progreso.",
    funciones: ["Actividades matemáticas", "Refuerzo adaptado", "Progreso y misión espacial"],
    relacion: "El estudiante utiliza la app móvil de Órbita Kids para practicar matemáticas y avanzar en su misión.",
    icono: ".avatar-student svg"
  },
  {
    id: "teacher", titulo: "Docente", tipo: "Rol principal · Usuario de seguimiento", color: "violet",
    subtitulo: "PWA docente · Gestión y seguimiento",
    descripcion: "Utiliza la PWA para administrar grupos, asignar actividades y consultar resultados y progreso.",
    funciones: ["Refuerzo adaptado", "Grupos y asignaciones", "Resultados y seguimiento"],
    relacion: "El docente usa la PWA para gestionar actividades y consultar información que le ayude a identificar necesidades de refuerzo.",
    icono: ".avatar-teacher svg"
  },
  {
    id: "school", titulo: "Escuela / Institución", tipo: "Actor externo · Contexto de adopción", color: "yellow",
    subtitulo: "Pilotos · Demostraciones · Licencias",
    descripcion: "Contexto institucional donde Órbita Kids puede ser adoptado mediante pilotos y licencias.",
    funciones: ["Adopción institucional", "Pilotos escolares", "Licencia de la plataforma"],
    relacion: "La escuela representa el contexto de adopción. Esta versión no contempla una interfaz específica para este actor.",
    icono: ".school-icon svg"
  },
  {
    id: "activities", titulo: "Actividades matemáticas", tipo: "Funcionalidad · Estudiante", color: "blue",
    subtitulo: "Sumas interactivas · Niveles de dificultad",
    descripcion: "Sumas interactivas y diferentes niveles de dificultad.",
    funciones: ["Resolver ejercicios de sumas", "Practicar en niveles de dificultad"],
    relacion: "El estudiante utiliza esta función en la aplicación móvil de Órbita Kids.",
    actores: ["student"], icono: ".feature-blue .feature-icon svg"
  },
  {
    id: "reinforcement", titulo: "Refuerzo adaptado", tipo: "Funcionalidad · Estudiante y docente", color: "green",
    subtitulo: "Apoyo según aciertos y errores",
    descripcion: "Apoyo y ajuste según aciertos y errores.",
    funciones: ["Proporcionar apoyo visual", "Ajustar la dificultad mediante reglas de refuerzo"],
    relacion: "El estudiante recibe apoyo durante la práctica. El docente consulta el desempeño para decidir qué contenidos requieren más práctica.",
    actores: ["student", "teacher"], icono: ".feature-green .feature-icon svg"
  },
  {
    id: "mission", titulo: "Progreso y misión espacial", tipo: "Funcionalidad · Estudiante", color: "violet",
    subtitulo: "Planetas · Nave · Recompensas",
    descripcion: "Planetas, nave, progreso y recompensas.",
    funciones: ["Avanzar por planetas y niveles", "Reparar la nave espacial", "Obtener recompensas y visualizar el progreso"],
    relacion: "El estudiante vive la misión en la app móvil; su progreso y resultados quedan registrados para el seguimiento docente.",
    actores: ["student"], icono: ".feature-violet .feature-icon svg"
  },
  {
    id: "groups", titulo: "Grupos y asignaciones", tipo: "Funcionalidad · Docente", color: "pink",
    subtitulo: "Administración de grupos · Actividades",
    descripcion: "Administrar grupos y actividades.",
    funciones: ["Administrar grupos", "Asignar actividades matemáticas"],
    relacion: "El docente gestiona sus grupos desde la PWA y asigna actividades a sus estudiantes.",
    actores: ["teacher"], icono: ".feature-pink .feature-icon svg"
  },
  {
    id: "results", titulo: "Resultados y seguimiento", tipo: "Funcionalidad · Docente", color: "yellow",
    subtitulo: "Progreso · Errores · Necesidades de refuerzo",
    descripcion: "Progreso, errores y necesidades de refuerzo.",
    funciones: ["Consultar resultados y errores", "Revisar el progreso", "Identificar qué ejercicios requieren más práctica"],
    relacion: "El docente consulta la información de desempeño en la PWA y la utiliza para orientar el refuerzo.",
    actores: ["teacher"], icono: ".feature-yellow .feature-icon svg"
  }
];

const plataforma = {
  titulo: "Órbita Kids",
  tipo: "Núcleo central · Plataforma educativa",
  color: "violet",
  subtitulo: "Plataforma educativa de matemáticas",
  descripcion: "Órbita Kids conecta la experiencia móvil del estudiante con las herramientas de seguimiento docente y el contexto institucional de adopción.",
  funciones: ["Actividades matemáticas", "Refuerzo adaptado", "Progreso y misión espacial", "Grupos y asignaciones", "Resultados y seguimiento"],
  relacion: "El estudiante y el docente interactúan con la plataforma desde sus experiencias correspondientes. La escuela representa el contexto de adopción institucional.",
  icono: ".core-logo img"
};

const dialogo = document.querySelector("#detail-dialog");
const contenido = document.querySelector("#detail-content");
const cerrar = document.querySelector("#close-dialog");
const anterior = document.querySelector("#previous-item");
const siguiente = document.querySelector("#next-item");
const posicion = document.querySelector("#detail-position");
const vistos = new Set();
let indiceActual = -1;
let botonOrigen = null;
let gestoEnBackdrop = false;

function escapar(texto) {
  return String(texto).replace(/[&<>"']/g, caracter => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
  })[caracter]);
}

function ilustracionDe(ficha) {
  const origen = document.querySelector(ficha.icono);
  if (!origen) return "";
  if (origen instanceof HTMLImageElement) return `<img src="${origen.getAttribute("src")}" alt="">`;
  return origen.outerHTML;
}

function abrirFicha(ficha, indice = -1, origen = document.activeElement) {
  const yaAbierto = dialogo.open;
  if (!yaAbierto) botonOrigen = origen;
  indiceActual = indice;
  dialogo.style.setProperty("--accent", `var(--${ficha.color})`);
  document.querySelector("#detail-number").textContent = ficha.tipo.toLocaleUpperCase("es");
  document.querySelector("#detail-title").textContent = ficha.titulo;
  document.querySelector("#detail-subtitle").textContent = ficha.subtitulo;

  const rolNombres = { student: "Estudiante", teacher: "Docente" };
  const funciones = ficha.funciones.map(item => `<li>${escapar(item)}</li>`).join("");
  const roles = ficha.actores
    ? `<div class="detail-section"><h3>Roles relacionados</h3><div class="related-roles">${ficha.actores.map(id => `<span class="related-role ${id}"><i></i>${rolNombres[id]}</span>`).join("")}</div></div>`
    : "";

  contenido.innerHTML = `
    <section class="detail-hero">
      <div class="detail-illustration" aria-hidden="true">${ilustracionDe(ficha)}</div>
      <div><p class="detail-type">${escapar(ficha.tipo)}</p><p>${escapar(ficha.descripcion)}</p></div>
    </section>
    <section class="detail-section"><h3>${ficha.actores ? "Qué permite hacer" : "Funciones principales"}</h3><ul class="detail-list">${funciones}</ul></section>
    ${roles}
    <section class="detail-section"><h3>Interacción con Órbita Kids</h3><p class="detail-relation">${escapar(ficha.relacion)}</p></section>`;

  anterior.disabled = indice === 0;
  siguiente.disabled = indice === fichas.length - 1;
  if (indice === -1) {
    anterior.disabled = false;
    siguiente.disabled = false;
    posicion.textContent = "Núcleo · ficha central";
  } else {
    posicion.textContent = `${indice + 1} de ${fichas.length}`;
  }

  if (!yaAbierto) {
    dialogo.showModal();
    document.body.classList.add("modal-open");
  }
  cerrar.focus({ preventScroll: true });
  contenido.scrollTop = 0;
  if (indice >= 0) {
    vistos.add(ficha.id);
    const activador = document.querySelector(`[data-item="${ficha.id}"]`);
    if (activador) activador.dataset.seen = "true";
    document.querySelector("#explore-progress").textContent = `${vistos.size} de ${fichas.length} elementos explorados`;
  }
}

document.querySelector(".diagram-board").addEventListener("click", evento => {
  const boton = evento.target.closest("[data-item]");
  if (!boton) return;
  if (boton.dataset.item === "platform") {
    abrirFicha(plataforma, -1, boton);
    return;
  }
  const indice = fichas.findIndex(ficha => ficha.id === boton.dataset.item);
  if (indice !== -1) abrirFicha(fichas[indice], indice, boton);
});

function navegar(destino) {
  if (indiceActual === -1) {
    const indice = destino === "next" ? 0 : fichas.length - 1;
    abrirFicha(fichas[indice], indice, botonOrigen);
    return;
  }
  const indice = indiceActual + (destino === "next" ? 1 : -1);
  if (indice >= 0 && indice < fichas.length) abrirFicha(fichas[indice], indice, botonOrigen);
}

anterior.addEventListener("click", () => navegar("previous"));
siguiente.addEventListener("click", () => navegar("next"));
cerrar.addEventListener("click", () => dialogo.close());

dialogo.addEventListener("close", () => {
  document.body.classList.remove("modal-open");
  if (botonOrigen instanceof HTMLElement && botonOrigen.isConnected) botonOrigen.focus({ preventScroll: true });
});

function fueraDelDialogo(evento) {
  const rect = dialogo.getBoundingClientRect();
  return evento.clientX < rect.left || evento.clientX > rect.right || evento.clientY < rect.top || evento.clientY > rect.bottom;
}

dialogo.addEventListener("pointerdown", evento => {
  gestoEnBackdrop = evento.target === dialogo && fueraDelDialogo(evento);
});
dialogo.addEventListener("click", evento => {
  if (gestoEnBackdrop && evento.target === dialogo && fueraDelDialogo(evento)) dialogo.close();
  gestoEnBackdrop = false;
});

dialogo.addEventListener("keydown", evento => {
  if (evento.key !== "Tab") return;
  const controles = [...dialogo.querySelectorAll("button:not(:disabled), a[href]")];
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

const botonMovimiento = document.querySelector("#motion-toggle");
const movimientoReducido = window.matchMedia("(prefers-reduced-motion: reduce)");
function actualizarMovimiento() { botonMovimiento.hidden = movimientoReducido.matches; }
botonMovimiento.addEventListener("click", () => {
  const pausado = document.body.classList.toggle("motion-paused");
  const etiqueta = pausado ? "Reanudar animaciones" : "Pausar animaciones";
  botonMovimiento.setAttribute("aria-pressed", String(pausado));
  botonMovimiento.setAttribute("aria-label", etiqueta);
  botonMovimiento.title = etiqueta;
  botonMovimiento.querySelector(".motion-label").textContent = etiqueta;
  botonMovimiento.querySelector(".motion-icon").textContent = pausado ? "▶" : "Ⅱ";
});
movimientoReducido.addEventListener("change", actualizarMovimiento);
actualizarMovimiento();
