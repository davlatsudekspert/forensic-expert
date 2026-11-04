#!/usr/bin/env python3
"""Ustoz bosh sahifasi: «Ilmiy kutubxona» ixcham qatori (egasi, 2026-11-04).
Tartib: `l10n_no_yaratish.py` dan keyin, `flutter gen-l10n` dan oldin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = collections.OrderedDict()


def k(key, desc, uz, ru, en):
    K[key] = (desc, uz, ru, en)


k('homeTeacherLibraryTitle', 'Teacher home: compact library row title.',
  'Ilmiy kutubxona', 'Научная библиотека', 'Scientific library')
k('homeTeacherLibraryBody', 'Teacher home: library row hint.',
  'Moddalar, laboratoriya, reagentlar, usullar, standartlar va fanlar — Kutubxona va Vositalarda',
  'Вещества, лаборатория, реагенты, методы, стандарты и дисциплины — в Библиотеке и Инструментах',
  'Substances, laboratory, reagents, methods, standards and disciplines — in Library and Tools')

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
print('l10n_teacher_library:', len(K), 'keys')
