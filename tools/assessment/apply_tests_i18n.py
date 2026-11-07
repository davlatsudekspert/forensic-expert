#!/usr/bin/env python3
"""data/tests_i18n.json dagi RU/EN maydonlarini assessment_v1.json testlariga qo‘shadi.

Qo‘shiladigan maydonlar: text_ru, options_ru, text_en, options_en, ru_src
(«official» — tmbm.ssv.uz rasmiy ruscha PDF; «llm» — mashina tarjimasi), en_src («llm»).
key/keySrc va o‘zbekcha matn o‘zgarmaydi (UZ_FIXES dan tashqari). Qayta ishga tushirish xavfsiz.
Ishlatish: apply_tests_i18n.py <tests_i18n.json> <assessment_v1.json>
merge_tests.py oxirida avtomatik chaqiriladi (data/tests_i18n.json bo‘lsa).
"""
import json
import sys

FIELDS = ('text_ru', 'options_ru', 'text_en', 'options_en', 'ru_src', 'en_src')
# O‘zbekcha manbadagi variantlar noto‘g‘ri bo‘lingan (rasmiy RU bo‘yicha tiklandi; kalit yo‘q).
UZ_FIXES = {
    ('sud_tib', 327): [
        'murda elementlari bilan taqqoslash uchun suvning tarkibiy elementlarini aniqlash maqsadida',
        'suvdagi planktonni topish va murda organizmida topilgan plankton bilan taqqoslash uchun',
        'suv florasini o‘stirish maqsadida',
        'suvning fizik-kimyoviy xususiyatlarini aniqlash maqsadida',
    ],
}


def apply(i18n, bundle):
    n_set = 0
    for sp in bundle['specialties']:
        tr = i18n['specialties'].get(sp['id'], {})
        for t in sp.get('tests', []):
            fix = UZ_FIXES.get((sp['id'], t['n']))
            if fix and 'key' not in t:
                t['options'] = fix
            e = tr.get(str(t['n']))
            for f in FIELDS:
                t.pop(f, None)
            if not e:
                continue
            for f in FIELDS:
                if f in e:
                    t[f] = e[f]
            n_set += 1
    return n_set


if __name__ == '__main__':
    i18n = json.load(open(sys.argv[1], encoding='utf8'))
    path = sys.argv[2]
    raw = open(path, encoding='utf8').read()
    bundle = json.loads(raw)
    n = apply(i18n, bundle)
    out = json.dumps(bundle, ensure_ascii=False, separators=(',', ':'))
    if raw.endswith('\n'):
        out += '\n'
    open(path, 'w', encoding='utf8').write(out)
    print('tests with i18n:', n)
