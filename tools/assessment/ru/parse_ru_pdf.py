#!/usr/bin/env python3
"""Rasmiy ruscha test PDF (tmbm.ssv.uz, «Перечень тестовых вопросов») -> JSON.

Ishlatish: python3 -I parse_ru_pdf.py <pdf> <chiqish.json>
Natija: [{"n": int, "q": str, "opts": [4 ta str], "warn": str?}]
Qatorlar «mantiqiy qator»ga birlashtiriladi: oldingi qator o‘ng chetga yetgan
bo‘lsa (so‘z ko‘chishi), keyingi qator uning davomi. Savol raqami bilan boshlangan
qator yangi blok; blokdagi oxirgi 4 mantiqiy qator — variantlar.
"""
import json, re, sys
import pdfplumber

NUM = re.compile(r'^(\d{1,3})(?:\.|\s)\s*(.*)$')


def lines(pdf):
    for page in pdf.pages:
        ls = [l for l in page.extract_text_lines() if l['text'].strip()]
        if not ls:
            continue
        right = max(l['x1'] for l in ls)
        for l in ls:
            yield {'t': l['text'].strip(), 'x0': l['x0'], 'x1': l['x1'], 'right': right,
                   'bold': 'Bold' in l['chars'][0]['fontname']}


def join(a, b):
    if a.endswith('-') and not a.endswith(' -'):
        return a[:-1] + b
    return a + ' ' + b


def merge(ls, k):
    """Qatorlarni k ta mantiqiy qatorga birlashtirish: eng ehtimolli so‘z ko‘chishlari
    (oldingi qator uzun, keyingisi kichik harf bilan) birinchi."""
    items = [[l['t'], l['x1'], l['right']] for l in ls]
    while len(items) > k:
        best, bi = None, 0
        for i in range(len(items) - 1):
            a, b = items[i], items[i + 1]
            sc = a[1] / a[2]
            if b[0][:1].islower():
                sc += 0.3
            if a[0].endswith((',', '-', ' и', ' в', ' с', ' на')):
                sc += 0.3
            if a[0].endswith(('.', ':')):
                sc -= 0.3
            if best is None or sc > best:
                best, bi = sc, i
        a, b = items[bi], items.pop(bi + 1)
        items[bi] = [join(a[0], b[0]), b[1], b[2]]
    return [i[0] for i in items]


def main(src, out):
    pdf = pdfplumber.open(src)
    blocks, cur, expect = [], None, 1
    for l in lines(pdf):
        m = NUM.match(l['t'])
        if m and int(m.group(1)) == expect and m.group(2):
            cur = {'n': expect, 'lines': [dict(l, t=m.group(2))]}
            blocks.append(cur)
            expect += 1
            continue
        if cur is None:
            continue  # sarlavha
        cur['lines'].append(l)
    res = []
    for b in blocks:
        ls = b['lines']
        warn = ''
        if any(l['t'].startswith(('- ', '– ')) for l in ls[1:]):
            # sud_kimyo: variantlar «- » bilan boshlanadi, savol qalin
            q, opts = [], []
            for l in ls:
                t = l['t']
                if t.startswith(('- ', '– ')):
                    opts.append(t[2:].strip())
                elif opts:
                    opts[-1] = join(opts[-1], t)
                else:
                    q.append(t)
            q = ' '.join(q)
        else:
            qi = next((i for i, l in enumerate(ls[:8]) if l['t'].rstrip().endswith((':', '?'))), None)
            if qi is None or len(ls) - qi - 1 < 4:
                # ikki nuqtasiz savol: birinchi qisqa (chetga yetmagan) qator savol oxiri
                qi = next((i for i, l in enumerate(ls[:8]) if l['x1'] / l['right'] < 0.85
                           and len(ls) - i - 1 >= 4), None)
                warn = 'savol-chegara'
            if qi is not None and len(ls) - qi - 1 >= 4:
                q = ' '.join(l['t'] for l in ls[:qi + 1])
                opts = merge(ls[qi + 1:], 4)
                if len(ls) - qi - 1 > 4:
                    warn = (warn + ' variant-birlashtirildi').strip()
            else:
                m = merge(ls, 5)
                q, opts = m[0], m[1:]
                warn = 'savol-chegara'
        if len(opts) != 4:
            warn = f'{len(opts)} variant'
        e = {'n': b['n'], 'q': re.sub(r'\s+', ' ', q).strip(), 'opts': [re.sub(r'\s+', ' ', o).strip() for o in opts]}
        if warn:
            e['warn'] = warn
        res.append(e)
    json.dump(res, open(out, 'w', encoding='utf8'), ensure_ascii=False, indent=1)
    print(src.split('/')[-1], len(res), 'warn', sum(1 for r in res if 'warn' in r))


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
