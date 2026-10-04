#!/usr/bin/env python3
"""FORENSIC EXPERT — A3 «Nested Peaks» asosidagi 3 ta TAKOMILLASHTIRILGAN variant.

PROTOTIP — yakuniy logo EMAS. Egasining tasdig‘isiz qulflanmaydi.

Variantlar:
  R1-tailing-peak      asimmetrik «tailing» xromatografik cho‘qqi + integrallangan
                       maydon (accent) + to‘rtta burchak «dalil/aniqlik» qavslari
  R2-integrated-peak   cho‘qqi konturi + qisman bo‘yalgan integrallash oynasi +
                       retention-time belgisi + chapga cho‘zilgan bazaviy chiziq
  R3-resolved-doublet  balandligi har xil, qisman ustma-ust tushgan ikki cho‘qqi
                       (ikki moddaning ajralishi) + ochiq aylana ramka

Har variant uchun (100×100 grid) SVG:
  <id>-icon.svg        app icon (navy fon, oq chiziq, teal accent), glif Android
                       xavfsiz doirasi (66/108) ichida
  <id>-icon-small.svg  ≤64 px uchun optik soddalashtirilgan, kattaroq glif
  <id>-light.svg       shaffof/oq fon uchun navy + #0A6F7A
  <id>-dark.svg        qorong‘i fonda oq + #4CC9D6
  <id>-mono.svg        bir rangli ink #0B1220, shaffof fon
  <id>-mono-small.svg  ≤64 px mono

Glif «dizayn koordinatalari»da chiziladi: (50,50) markazli r=46 doira ichida.
So‘ng har bir chiqish turi uchun markaz atrofida masshtablanadi.
"""
import math
from pathlib import Path

NAVY = "#0F1E3D"
WHITE = "#FFFFFF"
TEAL_ON_NAVY = "#4CC9D6"
TEAL_ON_LIGHT = "#0A6F7A"
INK = "#0B1220"
DARK_BG = "#0A101C"

OUT = Path(__file__).resolve().parents[1] / "svg"

GLYPH_R = 46.0          # dizayn koordinatalaridagi glif doirasi radiusi
# Har bir chiqish turida glif doirasining yakuniy radiusi (100-grid birligida).
# Android adaptive: 100-grid = 108dp qatlam, xavfsiz doira r = 33/108*100 = 30.56.
R_FINAL = {
    "icon": 28.0,        # xavfsiz doiradan ~2.5 birlik zaxira
    "icon-small": 38.0,  # favicon / ≤64 px: kattaroq glif (adaptive uchun EMAS)
    "plain": 44.0,       # light / dark / mono
    "plain-small": 46.0,
}


# --- Geometriya yordamchilari ------------------------------------------------

def emg(x, mu, sigma, tau):
    """Exponentially Modified Gaussian — real xromatografik cho‘qqi shakli
    (tik old qism, uzun «tailing» dum)."""
    lam = 1.0 / tau
    a = lam / 2.0 * (2 * mu + lam * sigma * sigma - 2 * x)
    b = (mu + lam * sigma * sigma - x) / (math.sqrt(2) * sigma)
    return math.exp(a) * math.erfc(b) if a < 700 else 0.0


def peak_pts(x0, x1, base, height, mu, sigma, tau, n=90):
    """x0..x1 oralig‘ida bazaviy chiziqqa tushadigan EMG cho‘qqi nuqtalari."""
    xs = [x0 + (x1 - x0) * i / (n - 1) for i in range(n)]
    ys = [emg(x, mu, sigma, tau) for x in xs]
    y0, y1 = ys[0], ys[-1]
    ys = [y - (y0 + (y1 - y0) * i / (n - 1)) for i, y in enumerate(ys)]
    m = max(ys)
    return [(x, base - height * max(y, 0) / m) for x, y in zip(xs, ys)]


def apex(pts):
    return min(pts, key=lambda p: p[1])


def poly(pts, close=False):
    d = "M " + " L ".join(f"{x:.2f} {y:.2f}" for x, y in pts)
    return d + (" Z" if close else "")


def area_under(pts, base, xa=None, xb=None):
    """Cho‘qqi ostidagi (xa..xb oralig‘idagi) yopiq maydon."""
    sel = [p for p in pts if (xa is None or p[0] >= xa) and (xb is None or p[0] <= xb)]
    return poly([(sel[0][0], base)] + sel + [(sel[-1][0], base)], close=True)


def bracket(cx, cy, s, arm, corner):
    """Burchak qavsi (L shakl). corner: 'tl','tr','bl','br'."""
    sx = -1 if corner[1] == "l" else 1
    sy = -1 if corner[0] == "t" else 1
    x, y = cx + sx * s, cy + sy * s
    return f"M {x:.2f} {y - sy*arm:.2f} L {x:.2f} {y:.2f} L {x - sx*arm:.2f} {y:.2f}"


def arc_path(cx, cy, r, a0, a1):
    """a0 dan a1 gacha (gradus, soat strelkasi bo‘yicha, 0 = o‘ng) yoy."""
    p0 = (cx + r * math.cos(math.radians(a0)), cy + r * math.sin(math.radians(a0)))
    p1 = (cx + r * math.cos(math.radians(a1)), cy + r * math.sin(math.radians(a1)))
    large = 1 if (a1 - a0) % 360 > 180 else 0
    return f"M {p0[0]:.2f} {p0[1]:.2f} A {r} {r} 0 {large} 1 {p1[0]:.2f} {p1[1]:.2f}"


# Element: dict(kind='stroke'|'fill', d=..., role='main'|'accent', sw=..., cap=...)
# fill uchun knock: maydon bilan kontur orasida bo‘shliq qoldirish uchun
# (mask) chiziqlar ro‘yxati va bo‘shliq kengligi.

def S(d, sw, role="main", cap="butt"):
    return dict(kind="stroke", d=d, sw=sw, role=role, cap=cap)


def F(d, role="accent", knock=(), gap=0.0):
    return dict(kind="fill", d=d, role=role, knock=list(knock), gap=gap)


# --- Variantlar ---------------------------------------------------------------

def v_r1(small=False):
    """R1 «Tailing Peak»: asimmetrik EMG cho‘qqi (tik old qism, uzun dum),
    ostidagi integrallangan maydon accent bilan to‘ldirilgan, to‘rt burchakda
    dalil/aniqlik qavslari. Cho‘qqi past va keng — «A»/tog‘ emas."""
    sw = 9.0 if small else 6.5
    # ≤64 px: qavslar tashqariroq, bazaviy chiziq yuqoriroq — 32 px da qavslar
    # cho‘qqiga yopishib qolmasligi uchun (icon-small adaptive uchun emas).
    s = (32.5 if not small else 35.0) - sw / 2           # qavs markazdan masofa
    arm = 8.0 if small else 10.0
    base = 68.0 if not small else 64.0
    x0, x1 = (21.0, 82.0) if not small else (28.5, 71.0)
    pts = peak_pts(x0, x1, base, 36 if not small else 32,
                   mu=33.0 if not small else 35.5, sigma=4.6 if not small else 3.6,
                   tau=20.0 if not small else 17.0)
    curve = poly(pts)
    baseline = f"M {x0 - (2 if not small else 0):.2f} {base} L {x1 + (1 if not small else 0):.2f} {base}"
    gap = 2.6
    knock = [] if small else [curve, baseline]   # ≤64 px: maydon konturga yopishadi (yaxlit siluet)
    els = [F(area_under(pts, base), knock=knock, gap=sw + 2 * gap)]
    els += [S(bracket(50, 50, s, arm, c), sw, cap="square") for c in ("tl", "tr", "bl", "br")]
    els += [S(curve, sw, cap="round"), S(baseline, sw)]
    return els


def v_r2(small=False):
    """R2 «Integrated Peak»: tailing kontur + qisman integrallash maydoni
    (cho‘qqi boshidan tushirish chizig‘igacha), tushirish chizig‘i bazaviy
    chiziqdan pastga chiqib retention/integration belgisi bo‘ladi; bazaviy
    chiziq chapga uzaygan, chap uchida «injection» belgisi. Kompozitsiya
    markazdan o‘ngga siljigan."""
    sw = 9.5 if small else 6.5
    base = 66.0 if not small else 70.0
    x0, x1 = (32.0, 92.0) if not small else (28.0, 92.0)
    pts = peak_pts(x0, x1, base, 42 if not small else 50,
                   mu=43.0, sigma=5.2 if not small else 5.8, tau=14.0)
    ax, ay = apex(pts)
    curve = poly(pts)
    bl_left = 8.0
    baseline = f"M {bl_left} {base} L {x1:.2f} {base}"
    drop = ax + (19.0 if not small else 18.0)            # integrallash oynasi oxiri
    dy = min(pts, key=lambda p: abs(p[0] - drop))[1]
    gap = 3.4 if small else 2.6
    tick = 7.0 if small else 6.0
    drop_d = f"M {drop:.2f} {dy:.2f} L {drop:.2f} {base + tick}"
    knock = [] if small else [curve, baseline, drop_d]   # ≤64 px: yaxlit maydon
    els = [F(area_under(pts, base, None, drop), knock=knock, gap=sw + 2 * gap)]
    els += [S(curve, sw, cap="round"), S(baseline, sw), S(drop_d, sw * 0.8, role="accent")]
    if not small:
        els += [S(f"M {bl_left + 4} {base} L {bl_left + 4} {base - 8}", sw * 0.8)]
    return els


def v_r3(small=False):
    """R3 «Resolved Doublet»: ikki modda — baland keng (oq kontur) va past
    (teal to‘ldirilgan) — qisman ustma-ust, lekin ajralgan; ochiq aylana ramka
    (uzilish o‘ng-yuqorida)."""
    sw = 9.0 if small else 6.0
    base = 64.0 if not small else 65.0
    ring_r = 46.0 - sw / 2
    big = peak_pts(13, 64, base, 38 if not small else 40, mu=28, sigma=5.4 if not small else 6.0, tau=9.0)
    sm = peak_pts(42, 86, base, 28 if not small else 31, mu=55, sigma=4.6 if not small else 5.2, tau=9.0)
    big_d, sm_d = poly(big), poly(sm)
    baseline = f"M 9 {base} L 91 {base}"
    gap = 2.4
    knock = [] if small else [big_d, baseline]
    els = [F(area_under(sm, base), knock=knock, gap=sw + 2 * gap)]
    els += [S(arc_path(50, 50, ring_r, 0 if not small else -5, 250), sw, cap="round"),
            S(big_d, sw, cap="round"), S(baseline, sw)]
    if not small:
        els += [S(sm_d, sw * 0.55, role="accent", cap="round")]
    return els


VARIANTS = {
    "R1-tailing-peak": v_r1,
    "R2-integrated-peak": v_r2,
    "R3-resolved-doublet": v_r3,
}


# --- SVG yig‘uvchi ------------------------------------------------------------

def svg(els, main, accent, r_final, bg=None, uid="g", size=100):
    k = r_final / GLYPH_R
    tf = f"translate(50 50) scale({k:.5f}) translate(-50 -50)"
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="{size}" height="{size}">']
    defs = []
    body = []
    for i, e in enumerate(els):
        color = main if e["role"] == "main" else accent
        if e["kind"] == "stroke":
            body.append(f'<path d="{e["d"]}" fill="none" stroke="{color}" stroke-width="{e["sw"]}" '
                        f'stroke-linecap="{e["cap"]}" stroke-linejoin="round"/>')
        else:
            mid = f"{uid}-m{i}"
            knock = "".join(f'<path d="{d}" fill="none" stroke="#000" stroke-width="{e["gap"]}" '
                            f'stroke-linejoin="round" stroke-linecap="round"/>' for d in e["knock"])
            defs.append(f'<mask id="{mid}" maskUnits="userSpaceOnUse" x="-50" y="-50" width="200" height="200">'
                        f'<rect x="-50" y="-50" width="200" height="200" fill="#fff"/>{knock}</mask>')
            body.append(f'<path d="{e["d"]}" fill="{color}" mask="url(#{mid})"/>')
    if defs:
        out.append("<defs>" + "".join(defs) + "</defs>")
    if bg:
        out.append(f'<rect width="100" height="100" fill="{bg}"/>')
    out.append(f'<g transform="{tf}">')
    out += body
    out.append("</g></svg>")
    return "\n".join(out) + "\n"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for vid, fn in VARIANTS.items():
        big, sm = fn(), fn(small=True)
        files = {
            "icon": svg(big, WHITE, TEAL_ON_NAVY, R_FINAL["icon"], bg=NAVY, uid=vid + "i"),
            "icon-small": svg(sm, WHITE, TEAL_ON_NAVY, R_FINAL["icon-small"], bg=NAVY, uid=vid + "is"),
            "light": svg(big, NAVY, TEAL_ON_LIGHT, R_FINAL["plain"], uid=vid + "l"),
            "dark": svg(big, WHITE, TEAL_ON_NAVY, R_FINAL["plain"], bg=DARK_BG, uid=vid + "d"),
            "mono": svg(big, INK, INK, R_FINAL["plain"], uid=vid + "m"),
            "mono-small": svg(sm, INK, INK, R_FINAL["plain-small"], uid=vid + "ms"),
        }
        for kind, text in files.items():
            (OUT / f"{vid}-{kind}.svg").write_text(text)
    print("written to", OUT)


if __name__ == "__main__":
    main()
