# Referral («Hamkasbingizni taklif qiling»), ulashish va birinchi qadamlar.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
I = {"type": "int"}
S = {"type": "String"}

k("referralTitle","Invite screen title.","Invite a colleague","Пригласить коллегу","Hamkasbingizni taklif qiling")
k("referralLead","Invite lead.","Know a forensic scientist, laboratory specialist or student who would find FORENSIC EXPERT useful? Share your personal invitation.","Знаете судебного эксперта, специалиста лаборатории или студента, которому пригодится FORENSIC EXPERT? Поделитесь личным приглашением.","FORENSIC EXPERT foydali bo‘ladigan sud eksperti, laboratoriya mutaxassisi yoki talabani bilasizmi? Shaxsiy taklifingizni ulashing.")
k("referralYourCode","Label.","Your invitation code","Ваш код приглашения","Taklif kodingiz")
k("referralYourLink","Label.","Your invitation link","Ваша ссылка-приглашение","Taklif havolangiz")
k("referralNoLinkNote","Note when no public link.","A web link will appear here once the public FORENSIC EXPERT site is connected. For now, share your code — a colleague enters it in Profile → Invitation code.","Веб-ссылка появится здесь после подключения публичного сайта FORENSIC EXPERT. Пока поделитесь кодом — коллега вводит его в «Профиль → Код приглашения».","Ommaviy FORENSIC EXPERT sayti ulangach, bu yerda veb-havola paydo bo‘ladi. Hozircha kodni ulashing — hamkasbingiz uni «Profil → Taklif kodi» bo‘limida kiritadi.")
k("referralShare","Action.","Share invitation","Поделиться приглашением","Taklifni ulashish")
k("referralCopy","Action.","Copy","Копировать","Nusxa olish")
k("referralCopied","Snackbar.","Copied to clipboard","Скопировано в буфер обмена","Buferga nusxa olindi")
k("referralStatsTitle","Section.","Your invitations","Ваши приглашения","Takliflaringiz")
k("referralStatJoined","Stat.","Joined","Присоединились","Qo‘shildi")
k("referralStatVerified","Stat.","Verified","Подтверждены","Tasdiqlangan")
k("referralStatPending","Stat.","Pending","Ожидают","Kutilmoqda")
k("referralStatCredits","Stat.","FORENSIC Credits","Кредиты FORENSIC","FORENSIC kreditlari")
k("referralCreditsPending","Pending credits line.","{amount} credits awaiting confirmation","{amount} кредитов ожидают подтверждения","{amount} kredit tasdiqlanishini kutmoqda",{"amount":S})
k("referralCreditsFuture","Credits note (rewards not live).","When paid services launch, eligible purchases by colleagues you invite may earn you FORENSIC Credits — {percent}% of the purchase value. Credits are an internal promotional bonus, not cash, and are not awarded for registration.","После запуска платных услуг подходящие покупки приглашённых вами коллег могут приносить вам FORENSIC Credits — {percent}% от суммы покупки. Кредиты — внутренний промо-бонус, а не деньги; за регистрацию они не начисляются.","Pullik xizmatlar ishga tushgach, taklif qilgan hamkasblaringizning mos xaridlaridan sizga FORENSIC Credits hisoblanishi mumkin — xarid qiymatining {percent}%. Kreditlar pul emas, ichki promo-bonus; ro‘yxatdan o‘tish uchun berilmaydi.",{"percent":S})
k("referralCreditsActive","Credits note (rewards live).","You receive FORENSIC Credits worth {percent}% of eligible purchases by colleagues you invite. Credits are confirmed after the refund period. They are an internal promotional bonus, not cash.","Вы получаете FORENSIC Credits в размере {percent}% от подходящих покупок приглашённых коллег. Кредиты подтверждаются после периода возврата. Это внутренний промо-бонус, а не деньги.","Taklif qilgan hamkasblaringizning mos xaridlaridan {percent}% miqdorida FORENSIC Credits olasiz. Kreditlar qaytarish muddatidan keyin tasdiqlanadi. Ular pul emas, ichki promo-bonus.",{"percent":S})
k("referralPrivacyNote","Privacy note.","Only totals are shown. Your colleagues’ names, emails, profiles and documents are never shared — neither with you nor in the invitation.","Показываются только итоговые числа. Имена, email, профили и документы коллег никогда не передаются — ни вам, ни в приглашении.","Faqat umumiy sonlar ko‘rsatiladi. Hamkasblaringizning ismi, emaili, profili va hujjatlari hech qachon ulashilmaydi — na sizga, na taklifda.")
k("referralShareSubject","Share subject.","Invitation to FORENSIC EXPERT","Приглашение в FORENSIC EXPERT","FORENSIC EXPERT’ga taklif")
k("referralShareWithLink","Share text with link.","I use FORENSIC EXPERT as a scientific reference for forensic work — substances, methods, sources and source-linked AI answers. You can join with my invitation:\n{link}","Я пользуюсь FORENSIC EXPERT как научным справочником для судебно-экспертной работы: вещества, методы, источники и ответы ИИ со ссылками на источники. Присоединяйтесь по моему приглашению:\n{link}","Men FORENSIC EXPERT’dan sud-ekspert ishida ilmiy ma’lumotnoma sifatida foydalanaman: moddalar, usullar, manbalar va manbaga tayangan AI javoblari. Mening taklifim orqali qo‘shiling:\n{link}",{"link":S})
k("referralShareWithCode","Share text with code.","I use FORENSIC EXPERT as a scientific reference for forensic work — substances, methods, sources and source-linked AI answers. Install the app and enter my invitation code in Profile → Invitation code: {code}","Я пользуюсь FORENSIC EXPERT как научным справочником для судебно-экспертной работы: вещества, методы, источники и ответы ИИ со ссылками на источники. Установите приложение и введите мой код в «Профиль → Код приглашения»: {code}","Men FORENSIC EXPERT’dan sud-ekspert ishida ilmiy ma’lumotnoma sifatida foydalanaman: moddalar, usullar, manbalar va manbaga tayangan AI javoblari. Ilovani o‘rnating va «Profil → Taklif kodi» bo‘limida kodimni kiriting: {code}",{"code":S})
k("referralSignInTitle","Signed-out title.","Sign in to get your invitation","Войдите, чтобы получить приглашение","Taklif olish uchun hisobga kiring","")
k("referralSignInBody","Signed-out body.","Your personal code is created on the server after you sign in with your email. All scientific content stays available without an account.","Личный код создаётся на сервере после входа по email. Весь научный контент доступен и без аккаунта.","Shaxsiy kod email orqali kirganingizdan so‘ng serverda yaratiladi. Barcha ilmiy ma’lumotlar akkauntsiz ham ochiq.")
k("referralNotConfigured","Not connected.","Invitations will be available once the FORENSIC EXPERT account service is connected.","Приглашения станут доступны после подключения аккаунт-сервиса FORENSIC EXPERT.","FORENSIC EXPERT akkaunt xizmati ulangach, takliflar ishlaydi.")
k("referralLoadError","Load error.","Couldn’t load your invitation. Check the connection and try again.","Не удалось загрузить приглашение. Проверьте соединение и повторите.","Taklif yuklanmadi. Aloqani tekshirib, qayta urinib ko‘ring.")
k("referralRetry","Action.","Try again","Повторить","Qayta urinish")
k("referralHaveCode","Section.","Invitation code","Код приглашения","Taklif kodi")
k("referralHaveCodeHint","Hint.","Received an invitation from a colleague? Enter the 8-character code. It applies only to new accounts.","Получили приглашение от коллеги? Введите 8-значный код. Он действует только для новых аккаунтов.","Hamkasbingizdan taklif oldingizmi? 8 belgili kodni kiriting. U faqat yangi akkauntlar uchun amal qiladi.")
k("referralCodeField","Field label.","Invitation code","Код приглашения","Taklif kodi")
k("referralApply","Action.","Apply","Применить","Qo‘llash")
k("referralLinkedNote","Already has referrer.","Your account was created with a colleague’s invitation.","Ваш аккаунт создан по приглашению коллеги.","Akkauntingiz hamkasbingiz taklifi bilan ochilgan.")
k("referralClaimValid","Outcome.","Invitation applied. Welcome to FORENSIC EXPERT.","Приглашение применено. Добро пожаловать в FORENSIC EXPERT.","Taklif qo‘llandi. FORENSIC EXPERT’ga xush kelibsiz.")
k("referralClaimPending","Outcome.","Invitation saved. It becomes valid once your email is confirmed.","Приглашение сохранено. Оно вступит в силу после подтверждения email.","Taklif saqlandi. Email tasdiqlangach kuchga kiradi.")
k("referralClaimInvalid","Outcome.","This code was not found. Check it and try again.","Код не найден. Проверьте его и попробуйте снова.","Bu kod topilmadi. Tekshirib, qayta urinib ko‘ring.")
k("referralClaimSelf","Outcome.","You can’t use your own invitation code.","Нельзя использовать собственный код приглашения.","O‘z taklif kodingizdan foydalana olmaysiz.")
k("referralClaimAlready","Outcome.","An invitation is already linked to your account.","К вашему аккаунту уже привязано приглашение.","Akkauntingizga taklif allaqachon bog‘langan.")
k("referralClaimNotEligible","Outcome.","Invitation codes apply only to new accounts.","Коды приглашения действуют только для новых аккаунтов.","Taklif kodlari faqat yangi akkauntlar uchun amal qiladi.")
k("referralClaimRateLimited","Outcome.","Too many attempts. Please try again later.","Слишком много попыток. Попробуйте позже.","Urinishlar juda ko‘p. Keyinroq qayta urinib ko‘ring.")
k("referralClaimSaved","Outcome.","Code saved. It will be applied after you sign in.","Код сохранён. Он будет применён после входа.","Kod saqlandi. Hisobga kirganingizdan so‘ng qo‘llanadi.")
k("referralClaimOffline","Outcome.","No connection. The code is saved and will be applied later.","Нет соединения. Код сохранён и будет применён позже.","Aloqa yo‘q. Kod saqlandi va keyinroq qo‘llanadi.")
k("referralClaimFormat","Validation.","Enter the 8-character code (letters and digits).","Введите 8-значный код (буквы и цифры).","8 belgili kodni kiriting (harf va raqamlar).")
k("referralProfileRowHint","Profile row hint.","Share FORENSIC EXPERT with colleagues","Поделитесь FORENSIC EXPERT с коллегами","FORENSIC EXPERT’ni hamkasblaringiz bilan ulashing")
k("homeInviteHint","Home action hint.","Share a reference you trust with colleagues","Поделитесь надёжным справочником с коллегами","Ishonchli ma’lumotnomani hamkasblaringiz bilan ulashing")
k("shareAction","Action.","Share","Поделиться","Ulashish")
k("shareFooter","Footer for shared scientific records.","Shared from FORENSIC EXPERT — scientific reference for forensic professionals. Verify against the original source before use.","Отправлено из FORENSIC EXPERT — научного справочника для судебных экспертов. Перед использованием сверяйтесь с первоисточником.","FORENSIC EXPERT’dan ulashildi — sud-ekspertlar uchun ilmiy ma’lumotnoma. Foydalanishdan oldin asl manba bilan solishtiring.")
k("shareSourcesLabel","Label in shared text.","Sources","Источники","Manbalar")
k("savedAdded","Snackbar.","Saved to your library","Сохранено в вашу библиотеку","Saqlanganlarga qo‘shildi")
k("savedRemoved","Snackbar.","Removed from saved","Удалено из сохранённого","Saqlanganlardan olib tashlandi")
k("firstStepsTitle","Card title.","Get started in 5 minutes","Начните за 5 минут","5 daqiqada boshlang")
k("firstStepsProgress","Progress.","{done} of {total} done","Выполнено {done} из {total}","{total} tadan {done} tasi bajarildi",{"done":I,"total":I})
k("firstStepsSearch","Step.","Search a substance","Найдите вещество","Moddani qidiring")
k("firstStepsDiscipline","Step.","Explore a discipline","Откройте дисциплину","Fan bo‘limini oching")
k("firstStepsSource","Step.","Open a scientific source","Откройте научный источник","Ilmiy manbani oching")
k("firstStepsAi","Step.","Try Forensic AI","Попробуйте Forensic AI","Forensic AI’ni sinab ko‘ring")
k("firstStepsSave","Step.","Save useful material","Сохраните полезный материал","Foydali materialni saqlang")
k("firstStepsHide","Action.","Hide","Скрыть","Yashirish")
k("firstStepsDone","Completed state.","You’re all set. Your saved materials and recent records stay on this device.","Всё готово. Сохранённые материалы и недавние записи остаются на этом устройстве.","Hammasi tayyor. Saqlangan materiallar va so‘nggi yozuvlar shu qurilmada qoladi.")

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
# Eslatma: privacySummary’ga «Takliflar» bandi qo‘shilgan (bir martalik).
