#!/usr/bin/env python3
"""Apparat TURI bo'yicha sxematik chizmalar (D-36a: aniq model fotosi emas).

Har bir chizma — shu turdagi apparatning umumiy, original tasviri: namuna
rakasi, reagent joyi, zond/igna, displey, chiqindi. Hech bir ishlab chiqaruvchi
dizayniga, logotipiga yoki yozuviga o'xshatilmagan. Rasmdagi yagona matn —
asosiy qismlarni ko'rsatuvchi raqamli belgilar (1..n, `<g id="callouts">`);
qismlar nomi, vazifasi, ishlash prinsipi va natija — ilovada, ARB da
(manba: parts_src.py, generator: parts_l10n.py).

    python3 tool/illustrations/schematic/gen.py            # SVG larni yozadi
    NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --schematic
                                                            # PNG (480 va 1200)

Katalogdagi `schematic` kaliti (tool/instrument_catalog_src.py) shu nomlarga
mos keladi. Yo'nalish kartalari (catalog.json `lab_cards[].schematic`) uchun
apparat SINFI chizmalari (L1-L25: GC-MS, LC-MS, MALDI-TOF, ...) ham shu yerda;
ro'yxat — lib/features/instruments/lab_direction_card.dart `LabSchematic`.
Yangi chizmalar PNG hajmini kamaytirish uchun `--quant` (pngquant) bilan:
    NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --schematic --quant mass_spec_gc ...
"""
import math
import pathlib
import random
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from parts_src import PARTS  # noqa: E402

HERE = pathlib.Path(__file__).resolve().parent
W, H = 1200, 800
GROUND = 702

# Palitra: lib/design/tokens.dart va mavjud tool/illustrations/*.svg bilan bir xil.
LINE = "#B9C4BD"

DEFS = """
<defs>
  <linearGradient id="body" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#E1E7E3"/></linearGradient>
  <linearGradient id="bodyH" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#F4F7F5"/><stop offset="0.7" stop-color="#FFFFFF"/><stop offset="1" stop-color="#D9E1DC"/></linearGradient>
  <linearGradient id="topP" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#EEF2EF"/><stop offset="1" stop-color="#D7DFDA"/></linearGradient>
  <linearGradient id="deck" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#C9D4CE"/><stop offset="1" stop-color="#E4EAE6"/></linearGradient>
  <linearGradient id="screen" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#1F5A4C"/><stop offset="1" stop-color="#143C33"/></linearGradient>
  <linearGradient id="dark" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#34403B"/><stop offset="1" stop-color="#151A18"/></linearGradient>
  <linearGradient id="niche" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#26302C"/><stop offset="1" stop-color="#3B4843"/></linearGradient>
  <linearGradient id="metal" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#E4E9E6"/><stop offset="1" stop-color="#A9B4AE"/></linearGradient>
  <linearGradient id="glass" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FFFFFF" stop-opacity="0.55"/><stop offset="0.45" stop-color="#FFFFFF" stop-opacity="0.08"/><stop offset="1" stop-color="#CFE9D9" stop-opacity="0.25"/></linearGradient>
  <linearGradient id="liquid" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F0D36B"/><stop offset="1" stop-color="#E0B73A"/></linearGradient>
  <filter id="soft" filterUnits="userSpaceOnUse" x="0" y="0" width="1200" height="800"><feGaussianBlur stdDeviation="14"/></filter>
</defs>
"""


def svg(inner):
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" '
        f'width="{W}" height="{H}">\n{DEFS}\n{inner}\n</svg>\n'
    )


# ----------------------------------------------------------------- primitives
def ground(cx, rx, cy=GROUND + 10, ry=20, op=0.5):
    return (
        f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="#6F8479" '
        f'opacity="{op}" filter="url(#soft)"/>'
    )


def rect(x, y, w, h, rx=0, fill="url(#body)", stroke=LINE, sw=3, extra=""):
    st = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ""
    return f'<rect x="{x:g}" y="{y:g}" width="{w:g}" height="{h:g}" rx="{rx:g}" fill="{fill}"{st} {extra}/>'


def ell(cx, cy, rx, ry, fill, stroke=None, sw=2, extra=""):
    st = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ""
    return f'<ellipse cx="{cx:.1f}" cy="{cy:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{fill}"{st} {extra}/>'


def line(x1, y1, x2, y2, stroke=LINE, sw=3, cap="round", extra=""):
    return (
        f'<line x1="{x1:g}" y1="{y1:g}" x2="{x2:g}" y2="{y2:g}" stroke="{stroke}" '
        f'stroke-width="{sw}" stroke-linecap="{cap}" {extra}/>'
    )


def path(d, fill="none", stroke=LINE, sw=3, extra=""):
    return (
        f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" '
        f'stroke-linecap="round" stroke-linejoin="round" {extra}/>'
    )


def hose(d, color="#A9B5AE", sw=6):
    """Egiluvchan shlang (reagent/chiqindi liniyasi)."""
    return path(d, stroke=color, sw=sw)


def led(cx, cy, color="#6FCF7F", r=7):
    return ell(cx, cy, r, r, color, "#FFFFFF", 2)


def vents(x, y, w, n, gap=11, stroke="#CBD4CE"):
    return "".join(line(x, y + i * gap, x + w, y + i * gap, stroke, 4) for i in range(n))


# ------------------------------------------------------------ lab containers
TUBE_CAPS = ["#8E6CC4", "#B6403A", "#E3B93C", "#5B8FD0", "#6FB07F"]


def tube(x, y, cap="#8E6CC4", fill="#B6403A", h=96, w=26, level=0.5):
    """Probirka: (x, y) — qopqoqning chap-yuqori nuqtasi; cap=None — ochiq."""
    ly = y + 16 + h * (1 - level)
    s = rect(x, y + 16, w, h, 12, "#FFFFFFD9", "#C3CCC6", 3)
    s += rect(x + 3, ly, w - 6, y + 16 + h - ly - 4, 9, fill, None)
    if cap:
        s += rect(x - 3, y, w + 6, 24, 6, cap, None)
    return s


def rack(x, y, n, caps=None, fills=None, step=46, plate_w=None, h=96):
    """Probirka rakasi; (x, y) — tagidagi plastina yuqori-chap nuqtasi."""
    caps = caps or TUBE_CAPS
    fills = fills or ["#B6403A", "#B6403A", "#D14A42", "#B6403A", "#C2453E"]
    pw = plate_w or (n * step + 14)
    s = ""
    for i in range(n):
        s += tube(x + 14 + i * step, y - h - 14, caps[i % len(caps)], fills[i % len(fills)], h=h,
                  level=0.45 + 0.1 * (i % 3))
    s += rect(x, y, pw, 34, 9, "#DDE5DF", "#BFC9C2", 3)
    s += line(x + 12, y + 17, x + pw - 12, y + 17, "#C9D2CC", 3)
    return s


def bottle(x, y, w, h, cap, liquid, label=None):
    """Reagent / eritma idishi; (x, y) — yuqori-chap."""
    nw = w * 0.42
    s = rect(x, y + h * 0.14, w, h * 0.86, w * 0.16, "#F6F8F6", "#C3CCC6", 3)
    s += rect(x + w * 0.1, y + h * 0.42, w * 0.8, h * 0.5, w * 0.1, liquid, None, extra='opacity="0.9"')
    s += rect(x + (w - nw) / 2, y + h * 0.02, nw, h * 0.16, 5, cap, None)
    if label:
        s += rect(x + w * 0.2, y + h * 0.5, w * 0.6, h * 0.2, 4, label, None, extra='opacity="0.95"')
    return s


def jug(x, y, w, h, cap, liquid, level=0.7):
    """Katta kanistr (distillangan suv/eritma); (x, y) — yuqori-chap."""
    s = rect(x, y + 18, w, h - 18, 16, "#F2F5F3", "#C3CCC6", 3)
    ly = y + 18 + (h - 18) * (1 - level)
    s += rect(x + 8, ly, w - 16, y + h - ly - 8, 10, liquid, None, extra='opacity="0.85"')
    s += rect(x + w * 0.62, y + 2, w * 0.24, 22, 6, cap, None)
    s += path(f"M{x + w * 0.2:g} {y + 34:g} q{w * 0.12:g} -18 {w * 0.24:g} 0", stroke="#C3CCC6", sw=4)
    return s


def waste_can(x, y, w, h):
    s = rect(x, y + 16, w, h - 16, 14, "#E6EAE7", "#BFC9C2", 3)
    s += rect(x + 10, y + h * 0.45, w - 20, h * 0.18, 5, "#CBD3CE", None)
    s += rect(x + w * 0.58, y, w * 0.28, 22, 6, "#8C9791", None)
    return s


# --------------------------------------------------------------- big pieces
def ring_points(cx, cy, rx, ry, k, n, phase=0.0):
    return [
        (cx + rx * k * math.cos(phase + 2 * math.pi * i / n), cy + ry * k * math.sin(phase + 2 * math.pi * i / n))
        for i in range(n)
    ]


def drum(cx, cy, rx, ry, depth, top="#E4EAE6", side="#BAC6BF"):
    """Yuqoridan perspektivada disk/karusel (past silindr)."""
    s = f'<path d="M{cx - rx:.1f} {cy:.1f} V{cy + depth:.1f} A{rx:.1f} {ry:.1f} 0 0 0 {cx + rx:.1f} {cy + depth:.1f} V{cy:.1f} Z" fill="{side}" stroke="{LINE}" stroke-width="2" stroke-linejoin="round"/>'
    s += ell(cx, cy, rx, ry, top, LINE, 2)
    return s


def reagent_disk(cx, cy, rx, ry, depth=16, outer=18, inner=10, caps=None):
    """Reagent karuseli: tashqi va ichki halqada idish bo'g'izlari."""
    caps = caps or ["#7FB3C8", "#D98BA6", "#E3B93C", "#9FB3AA", "#8E6CC4"]
    s = drum(cx, cy, rx, ry, depth)
    s += ell(cx, cy, rx * 0.93, ry * 0.93, "#D3DCD6", None)
    pts = [(p, rx * 0.075, ry * 0.2) for p in ring_points(cx, cy, rx, ry, 0.74, outer, 0.2)]
    pts += [(p, rx * 0.062, ry * 0.17) for p in ring_points(cx, cy, rx, ry, 0.46, inner, 0.5)]
    pts.sort(key=lambda t: t[0][1])
    for i, ((px, py), a, b) in enumerate(pts):
        s += ell(px, py + 3, a, b, "#8E9B94")
        s += ell(px, py, a, b, caps[i % len(caps)], "#FFFFFF", 1.5)
    s += ell(cx, cy, rx * 0.2, ry * 0.2, "#BAC6BF", LINE, 2)
    return s


def sample_disk(cx, cy, rx, ry, depth=12, n=16, caps=None):
    caps = caps or TUBE_CAPS
    s = drum(cx, cy, rx, ry, depth)
    s += ell(cx, cy, rx * 0.92, ry * 0.92, "#D3DCD6", None)
    pts = sorted(ring_points(cx, cy, rx, ry, 0.76, n, 0.1), key=lambda t: t[1])
    for i, (px, py) in enumerate(pts):
        s += ell(px, py + 2, rx * 0.075, ry * 0.22, "#7A8780")
        s += ell(px, py, rx * 0.075, ry * 0.22, caps[i % len(caps)], "#FFFFFF", 1.2)
    for px, py in sorted(ring_points(cx, cy, rx, ry, 0.46, n // 2, 0.4), key=lambda t: t[1]):
        s += ell(px, py, rx * 0.055, ry * 0.16, "#F6F8F6", "#9FB3AA", 1.2)
    s += ell(cx, cy, rx * 0.16, ry * 0.16, "#BAC6BF", LINE, 2)
    return s


def reaction_ring(cx, cy, rx, ry, depth=14, n=26):
    s = drum(cx, cy, rx, ry, depth, top="#DDE5E0")
    s += ell(cx, cy, rx * 0.64, ry * 0.64, "#EEF2EF", LINE, 2)
    pts = sorted(ring_points(cx, cy, rx, ry, 0.82, n, 0.05), key=lambda t: t[1])
    for i, (px, py) in enumerate(pts):
        s += rect(px - rx * 0.03, py - ry * 0.2, rx * 0.06, ry * 0.4, 2,
                  "#EAF6FA" if i % 3 else "#C9E6F0", "#8FAAB0", 1.2)
    return s


def probe_arm(px, py, pts, tip_len=20, color="#8E9B94", base="#C9D2CC"):
    """Zond qo'li: tayanch ustun (px, py) -> qo'l -> pastga igna."""
    d = f"M{px} {py} " + " ".join(f"L{x} {y}" for x, y in pts)
    tx, ty = pts[-1]
    s = ell(px, py + 4, 15, 7, "#8E9B94")
    s += ell(px, py, 15, 7, base, LINE, 2)
    s += path(d, stroke="#6E7B74", sw=12)
    s += path(d, stroke=color, sw=8)
    s += line(tx, ty, tx, ty + tip_len, "#4C5853", 3)
    s += ell(tx, ty + tip_len + 3, 3, 3, "#D7A96B", None)
    return s


def monitor(x, y, w, h, content="", arm=None):
    """Sensorli displey; arm — mahkamlovchi yo'l nuqtalari."""
    s = ""
    if arm:
        d = "M" + " L".join(f"{a} {b}" for a, b in arm)
        s += path(d, stroke="#A8B3AC", sw=14)
        s += path(d, stroke="#D5DCD8", sw=8)
    s += rect(x, y, w, h, 14, "url(#dark)", "#0F1412", 2)
    s += rect(x + 10, y + 10, w - 20, h - 20, 7, "url(#screen)", None)
    s += f'<g transform="translate({x + 10},{y + 10})">{content}</g>'
    s += ell(x + w - 18, y + h - 6, 2.5, 2.5, "#6FCF7F")
    return s


def ui_bars(w, h, n=5, accent="#C5E8A1"):
    s = rect(10, 10, w * 0.45, 9, 4, "#8FC9A0", None)
    s += rect(w * 0.62, 10, w * 0.28 - 4, 9, 4, "#5E8C7E", None)
    rh = (h - 44) / n
    for i in range(n):
        yy = 30 + i * rh
        s += rect(10, yy, w - 20, rh - 6, 4, "#FFFFFF", None, extra='opacity="0.10"')
        s += rect(16, yy + (rh - 6) / 2 - 3, w * (0.25 + 0.12 * ((i * 3) % 4)), 6, 3,
                  accent if i % 2 == 0 else "#8FC9A0", None)
        s += ell(w - 26, yy + (rh - 6) / 2, 4, 4, "#6FCF7F" if i != 2 else "#E3B93C")
    return s


def ui_curve(w, h):
    s = rect(10, 8, w * 0.4, 8, 4, "#8FC9A0", None)
    s += line(14, h - 14, w - 14, h - 14, "#5E8C7E", 2)
    s += line(14, 24, 14, h - 14, "#5E8C7E", 2)
    s += path(f"M18 {h - 20} C {w * .25:g} {h - 20} {w * .3:g} 30 {w * .45:g} 30 S {w * .65:g} {h - 24} {w - 20} {h - 24}",
              stroke="#C5E8A1", sw=3.5)
    s += path(f"M18 {h - 18} C {w * .3:g} {h - 18} {w * .4:g} {h * .5:g} {w * .6:g} {h * .5:g} S {w * .8:g} {h - 22} {w - 20} {h - 22}",
              stroke="#8FC9A0", sw=2.5)
    return s


def ui_scatter(w, h):
    """Skatterogramma (rangli nuqta bulutlari) + gistogramma."""
    rnd = random.Random(7)
    s = rect(10, 10, w * 0.4, 9, 4, "#8FC9A0", None)
    s += line(14, h - 18, w * 0.52, h - 18, "#5E8C7E", 2) + line(14, 28, 14, h - 18, "#5E8C7E", 2)
    clouds = [(0.17, 0.78, 0.07, "#8FC9A0"), (0.3, 0.55, 0.08, "#C5E8A1"), (0.38, 0.8, 0.06, "#E3B93C"),
              (0.2, 0.42, 0.07, "#D98BA6"), (0.44, 0.35, 0.05, "#7FB3C8")]
    for cx, cy, r, col in clouds:
        for _ in range(26):
            a, d = rnd.random() * 6.283, rnd.random() * r
            s += ell(w * cx + math.cos(a) * d * w, h * cy + math.sin(a) * d * w * 0.8, 2.2, 2.2, col)
    s += line(w * 0.58, h - 18, w - 14, h - 18, "#5E8C7E", 2)
    s += path(f"M{w * .58:g} {h - 20} C {w * .66:g} {h - 20} {w * .68:g} 40 {w * .75:g} 40 S {w * .84:g} {h - 22} {w - 14} {h - 22}",
              stroke="#C5E8A1", sw=3.5)
    s += path(f"M{w * .58:g} {h - 20} C {w * .6:g} {h - 20} {w * .62:g} {h * .5:g} {w * .66:g} {h * .5:g}",
              stroke="#8FC9A0", sw=2)
    return s


def ui_hist(w, h, n=3):
    s = rect(10, 10, w * 0.4, 9, 4, "#8FC9A0", None)
    colw = (w - 20) / n
    for i in range(n):
        x0 = 12 + i * colw
        s += line(x0 + 2, h - 18, x0 + colw - 8, h - 18, "#5E8C7E", 2)
        mid = x0 + colw * (0.35 + 0.1 * i)
        s += path(f"M{x0 + 2:g} {h - 20} C {x0 + colw * .2:g} {h - 20} {mid - 12:g} 38 {mid:g} 38 S {x0 + colw - 22:g} {h - 22} {x0 + colw - 8:g} {h - 22}",
                  stroke=["#C5E8A1", "#8FC9A0", "#7FB3C8"][i % 3], sw=3)
    return s


def strip_pads(x, y, n=10, step=26, w=20, h=22):
    cols = ["#F3E8A6", "#E7D58A", "#C9D68A", "#9FC27A", "#E7B27A", "#D98BA6", "#B79AD0", "#7FB3C8", "#F0DE90", "#E9C47F"]
    s = rect(x - 10, y - 8, n * step + 10, h + 16, 8, "#F6F8F6", "#BFC9C2", 2.5)
    for i in range(n):
        s += rect(x + i * step, y, w, h, 3, cols[i % len(cols)], "#FFFFFF", 1.2)
    return s


def pack_tray(cx, y_back, y_front, w_back, w_front, rows=3, cols=7):
    """Reagent paketlari tarnovi (to'rtburchak, perspektivada)."""
    s = path(f"M{cx - w_front / 2:g} {y_front} L{cx - w_back / 2:g} {y_back} H{cx + w_back / 2:g} L{cx + w_front / 2:g} {y_front} Z",
             "#E4EAE6", LINE, 2)
    caps = ["#8E6CC4", "#7FB3C8", "#D98BA6", "#E3B93C"]
    for j in range(rows):
        t = (j + 0.5) / rows
        yy = y_back + (y_front - y_back) * t
        sc = 0.62 + 0.5 * t
        span = w_back + (w_front - w_back) * t
        step = (span - 30) / (cols - 1)
        for i in range(cols):
            x = cx - (span - 30) / 2 + i * step
            pw, ph = 20 * sc, 30 * sc
            s += rect(x - pw / 2, yy - ph, pw, ph, 3 * sc, "#F6F8F6", "#A9B8AF", 1.4)
            s += rect(x - pw / 2 + 2 * sc, yy - ph + 3 * sc, pw - 4 * sc, 7 * sc, 2, caps[(i + j) % 4], None)
            s += rect(x - pw / 2 + 2 * sc, yy - ph + 13 * sc, pw - 4 * sc, 6 * sc, 2, caps[(i + 2 * j + 1) % 4], None, extra='opacity="0.7"')
    return s


def deck_clip(cid, pts):
    return f'<clipPath id="{cid}"><path d="{pts}"/></clipPath>'


# =========================================================================
# 1. Avtomatik biokimyoviy analizator (stol usti / pol usti)
# =========================================================================
def chemistry():
    s = ground(600, 480)
    # tashqi idishlar va shlanglar (korpus orqasida)
    s += hose("M118 540 V 470 H 320", "#7FB3C8")
    s += hose("M238 566 V 522 H 320", "#9AA6A0")
    s += jug(62, 530, 112, 172, "#7FB3C8", "#CFE3EC", 0.8)
    s += waste_can(190, 560, 96, 142)
    # korpus
    s += rect(300, 392, 600, 310, 22, "url(#bodyH)")
    # yuqori qism (shisha qopqoqli pallasi)
    s += path("M300 392 L338 232 Q342 220 354 220 H846 Q858 220 862 232 L900 392 Z", "url(#deck)", LINE, 3)
    s += deck_clip("dc", "M312 388 L346 238 H854 L888 388 Z") + '<g clip-path="url(#dc)">'
    s += rect(300, 230, 600, 160, 0, "#D4DDD7", None)
    s += reagent_disk(486, 336, 156, 36, 17)
    s += reaction_ring(744, 318, 104, 26, 13)
    s += sample_disk(690, 366, 70, 15, 8, 12)
    s += probe_arm(612, 270, [(560, 296), (508, 322)], 26)
    s += probe_arm(852, 262, [(790, 292), (730, 316)], 26)
    s += probe_arm(404, 262, [(440, 290)], 14, "#9FB3AA")
    s += ell(640, 366, 14, 5, "#8FA0A0", "#FFFFFF", 1.5)
    # fotometr: halqa markazidagi lampa -> kyuvetalar -> tashqi detektor bloki
    s += ell(744, 318, 13, 6, "#F6E7A8", None, extra='opacity="0.55"') + ell(744, 318, 6, 3, "#FFF6C8")
    s += line(752, 318, 846, 318, "#F2D46B", 3, extra='opacity="0.9"')
    s += "</g>"
    s += '<path d="M312 388 L346 238 H700 L610 388 Z" fill="url(#glass)"/>'
    s += rect(842, 302, 34, 32, 7, "url(#dark)", "#0F1412", 2) + ell(852, 318, 4, 4, "#F2D46B")
    s += rect(296, 380, 608, 22, 9, "#DCE4DF", LINE, 3)
    # namuna rakasi uyasi
    s += rect(338, 436, 292, 226, 16, "url(#niche)", "#232B28", 2)
    s += rack(362, 640, 5, h=96)
    # o'ng eshik / panel
    s += rect(668, 436, 202, 226, 14, "#F4F7F5", LINE, 3)
    s += vents(698, 548, 142, 6)
    s += rect(842, 500, 12, 74, 5, "#5F6B65", None)
    s += led(696, 462)
    s += rect(722, 455, 70, 14, 7, "#DDE5DF", None)
    # monitor
    s += monitor(946, 238, 214, 158, ui_bars(194, 138), arm=[(900, 450), (1054, 450), (1054, 396)])
    return s


# =========================================================================
# 2. Yarim avtomatik fotometr
# =========================================================================
def photometer():
    s = ground(600, 420)
    s += hose("M200 560 V 520 Q200 470 270 470 H 345", "#9AA6A0")
    s += waste_can(150, 560, 100, 142)
    # asosiy korpus
    s += rect(330, 330, 540, 372, 24, "url(#bodyH)")
    # yuqori qiya panel (displey + tugmalar)
    s += path("M330 330 L370 190 Q374 178 386 178 H814 Q826 178 830 190 L870 330 Z", "url(#topP)", LINE, 3)
    s += rect(412, 204, 270, 100, 12, "url(#dark)", "#0F1412", 2)
    s += rect(424, 214, 246, 80, 7, "url(#screen)", None)
    s += f'<g transform="translate(424,214)">{ui_curve(246, 80)}</g>'
    for r in range(3):
        for c in range(4):
            s += rect(704 + c * 30, 206 + r * 30, 24, 22, 6, "#FFFFFF", "#C3CCC6", 2)
    s += led(798, 318, "#6FCF7F", 6)
    # kyuveta kamerasi
    s += rect(650, 345, 190, 120, 14, "#EEF2EF", LINE, 3)
    s += rect(676, 366, 138, 34, 10, "url(#dark)", None)
    s += rect(744, 372, 22, 22, 4, "#EAF6FA", "#9FB3AA", 2)
    s += line(678, 433, 812, 433, "#C9D2CC", 4)
    s += line(678, 447, 790, 447, "#C9D2CC", 4)
    # termoprinter
    s += rect(650, 480, 190, 62, 12, "#DDE5DF", LINE, 3)
    s += rect(676, 500, 138, 8, 4, "#4C5853", None)
    s += rect(704, 462, 84, 40, 3, "#FFFFFF", "#D2DAD5", 2, extra='transform="rotate(-2 746 482)"')
    s += line(716, 474, 776, 473, "#BFC9C2", 3) + line(716, 485, 760, 484, "#BFC9C2", 3)
    # aspiratsiya uyasi: igna + probirka
    s += rect(372, 380, 240, 250, 16, "url(#niche)", "#232B28", 2)
    s += rect(396, 604, 190, 34, 9, "#DDE5DF", "#BFC9C2", 3)
    s += tube(478, 506, None, "#E0B73A", h=96, level=0.6)
    s += rect(482, 388, 28, 76, 8, "url(#metal)", "#8E9B94", 2)
    s += rect(492, 464, 8, 90, 4, "#7B8781", None)
    s += hose("M496 410 H 372 Q 345 410 345 470", "#7FB3C8", 5)
    s += led(398, 404)
    # reagent shisha (yonida)
    s += bottle(900, 548, 74, 154, "#D98BA6", "#F5DCE5", "#FFFFFF")
    s += bottle(990, 580, 64, 122, "#7FB3C8", "#DCEBF2")
    s += hose("M936 552 Q936 470 870 470", "#D98BA6", 4)
    return s


# =========================================================================
# 3. Gematologik analizator — 5 qismli (avtomatik yuklagich)
# =========================================================================
def hematology5():
    s = ground(600, 440)
    s += hose("M980 560 V 430 H 860", "#7FB3C8")
    s += hose("M1086 590 V 470 H 860", "#D98BA6")
    s += hose("M236 640 V 560 H 340", "#9AA6A0")
    s += jug(924, 548, 112, 154, "#7FB3C8", "#DCEBF2", 0.75)
    s += bottle(1050, 590, 70, 112, "#D98BA6", "#F5DCE5", "#FFFFFF")
    s += waste_can(190, 610, 90, 92)
    # korpus
    s += rect(330, 250, 530, 452, 26, "url(#bodyH)")
    # avtomatik yuklagich
    s += path("M360 250 L384 168 Q388 156 400 156 H800 Q812 156 816 168 L840 250 Z", "url(#topP)", LINE, 3)
    s += rect(396, 172, 408, 62, 10, "url(#dark)", None)
    s += rack(416, 218, 6, caps=TUBE_CAPS, h=34, step=62, plate_w=372)
    # displey (skatterogramma)
    s += monitor(380, 288, 430, 220, ui_scatter(410, 200))
    # namuna zond joyi (ochiq rejim)
    s += rect(380, 540, 270, 130, 16, "url(#niche)", "#232B28", 2)
    s += tube(488, 604, None, "#B6403A", h=44, level=0.6)
    s += rect(492, 548, 22, 52, 7, "url(#metal)", "#8E9B94", 2)
    s += rect(500, 600, 6, 40, 3, "#7B8781", None)
    s += rect(566, 566, 62, 62, 12, "#F4F7F5", LINE, 3)
    s += ell(597, 597, 17, 17, "#6FCF7F", "#FFFFFF", 3)
    # o'lchash bloki kesigi: impedans kamerasi (teshik + elektrodlar) va
    # lazer -> oqim kyuvetasi -> detektor
    s += rect(676, 540, 150, 130, 14, "url(#niche)", "#232B28", 2)
    s += rect(688, 590, 60, 66, 6, "#CFE3EC", "#9FB8C4", 1.5)
    s += line(718, 592, 718, 616, "#4C5853", 4) + line(718, 626, 718, 654, "#4C5853", 4)
    s += rect(692, 602, 6, 40, 2, "#E3B93C", None) + rect(738, 602, 6, 40, 2, "#E3B93C", None)
    for cx, cy in [(707, 612), (710, 630), (704, 644), (713, 621)]:
        s += ell(cx, cy, 4, 3, "#B6403A")
    s += rect(754, 600, 22, 16, 3, "#5F6B65", None) + rect(757, 603, 8, 10, 2, "#5B8FD0", None)
    s += line(776, 608, 794, 608, "#5B8FD0", 3)
    s += rect(794, 590, 10, 40, 3, "url(#glass)", "#CFE3EC", 1.5) + ell(799, 608, 3, 3, "#FFFFFF")
    s += line(799, 590, 799, 630, "#D98BA6", 2, extra='opacity="0.8"')
    s += rect(808, 600, 12, 16, 3, "url(#metal)", "#7C8C84", 1.5)
    return s


# =========================================================================
# 4. Gematologik analizator — 3 qismli (ixcham)
# =========================================================================
def hematology3():
    s = ground(560, 360, ry=18)
    s += hose("M780 590 V 520 H 730", "#7FB3C8", 5)
    s += hose("M880 620 V 540 H 740", "#9AA6A0", 5)
    s += bottle(742, 560, 76, 142, "#7FB3C8", "#DCEBF2", "#FFFFFF")
    s += waste_can(838, 590, 82, 112)
    s += rect(300, 280, 440, 422, 24, "url(#bodyH)")
    # termoprinter yuqorida
    s += path("M324 280 L348 214 Q352 204 364 204 H676 Q688 204 692 214 L716 280 Z", "url(#topP)", LINE, 3)
    s += rect(400, 236, 240, 20, 7, "url(#dark)", None)
    s += rect(420, 200, 200, 48, 3, "#FFFFFF", "#D2DAD5", 2, extra='transform="rotate(-1.5 520 224)"')
    s += line(436, 212, 560, 211, "#BFC9C2", 3) + line(436, 224, 520, 223, "#BFC9C2", 3)
    s += rect(400, 250, 240, 12, 4, "url(#dark)", None)
    # displey (3 gistogramma)
    s += monitor(330, 302, 380, 196, ui_hist(360, 176, 3))
    # namuna zondi
    s += rect(350, 520, 250, 150, 16, "url(#niche)", "#232B28", 2)
    s += tube(450, 596, None, "#B6403A", h=44, level=0.6)
    s += rect(454, 530, 24, 62, 7, "url(#metal)", "#8E9B94", 2)
    s += rect(462, 592, 8, 40, 3, "#7B8781", None)
    s += rect(528, 546, 56, 56, 12, "#F4F7F5", LINE, 3)
    s += ell(556, 574, 15, 15, "#6FCF7F", "#FFFFFF", 3)
    # impedans kamerasi kesigi: teshikli to'siq va ikki elektrod
    s += rect(620, 540, 90, 110, 12, "url(#niche)", "#232B28", 2)
    s += rect(632, 566, 66, 72, 6, "#CFE3EC", "#9FB8C4", 1.5)
    s += line(665, 568, 665, 596, "#4C5853", 4) + line(665, 606, 665, 636, "#4C5853", 4)
    s += rect(637, 580, 5, 40, 2, "#E3B93C", None) + rect(688, 580, 5, 40, 2, "#E3B93C", None)
    for cx, cy in [(652, 592), (655, 610), (650, 624), (658, 600)]:
        s += ell(cx, cy, 4, 3, "#B6403A")
    return s


# =========================================================================
# 5. Xemilyuminessent / immunoanaliz analizatori
# =========================================================================
def immunoassay():
    s = ground(580, 500)
    s += hose("M114 520 V 462 H 280", "#7FB3C8")
    s += hose("M220 544 V 500 H 280", "#D98BA6")
    s += jug(62, 520, 104, 182, "#7FB3C8", "#DCEBF2", 0.75)
    s += jug(180, 544, 80, 158, "#D98BA6", "#F5DCE5", 0.6)
    # korpus
    s += rect(270, 384, 640, 318, 22, "url(#bodyH)")
    s += path("M270 384 L308 214 Q312 202 324 202 H856 Q868 202 872 214 L910 384 Z", "url(#deck)", LINE, 3)
    s += deck_clip("dc", "M282 380 L318 220 H862 L898 380 Z") + '<g clip-path="url(#dc)">'
    s += rect(270, 214, 640, 170, 0, "#D4DDD7", None)
    s += pack_tray(450, 262, 358, 232, 286)
    s += reaction_ring(676, 318, 96, 26, 13, n=24)
    # kyuveta bunkeri
    s += rect(792, 240, 78, 52, 6, "#F4F7F5", LINE, 2)
    for i in range(6):
        s += rect(802 + i * 11, 250, 7, 30, 2, "#EAF6FA", "#9FB3AA", 1)
    s += probe_arm(580, 252, [(540, 286), (470, 306)], 24)
    s += probe_arm(740, 250, [(702, 286), (672, 306)], 24)
    s += rect(574, 346, 42, 20, 4, "#9FB3AA", "#7C8C84", 1.5)
    s += rect(582, 351, 26, 9, 3, "#6F7F77", None)
    s += "</g>"
    s += '<path d="M282 380 L318 220 H640 L560 380 Z" fill="url(#glass)"/>'
    s += rect(266, 374, 648, 22, 9, "#DCE4DF", LINE, 3)
    # namuna rakasi uyasi
    s += rect(306, 428, 260, 236, 16, "url(#niche)", "#232B28", 2)
    s += rack(328, 640, 4, h=96)
    # detektor modul (yorug'lik belgisi)
    s += rect(600, 428, 118, 112, 14, "#F4F7F5", LINE, 3)
    s += '<g transform="translate(659,484)">' + "".join(
        line(math.cos(a) * 14, math.sin(a) * 14, math.cos(a) * 28, math.sin(a) * 28, "#E3B93C", 4)
        for a in [i * math.pi / 4 for i in range(8)]) + ell(0, 0, 9, 9, "#E3B93C", None) + "</g>"
    s += rect(740, 436, 156, 104, 14, "#F4F7F5", LINE, 3)
    s += vents(762, 462, 112, 5)
    s += led(752, 450)
    # chiqindi tortmasi
    s += rect(600, 560, 296, 104, 14, "#F4F7F5", LINE, 3)
    s += rect(622, 584, 254, 40, 8, "#E3E9E5", "#C3CCC6", 2)
    s += rect(748, 640, 100, 10, 5, "#CBD3CE", None)
    s += monitor(950, 232, 214, 156, ui_bars(194, 136, 4), arm=[(910, 450), (1056, 450), (1056, 388)])
    return s


# =========================================================================
# 6. Siydik test-chiziq o'quvchisi (yarim avtomatik)
# =========================================================================
def urine_strip():
    s = ground(560, 380, ry=18)
    s += rect(330, 300, 520, 402, 26, "url(#bodyH)")
    # tepa qopqoq
    s += path("M354 300 L384 214 Q388 202 400 202 H780 Q792 202 796 214 L826 300 Z", "url(#topP)", LINE, 3)
    s += rect(430, 226, 320, 50, 12, "url(#dark)", None)
    s += rect(446, 240, 288, 22, 5, "#EEF2EF", None)
    # displey
    s += monitor(372, 322, 270, 160, ui_bars(250, 140, 4))
    for r in range(2):
        for c in range(3):
            s += rect(666 + c * 54, 332 + r * 44, 44, 34, 9, "#FFFFFF", "#C3CCC6", 2)
    s += led(690, 440, "#6FCF7F", 7)
    s += rect(716, 434, 80, 12, 6, "#DDE5DF", None)
    # chiziq lotogi
    s += rect(372, 520, 440, 120, 16, "url(#niche)", "#232B28", 2)
    s += rect(396, 548, 392, 58, 8, "#CBD3CE", "#9FB3AA", 2)
    s += rect(404, 556, 376, 42, 6, "#E3E9E5", None)
    s += strip_pads(430, 566, 10, 30, 22, 22)
    s += rect(782, 556, 56, 42, 8, "#FFFFFF", "#C3CCC6", 2)
    # o'qish kallagi: LEDlar (uch to'lqin uzunligi) va fotosensor maydoncha ustida
    s += path("M578 548 L572 566 H628 L622 548 Z", "#F6E7A8", None, 0, extra='opacity="0.35"')
    s += rect(564, 524, 72, 26, 6, "url(#dark)", "#0F1412", 1.5)
    for x, c in [(580, "#5B8FD0"), (600, "#6FCF7F"), (620, "#D9604F")]:
        s += ell(x, 546, 4, 4, c)
    s += rect(594, 530, 12, 8, 2, "#8E9B94", None)
    # siydik idishi va chiziq
    s += rect(86, 600, 120, 102, 18, "#F2F5F3", "#C3CCC6", 3)
    s += rect(98, 640, 96, 52, 10, "url(#liquid)", None, extra='opacity="0.9"')
    s += rect(92, 582, 108, 30, 9, "#FFFFFF", "#C3CCC6", 3)
    s += rect(118, 520, 18, 100, 4, "#E7D58A", "#FFFFFF", 1.5, extra='transform="rotate(12 127 570)"')
    # ishlatilgan chiziqlar qutisi
    s += rect(878, 590, 180, 112, 14, "#E6EAE7", "#BFC9C2", 3)
    s += rect(896, 608, 144, 14, 6, "#CBD3CE", None)
    return s


# =========================================================================
# 7. Siydik tahlili tizimi (chiziq + cho'kma) — ikki modul + raka yo'li
# =========================================================================
def urine_system():
    s = ground(600, 520)
    # tashqi idishlar (modullar orqasida)
    s += hose("M1010 640 V 520 H 920", "#7FB3C8")
    s += hose("M1104 640 V 560 H 920", "#9AA6A0")
    s += bottle(970, 580, 76, 122, "#7FB3C8", "#DCEBF2", "#FFFFFF")
    s += waste_can(1060, 590, 90, 112)
    # chap modul: kimyoviy (chiziq)
    s += rect(110, 300, 380, 402, 22, "url(#bodyH)")
    s += path("M110 300 L134 238 Q138 228 150 228 H450 Q462 228 466 238 L490 300 Z", "url(#topP)", LINE, 3)
    s += rect(160, 246, 280, 34, 9, "url(#dark)", None)
    s += rect(176, 254, 248, 14, 4, "#EEF2EF", None)
    s += rect(142, 322, 316, 92, 14, "url(#niche)", "#232B28", 2)
    s += line(156, 338, 444, 338, "#5F6B65", 3) + line(156, 398, 444, 398, "#5F6B65", 3)
    s += strip_pads(178, 352, 8, 32, 22, 22)
    s += led(136, 438, "#6FCF7F", 6)
    s += rect(142, 456, 316, 70, 12, "#F4F7F5", LINE, 3) + vents(166, 474, 200, 4, 11)
    # o'ng modul: cho'kma (raqamli mikroskopik tasvirlash)
    s += rect(520, 210, 400, 492, 24, "url(#bodyH)")
    s += monitor(552, 236, 336, 200, ui_gallery(316, 180))
    s += rect(552, 460, 336, 66, 14, "#F4F7F5", LINE, 3)
    s += ell(610, 493, 22, 22, "url(#dark)", "#9FB3AA", 3) + ell(610, 493, 9, 9, "#EAF6FA")
    s += rect(660, 478, 200, 10, 5, "#DDE5DF", None) + rect(660, 498, 140, 10, 5, "#DDE5DF", None)
    # namuna yo'li (modullar oldida)
    s += rect(60, 560, 920, 76, 16, "url(#metal)", "#8E9B94", 3)
    s += rect(72, 574, 896, 48, 10, "url(#niche)", None)
    for i in range(12):
        s += line(90 + i * 75, 580, 90 + i * 75, 616, "#4E5A55", 2)
    # igna bloklari (yo'l ustida)
    for nx in (307, 711):
        s += rect(nx - 20, 500, 40, 42, 8, "url(#metal)", "#8E9B94", 2) + line(nx, 542, nx, 566, "#4C5853", 3)
    yel = ["#E3B93C"] * 5
    s += rack(236, 646, 5, caps=yel, fills=["#F0D36B", "#E8C64F", "#F0D36B", "#E0B73A", "#EBCB5A"], step=44, h=82)
    s += rack(640, 646, 4, caps=["#9AA6A0"] * 4, fills=["#F0D36B", "#E8C64F", "#F0D36B", "#E0B73A"], step=44, h=82)
    return s


# =========================================================================
# Yo'nalish kartalari (lab_cards) uchun apparat SINFI chizmalari.
# Faqat tamoyil darajasidagi umumiy qismlar (masalan, mass-spektrometrda
# ion manbai -> analizator -> detektor). Brend, logotip, matn, aniq model
# shakli yo'q. Kesik oyna (`niche`) ichki tuzilishni ko'rsatadi.
# =========================================================================
TEAL = "#3E8F7C"
AIR = "#5B8FD0"
ROOM = "#C9A15A"
UV = "#8E6CC4"
GLOW = "#9BE36B"


def arrow(pts, color=AIR, sw=7, head=20):
    """Ko'p nuqtali strelka (oxirgi kesma yo'nalishida uchi)."""
    (x1, y1), (x2, y2) = pts[-2], pts[-1]
    a = math.atan2(y2 - y1, x2 - x1)
    bx, by = x2 - math.cos(a) * head * 0.7, y2 - math.sin(a) * head * 0.7
    d = f"M{pts[0][0]:g} {pts[0][1]:g} " + " ".join(f"L{x:g} {y:g}" for x, y in pts[1:-1])
    d += f" L{bx:.1f} {by:.1f}"
    s = path(d, stroke=color, sw=sw)
    c, sn = math.cos(a), math.sin(a)
    p2 = (x2 - head * c + head * 0.55 * sn, y2 - head * sn - head * 0.55 * c)
    p3 = (x2 - head * c - head * 0.55 * sn, y2 - head * sn + head * 0.55 * c)
    s += f'<path d="M{x2:.1f} {y2:.1f} L{p2[0]:.1f} {p2[1]:.1f} L{p3[0]:.1f} {p3[1]:.1f} Z" fill="{color}"/>'
    return s


def dial(cx, cy, r, angle=-40, color="#B6403A"):
    """Strelkali manometr/termometr (raqamsiz shkala)."""
    s = ell(cx, cy, r + 8, r + 8, "url(#metal)", "#8E9B94", 2)
    s += ell(cx, cy, r, r, "#FFFFFF", "#C3CCC6", 2)
    for i in range(11):
        a = math.radians(135 + i * 27)
        k = 0.78 if i % 5 else 0.68
        s += line(cx + math.cos(a) * r * k, cy + math.sin(a) * r * k,
                  cx + math.cos(a) * r * 0.9, cy + math.sin(a) * r * 0.9, "#5F6B65", 2.5)
    s += path(f"M{cx + math.cos(math.radians(135)) * r * 0.9:.1f} {cy + math.sin(math.radians(135)) * r * 0.9:.1f} "
              f"A{r * 0.9:.1f} {r * 0.9:.1f} 0 0 1 {cx + math.cos(math.radians(45)) * r * 0.9:.1f} {cy + math.sin(math.radians(45)) * r * 0.9:.1f}",
              stroke="#E3B93C", sw=3, extra='opacity="0.0"')
    a = math.radians(angle - 90)
    s += line(cx, cy, cx + math.cos(a) * r * 0.78, cy + math.sin(a) * r * 0.78, color, 4)
    s += ell(cx, cy, 6, 6, "#4C5853")
    return s


def glass_box(x, y, w, h, rx=10):
    return rect(x, y, w, h, rx, "url(#glass)", "#AFC3B8", 3)


def curve_path(fn, x0, x1, n=80):
    pts = [(x0 + (x1 - x0) * i / n, fn(i / n)) for i in range(n + 1)]
    return "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts)


def gauss(t, mu, sig):
    return math.exp(-((t - mu) ** 2) / (2 * sig * sig))


def ui_frame(w, h):
    s = rect(10, 8, w * 0.38, 8, 4, "#8FC9A0", None)
    s += line(14, h - 14, w - 14, h - 14, "#5E8C7E", 2)
    s += line(14, 22, 14, h - 14, "#5E8C7E", 2)
    return s


def ui_peaks(w, h, peaks, color="#C5E8A1", y0=None, y1=None, x0=18, x1=None):
    """Xromatogramma/denstitogramma: gauss cho'qqilari (t, balandlik, eni)."""
    x1 = x1 or w - 16
    y0 = y0 if y0 is not None else h - 16
    y1 = y1 if y1 is not None else 26
    fn = lambda t: y0 - (y0 - y1) * sum(a * gauss(t, m, sg) for m, a, sg in peaks)
    return path(curve_path(fn, x0, x1, 160), stroke=color, sw=3)


def ui_sticks(w, h, x0, x1, y0, y1, heights, color="#C5E8A1"):
    """Mass-spektr: m/z bo'yicha vertikal chiziqlar."""
    s = line(x0, y0, x1, y0, "#5E8C7E", 2)
    n = len(heights)
    for i, a in enumerate(heights):
        x = x0 + 8 + (x1 - x0 - 16) * i / (n - 1)
        s += line(x, y0, x, y0 - (y0 - y1) * a, color, 3.5, "butt")
    return s


def ui_gcms(w, h):
    """Yuqorida xromatogramma (TIC), pastda bitta cho'qqining mass-spektri."""
    s = rect(10, 8, w * 0.38, 8, 4, "#8FC9A0", None)
    mid = h * 0.5
    s += line(14, mid - 6, w - 14, mid - 6, "#5E8C7E", 2)
    s += ui_peaks(w, h, [(0.15, 0.35, 0.012), (0.33, 0.8, 0.014), (0.48, 0.25, 0.01), (0.62, 0.55, 0.013),
                         (0.8, 0.4, 0.012)], y0=mid - 8, y1=24)
    s += ui_sticks(w, h, 14, w - 14, h - 12, mid + 10,
                   [0.2, 0.05, 0.45, 0.1, 1.0, 0.3, 0.08, 0.55, 0.12, 0.04, 0.3, 0.15, 0.06, 0.22], "#8FC9A0")
    return s


def ui_spectrum(w, h):
    s = rect(10, 8, w * 0.38, 8, 4, "#8FC9A0", None)
    s += ui_peaks(w, h, [(0.12, 0.25, 0.008), (0.22, 0.5, 0.007), (0.3, 0.9, 0.008), (0.41, 0.35, 0.007),
                         (0.52, 0.65, 0.008), (0.6, 0.2, 0.006), (0.7, 0.45, 0.008), (0.84, 0.3, 0.007)],
                  y0=h - 16, y1=28)
    s += line(14, h - 14, w - 14, h - 14, "#5E8C7E", 2)
    return s


def ui_amp(w, h):
    """Real vaqt PCR: sigmasimon kuchayish egri chiziqlari + chegara chizig'i."""
    s = ui_frame(w, h)
    cols = ["#C5E8A1", "#8FC9A0", "#7FB3C8", "#E3B93C", "#D98BA6"]
    for i, c in enumerate([0.32, 0.42, 0.5, 0.6, 0.72]):
        fn = lambda t, c=c: (h - 18) - (h - 46) / (1 + math.exp(-(t - c) * 16))
        s += path(curve_path(fn, 16, w - 14), stroke=cols[i], sw=3)
    s += line(16, h * 0.62, w - 14, h * 0.62, "#E3B93C", 2, "butt", extra='stroke-dasharray="8 6"')
    return s


def ui_clot(w, h):
    s = ui_frame(w, h)
    for i, (c, col) in enumerate([(0.35, "#C5E8A1"), (0.52, "#8FC9A0")]):
        fn = lambda t, c=c: 30 + (h - 60) / (1 + math.exp(-(t - c) * 18))
        s += path(curve_path(fn, 16, w - 14), stroke=col, sw=3.5)
    return s


def ui_agg(w, h):
    """Yorug'lik o'tkazuvchi agregometriya: o'tkazuvchanlik vaqt bo'yicha ortadi."""
    s = ui_frame(w, h)
    for amp, c, col in [(0.85, 0.3, "#C5E8A1"), (0.62, 0.36, "#8FC9A0"), (0.35, 0.42, "#7FB3C8"), (0.12, 0.5, "#E3B93C")]:
        fn = lambda t, a=amp, c=c: (h - 20) - (h - 44) * a / (1 + math.exp(-(t - c) * 14))
        s += path(curve_path(fn, 16, w - 14), stroke=col, sw=3)
    return s


def ui_teg(w, h):
    """Viskoelastik trassa: o'rta chiziqdan ajralib, keyin sekin yaqinlashadi."""
    s = rect(10, 8, w * 0.38, 8, 4, "#8FC9A0", None)
    mid = h * 0.56
    s += line(14, mid, w - 14, mid, "#5E8C7E", 2)

    def amp(t):
        if t < 0.18:
            return 0.0
        u = (t - 0.18) / 0.82
        return (1 - math.exp(-u * 7)) * (1 - 0.35 * u * u)

    a = (h - 44) / 2
    s += path(curve_path(lambda t: mid - a * amp(t), 16, w - 14, 120), stroke="#C5E8A1", sw=3.5)
    s += path(curve_path(lambda t: mid + a * amp(t), 16, w - 14, 120), stroke="#C5E8A1", sw=3.5)
    return s


def ui_spe(w, h):
    """Zardob oqsillari elektroforegrammasi: albumin, a1, a2, beta, gamma."""
    s = ui_frame(w, h)
    s += ui_peaks(w, h, [(0.2, 0.95, 0.04), (0.38, 0.12, 0.025), (0.5, 0.28, 0.03), (0.64, 0.26, 0.035),
                         (0.83, 0.3, 0.07)])
    return s


def ui_freeze(w, h):
    """Muzlash nuqtasi egri chizig'i: sovish, o'ta sovish, sakrash, plato."""
    s = ui_frame(w, h)
    top, low = 30, h - 22

    def fn(t):
        if t < 0.42:
            return top + (low - top) * (t / 0.42) ** 0.8 * 0.95
        if t < 0.47:
            u = (t - 0.42) / 0.05
            return low - (low - (top + (low - top) * 0.55)) * u
        return top + (low - top) * 0.55 + (t - 0.47) ** 2 * 60
    s += path(curve_path(fn, 18, w - 16, 160), stroke="#C5E8A1", sw=3.5)
    s += line(18, top + (low - top) * 0.55, w - 16, top + (low - top) * 0.55, "#E3B93C", 2, "butt",
              extra='stroke-dasharray="7 6"')
    return s


def ui_tracks(w, h):
    """CASA: harakatlanuvchi spermatozoid izlari (rangli egri chiziqlar) va boshchalar."""
    rnd = random.Random(11)
    s = ""
    cols = ["#C5E8A1", "#8FC9A0", "#7FB3C8", "#E3B93C", "#D98BA6"]
    for i in range(9):
        x, y = rnd.uniform(30, w - 60), rnd.uniform(30, h - 40)
        a = rnd.uniform(0, 6.28)
        pts = []
        for k in range(14):
            a += rnd.uniform(-0.5, 0.5)
            x += math.cos(a) * 9 + math.sin(k * 1.7) * 3
            y += math.sin(a) * 9 + math.cos(k * 1.7) * 3
            pts.append((min(max(x, 14), w - 14), min(max(y, 14), h - 14)))
        s += path("M" + " L".join(f"{px:.1f} {py:.1f}" for px, py in pts), stroke=cols[i % 5], sw=2.5)
        s += ell(pts[-1][0], pts[-1][1], 4.5, 3.2, "#FFFFFF")
    for _ in range(6):
        s += ell(rnd.uniform(20, w - 20), rnd.uniform(20, h - 20), 4, 3, "#9FB3AA")
    return s


def ui_gallery(w, h):
    """Siydik cho'kmasi: tasniflangan zarracha tasvirlari to'ri (yorug' maydon)."""
    s = rect(10, 8, w * 0.38, 8, 4, "#8FC9A0", None)
    cols, rows = 4, 3
    tw, th = (w - 20 - (cols - 1) * 6) / cols, (h - 30 - (rows - 1) * 6) / rows
    for r in range(rows):
        for c in range(cols):
            x, y = 10 + c * (tw + 6), 24 + r * (th + 6)
            s += rect(x, y, tw, th, 4, "#E6EEEA", None)
            cx, cy = x + tw / 2, y + th / 2
            k = (r * cols + c) % 6
            if k == 0:  # eritrotsit: rangpar markazli disk
                s += ell(cx, cy, 11, 11, "#D98B86") + ell(cx, cy, 5, 5, "#EDC2BE")
            elif k == 1:  # leykotsit: donador hujayra
                s += ell(cx, cy, 13, 13, "#C9C4D8", "#9A93B5", 1.5)
                s += ell(cx - 4, cy - 2, 4, 3, "#8E86AE") + ell(cx + 4, cy + 3, 4, 3, "#8E86AE")
            elif k == 2:  # gialin silindr
                s += rect(cx - 22, cy - 7, 44, 14, 7, "#D7E3E0", "#9FB3AA", 1.5)
            elif k == 3:  # kristall (konvert shakli)
                s += path(f"M{cx:g} {cy - 11:g} L{cx + 11:g} {cy:g} L{cx:g} {cy + 11:g} L{cx - 11:g} {cy:g} Z",
                          "#F4F7F5", "#7C8C84", 1.5)
                s += line(cx - 11, cy, cx + 11, cy, "#9FB3AA", 1) + line(cx, cy - 11, cx, cy + 11, "#9FB3AA", 1)
            elif k == 4:  # yassi epiteliy
                s += path(f"M{cx - 18:g} {cy - 8:g} L{cx + 6:g} {cy - 13:g} L{cx + 19:g} {cy + 2:g} "
                          f"L{cx + 4:g} {cy + 13:g} L{cx - 16:g} {cy + 9:g} Z", "#E9DCCB", "#B9A78E", 1.5)
                s += ell(cx, cy, 4, 3, "#8E7A60")
            else:  # bakteriyalar (tayoqchalar)
                for dx, dy, a in [(-9, -5, 20), (6, -7, -30), (-3, 6, 60), (10, 6, 10)]:
                    s += f'<rect x="{cx + dx - 5:g}" y="{cy + dy - 1.8:g}" width="10" height="3.6" rx="1.8" fill="#6E7B74" transform="rotate({a} {cx + dx:g} {cy + dy:g})"/>'
    return s


def ui_hba1c(w, h):
    """HbA1c ion almashinuv xromatogrammasi: kichik erta cho'qqilar, HbA1c, HbA0."""
    s = ui_frame(w, h)
    s += ui_peaks(w, h, [(0.12, 0.12, 0.015), (0.2, 0.18, 0.015), (0.36, 0.34, 0.02), (0.68, 0.95, 0.045)])
    return s


def ui_growth(w, h):
    """Suyuq kultura: nazorat probirkasi o'sish egri chizig'i ko'tariladi, dorili tekis qoladi."""
    s = ui_frame(w, h)
    up = lambda t: (h - 18) - (h - 48) / (1 + math.exp(-(t - 0.5) * 12))
    flat = lambda t: (h - 18) - (h - 48) * 0.06 * t
    s += path(curve_path(up, 16, w - 14), stroke="#C5E8A1", sw=3.5)
    s += path(curve_path(flat, 16, w - 14), stroke="#E3B93C", sw=3)
    return s


def vial(x, y, w=18, h=34, cap="#5B8FD0", fill="#EAF6FA"):
    s = rect(x, y + 8, w, h - 8, 4, fill, "#AFC3B8", 1.5)
    s += rect(x - 2, y, w + 4, 11, 3, cap, None)
    return s


def pump_box(x, y, w=150, h=110):
    """Vakuum (forvakuum) nasosi: motor silindri va korpus."""
    s = rect(x, y + 20, w, h - 20, 14, "#DDE5DF", LINE, 3)
    s += rect(x + 18, y, w * 0.55, h - 12, 22, "url(#metal)", "#8E9B94", 2)
    for i in range(5):
        s += line(x + 30 + i * 12, y + 14, x + 30 + i * 12, y + h - 30, "#9AA6A0", 3)
    s += led(x + w - 24, y + 42, "#6FCF7F", 6)
    return s


def turbo(cx, y, w=90, h=80):
    """Turbomolekulyar nasos (kesik ko'rinish: parraklar)."""
    s = rect(cx - w / 2, y, w, h, 10, "url(#metal)", "#8E9B94", 2)
    for i in range(5):
        yy = y + 12 + i * (h - 24) / 4
        s += line(cx - w / 2 + 10, yy, cx + w / 2 - 10, yy + 6, "#6E7B74", 3)
    s += line(cx, y + 6, cx, y + h - 6, "#4C5853", 4)
    return s


def quad_rods(x0, x1, cy, gap=16, r=9):
    """Kvadrupol: to'rt sterjen (ikki juft) yon tomondan."""
    s = ""
    for dy, fill in [(-gap - r, "url(#metal)"), (gap + r, "url(#metal)")]:
        s += rect(x0, cy + dy - r, x1 - x0, 2 * r, r, fill, "#7C8C84", 2)
    s += rect(x0 + 6, cy - r * 0.7, x1 - x0 - 12, r * 1.4, r * 0.7, "#AEB9B3", "#7C8C84", 1.5, extra='opacity="0.65"')
    return s


def ion_path(x0, x1, cy, n=7, cols=("#E3B93C", "#D98BA6", "#7FB3C8")):
    s = line(x0, cy, x1, cy, "#E3B93C", 2, "butt", extra='stroke-dasharray="4 7" opacity="0.8"')
    for i in range(n):
        x = x0 + (x1 - x0) * (i + 0.5) / n
        s += ell(x, cy + (4 if i % 2 else -4), 4.5, 4.5, cols[i % len(cols)])
    return s


def detector_horn(x, cy, h=56):
    """Elektron ko'paytirgich (detektor) — konus."""
    s = path(f"M{x:g} {cy - h / 2:g} L{x + 46:g} {cy - 12:g} L{x + 46:g} {cy + 12:g} L{x:g} {cy + h / 2:g} Z",
             "url(#metal)", "#7C8C84", 2)
    s += rect(x + 44, cy - 16, 22, 32, 5, "#8E9B94", None)
    s += line(x + 8, cy - h / 2 + 8, x + 8, cy + h / 2 - 8, "#E3B93C", 3)
    return s


# =========================================================================
# L1. Gaz xromatografi - mass-spektrometr (GC-MS)
# =========================================================================
def mass_spec_gc():
    s = ground(610, 540)
    # tashuvchi gaz ballon (geliy) va liniya
    s += hose("M142 300 H 204 V 362", "#9AA6A0", 5)
    s += rect(70, 330, 100, 372, 44, "url(#bodyH)")
    s += rect(98, 300, 44, 40, 10, "url(#metal)", "#8E9B94", 2)
    s += ell(120, 296, 16, 10, "#8E9B94")
    s += rect(84, 420, 72, 18, 5, "#9FB3AA", None)
    # GC korpusi
    s += rect(180, 360, 330, 342, 20, "url(#bodyH)")
    # avtonamunaoluvchi minora va flakon tarnovi
    s += rect(232, 196, 70, 170, 14, "#E4EAE6", LINE, 3)
    s += rect(246, 214, 42, 120, 8, "url(#niche)", None)
    s += rect(262, 222, 10, 92, 3, "#EAF6FA", "#9FB3AA", 1.5)
    s += line(267, 312, 267, 350, "#4C5853", 3)
    s += drum(410, 340, 82, 18, 14)
    for i, (px, py) in enumerate(sorted(ring_points(410, 340, 82, 18, 0.72, 14, 0.2), key=lambda t: t[1])):
        s += ell(px, py - 6, 7, 4.5, ["#5B8FD0", "#9AA6A0"][i % 2], "#FFFFFF", 1)
    s += rect(254, 350, 30, 14, 4, "url(#metal)", "#8E9B94", 2)  # injektor
    # termostat (pech) eshigi: kesik oynada kapillyar kolonka o'rami
    s += rect(208, 400, 274, 252, 16, "#F4F7F5", LINE, 3)
    s += rect(232, 424, 226, 176, 12, "url(#niche)", "#232B28", 2)
    for k in range(7):
        s += ell(345, 512, 82 - k * 3, 64 - k * 3, "none", "#C9A15A", 2.4)
    s += ell(345, 512, 50, 38, "#3B4843", "#6E7B74", 2)
    s += line(267, 438, 290, 470, "#C9A15A", 2.4) + line(424, 470, 458, 470, "#C9A15A", 2.4)
    s += rect(232, 616, 120, 12, 6, "#DDE5DF", None) + led(452, 622, "#E3B93C", 6)
    # issiq uzatish liniyasi GC -> MS
    s += rect(482, 458, 92, 22, 10, "url(#metal)", "#8E9B94", 2)
    # MS korpusi
    s += rect(560, 330, 400, 372, 22, "url(#bodyH)")
    s += rect(586, 360, 348, 176, 14, "url(#niche)", "#232B28", 2)
    # ion manbai -> linzalar -> kvadrupol -> detektor
    s += rect(600, 434, 62, 60, 8, "url(#metal)", "#7C8C84", 2)
    s += path("M612 450 q8 -10 16 0 t16 0 t16 0", stroke="#E3B93C", sw=3)
    s += line(574, 469, 600, 469, "#8E9B94", 6)
    for i in range(3):
        s += rect(674 + i * 12, 436, 5, 66, 2, "#AEB9B3", None)
    s += quad_rods(716, 852, 469)
    s += ion_path(660, 860, 469)
    s += detector_horn(862, 469)
    # vakuum: turbo nasos (kesik) va forvakuum nasosi
    s += rect(586, 556, 200, 118, 14, "url(#niche)", "#232B28", 2)
    s += turbo(686, 568, 100, 92)
    s += line(686, 536, 686, 568, "#8E9B94", 10)
    s += rect(806, 556, 128, 118, 14, "#F4F7F5", LINE, 3) + vents(826, 584, 88, 5) + led(830, 570)
    s += hose("M960 650 H 1010 V 610", "#9AA6A0", 7)
    s += pump_box(980, 590, 150, 112)
    s += monitor(980, 214, 196, 146, ui_gcms(176, 126), arm=[(960, 410), (1080, 410), (1080, 360)])
    return s


# =========================================================================
# L2. Suyuqlik xromatografi - mass-spektrometr (LC-MS)
# =========================================================================
def mass_spec_lc():
    s = ground(610, 540)
    # erituvchi idishlari va trubkalar
    for i, (c, liq) in enumerate([("#7FB3C8", "#DCEBF2"), ("#9AA6A0", "#EEF2EF"), ("#D98BA6", "#F5DCE5")]):
        s += bottle(176 + i * 82, 128, 60, 110, c, liq)
    s += rect(150, 236, 290, 26, 8, "#DDE5DF", LINE, 3)
    # nasos moduli
    s += rect(150, 262, 290, 130, 14, "url(#bodyH)")
    s += rect(176, 290, 120, 40, 8, "url(#dark)", None)
    s += rect(186, 300, 80, 8, 3, "#8FC9A0", None) + rect(186, 314, 56, 6, 3, "#5E8C7E", None)
    s += ell(370, 320, 22, 22, "url(#metal)", "#8E9B94", 2) + ell(370, 320, 8, 8, "#6E7B74")
    s += led(176, 362) + rect(200, 356, 90, 12, 6, "#DDE5DF", None)
    # avtonamunaoluvchi (flakonlar)
    s += rect(150, 396, 290, 150, 14, "url(#bodyH)")
    s += rect(174, 418, 242, 104, 12, "url(#niche)", "#232B28", 2)
    for r in range(2):
        for c in range(8):
            s += vial(186 + c * 28, 430 + r * 44, 16, 32, ["#5B8FD0", "#9AA6A0", "#E3B93C"][(r + c) % 3])
    # kolonka termostati (kolonka ko'rinadi)
    s += rect(150, 550, 290, 152, 14, "url(#bodyH)")
    s += rect(174, 572, 242, 82, 12, "url(#niche)", "#232B28", 2)
    s += rect(204, 604, 182, 18, 9, "url(#metal)", "#7C8C84", 2)
    s += rect(196, 600, 16, 26, 4, "#8E9B94", None) + rect(378, 600, 16, 26, 4, "#8E9B94", None)
    s += led(176, 676, "#E3B93C", 6)
    # trubkalar (shisha idishlardan nasosga, kolonkadan ESI manbaiga)
    s += path("M206 238 V 270", stroke="#C9A15A", sw=3) + path("M288 238 V 270", stroke="#C9A15A", sw=3)
    s += path("M394 613 H 470 Q 500 613 500 580 V 500 H 548", stroke="#C9A15A", sw=4)
    # MS korpusi
    s += rect(560, 340, 400, 362, 22, "url(#bodyH)")
    # ESI manbai: kapillyar igna, purkash konusi, kirish teshigi
    s += rect(530, 430, 120, 130, 14, "#E4EAE6", LINE, 3)
    s += rect(546, 446, 96, 98, 10, "url(#niche)", "#232B28", 2)
    s += rect(548, 488, 36, 12, 4, "url(#metal)", "#8E9B94", 1.5)
    s += line(584, 494, 600, 494, "#C9D2CC", 3)
    s += path("M600 494 L636 476 L636 512 Z", "#7FB3C8", None, 0, extra='opacity="0.45"')
    for i in range(8):
        s += ell(606 + i * 4, 494 + (-1) ** i * (i * 1.8), 2, 2, "#CFE9F2")
    # MS kesigi: ion optikasi -> kvadrupol -> detektor
    s += rect(660, 366, 274, 170, 14, "url(#niche)", "#232B28", 2)
    s += path("M640 482 L660 488 L660 500 L640 506 Z", "url(#metal)", "#7C8C84", 1.5)
    for i in range(5):
        s += rect(668 + i * 9, 452 - i * 3, 4, 84 - i * 0 - 0, 2, "#AEB9B3", None, extra='opacity="0.9"')
    s += quad_rods(722, 842, 494, 14, 8)
    s += ion_path(640, 850, 494, 6)
    s += detector_horn(852, 494, 50)
    # vakuum
    s += rect(586, 556, 200, 118, 14, "url(#niche)", "#232B28", 2)
    s += turbo(686, 568, 100, 92)
    s += line(686, 536, 686, 568, "#8E9B94", 10)
    s += rect(806, 556, 128, 118, 14, "#F4F7F5", LINE, 3) + vents(826, 584, 88, 5) + led(830, 570)
    s += hose("M960 650 H 1010 V 610", "#9AA6A0", 7)
    s += pump_box(980, 590, 150, 112)
    s += monitor(980, 226, 196, 146, ui_spectrum(176, 126), arm=[(960, 420), (1080, 420), (1080, 372)])
    return s


# =========================================================================
# L3. MALDI-TOF mass-spektrometr
# =========================================================================
def maldi_tof():
    s = ground(600, 520)
    s += rect(200, 330, 640, 372, 24, "url(#bodyH)")
    s += rect(228, 360, 584, 200, 16, "url(#niche)", "#232B28", 2)
    # nishon plastinasi (yon tomondan) va lazer
    s += rect(262, 400, 16, 120, 3, "url(#metal)", "#7C8C84", 2)
    for i in range(6):
        s += ell(282, 412 + i * 19, 3.5, 5, "#E3B93C")
    s += rect(300, 372, 86, 34, 8, "#5F6B65", "#8E9B94", 2)
    s += rect(306, 380, 20, 18, 3, UV, None)
    s += line(300, 389, 286, 452, UV, 5) + ell(284, 456, 7, 7, UV, None, extra='opacity="0.6"')
    # tezlatuvchi to'rlar va uchish trubasi
    s += line(304, 410, 304, 512, "#AEB9B3", 3, extra='stroke-dasharray="3 4"')
    s += line(322, 410, 322, 512, "#AEB9B3", 3, extra='stroke-dasharray="3 4"')
    s += rect(336, 436, 410, 44, 22, "#3E4A45", "#6E7B74", 2)
    s += rect(336, 436, 410, 44, 22, "url(#glass)", None, extra='opacity="0.35"')
    # yengil ionlar oldinda (detektorga birinchi yetadi)
    for i, (x, r, c) in enumerate([(360, 8, "#E3B93C"), (420, 7.5, "#D98BA6"), (486, 7, "#7FB3C8"), (552, 6, "#E3B93C"),
                                   (614, 5, "#D98BA6"), (672, 4.2, "#7FB3C8"), (722, 3.5, "#E3B93C")]):
        s += ell(x, 458 + (-1) ** i * 6, r, r, c)
    s += line(290, 458, 740, 458, "#E3B93C", 2, "butt", extra='stroke-dasharray="4 8" opacity="0.7"')
    # detektor
    s += rect(752, 418, 26, 80, 6, "url(#metal)", "#7C8C84", 2)
    s += line(758, 428, 758, 488, "#E3B93C", 3)
    # nishon plastinasi yuklash eshigi va old plastina
    s += rect(228, 584, 250, 30, 8, "url(#dark)", None)
    s += path("M210 640 L250 596 H460 L500 640 Z", "#C9D2CC", LINE, 2)
    s += path("M232 634 L262 604 H448 L478 634 Z", "url(#metal)", "#8E9B94", 2)
    for r in range(3):
        for c in range(8):
            t = r / 2
            x = 262 + 4 * (2 - r) * 0 + c * 26 - r * 6 + 4
            s += ell(x + r * 2, 611 + r * 9, 5.5 - r * 0.4 * -1, 3.5, ["#E3B93C", "#F0E2B0", "#D7C27A"][(r + c) % 3],
                     "#9FB3AA", 1)
    s += rect(516, 584, 296, 90, 14, "#F4F7F5", LINE, 3) + vents(540, 604, 200, 5) + led(788, 600)
    # vakuum nasosi
    s += hose("M840 650 H 890", "#9AA6A0", 7)
    s += pump_box(880, 590, 150, 112)
    s += monitor(888, 214, 220, 156, ui_spectrum(200, 136), arm=[(840, 400), (998, 400), (998, 370)])
    return s


def ast_card(x, y, w=48, h=130, tint="#EEF2EF"):
    """Mikrobiologik ID/AST kartasi: quduqchalar to'ri, bo'sh yorliq, somon."""
    s = rect(x, y, w, h, 6, tint, "#AFC3B8", 2)
    s += rect(x + 6, y + 6, w - 12, 18, 3, "#FFFFFF", None)
    cols = ["#F3E8A6", "#C9D68A", "#D98BA6", "#EAF6FA", "#B79AD0", "#E7B27A"]
    for r in range(8):
        for c in range(4):
            s += rect(x + 6 + c * (w - 12) / 4, y + 30 + r * (h - 38) / 8, (w - 12) / 4 - 2, (h - 38) / 8 - 2, 1.5,
                      cols[(r * 3 + c * 5) % 6], None, extra='opacity="0.85"')
    return s


# =========================================================================
# L4. Avtomatik mikrobiologik identifikatsiya / AST tizimi
# =========================================================================
def microbial_id_ast():
    s = ground(600, 520)
    # kasseta: suspenziya probirkalari va ularga somon bilan ulangan kartalar
    s += rect(76, 584, 318, 70, 10, "#E4EAE6", "#BFC9C2", 3)
    s += rect(70, 650, 330, 44, 10, "#DDE5DF", "#BFC9C2", 3)
    for i in range(5):
        x = 86 + i * 62
        s += ast_card(x, 452, 44, 132, ["#EEF2EF", "#E4EEF4"][i % 2])
        s += path(f"M{x + 10:g} 584 Q{x + 12:g} 606 {x + 30:g} 614 V 632", stroke="#BFC9C2", sw=4)
        s += tube(x + 18, 598, None, "#F3EFD8", h=56, w=26, level=0.7)
    # asosiy korpus
    s += rect(430, 290, 520, 412, 24, "url(#bodyH)")
    s += path("M430 290 L452 238 Q456 228 468 228 H912 Q924 228 928 238 L950 290 Z", "url(#topP)", LINE, 3)
    # kesik oyna: inkubator-o'quvchi ichidagi kartalar va optik skaner
    s += rect(458, 316, 300, 220, 16, "url(#niche)", "#232B28", 2)
    s += rect(474, 486, 268, 14, 5, "#5F6B65", None)
    for i in range(6):
        s += ast_card(482 + i * 44, 360, 36, 122)
    s += rect(560, 336, 52, 166, 10, "#3E4A45", "#8E9B94", 2, extra='opacity="0.92"')
    for yy in (376, 408, 440, 472):
        s += line(566, yy, 606, yy, "#E3B93C", 3, extra='opacity="0.9"')
    s += ell(586, 346, 8, 5, "#E3B93C")
    # o'ng panel
    s += rect(782, 316, 144, 220, 14, "#F4F7F5", LINE, 3)
    s += rect(800, 336, 108, 64, 8, "url(#dark)", None)
    s += rect(810, 348, 64, 8, 3, "#8FC9A0", None) + rect(810, 364, 48, 6, 3, "#5E8C7E", None)
    s += vents(804, 430, 100, 5) + led(806, 506)
    # kasseta yuklash bo'limi (to'ldirish kamerasi)
    s += rect(458, 560, 468, 110, 14, "#F4F7F5", LINE, 3)
    s += rect(482, 580, 300, 70, 10, "url(#niche)", "#232B28", 2)
    s += rect(498, 628, 268, 12, 4, "#8E9B94", None)
    s += rect(806, 590, 96, 14, 7, "#DDE5DF", None) + led(812, 632, "#E3B93C", 6)
    s += monitor(972, 236, 200, 148, ui_bars(180, 128, 4), arm=[(950, 440), (1072, 440), (1072, 384)])
    return s


def culture_bottle(x, y, w=46, h=92, cap="#7FB3C8", broth="#E8D9A8", sensor="#B8C9A0"):
    """Gemokultura flakoni: yelka, bo'g'iz, qopqoq, bulyon, tubida sensor."""
    s = rect(x, y + h * 0.3, w, h * 0.7, w * 0.22, "#F6F8F6", "#AFC3B8", 2)
    s += path(f"M{x + w * 0.08:g} {y + h * 0.42:g} Q{x + w * 0.1:g} {y + h * 0.24:g} {x + w * 0.34:g} {y + h * 0.2:g} "
              f"H{x + w * 0.66:g} Q{x + w * 0.9:g} {y + h * 0.24:g} {x + w * 0.92:g} {y + h * 0.42:g} Z",
              "#F6F8F6", "#AFC3B8", 2)
    s += rect(x + w * 0.3, y + h * 0.1, w * 0.4, h * 0.14, 3, "#E4EAE6", "#AFC3B8", 1.5)
    s += rect(x + w * 0.24, y, w * 0.52, h * 0.13, 4, cap, None)
    s += rect(x + w * 0.1, y + h * 0.5, w * 0.8, h * 0.44, w * 0.16, broth, None, extra='opacity="0.95"')
    s += ell(x + w / 2, y + h * 0.9, w * 0.26, h * 0.05, sensor, "#FFFFFF", 1)
    return s


# =========================================================================
# L5. Avtomatik gemokultura tizimi (inkubator-o'quvchi, flakonlar)
# =========================================================================
def blood_culture():
    s = ground(600, 500)
    # stolda: aerob va anaerob flakonlar (qon solingan)
    s += culture_bottle(120, 560, 64, 132, "#7FB3C8", "#9E4A3F")
    s += culture_bottle(200, 560, 64, 132, "#9AA6A0", "#9E4A3F")
    # korpus, ochiq eshik
    s += rect(360, 210, 480, 492, 24, "url(#bodyH)")
    s += path("M360 226 L304 198 V 668 L360 690 Z", "#EEF2EF", LINE, 3)
    s += rect(318, 420, 10, 70, 5, "#8E9B94", None)
    s += rect(386, 236, 428, 360, 16, "url(#niche)", "#232B28", 2)
    for r in range(3):
        yy = 254 + r * 114
        s += rect(398, yy + 96, 404, 8, 3, "#5F6B65", None)
        for i in range(7):
            x = 404 + i * 57
            s += culture_bottle(x, yy, 44, 92, ["#7FB3C8", "#9AA6A0"][(i + r) % 2],
                                "#9E4A3F" if (i * 5 + r * 3) % 7 < 5 else "#E8D9A8")
            s += led(x + 22, yy + 102, "#E3B93C" if (r, i) == (2, 4) else "#6FCF7F", 4)
    # pastki panel
    s += rect(386, 612, 428, 66, 14, "#F4F7F5", LINE, 3)
    s += vents(410, 630, 260, 3) + rect(700, 628, 90, 30, 6, "url(#dark)", None)
    s += rect(708, 636, 54, 7, 3, "#8FC9A0", None)
    s += monitor(886, 260, 210, 154, ui_bars(190, 134, 5), arm=[(840, 470), (990, 470), (990, 414)])
    return s


# =========================================================================
# L6. Mikobakteriyalar uchun avtomatik suyuq muhit tizimi (inkubator-o'quvchi)
# =========================================================================
def mycobacterial_culture():
    s = ground(600, 500)
    # stolda: suyuq muhitli probirkalar, tubida kislorodga sezgir sensor
    s += rect(96, 664, 210, 30, 9, "#DDE5DF", "#BFC9C2", 3)
    for i in range(4):
        x = 112 + i * 48
        s += tube(x, 494, "#9AA6A0", "#F1E6C2", h=150, w=26, level=0.82)
        pos = i == 0
        if pos:
            s += ell(x + 13, 650, 26, 16, "#F0A040", None, extra='opacity="0.55" filter="url(#soft)"')
        s += rect(x + 4, 640, 18, 12, 4, "#F0A040" if pos else "#C9B48A", None)
    # korpus: uch tortma
    s += rect(340, 214, 520, 488, 24, "url(#bodyH)")
    s += rect(368, 234, 464, 58, 12, "#F4F7F5", LINE, 3)
    s += rect(386, 246, 150, 34, 7, "url(#dark)", None) + rect(396, 256, 90, 7, 3, "#8FC9A0", None)
    for i in range(4):
        s += led(580 + i * 30, 263, ["#6FCF7F", "#6FCF7F", "#E3B93C", "#6FCF7F"][i], 6)
    # yuqori tortma ochiq: probirka qopqoqlari to'ri (perspektivada)
    s += path("M392 306 H808 L842 410 H358 Z", "#D3DCD6", LINE, 2)
    for j in range(5):
        t = (j + 0.5) / 5
        yy = 312 + (404 - 312) * t
        x0, x1 = 400 - 36 * t, 800 + 36 * t
        n = 13
        for i in range(n):
            x = x0 + 14 + (x1 - x0 - 28) * i / (n - 1)
            sc = 0.7 + 0.4 * t
            s += ell(x, yy + 2, 11 * sc, 5 * sc, "#7A8780")
            s += ell(x, yy, 11 * sc, 5 * sc, "#9AA6A0" if (i + j) % 5 else "#C3CCC6", "#FFFFFF", 1)
            if (i * 7 + j * 3) % 11 == 0:
                s += ell(x + 13 * sc, yy - 4, 3, 3, "#E3B93C" if j == 2 else "#6FCF7F")
    s += rect(352, 410, 496, 52, 12, "#F4F7F5", LINE, 3)
    s += rect(560, 428, 80, 12, 6, "#8E9B94", None)
    # yopiq tortmalar
    for yy in (478, 586):
        s += rect(368, yy, 464, 96, 12, "#F4F7F5", LINE, 3)
        s += rect(560, yy + 40, 80, 12, 6, "#8E9B94", None)
        s += led(392, yy + 46, "#6FCF7F", 6)
    s += monitor(900, 250, 200, 146, ui_growth(180, 126), arm=[(860, 470), (1000, 470), (1000, 396)])
    return s


# =========================================================================
# L7. Oqim sitometri: suyuqlik tizimi, lazer, oqim kyuvetasi, detektorlar
# =========================================================================
def flow_cytometer():
    s = ground(600, 520)
    # suyuqlik tizimi: obolochka (sheath) suyuqligi va chiqindi
    s += hose("M138 540 V 470 H 330", "#7FB3C8")
    s += hose("M248 566 V 506 H 330", "#9AA6A0")
    s += jug(84, 530, 110, 172, "#7FB3C8", "#CFE3EC", 0.8)
    s += waste_can(206, 560, 92, 142)
    # korpus
    s += rect(320, 290, 500, 412, 24, "url(#bodyH)")
    s += rect(344, 314, 452, 262, 16, "url(#niche)", "#232B28", 2)
    # 1) tafsilot: gidrodinamik fokuslash (yon tomondan)
    s += rect(360, 330, 104, 150, 10, "#2E3934", "#6E7B74", 1.5)
    s += path("M372 340 H452 L424 430 V 470 H400 V 430 Z", "#CFE3EC", None, 0, extra='opacity="0.55"')
    s += path("M412 340 V 470", stroke="#D98BA6", sw=5)
    s += path("M412 340 V 470", stroke="#F2C2D2", sw=1.5)
    for k in range(4):
        s += ell(412, 440 + k * 9, 3.6, 3.6, "#FFFFFF")
    # 2) optika (yuqoridan): lazer -> kyuveta -> FSC; 90 gradusda SSC/fluoressensiya
    s += rect(482, 520, 74, 34, 8, "#5F6B65", "#8E9B94", 2)
    s += rect(488, 528, 16, 18, 3, "#5B8FD0", None)
    s += line(556, 537, 642, 537, "#5B8FD0", 4)
    s += rect(628, 522, 30, 30, 4, "url(#glass)", "#CFE3EC", 2)
    s += ell(643, 537, 5, 5, "#FFFFFF")
    s += line(658, 537, 700, 537, "#5B8FD0", 3, extra='opacity="0.6"')
    s += rect(700, 530, 6, 14, 2, "#151A18", None)
    s += rect(716, 518, 40, 38, 6, "url(#metal)", "#7C8C84", 2)
    s += ell(643, 498, 22, 6, "url(#glass)", "#CFE3EC", 2)
    s += line(643, 522, 643, 400, "#C5E8A1", 3)
    s += line(643, 400, 770, 400, "#C5E8A1", 3)
    for i, (x, c) in enumerate([(668, "#5B8FD0"), (708, "#6FCF7F"), (748, "#E3B93C")]):
        s += line(x - 10, 410, x + 10, 390, "#CFE3EC", 4)
        s += line(x, 400, x, 362, c, 3)
        s += rect(x - 12, 330, 24, 34, 6, "url(#metal)", "#7C8C84", 1.5)
    s += line(770, 400, 778, 400, "#C5E8A1", 3)
    s += rect(774, 386, 16, 28, 4, "url(#metal)", "#7C8C84", 1.5)
    # namuna probirkasi (SIP)
    s += rect(344, 596, 250, 84, 14, "url(#niche)", "#232B28", 2)
    s += tube(450, 622, None, "#F3D9E1", h=44, level=0.6)
    s += rect(456, 600, 14, 46, 5, "url(#metal)", "#8E9B94", 2)
    s += rect(614, 596, 182, 84, 14, "#F4F7F5", LINE, 3) + vents(636, 616, 130, 4) + led(636, 662)
    s += monitor(860, 226, 220, 160, ui_scatter(200, 140), arm=[(820, 450), (970, 450), (970, 386)])
    return s


# =========================================================================
# L8. Real vaqt PCR amplifikatori: termoblok, optik modul, probirka qatori
# =========================================================================
def real_time_pcr():
    s = ground(600, 480)
    # 8 probirkali qator (stolda, tagligida)
    s += rect(110, 640, 230, 40, 10, "#DDE5DF", "#BFC9C2", 3)
    for i in range(8):
        x = 124 + i * 26
        s += path(f"M{x:g} 586 H{x + 20:g} V 616 L{x + 13:g} 640 H{x + 7:g} L{x:g} 616 Z", "#F6F8F6", "#AFC3B8", 1.5)
        s += path(f"M{x + 3:g} 612 H{x + 17:g} L{x + 12:g} 634 H{x + 8:g} Z", ["#F3D9E1", "#E4EEF4"][i % 2], None, 0)
        s += rect(x - 1, 576, 22, 12, 4, "#E8EDEA", "#AFC3B8", 1.5)
    s += line(124, 580, 330, 580, "#AFC3B8", 2)
    # korpus va ochiq qopqoq
    s += rect(370, 420, 470, 282, 24, "url(#bodyH)")
    s += rect(400, 188, 410, 168, 16, "url(#topP)", LINE, 3)
    s += rect(424, 206, 362, 132, 10, "url(#metal)", "#8E9B94", 2)
    for r in range(4):
        for c in range(12):
            s += ell(446 + c * 29.5, 226 + r * 30, 6, 6, "#7C8C84")
    s += path("M370 430 L398 356 H812 L840 430 Z", "url(#deck)", LINE, 3)
    s += path("M418 420 L436 368 H774 L792 420 Z", "url(#metal)", "#8E9B94", 2)
    for r in range(4):
        t = (r + 0.5) / 4
        yy = 372 + 44 * t
        x0, x1 = 438 - 18 * t, 772 + 18 * t
        for c in range(12):
            x = x0 + 10 + (x1 - x0 - 20) * c / 11
            s += ell(x, yy, 8 + 2 * t, 3.5 + 1.5 * t, "#4C5853")
    # oldingi kesik: optik modul (yorug'lik manbai, filtrlar, detektor)
    s += rect(396, 456, 250, 206, 16, "url(#niche)", "#232B28", 2)
    s += ell(446, 600, 18, 18, "#5B8FD0", None, extra='opacity="0.35"')
    s += ell(446, 600, 9, 9, "#9CC3EC")
    s += ell(540, 600, 40, 40, "#3E4A45", "#8E9B94", 2)
    for i, c in enumerate(["#5B8FD0", "#6FCF7F", "#E3B93C", "#D9604F"]):
        a = math.radians(-90 + i * 90)
        s += ell(540 + math.cos(a) * 22, 600 + math.sin(a) * 22, 9, 9, c)
    s += line(464, 600, 498, 600, "#9CC3EC", 3)
    s += rect(590, 480, 40, 34, 6, "url(#metal)", "#7C8C84", 2)
    s += line(540, 560, 540, 500, "#C5E8A1", 3) + line(540, 500, 590, 497, "#C5E8A1", 3)
    s += rect(666, 456, 150, 206, 16, "#F4F7F5", LINE, 3) + vents(688, 500, 106, 6) + led(690, 476)
    s += monitor(880, 250, 220, 160, ui_amp(200, 140), arm=[(840, 480), (990, 480), (990, 410)])
    return s


# =========================================================================
# L9. Kartrijli yopiq molekulyar platforma (modulli)
# =========================================================================
def cartridge_molecular():
    s = ground(600, 510)
    # stolda: bir martalik kartrij, namuna idishi, pipetka
    s += rect(96, 540, 116, 150, 12, "#F6F8F6", "#AFC3B8", 3)
    s += rect(88, 516, 132, 30, 8, "#E4EAE6", "#AFC3B8", 2.5)
    for (x, y, w, h, c) in [(108, 560, 40, 52, "#E4EEF4"), (156, 560, 44, 34, "#F3E8A6"), (156, 600, 44, 30, "#D9E8D0"),
                            (108, 620, 40, 56, "#F5DCE5"), (156, 638, 44, 38, "#EAF6FA")]:
        s += rect(x, y, w, h, 6, c, "#C3CCC6", 1.5)
    s += path("M212 640 L236 650 V 690 H212 Z", "#E4EEF4", "#AFC3B8", 2)
    s += rect(250, 610, 64, 80, 12, "#F2F5F3", "#C3CCC6", 2.5)
    s += rect(244, 596, 76, 22, 6, "#9AA6A0", None)
    s += rect(256, 640, 52, 40, 8, "#E8DFC0", None, extra='opacity="0.85"')
    # korpus: to'rtta modul eshigi
    s += rect(340, 330, 560, 372, 24, "url(#bodyH)")
    s += rect(340, 330, 560, 34, 14, "#E4EAE6", LINE, 3)
    for i in range(4):
        x = 364 + i * 132
        if i == 1:
            s += rect(x, 384, 116, 288, 14, "url(#niche)", "#232B28", 2)
            s += rect(x + 22, 452, 72, 96, 10, "#F6F8F6", "#AFC3B8", 2)
            s += rect(x + 16, 436, 84, 22, 6, "#E4EAE6", "#AFC3B8", 2)
            for (yy, c) in [(470, "#E4EEF4"), (500, "#F3E8A6"), (526, "#F5DCE5")]:
                s += rect(x + 30, yy, 56, 20, 4, c, None)
            s += path(f"M{x:g} 384 L{x - 20:g} 396 V 664 L{x:g} 672 Z", "#EEF2EF", LINE, 2)
            s += led(x + 58, 404, "#E3B93C", 6)
        else:
            s += rect(x, 384, 116, 288, 14, "#F4F7F5", LINE, 3)
            s += rect(x + 46, 400, 24, 8, 4, "#DDE5DF", None)
            s += led(x + 58, 432, "#6FCF7F", 6)
            s += rect(x + 20, 610, 76, 10, 5, "#DDE5DF", None)
    s += monitor(934, 250, 200, 150, ui_bars(180, 130, 4), arm=[(900, 460), (1034, 460), (1034, 400)])
    return s


# =========================================================================
# L10. Koagulometr (avtomatik): reagentlar, sitratli probirkalar, kyuvetalar
# =========================================================================
def coag_analyzer():
    s = ground(600, 480)
    s += rect(300, 384, 600, 318, 22, "url(#bodyH)")
    s += path("M300 384 L338 236 Q342 224 354 224 H846 Q858 224 862 236 L900 384 Z", "url(#deck)", LINE, 3)
    s += deck_clip("dcg", "M312 380 L346 242 H854 L888 380 Z") + '<g clip-path="url(#dcg)">'
    s += rect(300, 234, 600, 150, 0, "#D4DDD7", None)
    # sovutilgan reagent bloki
    s += path("M352 360 L376 262 H560 L552 360 Z", "#C3D3DC", LINE, 2)
    for j in range(3):
        for i in range(5):
            x = 384 + i * 34 - j * 9 + 2
            y = 282 + j * 28
            s += ell(x + 6, y + 3, 13, 7, "#8E9B94")
            s += ell(x + 6, y, 13, 7, ["#7FB3C8", "#E3B93C", "#D98BA6", "#9FB3AA", "#F6F8F6"][(i + j) % 5], "#FFFFFF", 1.5)
    # o'lchash kanallari (kyuvetalar qatori)
    s += path("M600 360 L612 300 H860 L878 360 Z", "#E4EAE6", LINE, 2)
    for i in range(8):
        x = 624 + i * 30
        s += rect(x, 318, 18, 28, 3, "#EAF6FA", "#8FAAB0", 1.5)
    s += probe_arm(600, 266, [(640, 290), (668, 312)], 16)
    s += "</g>"
    s += '<path d="M312 380 L346 242 H640 L560 380 Z" fill="url(#glass)"/>'
    s += rect(296, 374, 608, 22, 9, "#DCE4DF", LINE, 3)
    # namunalar: havorang qopqoqli sitratli probirkalar
    s += rect(330, 424, 270, 236, 16, "url(#niche)", "#232B28", 2)
    s += rack(350, 636, 5, caps=["#8EC3E6"] * 5, fills=["#E8C27A", "#EBCB7F", "#E3BD70", "#E8C27A", "#EECF87"], h=96, step=46)
    # kyuveta optikasi: yorug'lik manbai -> kyuveta -> fotodetektor
    s += rect(624, 424, 248, 120, 14, "url(#niche)", "#232B28", 2)
    s += ell(664, 484, 12, 12, "#E3B93C", None, extra='opacity="0.4"') + ell(664, 484, 6, 6, "#F6E7A8")
    s += line(676, 484, 818, 484, "#F6E7A8", 3, extra='opacity="0.8"')
    s += rect(732, 452, 32, 60, 4, "#EAF6FA", "#8FAAB0", 2)
    s += rect(735, 476, 26, 33, 3, "#E8C27A", None, extra='opacity="0.85"')
    s += rect(820, 466, 28, 36, 6, "url(#metal)", "#7C8C84", 2)
    s += rect(624, 560, 248, 100, 14, "#F4F7F5", LINE, 3) + vents(648, 584, 200, 4) + led(650, 636)
    s += monitor(946, 238, 214, 156, ui_clot(194, 136), arm=[(900, 450), (1056, 450), (1056, 394)])
    return s


def plate(x0, y0, x1, y1, xb0, xb1, rows=8, cols=12, fills=None):
    """Mikroplanshet perspektivada: (x0..x1, y1) — old, (xb0..xb1, y0) — orqa."""
    s = path(f"M{x0:g} {y1:g} L{xb0:g} {y0:g} H{xb1:g} L{x1:g} {y1:g} Z", "#F6F8F6", "#AFC3B8", 2)
    rnd = random.Random(5)
    for r in range(rows):
        t = (r + 0.5) / rows
        yy = y0 + (y1 - y0) * t
        a, b = xb0 + (x0 - xb0) * t, xb1 + (x1 - xb1) * t
        for c in range(cols):
            x = a + 10 + (b - a - 20) * c / (cols - 1)
            rx = (b - a - 20) / (cols - 1) * 0.36
            col = fills(r, c, rnd) if fills else "#E4EAE6"
            s += ell(x, yy, rx, rx * 0.5, col, "#C3CCC6", 0.8)
    return s


def _tmb(r, c, rnd):
    v = rnd.random()
    if c < 2:
        v = [0.95, 0.75, 0.55, 0.38, 0.25, 0.14, 0.06, 0.0][r]
    return ["#FFFFFF", "#FBF3C9", "#F6E38A", "#F0D050", "#E8BF2A"][min(4, int(v * 5))]


# =========================================================================
# L11. Mikroplanshet (ELISA) fotometri va yuvish qurilmasi
# =========================================================================
def elisa_reader():
    s = ground(600, 500)
    # o'quvchi
    s += rect(120, 450, 420, 252, 22, "url(#bodyH)")
    s += path("M120 450 L140 404 Q144 394 156 394 H504 Q516 394 520 404 L540 450 Z", "url(#topP)", LINE, 3)
    # optik yo'l (kesik): lampa -> filtr -> quduqcha -> detektor
    s += rect(148, 474, 110, 150, 12, "url(#niche)", "#232B28", 2)
    s += rect(186, 484, 34, 20, 4, "url(#metal)", "#7C8C84", 1.5)
    s += line(203, 504, 203, 600, "#F6E7A8", 3, extra='opacity="0.8"')
    s += path("M188 530 H218 V 556 Q203 566 188 556 Z", "#F6F8F6", "#AFC3B8", 1.5)
    s += rect(190, 538, 26, 18, 3, "#F0D050", None)
    s += rect(184, 572, 38, 8, 2, "#7FB3C8", None)
    s += ell(203, 602, 11, 11, "#E3B93C", None, extra='opacity="0.45"') + ell(203, 602, 6, 6, "#F6E7A8")
    s += rect(280, 474, 236, 64, 10, "url(#dark)", None)
    s += rect(292, 488, 120, 8, 3, "#8FC9A0", None) + rect(292, 504, 80, 6, 3, "#5E8C7E", None)
    s += led(498, 492) + vents(284, 560, 220, 3)
    # planshet tashuvchisi (tortma) tashqariga chiqqan
    s += rect(260, 610, 260, 20, 6, "url(#dark)", None)
    s += path("M232 696 L270 620 H510 L548 696 Z", "#C9D2CC", LINE, 2)
    s += plate(244, 626, 536, 690, 278, 502, fills=_tmb)
    # yuvish qurilmasi (washer)
    s += hose("M1000 560 V 500 H 930", "#7FB3C8")
    s += hose("M1096 600 V 530 H 930", "#9AA6A0")
    s += rect(600, 470, 330, 232, 22, "url(#bodyH)")
    s += rect(626, 494, 278, 126, 12, "url(#niche)", "#232B28", 2)
    s += rect(650, 510, 230, 26, 6, "url(#metal)", "#7C8C84", 2)
    for i in range(12):
        s += line(662 + i * 19, 536, 662 + i * 19, 566, "#C9D2CC", 3)
    s += path("M640 612 L652 578 H878 L890 612 Z", "#F6F8F6", "#AFC3B8", 1.5)
    for c in range(12):
        s += ell(660 + c * 19.5, 594, 6, 3.2, "#E4EAE6", "#C3CCC6", 0.8)
    s += rect(626, 636, 278, 46, 10, "#F4F7F5", LINE, 3) + led(648, 659) + rect(672, 653, 90, 12, 6, "#DDE5DF", None)
    s += jug(950, 540, 100, 162, "#7FB3C8", "#CFE3EC", 0.75)
    s += waste_can(1060, 580, 84, 122)
    return s


def pleats(x, y, w, h, n=None):
    """HEPA filtri: burmali qatlam."""
    n = n or int(w / 12)
    s = rect(x, y, w, h, 4, "#FFFFFF", "#9FB3AA", 2)
    d = f"M{x + 4:g} {y + 4:g}"
    for i in range(n):
        xx = x + 4 + (w - 8) * (i + 0.5) / n
        d += f" L{xx:.1f} {y + h - 4:g} L{x + 4 + (w - 8) * (i + 1) / n:.1f} {y + 4:g}"
    return s + path(d, stroke="#B7C6BE", sw=2)


# =========================================================================
# L12. II sinf biologik xavfsizlik shkafi — yon kesimi, havo oqimi
# =========================================================================
def bsc_class2():
    s = ground(600, 360)
    # tayanch
    s += rect(400, 560, 22, 142, 6, "url(#metal)", "#8E9B94", 2)
    s += rect(760, 560, 22, 142, 6, "url(#metal)", "#8E9B94", 2)
    s += rect(400, 630, 382, 14, 5, "#C9D2CC", None)
    # korpus (kesim)
    s += path("M372 140 H820 Q836 140 836 156 V 544 Q836 560 820 560 H372 Q356 560 356 544 V 404 L372 222 Z",
              "url(#bodyH)", LINE, 3)
    s += rect(400, 268, 330, 206, 6, "#F7F9F8", "#D6DED9", 2)           # ish zonasi
    s += rect(744, 196, 44, 336, 8, "#D3DCD6", None)                     # orqa kanal
    s += rect(396, 492, 392, 40, 8, "#D3DCD6", None)                     # stol osti kanali
    s += rect(400, 474, 330, 18, 4, "url(#metal)", "#8E9B94", 2)        # ish yuzasi
    for i in range(6):
        s += ell(386 + (i % 2) * 6, 478 + i * 2.5, 2, 2, "#6E7B74")
    s += rect(376, 474, 22, 18, 3, "#C9D2CC", "#8E9B94", 1.5)           # old panjara
    # ventilyator va filtrlar
    s += ell(690, 200, 24, 24, "url(#metal)", "#8E9B94", 2)
    for k in range(6):
        a = math.radians(k * 60)
        s += line(690, 200, 690 + math.cos(a) * 19, 200 + math.sin(a) * 19, "#6E7B74", 4)
    s += pleats(404, 232, 324, 30)                                       # tushuvchi oqim HEPA
    s += pleats(560, 146, 180, 20)                                       # chiqish HEPA
    s += rect(610, 110, 100, 34, 6, "#DDE5DF", LINE, 2)
    # oyna (sash) va operator ochig'i
    s += path("M360 226 L376 230 L384 404 L366 404 Z", "url(#glass)", "#AFC3B8", 2)
    s += rect(356, 222, 30, 12, 4, "#C9D2CC", None)
    # ish yuzasidagi probirka rakasi
    s += rect(560, 446, 90, 16, 4, "#DDE5DF", "#BFC9C2", 2)
    for i in range(4):
        s += rect(566 + i * 21, 412, 12, 36, 5, "#FFFFFFD9", "#C3CCC6", 1.5)
        s += rect(564 + i * 21, 404, 16, 10, 3, TUBE_CAPS[i], None)
    # havo oqimi: xona havosi (sariq) — old ochiqlikdan panjaraga
    s += arrow([(240, 440), (330, 440), (376, 452), (387, 486)], ROOM, 7, 18)
    s += arrow([(240, 470), (330, 470), (360, 480)], ROOM, 7, 18)
    # HEPA dan pastga (ko'k) — ish yuzasiga
    for x in (450, 530, 690):
        s += arrow([(x, 270), (x, 446)], AIR, 6, 16)
    # stol osti -> orqa kanal -> yuqoriga
    s += arrow([(410, 512), (770, 512), (770, 214), (720, 204)], "#7FA8C8", 6, 16)
    # chiqish: HEPA orqali tashqariga
    s += arrow([(660, 112), (660, 50)], AIR, 7, 18)
    s += rect(800, 330, 22, 60, 6, "#EEF2EF", LINE, 2) + led(811, 346, "#6FCF7F", 5)
    return s


# =========================================================================
# L13. Avtoklav (bug'li sterilizator, stol usti)
# =========================================================================
def autoclave():
    s = ground(600, 420)
    s += hose("M352 660 Q 300 660 300 702", "#9AA6A0", 6)
    s += rect(340, 320, 520, 382, 26, "url(#bodyH)")
    s += path("M362 320 L382 282 Q386 274 396 274 H804 Q814 274 818 282 L838 320 Z", "url(#topP)", LINE, 3)
    s += ell(760, 290, 26, 8, "url(#metal)", "#8E9B94", 2)                # suv idishi qopqog'i
    s += rect(468, 258, 22, 26, 5, "url(#metal)", "#8E9B94", 2)           # xavfsizlik klapani
    # kamera: flanets, ichki silindr, savat
    s += ell(520, 504, 150, 150, "url(#metal)", "#8E9B94", 3)
    s += ell(520, 504, 128, 128, "url(#niche)", "#232B28", 2)
    s += ell(530, 500, 96, 96, "#3B4843", "#56635D", 2)
    s += rect(430, 534, 196, 12, 4, "#AEB9B3", None)
    for x, w, h, c in [(446, 52, 34, "#E8DFC0"), (504, 44, 46, "#F4F7F5"), (556, 56, 30, "#E8DFC0")]:
        s += rect(x, 534 - h, w, h, 5, c, "#BFC9C2", 1.5)
    s += line(452, 520, 492, 520, "#C9A15A", 2) + line(560, 522, 606, 522, "#C9A15A", 2)
    # ochiq eshik (yon tomondan)
    s += path("M372 380 Q 330 386 322 504 Q 330 622 372 628", stroke="#8E9B94", sw=6)
    s += ell(300, 504, 44, 150, "url(#metal)", "#8E9B94", 3)
    s += ell(306, 504, 30, 126, "#C9D2CC", "#AEB9B3", 2)
    s += rect(262, 488, 22, 32, 6, "#5F6B65", None)
    # boshqaruv paneli: bosim va harorat manometrlari
    s += rect(700, 346, 140, 330, 16, "#F4F7F5", LINE, 3)
    s += dial(770, 422, 44, 40)
    s += dial(770, 534, 44, 10, "#5B8FD0")
    s += led(730, 620) + led(770, 620, "#E3B93C") + led(810, 620, "#6FCF7F")
    s += rect(730, 640, 80, 12, 6, "#DDE5DF", None)
    return s


def syringe(x, y, h=150, w=30, blood="#8E2F28"):
    """Gaz tahlili shprisi (geparinli): uchi yuqorida, porshen pastda."""
    s = rect(x + w * 0.38, y, w * 0.24, 14, 3, "#E4EAE6", "#AFC3B8", 1.5)
    s += rect(x, y + 12, w, h * 0.62, 6, "#F6F8F6D9", "#AFC3B8", 2)
    s += rect(x + 3, y + 16, w - 6, h * 0.44, 4, blood, None)
    s += rect(x + 2, y + 16 + h * 0.44, w - 4, 10, 3, "#5F6B65", None)
    s += rect(x + w * 0.4, y + 12 + h * 0.62, w * 0.2, h * 0.3, 2, "#E4EAE6", "#AFC3B8", 1.5)
    s += rect(x - 6, y + 12 + h * 0.92, w + 12, 8, 3, "#E4EAE6", "#AFC3B8", 1.5)
    s += rect(x - 8, y + 12 + h * 0.6, w + 16, 6, 3, "#E4EAE6", "#AFC3B8", 1.5)
    return s


# =========================================================================
# L14. Qon gazlari va elektrolitlar (ISE) analizatori
# =========================================================================
def blood_gas_ise():
    s = ground(600, 360)
    s += rect(400, 270, 400, 432, 24, "url(#bodyH)")
    # termoprinter
    s += path("M424 270 L444 222 Q448 212 460 212 H740 Q752 212 756 222 L776 270 Z", "url(#topP)", LINE, 3)
    s += rect(500, 240, 200, 18, 7, "url(#dark)", None)
    s += rect(516, 206, 168, 44, 3, "#FFFFFF", "#D2DAD5", 2, extra='transform="rotate(-1.5 600 228)"')
    s += line(530, 218, 640, 217, "#BFC9C2", 3) + line(530, 230, 600, 229, "#BFC9C2", 3)
    s += monitor(426, 292, 348, 150, ui_bars(328, 130, 4))
    # namuna kiritish: zond va shpris
    s += rect(426, 462, 132, 130, 14, "url(#niche)", "#232B28", 2)
    s += rect(482, 470, 20, 30, 5, "url(#metal)", "#8E9B94", 2)
    s += rect(489, 498, 6, 18, 2, "#7B8781", None)
    s += syringe(478, 512, 104, 28)
    # sensor kassetasi (kesik): o'lchash kanali bo'ylab sensorlar (elektrodlar)
    s += rect(574, 462, 200, 130, 14, "url(#niche)", "#232B28", 2)
    s += rect(586, 476, 176, 10, 4, "#5F6B65", None)
    s += rect(586, 548, 176, 16, 8, "#C9D2CC", "#8E9B94", 1.5)
    s += line(592, 556, 756, 556, "#B6403A", 5)
    for i, c in enumerate(["#7FB3C8", "#6FCF7F", "#D98BA6", "#E3B93C", "#8E6CC4"]):
        x = 594 + i * 34
        s += line(x + 13, 486, x + 13, 506, "#AEB9B3", 2)
        s += rect(x, 504, 26, 42, 6, "url(#metal)", "#7C8C84", 1.5)
        s += ell(x + 13, 546, 9, 4, c, None)
    # reagent paketi
    s += rect(426, 608, 348, 76, 14, "#F4F7F5", LINE, 3)
    s += rect(452, 622, 220, 50, 10, "#DDE5DF", "#BFC9C2", 2)
    s += rect(536, 636, 52, 12, 6, "#8E9B94", None)
    s += led(712, 646)
    return s


# =========================================================================
# L15. HbA1c analizatori (ixcham, EDTA qonli probirkalar)
# =========================================================================
def hba1c_analyzer():
    s = ground(600, 420)
    s += hose("M940 560 V 470 H 840", "#7FB3C8")
    s += hose("M1040 590 V 500 H 840", "#D98BA6")
    s += hose("M230 640 V 560 H 360", "#9AA6A0")
    s += bottle(900, 548, 76, 154, "#7FB3C8", "#DCEBF2", "#FFFFFF")
    s += bottle(1000, 580, 70, 122, "#D98BA6", "#F5DCE5")
    s += waste_can(186, 610, 90, 92)
    s += rect(360, 280, 480, 422, 24, "url(#bodyH)")
    s += path("M384 280 L404 228 Q408 218 420 218 H780 Q792 218 796 228 L816 280 Z", "url(#topP)", LINE, 3)
    # kesik oyna: ion almashinuv kolonkasi -> fotometrik detektor (oqim kyuvetasi)
    s += rect(404, 228, 180, 44, 8, "url(#niche)", "#232B28", 2)
    s += rect(418, 242, 96, 16, 7, "url(#metal)", "#7C8C84", 1.5)
    s += rect(412, 244, 8, 12, 2, "#8E9B94", None) + rect(512, 244, 8, 12, 2, "#8E9B94", None)
    s += line(520, 250, 540, 250, "#C9A15A", 3)
    s += rect(540, 238, 10, 24, 2, "url(#glass)", "#CFE3EC", 1.5)
    s += line(546, 250, 556, 250, "#F2D46B", 2)
    s += rect(556, 238, 18, 24, 3, "url(#metal)", "#7C8C84", 1.5)
    s += rect(600, 246, 160, 18, 7, "url(#dark)", None)
    s += rect(614, 214, 132, 42, 3, "#FFFFFF", "#D2DAD5", 2, extra='transform="rotate(-1.5 680 235)"')
    s += line(628, 226, 716, 225, "#BFC9C2", 3)
    s += monitor(386, 302, 270, 168, ui_hba1c(250, 148))
    for r in range(3):
        for c in range(3):
            s += rect(680 + c * 46, 312 + r * 42, 36, 32, 8, "#FFFFFF", "#C3CCC6", 2)
    # namuna rakasi (binafsha qopqoq — EDTA, butun qon)
    s += rect(386, 494, 428, 180, 16, "url(#niche)", "#232B28", 2)
    s += rack(410, 650, 8, caps=["#8E6CC4"] * 8, fills=["#9E2F2A", "#A83630", "#9E2F2A", "#B03A33"], step=46, h=96)
    s += probe_arm(760, 512, [(700, 520), (650, 528)], 30)
    return s


# =========================================================================
# L16. Laboratoriya muzlatgich-sovutgichi va harorat monitoringi
# =========================================================================
def lab_fridge():
    s = ground(620, 380)
    s += rect(400, 110, 340, 592, 22, "url(#bodyH)")
    s += rect(420, 124, 300, 40, 10, "url(#dark)", None)
    s += rect(436, 136, 70, 16, 4, "#8FC9A0", None) + led(700, 144, "#6FCF7F", 6)
    # shisha eshik va javonlar
    s += rect(416, 176, 308, 330, 14, "#E4EAE6", LINE, 3)
    s += rect(432, 190, 276, 302, 8, "#F2F7F9", "#C9D7DC", 2)
    for yy in (290, 390):
        s += rect(434, yy, 272, 8, 3, "#C3D0D6", None)
    s += rack(446, 270, 4, caps=TUBE_CAPS, h=50, step=30, plate_w=132)
    s += rect(596, 232, 92, 56, 6, "#F6F8F6", "#BFC9C2", 2)
    s += rect(604, 242, 76, 10, 3, "#D98BA6", None)
    s += bottle(452, 316, 40, 74, "#7FB3C8", "#DCEBF2")
    s += bottle(500, 326, 36, 64, "#E3B93C", "#F3E8A6")
    # harorat datchigi: buferli flakon (glikol) ichida zond
    s += bottle(620, 330, 40, 60, "#9AA6A0", "#E9E2F2")
    s += line(640, 334, 640, 372, "#5F6B65", 3)
    s += path("M640 330 Q 650 300 708 296 H 724", stroke="#5F6B65", sw=4)
    s += rect(452, 410, 120, 64, 6, "#F6F8F6", "#BFC9C2", 2)
    s += rect(586, 418, 110, 56, 6, "#F6F8F6", "#BFC9C2", 2)
    s += rect(432, 190, 276, 302, 8, "url(#glass)", None)
    s += rect(728, 220, 10, 180, 5, "#8E9B94", None)
    # muzlatgich
    s += rect(416, 520, 308, 166, 14, "#F4F7F5", LINE, 3)
    s += rect(500, 538, 140, 12, 6, "#8E9B94", None)
    s += vents(456, 640, 228, 3)
    # raqamli ma'lumot yozgich (DDL), kabel eshik zichlagichi orqali
    s += path("M724 296 H 760 Q 800 296 800 360 V 560", stroke="#5F6B65", sw=4)
    s += rect(756, 560, 116, 96, 14, "#F4F7F5", LINE, 3)
    s += rect(770, 574, 88, 44, 6, "url(#dark)", None)
    s += rect(778, 584, 46, 8, 3, "#8FC9A0", None) + rect(778, 600, 30, 6, 3, "#5E8C7E", None)
    s += led(776, 636, "#6FCF7F", 5) + led(798, 636, "#E3B93C", 5)
    s += rect(748, 652, 132, 50, 8, "#DDE5DF", "#BFC9C2", 2)
    return s


def microscope(dx=0, epi=False, camera=False, heated=False):
    """Tik (upright) mikroskop, yon ko'rinish; oldi chap tomonda."""
    s = ""
    # asos va ustun
    s += rect(330 + dx, 640, 340, 62, 22, "url(#bodyH)")
    s += ell(450 + dx, 640, 22, 6, "#E8EDEA", "#AFC3B8", 2)
    s += path(f"M{560 + dx} 642 V 360 Q{560 + dx} 300 {600 + dx} 300 H{640 + dx} V 642 Z", "url(#bodyH)", LINE, 3)
    s += rect(400 + dx, 276, 250, 70, 24, "url(#bodyH)")
    # bosh va okulyarlar
    s += path(f"M{420 + dx} 278 L{440 + dx} 232 H{520 + dx} L{540 + dx} 278 Z", "url(#topP)", LINE, 3)
    for k in (0, 14):
        s += f'<g transform="rotate(-32 {450 + dx + k} 236)">' + rect(436 + dx + k, 150, 30, 92, 8, "url(#metal)", "#8E9B94", 2) + \
             rect(432 + dx + k, 144, 38, 18, 6, "#5F6B65", None) + "</g>"
    # revolver va obyektivlar
    s += ell(460 + dx, 352, 52, 12, "url(#metal)", "#8E9B94", 2)
    s += rect(446 + dx, 356, 28, 64, 6, "url(#metal)", "#7C8C84", 2)
    s += rect(450 + dx, 412, 20, 14, 3, "#5F6B65", None)
    s += path(f"M{410 + dx} 358 L{396 + dx} 404 L{414 + dx} 408 L{426 + dx} 362 Z", "url(#metal)", "#7C8C84", 1.5)
    s += path(f"M{494 + dx} 362 L{508 + dx} 400 L{524 + dx} 396 L{510 + dx} 358 Z", "url(#metal)", "#7C8C84", 1.5)
    # stolik, preparat, kondensor
    s += rect(560 + dx, 448, 20, 60, 4, "#C9D2CC", None)
    if heated:
        s += rect(360 + dx, 444, 210, 8, 3, "#E7B27A", None)
    s += rect(350 + dx, 450, 230, 18, 6, "url(#metal)", "#8E9B94", 2)
    s += rect(396 + dx, 438, 130, 12, 2, "#EAF6FA", "#9FB3AA", 1.5)
    if camera:
        s += rect(420 + dx, 436, 80, 3, 1, "#C9D7DC", None)
    s += rect(444 + dx, 474, 32, 34, 6, "url(#metal)", "#7C8C84", 2)
    s += ell(460 + dx, 540, 26, 8, "#C9D2CC", "#AFC3B8", 2)
    s += line(460 + dx, 548, 460 + dx, 634, "#C9D2CC", 6)
    # fokus vintlari
    s += ell(616 + dx, 540, 30, 30, "url(#metal)", "#8E9B94", 2) + ell(616 + dx, 540, 14, 14, "#AEB9B3", "#8E9B94", 1.5)
    if epi:
        # LED fluoressent yoritgich moduli va filtr kubigi
        s += rect(640 + dx, 284, 96, 54, 12, "#DDE5DF", LINE, 3)
        for i in range(5):
            s += line(652 + dx + i * 16, 290, 652 + dx + i * 16, 332, "#BFC9C2", 3)
        s += ell(640 + dx, 311, 10, 10, "#5B8FD0", None, extra='opacity="0.5"')
        s += rect(486 + dx, 330, 44, 14, 4, "#5F6B65", None) + rect(492 + dx, 333, 14, 8, 2, "#5B8FD0", None) + \
            rect(510 + dx, 333, 14, 8, 2, "#9BE36B", None)
        s += path(f"M{452 + dx} 426 L{432 + dx} 440 H{488 + dx} L{468 + dx} 426 Z", "#5B8FD0", None, 0, extra='opacity="0.45"')
        s += ell(460 + dx, 440, 16, 4, GLOW, None, extra='opacity="0.85"')
    if camera:
        s += rect(476 + dx, 168, 30, 70, 6, "url(#metal)", "#8E9B94", 2)
        s += rect(458 + dx, 118, 66, 56, 10, "url(#dark)", "#0F1412", 2)
        s += ell(491 + dx, 146, 10, 10, "#3E4A45", "#8E9B94", 2)
    return s


def afb_field(cx, cy, r):
    """Ko'rish maydoni: qorong'i fonda sarg'ish-yashil tayoqchalar (auramin)."""
    rnd = random.Random(3)
    s = ell(cx, cy, r + 10, r + 10, "url(#metal)", "#8E9B94", 3)
    s += ell(cx, cy, r, r, "#0F1A16")
    cells = [(gx, gy) for gx in range(-2, 3) for gy in range(-2, 3) if gx * gx + gy * gy <= 5]
    rnd.shuffle(cells)
    for gx, gy in cells[:13]:
        x = cx + gx * r * 0.3 + rnd.uniform(-0.08, 0.08) * r
        y = cy + gy * r * 0.3 + rnd.uniform(-0.08, 0.08) * r
        a = rnd.uniform(0, 3.14)
        L = rnd.uniform(16, 26)
        bend = rnd.uniform(-5, 5)
        d = f"M{x - math.cos(a) * L / 2:.1f} {y - math.sin(a) * L / 2:.1f} q{math.cos(a) * L / 2 - math.sin(a) * bend:.1f} {math.sin(a) * L / 2 + math.cos(a) * bend:.1f} {math.cos(a) * L:.1f} {math.sin(a) * L:.1f}"
        s += path(d, stroke=GLOW, sw=8, extra='opacity="0.25"')
        s += path(d, stroke="#E4F27A", sw=4)
    for _ in range(10):
        a, d = rnd.uniform(0, 6.283), rnd.uniform(0.1, 0.85) * r
        s += ell(cx + math.cos(a) * d, cy + math.sin(a) * d, 3, 2, "#3B5A3A")
    return s


# =========================================================================
# L17. LED fluoressent mikroskop (auramin bilan bo'yalgan surtma)
# =========================================================================
def fluorescence_microscope():
    s = ground(560, 300)
    s += microscope(-40, epi=True)
    s += line(480, 440, 760, 380, "#9FB3AA", 2, extra='stroke-dasharray="6 6"')
    s += afb_field(910, 380, 150)
    return s


# =========================================================================
# L18. Kompyuterli sperma tahlili (CASA): kamera, isitiladigan stolik, kompyuter
# =========================================================================
def casa():
    s = ground(600, 470)
    s += microscope(-120, camera=True, heated=True)
    s += path("M404 120 Q 404 80 470 80 H 760 Q 800 80 800 200 V 250", stroke="#5F6B65", sw=5)
    # monitor (stolda)
    s += rect(870, 560, 40, 120, 8, "url(#metal)", "#8E9B94", 2)
    s += rect(820, 676, 140, 26, 10, "#DDE5DF", LINE, 2)
    s += rect(720, 250, 340, 320, 16, "url(#dark)", "#0F1412", 2)
    s += rect(734, 264, 312, 292, 8, "#142621", None)
    s += f'<g transform="translate(734,264)">{ui_tracks(312, 292)}</g>'
    return s


def gel_card(x, y, w=330, h=440):
    """Gel (mikrokolonka) kartasi: 6 mikronaycha; musbat — gel ustida qizil
    chiziq, manfiy — tubida eritrotsit tugmasi."""
    s = rect(x, y, w, h, 18, "#F6F8F6", "#AFC3B8", 3)
    s += rect(x, y, w, 36, 14, "url(#metal)", "#9FB3AA", 2)
    s += rect(x + 20, y + h - 64, w - 40, 44, 8, "#FFFFFF", "#D2DAD5", 2)
    step = (w - 40) / 6
    for i in range(6):
        cx = x + 20 + step * (i + 0.5)
        s += path(f"M{cx - 18:g} {y + 52:g} H{cx + 18:g} V {y + 112:g} L{cx + 9:g} {y + 128:g} H{cx - 9:g} L{cx - 18:g} {y + 112:g} Z",
                  "#FFFFFF", "#C3CCC6", 1.5)
        top, bot = y + 128, y + h - 90
        s += rect(cx - 9, top, 18, bot - top, 4, "#E1EEE8", "#C3CCC6", 1.5)
        s += path(f"M{cx - 9:g} {bot - 4:g} L{cx:g} {bot + 12:g} L{cx + 9:g} {bot - 4:g}", "#E1EEE8", "#C3CCC6", 1.5)
        if i < 2:
            s += rect(cx - 9, top + 2, 18, 18, 3, "#B6403A", None)
        elif i == 2:
            for k in range(9):
                s += ell(cx + (-4 if k % 2 else 4), top + 14 + k * 16, 4, 3, "#C2453E")
        else:
            s += ell(cx, bot + 2, 8, 7, "#B6403A")
    return s


# =========================================================================
# L19. Gel-kartali tizim: karta sentrifugasi, inkubator, gel karta
# =========================================================================
def gel_card_system():
    s = ground(600, 500)
    # karta sentrifugasi
    s += rect(110, 520, 330, 182, 24, "url(#bodyH)")
    s += ell(275, 520, 156, 42, "url(#topP)", LINE, 3)
    s += ell(275, 518, 128, 32, "url(#niche)", "#232B28", 2)
    for k in range(12):
        a = 2 * math.pi * k / 12
        s += line(275 + math.cos(a) * 46, 518 + math.sin(a) * 11, 275 + math.cos(a) * 108, 518 + math.sin(a) * 26,
                  "#F6F8F6", 7, "butt")
    s += ell(275, 518, 26, 7, "#8E9B94")
    s += rect(150, 590, 120, 40, 8, "url(#dark)", None) + rect(160, 602, 70, 7, 3, "#8FC9A0", None)
    s += led(300, 610) + rect(326, 604, 80, 12, 6, "#DDE5DF", None)
    # inkubator (kartalar tik turibdi)
    s += rect(470, 590, 250, 112, 18, "url(#bodyH)")
    s += rect(488, 574, 214, 20, 6, "#C9D2CC", LINE, 2)
    for i in range(6):
        x = 498 + i * 34
        s += rect(x, 500, 24, 84, 4, "#F6F8F6", "#AFC3B8", 1.5)
        s += rect(x, 500, 24, 10, 3, "#C9D2CC", None)
        for k in range(3):
            s += line(x + 6 + k * 6, 516, x + 6 + k * 6, 570, "#DCE9E2", 3)
    s += led(494, 650) + rect(520, 644, 90, 12, 6, "#DDE5DF", None)
    s += gel_card(770, 262, 320, 440)
    return s


# =========================================================================
# L20. EChT: Westergren shtativi va avtomatik o'quvchi
# =========================================================================
def esr_analyzer():
    s = ground(600, 480)
    # Westergren shtativi
    s += rect(100, 650, 340, 40, 12, "#DDE5DF", "#BFC9C2", 3)
    s += rect(100, 236, 340, 26, 10, "#DDE5DF", "#BFC9C2", 3)
    s += rect(110, 262, 12, 388, 4, "#C9D2CC", None) + rect(418, 262, 12, 388, 4, "#C9D2CC", None)
    for i, b in enumerate([288, 306, 334, 372, 430]):
        x = 156 + i * 60
        s += rect(x, 250, 20, 400, 8, "#FFFFFFD9", "#C3CCC6", 2)
        s += rect(x + 3, 270, 14, b - 270, 3, "#F3E3A8", None)
        s += rect(x + 3, b, 14, 632 - b, 3, "#B6403A", None)
        for k in range(10):
            yy = 270 + k * 36
            s += line(x - 10, yy, x - 2, yy, "#9FB3AA", 2)
        s += rect(x - 4, 632, 28, 22, 5, "#5F6B65", None)
    # avtomatik o'quvchi (yopiq probirkalar, qora qopqoq)
    s += rect(540, 420, 480, 282, 24, "url(#bodyH)")
    s += rect(566, 404, 428, 30, 10, "#DDE5DF", LINE, 3)
    for i in range(8):
        s += tube(586 + i * 50, 296, "#3A3F3D", "#B6403A", h=112, w=26, level=0.62)
        s += rect(589 + i * 50, 312, 20, 30, 3, "#F3E3A8", None)
    s += rect(570, 366, 420, 18, 8, "#3E8F7C", None, extra='opacity="0.35"')
    for i in range(8):
        s += ell(599 + i * 50, 375, 5, 5, "#9BE36B")
    s += rect(570, 460, 230, 130, 12, "url(#dark)", None)
    s += f'<g transform="translate(580,470)">{ui_bars(210, 110, 4)}</g>'
    s += rect(824, 460, 170, 130, 14, "#F4F7F5", LINE, 3) + vents(846, 494, 126, 5) + led(848, 476)
    s += rect(570, 612, 424, 66, 14, "#F4F7F5", LINE, 3) + rect(600, 640, 120, 12, 6, "#DDE5DF", None)
    return s


# =========================================================================
# L21. Trombotsit agregometri (LTA) va viskoelastik analizator (TEG/ROTEM)
# =========================================================================
def aggregometer():
    s = ground(620, 520)
    # LTA agregometri
    s += rect(100, 470, 430, 232, 22, "url(#bodyH)")
    s += path("M100 470 L122 410 Q126 400 138 400 H492 Q504 400 508 410 L530 470 Z", "url(#topP)", LINE, 3)
    for i in range(4):
        x = 160 + i * 44
        s += ell(x, 436, 15, 6, "#4C5853")
        s += rect(x - 8, 404, 16, 34, 3, "#F6F8F6D9", "#AFC3B8", 1.5)
        s += rect(x - 6, 418, 12, 18, 2, "#F2DFA0", None)
    for i in range(6):
        s += ell(354 + i * 26, 440, 9, 4, "#4C5853")
    # bitta kanalning kesigi: LED -> kyuveta (aralashtirgich) -> fotodiod
    s += rect(126, 494, 170, 120, 12, "url(#niche)", "#232B28", 2)
    s += ell(150, 552, 10, 10, "#E3B93C", None, extra='opacity="0.45"') + ell(150, 552, 5, 5, "#F6E7A8")
    s += line(160, 552, 260, 552, "#F6E7A8", 3, extra='opacity="0.8"')
    s += rect(194, 506, 34, 90, 5, "#F6F8F6D9", "#AFC3B8", 2)
    s += rect(197, 528, 28, 64, 4, "#F2DFA0", None, extra='opacity="0.9"')
    s += rect(202, 582, 18, 7, 3.5, "#5F6B65", None)
    s += rect(262, 538, 24, 30, 5, "url(#metal)", "#7C8C84", 2)
    s += rect(316, 494, 190, 120, 12, "url(#dark)", None)
    s += f'<g transform="translate(322,500)">{ui_agg(178, 108)}</g>'
    s += rect(126, 630, 380, 50, 10, "#F4F7F5", LINE, 3) + led(148, 655) + rect(174, 649, 90, 12, 6, "#DDE5DF", None)
    # viskoelastik analizator: ikki kanal (kosacha va pin)
    s += rect(580, 360, 320, 342, 22, "url(#bodyH)")
    for k in range(2):
        x = 606 + k * 146
        s += rect(x, 386, 122, 196, 12, "url(#niche)", "#232B28", 2)
        cx = x + 61
        s += rect(cx - 16, 396, 32, 40, 6, "url(#metal)", "#7C8C84", 2)
        s += line(cx, 436, cx, 520, "#C9D2CC", 4)
        s += path(f"M{cx - 28:g} 486 H{cx + 28:g} V 540 Q{cx:g} 556 {cx - 28:g} 540 Z", "#F6F8F6D9", "#AFC3B8", 2)
        s += path(f"M{cx - 24:g} 506 H{cx + 24:g} V 538 Q{cx:g} 550 {cx - 24:g} 538 Z", "#8E2F28", None, 0)
        s += rect(cx - 9, 484, 18, 46, 5, "url(#metal)", "#7C8C84", 1.5)
        s += rect(cx - 38, 554, 76, 16, 5, "#8E9B94", None)
        s += path(f"M{cx - 44:g} 574 Q{cx:g} 590 {cx + 44:g} 574", stroke="#E3B93C", sw=3)
    s += rect(606, 600, 268, 80, 12, "#F4F7F5", LINE, 3) + vents(628, 620, 160, 4) + led(844, 622)
    s += monitor(936, 230, 210, 156, ui_teg(190, 136), arm=[(900, 450), (1040, 450), (1040, 386)])
    return s


# =========================================================================
# L22. Elektroforez apparati: tok manbai, kamera, densitometr
# =========================================================================
def electrophoresis():
    s = ground(600, 520)
    # tok manbai
    s += rect(70, 520, 230, 182, 20, "url(#bodyH)")
    s += rect(94, 542, 120, 50, 8, "url(#dark)", None) + rect(104, 556, 70, 8, 3, "#8FC9A0", None)
    s += ell(256, 566, 22, 22, "url(#metal)", "#8E9B94", 2) + ell(256, 566, 7, 7, "#6E7B74")
    s += ell(120, 650, 12, 12, "#B6403A", "#FFFFFF", 2) + ell(170, 650, 12, 12, "#2E3330", "#FFFFFF", 2)
    # kamera: bufer bo'limlari, pilikchalar, tashuvchi muhit, qopqoq
    s += path("M350 696 L384 590 H776 L810 696 Z", "#EEF4F6", "#AFC3B8", 3)
    s += path("M356 690 L386 600 H446 L432 690 Z", "#CFE3EC", None, 0, extra='opacity="0.9"')
    s += path("M728 690 L714 600 H774 L804 690 Z", "#CFE3EC", None, 0, extra='opacity="0.9"')
    s += line(392, 612, 372, 680, "#2E3330", 3) + line(768, 612, 788, 680, "#B6403A", 3)
    s += path("M424 660 L440 612 H720 L736 660 Z", "#FFFFFF", "#C3CCC6", 2)
    s += path("M414 664 L432 610 H450 L436 664 Z", "#E8DFC0", None, 0)
    s += path("M710 610 H728 L746 664 H724 Z", "#E8DFC0", None, 0)
    for r in range(4):
        t = (r + 0.5) / 4
        yy = 616 + 40 * t
        a, b = 440 - 16 * t, 720 + 16 * t
        for f, wdt, op in [(0.2, 26, 0.35), (0.4, 9, 0.6), (0.53, 10, 0.65), (0.64, 6, 0.6), (0.8, 16, 0.95)]:
            x = a + (b - a) * f
            s += rect(x - wdt / 2, yy - 4, wdt, 8, 3, "#6B4FA0", None, extra=f'opacity="{op}"')
    s += path("M380 560 L404 470 H760 L786 560 Z", "url(#glass)", "#AFC3B8", 2)
    # simlar: qizil — anod (+), qora — katod (-)
    s += path("M120 650 Q 130 742 470 720 T 788 680", stroke="#B6403A", sw=5)
    s += path("M170 650 Q 200 560 374 676", stroke="#2E3330", sw=5)
    # densitometr
    s += rect(850, 470, 280, 232, 22, "url(#bodyH)")
    s += rect(870, 494, 240, 120, 10, "url(#dark)", None)
    s += f'<g transform="translate(878,500)">{ui_spe(224, 108)}</g>'
    s += rect(874, 636, 232, 18, 6, "url(#dark)", None)
    s += led(882, 676) + rect(906, 670, 90, 12, 6, "#DDE5DF", None)
    return s


# =========================================================================
# L23. Osmometr (muzlash nuqtasining pasayishi)
# =========================================================================
def osmometer():
    s = ground(600, 400)
    # stolda: kichik namuna probirkalari
    s += rect(210, 650, 150, 30, 8, "#DDE5DF", "#BFC9C2", 3)
    for i in range(4):
        s += tube(224 + i * 34, 590, ["#9AA6A0", "#E3B93C", "#9AA6A0", "#B6403A"][i], "#F3E3A8", h=50, w=18, level=0.5)
    s += rect(400, 380, 420, 322, 24, "url(#bodyH)")
    # ustun va bosh (termistor zondi)
    s += rect(620, 230, 44, 160, 10, "url(#metal)", "#8E9B94", 2)
    s += rect(490, 228, 174, 46, 12, "#DDE5DF", LINE, 3)
    s += line(530, 274, 530, 388, "#8E9B94", 5)
    s += ell(530, 384, 34, 9, "#4C5853")
    # kesik: sovutish bloki ichida namuna probirkasi, termistor, aralashtirgich sim
    s += rect(430, 404, 200, 210, 14, "url(#niche)", "#232B28", 2)
    s += rect(456, 416, 148, 182, 10, "#CFE3EC", "#9FB8C4", 2)
    for i in range(5):
        s += line(462, 440 + i * 32, 476, 432 + i * 32, "#FFFFFF", 2, extra='opacity="0.7"')
        s += line(584, 440 + i * 32, 598, 432 + i * 32, "#FFFFFF", 2, extra='opacity="0.7"')
    s += rect(504, 416, 52, 160, 8, "#26302C", None)
    s += rect(512, 424, 36, 140, 10, "#FFFFFFD9", "#C3CCC6", 2)
    s += rect(515, 500, 30, 60, 8, "#F3E3A8", None)
    s += line(530, 388, 530, 530, "#AEB9B3", 3) + ell(530, 532, 4.5, 4.5, "#E3B93C")
    s += line(540, 400, 540, 540, "#D9604F", 1.5)
    # displey va tugmalar
    s += monitor(648, 404, 150, 120, ui_freeze(130, 100))
    for r in range(2):
        for c in range(3):
            s += rect(654 + c * 48, 540 + r * 36, 40, 28, 7, "#FFFFFF", "#C3CCC6", 2)
    s += rect(430, 632, 200, 50, 10, "#F4F7F5", LINE, 3) + led(452, 657)
    return s


# =========================================================================
# L24. Yupqa qatlam xromatografiyasi: rivojlantirish kamerasi va UB lampa
# =========================================================================
def tlc():
    s = ground(600, 470)
    # rivojlantirish kamerasi (shisha), qopqoq, filtr qog'oz, erituvchi
    s += rect(176, 384, 268, 296, 6, "#F3EFE2", None, extra='opacity="0.8"')
    s += rect(166, 640, 288, 46, 4, "#EFE3B6", None, extra='opacity="0.85"')
    s += rect(232, 400, 150, 276, 4, "#FFFFFF", "#C3CCC6", 2)
    s += rect(234, 470, 146, 204, 2, "#EEF0E6", None)
    s += line(236, 470, 378, 470, "#C9A15A", 2, extra='stroke-dasharray="5 4"')
    s += line(240, 622, 374, 622, "#9AA6A0", 2)
    for i, ys in enumerate([[560, 506], [592, 530, 488], [548]]):
        x = 268 + i * 40
        s += ell(x, 622, 5, 3, "#B79AD0", None, extra='opacity="0.6"')
        for yy in ys:
            s += ell(x, yy, 9, 6, ["#8E6CC4", "#D98BA6", "#E3B93C"][i], None, extra='opacity="0.75"')
    s += rect(160, 360, 300, 330, 10, "url(#glass)", "#AFC3B8", 3)
    s += rect(148, 344, 324, 20, 6, "url(#glass)", "#AFC3B8", 3)
    # kapillyarlar
    s += rect(486, 620, 44, 60, 10, "#F2F5F3", "#C3CCC6", 2)
    for k in range(3):
        s += line(496 + k * 10, 570 + k * 6, 500 + k * 10, 650, "#C9D7DC", 3)
    # UB lampa (254 nm) shtativda va rivojlantirilgan plastina
    s += rect(1010, 330, 16, 372, 6, "url(#metal)", "#8E9B94", 2)
    s += rect(960, 676, 120, 26, 8, "#DDE5DF", LINE, 2)
    s += rect(640, 334, 386, 18, 6, "#C9D2CC", None)
    s += rect(650, 352, 340, 60, 14, "#4C5853", "#2E3330", 2)
    s += rect(670, 408, 300, 12, 4, UV, None)
    s += path("M670 420 L620 690 H1020 L970 420 Z", UV, None, 0, extra='opacity="0.10"')
    s += path("M640 690 L668 566 H952 L980 690 Z", "#8FDE7A", "#6FB07F", 2)
    s += line(660, 670, 962, 670, "#4C5853", 2, extra='opacity="0.6"')
    s += line(670, 588, 952, 588, "#4C5853", 1.5, extra='stroke-dasharray="5 4" opacity="0.5"')
    for i, ys in enumerate([[640, 616], [652, 626, 602], [634]]):
        x = 740 + i * 80
        for yy in ys:
            s += ell(x, yy, 14, 6, "#3B4A42", None, extra='opacity="0.8"')
    return s


# =========================================================================
# L25. Analitik tarozi: gravimetrik kalibrlash (pipetka, suv, termometr)
# =========================================================================
def analytical_balance():
    s = ground(600, 470)
    # suv idishi va termometr
    s += path("M150 560 H262 L256 694 Q256 702 248 702 H164 Q156 702 156 694 Z", "#F2F7F9", "#AFC3B8", 3)
    s += path("M160 610 H258 L256 694 Q256 700 248 700 H164 Q158 700 158 694 Z", "#CFE3EC", None, 0, extra='opacity="0.9"')
    s += line(232, 470, 232, 680, "#AEB9B3", 4) + ell(232, 682, 5, 5, "#D9604F")
    s += rect(280, 620, 80, 82, 12, "#F4F7F5", LINE, 3) + rect(292, 634, 56, 30, 5, "url(#dark)", None)
    s += rect(298, 644, 32, 7, 3, "#8FC9A0", None)
    s += path("M320 620 Q 320 470 232 470", stroke="#5F6B65", sw=3)
    # tarozi asosi va displey
    s += rect(390, 560, 440, 142, 20, "url(#bodyH)")
    s += rect(420, 600, 190, 56, 8, "url(#dark)", None)
    s += rect(434, 614, 110, 12, 4, "#8FC9A0", None) + rect(434, 634, 70, 7, 3, "#5E8C7E", None)
    for i in range(4):
        s += rect(636 + i * 44, 612, 34, 30, 7, "#FFFFFF", "#C3CCC6", 2)
    s += ell(420, 704, 16, 5, "#8E9B94") + ell(800, 704, 16, 5, "#8E9B94")
    # shamoldan himoya qutisi (shisha), ichida tarozi pallasi va idish
    s += rect(424, 300, 372, 262, 10, "#F7FAF9", None, extra='opacity="0.6"')
    s += line(610, 540, 610, 520, "#8E9B94", 6)
    s += ell(610, 520, 70, 12, "url(#metal)", "#8E9B94", 2)
    s += path("M580 516 L586 452 H634 L640 516 Z", "#F2F7F9", "#AFC3B8", 2)
    s += path("M583 516 L586 488 H634 L637 516 Z", "#CFE3EC", None, 0)
    s += rect(576, 444, 68, 10, 3, "#E4EAE6", "#AFC3B8", 1.5)
    s += rect(424, 300, 372, 262, 10, "url(#glass)", "#AFC3B8", 3)
    s += line(424, 300, 796, 300, "#AFC3B8", 8)
    s += rect(560, 292, 120, 12, 4, "#E4EAE6", "#AFC3B8", 2)
    # pipetka (havo siljitishli): tugma, korpus, uchlik va tomchi
    s += rect(596, 96, 28, 24, 6, "#9AA6A0", None)
    s += rect(588, 118, 44, 170, 18, "url(#bodyH)")
    s += rect(600, 160, 20, 40, 5, "url(#dark)", None)
    s += rect(602, 288, 16, 30, 4, "#C9D2CC", "#AFC3B8", 1.5)
    s += path("M602 318 H618 L612 420 H608 Z", "#F6F8F6", "#AFC3B8", 2)
    s += path("M610 426 q-5 9 0 13 q5 -4 0 -13 Z", "#9CC3EC", None, 0)
    return s


# nom: (funksiya, tepa y, masshtab) — chizma tik markazlanadi va kartani to'ldiradi.
SCENES = {
    "chemistry": (chemistry, 220, 1.0),
    "photometer": (photometer, 178, 1.2),
    "hematology5": (hematology5, 156, 1.15),
    "hematology3": (hematology3, 188, 1.2),
    "immunoassay": (immunoassay, 202, 1.0),
    "urine_strip": (urine_strip, 202, 1.1),
    "urine_system": (urine_system, 210, 1.0),
    # Yo'nalish kartalari (lab_cards) — apparat sinfi chizmalari.
    "mass_spec_gc": (mass_spec_gc, 196, 1.0),
    "mass_spec_lc": (mass_spec_lc, 128, 0.98),
    "maldi_tof": (maldi_tof, 214, 1.0),
    "microbial_id_ast": (microbial_id_ast, 228, 1.0),
    "blood_culture": (blood_culture, 198, 1.0),
    "mycobacterial_culture": (mycobacterial_culture, 214, 1.0),
    "flow_cytometer": (flow_cytometer, 226, 1.0),
    "real_time_pcr": (real_time_pcr, 188, 1.0),
    "cartridge_molecular": (cartridge_molecular, 250, 1.05),
    "coag_analyzer": (coag_analyzer, 224, 1.0),
    "elisa_reader": (elisa_reader, 394, 1.05),
    "bsc_class2": (bsc_class2, 50, 1.0),
    "autoclave": (autoclave, 258, 1.1),
    "blood_gas_ise": (blood_gas_ise, 206, 1.15),
    "hba1c_analyzer": (hba1c_analyzer, 214, 1.05),
    "lab_fridge": (lab_fridge, 110, 1.0),
    "fluorescence_microscope": (fluorescence_microscope, 140, 1.0),
    "casa": (casa, 80, 1.0),
    "gel_card_system": (gel_card_system, 262, 1.0),
    "esr_analyzer": (esr_analyzer, 236, 1.05),
    "aggregometer": (aggregometer, 230, 1.0),
    "electrophoresis": (electrophoresis, 470, 1.05),
    "osmometer": (osmometer, 228, 1.15),
    "tlc": (tlc, 330, 1.1),
    "analytical_balance": (analytical_balance, 96, 1.0),
}


def framed(fn, top, k):
    ty = 395 - k * (top + GROUND) / 2
    return f'<g transform="translate({600 * (1 - k):g},{ty:g}) scale({k:g})">{fn()}</g>'


# Raqamli belgilar (egasi talabi 2026-10-25): sahnadagi qism joyida doiracha
# va raqam; ilovadagi “Qismlari va ishlash prinsipi” ro'yxati shu tartibda.
# O'lcham masshtabdan mustaqil (1200 px kanvasda): 390 px telefonda doiracha
# ~16 px, raqam ~10 px. Rasmdagi yagona matn — shu guruhdagi raqamlar
# (test/guards/lab_card_schematic_guard_test.dart tekshiradi).
CALLOUT_R = 28
CALLOUT_FS = 34
CALLOUT_FILL = "#1B5E50"


def callouts(name, top, k):
    ty = 395 - k * (top + GROUND) / 2
    tx = 600 * (1 - k)

    def at(pt):
        return tx + k * pt[0], ty + k * pt[1]

    s = ('<g id="callouts" font-family="Inter, Arial, sans-serif" font-weight="700" '
         'text-anchor="middle">')
    for n, part in enumerate(PARTS[name]["parts"], 1):
        mx, my = at(part["m"])
        s += f'<g class="callout" data-n="{n}">'
        if part["a"] is not None:
            ax, ay = at(part["a"])
            d = math.hypot(ax - mx, ay - my)
            if d > CALLOUT_R:
                ex, ey = mx + (ax - mx) * CALLOUT_R / d, my + (ay - my) * CALLOUT_R / d
                s += line(ex, ey, ax, ay, "#FFFFFF", 8)
                s += line(ex, ey, ax, ay, CALLOUT_FILL, 3.5)
            s += ell(ax, ay, 6.5, 6.5, CALLOUT_FILL, "#FFFFFF", 2.5)
        s += ell(mx, my, CALLOUT_R, CALLOUT_R, CALLOUT_FILL, "#FFFFFF", 4)
        s += (f'<text x="{mx:.1f}" y="{my + CALLOUT_FS * 0.36:.1f}" font-size="{CALLOUT_FS}" '
              f'fill="#FFFFFF">{n}</text>')
        s += "</g>"
    return s + "</g>"


if __name__ == "__main__":
    assert set(PARTS) == set(SCENES), set(PARTS) ^ set(SCENES)
    for name, (fn, top, k) in SCENES.items():
        body = framed(fn, top, k) + callouts(name, top, k)
        (HERE / f"{name}.svg").write_text(svg(body), encoding="utf-8")
        print("svg", name, len(PARTS[name]["parts"]))
