# «Ilmiy lug‘at» (uz/ru/en atamalar, `term_translations`) va yo‘riqnoma
# kartalaridagi «Atamalar» bo‘limi uchun UI matnlari.
# Mashina tarjimasi (machine_draft) hech qachon tasdiqlangan deb
# ko‘rsatilmaydi — belgi va izoh matnlari shu yerda.
#
# Idempotent. Ishga tushirish: apps/mobile ichida `python3 tool/l10n_glossary.py`,
# so‘ng (CLAUDE.md tartibida) `l10n_ux_audit.py` va `flutter gen-l10n`.
import collections
import json

D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)


S = {"type": "String"}
k("glossaryTitle", "Scientific glossary screen title and Library hub tile.",
  "Scientific glossary", "Научный словарь", "Ilmiy lug‘at")
k("glossaryIntro", "Short note at the top of the glossary.",
  "Terms in Uzbek, Russian and English. Translations remain machine drafts until a terminologist reviews them.",
  "Термины на узбекском, русском и английском языках. Переводы остаются машинными черновиками, пока их не проверит терминолог.",
  "Atamalar o‘zbek, rus va ingliz tillarida. Tarjimalar terminolog tekshirmaguncha mashina qoralamasi bo‘lib qoladi.")
k("glossaryFilterHint", "Filter field hint in the glossary (any of the three languages).",
  "Filter terms (uz, ru, en)", "Фильтр терминов (uz, ru, en)", "Atamani izlash (uz, ru, en)")
k("glossaryEmpty", "Glossary: nothing matches the filter.",
  "No terms match the filter.", "Нет терминов, подходящих под фильтр.", "Filtrga mos atama topilmadi.")
k("glossaryMachineDraft", "Badge on a machine-translated (unverified) term.",
  "Machine translation — not verified", "Машинный перевод — не проверен", "Mashina tarjimasi — tekshirilmagan")
k("glossaryMachineDraftNote", "Explanation under a machine-translated term.",
  "These translations were produced automatically and have not been checked by a terminologist. Use them for orientation; for reports, check the term in an authoritative source.",
  "Эти переводы получены автоматически и не проверены терминологом. Используйте их для ориентира; для заключений сверяйте термин с авторитетным источником.",
  "Bu tarjimalar avtomatik olingan va terminolog tomonidan tekshirilmagan. Ulardan yo‘l-yo‘riq sifatida foydalaning; xulosa uchun atamani ishonchli manbadan tekshiring.")
k("glossaryStatusTranslated", "Badge: translated by a person but not yet reviewed.",
  "Translated — not reviewed", "Переведено — не проверено", "Tarjima qilingan — tekshirilmagan")
k("glossaryStatusReviewed", "Badge: translation reviewed by a terminologist.",
  "Reviewed translation", "Проверенный перевод", "Tekshirilgan tarjima")
k("glossaryOriginal", "Term detail: the form used in the source and its language.",
  "In the source ({language}): {term}", "В источнике ({language}): {term}", "Manbada ({language}): {term}",
  {"language": S, "term": S})
k("glossaryKindTerm", "Glossary entry kind.", "Term", "Термин", "Atama")
k("glossaryKindAbbreviation", "Glossary entry kind.", "Abbreviation", "Аббревиатура", "Qisqartma")
k("glossaryKindIdentifier", "Glossary entry kind.", "Identifier", "Идентификатор", "Identifikator")
k("glossaryKindFormula", "Glossary entry kind.", "Formula", "Формула", "Kimyoviy formula")
k("glossaryUsedIn", "Term detail: guideline cards that use the term.",
  "Used in guideline cards", "Встречается в карточках руководств", "Qaysi yo‘riqnomalarda uchraydi")
k("glossaryNoCards", "Term detail: the term is not linked to a guideline card.",
  "Not linked to a guideline card yet.", "Пока не связан с карточками руководств.", "Hozircha yo‘riqnoma kartasiga bog‘lanmagan.")
k("glossaryOpenInGlossary", "Action in the term sheet: open the full glossary entry.",
  "Open in glossary", "Открыть в словаре", "Lug‘atda ochish")
k("guidelineTerms", "Guideline card section listing glossary terms.",
  "Terms", "Термины", "Atamalar")
k("guidelineTermsHint", "Hint under the Terms section of a guideline card.",
  "Tap a term to see it in Uzbek, Russian and English.",
  "Нажмите на термин, чтобы увидеть его на узбекском, русском и английском.",
  "Atamani o‘zbek, rus va ingliz tillarida ko‘rish uchun bosing.")

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key, (desc, en, ru, uz, ph) in K.items():
        data[key] = (en, ru, uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = ph
            data["@" + key] = meta
    json.dump(data, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p, "a").write("\n")
print(len(K), "keys")
