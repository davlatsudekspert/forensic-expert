#!/usr/bin/env python3
"""Fanlar hubida kontenti yo‘q fanlar guruhi: «Tez orada» → «Tayyorlanmoqda»
(egasi, 2026-11-05). Kalit (`disciplinesComingSoon`) o‘zgarmaydi.
Tartib: `l10n_teacher_desk_title.py` dan keyin, `flutter gen-l10n` dan oldin.
Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
V = {'uz': 'Tayyorlanmoqda ({count})', 'ru': 'Готовится ({count})',
     'en': 'In preparation ({count})'}
for lang, val in V.items():
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    b['disciplinesComingSoon'] = val
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_disciplines_preparing: ok')
