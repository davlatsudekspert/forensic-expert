# «Ustoz» rejimi va fan sahifasidagi «Darslar» bo‘limi (2026-10-24, egasi topshirig‘i):
# onboarding/sozlamalarda uchinchi rejim — Ustoz; fan (Sud tibbiyoti, Sud
# toksikologiyasi) sahifasida shu fan prezentatsiyalari va har dars ostida
# «Guruh testi». Idempotent: faqat shu fayldagi kalitlarni yozadi.
# CLAUDE.md tartibida: l10n_group_lesson_test.py dan keyin, l10n_ux_audit.py dan oldin:
#   cd apps/mobile && python3 tool/l10n_teacher_mode.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph or {})


k("modeTeacher", "Usage mode card: teacher.", "Teacher", "Преподаватель", "Ustoz")
k("modeTeacherDescription", "Usage mode card: teacher, who it is for.",
  "Lecturers: lecture decks by discipline, a group test after every topic, live results with places",
  "Преподаватели: презентации по дисциплинам, тест для группы после каждой темы, живые результаты с местами",
  "O‘qituvchilar: fan bo‘yicha prezentatsiyalar, har mavzudan keyin guruh testi, jonli natijalar va o‘rinlar")
k("modeTeacherNote", "Note under the teacher mode card: server role is required for lessons.",
  "Lessons and tests open with the teacher role on the server. The role is granted by the administrator — see the note in the Teacher panel.",
  "Уроки и тесты открываются с ролью преподавателя на сервере. Роль выдаёт администратор — см. примечание в Панели преподавателя.",
  "Darslar va testlar serverdagi ustoz roli bilan ochiladi. Rolni administrator beradi — Ustoz panelidagi izohga qarang.")
k("disciplineLessonsTitle", "Discipline page section: lecture decks of this discipline with a group test under each.",
  "Lessons: presentation and group test", "Уроки: презентация и тест для группы", "Darslar: prezentatsiya va guruh testi")
k("disciplineLessonsBody", "Discipline page section hint. {count} lessons.",
  "{count} lessons. Open a lesson — at the end, «Give a test to a group»: students join by QR, results by name with places, hard questions for discussion.",
  "{count} уроков. Откройте урок — в конце «Дать тест группе»: студенты входят по QR, результаты по именам с местами, трудные вопросы для разбора.",
  "{count} ta dars. Darsni oching — oxirida «Guruhga test berish»: talabalar QR bilan kiradi, natijalar ism bo‘yicha o‘rinlari bilan, qiyin savollar muhokamaga.",
  {"count": "int"})
k("disciplineLessonGroupTest", "Tooltip/button on a lesson row: start a group test on this topic right away.",
  "Group test", "Тест для группы", "Guruh testi")
k("disciplineLessonsTeacherOnly", "Discipline page note for teacher mode without the server role.",
  "Lessons and group tests open with the teacher role. Open the Teacher panel to see how to get it.",
  "Уроки и тесты для группы открываются с ролью преподавателя. Откройте Панель преподавателя — там написано, как её получить.",
  "Darslar va guruh testlari ustoz roli bilan ochiladi. Ustoz panelini oching — rolni olish tartibi yozilgan.")
k("homeInstrumentsTitle", "Home tile (professional/teacher): instrument course.",
  "Working with instruments", "Работа на приборах", "Apparatlar bilan ishlash")
k("homeInstrumentsBody", "Home tile body: instrument course contents.",
  "Ethanol by GC (Kristallyuks), COHb on UV-1900, GC-MS basics: procedure, photos, test",
  "Этанол на ГХ (Кристаллюкс), COHb на UV-1900, основы ГХ-МС: порядок работы, фото, тест",
  "GC da etanol (Kristallyuks), UV-1900 da COHb, GX-MS asoslari: ish tartibi, rasmlar, test")
k("lessonsForbidden", "Lessons: this lesson needs the teacher role (open courses are for everyone).",
  "This lesson opens with the teacher role. The «Working with instruments» course is open to everyone.",
  "Этот урок открывается с ролью преподавателя. Курс «Работа на приборах» открыт всем.",
  "Bu dars ustoz roli bilan ochiladi. «Apparatlar bilan ishlash» kursi hammaga ochiq.")
k("lessonsOpenNote", "Lessons list note for a signed-in user without the teacher role.",
  "You see the open courses. Lecture decks for teaching open with the teacher role.",
  "Вам показаны открытые курсы. Лекционные презентации открываются с ролью преподавателя.",
  "Sizga ochiq kurslar ko‘rsatilgan. Ma’ruza prezentatsiyalari ustoz roli bilan ochiladi.")
k("disciplineLessonsAll", "Link at the end of the discipline lessons section: full list.",
  "All lessons", "Все уроки", "Barcha darslar")

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
    json.loads(text)
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")
