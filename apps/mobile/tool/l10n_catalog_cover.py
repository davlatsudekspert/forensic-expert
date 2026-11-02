#!/usr/bin/env python3
"""Katalog: rejimga qarab ro‘yxat, tasdiqlangan belgi, ikki xil «ko‘rsatish»
kaliti va ustoz kartasi fon rasmi (egasi so‘rovi, 2026-11-02). Tartib:
`l10n_assessment_modes.py` dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = collections.OrderedDict()
# Mavjud kalitning faqat qiymati yangilanadi (tavsif o‘zgarmaydi).
OVERRIDE = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('catShowMeTeachers', 'Teacher profile switch: show in teachers catalogue.',
  'Ustozlar katalogida ko‘rsatish', 'Показывать в каталоге преподавателей',
  'Show in the teachers catalogue')
k('catShowMeExperts', 'Expert profile switch: show in specialists catalogue.',
  'Mutaxassislar katalogida ko‘rsatish', 'Показывать в каталоге специалистов',
  'Show in the specialists catalogue')
k('catExpertUnverifiedHint',
  'Hint under the specialists switch while the profile is not verified.',
  'Tasdiqlangandan keyin ismingiz yonida belgi chiqadi',
  'После подтверждения рядом с вашим именем появится значок',
  'A badge appears next to your name once you are verified')
k('catVerifiedExpert', 'Tooltip/semantics of the verified badge.',
  'Tasdiqlangan mutaxassis', 'Подтверждённый специалист', 'Verified specialist')
k('tcCoverSection', 'Teacher card edit: cover image section.',
  'Fon rasmi', 'Фоновое изображение', 'Cover image')
k('tcCoverChoose', 'Pick cover image.',
  'Fon rasmini tanlash', 'Выбрать фон', 'Choose cover')
k('tcCoverChange', 'Change cover image.',
  'Fon rasmini almashtirish', 'Заменить фон', 'Change cover')
k('tcCoverRemove', 'Remove cover image.',
  'Fonni olib tashlash', 'Убрать фон', 'Remove cover')
k('tcCoverHint', 'Recommended cover image size.',
  'Tavsiya: 1500×500 px (3:1), JPG yoki PNG, 1 MB gacha',
  'Рекомендуем: 1500×500 px (3:1), JPG или PNG, до 1 МБ',
  'Recommended: 1500×500 px (3:1), JPG or PNG, up to 1 MB')
k('tcCoverSemantics', 'Semantics label of the cover image.',
  'Fon rasmi', 'Фоновое изображение', 'Cover image')

OVERRIDE['catEmptyExperts'] = (
    'Hozircha katalogda mutaxassis yo‘q. Mutaxassis profilida «Mutaxassislar katalogida ko‘rsatish»ni yoqishi bilan shu yerda chiqadi.',
    'В каталоге пока нет специалистов. Они появятся здесь, как только включат «Показывать в каталоге специалистов» в профиле.',
    'No specialists in the catalogue yet. They appear here once they turn on “Show in the specialists catalogue” in their profile.')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, (desc, *vals, ph) in K.items():
        b[key] = vals[i]
        if lang == 'en':
            b['@' + key] = collections.OrderedDict(description=desc)
    for key, vals in OVERRIDE.items():
        b[key] = vals[i]
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_catalog_cover:', len(K), 'keys')
