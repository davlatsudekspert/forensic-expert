#!/usr/bin/env python3
"""Admin: «Institutlar» (kodlar, shartnoma PDF), sovg‘a promokodlari va
litsenziar rekvizitlari matnlari (egasi qarori, 2026-11-04). Tartib:
`l10n_institute_code.py` dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
S = {'type': 'String'}
N = {'type': 'int'}
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('instNavTitle', 'Admin: institutes section title.',
  'Institutlar', 'Институты', 'Institutes')
k('instNavHint', 'Admin: institutes tile hint.',
  'Litsenziya kodlari, shartnoma PDF', 'Коды лицензии, PDF договора',
  'Licence codes, contract PDF')
k('instNew', 'Admin: new institute.', 'Yangi institut', 'Новый институт',
  'New institute')
k('instGift', 'Admin: gift promo codes.', 'Sovg‘a promokod',
  'Подарочный промокод', 'Gift promo code')
k('instLicensor', 'Admin: licensor details.', 'Litsenziar rekvizitlari',
  'Реквизиты лицензиара', 'Licensor details')
k('instEmpty', 'Admin: no institutes.', 'Hali institut yo‘q.',
  'Институтов пока нет.', 'No institutes yet.')
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
k('instFName', 'Form: institute name.', 'Nomi', 'Название', 'Name')
k('instFAddress', 'Form: address.', 'Manzil', 'Адрес', 'Address')
k('instFStir', 'Form: tax ID (STIR).', 'STIR (soliq raqami)', 'ИНН (STIR)', 'Tax ID (STIR)')
k('instFBank', 'Form: bank.', 'Bank nomi', 'Банк', 'Bank')
k('instFAccount', 'Form: account number.', 'Hisob raqam', 'Расчётный счёт',
  'Account number')
k('instFMfo', 'Form: MFO.', 'MFO (bank kodi)', 'МФО', 'MFO')
k('instFDirector', 'Form: director.', 'Rahbar F.I.O.', 'Руководитель (Ф.И.О.)',
  'Director (full name)')
k('instFPhone', 'Form: phone.', 'Telefon', 'Телефон', 'Phone')
k('instFContractNo', 'Form: contract number.', 'Shartnoma raqami',
  'Номер договора', 'Contract number')
k('instFContractDate', 'Form: contract date.', 'Shartnoma sanasi',
  'Дата договора', 'Contract date')
k('instFSeats', 'Form: seats.', 'O‘rinlar soni', 'Количество мест',
  'Number of seats')
k('instFMonths', 'Form: months.', 'Oylar soni', 'Количество месяцев',
  'Number of months')
k('instFPrice', 'Form: price per seat per month.',
  'Bitta o‘rin narxi (so‘m/oy)', 'Цена одного места (сум/мес.)',
  'Price per seat (UZS/month)')
k('instFTermStart', 'Form: start date.', 'Boshlanish sanasi', 'Дата начала',
  'Start date')
k('instFPickDate', 'Form: pick a date.', 'Sanani tanlang', 'Выберите дату',
  'Pick a date')
k('instFTotal', 'Form: auto total = seats x months x price.',
  'Jami summa: {sum} so‘m (o‘rinlar × oylar × narx)',
  'Итого: {sum} сум (места × месяцы × цена)',
  'Total: {sum} UZS (seats × months × price)', {'sum': S})
k('instFSave', 'Form: save and create codes.', 'Saqlash va kodlar yaratish',
  'Сохранить и создать коды', 'Save and create codes')
k('instFInvalid', 'Form: invalid input.',
  'Nomini, o‘rinlar (1–500) va oylar (1–60) sonini to‘g‘ri kiriting.',
  'Укажите название, число мест (1–500) и месяцев (1–60).',
  'Enter the name, seats (1–500) and months (1–60).')
k('instFError', 'Form: server error.',
  'Institutni saqlab bo‘lmadi. Qayta urinib ko‘ring.',
  'Не удалось сохранить институт. Повторите.',
  'Could not save the institute. Try again.')
k('instCreated', 'Institute saved: codes count.',
  'Institut saqlandi. {n} ta kod yaratildi.',
  'Институт сохранён. Создано кодов: {n}.',
  'Institute saved. {n} codes created.', {'n': N})
# kodlar
k('instCodesTitle', 'Codes section title.', 'Kodlar', 'Коды', 'Codes')
k('instCodesNote', 'Codes visible only to admin.',
  'Kodlar faqat adminga ko‘rinadi. Ularni faqat vakilga yopiq kanal orqali yuboring.',
  'Коды видны только администратору. Передавайте их только представителю по закрытому каналу.',
  'Codes are visible to the admin only. Send them to the representative through a private channel only.')
k('instCopy', 'Copy code.', 'Nusxalash', 'Копировать', 'Copy')
k('instCopyAll', 'Copy all codes.', 'Hammasini nusxalash',
  'Копировать все', 'Copy all')
k('instCopied', 'Copied.', 'Nusxalandi', 'Скопировано', 'Copied')
k('instColNo', 'Codes table: number.', '№', '№', '#')
k('instColCode', 'Codes table: code.', 'Kod', 'Код', 'Code')
k('instColStatus', 'Codes table: status.', 'Holati', 'Статус', 'Status')
k('instStatusFree', 'Code status: free.', 'Bo‘sh', 'Свободен', 'Free')
k('instStatusRedeemed', 'Code status: used by email.',
  'Ishlatilgan: {email}', 'Использован: {email}', 'Used: {email}',
  {'email': S})
k('instStatusRevoked', 'Code status: revoked.', 'Bekor qilingan', 'Отозван',
  'Revoked')
k('instRevoke', 'Revoke the code.', 'Kodni bekor qilish', 'Отозвать код',
  'Revoke code')
k('instRevokeTitle', 'Revoke dialog title.', 'Kodni bekor qilasizmi?',
  'Отозвать код?', 'Revoke the code?')
k('instRevokeBody', 'Revoke dialog body.',
  '{code}: kod ishlamay qoladi. Ishlatilgan kodni bekor qilib bo‘lmaydi.',
  '{code}: код перестанет работать. Использованный код отозвать нельзя.',
  '{code}: the code will stop working. A used code cannot be revoked.',
  {'code': S})
k('instRevokeKeep', 'Revoke dialog: keep.', 'Qoldirish', 'Оставить', 'Keep')
k('instRevokeDone', 'Revoked.', 'Kod bekor qilindi.', 'Код отозван.',
  'The code was revoked.')
k('instRevokeNotFound', 'Revoke: not found or used.',
  'Kod topilmadi yoki allaqachon ishlatilgan.',
  'Код не найден или уже использован.',
  'The code was not found or is already used.')
k('instDetailTerm', 'Institute term line.', 'Muddat: {from} — {to}',
  'Срок: {from} — {to}', 'Term: {from} — {to}', {'from': S, 'to': S})
k('instDetailSeats', 'Institute seats line.',
  'O‘rinlar: {seats} · ishlatilgan: {used} · bekor: {revoked}',
  'Мест: {seats} · использовано: {used} · отозвано: {revoked}',
  'Seats: {seats} · used: {used} · revoked: {revoked}',
  {'seats': N, 'used': N, 'revoked': N})
# PDF
k('instPdf', 'Contract PDF button.', 'Shartnoma PDF', 'PDF договора',
  'Contract PDF')
k('instPdfNote', 'Contract PDF note.',
  'Litsenziar rekvizitlari «Litsenziar rekvizitlari» sozlamasidan olinadi. Kodlar alohida «Kodlar varag‘i» faylida; shartnomaga yozilmaydi.',
  'Реквизиты лицензиара берутся из настройки «Реквизиты лицензиара». Коды — в отдельном файле «Лист кодов», в договор они не вносятся.',
  'Licensor details come from the “Licensor details” setting. Codes go in a separate “Codes sheet” file and are never written into the contract.')
k('instPdfError', 'PDF failed.', 'PDF yaratib bo‘lmadi. Qayta urinib ko‘ring.',
  'Не удалось создать PDF. Повторите.', 'Could not create the PDF. Try again.')
# sovg'a
k('instGiftFrom', 'Gift: who gives.', 'Kim bergan', 'От кого', 'Given by')
k('instGiftCount', 'Gift: count 1-50.', 'Soni (1–50)', 'Количество (1–50)',
  'Count (1–50)')
k('instGiftDays', 'Gift: days.', 'Kunlar', 'Дней', 'Days')
k('instGiftPlan', 'Gift: plan.', 'Reja', 'Тариф', 'Plan')
k('instGiftCreate', 'Gift: create.', 'Kodlar yaratish', 'Создать коды',
  'Create codes')
k('instGiftInvalid', 'Gift: invalid.',
  'Kim bergan, soni (1–50) va kunlarni (1–1100) to‘g‘ri kiriting.',
  'Укажите, от кого, количество (1–50) и дни (1–1100).',
  'Enter who gave it, count (1–50) and days (1–1100).')
k('instGiftError', 'Gift: failed.', 'Kodlarni yaratib bo‘lmadi.',
  'Не удалось создать коды.', 'Could not create the codes.')
k('instGiftDone', 'Gift: created.', '{n} ta kod yaratildi.',
  'Создано кодов: {n}.', '{n} codes created.', {'n': N})
# litsenziar
k('instLicNote', 'Licensor details: local only.',
  'Bu ma’lumotlar faqat shu qurilmada saqlanadi va faqat shartnoma PDF’iga qo‘yiladi. Serverga yuborilmaydi.',
  'Эти данные хранятся только на этом устройстве и подставляются только в PDF договора. На сервер не отправляются.',
  'These details are stored on this device only and are placed only into the contract PDF. They are never sent to the server.')
k('instLicTransit', 'Licensor: transit account.',
  'Yuridik shaxslar uchun tranzit hisobi',
  'Транзитный счёт для юридических лиц',
  'Transit account for legal entities')
k('instLicAccount', 'Licensor: receiving account.', 'Qabul qiluvchi hisobi',
  'Счёт получателя', 'Receiving account')
k('instLicSave', 'Licensor: save.', 'Saqlash', 'Сохранить', 'Save')
k('instLicSaved', 'Licensor: saved.', 'Saqlandi.', 'Сохранено.', 'Saved.')

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
print('l10n_admin_institutes:', len(K), 'keys')
