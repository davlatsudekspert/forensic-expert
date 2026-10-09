# First-run, Home va Profil polish (2026-10-09): qisqa onboarding,
# rejimga mos tezkor amallar, sokin ishonch izohi, guruhlangan Profil.
# Idempotent: qayta ishga tushirilsa natija o‘zgarmaydi.
#   python3 tool/l10n_polish_home.py && flutter gen-l10n
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
I = {"type": "int"}

# --- Onboarding ---------------------------------------------------------------
k("onbStep","Onboarding progress label.","Step {current} of {total}","Шаг {current} из {total}","Qadam {current} / {total}",{"current":I,"total":I})
k("disclaimerIntroTitle","Onboarding disclaimer headline.","Before you start","Прежде чем начать","Boshlashdan oldin")
k("disclaimerPointReference","Disclaimer summary point.","A scientific reference and learning tool — it never issues expert conclusions.","Научный справочник и учебный инструмент — экспертных заключений не выдаёт.","Ilmiy ma’lumotnoma va o‘quv vositasi — ekspert xulosasini bermaydi.")
k("disclaimerPointLab","Disclaimer summary point.","It does not replace validated lab methods, protocols, the law or a specialist’s judgement.","Не заменяет валидированные методики, протоколы, закон и мнение специалиста.","Validatsiyadan o‘tgan usullar, protokollar, qonun va mutaxassis fikrining o‘rnini bosmaydi.")
k("disclaimerPointMedical","Disclaimer summary point.","For medical questions, consult a qualified doctor.","По медицинским вопросам обращайтесь к квалифицированному врачу.","Tibbiy savollar bo‘yicha malakali shifokorga murojaat qiling.")
k("disclaimerFullText","Expandable full disclaimer.","Full text","Полный текст","To‘liq matn")
k("modeProfessionalDescription","Mode card description (short).","Forensic experts, physicians, toxicologists, chemists and lab specialists","Судебные эксперты, врачи, токсикологи, химики и специалисты лабораторий","Sud ekspertlari, shifokorlar, toksikologlar, kimyogarlar va laboratoriya mutaxassislari")
k("accountReadyTitle","Last onboarding step title.","You’re all set","Всё готово","Hammasi tayyor")
k("accountReadyBody","Last onboarding step body.","The scientific database, search and calculators work offline — no account needed.","Научная база, поиск и калькуляторы работают офлайн — аккаунт не нужен.","Ilmiy baza, qidiruv va kalkulyatorlar oflayn ishlaydi — hisob shart emas.")
k("accountStartNow","Primary button: open the app without an account.","Start","Начать","Boshlash")
k("accountBenefitsNote","What an account adds (one line).","An account adds professional verification, sync and cloud AI. You can sign in any time in Profile.","Аккаунт добавляет профессиональное подтверждение, синхронизацию и облачный ИИ. Войти можно в любой момент в Профиле.","Hisob professional tasdiq, sinxronlash va bulutli AI imkonini beradi. Istalgan vaqtda Profil bo‘limida kirish mumkin.")

# --- Home -----------------------------------------------------------------------
k("homeGreetingStudent","Home headline, student mode.","What shall we study today?","Что изучим сегодня?","Bugun nimani o‘rganamiz?")
k("homeGreetingExpert","Home headline, professional mode.","What are you working on today?","Над чем работаете сегодня?","Bugun nima ustida ishlaysiz?")
k("homeAreasTitle","Home section: subject areas.","Areas","Разделы","Bo‘limlar")
k("homeActLearnTitle","Quick action.","Study & quizzes","Учёба и тесты","O‘qish va testlar")
k("homeActLearnBody","Quick action hint.","Flashcards, quizzes, exam practice","Карточки, тесты, экзамен","Kartochkalar, testlar, imtihon")
k("homeActGuidelinesBody","Quick action hint.","Practical guidance by discipline","Практические руководства по дисциплинам","Fanlar bo‘yicha amaliy yo‘riqlar")
k("homeActSubstancesBody","Quick action hint.","Properties, analysis, sources","Свойства, анализ, источники","Xossalar, tahlil, manbalar")
k("homeActMethodsBody","Quick action hint.","Analytical methods, sample prep","Методы анализа, пробоподготовка","Tahlil usullari, namuna tayyorlash")
k("homeActToolsTitle","Quick action.","Calculators","Калькуляторы","Kalkulyatorlar")
k("homeActToolsBody","Quick action hint.","Lab and forensic calculations","Лабораторные и экспертные расчёты","Laboratoriya va ekspertiza hisoblari")
k("homeActAiBody","Quick action hint.","Ask a question — answers cite sources","Задайте вопрос — ответ со ссылками","Savol bering — javob manbalar bilan")
k("homeAllDisciplinesCount","Card hint: number of disciplines.","{count, plural, one{{count} discipline} other{{count} disciplines}}","{count, plural, one{{count} дисциплина} few{{count} дисциплины} many{{count} дисциплин} other{{count} дисциплины}}","{count} ta fan",{"count":I})
k("homeTrustNote","Calm one-line honesty note at the bottom of Home.","Database under expert review · every entry shows its source and status","База на экспертной проверке · у каждой записи указаны источник и статус","Baza ekspert tekshiruvida · har bir yozuvda manba va holat ko‘rsatiladi")

# --- Profil -----------------------------------------------------------------------
k("profileSignInBody","Signed-out account card hint.","Sync, verification and cloud AI. No password needed.","Синхронизация, подтверждение и облачный ИИ. Пароль не нужен.","Sinxronlash, tasdiq va bulutli AI. Parol shart emas.")
k("profileSectionHelp","Profile section.","Help and community","Помощь и сообщество","Yordam va hamjamiyat")
k("profileSectionAppearance","Profile section.","Appearance","Оформление","Ko‘rinish")

for idx, code in enumerate(["en","ru","uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key,(desc,en,ru,uz,ph) in K.items():
        data[key] = (en,ru,uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph: meta["placeholders"] = ph
            data["@"+key] = meta
    with open(p, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")
print(len(K), "keys")
