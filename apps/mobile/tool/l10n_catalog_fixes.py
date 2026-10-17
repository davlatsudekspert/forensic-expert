#!/usr/bin/env python3
"""Ekranlar katalogi ko‘rigi bo‘yicha tuzatishlar (2026-10-17, uz/ru/en).

Kalkulyator «Texnik ma’lumot», sinf testi mavzu tanlovi va manba qatori,
mashq ekrani izohlari, GHS P-kodlar, skrining ogohlantirishi (oddiy jumla
registri). Idempotent: yangi kalitlarni qo‘shadi va ro‘yxatdagi mavjud
kalitlar qiymatini o‘rnatadi (merge’dan keyin qayta ishga tushirilsa, shu
qiymatlar tiklanadi).

Tartib (CLAUDE.md «L10n skriptlari tartibi»): `l10n_design_premium.py` dan
keyin, `l10n_ux_audit.py` dan oldin («yangi skriptlar» o‘rni), so‘ng
`flutter gen-l10n`. Ishga tushirish: apps/mobile ichida
`python3 tool/l10n_catalog_fixes.py`.
"""
import json
import pathlib

ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"
LANGS = ("uz", "ru", "en")
S = {"type": "String"}
I = {"type": "int"}

# (uz, ru, en, tavsif, placeholderlar)
NEW = {
    "calcTechInfo": (
        "Texnik ma’lumot",
        "Техническая информация",
        "Technical details",
        "Collapsed section on a calculator page with the module id and version.",
        None,
    ),
    "calcTechModule": (
        "Hisoblash moduli: {id}, versiya {version}",
        "Расчётный модуль: {id}, версия {version}",
        "Calculation module: {id}, version {version}",
        "Technical line inside the collapsed 'Technical details' section.",
        {"id": S, "version": S},
    ),
    "classSourceLineNoPage": (
        "Manba: {author}, {title}",
        "Источник: {author}, {title}",
        "Source: {author}, {title}",
        "Class quiz source line when the source has no page.",
        {"author": S, "title": S},
    ),
    "classSourceLineLocator": (
        "Manba: {author}, {title}, {locator}",
        "Источник: {author}, {title}, {locator}",
        "Source: {author}, {title}, {locator}",
        "Class quiz source line when the place is a chapter/section, not a page number.",
        {"author": S, "title": S, "locator": S},
    ),
    "classTopicSearchHint": (
        "Mavzu yoki kursni qidiring",
        "Поиск темы или курса",
        "Search a topic or course",
        "Search field above the grouped topic list (teacher, new class quiz).",
        None,
    ),
    "classTopicGroupOther": (
        "Boshqa mavzular",
        "Другие темы",
        "Other topics",
        "Group title for topics without a course/subject in the question bank index.",
        None,
    ),
    "classTopicNoMatch": (
        "Mos mavzu topilmadi.",
        "Подходящих тем не найдено.",
        "No matching topics.",
        "Topic search returned nothing.",
        None,
    ),
    "classTopicSelected": (
        "Tanlangan mavzu",
        "Выбранная тема",
        "Selected topic",
        "Label above the selected topic summary.",
        None,
    ),
    "classTopicGroupCount": (
        "{count} ta mavzu",
        "Тем: {count}",
        "{count} topics",
        "Number of topics in a course group.",
        {"count": I},
    ),
    "ghsPCodesDetails": (
        "Batafsil: ehtiyot choralari (P-kodlar, {count} ta)",
        "Подробнее: меры предосторожности (P-коды: {count})",
        "Details: precautionary statements ({count} P-codes)",
        "Collapsed list of GHS precautionary P-codes under a hazard note.",
        {"count": I},
    ),
    "studyExamUnavailableHub": (
        "«Faqat mashq» belgili to‘plamlarda imtihon yo‘q: savollar avtomatik tuzilgan yoki ularda izoh yoki manbadagi sahifa yo‘q. Ular bo‘yicha mashq rejimidan foydalaning.",
        "В наборах с отметкой «Только тренировка» экзамена нет: вопросы созданы автоматически или у них нет пояснения либо страницы источника. Для них используйте тренировку.",
        "Sets marked “Practice only” have no exam: their questions are generated automatically or lack an explanation or page in the source. Use Practice for them.",
        "One note at the top of the study hub (replaces the repeated per-set text and disabled Exam buttons).",
        None,
    ),
    "studyQuizAboutPractice": (
        "Mashq rejimi va variantlar haqida",
        "О режиме тренировки и вариантах",
        "About practice mode and options",
        "Title of the single collapsible info box on the first practice question.",
        None,
    ),
}

# Mavjud kalitlar: (uz, ru, en) — None bo‘lsa o‘zgartirilmaydi.
SET = {
    # Mayin uslub: KATTA HARF o‘rniga oddiy jumla; ma’no saqlanadi.
    "screeningBanner": (
        "Skrining natijasi — tasdiqlangan identifikatsiya emas. Ijobiy skrining dastlabki natija bo‘lib, validatsiyadan o‘tgan tasdiqlovchi usulni talab qiladi.",
        "Результат скрининга — не подтверждённая идентификация. Положительный скрининг предварителен и требует валидированного подтверждающего метода.",
        "A screening result is not a confirmed identification. A positive screen is presumptive and requires a validated confirmatory method.",
    ),
}


def main() -> None:
    for i, lang in enumerate(LANGS):
        p = ARB / f"app_{lang}.arb"
        d = json.loads(p.read_text(encoding="utf-8"))
        for k, (uz, ru, en, desc, ph) in NEW.items():
            d[k] = (uz, ru, en)[i]
            if lang == "en":
                meta = {"description": desc}
                if ph:
                    meta["placeholders"] = ph
                d["@" + k] = meta
        for k, vals in SET.items():
            if vals[i] is not None and k in d:
                d[k] = vals[i]
        p.write_text(
            json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
    print(f"l10n_catalog_fixes: {len(NEW)} yangi, {len(SET)} yangilangan kalit")


if __name__ == "__main__":
    main()
