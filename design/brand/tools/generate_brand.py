#!/usr/bin/env python3
"""FORENSIC EXPERT — premium logotip assetlari generatori (2026-10-09).

Yagona manba: egasi bergan rastr logotip
`design/brand/source/logo_original.webp` (1254×1254, RGB, oq fon).
Vektor trace qilinmagan: manbada metall gradientlar va soyalar bor —
trace ularni tekislab yuborardi. Barcha assetlar yuqori aniqlikdagi
rastrdan (premultiplied alpha bilan) **faqat kichraytirib** olinadi.

Natijalar:
  * design/brand/png/ — kesilgan emblema (light/dark, full/small, mono),
    kvadrat emblema, wordmark, lockup (light/dark), app icon, o‘lcham
    sinovi;
  * apps/mobile/assets/brand/ — ilova ichidagi emblema (@1x/@2x/@3x);
  * Android: mipmap (legacy, adaptive foreground/background, monochrome),
    splash (drawable-*/launch_mark, light va night);
  * iOS: AppIcon (alpha yo‘q), LaunchImage (light + dark appearance).

Talab: `pip install pillow numpy`. Ishga tushirish (repo ildizidan):
  python3 design/brand/tools/generate_brand.py
"""
import json
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[3]
BRAND = ROOT / "design" / "brand"
SRC = BRAND / "source" / "logo_original.webp"
PNG = BRAND / "png"
APP = ROOT / "apps" / "mobile"

# Logotipdan o‘lchangan ranglar (docs/BRAND.md).
NAVY = (0x01, 0x18, 0x30)          # qalqon ichi (o‘rtacha)
NAVY_ICON_CENTER = (0x17, 0x31, 0x55)
NAVY_ICON_EDGE = (0x06, 0x12, 0x24)
NAVY_LIFT = (0x10, 0x2C, 0x52)      # to‘q fonda qalqon ichi (ko‘tarilgan)
IVORY = (0xF7, 0xF5, 0xEF)          # FePalette.light.background
GRAPHITE = (0x0B, 0x10, 0x17)       # FePalette.dark.background
TEXT_IVORY = (0xF4, 0xF4, 0xF1)     # FePalette.dark.textPrimary
TAGLINE_DARK = (0xC3, 0xC9, 0xD2)
WHITE = np.array([254.0, 254.0, 254.0])

# Manbadagi qismlar (piksel, 1254² koordinatada).
SHIELD_BOX = (330, 95, 925, 785)
WORD_FORENSIC = (110, 782, 1140, 962)
WORD_EXPERT = (110, 972, 1140, 1075)
WORD_TAGLINE = (110, 1092, 1140, 1132)


# --------------------------------------------------------------- yordamchi

def box_blur(a, r):
    """Kvadrat (2r+1) o‘rtacha filtri, 2D yoki 3D massiv (cumsum)."""
    if r <= 0:
        return a.astype(float)
    a = a.astype(float)
    pad = [(r + 1, r), (r + 1, r)] + [(0, 0)] * (a.ndim - 2)
    p = np.pad(a, pad, mode="edge")
    c = p.cumsum(0).cumsum(1)
    k = 2 * r + 1
    s = c[k:, k:] - c[:-k, k:] - c[k:, :-k] + c[:-k, :-k]
    return s / (k * k)


def morph(mask, r, op):
    img = Image.fromarray((mask * 255).astype(np.uint8))
    f = ImageFilter.MaxFilter(2 * r + 1) if op == "dilate" else ImageFilter.MinFilter(2 * r + 1)
    return np.asarray(img.filter(f)) > 127


def flood_outside(fgmask):
    """Burchaklardan fon (fg bo‘lmagan) mintaqasini to‘ldirish."""
    h, w = fgmask.shape
    out = np.zeros((h, w), bool)
    q = deque()
    for y, x in ((0, 0), (0, w - 1), (h - 1, 0), (h - 1, w - 1)):
        if not fgmask[y, x]:
            out[y, x] = True
            q.append((y, x))
    while q:
        y, x = q.popleft()
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= ny < h and 0 <= nx < w and not out[ny, nx] and not fgmask[ny, nx]:
                out[ny, nx] = True
                q.append((ny, nx))
    return out


def unmix(rgb, core, band, radius=3, fallback=None):
    """Oq fondan ajratish: chekka piksellar uchun alpha va rang.

    core — to‘liq qoplangan piksellar; band — chekka. Har chekka piksel
    uchun yaqin core ranglarining o‘rtachasi F; alpha = (p−W)·(F−W)/|F−W|².
    Rang F ga tenglanadi — oq «halo» qolmaydi.
    """
    w = box_blur(core.astype(float), radius)
    s = box_blur(rgb * core[..., None], radius)
    with np.errstate(invalid="ignore", divide="ignore"):
        F = s / w[..., None]
    nofg = w < 1e-6
    if fallback is not None:
        F[nofg] = fallback(rgb)[nofg]
    else:
        F[nofg] = rgb[nofg]
    d = F - WHITE
    a = ((rgb - WHITE) * d).sum(-1) / np.maximum((d * d).sum(-1), 1.0)
    a = np.clip(a, 0, 1)
    alpha = np.where(core, 1.0, np.where(band, a, 0.0))
    color = np.where(core[..., None], rgb, F)
    return alpha, np.clip(color, 0, 255)


def to_img(color, alpha):
    arr = np.dstack([color, alpha[..., None] * 255.0]).round().clip(0, 255).astype(np.uint8)
    return Image.fromarray(arr, "RGBA")


def bbox_of(img):
    return img.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()


def resize(img, size):
    """Premultiplied alpha bilan kichraytirish (qora/oq chekka yo‘q)."""
    if img.size == size:
        return img.copy()
    return img.convert("RGBa").resize(size, Image.LANCZOS).convert("RGBA")


def fit(img, box_w, box_h):
    """Proporsiyani saqlab (cho‘zmasdan) quti ichiga sig‘diradi."""
    s = min(box_w / img.width, box_h / img.height)
    return resize(img, (max(1, round(img.width * s)), max(1, round(img.height * s))))


def paste_center(canvas, img, cx=None, cy=None):
    cx = canvas.width / 2 if cx is None else cx
    cy = canvas.height / 2 if cy is None else cy
    canvas.alpha_composite(img, (round(cx - img.width / 2), round(cy - img.height / 2)))
    return canvas


def save(img, path, rgb=None):
    path.parent.mkdir(parents=True, exist_ok=True)
    if rgb is not None:
        base = Image.new("RGB", img.size, rgb)
        base.paste(img, mask=img.getchannel("A"))
        img = base
    img.save(path, optimize=True)


def radial_bg(px, center=NAVY_ICON_CENTER, edge=NAVY_ICON_EDGE, cy=0.42):
    yy, xx = np.mgrid[0:px, 0:px] + 0.5
    r = np.sqrt((xx / px - 0.5) ** 2 + (yy / px - cy) ** 2) / 0.75
    t = np.clip(r, 0, 1)[..., None] ** 1.2
    c = np.array(center) * (1 - t) + np.array(edge) * t
    return Image.fromarray(c.round().astype(np.uint8), "RGB").convert("RGBA")


# --------------------------------------------------------------- emblema

def cut_shield(rgb):
    x0, y0, x1, y1 = SHIELD_BOX
    c = rgb[y0:y1, x0:x1]
    diff = np.abs(c - WHITE).max(-1)
    outside = flood_outside(diff > 40)
    core = morph(~outside, 1, "erode")
    band = morph(core, 3, "dilate") & ~core
    alpha, color = unmix(c, core, band)
    img = to_img(color, alpha)
    bb = bbox_of(img)
    return img.crop(bb), (x0 + bb[0], y0 + bb[1])


def gold_components(c):
    R, B = c[..., 0], c[..., 2]
    gold = ((R - B) > 35) & (R > 110)
    h, w = gold.shape
    lab = np.zeros((h, w), np.int32)
    boxes = {}
    n = 0
    for y, x in zip(*np.nonzero(gold)):
        if lab[y, x]:
            continue
        n += 1
        lab[y, x] = n
        q = deque([(y, x)])
        bb = [x, y, x, y]
        while q:
            yy, xx = q.popleft()
            bb = [min(bb[0], xx), min(bb[1], yy), max(bb[2], xx), max(bb[3], yy)]
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    ny, nx = yy + dy, xx + dx
                    if 0 <= ny < h and 0 <= nx < w and gold[ny, nx] and not lab[ny, nx]:
                        lab[ny, nx] = n
                        q.append((ny, nx))
        boxes[n] = bb
    return gold, lab, boxes


def simplify_small(shield):
    """Kichik o‘lcham varianti: qalqon + tayoq/ilon (DNK va tarozisiz)."""
    a = np.asarray(shield).astype(float)
    c, alpha = a[..., :3], a[..., 3] / 255
    h, w = alpha.shape
    gold, lab, boxes = gold_components(c)
    border = max(boxes, key=lambda k: (boxes[k][2] - boxes[k][0]) * (boxes[k][3] - boxes[k][1]))
    keep = np.zeros_like(gold)
    for k, (bx0, by0, bx1, by1) in boxes.items():
        cx = (bx0 + bx1) / 2 / w
        head = bx0 > 0.53 * w and bx1 < 0.83 * w and by1 < 0.33 * h  # ilon boshi, tili
        if k == border or 0.37 <= cx <= 0.63 or head:
            keep |= lab == k
    R, B = c[..., 0], c[..., 2]
    lum = c.mean(-1)
    # Oltin yaltirashlari (shar, tayoq) deyarli oq — ular ham saqlanadi.
    keep |= morph(keep, 3, "dilate") & (lum > 150) & (R >= B)
    dna = (B > 75) & ((B - R) > 30) & ~gold
    # Hoshiyaning ichki faskasi (soya/yaltirash) tegilmaydi.
    interior = morph(alpha > 0.99, 4, "erode") & ~morph(lab == border, 9, "dilate")
    stuff = interior & ((lum > 45) | dna)        # navy bo‘lmagan har qanday narsa
    drop = (gold & ~keep) | dna
    # Tashlanadigan element atrofidagi yarim-ton piksellar ham olinadi.
    near = morph(drop, 6, "dilate") & stuff & ~morph(keep, 2, "dilate")
    remove = morph(drop | near, 2, "dilate") & interior & ~morph(keep, 1, "dilate")
    navy = interior & ~stuff & ~remove
    wsum = box_blur(navy.astype(float), 24)
    fill = box_blur(c * navy[..., None], 24) / np.maximum(wsum, 1e-6)[..., None]
    fill[wsum < 1e-6] = NAVY
    # Yumshoq chegara: olib tashlangan joy navy bilan bir tekis qoplanadi.
    soft = np.clip(box_blur(remove.astype(float), 1) * 1.6, 0, 1)
    out = c * (1 - soft[..., None]) + fill * soft[..., None]
    return to_img(out, alpha)


def darken_variant(img):
    """To‘q fon varianti: qalqon ichidagi navy biroz ko‘tariladi — grafit
    fonda yo‘qolib ketmaydi; oltin hoshiya va ramzlar o‘zgarmaydi."""
    a = np.asarray(img).astype(float)
    c = a[..., :3]
    lum = c.mean(-1)
    blue = (c[..., 2] - c[..., 0]) > 15
    w = np.clip(1 - (lum - 18) / 40, 0, 1) * blue
    lift = np.array(NAVY_LIFT) - np.array(NAVY)
    c = c + w[..., None] * lift
    return to_img(np.clip(c, 0, 255), a[..., 3] / 255)


def mono_variant(img):
    """Android 13 themed ikon: oltin (hoshiya + tayoq/ilon) → oq siluet."""
    a = np.asarray(img).astype(float)
    R = a[..., 0]
    alpha = np.clip((R - 40) / 110, 0, 1) * (a[..., 3] / 255)
    white = np.full(a.shape[:2] + (3,), 255.0)
    return to_img(white, alpha)


# --------------------------------------------------------------- wordmark

def ink_fallback(rgb):
    gold = (rgb[..., 0] - rgb[..., 2]) > 25
    out = np.empty_like(rgb)
    out[...] = (0x0B, 0x1B, 0x35)
    out[gold] = (0xB3, 0x93, 0x5F)
    return out


def cut_text(rgb, box):
    x0, y0, x1, y1 = box
    c = rgb[y0:y1, x0:x1]
    diff = np.abs(c - WHITE).max(-1)
    core = diff > 120
    band = (diff > 6) & ~core
    alpha, color = unmix(c, core, band, radius=2, fallback=ink_fallback)
    img = to_img(color, alpha)
    bb = bbox_of(img)
    return img.crop(bb), (x0 + bb[0], y0 + bb[1])


def recolor_text(img, navy_to, gold_to=None):
    a = np.asarray(img).astype(float)
    c = a[..., :3]
    gold = (c[..., 0] - c[..., 2]) > 25
    out = c.copy()
    out[~gold] = navy_to
    if gold_to is not None:
        out[gold] = gold_to
    return to_img(out, a[..., 3] / 255)


def lockup(shield, forensic, expert, tagline, src_offsets, tagline_on=True, width=1200):
    """Asl kompozitsiya oraliqlari saqlangan holda shaffof lockup."""
    parts = [(shield, src_offsets["shield"]), (forensic, src_offsets["forensic"]),
             (expert, src_offsets["expert"])]
    if tagline_on:
        parts.append((tagline, src_offsets["tagline"]))
    xs0 = min(o[0] for _, o in parts)
    ys0 = min(o[1] for _, o in parts)
    xs1 = max(o[0] + im.width for im, o in parts)
    ys1 = max(o[1] + im.height for im, o in parts)
    pad = 24
    canvas = Image.new("RGBA", (xs1 - xs0 + 2 * pad, ys1 - ys0 + 2 * pad), (0, 0, 0, 0))
    for im, (ox, oy) in parts:
        canvas.alpha_composite(im, (ox - xs0 + pad, oy - ys0 + pad))
    return fit(canvas, width, 10_000) if width < canvas.width else canvas


def square(img, px, scale=0.98):
    canvas = Image.new("RGBA", (px, px), (0, 0, 0, 0))
    return paste_center(canvas, fit(img, px * scale, px * scale))


# --------------------------------------------------------------- ikonlar

def app_icon(px, shield, small=None, ivory=False):
    """Kvadrat ikon (iOS 1024 va boshqalar): navy gradient + qalqon."""
    if ivory:
        bg = Image.new("RGBA", (px, px), IVORY + (255,))
    else:
        bg = radial_bg(px)
    mark = small if (small is not None and px <= 48) else shield
    h = px * 0.66
    m = fit(mark, h * mark.width / mark.height, h)
    return paste_center(bg, m, cy=px * 0.5)


def crisp(img, px):
    """≤ 64 px: yengil unsharp — kichik o‘lchamda hoshiya va tayoq aniq."""
    if px > 64:
        return img
    return img.filter(ImageFilter.UnsharpMask(radius=0.6, percent=70, threshold=0))


def icon_at(px, mark):
    bg = resize(radial_bg(min(px * 4, 1024)), (px, px))
    # ≤ 32 px: belgi biroz kattaroq — tayoq/ilon o‘qiladi.
    h = px * (0.74 if px <= 32 else 0.66)
    return crisp(paste_center(bg, fit(mark, h * mark.width / mark.height, h)), px)


def adaptive_fg(px108, shield):
    # 108dp tuval; qalqon 52dp balandlikda — 66dp xavfsiz doira ichida.
    canvas = Image.new("RGBA", (px108, px108), (0, 0, 0, 0))
    h = px108 * 52 / 108
    return paste_center(canvas, fit(shield, h * shield.width / shield.height, h))


def rounded_mask(px, radius_frac):
    m = Image.new("L", (px * 4, px * 4), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, px * 4 - 1, px * 4 - 1], radius=px * 4 * radius_frac, fill=255)
    return m.resize((px, px), Image.LANCZOS)


# --------------------------------------------------------------- asosiy

def main():
    rgb = np.asarray(Image.open(SRC).convert("RGB")).astype(float)
    PNG.mkdir(parents=True, exist_ok=True)
    for f in PNG.iterdir():
        f.unlink()

    # Kesilgan qalqon va uning manbadagi joyi (lockup oraliqlari uchun).
    shield, shield_off = cut_shield(rgb)

    small = simplify_small(shield)
    shield_dark = darken_variant(shield)
    small_dark = darken_variant(small)
    mono = mono_variant(small)

    texts = {}
    offs = {"shield": shield_off}
    for key, box in (("forensic", WORD_FORENSIC), ("expert", WORD_EXPERT), ("tagline", WORD_TAGLINE)):
        texts[key], offs[key] = cut_text(rgb, box)
    forensic_d = recolor_text(texts["forensic"], TEXT_IVORY)
    expert_d = texts["expert"]
    tagline_d = recolor_text(texts["tagline"], TAGLINE_DARK)

    # --- design/brand/png -------------------------------------------------
    save(shield, PNG / "emblem-full-light.png")
    save(shield_dark, PNG / "emblem-full-dark.png")
    save(small, PNG / "emblem-small-light.png")
    save(small_dark, PNG / "emblem-small-dark.png")
    save(mono, PNG / "emblem-mono-white.png")
    for name, im in (("full-light", shield), ("full-dark", shield_dark),
                     ("small-light", small), ("small-dark", small_dark)):
        for px in (512, 256):
            save(square(im, px), PNG / f"emblem-square-{name}-{px}.png")
    light_lock = lockup(shield, texts["forensic"], texts["expert"], texts["tagline"], offs)
    dark_lock = lockup(shield_dark, forensic_d, expert_d, tagline_d, offs)
    save(light_lock, PNG / "lockup-stacked-light.png")
    save(dark_lock, PNG / "lockup-stacked-dark.png")
    save(lockup(shield, texts["forensic"], texts["expert"], None, offs, tagline_on=False),
         PNG / "lockup-compact-light.png")
    save(lockup(shield_dark, forensic_d, expert_d, None, offs, tagline_on=False),
         PNG / "lockup-compact-dark.png")
    word_offs = {k: v for k, v in offs.items()}
    word = lockup(Image.new("RGBA", (1, 1)), texts["forensic"], texts["expert"], texts["tagline"],
                  dict(word_offs, shield=offs["forensic"]))
    save(word, PNG / "wordmark-light.png")
    save(lockup(Image.new("RGBA", (1, 1)), forensic_d, expert_d, tagline_d,
                dict(word_offs, shield=offs["forensic"])), PNG / "wordmark-dark.png")
    save(app_icon(1024, shield), PNG / "app-icon-1024.png", rgb=NAVY_ICON_EDGE)
    save(app_icon(1024, shield, ivory=True), PNG / "app-icon-alt-ivory-1024.png", rgb=IVORY)

    # O‘lcham sinovi: 16…180 px, full va small, yorug‘ va to‘q fonda.
    sizes = [16, 24, 32, 48, 64, 96, 180]
    rows = [("full", shield, IVORY), ("small", small, IVORY),
            ("full", shield_dark, GRAPHITE), ("small", small_dark, GRAPHITE)]
    sheet = Image.new("RGBA", (40 + sum(s + 40 for s in sizes), len(rows) * 220), (255, 255, 255, 255))
    dr = ImageDraw.Draw(sheet)
    for ri, (_, im, bg) in enumerate(rows):
        y0r = ri * 220
        dr.rectangle([0, y0r, sheet.width, y0r + 219], fill=bg + (255,))
        x = 40
        for s in sizes:
            sheet.alpha_composite(square(im, s), (x, y0r + (220 - s) // 2))
            x += s + 40
    save(sheet, PNG / "size-test-sheet.png", rgb=(255, 255, 255))

    # --- Flutter assets (@1x/@2x/@3x, kvadrat) -----------------------------
    assets = APP / "assets" / "brand"
    for name, im, base in (("emblem_full_light", shield, 128), ("emblem_full_dark", shield_dark, 128),
                           ("emblem_small_light", small, 40), ("emblem_small_dark", small_dark, 40)):
        for sub, k in (("", 1), ("2.0x/", 2), ("3.0x/", 3)):
            save(square(im, base * k), assets / f"{sub}{name}.png")

    # --- Android ------------------------------------------------------------
    res = APP / "android" / "app" / "src" / "main" / "res"
    dens = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    for d, f in dens.items():
        p48, p108 = round(48 * f), round(108 * f)
        legacy = icon_at(p48, small if p48 <= 48 else shield)
        legacy.putalpha(rounded_mask(p48, 0.2))
        save(legacy, res / f"mipmap-{d}" / "ic_launcher.png")
        save(adaptive_fg(p108, shield), res / f"mipmap-{d}" / "ic_launcher_foreground.png")
        save(radial_bg(p108, cy=0.47), res / f"mipmap-{d}" / "ic_launcher_background.png", rgb=NAVY_ICON_EDGE)
        save(adaptive_fg(p108, mono), res / f"mipmap-{d}" / "ic_launcher_monochrome.png")
        # Splash: 200dp kenglikdagi lockup (tagline bilan).
        w = round(200 * f)
        save(fit(light_lock, w, 10_000), res / f"drawable-{d}" / "launch_mark.png")
        save(fit(dark_lock, w, 10_000), res / f"drawable-night-{d}" / "launch_mark.png")
    old = res / "drawable-nodpi" / "launch_mark.png"
    if old.exists():
        old.unlink()
        old.parent.rmdir()

    # --- iOS ------------------------------------------------------------------
    xc = APP / "ios" / "Runner" / "Assets.xcassets"
    iconset = xc / "AppIcon.appiconset"
    for im in json.loads((iconset / "Contents.json").read_text())["images"]:
        fn = im.get("filename")
        if not fn:
            continue
        px = round(float(im["size"].split("x")[0]) * int(im["scale"].rstrip("x")))
        # ≤ 48 px (Spotlight, Settings, bildirishnoma) — soddalashtirilgan
        # variant; fon 4× o‘lchamda chiziladi, belgi bir marta kichraytiriladi.
        mark = small if px <= 48 else shield
        save(icon_at(px, mark), iconset / fn, rgb=NAVY_ICON_EDGE)
    launch = xc / "LaunchImage.imageset"
    for f in launch.glob("*.png"):
        f.unlink()
    images = []
    for k in (1, 2, 3):
        sfx = "" if k == 1 else f"@{k}x"
        save(fit(light_lock, 200 * k, 10_000), launch / f"LaunchImage{sfx}.png")
        save(fit(dark_lock, 200 * k, 10_000), launch / f"LaunchImageDark{sfx}.png")
        images.append({"idiom": "universal", "filename": f"LaunchImage{sfx}.png", "scale": f"{k}x"})
        images.append({"idiom": "universal", "filename": f"LaunchImageDark{sfx}.png", "scale": f"{k}x",
                       "appearances": [{"appearance": "luminosity", "value": "dark"}]})
    (launch / "Contents.json").write_text(json.dumps(
        {"images": images, "info": {"version": 1, "author": "xcode"}}, indent=2) + "\n")
    colorset = xc / "LaunchBackground.colorset"
    colorset.mkdir(exist_ok=True)

    def comp(c):
        return {"color-space": "srgb", "components": {
            "red": f"0x{c[0]:02X}", "green": f"0x{c[1]:02X}", "blue": f"0x{c[2]:02X}", "alpha": "1.000"}}
    (colorset / "Contents.json").write_text(json.dumps({
        "colors": [
            {"idiom": "universal", "color": comp(IVORY)},
            {"idiom": "universal", "appearances": [{"appearance": "luminosity", "value": "dark"}],
             "color": comp(GRAPHITE)},
        ],
        "info": {"version": 1, "author": "xcode"}}, indent=2) + "\n")

    print("shield", shield.size, "small", small.size, "lockup", light_lock.size, "offsets", offs)


if __name__ == "__main__":
    main()
