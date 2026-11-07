#!/usr/bin/env python3
"""UZ testlarini rasmiy RU testlariga mazmun bo‘yicha tekislash (taklif).

Ishlatish: python3 -I align_ru.py <assessment_v1.json> <spec> <ru.json> <chiqish.json>
Ruscha matn lotinga transliteratsiya qilinadi, o‘zbekcha bilan belgi trigrammalari,
raqamlar bo‘yicha solishtiriladi; tartib saqlanadigan DP (Needleman–Wunsch).
Har juft uchun variant tartibi ham taklif qilinadi (permutatsiya). Natija — faqat
taklif: yakuniy qaror qo‘lda ko‘rib chiqilgan `ru_map_<spec>.json` da.
"""
import json, re, sys, itertools

TR = dict(zip('абвгдеёжзийклмнопрстуфхцчшщъыьэюя',
              ['a','b','v','g','d','e','yo','j','z','i','y','k','l','m','n','o','p','r','s','t','u','f','x','ts','ch','sh','sh','','i','','e','yu','ya']))


def norm_ru(s):
    s = s.lower()
    return ''.join(TR.get(c, c) for c in s)


def norm_uz(s):
    s = s.lower()
    s = re.sub(r"[‘ʻ’'ʼ`]", '', s)
    return s.replace('h', 'x').replace('q', 'k')


def prep(s):
    s = s.replace('h', 'x').replace('q', 'k').replace('ts', 's').replace('ye', 'e').replace('yo', 'o')
    s = s.replace('ii', 'i').replace('ll', 'l').replace('ss', 's').replace('mm', 'm').replace('ff', 'f')
    return re.sub(r'[^a-z0-9 ]', ' ', s)


def grams(s):
    s = prep(s)
    g = set()
    for w in s.split():
        if len(w) < 3:
            if w.isdigit():
                g.add('#' + w)
            continue
        w = f' {w} '
        g |= {w[i:i + 3] for i in range(len(w) - 2)}
    return g


def nums(s):
    return set(re.findall(r'\d+', s))


def sim(a, b):
    if not a or not b:
        return 0.0
    return len(a & b) / len(a | b)


def feats(text, opts, f):
    return {'q': grams(f(text)), 'o': [grams(f(o)) for o in opts], 'n': nums(text + ' ' + ' '.join(opts)),
            'on': [nums(o) for o in opts]}


def best_perm(u, r):
    # r variantlarini u tartibiga keltiruvchi permutatsiya: perm[i] = r indeksi
    M = [[sim(u['o'][i], r['o'][j]) + (0.5 if u['on'][i] and u['on'][i] == r['on'][j] else 0) for j in range(4)] for i in range(4)]
    best = max(itertools.permutations(range(4)), key=lambda p: sum(M[i][p[i]] for i in range(4)))
    ident = sum(M[i][i] for i in range(4))
    bs = sum(M[i][best[i]] for i in range(4))
    if bs - ident < 0.15:
        best = (0, 1, 2, 3)
    return list(best), sum(M[i][best[i]] for i in range(4)) / 4


def score(u, r):
    p, os_ = best_perm(u, r)
    qs = sim(u['q'], r['q'])
    ns = sim(u['n'], r['n']) if (u['n'] or r['n']) else 0.3
    return 0.45 * qs + 0.4 * os_ + 0.15 * ns, p


def main(bundle, spec, ru_path, out):
    tests = next(s for s in json.load(open(bundle, encoding='utf8'))['specialties'] if s['id'] == spec)['tests']
    ru = [r for r in json.load(open(ru_path, encoding='utf8')) if len(r['opts']) == 4]
    U = [feats(t['text'], t['options'], norm_uz) for t in tests]
    R = [feats(r['q'], r['opts'], norm_ru) for r in ru]
    n, m = len(U), len(R)
    W = 12  # oyna: tartib deyarli bir xil deb hisoblanadi
    GAP = 0.08
    NEG = -1e9
    S = {}
    def sc(i, j):
        if (i, j) not in S:
            S[(i, j)] = score(U[i], R[j])
        return S[(i, j)]
    # diagonal oynali DP
    D = [[NEG] * (m + 1) for _ in range(n + 1)]
    B = [[None] * (m + 1) for _ in range(n + 1)]
    D[0][0] = 0
    for i in range(n + 1):
        for j in range(m + 1):
            if i == 0 and j == 0:
                continue
            if abs(i * m / max(n, 1) - j) > 60:
                continue
            c = []
            if i and j and D[i - 1][j - 1] > NEG:
                c.append((D[i - 1][j - 1] + sc(i - 1, j - 1)[0], 'd'))
            if i and D[i - 1][j] > NEG:
                c.append((D[i - 1][j] + GAP, 'u'))
            if j and D[i][j - 1] > NEG:
                c.append((D[i][j - 1] + GAP, 'r'))
            if c:
                D[i][j], B[i][j] = max(c)
    i, j, pairs = n, m, []
    while i or j:
        b = B[i][j]
        if b == 'd':
            pairs.append((i - 1, j - 1)); i -= 1; j -= 1
        elif b == 'u':
            pairs.append((i - 1, None)); i -= 1
        else:
            pairs.append((None, j - 1)); j -= 1
    pairs.reverse()
    res = []
    for a, b in pairs:
        e = {}
        if a is not None:
            e['n'] = tests[a]['n']
        if b is not None:
            e['ru_n'] = ru[b]['n']
        if a is not None and b is not None:
            s, p = sc(a, b)
            e['score'] = round(s, 3)
            e['perm'] = p
        res.append(e)
    json.dump(res, open(out, 'w', encoding='utf8'), ensure_ascii=False, indent=0)
    d = [e for e in res if 'score' in e]
    print(spec, 'pairs', len(d), 'uz-only', sum(1 for e in res if 'ru_n' not in e), 'ru-only', sum(1 for e in res if 'n' not in e),
          'low<0.15', sum(1 for e in d if e['score'] < 0.15), 'perm', sum(1 for e in d if e['perm'] != [0, 1, 2, 3]))


if __name__ == '__main__':
    main(*sys.argv[1:5])
