# -*- coding: utf-8 -*-
"""Motor de wireframes B/N con cotas exhaustivas.

- Móvil  → Flutter: píxeles lógicos (lp = dp). 1 lp en el lienzo = 1 unidad SVG.
- Web    → React + Vite: px CSS (1 rem = 16 px). 1 px CSS = 1 unidad SVG.

Cada primitiva con significado (caja, círculo, icono, texto, separación) se registra
en Doc.els con su geometría exacta; esa misma lista dibuja las cotas rojas y alimenta
las tablas de medidas (medidas.js / medidas.csv / medidas.html).
"""
import html

FONT = "DejaVu Sans, Verdana, sans-serif"
MONO = "DejaVu Sans Mono, monospace"
INK, GRAY, LIGHT, FILL, FILL2 = "#111", "#666", "#BDBDBD", "#F6F6F6", "#EDEDED"
ACC = "#E0003C"          # color de cotas / redlines

# alto de línea por tamaño de fuente (misma escala en Flutter y web)
LH = {8: 12, 9: 12, 10: 14, 11: 16, 12: 16, 13: 18, 14: 20, 16: 22, 17: 24, 20: 28, 22: 28, 26: 32, 28: 36}
def lh(fs): return LH.get(fs, round(fs * 1.35))

def esc(s): return html.escape(str(s), quote=True)

def num(v):
    """Número exacto: entero si lo es, si no hasta 2 decimales."""
    v = round(float(v), 2)
    return str(int(v)) if v == int(v) else f"{v:.2f}".rstrip("0").rstrip(".")

class Doc:
    def __init__(s, dry=False):
        s.p = []; s.dry = dry; s.els = []; s.blk = None
    def add(s, x):
        if not s.dry: s.p.append(x)
    def reg(s, kind, name, x, y, w, h, **kw):
        if s.dry: return None
        e = dict(kind=kind, name=name, x=x, y=y, w=w, h=h, block=s.blk)
        e.update(kw)
        s.els.append(e)
        return e
    # ---------- primitivas ----------
    def rect(s, x, y, w, h, r=0, fill="none", stroke=INK, sw=1.2, dash=None):
        d = f' stroke-dasharray="{dash}"' if dash else ''
        s.add(f'<rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{h:.2f}" rx="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>')
    def line(s, x1, y1, x2, y2, stroke=INK, sw=1, dash=None):
        d = f' stroke-dasharray="{dash}"' if dash else ''
        s.add(f'<line x1="{x1:.2f}" y1="{y1:.2f}" x2="{x2:.2f}" y2="{y2:.2f}" stroke="{stroke}" stroke-width="{sw}"{d}/>')
    def circle(s, cx, cy, r, fill="none", stroke=INK, sw=1.2, dash=None):
        d = f' stroke-dasharray="{dash}"' if dash else ''
        s.add(f'<circle cx="{cx:.2f}" cy="{cy:.2f}" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>')
    def text(s, x, y, t, size=13, weight="normal", anchor="start", fill=INK, family=FONT, rot=None, keep=False):
        """keep=False → wireframe puro: el texto se sustituye por una barra. Devuelve (x0, ancho_barra)."""
        if not keep:
            n = len(str(t).strip())
            if n == 0: return (x, 0)
            w = max(size * 0.9, min(n * size * 0.52, 260 if size < 20 else 340))
            bh = max(3.0, size * 0.42)
            x0 = x if anchor == "start" else (x - w / 2 if anchor == "middle" else x - w)
            col = "#FFFFFF" if str(fill).lower() in ("#fff", "#ffffff") else ("#8C8C8C" if weight == "bold" else "#C9C9C9")
            s.add(f'<rect x="{x0:.2f}" y="{y - size * 0.72:.2f}" width="{w:.2f}" height="{bh:.2f}" rx="{bh/2:.2f}" fill="{col}"/>')
            return (x0, w)
        tr = f' transform="rotate({rot} {x:.2f} {y:.2f})"' if rot else ''
        s.add(f'<text x="{x:.2f}" y="{y:.2f}" font-family="{family}" font-size="{size}" font-weight="{weight}" text-anchor="{anchor}" fill="{fill}"{tr}>{esc(t)}</text>')
        return (x, 0)
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
        d.path(pth, stroke=stroke, sw=sw / k if k else sw, tr=f"translate({x:.2f} {y:.2f}) scale({k:.3f})")

# =========================================================
# Primitivas registradas (dibujan + registran la medida)
# =========================================================
def R(d, x, y, w, h, r=0, fill="none", stroke=INK, sw=1.2, dash=None, kind="box", nm="Contenedor",
      pad=None, ann=True, rep=1, padann=False, note=None, tag="in"):
    d.rect(x, y, w, h, r, fill, stroke, sw, dash)
    return d.reg(kind, nm, x, y, w, h, r=r, pad=pad, ann=ann, rep=rep, padann=padann, note=note, tag=tag,
                 stroke=sw if stroke not in ("none", None) else 0)

def O(d, cx, cy, r, fill="none", stroke=INK, sw=1.2, dash=None, nm="Círculo", ann=True, rep=1, side="r", note=None):
    d.circle(cx, cy, r, fill, stroke, sw, dash)
    return d.reg("circle", nm, cx - r, cy - r, 2 * r, 2 * r, r=r, ann=ann, rep=rep, side=side, note=note)

def I(d, name, x, y, s=24, sw=1.6, stroke=INK, nm=None, ann=True, rep=1, side="r"):
    icon(d, name, x, y, s, sw, stroke)
    return d.reg("icon", nm or f"Icono «{name}»", x, y, s, s, ann=ann, rep=rep, side=side, icon=name)

def T(d, x, top, t, fs=13, bold=False, fill=INK, anchor="start", nm="Texto", maxw=None, ann=False, rep=1, keep=False, family=FONT):
    """Texto posicionado por la parte superior de su caja de línea (top). Registra fs / peso / alto de línea."""
    L = lh(fs)
    base = top + (L - fs) / 2 + 0.78 * fs
    x0, bw = d.text(x, base, t, fs, "bold" if bold else "normal", anchor, fill, family, keep=keep)
    w = maxw if maxw else bw
    if anchor == "middle" and maxw: x0 = x - maxw / 2
    if anchor == "end" and maxw: x0 = x - maxw
    return d.reg("text", nm, x0, top, w, L, fs=fs, fw=700 if bold else 400, lh=L, align=anchor, ann=ann, rep=rep,
                 barw=bw, baseline=base, auto=not maxw)

def LN(d, x1, y1, x2, y2, stroke=INK, sw=1, nm="Divisor", ann=False):
    d.line(x1, y1, x2, y2, stroke, sw)
    return d.reg("divider", nm, min(x1, x2), min(y1, y2), abs(x2 - x1), abs(y2 - y1) or sw, ann=ann, sw=sw)

def G(d, x, y, w, h, nm="Separación", ann=True, orient="v"):
    """Separación (gap) entre hermanos. orient v = vertical (alto = gap), h = horizontal (ancho = gap)."""
    return d.reg("gap", nm, x, y, w, h, ann=ann, orient=orient)

# =========================================================
# Cotas
# =========================================================
def _lbl_box(d, cx, cy, label, size, color, bg="#fff", rot=False):
    wlab = len(label) * size * 0.62 + 6
    if rot:
        d.rect(cx - size / 2 - 3, cy - wlab / 2, size + 5, wlab, 1.5, bg, "none", 0)
        d.text(cx + size * 0.35, cy, label, size, "bold", "middle", color, MONO, rot=-90, keep=True)
    else:
        d.rect(cx - wlab / 2, cy - size / 2 - 3, wlab, size + 5, 1.5, bg, "none", 0)
        d.text(cx, cy + size * 0.35, label, size, "bold", "middle", color, MONO, keep=True)

def hdim(d, x1, x2, y, label, size=10, tick=5, color=INK, sw=0.9, outside=False):
    d.line(x1, y, x2, y, color, sw)
    a = min(5, abs(x2 - x1) / 3)
    for xx, sgn in ((x1, 1), (x2, -1)):
        d.path(f"M{xx + sgn*a:.2f} {y-2.2:.2f} L{xx:.2f} {y:.2f} L{xx + sgn*a:.2f} {y+2.2:.2f}", stroke=color, sw=sw)
        d.line(xx, y - tick, xx, y + tick, color, sw)
    wlab = len(label) * size * 0.62 + 6
    if outside or wlab > abs(x2 - x1) - 2:
        _lbl_box(d, (x1 + x2) / 2, y - size / 2 - 5, label, size, color)
    else:
        _lbl_box(d, (x1 + x2) / 2, y, label, size, color)

def vdim(d, y1, y2, x, label, size=10, tick=5, color=INK, sw=0.9, outside=None):
    d.line(x, y1, x, y2, color, sw)
    a = min(5, abs(y2 - y1) / 3)
    for yy, sgn in ((y1, 1), (y2, -1)):
        d.path(f"M{x-2.2:.2f} {yy + sgn*a:.2f} L{x:.2f} {yy:.2f} L{x+2.2:.2f} {yy + sgn*a:.2f}", stroke=color, sw=sw)
        d.line(x - tick, yy, x + tick, yy, color, sw)
    wlab = len(label) * size * 0.62 + 6
    cy = (y1 + y2) / 2
    if outside or (outside is None and wlab > abs(y2 - y1) - 2):
        # etiqueta horizontal a un lado de la cota
        side = outside if outside in ("l", "r") else "r"
        lx = x + (wlab / 2 + 5) * (1 if side == "r" else -1)
        _lbl_box(d, lx, cy, label, size, color)
    else:
        _lbl_box(d, x, cy, label, size, color, rot=True)

def pill(d, x, y, label, size=7, anchor="end", color=ACC):
    """Etiqueta roja con fondo blanco. (x, y) = esquina de anclaje (abajo)."""
    w = len(label) * size * 0.61 + 5
    x0 = x - w if anchor == "end" else (x - w / 2 if anchor == "middle" else x)
    d.rect(x0, y - size - 3, w, size + 4, 2, "#fff", color, 0.5)
    d.text(x0 + w / 2, y - 2.6, label, size, "bold", "middle", color, MONO, keep=True)
    return w
