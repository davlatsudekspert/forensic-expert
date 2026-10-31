# Anti-cheat paketi (2026-10-31): variantlar tartibi har talabaga alohida,
# savol soni ogohlantirishi, erkin soniya (5–300), «ilovadan chiqdi» va
# betaraf «tez va to‘g‘ri» ishorasi (uz/ru/en).
# Idempotent: faqat shu fayldagi kalitlarni yozadi (mavjudini yangilaydi).
# CLAUDE.md tartibida «(yangi skriptlar)» o‘rnida — l10n_group_wording.py dan
# keyin, l10n_ux_audit.py dan oldin:
#   cd apps/mobile && python3 tool/l10n_anti_cheat.py && flutter gen-l10n
# Eslatma: asl matn — o‘zbekcha; RU/EN — qo‘pol tarjima (keyingi haftada
# tahrirdan o‘tkaziladi), ARB paritet testi uchun mavjud.
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    """ph: {nom: 'int' | 'String'} — ICU o‘rinbosarlar (faqat en ARB metama’lumotida)."""
    K[key] = (desc, en, ru, uz, ph or {})


k("acShuffleHint",
  "Always-visible hint for the teacher: answer options are shuffled per student.",
  "Answer options (A, B, C, D) are shuffled for each student separately.",
  "Порядок вариантов (A, B, C, D) у каждого студента свой.",
  "Variantlar (A, B, C, D) tartibi har talabaga alohida aralashtiriladi.")
k("acCountWarning",
  "Warning shown when the question pool is smaller than twice the chosen number of questions, so students cannot get different question sets.",
  "The topic has {pool} questions. With {count} questions students will not get different sets, only a different option order. To make copying harder, keep it to {recommended} questions or fewer.",
  "В теме {pool} вопросов. При {count} вопросах у студентов не будет разных наборов, отличаться будет только порядок вариантов. Чтобы списывать было труднее, возьмите не больше {recommended} вопросов.",
  "Mavzuda {pool} ta savol bor. {count} ta savolda talabalarga turli to‘plam tushmaydi, faqat variantlar tartibi farq qiladi. Ko‘chirishni qiyinlashtirish uchun {recommended} tadan oshirmaslik tavsiya etiladi.",
  {"pool": "int", "count": "int", "recommended": "int"})
k("acStudentNote",
  "One calm line shown to the student during a test: the teacher can see leaving the app.",
  "If you leave the app during the test, your teacher can see it.",
  "Если вы выйдете из приложения во время теста, преподаватель это увидит.",
  "Test paytida ilovadan chiqsangiz, ustoz buni ko‘ra oladi.")
k("acLeftCount",
  "Teacher-only note: how many times the student left the app during the test.",
  "left the app: {count} times",
  "выходил из приложения: {count} раз",
  "ilovadan chiqdi: {count} marta",
  {"count": "int"})
k("acFastCorrect",
  "Neutral teacher-only hint: the student answered quickly with a high score. Never an accusation.",
  "fast and correct answers — worth a look",
  "быстрые и верные ответы — стоит проверить",
  "tez va to‘g‘ri javob — tekshirib ko‘ring")
k("acSecondsHint",
  "Helper text under the seconds-per-question field in live class creation.",
  "Any whole number from 5 to 300 seconds.",
  "Любое целое число от 5 до 300 секунд.",
  "5 dan 300 gacha istalgan butun son (soniya).")
k("acSecondsError",
  "Error under the seconds-per-question field when the value is outside 5-300 or not a whole number.",
  "Enter a whole number from 5 to 300.",
  "Введите целое число от 5 до 300.",
  "5 dan 300 gacha butun son kiriting.")
k("acSecondsLabel",
  "Label of the seconds-per-question text field.",
  "Seconds", "Секунды", "Soniya")
k("acSecondsMinus",
  "Accessibility label of the button that decreases the seconds per question by 5.",
  "Decrease time by 5 seconds", "Уменьшить время на 5 секунд", "Vaqtni 5 soniyaga kamaytirish")
k("acSecondsPlus",
  "Accessibility label of the button that increases the seconds per question by 5.",
  "Increase time by 5 seconds", "Увеличить время на 5 секунд", "Vaqtni 5 soniyaga oshirish")

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
                data[kk] = vv
    json.loads(text)  # hali ham to‘g‘ri JSON
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")
