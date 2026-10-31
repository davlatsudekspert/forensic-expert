# Ekspert Home (2026-10-31): «Ish stolim» bloki va «Bugungi ma’lumot» kartasi.
# Idempotent: kalit bo‘lsa — qiymati yangilanadi, bo‘lmasa — qo‘shiladi.
# Tartib (CLAUDE.md): … l10n_group_wording.py → l10n_expert_home.py → … → flutter gen-l10n
# Ishga tushirish:
#   cd apps/mobile && python3 tool/l10n_expert_home.py && flutter gen-l10n
# O‘zbekcha — adabiy lotin: o‘ g‘ (U+2018) va ’ (U+2019).
import collections
import json

D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)


k("workbenchTitle", "Expert Home section title: the expert's personal workbench.",
  "My workbench", "Мой рабочий стол", "Ish stolim")
k("workbenchFactTitle", "Expert Home card title: one sourced fact per day.",
  "Today’s fact", "Сведение дня", "Bugungi ma’lumot")
k("workbenchFactSource", "Label before the source line of the daily fact.",
  "Source", "Источник", "Manba")
k("workbenchFactSemantics", "Screen-reader hint for the daily fact card.",
  "Open the full entry", "Открыть полную запись",
  "To‘liq yozuvni ochish")

k("workbenchCasebookTitle", "Workbench card: personal casebook.",
  "Casebook", "Рабочий журнал", "Ish daftari")
k("workbenchCasebookBody", "Workbench card subtitle: casebook.",
  "Your case notes — on this device only",
  "Записи по вашим делам — только на устройстве",
  "Ishlaringiz bo‘yicha yozuvlar — faqat qurilmada")
k("workbenchCourtTitle", "Workbench card: court questioning preparation.",
  "Court questioning", "Допрос в суде", "Sudda so‘roq")
k("workbenchCourtBody", "Workbench card subtitle: court preparation.",
  "Prepare evidence-based answers to court questions",
  "Подготовка к вопросам суда с научным обоснованием",
  "Sud savollariga ilmiy asosli javobga tayyorgarlik")
k("workbenchCalcTitle", "Workbench card: calculators.",
  "Calculators", "Калькуляторы", "Kalkulyatorlar")
k("workbenchCalcMedBody", "Workbench card subtitle: forensic-medicine calculators.",
  "PMI, Widmark and other calculations",
  "PMI, Widmark и другие расчёты",
  "PMI, Widmark va boshqa hisoblar")
k("workbenchCalcMixedBody", "Workbench card subtitle: calculators for a mixed profile.",
  "Forensic medicine and laboratory calculations",
  "Расчёты для судебной медицины и лаборатории",
  "Sud tibbiyoti va laboratoriya hisoblari")
k("workbenchAiBody", "Workbench card subtitle: Forensic AI.",
  "Sourced answers with citations",
  "Ответы с источниками и цитатами",
  "Manbali javoblar va iqtiboslar")

k("workbenchLabTitle", "Wide workbench card for chemistry experts: laboratory methods.",
  "Laboratory methods", "Лабораторные методы", "Laboratoriya usullari")
k("workbenchLabBody", "Subtitle of the laboratory methods card.",
  "From reagents to GC-MS — in one place",
  "От реактивов до GC-MS — в одном месте",
  "Reaktivlardan GC-MS gacha — bir joyda")
k("workbenchLabReagents", "Laboratory methods item: reagents.",
  "Reagents", "Реактивы", "Reaktivlar")
k("workbenchLabReagentsSub", "Subtitle: reagents item.",
  "Solutions and recipes", "Растворы и рецептуры", "Eritmalar va retseptlar")
k("workbenchLabExpress", "Laboratory methods item: express tests.",
  "Express test analyses", "Экспресс-тесты", "Ekspress test tahlillari")
k("workbenchLabExpressSub", "Subtitle: express tests item.",
  "Screening and colour tests", "Скрининг и цветные пробы",
  "Skrining va rangli sinamalar")
k("workbenchLabSpectro", "Laboratory methods item: spectrophotometry.",
  "Spectrophotometry methods", "Спектрофотометрические методы",
  "Spektrofotometriya usullari")
k("workbenchLabSpectroSub", "Subtitle: spectrophotometry item.",
  "Beer–Lambert law", "Закон Бугера–Ламберта–Бера", "Buger–Lambert–Ber qonuni")
k("workbenchLabMs", "Laboratory methods item (and card): GC-MS / LC-MS.",
  "GC-MS / LC-MS", "GC-MS / LC-MS", "GC-MS / LC-MS")
k("workbenchLabMsSub", "Subtitle: GC-MS / LC-MS item.",
  "Chromatography and mass spectrometry",
  "Хроматография и масс-спектрометрия",
  "Xromatografiya va mass-spektrometriya")

k("workbenchSolutionTitle", "Workbench card: reagent and solution calculator.",
  "Reagent and solution calculator", "Калькулятор реактивов и растворов",
  "Reaktiv va eritma kalkulyatori")
k("workbenchSolutionBody", "Subtitle: reagent and solution calculator.",
  "Mass, dilution, concentration", "Масса, разбавление, концентрация",
  "Massa, suyultirish, konsentratsiya")
k("workbenchLodTitle", "Workbench card: LOD/LOQ and calibration.",
  "LOD/LOQ · calibration", "LOD/LOQ · калибровка", "LOD/LOQ · kalibrlash")
k("workbenchLodBody", "Subtitle: LOD/LOQ and validation.",
  "Detection limits and validation", "Пределы обнаружения и валидация",
  "Aniqlash chegarasi va validatsiya")

# --- Talaba: «O‘qish stolim» va «Bugungi savol» -------------------------------
k("studentDeskTitle", "Student Home section title: the student's study desk.",
  "My study desk", "Мой учебный стол", "O‘qish stolim")
k("deskLessonsTitle", "Study desk card: lessons and books.",
  "Lessons and books", "Уроки и книги", "Darslar va kitoblar")
k("deskLessonsBody", "Study desk card subtitle: lessons.",
  "Forensic medicine, toxicology, biochemistry",
  "Судебная медицина, токсикология, биохимия",
  "Sud tibbiyoti, toksikologiya, biokimyo")
k("deskTestsTitle", "Study desk card: self-study quizzes and flashcards.",
  "Quizzes and flashcards", "Тесты и карточки", "Testlar va kartochkalar")
k("deskTestsBody", "Study desk card subtitle: quizzes and flashcards.",
  "Check yourself and review", "Проверьте себя и повторите",
  "O‘zingizni tekshiring va takrorlang")
k("deskExamTitle", "Study desk card: exam mode.",
  "Exam mode", "Режим экзамена", "Imtihon rejimi")
k("deskExamBody", "Study desk card subtitle: exam mode.",
  "Graded questions with sources", "Оцениваемые вопросы с источниками",
  "Baholanadigan, manbali savollar")
k("deskGroupTitle", "Study desk card: my group.",
  "My group", "Моя группа", "Guruhim")
k("deskGroupBody", "Study desk card subtitle: group.",
  "Join a group and take teacher tests",
  "Вступить в группу и пройти тесты преподавателя",
  "Guruhga qo‘shiling va ustoz testlarini yeching")
k("dailyQuestionTitle", "Student Home card title: one quiz question per day.",
  "Today’s question", "Вопрос дня", "Bugungi savol")
k("dailyQuestionCorrect", "Feedback after a correct answer.",
  "Correct", "Верно", "To‘g‘ri")
k("dailyQuestionWrong", "Feedback after a wrong answer (correct option is highlighted).",
  "Not quite — the correct answer is highlighted",
  "Неверно — правильный ответ выделен",
  "Noto‘g‘ri — to‘g‘ri javob belgilangan")
k("dailyQuestionExplain", "Button: open the full explanation in the normal quiz.",
  "Full explanation and practice", "Полное объяснение и практика",
  "To‘liq izoh va mashq")


def main():
    for lang, idx in (("en", 1), ("ru", 2), ("uz", 3)):
        p = f"{D}/app_{lang}.arb"
        with open(p, encoding="utf-8") as f:
            data = json.load(f, object_pairs_hook=collections.OrderedDict)
        for key, v in K.items():
            data[key] = v[idx]
            if lang == "en":
                meta = collections.OrderedDict(description=v[0])
                if v[4]:
                    meta["placeholders"] = v[4]
                data["@" + key] = meta
        with open(p, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
    print(f"l10n_expert_home: {len(K)} keys")


if __name__ == "__main__":
    main()
