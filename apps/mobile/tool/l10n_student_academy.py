#!/usr/bin/env python3
"""Talaba bosh sahifasi «Mening akademiyam» (egasi, 2026-11-04): yangi sarlavhalar.
`studentDeskTitle` qiymati yangilanadi. Tartib: `l10n_teacher_library.py` dan
keyin, `flutter gen-l10n` dan oldin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = collections.OrderedDict()


def k(key, desc, uz, ru, en):
    K[key] = (desc, uz, ru, en)


k('studentDeskTitle', 'Student home: banner title (My Academy).',
  'Mening akademiyam', 'Моя академия', 'My Academy')
k('studentLearnTitle', 'Student home: section title for the 2x2 study cards.',
  'O‘quv mashg‘ulotlari', 'Учебные занятия', 'Study sessions')
k('studentScienceTitle', 'Student home: section title for the horizontal science cards.',
  'Ilmiy va amaliy bo‘limlar', 'Научные и практические разделы',
  'Science and practice')
k('studentMoreTitle', 'Student home: section title for the remaining cards.',
  'Qo‘shimcha', 'Дополнительно', 'More')

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
print('l10n_student_academy:', len(K), 'keys')
