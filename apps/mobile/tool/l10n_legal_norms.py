#!/usr/bin/env python3
"""Huquqiy normalar (O‘zbekiston: JPK/JK/sud-ekspertlik qonuni) ekrani matnlari (uz/ru/en).
`flutter gen-l10n` dan oldin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('legalNormsTitle', 'Jurisdiction: forensic expertise norms screen title.',
  'Sud-ekspertiza normalari', 'Нормы судебной экспертизы', 'Forensic expertise norms')
k('legalNormsBody', 'Jurisdiction: norms entry subtitle.',
  'Ekspertning huquq, majburiyat va javobgarligi; ekspertiza tayinlash va xulosa',
  'Права, обязанности и ответственность эксперта; назначение экспертизы и заключение',
  'Expert rights, duties and liability; ordering an examination and the conclusion')
k('legalNormsReview', 'Banner: norms are summaries awaiting legal review.',
  'Yurist tekshiruvi kutilmoqda. Qisqartirilgan mazmun rasmiy matn o‘rnini bosmaydi — to‘liq matn uchun rasmiy havolaga qarang.',
  'Ожидается проверка юриста. Краткое содержание не заменяет официальный текст — полный текст по официальной ссылке.',
  'Awaiting legal review. The short summary does not replace the official text — see the official link for the full text.')
k('legalNormsLangNote', 'Note: summaries are in Uzbek only.',
  'Qisqa mazmun o‘zbek tilida.', 'Краткое содержание — на узбекском языке.', 'Summaries are in Uzbek.')
k('legalNormsNone', 'No norms recorded for this jurisdiction.',
  'Bu yurisdiksiya uchun tasdiqlangan norma yo‘q.', 'Для этой юрисдикции подтверждённых норм нет.',
  'No verified norms for this jurisdiction.')
k('legalStatusNotYet', 'Instrument status: not yet in force.',
  'Hali kuchga kirmagan', 'Ещё не вступил в силу', 'Not yet in force')
k('legalNormArticle', 'Article label.', '{article}-modda', 'Статья {article}', 'Art. {article}',
  {'article': {'type': 'String'}})
k('legalInForceFrom', 'Chip: in force from date.', '{date} dan amal qiladi', 'Действует с {date}', 'In force from {date}',
  {'date': {'type': 'String'}})
k('legalInForceUntil', 'Chip: in force until date.', '{date} gacha amalda', 'Действует до {date}', 'In force until {date}',
  {'date': {'type': 'String'}})

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'), object_pairs_hook=collections.OrderedDict)
    for key, (desc, uz, ru, en, ph) in K.items():
        b[key] = (uz, ru, en)[i]
        if lang == 'en':
            m = collections.OrderedDict(description=desc)
            if ph:
                m['placeholders'] = ph
            b['@' + key] = m
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('l10n_legal_norms:', len(K), 'keys')
