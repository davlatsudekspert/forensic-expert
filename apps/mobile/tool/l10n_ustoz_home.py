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
