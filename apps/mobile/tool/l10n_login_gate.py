#!/usr/bin/env python3
"""Majburiy kirish («avval ro‘yxatdan o‘ting, keyin foydalaning», egasi,
2026-11-03): kirish ekrani matnlari. Tartib: `l10n_name_wording.py` dan keyin.
Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = collections.OrderedDict()


def k(key, desc, uz, ru, en):
    K[key] = (desc, uz, ru, en)


k('loginGateTitle', 'Required sign-in screen title.',
  'Avval kiring', 'Сначала войдите', 'Sign in first')
k('loginGateBody', 'Required sign-in screen explanation.',
  'Darslar, testlar va guruhlardan foydalanish uchun Gmail (elektron pochta) '
  'bilan kiring. Kod pochtangizga yuboriladi, parol kerak emas.',
  'Чтобы пользоваться уроками, тестами и группами, войдите по e-mail '
  '(Gmail). Код придёт на почту, пароль не нужен.',
  'Sign in with your e-mail (Gmail) to use lessons, tests and groups. A code '
  'is sent to your inbox — no password needed.')
k('loginGateButton', 'Required sign-in button.',
  'Gmail / email bilan kirish', 'Войти по e-mail / Gmail',
  'Sign in with e-mail / Gmail')
k('loginGateOffline', 'Required sign-in, backend not reachable.',
  'Internet yo‘q yoki xizmat ulanmagan. Internetni yoqib, qayta urinib ko‘ring.',
  'Нет интернета или сервис недоступен. Включите интернет и попробуйте снова.',
  'No internet or the service is unavailable. Turn on the internet and try again.')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, (desc, *vals) in K.items():
        b[key] = vals[i]
        if lang == 'en':
            b['@' + key] = collections.OrderedDict(description=desc)
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_login_gate:', len(K), 'keys')
