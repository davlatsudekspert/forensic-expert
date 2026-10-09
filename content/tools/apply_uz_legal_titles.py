#!/usr/bin/env python3
"""Official Uzbek / Russian titles of Uzbek legal acts in references.json (Phase D).

Adds to each Uzbek legal reference (idempotent):
  titles          {uz, ru, en}  display title per UI language (with date/number/articles)
  official_titles {uz, uz_cyrl, ru}  exact official names as published on lex.uz
  title_status    {uz, ru, en}  official | official_transliterated | unofficial_translation
  title_verification [{url, lang, verbatim, accessed}]  what was read on lex.uz

The original bibliographic `title` is kept, except that the mixed Russian +
English title of court_uz_expertise_law is reduced to its Russian original
(the English gloss now lives in titles.en).

Uzbek official texts on lex.uz are published in Cyrillic; the Latin form is a
letter-by-letter transliteration under the 1995 Uzbek Latin alphabet
(status `official_transliterated`). English titles are not official.

Run from the repository root:  python3 content/tools/apply_uz_legal_titles.py
"""
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[2]
REFS = ROOT / "content/guidelines/references.json"
ACCESSED = "2026-10-09"
STATUS = {"uz": "official_transliterated", "ru": "official", "en": "unofficial_translation"}

DATA = {
    "court_uz_cpc": {
        "titles": {
            "uz": "O‘zbekiston Respublikasining Jinoyat-protsessual kodeksi (22.09.1994), 67, 68, 76, 78, 184, 186, 187-moddalar",
            "ru": "Уголовно-процессуальный кодекс Республики Узбекистан от 22.09.1994, статьи 67, 68, 76, 78, 184, 186, 187",
            "en": "Criminal Procedure Code of the Republic of Uzbekistan (22.09.1994), Articles 67, 68, 76, 78, 184, 186, 187",
        },
        "official_titles": {
            "uz": "O‘zbekiston Respublikasining Jinoyat-protsessual kodeksi",
            "uz_cyrl": "Ўзбекистон Республикасининг Жиноят-процессуал кодекси",
            "ru": "Уголовно-процессуальный кодекс Республики Узбекистан",
        },
        "title_verification": [
            {"url": "https://lex.uz/docs/111460", "lang": "uz-Cyrl",
             "verbatim": "Ўзбекистон Республикасининг Жиноят-процессуал кодекси", "accessed": ACCESSED},
            {"url": "https://lex.uz/docs/111463", "lang": "ru",
             "verbatim": "Уголовно-процессуальный кодекс Республики Узбекистан", "accessed": ACCESSED},
        ],
    },
    "court_uz_expertise_law": {
        "title": "Закон Республики Узбекистан «О судебной экспертизе» от 01.06.2010 № ЗРУ-249, статьи 4, 7, 8, 15, 16, 24",
        "titles": {
            "uz": "O‘zbekiston Respublikasining «Sud ekspertizasi to‘g‘risida»gi Qonuni (01.06.2010, O‘RQ-249), 4, 7, 8, 15, 16, 24-moddalar",
            "ru": "Закон Республики Узбекистан «О судебной экспертизе» от 01.06.2010 № ЗРУ-249, статьи 4, 7, 8, 15, 16, 24",
            "en": "Law of the Republic of Uzbekistan “On Forensic Expertise” No. ZRU-249 of 01.06.2010, Articles 4, 7, 8, 15, 16, 24",
        },
        "official_titles": {
            "uz": "Sud ekspertizasi to‘g‘risida",
            "uz_cyrl": "Суд экспертизаси тўғрисида",
            "ru": "О судебной экспертизе",
        },
        "title_verification": [
            {"url": "https://lex.uz/docs/1633102", "lang": "uz-Cyrl",
             "verbatim": "ЎРҚ-249-сон 01.06.2010. Суд экспертизаси тўғрисида", "accessed": ACCESSED},
            {"url": "https://lex.uz/docs/1633100", "lang": "ru",
             "verbatim": "ЗРУ-249-сон 01.06.2010. О судебной экспертизе", "accessed": ACCESSED},
        ],
        "note": "Russian text on lex.uz (docs/1633100) was read for the articles; the official Uzbek text is docs/1633102. Wording as in force on 2026-10-09, including 2024 amendments (ZRU-945, ZRU-1003). Accessed 2026-10-09.",
        "legal_status_note": "LexUZ commentary on docs/1633102 (read 2026-10-09): the law loses force on 13.12.2026 under Law O‘RQ-1152 of 11.06.2026 «Sud-ekspertlik faoliyati to‘g‘risida». Cards citing ZRU-249 must be re-checked against O‘RQ-1152 before that date (NEEDS LEGAL REVIEW; not changed in content).",
    },
    "gmt_lex_law813": {
        "titles": {
            "uz": "O‘zbekiston Respublikasining «Giyohvandlik vositalari va psixotrop moddalar to‘g‘risida»gi Qonuni (19.08.1999, 813-I-son), konsolidatsiyalangan matn",
            "ru": "Закон Республики Узбекистан «О наркотических средствах и психотропных веществах» от 19.08.1999 № 813-I (действующая редакция)",
            "en": "Law of the Republic of Uzbekistan No. 813-I of 19.08.1999 «On narcotic drugs and psychotropic substances» (consolidated text)",
        },
        "official_titles": {
            "uz": "Giyohvandlik vositalari va psixotrop moddalar to‘g‘risida",
            "uz_cyrl": "Гиёҳвандлик воситалари ва психотроп моддалар тўғрисида",
            "ru": "О наркотических средствах и психотропных веществах",
        },
        "title_verification": [
            {"url": "https://lex.uz/docs/86044", "lang": "uz-Cyrl",
             "verbatim": "813-I-сон 19.08.1999. Гиёҳвандлик воситалари ва психотроп моддалар тўғрисида", "accessed": ACCESSED},
            {"url": "https://lex.uz/docs/86028", "lang": "ru",
             "verbatim": "813-I-сон 19.08.1999. О наркотических средствах и психотропных веществах", "accessed": ACCESSED},
        ],
    },
    "gmt_lex_cm330": {
        "titles": {
            "uz": "Vazirlar Mahkamasining 12.11.2015 yildagi 330-son «Giyohvandlik vositalari, psixotrop moddalar va prekursorlarni O‘zbekiston Respublikasi hududiga olib kirish, undan olib chiqish va tranzit tarzida o‘tkazish tartibini, shuningdek ularning muomalada bo‘lishi yuzasidan nazoratni takomillashtirish to‘g‘risida»gi qarori",
            "ru": "Постановление Кабинета Министров Республики Узбекистан от 12.11.2015 № 330 «О совершенствовании порядка ввоза, вывоза и транзита через территорию Республики Узбекистан наркотических средств, психотропных веществ и прекурсоров, а также контроля за их оборотом»",
            "en": "Resolution of the Cabinet of Ministers No. 330 of 12.11.2015 «On improving the procedure for import, export and transit of narcotic drugs, psychotropic substances and precursors through the territory of the Republic of Uzbekistan and control over their circulation» (consolidated text)",
        },
        "official_titles": {
            "uz": "Giyohvandlik vositalari, psixotrop moddalar va prekursorlarni O‘zbekiston Respublikasi hududiga olib kirish, undan olib chiqish va tranzit tarzida o‘tkazish tartibini, shuningdek ularning muomalada bo‘lishi yuzasidan nazoratni takomillashtirish to‘g‘risida",
            "uz_cyrl": "Гиёҳвандлик воситалари, психотроп моддалар ва прекурсорларни Ўзбекистон Республикаси ҳудудига олиб кириш, ундан олиб чиқиш ва транзит тарзида ўтказиш тартибини, шунингдек уларнинг муомалада бўлиши юзасидан назоратни такомиллаштириш тўғрисида",
            "ru": "О совершенствовании порядка ввоза, вывоза и транзита через территорию Республики Узбекистан наркотических средств, психотропных веществ и прекурсоров, а также контроля за их оборотом",
        },
        "title_verification": [
            {"url": "https://lex.uz/docs/2815340", "lang": "uz-Cyrl",
             "verbatim": "330-сон 12.11.2015 (Uzbek title read in four parts, concatenated above)", "accessed": ACCESSED},
            {"url": "https://lex.uz/docs/2815342", "lang": "ru",
             "verbatim": "О совершенствовании порядка ввоза, вывоза и транзита через территорию Республики Узбекистан наркотических средств, психотропных веществ и прекурсоров, а также контроля за их оборотом", "accessed": ACCESSED},
        ],
    },
}


def main():
    raw = REFS.read_text(encoding="utf-8")
    d = json.loads(raw)
    done = []
    for r in d["references"]:
        upd = DATA.get(r["key"])
        if not upd:
            continue
        for k, v in upd.items():
            r[k] = v
        r["title_status"] = dict(STATUS)
        done.append(r["key"])
    REFS.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    missing = sorted(set(DATA) - set(done))
    print(f"uz legal titles: {len(done)} references updated; missing: {missing}")


if __name__ == "__main__":
    main()
