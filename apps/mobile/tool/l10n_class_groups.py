# «Ustoz–talaba testi» (guruhlar va mavzu testlari) — UI matnlari (uz/ru/en).
# Idempotent: kalitlar qayta yoziladi. CLAUDE.md tartibida «(yangi skriptlar)»
# joyida — l10n_class_quiz.py dan keyin, l10n_ux_audit.py dan oldin:
#   cd apps/mobile && python3 tool/l10n_class_groups.py && flutter gen-l10n
# RU/EN — egasi qaroriga ko'ra (2026-10-12) UI matni uch tilda; kontent emas.
import collections
import json

D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)


I = {"type": "int"}
S = {"type": "String"}

# --- jonli testdan farqlash (Ustoz paneli)
k("teacherRunTitle", "Teacher panel: live quiz tile.", "Class quiz (live)", "Тест в классе (живой)", "Sinfda test (jonli)")
k("teacherPanelIntro", "Teacher panel intro.", "Run a live class quiz, give a topic test to a group, and see the results.", "Проведите живой тест в классе, дайте группе тест по теме и смотрите результаты.", "Sinfda jonli test o‘tkazing, guruhga mavzu testi bering va natijalarni ko‘ring.")

# --- umumiy
k("grpTitle", "Feature title.", "Groups and topic tests", "Группы и тесты по темам", "Guruhlar va mavzu testlari")
k("grpEntrySubtitle", "Learn hub card subtitle.", "Your teacher’s groups: topic tests with a deadline", "Группы преподавателя: тесты по темам со сроком", "Ustoz guruhlari: muddatli mavzu testlari")
k("grpTeacherTileBody", "Teacher tile body.", "Create a group, give a topic test, follow results live", "Создайте группу, дайте тест по теме, следите за результатами", "Guruh yarating, mavzu testi bering, natijani jonli kuzating")
k("grpStudentTileBody", "Student tile body.", "Join your teacher’s group with a code or QR", "Вступите в группу преподавателя по коду или QR", "Ustoz guruhiga kod yoki QR bilan qo‘shiling")
k("grpIntro", "Home intro.", "The teacher gives a topic test to the group. You solve it in your own time before the deadline; the server counts the score.", "Преподаватель даёт группе тест по теме. Вы решаете его в удобное время до срока; баллы считает сервер.", "Ustoz guruhga mavzu testi beradi. Siz uni muddatgacha o‘zingizga qulay vaqtda yechasiz; ballni server hisoblaydi.")
k("grpDemoBanner", "Demo banner.", "Demo mode: data stays on this device only. Real groups need the server connection.", "Демо-режим: данные только на этом устройстве. Для настоящих групп нужно подключение к серверу.", "Demo rejim: ma’lumot faqat shu qurilmada. Haqiqiy guruhlar uchun server ulanishi kerak.")
k("grpPrivacyNote", "Privacy note.", "The teacher sees only your nickname and score — not your name or e-mail. Other students don’t see your result.", "Преподаватель видит только ваш псевдоним и баллы — не имя и не e-mail. Другие студенты ваш результат не видят.", "Ustoz faqat taxallusingiz va ballingizni ko‘radi — ismingiz va emailingizni emas. Boshqa talabalar natijangizni ko‘rmaydi.")
k("grpSignInTitle", "Sign-in card.", "Sign in to join", "Войдите, чтобы вступить", "Qo‘shilish uchun hisobga kiring")
k("grpSignInBody", "Sign-in body.", "Only registered accounts can join a group — your result is tied to your account. The invite is kept while you sign in.", "Вступить в группу могут только зарегистрированные аккаунты — результат привязан к аккаунту. Приглашение сохранится, пока вы входите.", "Guruhga faqat ro‘yxatdan o‘tgan hisob qo‘shiladi — natija hisobingizga bog‘lanadi. Kirish davomida taklif saqlanib turadi.")
k("grpSignInAction", "Button.", "Sign in", "Войти", "Hisobga kirish")
k("grpJoinByCode", "Button.", "Join with a code", "Вступить по коду", "Kod bilan qo‘shilish")
k("grpScanAction", "Button.", "Scan QR", "Сканировать QR", "QR skanerlash")
k("grpScanTitle", "Scan screen title.", "Scan group QR", "Сканирование QR группы", "Guruh QR kodini skanerlash")
k("grpScanHint", "Scan hint.", "Point the camera at the QR on the teacher’s screen.", "Наведите камеру на QR на экране преподавателя.", "Kamerani ustoz ekranidagi QR kodga qarating.")
k("grpTeachingSection", "Section.", "My groups (teacher)", "Мои группы (преподаватель)", "Mening guruhlarim (ustoz)")
k("grpMemberSection", "Section.", "Groups I’m in", "Группы, где я состою", "Men a’zo guruhlar")
k("grpTeachingEmpty", "Empty.", "No groups yet. Create one and share its code or QR with students.", "Групп пока нет. Создайте группу и покажите студентам её код или QR.", "Hozircha guruh yo‘q. Guruh yarating va kodini yoki QR kodini talabalarga ko‘rsating.")
k("grpMemberEmpty", "Empty.", "You haven’t joined a group yet. Ask your teacher for the code or scan the QR.", "Вы ещё не вступили в группу. Попросите код у преподавателя или отсканируйте QR.", "Hali guruhga qo‘shilmagansiz. Ustozdan kodni so‘rang yoki QR kodni skanerlang.")
k("grpMembersCount", "Members count.", "Students: {count} / {limit}", "Студентов: {count} / {limit}", "Talabalar: {count} / {limit}", {"count": I, "limit": I})
k("grpMyNickname", "Student nickname line.", "My nickname: {nickname}", "Мой псевдоним: {nickname}", "Taxallusim: {nickname}", {"nickname": S})
k("grpRetry", "Button.", "Try again", "Повторить", "Qayta urinish")
k("grpRefresh", "Button.", "Refresh", "Обновить", "Yangilash")
k("grpCancel", "Button.", "Cancel", "Отмена", "Bekor qilish")
k("grpOk", "Button.", "OK", "Хорошо", "Yaxshi")

# --- guruh yaratish
k("grpCreateAction", "Button.", "Create group", "Создать группу", "Guruh yaratish")
k("grpCreateTitle", "Screen title.", "New group", "Новая группа", "Yangi guruh")
k("grpNameLabel", "Field.", "Group name", "Название группы", "Guruh nomi")
k("grpNameHelper", "Helper.", "For example: “4th year, group 2”. Students see this name.", "Например: «4 курс, 2 группа». Студенты видят это название.", "Masalan: «4-kurs, 2-guruh». Talabalar shu nomni ko‘radi.")

# --- guruh sahifasi
k("grpAssignAction", "Primary button.", "Give a topic test", "Дать тест по теме", "Mavzu testi berish")
k("grpInviteTitle", "Invite panel.", "Invite code", "Код приглашения", "Taklif kodi")
k("grpInviteHint", "Invite hint.", "Students scan the QR or enter the code in Learn → Groups.", "Студенты сканируют QR или вводят код в разделе Учёба → Группы.", "Talabalar QR kodni skanerlaydi yoki kodni O‘qish → Guruhlar bo‘limida kiritadi.")
k("grpCopyCode", "Button.", "Copy code", "Копировать код", "Kodni nusxalash")
k("grpCodeCopied", "Snackbar.", "Code copied", "Код скопирован", "Kod nusxalandi")
k("grpCodeSpoken", "Screen reader.", "Group code {code}", "Код группы {code}", "Guruh kodi {code}", {"code": S})
k("grpTestsSection", "Section.", "Topic tests", "Тесты по темам", "Mavzu testlari")
k("grpTestsEmptyTeacher", "Empty.", "No tests yet. Tap “Give a topic test”.", "Тестов пока нет. Нажмите «Дать тест по теме».", "Hozircha test yo‘q. «Mavzu testi berish» tugmasini bosing.")
k("grpTestsEmptyStudent", "Empty.", "The teacher hasn’t given a test yet.", "Преподаватель ещё не дал тест.", "Ustoz hali test bermagan.")
k("grpMembersSection", "Section.", "Students", "Студенты", "Talabalar")
k("grpMembersEmpty", "Empty.", "No students yet. Show the QR or code to the class.", "Студентов пока нет. Покажите классу QR или код.", "Hozircha talaba yo‘q. Sinfga QR yoki kodni ko‘rsating.")
k("grpProgress", "Assignment progress.", "Started: {started} · finished: {finished} of {total}", "Начали: {started} · завершили: {finished} из {total}", "Boshlagan: {started} · tugatgan: {finished} / {total}", {"started": I, "finished": I, "total": I})
k("grpClosedProgress", "Closed assignment progress.", "Closed · finished: {finished} of {total}", "Закрыт · завершили: {finished} из {total}", "Yopilgan · tugatgan: {finished} / {total}", {"finished": I, "total": I})
k("grpRemoveAction", "Button / tooltip.", "Remove from group", "Удалить из группы", "Guruhdan chiqarish")
k("grpRemoveTitle", "Dialog.", "Remove the student?", "Удалить студента?", "Talabani chiqarasizmi?")
k("grpRemoveBody", "Dialog.", "“{nickname}” will leave the group; their results in this group are deleted.", "«{nickname}» покинет группу; его результаты в этой группе удаляются.", "«{nickname}» guruhdan chiqariladi; uning shu guruhdagi natijalari o‘chiriladi.", {"nickname": S})
k("grpLeaveAction", "Button.", "Leave group", "Покинуть группу", "Guruhdan chiqish")
k("grpLeaveTitle", "Dialog.", "Leave the group?", "Покинуть группу?", "Guruhdan chiqasizmi?")
k("grpLeaveBody", "Dialog.", "You’ll need the code again to rejoin.", "Чтобы вернуться, снова понадобится код.", "Qaytib qo‘shilish uchun yana kod kerak bo‘ladi.")
k("grpStartTest", "Button.", "Start test", "Начать тест", "Testni boshlash")
k("grpContinueTest", "Button.", "Continue test", "Продолжить тест", "Testni davom ettirish")
k("grpMyScore", "Button with score.", "Result: {score} / {total}", "Результат: {score} / {total}", "Natija: {score} / {total}", {"score": I, "total": I})

# --- test sozlamalari
k("grpAssignTitle", "Screen title.", "Topic test for the group", "Тест по теме для группы", "Guruhga mavzu testi")
k("grpTopicSection", "Section.", "Topic", "Тема", "Mavzu")
k("grpChangeTopic", "Link.", "Change", "Изменить", "O‘zgartirish")
k("grpSettingsSection", "Section.", "Settings", "Настройки", "Sozlamalar")
k("grpCountLabel", "Slider label.", "Questions per student: {count}", "Вопросов каждому студенту: {count}", "Har talabaga savollar: {count}", {"count": I})
k("grpTimeLimitLabel", "Switch.", "Time limit", "Ограничение времени", "Vaqt chegarasi")
k("grpNoTimeLimit", "No limit.", "No time limit", "Без ограничения времени", "Vaqt chegarasi yo‘q")
k("grpMinutesN", "Minutes.", "{minutes, plural, =1{1 minute} other{{minutes} minutes}}", "{minutes, plural, one{{minutes} минута} few{{minutes} минуты} other{{minutes} минут}}", "{minutes} daqiqa", {"minutes": I})
k("grpQuestionsN", "Questions.", "{count, plural, =1{1 question} other{{count} questions}}", "{count, plural, one{{count} вопрос} few{{count} вопроса} other{{count} вопросов}}", "{count} ta savol", {"count": I})
k("grpDueTitle", "Due tile.", "Deadline", "Срок", "Muddat")
k("grpNoDue", "No due.", "No deadline — until the teacher closes the test", "Без срока — пока преподаватель не закроет тест", "Muddatsiz — ustoz testni yopguncha")
k("grpDueLabel", "Due label.", "Due: {date}", "Срок: {date}", "Muddat: {date}", {"date": S})
k("grpClearDue", "Tooltip.", "Remove deadline", "Убрать срок", "Muddatni olib tashlash")
k("grpVariantLabel", "Switch.", "Different questions for each student", "Разные вопросы каждому студенту", "Har talabaga boshqa savollar")
k("grpVariantShort", "Chip.", "variants", "варианты", "variantli")
k("grpVariantHelp", "Variant help.", "Each student gets their own set from the topic (fixed by the server).", "Каждый студент получает свой набор из темы (определяет сервер).", "Har talaba mavzudan o‘z to‘plamini oladi (server belgilaydi).")
k("grpVariantTooFew", "Variant disabled.", "Variants are off: the topic has {available} questions, at least {needed} are needed (twice the number per student). Otherwise the sets would be almost the same.", "Варианты выключены: в теме {available} вопросов, нужно не меньше {needed} (вдвое больше, чем на студента). Иначе наборы почти совпадут.", "Variantlar o‘chiq: mavzuda {available} ta savol bor, kamida {needed} ta kerak (har talabaga beriladiganidan 2 barobar). Aks holda to‘plamlar deyarli bir xil bo‘lib qoladi.", {"available": I, "needed": I})
k("grpRevealSection", "Section.", "When are correct answers shown?", "Когда показать правильные ответы?", "To‘g‘ri javoblar qachon ochiladi?")
k("grpRevealAfterDue", "Radio.", "After the deadline (or when I close the test)", "После срока (или когда я закрою тест)", "Muddat tugagach (yoki testni yopganimda)")
k("grpRevealAfterClose", "Radio.", "Only when I close the test", "Только когда я закрою тест", "Faqat testni yopganimda")
k("grpRevealNeedsDue", "Radio hint.", "Set a deadline first", "Сначала укажите срок", "Avval muddatni belgilang")
k("grpAssignSubmit", "Button.", "Give the test", "Дать тест", "Testni berish")

# --- ustoz jonli paneli / katta ekran
k("grpLiveTitle", "Screen title.", "Test results (live)", "Результаты теста (живые)", "Test natijalari (jonli)")
k("grpTestQrTitle", "QR card.", "One QR for everyone", "Один QR для всех", "Hammaga bitta QR")
k("grpTestQrHint", "QR hint.", "Students scan it, enter a nickname the first time, and the test opens.", "Студенты сканируют его, при первом входе вводят псевдоним — и тест открывается.", "Talabalar skanerlaydi, birinchi marta taxallus yozadi — test ochiladi.")
k("grpBigScreen", "Button.", "Big screen", "Большой экран", "Katta ekran")
k("grpPreviewShort", "Button.", "Try as student", "Как студент", "Talaba ko‘rinishida")
k("grpCounts", "Counts.", "Joined: {joined} · solving: {solving} · finished: {finished}", "Вошли: {joined} · решают: {solving} · завершили: {finished}", "Qo‘shildi: {joined} · yechmoqda: {solving} · tugatdi: {finished}", {"joined": I, "solving": I, "finished": I})
k("grpStateJoined", "State.", "Joined", "Вошёл", "Qo‘shildi")
k("grpStateSolving", "State.", "Solving", "Решает", "Yechmoqda")
k("grpStateFinished", "State.", "Finished", "Завершил", "Tugatdi")
k("grpCloseAction", "Button.", "Close the test", "Закрыть тест", "Testni yopish")
k("grpCloseTitle", "Dialog.", "Close the test?", "Закрыть тест?", "Testni yopasizmi?")
k("grpCloseBody", "Dialog.", "New attempts won’t start. Students who are solving get 30 seconds to send; then their saved answers are counted. Correct answers open to students.", "Новые попытки не начнутся. Тем, кто решает, даётся 30 секунд на отправку; затем засчитываются сохранённые ответы. Правильные ответы откроются студентам.", "Yangi urinish boshlanmaydi. Yechayotganlarga yuborish uchun 30 soniya beriladi, so‘ng saqlangan javoblari hisoblanadi. To‘g‘ri javoblar talabalarga ochiladi.")
k("grpClosedBanner", "Banner.", "The test is closed — correct answers are open to students.", "Тест закрыт — правильные ответы открыты студентам.", "Test yopildi — to‘g‘ri javoblar talabalarga ochildi.")
k("grpBoardHint", "Big screen hint.", "FORENSIC EXPERT → Learn → Groups: scan the QR or enter the code", "FORENSIC EXPERT → Учёба → Группы: отсканируйте QR или введите код", "FORENSIC EXPERT → O‘qish → Guruhlar: QR kodni skanerlang yoki kodni kiriting")
k("grpBoardWaiting", "Big screen empty.", "Waiting for students…", "Ждём студентов…", "Talabalar kutilmoqda…")
k("grpRevealAfterDueNote", "Reveal note.", "Correct answers open after the deadline ({date}) or when the teacher closes the test.", "Правильные ответы откроются после срока ({date}) или когда преподаватель закроет тест.", "To‘g‘ri javoblar muddat tugagach ({date}) yoki ustoz testni yopgach ochiladi.", {"date": S})
k("grpRevealAfterCloseNote", "Reveal note.", "Correct answers open when the teacher closes the test.", "Правильные ответы откроются, когда преподаватель закроет тест.", "To‘g‘ri javoblar ustoz testni yopgach ochiladi.")

# --- qo'shilish
k("grpJoinTitle", "Screen title.", "Join a group", "Вступить в группу", "Guruhga qo‘shilish")
k("grpCodeLabel", "Field.", "Group code", "Код группы", "Guruh kodi")
k("grpCodeHelper", "Helper.", "8 characters. The code has no 0, O, 1, I or L. A pasted link also works.", "8 символов. В коде нет 0, O, 1, I и L. Можно вставить ссылку.", "8 belgi. Kodda 0, O, 1, I va L bo‘lmaydi. Havolani qo‘ysangiz ham bo‘ladi.")
k("grpContinue", "Button.", "Continue", "Продолжить", "Davom etish")
k("grpJoinAction", "Button.", "Join and open the test", "Вступить и открыть тест", "Qo‘shilish va testni ochish")
k("grpJoinGroupName", "Group name line.", "Group: {name}", "Группа: {name}", "Guruh: {name}", {"name": S})
k("grpNickLabel", "Field.", "Nickname", "Псевдоним", "Taxallus")
k("grpNickHelper", "Helper.", "2–20 characters, asked only once. The teacher sees only this nickname — not your name or e-mail.", "2–20 символов, спрашиваем один раз. Преподаватель видит только этот псевдоним — не имя и не e-mail.", "2–20 belgi, faqat bir marta so‘raladi. Ustoz faqat shu taxallusni ko‘radi — ismingiz va emailingizni emas.")
k("grpNickNeeded", "Nickname required.", "Enter a nickname to join.", "Введите псевдоним, чтобы вступить.", "Qo‘shilish uchun taxallus yozing.")
k("grpOwnerTitle", "Owner panel.", "You are the teacher of this group", "Вы преподаватель этой группы", "Siz bu guruhning ustozisiz")
k("grpOwnerBody", "Owner panel body.", "This is your own invite for “{group}”. A teacher can’t join their own group as a student — you can open it as the teacher or try the test as a student would see it.", "Это ваше приглашение в «{group}». Преподаватель не может вступить в свою группу как студент — откройте её как преподаватель или попробуйте тест глазами студента.", "Bu «{group}» guruhiga o‘zingizning taklifingiz. Ustoz o‘z guruhiga talaba sifatida qo‘shilmaydi — guruhni ustoz sifatida oching yoki testni talaba ko‘zi bilan sinab ko‘ring.", {"group": S})
k("grpPreviewAction", "Button.", "Try as a student", "Попробовать как студент", "Talaba ko‘rinishida sinash")
k("grpOwnerOpen", "Button.", "Open as teacher", "Открыть как преподаватель", "Ustoz sifatida ochish")
k("grpOwnerOtherAccount", "Owner note.", "To take the test for real, sign in with a different (student) account.", "Чтобы пройти тест по-настоящему, войдите под другим (студенческим) аккаунтом.", "Testni haqiqatan yechish uchun boshqa (talaba) hisobi bilan kiring.")

# --- test
k("grpTestTitle", "Screen title.", "Topic test", "Тест по теме", "Mavzu testi")
k("grpQuestionOf", "Progress.", "Question {current} of {total}", "Вопрос {current} из {total}", "{current}-savol / {total}", {"current": I, "total": I})
k("grpAnsweredOf", "Screen reader.", "Answered {answered} of {total}", "Отвечено {answered} из {total}", "{answered} / {total} ta savolga javob berildi", {"answered": I, "total": I})
k("grpTimeLeftSemantics", "Screen reader.", "Time left: {time}", "Осталось времени: {time}", "Qolgan vaqt: {time}", {"time": S})
k("grpPrev", "Button.", "Back", "Назад", "Oldingi")
k("grpNext", "Button.", "Next", "Далее", "Keyingi")
k("grpFinish", "Button.", "Finish", "Завершить", "Yakunlash")
k("grpSubmitTitle", "Dialog.", "Send your answers?", "Отправить ответы?", "Javoblarni yuborasizmi?")
k("grpSubmitBodyAll", "Dialog.", "All questions are answered. After sending you can’t change them.", "Ответы на все вопросы даны. После отправки изменить их нельзя.", "Hamma savolga javob berildi. Yuborgandan keyin o‘zgartirib bo‘lmaydi.")
k("grpSubmitBodyLeft", "Dialog.", "{count, plural, =1{1 question has no answer.} other{{count} questions have no answer.}} After sending you can’t change them.", "{count, plural, one{{count} вопрос без ответа.} few{{count} вопроса без ответа.} other{{count} вопросов без ответа.}} После отправки изменить нельзя.", "{count} ta savolga javob berilmagan. Yuborgandan keyin o‘zgartirib bo‘lmaydi.", {"count": I})
k("grpSubmitAction", "Button.", "Send", "Отправить", "Yuborish")
k("grpLateSubmitted", "Snackbar.", "Time was up — your last saved answers were counted.", "Время вышло — засчитаны последние сохранённые ответы.", "Vaqt tugagan edi — oxirgi saqlangan javoblaringiz hisoblandi.")
k("grpPreviewBanner", "Preview banner.", "Trial mode: this is what students see. Nothing is sent to the server.", "Пробный режим: так видят студенты. На сервер ничего не отправляется.", "Sinov rejimi: talabalar shunday ko‘radi. Serverga hech narsa yuborilmaydi.")
k("grpPreviewDone", "Preview finished.", "Trial finished: {score} / {total}", "Проба завершена: {score} / {total}", "Sinov tugadi: {score} / {total}", {"score": I, "total": I})
k("grpPreviewNothingSent", "Preview body.", "Nothing was sent to the server — students’ results are not affected.", "На сервер ничего не отправлено — результаты студентов не изменились.", "Serverga hech narsa yuborilmadi — talabalar natijasiga ta’sir qilmaydi.")
k("grpBackToGroup", "Button.", "Back to the group", "Назад к группе", "Guruhga qaytish")

# --- natija
k("grpResultTitle", "Screen title.", "My result", "Мой результат", "Mening natijam")
k("grpScoreCaption", "Score caption.", "correct answers (counted by the server)", "правильных ответов (считает сервер)", "to‘g‘ri javob (server hisobladi)")
k("grpExpiredNote", "Expired note.", "Time ran out — your saved answers were counted.", "Время истекло — засчитаны сохранённые ответы.", "Vaqt tugadi — saqlangan javoblaringiz hisoblandi.")
k("grpAnswersSection", "Section.", "Answers and explanations", "Ответы и пояснения", "Javoblar va izohlar")
k("grpYourAnswer", "Your answer.", "Your answer: {answer}", "Ваш ответ: {answer}", "Sizning javobingiz: {answer}", {"answer": S})
k("grpCorrectAnswer", "Correct answer.", "Correct answer: {answer}", "Правильный ответ: {answer}", "To‘g‘ri javob: {answer}", {"answer": S})
k("grpNoAnswer", "No answer.", "No answer", "Нет ответа", "Javob berilmagan")
k("grpPage", "Source page.", "p. {page}", "с. {page}", "{page}-bet", {"page": S})

# --- xatolar
k("grpErrNotConfigured", "Error.", "Groups will work once the FORENSIC EXPERT server is connected.", "Группы заработают после подключения сервера FORENSIC EXPERT.", "Guruhlar FORENSIC EXPERT serveri ulangach ishlaydi.")
k("grpErrSessionExpired", "Error.", "Your session has ended. Please sign in again.", "Сеанс завершён. Войдите снова.", "Sessiya tugagan. Qaytadan hisobga kiring.")
k("grpErrOffline", "Error.", "No internet connection. Check it and try again.", "Нет подключения к интернету. Проверьте и повторите.", "Internet yo‘q. Ulanishni tekshirib, qayta urinib ko‘ring.")
k("grpErrServer", "Error.", "Something went wrong on the server. Try again in a moment.", "Сбой на сервере. Повторите чуть позже.", "Serverda xatolik. Birozdan so‘ng qayta urinib ko‘ring.")
k("grpErrForbidden", "Error.", "You don’t have access to this group.", "У вас нет доступа к этой группе.", "Bu guruhga kirish huquqingiz yo‘q.")
k("grpErrRateLimited", "Error.", "Too many attempts. Try again in an hour.", "Слишком много попыток. Повторите через час.", "Urinishlar juda ko‘p. Bir soatdan keyin qayta urinib ko‘ring.")
k("grpErrBadCode", "Error.", "Enter the 8-character group code.", "Введите 8-значный код группы.", "8 belgili guruh kodini kiriting.")
k("grpErrCodeAmbiguous", "Error.", "Group codes never contain 0, O, 1, I or L. Check the code on the teacher’s screen: it may be a similar letter or digit (for example 2 or Z, 8 or B).", "В кодах групп не бывает 0, O, 1, I и L. Сверьте код с экраном преподавателя: возможно, это похожая буква или цифра (например, 2 или Z, 8 или B).", "Guruh kodida 0, O, 1, I va L bo‘lmaydi. Kodni ustoz ekrani bilan solishtiring: o‘xshash harf yoki raqam bo‘lishi mumkin (masalan, 2 yoki Z, 8 yoki B).")
k("grpErrNotFound", "Error.", "No group with this code. Check it and try again.", "Группа с таким кодом не найдена. Проверьте код.", "Bunday kodli guruh topilmadi. Kodni tekshirib, qayta urinib ko‘ring.")
k("grpErrGroupFull", "Error.", "The group is full (200 students). Tell your teacher.", "Группа заполнена (200 студентов). Сообщите преподавателю.", "Guruh to‘lgan (200 kishi) — ustozingizga ayting.")
k("grpErrNickLength", "Error.", "The nickname must be 2–20 characters.", "Псевдоним должен содержать 2–20 символов.", "Taxallus 2–20 belgidan iborat bo‘lishi kerak.")
k("grpErrNickChars", "Error.", "Use letters, digits, spaces and . _ ' - only (no e-mail or links).", "Используйте только буквы, цифры, пробелы и . _ ' - (без e-mail и ссылок).", "Faqat harf, raqam, bo‘shliq va . _ ' - belgilaridan foydalaning (email yoki havola emas).")
k("grpErrNickBlocked", "Error.", "Please choose a different nickname.", "Выберите другой псевдоним.", "Boshqa taxallus tanlang.")
k("grpErrNickTaken", "Error.", "This nickname is already taken in the group. Add a letter or a number.", "Такой псевдоним в группе уже есть. Добавьте букву или цифру.", "Bu taxallus guruhda band. Harf yoki raqam qo‘shing.")
k("grpErrBadName", "Error.", "The group name must be 2–60 characters.", "Название группы — от 2 до 60 символов.", "Guruh nomi 2–60 belgidan iborat bo‘lishi kerak.")
k("grpErrTooManyGroups", "Error.", "You already have 30 groups — the maximum.", "У вас уже 30 групп — это максимум.", "Sizda allaqachon 30 ta guruh bor — bu eng ko‘pi.")
k("grpErrInvalidSettings", "Error.", "Check the settings: 1–50 questions, time limit 1–180 minutes.", "Проверьте настройки: 1–50 вопросов, время 1–180 минут.", "Sozlamalarni tekshiring: 1–50 savol, vaqt 1–180 daqiqa.")
k("grpErrBadDue", "Error.", "The deadline must be in the future (within a year).", "Срок должен быть в будущем (в пределах года).", "Muddat kelajakda (bir yil ichida) bo‘lishi kerak.")
k("grpErrRevealNeedsDue", "Error.", "“After the deadline” needs a deadline.", "Для «после срока» нужно указать срок.", "«Muddat tugagach» uchun muddat belgilang.")
k("grpErrNotEnoughQuestions", "Error.", "The topic has only {available} questions.", "В теме только {available} вопросов.", "Mavzuda faqat {available} ta savol bor.", {"available": I})
k("grpErrTooManyAssignments", "Error.", "The group already has 50 open tests. Close some first.", "В группе уже 50 открытых тестов. Сначала закройте часть.", "Guruhda 50 ta ochiq test bor. Avval ba’zilarini yoping.")
k("grpErrClosed", "Error.", "The teacher has closed this test.", "Преподаватель закрыл этот тест.", "Ustoz bu testni yopgan.")
k("grpErrPastDue", "Error.", "The deadline for this test has passed.", "Срок этого теста прошёл.", "Bu testning muddati o‘tgan.")
k("grpErrAlreadySubmitted", "Error.", "You have already sent this test.", "Вы уже отправили этот тест.", "Bu testni allaqachon yuborgansiz.")
k("grpErrTimeOver", "Error.", "Time is up — new answers are no longer accepted.", "Время вышло — новые ответы не принимаются.", "Vaqt tugadi — yangi javoblar qabul qilinmaydi.")
k("grpErrNotSubmitted", "Error.", "You haven’t sent this test yet.", "Вы ещё не отправили этот тест.", "Bu testni hali yubormagansiz.")

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    with open(p, encoding="utf-8") as f:
        data = json.load(f, object_pairs_hook=collections.OrderedDict)
    for key, (desc, en, ru, uz, ph) in K.items():
        data[key] = (en, ru, uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = {n: dict(t) for n, t in ph.items()}
            data["@" + key] = meta
    with open(p, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")
print(len(K), "keys")
