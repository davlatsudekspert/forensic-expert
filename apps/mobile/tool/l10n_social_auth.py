# Google / Apple bilan kirish matnlari (docs/SOCIAL_SIGN_IN.md). Idempotent.
# Tartib: l10n_avatar.py dan keyin, l10n_ux_audit.py dan oldin; oxirida
# `flutter gen-l10n`.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz):
    K[key] = (desc, en, ru, uz)
k("socialOr","Divider between email form and social sign-in buttons.","or","или","yoki")
k("socialContinueGoogle","Google sign-in button label (brand guideline wording).","Continue with Google","Продолжить с Google","Google bilan davom etish")
k("socialContinueApple","Apple sign-in button label (Apple HIG wording).","Continue with Apple","Продолжить с Apple","Apple bilan davom etish")
k("socialErrUnavailable","Error: Google/Apple sign-in failed or is unavailable on this device.","Sign-in with this provider is unavailable right now. Try again or use your email.","Вход через этого провайдера сейчас недоступен. Попробуйте ещё раз или войдите по email.","Bu usulda kirish hozir mavjud emas. Qayta urinib ko‘ring yoki email orqali kiring.")
k("socialTermsNote","Note under social buttons: continuing means accepting terms.","By continuing you accept the Terms of Use and the Privacy Policy.","Продолжая, вы принимаете Условия использования и Политику конфиденциальности.","Davom etib, Foydalanish shartlari va Maxfiylik siyosatiga rozilik bildirasiz.")
k("deleteAccountSocialNote","Delete-account screen note for accounts created with Google/Apple (no password).","This account was created with Google or Apple, so no password is needed. Confirm below to delete it.","Этот аккаунт создан через Google или Apple, пароль не нужен. Подтвердите ниже, чтобы удалить его.","Bu akkaunt Google yoki Apple orqali ochilgan, shuning uchun parol kerak emas. O‘chirish uchun pastda tasdiqlang.")
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
