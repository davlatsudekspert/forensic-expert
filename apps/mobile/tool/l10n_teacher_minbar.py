#!/usr/bin/env python3
"""Ustoz bosh sahifasi «Ustoz minbari» (egasi, 2026-11-04): banner va bo‘lim
sarlavhalari (uz/ru/en). Tartib: `l10n_student_academy.py` dan keyin,
`flutter gen-l10n` dan oldin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = collections.OrderedDict()


def k(key, desc, uz, ru, en):
    K[key] = (desc, uz, ru, en)


k('teacherBannerTitle', 'Teacher home: banner title (Teacher’s Podium).',
  'USTOZ MINBARI', 'Кафедра устаза', 'Teacher’s Podium')
k('teacherBannerTagline', 'Teacher home: banner tagline.',
  'Ta’lim • Tajriba • Mahorat', 'Образование • Опыт • Мастерство',
  'Knowledge • Experience • Mastery')
k('teacherBannerSemantics', 'Teacher home: screen-reader label of the banner.',
  'Ustoz minbari: ta’lim, tajriba, mahorat',
  'Кафедра устаза: образование, опыт, мастерство',
  'Teacher’s Podium: knowledge, experience, mastery')
k('teacherSectionMaterials', 'Teacher home: section title for subjects and sources.',
  'Materiallar va manbalar', 'Материалы и источники', 'Materials and sources')
k('teacherSectionMore', 'Teacher home: section title for the remaining cards.',
  'Boshqa imkoniyatlar', 'Другие возможности', 'More tools')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, (desc, *vals) in K.items():
        b[key] = vals[i]
        if lang == 'en' and '@' + key not in b:
            b['@' + key] = collections.OrderedDict(description=desc)
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_teacher_minbar:', len(K), 'keys')
