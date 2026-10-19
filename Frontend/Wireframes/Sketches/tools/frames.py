# -*- coding: utf-8 -*-
from lib import *
from blocks import draw, WIDGETS

NAV_M = [("Inicio", "dot"), ("Retos", "diamond"), ("Cursos", "list"), ("Perfil", "user")]
SIDE = {
 "Estudiante": ["Resumen", "Aprendizaje", "Retos offline", "Actividades", "Progreso", "Recursos"],
 "Profesor":   ["Resumen", "Grupos", "Retos offline", "Actividades", "Evaluación", "Familias"],
}

def r(v): return int(round(v))

def describe(blk, w, h, g, web):
    t = blk[0]; kw = blk[1] if len(blk) > 1 else {}
    name, rc, fl = WIDGETS[t]
    sz = f"{r(w)}×{r(h)}"
    if t == "stats":
        n = len(kw["items"]); cw = (w - g * (n - 1)) / n; sz = f"{r(cw)}×{r(h)} ×{n}"
    elif t == "grid":
        c = kw["cols"]; cw = (w - g * (c - 1)) / c; ch = kw.get("ch") or (120 if web else 96)
        sz = f"{r(cw)}×{ch} ×{len(kw['items'])}"
    elif t == "steps": sz = f"{r(w)}×{48 if web else 44} ×{len(kw['items'])}"
    elif t == "options": sz = f"{r(w)}×48 ×{len(kw['items'])}"
    elif t == "list": sz = f"{r(w)}×{kw.get('rh', 64)} ×{len(kw['items'])}"
    elif t == "toggles": sz = f"{r(w)}×56 ×{len(kw['items'])}"
    elif t == "btns":
        n = len(kw["items"]); bw = (w - 12 * (n - 1)) / n; sz = f"{r(bw)}×48 ×{n}"
    elif t == "btn": sz = f"{r(w)}×48"
    elif t == "table": sz = f"{r(w)}×{r(h)} (fila 44)"
    return {"name": name, "size": sz, "react": rc, "flutter": fl, "type": t}

def render_mobile(sc):
    W, H = 375, 812
    L, T = 80, 100
    CW, CH = W + L + 90, H + T + 72
    d = Doc(); ctx = {"web": False, "gap": 12, "tags": True}
    d.add(f'<svg xmlns="http://www.w3.org/2000/svg" width="{CW}" height="{CH}" viewBox="0 0 {CW} {CH}">')
    d.rect(0, 0, CW, CH, 0, "#EFEFEF", "none", 0)
    d.raw(f'<g transform="translate({L} {T})">')
    # dispositivo
    d.rect(0, 0, W, H, 44, "#fff", INK, 3)
    d.rect(133, 10, 110, 28, 14, INK, INK, 1)
    d.text(32, 30, "9:41", 13, "bold")
    d.rect(318, 21, 24, 12, 3, "none", INK, 1.3); d.rect(320, 23, 15, 8, 1, INK, INK, 0)
    for i in range(3): d.rect(296 + i * 5, 29 - i * 3 - 3, 3, 5 + i * 3 - 2 + 2, 0, INK, INK, 0)
    # app bar
    d.circle(16 + 14, 72, 14, "none", INK, 1.3, "2 3")
    d.text(54, 70, "ÓRBITA KIDS", 14, "bold")
    d.text(54, 85, f"{sc['role'].upper()} / MÓVIL", 8.5, "normal", fill=GRAY)
    d.circle(W - 16 - 16, 72, 16, FILL, INK, 1.3); icon(d, "user", W - 16 - 16 - 9, 72 - 9, 18, 1.3)
    d.line(0, 100, W, 100, LIGHT, 1)
    # contenido
    d.raw(f'<clipPath id="cc"><rect x="0" y="100" width="{W}" height="648"/></clipPath><g clip-path="url(#cc)">')
    y = 116; x = 16; w = 343; g = 12
    blocks = [("title", dict(title=sc["title_ui"], sub=sc["sub"]))] + sc["blocks"]
    marks, comps = [], []
    for b in blocks:
        h = draw(d, b, x, y, w, ctx)
        marks.append((y, y + h))
        info = describe(b, w, h, g, False)
        if b[0] == "row":
            for (sp, cb), cw in zip(b[1], ctx.get("_rowinfo", [])): comps.append(describe(cb, cw, h, g, False))
        else: comps.append(info)
        y += h + g
    total = y - g
    d.raw('</g>')
    over = total > 748 - 8
    if over:
        d.rect(0, 722, W, 26, 0, "#fff", "none", 0)
        d.text(W / 2, 739, f"scroll ↓ {r(total - 100)}dp", 9, "normal", "middle", GRAY, MONO, keep=True)
    # nav
    d.raw(f'<clipPath id="dv"><rect x="0" y="0" width="{W}" height="{H}" rx="44"/></clipPath><g clip-path="url(#dv)">')
    d.rect(0, 748, W, 64, 0, "#fff", "none", 0); d.line(0, 748, W, 748, LIGHT, 1)
    act = sc.get("nav", 0)
    for i, (lab, ic) in enumerate(NAV_M):
        cx = W / 8 * (2 * i + 1)
        icon(d, ic, cx - 12, 756, 24, 2.1 if i == act else 1.4)
        d.text(cx, 794 - 6, lab, 10, "bold" if i == act else "normal", "middle")
    d.rect(W / 2 - 60, 802, 120, 4, 2, INK, INK, 0)
    d.raw('</g></g>')
    # redibujar contorno encima de todo
    d.rect(L, T, W, H, 44, "none", INK, 3)
    d.raw(f'<g transform="translate({L} {T})">')
    # cotas
    hdim(d, 0, W, -34, f"{W}dp")
    hdim(d, 0, 16, -14, "16", 9); hdim(d, 16, W - 16, -14, "343", 9); hdim(d, W - 16, W, -14, "16", 9)
    for (a, b) in marks: vdim(d, a, b, -18, f"{r(b - a)}", 9)
    gx = W + 22
    vdim(d, 0, 44, gx, "44", 9); vdim(d, 44, 100, gx, "56", 9)
    vdim(d, 100, 748, gx, "content 648", 9); vdim(d, 748, 812, gx, "64", 9)
    d.raw('</g>')
    d.raw('</svg>')
    spec = {"frame": {"w": W, "h": H, "unit": "dp", "tech": "Flutter"},
            "regions": [{"name": "Barra de estado", "size": "375×44"}, {"name": "AppBar", "size": "375×56"},
                        {"name": "Contenido (padding 16, gap 12)", "size": "343×648 útil"}, {"name": "NavigationBar", "size": "375×64"}],
            "components": comps, "contentHeight": r(total - 100)}
    return "\n".join(d.p), (CW, CH), spec

def render_web(sc):
    W, H = 1280, 800
    L, T = 76, 104
    CW, CH = W + L + 110, H + T + 78
    d = Doc(); ctx = {"web": True, "gap": 24, "tags": True}
    d.add(f'<svg xmlns="http://www.w3.org/2000/svg" width="{CW}" height="{CH}" viewBox="0 0 {CW} {CH}">')
    d.rect(0, 0, CW, CH, 0, "#EFEFEF", "none", 0)
    d.raw(f'<g transform="translate({L} {T})">')
    d.rect(0, 0, W, H, 14, "#fff", INK, 2.5)
    d.raw(f'<clipPath id="fr"><rect x="0" y="0" width="{W}" height="{H}" rx="14"/></clipPath><g clip-path="url(#fr)">')
    # header 80
    d.rect(0, 0, W, 80, 0, "#F0F0F0", "none", 0); d.line(0, 80, W, 80, INK, 1.2)
    d.rect(24, 16, 48, 48, 8, "#fff", INK, 1.3); d.circle(48, 40, 14, "none", INK, 1.3, "2 3")
    d.text(88, 38, "ÓRBITA KIDS", 16, "bold"); d.text(88, 56, f"PWA · {sc['role']}", 11, fill=GRAY)
    d.rect(340, 18, 420, 44, 22, "#fff", LIGHT, 1.2); icon(d, "search", 358, 28, 24, 1.4); d.text(392, 45, "Buscar actividades, retos, recursos…", 12, fill="#9A9A9A")
    icon(d, "bell", W - 24 - 40 - 16 - 24 - 16 - 24, 28, 24, 1.4); icon(d, "menu", W - 24 - 40 - 16 - 24, 28, 24, 1.4)
    d.circle(W - 24 - 20, 40, 20, FILL, INK, 1.4); icon(d, "user", W - 24 - 20 - 11, 29, 22, 1.4)
    # sidebar 260
    d.rect(0, 80, 260, 720, 0, FILL, "none", 0); d.line(260, 80, 260, H, INK, 1.2)
    d.text(24, 112, sc["role"].upper(), 12, "bold")
    act = sc.get("side", 0)
    for i, it in enumerate(SIDE[sc["role"]]):
        yy = 128 + i * 52
        d.rect(16, yy, 228, 44, 10, "#fff", INK if i == act else LIGHT, 2 if i == act else 1.1)
        d.text(32, yy + 27, it, 13, "bold" if i == act else "normal")
        if i == 0: d.text(236, yy + 38, "228×44", 8, "normal", "end", "#8A8A8A", MONO)
    d.rect(16, H - 16 - 88, 228, 88, 12, "#fff", LIGHT, 1.2)
    d.text(30, H - 16 - 88 + 28, "APRENDER + MOVERSE", 11, "bold"); d.text(30, H - 16 - 88 + 50, "Pausas y retos reales", 11, fill=GRAY)
    d.text(236, H - 16 - 6, "228×88", 8, "normal", "end", "#8A8A8A", MONO)
    # contenido
    d.raw('<clipPath id="mc"><rect x="261" y="81" width="1018" height="718"/></clipPath><g clip-path="url(#mc)">')
    x, y, w, g = 284, 104, 972, 24
    crumb = f"Inicio / {sc['crumb']} / {sc['title']}"
    blocks = [("title", dict(title=sc["title_ui"], sub=sc["sub"], crumb=crumb))] + sc["blocks"]
    marks, comps = [], []
    for b in blocks:
        h = draw(d, b, x, y, w, ctx)
        marks.append((y, y + h))
        if b[0] == "row":
            for (sp, cb), cw in zip(b[1], ctx.get("_rowinfo", [])): comps.append(describe(cb, cw, h, g, True))
        else: comps.append(describe(b, w, h, g, True))
        y += h + g
    total = y - g
    d.raw('</g></g>')
    if total > H - 12:
        d.rect(261, 770, 1018, 28, 0, "#fff", "none", 0)
        d.text(770, 789, f"scroll ↓ {r(total - 80)}px", 10, "normal", "middle", GRAY, MONO, keep=True)
    d.raw('</g>')
    d.rect(L, T, W, H, 14, "none", INK, 2.5)
    d.raw(f'<g transform="translate({L} {T})">')
    hdim(d, 0, W, -38, f"{W}px"); hdim(d, 0, 260, -16, "260", 9); hdim(d, 260, W, -16, "1020", 9)
    hdim(d, 284, 284 + 972, 74, "972", 9) if False else None
    vdim(d, 0, 80, -22, "80", 10); vdim(d, 80, H, -22, "720", 10)
    gx = W + 24
    for (a, b) in marks: vdim(d, a, b, gx, f"{r(b - a)}", 9)
    vdim(d, 0, 80, gx + 34, "header 80", 9) if False else None
    d.raw('</g>')
    d.raw('</svg>')
    spec = {"frame": {"w": W, "h": H, "unit": "px", "tech": "React + Vite"},
            "regions": [{"name": "Header", "size": "1280×80"}, {"name": "Sidebar", "size": "260×720"},
                        {"name": "Main (padding 24, gap 24)", "size": "972×(720-48) útil"}],
            "components": comps, "contentHeight": r(total - 80)}
    return "\n".join(d.p), (CW, CH), spec

def render(sc):
    return render_mobile(sc) if sc["platform"] == "Movil" else render_web(sc)
