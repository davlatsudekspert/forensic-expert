# «Ustoz kartasi» (2026-10-31): ustoz profilida rasm, ish joyi, «o‘zim haqimda»
# va tarmoq havolalari; talaba guruh sahifasida ko‘radi (uz/ru/en).
# Idempotent: faqat shu fayldagi kalitlarni yozadi (mavjudini yangilaydi).
# CLAUDE.md tartibida «(yangi skriptlar)» o‘rnida — l10n_group_wording.py dan
# keyin, l10n_ux_audit.py dan oldin:
#   cd apps/mobile && python3 tool/l10n_teacher_card.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    """ph: {nom: 'int' | 'String'} — ICU o‘rinbosarlar (faqat en ARB metama’lumotida)."""
    K[key] = (desc, en, ru, uz, ph or {})


k("tcTitle", "Title of the teacher card editor and the profile row.",
  "My teacher card", "Моя карточка преподавателя", "Ustoz kartam")
k("tcProfileHint", "Profile row subtitle under the teacher card entry.",
  "Photo, workplace, links — shown to your students",
  "Фото, место работы, ссылки — видны вашим студентам",
  "Rasm, ish joyi, havolalar — talabalaringizga ko‘rinadi")
k("tcProfileOn", "Profile row value: the card is shown to the students.",
  "Visible", "Показывается", "Ko‘rinadi")
k("tcProfileOff", "Profile row value: the card exists but is hidden from the students.",
  "Hidden", "Скрыта", "Yashirin")
k("tcProfileNone", "Profile row value: the card has not been filled in.",
  "Not set", "Не заполнена", "To‘ldirilmagan")
k("tcLead", "Intro text at the top of the teacher card editor.",
  "A short introduction your students see on the group page. Only your name is required.",
  "Короткое знакомство, которое студенты видят на странице группы. Обязательно только имя.",
  "Talabalaringiz guruh sahifasida ko‘radigan qisqa tanishtiruv. Faqat ism majburiy.")
k("tcStudentLabel", "Small label above the teacher card on the group page (student view).",
  "Teacher", "Преподаватель", "Ustoz")
k("tcPhotoSection", "Section label: teacher photo.", "Photo", "Фото", "Rasm")
k("tcPhotoChoose", "Button: pick a photo.", "Choose photo", "Выбрать фото", "Rasm tanlash")
k("tcPhotoChange", "Button: replace the photo.", "Change photo", "Сменить фото", "Rasmni almashtirish")
k("tcPhotoRemove", "Button: remove the photo.", "Remove photo", "Удалить фото", "Rasmni olib tashlash")
k("tcPhotoNote", "Privacy note under the photo: it is separate from the on-device profile picture.",
  "This photo is separate from your profile picture, which stays on this phone. It is uploaded when you save the card, and your group members can see it only if «Show to my students» is on.",
  "Это фото отдельное от аватара профиля, который остаётся на телефоне. Оно загружается при сохранении карточки, а участники ваших групп видят его, только если включено «Показывать моим студентам».",
  "Bu rasm profildagi (faqat shu telefonda qoladigan) rasmdan alohida. Karta saqlanganda serverga yuklanadi, guruhingiz a’zolari uni faqat «Talabalarimga ko‘rsatish» yoqilgan bo‘lsa ko‘radi.")
k("tcPhotoSemantics", "Semantics label of the teacher's photo.",
  "Photo of {name}", "Фото: {name}", "{name} rasmi", {"name": "String"})
k("tcName", "Field label: teacher's full name.", "Full name", "Имя и фамилия", "Ism va familiya")
k("tcNameHelper", "Helper under the name field.", "2–60 characters", "От 2 до 60 символов", "2–60 ta belgi")
k("tcWorkplace", "Field label: workplace.", "Workplace", "Место работы", "Ish joyi")
k("tcWorkplaceHint", "Hint in the workplace field.",
  "e.g. university, bureau, laboratory",
  "например: университет, бюро, лаборатория",
  "masalan: universitet, byuro, laboratoriya")
k("tcLogoSection", "Section label: optional workplace logo.",
  "Workplace logo (optional)", "Логотип места работы (необязательно)", "Ish joyi logotipi (ixtiyoriy)")
k("tcLogoChoose", "Button: pick a logo.", "Choose logo", "Выбрать логотип", "Logotip tanlash")
k("tcLogoRemove", "Button: remove the logo.", "Remove logo", "Удалить логотип", "Logotipni olib tashlash")
k("tcLogoSemantics", "Semantics label of the workplace logo.",
  "Workplace logo", "Логотип места работы", "Ish joyi logotipi")
k("tcBio", "Field label: short self-description.", "About me", "О себе", "O‘zim haqimda")
k("tcBioHint", "Hint in the about-me field.",
  "A few sentences about your experience and subjects",
  "Несколько предложений об опыте и предметах",
  "Tajriba va fanlaringiz haqida bir-ikki gap")
k("tcSocials", "Section label: social networks and website.",
  "Social networks and website", "Соцсети и сайт", "Ijtimoiy tarmoqlar va vebsayt")
k("tcSocialsHint", "Hint under the social links section.",
  "Paste a link or @username. Only secure (https) links to the network's own site are accepted.",
  "Вставьте ссылку или @username. Принимаются только защищённые (https) ссылки на сайт самой сети.",
  "Havola yoki @username kiriting. Faqat tarmoqning o‘z manziliga olib boradigan xavfsiz (https) havolalar qabul qilinadi.")
k("tcNetTelegram", "Network name.", "Telegram", "Telegram", "Telegram")
k("tcNetInstagram", "Network name.", "Instagram", "Instagram", "Instagram")
k("tcNetYoutube", "Network name.", "YouTube", "YouTube", "YouTube")
k("tcNetFacebook", "Network name.", "Facebook", "Facebook", "Facebook")
k("tcNetLinkedin", "Network name.", "LinkedIn", "LinkedIn", "LinkedIn")
k("tcNetTiktok", "Network name.", "TikTok", "TikTok", "TikTok")
k("tcNetWebsite", "Name of the personal/work website field.", "Website", "Сайт", "Vebsayt")
k("tcSocialHintUser", "Hint in a network field that accepts @username or a link.",
  "@username or link", "@username или ссылка", "@username yoki havola")
k("tcSocialHintWeb", "Hint in the website field.", "https://example.org", "https://example.org", "https://example.org")
k("tcSocialInvalid", "Inline error under an invalid social link.",
  "Invalid link. Use https and the network's own address.",
  "Неверная ссылка. Нужен https и адрес самой сети.",
  "Havola noto‘g‘ri. https va tarmoqning o‘z manzili kerak.")
k("tcVisibleTitle", "Switch title: show the card to the teacher's students.",
  "Show to my students", "Показывать моим студентам", "Talabalarimga ko‘rsatish")
k("tcConsent", "Consent text under the visibility switch.",
  "Your photo and details are visible only to members of your groups. You can turn this off at any time or delete the card completely.",
  "Ваше фото и данные видны только участникам ваших групп. Вы можете в любой момент отключить показ или полностью удалить карточку.",
  "Rasm va ma’lumotlaringiz faqat sizning guruhlaringiz a’zolariga ko‘rinadi. Istalgan vaqtda ko‘rsatishni o‘chirib qo‘yishingiz yoki kartani butunlay o‘chirishingiz mumkin.")
k("tcVisibleOn", "Status under the switch when on.",
  "Visible to your group members", "Видна участникам ваших групп", "Guruhlaringiz a’zolariga ko‘rinadi")
k("tcVisibleOff", "Status under the switch when off.",
  "Not visible to anyone yet", "Пока никому не видна", "Hozircha hech kimga ko‘rinmaydi")
k("tcPreview", "Button: preview the card as students see it.", "Preview", "Предпросмотр", "Ko‘rish")
k("tcPreviewTitle", "Title of the preview sheet.",
  "This is how your students see it", "Так видят ваши студенты", "Talabalar shunday ko‘radi")
k("tcPreviewNote", "Note in the preview sheet.",
  "Students see it only after you turn on «Show to my students».",
  "Студенты увидят её, только когда вы включите «Показывать моим студентам».",
  "Talabalar buni faqat «Talabalarimga ko‘rsatish» yoqilgach ko‘radi.")
k("tcSave", "Button: save the card.", "Save card", "Сохранить карточку", "Kartani saqlash")
k("tcSaved", "Snackbar after saving.", "Card saved", "Карточка сохранена", "Karta saqlandi")
k("tcDelete", "Button: delete the card.", "Delete card", "Удалить карточку", "Kartani o‘chirish")
k("tcDeleteTitle", "Dialog title: delete the card.", "Delete the card?", "Удалить карточку?", "Kartani o‘chiraymi?")
k("tcDeleteBody", "Dialog body: delete the card.",
  "The card and its photos will be deleted from the server. Students will no longer see it.",
  "Карточка и её фото будут удалены с сервера. Студенты больше её не увидят.",
  "Karta va uning rasmlari serverdan o‘chiriladi. Talabalar uni endi ko‘rmaydi.")
k("tcDeleteConfirm", "Dialog button: confirm deletion.", "Delete", "Удалить", "O‘chirish")
k("tcCancel", "Dialog button: cancel.", "Cancel", "Отмена", "Bekor qilish")
k("tcDeleted", "Snackbar after deleting.", "Card deleted", "Карточка удалена", "Karta o‘chirildi")
k("tcRetry", "Button: retry loading.", "Try again", "Повторить", "Qayta urinish")
k("tcReport", "Tooltip/button: report the teacher card (UGC).",
  "Report this card", "Пожаловаться на карточку", "Kartadan shikoyat qilish")
k("tcOpenLink", "Semantics/tooltip of a social icon.",
  "Open {network}", "Открыть {network}", "{network} ni ochish", {"network": "String"})
k("tcLinkOpenFailed", "Snackbar when a link cannot be opened.",
  "Could not open the link.", "Не удалось открыть ссылку.", "Havolani ochib bo‘lmadi.")
k("tcErrName", "Error: invalid name.",
  "Enter your name (2–60 characters).", "Введите имя (2–60 символов).", "Ismingizni kiriting (2–60 ta belgi).")
k("tcErrWorkplace", "Error: workplace too long.",
  "Workplace is too long (up to 120 characters).",
  "Место работы слишком длинное (до 120 символов).",
  "Ish joyi juda uzun (120 ta belgigacha).")
k("tcErrBio", "Error: bio too long.",
  "«About me» is too long (up to 300 characters).",
  "«О себе» слишком длинное (до 300 символов).",
  "«O‘zim haqimda» juda uzun (300 ta belgigacha).")
k("tcErrImage", "Error: the image cannot be used.",
  "The image could not be used. Choose another one (JPEG, PNG or WebP).",
  "Не удалось использовать изображение. Выберите другое (JPEG, PNG или WebP).",
  "Rasmdan foydalanib bo‘lmadi. Boshqasini tanlang (JPEG, PNG yoki WebP).")
k("tcErrImageLarge", "Error: the image is too large even after compression.",
  "The image is too large even after compression. Choose a smaller one.",
  "Изображение слишком большое даже после сжатия. Выберите меньшее.",
  "Rasm siqilgandan keyin ham juda katta. Kichikroq rasm tanlang.")
k("tcErrSocial", "Error: some social link was rejected.",
  "One of the links is not accepted. Check the fields marked in red.",
  "Одна из ссылок не принята. Проверьте поля, отмеченные красным.",
  "Havolalardan biri qabul qilinmadi. Qizil belgilangan maydonlarni tekshiring.")
k("tcErrHidden", "Banner/error: the card was hidden by a moderator.",
  "Your card was hidden by a moderator. Write to us via «Suggestions & support».",
  "Ваша карточка скрыта модератором. Напишите нам через «Предложения и обращения».",
  "Kartangiz moderator tomonidan yashirilgan. «Taklif va murojaatlar» orqali bizga yozing.")
k("tcErrForbidden", "Error: not a teacher account.",
  "The teacher card works only for accounts with the teacher role.",
  "Карточка преподавателя работает только для аккаунтов с ролью преподавателя.",
  "Ustoz kartasi faqat ustoz roli bor hisobda ishlaydi.")
k("tcErrOffline", "Error: offline.",
  "No internet connection. Try again.", "Нет интернета. Повторите попытку.", "Internet yo‘q. Qayta urinib ko‘ring.")
k("tcErrNotConfigured", "Error: backend not connected.",
  "This service is not connected yet.", "Этот сервис пока не подключён.", "Bu xizmat hali ulanmagan.")
k("tcErrServer", "Error: generic server failure.",
  "Could not complete the action. Please try again later.",
  "Не удалось выполнить действие. Повторите позже.",
  "Amalni bajarib bo‘lmadi. Keyinroq qayta urinib ko‘ring.")
k("tcErrSignIn", "Error: not signed in.",
  "Sign in to your account first.", "Сначала войдите в аккаунт.", "Avval hisobingizga kiring.")

# Matnli qo‘shish (json.dump faylning qolgan formatini o‘zgartirmasin).
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
                data[kk] = vv
    json.loads(text)  # hali ham to‘g‘ri JSON
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")

# Ilova ichidagi maxfiylik xulosasiga ustoz kartasi haqida bir gap.
ADD = {
    "uz": " Ustoz kartasini (ixtiyoriy) to‘ldirsangiz, undagi ism, ish joyi, matn, havolalar va rasm serverda saqlanadi va faqat sizning guruhlaringiz a’zolariga, siz «Talabalarimga ko‘rsatish»ni yoqqan bo‘lsangina ko‘rinadi; kartani istalgan vaqtda o‘chirishingiz mumkin, hisob o‘chirilsa ham o‘chadi.",
    "ru": " Если вы заполните карточку преподавателя (необязательно), имя, место работы, текст, ссылки и фото из неё хранятся на сервере и видны только участникам ваших групп, и только если вы включили «Показывать моим студентам»; карточку можно удалить в любой момент, она удаляется и вместе с аккаунтом.",
    "en": " If you fill in the optional teacher card, its name, workplace, text, links and photo are stored on the server and visible only to members of your groups, and only if you turned on «Show to my students»; you can delete the card at any time, and it is deleted with your account.",
}
for code in ("uz", "ru", "en"):
    p = f"{D}/app_{code}.arb"
    text = open(p, encoding="utf-8").read()
    d = json.loads(text)
    s = d["privacySummary"]
    if ADD[code].strip()[:40] in s:
        continue
    i = s.index("\n\n")
    new = s[:i] + ADD[code] + s[i:]
    line_old = f"  {json.dumps('privacySummary')}: {json.dumps(s, ensure_ascii=False)}"
    line_new = f"  {json.dumps('privacySummary')}: {json.dumps(new, ensure_ascii=False)}"
    assert line_old in text, code
    open(p, "w", encoding="utf-8").write(text.replace(line_old, line_new, 1))
print("privacy ok")
