# «Toksikologik kimyo» o‘quv-uslubiy majmuasi (prof. Yuldashev Z.A. va
# hammualliflar, TFI 2025) asosidagi yo‘riqnoma kartalari va o‘quv rejimi
# savollari uchun UI matnlari. Muallif ruxsati bilan; egasi qarori — barcha
# uchun bepul (2026-10-09).
#
# Idempotent. Ishga tushirish: apps/mobile ichida `python3 tool/l10n_toks.py`,
# so‘ng (CLAUDE.md tartibida) `l10n_ux_audit.py` va `flutter gen-l10n`.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
k("guidelineToksAttribution", "Attribution line on guideline cards based on Prof. Yuldashev's teaching materials.",
  "Source: Prof. Yuldashev Z.A. and co-authors, «Toxicological chemistry» teaching complexes (Tashkent Pharmaceutical Institute, 2025) — used with the author’s permission, free for everyone.",
  "Источник: проф. Юлдашев З.А. и соавторы, учебно-методические комплексы «Токсикологическая химия» (Ташкентский фармацевтический институт, 2025) — с разрешения автора, бесплатно для всех.",
  "Manba: prof. Yuldashev Z.A. va hammualliflar, «Toksikologik kimyo» o‘quv-uslubiy majmualari (Toshkent farmatsevtika instituti, 2025) — muallif ruxsati bilan, barcha uchun bepul.")
k("studySectionTeaching", "Study hub section for decks built from teaching complexes.",
  "Teaching complexes", "Учебно-методические комплексы", "O‘quv-uslubiy majmualar")
k("studyDeckToks", "Deck title: questions based on the toxicological chemistry teaching complex.",
  "Toxicological chemistry (Yuldashev Z.A.)", "Токсикологическая химия (Юлдашев З.А.)", "Toksikologik kimyo (Yuldashev Z.A.)")
k("studyFrontQuestion", "Flashcard front hint for a question card.",
  "Recall the answer, then flip the card", "Вспомните ответ и переверните карточку", "Javobni eslang, so‘ng kartochkani aylantiring")
k("studyQuizNoteAuthored", "Quiz banner for decks with written answer options.",
  "Questions and wrong options were written independently from the facts in the guideline cards; the correct answer and its page are given in the cited source.",
  "Вопросы и неверные варианты составлены самостоятельно по фактам из карточек руководств; правильный ответ и страница указаны в цитируемом источнике.",
  "Savollar va noto‘g‘ri variantlar yo‘riqnoma kartalaridagi faktlar asosida mustaqil tuzilgan; to‘g‘ri javob va uning sahifasi keltirilgan manbada.")
k("studySourcePages", "Page numbers in the cited source.",
  "pp. {pages}", "с. {pages}", "{pages}-betlar", {"pages": S})
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
