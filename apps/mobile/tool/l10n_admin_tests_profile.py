"""Admin «O‘tkazilgan testlar» va ustoz profili boshi (toifa) — egasi so‘rovi,
2026-11-02. Tartib: `l10n_score_grade.py` dan keyin. Idempotent."""
import json, pathlib
D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = {
 'tcCategoryLabel': ('Toifa', 'Категория', 'Category'),
 'tcCategoryHigher': ('Oliy toifa', 'Высшая категория', 'Highest category'),
 'tcCategoryFirst': ('Birinchi toifa', 'Первая категория', 'First category'),
 'tcCategorySecond': ('Ikkinchi toifa', 'Вторая категория', 'Second category'),
 'tcCategoryNone': ('Toifasiz', 'Без категории', 'No category'),
 'profTeacherEdit': ('Profilni tahrirlash', 'Редактировать профиль', 'Edit profile'),
 'profTeacherFill': ('Ustoz profilini to‘ldiring', 'Заполните профиль преподавателя', 'Complete your teacher profile'),
 'profTeacherFillHint': ('Rasm, ish joyi va toifangizni qo‘shing — talabalaringiz guruhda ko‘radi.', 'Добавьте фото, место работы и категорию — студенты увидят их в группе.', 'Add a photo, workplace and category — your students will see them in the group.'),
 'profTeacherVisibleOn': ('Talabalarga ko‘rinadi', 'Видно студентам', 'Visible to students'),
 'profTeacherVisibleOff': ('Talabalarga yashirin', 'Скрыто от студентов', 'Hidden from students'),
 'admTestsTitle': ('O‘tkazilgan testlar', 'Проведённые тесты', 'Tests conducted'),
 'admTestsHint': ('Ustozlar, guruhlar va natijalar', 'Преподаватели, группы и результаты', 'Teachers, groups and results'),
 'admTestsRefresh': ('Yangilash', 'Обновить', 'Refresh'),
 'admTestsSearch': ('Ustoz, guruh yoki mavzu bo‘yicha qidirish', 'Поиск по преподавателю, группе или теме', 'Search by teacher, group or topic'),
 'admTestsEmpty': ('Hali test o‘tkazilmagan.', 'Тесты ещё не проводились.', 'No tests have been conducted yet.'),
 'admTestsKindLive': ('Jonli sinf', 'Живой класс', 'Live class'),
 'admTestsKindAssignment': ('Guruh testi', 'Тест группы', 'Group test'),
 'admTestsNoAvg': ('Hali natija yo‘q', 'Результатов пока нет', 'No results yet'),
 'admTestsResultsTitle': ('Natijalar', 'Результаты', 'Results'),
 'admTestsNoStudents': ('Bu testda talaba yo‘q.', 'В этом тесте нет студентов.', 'No students in this test.'),
 'admTestsNotDone': ('Topshirmagan', 'Не сдал', 'Not submitted'),
}
S = 'String'
I = 'int'
P = {
 'admTestsTeacher': (('Ustoz: {name}', 'Преподаватель: {name}', 'Teacher: {name}'), {'name': S}),
 'admTestsGroup': (('Guruh: {name}', 'Группа: {name}', 'Group: {name}'), {'name': S}),
 'admTestsCode': (('Kod: {code}', 'Код: {code}', 'Code: {code}'), {'code': S}),
 'admTestsQuestions': (('{n} ta savol', 'Вопросов: {n}', '{n} questions'), {'n': I}),
 'admTestsJoined': (('{n} ta talaba qatnashdi', 'Участвовало студентов: {n}', '{n} students took part'), {'n': I}),
 'admTestsFinished': (('{done} / {total} topshirdi', 'Сдали: {done} из {total}', '{done} of {total} submitted'), {'done': I, 'total': I}),
 'admTestsAvg': (('O‘rtacha ball (100): {score} · Baho: {grade}', 'Средний балл (100): {score} · Оценка: {grade}', 'Average score (100): {score} · Grade: {grade}'), {'score': S, 'grade': S}),
}
for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'))
    for k, v in K.items():
        b[k] = v[i]
        if lang == 'en':
            b['@' + k] = {'description': 'Admin conducted tests / teacher profile header.'}
    for k, (v, ph) in P.items():
        b[k] = v[i]
        if lang == 'en':
            b['@' + k] = {'description': 'Admin conducted tests.',
                          'placeholders': {n: {'type': t} for n, t in ph.items()}}
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('l10n_admin_tests_profile:', len(K) + len(P), 'keys')
