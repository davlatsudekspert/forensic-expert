# «Dars oxirida Guruh testi» (2026-10-24, egasi qarori) — yangi UI matnlari (uz/ru/en):
# dars → guruh testi oqimi, jonli doska ustunlari (o‘rin, to‘g‘ri soni, vaqt),
# qiyin savollar bloki; talaba endi «taxallus» emas, o‘z ISMI bilan qo‘shiladi.
# Idempotent: faqat shu fayldagi kalitlarni yozadi (eski grp* kalitlarini
# qayta yozadi: taxallus → ism).
# CLAUDE.md tartibida «(yangi skriptlar)» o‘rnida — l10n_class_lesson_quiz.py dan
# keyin, l10n_ux_audit.py dan oldin:
#   cd apps/mobile && python3 tool/l10n_group_lesson_test.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    """ph: {nom: 'int' | 'String'} — ICU o‘rinbosarlar (faqat en ARB metama’lumotida)."""
    K[key] = (desc, en, ru, uz, ph or {})


# ---- dars → guruh testi
k("grpLessonGroupTest", "Lesson test choice: primary button, give the test to a group.",
  "Give a test to a group", "Дать тест группе", "Guruhga test berish")
k("grpLessonGroupTestHint", "Lesson test choice: hint under the primary button.",
  "Students join by QR; results appear on screen by name, with places.",
  "Студенты входят по QR; результаты на экране по именам, с местами.",
  "Talabalar QR bilan qo‘shiladi; natijalar ekranda ism bo‘yicha, o‘rinlari bilan ko‘rinadi.")
k("grpLessonTitle", "Screen title: group test after a lesson.",
  "Group test", "Тест для группы", "Guruh testi")
k("grpLessonGroupSection", "Section: which group.",
  "Group", "Группа", "Guruh")
k("grpLessonNewGroup", "Button: create another group inline.",
  "New group", "Новая группа", "Yangi guruh")
k("grpLessonNoGroups", "Hint when the teacher has no group yet.",
  "You have no group yet. Type a name — the group is created right here.",
  "У вас пока нет группы. Введите название — группа создастся прямо здесь.",
  "Hali guruhingiz yo‘q. Nom yozing — guruh shu yerning o‘zida yaratiladi.")
k("grpLessonCreateGroup", "Button: create the group inline.",
  "Create group", "Создать группу", "Guruh yaratish")
k("grpLessonCancelNew", "Button: back to the list of groups.",
  "Pick an existing group", "Выбрать существующую", "Mavjud guruhni tanlash")
k("grpLessonTopicSection", "Section: topic of the test (fixed to the lesson).",
  "Topic (from this lesson)", "Тема (из этого урока)", "Mavzu (shu darsdan)")
k("grpLessonTopicFixed", "Note under the topic: it cannot be changed here.",
  "The test is built from this lesson’s topic.",
  "Тест составляется по теме этого урока.",
  "Test shu dars mavzusi bo‘yicha tuziladi.")
k("grpLessonNoTopic", "Error: no test topic for the lesson.",
  "No test questions were found for this lesson.",
  "Для этого урока не найдено вопросов теста.",
  "Bu dars uchun test savollari topilmadi.")
k("grpLessonStart", "Button: create the test and show QR.",
  "Start the test", "Начать тест", "Testni boshlash")
k("grpLessonPickGroup", "Error: no group chosen.",
  "Choose a group first.", "Сначала выберите группу.", "Avval guruhni tanlang.")
k("grpLessonStartedTitle", "Title after the test is created.",
  "The test has started", "Тест начался", "Test boshlandi")
k("grpLessonStartedHint", "Hint next to the QR after the test is created.",
  "Students scan the QR or enter the code. They join the group under their own name and the test opens.",
  "Студенты сканируют QR или вводят код. Они входят в группу под своим именем, и тест открывается.",
  "Talabalar QR kodni skanerlaydi yoki kodni kiritadi. Ular o‘z ismi bilan guruhga qo‘shiladi va test ochiladi.")
k("grpLessonLiveResults", "Button: open the live results board.",
  "Live results", "Живые результаты", "Jonli natijalar")
k("grpLessonTeacherPanel", "Button: open the teacher panel of the test.",
  "Teacher panel", "Панель преподавателя", "Ustoz paneli")
k("grpLessonJoinLink", "Small label above the join link.",
  "Group code", "Код группы", "Guruh kodi")

# ---- jonli doska
k("grpColRank", "Board column: place.", "Place", "Место", "O‘rin")
k("grpColName", "Board column: student name.", "Name", "Имя", "Ism")
k("grpColCorrect", "Board column: correct answers / total.",
  "Correct", "Верно", "To‘g‘ri")
k("grpColTime", "Board column: time spent.", "Time", "Время", "Vaqt")
k("grpColState", "Board column: state.", "Status", "Статус", "Holat")
k("grpRankSpoken", "Screen reader: place of a student.",
  "Place {rank}", "Место {rank}", "{rank}-o‘rin", {"rank": "int"})
k("grpBoardClosed", "Big board: banner after the test was closed.",
  "The test is closed", "Тест закрыт", "Test yopildi")

# ---- qiyin savollar
k("grpHardestTitle", "Block title: hardest questions after closing.",
  "Hard questions", "Трудные вопросы", "Qiyin savollar")
k("grpHardestBody", "Block body: discuss the hardest questions together.",
  "The questions most students got wrong, picked automatically. Discuss them together.",
  "Вопросы, в которых чаще всего ошибались; выбраны автоматически. Разберите их вместе.",
  "Eng ko‘p xato qilingan savollar avtomatik tanlandi. Ularni birgalikda muhokama qiling.")
k("grpHardestOpen", "Button: open the discussion.",
  "Discuss hard questions", "Разобрать трудные вопросы", "Qiyin savollarni muhokama qilish")
k("grpHardestLocked", "Hint before the test is closed.",
  "Close the test to see the hard questions here.",
  "Закройте тест — трудные вопросы появятся здесь.",
  "Testni yopsangiz, qiyin savollar shu yerda chiqadi.")
k("grpErrNotFinished", "Error: hard questions requested before the test was closed.",
  "Hard questions appear after the test is closed.",
  "Трудные вопросы появятся после закрытия теста.",
  "Qiyin savollar test yopilgandan keyin ko‘rinadi.")

# ---- talaba ISMI (taxallus o‘rniga) — mavjud kalitlar qayta yoziladi
k("grpNickLabel", "Field: the student's name in the group.",
  "Your name", "Ваше имя", "Ismingiz")
k("grpNickHelper", "Helper under the name field.",
  "Filled in from your profile — change it if you like. 2–20 characters, asked only once. The teacher and the group see this name (never your e-mail).",
  "Подставлено из профиля — при желании измените. 2–20 символов, спрашиваем один раз. Преподаватель и группа видят это имя (e-mail — никогда).",
  "Profilingizdan olindi — xohlasangiz o‘zgartiring. 2–20 belgi, faqat bir marta so‘raladi. Ustoz va guruh shu ismni ko‘radi (email hech qachon ko‘rinmaydi).")
k("grpNickNeeded", "Error: name needed to join.",
  "Enter your name to join.", "Введите имя, чтобы вступить.", "Qo‘shilish uchun ismingizni yozing.")
k("grpMyNickname", "Group card: my name.",
  "My name: {nickname}", "Моё имя: {nickname}", "Ismim: {nickname}", {"nickname": "String"})
k("grpPrivacyNote", "Privacy note on the group screen.",
  "The teacher and your group see your name and score — never your e-mail. Other students don’t see your answers.",
  "Преподаватель и ваша группа видят ваше имя и балл — e-mail никогда. Другие студенты не видят ваши ответы.",
  "Ustoz va guruhingiz ismingiz va ballingizni ko‘radi — emailingizni hech qachon. Boshqa talabalar javoblaringizni ko‘rmaydi.")
k("grpTestQrHint", "Hint next to the group QR.",
  "Students scan it; their name is filled in automatically — and the test opens.",
  "Студенты сканируют его; имя подставляется автоматически — и тест открывается.",
  "Talabalar skanerlaydi; ism avtomatik yoziladi — test ochiladi.")
k("grpErrNickLength", "Error: name length.",
  "The name must be 2–20 characters.", "Имя должно содержать 2–20 символов.",
  "Ism 2–20 belgidan iborat bo‘lishi kerak.")
k("grpErrNickBlocked", "Error: name blocked by the filter.",
  "Please write a different name.", "Напишите другое имя.", "Boshqa ism yozing.")
k("grpErrNickTaken", "Error: name already used in the group.",
  "This name is already in the group. Add the first letter of your surname.",
  "Такое имя в группе уже есть. Добавьте первую букву фамилии.",
  "Bu ism guruhda band. Familiyaning bosh harfini qo‘shing.")

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
        data = json.loads(text)
    json.loads(text)  # hali ham to‘g‘ri JSON
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")
