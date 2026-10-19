# -*- coding: utf-8 -*-
"""Bloques de contenido. Cada bloque: fn(d, x, y, w, ctx, fh=None, **kw) -> alto.
Todas las posiciones internas salen de tokens (P, GAP_IN, radios) para que las cotas sean exactas."""
from lib import *

# nombre legible + widget sugerido por tecnología
WIDGETS = {
 "title":  ("Encabezado de página", "<PageHeader/>", "Column(Text headlineSmall, Text bodyMedium)"),
 "stats":  ("Tarjetas métricas", "<StatCard/> ×N (CSS grid)", "Row(Expanded(Card)) ×N"),
 "hero":   ("Tarjeta destacada", "<HeroCard/>", "Card + Column + OutlinedButton"),
 "grid":   ("Cuadrícula de tarjetas", "<CardGrid/> (CSS grid)", "GridView.count / Wrap"),
 "steps":  ("Lista de pasos", "<StepList/>", "ListView + ListTile(leading: CircleAvatar)"),
 "form":   ("Formulario", "<Form/> + <TextField/>", "Form + TextFormField"),
 "note":   ("Nota / aviso", "<InfoCard/>", "Card + ListTile"),
 "chart":  ("Gráfica de líneas", "<LineChart/> (Recharts)", "fl_chart LineChart / CustomPaint"),
 "bars":   ("Barras de progreso", "<ProgressList/>", "LinearProgressIndicator ×N"),
 "question": ("Pregunta", "<QuestionCard/>", "Card + Column(Text)"),
 "options": ("Opciones (radio)", "<RadioGroup/>", "RadioListTile ×N"),
 "video":  ("Reproductor de video", "<video/> / <VideoPlayer/>", "AspectRatio(16/9) + video_player"),
 "timer":  ("Temporizador", "<Countdown/>", "Stack + CircularProgressIndicator"),
 "check":  ("Lista de verificación", "<Checklist/>", "CheckboxListTile ×N"),
 "list":   ("Lista con avatar", "<ListRow/> ×N", "ListView.separated + ListTile"),
 "table":  ("Tabla de datos", "<DataTable/>", "DataTable / Table"),
 "chips":  ("Filtros (chips)", "<ChipGroup/>", "Wrap + ChoiceChip"),
 "search": ("Campo de búsqueda", "<SearchInput/>", "SearchBar"),
 "toggles": ("Ajustes (switches)", "<SettingRow/> ×N", "SwitchListTile ×N"),
 "week":   ("Calendario semanal", "<WeekStrip/>", "Row(Expanded) ×7"),
 "profile": ("Tarjeta de perfil", "<ProfileCard/>", "Card + CircleAvatar"),
 "btn":    ("Botón", "<Button/>", "FilledButton / OutlinedButton"),
 "btns":   ("Botones en fila", "<ButtonRow/>", "Row(Expanded(Button))"),
 "doc":    ("Vista previa de documento", "<DocPreview/>", "AspectRatio + Container"),
 "rubric": ("Matriz de rúbrica", "<RubricGrid/>", "Table + Radio"),
 "illus":  ("Imagen / ilustración", "<img/> (placeholder)", "Image / Placeholder"),
 "text":   ("Bloque de texto", "<h2/> + <p/>", "Column(Text)"),
 "row":    ("Fila de columnas", "CSS grid (12 col)", "Row + Expanded(flex)"),
 "evidence": ("Evidencia del alumno", "<EvidenceCard/>", "Card + ListTile + Container"),
}

P = 16        # padding de tarjeta (ambas plataformas)
HP = 20       # padding de tarjeta destacada
GI = 4        # separación título ↔ texto dentro de tarjeta
BH = 48       # alto de botón / input
RC, RB, RI = 12, 10, 8   # radios: tarjeta, botón/fila, input

def card(d, x, y, w, h, nm, fill="#fff", r=RC, sw=1.2, stroke=LIGHT, pad=(P, P, P, P), ann=True, rep=1, padann=None, dash=None):
    return R(d, x, y, w, h, r, fill, stroke, sw, dash, "card", nm, pad=list(pad), ann=ann, rep=rep,
             padann=ann if padann is None else padann)

def btn(d, x, y, w, h, label, kind="outline", nm="Botón", ann=True, rep=1):
    if kind == "primary": R(d, x, y, w, h, RB, INK, INK, 1.2, kind="button", nm=nm + " (primario)", pad=[0, 16, 0, 16], ann=ann, rep=rep); col = "#fff"
    else: R(d, x, y, w, h, RB, "#fff", INK, 1.5, kind="button", nm=nm + " (contorno)", pad=[0, 16, 0, 16], ann=ann, rep=rep); col = INK
    T(d, x + w / 2, y + (h - lh(13)) / 2, fit(label, 13, w - 32, True), 13, True, col, "middle", nm="Etiqueta de botón", maxw=w - 32, rep=rep)

def inputbox(d, x, y, w, h, label=None, ph="", ann=True, rep=1):
    if label: T(d, x, y - 6 - lh(11), fit(label, 11, w, True), 11, True, nm="Etiqueta de campo", maxw=w, rep=rep, ann=ann)
    R(d, x, y, w, h, RI, FILL, LIGHT, 1.2, kind="input", nm="Campo de texto" if h <= 56 else "Área de texto", pad=[12, 12, 12, 12], ann=ann, rep=rep)
    if ph: T(d, x + 12, y + (12 if h > 56 else (h - lh(12)) / 2), fit(ph, 12, w - 24), 12, fill="#9A9A9A", nm="Placeholder", maxw=w - 24, rep=rep, ann=ann)

def hgaps(d, x, y, w, h, n, g, nm="Separación entre columnas"):
    cw = (w - g * (n - 1)) / n
    for i in range(n - 1):
        G(d, x + cw * (i + 1) + g * i, y, g, h, nm, ann=(i == 0), orient="h")

def vgap(d, x, y, w, g, nm="Separación entre filas", ann=True):
    G(d, x, y, w, g, nm, ann=ann, orient="v")

# =========================================================
def b_title(d, x, y, w, ctx, fh=None, title="", sub="", crumb=None):
    if ctx["web"]:
        h = 88
        if crumb: T(d, x, y, fit(crumb, 12, w), 12, fill=GRAY, nm="Migas de pan (breadcrumb)", maxw=w, ann=True)
        T(d, x, y + 24, fit(title, 28, w, True), 28, True, nm="Título de página (H1)", maxw=w, ann=True)
        T(d, x, y + 64, fit(sub, 14, w), 14, fill=GRAY, nm="Subtítulo", maxw=w, ann=True)
        LN(d, x, y + h, x + w, y + h, LIGHT, 1, "Divisor inferior")
        return h
    h = 64
    T(d, x, y + 2, fit(title, 22, w, True), 22, True, nm="Título de página (H1)", maxw=w, ann=True)
    T(d, x, y + 2 + 28 + 8, fit(sub, 13, w), 13, fill=GRAY, nm="Subtítulo", maxw=w, ann=True)
    return h

def b_stats(d, x, y, w, ctx, fh=None, items=(), **kw):
    n, g = len(items), ctx["gap"]
    h = fh or (104 if ctx["web"] else 88)
    cw = (w - g * (n - 1)) / n
    for i, (lab, val) in enumerate(items):
        cx = x + i * (cw + g)
        card(d, cx, y, cw, h, "Tarjeta métrica", FILL, ann=(i == 0), rep=n)
        T(d, cx + P, y + P, fit(lab, 12, cw - 2 * P), 12, fill=GRAY, nm="Etiqueta métrica", maxw=cw - 2 * P, ann=(i == 0), rep=n)
        T(d, cx + P, y + h - P - lh(28), fit(val, 28, cw - 2 * P, True), 28, True, nm="Valor métrica", maxw=cw - 2 * P, ann=(i == 0), rep=n)
    hgaps(d, x, y, w, h, n, g)
    return h

def b_hero(d, x, y, w, ctx, fh=None, title="", text="", button="Abrir", ic="figure", **kw):
    h = fh or (176 if ctx["web"] else 152)
    card(d, x, y, w, h, "Tarjeta destacada", pad=(HP, HP, HP, HP))
    tw = w - 2 * HP - 32 - 16
    T(d, x + HP, y + HP, fit(title, 17, tw, True), 17, True, nm="Título de tarjeta", maxw=tw, ann=True)
    ls = wrap(text, 13, tw, 2)
    for i, ln in enumerate(ls):
        T(d, x + HP, y + HP + lh(17) + GI + i * lh(13), ln, 13, fill=GRAY, nm="Texto de tarjeta", maxw=tw, ann=(i == 0), rep=len(ls))
    I(d, ic, x + w - HP - 32, y + HP, 32, 1.6, nm="Icono destacado")
    bw = min(w - 2 * HP, max(120, 8 * round((len(button) * 8.6 + 36) / 8)))
    btn(d, x + HP, y + h - HP - BH, bw, BH, button, "outline")
    return h

def b_grid(d, x, y, w, ctx, fh=None, cols=2, items=(), ch=None, **kw):
    g = ctx["gap"]
    ch = ch or (120 if ctx["web"] else 96)
    cw = (w - g * (cols - 1)) / cols
    rows = (len(items) + cols - 1) // cols
    n = len(items)
    for i, it in enumerate(items):
        ic, t, sub = it
        cx, cy = x + (i % cols) * (cw + g), y + (i // cols) * (ch + g)
        f = i == 0
        card(d, cx, cy, cw, ch, "Tarjeta de cuadrícula", ann=f, rep=n)
        I(d, ic, cx + P, cy + P, 24, 1.5, nm="Icono de tarjeta", ann=f, rep=n)
        T(d, cx + P + 24 + 12, cy + P + (24 - lh(13)) / 2, fit(t, 13, cw - 2 * P - 36, True), 13, True, nm="Título de tarjeta", maxw=cw - 2 * P - 36, ann=f, rep=n)
        T(d, cx + P, cy + ch - P - lh(11), fit(sub, 11, cw - 2 * P), 11, fill=GRAY, nm="Descripción", maxw=cw - 2 * P, ann=f, rep=n)
    for r_ in range(rows):
        hgaps(d, x, y + r_ * (ch + g), w, ch, cols, g) if r_ == 0 else None
        if r_ > 0: vgap(d, x, y + r_ * (ch + g) - g, cw, g, ann=(r_ == 1))
    return rows * ch + (rows - 1) * g

def b_steps(d, x, y, w, ctx, fh=None, items=(), title=None, **kw):
    ih = 48 if ctx["web"] else 44
    n = len(items)
    if title:
        total = P + lh(14) + 12 + n * (ih + 8) - 8 + P
        card(d, x, y, w, total, "Contenedor de pasos")
        T(d, x + P, y + P, fit(title, 14, w - 2 * P, True), 14, True, nm="Título de lista", maxw=w - 2 * P, ann=True)
        x2, w2, yy = x + P, w - 2 * P, y + P + lh(14) + 12
    else:
        total = n * (ih + 8) - 8
        x2, w2, yy = x, w, y
    for i, t in enumerate(items):
        f = i == 0
        R(d, x2, yy, w2, ih, RB, FILL if i % 2 == 0 else "#fff", LIGHT, 1.1, kind="row", nm="Fila de paso", pad=[0, 12, 0, 12], ann=f, rep=n, padann=f)
        O(d, x2 + 12 + 12, yy + ih / 2, 12, "#fff", INK, 1.3, nm="Número de paso", ann=f, rep=n)
        T(d, x2 + 24, yy + (ih - lh(11)) / 2, str(i + 1), 11, True, anchor="middle", nm="Dígito", rep=n)
        T(d, x2 + 12 + 24 + 12, yy + (ih - lh(13)) / 2, fit(t, 13, w2 - 60), 13, nm="Texto de paso", maxw=w2 - 60, ann=f, rep=n)
        if i < n - 1: vgap(d, x2, yy + ih, w2, 8, ann=f)
        yy += ih + 8
    return total

def b_form(d, x, y, w, ctx, fh=None, fields=(), button=None, **kw):
    hs = []
    for f in fields:
        lab, kind = (f if isinstance(f, tuple) else (f, "input"))
        hs.append((lab, kind, 96 if kind == "area" else BH))
    LB = lh(11) + 6
    natural = P + sum(LB + hh for _, _, hh in hs) + 16 * (len(hs) - 1) + ((24 + BH) if button else 0) + P
    h = fh or natural
    card(d, x, y, w, h, "Tarjeta de formulario")
    yy = y + P + LB
    for i, (lab, kind, hh) in enumerate(hs):
        inputbox(d, x + P, yy, w - 2 * P, hh, lab, ann=True)
        if i < len(hs) - 1: vgap(d, x + P, yy + hh, w - 2 * P, 16, "Separación entre campos", ann=(i == 0))
        yy += hh + 16 + LB
    if button:
        by = y + h - P - BH
        vgap(d, x + P, by - 24, w - 2 * P, 24, "Separación campos ↔ botón") if not fh else None
        btn(d, x + P, by, w - 2 * P, BH, button, "primary")
    return h

def b_note(d, x, y, w, ctx, fh=None, title="", text="", ic=None, **kw):
    h = fh or 88
    card(d, x, y, w, h, "Tarjeta de aviso")
    tw = w - 2 * P - (36 if ic else 0)
    T(d, x + P, y + P, fit(title, 13, tw, True), 13, True, nm="Título de aviso", maxw=tw, ann=True)
    ls = wrap(text, 12, tw, 2)
    for i, ln in enumerate(ls):
        T(d, x + P, y + P + lh(13) + GI + i * lh(12), ln, 12, fill=GRAY, nm="Texto de aviso", maxw=tw, ann=(i == 0), rep=len(ls))
    if ic: I(d, ic, x + w - P - 24, y + P, 24, 1.5, nm="Icono de aviso")
    return h

def b_chart(d, x, y, w, ctx, fh=None, title="", **kw):
    h = fh or 200
    card(d, x, y, w, h, "Tarjeta de gráfica")
    T(d, x + P, y + P, fit(title, 13, w - 2 * P, True), 13, True, nm="Título de gráfica", maxw=w - 2 * P, ann=True)
    px0, py0, px1, py1 = x + P, y + P + lh(13) + 12, x + w - P, y + h - P
    R(d, px0, py0, px1 - px0, py1 - py0, 0, "none", "none", 0, kind="area", nm="Área de trazado", ann=True, tag="tl")
    d.line(px0, py0, px0, py1, INK, 1.4); d.line(px0, py1, px1, py1, INK, 1.4)
    vals = [.15, .32, .24, .5, .42, .66, .6, .82]
    pts = [(px0 + 8 + i * (px1 - px0 - 16) / (len(vals) - 1), py1 - 8 - v * (py1 - py0 - 16)) for i, v in enumerate(vals)]
    d.path("M" + " L".join(f"{a:.2f} {b:.2f}" for a, b in pts), stroke=INK, sw=2)
    for i, (a, b) in enumerate(pts): O(d, a, b, 3, INK, INK, 1, nm="Punto de dato", ann=(i == len(pts) - 1), rep=len(pts), side="l")
    return h

def b_bars(d, x, y, w, ctx, fh=None, title="", items=(), **kw):
    n = len(items)
    h = fh or (P + lh(13) + 12 + n * 40 - 8 + P)
    card(d, x, y, w, h, "Tarjeta de progreso")
    T(d, x + P, y + P, fit(title, 13, w - 2 * P, True), 13, True, nm="Título", maxw=w - 2 * P, ann=True)
    yy = y + P + lh(13) + 12
    for i, (nm, pct) in enumerate(items):
        f = i == 0
        T(d, x + P, yy, nm, 12, True, nm="Etiqueta de barra", ann=f, rep=n)
        T(d, x + w - P, yy, f"{pct}%", 12, True, anchor="end", nm="Porcentaje", rep=n)
        R(d, x + P, yy + 24, w - 2 * P, 8, 4, "#E6E6E6", "none", 0, kind="track", nm="Pista de progreso", ann=f, rep=n, tag="above")
        d.rect(x + P, yy + 24, (w - 2 * P) * pct / 100, 8, 4, "#555", "none", 0)
        yy += 40
    return h

def b_question(d, x, y, w, ctx, fh=None, head="", text="", **kw):
    ls = wrap(text, 13, w - 2 * P, 2)
    h = fh or max(88, P + lh(14) + GI + len(ls) * lh(13) + P)
    card(d, x, y, w, h, "Tarjeta de pregunta")
    T(d, x + P, y + P, fit(head, 14, w - 2 * P, True), 14, True, nm="Encabezado de pregunta", maxw=w - 2 * P, ann=True)
    for i, ln in enumerate(ls):
        T(d, x + P, y + P + lh(14) + GI + i * lh(13), ln, 13, fill=GRAY, nm="Enunciado", maxw=w - 2 * P, ann=(i == 0), rep=len(ls))
    return h

def b_options(d, x, y, w, ctx, fh=None, items=(), sel=None, **kw):
    ih = BH; yy = y; n = len(items)
    for i, t in enumerate(items):
        f = i == 0
        R(d, x, yy, w, ih, RB, "#fff", LIGHT, 1.2, kind="row", nm="Opción", pad=[0, 16, 0, 16], ann=f, rep=n, padann=f)
        O(d, x + P + 10, yy + ih / 2, 10, "#fff", INK, 1.5, nm="Radio", ann=f, rep=n)
        if sel == i: O(d, x + P + 10, yy + ih / 2, 5, INK, INK, 1, nm="Radio seleccionado (punto)", ann=True, side="l")
        T(d, x + P + 20 + 12, yy + (ih - lh(13)) / 2, fit(t, 13, w - 64), 13, nm="Texto de opción", maxw=w - 64, ann=f, rep=n)
        if i < n - 1: vgap(d, x, yy + ih, w, 8, ann=f)
        yy += ih + 8
    return yy - 8 - y

def b_video(d, x, y, w, ctx, fh=None, **kw):
    h = fh or round(w * 9 / 16)
    R(d, x, y, w, h, RC, FILL, INK, 1.4, kind="media", nm="Reproductor 16:9", note="aspect-ratio 16/9")
    d.line(x, y, x + w, y + h, "#D0D0D0", 1); d.line(x + w, y, x, y + h, "#D0D0D0", 1)
    O(d, x + w / 2, y + h / 2, 28, "#fff", INK, 1.5, nm="Botón reproducir")
    d.path(f"M{x+w/2-8:.2f} {y+h/2-12:.2f} L{x+w/2+13:.2f} {y+h/2:.2f} L{x+w/2-8:.2f} {y+h/2+12:.2f}z", stroke=INK, sw=1.4)
    T(d, x + 12, y + 12, "Video 16:9", 10, fill=GRAY, family=MONO, keep=True, nm="Etiqueta de medio")
    return h

def b_timer(d, x, y, w, ctx, fh=None, title="", time="05:00", text="", **kw):
    h = fh or 240
    card(d, x, y, w, h, "Tarjeta de temporizador", FILL, stroke=INK, sw=1.4)
    T(d, x + P, y + P, fit(title, 14, w - 2 * P, True), 14, True, nm="Título", maxw=w - 2 * P, ann=True)
    cx, cy = x + w / 2, y + h / 2
    O(d, cx, cy, 58, "#fff", INK, 1.6, nm="Anillo de tiempo")
    T(d, cx, cy - lh(26) / 2, time, 26, True, anchor="middle", nm="Tiempo (mm:ss)", ann=True)
    T(d, x + P, y + h - P - lh(12), fit(text, 12, w - 2 * P), 12, fill=GRAY, nm="Texto de ayuda", maxw=w - 2 * P, ann=True)
    return h

def b_check(d, x, y, w, ctx, fh=None, title="", items=(), **kw):
    ih = 52; n = len(items)
    top = P + lh(14) + 12
    h = fh or (top + n * ih)
    card(d, x, y, w, h, "Tarjeta de verificación", pad=(P, P, 0, P))
    T(d, x + P, y + P, fit(title, 14, w - 2 * P, True), 14, True, nm="Título", maxw=w - 2 * P, ann=True)
    yy = y + top
    for i, t in enumerate(items):
        f = i == 0
        LN(d, x + P, yy, x + w - P, yy, "#DDD", 1, "Divisor de fila")
        R(d, x + P, yy, w - 2 * P, ih, 0, "none", "none", 0, kind="row", nm="Fila de verificación", ann=f, rep=n, tag="tr")
        R(d, x + P, yy + (ih - 20) / 2, 20, 20, 4, "#fff", INK, 1.5, kind="checkbox", nm="Casilla", ann=f, rep=n, tag="out")
        T(d, x + P + 20 + 12, yy + (ih - lh(13)) / 2, fit(t, 13, w - 2 * P - 32), 13, nm="Texto de casilla", maxw=w - 2 * P - 32, ann=f, rep=n)
        yy += ih
    return h

def b_list(d, x, y, w, ctx, fh=None, items=(), rh=64, **kw):
    yy = y; n = len(items)
    for i, (ic, t, sub) in enumerate(items):
        f = i == 0
        R(d, x, yy, w, rh, RC, "#fff", LIGHT, 1.2, kind="row", nm="Fila de lista", pad=[12, 16, 12, 16], ann=f, rep=n, padann=f)
        O(d, x + P + 20, yy + rh / 2, 20, FILL, INK, 1.2, nm="Avatar", ann=f, rep=n)
        if ic: I(d, ic, x + P + 8, yy + rh / 2 - 12, 24, 1.4, nm="Icono de avatar", ann=False, rep=n)
        tx = x + P + 40 + 16; tw = w - (tx - x) - P - 20 - 12
        top = yy + (rh - lh(14) - lh(11)) / 2
        T(d, tx, top, fit(t, 14, tw, True), 14, True, nm="Título de fila", maxw=tw, ann=f, rep=n)
        T(d, tx, top + lh(14), fit(sub, 11, tw), 11, fill=GRAY, nm="Subtítulo de fila", maxw=tw, ann=f, rep=n)
        I(d, "chevron", x + w - P - 20, yy + rh / 2 - 10, 20, 1.5, nm="Chevron", ann=f, rep=n, side="l")
        if i < n - 1: vgap(d, x, yy + rh, w, 8, ann=f)
        yy += rh + 8
    return yy - 8 - y

def b_table(d, x, y, w, ctx, fh=None, cols=(), rows=(), widths=None, rh=44, **kw):
    n = len(cols)
    widths = widths or [1] * n
    tot = sum(widths); cws = [w * k / tot for k in widths]
    h = fh or (rh + len(rows) * rh)
    R(d, x, y, w, h, RC, "#fff", "none", 0, kind="card", nm="Tabla", ann=True)
    d.rect(x, y, w, rh, RC, FILL2, "none", 0); d.rect(x, y + 14, w, rh - 14, 0, FILL2, "none", 0)
    d.rect(x, y, w, h, RC, "none", LIGHT, 1.2)
    R(d, x, y, w, rh, 0, "none", "none", 0, kind="row", nm="Fila de encabezado", ann=True, tag="tl")
    cx = x
    for i, c in enumerate(cols):
        R(d, cx, y, cws[i], rh, 0, "none", "none", 0, kind="cell", nm=f"Columna «{c}»", pad=[0, 16, 0, 16], ann=False)
        T(d, cx + 16, y + (rh - lh(12)) / 2, fit(c, 12, cws[i] - 24, True), 12, True, nm="Encabezado de columna", maxw=cws[i] - 32, ann=(i == 0), rep=n)
        cx += cws[i]
    # cotas de ancho de columna (registradas como gap horizontal de tipo "col")
    cx = x
    for i in range(n):
        d.reg("colw", f"Ancho de columna {i+1}", cx, y, cws[i], rh, ann=True)
        cx += cws[i]
    yy = y + rh
    for ri, r in enumerate(rows):
        LN(d, x, yy, x + w, yy, "#DDD", 1, "Divisor de fila")
        R(d, x, yy, w, rh, 0, "none", "none", 0, kind="row", nm="Fila de datos", ann=(ri == 0), rep=len(rows), tag="tr")
        cx = x
        for i, c in enumerate(r):
            f = ri == 0
            if isinstance(c, str) and c.startswith("%"):
                p = int(c[1:])
                R(d, cx + 16, yy + rh / 2 - 4, cws[i] - 64, 8, 4, "#E6E6E6", "none", 0, kind="track", nm="Barra en celda", ann=f, rep=len(rows), tag="above")
                d.rect(cx + 16, yy + rh / 2 - 4, (cws[i] - 64) * p / 100, 8, 4, "#555", "none", 0)
                T(d, cx + cws[i] - 16, yy + (rh - lh(11)) / 2, f"{p}%", 11, True, anchor="end", nm="Porcentaje", rep=len(rows))
            elif isinstance(c, str) and c.startswith("["):
                bw = min(cws[i] - 32, 104)
                R(d, cx + 16, yy + rh / 2 - 14, bw, 28, RI, "#fff", INK, 1.3, kind="button", nm="Botón de celda (sm)", pad=[0, 12, 0, 12], ann=f, rep=len(rows))
                T(d, cx + 16 + bw / 2, yy + (rh - lh(11)) / 2, c.strip("[]"), 11, True, anchor="middle", nm="Etiqueta", rep=len(rows))
            else:
                T(d, cx + 16, yy + (rh - lh(12)) / 2, fit(c, 12, cws[i] - 32, i == 0), 12, i == 0, nm="Texto de celda", maxw=cws[i] - 32, ann=(f and i == 0), rep=len(rows))
            cx += cws[i]
        yy += rh
    return h

def b_chips(d, x, y, w, ctx, fh=None, items=(), active=0, **kw):
    cx = x
    for i, t in enumerate(items):
        cw = 16 + round(len(t) * 7.2) + 16
        R(d, cx, y, cw, 36, 18, INK if i == active else "#fff", INK, 1.2, kind="chip", nm="Chip activo" if i == active else "Chip", pad=[0, 16, 0, 16], ann=True)
        T(d, cx + cw / 2, y + (36 - lh(12)) / 2, t, 12, True, "#fff" if i == active else INK, "middle", nm="Etiqueta de chip", rep=len(items))
        if i < len(items) - 1: G(d, cx + cw, y, 8, 36, "Separación entre chips", ann=(i == 0), orient="h")
        cx += cw + 8
    return 36

def b_search(d, x, y, w, ctx, fh=None, ph="Buscar", **kw):
    R(d, x, y, w, BH, 24, "#fff", INK, 1.4, kind="input", nm="Campo de búsqueda", pad=[0, 16, 0, 16], padann=True)
    I(d, "search", x + 16, y + 12, 24, 1.5, nm="Icono buscar")
    T(d, x + 16 + 24 + 12, y + (BH - lh(13)) / 2, ph, 13, fill="#9A9A9A", nm="Placeholder", maxw=w - 68, ann=True)
    return BH

def b_toggles(d, x, y, w, ctx, fh=None, items=(), **kw):
    rh = 56; n = len(items)
    h = fh or n * rh + 8
    card(d, x, y, w, h, "Tarjeta de ajustes", pad=(4, P, 4, P), padann=False)
    yy = y + 4
    for i, (t, on) in enumerate(items):
        f = i == 0
        if i: LN(d, x + P, yy, x + w - P, yy, "#DDD", 1, "Divisor de fila")
        R(d, x + P, yy, w - 2 * P, rh, 0, "none", "none", 0, kind="row", nm="Fila de ajuste", ann=f, rep=n, tag="tl")
        T(d, x + P, yy + (rh - lh(13)) / 2, fit(t, 13, w - 2 * P - 60), 13, on, nm="Texto de ajuste", maxw=w - 2 * P - 60, ann=f, rep=n)
        sx = x + w - P - 44
        R(d, sx, yy + rh / 2 - 12, 44, 24, 12, INK if on else "#fff", INK, 1.4, kind="switch", nm="Switch (pista)", ann=f, rep=n, tag="out")
        O(d, sx + (32 if on else 12), yy + rh / 2, 8, "#fff" if on else INK, INK, 1.2, nm="Switch (pulgar)", ann=f, rep=n, side="l")
        yy += rh
    return h

def b_week(d, x, y, w, ctx, fh=None, days="LMXJVSD", marks=(1, 3, 5), **kw):
    g = 8; h = fh or 140
    card(d, x, y, w, h, "Tarjeta de semana")
    T(d, x + P, y + P, "Plan semanal", 13, True, nm="Título", ann=True)
    cw = (w - 2 * P - g * 6) / 7
    top = P + lh(13) + 12
    ch = h - top - P
    for i, dd in enumerate(days):
        f = i == 0
        cx = x + P + i * (cw + g)
        R(d, cx, y + top, cw, ch, RB, FILL if i in marks else "#fff", LIGHT, 1.2, kind="cell", nm="Celda de día", ann=f, rep=7, tag="below")
        T(d, cx + cw / 2, y + top + 12, dd, 12, True, anchor="middle", nm="Inicial del día", rep=7)
        O(d, cx + cw / 2, y + top + 12 + lh(12) + 12 + 8, 8, INK if i in marks else "#fff", INK, 1.3, nm="Indicador de día", ann=f, rep=7)
        if i < 6: G(d, cx + cw, y + top, g, ch, "Separación entre días", ann=f, orient="h")
    return h

def b_profile(d, x, y, w, ctx, fh=None, name="", sub="", **kw):
    h = fh or 120
    card(d, x, y, w, h, "Tarjeta de perfil")
    O(d, x + P + 36, y + h / 2, 36, FILL, INK, 1.4, nm="Avatar grande")
    I(d, "user", x + P + 36 - 16, y + h / 2 - 16, 32, 1.4, nm="Icono de avatar", ann=False)
    tx = x + P + 72 + 16; tw = w - (tx - x) - P
    top = y + (h - lh(17) - GI - lh(12)) / 2
    T(d, tx, top, fit(name, 17, tw, True), 17, True, nm="Nombre", maxw=tw, ann=True)
    T(d, tx, top + lh(17) + GI, fit(sub, 12, tw), 12, fill=GRAY, nm="Detalle", maxw=tw, ann=True)
    return h

def b_btn(d, x, y, w, ctx, fh=None, label="", kind="primary", **kw):
    btn(d, x, y, w, BH, label, kind)
    return BH

def b_btns(d, x, y, w, ctx, fh=None, items=(), **kw):
    g = 12; n = len(items); bw = (w - g * (n - 1)) / n
    for i, (lab, kind) in enumerate(items): btn(d, x + i * (bw + g), y, bw, BH, lab, kind, ann=True)
    hgaps(d, x, y, w, BH, n, g, "Separación entre botones")
    return BH

def b_doc(d, x, y, w, ctx, fh=None, title="", hh=240, **kw):
    h = fh or hh
    card(d, x, y, w, h, "Contenedor de vista previa", FILL, pad=(20, 20, 20, 20), padann=False)
    pw = round(min(w - 48, (h - 40) * 0.72)); px = x + (w - pw) / 2
    R(d, px, y + 20, pw, h - 40, 4, "#fff", INK, 1.3, kind="media", nm="Hoja (proporción carta 0.72)", pad=[16, 14, 16, 14])
    T(d, px + 14, y + 20 + 16, fit(title, 12, pw - 28, True), 12, True, nm="Título de hoja", maxw=pw - 28, ann=True)
    yy = y + 20 + 16 + lh(12) + 12
    k = 0
    while yy < y + h - 40:
        d.line(px + 14, yy, px + pw - (14 if k % 3 else 50), yy, "#C8C8C8", 3); yy += 14; k += 1
    d.reg("lines", "Líneas de contenido (3 px, cada 14)", px + 14, y + 20 + 16 + lh(12) + 12, pw - 28, max(0, k - 1) * 14, ann=False)
    return h

def b_rubric(d, x, y, w, ctx, fh=None, levels=("Inicial", "Básico", "Logrado", "Destacado"), rows=(), sel=None, **kw):
    web = ctx["web"]
    rh = 52 if web else 80
    h = fh or ((44 + len(rows) * rh) if web else (8 + len(rows) * rh))
    R(d, x, y, w, h, RC, "#fff", LIGHT, 1.2, kind="card", nm="Matriz de rúbrica", pad=None if ctx["web"] else [8, P, 4, P], padann=not ctx["web"])
    nr = len(rows)
    if web:
        first = w * 0.30
        cw = (w - first) / len(levels)
        d.rect(x, y, w, 44, RC, FILL2, "none", 0); d.rect(x, y + 14, w, 30, 0, FILL2, "none", 0); d.rect(x, y, w, h, RC, "none", LIGHT, 1.2)
        R(d, x, y, w, 44, 0, "none", "none", 0, kind="row", nm="Fila de encabezado", ann=True, tag="tl")
        T(d, x + 16, y + (44 - lh(12)) / 2, "Criterio", 12, True, nm="Encabezado «Criterio»", ann=True)
        d.reg("colw", "Columna criterio (30 %)", x, y, first, 44, ann=True)
        for j, l in enumerate(levels):
            T(d, x + first + cw * j + cw / 2, y + (44 - lh(12)) / 2, l, 12, True, anchor="middle", nm="Encabezado de nivel", rep=len(levels))
            d.reg("colw", f"Columna nivel {j+1}", x + first + cw * j, y, cw, 44, ann=(j == 0))
        yy = y + 44
        for i, r in enumerate(rows):
            f = i == 0
            LN(d, x, yy, x + w, yy, "#DDD", 1, "Divisor de fila")
            R(d, x, yy, w, rh, 0, "none", "none", 0, kind="row", nm="Fila de criterio", ann=f, rep=nr, tag="tr")
            T(d, x + 16, yy + (rh - lh(12)) / 2, fit(r, 12, first - 32, True), 12, True, nm="Nombre de criterio", maxw=first - 32, ann=f, rep=nr)
            for j in range(len(levels)):
                cx = x + first + cw * j + cw / 2
                O(d, cx, yy + rh / 2, 9, INK if (sel or [2, 1, 3, 2, 2])[i % 5] == j else "#fff", INK, 1.4, nm="Radio de nivel", ann=(f and j == 0), rep=nr * len(levels))
            yy += rh
    else:
        yy = y + 8
        lw = (w - 2 * P) / len(levels)
        for i, r in enumerate(rows):
            f = i == 0
            R(d, x + P, yy, w - 2 * P, rh - 4, 0, "none", "none", 0, kind="row", nm="Bloque de criterio", ann=f, rep=nr, tag="tr")
            T(d, x + P, yy + 8, fit(r, 13, w - 2 * P, True), 13, True, nm="Nombre de criterio", maxw=w - 2 * P, ann=f, rep=nr)
            for j, l in enumerate(levels):
                cx = x + P + lw * j + lw / 2
                O(d, cx, yy + 8 + lh(13) + 8 + 8, 8, INK if (sel or [2, 1, 3, 2])[i % 4] == j else "#fff", INK, 1.4, nm="Radio de nivel", ann=(f and j == 0), rep=nr * len(levels))
                T(d, cx, yy + 8 + lh(13) + 8 + 16 + 4, l[:7], 10, fill=GRAY, anchor="middle", nm="Etiqueta de nivel", maxw=lw - 4, ann=(f and j == 0), rep=nr * len(levels))
            if i < nr - 1: LN(d, x + P, yy + rh - 4, x + w - P, yy + rh - 4, "#DDD", 1, "Divisor")
            yy += rh
    return h

def b_illus(d, x, y, w, ctx, fh=None, ic="sun", label="Ilustración", **kw):
    h = fh or 120
    R(d, x, y, w, h, RC, FILL2, LIGHT, 1.2, kind="media", nm="Ilustración (placeholder)")
    I(d, ic, x + w / 2 - 28, y + h / 2 - 28, 56, 1.4, "#555", nm="Icono ilustración")
    T(d, x + 12, y + 12, label.split(" ")[0], 10, fill=GRAY, family=MONO, keep=True, nm="Etiqueta")
    return h

def b_text(d, x, y, w, ctx, fh=None, title="", body="", **kw):
    ls = wrap(body, 14, w, 3)
    h = fh or (lh(20) + 8 + len(ls) * lh(14))
    T(d, x, y, fit(title, 20, w, True), 20, True, nm="Título de sección (H2)", maxw=w, ann=True)
    for i, ln in enumerate(ls): T(d, x, y + lh(20) + 8 + i * lh(14), ln, 14, fill=GRAY, nm="Párrafo", maxw=w, ann=(i == 0), rep=len(ls))
    return h

def b_evidence(d, x, y, w, ctx, fh=None, name="", text="", **kw):
    h = fh or 200
    card(d, x, y, w, h, "Tarjeta de evidencia")
    O(d, x + P + 20, y + P + 20, 20, FILL, INK, 1.2, nm="Avatar")
    I(d, "user", x + P + 8, y + P + 8, 24, 1.4, nm="Icono de avatar", ann=False)
    tx = x + P + 40 + 12
    top = y + P + (40 - lh(14) - lh(11)) / 2
    T(d, tx, top, fit(name, 14, w - (tx - x) - P, True), 14, True, nm="Nombre del alumno", maxw=w - (tx - x) - P, ann=True)
    T(d, tx, top + lh(14), "Entrega · hace 2 h", 11, fill=GRAY, nm="Metadatos", ann=True)
    yy = y + P + 40 + 16
    ls = wrap(text, 13, w - 2 * P, 3)
    for i, ln in enumerate(ls): T(d, x + P, yy + i * lh(13), ln, 13, nm="Comentario", maxw=w - 2 * P, ann=(i == 0), rep=len(ls))
    R(d, x + P, y + h - P - 44, w - 2 * P, 44, RI, FILL, LIGHT, 1.2, kind="row", nm="Adjunto", pad=[10, 12, 10, 12])
    I(d, "doc", x + P + 12, y + h - P - 44 + 10, 24, 1.4, nm="Icono archivo")
    T(d, x + P + 12 + 24 + 12, y + h - P - 44 + (44 - lh(12)) / 2, "evidencia_reto.pdf", 12, fill=GRAY, nm="Nombre de archivo", ann=True)
    return h

BLOCKS = {k[2:]: v for k, v in globals().items() if k.startswith("b_")}

def draw(d, blk, x, y, w, ctx, fh=None):
    t = blk[0]
    if t == "row":
        _, spans, *rest = blk
        g = ctx["gap"]
        tot = sum(s for s, _ in spans)
        usable = w - g * (len(spans) - 1)
        widths = [usable * s / tot for s, _ in spans]
        dry = Doc(dry=True)
        hs = [draw(dry, b, 0, 0, wd, dict(ctx), None) for (s, b), wd in zip(spans, widths)]
        h = fh or max(hs)
        cx = x
        parent = d.blk
        for k, ((s, b), wd) in enumerate(zip(spans, widths)):
            if not d.dry: d.blk = f"{parent}.{k+1} {WIDGETS[b[0]][0]}"
            draw(d, b, cx, y, wd, ctx, h)
            if k < len(spans) - 1: G(d, cx + wd, y, g, h, "Separación entre columnas", ann=True, orient="h")
            cx += wd + g
        if not d.dry: d.blk = parent
        ctx["_rowinfo"] = [wd for wd in widths]
        ctx["_rowspans"] = [s for s, _ in spans]
        return h
    fn = BLOCKS[t]
    kw = blk[1] if len(blk) > 1 else {}
    return fn(d, x, y, w, ctx, fh, **kw)
