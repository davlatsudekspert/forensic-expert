# O‘quv testi qayta qurilishi (Phase E) va terminologiya (Phase F):
# mashq / imtihon rejimlari, «To‘g‘ri / Noto‘g‘ri» savollari, izohlar,
# aralash to‘plamlar, qisqartmalar izohi; sanoq matnlari («1-savol / 5 ta»)
# va ru ARB’dagi xalqaro qisqartmalar (content/terminology/canonical_terms.json).
#
# Idempotent. Ishga tushirish: apps/mobile ichida
# `python3 tool/l10n_study_terms.py` (CLAUDE.md tartibida l10n_glossary.py dan
# keyin), so‘ng `l10n_ux_audit.py` va `flutter gen-l10n`.
import collections
import json

D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)


S = {"type": "String"}
I = {"type": "int"}

# --- Rejimlar ---------------------------------------------------------------
k("studyModePractice", "Study deck button and quiz mode: ungraded practice.",
  "Practice", "Тренировка", "Mashq")
k("studyModeExam", "Study deck button and quiz mode: graded exam.",
  "Exam", "Экзамен", "Imtihon")
k("studyModePracticeBanner", "Banner at the top of a practice quiz.",
  "Practice mode — not graded. After each answer you see whether it is right, why, and the source.",
  "Режим тренировки — без оценки. После каждого ответа показано, верен ли он, почему и источник.",
  "Mashq rejimi — baholanmaydi. Har bir javobdan keyin to‘g‘ri-noto‘g‘riligi, izohi va manbasi ko‘rsatiladi.")
k("studyModeExamBanner", "Banner at the top of a graded exam.",
  "Graded exam — only questions with an author-written answer key, three related wrong options, an explanation and a page or section in the source. Answers and explanations are shown at the end.",
  "Экзамен с оценкой — только вопросы с авторским ключом ответа, тремя связанными неверными вариантами, пояснением и страницей или разделом источника. Ответы и пояснения — в конце.",
  "Baholanadigan imtihon — faqat muallif yozgan javob kaliti, uchta mantiqan bog‘liq noto‘g‘ri varianti, izohi va manbadagi sahifa yoki bo‘limi bor savollar. Javoblar va izohlar oxirida ko‘rsatiladi.")
k("studyExamCount", "Deck card: number of questions eligible for the graded exam.",
  "{count, plural, =0{No exam questions} =1{Exam: 1 question} other{Exam: {count} questions}}",
  "{count, plural, =0{Нет экзаменационных вопросов} one{Экзамен: {count} вопрос} few{Экзамен: {count} вопроса} other{Экзамен: {count} вопросов}}",
  "{count, plural, =0{Imtihon savollari yo‘q} other{Imtihon: {count} ta savol}}",
  {"count": I})
k("studyPracticeOnly", "Deck card / question badge: material that never enters the graded exam.",
  "Practice only", "Только тренировка", "Faqat mashq")
k("studyExamUnavailable", "Deck card: why the exam button is disabled.",
  "No exam for this set: its questions are generated automatically or lack an explanation or page in the source. Use Practice.",
  "Экзамена по этому набору нет: вопросы созданы автоматически или у них нет пояснения либо страницы источника. Используйте тренировку.",
  "Bu to‘plam bo‘yicha imtihon yo‘q: savollar avtomatik tuzilgan yoki ularda izoh yoki manbadagi sahifa yo‘q. Mashq rejimidan foydalaning.")
k("studyExamDraftLanguage", "Deck card: exam questions exist but the current UI language is a draft translation.",
  "The exam is available in Uzbek: the English translation of these questions is still a draft.",
  "Экзамен доступен на узбекском: русский перевод этих вопросов пока черновой.",
  "Imtihon o‘zbek tilida mavjud: bu savollarning tarjimasi hali qoralama.")
k("studyQuizFlashcardsOnly", "Deck card: no plausible related options — flashcards only.",
  "Too few related options for a test — flashcards only",
  "Слишком мало связанных вариантов для теста — только карточки",
  "Test uchun mantiqan bog‘liq variantlar yetarli emas — faqat kartochkalar")

# --- To‘g‘ri / Noto‘g‘ri -------------------------------------------------------
k("studyTfQuestion", "True/false question: asks whether the proposed answer is correct.",
  "Is this answer correct?", "Верен ли этот ответ?", "Bu javob to‘g‘rimi?")
k("studyTfProposed", "True/false question: label above the proposed answer.",
  "Proposed answer", "Предлагаемый ответ", "Taklif etilgan javob")
k("studyTrue", "True/false choice.", "Correct", "Верно", "To‘g‘ri")
k("studyFalse", "True/false choice.", "Incorrect", "Неверно", "Noto‘g‘ri")
k("studyTfNote", "Banner when a practice quiz contains true/false questions.",
  "Where fewer than three related wrong options exist, the question is shown as Correct / Incorrect.",
  "Если связанных неверных вариантов меньше трёх, вопрос показан в форме «Верно / Неверно».",
  "Mantiqan bog‘liq noto‘g‘ri variant uchtadan kam bo‘lsa, savol «To‘g‘ri / Noto‘g‘ri» ko‘rinishida beriladi.")

# --- Izohlar ---------------------------------------------------------------
k("studyExplainTopic", "Explanation after a quote→topic question.",
  "This statement is cited for “{topic}”. The other options are topics of the same field whose sources say something else.",
  "Это утверждение приведено для темы «{topic}». Другие варианты — темы той же области, в источниках которых сказано иное.",
  "Bu iqtibos «{topic}» mavzusiga keltirilgan. Boshqa variantlar — shu sohaning boshqa mavzulari, ularning manbalarida boshqa gap aytilgan.",
  {"topic": S})
k("studyExplainSourceSays", "Explanation: label above the sourced statement.",
  "The source states:", "В источнике сказано:", "Manbada shunday deyilgan:")
k("studyExplainSubstance", "Explanation after a substance→formula question.",
  "Molecular formula of {name} in its identity record: {formula}. The other options are formulas of substances from the same group.",
  "Молекулярная формула {name} в идентификационной записи: {formula}. Другие варианты — формулы веществ той же группы.",
  "{name} identifikatsiya yozuvidagi molekulyar formulasi: {formula}. Boshqa variantlar — shu guruhdagi boshqa moddalar formulalari.",
  {"name": S, "formula": S})
k("studyExplainGuideline", "Explanation after a summary→guideline question.",
  "This summary belongs to the guideline card “{title}”. The other options are cards of the same area.",
  "Это краткое содержание относится к карточке руководства «{title}». Другие варианты — карточки той же области.",
  "Bu qisqa mazmun «{title}» yo‘riqnoma kartasiga tegishli. Boshqa variantlar — shu yo‘nalishning boshqa kartalari.",
  {"title": S})
k("studyOpenSource", "Button after an answer: open the cited source.",
  "Open source", "Открыть источник", "Manbani ochish")
k("studyQuoteTranslated", "Label above a machine-translated quote in study mode.",
  "Quote from the source — machine translation, not reviewed",
  "Цитата из источника — машинный перевод, не проверен",
  "Manbadan iqtibos — avtomatik tarjima, tekshirilmagan")
k("studyShowOriginalQuote", "Expandable: show the original-language quote.",
  "Show the original quote", "Показать цитату на языке оригинала", "Asl manbadagi iqtibosni ko‘rish")
k("studySourceSection", "Citation line: section of the guideline card where the source is cited.",
  "Section: {section}", "Раздел: {section}", "Bo‘lim: {section}", {"section": S})
k("studyExamResultTitle", "Exam results header.",
  "Exam result", "Результат экзамена", "Imtihon natijasi")
k("studyExamReview", "Exam results: list of all answers with explanations.",
  "Answers and explanations", "Ответы и пояснения", "Javoblar va izohlar")
k("studyExamPercent", "Exam results: percentage of correct answers.",
  "{percent}% correct", "{percent}% верных", "{percent}% to‘g‘ri", {"percent": I})

# --- Aralash to‘plamlar ------------------------------------------------------
k("studyDeckMixedTopics", "Study deck that combines small topic sets (each keeps its own field for wrong options).",
  "Other topics (small sets combined)", "Другие темы (малые наборы объединены)",
  "Boshqa mavzular (kichik to‘plamlar birlashtirilgan)")
k("studyDeckMixedSubstances", "Study deck that combines small substance groups.",
  "Other groups (small sets combined)", "Другие группы (малые наборы объединены)",
  "Boshqa guruhlar (kichik to‘plamlar birlashtirilgan)")
k("studyDeckMixedGuidelines", "Study deck that combines small guideline areas.",
  "Other guidelines (small sets combined)", "Другие руководства (малые наборы объединены)",
  "Boshqa yo‘riqnomalar (kichik to‘plamlar birlashtirilgan)")

# --- Glossariy qisqartmalari -----------------------------------------------
k("glossaryShortExplanation", "Glossary term sheet: short explanation of an abbreviation.",
  "Short explanation", "Краткое пояснение", "Qisqa izoh")
k("glossaryAbbrevSemantics", "Screen reader hint on an abbreviation link in text.",
  "Abbreviation {abbr}: tap for a short explanation",
  "Аббревиатура {abbr}: нажмите для краткого пояснения",
  "{abbr} qisqartmasi: qisqa izoh uchun bosing", {"abbr": S})

# --- Mavjud kalitlar: yangi matn --------------------------------------------
UPDATE = {
    # Sanoq — l10n agent uslubi («1-savol / 5 ta»), faqat uz.
    "studyQuizQuestionOf": {"uz": "{current}-savol / {total} ta"},
    "studyCardProgress": {"uz": "{current}-kartochka / {total} ta"},
    "studyQuizScore": {"uz": "Natija: {correct} / {total}"},
    "studySessionSummary": {"uz": "Bildingiz: {known} / {total}"},
    "studyBox": {"uz": "{box}-quti / {total} ta"},
    "studyQuizUnavailable": {
        "en": "Too few related options for a test — flashcards only",
        "ru": "Слишком мало связанных вариантов для теста — только карточки",
        "uz": "Test uchun mantiqan bog‘liq variantlar yetarli emas — faqat kartochkalar",
    },
    "studyQuizNote": {
        "en": "Wrong options are other records of the same field or group only; nothing is invented. Practice only — not part of the graded exam.",
        "ru": "Неверные варианты — только другие записи той же области или группы; ничего не придумано. Только тренировка — в экзамен не входит.",
        "uz": "Noto‘g‘ri variantlar — faqat shu soha yoki guruhdagi boshqa yozuvlar; hech narsa to‘qib chiqarilmagan. Faqat mashq — imtihonga kirmaydi.",
    },
    # Xalqaro qisqartmalar barcha tillarda (canonical_terms.json).
    "tech_tlc": {"ru": "TLC (тонкослойная хроматография)"},
    "tech_gcMs": {"ru": "GC-MS"},
    "tech_hplc": {"ru": "HPLC"},
    "tech_lcMsMs": {"ru": "LC-MS/MS"},
    "tech_gcMsMs": {"ru": "GC-MS/MS"},
    "tech_lcMs": {"ru": "LC-MS"},
    "tech_gc": {"ru": "GC"},
    "tech_gcFid": {"ru": "GC-FID"},
    "tech_headspaceGc": {"ru": "Парофазная GC"},
}

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
    for key, vals in UPDATE.items():
        if key not in data:
            raise SystemExit(f"{key} missing in {p}")
        if code in vals:
            data[key] = vals[code]
    json.dump(data, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p, "a").write("\n")
print(len(K), "new keys,", len(UPDATE), "updated")
