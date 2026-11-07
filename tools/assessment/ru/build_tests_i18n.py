#!/usr/bin/env python3
"""Rasmiy test savollarining RU va EN versiyalarini yig‘adi -> data/tests_i18n.json.

Kirish (ru/data/):
  ru_parsed_<spec>.json   — rasmiy RU PDF (tmbm.ssv.uz) dan parse_ru_pdf.py natijasi
  fixes_<spec>.jsonl      — qo‘lda ko‘rilgan tuzatishlar: {n, q?, opts?, perm?, replace?,
                            replace_re?, llm?, note?}; n siz yozuv — butun mutaxassislikka.
                            llm=true: rasmiy matn ma’nosi o‘zbekchadan farq qilgan/buzilgan,
                            tuzatilgan matn «llm» (mashina tarjimasi) deb belgilanadi.
  ru_llm_<spec>.txt       — n|savol|v1|v2|v3|v4 — rasmiy RU topilmagan/rad etilgan testlar
                            uchun mashina tarjimasi (o‘zbekchadan)
  align_sud_kimyo.json    — [[uz_n, ru_n, perm]] — sud_kimyo da raqamlar mos emas, qo‘lda
                            tasdiqlangan juftlar (perm[i] = UZ i-variantiga mos RU indeks)
  en_<spec>.txt           — n|savol|v1..v4 — inglizcha tarjima (rasmiy RU bor bo‘lsa undan)
sud_tib va pat_anat da UZ raqami = RU raqami (tekshirildi). Variantlar tartibi UZ bo‘yicha.
Ishlatish: python3 -I build_tests_i18n.py <assessment_v1.json> <chiqish tests_i18n.json>
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, 'data')
SPECS = ['sud_tib', 'pat_anat', 'sud_kimyo']


def rd(name):
    return os.path.join(DATA, name)


def lines(path):
    out = {}
    if os.path.exists(path):
        for ln in open(path, encoding='utf8'):
            ln = ln.rstrip('\n')
            if ln:
                p = ln.split('|')
                assert len(p) == 6, (path, ln[:40])
                out[int(p[0])] = (p[1], p[2:])
    return out


def clean_ru(s):
    s = s.replace('­', '').replace('¬', '')
    s = re.sub(r'(?<![А-Яа-яЁё])рН', 'pH', s)   # kirill «р» -> lotin pH
    s = s.replace('NаОН', 'NaOH').replace('NаСl', 'NaCl')
    s = re.sub(r'\s+', ' ', s).strip()
    return s


def apply_rep(text, fx):
    for a, b in fx.get('replace', []):
        text = text.replace(a, b)
    for a, b in fx.get('replace_re', []):
        text = re.sub(a, b, text)
    return text


def main(bundle_path, out_path):
    bundle = json.load(open(bundle_path, encoding='utf8'))
    result = {'_doc': __doc__.strip().split('\n')[0], 'specialties': {}}
    report = {}
    for spec in SPECS:
        tests = next(s for s in bundle['specialties'] if s['id'] == spec)['tests']
        ru = {r['n']: r for r in json.load(open(rd(f'ru_parsed_{spec}.json'), encoding='utf8'))}
        fixes, glob = {}, []
        fpath = rd(f'fixes_{spec}.jsonl')
        if os.path.exists(fpath):
            for ln in open(fpath, encoding='utf8'):
                if ln.strip():
                    e = json.loads(ln)
                    if 'n' in e:
                        fixes.setdefault(e['n'], []).append(e)
                    else:
                        glob.append(e)
        llm = lines(rd(f'ru_llm_{spec}.txt'))
        en = lines(rd(f'en_{spec}.txt'))
        if spec == 'sud_kimyo':
            align = {a: (b, p) for a, b, p in json.load(open(rd('align_sud_kimyo.json')))}
        else:
            align = {t['n']: (t['n'], [0, 1, 2, 3]) for t in tests if t['n'] in ru}
        out, st = {}, {'official': 0, 'llm': 0, 'reordered': [], 'fixed': [], 'missing_en': []}
        for t in tests:
            n = t['n']
            e = {}
            src = None
            if n in llm and spec == 'pat_anat':
                st.setdefault('rejected', []).append(n)  # rasmiy matn buzilgan/farqli
            elif n in align:
                rn, perm = align[n]
                r = ru[rn]
                q, opts, is_llm, touched = r['q'], list(r['opts']), False, False
                for g in glob:
                    q2 = apply_rep(q, g)
                    o2 = [apply_rep(o, g) for o in opts]
                    if q2 != q or o2 != opts:
                        touched = True
                        is_llm |= bool(g.get('llm'))
                    q, opts = q2, o2
                for fx in fixes.get(n, []):
                    if 'perm' in fx:
                        perm = fx['perm']
                    q = fx.get('q', q)
                    opts = fx.get('opts', opts)
                    q = apply_rep(q, fx)
                    opts = [apply_rep(o, fx) for o in opts]
                    if set(fx) - {'n', 'perm'}:
                        touched = True
                    is_llm |= bool(fx.get('llm'))
                assert len(opts) == 4, (spec, n, opts)
                e['text_ru'] = clean_ru(q)
                e['options_ru'] = [clean_ru(opts[perm[i]]) for i in range(4)]
                e['ru_src'] = 'llm' if is_llm else 'official'
                e['ru_n'] = rn
                if perm != [0, 1, 2, 3]:
                    e['ru_perm'] = perm
                    st['reordered'].append(n)
                if touched and not is_llm:
                    st['fixed'].append(n)
                src = e['ru_src']
            if src is None:
                assert n in llm, (spec, n, 'RU yo‘q')
                q, opts = llm[n]
                e['text_ru'], e['options_ru'], e['ru_src'] = q, opts, 'llm'
                src = 'llm'
            st[src] += 1
            if n in en:
                e['text_en'], e['options_en'] = en[n][0], en[n][1]
                e['en_src'] = 'llm'
            else:
                st['missing_en'].append(n)
            out[str(n)] = e
        used_any = {v[0] for k, v in align.items() if str(k) in out}
        st['ru_only'] = [(r['n'], r['q']) for r in ru.values() if r['n'] not in used_any]
        result['specialties'][spec] = out
        report[spec] = st
    json.dump(result, open(out_path, 'w', encoding='utf8'), ensure_ascii=False, indent=0)
    json.dump(report, open(out_path.replace('.json', '_report.json'), 'w', encoding='utf8'),
              ensure_ascii=False, indent=1)
    for s, st in report.items():
        print(s, 'official', st['official'], 'llm', st['llm'], 'reordered', st['reordered'],
              'fixed', len(st['fixed']), 'ru_only', len(st['ru_only']), 'missing_en', st['missing_en'])


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
