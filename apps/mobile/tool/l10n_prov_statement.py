#!/usr/bin/env python3
"""«Bu ma'lumot qayerdan?» oynasida da'voning o'z matni uchun yorliq (uz/ru/en).

Oynada da'vo matni umuman ko'rinmasdi: iqtibosi bo'lmagan (o'z so'zimiz bilan
yozilgan) da'vo uchun «iqtibos ko'rsatilmaydi» deb chiqardi. Endi matnning
o'zi ko'rsatiladi, va u manbadan so'zma-so'z olinmagani aytiladi.
"""
import json, pathlib
ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"
KEYS = {
  "provOwnWordsNote": {
    "uz": "Manbadagi mazmun o‘z so‘zlarimiz bilan berilgan; asl matn ko‘chirilmagan. Aniq joyi quyida.",
    "ru": "Содержание источника изложено своими словами; оригинальный текст не копировался. Точное место — ниже.",
    "en": "The content of the source is given in our own words; the original text is not copied. The exact place is below."},
}
DESC = {"provOwnWordsNote": "Note under a claim written in our own words, shown in the provenance sheet."}
for lang in ("uz", "ru", "en"):
    p = ARB / f"app_{lang}.arb"
    d = json.loads(p.read_text(encoding="utf-8"))
    for k, v in KEYS.items():
        d.setdefault(k, v[lang])
        if lang == "en":
            d.setdefault("@" + k, {"description": DESC[k]})
    p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("ok")
