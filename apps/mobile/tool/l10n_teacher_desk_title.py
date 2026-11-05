#!/usr/bin/env python3
"""Ustoz bosh sahifasi bo‘lim nomi: «Ustoz stolim» → «Ustoz boshqaruvi»
(egasi, 2026-11-05). Faqat uz; kalit (`teacherDeskTitle`) o‘zgarmaydi.
Tartib: `l10n_teacher_minbar.py` dan keyin, `flutter gen-l10n` dan oldin.
Idempotent."""
import collections, json, pathlib

f = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb/app_uz.arb'
b = json.loads(f.read_text(encoding='utf-8'),
               object_pairs_hook=collections.OrderedDict)
b['teacherDeskTitle'] = 'Ustoz boshqaruvi'
f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('l10n_teacher_desk_title: ok')
