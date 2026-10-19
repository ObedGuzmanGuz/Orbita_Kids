# -*- coding: utf-8 -*-
"""Genera los 80 wireframes (con cotas y limpios) + datos de medidas.
Uso:  pip install cairosvg  &&  python3 build.py"""
import json, os, sys, cairosvg, unicodedata
from specs import SPECS
from frames import render
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
cat = json.load(open(f"{ROOT}/catalogo.json", encoding="utf-8"))
def ascii_slug(s): return unicodedata.normalize("NFD", s).encode("ascii", "ignore").decode()
only = set(sys.argv[1:])
out = {}
for s in cat:
    key = (s["role"], s["platform"], s["slug"])
    sc = dict(SPECS[key], role=s["role"], platform=s["platform"], step=s["step"], title=s["title"], slug=s["slug"])
    name = f"{s['step']:02d}_{ascii_slug(s['slug'])}"
    base = f"assets/wireframes/{s['role']}/{s['platform']}/{name}"
    clean = f"assets/wireframes/{s['role']}/{s['platform']}/limpio/{name}"
    svg, _, spec, els = render(sc, True)
    out[key] = dict(file=base + ".png", svg=base + ".svg", fileClean=clean + ".png", spec=spec, elements=els)
    if only and f"{s['role'][:3]}-{s['platform'][:3]}-{s['step']}" not in only:
        continue
    scale = 1.6
    os.makedirs(os.path.dirname(f"{ROOT}/{clean}"), exist_ok=True)
    open(f"{ROOT}/{base}.svg", "w", encoding="utf-8").write(svg)
    cairosvg.svg2png(bytestring=svg.encode("utf-8"), write_to=f"{ROOT}/{base}.png", scale=scale)
    svg2, *_ = render(sc, False)
    cairosvg.svg2png(bytestring=svg2.encode("utf-8"), write_to=f"{ROOT}/{clean}.png", scale=1.25)
json.dump({"|".join(k): v for k, v in out.items()}, open(os.path.join(os.path.dirname(__file__), "out.json"), "w", encoding="utf-8"), ensure_ascii=False)
print("ok", len(out))
