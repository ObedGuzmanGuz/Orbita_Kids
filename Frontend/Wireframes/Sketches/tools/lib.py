# -*- coding: utf-8 -*-
"""Motor de wireframes B/N con cotas (dp para Flutter, px para React+Vite)."""
import html, math

FONT = "DejaVu Sans, Verdana, sans-serif"
MONO = "DejaVu Sans Mono, monospace"
INK, GRAY, LIGHT, FILL, FILL2 = "#111", "#666", "#BDBDBD", "#F6F6F6", "#EDEDED"

def esc(s): return html.escape(str(s), quote=True)

class Doc:
    def __init__(s, dry=False): s.p = []; s.dry = dry
    def add(s, x):
        if not s.dry: s.p.append(x)
    def rect(s, x, y, w, h, r=0, fill="none", stroke=INK, sw=1.2, dash=None):
        d = f' stroke-dasharray="{dash}"' if dash else ''
        s.add(f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>')
    def line(s, x1, y1, x2, y2, stroke=INK, sw=1, dash=None):
        d = f' stroke-dasharray="{dash}"' if dash else ''
        s.add(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="{stroke}" stroke-width="{sw}"{d}/>')
    def circle(s, cx, cy, r, fill="none", stroke=INK, sw=1.2, dash=None):
        d = f' stroke-dasharray="{dash}"' if dash else ''
        s.add(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>')
    def text(s, x, y, t, size=13, weight="normal", anchor="start", fill=INK, family=FONT, rot=None, keep=False):
        if not keep:
            # wireframe puro: el texto se reemplaza por una barra gris
            n = len(str(t).strip())
            if n == 0: return
            w = max(size * 0.9, min(n * size * 0.52, 260 if size < 20 else 340))
            bh = max(3.0, size * 0.42)
            x0 = x if anchor == "start" else (x - w / 2 if anchor == "middle" else x - w)
            col = "#FFFFFF" if str(fill).lower() in ("#fff", "#ffffff") else ("#8C8C8C" if weight == "bold" else "#C9C9C9")
            s.add(f'<rect x="{x0:.1f}" y="{y - size * 0.72:.1f}" width="{w:.1f}" height="{bh:.1f}" rx="{bh/2:.1f}" fill="{col}"/>')
            return
        tr = f' transform="rotate({rot} {x:.1f} {y:.1f})"' if rot else ''
        s.add(f'<text x="{x:.1f}" y="{y:.1f}" font-family="{family}" font-size="{size}" font-weight="{weight}" text-anchor="{anchor}" fill="{fill}"{tr}>{esc(t)}</text>')
    def path(s, d, fill="none", stroke=INK, sw=1.2, tr=None):
        t = f' transform="{tr}"' if tr else ''
        s.add(f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round"{t}/>')
    def raw(s, x): s.add(x)

def wrap(t, size, w, maxlines=3):
    cw = size * 0.58
    n = max(4, int(w / cw))
    words, lines, cur = str(t).split(), [], ""
    for wd in words:
        if len((cur + " " + wd).strip()) <= n: cur = (cur + " " + wd).strip()
        else: lines.append(cur); cur = wd
    if cur: lines.append(cur)
    if len(lines) > maxlines:
        lines = lines[:maxlines]; lines[-1] = lines[-1][:max(1, n - 1)] + "…"
    return lines

def fit(t, size, w, bold=False):
    cw = size * (0.60 if bold else 0.56)
    n = max(3, int(w / cw))
    t = str(t)
    return t if len(t) <= n else t[:n - 1] + "…"

# ---------- iconos (caja 24x24, solo trazo) ----------
ICONS = {
 "book":   ["M2 5h9v14H2z", "M13 5h9v14h-9z"],
 "figure": ["M12 8v7", "M6 11l6-1 6-1", "M12 15l-4 5", "M12 15l4 5"],
 "noscreen": ["M3 12a9 6 0 1 0 18 0a9 6 0 1 0 -18 0", "M6 19L18 5"],
 "clock":  ["M3 12a9 9 0 1 0 18 0a9 9 0 1 0 -18 0", "M12 7v5l3 2"],
 "sun":    ["M8 12a4 4 0 1 0 8 0a4 4 0 1 0 -8 0", "M12 2v3", "M12 19v3", "M2 12h3", "M19 12h3", "M5 5l2 2", "M17 17l2 2", "M19 5l-2 2", "M7 17l-2 2"],
 "check":  ["M3 12a9 9 0 1 0 18 0a9 9 0 1 0 -18 0", "M8 12l3 3 5-6"],
 "chart":  ["M3 3v18h18", "M7 17v-5", "M11 17v-9", "M15 17v-6", "M19 17v-12"],
 "pencil": ["M4 20l1-5L16 4l4 4L9 19z"],
 "search": ["M4 10a6 6 0 1 0 12 0a6 6 0 1 0 -12 0", "M15 15l5 5"],
 "user":   ["M8 8a4 4 0 1 0 8 0a4 4 0 1 0 -8 0", "M4 21c0-4 4-6 8-6s8 2 8 6"],
 "home":   ["M3 11l9-8 9 8v10H3z"],
 "diamond": ["M12 3l9 9-9 9-9-9z"],
 "list":   ["M4 5h16v14H4z", "M4 10h16", "M4 15h16"],
 "dot":    ["M3 12a9 9 0 1 0 18 0a9 9 0 1 0 -18 0", "M9 12a3 3 0 1 0 6 0a3 3 0 1 0 -6 0"],
 "chevron": ["M9 6l6 6-6 6"],
 "play":   ["M8 5l11 7-11 7z"],
 "doc":    ["M6 3h9l4 4v14H6z", "M9 12h7", "M9 16h7"],
 "bell":   ["M6 17V11a6 6 0 0 1 12 0v6l2 2H4z", "M10 21h4"],
 "menu":   ["M4 6h16", "M4 12h16", "M4 18h16"],
 "users":  ["M4 8a3 3 0 1 0 6 0a3 3 0 1 0 -6 0", "M14 9a3 3 0 1 0 6 0a3 3 0 1 0 -6 0", "M2 20c0-3 3-5 6-5s6 2 6 5", "M15 15c3 0 7 1 7 5"],
 "chat":   ["M3 4h18v12H9l-5 4v-4H3z"],
 "download": ["M12 3v12", "M7 11l5 5 5-5", "M4 20h16"],
 "shield": ["M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6z", "M9 12l2 2 4-4"],
 "leaf":   ["M5 19C5 9 11 5 20 4c0 9-4 15-13 15", "M5 19l8-8"],
}
def icon(d, name, x, y, s=24, sw=1.6, stroke=INK):
    k = s / 24.0
    for pth in ICONS.get(name, ICONS["dot"]):
        d.path(pth, stroke=stroke, sw=sw / k if k else sw, tr=f"translate({x:.1f} {y:.1f}) scale({k:.3f})")

# ---------- cotas ----------
def hdim(d, x1, x2, y, label, size=10, tick=5, weight="bold"):
    d.line(x1, y, x2, y, INK, 0.9)
    for xx, sgn in ((x1, 1), (x2, -1)):
        d.path(f"M{xx + sgn*5:.1f} {y-2.5:.1f} L{xx:.1f} {y:.1f} L{xx + sgn*5:.1f} {y+2.5:.1f}", stroke=INK, sw=0.9)
        d.line(xx, y - tick, xx, y + tick, INK, 0.9)
    d.rect((x1 + x2) / 2 - len(label) * size * 0.31 - 3, y - size / 2 - 3, len(label) * size * 0.62 + 6, size + 5, 0, "#fff", "none", 0)
    d.text((x1 + x2) / 2, y + size * 0.35, label, size, weight, "middle", INK, MONO, keep=True)

def vdim(d, y1, y2, x, label, size=10, tick=5, weight="bold"):
    d.line(x, y1, x, y2, INK, 0.9)
    for yy, sgn in ((y1, 1), (y2, -1)):
        d.path(f"M{x-2.5:.1f} {yy + sgn*5:.1f} L{x:.1f} {yy:.1f} L{x+2.5:.1f} {yy + sgn*5:.1f}", stroke=INK, sw=0.9)
        d.line(x - tick, yy, x + tick, yy, INK, 0.9)
    cy = (y1 + y2) / 2
    d.rect(x - size / 2 - 3, cy - len(label) * size * 0.31 - 3, size + 5, len(label) * size * 0.62 + 6, 0, "#fff", "none", 0)
    d.text(x + size * 0.35, cy, label, size, weight, "middle", INK, MONO, rot=-90, keep=True)

def sizetag(d, x, y, w, h, ctx):
    """Etiqueta de medida dentro del componente (esquina inferior derecha)."""
    if ctx.get("tags", True) and w >= 70 and h >= 30:
        d.text(x + w - 5, y + h - 5, f"{int(round(w))}×{int(round(h))}", 8, "normal", "end", "#8A8A8A", MONO, keep=True)
