#!/usr/bin/env python3
"""«Guruh testi»: «Laqab» o‘rniga «Ism» (egasi, 2026-11-03: «Laqab o‘zbek
tilida g‘alati eshitiladi, Ism deb yoz»). Ma’no uch tilda bir xil bo‘lishi
uchun ru/en ham «Имя»/«Name». Faqat qiymatlar yangilanadi (@-metadata
o‘zgarmaydi). Tartib: `l10n_oral_group.py` dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
V = collections.OrderedDict()


def v(key, uz, ru, en):
    V[key] = (uz, ru, en)


v('classQuizIntro',
  'Ustoz ekranda 6 xonali kod va QR ko‘rsatadi. Talabalar ismini yozib '
  'qo‘shiladi va har bir savolga vaqt tugaguncha javob beradi.',
  'Преподаватель показывает на экране 6-значный код и QR. Студенты входят, '
  'указав имя, и отвечают на каждый вопрос до конца таймера.',
  'The teacher shows a 6-digit code and QR on the screen. Students join with '
  'their name and answer each question before the timer ends.')
v('classNickLabel', 'Ism', 'Имя', 'Name')
v('classNickHelper',
  '2–20 belgi. Ustoz faqat shu ismni ko‘radi, elektron pochtangiz '
  'ko‘rinmaydi.',
  '2–20 символов. Преподаватель видит только это имя, ваш e-mail не виден.',
  '2–20 characters. The teacher sees only this name, not your e-mail.')
v('classPrivacyNote',
  'Ustoz faqat shu ismni ko‘radi. Tugagan testlar 30 kundan keyin avtomatik '
  'o‘chiriladi. Nomaqbul ismga shikoyat qilish mumkin, u olib tashlanadi.',
  'Преподаватель видит только это имя. Завершённые тесты автоматически '
  'удаляются через 30 дней. На неприемлемое имя можно пожаловаться, и оно '
  'будет удалено.',
  'The teacher sees only this name. Finished tests are deleted automatically '
  'after 30 days. Offensive names can be reported and removed.')
v('classSignInBody',
  'Natijangiz serverda hisobingizga bog‘lanadi. Boshqa talabalar va ustoz '
  'faqat yozgan ismingizni ko‘radi.',
  'Ваш результат привязан к аккаунту на сервере. Другие студенты и '
  'преподаватель видят только указанное вами имя.',
  'Your result is tied to your account on the server. Other students and the '
  'teacher only see the name you entered.')
v('classReportsCount',
  'Ismga shikoyatlar: {count} — ro‘yxatni tekshiring',
  'Жалоб на имена: {count} — проверьте список',
  '{count} name report(s) — review the list')
v('classReportTitle', 'Bu ismga shikoyat qilinsinmi?',
  'Пожаловаться на это имя?', 'Report this name?')
v('classReportReason', 'Nomaqbul ism', 'Неприемлемое имя', 'Inappropriate name')
v('classErrNickLength', 'Ism 2–20 belgidan iborat bo‘lishi kerak.',
  'Имя должно содержать 2–20 символов.', 'Name must be 2–20 characters.')
v('classErrNickChars', 'Ismda ruxsat etilmagan belgilar bor.',
  'В имени есть недопустимые символы.',
  'This name contains characters that aren’t allowed.')
v('classErrNickBlocked', 'Boshqa ism yozing.', 'Введите другое имя.',
  'Please enter a different name.')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, vals in V.items():
        if key not in b:
            raise SystemExit(f'{lang}: {key} yo‘q')
        b[key] = vals[i]
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_name_wording:', len(V), 'keys')
