#!/usr/bin/env python3
"""Yangi logotip uchun ko‘rib chiqish (egasi tasdig‘i) to‘plami.

`generate_brand.py` yaratgan HAQIQIY resurslardan (mipmap, AppIcon,
launch_mark, assets/brand) yig‘iladi — qayta chizilmaydi:

  icon_sheet.png        — Android adaptive (doira / squircle / yumaloq
                          kvadrat) 48…192 px, iOS 60/120/180/1024, kichik
                          16/24/32, Android 13 themed (monoxrom);
  homescreen_light.png  — uy ekrani simulyatsiyasi (yorug‘ va to‘q fon
  homescreen_dark.png     rasmlarida, Android doira + iOS squircle);
  splash_*.png          — native splash simulyatsiyasi: 320×640 dp,
                          390×844 dp, 1080×2400 px, planshet 800×1280 dp
                          (yorug‘/qorong‘i) + Android 12+ tizim splash’i;
  contact_sheet.png     — bitta umumiy varaq (≤ 2000 px, o‘zbekcha yorliq).

Ilova skrinshotlari: `app/` (integration_test/qa_brand_test.dart).
Ishga tushirish: python3 design/brand/tools/preview_brand.py
"""
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[3]
APP = ROOT / "apps" / "mobile"
RES = APP / "android" / "app" / "src" / "main" / "res"
IOS = APP / "ios" / "Runner" / "Assets.xcassets"
OUT = ROOT / "docs" / "brand" / "logo_preview_20261009"
FONTS = APP / "assets" / "fonts"

IVORY = (0xF7, 0xF5, 0xEF)
GRAPHITE = (0x0B, 0x10, 0x17)
INK = (0x16, 0x1B, 0x22)
MUTED = (0x52, 0x5A, 0x66)
GOLD = (0x7D, 0x5F, 0x27)


def font(size, bold=False, serif=False):
    if serif:
        f = FONTS / "source_serif_4" / ("SourceSerif4-SemiBold.ttf" if bold else "SourceSerif4-Regular.ttf")
    else:
        f = FONTS / "inter" / ("Inter-SemiBold.ttf" if bold else "Inter-Regular.ttf")
    return ImageFont.truetype(str(f), size)


def rgba(p):
    return Image.open(p).convert("RGBA")


def ss_mask(px, shape):
    """Launcher niqoblari (4× supersampling)."""
    s = px * 4
    m = Image.new("L", (s, s), 0)
    d = ImageDraw.Draw(m)
    if shape == "circle":
        d.ellipse([0, 0, s - 1, s - 1], fill=255)
    elif shape == "rounded":
        d.rounded_rectangle([0, 0, s - 1, s - 1], radius=s * 0.18, fill=255)
    elif shape in ("squircle", "ios"):
        # Superellips (iOS «continuous corners» ga yaqin).
        n = 5.0 if shape == "squircle" else 4.6
        pts = []
        for i in range(720):
            t = 2 * math.pi * i / 720
            c, si = math.cos(t), math.sin(t)
            x = abs(c) ** (2 / n) * (1 if c >= 0 else -1)
            y = abs(si) ** (2 / n) * (1 if si >= 0 else -1)
            pts.append(((x + 1) / 2 * (s - 1), (y + 1) / 2 * (s - 1)))
        d.polygon(pts, fill=255)
    return m.resize((px, px), Image.LANCZOS)


def adaptive(px, shape, mono=False, tint=None):
    """Adaptive ikon: 108dp qatlamlardan markaziy 72dp ko‘rinadigan qism."""
    fg = rgba(RES / "mipmap-xxxhdpi" / ("ic_launcher_monochrome.png" if mono else "ic_launcher_foreground.png"))
    if mono:
        # Android 13 themed: och fon + to‘q tint (tizim palitrasi taqlidi).
        bg = Image.new("RGBA", fg.size, tint[0] + (255,))
        col = Image.new("RGBA", fg.size, tint[1] + (255,))
        layer = Image.composite(col, Image.new("RGBA", fg.size, (0, 0, 0, 0)), fg.getchannel("A"))
        bg.alpha_composite(layer)
    else:
        bg = rgba(RES / "mipmap-xxxhdpi" / "ic_launcher_background.png")
        bg.alpha_composite(fg)
    w = bg.width
    cut = round(w * 18 / 108)
    vis = bg.crop((cut, cut, w - cut, w - cut))
    vis = vis.convert("RGBa").resize((px, px), Image.LANCZOS).convert("RGBA")
    vis.putalpha(ss_mask(px, shape))
    return vis


def ios_icon(px):
    # Har o‘lcham uchun haqiqiy (teng yoki kattaroq) AppIcon fayli.
    f = {60: "Icon-App-20x20@3x.png", 120: "Icon-App-60x60@2x.png", 180: "Icon-App-60x60@3x.png",
         1024: "Icon-App-1024x1024@1x.png", 16: "Icon-App-20x20@1x.png", 24: "Icon-App-29x29@1x.png",
         32: "Icon-App-40x40@1x.png", 40: "Icon-App-40x40@1x.png", 58: "Icon-App-29x29@2x.png"}
    p = IOS / "AppIcon.appiconset" / f.get(px, "Icon-App-1024x1024@1x.png")
    im = rgba(p)
    if im.width != px:
        im = im.convert("RGBa").resize((px, px), Image.LANCZOS).convert("RGBA")
    im.putalpha(ss_mask(px, "ios"))
    return im


def label(d, xy, text, size=18, fill=INK, bold=False, anchor="la", serif=False):
    d.text(xy, text, font=font(size, bold, serif), fill=fill, anchor=anchor)


def shadow(canvas, im, xy, blur=6, alpha=70):
    a = im.getchannel("A").point(lambda v: v * alpha // 255)
    sh = Image.new("RGBA", (im.width + 4 * blur, im.height + 4 * blur), (0, 0, 0, 0))
    sh.paste(Image.new("RGBA", im.size, (0, 0, 0, 255)), (2 * blur, 2 * blur), a)
    sh = sh.filter(ImageFilter.GaussianBlur(blur))
    canvas.alpha_composite(sh, (xy[0] - 2 * blur, xy[1] - 2 * blur + blur // 2))
    canvas.alpha_composite(im, xy)


# ---------------------------------------------------------------- icon sheet

def icon_sheet():
    W = 1900
    sheet = Image.new("RGBA", (W, 1560), IVORY + (255,))
    d = ImageDraw.Draw(sheet)
    label(d, (40, 30), "Ilova belgisi — oldindan ko‘rish (tasdiqlanmagan)", 34, bold=True, serif=True)
    label(d, (40, 78), "Faqat markaziy emblema (qalqon), mayda matnsiz. Navy fon, oltin hoshiya.", 18, MUTED)
    y = 130
    sizes = [48, 72, 96, 144, 192]
    for shape, name in (("circle", "Android — doira"), ("squircle", "Android — squircle"),
                        ("rounded", "Android — yumaloq kvadrat")):
        label(d, (40, y + 8), name, 20, bold=True)
        x = 380
        for s in sizes:
            ic = adaptive(s, shape)
            shadow(sheet, ic, (x, y + (192 - s) // 2))
            label(d, (x + s // 2, y + 200), f"{s} px", 14, MUTED, anchor="ma")
            x += s + 60
        y += 240
    label(d, (40, y + 8), "iOS (alpha yo‘q)", 20, bold=True)
    x = 380
    for s in (60, 120, 180):
        ic = ios_icon(s)
        shadow(sheet, ic, (x, y + (192 - s) // 2))
        label(d, (x + s // 2, y + 200), f"{s} px", 14, MUTED, anchor="ma")
        x += s + 60
    big = ios_icon(1024).resize((300, 300), Image.LANCZOS)
    shadow(sheet, big, (x + 20, y - 40))
    label(d, (x + 170, y + 270), "1024 px (App Store, kichraytirilgan)", 14, MUTED, anchor="ma")
    y += 330
    label(d, (40, y + 8), "Kichik: 16 / 24 / 32 px", 20, bold=True)
    label(d, (40, y + 36), "soddalashtirilgan: qalqon + tayoq/ilon", 15, MUTED)
    x = 380
    for s in (16, 24, 32):
        for bg in (IVORY, GRAPHITE):
            tile = Image.new("RGBA", (90, 90), bg + (255,))
            ic = ios_icon(s)  # ≤ 48 px AppIcon — soddalashtirilgan variant
            tile.alpha_composite(ic, ((90 - s) // 2, (90 - s) // 2))
            sheet.alpha_composite(tile, (x, y))
            x += 100
        label(d, (x - 105, y + 100), f"{s} px", 14, MUTED, anchor="ma")
        x += 30
    # Kattalashtirilgan (piksel ko‘rinishi) 16/24/32.
    for s in (16, 24, 32):
        ic = ios_icon(s)  # ≤ 48 px AppIcon — soddalashtirilgan variant
        z = ic.resize((s * 4, s * 4), Image.NEAREST)
        sheet.alpha_composite(z, (x, y + (128 - s * 4) // 2 if s * 4 < 128 else y))
        x += s * 4 + 20
    label(d, (x - 120, y + 140), "×4 piksel", 14, MUTED, anchor="ma")
    y += 190
    label(d, (40, y + 8), "Android 13 themed", 20, bold=True)
    label(d, (40, y + 36), "monoxrom siluet", 15, MUTED)
    x = 380
    for tint in (((0xD8, 0xE2, 0xF4), (0x1B, 0x2B, 0x48)), ((0x2B, 0x33, 0x40), (0xD6, 0xE0, 0xF0)),
                 ((0xF2, 0xE4, 0xC8), (0x4A, 0x38, 0x10))):
        for s in (72, 144):
            ic = adaptive(s, "circle", mono=True, tint=tint)
            shadow(sheet, ic, (x, y + (144 - s) // 2))
            x += s + 40
        x += 30
    sheet = sheet.crop((0, 0, W, y + 190))
    sheet.convert("RGB").save(OUT / "icon_sheet.png", optimize=True)
    return sheet


# ---------------------------------------------------------- home screen

def homescreen(dark):
    W, H = 900, 1000
    top = (0x1C, 0x24, 0x33) if dark else (0xE9, 0xE4, 0xD6)
    bot = (0x05, 0x08, 0x0D) if dark else (0xBF, 0xCB, 0xD9)
    img = Image.new("RGBA", (W, H))
    px = img.load()
    for yy in range(H):
        t = yy / H
        c = tuple(round(top[i] * (1 - t) + bot[i] * t) for i in range(3))
        for xx in range(W):
            px[xx, yy] = c + (255,)
    d = ImageDraw.Draw(img)
    fg = (0xF4, 0xF4, 0xF1) if dark else (0x16, 0x1B, 0x22)
    label(d, (W // 2, 30), "Qorong‘i fon rasmi" if dark else "Yorug‘ fon rasmi", 26, fg, True, "ma")
    # Boshqa ilovalar o‘rnida neytral «placeholder» ikonlar.
    others = [(0x3D, 0x7B, 0xD8), (0x2E, 0xA0, 0x6B), (0xE0, 0x5A, 0x47), (0x8E, 0x6B, 0xD9),
              (0xF2, 0xA6, 0x2B), (0x4B, 0x55, 0x63), (0x14, 0xA3, 0xB8), (0xD6, 0x48, 0x8F)]
    for col, (shape, title) in enumerate((("circle", "Android"), ("ios", "iOS"))):
        x0 = 40 + col * 440
        label(d, (x0 + 200, 80), title, 20, fg, True, "ma")
        s = 96
        k = 0
        for r in range(4):
            for c in range(3):
                x = x0 + 20 + c * 130
                y = 130 + r * 200
                if r == 1 and c == 1:
                    ic = adaptive(s, "circle") if shape == "circle" else ios_icon(180).resize((s, s), Image.LANCZOS)
                    name = "Forensic Expert"
                else:
                    ic = Image.new("RGBA", (s, s), others[k % len(others)] + (255,))
                    ic.putalpha(ss_mask(s, "circle" if shape == "circle" else "ios"))
                    name = ["Xarita", "Pochta", "Kamera", "Musiqa", "Soat", "Sozlamalar",
                            "Ob-havo", "Galereya", "Kalendar", "Fayllar", "Telefon"][k % 11]
                    k += 1
                shadow(img, ic, (x, y), blur=5, alpha=90)
                label(d, (x + s // 2, y + s + 12), name, 15, fg, anchor="ma")
    img = img.crop((0, 0, W, 930))
    img.convert("RGB").save(OUT / f"homescreen_{'dark' if dark else 'light'}.png", optimize=True)
    return img


# ---------------------------------------------------------------- splash

def launch_mark(density, dark):
    return rgba(RES / f"drawable-{'night-' if dark else ''}{density}" / "launch_mark.png")


def splash(w_px, h_px, scale, density, dark):
    bg = GRAPHITE if dark else IVORY
    img = Image.new("RGBA", (w_px, h_px), bg + (255,))
    m = launch_mark(density, dark)
    dens = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}[density]
    if abs(dens - scale) > 1e-3:  # Android tanlangan zichlikni ekranga moslab kichraytiradi
        f = scale / dens
        m = m.convert("RGBa").resize((round(m.width * f), round(m.height * f)), Image.LANCZOS).convert("RGBA")
    img.alpha_composite(m, ((w_px - m.width) // 2, (h_px - m.height) // 2))
    return img


def splash_v31(w_px, h_px, scale, dark):
    """Android 12+ tizim splash’i: 240dp ikon (160dp doira ko‘rinadi)."""
    bg = GRAPHITE if dark else IVORY
    img = Image.new("RGBA", (w_px, h_px), bg + (255,))
    s = round(160 * scale)
    ic = adaptive(s, "circle")
    img.alpha_composite(ic, ((w_px - s) // 2, (h_px - s) // 2))
    return img


def splashes():
    cases = [
        ("320x640dp", 640, 1280, 2, "xhdpi"),
        ("390x844dp", 1170, 2532, 3, "xxhdpi"),
        ("1080x2400px", 1080, 2400, 2.625, "xxhdpi"),
        ("planshet_800x1280dp", 1600, 2560, 2, "xhdpi"),
    ]
    out = {}
    for name, w, h, sc, den in cases:
        for dark in (False, True):
            im = splash(w, h, sc, den, dark)
            fn = f"splash_{name}_{'dark' if dark else 'light'}.png"
            im.convert("RGB").save(OUT / fn, optimize=True)
            out[(name, dark)] = im
    for dark in (False, True):
        im = splash_v31(1170, 2532, 3, dark)
        im.convert("RGB").save(OUT / f"splash_android12_{'dark' if dark else 'light'}.png", optimize=True)
        out[("android12", dark)] = im
    return out


# ---------------------------------------------------------- contact sheet

def phone(img, w):
    """Telefon ramkasi (yumaloq burchak + nozik chegara)."""
    h = round(img.height * w / img.width)
    im = img.convert("RGBa").resize((w, h), Image.LANCZOS).convert("RGBA")
    r = max(10, w // 14)
    mask = Image.new("L", (w * 2, h * 2), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w * 2 - 1, h * 2 - 1], radius=r * 2, fill=255)
    im.putalpha(mask.resize((w, h), Image.LANCZOS))
    frame = Image.new("RGBA", (w + 8, h + 8), (0, 0, 0, 0))
    fm = Image.new("L", ((w + 8) * 2, (h + 8) * 2), 0)
    ImageDraw.Draw(fm).rounded_rectangle([0, 0, (w + 8) * 2 - 1, (h + 8) * 2 - 1], radius=(r + 4) * 2, fill=255)
    frame.paste(Image.new("RGBA", frame.size, (0x2A, 0x2F, 0x38, 255)), (0, 0), fm.resize(frame.size, Image.LANCZOS))
    frame.alpha_composite(im, (4, 4))
    return frame


def contact(icon, splash_imgs):
    appdir = OUT / "app"
    W = 1900
    pw = 300  # telefon kengligi
    sheet = Image.new("RGBA", (W, 6000), (0xFF, 0xFF, 0xFF, 255))
    d = ImageDraw.Draw(sheet)
    label(d, (W // 2, 36), "FORENSIC EXPERT — yangi logotip (tasdiq uchun)", 44, INK, True, "ma", serif=True)
    label(d, (W // 2, 100), "Ilova ichidagi ko‘rinish: haqiqiy ilova skrinshotlari (Linux, MOCK hisob). "
          "Belgi va splash — haqiqiy resurslardan simulyatsiya.", 20, MUTED, anchor="ma")
    y = 160

    def section(title, sub=None):
        nonlocal y
        d.rectangle([40, y, W - 40, y + 2], fill=(0xD9, 0xC9, 0xA3))
        label(d, (40, y + 18), title, 34, INK, True, serif=True)
        if sub:
            label(d, (40, y + 66), sub, 18, MUTED)
        y += 110 if sub else 80

    # 1) Ilova belgisi
    section("Ilova belgisi", "Android (doira, squircle, yumaloq kvadrat), iOS; uy ekrani — yorug‘ va qorong‘i fon")
    x = 60
    for shape in ("circle", "squircle", "rounded"):
        ic = adaptive(192, shape)
        shadow(sheet, ic, (x, y + 20))
        x += 230
    ic = ios_icon(180)
    shadow(sheet, ic, (x, y + 26))
    x += 230
    for s in (48, 32, 24, 16):
        ic = ios_icon(s)  # ≤ 48 px AppIcon — soddalashtirilgan variant
        sheet.alpha_composite(ic, (x, y + 116 - s // 2))
        label(d, (x + s // 2, y + 190), f"{s}", 14, MUTED, anchor="ma")
        x += s + 30
    hs_l = Image.open(OUT / "homescreen_light.png").convert("RGBA")
    hs_d = Image.open(OUT / "homescreen_dark.png").convert("RGBA")
    hs_w = 420
    for i, hs in enumerate((hs_l, hs_d)):
        t = hs.resize((hs_w, round(hs.height * hs_w / hs.width)), Image.LANCZOS)
        sheet.alpha_composite(t, (W - 40 - (2 - i) * (hs_w + 20), y))
    y += max(260, round(hs_l.height * hs_w / hs_l.width)) + 40

    # 2) Splash
    section("Splash", "Native ishga tushish ekrani: 320×640 dp, 390×844 dp, 1080×2400 px, planshet; "
            "chapda — Yorug‘ rejim, o‘ngda — Qorong‘i rejim")
    x = 60
    row_h = 0
    for dark in (False, True):
        for name in ("320x640dp", "390x844dp", "1080x2400px", "planshet_800x1280dp"):
            im = splash_imgs[(name, dark)]
            w = 170 if "planshet" not in name else 230
            f = phone(im, w)
            sheet.alpha_composite(f, (x, y + 30))
            label(d, (x + f.width // 2, y + 36 + f.height), name.replace("_", " "), 13, MUTED, anchor="ma")
            row_h = max(row_h, f.height)
            x += f.width + 22
        x += 8
    label(d, (60, y), "Yorug‘ rejim", 22, INK, True)
    label(d, (60 + 3 * 192 + 252 + 30, y), "Qorong‘i rejim", 22, INK, True)
    y += row_h + 90

    # 3–5) Ilova ekranlari: Yorug‘ | Qorong‘i, 390 va 320 dp
    # Skrinshotlar brendga tegishli yuqori qismigacha kesiladi (dp).
    crop_dp = {"b02_login": 560, "b03_home_student": 470, "b05_admin": 360, "b01_language": 640}

    def shot(p, key):
        im = Image.open(p).convert("RGBA")
        k = im.width / (390 if "_390" in p.name else 320)
        return im.crop((0, 0, im.width, min(im.height, round(crop_dp[key] * k))))

    for key, title in (("b02_login", "Kirish sahifasi"), ("b03_home_student", "Bosh sahifa"),
                       ("b05_admin", "Admin panel")):
        section(title, "390 dp va 320 dp; chapda — Yorug‘ rejim, o‘ngda — Qorong‘i rejim")
        x = 60
        row_h = 0
        for tag, tlabel in (("light", "Yorug‘ rejim"), ("dark", "Qorong‘i rejim")):
            label(d, (x, y), tlabel, 22, INK, True)
            for wdp in (390, 320):
                p = appdir / f"{key}_{tag}_{wdp}.png"
                if not p.exists():
                    continue
                im = shot(p, key)
                f = phone(im, 390 if wdp == 390 else 320)
                sheet.alpha_composite(f, (x, y + 40))
                label(d, (x + f.width // 2, y + 46 + f.height), f"{wdp} dp", 14, MUTED, anchor="ma")
                row_h = max(row_h, f.height)
                x += f.width + 24
            x += 40
        y += row_h + 100

    # Til ekrani (katta lockup + tagline)
    section("Splash / birinchi ekran (ilova ichida)", "Til tanlash: emblema + wordmark + tagline")
    x = 60
    row_h = 0
    for tag, tlabel in (("light", "Yorug‘ rejim"), ("dark", "Qorong‘i rejim")):
        label(d, (x, y), tlabel, 22, INK, True)
        for wdp in (390, 320):
            p = appdir / f"b01_language_{tag}_{wdp}.png"
            im = shot(p, "b01_language")
            f = phone(im, 390 if wdp == 390 else 320)
            sheet.alpha_composite(f, (x, y + 40))
            label(d, (x + f.width // 2, y + 46 + f.height), f"{wdp} dp", 14, MUTED, anchor="ma")
            row_h = max(row_h, f.height)
            x += f.width + 24
        x += 40
    y += row_h + 90
    sheet = sheet.crop((0, 0, W, y))
    sheet.convert("RGB").save(OUT / "contact_sheet.png", optimize=True)
    # Telefonda ochish uchun yengil nusxa.
    sheet.convert("RGB").save(OUT / "contact_sheet.jpg", quality=88, optimize=True)
    return sheet


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    icon = icon_sheet()
    homescreen(False)
    homescreen(True)
    sp = splashes()
    cs = contact(icon, sp)
    print("contact sheet", cs.size)


if __name__ == "__main__":
    main()
