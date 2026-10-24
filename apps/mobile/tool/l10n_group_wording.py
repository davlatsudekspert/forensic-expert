# «Sinf» → «Guruh» (egasi qarori, 2026-10-24): ilovada «Sinfda test» degan joy qolmasin —
# jonli test ham «Guruh testi (jonli)» deyiladi; talaba/ustoz uchun bitta tushuncha: guruh.
# Idempotent: faqat shu kalitlarni qayta yozadi (uz/ru/en). «Modda sinfi» (kimyoviy sinf) tegilmaydi.
# CLAUDE.md tartibida: l10n_teacher_mode.py dan keyin:
#   cd apps/mobile && python3 tool/l10n_group_wording.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, en, ru, uz):
    K[key] = (en, ru, uz)


k("homeActLearnBody", "Courses, practice, group test", "Курсы, упражнения, тест для группы", "Kurslar, mashqlar, guruh testi")
k("classQuizTitle", "Group test (live)", "Тест для группы (живой)", "Guruh testi (jonli)")
k("classDemoBanner", "Demo mode: data stays on this device only. A real group test needs the server connection.",
  "Демо-режим: данные хранятся только на этом устройстве. Для настоящего теста группы нужно подключение к серверу.",
  "Demo rejim: ma’lumot faqat shu qurilmada qoladi. Haqiqiy guruh testi uchun server ulanishi kerak.")
k("classJoinSection", "Join a group test", "Войти в тест группы", "Guruh testiga qo‘shilish")
k("classJoinTitle", "Join group test", "Вход в тест группы", "Guruh testiga qo‘shilish")
k("classCodeLabel", "Test code", "Код теста", "Test kodi")
k("classCodeSpoken", "Test code {code}", "Код теста {code}", "Test kodi {code}")
k("classScanTitle", "Scan the test QR", "Сканирование QR теста", "Test QR kodini skanerlash")
k("classRecentSection", "Recent tests", "Недавние тесты", "So‘nggi testlar")
k("classPrivacyNote", "The teacher sees only your name. Finished tests are deleted automatically after 30 days. Offensive names can be reported and removed.",
  "Преподаватель видит только ваше имя. Завершённые тесты автоматически удаляются через 30 дней. На неприемлемое имя можно пожаловаться, и оно будет удалено.",
  "Ustoz faqat ismingizni ko‘radi. Tugagan testlar 30 kundan keyin avtomatik o‘chiriladi. Nomaqbul ismga shikoyat qilish mumkin, u olib tashlanadi.")
k("classCreateAction", "Start the test", "Запустить тест", "Testni boshlash")
k("classHostJoinHint", "Open FORENSIC EXPERT → Group test and enter this code, or scan the QR:",
  "Откройте FORENSIC EXPERT → Тест для группы и введите этот код или отсканируйте QR:",
  "FORENSIC EXPERT → Guruh testi bo‘limida shu kodni kiriting yoki QR kodni skanerlang:")
k("classQrSemantics", "QR code to join the test", "QR-код для входа в тест", "Testga qo‘shilish QR kodi")
k("classKickTitle", "Remove from the test?", "Убрать из теста?", "Testdan chiqarilsinmi?")
k("classCsvSubject", "Group test results", "Результаты теста группы", "Guruh testi natijalari")
k("classRetentionNote", "The test is deleted automatically {days} days after it ends.",
  "Тест автоматически удаляется через {days} дн. после завершения.",
  "Test tugagach {days} kundan keyin avtomatik o‘chiriladi.")
k("classErrNotConfigured", "Group tests will be available once the FORENSIC EXPERT server is connected.",
  "Тесты для группы станут доступны после подключения сервера FORENSIC EXPERT.",
  "Guruh testi FORENSIC EXPERT serveri ulangach ishlaydi.")
k("classErrForbidden", "You don’t have access to this test.", "У вас нет доступа к этому тесту.", "Bu testga kirish huquqingiz yo‘q.")
k("classErrNotFound", "No test with this code. Check it and try again.",
  "Тест с таким кодом не найден. Проверьте код и повторите.",
  "Bunday kodli test topilmadi. Kodni tekshirib, qayta urinib ko‘ring.")
k("classErrOwnSession", "You are the teacher of this test and can’t join it as a student.",
  "Вы преподаватель этого теста и не можете войти как студент.",
  "Siz bu testning ustozisiz, talaba sifatida qo‘shila olmaysiz.")
k("classErrKicked", "The teacher removed you from this test.", "Преподаватель убрал вас из этого теста.", "Ustoz sizni bu testdan chiqargan.")
k("classErrFull", "This test is full.", "Тест заполнен.", "Test to‘lgan.")
k("classErrTooManySessions", "Too many open tests. Finish one first.", "Слишком много открытых тестов. Сначала завершите один.", "Ochiq testlar juda ko‘p. Avval birini tugating.")
k("teacherPanelHomeBody", "Run a group test and get the results as CSV", "Проведите тест для группы и получите результаты в CSV", "Guruh testi o‘tkazing, natijalarni CSV’da oling")
k("teacherPanelHomeBodyStudent", "Join a group test with your teacher's code", "Войдите в тест группы по коду преподавателя", "Ustoz kodi bilan guruh testiga qo‘shiling")
k("teacherPanelIntro", "Run a live group test, give a topic test to a group, and see the results.",
  "Проведите живой тест для группы, дайте группе тест по теме и смотрите результаты.",
  "Jonli guruh testi o‘tkazing, guruhga mavzu testi bering va natijalarni ko‘ring.")
k("teacherRunTitle", "Group test (live)", "Тест для группы (живой)", "Guruh testi (jonli)")
k("teacherRunBody", "Pick a topic — a 6-digit code and QR appear for the group", "Выберите тему — для группы появятся 6-значный код и QR", "Mavzuni tanlang — guruh uchun 6 xonali kod va QR chiqadi")
k("teacherJoinTitle", "Join a group test (student)", "Войти в тест группы (студент)", "Guruh testiga qo‘shilish (talaba)")
k("grpMembersEmpty", "No students yet. Show the QR or code to the group.", "Студентов пока нет. Покажите группе QR или код.", "Hozircha talaba yo‘q. Guruhga QR yoki kodni ko‘rsating.")
k("grpChoiceLive", "Live group test", "Живой тест для группы", "Jonli guruh testi")

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    text = open(p, encoding="utf-8").read()
    data = json.loads(text)
    for key, vals in K.items():
        assert key in data, key
        line = f"  {json.dumps(key, ensure_ascii=False)}: {json.dumps(vals[idx], ensure_ascii=False)}"
        text = re.sub(r"(?ms)^  " + re.escape(json.dumps(key, ensure_ascii=False)) + r": .*?(,?)\n(?=  \"|\}$)",
                      lambda m: line + m.group(1) + "\n", text, count=1)
    json.loads(text)
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")
