#!/usr/bin/env python3
"""Jahon adabiyoti kalitlarini yig‘adi. Faqat mustaqil auditdan o‘tganlar kiradi:
verdict == DIRECT, correct_index == da’vo qilingan kalit, quote_ok, source_quality == strong.
Ishlatish: assemble_web_keys.py <qwork_dir> <data_dir>
(qwork_dir: web_out_*.json — qidiruv agentlari, wver_out_*.json — auditorlar natijasi)
"""
import glob, json, os, sys

W, D = sys.argv[1], sys.argv[2]
claims = {}  # id -> entry
for f in glob.glob(os.path.join(W, 'wver_in_*.json')):
    for e in json.load(open(f, encoding='utf8')):
        claims[e['id']] = e
audit = {}
for f in sorted(glob.glob(os.path.join(W, 'wver_out_*.json'))):
    for e in json.load(open(f, encoding='utf8')):
        audit[e['id']] = e
# qo‘lda chiqarilganlar: auditorlar topgan nuqsonlar (sabab bilan)
MANUAL_EXCLUDE = {
    'sud_tib:67': 'JPK 177-modda ekspertiza o‘tkazish tartibi; tayinlash 176¹ da',
}
out = {}
rows = []
for i, a in audit.items():
    c = claims.get(i)
    if not c:
        continue
    ok = (a['verdict'] == 'DIRECT' and a.get('correct_index') in (None, c['claimed_key'])
          and a.get('quote_ok') and a.get('source_quality') == 'strong' and i not in MANUAL_EXCLUDE)
    rows.append({'id': i, 'claimed': c['claimed_key'], 'verdict': a['verdict'], 'quote_ok': a.get('quote_ok'),
                 'source_quality': a.get('source_quality'), 'why': a.get('why', ''), 'accepted': ok,
                 'url': c['url']})
    if ok:
        spec, n = i.split(':')
        out.setdefault(spec, []).append({'n': int(n), 'key': c['claimed_key'], 'url': c['url'],
                                         'title': c.get('title', ''), 'quote': c['quote']})
for spec, lst in out.items():
    lst.sort(key=lambda x: x['n'])
    json.dump(lst, open(os.path.join(D, f'web_keys_{spec}__verified.json'), 'w', encoding='utf8'),
              ensure_ascii=False, indent=0)
os.makedirs(os.path.join(D, 'audit'), exist_ok=True)
json.dump(rows, open(os.path.join(D, 'audit', 'web_key_audit.json'), 'w', encoding='utf8'),
          ensure_ascii=False, indent=0)
print({k: len(v) for k, v in out.items()}, 'audited', len(rows), 'accepted', sum(r['accepted'] for r in rows))
