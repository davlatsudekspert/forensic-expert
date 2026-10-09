# UX audit (TestFlight oldidan): soddalashtirish, terminologiya va yangi
# kalitlar. Idempotent — qiymatlarni o‘rnatadi; merge’dan keyin qayta
# ishga tushirilsa, shu qiymatlar tiklanadi.
# Ishga tushirish: apps/mobile ichida `python3 tool/l10n_ux_audit.py`, so‘ng
# `flutter gen-l10n`.
import collections
import json
import re

D = "lib/core/l10n/arb"
LANGS = ["en", "ru", "uz"]

# --- 1. Yangi kalitlar (tavsif + placeholder bilan) -------------------------
NEW = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    NEW[key] = (desc, en, ru, uz, ph)


S = {"type": "String"}
I = {"type": "int"}
k("notFoundTitle", "Router error page title.", "Page not found", "Страница не найдена", "Sahifa topilmadi")
k("notFoundBody", "Router error page body.", "The link may be outdated or incorrect.", "Ссылка могла устареть или быть неверной.", "Havola eskirgan yoki noto‘g‘ri bo‘lishi mumkin.")
k("notFoundHome", "Router error page action.", "Go to Home", "На главную", "Bosh sahifaga")
k("accountSignInEmailCode", "Single sign-in row / action (email one-time code).", "Sign in (email code)", "Войти (код по почте)", "Kirish (email kod)")
k("toolsReviewNote", "One note at the top of the Tools screen (replaces per-tile chips).", "Calculation modules are software-tested. Formulas and their sources have not yet been confirmed by an expert.", "Расчётные модули протестированы программно. Формулы и их источники ещё не подтверждены экспертом.", "Hisoblash modullari dasturiy sinovdan o‘tgan. Formulalar va ularning manbalari hali ekspert tomonidan tasdiqlanmagan.")
k("searchAllStatus", "One line above search results when every result has the same review status.", "All results: {status}", "Все результаты: {status}", "Barcha natijalar: {status}", {"status": S})
k("researchOpenInBrowser", "Open a research link in the browser.", "Open", "Открыть", "Ochish")
k("disciplinesComingSoon", "Collapsed group of disciplines without records.", "Coming soon ({count})", "Скоро ({count})", "Tez orada ({count})", {"count": I})
k("modeRoleExpand", "Collapsed role picker on the mode screen.", "Choose a role (optional)", "Выбрать роль (необязательно)", "Rolni tanlash (ixtiyoriy)")
k("sourcesEmpty", "Sources list empty state.", "No sources are available yet.", "Источников пока нет.", "Hozircha manbalar yo‘q.")

# --- 2. Mavjud kalitlar: qiymatlarni o‘rnatish (None — o‘zgartirilmaydi) ---
SET = collections.OrderedDict()


def s(key, en=None, ru=None, uz=None):
    SET[key] = (en, ru, uz)


# 6. Profil eslatmasi — tasdiqlashga yuborilganda serverga jo‘natiladi.
s("profileLocalOnlyNote",
  en="Your profile is stored on this device. It is sent to the server only when you submit it for verification.",
  ru="Профиль хранится на этом устройстве. На сервер он отправляется, только когда вы подаёте его на подтверждение.",
  uz="Profil shu qurilmada saqlanadi. Faqat tasdiqlashga yuborganingizda serverga jo‘natiladi.")
# 12. Sokin, oddiy registr.
s("unverifiedBanner", en="Not yet confirmed by an expert", ru="Информация ещё не подтверждена экспертом", uz="Ma’lumot hali ekspert tomonidan tasdiqlanmagan")
s("provNotVerified", en="Not yet confirmed by an expert", ru="Информация ещё не подтверждена экспертом", uz="Ma’lumot hali ekspert tomonidan tasdiqlanmagan")
# 22.
s("inDevelopmentBody", en="No reviewed information has been added to this section yet.", ru="В этот раздел ещё не добавлена проверенная информация.", uz="Bu bo‘limga hali tekshirilgan ma’lumot qo‘shilmagan.")
# 23. «Bu yig‘mada…», «Ishchi AI xizmati», «interfeys namoyishi».
s("aiNotConnectedTitle", en="AI is temporarily unavailable", ru="ИИ временно недоступен", uz="AI vaqtincha ishlamayapti")
s("aiStatusPreview", en="Not available yet", ru="Пока недоступно", uz="Hozircha mavjud emas")
s("aiPreviewPoint1", en="No AI answers are generated right now.", ru="Сейчас ответы ИИ не формируются.", uz="Hozircha AI javobi yaratilmaydi.")
s("aiPreviewPoint2", en="This is temporary; the rest of the app works offline.", ru="Это временно; остальная часть приложения работает офлайн.", uz="Bu vaqtinchalik; ilovaning qolgan qismi oflayn ishlaydi.")
s("aiPreviewPoint3", en="The sample below only shows how an answer is laid out.", ru="Пример ниже лишь показывает, как устроен ответ.", uz="Quyidagi namuna faqat javob qanday tuzilishini ko‘rsatadi.")
s("aiPreviewTitle", uz="Javob tuzilmasi (namuna)")
s("aiSendUnavailable", en="AI is temporarily unavailable — sending is disabled.", ru="ИИ временно недоступен — отправка отключена.", uz="AI vaqtincha ishlamayapti — yuborish o‘chirilgan.")
s("accountNotConnected", uz="Hisob xizmati hozircha mavjud emas. Barcha oflayn funksiyalar ishlaydi.")
s("authErrNotConfigured", uz="Hisob xizmati hozircha mavjud emas.")
s("storeNotConnected", uz="App Store / Google Play hozircha mavjud emas. Narx va xarid faqat do‘kon bergandagina paydo bo‘ladi.")
s("purchaseUnavailableSnack", uz="Xarid hozircha mavjud emas.")
s("libraryNotInstalled", uz="Ilmiy baza hozircha o‘rnatilmagan.")
# 24.
s("reviewExplain", ru="Утверждение становится ПОДТВЕРЖДЁННЫМ только после одобрения текущей версии двумя независимыми квалифицированными рецензентами по специальности. Приложение и его авторы не могут сами отметить что-либо как проверенное.",
  uz="Da’vo faqat o‘z sohasidagi ikki mustaqil malakali taqrizchi joriy versiyani tasdiqlagandan keyin TASDIQLANGAN bo‘ladi. Ilova va uning mualliflari hech narsani o‘zlari tasdiqlangan deb belgilay olmaydi.")
s("detailIdentifierVerified", en="DOI/PMID checked automatically", ru="DOI/PMID проверены автоматически", uz="DOI/PMID avtomatik tekshirilgan")
s("detailTranslationDraft", en="Names are machine-translated and not yet reviewed", ru="Названия переведены автоматически и ещё не проверены", uz="Nomlar avtomatik tarjima qilingan, hali tekshirilmagan")
# 25. Elektron pochta (gap ichida).
s("accountVerified", uz="Elektron pochta tasdiqlangan")
s("accountNotVerified", uz="Elektron pochta tasdiqlanmagan")
s("accountVerifyNow", uz="Elektron pochtani tasdiqlash")
s("accountMinimalData", uz="Faqat elektron pochta so‘raladi. Kasbiy, ish bo‘yicha yoki shaxsiy ma’lumot yig‘ilmaydi.")
s("pwRuleNotEmail", uz="Elektron pochta bilan bir xil emas")
s("verifyTitle", uz="Elektron pochtani tasdiqlang")
s("verifyBody", uz="{email} manziliga {n} xonali kod yubordik. Hisobni faollashtirish uchun uni kiriting.")
s("verifyDone", uz="Elektron pochta tasdiqlandi. Hisobingiz faol.")
s("forgotBody", uz="Hisobingiz elektron pochtasini kiriting. Agar hisob mavjud bo‘lsa, tiklash kodini yuboramiz.")
s("forgotSent", uz="Bu elektron pochta uchun hisob mavjud bo‘lsa, tiklash kodi yuborildi. U {minutes} daqiqa amal qiladi.")
s("authErrInvalidEmail", uz="To‘g‘ri elektron pochta manzilini kiriting.")
s("authErrCredentials", uz="Elektron pochta yoki parol noto‘g‘ri.")
s("authErrNotVerified", uz="Elektron pochta hali tasdiqlanmagan. Yuborilgan kodni kiriting.")
s("authErrAlreadyVerified", uz="Bu elektron pochta allaqachon tasdiqlangan. Kirishingiz mumkin.")
s("emailCodeTitle", uz="Elektron pochta kodi orqali kirish")
s("emailCodeRowHint", uz="Elektron pochtangizga 6 xonali kod yuboriladi — parol shart emas")
s("emailCodeSubtitle", uz="Elektron pochtangizni kiriting. FORENSIC EXPERT bir martalik 6 xonali tasdiqlash kodini yuboradi.")
s("emailCodeChange", uz="Elektron pochtani o‘zgartirish")
s("emailCodeNotProfessional", uz="Elektron pochtani tasdiqlash hisobga kirishni ta’minlaydi. U mutaxassis maqomini tasdiqlamaydi.")
s("emailCodeSignedIn", uz="Elektron pochta tasdiqlandi. Hisobga kirdingiz.")
s("referralPrivacyNote", uz="Faqat umumiy sonlar ko‘rsatiladi. Hamkasblaringizning ismi, elektron pochtasi, profili va hujjatlari hech qachon ulashilmaydi — na sizga, na taklifda.")
s("referralSignInBody", uz="Shaxsiy kod elektron pochta orqali kirganingizdan so‘ng serverda yaratiladi. Barcha ilmiy ma’lumotlar hisobsiz ham ochiq.")
s("referralClaimPending", uz="Taklif saqlandi. Elektron pochta tasdiqlangach kuchga kiradi.")
s("adminConfirmed", uz="Elektron pochta tasdiqlangan")
s("adminPrivacyNote", uz="Shaxsiy ma’lumot (elektron pochta) bor. Skrinshotlarni tarqatmang.")
s("adminEmail", uz="Foydalanuvchi elektron pochtasi")
s("adminNotFound", uz="Bunday elektron pochtali foydalanuvchi yo‘q.")
# 26. SOP bir marta izohlanadi.
s("moduleMethods", uz="Usullar va SOP")
s("methodKindSop", en="Institutional SOPs (standard operating procedures)", ru="СОП учреждений (стандартные операционные процедуры)", uz="Muassasa SOP’lari (standart ish tartiblari)")
# 27. Holat atamalari.
s("statusNeedsReview", uz="Tekshirilmagan")
s("lcNeedsReview", uz="Tekshirilmagan")
s("moduleHubSourcedNote", uz="Manbasi va joriy tekshiruv holati bilan ko‘rsatiladi. «Tekshirilmagan» — mavjud manbali ma’lumot ekspert tekshiruvini kutmoqda degani, ma’lumot yo‘q degani emas.")
s("homeStatHumanVerified", en="Expert verified", uz="Ekspertlar tasdiqlagan")
s("homeStatPolicy", en="Expert verified = two independent qualified experts. Automated checks and AI are never counted.", uz="«Ekspertlar tasdiqlagan» = ikki mustaqil malakali ekspert. Avtomatik tekshiruv va AI hisoblanmaydi.")
s("homeDbHumanVerified", en="Expert verified (2 independent experts): {count}", ru="Подтверждено экспертами (2 независимых эксперта): {count}", uz="Ekspertlar tasdiqlagan (2 mustaqil ekspert): {count}")
# 29.
s("learnBookmarks", en="Favorites", ru="Избранное", uz="Saralanganlar")
s("learnBookmarksEmpty", en="Mark a topic with the star to find it here.", ru="Отметьте тему звёздочкой, чтобы найти её здесь.")
# 30. AI uslubi.
s("aiExperienceProfessional", en="Short answer", ru="Коротко", uz="Qisqa javob")
s("aiExperienceTutor", en="Explain it to me", ru="Объясните подробно", uz="Tushuntirib bering")
# 33.
s("tierStudentPro", uz="Talaba Pro")
s("tierProfessionalPro", uz="Mutaxassis Pro")
# 35. Qisqaroq hisoblagich.
s("emailCodeResendIn", en="Resend ({seconds})", ru="Повторить ({seconds})", uz="Qayta yuborish ({seconds})")

# --- 3. Uzbek terminologiya: butun fayl bo‘yicha (idempotent) -------------
UZ_SUBS = [
    # 25. «akkaunt» → «hisob».
    (r"akkaunt", "hisob"),
    (r"Akkaunt", "Hisob"),
    # 25. «email» gap ichida → «elektron pochta» (placeholder’larga tegmaydi).
    (r"\bemailingizning\b", "elektron pochtangizning"),
    (r"\bemailingiz\b", "elektron pochtangiz"),
    (r"\(email,", "(elektron pochta,"),
    # 26. «metod» → «usul» («metodika» — alohida atama, o‘zgarmaydi).
    (r"\bmetod(?!ika)", "usul"),
    (r"\bMetod(?!ika)", "Usul"),
    (r"\bMETOD\b", "USUL"),
    # 33.
    (r"Student Pro", "Talaba Pro"),
    (r"Professional Pro", "Mutaxassis Pro"),
]


def main():
    for idx, code in enumerate(LANGS):
        p = f"{D}/app_{code}.arb"
        with open(p, encoding="utf-8") as f:
            data = json.load(f, object_pairs_hook=collections.OrderedDict)
        for key, (desc, en, ru, uz, ph) in NEW.items():
            data[key] = (en, ru, uz)[idx]
            if code == "en":
                meta = {"description": desc}
                if ph:
                    meta["placeholders"] = ph
                data["@" + key] = meta
        for key, vals in SET.items():
            if key not in data:
                raise SystemExit(f"missing key {key} in {p}")
            v = vals[idx]
            if v is not None:
                data[key] = v
        if code == "uz":
            for key in list(data.keys()):
                v = data[key]
                if key.startswith("@") or not isinstance(v, str):
                    continue
                for rx, rep in UZ_SUBS:
                    v = re.sub(rx, rep, v)
                data[key] = v
        with open(p, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
    print(len(NEW), "new keys,", len(SET), "updated keys")


if __name__ == "__main__":
    main()
