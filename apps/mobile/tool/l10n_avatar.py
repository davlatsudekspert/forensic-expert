#!/usr/bin/env python3
"""Profil rasmi (avatar) matnlari (uz/ru/en). Rasm faqat telefonda saqlanadi."""
import json, pathlib
ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"
K = {
 "avatarSemantics": ("Profil rasmi", "Фото профиля", "Profile photo", "Semantics label of the profile photo."),
 "avatarChange": ("Rasmni o‘zgartirish", "Изменить фото", "Change photo", "Sheet title / action for changing the profile photo."),
 "avatarChoose": ("Galereyadan tanlash", "Выбрать из галереи", "Choose from gallery", "Action: pick a photo from the gallery."),
 "avatarView": ("Kattalashtirib ko‘rish", "Увеличить", "View larger", "Action: show the profile photo enlarged."),
 "avatarRemove": ("Rasmni olib tashlash", "Удалить фото", "Remove photo", "Action: remove the profile photo."),
 "avatarCropTitle": ("Rasmni moslash", "Настройка фото", "Adjust photo", "Title of the crop screen."),
 "avatarCropHint": ("Suring va barmoqlar bilan yaqinlashtiring", "Двигайте и увеличивайте пальцами", "Drag and pinch to zoom", "Hint on the crop screen."),
 "avatarSave": ("Saqlash", "Сохранить", "Save", "Save button on the crop screen."),
 "avatarCancel": ("Bekor qilish", "Отмена", "Cancel", "Cancel button on the crop screen."),
 "avatarDeviceOnly": ("Rasm faqat shu telefonda saqlanadi, serverga yuborilmaydi.", "Фото хранится только на этом телефоне и не отправляется на сервер.", "The photo stays on this phone only and is never sent to a server.", "Privacy note under the avatar actions."),
 "avatarError": ("Rasmni ochib bo‘lmadi. Boshqa rasm tanlang.", "Не удалось открыть фото. Выберите другое.", "Could not open the photo. Choose another one.", "Error when the chosen image cannot be read."),
}
for i, lang in enumerate(("uz", "ru", "en")):
    p = ARB / f"app_{lang}.arb"; d = json.loads(p.read_text(encoding="utf-8"))
    for k, v in K.items():
        d.setdefault(k, v[i])
        if lang == "en": d.setdefault("@" + k, {"description": v[3]})
    p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("ok")

# Maxfiylik xulosasiga bir gap: profil rasmi faqat qurilmada.
ADD = {"uz": " Profil rasmingiz (agar qo‘ysangiz) faqat shu qurilmada saqlanadi.",
       "ru": " Фото профиля (если вы его задали) хранится только на этом устройстве.",
       "en": " Your profile photo (if you set one) stays on this device only."}
for lang in ("uz", "ru", "en"):
    p = ARB / f"app_{lang}.arb"; d = json.loads(p.read_text(encoding="utf-8"))
    s = d["privacySummary"]
    if ADD[lang].strip() not in s:
        marker = "\n\n"
        i = s.index(marker)
        d["privacySummary"] = s[:i] + ADD[lang] + s[i:]
        p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("privacy ok")

BK = {
 "bookMethodsTitle": ("Kitob qo‘llanmasi bo‘yicha usullar", "Методы по руководствам и учебникам", "Methods from the textbooks and manuals", "Heading of the textbook-methods block on the substance analysis tab."),
 "bookMethodsNote": ("Tekshirish usullari tasdiqlangan manbadan (ustoz kitobi va qo‘llanmalar): rangli reaksiyalar, mikrokristall, TLC, UB spektr, tasdiqlovchi usul. Har yozuvda to‘liq tavsif, manba va aniq joyi bor.", "Методы исследования из подтверждённых источников (книги преподавателя и пособия): цветные реакции, микрокристаллоскопия, TLC, УФ-спектр, подтверждающий метод. В каждой записи — полное описание, источник и точное место.", "Analytical methods from confirmed sources (the teacher's books and manuals): colour tests, microcrystal tests, TLC, UV spectrum, confirmatory method. Each entry gives the full description, source and exact place.", "Note under the textbook-methods heading."),
}
for i, lang in enumerate(("uz", "ru", "en")):
    p = ARB / f"app_{lang}.arb"; d = json.loads(p.read_text(encoding="utf-8"))
    for k, v in BK.items():
        d.setdefault(k, v[i])
        if lang == "en": d.setdefault("@" + k, {"description": v[3]})
    p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("book ok")

XT = {
 "extraInfoTitle": ("Qo‘shimcha ma’lumot: ilmiy maqola, tezis, adabiyot", "Дополнительно: научные статьи, тезисы, литература", "Additional information: articles, theses, literature", "Heading of the third layer on the analysis tab."),
 "extraInfoNote": ("Bu qism xalqaro manbalardan (SWGDRUG, UNODC, maqola, tezis). Asosiy manba emas — tasdiqlash kerak. GC-MS, LC-MS/MS usullari va sud-tibbiy holatlar pastdagi «Xalqaro ilmiy qatlam»da.", "Эта часть — из международных источников (SWGDRUG, UNODC, статьи, тезисы). Не основной источник — требует подтверждения. Методы GC-MS, LC-MS/MS и судебно-медицинские случаи — ниже, в «Международном научном слое».", "This part comes from international sources (SWGDRUG, UNODC, articles, theses). Not a primary source — needs confirmation. GC-MS and LC-MS/MS methods and forensic cases are in the international scientific layer below.", "Note explaining the literature layer."),
 "litClaimsTitle": ("Adabiyotdagi dalillar (to‘liq)", "Данные из литературы (полностью)", "Evidence from the literature (in full)", "Heading of the full literature claims list."),
}
for i, lang in enumerate(("uz", "ru", "en")):
    p = ARB / f"app_{lang}.arb"; d = json.loads(p.read_text(encoding="utf-8"))
    for k, v in XT.items():
        d.setdefault(k, v[i])
        if lang == "en": d.setdefault("@" + k, {"description": v[3]})
    p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("xt ok")
