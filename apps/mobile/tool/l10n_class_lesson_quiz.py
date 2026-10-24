# «Har darsdan keyin test» (2026-10-24) — yangi UI matnlari (uz/ru/en):
# savol soni chiplari, «tarjima kutilmoqda», qiyin savol muhokamasi, reyting
# qatori (to‘g‘ri soni / vaqt). Idempotent: faqat shu fayldagi kalitlarni yozadi.
# CLAUDE.md tartibida «(yangi skriptlar)» o‘rnida — l10n_class_quiz_fixes.py dan
# keyin, l10n_ux_audit.py dan oldin:
#   cd apps/mobile && python3 tool/l10n_class_lesson_quiz.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    """ph: {nom: 'int' | 'String'} — ICU o‘rinbosarlar (faqat en ARB metama’lumotida)."""
    K[key] = (desc, en, ru, uz, ph or {})


k("classQuestionCountAll", "Chip: use all questions available in the topic.",
  "All · {n}", "Все · {n}", "Hammasi · {n}", {"n": "int"})
k("classQuestionCountOther", "Chip: choose a custom number of questions (opens a slider).",
  "Other", "Другое", "Boshqa")
k("classQuestionCountLimited",
  "Shown when the topic has fewer than 20 questions: larger choices are disabled.",
  "This topic has only {n} questions, so larger choices are not available.",
  "В этой теме всего {n} вопросов, поэтому больше выбрать нельзя.",
  "Bu mavzuda faqat {n} ta savol bor, shuning uchun ko‘proq tanlab bo‘lmaydi.", {"n": "int"})
k("classTranslationPending",
  "Badge: the content exists only in Uzbek (original); the translation is not ready yet. Not a machine translation.",
  "Translation pending — original Uzbek text",
  "Перевод ожидается — показан оригинал на узбекском",
  "Tarjima kutilmoqda — asl o‘zbekcha matn")
k("classHardestOpenHint", "Hint under the hardest-questions card: tap a question to discuss it.",
  "Tap a question to discuss it", "Нажмите на вопрос для обсуждения",
  "Muhokama uchun savolni bosing")
k("classDiscussTitle", "Title of the hardest-question discussion page.",
  "Question discussion", "Обсуждение вопроса", "Savol muhokamasi")
k("classDiscussPosition", "Position among the hardest questions, e.g. 'Hard question 1 / 3'.",
  "Hard question {n} / {total}", "Сложный вопрос {n} / {total}", "Qiyin savol {n} / {total}",
  {"n": "int", "total": "int"})
k("classDiscussWrongPct", "Share of wrong answers (no student names).",
  "{pct}% wrong", "{pct}% ошибок", "{pct}% xato", {"pct": "int"})
k("classDiscussAnswered", "How many students answered this question.",
  "{n} answers", "Ответов: {n}", "{n} ta javob", {"n": "int"})
k("classDiscussCorrectMark", "Screen-reader label and badge for the correct option.",
  "Correct answer", "Правильный ответ", "To‘g‘ri javob")
k("classDiscussExplanation", "Section label: explanation of the answer.",
  "Explanation", "Объяснение", "Tushuntirish")
k("classDiscussNoExplanation", "Shown when a question has no explanation text.",
  "No explanation for this question.", "Для этого вопроса нет объяснения.",
  "Bu savol uchun tushuntirish yo‘q.")
k("classDiscussSource", "Section label: source (author, title, page).",
  "Source", "Источник", "Manba")
k("classDiscussPrev", "Button: previous hard question.",
  "Previous", "Предыдущий", "Oldingi")
k("classDiscussNext", "Button: next hard question.",
  "Next", "Следующий", "Keyingi")
k("classDiscussUnavailable",
  "Shown when option/explanation/source details cannot be loaded (old server or no connection).",
  "Details are not available right now. Showing the question text and wrong-answer share only.",
  "Подробности сейчас недоступны. Показаны только текст вопроса и доля ошибок.",
  "Tafsilot hozir mavjud emas. Faqat savol matni va xato foizi ko‘rsatilmoqda.")
k("classDiscussBigFont", "Toggle: larger text for the projector.",
  "Large text", "Крупный шрифт", "Katta shrift")
k("classDiscussPicked", "Number of students who picked this option.",
  "{n} chose this", "Выбрали: {n}", "{n} ta tanladi", {"n": "int"})
k("classDiscussClose", "Tooltip: close the discussion page.",
  "Close", "Закрыть", "Yopish")
k("classLeaderCorrect", "Leaderboard row: correct answers out of all questions.",
  "{correct}/{total} correct", "{correct}/{total} верно", "{correct}/{total} to‘g‘ri",
  {"correct": "int", "total": "int"})
k("classLeaderAvgTime", "Leaderboard row: average time of correct answers, seconds as text.",
  "avg {seconds} s", "в среднем {seconds} с", "o‘rt. {seconds} s", {"seconds": "String"})

# Matnli qo‘shish (json.dump faylning qolgan formatini o‘zgartirmasin).
for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    text = open(p, encoding="utf-8").read()
    data = json.loads(text)
    for key, (desc, en, ru, uz, ph) in K.items():
        val = (en, ru, uz)[idx]
        entries = [(key, val)]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = {n: {"type": t} for n, t in ph.items()}
            entries.append(("@" + key, meta))
        for kk, vv in entries:
            line = f"  {json.dumps(kk, ensure_ascii=False)}: {json.dumps(vv, ensure_ascii=False)}"
            if kk in data:
                text = re.sub(r"(?ms)^  " + re.escape(json.dumps(kk, ensure_ascii=False)) + r": .*?(,?)\n(?=  \"|\}$)",
                              lambda m: line + m.group(1) + "\n", text, count=1)
            else:
                body = text.rstrip()
                assert body.endswith("}")
                text = body[:-1].rstrip() + ",\n" + line + "\n}\n"
    json.loads(text)  # hali ham to‘g‘ri JSON
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")
