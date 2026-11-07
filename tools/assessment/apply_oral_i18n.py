#!/usr/bin/env python3
"""Og‘zaki imtihon savollariga (specialties[].categories[].questions[]) RU/EN qo‘shadi.

Faqat `questions` qismi o‘zgaradi; `tests` (MCQ) va boshqa maydonlarga tegilmaydi
(MCQ tarjimasi — apply_tests_i18n.py). Qayta ishga tushirish xavfsiz.

Manbalar (data/):
* oral_ru_official/ru_official.json — tmbm.ssv.uz rasmiy ruscha «Перечень устных
  вопросов» (DOCX dan, parse/parse_ru_oral.py) toifalar bo‘yicha;
* oral_ru_official/match.json — qo‘lda moslash: o‘zbekcha savol indeksi -> rasmiy
  RU indeks (shu toifada). `diag` — tartib bir xil; `<key>.errors` — rasmiy RU
  matnida mazmun xatosi bo‘lgan indekslar (ular uchun LLM tarjima);
* oral_ru_official/en_from_official.json — rasmiy RU matnidan inglizcha (LLM);
* oral_llm_i18n.json — o‘zbekchadan LLM tarjima [{uz, ru?, en}].

Natija maydonlari: text_ru, ru_src («official» | «llm»), text_en, en_src («llm»).
O‘zbekcha matn tarjima qilingan matndan farq qilsa (manba o‘zgargan) — LLM tarjima
qo‘yilmaydi (eskirgan tarjima ko‘rsatilmaydi).
Ishlatish: apply_oral_i18n.py <data_dir> <assessment_v1.json>
"""
import json
import os
import sys

FIELDS = ('text_ru', 'ru_src', 'text_en', 'en_src')


def load(data, name):
    return json.load(open(os.path.join(data, name), encoding='utf8'))


def apply(data, bundle):
    ru_off = load(data, 'oral_ru_official/ru_official.json')
    match = load(data, 'oral_ru_official/match.json')
    en_off = load(data, 'oral_ru_official/en_from_official.json')
    llm = {e['uz'].strip(): e for e in load(data, 'oral_llm_i18n.json')}
    stats = {}
    for sp in bundle['specialties']:
        for cat in sp.get('categories', []):
            key = f"{sp['id']}.{cat['id']}"
            rule = match.get(key, {})
            errors = set(match.get(key + '.errors', []))
            official = ru_off.get(sp['id'], {}).get(cat['id'], [])
            st = stats.setdefault(key, {'official': 0, 'llm': 0, 'none': 0})
            for i, q in enumerate(cat['questions']):
                for f in FIELDS:
                    q.pop(f, None)
                j = None
                if rule == 'diag':
                    if i < len(official) and i not in errors:
                        j = i
                elif isinstance(rule, dict) and str(i) in rule:
                    j = rule[str(i)]
                tr = llm.get(q['text'].strip(), {})
                if j is not None:
                    ru = official[j]
                    q['text_ru'] = ru
                    q['ru_src'] = 'official'
                    en = en_off.get(ru) or tr.get('en')
                    st['official'] += 1
                elif tr.get('ru'):
                    q['text_ru'] = tr['ru']
                    q['ru_src'] = 'llm'
                    en = tr.get('en')
                    st['llm'] += 1
                else:
                    en = tr.get('en')
                    st['none'] += 1
                if en:
                    q['text_en'] = en
                    q['en_src'] = 'llm'
    return stats


if __name__ == '__main__':
    data, path = sys.argv[1], sys.argv[2]
    raw = open(path, encoding='utf8').read()
    bundle = json.loads(raw)
    stats = apply(data, bundle)
    out = json.dumps(bundle, ensure_ascii=False, separators=(',', ':'))
    if raw.endswith('\n'):
        out += '\n'
    open(path, 'w', encoding='utf8').write(out)
    for k, v in stats.items():
        print(k, v)
