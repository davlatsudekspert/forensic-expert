# «Sinfda test» audit tuzatishlari (2026-10-18) — yangi UI matnlari (uz/ru/en).
# Idempotent: faqat shu fayldagi kalitlarni yozadi (boshqa kalitlarga tegmaydi).
# CLAUDE.md tartibida «(yangi skriptlar)» o‘rnida — l10n_class_quiz.py dan
# keyin, l10n_ux_audit.py dan oldin:
#   cd apps/mobile && python3 tool/l10n_class_quiz_fixes.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz):
    K[key] = (desc, en, ru, uz)

k("classReconnecting",
  "Small non-blocking indicator while the live class poll is failing; the last screen stays visible.",
  "Reconnecting…", "Восстанавливаем соединение…", "Aloqa tiklanmoqda…")

# Matnli qo‘shish (json.dump faylning qolgan formatini o‘zgartirmasin).
for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    text = open(p, encoding="utf-8").read()
    data = json.loads(text)
    for key, (desc, en, ru, uz) in K.items():
        val = (en, ru, uz)[idx]
        entries = [(key, val)]
        if code == "en":
            entries.append(("@" + key, {"description": desc}))
        for kk, vv in entries:
            line = f"  {json.dumps(kk, ensure_ascii=False)}: {json.dumps(vv, ensure_ascii=False)}"
            if kk in data:
                text = re.sub(r"(?m)^  " + re.escape(json.dumps(kk, ensure_ascii=False)) + r": .*?(,?)$",
                              lambda m: line + m.group(1), text, count=1)
            else:
                body = text.rstrip()
                assert body.endswith("}")
                text = body[:-1].rstrip() + ",\n" + line + "\n}\n"
    json.loads(text)  # hali ham to‘g‘ri JSON
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")
