# «Talaba kartasi» (2026-10-31, 1-bosqich): talaba ixtiyoriy ravishda rasm,
# ism/taxallus va qisqa matn kiritadi; guruhdoshlari va ustozi guruh sahifasida
# ko‘radi. Havola/layk/obuna YO‘Q. Yangi kontent avval o‘zbekcha mukammal
# (CLAUDE.md, 2026-10-12); ru/en shu skriptda ham beriladi, keyin tekshiriladi.
# Idempotent: faqat shu fayldagi kalitlarni yozadi (mavjudini yangilaydi).
# CLAUDE.md tartibida «(yangi skriptlar)» o‘rnida (l10n_teacher_card.py dan keyin,
# l10n_ux_audit.py dan oldin):
#   cd apps/mobile && python3 tool/l10n_student_card.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    """ph: {nom: 'int' | 'String'} — ICU o‘rinbosarlar (faqat en ARB metama’lumotida)."""
    K[key] = (desc, en, ru, uz, ph or {})


k("scdTitle", "Title of the student card editor and the profile row.",
  "My student card", "Моя карточка студента", "Talaba kartam")
k("scdProfileHint", "Profile row subtitle under the student card entry.",
  "Optional: photo and a short intro for your groupmates and teacher",
  "Необязательно: фото и короткое знакомство для одногруппников и преподавателя",
  "Ixtiyoriy: guruhdoshlaringiz va ustozingiz uchun rasm va qisqa tanishtiruv")
k("scdProfileOn", "Profile row value: the card is shown to group members.",
  "Visible to my groups", "Видна моим группам", "Guruhlarimga ko‘rinadi")
k("scdProfileOff", "Profile row value: the card is hidden.",
  "Hidden", "Скрыта", "Yashirin")
k("scdLead", "Intro text at the top of the student card editor.",
  "A short, optional introduction. Only your groupmates and your teacher can see it, and only if you turn it on below. Only a name is required — a nickname is fine.",
  "Короткое необязательное знакомство. Видят его только одногруппники и преподаватель, и только если вы включите это ниже. Обязательно только имя — можно псевдоним.",
  "Qisqa va ixtiyoriy tanishtiruv. Uni faqat guruhdoshlaringiz va ustozingiz ko‘radi, va faqat siz quyida yoqsangiz. Faqat ism majburiy — taxallus ham bo‘ladi.")
k("scdLabel", "Small label above the student card in the viewer sheet.",
  "Student card", "Карточка студента", "Talaba kartasi")
k("scdPhotoSection", "Section label: student photo.", "Photo", "Фото", "Rasm")
k("scdPhotoChoose", "Button: pick a photo.", "Choose photo", "Выбрать фото", "Rasm tanlash")
k("scdPhotoChange", "Button: replace the photo.", "Change photo", "Сменить фото", "Rasmni almashtirish")
k("scdPhotoRemove", "Button: remove the photo.", "Remove photo", "Удалить фото", "Rasmni olib tashlash")
k("scdPhotoNote", "Privacy note under the photo.",
  "The photo is optional — you can use only your initial. It is separate from your profile picture, which stays on this phone.",
  "Фото необязательно — можно обойтись первой буквой имени. Оно отдельное от аватара профиля, который остаётся на телефоне.",
  "Rasm ixtiyoriy — faqat ism bosh harfi ham bo‘ladi. U profildagi (faqat shu telefonda qoladigan) rasmdan alohida.")
k("scdPhotoSemantics", "Semantics label of the student's photo.",
  "Photo of {name}", "Фото: {name}", "{name} rasmi", {"name": "String"})
k("scdName", "Field label: name or nickname.", "Name or nickname", "Имя или псевдоним", "Ism yoki taxallus")
k("scdNameHelper", "Helper under the name field.",
  "2–40 characters. A nickname is fine.", "От 2 до 40 символов. Можно псевдоним.", "2–40 ta belgi. Taxallus ham bo‘ladi.")
k("scdBio", "Field label: short self-description.", "About me", "О себе", "O‘zim haqimda")
k("scdBioHint", "Hint in the about-me field.",
  "One or two sentences: interests, field of study",
  "Одно-два предложения: интересы, направление учёбы",
  "Bir-ikki gap: qiziqishlaringiz, o‘qish yo‘nalishingiz")
k("scdNoContact", "Rule shown under the fields: no links or contact details.",
  "Do not write links, phone numbers, e-mail, @usernames or social network names — such text is rejected. Do not share personal contact details.",
  "Не пишите ссылки, номера телефонов, e-mail, @username и названия соцсетей — такой текст отклоняется. Не делитесь личными контактами.",
  "Havola, telefon raqami, elektron pochta, @username va ijtimoiy tarmoq nomini yozmang — bunday matn qabul qilinmaydi. Shaxsiy aloqa ma’lumotini ulashmang.")
k("scdVisibleTitle", "Switch title: show the card to groupmates and teacher.",
  "Show to my groupmates and teacher", "Показывать одногруппникам и преподавателю",
  "Guruhdoshlarimga va ustozimga ko‘rsatish")
k("scdVisibleOn", "Switch subtitle when on.",
  "Visible to members and the teacher of your groups",
  "Видна участникам и преподавателю ваших групп",
  "Guruhlaringiz a’zolari va ustoziga ko‘rinadi")
k("scdVisibleOff", "Switch subtitle when off.",
  "Hidden — nobody sees it", "Скрыта — никто не видит", "Yashirin — hech kim ko‘rmaydi")
k("scdConsent", "Consent text next to the visibility switch.",
  "If you turn this on, your photo, name and short text will be visible only to the other members and the teacher of the groups you belong to. Nobody outside your groups can see it, and there are no likes or followers. You can turn it off or delete the card at any time. Do not share personal contact details.",
  "Если включить, ваши фото, имя и короткий текст увидят только другие участники и преподаватель групп, в которых вы состоите. Никто вне ваших групп их не увидит, лайков и подписчиков нет. Отключить показ или удалить карточку можно в любой момент. Не делитесь личными контактами.",
  "Yoqsangiz, rasmingiz, ismingiz va qisqa matningiz faqat siz a’zo bo‘lgan guruhlarning boshqa a’zolari va ustoziga ko‘rinadi. Guruhingizdan tashqaridagi hech kim ko‘ra olmaydi, layk va obunachilar yo‘q. Istalgan vaqtda ko‘rsatishni o‘chirishingiz yoki kartani o‘chirishingiz mumkin. Shaxsiy aloqa ma’lumotini ulashmang.")
k("scdPreview", "Button: preview the card as others see it.", "Preview", "Просмотр", "Ko‘rish")
k("scdPreviewTitle", "Title of the preview sheet.", "How others see your card",
  "Так видят вашу карточку", "Kartangizni boshqalar shunday ko‘radi")
k("scdPreviewNote", "Note under the preview.",
  "Only people in your groups can see it, and only when the switch is on.",
  "Увидят только люди из ваших групп и только при включённом переключателе.",
  "Faqat guruhlaringizdagi odamlar ko‘radi va faqat kalit yoqilgan bo‘lsa.")
k("scdSave", "Button: save the card.", "Save card", "Сохранить карточку", "Kartani saqlash")
k("scdSaved", "Snackbar: saved.", "Card saved", "Карточка сохранена", "Karta saqlandi")
k("scdDelete", "Button: delete the card.", "Delete card", "Удалить карточку", "Kartani o‘chirish")
k("scdDeleteTitle", "Dialog title: delete the card.", "Delete the card?", "Удалить карточку?", "Kartani o‘chiramizmi?")
k("scdDeleteBody", "Dialog body: delete the card.",
  "Your card and its photo will be removed from the server. This cannot be undone.",
  "Карточка и её фото будут удалены с сервера. Это нельзя отменить.",
  "Kartangiz va rasmi serverdan o‘chiriladi. Buni qaytarib bo‘lmaydi.")
k("scdDeleteConfirm", "Dialog confirm button: delete.", "Delete", "Удалить", "O‘chirish")
k("scdDeleted", "Snackbar: card deleted.", "Card deleted", "Карточка удалена", "Karta o‘chirildi")
k("scdCancel", "Dialog cancel button.", "Cancel", "Отмена", "Bekor qilish")
k("scdRetry", "Retry button.", "Try again", "Повторить", "Qayta urinish")
k("scdAdminHidden", "Banner: the card was hidden by a moderator.",
  "Your card was hidden by a moderator. Write to us via «Suggestions & support».",
  "Ваша карточка скрыта модератором. Напишите нам через «Предложения и обращения».",
  "Kartangiz moderator tomonidan yashirilgan. «Taklif va murojaatlar» orqali bizga yozing.")
k("scdTeacherHidden", "Banner: the teacher hid the card in some groups.",
  "Your teacher hid your card in some groups. Members of those groups cannot see it.",
  "Преподаватель скрыл вашу карточку в некоторых группах. Участники этих групп её не видят.",
  "Ustozingiz kartangizni ba’zi guruhlarda yashirgan. O‘sha guruhlar a’zolari uni ko‘rmaydi.")
k("scdErrName", "Error: invalid name.", "The name must be 2–40 characters.",
  "Имя должно содержать от 2 до 40 символов.", "Ism 2–40 ta belgidan iborat bo‘lishi kerak.")
k("scdErrBio", "Error: bio too long.", "«About me» is too long (up to 150 characters).",
  "«О себе» слишком длинное (до 150 символов).", "«O‘zim haqimda» juda uzun (150 ta belgigacha).")
k("scdErrContact", "Error: the text contains a link or contact details.",
  "Links, phone numbers, e-mail, @usernames and social network names are not allowed. Remove them and try again.",
  "Ссылки, номера телефонов, e-mail, @username и названия соцсетей запрещены. Удалите их и повторите.",
  "Havola, telefon raqami, elektron pochta, @username va ijtimoiy tarmoq nomi taqiqlangan. Ularni olib tashlab, qayta urinib ko‘ring.")
k("scdErrImage", "Error: the image cannot be used.",
  "The image could not be used. Choose another one (JPEG, PNG or WebP).",
  "Не удалось использовать изображение. Выберите другое (JPEG, PNG или WebP).",
  "Rasmdan foydalanib bo‘lmadi. Boshqasini tanlang (JPEG, PNG yoki WebP).")
k("scdErrImageLarge", "Error: the image is too large even after compression.",
  "The image is too large even after compression. Choose a smaller one.",
  "Изображение слишком большое даже после сжатия. Выберите меньшее.",
  "Rasm siqilgandan keyin ham juda katta. Kichikroq rasm tanlang.")
k("scdErrLimit", "Error: too many hidden cards.",
  "Too many hidden cards. Restore some first.",
  "Слишком много скрытых карточек. Сначала верните некоторые.",
  "Yashirilgan kartalar juda ko‘p. Avval ba’zilarini qaytaring.")
k("scdErrForbidden", "Error: no access.", "You do not have access to this card.",
  "У вас нет доступа к этой карточке.", "Bu kartaga ruxsatingiz yo‘q.")
k("scdErrNotFound", "Error: the student is not in this group.",
  "This student is no longer in the group.", "Этого студента больше нет в группе.",
  "Bu talaba endi guruhda emas.")
k("scdErrOffline", "Error: offline.", "No internet connection. Try again.",
  "Нет интернета. Повторите попытку.", "Internet yo‘q. Qayta urinib ko‘ring.")
k("scdErrNotConfigured", "Error: backend not connected.", "This service is not connected yet.",
  "Этот сервис пока не подключён.", "Bu xizmat hali ulanmagan.")
k("scdErrServer", "Error: generic server failure.",
  "Could not complete the action. Please try again later.",
  "Не удалось выполнить действие. Повторите позже.",
  "Amalni bajarib bo‘lmadi. Keyinroq qayta urinib ko‘ring.")
k("scdErrSignIn", "Error: not signed in.", "Sign in to your account first.",
  "Сначала войдите в аккаунт.", "Avval hisobingizga kiring.")
k("scdGroupSection", "Section header in the group screen: groupmates with cards.",
  "Groupmates", "Одногруппники", "Guruhdoshlar")
k("scdOpenCard", "Semantics/tooltip: open a student's card.", "Open {name}'s card",
  "Открыть карточку: {name}", "{name} kartasini ochish", {"name": "String"})
k("scdSheetReport", "Sheet action: report the card.", "Report this card",
  "Пожаловаться на карточку", "Kartaga shikoyat qilish")
k("scdSheetHide", "Sheet action: hide the card for me.", "Hide this card for me",
  "Скрыть эту карточку для меня", "Bu kartani yashirish")
k("scdSheetHideNote", "Note under the hide action.",
  "Only you will stop seeing it. You can restore it under «Hidden cards» on the group page.",
  "Только вы перестанете её видеть. Вернуть можно в «Скрытые карточки» на странице группы.",
  "Faqat siz ko‘rmaysiz. Guruh sahifasidagi «Yashirilgan kartalar»dan qaytarishingiz mumkin.")
k("scdHiddenToast", "Snackbar: card hidden for me.", "Card hidden", "Карточка скрыта", "Karta yashirildi")
k("scdSheetGroupHide", "Sheet action (teacher): hide the card from the group.",
  "Hide from this group", "Скрыть из этой группы", "Guruhdan yashirish")
k("scdSheetGroupUnhide", "Sheet action (teacher): restore the card to the group.",
  "Show in this group again", "Показывать в этой группе снова", "Guruhga qaytarish")
k("scdSheetGroupNote", "Note under the teacher moderation action.",
  "As the teacher you can hide an inappropriate card from the group. The student cannot turn it back on.",
  "Как преподаватель вы можете скрыть неподобающую карточку из группы. Студент не сможет включить её обратно.",
  "Ustoz sifatida nomaqbul kartani guruhdan yashira olasiz. Talaba uni qayta yoqa olmaydi.")
k("scdGroupHiddenLabel", "Label (teacher): this card is hidden from the group.",
  "Hidden from the group", "Скрыта из группы", "Guruhdan yashirilgan")
k("scdGroupHiddenToast", "Snackbar (teacher): card hidden from the group.",
  "Card hidden from the group", "Карточка скрыта из группы", "Karta guruhdan yashirildi")
k("scdGroupShownToast", "Snackbar (teacher): card restored to the group.",
  "Card shown in the group again", "Карточка снова показывается в группе", "Karta guruhga qaytarildi")
k("scdHiddenSection", "Section header: cards the viewer hid.",
  "Hidden cards", "Скрытые карточки", "Yashirilgan kartalar")
k("scdHiddenItem", "Row title: a hidden card (no personal data shown).",
  "Hidden card", "Скрытая карточка", "Yashirilgan karta")
k("scdRestore", "Button: restore a hidden card.", "Restore", "Вернуть", "Qaytarish")
k("scdRestored", "Snackbar: card restored.", "Card restored", "Карточка возвращена", "Karta qaytarildi")

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

# Ilova ichidagi maxfiylik xulosasiga talaba kartasi haqida bir gap.
ADD = {
    "uz": " Talaba kartasini (ixtiyoriy) to‘ldirsangiz, undagi ism yoki taxallus, qisqa matn va rasm serverda saqlanadi va faqat siz a’zo bo‘lgan guruhlarning a’zolari va ustoziga, siz «Guruhdoshlarimga va ustozimga ko‘rsatish»ni yoqqan bo‘lsangina ko‘rinadi; karta ommaviy emas, unda havola yoki aloqa ma’lumoti bo‘lmaydi; nomaqbul kartaga shikoyat qilish va uni yashirish mumkin; kartani istalgan vaqtda o‘chirishingiz mumkin, hisob o‘chirilsa ham o‘chadi.",
    "ru": " Если вы заполните карточку студента (необязательно), имя или псевдоним, короткий текст и фото из неё хранятся на сервере и видны только участникам и преподавателю групп, в которых вы состоите, и только если вы включили «Показывать одногруппникам и преподавателю»; карточка не публичная, ссылок и контактов в ней нет; на неподобающую карточку можно пожаловаться и скрыть её; карточку можно удалить в любой момент, она удаляется и вместе с аккаунтом.",
    "en": " If you fill in the optional student card, its name or nickname, short text and photo are stored on the server and visible only to the members and the teacher of the groups you belong to, and only if you turned on «Show to my groupmates and teacher»; the card is not public and contains no links or contact details; an inappropriate card can be reported and hidden; you can delete the card at any time, and it is deleted with your account.",
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
