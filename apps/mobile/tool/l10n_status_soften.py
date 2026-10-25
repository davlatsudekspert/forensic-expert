# Ilmiy holat yozuvlarini yumshatish (egasi qarori, 2026-10-25): foydalanuvchini qo‘rqitadigan
# «Tasdiqlash kerak» / «Tekshirilmagan» o‘rniga haqiqatga mos neytral yozuv (manba/adabiyot).
# Ustoz kitoblari «Tasdiqlangan manba» bo‘lib qoladi. Idempotent; mavjud kalitlarni yangilaydi.
# l10n_admin_duration.py dan keyin:
#   cd apps/mobile && python3 tool/l10n_status_soften.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph or {})


k('needsConfirmationChip', 'Chip: a claim from international literature (article, thesis).',
  'International literature', 'Международная литература', 'Xalqaro adabiyot')
k('needsConfirmationBanner', 'Banner for claims from international literature.',
  'From international literature (article, thesis); see the original source for important decisions.',
  'Из международной литературы (статья, тезис); для важных решений см. оригинальный источник.',
  'Xalqaro adabiyotdan (maqola, tezis) olingan; muhim qarorlar uchun asl manbani ko‘ring.')
k('statusSourced', 'Status badge for content that cites a source but has no reviewer sign-off yet.',
  'Source cited', 'Источник указан', 'Manba keltirilgan')
k('aiLimNotVerified', 'AI limitation: evidence is from literature, for reference.',
  'Information is taken from the literature and is for reference; it does not replace an official expert conclusion.',
  'Сведения взяты из литературы и носят справочный характер; не заменяют официальное заключение эксперта.',
  'Ma’lumotlar adabiyotdan olingan va ma’lumot uchun; rasmiy ekspert xulosasi o‘rnini bosmaydi.')

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
