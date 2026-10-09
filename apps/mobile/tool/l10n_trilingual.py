# Uch tilli ko‘rsatish qatlami (Phase B + C, 2026-10-09):
#  * B — noqulay o‘zbekcha sanoq «{total} tadan {n}-…» → tabiiy «{n}-savol / {total}»
#    (8 kalit), ru matnidagi qolgan «email» → «электронная почта»;
#  * C — tarjima holati belgilari, «Asl matn» ochiladigan bloki, tarjima yo‘qligi
#    haqidagi halol xabar, til nomlari va huquqiy hujjat nomi holati.
#
# Idempotent: qiymatlarni o‘rnatadi; mavjud kalitning @meta’si saqlanadi.
# Tartib (CLAUDE.md): `l10n_glossary.py` dan keyin, `l10n_ux_audit.py` dan oldin;
# so‘ng `flutter gen-l10n`. Ishga tushirish: apps/mobile ichida
# `python3 tool/l10n_trilingual.py`.
import collections
import json
import re

D = "lib/core/l10n/arb"
LANGS = ["en", "ru", "uz"]
S = {"type": "String"}

# --- 1. Yangi kalitlar (tavsif + placeholder bilan) -------------------------
NEW = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    NEW[key] = (desc, en, ru, uz, ph)


k("trStatusMachineDraft", "Translation status badge: machine translation, not reviewed by a person.",
  "Machine translation — not reviewed", "Автоматический перевод — не проверен",
  "Avtomatik tarjima — tekshirilmagan")
k("trStatusTerminologyChecked", "Translation status badge: terminology checked automatically, content not reviewed.",
  "Machine translation — terminology checked, content not reviewed",
  "Автоматический перевод — термины сверены, содержание не проверено",
  "Avtomatik tarjima — atamalar tekshirilgan, mazmuni tekshirilmagan")
k("trStatusClaimChecked", "Translation status badge: numbers, units and substance names checked automatically; no expert review.",
  "Machine translation — numbers and units checked, not reviewed by an expert",
  "Автоматический перевод — числа и единицы сверены, специалист не проверял",
  "Avtomatik tarjima — raqam va birliklar tekshirilgan, mutaxassis ko‘rmagan")
k("trStatusReviewed", "Translation status badge: reviewed by a qualified person.",
  "Translation reviewed by an expert", "Перевод проверен специалистом",
  "Tarjima mutaxassis tomonidan tekshirilgan")
k("trStatusOfficial", "Translation status badge: official text in this language.",
  "Official text", "Официальный текст", "Rasmiy matn")
k("trOriginalShow", "Expandable control that reveals the original-language text.",
  "Original text", "Оригинал", "Asl matn")
k("trOriginalHide", "Collapse the original-language text.",
  "Hide original text", "Скрыть оригинал", "Asl matnni yashirish")
k("trOriginalQuoteShow", "Study quiz: reveal the verbatim quote from the original source.",
  "Show the quote from the original source", "Показать цитату из первоисточника",
  "Asl manbadagi iqtibosni ko‘rish")
k("trOriginalTitle", "Secondary line: the original (untranslated) title of a work or document.",
  "Original title: {title}", "Оригинальное название: {title}", "Asl nomi: {title}", {"title": S})
k("trNotTranslated", "Honest notice: no translation into the UI language exists yet; the original follows.",
  "An English translation of this text is not available yet — original language: {language}",
  "Русский перевод этого текста ещё не подготовлен — язык оригинала: {language}",
  "Bu matnning o‘zbekcha tarjimasi hali tayyorlanmagan — asl tili: {language}", {"language": S})
k("trTitleNotTranslated", "Honest notice under an untranslated title.",
  "No English translation of the title yet — original language: {language}",
  "Перевода названия на русский пока нет — язык оригинала: {language}",
  "Nomning o‘zbekcha tarjimasi hali yo‘q — asl tili: {language}", {"language": S})
k("trInOriginalLanguage", "Compact tag after a short untranslated value (name, list item).",
  "original: {language}", "оригинал: {language}", "asl tili: {language}", {"language": S})
k("trLanguageName", "Language name used inside «original language: …».",
  "{code, select, en{English} ru{Russian} uz{Uzbek} de{German} fr{French} other{{code}}}",
  "{code, select, en{английский} ru{русский} uz{узбекский} de{немецкий} fr{французский} other{{code}}}",
  "{code, select, en{ingliz} ru{rus} uz{o‘zbek} de{nemis} fr{fransuz} other{{code}}}",
  {"code": S})
k("trQuoteTranslatedLabel", "Label above a translated source quote (translation shown first).",
  "Source quote (translation)", "Цитата из источника (перевод)", "Manbadagi iqtibos (tarjima)")
k("trTranslationSemantics", "Screen-reader label for a translated block.",
  "Translation of the original text. {status}. The original is available under «Original text».",
  "Перевод оригинального текста. {status}. Оригинал доступен по кнопке «Оригинал».",
  "Asl matnning tarjimasi. {status}. Asl matn «Asl matn» tugmasi orqali ochiladi.", {"status": S})
k("imageCaptionSection", "Image viewer: section header for the caption from the source (translation shown first).",
  "Caption in the source", "Подпись в источнике", "Manbadagi izoh")
k("trStatusDerivedDraft", "Status badge: explanation compiled automatically from the sourced quote in the same language; not reviewed.",
  "Automatic explanation — not reviewed", "Автоматическое объяснение — не проверено",
  "Avtomatik tushuntirish — tekshirilmagan")
k("trTopicSummaryLabel", "Topic card: short explanation in the UI language (from the card's sourced statements).",
  "Brief explanation", "Краткое объяснение", "Qisqacha tushuntirish")
k("trTopicSummaryNote", "Note under the topic card explanation header.",
  "Compiled from the sourced statements on this card; the original quote is below.",
  "Составлено по утверждениям карточки с источниками; оригинальная цитата — ниже.",
  "Kartadagi manbali da’volar asosida tuzilgan; asl iqtibos quyida.")
k("glossaryLibraryArticles", "Section inside the single Scientific glossary: glossary articles from the library.",
  "Glossary articles in the library", "Статьи словаря в библиотеке", "Kutubxonadagi lug‘at maqolalari")
k("legalTitleUnofficial", "Status line under a legal document title shown as a translation.",
  "Unofficial translation of the title — not reviewed", "Неофициальный перевод названия — не проверен",
  "Nomning norasmiy tarjimasi — tekshirilmagan")
k("legalTitleOfficialIn", "Status line under a legal document title shown in its official language.",
  "Official title ({language})", "Официальное название (язык: {language})",
  "Rasmiy nomi ({language} tilida)", {"language": S})

# --- 2. Mavjud kalitlar: qiymatlarni o‘rnatish (None — o‘zgartirilmaydi) ---
SET = collections.OrderedDict()


def s(key, en=None, ru=None, uz=None):
    SET[key] = (en, ru, uz)


# Noqulay sanoq «{total} tadan {n}-…» (egasi misoli «1 tadan 1-savol").
# (study* sanoqlari — `l10n_study_terms.py` da: «{current}-savol / {total} ta»;
# shu uslub bu yerda ham.)
s("courtQuestionOf", uz="{index}-savol / {count} ta")
s("courtDrillStep", uz="{index}-qadam / {count} ta")
s("firstStepsProgress", uz="Bajarildi: {done} / {total}")
s("admShown", uz="Ko‘rsatilmoqda: {shown} / {total}")
# ru: lotincha «email» gap ichida.
s("emailCodeChange", ru="Изменить адрес электронной почты")
# Tarjima endi birinchi, asl matn — «Asl matn» ostida (Phase C).
s("quoteMachineTranslation",
  en="Machine translation — not reviewed",
  ru="Автоматический перевод — не проверен",
  uz="Avtomatik tarjima — tekshirilmagan")
s("quoteMachineTranslationSemantics",
  en="Machine translation of a source quote, not reviewed by an expert. The original quote is available under «Original text».",
  ru="Автоматический перевод цитаты из источника, не проверен экспертом. Оригинальная цитата доступна по кнопке «Оригинал».",
  uz="Manbadan iqtibosning avtomatik tarjimasi, ekspert tomonidan tekshirilmagan. Asl iqtibos «Asl matn» tugmasi orqali ochiladi.")
s("quoteOriginalTitle", en="Original title: {title}", ru="Оригинальное название: {title}", uz="Asl nomi: {title}")

# ru matnlaridagi «email» → «электронная почта» (gap ichida; placeholder’ga tegmaydi).
RU_EMAIL = [
    ("privacySummary", r"солёный хеш вашего email", "солёный хеш адреса вашей электронной почты"),
    ("privacySummary", r"ваше имя, email, профиль", "ваше имя, адрес электронной почты, профиль"),
]


def main():
    for idx, code in enumerate(LANGS):
        p = f"{D}/app_{code}.arb"
        data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
        for key, (desc, en, ru, uz, ph) in NEW.items():
            data[key] = (en, ru, uz)[idx]
            if code == "en":
                meta = {"description": desc}
                if ph:
                    meta["placeholders"] = ph
                data["@" + key] = meta
        for key, vals in SET.items():
            v = vals[idx]
            if v is None:
                continue
            if key not in data:
                raise SystemExit(f"{key}: kalit {code} ARB’da yo‘q")
            data[key] = v
        if code == "ru":
            for key, pat, rep in RU_EMAIL:
                data[key] = re.sub(pat, rep, data[key])
        json.dump(data, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
        open(p, "a").write("\n")
    print(f"l10n_trilingual: {len(NEW)} yangi, {len(SET)} o‘rnatilgan kalit")


if __name__ == "__main__":
    main()
