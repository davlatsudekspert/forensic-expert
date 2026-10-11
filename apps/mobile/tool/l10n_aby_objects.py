#!/usr/bin/env python3
"""ABY yozuvlaridagi «Ob'ekt» maydoni uchun matnlar (uz/ru/en).

Ekspert xulosa yozayotganda birinchi savol — qaysi ob'ektdan. ABY matnida
aytilgan ob'ekt endi alohida qator bo'lib ko'rsatiladi; aytilmagan bo'lsa
shu ham ochiq yoziladi (taxmin qilinmaydi).
"""
import json
import pathlib

ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"

KEYS = {
    "abyObjectLabel": {
        "uz": "Ob’ekt",
        "ru": "Объект",
        "en": "Specimen",
    },
    "abyObjectNotStated": {
        "uz": "ABY matnida ob’ekt ko‘rsatilmagan",
        "ru": "В тексте ABY объект не указан",
        "en": "The ABY text does not name a specimen",
    },
    "abyObjBlood": {"uz": "qon", "ru": "кровь", "en": "blood"},
    "abyObjUrine": {"uz": "siydik", "ru": "моча", "en": "urine"},
    "abyObjLiver": {"uz": "jigar", "ru": "печень", "en": "liver"},
    "abyObjGastric": {
        "uz": "me’da ichidagi massa",
        "ru": "содержимое желудка",
        "en": "gastric contents",
    },
    "abyObjKidney": {"uz": "buyrak", "ru": "почка", "en": "kidney"},
    "abyObjLung": {"uz": "o‘pka", "ru": "лёгкое", "en": "lung"},
    "abyObjHair": {"uz": "soch", "ru": "волосы", "en": "hair"},
    "abyObjBrain": {"uz": "miya", "ru": "головной мозг", "en": "brain"},
    "abyObjMuscle": {"uz": "mushak", "ru": "мышца", "en": "muscle"},
    "abyObjBile": {"uz": "o‘t", "ru": "жёлчь", "en": "bile"},
    "abyObjIntestine": {"uz": "ichak", "ru": "кишечник", "en": "intestine"},
    "abyObjTrachea": {"uz": "traxeya", "ru": "трахея", "en": "trachea"},
    "abyObjPlasma": {"uz": "plazma", "ru": "плазма", "en": "plasma"},
    "abyObjSerum": {"uz": "zardob", "ru": "сыворотка", "en": "serum"},
    "abyObjSaliva": {"uz": "so‘lak", "ru": "слюна", "en": "saliva"},
    "abyObjSemen": {"uz": "sperma", "ru": "сперма", "en": "semen"},
    "abyObjFaeces": {"uz": "najas", "ru": "кал", "en": "faeces"},
    "abyObjVomit": {
        "uz": "qusuq massasi",
        "ru": "рвотные массы",
        "en": "vomit",
    },
    "abyObjOrgans": {
        "uz": "ichki a’zolar",
        "ru": "внутренние органы",
        "en": "internal organs",
    },
}


def main() -> None:
    for lang in ("uz", "ru", "en"):
        p = ARB / f"app_{lang}.arb"
        d = json.loads(p.read_text(encoding="utf-8"))
        added = 0
        for key, vals in KEYS.items():
            if key not in d:
                d[key] = vals[lang]
                added += 1
        p.write_text(
            json.dumps(d, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"{lang}: +{added}")


if __name__ == "__main__":
    main()
