#!/usr/bin/env python3
"""FORENSIC EXPERT — «Shield of Evidence» brend generatori (yakuniy).

Egasi bergan referens rasm — faqat vizual yo‘nalish. Belgi toza vektor
geometriyada qayta chizilgan original kompozitsiya:

  * qalqon — institutsional ishonch, dalilni himoya qilish;
  * markazdagi tayoq va bitta ilon — umumiy tibbiyot ramzi (Asklepiy
    tayog‘i, jamoat mulki) — sud tibbiyoti;
  * tarozi — ekspert xulosasining xolisligi;
  * barmoq izi (chapda) — kriminalistik dalil;
  * xromatogramma cho‘qqilari (o‘ngda) — analitik laboratoriya
    (shartli shakl, real ma’lumot emas);
  * tashqi bo‘lingan halqa (4 kesik) — aniqlik.

Hech qanday tashkilot (AAFS, WHO, politsiya, vazirlik va h.k.) logotipidan
nusxa emas; 3D/metall effektlar yo‘q — tekis vektor, oltin faqat
emblemada cheklangan aksent.

Uch daraja (optik soddalashtirish):
  full  (≥ 96 px)  — barcha elementlar: splash, About, marketing;
  icon  (41–95 px) — qalqon + tayoq/ilon + tarozi: launcher, App Store;
  small (≤ 40 px)  — qalqon + tayoq/ilon: favicon, kichik header.

Yagona manba: shu fayldagi geometriya → SVG (design/brand/svg), PNG
(cairosvg), Android/iOS ikonlari va splash, hamda Flutter painter
(`apps/mobile/lib/core/widgets/brand_emblem.g.dart`). 100×100 grid.
Talab: `pip install cairosvg pillow`.
"""
import io
import json
import math
from pathlib import Path

import cairosvg
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "design" / "brand"
APP = ROOT / "apps" / "mobile"

NAVY = "#0F1E3D"
NAVY_FILL = "#15284D"     # qalqon ichki foni (to‘q variant)
GRAPHITE = "#1E2633"
WHITE = "#FFFFFF"
SILVER = "#E8EDF4"         # to‘q fonda asosiy siyoh
GOLD_DARK = "#C9A75E"      # to‘q fonda cheklangan oltin aksent
GOLD_LIGHT = "#9C7A33"     # oq fonda oltin (kontrast uchun to‘qroq)
TEAL_LIGHT = "#0A6F7A"
TEAL_DARK = "#4CC9D6"
INK = "#0B1220"

PALETTES = {
    # nom: (ink, gold, accent, shield_fill)
    "light": (NAVY, GOLD_LIGHT, TEAL_LIGHT, WHITE),
    "dark": (SILVER, GOLD_DARK, TEAL_DARK, NAVY_FILL),
    "mono-black": (INK, INK, INK, None),
    "mono-white": (WHITE, WHITE, WHITE, None),
}


# --- Geometriya ------------------------------------------------------------

def arc(cx, cy, rx, ry, a0, a1):
    """Ellips yoyi → kubik Bezye bo‘laklari (≤ 90°). Burchak — gradus."""
    cmds = []
    n = max(1, math.ceil(abs(a1 - a0) / 90))
    step = (a1 - a0) / n
    for i in range(n):
        t0 = math.radians(a0 + step * i)
        t1 = math.radians(a0 + step * (i + 1))
        k = 4 / 3 * math.tan((t1 - t0) / 4)
        p0 = (cx + rx * math.cos(t0), cy + ry * math.sin(t0))
        p3 = (cx + rx * math.cos(t1), cy + ry * math.sin(t1))
        c1 = (p0[0] - k * rx * math.sin(t0), p0[1] + k * ry * math.cos(t0))
        c2 = (p3[0] + k * rx * math.sin(t1), p3[1] - k * ry * math.cos(t1))
        if i == 0:
            cmds.append(("M", p0))
        cmds.append(("C", c1, c2, p3))
    return cmds


def circle(cx, cy, r):
    return arc(cx, cy, r, r, 0, 360) + [("Z",)]


def E(d, role, w=None, fill=False, halo=0.0):
    """Element: path, rang roli, chiziq qalinligi, fon «halo»si (kesishish)."""
    return {"d": d, "role": role, "w": w, "fill": fill, "halo": halo}


def shield(x0, x1, top, notch, shoulder, tip):
    m = (x0 + x1) / 2
    return [("M", (x0, top)),
            ("C", (x0 + (m - x0) * 0.33, top), (x0 + (m - x0) * 0.67, top - notch * 0.3),
             (m, top - notch)),
            ("C", (x1 - (x1 - m) * 0.67, top - notch * 0.3), (x1 - (x1 - m) * 0.33, top),
             (x1, top)),
            ("L", (x1, shoulder)),
            ("C", (x1, shoulder + (tip - shoulder) * 0.45), (m + (x1 - m) * 0.5, tip - 8),
             (m, tip)),
            ("C", (m - (m - x0) * 0.5, tip - 8), (x0, shoulder + (tip - shoulder) * 0.45),
             (x0, shoulder)),
            ("Z",)]


def serpent(y_bottom, y_top, amp, coils, head):
    """Tayoq atrofidagi S-ilon: pastdan yuqoriga `coils` yarim to‘lqin."""
    h = (y_bottom - y_top) / coils
    d = [("M", (50 - amp * 0.55, y_bottom + 1.5))]
    side = 1
    y = y_bottom
    for _ in range(coils):
        y2 = y - h
        d.append(("C", (50 + side * amp, y - h * 0.15), (50 + side * amp, y2 + h * 0.4),
                  (50, y2)))
        side = -side
        y = y2
    # bosh tomonga burilish
    d.append(("C", (50 + head * 0.35, y - 1.6), (50 + head * 0.75, y - 1.6), (50 + head, y)))
    return d, (50 + head + 0.6, y + 0.4)


def scales(beam_y, half, pan_cx, pan_w, drop, w_beam, w_line):
    els = [E([("M", (50 - half, beam_y)), ("L", (50 + half, beam_y))], "gold", w_beam)]
    for side in (-1, 1):
        cx = 50 + side * pan_cx
        l = (cx - pan_w / 2, beam_y + drop)
        r = (cx + pan_w / 2, beam_y + drop)
        els.append(E([("M", l), ("L", (cx, beam_y)), ("L", r)], "gold", w_line))
        pan = [("M", l), ("C", (l[0] + 1, beam_y + drop + pan_w * 0.42),
                              (r[0] - 1, beam_y + drop + pan_w * 0.42), r), ("Z",)]
        els.append(E(pan, "gold", fill=True))
    return els


def emblem(tier):
    els = []
    if tier == "full":
        for a0 in (0, 90, 180, 270):
            els.append(E(arc(50, 50, 46, 46, a0 + 9, a0 + 81), "gold", 3.0))
        for x0, x1 in ((1.5, 8.5), (91.5, 98.5)):
            els.append(E([("M", (x0, 50)), ("L", (x1, 50))], "gold", 2.0))
        sh = shield(25, 75, 21, 4.5, 47, 84)
        els.append(E(sh, "fill", fill=True))
        els.append(E(sh, "ink", 3.0))
        els += scales(31, 19, 15, 10, 9.5, 1.9, 0.9)
        for i, r in enumerate((1.6, 3.4, 5.2, 7.0)):
            els.append(E(arc(37, 58, r, r * 1.22, 150 + i * 8, 470 - i * 10), "accent", 1.15))
        pk = [(55, 64), (57, 64), (58, 59), (59, 64), (60.3, 64), (61.5, 49.5),
              (62.7, 64), (64, 64), (65, 56), (66, 64), (68.5, 64)]
        els.append(E([("M", pk[0])] + [("L", p) for p in pk[1:]], "accent", 1.25))
        els.append(E([("M", (50, 8)), ("L", (50, 91))], "ink", 2.6))
        els.append(E(circle(50, 7, 2.7), "gold", fill=True))
        d, hd = serpent(76, 30, 6.5, 4, 7)
        els.append(E(d, "ink", 3.1, halo=2.2))
        els.append(E(circle(*hd, 2.1), "ink", fill=True))
    elif tier == "icon":
        sh = shield(21, 79, 19, 5.5, 46, 89)
        els.append(E(sh, "fill", fill=True))
        els.append(E(sh, "ink", 4.6))
        els += scales(31, 21, 16.5, 12, 11, 3.0, 1.6)
        els.append(E([("M", (50, 7)), ("L", (50, 95))], "ink", 3.8))
        els.append(E(circle(50, 6.5, 3.8), "gold", fill=True))
        d, hd = serpent(79, 31, 8.5, 4, 9)
        els.append(E(d, "ink", 4.6, halo=2.6))
        els.append(E(circle(*hd, 3.0), "ink", fill=True))
    else:  # small
        sh = shield(15, 85, 15, 7, 46, 94)
        els.append(E(sh, "fill", fill=True))
        els.append(E(sh, "ink", 8.5))
        els.append(E([("M", (50, 18)), ("L", (50, 86))], "ink", 6.0))
        d, hd = serpent(76, 32, 12, 3, 10)
        els.append(E(d, "accent", 6.2, halo=3.6))
        els.append(E(circle(hd[0], hd[1], 4.6), "accent", fill=True))
    return els


# --- SVG -------------------------------------------------------------------

def path_d(d):
    out = []
    for c in d:
        out.append("Z" if c[0] == "Z" else
                   c[0] + " " + " ".join(f"{p[0]:.2f} {p[1]:.2f}" for p in c[1:]))
    return " ".join(out)


def svg_group(tier, palette):
    ink, gold, accent, fill = PALETTES[palette]
    col = {"ink": ink, "gold": gold, "accent": accent, "fill": fill}
    parts = []
    for e in emblem(tier):
        c = col[e["role"]]
        if c is None:
            continue
        d = path_d(e["d"])
        if e["fill"]:
            parts.append(f'<path d="{d}" fill="{c}"/>')
            continue
        if e["halo"] and fill:
            parts.append(f'<path d="{d}" fill="none" stroke="{fill}" '
                         f'stroke-width="{e["w"] + e["halo"]:.2f}" stroke-linecap="round" '
                         f'stroke-linejoin="round"/>')
        parts.append(f'<path d="{d}" fill="none" stroke="{c}" stroke-width="{e["w"]:.2f}" '
                     f'stroke-linecap="round" stroke-linejoin="round"/>')
    return "\n".join(parts)


def svg_symbol(tier, palette, size=100, pad=0.0, bg=None, radius=0):
    s = 1 - 2 * pad
    o = 50 * (1 - s)
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="{size}" '
           f'height="{size}" role="img" aria-label="FORENSIC EXPERT">']
    if bg:
        out.append(f'<rect width="100" height="100" rx="{radius}" fill="{bg}"/>')
    out.append(f'<g transform="translate({o:.3f} {o:.3f}) scale({s:.4f})">')
    out.append(svg_group(tier, palette))
    out.append("</g>\n</svg>")
    return "\n".join(out)


SERIF = "Georgia, 'Times New Roman', 'Liberation Serif', serif"
SANS = "Inter, 'Helvetica Neue', Arial, 'Liberation Sans', sans-serif"
TAGLINE = "EVIDENCE · SCIENCE · PRECISION"


def svg_lockup(palette, stacked=False, bg=None):
    ink, gold, _, _ = PALETTES[palette]
    dark = palette == "dark"
    word = WHITE if dark else ink
    sub = "#B8C2D6" if dark else ("#4A5568" if palette == "light" else ink)
    sym = svg_group("full", palette)
    rect = f'<rect width="100%" height="100%" fill="{bg}"/>' if bg else ""
    if stacked:
        return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300" role="img" '
                f'aria-label="FORENSIC EXPERT — Evidence · Science · Precision">{rect}'
                f'<g transform="translate(130 12) scale(1.4)">{sym}</g>'
                f'<text x="200" y="210" text-anchor="middle" font-family="{SERIF}" '
                f'font-weight="600" font-size="31" letter-spacing="1.5" fill="{word}">'
                f'FORENSIC EXPERT</text>'
                f'<line x1="40" y1="236" x2="64" y2="236" stroke="{gold}" stroke-width="1.5"/>'
                f'<line x1="336" y1="236" x2="360" y2="236" stroke="{gold}" stroke-width="1.5"/>'
                f'<text x="200" y="241" text-anchor="middle" font-family="{SANS}" '
                f'font-weight="500" font-size="11.5" letter-spacing="2" fill="{sub}">'
                f'{TAGLINE}</text></svg>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 120" role="img" '
            f'aria-label="FORENSIC EXPERT — Evidence · Science · Precision">{rect}'
            f'<g transform="translate(10 10)">{sym}</g>'
            f'<line x1="126" y1="22" x2="126" y2="98" stroke="{gold}" stroke-width="1.5"/>'
            f'<text x="144" y="64" font-family="{SERIF}" font-weight="600" font-size="38" '
            f'letter-spacing="1.5" fill="{word}">FORENSIC EXPERT</text>'
            f'<text x="146" y="90" font-family="{SANS}" font-weight="500" font-size="13" '
            f'letter-spacing="2.6" fill="{sub}">{TAGLINE}</text></svg>')


# --- Rastr -----------------------------------------------------------------

def tier_for(px):
    return "small" if px <= 40 else ("icon" if px < 96 else "full")


def raster_svg(svg, w, h=None):
    # Rastrlash muhitida Georgia yo‘q — metrik mos «Liberation Serif».
    svg = svg.replace(SERIF, "Liberation Serif")
    data = cairosvg.svg2png(bytestring=svg.encode(), output_width=w, output_height=h or w)
    return Image.open(io.BytesIO(data)).convert("RGBA")


def render(px, palette, tier=None, pad=0.0, bg=None):
    tier = tier or tier_for(px)
    big = raster_svg(svg_symbol(tier, palette, pad=pad, bg=bg), px * 4)
    return big.resize((px, px), Image.LANCZOS)


def save_png(img, path, flatten=None):
    path.parent.mkdir(parents=True, exist_ok=True)
    if flatten:
        base = Image.new("RGB", img.size, flatten)
        base.paste(img, mask=img.split()[3])
        base.save(path)
    else:
        img.save(path)


# --- Flutter painter -------------------------------------------------------

def dart_painter():
    def pt(p):
        return f"{p[0]:.2f}, {p[1]:.2f}"

    lines = [
        "// GENERATED by design/brand/tools/generate_brand.py — qo‘lda tahrir qilmang.",
        "part of 'brand_mark.dart';",
        "",
        "const _emblemTiers = <BrandTier, List<_El>>{",
    ]
    for tier in ("full", "icon", "small"):
        lines.append(f"  BrandTier.{tier}: [")
        for e in emblem(tier):
            ops = []
            for c in e["d"]:
                if c[0] == "M":
                    ops.append(f"_Op.m({pt(c[1])})")
                elif c[0] == "L":
                    ops.append(f"_Op.l({pt(c[1])})")
                elif c[0] == "C":
                    ops.append(f"_Op.c({pt(c[1])}, {pt(c[2])}, {pt(c[3])})")
                else:
                    ops.append("_Op.z()")
            w = f"{e['w']:.2f}" if e["w"] else "0"
            lines.append(f"    _El(")
            lines.append(f"      _Role.{e['role']},")
            lines.append(f"      {w},")
            if e["fill"]:
                lines.append("      fill: true,")
            if e["halo"]:
                lines.append(f"      halo: {e['halo']:.2f},")
            lines.append("      ops: [")
            for op in ops:
                lines.append(f"        {op},")
            lines.append("      ],")
            lines.append("    ),")
        lines.append("  ],")
    lines.append("};")
    return "\n".join(lines) + "\n"


# --- Asosiy ----------------------------------------------------------------

def main():
    svgdir, pngdir = OUT / "svg", OUT / "png"
    for d in (svgdir, pngdir):
        d.mkdir(parents=True, exist_ok=True)
        for f in d.iterdir():
            f.unlink()  # eski belgining barcha assetlari o‘chiriladi
    files = {}
    for tier in ("full", "icon", "small"):
        for pal in PALETTES:
            files[f"emblem-{tier}-{pal}.svg"] = svg_symbol(tier, pal)
    files["app-icon-dark.svg"] = svg_symbol("icon", "dark", 1024, 0.1, NAVY)
    files["app-icon-light.svg"] = svg_symbol("icon", "light", 1024, 0.1, WHITE)
    files["app-icon-mono-dark.svg"] = svg_symbol("icon", "mono-white", 1024, 0.1, GRAPHITE)
    files["app-icon-mono-light.svg"] = svg_symbol("icon", "mono-black", 1024, 0.1, WHITE)
    files["splash-mark.svg"] = svg_symbol("full", "dark", 512)
    files["logo-horizontal-light.svg"] = svg_lockup("light")
    files["logo-horizontal-dark.svg"] = svg_lockup("dark", bg=NAVY)
    files["logo-horizontal-mono.svg"] = svg_lockup("mono-black")
    files["logo-stacked-light.svg"] = svg_lockup("light", stacked=True)
    files["logo-stacked-dark.svg"] = svg_lockup("dark", stacked=True, bg=NAVY)
    files["logo-stacked-mono.svg"] = svg_lockup("mono-black", stacked=True)
    for name, svg in files.items():
        (svgdir / name).write_text(svg + "\n", encoding="utf-8")

    for name in ("logo-horizontal-light", "logo-horizontal-dark"):
        save_png(raster_svg(files[name + ".svg"], 1120, 240), pngdir / f"{name}.png")
    for name in ("logo-stacked-light", "logo-stacked-dark"):
        save_png(raster_svg(files[name + ".svg"], 800, 600), pngdir / f"{name}.png")
    for name in ("app-icon-dark", "app-icon-light", "app-icon-mono-dark", "app-icon-mono-light"):
        save_png(raster_svg(files[name + ".svg"], 512), pngdir / f"{name}-512.png")

    # O‘lcham sinovi: light / dark / mono / app icon × 16…180 px.
    sizes = [16, 24, 32, 48, 64, 96, 180]
    rows = [("light", "#F5F7FA", 0.0, None), ("dark", NAVY, 0.0, None),
            ("mono-black", "#FFFFFF", 0.0, None), ("dark", "#FFFFFF", 0.1, NAVY)]
    sheet = Image.new("RGB", (40 + sum(s + 40 for s in sizes), len(rows) * 230), "#FFFFFF")
    dr = ImageDraw.Draw(sheet)
    for ri, (pal, bg, pad, tile) in enumerate(rows):
        y0 = ri * 230
        dr.rectangle([0, y0, sheet.width, y0 + 229], fill=bg)
        x = 40
        for s in sizes:
            im = render(s, pal, pad=pad, bg=tile)
            sheet.paste(im, (x, y0 + (230 - s) // 2), im)
            x += s + 40
    save_png(sheet, pngdir / "size-test-sheet.png")
    for s in (16, 24, 32, 48, 64, 96, 180, 512, 1024):
        save_png(render(s, "light"), pngdir / f"emblem-light-{s}.png")
        save_png(render(s, "dark", bg=NAVY), pngdir / f"emblem-dark-{s}.png")
    save_png(render(32, "light", bg=WHITE), pngdir / "favicon-32.png")
    save_png(render(16, "light", bg=WHITE), pngdir / "favicon-16.png")

    # --- Android -----------------------------------------------------------
    res = APP / "android" / "app" / "src" / "main" / "res"
    for dname, f in {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}.items():
        px = round(48 * f)
        save_png(render(px, "dark", tier="icon", pad=0.1, bg=NAVY),
                 res / f"mipmap-{dname}" / "ic_launcher.png", flatten=NAVY)
        # Adaptive foreground 108dp: belgi 66dp xavfsiz zona ichida.
        save_png(render(round(108 * f), "dark", tier="icon", pad=0.2),
                 res / f"mipmap-{dname}" / "ic_launcher_foreground.png")
        # Android 13+ themed (monoxrom) ikon.
        save_png(render(round(108 * f), "mono-white", tier="icon", pad=0.2),
                 res / f"mipmap-{dname}" / "ic_launcher_monochrome.png")
    save_png(render(288, "dark", tier="full"), res / "drawable-nodpi" / "launch_mark.png")

    # --- iOS (alpha yo‘q) --------------------------------------------------
    iconset = APP / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    for im in json.loads((iconset / "Contents.json").read_text())["images"]:
        fn = im.get("filename")
        if not fn:
            continue
        px = round(float(im["size"].split("x")[0]) * int(im["scale"].rstrip("x")))
        tier = "small" if px <= 40 else "icon"
        save_png(render(px, "dark", tier=tier, pad=0.1, bg=NAVY), iconset / fn, flatten=NAVY)
    launch = APP / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"
    for fn, px in (("LaunchImage.png", 160), ("LaunchImage@2x.png", 320),
                   ("LaunchImage@3x.png", 480)):
        save_png(render(px, "dark", tier="full"), launch / fn)

    (APP / "lib" / "core" / "widgets" / "brand_emblem.g.dart").write_text(
        dart_painter(), encoding="utf-8")
    print("brand assets generated:", len(files), "svg")


if __name__ == "__main__":
    main()
