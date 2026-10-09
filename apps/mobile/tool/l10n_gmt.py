# «Giyohvand moddalar tahlili» (GMT) kartalari, test savollari va
# muallif ruxsati bilan bepul manba atribusiyasi (2026-10-09).
# Idempotent. Ishga tushirish: apps/mobile ichida `python3 tool/l10n_gmt.py`,
# so‘ng `flutter gen-l10n` (tartib: CLAUDE.md «L10n skriptlari tartibi»).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
k("guidelineAuthorPermissionFree", "Guideline detail: attribution line for cards built on an author-permitted source (free for everyone).",
  "Source: {author} et al., «{title}», {year} — used with the author's permission, free for everyone.",
  "Источник: {author} и др., «{title}», {year} — с разрешения автора, бесплатно для всех.",
  "Manba: {author} va boshq., «{title}», {year} — muallif ruxsati bilan, barcha uchun bepul.",
  {"author": S, "title": S, "year": S})
k("studyFrontGuidelineQuiz", "Flashcard front hint for a guideline question.",
  "Recall the answer, then flip the card",
  "Вспомните ответ, затем переверните карточку",
  "Javobni eslang, so‘ng kartochkani aylantiring")
# Mavjud matnlar endi tahririyat yozgan (manbali) savollarni ham qamraydi.
k("studyIntro", "Hub banner.",
  "Every card and question is built from a record or guideline that already exists in the app, together with its source. Guideline questions are written by the editors from the card's facts. Material that is still under expert review is labelled.",
  "Каждая карточка и вопрос построены из записи или руководства, уже имеющихся в приложении, вместе с источником. Вопросы к руководствам составлены редакцией по фактам карточки. Материал, ещё не прошедший экспертную проверку, отмечен.",
  "Har bir kartochka va savol ilovada mavjud yozuv yoki yo‘riqnomadan, uning manbasi bilan birga tuziladi. Yo‘riqnoma savollarini tahririyat karta faktlari asosida yozgan. Hali ekspert tekshiruvidan o‘tmagan material belgilab qo‘yilgan.")
k("studyQuizNote", "Quiz banner.",
  "Wrong options are other records of the same type from the app or, for guideline questions, options set by the editors on the card; every question shows its source.",
  "Неверные варианты — другие записи того же типа из приложения или, для вопросов к руководствам, варианты, заданные редакцией в карточке; у каждого вопроса указан источник.",
  "Noto‘g‘ri variantlar — ilovadagi shu turdagi boshqa yozuvlar yoki yo‘riqnoma savollarida tahririyat kartada belgilagan variantlar; har bir savolning manbasi ko‘rsatiladi.")

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
