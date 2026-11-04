#!/usr/bin/env python3
"""«Institut kodi / promokod» (profil) va qurilmalar limiti (3 ta) matnlari
(egasi qarori, 2026-11-04). Tartib: `l10n_group_manage.py` dan keyin.
Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
S = {'type': 'String'}
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('promoRowTitle', 'Profile row + screen title: promo code.',
  'Promokod', 'Промокод', 'Promo code')
k('promoRowHint', 'Profile row hint when no code is active.',
  'Sizga berilgan promokod', 'Промокод, который вам выдали',
  'The promo code you were given')
k('promoIntro', 'Promo screen intro.',
  'Sizga berilgan promokodni kiriting. Promokod hisobingizda ustoz imkoniyatlarini ochadi.',
  'Введите выданный вам промокод. Промокод открывает возможности преподавателя в вашем аккаунте.',
  'Enter the promo code you were given. The promo code unlocks teacher features on your account.')
k('promoFieldLabel', 'Promo code field label.', 'Promokod', 'Промокод',
  'Promo code')
k('promoFieldHint', 'Promo code field hint (spaces and dashes are ignored).',
  'Bo‘shliq va defis e’tiborsiz', 'Пробелы и дефисы игнорируются',
  'Spaces and dashes are ignored')
k('promoSubmit', 'Promo screen: activate button.',
  'Faollashtirish', 'Активировать', 'Activate')
k('promoEmpty', 'Promo result text.',
  'Promokodni kiriting.', 'Введите промокод.',
  'Enter the promo code.')
k('promoInvalid', 'Promo result text.',
  'Promokod noto‘g‘ri', 'Неверный промокод',
  'The promo code is incorrect')
k('promoUsed', 'Promo result text.',
  'Promokod ishlatilgan', 'Промокод уже использован',
  'The promo code has already been used')
k('promoAlreadyYours', 'Promo result text.',
  'Bu promokod allaqachon sizning hisobingizda faollashtirilgan.', 'Этот промокод уже активирован в вашем аккаунте.',
  'This promo code is already active on your account.')
k('promoExpired', 'Promo result text.',
  'Promokodning muddati tugagan', 'Срок действия промокода истёк',
  'The promo code has expired')
k('promoRevoked', 'Promo result text.',
  'Promokod bekor qilingan', 'Промокод отозван',
  'The promo code has been revoked')
k('promoTooMany', 'Promo result TOO_MANY.',
  'Juda ko‘p urinish. Keyinroq qayta urinib ko‘ring.',
  'Слишком много попыток. Повторите позже.',
  'Too many attempts. Please try again later.')
k('promoNotSigned', 'Promo result NOT_SIGNED.',
  'Avval hisobingizga kiring.', 'Сначала войдите в аккаунт.',
  'Please sign in first.')
k('promoOffline', 'Promo result text.',
  'Internet yo‘q. Aloqani tekshirib, qayta urinib ko‘ring.', 'Нет сети. Проверьте соединение и повторите.',
  'No connection. Check your network and try again.')
k('promoError', 'Promo result text.',
  'Promokodni tekshirib bo‘lmadi. Keyinroq qayta urinib ko‘ring.', 'Не удалось проверить промокод. Повторите позже.',
  'Could not check the promo code. Please try again later.')
k('promoOk', 'Promo OK: {label} is the name or gift label, {date} the end date.',
  'Promokod qabul qilindi: {label}, {date} gacha',
  'Промокод принят: {label}, до {date}',
  'Promo code accepted: {label}, until {date}',
  {'label': S, 'date': S})
k('promoOkShort', 'Promo OK without label/date.',
  'Promokod qabul qilindi', 'Промокод принят', 'Promo code accepted')
k('promoLabelInstitute', 'Profile: name of the issuing body, no prefix.',
  '{name}', '{name}', '{name}', {'name': S})
k('promoLabelGift', 'Profile: gift giver.',
  'Sovg‘a: {name}', 'Подарок: {name}', 'Gift: {name}', {'name': S})
k('promoUntil', 'Profile: end date of access.',
  '{date} gacha', 'до {date}', 'until {date}', {'date': S})
k('promoActiveTitle', 'Promo screen: active access section.',
  'Faol imkoniyat', 'Действующий доступ', 'Active access')

k('devLimitTitle', 'Device limit dialog title.',
  'Bu hisob {limit} ta qurilmada ishlatilmoqda',
  'Этот аккаунт используется на {limit} устройствах',
  'This account is used on {limit} devices', {'limit': {'type': 'int'}})
k('devLimitBody', 'Device limit dialog body (soft: app keeps working).',
  'Bu qurilmani qo‘shish uchun eskisini chiqaring. Hozircha ilova ishlashda davom etadi.',
  'Чтобы добавить это устройство, удалите одно из старых. Пока приложение продолжает работать.',
  'To add this device, remove an old one. For now the app keeps working.')
k('devLimitLastSeen', 'Device list: last sign-in date.',
  'Oxirgi kirish: {date}', 'Последний вход: {date}', 'Last sign-in: {date}',
  {'date': S})
k('devLimitUnknown', 'Device list: no label.',
  'Qurilma', 'Устройство', 'Device')
k('devLimitRemove', 'Device list: remove button.',
  'Chiqarish', 'Удалить', 'Remove')
k('devLimitLater', 'Device dialog: dismiss.',
  'Keyinroq', 'Позже', 'Later')
k('devLimitRemoveError', 'Device remove failed.',
  'Qurilmani chiqarib bo‘lmadi. Qayta urinib ko‘ring.',
  'Не удалось удалить устройство. Повторите.',
  'Could not remove the device. Try again.')
k('devLimitStillFull', 'Device removed but still full.',
  'Hali ham joy yo‘q. Yana bir qurilmani chiqaring.',
  'Мест всё ещё нет. Удалите ещё одно устройство.',
  'Still no free slot. Remove another device.')

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
print('l10n_institute_code:', len(K), 'keys')
