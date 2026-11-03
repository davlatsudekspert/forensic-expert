#!/usr/bin/env python3
"""Admin «Pro berish»: «Olib tashlash» tasdiq oynasi (egasi, 2026-11-03:
7 talabaning bepul sinovi adashib o‘chirilgan). Tartib: `l10n_login_gate.py`
dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
S = {'type': 'String'}
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('admProRevokeTitle', 'Admin: confirm removing a plan — title.',
  'Rejani olib tashlaysizmi?', 'Снять тариф?', 'Remove the plan?')
k('admProRevokeBody', 'Admin: confirm removing a plan — body.',
  '{email}: reja va bepul sinov muddati o‘chadi.',
  '{email}: тариф и пробный период будут удалены.',
  '{email}: the plan and free trial will be removed.', {'email': S})
k('admProRevokeNo', 'Admin: keep the plan.',
  'Bekor qilish', 'Отмена', 'Cancel')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, (desc, *vals, ph) in K.items():
        b[key] = vals[i]
        if lang == 'en':
            m = collections.OrderedDict(description=desc)
            if ph:
                m['placeholders'] = {n: dict(t) for n, t in ph.items()}
            b['@' + key] = m
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_admin_revoke:', len(K), 'keys')
