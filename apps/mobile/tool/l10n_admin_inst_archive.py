#!/usr/bin/env python3
"""Admin «Tashkilotlar»: arxivga olish / qaytarish va muddatni uzaytirish
matnlari (egasi topshirig‘i, 2026-11-04). Tartib: `l10n_admin_institutes.py`
dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
S = {'type': 'String'}
N = {'type': 'int'}
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('instArchive', 'Admin: archive organization button.', 'Arxivga olish',
  'В архив', 'Archive')
k('instRestore', 'Admin: restore from archive button.', 'Arxivdan qaytarish',
  'Вернуть из архива', 'Restore from archive')
k('instArchiveTitle', 'Archive confirm title.',
  'Tashkilot arxivga olinsinmi?', 'Отправить организацию в архив?',
  'Archive this organization?')
k('instArchiveBody', 'Archive confirm body.',
  'Arxivlangan tashkilot kodlari yangi foydalanuvchiga ishlamaydi. Mavjud a’zolar muddati tugaguncha qoladi. Hech narsa o‘chirilmaydi.',
  'Коды архивной организации не подойдут новым пользователям. Текущие участники остаются до конца срока. Ничего не удаляется.',
  'Codes of an archived organization will not work for new users. Current members stay until their term ends. Nothing is deleted.')
k('instArchiveDone', 'Archived.', 'Tashkilot arxivga olindi.',
  'Организация отправлена в архив.', 'The organization was archived.')
k('instRestoreDone', 'Restored.', 'Tashkilot arxivdan qaytarildi.',
  'Организация возвращена из архива.',
  'The organization was restored from the archive.')
k('instArchivedBadge', 'Archived badge.', 'Arxivda', 'В архиве', 'Archived')
k('instArchivedSection', 'Archived section toggle.', 'Arxivdagilar ({n})',
  'В архиве ({n})', 'Archived ({n})', {'n': N})
k('instArchivedNote', 'Archived organization note.',
  'Bu tashkilot arxivda: kodlari yangi foydalanuvchiga ishlamaydi. Muddatni uzaytirish mumkin.',
  'Организация в архиве: её коды не подойдут новым пользователям. Срок продлить можно.',
  'This organization is archived: its codes do not work for new users. The term can still be extended.')
k('instExtend', 'Admin: extend term button.', 'Muddatni uzaytirish',
  'Продлить срок', 'Extend term')
k('instExtendTitle', 'Extend dialog title.',
  'Muddat necha oyga uzaytirilsin?', 'На сколько месяцев продлить срок?',
  'Extend the term by how many months?')
k('instExtendMonths', 'Extend option.', '{n} oy', '{n} мес.', '{n} mo',
  {'n': N})
k('instExtendYes', 'Extend confirm button.', 'Uzaytirish', 'Продлить',
  'Extend')
k('instExtendDone', 'Extended message.',
  'Muddat uzaytirildi: {date} gacha. Kod kiritgan ustozlarning muddati ham yangilandi ({n}).',
  'Срок продлён: до {date}. Срок преподавателей, ввёдших код, тоже обновлён ({n}).',
  'Term extended until {date}. The term of teachers who entered a code was also updated ({n}).',
  {'date': S, 'n': N})
k('instActionError', 'Admin action failed.',
  'Amalni bajarib bo‘lmadi. Qayta urinib ko‘ring.',
  'Не удалось выполнить действие. Повторите.',
  'Could not complete the action. Try again.')
k('instDialogCancel', 'Dialog cancel.', 'Bekor qilish', 'Отмена', 'Cancel')

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
print('l10n_admin_inst_archive:', len(K), 'keys')
