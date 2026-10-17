# Apple akkauntni o'chirishda qayta tasdiqlash matni (docs/SOCIAL_SIGN_IN.md §3). Idempotent.
# Tartib: l10n_social_auth.py dan keyin; oxirida `flutter gen-l10n`.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz):
    K[key] = (desc, en, ru, uz)
k("deleteAccountAppleNote","Delete-account screen note for Apple accounts: Apple re-confirmation step.","This account was created with Apple, so no password is needed. After you confirm, Apple will ask you to verify it is you, and the app's access to your Apple ID will be revoked.","Этот аккаунт создан через Apple, пароль не нужен. После подтверждения Apple попросит подтвердить, что это вы, и доступ приложения к вашему Apple ID будет отозван.","Bu akkaunt Apple orqali ochilgan, shuning uchun parol kerak emas. Tasdiqlaganingizdan so‘ng Apple o‘zingizni tasdiqlashni so‘raydi va ilovaning Apple ID’ingizga kirish huquqi bekor qilinadi.")
for idx, code in enumerate(["en","ru","uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key,(desc,en,ru,uz) in K.items():
        data[key] = (en,ru,uz)[idx]
        if code == "en":
            data["@"+key] = {"description": desc}
    json.dump(data, open(p,"w",encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p,"a").write("\n")
print(len(K), "keys")
