#!/usr/bin/env python3
"""Toksikologik kimyo terminlari (uz → ru/en) — content/pilot/bundle.json.

Manba: «Toksikologik kimyo» o‘quv-uslubiy majmuasi (prof. Yuldashev Z.A.,
Umarova G.Q., TFI 2025; muallif ruxsati bilan, barcha uchun bepul) —
ma’ruzalar va glossariy (276–283-b.). Faqat terminlar (ta’riflar ko‘chirilmaydi).
Barcha tarjimalar `machine_draft` (FE040; tekshiruvdan o‘tmagan).

Atama → yo‘riqnoma kartasi bog‘lanishi ANIQ ([CARD_TERMS], matndan taxmin
qilinmaydi): har bir toks kartasining `src/card_*.json` fayliga `term_ids`
qatori yoziladi (ilovadagi «Atamalar» bo‘limi va «Ilmiy lug‘at» shu
ro‘yxatdan foydalanadi).

Idempotent: `T-TOKS-*` yozuvlarini va kartalardagi `term_ids` qatorini qayta
yozadi, boshqalariga tegmaydi.
Ishga tushirish (repo ildizida):
    python3 content/tools/toks_terms.py && tool/update_bundled_pack.sh
    python3 content/guidelines/build.py && python3 content/guidelines/validate.py
    python3 content/guidelines/sync_app_asset.py
"""
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[2]
BUNDLE = ROOT / "content/pilot/bundle.json"
CARDS = ROOT / "content/guidelines/src"

# (id, uz, ru, en)
TERMS = [
    ("steam-distillation", "suv bug‘i bilan haydash", "перегонка с водяным паром", "steam distillation"),
    ("distillate", "distillyat", "дистиллят", "distillate"),
    ("mineralization", "mineralizatsiya", "минерализация", "mineralization"),
    ("mineralizate", "mineralizat", "минерализат", "mineralizate (digest)"),
    ("denitration", "denitratsiya", "денитрация", "denitration"),
    ("destruction", "destruksiya", "деструкция", "destruction (partial digestion)"),
    ("fractional-method", "kasrli usul", "дробный метод", "fractional method"),
    ("masking", "niqoblash", "маскирование", "masking"),
    ("dialysis", "dializ", "диализ", "dialysis"),
    ("extraction", "ekstraksiya", "экстракция", "extraction"),
    ("extractant", "ekstragent", "экстрагент", "extractant"),
    ("back-extraction", "qayta ekstraksiya", "реэкстракция", "back-extraction"),
    ("partition-coefficient", "taqsimlanish koeffitsienti", "коэффициент распределения", "partition coefficient"),
    ("salting-out", "tuzlash (tuzlovchi elektrolit)", "высаливание", "salting-out"),
    ("azeotrope", "azeotrop aralashma", "азеотропная смесь", "azeotrope"),
    ("acidified-water-method", "nordonlashtirilgan suv usuli", "метод подкисленной воды", "acidified-water method"),
    ("stas-otto-method", "nordonlashtirilgan spirt (Stas–Otto) usuli", "метод подкисленного спирта (Стаса–Отто)", "acidified-alcohol (Stas–Otto) method"),
    ("volatile-poisons", "uchuvchi zaharlar", "летучие яды", "volatile poisons"),
    ("metal-poisons", "metall zaharlar", "металлические яды", "metal poisons"),
    ("marsh-test", "Marsh reaksiyasi", "реакция Марша", "Marsh test"),
    ("sanger-black-test", "Zanger–Blek reaksiyasi", "реакция Зангер–Блека", "Sanger–Black test"),
    ("prussian-blue", "Berlin zangorisi", "берлинская лазурь", "Prussian blue"),
    ("isocyanide-test", "izonitril reaksiyasi", "изонитрильная проба", "isocyanide (carbylamine) test"),
    ("fujiwara-reaction", "Fujivara reaksiyasi", "реакция Фудживары", "Fujiwara reaction"),
    ("fuchsin-sulfurous-acid", "fuksin-sulfit kislota", "фуксинсернистая кислота", "fuchsin-sulfurous acid (Schiff reagent)"),
    ("dithizone", "ditizon", "дитизон", "dithizone"),
    ("diethyldithiocarbamate", "dietilditiokarbamat", "диэтилдитиокарбамат", "diethyldithiocarbamate"),
    ("cholinesterase", "xolinesteraza", "холинэстераза", "cholinesterase"),
    ("organophosphorus", "fosfororganik birikmalar", "фосфорорганические соединения", "organophosphorus compounds"),
    ("organochlorine", "xlororganik birikmalar", "хлорорганические соединения", "organochlorine compounds"),
    ("synthetic-pyrethroids", "sintetik piretroidlar", "синтетические пиретроиды", "synthetic pyrethroids"),
    ("molybdenum-blue", "fosfor-molibden ko‘ki", "фосфорномолибденовая синь", "molybdenum blue"),
    ("negative-value-reaction", "manfiy ahamiyatli reaksiya", "реакция отрицательного значения", "reaction of negative (exclusionary) value"),
    ("microcrystal-test", "mikrokristalloskopik reaksiya", "микрокристаллоскопическая реакция", "microcrystal test"),
    ("xenobiotic", "ksenobiotik", "ксенобиотик", "xenobiotic"),
    ("cumulation", "kumulyatsiya", "кумуляция", "cumulation"),
    ("potentiation", "potensiyalanish (sinergizm)", "потенцирование (синергизм)", "potentiation (synergy)"),
    ("physical-evidence", "ashyoviy dalil", "вещественное доказательство", "physical evidence (exhibit)"),
]

# Karta (guideline.chem.toks_*) → unda ishlatilgan atamalar (TERMS dagi id).
# Umumiy atamalar (ksenobiotik, kumulyatsiya, potensiyalanish) hech qaysi
# kartaga bog‘lanmagan — ular faqat lug‘atda.
CARD_TERMS = {
    "guideline.chem.toks_isolation": [
        "steam-distillation", "distillate", "mineralization", "dialysis",
        "extraction", "extractant", "back-extraction", "partition-coefficient",
        "salting-out", "azeotrope", "acidified-water-method", "stas-otto-method",
        "volatile-poisons",
    ],
    "guideline.chem.toks_mineralization": [
        "mineralization", "mineralizate", "denitration", "destruction",
        "fractional-method", "masking", "back-extraction", "dithizone",
        "diethyldithiocarbamate", "metal-poisons",
    ],
    "guideline.chem.toks_metal_poisons": [
        "metal-poisons", "mineralization", "mineralizate", "destruction",
        "fractional-method", "masking", "marsh-test", "sanger-black-test",
        "dithizone", "diethyldithiocarbamate", "negative-value-reaction",
        "microcrystal-test",
    ],
    "guideline.chem.toks_volatile_poisons": [
        "volatile-poisons", "steam-distillation", "distillate", "azeotrope",
        "prussian-blue", "isocyanide-test", "fujiwara-reaction",
        "fuchsin-sulfurous-acid", "negative-value-reaction",
    ],
    "guideline.chem.toks_pesticides": [
        "organophosphorus", "organochlorine", "synthetic-pyrethroids",
        "cholinesterase", "molybdenum-blue", "extraction", "salting-out",
        "microcrystal-test", "negative-value-reaction", "physical-evidence",
    ],
}

_TERM_LINE = re.compile(r'^  "term_ids": \[[^\]]*\],\n', re.M)
_ANCHOR = re.compile(r'^  "related_tool_ids": \[[^\]]*\],\n', re.M)


def term_id(short: str) -> str:
    return f"T-TOKS-{short.upper()}"


def write_card_terms() -> int:
    """`term_ids` qatorini kartaning src fayliga yozadi (qo‘lda formatlangan
    JSON — faqat bitta qator almashtiriladi)."""
    known = {tid for tid, *_ in TERMS}
    done = 0
    for path in sorted(CARDS.glob("card_*.json")):
        raw = path.read_text(encoding="utf-8")
        cid = json.loads(raw)["id"]
        if cid not in CARD_TERMS:
            continue
        shorts = CARD_TERMS[cid]
        assert len(set(shorts)) == len(shorts), cid
        for t in shorts:
            assert t in known, (cid, t)
        line = '  "term_ids": [' + ", ".join(f'"{term_id(t)}"' for t in shorts) + "],\n"
        text = _TERM_LINE.sub("", raw)
        m = _ANCHOR.search(text)
        assert m, f"{path.name}: related_tool_ids qatori topilmadi"
        text = text[: m.end()] + line + text[m.end():]
        json.loads(text)  # buzilmaganini tekshirish
        if text != raw:
            path.write_text(text, encoding="utf-8")
        done += 1
    assert done == len(CARD_TERMS), "kartalar topilmadi"
    return done


def main() -> None:
    raw = BUNDLE.read_text(encoding="utf-8")
    bundle = json.loads(raw)
    keep = [t for t in bundle.get("term_translations", []) if not t["term_id"].startswith("T-TOKS-")]
    new = [
        {
            "term_id": term_id(tid),
            "kind": "term",
            "original": uz,
            "original_lang": "uz",
            "canonical": en,
            "localized": {"en": en, "ru": ru, "uz": uz},
            "status": {"en": "machine_draft", "ru": "machine_draft", "uz": "machine_draft"},
        }
        for tid, uz, ru, en in TERMS
    ]
    assert len({t["term_id"] for t in new}) == len(new)
    for t in new:
        for bad in ("o'", "g'", "oʻ", "gʻ"):
            assert bad not in t["original"], t["term_id"]
    bundle["term_translations"] = keep + new
    tail = "\n" if raw.endswith("\n") else ""
    BUNDLE.write_text(json.dumps(bundle, ensure_ascii=False, indent=2) + tail, encoding="utf-8")
    print(f"term_translations: {len(keep)} kept + {len(new)} T-TOKS-*")
    print(f"guideline cards: term_ids written to {write_card_terms()} cards")


if __name__ == "__main__":
    main()
