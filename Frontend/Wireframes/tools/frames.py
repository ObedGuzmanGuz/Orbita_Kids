# -*- coding: utf-8 -*-
from lib import *
from blocks import draw, WIDGETS, P, BH

NAV_M = [("Inicio", "dot"), ("Retos", "diamond"), ("Cursos", "list"), ("Perfil", "user")]
SIDE = {
 "Estudiante": ["Resumen", "Aprendizaje", "Retos offline", "Actividades", "Progreso", "Recursos"],
 "Profesor":   ["Resumen", "Grupos", "Retos offline", "Actividades", "Evaluación", "Familias"],
}

def r(v): return int(round(v))

def describe(blk, w, h, g, web):
    t = blk[0]; kw = blk[1] if len(blk) > 1 else {}
    name, rc, fl = WIDGETS[t]
    sz = f"{num(w)}×{num(h)}"
    if t == "stats":
        n = len(kw["items"]); cw = (w - g * (n - 1)) / n; sz = f"{num(cw)}×{num(h)} ×{n}"
    elif t == "grid":
        c = kw["cols"]; cw = (w - g * (c - 1)) / c; ch = kw.get("ch") or (120 if web else 96)
        sz = f"{num(cw)}×{ch} ×{len(kw['items'])}"
    elif t == "steps": sz = f"{num(w)}×{num(h)} (fila {48 if web else 44})"
    elif t == "options": sz = f"{num(w)}×48 ×{len(kw['items'])}"
    elif t == "list": sz = f"{num(w)}×{kw.get('rh', 64)} ×{len(kw['items'])}"
    elif t == "toggles": sz = f"{num(w)}×{num(h)} (fila 56)"
    elif t == "btns":
        n = len(kw["items"]); bw = (w - 12 * (n - 1)) / n; sz = f"{num(bw)}×48 ×{n}"
    elif t == "btn": sz = f"{num(w)}×48"
    elif t == "table": sz = f"{num(w)}×{num(h)} (fila 44)"
    return {"name": name, "size": sz, "react": rc, "flutter": fl, "type": t}

# =========================================================
# Capa de cotas
# =========================================================
BOXY = ("card", "button", "input", "row", "chip", "media", "cell", "area", "box", "track", "checkbox", "switch")

def _pad_dims(d, e, fs):
    t, rt, b, l = e["pad"]
    x, y, w, h = e["x"], e["y"], e["w"], e["h"]
    if l: hdim(d, x, x + l, y + h / 2, num(l), fs, 2.5, ACC, 0.7)
    if t: vdim(d, y, y + t, x + l + 12, num(t), fs, 2.5, ACC, 0.7, outside="r")
    if rt and rt != l: hdim(d, x + w - rt, x + w, y + h / 2, num(rt), fs, 2.5, ACC, 0.7)
    if b and b != t: vdim(d, y + h - b, y + h, x + w - rt - 12, num(b), fs, 2.5, ACC, 0.7, outside="l")

def annotate(d, els, fs):
    later = []
    for e in els:
        if not e.get("ann"): continue
        k = e["kind"]; x, y, w, h = e["x"], e["y"], e["w"], e["h"]
        rep = e.get("rep", 1) or 1
        sfx = f" ×{rep}" if rep > 1 else ""
        if k in BOXY:
            lab = f"{num(w)}×{num(h)}" + (f" r{num(e['r'])}" if e.get("r") else "") + sfx
            tg = e.get("tag", "in")
            if tg == "in": later.append((x + w - 3, y + h - 3, lab, "end"))
            elif tg == "tl": later.append((x + 3, y + fs + 5, lab, "start"))
            elif tg == "tr": later.append((x + w - 3, y + fs + 5, lab, "end"))
            elif tg == "above": later.append((x + w, y - 2, lab, "end"))
            elif tg == "below": later.append((x, y + h + fs + 5, lab, "start"))
            elif tg == "out": later.append((x - 3, y + h / 2 + fs / 2 + 1, lab, "end"))
            if e.get("padann") and e.get("pad"): _pad_dims(d, e, fs)
        elif k == "circle":
            lab = f"Ø{num(w)}" + sfx
            sd = e.get("side", "r")
            if sd == "r": later.append((x + w + 2, y + h / 2 + fs / 2 + 1, lab, "start"))
            elif sd == "b": later.append((x + w / 2, y + h + fs + 5, lab, "middle"))
            else: later.append((x - 2, y + h / 2 + fs / 2 + 1, lab, "end"))
        elif k == "icon":
            d.rect(x - 1, y - 1, w + 2, h + 2, 0, "none", ACC, 0.6, "2 1.5")
            lab = f"□{num(w)}" + sfx
            if e.get("side", "r") == "r": later.append((x - 1, y - 2, lab, "start"))
            else: later.append((x + w + 1, y - 2, lab, "end"))
        elif k == "text":
            lab = f"Aa{num(e['fs'])}/{e['lh']}" + (" B" if e["fw"] == 700 else "")
            tw = len(lab) * fs * 0.61 + 5
            bx = e["x"] + (e.get("barw") or 0) + 4 if e["align"] == "start" else None
            base = e["baseline"]
            if e["align"] == "start":
                lim = e["x"] + (e["w"] or 0)
                if bx + tw > lim + 2: later.append((lim, base + 1, lab, "end"))
                else: later.append((bx, base + 1, lab, "start"))
            else:
                bw = e.get("barw") or 0
                cx = (e["x"] + e["w"] / 2) if e["align"] == "middle" else e["x"] + e["w"]
                later.append((cx + bw / 2 + 4 if e["align"] == "middle" else cx + 4, base + 1, lab, "start"))
        elif k == "gap":
            if e["orient"] == "v":
                gx = x + min(w * 0.82, w - 18)
                vdim(d, y, y + h, gx, num(h), fs, 2.5, ACC, 0.7, outside="r")
            else:
                hdim(d, x, x + w, y + min(h * 0.5, 28), num(w), fs, 2.5, ACC, 0.7, outside=True)
        elif k == "colw":
            hdim(d, x + 1, x + w - 1, y + 5, num(w), fs, 2, ACC, 0.6)
    for (lx, ly, lab, anc) in later: pill(d, lx, ly, lab, fs, anc)

def legend(d, x, y, lines, size):
    for i, (head, body) in enumerate(lines):
        yy = y + i * (size + 7)
        d.text(x, yy, head, size, "bold", "start", ACC if head.startswith("ROJO") else INK, MONO, keep=True)
        d.text(x + len(head) * size * 0.62 + 8, yy, body, size, "normal", "start", "#333", MONO, keep=True)

# =========================================================
def export(els, unit):
    """Agrupa elementos idénticos repetidos dentro del mismo bloque y devuelve filas exactas."""
    rows, idx = [], {}
    for e in els:
        key = (e.get("block"), e["kind"], e["name"], num(e["w"]) if e["w"] else "", num(e["h"]), e.get("fs"), e.get("r"))
        if key in idx:
            rows[idx[key]]["n"] += 1
            continue
        row = {"b": e.get("block") or "", "k": e["kind"], "nm": e["name"], "x": num(e["x"]), "y": num(e["y"]),
               "w": "auto" if (e.get("auto") or not e["w"]) else num(e["w"]), "h": num(e["h"]), "n": 1}
        if e.get("r"): row["r"] = num(e["r"])
        if e.get("pad"): row["pad"] = [num(v) for v in e["pad"]]
        if e["kind"] == "text": row.update(fs=e["fs"], fw=e["fw"], lh=e["lh"], al=e["align"])
        if e.get("note"): row["note"] = e["note"]
        if e["kind"] == "icon": row["ic"] = e.get("icon")
        if e["kind"] == "gap": row["or"] = e.get("orient")
        idx[key] = len(rows); rows.append(row)
    return rows

# =========================================================
def render_mobile(sc, annotate_on=True):
    W, H = 375, 812
    L, T0 = 104, 112
    CW, CH = W + L + 104, H + T0 + 150
    d = Doc(); ctx = {"web": False, "gap": 12}
    FS = 7
    d.add(f'<svg xmlns="http://www.w3.org/2000/svg" width="{CW}" height="{CH}" viewBox="0 0 {CW} {CH}">')
    d.rect(0, 0, CW, CH, 0, "#EFEFEF", "none", 0)
    d.raw(f'<g transform="translate({L} {T0})">')
    # ---- dispositivo / barra de estado
    d.rect(0, 0, W, H, 44, "#fff", INK, 3)
    d.blk = "00 Chrome · Barra de estado (sistema)"
    d.reg("region", "Barra de estado / SafeArea superior", 0, 0, W, 44, ann=False, note="MediaQuery.padding.top (44 en el lienzo base)")
    R(d, 133, 10, 110, 28, 14, INK, INK, 1, kind="box", nm="Isla del dispositivo (referencia, no se implementa)", ann=False)
    T(d, 32, 12, "9:41", 13, True, nm="Hora (sistema)")
    d.rect(318, 21, 24, 12, 3, "none", INK, 1.3); d.rect(320, 23, 15, 8, 1, INK, INK, 0)
    for i in range(3): d.rect(296 + i * 5, 26 - i * 3, 3, 5 + i * 3, 0, INK, INK, 0)
    # ---- AppBar
    d.blk = "00 Chrome · AppBar"
    d.reg("region", "AppBar", 0, 44, W, 56, ann=False, pad=[0, 16, 0, 16], note="toolbarHeight: 56")
    O(d, 16 + 14, 72, 14, "none", INK, 1.3, "2 3", nm="Logo (placeholder)", side="r")
    T(d, 54, 72 - 17, "ÓRBITA KIDS", 14, True, nm="Nombre de la app", maxw=200, ann=True)
    T(d, 54, 72 + 3, f"{sc['role'].upper()} / MÓVIL", 10, fill=GRAY, nm="Contexto (rol / plataforma)", maxw=200, ann=True)
    O(d, W - 16 - 16, 72, 16, FILL, INK, 1.3, nm="Avatar de usuario", side="l", note="Área táctil 48×48 (IconButton)")
    I(d, "user", W - 16 - 16 - 9, 72 - 9, 18, 1.3, nm="Icono avatar", ann=False)
    LN(d, 0, 100, W, 100, LIGHT, 1, "Divisor AppBar")
    # ---- contenido
    d.raw(f'<clipPath id="cc"><rect x="0" y="100" width="{W}" height="648"/></clipPath><g clip-path="url(#cc)">')
    y = 116; x = 16; w = 343; g = 12
    blocks = [("title", dict(title=sc["title_ui"], sub=sc["sub"]))] + sc["blocks"]
    marks, comps = [], []
    for i, b in enumerate(blocks):
        d.blk = f"{i+1:02d} {WIDGETS[b[0]][0]}"
        h = draw(d, b, x, y, w, ctx)
        d.reg("block", WIDGETS[b[0]][0], x, y, w, h, ann=False)
        marks.append((y, y + h))
        if b[0] == "row":
            for (sp, cb), cw in zip(b[1], ctx.get("_rowinfo", [])): comps.append(describe(cb, cw, h, g, False))
        else: comps.append(describe(b, w, h, g, False))
        y += h + g
    total = y - g
    d.raw('</g>')
    over = total > 748 - 16
    if over:
        d.rect(0, 722, W, 26, 0, "#fff", "none", 0)
        d.text(W / 2, 739, f"scroll ↓ {r(total - 100)}lp", 9, "normal", "middle", GRAY, MONO, keep=True)
    # ---- NavigationBar
    d.raw(f'<clipPath id="dv"><rect x="0" y="0" width="{W}" height="{H}" rx="44"/></clipPath><g clip-path="url(#dv)">')
    d.blk = "00 Chrome · NavigationBar"
    d.rect(0, 748, W, 64, 0, "#fff", "none", 0)
    d.reg("region", "NavigationBar", 0, 748, W, 64, ann=False, note="height: 64 · 4 destinos")
    LN(d, 0, 748, W, 748, LIGHT, 1, "Divisor NavigationBar")
    act = sc.get("nav", 0)
    iw = W / 4
    for i, (lab, ic) in enumerate(NAV_M):
        cx = iw * i + iw / 2; f = i == 0
        R(d, iw * i, 748, iw, 64, 0, "none", "none", 0, kind="cell", nm="Destino de navegación", pad=[8, 0, 0, 0], ann=False, rep=4)
        I(d, ic, cx - 12, 756, 24, 2.1 if i == act else 1.4, nm="Icono de destino", ann=f, rep=4)
        T(d, cx, 756 + 24 + 4, lab, 10, i == act, anchor="middle", nm="Etiqueta de destino", rep=4, ann=f)
    R(d, W / 2 - 60, 802, 120, 4, 2, INK, INK, 0, kind="box", nm="Indicador de inicio (sistema)", ann=False)
    d.raw('</g></g>')
    d.rect(L, T0, W, H, 44, "none", INK, 3)
    # ---- cotas
    d.raw(f'<g transform="translate({L} {T0})">')
    hdim(d, 0, W, -40, f"{W} lp (dp) · Flutter", 10)
    hdim(d, 0, 16, -18, "16", 9); hdim(d, 16, W - 16, -18, "343 (cuerpo)", 9); hdim(d, W - 16, W, -18, "16", 9)
    for (a, b) in marks: vdim(d, a, b, -22, f"{num(b - a)}", 9)
    vdim(d, 100, 116, -22, "16", 8, color=ACC) if annotate_on else None
    for (a, b), (c, _) in zip(marks, marks[1:]):
        if annotate_on: vdim(d, b, c, -44, "12", 8, 3, ACC, 0.8, outside="l")
    gx = W + 22
    vdim(d, 0, 44, gx, "44", 9); vdim(d, 44, 100, gx, "56", 9)
    vdim(d, 100, 748, gx, "cuerpo 648", 9); vdim(d, 748, 812, gx, "64", 9)
    vdim(d, 0, H, gx + 34, f"{H} lp", 10)
    if annotate_on:
        # nav: ancho de destino
        hdim(d, 0, iw, 812 + 16, num(iw), 8, 3, ACC, 0.7)
        annotate(d, d.els, FS)
    d.raw('</g>')
    if annotate_on:
        legend(d, 24, T0 + H + 52, [
            ("UNIDADES", "Flutter · píxeles lógicos (lp = dp). Úsalos tal cual: SizedBox, EdgeInsets, BorderRadius."),
            ("LIENZO", "375×812 · SafeArea 44 · AppBar 56 · cuerpo 648 (padding 16, gap 12) · NavBar 64"),
            ("TOKENS", "tarjeta pad 16 · destacada 20 · radio 12/10/8 · botón/input h48 · icono 24"),
            ("TIPO", "Aa fs/lh = fontSize / alto de línea (TextStyle.height = lh ÷ fs) · B = w700"),
            ("ROJO", "medida · W×H rN = ancho×alto, radio · Ø diámetro · □ icono · ×N repetido idéntico"),
        ], 9)
    d.raw('</svg>')
    spec = {"frame": {"w": W, "h": H, "unit": "lp", "tech": "Flutter"},
            "regions": [{"name": "Barra de estado (SafeArea)", "size": "375×44"}, {"name": "AppBar (padding h 16)", "size": "375×56"},
                        {"name": "Cuerpo (padding 16, gap 12)", "size": "343×632 útil"}, {"name": "NavigationBar (4 destinos de 93.75)", "size": "375×64"}],
            "components": comps, "contentHeight": r(total - 100)}
    return "\n".join(d.p), (CW, CH), spec, export(d.els, "lp")

def render_web(sc, annotate_on=True):
    W, H = 1280, 800
    L, T0 = 96, 112
    CW, CH = W + L + 150, H + T0 + 140
    d = Doc(); ctx = {"web": True, "gap": 24}
    FS = 8
    d.add(f'<svg xmlns="http://www.w3.org/2000/svg" width="{CW}" height="{CH}" viewBox="0 0 {CW} {CH}">')
    d.rect(0, 0, CW, CH, 0, "#EFEFEF", "none", 0)
    d.raw(f'<g transform="translate({L} {T0})">')
    d.rect(0, 0, W, H, 14, "#fff", INK, 2.5)
    d.raw(f'<clipPath id="fr"><rect x="0" y="0" width="{W}" height="{H}" rx="14"/></clipPath><g clip-path="url(#fr)">')
    # ---- header 80
    d.blk = "00 Chrome · Header"
    d.rect(0, 0, W, 80, 0, "#F0F0F0", "none", 0)
    d.reg("region", "Header (sticky)", 0, 0, W, 80, ann=False, pad=[16, 24, 16, 24])
    LN(d, 0, 80, W, 80, INK, 1.2, "Borde inferior header")
    R(d, 24, 16, 48, 48, 8, "#fff", INK, 1.3, kind="box", nm="Contenedor de logo", tag="below")
    O(d, 48, 40, 14, "none", INK, 1.3, "2 3", nm="Logo (placeholder)", ann=False)
    T(d, 88, 20, "ÓRBITA KIDS", 16, True, nm="Nombre de la app", maxw=200, ann=True)
    T(d, 88, 44, f"PWA · {sc['role']}", 11, fill=GRAY, nm="Contexto (rol)", maxw=200, ann=True)
    R(d, 340, 18, 420, 44, 22, "#fff", LIGHT, 1.2, kind="input", nm="Búsqueda global", pad=[0, 16, 0, 16], padann=True)
    I(d, "search", 356, 28, 24, 1.4, nm="Icono buscar")
    T(d, 392, 18 + (44 - lh(12)) / 2, "Buscar actividades, retos, recursos…", 12, fill="#9A9A9A", nm="Placeholder", maxw=352, ann=True)
    I(d, "bell", 1136, 28, 24, 1.4, nm="Icono notificaciones")
    I(d, "menu", 1176, 28, 24, 1.4, nm="Icono menú")
    G(d, 1160, 28, 16, 24, "Separación entre acciones", orient="h")
    G(d, 1200, 28, 16, 24, "Separación entre acciones", ann=False, orient="h")
    O(d, 1236, 40, 20, FILL, INK, 1.4, nm="Avatar de usuario", side="b")
    I(d, "user", 1225, 29, 22, 1.4, nm="Icono avatar", ann=False)
    # ---- sidebar 260
    d.blk = "00 Chrome · Sidebar"
    d.rect(0, 80, 260, 720, 0, FILL, "none", 0)
    d.reg("region", "Sidebar (fija)", 0, 80, 260, 720, ann=False, pad=[24, 16, 16, 16])
    LN(d, 260, 80, 260, H, INK, 1.2, "Borde sidebar")
    T(d, 24, 104 - lh(12) / 2 - 2, sc["role"].upper(), 12, True, nm="Título de sección", ann=True)
    act = sc.get("side", 0)
    items = SIDE[sc["role"]]
    first_inactive = 0 if act != 0 else 1
    for i, it in enumerate(items):
        yy = 128 + i * 52
        R(d, 16, yy, 228, 44, 10, "#fff", INK if i == act else LIGHT, 2 if i == act else 1.1, kind="row",
          nm="Ítem de navegación (activo)" if i == act else "Ítem de navegación", pad=[0, 16, 0, 16], ann=(i == act or i == first_inactive), rep=1 if i == act else len(items) - 1, padann=(i == first_inactive))
        T(d, 32, yy + (44 - lh(13)) / 2, it, 13, i == act, nm="Etiqueta de ítem", rep=len(items), ann=(i == 0))
        if i < len(items) - 1: G(d, 16, yy + 44, 228, 8, "Separación entre ítems", ann=(i == 0))
    R(d, 16, H - 16 - 88, 228, 88, 12, "#fff", LIGHT, 1.2, kind="card", nm="Tarjeta inferior sidebar", pad=[16, 16, 16, 16], padann=True)
    T(d, 32, H - 16 - 88 + 16, "APRENDER + MOVERSE", 11, True, nm="Título", ann=True)
    T(d, 32, H - 16 - 88 + 16 + 16 + 4, "Pausas y retos reales", 11, fill=GRAY, nm="Texto", ann=True)
    # ---- contenido
    d.raw('<clipPath id="mc"><rect x="261" y="81" width="1018" height="718"/></clipPath><g clip-path="url(#mc)">')
    x, y, w, g = 284, 104, 972, 24
    crumb = f"Inicio / {sc['crumb']} / {sc['title']}"
    blocks = [("title", dict(title=sc["title_ui"], sub=sc["sub"], crumb=crumb))] + sc["blocks"]
    marks, comps = [], []
    for i, b in enumerate(blocks):
        d.blk = f"{i+1:02d} {WIDGETS[b[0]][0]}"
        h = draw(d, b, x, y, w, ctx)
        d.reg("block", WIDGETS[b[0]][0], x, y, w, h, ann=False)
        marks.append((y, y + h))
        if b[0] == "row":
            for (sp, cb), cw in zip(b[1], ctx.get("_rowinfo", [])): comps.append(describe(cb, cw, h, g, True))
        else: comps.append(describe(b, w, h, g, True))
        y += h + g
    total = y - g
    d.raw('</g></g>')
    if total > H - 24:
        d.rect(261, 770, 1018, 28, 0, "#fff", "none", 0)
        d.text(770, 789, f"scroll ↓ {r(total - 80)}px", 10, "normal", "middle", GRAY, MONO, keep=True)
    d.raw('</g>')
    d.rect(L, T0, W, H, 14, "none", INK, 2.5)
    # ---- cotas
    d.raw(f'<g transform="translate({L} {T0})">')
    hdim(d, 0, W, -44, f"{W}px = 80rem · React + Vite", 10)
    hdim(d, 0, 260, -20, "260px · 16.25rem", 9); hdim(d, 260, W, -20, "1020px · 63.75rem", 9)
    vdim(d, 0, 80, -24, "80", 10); vdim(d, 80, H, -24, "720px · 45rem", 10)
    vdim(d, 0, H, -52, "800px · 50rem", 10)
    gx = W + 26
    for (a, b) in marks: vdim(d, a, b, gx, f"{num(b - a)} · {num((b - a) / 16)}rem", 9)
    if annotate_on:
        for (a, b), (c, _) in zip(marks, marks[1:]): vdim(d, b, c, gx + 46, "24", 8, 3, ACC, 0.8, outside="r")
        vdim(d, 80, 104, gx + 46, "24", 8, 3, ACC, 0.8, outside="r")
        hdim(d, 260, 284, 92, "24", FS, 2.5, ACC, 0.7, outside=True)
        hdim(d, 284, 1256, 92, "972px · 60.75rem (útil)", FS, 2.5, ACC, 0.7)
        hdim(d, 1256, 1280, 92, "24", FS, 2.5, ACC, 0.7, outside=True)
        hdim(d, 0, 16, 124, "16", FS, 2.5, ACC, 0.7, outside=True)
        hdim(d, 244, 260, 124, "16", FS, 2.5, ACC, 0.7, outside=True)
        hdim(d, 72, 88, 30, "16", FS, 2.5, ACC, 0.7, outside=True)
        hdim(d, 0, 24, 10, "24", FS, 2.5, ACC, 0.7)
        hdim(d, 1256, 1280, 10, "24", FS, 2.5, ACC, 0.7)
        vdim(d, 0, 16, 64, "16", FS, 2.5, ACC, 0.7, outside="r")
        annotate(d, d.els, FS)
    d.raw('</g>')
    if annotate_on:
        legend(d, 24, T0 + H + 34, [
            ("UNIDADES", "React + Vite · px CSS; rem = px ÷ 16 (html { font-size: 100% } = 16px). 24px = 1.5rem · 48px = 3rem"),
            ("LIENZO", "1280×800 · Header 80 · Sidebar 260 · Main 1020 (padding 24 → útil 972) · gap entre bloques 24 · grid 12 col"),
            ("TOKENS", "tarjeta pad 16 (1rem) · destacada 20 (1.25rem) · radio 12/10/8 · botón/input h48 (3rem) · icono 24"),
            ("TIPO", "Aa fs/lh = font-size / line-height en px (÷16 = rem) · B = font-weight 700"),
            ("ROJO", "medida · W×H rN = ancho×alto, border-radius · Ø diámetro · □ icono · ×N repetido idéntico"),
        ], 11)
    d.raw('</svg>')
    spec = {"frame": {"w": W, "h": H, "unit": "px", "tech": "React + Vite"},
            "regions": [{"name": "Header (padding 16 / 24)", "size": "1280×80"}, {"name": "Sidebar (padding 16)", "size": "260×720"},
                        {"name": "Main (padding 24, gap 24)", "size": "972×672 útil"}],
            "components": comps, "contentHeight": r(total - 80)}
    return "\n".join(d.p), (CW, CH), spec, export(d.els, "px")

def render(sc, annotate_on=True):
    return render_mobile(sc, annotate_on) if sc["platform"] == "Movil" else render_web(sc, annotate_on)
