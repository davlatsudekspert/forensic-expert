# «Har kim o‘z tezligida» (2026-10-31) — jonli sinf testi uchun self-paced
# rejimi: rejim tanlovi, talaba o‘z-o‘zidan o‘tish matnlari, ustoz progress
# doskasi (uz/ru/en). Idempotent: faqat shu fayldagi kalitlarni yozadi.
# CLAUDE.md tartibida «(yangi skriptlar)» o‘rnida — l10n_group_wording.py dan
# keyin, l10n_ux_audit.py dan oldin:
#   cd apps/mobile && python3 tool/l10n_class_self_pace.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    """ph: {nom: 'int' | 'String'} — ICU o‘rinbosarlar (faqat en ARB metama’lumotida)."""
    K[key] = (desc, en, ru, uz, ph or {})


k("classPaceSection", "Section header on the new-test screen: who controls the pace of the quiz.",
  "Quiz mode", "Режим теста", "Test rejimi")
k("classPaceHost", "Mode option: the teacher controls the questions and the time for everyone (default).",
  "Teacher controls", "Ведёт преподаватель", "Ustoz boshqaradi")
k("classPaceHostHint", "One-line explanation under the 'teacher controls' option.",
  "Everyone is on the same question; the time is shared.",
  "Все на одном вопросе, время общее.",
  "Hamma bir savolda, vaqt umumiy.")
k("classPaceSelf", "Mode option: every student works at their own speed.",
  "Everyone at their own pace", "Каждый в своём темпе", "Har kim o‘z tezligida")
k("classPaceSelfHint", "One-line explanation under the self-paced option.",
  "Each student's time starts from their own start.",
  "У каждого студента время идёт с его собственного старта.",
  "Har talabaning vaqti o‘zidan boshlanadi.")
k("classPaceLine", "Line in the lobby: which mode this quiz uses, e.g. 'Mode: Teacher controls'.",
  "Mode: {mode}", "Режим: {mode}", "Rejim: {mode}", {"mode": "String"})
k("classLobbySelfHint", "Student lobby hint in self-paced mode.",
  "Everyone works at their own pace: after the teacher starts, you open the questions yourself.",
  "Каждый работает в своём темпе: после старта преподавателя вы сами открываете вопросы.",
  "Har kim o‘z tezligida ishlaydi: ustoz boshlagach, savollarni o‘zingiz ochasiz.")
k("classErrNotClosed", "Error: tried to go to the next question before answering and before the own time ran out.",
  "Answer this question first, or wait until your time runs out.",
  "Сначала ответьте на этот вопрос или дождитесь конца времени.",
  "Avval shu savolga javob bering yoki vaqt tugashini kuting.")
k("classSelfReadyTitle", "Self-paced student screen before the first question.",
  "Ready?", "Готовы?", "Tayyormisiz?")
k("classSelfReadyBody", "Explains the own timer in self-paced mode; seconds per question.",
  "{seconds} seconds per question. Your time starts when you open a question, and you move on by yourself.",
  "{seconds} секунд на вопрос. Время идёт с момента, когда вы открыли вопрос, дальше вы переходите сами.",
  "Har savolga {seconds} soniya. Vaqt savolni ochganingizdan boshlanadi, keyingisiga o‘zingiz o‘tasiz.", {"seconds": "int"})
k("classSelfStart", "Button: open the first question (the timer starts).",
  "Start", "Начать", "Boshlash")
k("classSelfNext", "Button: go to the next question yourself.",
  "Next question", "Следующий вопрос", "Keyingi savol")
k("classSelfFinish", "Button after the last question: finish my part of the quiz.",
  "Finish", "Завершить", "Yakunlash")
k("classAnswerFlowHint", "Small hint under the answer options of quizzes (group test and self-paced live quiz): choose, confirm, move on yourself.",
  "Choose an answer and press «Confirm». You move to the next question yourself.",
  "Выберите ответ и нажмите «Подтвердить». К следующему вопросу вы переходите сами.",
  "Javobni tanlang va «Tasdiqlash»ni bosing. Keyingi savolga o‘zingiz o‘tasiz.")
k("grpScoreReadyNote", "Group test result screen: the score is ready (answers are still locked; the existing reveal note follows).",
  "Your score is ready.", "Ваш балл готов.", "Balingiz tayyor.")
k("classSelfResultWait", "Shown after the own answer: the student decides when to move on.",
  "Read the result, then move on when you are ready.",
  "Прочитайте результат и переходите дальше, когда будете готовы.",
  "Natijani o‘qing va tayyor bo‘lganda keyingisiga o‘ting.")
k("classSelfDoneTitle", "Self-paced student finished all questions.",
  "You have finished all questions", "Вы ответили на все вопросы", "Siz hamma savolni tugatdingiz")
k("classSelfDoneBody", "The overall leaderboard appears when the teacher ends the quiz.",
  "Your result is below. The overall leaderboard appears when the teacher ends the quiz.",
  "Ваш результат ниже. Общий рейтинг появится, когда преподаватель завершит тест.",
  "Natijangiz quyida. Umumiy reyting ustoz testni tugatgach chiqadi.")
k("classBoardTitle", "Teacher board header in self-paced mode.",
  "Student progress", "Прогресс студентов", "Talabalar progressi")
k("classBoardHint", "Teacher hint in self-paced mode.",
  "Everyone works at their own pace. End the quiz when you are ready.",
  "Каждый работает в своём темпе. Завершите тест, когда будете готовы.",
  "Har kim o‘z tezligida ishlamoqda. Tayyor bo‘lganda testni tugating.")
k("classBoardSummary", "Teacher summary: how many students started and finished, out of all.",
  "{opened} started · {done} finished · {joined} in total",
  "Начали: {opened} · закончили: {done} · всего: {joined}",
  "{opened} ta boshladi · {done} ta tugatdi · jami {joined} ta",
  {"opened": "int", "done": "int", "joined": "int"})
k("classBoardAllDone", "Teacher banner: every student finished.",
  "Everyone has finished — you can end the quiz.",
  "Все закончили — можно завершать тест.",
  "Hamma tugatdi — testni tugatishingiz mumkin.")
k("classBoardNotStarted", "Row status: the student has not opened the first question yet.",
  "Not started", "Ещё не начал", "Hali boshlamagan")
k("classBoardDone", "Row status: the student finished all questions.",
  "Finished", "Закончил", "Tugatdi")
k("classBoardAnsweredCorrect", "Row detail: correct answers out of answered questions.",
  "{correct}/{answered} correct", "{correct}/{answered} верно", "{correct}/{answered} to‘g‘ri",
  {"correct": "int", "answered": "int"})

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
