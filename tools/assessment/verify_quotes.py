#!/usr/bin/env python3
"""Agent topgan kalitlarning iqtibosi kitob matnida (ko‘rsatilgan sahifa ±1) bor-yo‘qligini
tekshiradi. OCR shovqini (bo‘sh joylar, tinish belgilari) e’tiborga olinmaydi.

Ishlatish: verify_quotes.py <qwork_dir> <out_json> <input_out_json>...
Chiqish: [{"n":..,"spec":..,"ok":bool,...}] — faqat iqtibosi topilganlar keyingi
(mustaqil) tekshiruvga o‘tadi. Hech qanday kalit bu skriptda "tasdiqlanmaydi".
"""
import json, os, re, sys

W = sys.argv[1]
OUT = sys.argv[2]
INPUTS = sys.argv[3:]


def squash(s: str) -> str:
    s = s.lower()
    for a in "‘’ʻʼ`´'‑–—-":
        s = s.replace(a, '')
    return re.sub(r'[^a-z0-9а-яё]+', '', s)


pages = {}


def book_pages(book: str):
    if book not in pages:
        txt = open(os.path.join(W, f'book_{book}.txt'), encoding='utf8').read()
        parts = re.split(r'\n=====\[[^\]]+\] PDF-SAHIFA (\d+)=====\n', txt)
        d = {}
        for i in range(1, len(parts), 2):
            d[int(parts[i])] = squash(parts[i + 1])
        pages[book] = d
    return pages[book]


res = []
for f in INPUTS:
    for e in json.load(open(f, encoding='utf8')):
        if e.get('key') is None:
            continue
        ok = False
        try:
            bp = book_pages(e['book'])
            q = squash(e['quote'])
            ok = len(q) >= 12 and any(q in bp.get(p, '') for p in (e['page'] - 1, e['page'], e['page'] + 1))
        except Exception:
            ok = False
        res.append({'file': os.path.basename(f), **e, 'quote_found': ok})
json.dump(res, open(OUT, 'w', encoding='utf8'), ensure_ascii=False, indent=1)
print(len(res), 'keyed;', sum(r['quote_found'] for r in res), 'quote found in book')
