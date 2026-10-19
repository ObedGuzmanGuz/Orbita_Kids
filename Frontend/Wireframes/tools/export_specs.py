# -*- coding: utf-8 -*-
"""Vuelca tools/out.json a: catalogo.json/js, medidas.js, medidas.csv y tokens/ (CSS, TS, Dart).
Ejecutar después de build.py:  python3 export_specs.py"""
import json, os, csv
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
out = json.load(open(f"{HERE}/out.json", encoding="utf-8"))
cat = json.load(open(f"{ROOT}/catalogo.json", encoding="utf-8"))

# ---------------- tokens (fuente única) ----------------
TOKENS = {
 "spacing": {"xxs": 4, "xs": 8, "sm": 12, "md": 16, "lg": 20, "xl": 24, "xxl": 32},
 "radius": {"card": 12, "button": 10, "row": 10, "input": 8, "doc": 4, "checkbox": 4, "track": 4, "chip": 18, "search": 24, "searchHeader": 22, "switchTrack": 12},
 "size": {"button": 48, "input": 48, "textarea": 96, "chip": 36, "cellButton": 28, "icon": 24, "iconSm": 20, "iconMd": 32, "iconXl": 56,
          "avatar": 40, "avatarAppBar": 32, "avatarLg": 72, "stepBadge": 24, "radio": 20, "radioDot": 10, "radioRubric": 18, "checkbox": 20,
          "switchW": 44, "switchH": 24, "switchThumb": 16, "progress": 8, "timerRing": 116, "playButton": 56, "rowList": 64, "rowToggle": 56,
          "rowCheck": 52, "rowTable": 44, "rowStepMobile": 44, "rowStepWeb": 48, "tapTarget": 48},
 "type": {"h1Web": [28, 36, 700], "h1Mobile": [22, 28, 700], "h2": [20, 28, 700], "timer": [26, 32, 700], "statValue": [28, 36, 700],
          "cardTitle": [17, 24, 700], "brandWeb": [16, 22, 700], "title": [14, 20, 700], "body": [13, 18, 400], "bodyStrong": [13, 18, 700],
          "small": [12, 16, 400], "caption": [11, 16, 400], "label": [11, 16, 700], "nav": [10, 14, 400], "paragraph": [14, 20, 400]},
 "mobile": {"unit": "lp", "canvasW": 375, "canvasH": 812, "statusBar": 44, "appBar": 56, "navBar": 64, "body": 648, "pagePadding": 16,
            "contentWidth": 343, "blockGap": 12, "listGap": 8, "cardPadding": 16, "heroPadding": 20, "navItemW": 93.75},
 "web": {"unit": "px", "rootFontSize": 16, "canvasW": 1280, "canvasH": 800, "header": 80, "headerPaddingX": 24, "headerPaddingY": 16,
         "sidebar": 260, "sidebarPadding": 16, "sidebarItemW": 228, "sidebarItemH": 44, "sidebarItemGap": 8, "main": 1020,
         "mainPadding": 24, "contentWidth": 972, "blockGap": 24, "gridColumns": 12, "gridColumn": 59, "gridGutter": 24,
         "cardPadding": 16, "heroPadding": 20, "searchW": 420, "searchH": 44, "logoBox": 48, "headerAvatar": 40},
}
rem = lambda v: f"{v/16:g}rem"

# ---------------- catálogo + medidas ----------------
MED = {}
rows_csv = []
for s in cat:
    k = f"{s['role']}|{s['platform']}|{s['slug']}"
    o = out[k]
    s.pop("fileSketch", None)
    s["file"], s["svg"], s["fileClean"], s["spec"] = o["file"], o["svg"], o["fileClean"], o["spec"]
    MED[k] = o["elements"]
    unit = "lp" if s["platform"] == "Movil" else "px"
    for e in o["elements"]:
        rows_csv.append([s["role"], s["platform"], f"{s['step']:02d}", s["title"], e["b"], e["k"], e["nm"], e["x"], e["y"], e["w"], e["h"],
                         e.get("r", ""), " ".join(e.get("pad", [])) if e.get("pad") else "", e.get("fs", ""), e.get("lh", ""), e.get("fw", ""), e["n"], unit])
json.dump(cat, open(f"{ROOT}/catalogo.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
open(f"{ROOT}/catalogo.js", "w", encoding="utf-8").write("const CATALOGO=" + json.dumps(cat, ensure_ascii=False) + ";\n")

with open(f"{ROOT}/medidas.csv", "w", encoding="utf-8-sig", newline="") as f:
    w = csv.writer(f)
    w.writerow(["rol", "plataforma", "paso", "pantalla", "bloque", "tipo", "elemento", "x", "y", "ancho", "alto", "radio", "padding (t r b l)", "font-size", "line-height", "peso", "repeticiones", "unidad"])
    w.writerows(rows_csv)

HELPERS = r"""
/* Conversión a código. Web: px → rem (÷16). Flutter: píxeles lógicos tal cual. */
(function(){
 const n=v=>{v=parseFloat(v);return Number.isInteger(v)?String(v):String(+v.toFixed(2));};
 const rem=v=>v==='auto'?'auto':(n(parseFloat(v)/16)+'rem');
 const padF=p=>{if(!p)return '';const[t,r,b,l]=p.map(parseFloat);if(t===r&&r===b&&b===l)return `EdgeInsets.all(${n(t)})`;if(t===b&&l===r)return `EdgeInsets.symmetric(horizontal: ${n(l)}, vertical: ${n(t)})`;return `EdgeInsets.fromLTRB(${n(l)}, ${n(t)}, ${n(r)}, ${n(b)})`;};
 const padC=p=>{if(!p)return '';const v=p.map(x=>rem(x));return (v[0]===v[1]&&v[1]===v[2]&&v[2]===v[3])?v[0]:(v[0]===v[2]&&v[1]===v[3]?`${v[0]} ${v[1]}`:v.join(' '));};
 function flutter(e){
  const fw=e.fw===700?'FontWeight.w700':'FontWeight.w400';
  switch(e.k){
   case 'text': return `TextStyle(fontSize: ${e.fs}, height: ${e.lh} / ${e.fs} /* ≈${n(e.lh/e.fs)} */, fontWeight: ${fw})`;
   case 'circle': return `SizedBox.square(dimension: ${e.w}) · BoxShape.circle  /* CircleAvatar(radius: ${n(e.w/2)}) */`;
   case 'icon': return `Icon(..., size: ${e.w})`;
   case 'gap': return e.or==='h'?`SizedBox(width: ${e.w})`:`SizedBox(height: ${e.h})`;
   case 'colw': return `FlexColumnWidth / FixedColumnWidth(${e.w})`;
   case 'divider': return `Divider(height: 1, thickness: 1)`;
   default: {const p=[`SizedBox(width: ${e.w==='auto'?'double.infinity':e.w}, height: ${e.h})`];if(e.r)p.push(`BorderRadius.circular(${e.r})`);if(e.pad)p.push(padF(e.pad));return p.join(' · ');}
  }
 }
 function css(e){
  switch(e.k){
   case 'text': return `font-size:${rem(e.fs)}; line-height:${rem(e.lh)}; font-weight:${e.fw}`;
   case 'circle': return `width:${rem(e.w)}; height:${rem(e.w)}; border-radius:50%`;
   case 'icon': return `width:${rem(e.w)}; height:${rem(e.w)}`;
   case 'gap': return e.or==='h'?`column-gap:${rem(e.w)}`:`row-gap:${rem(e.h)}`;
   case 'colw': return `grid-template-columns → ${rem(e.w)} (${e.w}px)`;
   case 'divider': return `border-top:1px solid`;
   default: {const p=[`width:${rem(e.w)}`,`height:${rem(e.h)}`];if(e.r)p.push(`border-radius:${rem(e.r)}`);if(e.pad)p.push(`padding:${padC(e.pad)}`);return p.join('; ');}
  }
 }
 const KIND={card:'Tarjeta',button:'Botón',input:'Campo',row:'Fila',chip:'Chip',media:'Medio',cell:'Celda',area:'Área',box:'Caja',track:'Barra',checkbox:'Casilla',switch:'Switch',circle:'Círculo',icon:'Icono',text:'Texto',gap:'Separación',colw:'Columna',divider:'Divisor',region:'Región',block:'Bloque',lines:'Líneas'};
 window.MEDIDAS_UTIL={flutter,css,rem,n,KIND};
})();
"""
open(f"{ROOT}/medidas.js", "w", encoding="utf-8").write(
    "/* Generado por tools/export_specs.py — no editar a mano. */\n"
    "const MEDIDAS_TOKENS=" + json.dumps(TOKENS, ensure_ascii=False) + ";\n"
    "const MEDIDAS=" + json.dumps(MED, ensure_ascii=False, separators=(",", ":")) + ";\n" + HELPERS)

# ---------------- tokens: CSS ----------------
T = TOKENS
def kebab(s): return "".join("-" + c.lower() if c.isupper() else c for c in s)
css = ["/* Órbita Kids · Design tokens WEB (React + Vite)", " * Base: html { font-size: 100% } → 1rem = 16px. Valores px originales en comentario.",
       " * Generado por tools/export_specs.py */", ":root {"]
for grp, pre in (("spacing", "space"), ("radius", "radius"), ("size", "size")):
    css.append(f"  /* {grp} */")
    for k, v in T[grp].items(): css.append(f"  --{pre}-{kebab(k)}: {rem(v)}; /* {v}px */")
css.append("  /* tipografía: font-size / line-height / weight */")
for k, (fs, l, fw) in T["type"].items():
    css.append(f"  --font-{kebab(k)}-size: {rem(fs)}; /* {fs}px */\n  --font-{kebab(k)}-line: {rem(l)}; /* {l}px */\n  --font-{kebab(k)}-weight: {fw};")
css.append("  /* layout web */")
for k, v in T["web"].items():
    if isinstance(v, (int, float)) and k not in ("gridColumns", "rootFontSize"): css.append(f"  --layout-{kebab(k)}: {rem(v)}; /* {v}px */")
css.append(f"  --layout-grid-columns: {T['web']['gridColumns']};")
css += ["}", "", "/* Esqueleto de layout de referencia */",
        ".app-shell { display: grid; grid-template-columns: var(--layout-sidebar) 1fr; grid-template-rows: var(--layout-header) 1fr; min-height: 100vh; }",
        ".app-header { grid-column: 1 / -1; height: var(--layout-header); padding: var(--layout-header-padding-y) var(--layout-header-padding-x); display: flex; align-items: center; }",
        ".app-sidebar { padding: var(--space-xl) var(--layout-sidebar-padding) var(--layout-sidebar-padding); display: flex; flex-direction: column; gap: var(--layout-sidebar-item-gap); }",
        ".app-main { padding: var(--layout-main-padding); display: grid; grid-template-columns: repeat(12, minmax(0, 1fr)); column-gap: var(--layout-grid-gutter); row-gap: var(--layout-block-gap); align-content: start; }",
        ".card { border-radius: var(--radius-card); padding: var(--layout-card-padding); }",
        ".card--hero { padding: var(--layout-hero-padding); }",
        ".btn { height: var(--size-button); border-radius: var(--radius-button); padding: 0 var(--space-md); font-size: var(--font-body-strong-size); line-height: var(--font-body-strong-line); font-weight: 700; }",
        ".input { height: var(--size-input); border-radius: var(--radius-input); padding: 0 var(--space-sm); }", ""]
open(f"{ROOT}/tokens/tokens.css", "w", encoding="utf-8").write("\n".join(css))

# ---------------- tokens: TS (+ Tailwind) ----------------
def tsobj(d, conv):
    return "{\n" + "".join(f"    {k}: '{conv(v)}', // {v}px\n" for k, v in d.items()) + "  }"
ts = ["// Órbita Kids · Design tokens WEB (React + Vite). 1rem = 16px. Generado por tools/export_specs.py", "",
      "export const px = (v: number) => `${v}px`;", "export const rem = (v: number) => `${v / 16}rem`;", "",
      "export const tokens = {",
      f"  spacing: {tsobj(T['spacing'], rem)},", f"  radius: {tsobj(T['radius'], rem)},", f"  size: {tsobj(T['size'], rem)},",
      "  type: {"] + [f"    {k}: {{ fontSize: '{rem(fs)}', lineHeight: '{rem(l)}', fontWeight: {fw} }}, // {fs}/{l}px" for k, (fs, l, fw) in T["type"].items()] + [
      "  },", "  layout: {"] + [f"    {k}: {v}," for k, v in T["web"].items() if k != "unit"] + ["  },", "} as const;", "",
      "// Uso con Tailwind (tailwind.config.ts → theme.extend):",
      "export const tailwindExtend = {",
      "  spacing: Object.fromEntries(Object.entries(tokens.spacing)),",
      "  borderRadius: Object.fromEntries(Object.entries(tokens.radius)),",
      "  fontSize: Object.fromEntries(Object.entries(tokens.type).map(([k, t]) => [k, [t.fontSize, { lineHeight: t.lineHeight, fontWeight: String(t.fontWeight) }]])),",
      "  width: { sidebar: rem(260), content: rem(972), search: rem(420) },",
      "  height: { header: rem(80), control: rem(48), chip: rem(36) },", "};", ""]
open(f"{ROOT}/tokens/tokens.ts", "w", encoding="utf-8").write("\n".join(ts))

# ---------------- tokens: Dart ----------------
def camel(k): return k[0].lower() + k[1:]
def dnum(v): return f"{float(v):g}" if float(v) != int(v) else f"{int(v)}.0"
dart = ["// Órbita Kids · Design tokens MÓVIL (Flutter). Unidades: píxeles lógicos (lp = dp).",
        "// No multiplicar por devicePixelRatio: Flutter ya trabaja en lp. Generado por tools/export_specs.py", "",
        "import 'package:flutter/material.dart';", "", "abstract final class AppSpacing {"]
dart += [f"  static const double {camel(k)} = {dnum(v)};" for k, v in T["spacing"].items()] + ["}", "", "abstract final class AppRadius {"]
dart += [f"  static const double {camel(k)} = {dnum(v)};" for k, v in T["radius"].items()]
dart += ["  static const BorderRadius cardR = BorderRadius.all(Radius.circular(card));", "  static const BorderRadius buttonR = BorderRadius.all(Radius.circular(button));",
         "  static const BorderRadius inputR = BorderRadius.all(Radius.circular(input));", "}", "", "abstract final class AppSize {"]
dart += [f"  static const double {camel(k)} = {dnum(v)};" for k, v in T["size"].items()] + ["}", "", "abstract final class AppLayout {"]
dart += [f"  static const double {camel(k)} = {dnum(v)};" for k, v in T["mobile"].items() if k != "unit"]
dart += ["  static const EdgeInsets page = EdgeInsets.fromLTRB(16, 16, 16, 16);", "  static const EdgeInsets card = EdgeInsets.all(16);",
         "  static const EdgeInsets hero = EdgeInsets.all(20);", "}", "", "abstract final class AppText {",
         "  // height = lineHeight / fontSize (Flutter usa multiplicador)"]
for k, (fs, l, fw) in T["type"].items():
    dart.append(f"  static const TextStyle {camel(k)} = TextStyle(fontSize: {fs}, height: {l}/{fs}, fontWeight: FontWeight.w{fw}); // {fs}/{l}")
dart += ["}", ""]
open(f"{ROOT}/tokens/app_tokens.dart", "w", encoding="utf-8").write("\n".join(dart))
print("ok", len(rows_csv), "filas")
