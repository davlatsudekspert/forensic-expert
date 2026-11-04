#!/usr/bin/env python3
"""Admin: «Tashkilotlar» (promokodlar), sovg‘a promokodlari matnlari (egasi
qarori, 2026-11-04). Pul/shartnoma/rekvizit matnlari olib tashlangan; eski
kalitlar ARB’dan REMOVE orqali o‘chiriladi. Tartib: `l10n_institute_code.py`
dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
S = {'type': 'String'}
N = {'type': 'int'}
K = collections.OrderedDict()
REMOVE = ['instLicensor', 'instFAddress', 'instFStir', 'instFBank',
          'instFAccount', 'instFMfo', 'instFDirector', 'instFPhone',
          'instFContractNo', 'instFContractDate', 'instFPrice', 'instFTotal',
          'instPdf', 'instPdfNote', 'instPdfError', 'instLicNote',
          'instLicTransit', 'instLicAccount', 'instLicSave', 'instLicSaved']


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('instNavTitle', 'Admin: organizations section title.',
  'Tashkilotlar', 'Организации', 'Organizations')
k('instNavHint', 'Admin: organizations tile hint.',
  'Tashkilotlar va promokodlar', 'Организации и промокоды',
  'Organizations and promo codes')
k('instNew', 'Admin: new organization.', 'Yangi tashkilot',
  'Новая организация', 'New organization')
k('instGift', 'Admin: gift promo codes.', 'Sovg‘a promokod',
  'Подарочный промокод', 'Gift promo code')
k('instEmpty', 'Admin: no organizations.', 'Hali tashkilot yo‘q.',
  'Организаций пока нет.', 'No organizations yet.')
k('instLoadError', 'Admin: load failed.',
  'Ma’lumotni yuklab bo‘lmadi. Qayta urinib ko‘ring.',
  'Не удалось загрузить данные. Повторите.',
  'Could not load the data. Try again.')
k('instRowInfo', 'Admin: institute row info.',
  'O‘rinlar: {seats} · ishlatilgan: {used}',
  'Мест: {seats} · использовано: {used}',
  'Seats: {seats} · used: {used}', {'seats': N, 'used': N})
k('instRowUntil', 'Admin: institute term end.', '{date} gacha',
  'до {date}', 'until {date}', {'date': S})
# forma
k('instFName', 'Form: organization name.', 'Tashkilot nomi',
  'Название организации', 'Organization name')
k('instFSeats', 'Form: seats.', 'O‘rinlar soni', 'Количество мест',
  'Number of seats')
k('instFMonths', 'Form: months.', 'Oylar soni', 'Количество месяцев',
  'Number of months')
k('instFTermStart', 'Form: start date.', 'Boshlanish sanasi', 'Дата начала',
  'Start date')
k('instFPickDate', 'Form: pick a date.', 'Sanani tanlang', 'Выберите дату',
  'Pick a date')
k('instFSave', 'Form: save and add promo codes.',
  'Saqlash va promokodlar tayyorlash',
  'Сохранить и подготовить промокоды', 'Save and prepare promo codes')
k('instFInvalid', 'Form: invalid input.',
  'Nomini, o‘rinlar (1–500) va oylar (1–60) sonini to‘g‘ri kiriting.',
  'Укажите название, число мест (1–500) и месяцев (1–60).',
  'Enter the name, seats (1–500) and months (1–60).')
k('instFError', 'Form: server error.',
  'Tashkilotni saqlab bo‘lmadi. Qayta urinib ko‘ring.',
  'Не удалось сохранить организацию. Повторите.',
  'Could not save the organization. Try again.')
k('instCreated', 'Organization saved: codes count.',
  'Tashkilot saqlandi. {n} ta promokod tayyorlandi.',
  'Организация сохранена. Подготовлено промокодов: {n}.',
  'Organization saved. {n} promo codes prepared.', {'n': N})
# kodlar
k('instCodesTitle', 'Codes section title.', 'Promokodlar', 'Промокоды',
  'Promo codes')
k('instCodesNote', 'Codes visible only to admin.',
  'Promokodlar faqat adminga ko‘rinadi. Ularni faqat vakilga yopiq kanal orqali yuboring.',
  'Промокоды видны только администратору. Передавайте их только представителю по закрытому каналу.',
  'Promo codes are visible to the admin only. Send them to the representative through a private channel only.')
k('instCopy', 'Copy code.', 'Nusxalash', 'Копировать', 'Copy')
k('instCopyAll', 'Copy all codes.', 'Hammasini nusxalash',
  'Копировать все', 'Copy all')
k('instCopied', 'Copied.', 'Nusxalandi', 'Скопировано', 'Copied')
k('instColNo', 'Codes table: number.', '№', '№', '#')
k('instColCode', 'Codes table: code.', 'Promokod', 'Промокод', 'Promo code')
k('instColStatus', 'Codes table: status.', 'Holati', 'Статус', 'Status')
k('instStatusFree', 'Code status: free.', 'Bo‘sh', 'Свободен', 'Free')
k('instStatusRedeemed', 'Code status: used by email.',
  'Ishlatilgan: {email}', 'Использован: {email}', 'Used: {email}',
  {'email': S})
k('instStatusRevoked', 'Code status: revoked.', 'Bekor qilingan', 'Отозван',
  'Revoked')
k('instRevoke', 'Revoke the code.', 'Promokodni bekor qilish',
  'Отозвать промокод', 'Revoke promo code')
k('instRevokeTitle', 'Revoke dialog title.', 'Promokod bekor qilinsinmi?',
  'Отозвать промокод?', 'Revoke the promo code?')
k('instRevokeBody', 'Revoke dialog body.',
  '{code}: kod ishlamay qoladi. Ishlatilgan kodni bekor qilib bo‘lmaydi.',
  '{code}: код перестанет работать. Использованный код отозвать нельзя.',
  '{code}: the code will stop working. A used code cannot be revoked.',
  {'code': S})
k('instRevokeKeep', 'Revoke dialog: keep.', 'Qoldirish', 'Оставить', 'Keep')
k('instRevokeDone', 'Revoked.', 'Promokod bekor qilindi.',
  'Промокод отозван.', 'The promo code was revoked.')
k('instRevokeNotFound', 'Revoke: not found or used.',
  'Promokod topilmadi yoki allaqachon ishlatilgan.',
  'Промокод не найден или уже использован.',
  'The promo code was not found or is already used.')
k('instDetailTerm', 'Organization term line.', 'Muddat: {from} — {to}',
  'Срок: {from} — {to}', 'Term: {from} — {to}', {'from': S, 'to': S})
k('instDetailSeats', 'Institute seats line.',
  'O‘rinlar: {seats} · ishlatilgan: {used} · bekor: {revoked}',
  'Мест: {seats} · использовано: {used} · отозвано: {revoked}',
  'Seats: {seats} · used: {used} · revoked: {revoked}',
  {'seats': N, 'used': N, 'revoked': N})
# sovg'a
k('instGiftFrom', 'Gift: who gives.', 'Kim bergan', 'От кого', 'Given by')
k('instGiftCount', 'Gift: count 1-50.', 'Soni (1–50)', 'Количество (1–50)',
  'Count (1–50)')
k('instGiftDays', 'Gift: days.', 'Kunlar', 'Дней', 'Days')
k('instGiftPlan', 'Gift: plan.', 'Reja', 'Тариф', 'Plan')
k('instGiftCreate', 'Gift: prepare codes.', 'Promokodlar tayyorlash',
  'Подготовить промокоды', 'Prepare promo codes')
k('instGiftInvalid', 'Gift: invalid.',
  'Kim bergan, soni (1–50) va kunlarni (1–1100) to‘g‘ri kiriting.',
  'Укажите, от кого, количество (1–50) и дни (1–1100).',
  'Enter who gave it, count (1–50) and days (1–1100).')
k('instGiftError', 'Gift: failed.', 'Promokodlarni tayyorlab bo‘lmadi.',
  'Не удалось подготовить промокоды.', 'Could not prepare the promo codes.')
k('instGiftDone', 'Gift: prepared.', '{n} ta promokod tayyorlandi.',
  'Подготовлено промокодов: {n}.', '{n} promo codes prepared.', {'n': N})
k('instOpen', 'Open the organization page.', 'Tashkilot sahifasini ochish',
  'Открыть страницу организации', 'Open organization page')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key in REMOVE:
        b.pop(key, None)
        b.pop('@' + key, None)
    for key, (desc, *vals, ph) in K.items():
        b[key] = vals[i]
        if lang == 'en':
            m = collections.OrderedDict(description=desc)
            if ph:
                m['placeholders'] = {n: dict(t) for n, t in ph.items()}
            b['@' + key] = m
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_admin_institutes:', len(K), 'keys')
