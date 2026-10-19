# -*- coding: utf-8 -*-
"""Genera assets/VISTA_GENERAL_*.jpg (hoja de contacto 5×4 de wireframes con medidas)."""
import json, os
from PIL import Image, ImageDraw, ImageFont
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
cat = json.load(open(f"{ROOT}/catalogo.json", encoding="utf-8"))
F = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 22)
FT = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 34)
for role in ("Estudiante", "Profesor"):
    for plat, tw in (("Movil", 300), ("Web_PWA", 384)):
        items = sorted([s for s in cat if s["role"] == role and s["platform"] == plat], key=lambda s: s["step"])
        ims = [Image.open(f"{ROOT}/{s['file']}").convert("RGB") for s in items]
        th = round(ims[0].height * tw / ims[0].width)
        gap, head, lab = 24, 90, 34
        W = 5 * tw + 6 * gap; H = head + 4 * (th + lab + gap) + gap
        sheet = Image.new("RGB", (W, H), "#EFEFEF"); dr = ImageDraw.Draw(sheet)
        unit = "Flutter · píxeles lógicos (lp)" if plat == "Movil" else "React + Vite · px / rem"
        dr.text((gap, 28), f"ÓRBITA KIDS · WIREFRAMES · {role.upper()} · {'APP MÓVIL' if plat=='Movil' else 'WEB / PWA'} · {unit}", font=FT, fill="#111")
        for i, (s, im) in enumerate(zip(items, ims)):
            x = gap + (i % 5) * (tw + gap); y = head + (i // 5) * (th + lab + gap)
            dr.text((x, y), f"{s['step']:02d} · {s['title']}"[:30], font=F, fill="#111")
            sheet.paste(im.resize((tw, th), Image.LANCZOS), (x, y + lab))
        sheet.save(f"{ROOT}/assets/VISTA_GENERAL_{role}_{plat}.jpg", quality=86)
print("ok")
