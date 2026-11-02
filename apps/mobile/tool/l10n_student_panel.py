"""Talaba paneli: barcha mavzular ochiq, tinglash va o‘zi test yechish —
egasi so‘rovi, 2026-11-02. Tartib: `l10n_catalog.py` dan keyin. Idempotent."""
import json, pathlib
D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = {
 'studentDeskTitle': ('Talaba paneli', 'Панель студента', 'Student panel'),
 'deskLessonsTitle': ('Barcha mavzular', 'Все темы', 'All topics'),
 'deskLessonsBody': ('Fakultet va kurslar bo‘yicha: o‘qish, tinglash, test', 'По факультетам и курсам: чтение, прослушивание, тест', 'By faculty and course: read, listen, test'),
 'lessonsOpenNote': ('Hamma mavzu ochiq: o‘qing, tinglang va mavzu oxirida o‘zingiz test yeching.', 'Все темы открыты: читайте, слушайте и в конце темы решите тест сами.', 'All topics are open: read, listen and take the self-test at the end of each topic.'),
 'disciplineTopics': ('Mavzular tuzilmasi', 'Структура тем', 'Topic structure'),
 'disciplineLessonsTitleStudent': ('Darslar: o‘qish, tinglash va test', 'Уроки: чтение, прослушивание и тест', 'Lessons: read, listen and test'),
 'lessonsAllCourses': ('Hammasi', 'Все', 'All'),
 'lessonKindLecture': ('Ma’ruza', 'Лекция', 'Lecture'),
 'lessonKindPractice': ('Amaliy mashg‘ulot', 'Практическое занятие', 'Practical class'),
}
P = {
 'disciplineLessonsBodyStudent': (('{n} ta dars. Darsni oching — o‘qing, tinglang, oxirida o‘zingiz test yeching.', 'Уроков: {n}. Откройте урок — читайте, слушайте, в конце решите тест сами.', '{n} lessons. Open a lesson to read and listen, then take the self-test at the end.'), {'n': 'int'}),
 'disciplinePlannedMore': (('Rejadagi mavzular ({n})', 'Запланированные темы ({n})', 'Planned topics ({n})'), {'n': 'int'}),
}
for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'))
    for k, v in K.items():
        b[k] = v[i]
        if lang == 'en' and '@' + k not in b:
            b['@' + k] = {'description': 'Student panel / lessons list.'}
    for k, (v, ph) in P.items():
        b[k] = v[i]
        if lang == 'en':
            b['@' + k] = {'description': 'Discipline page (student).',
                          'placeholders': {n: {'type': t} for n, t in ph.items()}}
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('l10n_student_panel:', len(K) + len(P), 'keys')
