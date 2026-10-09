#!/usr/bin/env python3
"""Toksikologik kimyo terminlari (uz → ru/en) — content/pilot/bundle.json.

Manba: «Toksikologik kimyo» o‘quv-uslubiy majmuasi (prof. Yuldashev Z.A.,
Umarova G.Q., TFI 2025; muallif ruxsati bilan, barcha uchun bepul) —
ma’ruzalar va glossariy (276–283-b.). Faqat terminlar (ta’riflar ko‘chirilmaydi).
Barcha tarjimalar `machine_draft` (FE040; tekshiruvdan o‘tmagan).

Idempotent: `T-TOKS-*` yozuvlarini qayta yozadi, boshqalariga tegmaydi.
Ishga tushirish (repo ildizida):
    python3 content/tools/toks_terms.py && tool/update_bundled_pack.sh
"""
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[2]
BUNDLE = ROOT / "content/pilot/bundle.json"

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


def main() -> None:
    raw = BUNDLE.read_text(encoding="utf-8")
    bundle = json.loads(raw)
    keep = [t for t in bundle.get("term_translations", []) if not t["term_id"].startswith("T-TOKS-")]
    new = [
        {
            "term_id": f"T-TOKS-{tid.upper()}",
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


if __name__ == "__main__":
    main()
