#!/usr/bin/env python3
"""«Guruh og‘zaki imtihoni» (QR): ustoz sozlash/doska/navbat/baholash/natijalar,
talaba qo‘shilish va bilet ekrani, server xatolari (egasi, 2026-11-03).
Tartib: `l10n_teacher_oral.py` dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
I = {'type': 'int'}
S = {'type': 'String'}
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


# ---------------------------------------------------------------- tanlash
k('oralGroupButton', 'Topic picker: start a QR group oral exam.',
  'Guruhga (QR)', 'Группе (QR)', 'For a group (QR)')
k('oralGroupActiveLink', 'Topic picker: link to open group exams.',
  'Faol guruh imtihonlari: {n} ta', 'Активные групповые экзамены: {n}',
  'Active group exams: {n}', {'n': I})

# ---------------------------------------------------------------- sozlash
k('oralGroupSetupTitle', 'Group oral exam setup screen title.',
  'Guruh imtihoni', 'Групповой экзамен', 'Group exam')
k('oralGroupSetupIntro', 'Setup explanation.',
  'Doskada QR va kod chiqadi. Talabalar telefondan qo‘shilib, tasodifiy '
  'bilet oladi va savollarini darhol ko‘radi. Javob kaliti faqat sizning '
  'telefoningizda qoladi, serverga yuborilmaydi.',
  'На доске появятся QR и код. Студенты заходят с телефона, получают '
  'случайный билет и сразу видят вопросы. Ключ ответа остаётся только на '
  'вашем телефоне и на сервер не отправляется.',
  'A QR code and a code appear on the board. Students join from their '
  'phones, get a random ticket and see its questions right away. The answer '
  'key stays on your phone only and is never sent to the server.')
k('oralGroupNoTopics', 'Setup opened without topics.',
  'Yangi imtihon uchun avval mavzularni tanlang. Faol imtihonlar quyida.',
  'Для нового экзамена сначала выберите темы. Активные экзамены ниже.',
  'Pick topics first to start a new exam. Active exams are below.')
k('oralGroupStudentsLabel', 'Number of students field label.',
  'Talabalar soni', 'Количество студентов', 'Number of students')
k('oralGroupStudentsHelper', 'Number of students helper.',
  '1–200. Shuncha bilet tuziladi.', '1–200. Столько билетов будет составлено.',
  '1–200. This many tickets will be made.')
k('oralGroupStudentsDec', 'Decrease students tooltip.',
  'Kamaytirish', 'Уменьшить', 'Decrease')
k('oralGroupStudentsInc', 'Increase students tooltip.',
  'Ko‘paytirish', 'Увеличить', 'Increase')
k('oralGroupPrepLabel', 'Preparation time section label.',
  'Tayyorlanish vaqti', 'Время подготовки', 'Preparation time')
k('oralGroupPrepNone', 'No preparation time.', 'Yo‘q', 'Нет', 'None')
k('oralGroupPrepMin', 'Preparation chip, minutes.',
  '{n} daqiqa', '{n} мин', '{n} min', {'n': I})
k('oralGroupPrepHint', 'Preparation hint.',
  'Talaba biletini darhol ko‘radi; bu vaqt faqat sanoq uchun.',
  'Студент видит билет сразу; это время — только для отсчёта.',
  'The student sees the ticket at once; this time is only a countdown.')
k('oralGroupAvailable', 'Questions available in the chosen topics.',
  'Tanlangan mavzulardagi savollar: {n}', 'Вопросов в выбранных темах: {n}',
  'Questions in the chosen topics: {n}', {'n': I})
k('oralGroupRepeatNotice', 'Soft notice: the pool is too small.',
  'Savollar yetmaydi: ayrim biletlarda savollar takrorlanadi',
  'Вопросов не хватит: в некоторых билетах вопросы повторятся',
  'Not enough questions: some tickets will repeat questions')
k('oralGroupStart', 'Create the group exam.',
  'Boshlash', 'Начать', 'Start')
k('oralGroupActiveSection', 'Open group exams header.',
  'Faol imtihonlar', 'Активные экзамены', 'Active exams')
k('oralGroupFinishedSection', 'Finished group exams header.',
  'Yakunlanganlar (30 kun saqlanadi)', 'Завершённые (хранятся 30 дней)',
  'Finished (kept for 30 days)')
k('oralGroupSessionLine', 'Exam list row: code and counts.',
  'Kod {code} · qo‘shildi: {joined} · baholandi: {graded}',
  'Код {code} · зашло: {joined} · оценено: {graded}',
  'Code {code} · joined: {joined} · graded: {graded}',
  {'code': S, 'joined': I, 'graded': I})
k('oralGroupNoTitle', 'Exam without a title.',
  'Guruh imtihoni', 'Групповой экзамен', 'Group exam')

# ---------------------------------------------------------------- doska
k('oralGroupHostJoinHint', 'Board: how to join.',
  'FORENSIC EXPERT → «Guruh testi» bo‘limida kodni kiriting yoki QR ni '
  'skanerlang:',
  'В разделе «Групповой тест» FORENSIC EXPERT введите код или '
  'отсканируйте QR:',
  'In FORENSIC EXPERT → “Group test”, enter the code or scan the QR:')
k('oralGroupJoinedCount', 'Board: joined students.',
  'Qo‘shildi: {x} / {n}', 'Зашло: {x} / {n}', 'Joined: {x} / {n}',
  {'x': I, 'n': I})
k('oralGroupTile', 'Board tile number.', '№ {n}', '№ {n}', 'No. {n}',
  {'n': I})
k('oralGroupStatusFree', 'Ticket status: free.', 'bo‘sh', 'свободен', 'free')
k('oralGroupStatusJoined', 'Ticket status: student joined.',
  'qo‘shildi', 'зашёл', 'joined')
k('oralGroupStatusReady', 'Ticket status: student ready.',
  'tayyor', 'готов', 'ready')
k('oralGroupStatusGraded', 'Ticket status: graded.',
  'baholandi', 'оценён', 'graded')
k('oralGroupQueue', 'Open the queue.', 'Navbat', 'Очередь', 'Queue')
k('oralGroupResults', 'Open the results.', 'Natijalar', 'Результаты', 'Results')
k('oralGroupFinish', 'Finish the exam.', 'Yakunlash', 'Завершить', 'Finish')
k('oralGroupFinishTitle', 'Finish confirm title.',
  'Imtihonni yakunlaymizmi?', 'Завершить экзамен?', 'Finish the exam?')
k('oralGroupFinishBody', 'Finish confirm body.',
  'Yangi talabalar qo‘shila olmaydi, navbat yopiladi. Natijalar 30 kun '
  'saqlanadi.',
  'Новые студенты не смогут зайти, очередь закроется. Результаты хранятся '
  '30 дней.',
  'New students will not be able to join and the queue closes. Results are '
  'kept for 30 days.')
k('oralGroupFinishedBanner', 'Banner: exam finished.',
  'Imtihon yakunlangan. Natijalar 30 kun saqlanadi.',
  'Экзамен завершён. Результаты хранятся 30 дней.',
  'The exam is finished. Results are kept for 30 days.')
k('oralGroupCancel', 'Cancel in dialogs.',
  'Bekor qilish', 'Отмена', 'Cancel')
k('oralGroupQrNote', 'Board: scores are never shown.',
  'Ballar doskada ko‘rsatilmaydi.', 'Баллы на доске не показываются.',
  'Scores are never shown on the board.')

# ---------------------------------------------------------------- navbat
k('oralGroupQueueTitle', 'Queue screen title.', 'Navbat', 'Очередь', 'Queue')
k('oralGroupQueueEmpty', 'Queue is empty.',
  'Hozircha hech kim qo‘shilmagan.', 'Пока никто не зашёл.',
  'Nobody has joined yet.')
k('oralGroupSectionReady', 'Queue section: ready students.',
  'Tayyor ({n})', 'Готовы ({n})', 'Ready ({n})', {'n': I})
k('oralGroupSectionJoined', 'Queue section: preparing students.',
  'Tayyorlanmoqda ({n})', 'Готовятся ({n})', 'Preparing ({n})', {'n': I})
k('oralGroupSectionGraded', 'Queue section: graded students.',
  'Baholanganlar ({n})', 'Оценены ({n})', 'Graded ({n})', {'n': I})
k('oralGroupReadyAt', 'Queue row: ready time.',
  'Tayyor: {time}', 'Готов: {time}', 'Ready: {time}', {'time': S})
k('oralGroupCalledMark', 'Queue row: already called.',
  'chaqirilgan', 'вызван', 'called')

# ---------------------------------------------------------------- baholash
k('oralGroupGradeTitle', 'Grade screen title.',
  'Baholash', 'Оценивание', 'Grading')
k('oralGroupSave', 'Save the grades.', 'Saqlash', 'Сохранить', 'Save')
k('oralGroupSaved', 'Snackbar after saving the grades.',
  'Baho saqlandi: {total} / 100', 'Оценка сохранена: {total} / 100',
  'Grade saved: {total} / 100', {'total': I})
k('oralGroupKick', 'Menu: remove student from the exam.',
  'Imtihondan chiqarish', 'Удалить из экзамена', 'Remove from the exam')
k('oralGroupKickTitle', 'Kick confirm title.',
  '{name} imtihondan chiqarilsinmi?', 'Удалить {name} из экзамена?',
  'Remove {name} from the exam?', {'name': S})
k('oralGroupKickBody', 'Kick confirm body.',
  'Bilet bo‘shaydi va boshqa talaba oladi. Chiqarilgan talaba qayta '
  'qo‘shila olmaydi.',
  'Билет освободится и достанется другому студенту. Удалённый студент не '
  'сможет зайти снова.',
  'The ticket is freed for another student. A removed student cannot '
  'rejoin.')
k('oralGroupKeyMissing', 'Answer key not found locally.',
  'Javob kaliti topilmadi: dars o‘zgargan yoki yuklanmagan bo‘lishi mumkin.',
  'Ключ ответа не найден: занятие могло измениться или не загрузиться.',
  'Answer key not found: the lesson may have changed or failed to load.')
k('oralGroupGradedBefore', 'Grade screen: already graded.',
  'Avval baholangan — qayta baholash mumkin.',
  'Уже оценён — можно переоценить.',
  'Already graded — you can grade again.')

# ---------------------------------------------------------------- natijalar
k('oralGroupResultsTitle', 'Results screen title.',
  'Natijalar', 'Результаты', 'Results')
k('oralGroupResultsEmpty', 'No students joined.',
  'Hali hech kim qo‘shilmagan.', 'Пока никто не зашёл.',
  'Nobody has joined yet.')
k('oralGroupNotGraded', 'Result row: not graded yet.',
  'baholanmagan', 'не оценён', 'not graded')
k('oralGroupExport', 'Export results as CSV.',
  'CSV sifatida yuborish', 'Отправить как CSV', 'Share as CSV')
k('oralGroupCsvName', 'CSV header: name.', 'Ism', 'Имя', 'Name')
k('oralGroupCsvTicket', 'CSV header: ticket.', 'Bilet', 'Билет', 'Ticket')
k('oralGroupCsvQuestion', 'CSV header: question score.',
  '{n}-savol', 'Вопрос {n}', 'Question {n}', {'n': I})
k('oralGroupCsvTotal', 'CSV header: total.', 'Jami', 'Итого', 'Total')

# ---------------------------------------------------------------- talaba
k('oralJoinTitle', 'Student: join a group oral exam.',
  'Og‘zaki imtihonga qo‘shilish', 'Вход в устный экзамен',
  'Join an oral exam')
k('oralJoinNameLabel', 'Student: name field.',
  'Ism va familiya', 'Имя и фамилия', 'First and last name')
k('oralJoinNameHelper', 'Student: name helper.',
  '2–40 belgi. Ustoz sizni shu ism bilan ko‘radi.',
  '2–40 символов. Преподаватель увидит вас под этим именем.',
  '2–40 characters. The teacher sees you under this name.')
k('oralJoinNote', 'Student: privacy note.',
  'Ballaringizni faqat siz va ustoz ko‘rasiz. Natijalar 30 kundan keyin '
  'o‘chiriladi.',
  'Ваши баллы видите только вы и преподаватель. Результаты удаляются через '
  '30 дней.',
  'Only you and the teacher see your scores. Results are deleted after 30 '
  'days.')
k('oralResumeCard', 'Resume card for the last open oral exam.',
  'Davom etish: Bilet № {n}', 'Продолжить: билет № {n}',
  'Continue: ticket No. {n}', {'n': I})
k('oralPlayLeaveCount', 'Student: own app-leave count.',
  'Ilovadan chiqishlaringiz: {n}', 'Выходов из приложения: {n}',
  'Times you left the app: {n}', {'n': I})
k('oralGroupLeftAt', 'Teacher: time of the last app leave.',
  'oxirgisi: {time}', 'последний: {time}', 'last: {time}', {'time': S})
k('oralPlayTitle', 'Student: exam screen title.',
  'Og‘zaki imtihon', 'Устный экзамен', 'Oral exam')
k('oralPlayName', 'Student: own name line.',
  'Ism: {name}', 'Имя: {name}', 'Name: {name}', {'name': S})
k('oralPlayPrepLeft', 'Student: preparation countdown.',
  'Tayyorlanish vaqti: {time}', 'Время подготовки: {time}',
  'Preparation time: {time}', {'time': S})
k('oralPlayPrepDone', 'Student: preparation over.',
  'Tayyorlanish vaqti tugadi.', 'Время подготовки вышло.',
  'Preparation time is over.')
k('oralPlayReady', 'Student: I am ready to answer.',
  'Javobga tayyorman', 'Готов отвечать', 'I am ready to answer')
k('oralPlayWaiting', 'Student: in the queue.',
  'Navbatdasiz. Ustoz sizni chaqirishini kuting.',
  'Вы в очереди. Дождитесь, когда преподаватель вас вызовет.',
  'You are in the queue. Wait for the teacher to call you.')
k('oralPlayCalled', 'Student: called by the teacher.',
  'Ustoz sizni chaqirdi', 'Преподаватель вас вызвал',
  'The teacher called you')
k('oralPlayCalledHint', 'Student: go to the teacher.',
  'Ustoz oldiga boring.', 'Подойдите к преподавателю.',
  'Go to the teacher.')
k('oralPlayResultTitle', 'Student: result header.',
  'Sizning natijangiz', 'Ваш результат', 'Your result')
k('oralPlayScoreLine', 'Student: per-question score.',
  'Savol {n}: {s} / 20', 'Вопрос {n}: {s} / 20', 'Question {n}: {s} / 20',
  {'n': I, 's': I})
k('oralPlayFinished', 'Student: exam finished without a grade.',
  'Imtihon yakunlandi.', 'Экзамен завершён.', 'The exam has finished.')

# ---------------------------------------------------------------- xatolar
k('oralErrNotFound', 'Oral exam error: unknown code.',
  'Bu kod bo‘yicha test yoki imtihon topilmadi. Kodni tekshiring.',
  'По этому коду тест или экзамен не найден. Проверьте код.',
  'No test or exam with this code. Check it and try again.')
k('oralErrFinished', 'Oral exam error: finished.',
  'Bu imtihon yakunlangan, yangi talabalar qo‘shila olmaydi.',
  'Этот экзамен завершён, новые студенты зайти не могут.',
  'This exam has finished; new students cannot join.')
k('oralErrFull', 'Oral exam error: no free tickets.',
  'Barcha biletlar band: bu imtihonda joy qolmagan.',
  'Все билеты заняты: мест в этом экзамене не осталось.',
  'All tickets are taken: this exam is full.')
k('oralErrKicked', 'Oral exam error: kicked.',
  'Ustoz sizni bu imtihondan chiqardi.',
  'Преподаватель удалил вас из этого экзамена.',
  'The teacher removed you from this exam.')
k('oralErrNameLength', 'Oral exam error: name length.',
  'Ism 2–40 belgidan iborat bo‘lsin.', 'Имя должно содержать 2–40 символов.',
  'The name must be 2–40 characters.')
k('oralErrNameChars', 'Oral exam error: name characters.',
  'Ismda ruxsat etilmagan belgilar bor.',
  'В имени есть недопустимые символы.',
  'The name contains characters that are not allowed.')
k('oralErrNameBlocked', 'Oral exam error: name blocked.',
  'Boshqa ism yozing.', 'Укажите другое имя.', 'Please enter a different name.')
k('oralErrRateLimited', 'Oral exam error: too many attempts.',
  'Urinishlar juda ko‘p. Bir soatdan keyin qayta urinib ko‘ring.',
  'Слишком много попыток. Повторите через час.',
  'Too many attempts. Try again in an hour.')
k('oralErrOwnSession', 'Oral exam error: teacher joins own exam.',
  'Siz bu imtihonning ustozisiz, talaba sifatida qo‘shila olmaysiz.',
  'Вы — преподаватель этого экзамена и не можете зайти как студент.',
  'You are the teacher of this exam and cannot join as a student.')
k('oralErrInvalidSettings', 'Oral exam error: settings.',
  'Sozlamalarni tekshiring: 1–200 talaba, tayyorlanish vaqti 0–60 daqiqa.',
  'Проверьте настройки: 1–200 студентов, время подготовки 0–60 минут.',
  'Check the settings: 1–200 students, preparation time 0–60 minutes.')
k('oralErrInvalidTicket', 'Oral exam error: invalid ticket.',
  'Biletlar noto‘g‘ri tuzilgan. Mavzularni qayta tanlab ko‘ring.',
  'Билеты составлены неверно. Попробуйте выбрать темы заново.',
  'The tickets are invalid. Try picking the topics again.')
k('oralErrTooMany', 'Oral exam error: too many open exams.',
  'Ochiq imtihonlar juda ko‘p. Avval birini yakunlang.',
  'Слишком много открытых экзаменов. Сначала завершите один.',
  'Too many open exams. Finish one first.')
k('oralErrInvalidScores', 'Oral exam error: invalid scores.',
  'Ballar noto‘g‘ri: har bir savolga 0–20.',
  'Неверные баллы: за каждый вопрос 0–20.',
  'Invalid scores: 0–20 for each question.')
k('oralErrNotJoined', 'Oral exam error: not joined.',
  'Siz bu imtihonda emassiz yoki ustoz sizni chiqargan.',
  'Вы не участвуете в этом экзамене или преподаватель вас удалил.',
  'You are not in this exam, or the teacher removed you.')
k('oralErrNotAllowed', 'Oral exam error: action not allowed.',
  'Hozir bu amal mumkin emas: imtihon yakunlangan yoki siz baholangansiz.',
  'Сейчас это действие невозможно: экзамен завершён или вы уже оценены.',
  'This is not possible now: the exam has finished or you are already graded.')
k('oralErrTryAgain', 'Oral exam error: code generation failed.',
  'Kod yaratib bo‘lmadi. Yana bir bor urinib ko‘ring.',
  'Не удалось создать код. Попробуйте ещё раз.',
  'Could not create a code. Please try again.')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, (desc, *vals, ph) in K.items():
        b[key] = vals[i]
        if lang == 'en':
            m = collections.OrderedDict(description=desc)
            if ph:
                m['placeholders'] = {n: dict(t) for n, t in ph.items()}
            b['@' + key] = m
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_oral_group:', len(K), 'keys')
