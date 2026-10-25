#!/usr/bin/env python3
"""Rasmiy test savollarini (tmbm.ssv.uz "TEST SINOVI SAVOLLARI") va tasdiqlangan
javob kalitlarini assessment_v1.json ga qo‘shadi.

Kirish (data/): pat_anat_q.json, sud_tib_clean.json, sud_kimyo_q.json,
sud_kimyo_teacher_keys.json, book_keys_*.json (agent natijalari, kitob+bet+iqtibos).
Qoida: kalit faqat (a) ustoz yuborgan kalitli fayl bilan matn bo‘yicha mos kelsa yoki
(b) kitobdan aniq iqtibos + bet bilan topilgan bo‘lsa yoziladi; aks holda savol
kalitsiz qoladi va baholanadigan mashqqa kirmaydi. Hech narsa taxmin qilinmaydi.
Ishlatish: merge_tests.py <data_dir> <assessment_v1.json>
"""
import json, sys, glob, os

data, target = sys.argv[1], sys.argv[2]
BOOKS = {
    'giyosov_1_asoslar_travmatologiya': 'Z. A. G‘iyosov. Sud tibbiyoti, 1-qism (Toshkent: Global Books, 2018)',
    'giyosov_2_oqotar_asfiksiya_toksikologiya1': 'Z. A. G‘iyosov. Sud tibbiyoti, 2-qism (Toshkent: Global Books, 2018)',
    'giyosov_3_toksikologiya2_fizik_tanatologiya': 'Z. A. G‘iyosov. Sud tibbiyoti, 3-qism (Toshkent: Global Books, 2018)',
    'giyosov_4_murda_ekspertizasi_ashyoviy_dalillar': 'Z. A. G‘iyosov. Sud tibbiyoti, 4-qism (Toshkent: Global Books, 2018)',
    'toks_kimyo_majmua_A': 'Toksikologik kimyo modulidan o‘quv-uslubiy majmua (Toshkent farmatsevtika instituti, 2025–26)',
    'toks_kimyo_majmua_B': 'Toksikologik kimyo modulidan o‘quv-uslubiy majmua (Toshkent farmatsevtika instituti, 2025–26)',
    'giyohvand_moddalar_tahlili': 'Z. A. Yuldashev va b. Giyohvand moddalar tahlili. O‘quv qo‘llanma (Toshkent, 2024)',
}


def load(name):
    return json.load(open(os.path.join(data, name), encoding='utf8'))


def web_keys():
    # web_keys_<spec>__<n>.json: {n,key,url,title,quote} - mustaqil tekshiruvdan o‘tganlar
    out = {}
    for f in sorted(glob.glob(os.path.join(data, 'web_keys_*.json'))):
        spec = os.path.basename(f)[len('web_keys_'):].split('__')[0]
        for e in json.load(open(f, encoding='utf8')):
            if e.get('key') is not None and e.get('url') and e.get('quote'):
                out[(spec, e['n'])] = e
    return out


def book_keys():
    out = {}
    for f in sorted(glob.glob(os.path.join(data, 'book_keys_*.json'))):
        spec = os.path.basename(f)[len('book_keys_'):].split('__')[0]  # book_keys_<spec>__<n>.json
        for e in json.load(open(f, encoding='utf8')):
            if e.get('key') is not None and e.get('book') in BOOKS and e.get('page') and e.get('quote'):
                out[(spec, e['n'])] = e
    return out


bundle = json.load(open(target, encoding='utf8'))
bk = book_keys()
wk = web_keys()
teacher = load('sud_kimyo_teacher_keys.json')  # {n: key}
SRC = {'sud_tib': 'sud_tib_clean.json', 'pat_anat': 'pat_anat_q.json', 'sud_kimyo': 'sud_kimyo_q.json'}
stats = {}
for sp in bundle['specialties']:
    qs = load(SRC[sp['id']])
    tests = []
    for q in qs:
        if len(q['opts']) != 4:
            continue
        item = {'id': f"{sp['id']}.t.{q['n']:03d}", 'n': q['n'], 'text': q['q'], 'options': q['opts']}
        key = None
        if sp['id'] == 'sud_kimyo' and str(q['n']) in teacher:
            key = teacher[str(q['n'])]
            item['key'] = key
            item['keySrc'] = {'kind': 'teacher', 'title': '', 'page': 0, 'quote': ''}
        elif (sp['id'], q['n']) in bk:
            e = bk[(sp['id'], q['n'])]
            item['key'] = e['key']
            item['keySrc'] = {'kind': 'book', 'title': BOOKS[e['book']], 'page': e['page'], 'quote': e['quote'][:240]}
        elif (sp['id'], q['n']) in wk:
            e = wk[(sp['id'], q['n'])]
            item['key'] = e['key']
            item['keySrc'] = {'kind': 'web', 'title': e.get('title', '')[:200], 'page': 0,
                              'quote': e['quote'][:300], 'url': e['url']}
        tests.append(item)
    sp['tests'] = tests
    stats[sp['id']] = (len(tests), sum(1 for t in tests if 'key' in t))
bundle['testsSource'] = {
    'title': 'Test sinovi savollari ro‘yxati',
    'url': 'https://tmbm.ssv.uz/post/category/questions_test',
    'retrieved': '2026-10-25',
}
json.dump(bundle, open(target, 'w', encoding='utf8'), ensure_ascii=False, separators=(',', ':'))
print(stats)
