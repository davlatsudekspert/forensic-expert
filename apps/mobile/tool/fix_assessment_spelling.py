#!/usr/bin/env python3
"""Fix k/q, x/h and missing-apostrophe typos in the assessment test bank.

Whole-word, case-preserving replacements from tool/assessment_spelling_map.json.
Only question/option/answer text is touched; ids, keys and source metadata
(source, sources, keySrc, url) are left unchanged. Numbers are never edited.
Re-runnable (idempotent).
"""
import json, re, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
MAP = json.loads((ROOT / 'tool/assessment_spelling_map.json').read_text('utf-8'))
PHRASES = {'porsial but': 'parsial bug‘'}
WORDS = {k: v for k, v in MAP.items() if v}
SKIP_KEYS = {'id', 'source', 'sources', 'keySrc', 'url', 'page', 'spec', 'lang'}
AP = "‘ʻ’'ʼ"
pat = re.compile(r'(?<![\w' + AP + r'])(' + '|'.join(
    sorted(map(re.escape, WORDS), key=len, reverse=True)) + r')(?![\w' + AP + r'])',
    re.IGNORECASE)
count = 0


def fix_word(m):
    global count
    w = m.group(0)
    lw = w.lower()
    if lw not in WORDS or w.isupper() and len(w) > 1:
        return w  # abbreviations like KOK stay
    r = WORDS[lw]
    if w[0].isupper():
        r = r[0].upper() + r[1:]
    count += 1
    return r


def fix(s):
    global count
    for a, b in PHRASES.items():
        n = s.lower().count(a)
        if n:
            s = re.sub(re.escape(a), b, s, flags=re.IGNORECASE)
            count += n
    return pat.sub(fix_word, s)


def walk(x):
    if isinstance(x, dict):
        return {k: (v if k in SKIP_KEYS else walk(v)) for k, v in x.items()}
    if isinstance(x, list):
        return [walk(v) for v in x]
    if isinstance(x, str):
        return fix(x)
    return x


for f in sorted((ROOT / 'assets/content/assessment').glob('*.json')):
    count = 0
    t = f.read_text('utf-8')
    d = walk(json.loads(t))
    out = json.dumps(d, ensure_ascii=False, separators=(',', ':'))
    if t.endswith('\n'):
        out += '\n'
    if out != t:
        f.write_text(out, 'utf-8')
    print(f'{f.name}: {count} fixes')
