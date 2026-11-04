#!/usr/bin/env python3
"""Guruhni arxivlash / o‘chirish (ustoz; egasi, 2026-11-04). Tartib:
`l10n_admin_revoke.py` dan keyin. Idempotent."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
S = {'type': 'String'}
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, uz, ru, en, ph)


k('grpManage', 'Group screen: menu tooltip.', 'Guruh amallari', 'Действия с группой', 'Group actions')
k('grpArchive', 'Group menu: archive.', 'Arxivlash', 'В архив', 'Archive')
k('grpArchiveTitle', 'Archive confirm title.', 'Guruh arxivlansinmi?', 'Отправить группу в архив?', 'Archive this group?')
k('grpArchiveBody', 'Archive confirm body.',
  '«{name}» ro‘yxatdan yashiriladi. Natijalar saqlanadi, lekin guruhni ilovadan qaytarib bo‘lmaydi.',
  '«{name}» будет скрыта из списка. Результаты сохранятся, но вернуть группу из приложения нельзя.',
  '“{name}” will be hidden from the list. Results are kept, but the group cannot be restored from the app.', {'name': S})
k('grpArchiveYes', 'Archive confirm button.', 'Arxivlash', 'В архив', 'Archive')
k('grpDelete', 'Group menu: delete.', 'Guruhni o‘chirish', 'Удалить группу', 'Delete group')
k('grpDeleteTitle', 'Delete confirm title.', 'Guruh o‘chirilsinmi?', 'Удалить группу?', 'Delete this group?')
k('grpDeleteBody', 'Delete confirm body.',
  '«{name}», uning a’zolari, vazifalari va natijalari butunlay o‘chadi. Buni qaytarib bo‘lmaydi.',
  '«{name}», её участники, задания и результаты будут удалены без возможности восстановления.',
  '“{name}”, its members, assignments and results will be permanently deleted. This cannot be undone.', {'name': S})
k('grpDeleteYes', 'Delete confirm button.', 'O‘chirish', 'Удалить', 'Delete')

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
print('l10n_group_manage:', len(K), 'keys')
