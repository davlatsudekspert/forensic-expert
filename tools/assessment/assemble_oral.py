#!/usr/bin/env python3
"""Og‘zaki savollarga javoblarni (auditdan o‘tgan) ilova asset’iga yig‘adi.

Ishlatish: assemble_oral.py <qwork_dir> [<out_dir>]

Manba: <qwork>/oral_ver_in_*.json (audit kirishi — matn va indekslar shu yerdan) va
<qwork>/oral_ver_out_*.json (mustaqil auditor hukmi). Qoidalar:
  * topic_ok == false  -> savolning javobi butunlay tushiriladi («tez kunda»);
  * OK                 -> matn o‘zgarishsiz;
  * OVERSTATED         -> faqat auditorning `fix` matni (bo‘sh bo‘lsa tushiriladi);
  * WRONG              -> tushiriladi (accept_wrong_fix.json dagilar `fix` bilan);
  * oral_exclude.json  -> tushiriladi;
  * source_quality == weak -> tushiriladi;
  * iqtibos kitob sahifasida (±1) / saqlangan manba faylida topilmasa -> tushiriladi;
  * 3 tadan kam band qolsa -> javob tushiriladi.
Kitob sahifasi — iqtibos aslida topilgan PDF-sahifa.
"""
import glob
import json
import os
import re
import sys

W = sys.argv[1]
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', 'apps', 'mobile', 'assets', 'content', 'assessment')
BASE = os.path.join(OUT, 'assessment_v1.json')

BOOKS = {
    'giyosov_1_asoslar_travmatologiya': 'Z. A. G‘iyosov. Sud tibbiyoti, 1-qism (Toshkent: Global Books, 2018)',
    'giyosov_2_oqotar_asfiksiya_toksikologiya1': 'Z. A. G‘iyosov. Sud tibbiyoti, 2-qism (Toshkent: Global Books, 2018)',
    'giyosov_3_toksikologiya2_fizik_tanatologiya': 'Z. A. G‘iyosov. Sud tibbiyoti, 3-qism (Toshkent: Global Books, 2018)',
    'giyosov_4_murda_ekspertizasi_ashyoviy_dalillar': 'Z. A. G‘iyosov. Sud tibbiyoti, 4-qism (Toshkent: Global Books, 2018)',
    'toks_kimyo_majmua_A': 'Toksikologik kimyo modulidan o‘quv-uslubiy majmua (Toshkent farmatsevtika instituti, 2025–26)',
    'giyohvand_moddalar_tahlili': 'Z. A. Yuldashev va b. Giyohvand moddalar tahlili. O‘quv qo‘llanma (Toshkent, 2024)',
}
# Terminologiya tuzatishlari (audit topilmalari)
TERMS = [
    (r'obkladochniy|obkladochnye|obkladochn\w*', 'qoplovchi (parietal)'),
    (r'\bvorsinkali\b', 'vorsinkasimon (villyoz)'),
    (r'\bSurinkali\b', 'Surunkali'),
    (r'\bsurinkali\b', 'surunkali'),
    (r'HBcorAg', 'HBcAg'),
]
# Faqat ko‘rsatilgan audit faylidagi tuzatish matnlariga: «нередко» ning «kam uchramaydi»
# deb berilishi o‘zbekchada teskari ma’no beradi.
FILE_TERMS = {
    'oral_ver_in_pat_anat_11.json': [('kam uchramaydi', 'nisbatan tez-tez uchraydi')],
}
STRUKOV = 'А.И. Струков, В.В. Серов. Патологическая анатомия (darslik; matni medchitalka.ru saytida, sahifa havolasi har bandda)'
GAP_BAD = re.compile(r'xato|zid|shubhali|OCR|buzilgan|noto‘g‘ri|noto\'g\'ri|ziddiyat', re.I)

excl = {(a, b) for a, b in json.load(open(os.path.join(W, 'oral_exclude.json')))}
accept = {(a, b) for a, b in json.load(open(os.path.join(W, 'accept_wrong_fix.json')))}
meta = json.load(open(os.path.join(W, 'oral_unique_meta.json')))
dups = {}
for spec, items in meta.items():
    for it in items:
        if it.get('same_as'):
            dups[it['id']] = it['same_as']

base = json.load(open(BASE, encoding='utf8'))
all_qids = {s['id']: [q['id'] for c in s['categories'] for q in c['questions']] for s in base['specialties']}


def squash(s):
    s = s.lower()
    for a in "‘’ʻʼ`´'‑–—-":
        s = s.replace(a, '')
    return re.sub(r'[^a-z0-9а-яё]+', '', s)


_pages = {}


def book_pages(book):
    if book not in _pages:
        txt = open(os.path.join(W, f'book_{book}.txt'), encoding='utf8').read()
        parts = re.split(r'\n=====\[[^\]]+\] PDF-SAHIFA (\d+)=====\n', txt)
        _pages[book] = {int(parts[i]): squash(parts[i + 1]) for i in range(1, len(parts), 2)}
    return _pages[book]


def found_page(book, page, quote):
    q = squash(quote)
    if len(q) < 12:
        return None
    bp = book_pages(book)
    for p in (page, page - 1, page + 1):
        if q in bp.get(p, ''):
            return p
    return None


def web_ok(src, quote):
    if not src:
        return False
    try:
        t = open(os.path.join(W, src), encoding='utf8', errors='replace').read()
    except OSError:
        return False
    q = squash(quote)
    return len(q) >= 12 and q in squash(t)


def clean_text(t):
    for pat, rep in TERMS:
        t = re.sub(pat, rep, t)
    return t.strip()


sources = []
src_index = {}


def src_id(kind, title, url):
    key = (kind, title, url)
    if key not in src_index:
        src_index[key] = len(sources)
        sources.append({'k': kind, 't': title, **({'u': url} if url else {})})
    return src_index[key]


answers = {}
stats = {'q_in': 0, 'q_kept': 0, 'p_in': 0, 'p_kept': 0, 'drop': {}}


def drop(why):
    stats['drop'][why] = stats['drop'].get(why, 0) + 1


for fin in sorted(glob.glob(os.path.join(W, 'oral_ver_in_*.json'))):
    fout = fin.replace('oral_ver_in_', 'oral_ver_out_')
    if not os.path.exists(fout):
        continue
    ver = {q['id']: q for q in json.load(open(fout, encoding='utf8'))}
    # web-manba nomi -> src fayl: oral_out_* dagi `src` maydonidan
    srcmap = {}
    draft = fin.replace('oral_ver_in_', 'oral_out_')
    if os.path.exists(draft):
        for q in json.load(open(draft, encoding='utf8')):
            for i, p in enumerate(q['points']):
                srcmap[(q['id'], i)] = p.get('src')
    file_terms = FILE_TERMS.get(os.path.basename(fin), [])
    for q in json.load(open(fin, encoding='utf8')):
        stats['q_in'] += 1
        if (q['id'], -1) in excl:
            drop('savol butunlay chiqarilgan')
            continue
        v = ver.get(q['id'])
        if not v or not v.get('topic_ok', False):
            drop('topic_ok=false' if v else 'auditsiz')
            continue
        vp = {p['i']: p for p in v['points']}
        pts = []
        for p in q['points']:
            stats['p_in'] += 1
            key = (q['id'], p['i'])
            ver_p = vp.get(p['i'])
            if ver_p is None:
                drop('auditsiz band')
                continue
            if key in excl:
                drop('exclude')
                continue
            if ver_p.get('source_quality') == 'weak':
                drop('weak manba')
                continue
            verdict = ver_p['verdict']
            text = p['text']
            if verdict == 'OVERSTATED':
                if not ver_p.get('fix'):
                    drop('OVERSTATED fix yo‘q')
                    continue
                text = ver_p['fix']
                for a, b in file_terms:
                    text = text.replace(a, b)
            elif verdict == 'WRONG':
                if key in accept and ver_p.get('fix'):
                    text = ver_p['fix']
                else:
                    drop('WRONG')
                    continue
            elif verdict != 'OK':
                drop('noma’lum hukm')
                continue
            if p['book'] == 'web':
                if not web_ok(srcmap.get(key), p['quote']):
                    drop('web iqtibos topilmadi')
                    continue
                if 'medchitalka.ru' in p.get('url', ''):
                    # Darslik matni sayt sahifalarida: bitta manba, sahifa havolasi bandda.
                    sid = src_id('web', STRUKOV, 'https://www.medchitalka.ru')
                else:
                    sid = src_id('web', p.get('title', ''), p.get('url', ''))
                page = 0
            else:
                page = found_page(p['book'], p['page'], p['quote'])
                if page is None:
                    drop('kitob iqtibosi topilmadi')
                    continue
                sid = src_id('book', BOOKS[p['book']], '')
            item = {'t': clean_text(text), 's': sid, 'q': re.sub(r'\s+', ' ', p['quote']).strip()}
            if page:
                item['p'] = page
            if p.get('url') and p['book'] == 'web':
                item['u'] = p['url']
            pts.append(item)
        if len(pts) < 3:
            drop('3 tadan kam band')
            continue
        gaps = [g for g in q.get('gaps', []) if not GAP_BAD.search(g)]
        cov = 'full' if (q['coverage'] == 'full' and len(pts) >= 0.8 * len(q['points'])) else 'partial'
        ans = {'c': cov, 'p': pts}
        if cov == 'partial' and gaps:
            ans['g'] = gaps
        answers[q['id']] = ans
        stats['q_kept'] += 1
        stats['p_kept'] += len(pts)

# takror savollar (bir xil matn) — javobni ko‘chirish
for qid, same in dups.items():
    if qid in answers:
        for s in same:
            answers.setdefault(s, answers[qid])

# mutaxassislik bo‘yicha fayllar
by_spec = {}
for qid, a in answers.items():
    by_spec.setdefault(qid.split('.')[0], {})[qid] = a
total_bytes = 0
for spec, ans in by_spec.items():
    used = sorted({pt['s'] for a in ans.values() for pt in a['p']})
    remap = {old: i for i, old in enumerate(used)}
    out_ans = {}
    for qid, a in ans.items():
        out_ans[qid] = {**a, 'p': [{**pt, 's': remap[pt['s']]} for pt in a['p']]}
    doc = {'version': 1, 'spec': spec, 'sources': [sources[i] for i in used], 'answers': out_ans}
    path = os.path.join(OUT, f'oral_{spec}.json')
    with open(path, 'w', encoding='utf8') as f:
        json.dump(doc, f, ensure_ascii=False, separators=(',', ':'))
    total_bytes += os.path.getsize(path)
    cnt = len(out_ans)
    print(f'{spec}: {cnt}/{len(all_qids[spec])} savolga javob, {os.path.getsize(path) // 1024} KB')
print('stats:', json.dumps(stats, ensure_ascii=False))
print('jami', total_bytes // 1024, 'KB')
