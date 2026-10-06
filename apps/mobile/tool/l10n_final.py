# Yakuniy sprint: email kod (OTP), 3 bosqichli mutaxassis profili, ariza
# qabul qilindi dialogi, manba sahifasi. RU/UZ — tahrir qilingan.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
I = {"type": "int"}
S = {"type": "String"}

k("emailCodeTitle","Email code screen title.","Sign in with email code","Вход по коду из письма","Email kod orqali kirish")
k("emailCodeRowHint","Profile row hint.","A 6-digit code is sent to your email — no password needed","На почту придёт 6-значный код — пароль не нужен","Emailingizga 6 xonali kod yuboriladi — parol shart emas")
k("emailCodeSubtitle","Email code subtitle.","Enter your email. We will send a one-time 6-digit FORENSIC EXPERT verification code.","Введите email. Мы отправим одноразовый 6-значный код подтверждения FORENSIC EXPERT.","Emailingizni kiriting. FORENSIC EXPERT bir martalik 6 xonali tasdiqlash kodini yuboradi.")
k("emailCodeSend","Action.","Send code","Отправить код","Kodni yuborish")
k("emailCodeEnterTitle","Code stage title.","Enter the 6-digit code","Введите 6-значный код","6 xonali kodni kiriting")
k("emailCodeChange","Action.","Change email","Изменить email","Emailni o‘zgartirish")
k("emailCodeResendIn","Resend countdown.","Resend code in {seconds} s","Повторная отправка через {seconds} с","Kodni qayta yuborish: {seconds} s",{"seconds":I})
k("emailCodeNotProfessional","Note.","Confirming your email signs you in. It does not verify professional status.","Подтверждение email выполняет вход. Оно не подтверждает профессиональный статус.","Emailni tasdiqlash hisobga kirishni ta’minlaydi. U mutaxassis maqomini tasdiqlamaydi.")
k("emailCodeSignedIn","Snackbar.","Email confirmed. You are signed in.","Email подтверждён. Вы вошли в аккаунт.","Email tasdiqlandi. Hisobga kirdingiz.")
k("actionNext","Action.","Next","Далее","Keyingi")
k("profileSectionProfessional","Section.","Professional profile","Профиль специалиста","Mutaxassis profili")
k("profileStepPersonal","Step title.","Personal","Личные данные","Shaxsiy")
k("profileStepWork","Step title.","Professional","Профессиональные данные","Kasbiy")
k("profileStepProfessional","Step title.","Profile and verification","Профиль и подтверждение","Profil va tasdiqlash")
k("profileStepOf","Step counter.","Step {step} of {total}","Шаг {step} из {total}","{step}-bosqich / {total}",{"step":I,"total":I})
k("verifReceivedTitle","Dialog title.","Your application has been received.","Ваша заявка принята.","Arizangiz qabul qilindi.")
k("verifReceivedBody","Dialog body.","Your professional status is being reviewed.","Профессиональный статус проверяется.","Mutaxassis maqomi tekshirilmoqda.")
k("verifReceivedNote","Dialog note.","Status: application pending. Only an authorised human verifier can grant Verified Professional status — submitting documents does not verify you automatically.","Статус: заявка на рассмотрении. Статус «Подтверждённый специалист» может присвоить только уполномоченный проверяющий — загрузка документов не подтверждает автоматически.","Holat: ariza ko‘rib chiqilmoqda. «Tasdiqlangan mutaxassis» maqomini faqat vakolatli inson-tekshiruvchi beradi — hujjat yuklash avtomatik tasdiq emas.")
k("sourceDetailTitle","Screen title.","Source","Источник","Manba")
k("sourceLinkedRecords","Section.","Linked records ({count})","Связанные записи ({count})","Bog‘langan yozuvlar ({count})",{"count":I})
k("sourceNoLinkedRecords","Empty.","No records in the offline database cite this source.","В офлайн-базе нет записей, ссылающихся на этот источник.","Oflayn bazada bu manbaga tayangan yozuv yo‘q.")
k("sourceNotAttached","No source.","No reliable source attached.","Надёжный источник не прикреплён.","Ishonchli manba biriktirilmagan.")
k("sourceNotFound","Not found.","Source not found in the offline database.","Источник не найден в офлайн-базе.","Manba oflayn bazada topilmadi.")
k("sourceOpenDetails","Action.","Source details and linked records","Подробности источника и связанные записи","Manba tafsilotlari va bog‘langan yozuvlar")
k("homeDbCounts","Home DB counts.","{substances} substances · {sources} sources · {claims} sourced claims","Веществ: {substances} · источников: {sources} · утверждений с источниками: {claims}","{substances} modda · {sources} manba · {claims} manbali da’vo",{"substances":I,"sources":I,"claims":I})
k("homeDbHumanVerified","Home DB human-verified count.","Human verified (2 independent experts): {count}","Подтверждено людьми (2 независимых эксперта): {count}","Inson tasdiqlagan (2 mustaqil ekspert): {count}",{"count":I})
k("sourcePmid","Source identifier.","PMID {id}","PMID {id}","PMID {id}",{"id":S})
k("homeStatSubstances","Stat label.","Substances","Вещества","Moddalar")
k("homeStatSources","Stat label.","Sources","Источники","Manbalar")
k("homeStatClaims","Stat label.","Sourced claims","Утверждения","Manbali da’volar")
k("homeStatHumanVerified","Stat label.","Human verified","Подтверждено экспертами","Inson tasdiqlagan")
k("homeStatPolicy","Stat footnote.","Human verified = two independent qualified experts. Automated checks and AI are never counted.","«Подтверждено» = два независимых квалифицированных эксперта. Автоматические проверки и ИИ не учитываются.","«Inson tasdiqlagan» = ikki mustaqil malakali ekspert. Avtomatik tekshiruv va AI hisoblanmaydi.")
k("aiHeroSubtitle","AI header subtitle.","Answers only from FORENSIC EXPERT’s sourced scientific database — every statement cites a record and shows its review status.","Ответы только из научной базы FORENSIC EXPERT с источниками — каждое утверждение ссылается на запись и показывает статус проверки.","Faqat FORENSIC EXPERT’ning manbali ilmiy bazasidan javob — har bir fikr yozuvga iqtibos va tekshiruv holati bilan.")
k("aiStatusConnected","AI status.","Connected · beta","Подключено · бета","Ulangan · beta")
k("aiContextSources","AI context chip.","Source: offline database","Источник: офлайн-база","Manba: oflayn baza")
k("aiComposerTitle","Composer title.","Scientific query","Научный запрос","Ilmiy so‘rov")

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
