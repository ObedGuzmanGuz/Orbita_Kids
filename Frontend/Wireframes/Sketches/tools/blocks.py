# -*- coding: utf-8 -*-
from lib import *

# nombre legible + widget sugerido por tecnología
WIDGETS = {
 "title":  ("Encabezado de página", "<PageHeader/>", "Text (headlineSmall) + Text"),
 "stats":  ("Tarjetas métricas", "<StatCard/> ×N", "Card + Column (Row de Expanded)"),
 "hero":   ("Tarjeta destacada", "<HeroCard/>", "Card + FilledButton.tonal"),
 "grid":   ("Cuadrícula de tarjetas", "<CardGrid/>", "GridView.count / Wrap"),
 "steps":  ("Lista de pasos", "<StepList/>", "ListView + ListTile"),
 "form":   ("Formulario", "<Form/> + <TextField/>", "Form + TextFormField"),
 "note":   ("Nota / aviso", "<InfoCard/>", "Card + ListTile"),
 "chart":  ("Gráfica de líneas", "<LineChart/> (Recharts)", "CustomPaint / fl_chart LineChart"),
 "bars":   ("Barras de progreso", "<ProgressList/>", "LinearProgressIndicator"),
 "question": ("Pregunta", "<QuestionCard/>", "Card + Text"),
 "options": ("Opciones (radio)", "<RadioGroup/>", "RadioListTile"),
 "video":  ("Reproductor de video", "<video/> / <VideoPlayer/>", "AspectRatio 16:9 + video_player"),
 "timer":  ("Temporizador", "<Countdown/>", "Stack + CircularProgressIndicator"),
 "check":  ("Lista de verificación", "<Checklist/>", "CheckboxListTile"),
 "list":   ("Lista con avatar", "<ListRow/> ×N", "ListView.separated + ListTile"),
 "table":  ("Tabla de datos", "<DataTable/>", "DataTable / Table"),
 "chips":  ("Filtros (chips)", "<ChipGroup/>", "Wrap + ChoiceChip"),
 "search": ("Campo de búsqueda", "<SearchInput/>", "SearchBar"),
 "toggles": ("Ajustes (switches)", "<SettingRow/> ×N", "SwitchListTile"),
 "week":   ("Calendario semanal", "<WeekStrip/>", "Row de Expanded (7 días)"),
 "profile": ("Tarjeta de perfil", "<ProfileCard/>", "Card + CircleAvatar"),
 "btn":    ("Botón", "<Button/>", "FilledButton / OutlinedButton"),
 "btns":   ("Botones en fila", "<ButtonRow/>", "Row + Expanded(Button)"),
 "doc":    ("Vista previa de documento", "<DocPreview/>", "AspectRatio + Container"),
 "rubric": ("Matriz de rúbrica", "<RubricGrid/>", "Table + Radio"),
 "illus":  ("Imagen / ilustración", "<img/> (placeholder)", "Image / Placeholder"),
 "text":   ("Bloque de texto", "<p/> + <h2/>", "Column(Text)"),
 "row":    ("Fila de 2 columnas", "CSS grid (12 col)", "Row + Expanded(flex)"),
 "evidence": ("Evidencia del alumno", "<EvidenceCard/>", "Card + ListTile"),
}

def card(d, x, y, w, h, fill="#fff", r=12, sw=1.2, stroke=INK, dash=None):
    d.rect(x, y, w, h, r, fill, stroke, sw, dash)

def gapof(ctx): return ctx["gap"]

def btn(d, x, y, w, h, label, kind="outline", ctx=None):
    if kind == "primary": d.rect(x, y, w, h, 10, INK, INK, 1.2); col = "#fff"
    else: d.rect(x, y, w, h, 10, "#fff", INK, 1.5); col = INK
    d.text(x + w / 2, y + h / 2 + 4.5, fit(label, 13, w - 12, True), 13, "bold", "middle", col)

def inputbox(d, x, y, w, h, label=None, ph=""):
    if label: d.text(x, y - 7, fit(label, 11, w, True), 11, "bold", fill=INK)
    d.rect(x, y, w, h, 8, FILL, LIGHT, 1.2)
    if ph: d.text(x + 12, y + 28 if h > 56 else y + h / 2 + 4, fit(ph, 12, w - 24), 12, fill="#9A9A9A")

# =========================================================
# Cada bloque: fn(d, x, y, w, ctx, fh=None, **kw) -> h
# =========================================================
def b_title(d, x, y, w, ctx, fh=None, title="", sub="", crumb=None):
    if ctx["web"]:
        h = 88
        if crumb: d.text(x, y + 14, fit(crumb, 12, w), 12, fill=GRAY)
        d.text(x, y + 50, fit(title, 28, w, True), 28, "bold")
        d.text(x, y + 74, fit(sub, 14, w), 14, fill=GRAY)
        d.line(x, y + h, x + w, y + h, LIGHT, 1)
        return h + 0
    h = 64
    d.text(x, y + 26, fit(title, 22, w, True), 22, "bold")
    d.text(x, y + 49, fit(sub, 13, w), 13, fill=GRAY)
    return h

def b_stats(d, x, y, w, ctx, fh=None, items=(), **kw):
    n, g = len(items), ctx["gap"]
    h = fh or (104 if ctx["web"] else 88)
    cw = (w - g * (n - 1)) / n
    for i, (lab, val) in enumerate(items):
        cx = x + i * (cw + g)
        card(d, cx, y, cw, h, FILL, 12, 1.2, LIGHT)
        d.text(cx + 14, y + 24, fit(lab, 12, cw - 28), 12, fill=GRAY)
        d.text(cx + 14, y + h - 18, fit(val, 28, cw - 28, True), 28, "bold")
        if i == 0: sizetag(d, cx, y, cw, h, ctx)
    return h

def b_hero(d, x, y, w, ctx, fh=None, title="", text="", button="Abrir", ic="figure", **kw):
    h = fh or (176 if ctx["web"] else 152)
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    d.text(x + 20, y + 34, fit(title, 17, w - 84, True), 17, "bold")
    for i, ln in enumerate(wrap(text, 13, w - 84, 2)): d.text(x + 20, y + 56 + i * 18, ln, 13, fill=GRAY)
    icon(d, ic, x + w - 20 - 32, y + 16, 32, 1.6)
    bw, bh = (max(120, min(w - 40, len(button) * 8.6 + 36)), 48)
    btn(d, x + 20, y + h - 16 - bh, bw, bh, button, "outline")
    sizetag(d, x, y, w, h, ctx)
    return h

def b_grid(d, x, y, w, ctx, fh=None, cols=2, items=(), ch=None, **kw):
    g = ctx["gap"]
    ch = ch or (120 if ctx["web"] else 96)
    cw = (w - g * (cols - 1)) / cols
    rows = (len(items) + cols - 1) // cols
    for i, it in enumerate(items):
        ic, t, sub = it
        cx, cy = x + (i % cols) * (cw + g), y + (i // cols) * (ch + g)
        card(d, cx, cy, cw, ch, "#fff", 12, 1.2, LIGHT)
        icon(d, ic, cx + 14, cy + 14, 24, 1.5)
        d.text(cx + 48, cy + 31, fit(t, 13, cw - 60, True), 13, "bold")
        d.text(cx + 14, cy + ch - 16, fit(sub, 11, cw - 28), 11, fill=GRAY)
        if i == 0: sizetag(d, cx, cy, cw, ch, ctx)
    return rows * ch + (rows - 1) * g

def b_steps(d, x, y, w, ctx, fh=None, items=(), title=None, **kw):
    ih = 48 if ctx["web"] else 44
    yy = y
    if title:
        total = 48 + len(items) * (ih + 8)
        card(d, x, y, w, total, "#fff", 12, 1.2, LIGHT)
        d.text(x + 16, y + 30, fit(title, 14, w - 32, True), 14, "bold")
        x2, w2, yy = x + 12, w - 24, y + 44
    else: x2, w2 = x, w
    for i, t in enumerate(items):
        d.rect(x2, yy, w2, ih, 10, FILL if i % 2 == 0 else "#fff", LIGHT, 1.1)
        d.circle(x2 + 24, yy + ih / 2, 11, "#fff", INK, 1.3)
        d.text(x2 + 24, yy + ih / 2 + 4, str(i + 1), 11, "bold", "middle")
        d.text(x2 + 48, yy + ih / 2 + 4.5, fit(t, 13, w2 - 64), 13)
        if i == 0: sizetag(d, x2, yy, w2, ih, ctx)
        yy += ih + 8
    return (48 + len(items) * (ih + 8)) if title else (yy - 8 - y)

def b_form(d, x, y, w, ctx, fh=None, fields=(), button=None, **kw):
    pad = 16
    hs = []
    for f in fields:
        lab, kind = (f if isinstance(f, tuple) else (f, "input"))
        hs.append((lab, kind, 96 if kind == "area" else 48))
    natural = pad + sum(18 + hh + 14 for _, _, hh in hs) + (48 + pad if button else 0)
    h = fh or natural
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    yy = y + pad + 18
    for i, (lab, kind, hh) in enumerate(hs):
        inputbox(d, x + pad, yy, w - 2 * pad, hh, lab)
        if i == 0: sizetag(d, x + pad, yy, w - 2 * pad, hh, ctx)
        yy += hh + 14 + 18
    if button: btn(d, x + pad, y + h - pad - 48, w - 2 * pad, 48, button, "primary")
    return h

def b_note(d, x, y, w, ctx, fh=None, title="", text="", ic=None, **kw):
    h = fh or (88 if ctx["web"] else 80)
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    d.text(x + 16, y + 28, fit(title, 13, w - 70, True), 13, "bold")
    for i, ln in enumerate(wrap(text, 12, w - 80, 2)): d.text(x + 16, y + 50 + i * 16, ln, 12, fill=GRAY)
    if ic: icon(d, ic, x + w - 16 - 24, y + 14, 24, 1.5)
    sizetag(d, x, y, w, h, ctx)
    return h

def b_chart(d, x, y, w, ctx, fh=None, title="", **kw):
    h = fh or 200
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    d.text(x + 16, y + 28, fit(title, 13, w - 32, True), 13, "bold")
    px0, py0, px1, py1 = x + 24, y + 44, x + w - 20, y + h - 24
    d.line(px0, py0, px0, py1, INK, 1.4); d.line(px0, py1, px1, py1, INK, 1.4)
    vals = [.15, .32, .24, .5, .42, .66, .6, .82]
    pts = [(px0 + 8 + i * (px1 - px0 - 16) / (len(vals) - 1), py1 - 8 - v * (py1 - py0 - 16)) for i, v in enumerate(vals)]
    d.path("M" + " L".join(f"{a:.1f} {b:.1f}" for a, b in pts), stroke=INK, sw=2)
    for a, b in pts: d.circle(a, b, 3.2, INK, INK, 1)
    sizetag(d, x, y, w, h, ctx)
    return h

def b_bars(d, x, y, w, ctx, fh=None, title="", items=(), **kw):
    rh = 40
    h = fh or (48 + len(items) * rh + 8)
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    d.text(x + 16, y + 28, fit(title, 13, w - 32, True), 13, "bold")
    yy = y + 52
    for nm, pct in items:
        d.text(x + 16, yy + 8, nm, 12, "bold"); d.text(x + w - 16, yy + 8, f"{pct}%", 12, "bold", "end")
        d.rect(x + 16, yy + 16, w - 32, 8, 4, "#E6E6E6", "none", 0)
        d.rect(x + 16, yy + 16, (w - 32) * pct / 100, 8, 4, "#555", "none", 0)
        yy += rh
    sizetag(d, x, y, w, h, ctx)
    return h

def b_question(d, x, y, w, ctx, fh=None, head="", text="", **kw):
    h = fh or 88
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    d.text(x + 16, y + 30, fit(head, 14, w - 32, True), 14, "bold")
    for i, ln in enumerate(wrap(text, 13, w - 32, 2)): d.text(x + 16, y + 54 + i * 17, ln, 13, fill=GRAY)
    sizetag(d, x, y, w, h, ctx)
    return h

def b_options(d, x, y, w, ctx, fh=None, items=(), sel=None, **kw):
    ih = 48; yy = y
    for i, t in enumerate(items):
        d.rect(x, yy, w, ih, 10, "#fff", LIGHT, 1.2)
        d.circle(x + 24, yy + ih / 2, 9, "#fff", INK, 1.5)
        if sel == i: d.circle(x + 24, yy + ih / 2, 4.5, INK, INK, 1)
        d.text(x + 46, yy + ih / 2 + 4.5, fit(t, 13, w - 62), 13)
        if i == 0: sizetag(d, x, yy, w, ih, ctx)
        yy += ih + 8
    return yy - 8 - y

def b_video(d, x, y, w, ctx, fh=None, **kw):
    h = fh or round(w * 9 / 16)
    d.rect(x, y, w, h, 12, FILL, INK, 1.4)
    d.line(x, y, x + w, y + h, "#D0D0D0", 1); d.line(x + w, y, x, y + h, "#D0D0D0", 1)
    d.circle(x + w / 2, y + h / 2, 28, "#fff", INK, 1.5)
    d.path(f"M{x+w/2-8:.1f} {y+h/2-12:.1f} L{x+w/2+13:.1f} {y+h/2:.1f} L{x+w/2-8:.1f} {y+h/2+12:.1f}z", stroke=INK, sw=1.4)
    d.text(x + 12, y + 20, "Video 16:9", 10, "normal", fill=GRAY, family=MONO)
    sizetag(d, x, y, w, h, ctx)
    return h

def b_timer(d, x, y, w, ctx, fh=None, title="", time="05:00", text="", **kw):
    h = fh or 240
    card(d, x, y, w, h, FILL, 12, 1.4, INK)
    d.text(x + 16, y + 28, fit(title, 14, w - 32, True), 14, "bold")
    cx, cy = x + w / 2, y + h / 2 + 4
    d.circle(cx, cy, 58, "#fff", INK, 1.6)
    d.text(cx, cy + 9, time, 26, "bold", "middle")
    d.text(x + 16, y + h - 16, fit(text, 12, w - 32), 12, fill=GRAY)
    d.text(cx + 62, cy - 62, "Ø116", 9, "normal", fill="#8A8A8A", family=MONO, keep=True)
    sizetag(d, x, y, w, h, ctx)
    return h

def b_check(d, x, y, w, ctx, fh=None, title="", items=(), **kw):
    ih = 52
    h = fh or (52 + len(items) * ih)
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    d.text(x + 16, y + 32, fit(title, 14, w - 32, True), 14, "bold")
    yy = y + 48
    for i, t in enumerate(items):
        d.line(x + 16, yy, x + w - 16, yy, "#DDD", 1)
        d.rect(x + 18, yy + 16, 20, 20, 4, "#fff", INK, 1.5)
        d.text(x + 50, yy + 31, fit(t, 13, w - 70), 13)
        yy += ih
    sizetag(d, x, y, w, h, ctx)
    return h

def b_list(d, x, y, w, ctx, fh=None, items=(), rh=64, **kw):
    yy = y
    for i, (ic, t, sub) in enumerate(items):
        d.rect(x, yy, w, rh, 12, "#fff", LIGHT, 1.2)
        d.circle(x + 16 + 20, yy + rh / 2, 20, FILL, INK, 1.2)
        if ic: icon(d, ic, x + 16 + 8, yy + rh / 2 - 12, 24, 1.4)
        d.text(x + 72, yy + rh / 2 - 3, fit(t, 14, w - 120, True), 14, "bold")
        d.text(x + 72, yy + rh / 2 + 15, fit(sub, 11, w - 120), 11, fill=GRAY)
        icon(d, "chevron", x + w - 36, yy + rh / 2 - 10, 20, 1.5)
        if i == 0: sizetag(d, x, yy, w, rh, ctx)
        yy += rh + 8
    return yy - 8 - y

def b_table(d, x, y, w, ctx, fh=None, cols=(), rows=(), widths=None, rh=44, **kw):
    n = len(cols)
    widths = widths or [1] * n
    tot = sum(widths); cws = [w * k / tot for k in widths]
    h = fh or (rh + 4 + len(rows) * rh)
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    d.rect(x, y, w, rh, 12, FILL2, "none", 0); d.rect(x, y + 14, w, rh - 14, 0, FILL2, "none", 0)
    d.rect(x, y, w, h, 12, "none", LIGHT, 1.2)
    cx = x
    for i, c in enumerate(cols):
        d.text(cx + 14, y + rh / 2 + 4, fit(c, 12, cws[i] - 20, True), 12, "bold"); cx += cws[i]
    yy = y + rh
    for r in rows:
        d.line(x, yy, x + w, yy, "#DDD", 1)
        cx = x
        for i, c in enumerate(r):
            if isinstance(c, str) and c.startswith("%"):
                p = int(c[1:])
                d.rect(cx + 14, yy + rh / 2 - 4, cws[i] - 56, 8, 4, "#E6E6E6", "none", 0)
                d.rect(cx + 14, yy + rh / 2 - 4, (cws[i] - 56) * p / 100, 8, 4, "#555", "none", 0)
                d.text(cx + cws[i] - 14, yy + rh / 2 + 4, f"{p}%", 11, "bold", "end")
            elif isinstance(c, str) and c.startswith("["):
                d.rect(cx + 14, yy + rh / 2 - 14, min(cws[i] - 24, 104), 28, 8, "#fff", INK, 1.3)
                d.text(cx + 14 + min(cws[i] - 24, 104) / 2, yy + rh / 2 + 4, c.strip("[]"), 11, "bold", "middle")
            else:
                d.text(cx + 14, yy + rh / 2 + 4.5, fit(c, 12, cws[i] - 20, i == 0), 12, "bold" if i == 0 else "normal")
            cx += cws[i]
        yy += rh
    sizetag(d, x, y, w, h, ctx)
    return h

def b_chips(d, x, y, w, ctx, fh=None, items=(), active=0, **kw):
    cx = x
    for i, t in enumerate(items):
        cw = len(t) * 7.4 + 28
        d.rect(cx, y, cw, 36, 18, INK if i == active else "#fff", INK, 1.2)
        d.text(cx + cw / 2, y + 23, t, 12, "bold", "middle", "#fff" if i == active else INK)
        cx += cw + 8
    return 36

def b_search(d, x, y, w, ctx, fh=None, ph="Buscar", **kw):
    d.rect(x, y, w, 48, 24, "#fff", INK, 1.4)
    icon(d, "search", x + 16, y + 12, 24, 1.5)
    d.text(x + 52, y + 29, ph, 13, fill="#9A9A9A")
    sizetag(d, x, y, w, 48, ctx)
    return 48

def b_toggles(d, x, y, w, ctx, fh=None, items=(), **kw):
    rh = 56
    h = fh or len(items) * rh + 8
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    yy = y + 4
    for i, (t, on) in enumerate(items):
        if i: d.line(x + 16, yy, x + w - 16, yy, "#DDD", 1)
        d.text(x + 16, yy + rh / 2 + 4.5, fit(t, 13, w - 100), 13, "bold" if on else "normal")
        sx = x + w - 16 - 44
        d.rect(sx, yy + rh / 2 - 12, 44, 24, 12, INK if on else "#fff", INK, 1.4)
        d.circle(sx + (32 if on else 12), yy + rh / 2, 8, "#fff" if on else INK, INK, 1.2)
        yy += rh
    sizetag(d, x, y, w, h, ctx)
    return h

def b_week(d, x, y, w, ctx, fh=None, days="LMXJVSD", marks=(1, 3, 5), **kw):
    g = 12; h = fh or 140
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    d.text(x + 16, y + 28, "Plan semanal", 13, "bold")
    cw = (w - 32 - g * 6) / 7
    for i, dd in enumerate(days):
        cx = x + 16 + i * (cw + g)
        d.rect(cx, y + 44, cw, h - 60, 10, FILL if i in marks else "#fff", LIGHT, 1.2)
        d.text(cx + cw / 2, y + 66, dd, 12, "bold", "middle")
        d.circle(cx + cw / 2, y + 92, 8, INK if i in marks else "#fff", INK, 1.3)
        if i == 0: sizetag(d, cx, y + 44, cw, h - 60, dict(ctx, tags=ctx["tags"]))
    return h

def b_profile(d, x, y, w, ctx, fh=None, name="", sub="", **kw):
    h = fh or 120
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    d.circle(x + 16 + 36, y + h / 2, 36, FILL, INK, 1.4)
    icon(d, "user", x + 16 + 36 - 16, y + h / 2 - 16, 32, 1.4)
    d.text(x + 112, y + h / 2 - 2, fit(name, 17, w - 128, True), 17, "bold")
    d.text(x + 112, y + h / 2 + 20, fit(sub, 12, w - 128), 12, fill=GRAY)
    d.text(x + 16 + 36, y + h / 2 + 52, "Ø72", 9, "normal", "middle", "#8A8A8A", MONO) if False else None
    sizetag(d, x, y, w, h, ctx)
    return h

def b_btn(d, x, y, w, ctx, fh=None, label="", kind="primary", **kw):
    btn(d, x, y, w, 48, label, kind)
    sizetag(d, x, y, w, 48, dict(ctx, tags=True)) if w > 150 else None
    return 48

def b_btns(d, x, y, w, ctx, fh=None, items=(), **kw):
    g = 12; n = len(items); bw = (w - g * (n - 1)) / n
    for i, (lab, kind) in enumerate(items): btn(d, x + i * (bw + g), y, bw, 48, lab, kind)
    sizetag(d, x, y, bw, 48, ctx)
    return 48

def b_doc(d, x, y, w, ctx, fh=None, title="", hh=240, **kw):
    h = fh or hh
    card(d, x, y, w, h, FILL, 12, 1.2, LIGHT)
    pw = min(w - 48, (h - 40) * 0.72); px = x + (w - pw) / 2
    d.rect(px, y + 20, pw, h - 40, 4, "#fff", INK, 1.3)
    d.text(px + 14, y + 46, fit(title, 12, pw - 28, True), 12, "bold")
    yy = y + 62
    while yy < y + h - 40:
        d.line(px + 14, yy, px + pw - (14 if (yy // 12) % 3 else 50), yy, "#C8C8C8", 3); yy += 14
    sizetag(d, x, y, w, h, ctx)
    return h

def b_rubric(d, x, y, w, ctx, fh=None, levels=("Inicial", "Básico", "Logrado", "Destacado"), rows=(), sel=None, **kw):
    rh = 52 if ctx["web"] else 80
    h = fh or ((44 + len(rows) * rh + 4) if ctx["web"] else (16 + len(rows) * rh))
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    first = w * (0.30 if ctx["web"] else 0.0)
    if ctx["web"]:
        cw = (w - first) / len(levels)
        d.rect(x, y, w, 44, 12, FILL2, "none", 0); d.rect(x, y + 14, w, 30, 0, FILL2, "none", 0); d.rect(x, y, w, h, 12, "none", LIGHT, 1.2)
        d.text(x + 14, y + 27, "Criterio", 12, "bold")
        for j, l in enumerate(levels): d.text(x + first + cw * j + cw / 2, y + 27, l, 12, "bold", "middle")
        yy = y + 44
        for i, r in enumerate(rows):
            d.line(x, yy, x + w, yy, "#DDD", 1)
            d.text(x + 14, yy + rh / 2 + 4, fit(r, 12, first - 20, True), 12, "bold")
            for j in range(len(levels)):
                cx = x + first + cw * j + cw / 2
                d.circle(cx, yy + rh / 2, 9, INK if (sel or [2, 1, 3, 2, 2])[i % 5] == j else "#fff", INK, 1.4)
            yy += rh
    else:
        yy = y + 8
        for i, r in enumerate(rows):
            d.text(x + 16, yy + 22, fit(r, 13, w - 32, True), 13, "bold")
            lw = (w - 32) / len(levels)
            for j, l in enumerate(levels):
                cx = x + 16 + lw * j + lw / 2
                d.circle(cx, yy + 40, 8, INK if (sel or [2, 1, 3, 2])[i % 4] == j else "#fff", INK, 1.4)
                d.text(cx, yy + 62 - 4 + 8, l[:7], 8, "normal", "middle", GRAY)
            if i < len(rows) - 1: d.line(x + 16, yy + 76, x + w - 16, yy + 76, "#DDD", 1)
            yy += 80
    sizetag(d, x, y, w, h, ctx)
    return h

def b_illus(d, x, y, w, ctx, fh=None, ic="sun", label="Ilustración", **kw):
    h = fh or 120
    d.rect(x, y, w, h, 12, FILL2, LIGHT, 1.2)
    icon(d, ic, x + w / 2 - 28, y + h / 2 - 28, 56, 1.4, "#555")
    d.text(x + 12, y + 20, label, 10, "normal", fill=GRAY, family=MONO)
    sizetag(d, x, y, w, h, ctx)
    return h

def b_text(d, x, y, w, ctx, fh=None, title="", body="", **kw):
    ls = wrap(body, 14, w, 3)
    h = fh or (34 + len(ls) * 20 + 6)
    d.text(x, y + 22, fit(title, 20, w, True), 20, "bold")
    for i, ln in enumerate(ls): d.text(x, y + 48 + i * 20, ln, 14, fill=GRAY)
    return h

def b_evidence(d, x, y, w, ctx, fh=None, name="", text="", **kw):
    h = fh or 200
    card(d, x, y, w, h, "#fff", 12, 1.2, LIGHT)
    d.circle(x + 36, y + 36, 20, FILL, INK, 1.2); icon(d, "user", x + 24, y + 24, 24, 1.4)
    d.text(x + 68, y + 32, fit(name, 14, w - 90, True), 14, "bold")
    d.text(x + 68, y + 50, "Entrega · hace 2 h", 11, fill=GRAY)
    yy = y + 78
    for ln in wrap(text, 13, w - 32, 3): d.text(x + 16, yy, ln, 13); yy += 18
    d.rect(x + 16, y + h - 16 - 44, w - 32, 44, 8, FILL, LIGHT, 1.2)
    icon(d, "doc", x + 28, y + h - 16 - 34, 24, 1.4); d.text(x + 60, y + h - 16 - 17, "evidencia_reto.pdf", 12, fill=GRAY)
    sizetag(d, x, y, w, h, ctx)
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
        for (s, b), wd in zip(spans, widths):
            draw(d, b, cx, y, wd, ctx, h); cx += wd + g
        ctx["_rowinfo"] = [round(wd) for wd in widths]
        return h
    fn = BLOCKS[t]
    kw = blk[1] if len(blk) > 1 else {}
    return fn(d, x, y, w, ctx, fh, **kw)
