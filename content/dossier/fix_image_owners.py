#!/usr/bin/env python3
"""Tashqi (real o'lchov) rasmlarni o'zi ko'rsatayotgan moddaga biriktirish.

Muammo: rasm `method-*` yozuviga biriktirilgani uchun usul kartasi QAYSI
moddadan ochilsa ham o'sha rasm chiqardi — fenazepam kartasida nasha (THC,
CBD, CBN) plastinkasi ko'rinardi. Ilova uni «Misol: boshqa modda» deb
belgilasa ham, bu noto'g'ri: ekspert benzodiazepin o'qiyotganda kannabinoid
plastinkasini ko'rmasligi kerak.

Yechim: har bir rasm o'zi ko'rsatayotgan moddaga o'tadi. Shunda u KERAKLI
joyda chiqadi va keraksiz joydan yo'qoladi. Usul kartasida umumiy sxema
(`schematic`) qoladi — u har qanday modda uchun to'g'ri.

Moddasi bazada yo'q rasm (5-MAPB) olib tashlanmaydi, lekin usul kartasida
ham qoldirilmaydi: u `pending_substance` deb belgilanadi va hech qayerda
ko'rsatilmaydi, modda qo'shilganda biriktiriladi.

Skript idempotent.
"""
import json
import sys
from pathlib import Path

BUNDLE = Path(__file__).resolve().parents[2] / "content/pilot/bundle.json"

# rasm → haqiqatda qaysi moddani ko'rsatadi
MOVE = {
    # THC, CBD, CBN, CBG, THCA, CBDA standartlari silikagel va Ag(I)-TLC da
    "IMG-EXT-pmc9558087-ac2c01627_0004": "thc",
    # Siydikdagi THC-COOH, LLE/GC-MS
    "IMG-EXT-pmc11480513-gr2": "thc-cooh",
    # Marquis va nitrat kislota reaktivlarida ksilazin yolg'on musbat beradi
    "IMG-EXT-pmc12713473-ao5c07057_0002": "xylazine",
}

# Moddasi hali bazada yo'q — ko'rsatilmaydi (5-MAPB).
PARK = {
    "IMG-EXT-pmc6445230-ienz_a_1333987_f0003_c": "5-MAPB",
    "IMG-EXT-pmc6445230-ienz_a_1333987_f0004_b": "5-MAPB",
}


def main() -> int:
    b = json.loads(BUNDLE.read_text())
    subs = {s["substance_id"] for s in b["substances"]}
    moved, parked = 0, 0
    for im in b["images"]:
        iid = im["image_id"]
        if iid in MOVE:
            target = MOVE[iid]
            if target not in subs:
                print(f"XATO: {target} moddasi bazada yo'q ({iid})")
                return 1
            if im.get("entity_id") != target:
                im["entity_id"] = target
                moved += 1
        elif iid in PARK and not im.get("pending_substance"):
            im["pending_substance"] = PARK[iid]
            parked += 1
    BUNDLE.write_text(json.dumps(b, ensure_ascii=False, indent=1) + "\n")
    print(f"rasmlar: {moved} ta moddasiga ko'chirildi, {parked} ta kutishga")
    return 0


if __name__ == "__main__":
    sys.exit(main())
