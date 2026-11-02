#!/usr/bin/env python3
"""Asbob-uskunalar: SPE kartochkasi — rasm original sxema ekani haqida izoh
(egasi so‘rovi, 2026-11-03). Tartib: `l10n_oral_exam.py` dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
I = {'type': 'int'}
S = {'type': 'String'}
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('equipSchemeNote', 'Note under a schematic (original drawing) in an equipment card.',
  'Sxema (original chizma) — muayyan apparatning surati emas. Raqamlar bosqichlarga mos; oltin nuqtalar — aniqlanadigan modda, kulrang nuqtalar — matritsa halaqitlari.',
  'Схема (оригинальный рисунок), а не фотография конкретного прибора. Цифры соответствуют этапам; золотые точки — определяемое вещество, серые — мешающие компоненты матрицы.',
  'Schematic (original drawing), not a photo of a specific instrument. Numbers match the steps; gold dots are the analyte, grey dots are matrix interferences.')
k('methodDeviceCard', 'Link on a method page to the full equipment card.',
  'Qurilma, ehtiyot choralari va O‘zbekistondagi holat',
  'Оборудование, меры предосторожности и ситуация в Узбекистане',
  'Equipment, precautions and the situation in Uzbekistan')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, (desc, *vals, ph) in K.items():
        b[key] = vals[i]
        if lang == 'en':
            m = collections.OrderedDict(description=desc)
            if ph:
                m['placeholders'] = {n: dict(t) for n, t in ph.items()}
            b['@' + key] = m
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_spe_scheme:', len(K), 'keys')
