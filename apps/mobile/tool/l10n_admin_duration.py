# Admin «Pro berish»: ixtiyoriy muddat (kun/oy) va admin uchun «hammasi ochiq» belgisi
# (egasi so‘rovi, 2026-10-25). Idempotent. CLAUDE.md tartibida l10n_assessment.py dan keyin:
#   cd apps/mobile && python3 tool/l10n_admin_duration.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph or {})


k('admProCustom', 'Admin Pro grant: chip that opens a custom duration field.',
  'Custom', 'Другой срок', 'Boshqa muddat')
k('admProAmount', 'Admin Pro grant: label of the custom duration number field.',
  'Number', 'Количество', 'Soni')
k('admProUnitDay', 'Admin Pro grant: duration unit chip (days).', 'Days', 'Дни', 'Kun')
k('admProUnitMonth', 'Admin Pro grant: duration unit chip (months).', 'Months', 'Месяцы', 'Oy')
k('admProUntilDate', 'Admin Pro grant: preview of the end date of the custom duration.',
  'Valid until {date}', 'Действует до {date}', 'Amal qilish muddati: {date}', {'date': 'String'})
k('admProBadDuration', 'Admin Pro grant: custom duration out of range.',
  'Enter 1–3650 days or 1–120 months.', 'Введите 1–3650 дней или 1–120 месяцев.',
  '1–3650 kun yoki 1–120 oy kiriting.')
k('proPlanAdminAll', 'Profile plan row value for administrators.',
  'Administrator · everything open', 'Администратор · всё открыто',
  'Administrator · hammasi ochiq')

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    text = open(p, encoding="utf-8").read()
    data = json.loads(text)
    for key, (desc, en, ru, uz, ph) in K.items():
        val = (en, ru, uz)[idx]
        entries = [(key, val)]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = {n: {"type": t} for n, t in ph.items()}
            entries.append(("@" + key, meta))
        for kk, vv in entries:
            line = f"  {json.dumps(kk, ensure_ascii=False)}: {json.dumps(vv, ensure_ascii=False)}"
            if kk in data:
                text = re.sub(r"(?ms)^  " + re.escape(json.dumps(kk, ensure_ascii=False)) + r": .*?(,?)\n(?=  \"|\}$)",
                              lambda m: line + m.group(1) + "\n", text, count=1)
            else:
                body = text.rstrip()
                assert body.endswith("}")
                text = body[:-1].rstrip() + ",\n" + line + "\n}\n"
        data = json.loads(text)
    json.loads(text)
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")
