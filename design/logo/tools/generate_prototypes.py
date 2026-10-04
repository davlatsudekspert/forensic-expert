#!/usr/bin/env python3
"""FORENSIC EXPERT — «Ridge Spectrum» logo prototiplari generatori.

PROTOTIP — yakuniy logo EMAS. Egasining tasdig‘isiz qulflanmaydi.

Har bir variant uchun SVG yaratadi:
  <id>-icon.svg        app icon (navy fon, oq chiziqlar, teal accent)
  <id>-light.svg       oq fonda navy belgi
  <id>-dark.svg        qorong‘i fonda oq belgi
  <id>-mono.svg        bir rangli (qora), shaffof fon
  <id>-icon-small.svg  32–64 px uchun optik soddalashtirilgan versiya
Koordinatalar 100×100 grid’da.
"""
from pathlib import Path

NAVY = "#0F1E3D"
WHITE = "#FFFFFF"
TEAL_ON_NAVY = "#4CC9D6"
TEAL_ON_LIGHT = "#0A6F7A"
INK = "#0B1220"

OUT = Path(__file__).resolve().parents[1] / "prototypes"


def bell(cx, base, w, h, k1=0.42, k2=0.30):
    """Simmetrik «peak» (qo‘ng‘iroq shakli) — xromatografik cho‘qqi."""
    return (f"M {cx-w:.2f} {base:.2f} "
            f"C {cx-w*k1:.2f} {base:.2f}, {cx-w*k2:.2f} {base-h:.2f}, {cx:.2f} {base-h:.2f} "
            f"C {cx+w*k2:.2f} {base-h:.2f}, {cx+w*k1:.2f} {base:.2f}, {cx+w:.2f} {base:.2f}")


def arch(cx, base, r):
    return f"M {cx-r:.2f} {base:.2f} A {r:.2f} {r:.2f} 0 0 1 {cx+r:.2f} {base:.2f}"


# --- Variant ta’riflari: (ridge_paths, accent_paths, stroke) -----------------

def v_a1(small=False):
    """A1 «Loop & Spectrum»: chapda ochiq ridge yoylari, o‘ngda spektr cho‘qqilari,
    umumiy bazaviy chiziq — dalil (iz) → o‘lchov (spektr)."""
    base = 70
    radii = [11, 22] if small else [8, 16, 24]
    sw = 7.5 if small else 5.0
    cx = 36 if not small else 34
    ridges = [arch(cx, base, r) for r in radii]
    ridges.append(f"M 10 {base} L 90 {base}")
    if small:
        peaks = (f"M 58 {base} L 66 {base-34} L 74 {base} M 76 {base} L 81 {base-18} L 86 {base}")
    else:
        peaks = (f"M 61 {base} L 66.5 {base-38} L 72 {base} "
                 f"M 74 {base} L 78 {base-22} L 82 {base} "
                 f"M 83.5 {base} L 86 {base-11} L 88.5 {base}")
    return ridges, [peaks], sw


def v_a2(small=False):
    """A2 «Ridge Core Peak»: konsentrik ridge arkalar, markazida bitta o‘tkir
    analitik cho‘qqi; tashqi arkada barmoq izidagi kabi uzilish (ridge ending)."""
    base = 74
    sw = 8.0 if small else 5.5
    if small:
        ridges = [arch(50, base, 30)]
        peak = f"M 38 {base} L 50 {base-26} L 62 {base}"
    else:
        outer = (f"M 16 {base} A 34 34 0 0 1 72 {base-26.5}")  # uzilgan tashqi ridge
        ridges = [outer, arch(50, base, 24)]
        peak = f"M 40 {base} L 50 {base-21} L 60 {base}"
    ridges.append(f"M 10 {base} L 90 {base}")
    return ridges, [peak], sw


def v_a3(small=False):
    """A3 «Nested Peaks»: ichma-ich joylashgan xromatografik cho‘qqilar —
    bir vaqtda barmoq izi ridge halqasi va spektr cho‘qqisi sifatida o‘qiladi.
    Eng ichki (o‘tkir) cho‘qqi — accent."""
    base = 76
    sw = 8.0 if small else 5.0
    if small:
        ridges = [bell(50, base, 38, 50)]
        accent = [bell(50, base, 16, 32, 0.30, 0.18)]
    else:
        ridges = [bell(50, base, 40, 52), bell(50, base, 28, 41)]
        accent = [bell(50, base, 15, 29, 0.30, 0.16)]
    ridges.append(f"M 8 {base} L 92 {base}")
    return ridges, accent, sw


VARIANTS = {
    "A1-loop-spectrum": v_a1,
    "A2-ridge-core-peak": v_a2,
    "A3-nested-peaks": v_a3,
}


def svg(paths_main, paths_accent, sw, main, accent, bg=None, rounded=False, size=100):
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="{size}" height="{size}">']
    if bg:
        r = 22 if rounded else 0
        parts.append(f'<rect width="100" height="100" rx="{r}" fill="{bg}"/>')
    common = f'fill="none" stroke-width="{sw}" stroke-linecap="butt" stroke-linejoin="miter" stroke-miterlimit="10"'
    for p in paths_main:
        parts.append(f'<path d="{p}" stroke="{main}" {common}/>')
    for p in paths_accent:
        parts.append(f'<path d="{p}" stroke="{accent}" {common}/>')
    parts.append("</svg>")
    return "\n".join(parts) + "\n"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for vid, fn in VARIANTS.items():
        r, a, sw = fn()
        rs, as_, sws = fn(small=True)
        (OUT / f"{vid}-icon.svg").write_text(svg(r, a, sw, WHITE, TEAL_ON_NAVY, bg=NAVY))
        (OUT / f"{vid}-icon-small.svg").write_text(svg(rs, as_, sws, WHITE, TEAL_ON_NAVY, bg=NAVY))
        (OUT / f"{vid}-light.svg").write_text(svg(r, a, sw, NAVY, TEAL_ON_LIGHT))
        (OUT / f"{vid}-dark.svg").write_text(svg(r, a, sw, WHITE, TEAL_ON_NAVY, bg="#0A101C"))
        (OUT / f"{vid}-mono.svg").write_text(svg(r, a, sw, INK, INK))
        (OUT / f"{vid}-mono-small.svg").write_text(svg(rs, as_, sws, INK, INK))
    print("written to", OUT)


if __name__ == "__main__":
    main()
