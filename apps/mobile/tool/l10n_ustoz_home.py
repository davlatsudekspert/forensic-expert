#!/usr/bin/env python3
"""Ustoz minbari (egasi, 2026-11-07): «Darslar» kartasi nomi/izohi (uz/ru/en).
`flutter gen-l10n` dan oldin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = collections.OrderedDict()


def k(key, desc, uz, ru, en):
    K[key] = (desc, uz, ru, en)


k('teacherDeskLessonsTitle', 'Teacher desk card: lessons.',
  'Darslar', 'Занятия', 'Lessons')
k('teacherDeskLessonsBody', 'Teacher desk card: lessons body.',
  'Ma’ruza prezentatsiyalari — mavzular, proyektorda ko‘rsatish',
  'Лекционные презентации — темы, показ на проекторе',
  'Lecture presentations — topics, show on the projector')

k('lessonsTitle', 'Lessons screen title.', 'Darslar', 'Занятия', 'Lessons')
k('lessonSubjectBioethics', 'Lessons: subject Bioethics.', 'Bioetika', 'Биоэтика', 'Bioethics')
k('lessonSubjectForensic', 'Lessons: subject Forensic Medicine.', 'Sud tibbiyoti', 'Судебная медицина', 'Forensic Medicine')
k('lessonSubjectPharmacy', 'Lessons: Pharmacy faculty, Toxicological Chemistry.',
  'Farmatsiya fakulteti — Toksikologik kimyo',
  'Фармацевтический факультет — Токсикологическая химия',
  'Faculty of Pharmacy — Toxicological Chemistry')
k('lessonSubjectDevices', 'Lessons: working with instruments.', 'Apparatlar bilan ishlash', 'Работа на приборах', 'Working with instruments')
k('lessonFacultyMed', 'Faculty: General Medicine.', 'Davolash fakulteti', 'Лечебный факультет', 'General Medicine Faculty')
k('lessonFacultyPeds', 'Faculty: Pediatrics.', 'Pediatriya fakulteti', 'Педиатрический факультет', 'Faculty of Pediatrics')
k('lessonFacultyDent', 'Faculty: Dentistry.', 'Stomatologiya fakulteti', 'Стоматологический факультет', 'Faculty of Dentistry')
k('lessonFacultyPrev', 'Faculty: Preventive Medicine.', 'Tibbiy profilaktika fakulteti', 'Медико-профилактический факультет', 'Faculty of Preventive Medicine')
k('lessonChapterTox', 'Chapter: Forensic Toxicology (inside Forensic Medicine).', 'Sud-tibbiy toksikologiya', 'Судебно-медицинская токсикология', 'Forensic Toxicology')
k('lessonChapterToxNote', 'Note: toxicology is an internal chapter.', 'Ichki bob, alohida fakultet emas', 'Внутренняя глава, не отдельный факультет', 'Internal chapter, not a separate faculty')
k('lessonSubjectFacultiesNote', 'Forensic Medicine: faculties note.', 'Fakultetlar va o‘quv yo‘nalishlari', 'Факультеты и направления обучения', 'Faculties and programs')

k('teacherNotebookTitle', 'Casebook title in Teacher mode.',
  'Ustoz ish daftari', 'Журнал преподавателя', 'Teacher’s Notebook')

k('areasSoonTitle', 'Expertise areas: group of areas without content yet.',
  'Tez orada', 'Скоро', 'Coming soon')

k('areaBiologyDna', 'Expertise areas: forensic biology and DNA.',
  'Sud biologiyasi va DNK', 'Судебная биология и ДНК-анализ',
  'Forensic biology and DNA')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, (desc, *vals) in K.items():
        b[key] = vals[i]
        if lang == 'en':
            b['@' + key] = collections.OrderedDict(description=desc)
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_ustoz_home:', len(K), 'keys')
