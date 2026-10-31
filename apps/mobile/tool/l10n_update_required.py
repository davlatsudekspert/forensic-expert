# «Yangi versiya chiqdi» (majburiy yangilash) sahifasi. Idempotent.
# CLAUDE.md tartibida l10n_tts.py dan keyin:
#   cd apps/mobile && python3 tool/l10n_update_required.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph or {})


k('updReqTitle', 'Title of the blocking page shown when this app version is too old.',
  'A new version is available', 'Вышла новая версия', 'Yangi versiya chiqdi')
k('updReqBody', 'Body of the blocking page: the installed version is outdated.',
  'This version of the app is out of date. Update the app to continue.',
  'Эта версия приложения устарела. Чтобы продолжить, обновите приложение.',
  'Ilovaning bu versiyasi eskirgan. Davom etish uchun ilovani yangilang.')
k('updReqButton', 'Primary button of the blocking page: opens the store listing.',
  'Update', 'Обновить', 'Yangilash')
k('updReqStoreHint', 'Shown instead of the button when there is no store link (iOS).',
  'Update the app from the App Store.', 'Обновите приложение в App Store.',
  'App Store’dan yangilang.')

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
