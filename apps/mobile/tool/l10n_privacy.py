# Maxfiylik siyosati: «Taklif va murojaatlar» bandi (2026-10-09). Idempotent:
# band privacySummary oxiriga bir marta qo‘shiladi.
import json, collections
D = "lib/core/l10n/arb"
ADD = {
  "uz": "Taklif va murojaatlar: «Taklif va murojaatlar» bo‘limi orqali yuborgan xabaringiz, ixtiyoriy skrinshotingiz (faqat JPEG/PNG/WebP, 5 MB gacha), murojaat turi va hisobingiz elektron pochtasi serverimizda faqat sizga javob berish va ilovani yaxshilash uchun saqlanadi. Ularni faqat FORENSIC EXPERT jamoasining vakolatli administratori ko‘radi; boshqa foydalanuvchilar hech qachon ko‘rmaydi. Javobda administrator ismi emas, «FORENSIC EXPERT jamoasi» ko‘rsatiladi. Administrator amallari jurnalga yoziladi (xabar matnisiz). Murojaat yuborishdan oldin roziligingiz so‘raladi. Murojaatlar va skrinshotlar uchinchi shaxslarga berilmaydi, reklama yoki AI o‘qitish uchun ishlatilmaydi. Hisobingizni o‘chirsangiz, murojaatlaringiz, xabarlaringiz va skrinshotlaringiz ham butunlay o‘chiriladi.",
  "ru": "Предложения и обращения: сообщение, отправленное через раздел «Предложения и обращения», необязательный скриншот (только JPEG/PNG/WebP, до 5 МБ), тип обращения и электронная почта вашего аккаунта хранятся на нашем сервере только для ответа вам и улучшения приложения. Их видит только уполномоченный администратор команды FORENSIC EXPERT; другие пользователи их никогда не видят. В ответе указывается «Команда FORENSIC EXPERT», а не имя администратора. Действия администратора записываются в журнал (без текста сообщений). Перед отправкой обращения запрашивается ваше согласие. Обращения и скриншоты не передаются третьим лицам и не используются для рекламы или обучения ИИ. При удалении аккаунта ваши обращения, сообщения и скриншоты удаляются полностью.",
  "en": "Suggestions & support: the message you send in «Suggestions & support», an optional screenshot (JPEG/PNG/WebP only, up to 5 MB), the request type and your account e-mail are stored on our server only to reply to you and improve the app. Only an authorised FORENSIC EXPERT team administrator can see them; other users never can. Replies are signed «FORENSIC EXPERT team», not with an administrator's name. Administrator actions are logged (without message text). Your consent is requested before a request is sent. Requests and screenshots are not shared with third parties and are not used for advertising or AI training. If you delete your account, your requests, messages and screenshots are deleted permanently.",
}
for code, add in ADD.items():
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    cur = data["privacySummary"]
    if add not in cur:
        data["privacySummary"] = cur.rstrip() + "\n\n" + add
    json.dump(data, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p, "a").write("\n")
print("privacy: ok")
