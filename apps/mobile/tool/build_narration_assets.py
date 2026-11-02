#!/usr/bin/env python3
"""Build bundled lesson narration assets (uz) from the narration workspace.

Input:  <src>/out/<deck>.slides.json  ([{i,t,b,d}])  +  <deck>.narration.json ([str])
Output: assets/content/narration/<deck>.json  ([{"t": title, "n": text}])

Checks per deck (deck skipped on failure): same length, every slide has a
title, every digit run in a narration occurs in that slide's JSON, no
"keyingi slayd". The app applies a narration only when the title matches.
"""
import json, pathlib, re, sys

src = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else
                   '/home/user/forensic-expert/release/narration') / 'out'
dst = pathlib.Path(__file__).resolve().parent.parent / 'assets/content/narration'
dst.mkdir(parents=True, exist_ok=True)
ok = bad = 0
for nf in sorted(src.glob('*.narration.json')):
    deck = nf.name[:-len('.narration.json')]
    sf = src / f'{deck}.slides.json'
    if not re.fullmatch(r'[A-Za-z0-9_-]+', deck) or not sf.exists():
        print('SKIP', deck, 'no slides'); bad += 1; continue
    slides = json.loads(sf.read_text()); narr = json.loads(nf.read_text())
    errs = []
    if len(slides) != len(narr): errs.append('length')
    for s, n in zip(slides, narr):
        if not isinstance(n, str): errs.append(f'type@{s.get("i")}'); continue
        if not (s.get('t') or '').strip(): errs.append(f'title@{s.get("i")}')
        blob = json.dumps(s, ensure_ascii=False)
        for d in re.findall(r'\d+', n):
            if d not in blob: errs.append(f'digit {d}@{s.get("i")}')
        if 'keyingi slayd' in n.lower(): errs.append(f'phrase@{s.get("i")}')
    if errs:
        print('SKIP', deck, errs[:5]); bad += 1; continue
    out = [{'t': s['t'].strip(), 'n': n.strip()} for s, n in zip(slides, narr)]
    (dst / f'{deck}.json').write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')))
    ok += 1
print(f'built={ok} skipped={bad}')
