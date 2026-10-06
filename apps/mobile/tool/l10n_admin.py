# Admin panel (egasi) va server grant matnlari.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
I = {"type": "int"}
k("adminTitle","Screen title.","Admin panel","Админ-панель","Admin panel")
k("adminProfileHint","Profile row hint.","Users, platforms, countries, access","Пользователи, платформы, страны, доступ","Foydalanuvchilar, platformalar, davlatlar, kirish")
k("adminUsers","Stat.","Users","Пользователи","Foydalanuvchilar")
k("adminConfirmed","Stat.","Email confirmed","Email подтверждён","Email tasdiqlangan")
k("adminSignups7d","Stat.","New (7 days)","Новые (7 дней)","Yangi (7 kun)")
k("adminActive7d","Stat.","Active (7 days)","Активные (7 дней)","Faol (7 kun)")
k("adminAndroid","Stat.","Android","Android","Android")
k("adminIos","Stat.","iOS","iOS","iOS")
k("adminAiRequests","Stat.","AI requests","Запросы к ИИ","AI so‘rovlar")
k("adminReferrals","Stat.","Referrals","Приглашения","Takliflar")
k("adminProGrants","Stat.","Pro granted","Выдано Pro","Berilgan Pro")
k("adminRegions","Section.","Countries (device region)","Страны (регион устройства)","Davlatlar (qurilma hududi)")
k("adminDaily","Section.","Sign-ups, last 30 days","Регистрации за 30 дней","Ro‘yxatdan o‘tish, 30 kun")
k("adminUserList","Section.","Users ({count})","Пользователи ({count})","Foydalanuvchilar ({count})",{"count":I})
k("adminStoreNote","Note.","Only registered users are counted here. Installs without sign-up are shown in App Store Connect and Google Play Console.","Здесь учитываются только зарегистрированные пользователи. Установки без регистрации видны в App Store Connect и Google Play Console.","Bu yerda faqat ro‘yxatdan o‘tganlar sanaladi. Ro‘yxatdan o‘tmagan yuklab olishlar App Store Connect va Google Play Console’da ko‘rinadi.")
k("adminPrivacyNote","Note.","Contains personal data (emails). Do not share screenshots.","Содержит персональные данные (email). Не пересылайте скриншоты.","Shaxsiy ma’lumot (email) bor. Skrinshotlarni tarqatmang.")
k("adminGrantTitle","Section.","Give or remove Pro","Выдать или снять Pro","Pro berish yoki olib tashlash")
k("adminEmail","Field.","User email","Email пользователя","Foydalanuvchi emaili")
k("adminGrantPro","Action.","Give Professional Pro","Выдать Professional Pro","Professional Pro berish")
k("adminRevoke","Action.","Remove","Снять","Olib tashlash")
k("adminGranted","Result.","Pro granted.","Pro выдан.","Pro berildi.")
k("adminRevoked","Result.","Access removed.","Доступ снят.","Kirish olib tashlandi.")
k("adminNotFound","Result.","No user with this email.","Пользователь с таким email не найден.","Bunday emailli foydalanuvchi yo‘q.")
k("adminFailed","Result.","Action failed. Check the connection.","Не удалось. Проверьте соединение.","Bajarilmadi. Aloqani tekshiring.")
k("adminForbidden","Empty.","This section is for administrators only.","Раздел только для администраторов.","Bu bo‘lim faqat administratorlar uchun.")
k("adminRefresh","Action.","Refresh","Обновить","Yangilash")
k("adminUnknownRegion","Label.","Unknown","Неизвестно","Noma’lum")
k("adminAdminBadge","Badge.","Admin","Админ","Admin")
for idx, code in enumerate(["en","ru","uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key,(desc,en,ru,uz,ph) in K.items():
        data[key] = (en,ru,uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph: meta["placeholders"] = ph
            data["@"+key] = meta
    json.dump(data, open(p,"w",encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p,"a").write("\n")
print(len(K), "keys")
