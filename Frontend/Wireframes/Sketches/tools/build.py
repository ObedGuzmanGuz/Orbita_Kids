# -*- coding: utf-8 -*-
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
    sp = SPECS[key]
    sc = dict(sp, role=s["role"], platform=s["platform"], step=s["step"], title=s["title"], slug=s["slug"])
    svg, (cw, ch), spec = render(sc)
    base = f"assets/wireframes/{s['role']}/{s['platform']}/{s['step']:02d}_{ascii_slug(s['slug'])}"
    if only and f"{s['role'][:3]}-{s['platform'][:3]}-{s['step']}" not in only: 
        out[key] = (base, spec); continue
    os.makedirs(os.path.dirname(f"{ROOT}/{base}"), exist_ok=True)
    open(f"{ROOT}/{base}.svg", "w", encoding="utf-8").write(svg)
    cairosvg.svg2png(bytestring=svg.encode("utf-8"), write_to=f"{ROOT}/{base}.png", scale=1.5 if s["platform"] == "Movil" else 1.25)
    out[key] = (base, spec)
json.dump({"|".join(k): {"file": v[0] + ".png", "svg": v[0] + ".svg", "spec": v[1]} for k, v in out.items()},
          open("out.json", "w", encoding="utf-8"), ensure_ascii=False)
print("ok", len(out))
