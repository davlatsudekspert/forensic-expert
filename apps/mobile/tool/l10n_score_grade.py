#!/usr/bin/env python3
"""Sinf testi natijasi: tezlik bali «Reyting bali» deb nomlanadi (egasi so'rovi,
2026-11-02 — asosiy natija 100 ballik ball va PF-191 bahosi). Idempotent."""
import json, collections, pathlib
ARB = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
VALUES = {
    'uz': {'classScoreLine': 'Reyting bali: {score}'},
    'ru': {'classScoreLine': 'Рейтинговые баллы: {score}'},
    'en': {'classScoreLine': 'Ranking points: {score}'},
}
for lang, kv in VALUES.items():
    p = ARB / f'app_{lang}.arb'
    d = json.loads(p.read_text(), object_pairs_hook=collections.OrderedDict)
    for k, v in kv.items():
        d[k] = v
    p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + '\n')
print('ok')
