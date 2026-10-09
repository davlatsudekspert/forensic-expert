# «Giyohvand moddalar tahlili» (GMT) kartalari va savollari: muallif ruxsati
# bilan bepul manba atribusiyasi va o‘quv to‘plami nomi (2026-10-09).
# Idempotent. Ishga tushirish: apps/mobile ichida `python3 tool/l10n_gmt.py`,
# so‘ng `flutter gen-l10n` (tartib: CLAUDE.md «L10n skriptlari tartibi»).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
k("guidelineGmtAttribution", "Guideline detail / study deck: attribution for cards built on the drug-analysis teaching manual (free for everyone).",
  "Source: Yuldashev Z.A. et al., «Analysis of narcotic substances. Teaching manual» (Tashkent Pharmaceutical Institute, Tashkent, 2024) — used with the author’s permission, free for everyone.",
  "Источник: Юлдашев З.А. и соавт., «Анализ наркотических веществ. Учебное пособие» (Ташкентский фармацевтический институт, Ташкент, 2024) — с разрешения автора, бесплатно для всех.",
  "Manba: Yuldashev Z.A. va boshq., «Giyohvand moddalar tahlili. O‘quv qo‘llanma» (Toshkent farmatsevtika instituti, Toshkent, 2024) — muallif ruxsati bilan, barcha uchun bepul.")
k("studyDeckGmt", "Study deck title: questions on the drug-analysis teaching manual.",
  "Drug analysis (Yuldashev Z.A.)",
  "Анализ наркотических веществ (Юлдашев З.А.)",
  "Giyohvand moddalar tahlili (Yuldashev Z.A.)")
# Mavjud matn endi tahririyat yozgan (manbali) savollarni ham qamraydi.
k("studyIntro", "Hub banner.",
  "Every card and question is built from a record or guideline that already exists in the app, together with its source. Guideline questions are written by the editors from the card’s facts. Material that is still under expert review is labelled.",
  "Каждая карточка и вопрос построены из записи или руководства, уже имеющихся в приложении, вместе с источником. Вопросы к руководствам составлены редакцией по фактам карточки. Материал, ещё не прошедший экспертную проверку, отмечен.",
  "Har bir kartochka va savol ilovada mavjud yozuv yoki yo‘riqnomadan, uning manbasi bilan birga tuziladi. Yo‘riqnoma savollarini tahririyat karta faktlari asosida yozgan. Hali ekspert tekshiruvidan o‘tmagan material belgilab qo‘yilgan.")

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key, (desc, en, ru, uz, ph) in K.items():
        data[key] = (en, ru, uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = ph
            data["@" + key] = meta
    json.dump(data, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p, "a").write("\n")
print(len(K), "keys")
