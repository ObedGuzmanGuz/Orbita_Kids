# -*- coding: utf-8 -*-
def B(t, **kw): return (t, kw)
def stats(*i): return B("stats", items=list(i))
def hero(t, x, b, ic): return B("hero", title=t, text=x, button=b, ic=ic)
def grid(c, items, ch=None): return B("grid", cols=c, items=items, ch=ch)
def steps(items, title=None): return B("steps", items=items, title=title)
def form(fields, button=None): return B("form", fields=fields, button=button)
def note(t, x, ic=None): return B("note", title=t, text=x, ic=ic)
def chart(t, h=None): return B("chart", title=t)
def bars(t, items): return B("bars", title=t, items=items)
def question(h, t): return B("question", head=h, text=t)
def options(items, sel=None): return B("options", items=items, sel=sel)
def video(): return B("video")
def timer(t, time, x): return B("timer", title=t, time=time, text=x)
def check(t, items): return B("check", title=t, items=items)
def lst(items): return B("list", items=items)
def table(cols, rows, widths=None): return B("table", cols=cols, rows=rows, widths=widths)
def chips(items, active=0): return B("chips", items=items, active=active)
def search(ph): return B("search", ph=ph)
def toggles(items): return B("toggles", items=items)
def week(): return B("week")
def profile(n, s): return B("profile", name=n, sub=s)
def btn(l, k="primary"): return B("btn", label=l, kind=k)
def btns(*i): return B("btns", items=list(i))
def doc(t, hh=240): return B("doc", title=t, hh=hh)
def rubric(rows): return B("rubric", rows=rows)
def illus(ic, l="Ilustración", h=120): return B("illus", ic=ic, label=l)
def text(t, b): return B("text", title=t, body=b)
def evidence(n, t): return B("evidence", name=n, text=t)
def row(*spans): return ("row", list(spans))

SIG = note("IMPORTANTE", "Hazlo en un lugar seguro. Pide ayuda a un adulto o docente cuando corresponda.", "check")
NEXT = note("Siguiente paso", "Elige una experiencia corta y luego vuelve al entorno real.", "figure")
S3 = steps(["Revisa una idea", "Realiza la actividad sin pantalla", "Comparte lo que aprendiste"])
HELP = note("Aprende a tu ritmo", "Sesiones cortas con pausas y retos fuera de pantalla.", "clock")
RETOS4 = [("figure", "Circuito de pasos", "5 minutos"), ("dot", "Equilibrio", "Juego sin equipo"), ("sun", "Baile libre", "Con música"), ("clock", "Estiramientos", "Con supervisión")]
DOCS4 = [("doc", "Circuito aula", "PDF · 1 pág."), ("doc", "Observación", "PDF · 1 pág."), ("doc", "Diario lectura", "PDF · 2 pág."), ("doc", "Luz y sombra", "PDF · 1 pág.")]
DOCS8 = DOCS4 + [("doc", "Respiración", "PDF · 1 pág."), ("doc", "Ruta del patio", "PDF · 2 pág."), ("doc", "Retos familia", "PDF · 1 pág."), ("doc", "Rutina aula", "PDF · 1 pág.")]
CHART_STATS3 = stats(("Con pantalla", "35 min"), ("Sin pantalla", "95 min"), ("Pausas", "4"))
HERO_E = lambda t, x, ic: hero(t, x, "Abrir", ic)

SPECS = {}
def S(role, plat, slug, title_ui, sub, blocks, nav=0, side=0, crumb=""):
    SPECS[(role, plat, slug)] = dict(title_ui=title_ui, sub=sub, blocks=blocks, nav=nav, side=side, crumb=crumb)

E, P, M, W = "Estudiante", "Profesor", "Movil", "Web_PWA"

# ================= ESTUDIANTE · MÓVIL =================
S(E,M,"bienvenida","Bienvenido a Órbita Kids","Aprender también sucede fuera de la pantalla",
  [illus("sun","Ilustración 343×112"), text("¡Hola, explorador!","Aprende con videos cortos, juegos, paseos y actividades de la vida real."),
   hero("Primero aprendemos","Después exploramos sin celular","Comenzar","figure"),
   note("Una app con pausas","Sin desplazamiento infinito ni recompensas por estar conectado.","clock")], nav=-1)
S(E,M,"acceso","Iniciar sesión","Acceso sencillo para estudiantes",
  [form(["Correo electrónico","Contraseña"],"Entrar a mi cuenta"), btns(("Recuperar acceso","outline"),("Con ayuda familiar","outline")), HELP], nav=-1)
S(E,M,"perfil_infantil","Elige tu perfil","Selecciona tu espacio de aprendizaje",
  [grid(2,[("book","Mi avatar","Perfil de estudiante"),("figure","Con mi familia","Acceso acompañado")]), NEXT, S3, btn("Entrar al inicio")], nav=3)
S(E,M,"inicio","Mi inicio","Una misión breve para hoy",
  [stats(("Tiempo sugerido","10 min"),("Retos afuera","2")), hero("Tu reto de hoy","Busca 3 objetos de formas diferentes","Ver reto","noscreen"),
   grid(2,[("book","Aprende","Lección breve"),("figure","Explora","Reto sin pantalla")]),
   note("Sugerencia saludable","Cada contenido lleva a una actividad del entorno o a una pausa.","clock")], nav=0)
S(E,M,"cursos","Mis cursos","Aprende paso a paso",
  [grid(2,[("book","Matemáticas","4 unidades"),("figure","Ciencias","6 unidades"),("noscreen","Lectura","3 unidades"),("clock","Naturaleza","5 unidades")]), NEXT, S3], nav=2)
S(E,M,"leccion","Lección corta","Aprende y vuelve a explorar",
  [hero("Descubre las estaciones","Lee, observa y prueba una actividad real.","Leer","book"),
   steps(["Lee la explicación","Resuelve una pregunta","Apaga la pantalla y observa","Registra tu descubrimiento"]),
   note("Después de leer","Puedes continuar con una actividad en papel.","pencil")], nav=2)
S(E,M,"video_limitado","Video educativo","Al terminar, continúa sin pantalla",
  [video(), text("¿Cómo crecen las plantas?","4 min · Luego: observar una hoja"),
   hero("Al terminar el video","Sal de la app para observar, moverte o dibujar.","Marcar visto","figure"),
   note("Sin reproducción infinita","Al concluir, sugerimos desconectar en lugar de iniciar otro video.")], nav=2)
S(E,M,"quiz","Quiz de ciencias","Tres preguntas y una pausa",
  [question("Pregunta 1 de 3","¿Qué necesita una planta para crecer?"), options(["Agua y luz","Solo una pantalla","Únicamente juguetes"]), btn("Continuar"),
   note("Siguiente: descanso","Al terminar el quiz, habrá una pausa breve.","clock")], nav=2)
S(E,M,"retos_fisicos","Retos en movimiento","Ideas divertidas sin celular",
  [grid(2,RETOS4), NEXT, S3], nav=1)
S(E,M,"reto_circuito","Mi circuito de movimiento","Hazlo en un lugar despejado",
  [hero("Cinco estaciones","Reto guiado que se realiza sin teléfono.","Comenzar fuera","figure"),
   steps(["Camina hasta una marca","Equilíbrate unos segundos","Da 5 pasos laterales","Haz una pausa para respirar"]), SIG], nav=1)
S(E,M,"pausa_activa","Hora de una pausa","Guarda el celular y muévete",
  [timer("Pausa activa","05:00","Deja el dispositivo a un lado."), steps(["Levántate cuando sea seguro","Muévete suavemente","Respira y toma agua"]),
   note("Pantalla en reposo","Cuando suene el aviso, vuelve con calma al curso.","clock")], nav=1)
S(E,M,"explorar_entorno","Explora tu entorno","Observa sin llevar el teléfono",
  [hero("Detective de la naturaleza","Reto guiado que se realiza sin teléfono.","Comenzar fuera","noscreen"),
   steps(["Busca formas y colores","Observa una planta desde lejos","Cuenta 3 sonidos a tu alrededor","Vuelve para contar lo aprendido"]), SIG], nav=1)
S(E,M,"experimento","Laboratorio en casa","Aprendizaje fuera de pantalla",
  [hero("Sombras y luz","Reto guiado que se realiza sin teléfono.","Comenzar fuera","sun"),
   steps(["Pide acompañamiento a un adulto","Observa una sombra en un lugar seguro","Dibuja su forma en papel","Comenta qué cambió"]), SIG], nav=1)
S(E,M,"lectura_sin_pantalla","Rincón de lectura","Abre un libro, no otra pantalla",
  [hero("Aventura en papel","Reto guiado que se realiza sin teléfono.","Comenzar fuera","book"),
   steps(["Elige un libro físico","Lee con alguien 10 minutos","Dibuja tu parte favorita","Comparte tu dibujo en clase"]), SIG], nav=1)
S(E,M,"actividad_familiar","Reto en familia","Actividades para compartir",
  [grid(2,[("noscreen","Búsqueda de figuras","Dentro de casa"),("figure","Paseo acompañado","Zona segura"),("pencil","Construye con papel","Sin dispositivos"),("book","Cuenta una historia","En familia")]), NEXT, S3], nav=1)
S(E,M,"registro_sin_foto","Ya terminé mi reto","Cuéntanos sin subir fotos",
  [check("Lista de verificación",["Hice la actividad en un lugar seguro","Me acompañó un adulto cuando hizo falta","Aprendí algo nuevo","Quiero escribir una reflexión"]), btn("Guardar lista"),
   note("Sin fotos","Tu registro se guarda como texto: no se suben imágenes.","shield")], nav=1)
S(E,M,"diario","Mi diario de hallazgos","Describe lo aprendido en el mundo real",
  [form([("¿Qué descubriste?","area"),("¿Cómo te sentiste?","input"),("Algo que quieras repetir","input")],"Guardar reflexión"), btn("Compartir con docente","outline")], nav=3)
S(E,M,"equilibrio_digital","Mi equilibrio digital","Aprender, pausar y jugar afuera",
  [stats(("Sesión breve","10 min"),("Reto real","25 min")), chart("Aprendizaje equilibrado"),
   grid(2,[("book","Con pantalla","Aprendizaje corto"),("figure","Sin pantalla","Movimiento y lectura")]),
   note("No medimos rachas","Los descansos y actividades fuera de la app también cuentan.")], nav=3)
S(E,M,"logros","Mis logros","Reconocemos esfuerzo, no horas conectadas",
  [grid(2,[("noscreen","Explorador","3 retos reales"),("book","Lector","2 lecturas"),("sun","Observador","2 descubrimientos"),("check","Compañero","Reto en familia")]),
   NEXT, btn("Compartir logro","outline")], nav=3)
S(E,M,"perfil","Mi perfil","Tu progreso y tus preferencias",
  [profile("Mi espacio","Avanzo a mi ritmo"),
   grid(2,[("book","Mis cursos","4 activos"),("figure","Retos realizados","3 esta semana"),("pencil","Preferencias","Modo lectura"),("download","Materiales","Descargables")],88),
   note("Un buen hábito","La plataforma no premia permanecer conectado durante mucho tiempo.","clock")], nav=3)

# ================= PROFESOR · MÓVIL =================
S(P,M,"acceso","Acceso docente","Ingresa a tu espacio educativo",
  [form(["Correo institucional","Contraseña"],"Entrar al panel"), btns(("Recuperar acceso","outline"),("Cambiar cuenta","outline")), HELP], nav=-1)
S(P,M,"inicio","Hola, profesor","Resumen rápido del grupo",
  [stats(("Grupos","3"),("Retos activos","6")), hero("Hoy toca una pausa","Actividad breve en el aula","Ver reto","figure"),
   grid(2,[("book","Aprende","Lección breve"),("figure","Explora","Reto sin pantalla")]),
   note("Sugerencia saludable","Cada contenido lleva a una actividad del entorno o a una pausa.","clock")], nav=0)
S(P,M,"mis_grupos","Mis grupos","Consulta y organiza tus clases",
  [chips(["Todos","4.º","5.º"]), lst([("book","4.º A","24 estudiantes"),("figure","4.º B","22 estudiantes"),("noscreen","5.º A","26 estudiantes")]),
   note("Siguiente paso","Elige una actividad para seguir aprendiendo fuera de pantalla.","figure")], nav=2)
S(P,M,"avance_alumnos","Seguimiento","Progreso sin conexión excesiva",
  [bars("Indicadores de participación",[("Ana",85),("Luis",62),("Sara",92),("Diego",70)]),
   note("Qué medimos","Participación y aprendizaje, no tiempo de conexión ni rachas.","chart"), btn("Detectar rezago","outline")], nav=2)
S(P,M,"crear_actividad","Nueva actividad","Crea una tarea corta y significativa",
  [form([("Título de la actividad","input"),("Objetivo de aprendizaje","input"),("Duración sugerida","input")],"Guardar borrador"), btn("Asignar","outline")], nav=2)
S(P,M,"biblioteca_offline","Retos sin pantalla","Actividades para el mundo real",
  [search("Buscar recurso"), grid(2,[("figure","Pausa activa","5 minutos"),("noscreen","Explora el patio","10 minutos"),("book","Lectura en papel","15 minutos"),("sun","Observa sombras","10 minutos")]), NEXT], nav=1)
S(P,M,"reto_fisico","Diseña un reto físico","Movimiento seguro para estudiantes",
  [hero("Circuito en el aula","Reto guiado que se realiza sin teléfono.","Comenzar fuera","figure"),
   steps(["Despejar un área sin obstáculos","Explicar cada movimiento","Guiar pausas e hidratación","Registrar participación sin competir"]), SIG], nav=1)
S(P,M,"asignar_reto","Asignar un reto","Envía instrucciones breves",
  [form([("Grupo destinatario","input"),("Nombre del reto","input"),("Fecha de realización","input")],"Asignar a mi grupo"), HELP], nav=1)
S(P,M,"rutas_entorno","Ruta de observación","Explorar con supervisión",
  [hero("Formas del entorno","Reto guiado que se realiza sin teléfono.","Comenzar fuera","noscreen"),
   steps(["Definir un recorrido seguro","Elegir objetos que se observarán","Organizar equipos pequeños","Retornar y dialogar"]), SIG], nav=1)
S(P,M,"pausas_programadas","Pausas activas","Alterna aprendizaje y movimiento",
  [steps(["9:00 · Lección breve","9:20 · Movimiento en el aula","10:15 · Aprendizaje en papel","11:00 · Exploración acompañada","12:00 · Reflexión grupal"],"Pausas durante el día"),
   note("Personalizable","El docente ajusta duración, espacio y alternativas accesibles.","clock")], nav=1)
S(P,M,"rutinas_aula","Rutinas de aula","Hábitos breves para cada jornada",
  [lst([("figure","Respiración consciente","3 min · inicio de clase"),("clock","Estiramientos de inicio","5 min"),("sun","Observa la ventana","5 min · cierre")]),
   btn("Iniciar rutina"), note("Favoritas","Guarda las rutinas que más usas para acceder rápido.","check")], nav=1)
S(P,M,"seguridad","Seguridad","Protocolo antes de cada actividad",
  [check("Protocolo de seguridad",["Área libre de obstáculos","Supervisión de un adulto","Hidratación disponible","Alternativas accesibles"]),
   btns(("Confirmar","primary"),("Compartir","outline")), note("Registro","Cada confirmación queda guardada con fecha y grupo.","shield")], nav=2)
S(P,M,"validar_reto","Validar reto","Revisa evidencias sin fotos",
  [evidence("Ana Torres · 4.º A","Completó 4 de 5 estaciones del circuito y escribió su reflexión."),
   btns(("Aprobar","primary"),("Solicitar ajuste","outline")), note("Sin fotos de menores","La evidencia es texto o lista de verificación.","shield")], nav=1)
S(P,M,"retroalimentar","Retroalimentar","Un comentario claro y amable",
  [form([("Comentario para Ana","area")],"Enviar comentario"), chips(["Logrado","En proceso","Apoyo"]),
   note("Sugerencia","Reconoce el esfuerzo y propone un siguiente paso concreto.","pencil")], nav=2)
S(P,M,"rúbrica","Rúbrica","Criterios simples y observables",
  [rubric(["Participación","Seguridad","Colaboración"]), btn("Guardar")], nav=2)
S(P,M,"mensajes_familia","Mensajes a familias","Comunicación breve y respetuosa",
  [lst([("chat","Familia Torres","Hola, ¿cómo va el reto?"),("chat","Familia Ríos","Aviso: salida al patio"),("chat","Familia Soto","Sugerencia para casa")]),
   btns(("Enviar aviso","primary"),("Compartir idea","outline"))], nav=3)
S(P,M,"uso_pantalla","Uso de pantalla","Promedios por grupo, sin juicios",
  [stats(("Promedio diario","48 min"),("Pausas","12")), chart("Uso semanal"), btn("Recomendar pausa")], nav=2)
S(P,M,"reporte_semana","Reporte semanal","Resumen para compartir",
  [stats(("Retos hechos","18"),("Participación","86%")), bars("Por grupo",[("4.º A",88),("4.º B",79)]), btns(("Exportar","primary"),("Compartir","outline"))], nav=2)
S(P,M,"imprimibles","Imprimibles","Material para trabajar en papel",
  [grid(2,DOCS4), btns(("Descargar","primary"),("Imprimir","outline"))], nav=1)
S(P,M,"ajustes","Ajustes","Preferencias del panel docente",
  [toggles([("Avisos de pausa",True),("Resumen semanal",True),("Modo lectura",False),("Recordatorios a familias",False)]), btn("Guardar cambios"), HELP], nav=3)

# ================= ESTUDIANTE · WEB =================
CUR4 = [("book","Ciencias","Avance 78%"),("figure","Matemáticas","Avance 52%"),("noscreen","Lectura","Avance 61%"),("clock","Arte","Avance 64%")]
HUB4 = [("book","Aula y materias","Entrar a cursos"),("figure","Retos físicos","Ver actividades"),("noscreen","Lecturas offline","Recursos imprimibles"),("chart","Tu progreso","Consultar resumen")]
S3W = steps(["Revisa una idea","Realiza la actividad sin pantalla","Comparte lo que aprendiste"])
S(E,W,"dashboard","Panel de estudiante","Tu aprendizaje de un vistazo",
  [stats(("Cursos activos","4"),("Retos reales","3"),("Pausas","2")),
   row((2,hero("Una misión fuera de pantalla","Observa 3 formas en tu entorno","Abrir","noscreen")),(1,chart("Actividad semanal"))), grid(4,HUB4)], side=0, crumb="Resumen")
S(E,W,"dashboard_cursos","Panel de cursos","Organiza tus materias y próximos pasos",
  [grid(4,CUR4), NEXT, S3W], side=1, crumb="Aprendizaje")
S(E,W,"ruta_aprendizaje","Ruta de aprendizaje","Pequeños logros, actividades diversas",
  [steps(["Conoce el tema","Resuelve un ejercicio breve","Haz un reto fuera de pantalla","Reflexiona en tu diario","Comparte tus hallazgos"],"Tu ruta paso a paso"),
   note("Paso fuera de la pantalla","Aplica lo aprendido con una actividad del entorno.","figure")], side=1, crumb="Aprendizaje")
S(E,W,"detalle_curso","Detalle de Ciencias","Teoría, práctica y exploración",
  [stats(("Unidades","6"),("Completadas","4"),("Retos físicos","2")),
   row((2,hero("Tu próxima actividad","Observar sombras con ayuda","Abrir","sun")),(1,chart("Actividad semanal"))), grid(4,HUB4)], side=0, crumb="Resumen")
S(E,W,"leccion_breve","Lección breve","Contenido con duración definida",
  [hero("El ciclo del agua","Lee durante 5 minutos y observa tu alrededor.","Leer","book"),
   steps(["Lee la explicación","Resuelve una pregunta","Apaga la pantalla y observa","Registra tu descubrimiento"]),
   note("Después de leer","Puedes continuar con una actividad en papel.","pencil")], side=1, crumb="Aprendizaje")
S(E,W,"quiz","Evaluación corta","Refuerza lo aprendido en sesiones largas",
  [question("Pregunta 1 de 3","¿Qué elemento ayuda a crecer a una planta?"), options(["Agua y luz","Solo música","Solo una tableta"]), btn("Continuar"),
   note("Siguiente: descanso","Al terminar, haremos una pausa breve.","clock")], side=1, crumb="Aprendizaje")
S(E,W,"retos_offline","Biblioteca de retos reales","Actividades físicas y del entorno",
  [grid(4,[("figure","Camina y cuenta","Movimiento"),("noscreen","Detective de hojas","Naturaleza"),("sun","Sombras en papel","Experimento"),("book","Lectura compartida","Familia")]), NEXT, S3W], side=2, crumb="Retos offline")
S(E,W,"reto_movimiento","Detalle de reto físico","Guía imprimible para moverse sin pantalla",
  [hero("Circuito de cinco estaciones","Reto guiado que se realiza sin teléfono.","Comenzar fuera","figure"),
   steps(["Busca un área despejada","Realiza movimientos sencillos","Descansa cuando lo necesites","Marca el reto como realizado"]), SIG], side=2, crumb="Retos offline")
S(E,W,"calendario","Mi semana equilibrada","Alterna pantalla, movimiento y lectura",
  [week(), grid(4,[("book","Lunes","Lección corta"),("noscreen","Martes","Reto del entorno"),("book","Miércoles","Lectura en papel"),("figure","Jueves","Pausa activa")])], side=3, crumb="Actividades")
S(E,W,"guia_imprimible","Guías descargables","Descarga y desconéctate",
  [grid(4,[("figure","Circuito de aula","Imprimir ficha"),("noscreen","Observación natural","Imprimir ficha"),("book","Diario de lectura","Imprimir ficha"),("sun","Experimento de luz","Imprimir ficha")]), NEXT, S3W], side=2, crumb="Retos offline")
S(E,W,"naturaleza","Explora la naturaleza","Observa, anota y comparte",
  [hero("Detective de la naturaleza","Reto guiado que se realiza sin teléfono.","Comenzar fuera","noscreen"),
   grid(3,[("leaf","Hojas","Busca 3 formas"),("sun","Luz y sombra","Observa a distintas horas"),("figure","Paseo","Con acompañamiento")]), S3W], side=2, crumb="Retos offline")
S(E,W,"experimento_casa","Experimento en casa","Materiales simples y pasos claros",
  [hero("Sombras y luz","Revisa los pasos y empieza con un adulto.","Comenzar","sun"),
   steps(["Reúne papel, lápiz y una linterna","Pide acompañamiento","Observa y dibuja","Registra el resultado"]),
   row((1,note("Materiales","Papel, lápiz y linterna o luz del sol.","pencil")),(1,note("Seguridad","Hazlo con un adulto y en un lugar despejado.","shield")))], side=3, crumb="Actividades")
S(E,W,"lectura","Lectura guiada","Lee, responde y guarda tu avance",
  [row((2,doc("El jardín de las sombras",320)),(1,check("Para reflexionar",["¿Qué personaje te gustó?","¿Qué cambió en la historia?","¿Qué dibujarías?"]))),
   btns(("Guardar avance","primary"),("Responder","outline"))], side=1, crumb="Aprendizaje")
S(E,W,"diario","Diario de hallazgos","Escribe lo que descubres afuera",
  [row((1,form([("Título","input"),("¿Qué descubriste?","area")],"Guardar")),(1,lst([("pencil","Hojas del patio","Hoy"),("pencil","Sombras largas","Ayer"),("pencil","Paseo en familia","Hace 3 días")])))], side=4, crumb="Progreso")
S(E,W,"entrega_actividad","Entrega de actividad","Comparte tu evidencia sin subir fotos",
  [row((2,form([("Tu respuesta","area"),("Adjuntar evidencia (texto o PDF)","input")],"Enviar")),(1,check("Antes de enviar",["Escribí mi respuesta","Revisé mi trabajo","Lo hice con seguridad"])))], side=3, crumb="Actividades")
S(E,W,"equilibrio","Mi equilibrio digital","Alterna pantalla, pausa y movimiento",
  [CHART_STATS3, row((2,chart("Aprendizaje equilibrado")),(1,bars("Distribución",[("Lectura",40),("Movimiento",35),("Pantalla",25)]))),
   note("Sugerencia","Programa una pausa de 5 minutos después de cada lección.","clock")], side=4, crumb="Progreso")
S(E,W,"reporte_semanal","Reporte semanal","Tu avance de esta semana",
  [stats(("Lecciones","6"),("Retos reales","3"),("Pausas","4")),
   row((2,chart("Actividad de la semana")),(1,bars("Metas",[("Lecciones",80),("Retos",60),("Pausas",100)]))),
   row((1,btn("Descargar")),(1,btn("Compartir","outline")),(2,note("Compartir","Envía el reporte a tu familia o docente.","chat")))], side=4, crumb="Progreso")
S(E,W,"constancias","Constancias","Reconocimientos por tu esfuerzo",
  [grid(3,[("doc","Explorador de la naturaleza","Emitida 12 oct"),("doc","Lector constante","Emitida 05 oct"),("doc","Maestro del movimiento","Emitida 28 sep")],160),
   btns(("Descargar","primary"),("Compartir","outline")), note("Sin rankings","Las constancias reconocen hábitos, no competencia.","check")], side=4, crumb="Progreso")
S(E,W,"accesibilidad","Accesibilidad","Adapta la plataforma a ti",
  [row((1,toggles([("Alto contraste",True),("Texto grande",False),("Reducir animaciones",True),("Lectura en voz alta",False)])),(1,doc("Vista previa del texto",240))),
   btn("Guardar preferencia")], side=5, crumb="Recursos")
S(E,W,"perfil","Mi perfil","Tus datos, logros y ajustes",
  [row((1,profile("Mi espacio","Avanzo a mi ritmo")),(2,form([("Nombre","input"),("Correo del tutor","input")],"Guardar cambios"))),
   grid(4,[("book","Mis logros","8 insignias"),("doc","Constancias","3 emitidas"),("pencil","Datos","Editar"),("shield","Privacidad","Configurar")],100)], side=5, crumb="Recursos")

# ================= PROFESOR · WEB =================
S(P,W,"dashboard","Panel docente","Estado de grupos y experiencias fuera de línea",
  [stats(("Estudiantes","72"),("Grupos","3"),("Retos offline","9")),
   row((2,hero("Sugerencia de hoy","Pausa activa de 5 minutos","Abrir","figure")),(1,chart("Actividad semanal"))),
   grid(4,[("book","Mis grupos","Consultar estudiantes"),("figure","Retos de aula","Asignar actividad"),("noscreen","Recursos offline","Imprimibles"),("chart","Reportes","Revisar avances")])], side=0, crumb="Resumen")
S(P,W,"grupos","Grupos","Organiza y compara tus clases",
  [chips(["Todos","4.º","5.º","Activos"]),
   table(["Grupo","Estudiantes","Participación","Retos activos","Acción"],[["4.º A","24","%85","3","[Abrir]"],["4.º B","22","%78","2","[Abrir]"],["5.º A","26","%91","4","[Abrir]"]],[1.2,1,1.8,1,1]),
   row((1,btn("Comparar grupos","outline")),(1,btn("Nuevo grupo")),(2,note("Tip","Compara participación, no tiempo de conexión.","chart")))], side=1, crumb="Grupos")
S(P,W,"seguimiento","Seguimiento","Detecta rezago y acompaña a tiempo",
  [chips(["Todas las alertas","Rezago","Sin entrega"]),
   table(["Alumno","Grupo","Avance","Última actividad","Estado"],[["Ana Torres","4.º A","%85","Hoy","[Al día]"],["Luis Ríos","4.º A","%62","Hace 3 días","[Revisar]"],["Sara Soto","4.º B","%92","Hoy","[Al día]"],["Diego Paz","5.º A","%48","Hace 5 días","[Rezago]"],["Mía León","5.º A","%70","Ayer","[Al día]"]],[1.4,.8,1.8,1.2,1]),
   btn("Registrar observación","outline")], side=4, crumb="Evaluación")
S(P,W,"cursos","Cursos","Biblioteca de cursos para tus grupos",
  [grid(3,[("book","Ciencias naturales","4.º · 6 unidades"),("figure","Movimiento y salud","5.º · 4 unidades"),("noscreen","Lectura y entorno","4.º · 5 unidades"),("sun","Arte y luz","5.º · 3 unidades"),("clock","Hábitos digitales","4.º · 4 unidades"),("chart","Matemática real","5.º · 6 unidades")],140),
   row((1,btn("Nuevo curso")),(1,btn("Asignar","outline")))], side=3, crumb="Actividades")
S(P,W,"asignar_contenido","Asignar contenido","Elige qué, a quién y cuándo",
  [row((2,check("Selecciona contenido",["Lección: El ciclo del agua","Reto: Circuito en el aula","Lectura en papel","Guía imprimible"])),(1,form([("Grupo","input"),("Fecha de entrega","input")],"Publicar")))], side=3, crumb="Actividades")
S(P,W,"biblioteca_offline","Biblioteca offline","Recursos para trabajar sin pantalla",
  [search("Buscar recurso por tema o duración"), chips(["Todos","Movimiento","Naturaleza","Lectura","Familia"]), grid(4,DOCS8)], side=2, crumb="Retos offline")
S(P,W,"creador_retos","Creador de retos","Diseña retos físicos y del entorno",
  [row((2,form([("Nombre del reto","input"),("Objetivo","input"),("Reglas de seguridad","area")],"Guardar plantilla")),(1,hero("Vista previa","Circuito en el aula · 10 min","Probar","figure")))], side=2, crumb="Retos offline")
S(P,W,"plan_semanal","Plan semanal","Equilibra pantalla y movimiento",
  [week(), grid(4,[("book","Lunes","Lectura corta"),("figure","Martes","Reto de aula"),("noscreen","Miércoles","Exploración"),("clock","Jueves","Pausa activa")]),
   row((1,btn("Añadir bloque","outline")),(1,btn("Publicar")))], side=3, crumb="Actividades")
S(P,W,"pausas_activas","Pausas activas","Elige y programa pausas para tu grupo",
  [grid(3,[("figure","Estiramientos","5 min"),("clock","Respiración","3 min"),("sun","Mira por la ventana","5 min")]),
   steps(["9:20 · Movimiento en el aula","10:45 · Respiración","11:30 · Estiramientos","12:30 · Reflexión grupal"],"Pausas programadas hoy")], side=2, crumb="Retos offline")
S(P,W,"protocolo","Protocolo de seguridad","Consulta, descarga y comparte",
  [row((2,doc("Protocolo de seguridad",300)),(1,check("Verificar antes de iniciar",["Área despejada","Adulto presente","Hidratación lista"]))),
   btns(("Descargar","primary"),("Compartir","outline"))], side=3, crumb="Actividades")
S(P,W,"imprimibles","Imprimibles","Fichas listas para imprimir",
  [grid(4,DOCS8), btns(("Descargar","primary"),("Asignar","outline"))], side=2, crumb="Retos offline")
S(P,W,"registro_actividades","Registro de actividades","Historial de lo realizado",
  [table(["Fecha","Actividad","Grupo","Tipo","Estado"],[["12 oct","Circuito en el aula","4.º A","Físico","[Aplicada]"],["11 oct","Lectura en papel","4.º B","Lectura","[Aplicada]"],["10 oct","Ruta del patio","5.º A","Entorno","[Pendiente]"],["09 oct","Pausa de respiración","4.º A","Pausa","[Aplicada]"],["08 oct","Experimento de luz","5.º A","Casa","[Pendiente]"]],[1,2,1,1,1.2]),
   btn("Agregar registro")], side=3, crumb="Actividades")
S(P,W,"validar_actividad","Validar actividad","Revisa evidencias y da seguimiento",
  [row((2,evidence("Ana Torres · 4.º A","Completó 4 de 5 estaciones del circuito y escribió su reflexión.")),(1,form([("Comentario","area"),("Calificación","input")]))),
   btns(("Aprobar","primary"),("Solicitar corrección","outline"))], side=4, crumb="Evaluación")
S(P,W,"rubrica","Rúbrica","Criterios claros y observables",
  [rubric(["Participación","Seguridad","Colaboración","Reflexión","Cuidado del entorno"]), btns(("Aplicar rúbrica","primary"),("Guardar resultado","outline"))], side=4, crumb="Evaluación")
S(P,W,"retroalimentacion","Retroalimentación","Un comentario claro y amable",
  [row((2,form([("Para: Ana Torres","input"),("Retroalimentación","area")],"Enviar")),(1,lst([("user","Ana Torres","Pendiente"),("user","Luis Ríos","Enviado"),("user","Sara Soto","Pendiente")])))], side=4, crumb="Evaluación")
S(P,W,"uso_digital","Uso digital","Análisis semanal por grupo",
  [stats(("Promedio diario","48 min"),("Pausas aplicadas","12"),("Retos fuera","9")),
   row((2,chart("Uso por semana")),(1,bars("Por grupo",[("4.º A",52),("4.º B",44),("5.º A",47)]))),
   note("Recomendación","Programa una pausa tras cada 20 minutos de pantalla.","clock")], side=4, crumb="Evaluación")
S(P,W,"bienestar","Bienestar","Indicadores de equilibrio del grupo",
  [stats(("Pausas aplicadas","14"),("Retos fuera","9"),("Alertas","2")),
   row((2,chart("Tendencia de bienestar")),(1,bars("Indicadores",[("Movimiento",72),("Descanso",64),("Lectura",58)]))),
   btn("Registrar acción","outline")], side=4, crumb="Evaluación")
S(P,W,"familias","Familias","Comunicación con familias",
  [row((1,lst([("chat","Familia Torres","Hola, ¿cómo va el reto?"),("chat","Familia Ríos","Aviso: salida al patio"),("chat","Familia Soto","Sugerencia para casa")])),(2,form([("Para","input"),("Mensaje","area")],"Enviar mensaje"))),
   btns(("Programar aviso","outline"),("Compartir reporte","outline"))], side=5, crumb="Familias")
S(P,W,"informes","Informes","Genera y comparte reportes",
  [row((1,form([("Periodo","input"),("Grupo","input"),("Formato","input")],"Generar informe")),(2,doc("Vista previa del informe",320))),
   btns(("Descargar","primary"),("Enviar","outline"))], side=5, crumb="Familias")
S(P,W,"preferencias","Preferencias","Ajustes de tu cuenta docente",
  [row((1,toggles([("Avisos de pausa",True),("Resumen semanal",True),("Modo lectura",False),("Recordatorios a familias",False),("Exportar automático",False)])),(1,form([("Nombre","input"),("Institución","input")],"Guardar cambios")))], side=0, crumb="Resumen")
