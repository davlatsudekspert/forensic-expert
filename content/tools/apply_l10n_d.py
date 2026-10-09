#!/usr/bin/env python3
"""Phase D localisation fixes on pilot/bundle.json (idempotent post-step).

Only EXISTING data contracts are filled (no schema change):
  * methods[].titles            — canonical abbreviations (GC-MS, LC-MS/MS, HPLC, TLC …)
  * authorities[].names         — uz / ru / en for all 6 authorities («Олий Мажлис» → «Oliy Majlis»)
  * jurisdictions[].names       — INT uz / ru
  * instruments[].titles        — uz / ru (machine_draft) for INCB lists and UK acts;
                                  UZ-LAW-813-I uz / ru are the official lex.uz names
  * instruments[].official_reference — only the official number; the editor note
                                  («consolidated text retrieved …; NEEDS LEGAL REVIEW»)
                                  moves to `internal_note` (not shipped to content.db)
  * term_translations           — PMI: owner-approved uz / ru terms
  * recipes ingredients[].names / steps[].texts — Dragendorff PMC variant (5 items)
                                  and dropped synonyms («1-naphthol», «2-naphthol», «1 L»)
  * sources[SRC-OWNER-REAGENTS].title — original Russian title only (English gloss
                                  moved to notes); bibliography stays in its original language
  * running uz/ru text of recipes, names and instrument titles through the
    canonical terminology normaliser

Verbatim originals (claim excerpts, rule excerpts, research titles, recipe
`text`/`name`) are never changed. Run from content/:
  python3 tools/apply_l10n_d.py
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from l10n_terms_normalize import normalize_text  # noqa: E402

BUNDLE = "pilot/bundle.json"

METHOD_TITLES = {
    "method-gcms": {
        "uz": "Gaz xromatografiyasi — mass-spektrometriya (GC-MS)",
        "ru": "Газовая хроматография — масс-спектрометрия (GC-MS)",
    },
    "method-gc-fid": {
        "uz": "GC-FID (alanga-ionlanish detektorli gaz xromatografiyasi)",
        "ru": "GC-FID (газовая хроматография с пламенно-ионизационным детектором)",
    },
    "method-lcmsms": {
        "uz": "LC-MS/MS (suyuqlik xromatografiyasi — tandem mass-spektrometriya)",
        "ru": "LC-MS/MS (жидкостная хроматография — тандемная масс-спектрометрия)",
    },
    "method-hplc": {
        "uz": "HPLC — yuqori samarali suyuqlik xromatografiyasi (UB / DAD / fluoressent detektor)",
        "ru": "HPLC — высокоэффективная жидкостная хроматография (УФ / DAD / флуоресцентный детектор)",
    },
    "method-tlc": {
        "uz": "Yupqa qatlamli xromatografiya (TLC)",
        "ru": "Тонкослойная хроматография (TLC)",
    },
    "method-derivatization": {
        "uz": "GC (gaz xromatografiyasi) uchun derivatizatsiya",
        "ru": "Дериватизация для GC (газовой хроматографии)",
    },
}

AUTHORITY_NAMES = {
    "AUTH-GB-PARLIAMENT": {
        "en": "Parliament of the United Kingdom",
        "ru": "Парламент Соединённого Королевства",
        "uz": "Buyuk Britaniya Parlamenti",
    },
    "AUTH-GB-MDA-1971-SCH2": {
        "en": "Parliament of the United Kingdom",
        "ru": "Парламент Соединённого Королевства",
        "uz": "Buyuk Britaniya Parlamenti",
    },
    "AUTH-GB-SCT-MINISTERS": {
        "en": "The Scottish Ministers",
        "ru": "Правительство Шотландии (The Scottish Ministers)",
        "uz": "Shotlandiya hukumati (The Scottish Ministers)",
    },
    "AUTH-US-21CFR1308": {
        "en": "Drug Enforcement Administration (DEA), U.S. Department of Justice",
        "ru": "Управление по борьбе с наркотиками (DEA), Министерство юстиции США",
        "uz": "AQSh Adliya vazirligining Giyohvand moddalarga qarshi kurash boshqarmasi (DEA)",
    },
    "AUTH-DE-BTMG-ANL": {
        "de": "Bundesministerium der Justiz (Veröffentlichung)",
        "en": "Federal Ministry of Justice of Germany (Bundesministerium der Justiz), publisher",
        "ru": "Федеральное министерство юстиции Германии (Bundesministerium der Justiz), публикация",
        "uz": "Germaniya Federal adliya vazirligi (Bundesministerium der Justiz), nashr",
    },
    "AUTH-UZ-LAW-813-I": {
        "en": "Oliy Majlis (Parliament) of the Republic of Uzbekistan",
        "ru": "Олий Мажлис Республики Узбекистан",
        "uz": "O‘zbekiston Respublikasi Oliy Majlisi",
    },
}

JURISDICTION_NAMES = {"INT": {"en": "International", "ru": "Международный уровень", "uz": "Xalqaro daraja"}}

INSTRUMENT_TITLES = {
    "INT-INCB-YL-65": {
        "ru": "Перечень наркотических средств, находящихся под международным контролем («Жёлтый список»), 65-е издание",
        "uz": "Xalqaro nazoratdagi giyohvandlik vositalari ro‘yxati («Sariq ro‘yxat»), 65-nashr",
    },
    "INT-INCB-GL-36": {
        "ru": "Перечень психотропных веществ, находящихся под международным контролем («Зелёный список»), 36-е издание",
        "uz": "Xalqaro nazoratdagi psixotrop moddalar ro‘yxati («Yashil ro‘yxat»), 36-nashr",
    },
    "GB-RTA-1988-S11": {
        "ru": "Закон о дорожном движении 1988 г. (Road Traffic Act 1988), раздел 11",
        "uz": "1988-yilgi Yo‘l harakati to‘g‘risidagi qonun (Road Traffic Act 1988), 11-bo‘lim",
    },
    "GB-SCT-SSI-2014-328": {
        "ru": "Постановление 2014 г. к Закону о дорожном движении 1988 г. о предельно допустимых уровнях (Шотландия)",
        "uz": "1988-yilgi Yo‘l harakati to‘g‘risidagi qonunga oid belgilangan chegaralar haqidagi (Shotlandiya) 2014-yilgi qoidalar",
    },
}
# Official names (lex.uz, read 2026-10-09): uz-Cyrl docs/86044 «Гиёҳвандлик воситалари ва
# психотроп моддалар тўғрисида», ru docs/86028 «О наркотических средствах и психотропных веществах».
UZ_LAW_TITLES = {
    "uz": "O‘zbekiston Respublikasining «Giyohvandlik vositalari va psixotrop moddalar to‘g‘risida»gi Qonuni",
    "ru": "Закон Республики Узбекистан «О наркотических средствах и психотропных веществах»",
    "en": "Law of the Republic of Uzbekistan “On Narcotic Drugs and Psychotropic Substances”",
}

OFFICIAL_REFERENCE = {
    "US-21CFR1308": "21 CFR 1308.11–1308.15",
    "DE-BTMG-ANL": "BtMG 1981, Anlagen I–III",
    "UZ-LAW-813-I": "19.08.1999, № 813-I",
}

TERMS = {
    "T-POSTMORTEM-INTERVAL": {"ru": "посмертный интервал (PMI)", "uz": "o‘limdan keyin o‘tgan vaqt oralig‘i (PMI)",
                              "en": "postmortem interval (PMI)"},
}

# (recipe_id, part, index) -> {lang: text}
RECIPE_TEXTS = {
    ("recipe-dragendorff", "ingredients", 5): {"uz": "distillangan suv", "ru": "дистиллированная вода",
                                               "en": "distilled water"},
    ("recipe-dragendorff", "ingredients", 6): {"uz": "sirka kislota", "ru": "уксусная кислота", "en": "acetic acid"},
    ("recipe-dragendorff", "ingredients", 7): {"uz": "kaliy yodid eritmasi, 40 g% (w/v)",
                                               "ru": "раствор иодида калия, 40 g% (w/v)",
                                               "en": "potassium iodide solution, 40 g% (w/v)"},
    ("recipe-dragendorff", "ingredients", 8): {"uz": "asosli vismut nitrat, 20% v/v sirka kislotadagi 1,7 g% w/v",
                                               "ru": "основной нитрат висмута, 1,7 g% w/v в 20% v/v уксусной кислоте",
                                               "en": "basic bismuth nitrate, 1.7 g% w/v in 20% v/v acetic acid"},
    ("recipe-dragendorff", "steps", 3): {
        "uz": "Dragendorf reaktivi 70 ml distillangan suv va 20 ml sirka kislotani 5 ml 40 g% li kaliy yodid "
              "eritmasi hamda 20% v/v sirka kislotadagi 1,7 g% w/v asosli vismut nitrat eritmasidan 5 ml bilan "
              "aralashtirib tayyorlangan.",
        "ru": "Реактив Драгендорфа готовили, смешивая 70 мл дистиллированной воды и 20 мл уксусной кислоты с 5 мл "
              "40 g% раствора иодида калия и 5 мл раствора основного нитрата висмута 1,7 g% w/v в 20% v/v "
              "уксусной кислоте.",
        "en": "Dragendorff’s reagent was prepared by mixing 70 mL distilled water and 20 mL acetic acid with 5 mL of "
              "40 g% potassium iodide solution and 5 mL of 1.7 g% w/v basic bismuth nitrate in 20% v/v acetic acid "
              "solution."},
    ("recipe-alpha-naphthol-solution", "ingredients", 0): {"uz": "α-naftol (1-naftol)", "ru": "α-нафтол (1-нафтол)"},
    ("recipe-beta-naphthol-solution", "ingredients", 0): {"uz": "β-naftol (2-naftol)", "ru": "β-нафтол (2-нафтол)"},
    ("recipe-griess", "ingredients", 1): {
        "uz": "B eritma: α-naftilamin (1-naftilamin), 30 % li sirka kislotadagi 0,1 % li eritma",
        "ru": "раствор Б: α-нафтиламин (1-нафтиламин), 0,1 %-й раствор в 30 %-м растворе уксусной кислоты"},
    ("recipe-phosphate-buffer-ph-7-38", "steps", 0): {
        "ru": "В одной колбе растворяют 11,876 г моногидрофосфата натрия в 1 л дистиллированной воды, в другой — "
              "9,078 г дигидрофосфата калия в 1 л дистиллированной воды."},
    ("recipe-pyridine-freshly-distilled", "steps", 0): {
        "ru": "Товарный пиридин выдерживают над гранулами гидроксида калия 24 часа (сутки)."},
}

OWNER_REAGENTS_TITLE = "«Приготовление реактивов»"
OWNER_REAGENTS_NOTE = ("Bibliographic title kept in its original language (ru); descriptive gloss: reagent "
                       "preparation compilation (toxicological chemistry), 74 entries.")


def apply(b):
    n = {}

    def bump(k):
        n[k] = n.get(k, 0) + 1

    for m in b["methods"]:
        if m["method_id"] in METHOD_TITLES:
            m["titles"].update(METHOD_TITLES[m["method_id"]])
            bump("method_titles")
    for a in b["authorities"]:
        if a["authority_id"] in AUTHORITY_NAMES:
            a["names"] = dict(AUTHORITY_NAMES[a["authority_id"]])
            bump("authority_names")
    for j in b["jurisdictions"]:
        if j["jurisdiction_id"] in JURISDICTION_NAMES:
            j["names"] = dict(JURISDICTION_NAMES[j["jurisdiction_id"]])
            bump("jurisdiction_names")
    for i in b["instruments"]:
        iid = i["instrument_id"]
        if iid in INSTRUMENT_TITLES:
            i["titles"].update(INSTRUMENT_TITLES[iid])
            i["translation_status"] = "machine_draft"
            bump("instrument_titles")
        if iid == "UZ-LAW-813-I":
            i["titles"].update(UZ_LAW_TITLES)
            i["internal_title_note"] = ("uz/ru titles are the official names on lex.uz (uz-Cyrl docs/86044 "
                                        "transliterated to Latin; ru docs/86028), read 2026-10-09; en is unofficial.")
            bump("instrument_titles_official")
        ref = i.get("official_reference") or ""
        if iid in OFFICIAL_REFERENCE and ref != OFFICIAL_REFERENCE[iid]:
            i["internal_note"] = ref
            i["official_reference"] = OFFICIAL_REFERENCE[iid]
            bump("official_reference_cleaned")
    for t in b["term_translations"]:
        if t["term_id"] in TERMS:
            t["localized"].update(TERMS[t["term_id"]])
            bump("terms")
    recipes = {r["recipe_id"]: r for r in b["recipes"]}
    for (rid, part, idx), texts in RECIPE_TEXTS.items():
        item = recipes[rid][part][idx]
        key = "names" if part == "ingredients" else "texts"
        item.setdefault(key, {}).update(texts)
        bump("recipe_items")
    for s in b["sources"]:
        if s["source_id"] == "SRC-OWNER-REAGENTS" and s["title"] != OWNER_REAGENTS_TITLE:
            s["title"] = OWNER_REAGENTS_TITLE
            if OWNER_REAGENTS_NOTE not in (s.get("notes") or ""):
                s["notes"] = ((s.get("notes") or "") + " " + OWNER_REAGENTS_NOTE).strip()
            bump("source_titles")
    # canonical terminology in displayed uz/ru running text (not originals)
    for r in b["recipes"]:
        for part, key in (("ingredients", "names"), ("steps", "texts"), ("hazards", "texts"), ("notes", "texts")):
            for item in r.get(part, []) or []:
                if isinstance(item, dict) and isinstance(item.get(key), dict):
                    for lang in ("uz", "ru"):
                        if isinstance(item[key].get(lang), str):
                            item[key][lang] = normalize_text(item[key][lang], lang)
    for coll, field in (("substances", "names"), ("topics", "names"), ("screening_tests", "names"),
                        ("instruments", "titles"), ("methods", "titles")):
        for e in b.get(coll, []):
            m = e.get(field)
            if isinstance(m, dict):
                for lang in ("uz", "ru"):
                    if isinstance(m.get(lang), str):
                        m[lang] = normalize_text(m[lang], lang)
    return n


def main():
    b = json.load(open(BUNDLE, encoding="utf-8"))
    r = apply(b)
    json.dump(b, open(BUNDLE, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    print("apply_l10n_d:", json.dumps(r, sort_keys=True))


if __name__ == "__main__":
    main()
