#!/usr/bin/env python3
"""R1/R2/R3 (va A3 asos) uchun raqamli tekshiruv.

Kirish: render_refined.mjs yaratgan previews/*.png
Chiqish: metrics/refined_metrics.json va metrics/refined_metrics.md

O‘lchovlar:
 (i)  Android safe zone: icon-1024 da (100-grid = 108dp qatlam) navy fondan
      farq qiladigan glif piksellarining markaziy 66/108 doiradan tashqaridagi ulushi.
 (ii) 32 px: siluet (mono-small, alpha ≥ 128) va app icon (icon-small, fondan
      farq) bo‘yicha ink qoplami (%), 8-bog‘lanishli komponentlar soni,
      yopiq «counter»lar (teshiklar) soni.
 (iii) Ko‘zgu asimmetriyasi: siluet-1024 ni glifning bbox markazi bo‘yicha
      gorizontal aks ettirib, 1 − IoU (0 = to‘liq simmetrik, «A»/tog‘ xavfi yuqori).
Ishga tushirish: python3 design/logo/refined/tools/measure_refined.py
"""
import json
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PREV = ROOT / "previews"
OUT = ROOT / "metrics"
VARIANTS = ["A3-nested-peaks", "R1-tailing-peak", "R2-integrated-peak", "R3-resolved-doublet"]
NAVY = np.array([0x0F, 0x1E, 0x3D], dtype=float)


def load(name):
    return np.asarray(Image.open(PREV / name).convert("RGBA")).astype(float)


def fg_icon(a, thr=48.0):
    """App icon’da navy fondan farq qiladigan (glif) piksellar."""
    d = np.sqrt(((a[..., :3] - NAVY) ** 2).sum(-1))
    return (d > thr) & (a[..., 3] > 127)


def fg_sil(a):
    return a[..., 3] >= 128


def components(mask, conn=8):
    h, w = mask.shape
    seen = np.zeros_like(mask, dtype=bool)
    nb = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)] if conn == 8 else \
         [(-1, 0), (1, 0), (0, -1), (0, 1)]
    comps = []
    for y in range(h):
        for x in range(w):
            if mask[y, x] and not seen[y, x]:
                q = deque([(y, x)]); seen[y, x] = True; pix = []
                while q:
                    cy, cx = q.popleft(); pix.append((cy, cx))
                    for dy, dx in nb:
                        ny, nx = cy + dy, cx + dx
                        if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not seen[ny, nx]:
                            seen[ny, nx] = True; q.append((ny, nx))
                comps.append(pix)
    return comps


def holes(mask):
    """Yopiq fon sohalari (4-bog‘lanish), chegaraga tegmaydiganlar."""
    h, w = mask.shape
    n = 0
    for c in components(~mask, conn=4):
        if not any(y in (0, h - 1) or x in (0, w - 1) for y, x in c):
            n += 1
    return n


def outside_safe(mask):
    h, w = mask.shape
    yy, xx = np.mgrid[0:h, 0:w]
    cx, cy = (w - 1) / 2, (h - 1) / 2
    r = w * 33.0 / 108.0
    out = ((xx - cx) ** 2 + (yy - cy) ** 2) > r * r
    total = int(mask.sum())
    o = int((mask & out).sum())
    # glifning eng uzoq nuqtasi (100-grid birligida)
    ys, xs = np.nonzero(mask)
    rmax = float(np.sqrt((xs - cx) ** 2 + (ys - cy) ** 2).max()) / w * 100
    return dict(glyph_px=total, outside_px=o, outside_pct=round(100 * o / total, 3),
                max_radius_grid=round(rmax, 2), safe_radius_grid=round(100 * 33 / 108, 2))


def asym(mask):
    ys, xs = np.nonzero(mask)
    x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
    crop = mask[y0:y1 + 1, x0:x1 + 1]
    mir = crop[:, ::-1]
    iou = (crop & mir).sum() / (crop | mir).sum()
    full_mir = mask[:, ::-1]
    iou_c = (mask & full_mir).sum() / (mask | full_mir).sum()
    return dict(asymmetry_bbox=round(1 - float(iou), 3), asymmetry_canvas=round(1 - float(iou_c), 3))


def small_stats(mask):
    comps = components(mask)
    sizes = sorted((len(c) for c in comps), reverse=True)
    ys, xs = np.nonzero(mask)
    bbox_area = (xs.max() - xs.min() + 1) * (ys.max() - ys.min() + 1)
    return dict(ink_coverage_pct=round(100 * mask.mean(), 1),
                ink_in_bbox_pct=round(100 * mask.sum() / bbox_area, 1),
                bbox_px=[int(xs.max() - xs.min() + 1), int(ys.max() - ys.min() + 1)],
                components=len(comps), component_sizes=sizes, tiny_components_le3px=sum(s <= 3 for s in sizes),
                enclosed_counters=holes(mask))


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    res = {}
    for v in VARIANTS:
        res[v] = {
            "safe_zone_icon_1024": outside_safe(fg_icon(load(f"{v}-icon-1024.png"))),
            "safe_zone_icon_small_64_info": outside_safe(fg_icon(load(f"{v}-icon-64.png"))),
            "silhouette_32": small_stats(fg_sil(load(f"{v}-silhouette-32.png"))),
            "icon_32": small_stats(fg_icon(load(f"{v}-icon-32.png"))),
            "mirror": asym(fg_sil(load(f"{v}-silhouette-1024.png"))),
            "mirror_small_64": asym(fg_sil(load(f"{v}-silhouette-64.png"))),
        }
    (OUT / "refined_metrics.json").write_text(json.dumps(res, indent=2, ensure_ascii=False))

    lines = ["# Raqamli tekshiruv natijalari (avtomatik yaratilgan)", "",
             "Manba: `tools/measure_refined.py`. Xom ma’lumot: `refined_metrics.json`.", "",
             "| Variant | Safe zonadan tashqarida (icon, %) | Glif maks. radiusi / safe r (100-grid) "
             "| 32px siluet: ink % | 32px siluet: komponent | 32px siluet: counter | 32px icon: komponent "
             "| Asimmetriya 1024 (bbox, 1−IoU) | Asimmetriya small-64 |",
             "|---|---|---|---|---|---|---|---|---|"]
    for v, r in res.items():
        sz, s32, i32, m = r["safe_zone_icon_1024"], r["silhouette_32"], r["icon_32"], r["mirror"]
        lines.append(f"| {v} | {sz['outside_pct']} | {sz['max_radius_grid']} / {sz['safe_radius_grid']} "
                     f"| {s32['ink_coverage_pct']} | {s32['components']} | {s32['enclosed_counters']} "
                     f"| {i32['components']} | {m['asymmetry_bbox']} | {r['mirror_small_64']['asymmetry_bbox']} |")
    (OUT / "refined_metrics.md").write_text("\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
