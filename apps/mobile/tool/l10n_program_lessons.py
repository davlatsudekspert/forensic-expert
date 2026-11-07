#!/usr/bin/env python3
"""«Toksikologik kimyo» ixtisoslashtirish kursi mavzulari → ilovadagi
ma’ruzalar (toks-NN, sud-toks-NN) va Sud-kimyoviy ekspertiza sahifasidagi
kurs darslari havolasi (egasi skrinshotlari, 2026-11-07). uz/ru/en.
Tartib: `l10n_teacher_minbar.py` dan keyin, `flutter gen-l10n` dan oldin.
Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = collections.OrderedDict()
COUNT = {'count': {'type': 'int'}}


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, ph, uz, ru, en)


k('progLectures', 'Program topic sheet: section with the matching lectures.',
  'Ma’ruzalar: slayd va test', 'Лекции: слайды и тест',
  'Lectures: slides and test')
k('progLectureCount', 'Program topic chip: number of matching lectures.',
  '{count} ta ma’ruza', 'Лекций: {count}',
  '{count, plural, =1{1 lecture} other{{count} lectures}}', COUNT)
k('disciplineCourseList', 'Discipline page: open the lessons list of one course.',
  'Darslar ro‘yxati', 'Список уроков', 'Lessons list')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, (desc, ph, *vals) in K.items():
        b[key] = vals[i]
        if lang == 'en':
            meta = collections.OrderedDict(description=desc)
            if ph:
                meta['placeholders'] = ph
            b['@' + key] = meta
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_program_lessons:', len(K), 'keys')
