# «100 ballik natija va taxminiy baho» + «Oraliq nazorat» (2026-10-31) — yangi UI
# matnlari (uz/ru/en). Baho tartibi: PF-191, 2026-2027 o‘quv yili (taxminiy baho,
# rasmiy emas). Idempotent: faqat shu fayldagi kalitlarni yozadi.
# CLAUDE.md tartibida «(yangi skriptlar)» o‘rnida — l10n_teacher_card.py dan
# keyin, l10n_ux_audit.py dan oldin:
#   cd apps/mobile && python3 tool/l10n_scoring.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    """ph: {nom: 'int' | 'String'} — ICU o‘rinbosarlar (faqat en ARB metama’lumotida)."""
    K[key] = (desc, en, ru, uz, ph or {})


k("scoringScore100Label", "Label of the 100-point score (correct answers / questions x 100).",
  "Score (100)", "Балл (100)", "Ball (100)")
k("scoringGradeLabel", "Label of the approximate grade.",
  "Grade", "Оценка", "Baho")
k("scoringGradeApproxTitle",
  "Heading above the approximate grade; year is the academic year of the grading order.",
  "Approximate grade (per the {year} order)",
  "Ориентировочная оценка (по порядку {year})",
  "Taxminiy baho ({year} tartibi bo‘yicha)", {"year": "String"})
k("scoringGradeBelowMin",
  "Grade label when the score is below the minimum pass score (70.0). Must not sound like failure or debt.",
  "Below the minimum pass score", "Ниже минимального проходного балла",
  "Minimal o‘tish balidan past")
k("scoringApproxNote",
  "One-time note on result screens: the grade is an estimate made by the app, not official.",
  "This grade is an estimate calculated by the app from the share of correct answers (100-point scale; minimum pass score {minPass}). It is not an official grade.",
  "Это ориентировочная оценка, рассчитанная приложением по доле правильных ответов (100-балльная шкала; минимальный проходной балл {minPass}). Это не официальная оценка.",
  "Bu baho ilova to‘g‘ri javoblar ulushidan hisoblagan taxminiy baho (100 ballik shkala; minimal o‘tish bali {minPass}). Rasmiy baho emas.",
  {"minPass": "String"})
k("scoringRowLine",
  "Teacher result row: 100-point score and grade of a student.",
  "Score (100): {score} · Grade: {grade}",
  "Балл (100): {score} · Оценка: {grade}",
  "Ball (100): {score} · Baho: {grade}", {"score": "String", "grade": "String"})
k("scoringSpeedPointsNote",
  "Caption in the live class result: speed points are only for the class ranking.",
  "Speed points count only for the class ranking.",
  "Баллы за скорость учитываются только в рейтинге класса.",
  "Tezlik ballari faqat sinf reytingi uchun.")

# --- «Oraliq nazorat» ---
k("scoringMidtermTitle", "Title of the one-tap midterm preset card and the test-name prefix.",
  "Midterm check", "Промежуточный контроль", "Oraliq nazorat")
k("scoringMidtermIntro",
  "Intro of the midterm preset card: pick a course; all its topics are selected automatically.",
  "Pick a course: all its topics are selected automatically. Defaults: up to {count} questions, {minutes} minutes, open for {days} day. You can edit everything before creating.",
  "Выберите курс: все его темы выбираются автоматически. По умолчанию: до {count} вопросов, {minutes} минут, открыт {days} день. Всё можно изменить перед созданием.",
  "Kursni tanlang: uning barcha mavzulari avtomatik tanlanadi. Standart: {count} tagacha savol, {minutes} daqiqa, {days} kun ochiq. Yaratishdan oldin hammasini tahrirlash mumkin.",
  {"count": "int", "minutes": "int", "days": "int"})
k("scoringMidtermCourseLine", "Subtitle of a course button: number of topics and questions.",
  "{topics} topics · {questions} questions", "{topics} тем · {questions} вопросов",
  "{topics} ta mavzu · {questions} ta savol", {"topics": "int", "questions": "int"})
k("scoringMidtermApplied",
  "Confirmation after choosing a course in the midterm preset.",
  "Midterm check set up for “{course}”: all topics selected. Review the settings below.",
  "Промежуточный контроль для «{course}»: выбраны все темы. Проверьте настройки ниже.",
  "«{course}» uchun oraliq nazorat tayyor: barcha mavzular tanlandi. Sozlamalarni pastda tekshiring.",
  {"course": "String"})
k("scoringMidtermPoolShort",
  "Shown when the course has fewer questions than the default count; the count was reduced.",
  "The course has only {pool} questions, so the number of questions is set to {pool}.",
  "В курсе всего {pool} вопросов, поэтому количество вопросов установлено {pool}.",
  "Kursda faqat {pool} ta savol bor, shuning uchun savollar soni {pool} qilindi.",
  {"pool": "int"})
k("scoringMidtermVariantOff",
  "Shown when per-student variants were switched off because the pool is smaller than twice the question count.",
  "Variants are off: the question pool ({pool}) is smaller than twice the number of questions per student. Set {max} questions or fewer to turn variants on.",
  "Варианты выключены: банк вопросов ({pool}) меньше удвоенного числа вопросов на студента. Установите {max} вопросов или меньше, чтобы включить варианты.",
  "Variantlar o‘chirildi: savollar hovuzi ({pool}) har talabaga beriladigan savollar sonining ikki baravaridan kam. Variantlarni yoqish uchun savollar sonini {max} yoki undan kam qiling.",
  {"pool": "int", "max": "int"})
k("scoringMidtermVariantOn",
  "Shown when per-student variants are on in the midterm preset.",
  "Each student gets a different set of questions (variants are on).",
  "Каждый студент получает свой набор вопросов (варианты включены).",
  "Har talaba boshqa savollar to‘plamini oladi (variantlar yoqilgan).")

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
