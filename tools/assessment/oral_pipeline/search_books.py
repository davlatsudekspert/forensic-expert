#!/usr/bin/env python3
"""Kitob sahifalari bo‘yicha qidiruv: search_books.py <books: tib|kimyo|all> "kalit so‘zlar" [top=8]
Natija: kitob, PDF-sahifa, ball, kontekst parchasi. Qidiruv so‘z qismlariga (prefiks) mos; OCR shovqiniga chidamli emas —
bir nechta yozilish variantini sinab ko‘ring (o‘/o', g‘/g' belgilari olib tashlanadi)."""
import re, sys, os, math, collections
W = os.path.dirname(os.path.abspath(__file__))
SETS = {
 'tib': ['giyosov_1_asoslar_travmatologiya','giyosov_2_oqotar_asfiksiya_toksikologiya1','giyosov_3_toksikologiya2_fizik_tanatologiya','giyosov_4_murda_ekspertizasi_ashyoviy_dalillar'],
 'kimyo': ['toks_kimyo_majmua_A','giyohvand_moddalar_tahlili'],
}
SETS['all'] = SETS['tib'] + SETS['kimyo'] + ['toks_kimyo_majmua_B']
def norm(s):
    s = s.lower()
    for a in "‘’ʻʼ`´'": s = s.replace(a, '')
    return s
def pages(book):
    t = open(os.path.join(W, f'book_{book}.txt'), encoding='utf8').read()
    parts = re.split(r'\n=====\[[^\]]+\] PDF-SAHIFA (\d+)=====\n', t)
    return {int(parts[i]): parts[i+1] for i in range(1, len(parts), 2)}
def main():
    which, q = sys.argv[1], sys.argv[2]
    top = int(sys.argv[3]) if len(sys.argv) > 3 else 8
    terms = [w for w in re.findall(r'[a-zа-я0-9]+', norm(q)) if len(w) >= 3]
    docs = []
    for b in SETS[which]:
        for n, txt in pages(b).items():
            docs.append((b, n, txt, norm(txt)))
    df = collections.Counter()
    for _, _, _, nt in docs:
        for w in terms:
            if w[:max(4, len(w)-2)] in nt: df[w] += 1
    res = []
    for b, n, txt, nt in docs:
        sc = 0
        for w in terms:
            stem = w[:max(4, len(w)-2)]
            c = nt.count(stem)
            if c: sc += (1 + math.log(c)) * math.log(1 + len(docs) / (1 + df[w]))
        if sc: res.append((sc, b, n, txt, nt))
    res.sort(reverse=True)
    for sc, b, n, txt, nt in res[:top]:
        i = min([nt.find(w[:max(4, len(w)-2)]) for w in terms if w[:max(4, len(w)-2)] in nt] or [0])
        snippet = re.sub(r'\s+', ' ', txt[max(0, i-80): i+260])
        print(f'[{b} | PDF-SAHIFA {n} | {sc:.1f}] ...{snippet}...')
main()
