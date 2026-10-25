#!/usr/bin/env python3
"""oral_build_ver.py <draft_out.json> <ver_in.json> : har bir band uchun kitob-sahifada iqtibos topilishini tekshiradi
(book-rejim) va auditor uchun iqtibos atrofidagi kontekstni qo‘shadi. Topilmagan iqtibosli bandlar 'quote_ok': false."""
import json, re, sys, os
W = os.path.dirname(os.path.abspath(__file__))
out, ver = sys.argv[1], sys.argv[2]
b = json.load(open('/home/user/fe-pro/apps/mobile/assets/content/assessment/assessment_v1.json'))
qt = {q['id']: q['text'] for s in b['specialties'] for c in s['categories'] for q in c['questions']}
def squash_map(s):
    keep = []; idx = []
    for i, ch in enumerate(s):
        c = ch.lower()
        if c in "‘’ʻʼ`´'‑–—-": continue
        if re.match(r'[a-z0-9а-яё]', c):
            keep.append(c); idx.append(i)
    return ''.join(keep), idx
cache = {}
def page_text(book, page):
    key = book
    if key not in cache:
        if book.startswith('web:'):
            cache[key] = None
        else:
            t = open(os.path.join(W, f'book_{book}.txt'), encoding='utf8').read()
            parts = re.split(r'\n=====\[[^\]]+\] PDF-SAHIFA (\d+)=====\n', t)
            cache[key] = {int(parts[i]): parts[i+1] for i in range(1, len(parts), 2)}
    return cache[key].get(page, '') if cache[key] is not None else ''
items = []
bad = 0; tot = 0
for e in json.load(open(out)):
    pts = []
    for i, p in enumerate(e['points']):
        tot += 1
        ctx = ''; ok = False
        cands = [(p['page'], None)] if p['book'] != 'web' else [(0, p.get('src'))]
        if p['book'] != 'web': cands = [(pg, None) for pg in (p['page'], p['page'] - 1, p['page'] + 1)]
        for pg, src in cands:
            if src:
                try: txt = open(os.path.join(W, src), encoding='utf8', errors='replace').read()
                except OSError: txt = ''
            else:
                txt = page_text(p['book'], pg)
            sq, idx = squash_map(txt)
            qq, _ = squash_map(p['quote'])
            j = sq.find(qq) if len(qq) >= 12 else -1
            if j >= 0:
                s0 = idx[j]; e0 = idx[min(j + len(qq) - 1, len(idx) - 1)]
                ctx = re.sub(r'\s+', ' ', txt[max(0, s0 - 500): e0 + 500]); ok = True; break
        if not ok: bad += 1
        pts.append({'i': i, 'text': p['text'], 'book': p['book'], 'page': p['page'], 'quote': p['quote'], 'url': p.get('url',''), 'title': p.get('title',''), 'context': ctx, 'quote_ok': ok})
    items.append({'id': e['id'], 'question': qt.get(e['id'], ''), 'coverage': e['coverage'], 'gaps': e.get('gaps', []), 'points': pts})
json.dump(items, open(ver, 'w'), ensure_ascii=False, indent=0)
print(len(items), 'questions', tot, 'points', bad, 'quote not found')
