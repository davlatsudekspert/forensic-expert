// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'FORENSIC EXPERT';

  @override
  String get appTagline => 'Dalil · Fan · Aniqlik';

  @override
  String get languageNameNative => 'O‘zbekcha';

  @override
  String get chooseLanguageTitle => 'Tilni tanlang';

  @override
  String languageOptionSemantics(String language, String state) {
    return '$language. $state';
  }

  @override
  String get stateSelected => 'Tanlangan';

  @override
  String get stateNotSelected => 'Tanlanmagan';

  @override
  String get actionContinue => 'Davom etish';

  @override
  String get actionBack => 'Orqaga';

  @override
  String get disclaimerTitle => 'Ilmiy ogohlantirish';

  @override
  String get disclaimerBody =>
      'Forensic Expert professional ma’lumotnoma, ta’lim va ilmiy hisob-kitoblar uchun mo‘ljallangan. U validatsiyadan o‘tgan laboratoriya usullari, muassasa protokollari, amaldagi qonunchilik va malakali mutaxassis xulosasining o‘rnini bosmaydi.';

  @override
  String get disclaimerNoConclusions =>
      'Ilova hech qachon ekspert xulosasini bermaydi. O‘lchangan konsentratsiyaning o‘zi o‘lim sababini isbotlamaydi. Yakuniy professional xulosa malakali mutaxassisga tegishli.';

  @override
  String get disclaimerConsult =>
      'Tibbiy maslahat, tashxis yoki davolash uchun malakali tibbiyot mutaxassisiga murojaat qiling.';

  @override
  String get disclaimerAccept => 'Tushundim';

  @override
  String get modeTitle => 'FORENSIC EXPERT’dan qanday foydalanasiz?';

  @override
  String get modeSubtitle =>
      'Bosh ekran tanlovingizga moslashadi. Keyinroq Profil bo‘limida o‘zgartirish mumkin.';

  @override
  String get modeProfessional => 'Mutaxassis';

  @override
  String get modeProfessionalDescription =>
      'Sud ekspertlari, shifokorlar, toksikologlar, kimyogarlar va laboratoriya mutaxassislari';

  @override
  String get modeStudent => 'Talaba';

  @override
  String get modeStudentDescription =>
      'Talabalar, rezidentlar va stajyorlar, tadqiqotchilar va o‘rganuvchilar';

  @override
  String get modeResearch => 'Tadqiqot / ta’lim';

  @override
  String get modeResearchDescription => 'Ilmiy kutubxona, manbalar va o‘qitish';

  @override
  String get navHome => 'Asosiy';

  @override
  String get navTools => 'Vositalar';

  @override
  String get navLibrary => 'Kutubxona';

  @override
  String get navAi => 'AI';

  @override
  String get navProfile => 'Profil';

  @override
  String get searchHint =>
      'Moddalar, usullar, vositalar va manbalarni qidiring…';

  @override
  String get searchUnavailable =>
      'Qidiruv tekshirilgan ilmiy baza o‘rnatilgandan keyin ishlaydi.';

  @override
  String get moduleForensicMedicine => 'Sud tibbiyoti';

  @override
  String get moduleToxicology => 'Sud toksikologiyasi';

  @override
  String get moduleLaboratory => 'Laboratoriya';

  @override
  String get moduleSubstances => 'Moddalar kutubxonasi';

  @override
  String get moduleLearn => 'Ta’lim';

  @override
  String get moduleAi => 'Forensic AI';

  @override
  String get homeModulesHeading => 'Modullar';

  @override
  String get inDevelopmentTitle =>
      'Ko‘rsatish uchun tekshirilgan ma’lumot yo‘q';

  @override
  String get inDevelopmentBody =>
      'Bu bo‘limga hali tekshirilgan ma’lumot qo‘shilmagan.';

  @override
  String get unverifiedBanner =>
      'Ma’lumot hali ekspert tomonidan tasdiqlanmagan';

  @override
  String get statusVerified => 'Tasdiqlangan';

  @override
  String get statusReviewed => 'Ko‘rib chiqilgan';

  @override
  String get statusNeedsReview => 'Tekshirilmagan';

  @override
  String get statusOutdated => 'Eskirgan';

  @override
  String get aiNotConnectedTitle => 'AI vaqtincha ishlamayapti';

  @override
  String get aiNotConnectedBody =>
      'Forensic AI faqat tekshirilgan ichki bilimlar bazasi asosida javob beradi, har doim manbalarni ko‘rsatadi va hech qachon ekspert xulosasini bermaydi. Asosiy kutubxona va kalkulyatorlar AI’siz ishlaydi.';

  @override
  String get aiPiiWarning =>
      'Ism-familiya, ish raqami, pasport ma’lumotlari, telefon raqami, manzil yoki boshqa shaxsiy ma’lumotlarni kiritmang.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get settingsLanguage => 'Til';

  @override
  String get settingsTheme => 'Ko‘rinish';

  @override
  String get themeSystem => 'Tizim';

  @override
  String get themeLight => 'Yorug‘';

  @override
  String get themeDark => 'Qorong‘i';

  @override
  String get settingsMode => 'Foydalanish rejimi';

  @override
  String get scientificDatabaseLabel => 'Ilmiy baza';

  @override
  String get scientificDatabaseNotInstalled => 'Hali o‘rnatilmagan';

  @override
  String get appVersionLabel => 'Ilova versiyasi';

  @override
  String get legalSection => 'Huquqiy va xavfsizlik';

  @override
  String get scientificDisclaimerLink => 'Ilmiy ogohlantirish';

  @override
  String get diagnosticsSection => 'Diagnostika';

  @override
  String diagnosticsStartup(int ms) {
    return 'Birinchi kadrgacha: $ms ms';
  }

  @override
  String diagnosticsSettingsLoad(int ms) {
    return 'Sozlamalarni yuklash: $ms ms';
  }

  @override
  String get diagnosticsNotMeasured => 'O‘lchanmagan';

  @override
  String get toolsTitle => 'Vositalar';

  @override
  String get libraryTitle => 'Kutubxona';

  @override
  String get homeQuickAccess => 'Tezkor kirish';

  @override
  String get homeRecentTools => 'So‘nggi vositalar';

  @override
  String get homeFavorites => 'Saralanganlar';

  @override
  String get homeRecentSearches => 'So‘nggi qidiruvlar';

  @override
  String get homeEmptyRecentTools =>
      'Siz ochgan vositalar shu yerda ko‘rinadi.';

  @override
  String get homeEmptyFavorites =>
      'Vosita yoki kutubxona yozuvlarini saralanganlarga qo‘shing — ular shu yerda turadi.';

  @override
  String get homeEmptyRecentSearches =>
      'Qidiruvlaringiz faqat shu qurilmada saqlanadi.';

  @override
  String get homeContinueLearning => 'O‘qishni davom ettirish';

  @override
  String get homeStudyHubBody =>
      'Kurslar, testlar, kartochkalar va holatlar tahlili.';

  @override
  String get homePrototypeNotice =>
      'Namoyish yig‘masi: NAMUNA belgili yozuvlar faqat tasviriy, ilmiy ma’lumot emas.';

  @override
  String get testDataBadge => 'NAMUNA';

  @override
  String get seeAll => 'Barchasi';

  @override
  String get openAction => 'Ochish';

  @override
  String get toolsSubtitle =>
      'Formula, taxminlar va cheklovlar ko‘rsatilgan kalkulyator va konversiyalar.';

  @override
  String get toolCategoryToxicology => 'Toksikologiya';

  @override
  String get toolCategoryConversions => 'Birlik konversiyalari';

  @override
  String get toolDilutionName => 'Suyultirish (C₁V₁ = C₂V₂)';

  @override
  String get toolDilutionDesc =>
      'Suyultirishning to‘rtta qiymatidan istalgan birini hisoblash.';

  @override
  String get toolWidmarkName => 'Qondagi alkogol (Widmark)';

  @override
  String get toolWidmarkDesc =>
      'Taxminlar, noaniqlik va cheklovlar ko‘rsatilgan holda baholash.';

  @override
  String get toolBackCalcName => 'Etanolni teskari hisoblash';

  @override
  String get toolBackCalcDesc =>
      'Oldingi vaqt nuqtasi uchun diapazonli baholash.';

  @override
  String get toolPmiName =>
      'O‘limdan keyin o‘tgan vaqt oralig‘i (PMI) — Henssge';

  @override
  String get toolPmiDesc =>
      'Rektal harorat nomogrammasi (Henssge): 95 % chegarali baho.';

  @override
  String get toolMolarityName => 'Molyarlik va massa konsentratsiyasi';

  @override
  String get toolMolarityDesc =>
      'Tortilgan massa, molyar massa va hajmdan molyar konsentratsiya.';

  @override
  String get toolCalibrationName => 'Kalibrlash va chiziqli regressiya';

  @override
  String get toolCalibrationDesc =>
      'Kalibrlash egri chizig‘i, qoldiqlar va moslik statistikasi.';

  @override
  String get toolLodName => 'LOD / LOQ';

  @override
  String get toolLodDesc =>
      'Kalibrlash ma’lumotlari asosida aniqlash va miqdoriy aniqlash chegaralari.';

  @override
  String get toolStatsName => 'Tavsifiy statistika';

  @override
  String get toolStatsDesc => 'O‘rtacha, mediana, SD va CV.';

  @override
  String get toolUnitsName => 'Konsentratsiya birliklari konvertori';

  @override
  String get toolUnitsDesc =>
      'mg/L, µg/mL, ng/mL, mmol/L; berilgan molyar massa bilan massa ↔ molyar.';

  @override
  String get toolEthanolUnitsName => 'Etanol birliklari konvertori';

  @override
  String get toolEthanolUnitsDesc => 'g/L, ‰, mg/dL va g/100 mL.';

  @override
  String get toolStatusAvailable => 'Mavjud';

  @override
  String get toolStatusPlanned => 'Rejalashtirilgan';

  @override
  String get toolPlannedBody =>
      'Bu vosita rejalashtirilgan. U faqat usul, formula va manbalar ekspert tekshiruvidan o‘tgandan keyin qo‘shiladi.';

  @override
  String get favoriteAdd => 'Saralanganlarga qo‘shish';

  @override
  String get favoriteRemove => 'Saralanganlardan olib tashlash';

  @override
  String get calcInput => 'Kiritiladigan qiymatlar';

  @override
  String get calcMethod => 'Usul';

  @override
  String get calcFormula => 'Formula';

  @override
  String get calcResult => 'Natija';

  @override
  String get calcAssumptions => 'Taxminlar';

  @override
  String get calcLimitations => 'Cheklovlar';

  @override
  String get calcReferences => 'Manbalar';

  @override
  String get calcSolveFor => 'Topiladigan qiymat';

  @override
  String get calcStockConc => 'Boshlang‘ich konsentratsiya (C₁)';

  @override
  String get calcStockVol => 'Boshlang‘ich eritma hajmi (V₁)';

  @override
  String get calcFinalConc => 'Yakuniy konsentratsiya (C₂)';

  @override
  String get calcFinalVol => 'Yakuniy hajm (V₂)';

  @override
  String get calcUnit => 'Birlik';

  @override
  String get calcCalculate => 'Hisoblash';

  @override
  String get calcEnterValues =>
      'To‘rtinchisini topish uchun uchta qiymatni kiriting.';

  @override
  String get calcErrorPositive => 'Musbat son kiriting.';

  @override
  String get calcErrorUnits =>
      'Ikkala konsentratsiya mos birlikda bo‘lishi kerak (massa yoki molyar).';

  @override
  String get calcWarnExceeds =>
      'Yakuniy konsentratsiya boshlang‘ichdan yuqori — ma’lumotlarni tekshiring.';

  @override
  String get calcDilutionAssumptionConservation =>
      'Suyultirishda modda miqdori o‘zgarmaydi.';

  @override
  String get calcDilutionAssumptionMixing =>
      'Hajmlar qo‘shiluvchan, aralashtirish to‘liq.';

  @override
  String get calcDilutionLimitationContraction =>
      'Aralashtirishda hajm sezilarli kamayadigan hollarda mos emas (masalan, konsentrlangan etanol va suv).';

  @override
  String get calcDefinitional =>
      'Ta’rifiy munosabat (modda miqdorining saqlanishi); adabiyotdagi qiymatlar ishlatilmaydi.';

  @override
  String get calcNeedsReviewNotice =>
      'Bu kalkulyator hali laboratoriya taqrizchisi tomonidan tekshirilmagan.';

  @override
  String calcResultSemantics(String value) {
    return 'Natija: $value';
  }

  @override
  String get librarySubstances => 'Moddalar';

  @override
  String get libraryMethods => 'Analitik usullar';

  @override
  String get librarySpecimens => 'Namunalar';

  @override
  String get libraryReferences => 'Manbalar';

  @override
  String get libraryGlossary => 'Glossariy';

  @override
  String get libraryFilterHint => 'Bo‘lim bo‘yicha filtr…';

  @override
  String get filterAll => 'Barchasi';

  @override
  String get libraryEmptyFiltered => 'Filtrga mos yozuv yo‘q.';

  @override
  String get detailNames => 'Nomlar va sinonimlar';

  @override
  String get detailClass => 'Sinf';

  @override
  String get detailMetabolites => 'Metabolitlar';

  @override
  String get detailSpecimens => 'Namunalar';

  @override
  String get detailMethods => 'Analitik usullar';

  @override
  String get detailConcentrations => 'Referens konsentratsiyalar';

  @override
  String get detailInterpretation => 'Talqin';

  @override
  String get detailStability => 'Barqarorlik va saqlash';

  @override
  String get detailInterferences => 'Interferensiyalar';

  @override
  String get detailReferences => 'Manbalar';

  @override
  String get detailEvidenceStatus => 'Dalil holati';

  @override
  String get detailLastReviewed => 'Oxirgi tekshiruv';

  @override
  String get detailNotReviewed => 'Tekshirilmagan';

  @override
  String get detailPlaceholder =>
      'Bu yozuv uchun tekshirilgan ilmiy ma’lumot hozircha mavjud emas.';

  @override
  String get detailConcentrationsNote =>
      'Konsentratsiyaning o‘zi o‘lim sababini isbotlamaydi. Qiymatlar faqat matritsa, populyatsiya va manbalar bilan ko‘rsatiladi.';

  @override
  String get sourcesButton => 'Manbalar';

  @override
  String get sourcesNone => 'Bu yozuvga manba biriktirilmagan.';

  @override
  String get searchGroupTools => 'Vositalar';

  @override
  String get searchGroupLearning => 'Ta’lim';

  @override
  String get searchClearHistory => 'Tarixni tozalash';

  @override
  String get searchClearQuery => 'Tozalash';

  @override
  String searchNoResultsTitle(String query) {
    return '«$query» bo‘yicha natija topilmadi';
  }

  @override
  String get searchNoResultsBody =>
      'Imloni tekshiring yoki boshqa tilda yozib ko‘ring — inglizcha, ruscha va o‘zbekcha nomlar qo‘llab-quvvatlanadi.';

  @override
  String get searchOfflineLabel => 'Qurilmada · oflayn';

  @override
  String get searchExternalTitle => 'Ilmiy bazalar (onlayn)';

  @override
  String get searchExternalBody =>
      'Tashqi bazalar (PubMed, PubChem, Crossref) bu versiyada ulanmagan. Tashqi natijalar hech qachon tekshirilgan ichki baza bilan aralashtirilmaydi.';

  @override
  String get searchTypeToStart => 'Kamida ikki belgi kiriting.';

  @override
  String searchResultsSemantics(int count) {
    return 'Natijalar: $count';
  }

  @override
  String get aiAskTitle => 'Forensic AI’ga savol';

  @override
  String get aiInputHint =>
      'Moddalar, usullar yoki talqin cheklovlari haqida so‘rang…';

  @override
  String get aiSend => 'Yuborish';

  @override
  String aiPiiDetected(String kinds) {
    return 'Shaxsiy ma’lumot bo‘lishi mumkin: $kinds. Yuborishdan oldin olib tashlang.';
  }

  @override
  String get piiKindEmail => 'elektron pochta';

  @override
  String get piiKindPhone => 'telefon raqami';

  @override
  String get piiKindPassport => 'pasport/ID raqami';

  @override
  String get piiKindCase => 'ish raqami';

  @override
  String get piiKindName => 'F.I.Sh.';

  @override
  String get piiKindAddress => 'manzil';

  @override
  String get aiPreviewTitle => 'Javob tuzilmasi (namuna)';

  @override
  String get aiPreviewNotice =>
      'NAMOYISH — bu AI javobi ham, ilmiy tavsiya ham emas. Faqat ulangan javob qanday tuzilishini ko‘rsatadi.';

  @override
  String get aiSectionAvailable => 'Mavjud ma’lumotlar';

  @override
  String get aiSectionConsiderations => 'Differensial mulohazalar';

  @override
  String get aiSectionLimitations => 'Talqin cheklovlari';

  @override
  String get aiSampleInternal =>
      'Tekshirilgan ichki manbaga bog‘langan fikr namunasi.';

  @override
  String get aiSampleExternal =>
      'Tekshirilmagan tashqi manbadan olingan fikr namunasi.';

  @override
  String get aiSampleLimitation =>
      'Cheklov namunasi — yakuniy talqin uchun holatning to‘liq konteksti kerak.';

  @override
  String get aiEvidenceInternalVerified => 'Ichki · tasdiqlangan';

  @override
  String get aiEvidenceInternalReviewed => 'Ichki · ko‘rib chiqilgan';

  @override
  String get aiEvidenceExternal => 'Tashqi · tekshirilmagan';

  @override
  String aiPlaceholderSource(int number) {
    return 'Manba namunasi $number';
  }

  @override
  String aiCitationSemantics(int number) {
    return 'Manba $number';
  }

  @override
  String get aiExpertJudgment =>
      'Yakuniy professional xulosa malakali mutaxassisga tegishli. Forensic AI ekspert xulosasini bermaydi.';

  @override
  String get aiReport => 'Javob ustidan shikoyat qilish';

  @override
  String get learnCourses => 'Kurslar';

  @override
  String get learnLessons => 'Darslar';

  @override
  String get learnQuiz => 'Test';

  @override
  String get learnFlashcards => 'Kartochkalar';

  @override
  String get learnCases => 'Holatlar tahlili';

  @override
  String get learnProgress => 'O‘zlashtirish';

  @override
  String get learnNotStarted => 'Boshlanmagan';

  @override
  String get learnProgressEmpty =>
      'Boshlaganingizdan so‘ng natijalar shu qurilmada saqlanadi.';

  @override
  String learnLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta dars',
    );
    return '$_temp0';
  }

  @override
  String get learnStart => 'Boshlash';

  @override
  String get quizCheck => 'Javobni tekshirish';

  @override
  String get quizCorrect => 'To‘g‘ri';

  @override
  String get quizIncorrect => 'Noto‘g‘ri';

  @override
  String get quizExplanation => 'Izoh';

  @override
  String get flashcardShowAnswer => 'Javobni ko‘rsatish';

  @override
  String get flashcardKnew => 'Bilaman';

  @override
  String get flashcardAgain => 'Takrorlash';

  @override
  String get profileSectionPreferences => 'Sozlamalar';

  @override
  String get profileSectionAccount => 'Qurilmadagi ma’lumotlar';

  @override
  String get profileSectionAbout => 'Ilova haqida va huquqiy ma’lumot';

  @override
  String get settingsContrast => 'Kontrast';

  @override
  String get contrastStandard => 'Standart';

  @override
  String get contrastHigh => 'Yuqori';

  @override
  String get contrastSystemHint =>
      '«Tizim» qurilmaning maxsus imkoniyatlar sozlamasiga amal qiladi.';

  @override
  String get privacyPolicy => 'Maxfiylik siyosati';

  @override
  String get termsOfUse => 'Foydalanish shartlari';

  @override
  String get openSourceLicenses => 'Ochiq kodli dasturlar litsenziyalari';

  @override
  String get aboutApp => 'Ilova haqida';

  @override
  String get deleteAccount => 'Hisobni o‘chirish';

  @override
  String get legalDraftNotice =>
      'Qoralama. Hujjat professional yuridik tekshiruvdan so‘ng e’lon qilinadi.';

  @override
  String get privacySummary =>
      'Asosiy kutubxona va kalkulyatorlar oflayn ishlaydi. Qidiruv tarixi, natijalar va ixtiyoriy profilingiz (ism, tashkilot, mutaxassislik) qurilmangizda saqlanadi. Profil ma’lumotlari va malaka hujjatlari faqat professional tasdiqlash xizmati ulangandan keyin ariza yuborsangiz jo‘natiladi; hujjatlar maxfiy saqlanadi va hech qachon ochiq ko‘rsatilmaydi. Ilovada reklama SDK’lari yo‘q. Shaxsiy ma’lumot va ish tafsilotlari AI’ga hech qachon avtomatik yuborilmaydi.\n\nTakliflar: hamkasbingiz taklif kodidan foydalansangiz, server faqat ikki hisob orasidagi bog‘lanishni va elektron pochtangizning tuzli xeshini saqlaydi (hisobni qayta ochish orqali suiiste’molning oldini olish uchun). Taklif qilgan kishi faqat umumiy sonlarni ko‘radi — ismingiz, elektron pochtangiz, profilingiz yoki hujjatlaringizni hech qachon ko‘rmaydi. Ilova kontaktlaringizni o‘qimaydi.\n\nTaklif va murojaatlar: «Taklif va murojaatlar» bo‘limi orqali yuborgan xabaringiz, ixtiyoriy skrinshotingiz (faqat JPEG/PNG/WebP, 5 MB gacha), murojaat turi va hisobingiz elektron pochtasi serverimizda faqat sizga javob berish va ilovani yaxshilash uchun saqlanadi. Ularni faqat FORENSIC EXPERT jamoasining vakolatli administratori ko‘radi; boshqa foydalanuvchilar hech qachon ko‘rmaydi. Javobda administrator ismi emas, «FORENSIC EXPERT jamoasi» ko‘rsatiladi. Administrator amallari jurnalga yoziladi (xabar matnisiz). Murojaat yuborishdan oldin roziligingiz so‘raladi. Murojaatlar va skrinshotlar uchinchi shaxslarga berilmaydi, reklama yoki AI o‘qitish uchun ishlatilmaydi. Hisobingizni o‘chirsangiz, murojaatlaringiz, xabarlaringiz va skrinshotlaringiz ham butunlay o‘chiriladi.';

  @override
  String get aboutBody =>
      'Sud ekspertizasi uchun professional ma’lumotnoma, ta’lim va ilmiy hisob-kitob ilovasi.';

  @override
  String get aboutVersions =>
      'Ilova versiyasi va ilmiy baza versiyasi alohida yuritiladi.';

  @override
  String get storeNotConnected =>
      'App Store / Google Play hozircha mavjud emas. Narx va xarid faqat do‘kon bergandagina paydo bo‘ladi.';

  @override
  String get restorePurchases => 'Xaridlarni tiklash';

  @override
  String get restoreNothing => 'Tiklanadigan faol obuna yo‘q.';

  @override
  String get subscriptionSafetyNote =>
      'Ogohlantirishlar, cheklovlar va manbalar hech qachon pullik obuna ortida yashirilmaydi.';

  @override
  String get moduleHubTools => 'Bo‘lim vositalari';

  @override
  String get moduleHubReference => 'Ma’lumotnoma';

  @override
  String get settingsJurisdiction => 'Yurisdiksiya';

  @override
  String get jurisdictionPickerIntro =>
      'Ilmiy dalillar xalqaro va barcha davlatlar uchun bir xil. Yurisdiksiya faqat huquqiy va protsessual qatlamni (qonunlar, nazoratdagi moddalar ro‘yxatlari, milliy metodikalar) tanlaydi — u doim alohida ko‘rsatiladi.';

  @override
  String get jurisdictionGroupGlobal => 'Xalqaro va mintaqaviy';

  @override
  String get jurisdictionGroupCountries => 'Davlatlar';

  @override
  String get jurisdictionNoContent =>
      'Bu yurisdiksiya uchun huquqiy va protsessual kontent hali yuklanmagan. Kelajakdagi har bir yozuvda rasmiy manba, kuchga kirgan sana, tahrir va oxirgi tekshiruv sanasi ko‘rsatiladi.';

  @override
  String get jurisdictionCompare => 'Yurisdiksiyalarni solishtirish';

  @override
  String get jurisdictionCompareSoon =>
      'Rejalashtirilgan. Kamida ikki yurisdiksiya uchun tekshirilgan huquqiy kontent paydo bo‘lgach ishga tushadi.';

  @override
  String get jurisdictionInternationalHint =>
      '«Xalqaro» tanlangan: bu yerda faqat xalqaro konvensiyalar va standartlar. Davlatning huquqiy qatlamini ko‘rish uchun davlatni tanlang.';

  @override
  String get detailLayerScientific => 'Xalqaro ilmiy dalillar';

  @override
  String get detailLayerScientificNote =>
      'Davlatga bog‘liq emas. Huquqiy maqom va milliy protseduralar quyida alohida ko‘rsatiladi.';

  @override
  String detailLayerJurisdiction(String name) {
    return 'Yurisdiksiya qatlami: $name';
  }

  @override
  String get detailLegalStatus => 'Huquqiy maqom';

  @override
  String get detailNationalMethods => 'Milliy metodikalar va protseduralar';

  @override
  String get detailChangeJurisdiction => 'Yurisdiksiyani o‘zgartirish';

  @override
  String get purchaseTitle => 'Tariflar';

  @override
  String get purchaseCta => 'Tariflarni ko‘rish';

  @override
  String get purchaseFreeTitle => 'Bepul';

  @override
  String get purchaseFreeBody =>
      'Asosiy oflayn ma’lumotnoma, qidiruv va oddiy kalkulyatorlar — hisobsiz.';

  @override
  String get purchaseAiNote =>
      'Professional AI funksiyalari faqat AI xizmati ulanganda ishlaydi; cheklovlar xariddan oldin ko‘rsatiladi.';

  @override
  String get purchaseOwned => 'Obunangiz faol';

  @override
  String get purchaseUnavailableSnack => 'Xarid hozircha mavjud emas.';

  @override
  String get accessFree => 'Bepul';

  @override
  String get homePilotNotice =>
      'Ilmiy baza ekspert tekshiruvida. Har bir yozuv manbasi va tekshiruv holati bilan ko‘rsatiladi va yakuniy xulosa hisoblanmaydi.';

  @override
  String get detailIdentity => 'Identifikatorlar';

  @override
  String get detailMolecularFormula => 'Molekulyar formula';

  @override
  String get detailMolecularWeight => 'Molekulyar massa (g/mol)';

  @override
  String get detailIupac => 'IUPAC nomi';

  @override
  String get detailBiomarker => 'Biomarker';

  @override
  String get detailTransformationProduct => 'Hosil bo‘ladigan mahsulot';

  @override
  String get detailMetabolismNote => 'Metabolizm';

  @override
  String get detailExcerpt => 'Manbadan iqtibos';

  @override
  String get detailExcerptWithheld =>
      'Manba litsenziyasi qayta foydalanishga ruxsat bermagani uchun iqtibos ko‘rsatilmaydi. Manbani ochib o‘qing.';

  @override
  String get detailProvenance => 'Ma’lumotlar kelib chiqishi';

  @override
  String detailEvidenceLevel(String level) {
    return 'Dalil darajasi $level';
  }

  @override
  String get detailReviewerStatus => 'Taqrizchi holati';

  @override
  String get detailReviewsNone =>
      'Hali ekspert taqrizi yo‘q (2 ta talab qilinadi)';

  @override
  String detailReviewsCount(int count) {
    return 'Ekspert taqrizlari: $count';
  }

  @override
  String get detailVersion => 'Versiya';

  @override
  String detailVersionValue(int claim, String pack) {
    return 'Da’vo v$claim · baza $pack';
  }

  @override
  String get detailTranslationDraft =>
      'Nomlar avtomatik tarjima qilingan, hali tekshirilmagan';

  @override
  String get detailNoContentYet => 'Bu bo‘lim uchun manbali kontent hali yo‘q.';

  @override
  String detailSourceAccessed(String date) {
    return 'Murojaat sanasi: $date';
  }

  @override
  String get detailIdentifierVerified => 'DOI/PMID avtomatik tekshirilgan';

  @override
  String detailSourceLicence(String mode) {
    return 'Litsenziya rejimi: $mode';
  }

  @override
  String legalSchedule(String convention, String schedules) {
    return '$convention: $schedules-jadval';
  }

  @override
  String get legalListRow => 'Rasmiy ro‘yxatdagi qator';

  @override
  String legalEffective(String date) {
    return 'Nashr $date dan amalda';
  }

  @override
  String get legalDateYearOnly => '(manbada faqat yil ko‘rsatilgan)';

  @override
  String legalLastVerified(String date) {
    return 'Oxirgi tekshiruv: $date';
  }

  @override
  String get legalInternationalLayer => 'Xalqaro daraja (BMT konvensiyalari)';

  @override
  String get legalNotInListNote =>
      'Bu ro‘yxatlarda yo‘qligi modda nazoratda emas degani emas: milliy qonunchilik farq qilishi mumkin.';

  @override
  String legalNoNational(String name) {
    return '$name uchun milliy huquqiy kontent hali yuklanmagan.';
  }

  @override
  String get lockedTitle => 'Talaba Pro va Mutaxassis Pro tarkibida';

  @override
  String get lockedBody =>
      'Nomlar, ogohlantirishlar va manbalar ochiq qoladi. Ilmiy tafsilotlar va yurisdiksiya qatlami pullik tarifda ochiladi.';

  @override
  String get freeDemoBadge => 'Bepul';

  @override
  String get lockedBadge => 'Pro';

  @override
  String searchMoreLocked(int count) {
    return 'Pullik tarifda yana $count ta natija';
  }

  @override
  String get learnEmptyCourses =>
      'Kurslar o‘quv kontenti ekspert tekshiruvidan o‘tgach paydo bo‘ladi.';

  @override
  String get contentLoading => 'Ilmiy baza yuklanmoqda…';

  @override
  String get libraryNotInstalled => 'Ilmiy baza hozircha o‘rnatilmagan.';

  @override
  String get purchasePending => 'Xarid do‘kon tasdig‘ini kutmoqda.';

  @override
  String get purchaseFailed => 'Xarid yakunlanmadi.';

  @override
  String get purchaseCancelled => 'Xarid bekor qilindi.';

  @override
  String get purchaseSuccess => 'Obuna faollashtirildi. Rahmat!';

  @override
  String get aboutTrademarkPending =>
      'Nom va logo: tovar belgisi tekshiruvi yakunlanmagan.';

  @override
  String get diagPurchaseNone => 'Obuna: do‘kon tasdiqlamagan';

  @override
  String get diagPurchaseStore =>
      'Obuna: faqat do‘kon tasdiqlagan — server tekshiruvi ulanmagan (reliz to‘sig‘i)';

  @override
  String get diagPurchaseServer => 'Obuna: server tomonidan tekshirilgan';

  @override
  String get statusDraft => 'Qoralama';

  @override
  String get searchGroupTopics => 'Sud tibbiyoti va biokimyo';

  @override
  String get searchGroupReagents => 'Reagentlar va eritmalar';

  @override
  String get searchGroupScreening => 'Skrining testlari';

  @override
  String get searchGroupStandardsLaws => 'Standartlar va qonunlar';

  @override
  String get moduleBiochemistry => 'Biokimyo';

  @override
  String get moduleReagents => 'Reagentlar va eritmalar';

  @override
  String get moduleScreening => 'Ekspress va skrining testlari';

  @override
  String get moduleMethods => 'Usullar va SOP';

  @override
  String get moduleStandardsLaws => 'Huquq va yurisdiksiyalar';

  @override
  String get moduleEmerging => 'Yangi muammolar';

  @override
  String get homeAreasHeading => 'Professional bo‘limlar';

  @override
  String get homeDbTitle => 'Oflayn baza';

  @override
  String homeDbPack(String version) {
    return 'Ilmiy ma’lumotlar paketi $version';
  }

  @override
  String homeDbScientific(String version) {
    return 'Ilmiy ma’lumot $version';
  }

  @override
  String homeDbJurisdiction(String version) {
    return 'Yurisdiksiya ma’lumoti $version';
  }

  @override
  String get homeDbOffline =>
      'Oflayn ishlaydi. Qidiruv va savollar shu qurilmada qoladi.';

  @override
  String get homeDbNotInstalled => 'Ilmiy ma’lumotlar paketi o‘rnatilmagan.';

  @override
  String get homeDbLoading => 'Oflayn baza ochilmoqda…';

  @override
  String get knowledgeEmpty => 'O‘rnatilgan paketda hozircha yozuv yo‘q.';

  @override
  String get knowledgeNoSourcedContent => 'Hozircha manbali ma’lumot yo‘q';

  @override
  String get knowledgeStatements => 'Manbali ma’lumotlar';

  @override
  String get knowledgeSafety => 'Cheklovlar va xavfsizlik';

  @override
  String get knowledgeSources => 'Manbalar';

  @override
  String get knowledgeDetails => 'Tafsilotlar';

  @override
  String knowledgeSourceRef(String source) {
    return 'Manba: $source';
  }

  @override
  String get knowledgeNotInSource =>
      'Manbalarda ko‘rsatilmagan — taxmin qilinmaydi';

  @override
  String get knowledgeTaxonomy => 'Mavzular';

  @override
  String knowledgeTopicCount(int count, int total) {
    return '$total mavzudan $count tasida manbali ma’lumot bor';
  }

  @override
  String get reagentPreparation => 'Tayyorlash';

  @override
  String get reagentNoRecipe =>
      'Manbalarda tasdiqlangan tayyorlash retsepti topilmadi. Tarkib, miqdor, qo‘shish tartibi, saqlash va yaroqlilik muddati ko‘rsatilmaydi va taxmin qilinmaydi.';

  @override
  String get reagentIngredients => 'Tarkib';

  @override
  String get reagentFinalVolume => 'Yakuniy hajm';

  @override
  String get reagentSteps => 'Bosqichlar';

  @override
  String get reagentOrderNotStated =>
      'Manba qo‘shish tartibini aytmaydi — bosqichlar raqamsiz ko‘rsatilgan.';

  @override
  String get reagentStorage => 'Saqlash';

  @override
  String get reagentTemperature => 'Harorat';

  @override
  String get reagentStability => 'Barqarorlik';

  @override
  String get reagentHazards => 'Xavf';

  @override
  String get reagentDisposal => 'Utilizatsiya';

  @override
  String get reagentQc => 'Sifat nazorati';

  @override
  String get reagentOpenCalculator => 'Eritma tayyorlash kalkulyatori';

  @override
  String get screeningBanner =>
      'SKRINING NATIJASI ≠ TASDIQLANGAN IDENTIFIKATSIYA. Ijobiy skrining dastlabki natija bo‘lib, validatsiyadan o‘tgan tasdiqlovchi usulni talab qiladi.';

  @override
  String get screeningAnalyte => 'Analit';

  @override
  String get screeningSpecimen => 'Namuna';

  @override
  String get screeningPrinciple => 'Prinsip';

  @override
  String get screeningCutoff => 'Chegara qiymati (cut-off)';

  @override
  String get screeningSensitivity => 'Sezgirlik';

  @override
  String get screeningSpecificity => 'Spetsifiklik';

  @override
  String get screeningCrossReactivity => 'Kross-reaktivlik';

  @override
  String get screeningFalsePositive => 'Soxta ijobiy natijalar';

  @override
  String get screeningFalseNegative => 'Soxta salbiy natijalar';

  @override
  String get screeningLimitations => 'Cheklovlar';

  @override
  String get screeningConfirmatory => 'Tasdiqlovchi usullar';

  @override
  String get methodKindScientific => 'Ilmiy usullar';

  @override
  String get methodKindInternational => 'Xalqaro standartlar';

  @override
  String get methodKindNational => 'Milliy metodikalar';

  @override
  String get methodKindSop => 'Muassasa SOP’lari (standart ish tartiblari)';

  @override
  String get methodKindNote =>
      'Usul turlari aralashtirilmaydi: ilmiy usul huquqiy talab emas, muassasa SOP’i esa faqat o‘sha muassasada amal qiladi.';

  @override
  String get methodNoKindEntries => 'Bu turdagi yozuv hozircha yo‘q.';

  @override
  String get methodOrganization => 'Tashkilot';

  @override
  String get methodJurisdiction => 'Yurisdiksiya';

  @override
  String get methodTechniques => 'Tahlil texnikalari';

  @override
  String get methodDocumentVersion => 'Hujjat versiyasi';

  @override
  String emergingDate(String date) {
    return 'Nashr qilingan: $date';
  }

  @override
  String get emergingEvidenceType => 'Dalil turi';

  @override
  String get emergingScopeGlobal => 'Qamrov: global';

  @override
  String get evidenceTypeOfficialAlert => 'Rasmiy ogohlantirish';

  @override
  String get evidenceTypePeerReviewed => 'Taqrizdan o‘tgan nashr';

  @override
  String get evidenceTypeReport => 'Hisobot';

  @override
  String get evidenceTypeStandard => 'Standart';

  @override
  String get emergingNote =>
      'Har bir yozuvda manba, sana, dalil turi va qamrov bor. Bu yangiliklar lentasi emas.';

  @override
  String get emergingCatNps => 'Yangi psixoaktiv moddalar';

  @override
  String get emergingCatSyntheticOpioids => 'Sintetik opioidlar';

  @override
  String get emergingCatStimulants => 'Yangi stimulyatorlar';

  @override
  String get emergingCatAnalytical => 'Analitik muammolar';

  @override
  String get emergingCatInterferences => 'Yangi interferensiyalar';

  @override
  String get emergingCatPostmortem => 'O‘limdan keyingi talqin';

  @override
  String get emergingCatStandards => 'Yangi standartlar';

  @override
  String get emergingCatValidation => 'Usul validatsiyasi';

  @override
  String get emergingCatQuality => 'Laboratoriya sifati';

  @override
  String get emergingCatAlert => 'Ilmiy ogohlantirish';

  @override
  String get fmTopicDeathInvestigation => 'O‘lim holatini tekshirish';

  @override
  String get fmTopicCauseMechanismManner => 'O‘lim sababi, mexanizmi va turi';

  @override
  String get fmTopicPostmortemChanges => 'O‘limdan keyingi o‘zgarishlar';

  @override
  String get fmTopicPostmortemInterval =>
      'O‘limdan keyin o‘tgan vaqt oralig‘i (PMI)';

  @override
  String get fmTopicAlgorMortis => 'Murdaning sovishi';

  @override
  String get fmTopicRigorMortis => 'Murda qotishi';

  @override
  String get fmTopicLivorMortis => 'Murda dog‘lari';

  @override
  String get fmTopicDecomposition => 'Chirish';

  @override
  String get fmTopicTrauma => 'Jarohat';

  @override
  String get fmTopicBluntForceInjury => 'To‘mtoq jism jarohati';

  @override
  String get fmTopicSharpForceInjury => 'O‘tkir jism jarohati';

  @override
  String get fmTopicFirearmInjury => 'O‘qotar qurol jarohati';

  @override
  String get fmTopicAsphyxia => 'Asfiksiya';

  @override
  String get fmTopicBurns => 'Kuyishlar';

  @override
  String get fmTopicElectricalInjury => 'Elektr jarohati';

  @override
  String get fmTopicHypoHyperthermia => 'Gipo- va gipertermiya';

  @override
  String get fmTopicDrowning => 'Cho‘kish';

  @override
  String get fmTopicAnthropology => 'Sud antropologiyasi';

  @override
  String get fmTopicAgeEstimation => 'Yoshni aniqlash';

  @override
  String get fmTopicSexEstimation => 'Jinsni aniqlash';

  @override
  String get fmTopicStatureEstimation => 'Bo‘yni aniqlash';

  @override
  String get fmTopicOdontology => 'Sud odontologiyasi';

  @override
  String get fmTopicDisasterVictimIdentification =>
      'Falokat qurbonlarini identifikatsiya qilish';

  @override
  String get fmTopicHistology => 'Sud gistologiyasi';

  @override
  String get fmTopicPostmortemImaging => 'O‘limdan keyingi vizualizatsiya';

  @override
  String get compareTitle => 'Yurisdiksiyalarni solishtirish';

  @override
  String get compareTopicDrinkDrive =>
      'Mast holda haydash: belgilangan alkogol chegarasi';

  @override
  String get compareNoData => 'Ma’lumot yo‘q — xulosa chiqarilmaydi';

  @override
  String get compareNoTopics =>
      'Paketda hozircha solishtiriladigan huquqiy ma’lumot yo‘q.';

  @override
  String get compareNotAdvice =>
      'Ma’lumotnoma, yuridik maslahat emas. Har doim amaldagi rasmiy matnni tekshiring.';

  @override
  String get compareNoInference =>
      'Ma’lumot yo‘qligi «ruxsat», «nazoratda emas» yoki «taqiqlangan» degani emas.';

  @override
  String compareOverrides(String jurisdiction) {
    return '$jurisdiction qoidasi o‘rniga amal qiladi';
  }

  @override
  String compareArticle(String section) {
    return 'Modda/bo‘lim: $section';
  }

  @override
  String compareAuthority(String name) {
    return 'Organ: $name';
  }

  @override
  String get compareOfficialExcerpt => 'Rasmiy matn';

  @override
  String get specimenBreath => 'Nafas';

  @override
  String get specimenBlood => 'Qon';

  @override
  String get specimenUrine => 'Siydik';

  @override
  String get legalThresholdTitle => 'Huquqiy chegara';

  @override
  String get legalLayerNational => 'Milliy / hududiy qonun';

  @override
  String get legalOpenCompare => 'Yurisdiksiyalarni solishtirish';

  @override
  String get toolSolutionName => 'Eritma tayyorlash (kerakli massa)';

  @override
  String get toolSolutionDesc =>
      'Berilgan konsentratsiya va hajm uchun modda massasi: m = C·V(·M)/p. Molyar massa va tozalikni siz kiritasiz (sertifikat/yorliq).';

  @override
  String get calcTargetConc => 'Maqsadli konsentratsiya';

  @override
  String get calcMolarMass => 'Molyar massa (g/mol)';

  @override
  String get calcPurity => 'Tozalik (0–1)';

  @override
  String get calcMassRequired => 'Kerakli massa';

  @override
  String get calcErrorMolarMass =>
      'Molyar konsentratsiya uchun molyar massani sertifikat yoki yorliqdan kiriting.';

  @override
  String get calcErrorPurity =>
      'Tozalik 0 dan katta va 1 dan oshmasligi kerak.';

  @override
  String get calcSolutionAssumptionDefinition =>
      'Konsentratsiya ta’rifi bo‘yicha hisob (empirik koeffitsiyentsiz).';

  @override
  String get calcSolutionAssumptionInputs =>
      'Molyar massa va tozalikni foydalanuvchi kiritadi; hech narsa taxmin qilinmaydi.';

  @override
  String get calcSolutionLimitationRecipe =>
      'Bu reaktiv retsepti emas: modda tanlovi, tartib, saqlash va barqarorlik faqat tasdiqlangan manba yoki SOP’dan.';

  @override
  String get calcSolutionLimitationVolume =>
      'Eritishda hajm o‘zgarishi hisobga olinmaydi.';

  @override
  String get calcWarnPurity => 'Tozalik tuzatmasi qo‘llandi.';

  @override
  String legalExtent(String extent) {
    return 'Hududiy amal qilishi: $extent';
  }

  @override
  String legalAppliesTo(String places) {
    return 'Qo‘llaniladi: $places';
  }

  @override
  String get legalStatusInForce => 'Amalda';

  @override
  String get legalStatusAmended => 'O‘zgartirilgan';

  @override
  String get legalStatusSuperseded => 'Almashtirilgan';

  @override
  String get legalStatusRepealed => 'Kuchini yo‘qotgan';

  @override
  String get aiExperienceProfessional => 'Qisqa javob';

  @override
  String get aiExperienceTutor => 'Tushuntirib bering';

  @override
  String get aiExperienceProfessionalHint =>
      'Mutaxassislar uchun qisqa, manbaga tayangan javoblar.';

  @override
  String get aiExperienceTutorHint =>
      'O‘rganish uchun bosqichma-bosqich tushuntirish, har doim manba bilan.';

  @override
  String get aiFindSources => 'Manbalarni oflayn topish';

  @override
  String get aiRetrievalTitle => 'Oflayn bazadagi mos ma’lumotlar';

  @override
  String get aiRetrievalNote =>
      'Bu AI javobi emas: bular lokal qidiruv natijalari, har birining manbasi bor.';

  @override
  String get aiNoContext =>
      'Oflayn bazada ishonchli kontekst yo‘q — javob berilmaydi.';

  @override
  String get aiBlockedConclusion =>
      'O‘lim sababi yoki turi bo‘yicha yakuniy xulosa berilmaydi. Bu — ish materiallari to‘liq bo‘lgan ekspert qarori.';

  @override
  String get aiBlockedLegal =>
      'Huquqiy xulosa (aybdorlik, ayblov, jazo) berilmaydi.';

  @override
  String get aiBlockedPii =>
      'Qidirish yoki so‘rashdan oldin shaxsiy ma’lumotni olib tashlang.';

  @override
  String get learnLevelAll => 'Barcha darajalar';

  @override
  String get learnLevelFoundation => 'Boshlang‘ich';

  @override
  String get learnLevelIntermediate => 'O‘rta';

  @override
  String get learnLevelAdvanced => 'Yuqori';

  @override
  String learnProgressValue(int done, int total) {
    return '$total darsdan $done tasi tugatildi';
  }

  @override
  String get learnHistory => 'Yaqinda o‘rganilgan';

  @override
  String get learnBookmarks => 'Saralanganlar';

  @override
  String get learnBookmarksEmpty =>
      'Mavzuni yulduzcha bilan belgilang — u shu yerda chiqadi.';

  @override
  String get learnMarkComplete => 'Tugatildi deb belgilash';

  @override
  String get learnCompleted => 'Tugatildi';

  @override
  String get learnCourseSourceNote =>
      'Darslar manbadagi asl jumlalarni ko‘rsatadi. Yangi ilmiy matn yozilmaydi; mazmun ekspert tekshiruvini kutmoqda.';

  @override
  String get learnExam => 'Imtihon rejimi';

  @override
  String get learnExamIntro =>
      'Barcha savollarga javob bering. Natija va izohlar faqat topshirgandan keyin chiqadi.';

  @override
  String get learnExamSubmit => 'Imtihonni topshirish';

  @override
  String learnExamScore(int correct, int total) {
    return 'Natija: $total dan $correct';
  }

  @override
  String get learnExamEmpty =>
      'Tekshirilgan imtihon savollari hozircha yo‘q. Savollar avtomatik yaratilmaydi.';

  @override
  String get learnExamRetry => 'Qayta urinish';

  @override
  String get learnSimulatedCase => 'MODELLASHTIRILGAN HOLAT — haqiqiy ish emas';

  @override
  String get moduleHistology => 'Sud gistologiyasi';

  @override
  String get moduleResearch => 'Tadqiqotlar va dalillar';

  @override
  String get group_alcohols_volatiles => 'Spirtlar va uchuvchan moddalar';

  @override
  String get group_toxic_gases => 'Toksik gazlar';

  @override
  String get group_opioids => 'Opioidlar';

  @override
  String get group_stimulants => 'Stimulyatorlar';

  @override
  String get group_cannabinoids => 'Kannabinoidlar';

  @override
  String get group_hallucinogens_dissociatives =>
      'Gallyutsinogenlar va dissotsiativlar';

  @override
  String get group_benzodiazepines => 'Benzodiazepinlar';

  @override
  String get group_sedatives_hypnotics => 'Sedativ va uxlatuvchi';

  @override
  String get group_barbiturates => 'Barbituratlar';

  @override
  String get group_antidepressants => 'Antidepressantlar';

  @override
  String get group_antipsychotics => 'Antipsixotiklar';

  @override
  String get group_anticonvulsants => 'Antikonvulsantlar';

  @override
  String get group_pharmaceuticals => 'Keng tarqalgan dorilar';

  @override
  String get group_adulterants => 'Aralashmalar (adulterantlar)';

  @override
  String get group_pesticides => 'Pestitsidlar va rodentitsidlar';

  @override
  String get group_metals_inorganic => 'Metallar va anorganik zaharlar';

  @override
  String get groupAll => 'Barcha guruhlar';

  @override
  String get groupEditorialNote =>
      'Guruhlar — tahririy navigatsiya, ilmiy tasnif da’vosi emas.';

  @override
  String get detailAnalyticalMethods => 'Analitik usullar (manbalardan)';

  @override
  String get detailReportedConcentrations => 'Xabar qilingan konsentratsiyalar';

  @override
  String get concentrationNotThreshold =>
      'Alohida tadqiqot yoki holatlardan olingan qiymatlar — toksik, o‘ldiruvchi yoki huquqiy chegara EMAS. Talqin namuna, holat konteksti, tolerantlik va o‘limdan keyingi o‘zgarishlarga bog‘liq.';

  @override
  String get concentrationSpecimen => 'Namuna';

  @override
  String concentrationContext(String context) {
    return 'Kontekst: $context';
  }

  @override
  String get detailStructure => 'Kimyoviy tuzilish';

  @override
  String get detailRelated => 'Bog‘liq materiallar';

  @override
  String get relationAnalysedBy => 'Tahlil usuli (manbada tilga olingan)';

  @override
  String get relationMetabolism => 'Metabolizm manbasida birga tilga olingan';

  @override
  String get relationConfirmedBy => 'Tasdiqlovchi usullar';

  @override
  String get relationRelatedTopic => 'Bog‘liq mavzular';

  @override
  String get relationResearch => 'Tadqiqotlar va dalillar';

  @override
  String relationBasis(String basis) {
    return 'Asos: $basis';
  }

  @override
  String researchMore(int count) {
    return 'Barcha tadqiqotlar ($count)';
  }

  @override
  String get researchTitle => 'Tadqiqotlar kutubxonasi';

  @override
  String get researchNote =>
      'Faqat metama’lumotlar va havolalar — to‘liq matn ko‘chirilmaydi. Dissertatsiya, tezis va konferensiya materiallari taqrizdan o‘tgan maqola bilan teng ko‘rsatilmaydi.';

  @override
  String get researchAll => 'Barchasi';

  @override
  String get researchPeerReviewed => 'Taqrizdan o‘tgan';

  @override
  String get researchNotPeerReviewed => 'Taqrizdan o‘tgan maqola emas';

  @override
  String researchEvidence(String level) {
    return 'Dalil darajasi $level';
  }

  @override
  String get researchCopyLink => 'Havolani nusxalash';

  @override
  String get researchLinkCopied => 'Havola nusxalandi';

  @override
  String get researchLinked => 'Bog‘liq yozuvlar';

  @override
  String researchCount(int count) {
    return '$count ta yozuv';
  }

  @override
  String researchSourceApi(String api) {
    return '$api orqali indekslangan';
  }

  @override
  String get researchKindJournalArticle => 'Maqola';

  @override
  String get researchKindReview => 'Sharh maqola';

  @override
  String get researchKindSystematicReview => 'Tizimli sharh';

  @override
  String get researchKindMetaAnalysis => 'Meta-tahlil';

  @override
  String get researchKindCaseReport => 'Holat tavsifi';

  @override
  String get researchKindConferenceAbstract => 'Konferensiya tezisi';

  @override
  String get researchKindConferencePaper => 'Konferensiya maqolasi';

  @override
  String get researchKindDissertation => 'Doktorlik dissertatsiyasi';

  @override
  String get researchKindThesis => 'Dissertatsiya (magistr / boshqa)';

  @override
  String get researchKindOfficialReport => 'Rasmiy hisobot';

  @override
  String get researchKindStandard => 'Standart / qo‘llanma';

  @override
  String get imageSchematic => 'Sxema — eksperimental ma’lumot emas';

  @override
  String get imageRealData => 'Nashr qilingan tadqiqotdan rasm';

  @override
  String get imageDepiction => 'Struktura tasviri (hisoblangan)';

  @override
  String imageLicense(String license) {
    return 'Litsenziya: $license';
  }

  @override
  String get imageAttribution => 'Atribusiya';

  @override
  String get imageOriginalCaption => 'Asl izoh (manba tilida)';

  @override
  String imageOpen(String title) {
    return 'Rasmni ochish: $title';
  }

  @override
  String get imageUnavailable => 'Rasm oflayn mavjud emas';

  @override
  String get imagesHeading => 'Ilmiy tasvirlar';

  @override
  String get licenseOriginalWork => 'Asl asar (FORENSIC EXPERT)';

  @override
  String get licenseFactualDepiction => 'Faktik ma’lumotning asl tasviri';

  @override
  String get histologyNote =>
      'Mutaxassislar uchun ma’lumotnoma. Ilova va Forensic AI gistologik tashxis qo‘ymaydi.';

  @override
  String get fieldCaseObservation => 'Holat kuzatuvi (bitta holat)';

  @override
  String get fieldComposition => 'Tarkib (manbadagidek)';

  @override
  String get fieldConfirmation => 'Tasdiqlash talabi';

  @override
  String get metaAuthors => 'Mualliflar';

  @override
  String get metaContainer => 'Jurnal / konferensiya';

  @override
  String get metaInstitution => 'Muassasa';

  @override
  String get metaDegree => 'Ilmiy daraja';

  @override
  String get metaYear => 'Yil';

  @override
  String get metaCreator => 'Tasvir muallifi';

  @override
  String get metaSource => 'Manba';

  @override
  String get metaAccessed => 'Murojaat sanasi';

  @override
  String get tech_tlc => 'TLC (yupqa qatlamli xromatografiya)';

  @override
  String get tech_gc => 'GC';

  @override
  String get tech_gcFid => 'GC-FID';

  @override
  String get tech_headspaceGc => 'Bug‘ fazali GC';

  @override
  String get tech_gcMs => 'GC-MS';

  @override
  String get tech_hplc => 'HPLC';

  @override
  String get tech_lcMsMs => 'LC-MS/MS';

  @override
  String get tech_uvVis => 'UV-Vis spektrofotometriya';

  @override
  String get tech_immunoassay => 'Immunoanaliz';

  @override
  String get tech_spectroscopy => 'Spektroskopiya';

  @override
  String get tech_samplePreparation => 'Namuna tayyorlash';

  @override
  String get tech_extraction => 'Ekstraksiya';

  @override
  String get tech_calibration => 'Kalibrlash';

  @override
  String get tech_qualityControl => 'Sifat nazorati';

  @override
  String get tech_validation => 'Usul validatsiyasi';

  @override
  String get tech_uncertainty => 'O‘lchash noaniqligi';

  @override
  String get tech_statistics => 'Statistika';

  @override
  String get methodSection_purpose => 'Maqsad';

  @override
  String get methodSection_scope => 'Qo‘llanish sohasi';

  @override
  String get methodSection_analytes => 'Analitlar';

  @override
  String get methodSection_specimens => 'Namunalar';

  @override
  String get methodSection_principle => 'Prinsip';

  @override
  String get methodSection_equipment => 'Jihozlar';

  @override
  String get methodSection_reagents => 'Reagentlar';

  @override
  String get methodSection_samplePreparation => 'Namuna tayyorlash';

  @override
  String get methodSection_calibrationQc => 'Kalibrlash va sifat nazorati';

  @override
  String get methodSection_workflow => 'Ish tartibi';

  @override
  String get methodSection_interpretation => 'Talqin';

  @override
  String get methodSection_limitations => 'Cheklovlar';

  @override
  String get methodSection_validationStatus => 'Validatsiya holati';

  @override
  String get toolPercentName => 'Foizli eritmalar';

  @override
  String get toolPercentDesc =>
      '% (w/v), (v/v) yoki (w/w) uchun ta’rif bo‘yicha erigan modda miqdori.';

  @override
  String get calcValue => 'Qiymat';

  @override
  String get calcFrom => 'Dan';

  @override
  String get calcTo => 'Ga';

  @override
  String get calcConvertAssumption =>
      'Birlik prefikslari — SI ta’riflari; massa ↔ molyar o‘tish ρ = c · M dan foydalanadi.';

  @override
  String get calcConvertLimitation =>
      'Molyar massa sertifikat yoki tekshirilgan identifikatsiya ma’lumotidan olinadi; kalkulyator uni taxmin qilmaydi.';

  @override
  String get calcMolarityMass => 'Tortilgan massa';

  @override
  String get calcMolarityVolume => 'Yakuniy hajm';

  @override
  String get calcMolarityResult => 'Molyar konsentratsiya';

  @override
  String get calcMolarityAssumption =>
      'Molyar konsentratsiya ta’rifi: c = n / V, bunda n = m · p / M.';

  @override
  String get calcPercentBasis => 'Foiz turi';

  @override
  String get calcPercentWv => '% (w/v) — 100 mL da g';

  @override
  String get calcPercentVv => '% (v/v) — 100 mL da mL';

  @override
  String get calcPercentWw => '% (w/w) — 100 g da g';

  @override
  String get calcPercentValue => 'Foiz (%)';

  @override
  String get calcPercentTotalMl => 'Eritmaning umumiy hajmi (mL)';

  @override
  String get calcPercentTotalG => 'Eritmaning umumiy massasi (g)';

  @override
  String get calcPercentSolute => 'Erigan modda miqdori';

  @override
  String get calcPercentAssumption =>
      'Har bir tur uchun ko‘rsatilgan foiz ta’riflari.';

  @override
  String get calcPercentLimitationBasis =>
      'w/v, v/v va w/w o‘zaro almashtirilmaydi — validatsiyadan o‘tgan usul yoki SOP’dagi turni ishlating.';

  @override
  String get calcErrorPercent =>
      '0 dan katta va 100 dan oshmaydigan foiz kiriting.';

  @override
  String get calcStatsValues =>
      'Qiymatlar (bo‘shliq, «;» yoki yangi qator bilan; o‘nlik 0,5 yoki 0.5)';

  @override
  String get calcStatsN => 'n';

  @override
  String get calcStatsMean => 'O‘rtacha';

  @override
  String get calcStatsMedian => 'Mediana';

  @override
  String get calcStatsSd => 'SO (n − 1)';

  @override
  String get calcStatsCv => 'VK %';

  @override
  String get calcStatsMin => 'Minimum';

  @override
  String get calcStatsMax => 'Maksimum';

  @override
  String get calcStatsAssumption =>
      'Maxraji n − 1 bo‘lgan tanlanma standart og‘ishi.';

  @override
  String get calcStatsLimitation =>
      'Chetga chiquvchi qiymat yoki normallik tekshiruvi bajarilmaydi.';

  @override
  String get calcStatsWarnSd => 'SO va VK uchun kamida ikkita qiymat kerak.';

  @override
  String get calcErrorValues => 'Faqat sonli qiymatlar kiriting.';

  @override
  String get calcRegPoints =>
      'Kalibrlash nuqtalari: har qatorda bitta «x y» yoki «x; y» juftligi';

  @override
  String get calcRegSlope => 'Qiyalik (b)';

  @override
  String get calcRegIntercept => 'Kesishma (a)';

  @override
  String get calcRegR2 => 'R²';

  @override
  String get calcRegSyx => 'Qoldiq SO (s_y/x)';

  @override
  String get calcRegAssumptionOls =>
      'Vaznsiz eng kichik kvadratlar usuli, y = a + b·x.';

  @override
  String get calcRegLimitationRange =>
      'Faqat kalibrlangan diapazon ichida amal qiladi; vazn va chiziqlilik usul validatsiyasida belgilanadi.';

  @override
  String get calcRegWarnFew =>
      'Kalibrlash nuqtalari beshtadan kam — ehtiyotkorlik bilan talqin qiling.';

  @override
  String get calcErrorPoints =>
      'Kamida uchta turli x qiymatli «x y» juftligini kiriting.';

  @override
  String get calcLodSigma => 'Javob standart og‘ishi (σ)';

  @override
  String get calcLodSlope => 'Kalibrlash egri chizig‘i qiyaligi (S)';

  @override
  String get calcLodSigmaBasis => 'σ asosi';

  @override
  String get calcLodBasisBlank => 'Bo‘sh namunalar javobining SO';

  @override
  String get calcLodBasisResidual => 'Regressiya chizig‘ining qoldiq SO';

  @override
  String get calcLodBasisIntercept =>
      'Regressiya chiziqlari y-kesishmalarining SO';

  @override
  String get calcLodLod => 'Aniqlash chegarasi (DL = 3,3σ/S)';

  @override
  String get calcLodLoq => 'Miqdoriy aniqlash chegarasi (QL = 10σ/S)';

  @override
  String get calcLodAssumptionSigma =>
      'σ manbada keltirilgan usullardan biri bilan baholanadi: bo‘sh namuna SO, qoldiq SO yoki y-kesishmalar SO.';

  @override
  String get calcLodAssumptionLinear => 'Chegara yaqinida javob chiziqli.';

  @override
  String get calcLodLimitationOne =>
      'Bu bir nechta qabul qilingan usuldan biri; boshqalari — vizual baho va signal/shovqin nisbati.';

  @override
  String get calcLodLimitationVerify =>
      'Manba hisoblangan chegaralarni chegara yaqinidagi namunalarni tahlil qilib tasdiqlashni talab qiladi.';

  @override
  String get calcLodReference =>
      'ICH Q2(R2) Validation of Analytical Procedures (2023) — §3.2.3.3';

  @override
  String get calcLodReferenceNote =>
      'Koeffitsientlar rasmiy ICH Q2(R2) PDF bilan solishtirildi; Q2(R1) (almashtirilgan) dagidan o‘zgarmagan. Q2(R2) S/N va aniqlik/pretsizlik bilan bevosita tasdiqlashga ham ruxsat beradi. Laboratoriya taqrizchi tasdig‘i kutilmoqda (RG-25).';

  @override
  String get calcUseRegression =>
      'Shu regressiyadagi σ = s_y/x va S dan foydalanish';

  @override
  String get calcErrorSigma => 'σ > 0 va noldan farqli qiyalik kiriting.';

  @override
  String get researchKindGuideline => 'Uslubiy tavsiyanoma';

  @override
  String get researchKindValidationStudy => 'Validatsiya tadqiqoti';

  @override
  String get researchKindCaseSeries => 'Holatlar seriyasi';

  @override
  String get tech_gcMsMs => 'GC-MS/MS';

  @override
  String get tech_lcMs => 'LC-MS';

  @override
  String get tech_hrms => 'HRMS (yuqori aniqlikdagi mass-spektrometriya)';

  @override
  String get tech_spectrophotometry => 'Spektrofotometriya';

  @override
  String get emergingCatBiomarkers => 'Yangi biomarkerlar';

  @override
  String get emergingCatMethods => 'Yangi analitik usullar';

  @override
  String get emergingCatLegal => 'Huquqiy / normativ yangilanishlar';

  @override
  String get severityCritical => 'Muhim ogohlantirish';

  @override
  String get severityWarning => 'Ogohlantirish';

  @override
  String get severityInfo => 'Ma’lumot';

  @override
  String get severityReview => 'Tekshiruv holati';

  @override
  String get homeRecentlyViewed => 'Yaqinda ko‘rilganlar';

  @override
  String get homeQuickEmpty =>
      'Bu yerda yaqinda ko‘rilgan yozuvlar, vositalar, saralanganlar va qidiruvlar chiqadi. Ular faqat shu qurilmada saqlanadi.';

  @override
  String homeJurisdictionChip(String name) {
    return 'Yurisdiksiya: $name';
  }

  @override
  String get homeChange => 'O‘zgartirish';

  @override
  String get homeAllDisciplines => 'Barcha sud-ekspert fanlari';

  @override
  String homeAllDisciplinesBody(int count) {
    return '$count ta fan — qamrov va mavjud kontent';
  }

  @override
  String get disc_forensicMedicine => 'Sud tibbiyoti';

  @override
  String get disc_forensicPathology => 'Sud patologiyasi';

  @override
  String get disc_clinicalForensicMedicine => 'Klinik sud tibbiyoti';

  @override
  String get disc_forensicRadiology => 'Sud radiologiyasi va vizualizatsiya';

  @override
  String get disc_forensicPsychiatry => 'Sud psixiatriyasi va psixologiyasi';

  @override
  String get disc_forensicToxicology => 'Sud toksikologiyasi';

  @override
  String get disc_forensicChemistry => 'Sud kimyosi';

  @override
  String get disc_forensicBiochemistry => 'Sud biokimyosi';

  @override
  String get disc_analyticalScience => 'Analitik fan';

  @override
  String get disc_forensicBiology => 'Sud biologiyasi';

  @override
  String get disc_forensicGenetics => 'Sud genetikasi / DNK';

  @override
  String get disc_forensicHistology => 'Sud gistologiyasi';

  @override
  String get disc_forensicAnthropology => 'Sud antropologiyasi';

  @override
  String get disc_forensicOdontology => 'Sud odontologiyasi';

  @override
  String get disc_forensicMicrobiology => 'Sud mikrobiologiyasi';

  @override
  String get disc_forensicEntomology => 'Sud entomologiyasi';

  @override
  String get disc_humanIdentification => 'DVI / shaxsni aniqlash';

  @override
  String get disc_laboratoryQuality => 'Laboratoriya sifati va validatsiya';

  @override
  String get disc_evidenceHandling => 'Ashyoviy dalillar va saqlash zanjiri';

  @override
  String get disc_educationResearch => 'Ta’lim va tadqiqot';

  @override
  String get discGroupMedicine => 'Tibbiyot va patologiya';

  @override
  String get discGroupToxChem => 'Toksikologiya va kimyo';

  @override
  String get discGroupBioId => 'Biologiya va identifikatsiya';

  @override
  String get discGroupLab => 'Laboratoriya va sifat';

  @override
  String get discGroupEdu => 'Ta’lim va tadqiqot';

  @override
  String get disciplinesTitle => 'Sud-ekspert fanlari';

  @override
  String get disciplinesIntro =>
      'FORENSIC EXPERT shu fanlarni qamrab oladi. Ma’lumotlar bosqichma-bosqich, faqat manba va ekspert tekshiruvi bilan qo‘shiladi — bo‘sh fan «hali manbali ma’lumot yo‘q» degani, «bilim yo‘q» degani emas.';

  @override
  String disciplineRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta manbali yozuv',
      zero: 'Hali manbali yozuv yo‘q',
    );
    return '$_temp0';
  }

  @override
  String get disciplineReferenceOnly =>
      'Faqat professional ma’lumotnoma qamrovi';

  @override
  String get disciplineModules => 'Modullar';

  @override
  String get disciplineTopics => 'Rejalashtirilgan mavzular tuzilmasi';

  @override
  String get disciplineEmpty =>
      'Bu fanda hali manbali kontent yo‘q. Yozuvlar faqat tekshiriladigan manba va ekspert tekshiruvi bilan qo‘shiladi.';

  @override
  String get jurisdictionsTitle => 'Huquq va yurisdiksiyalar';

  @override
  String get jurisdictionCurrent => 'Joriy yurisdiksiya';

  @override
  String get jurisdictionLayersTitle => 'Uchta alohida qatlam';

  @override
  String get layerGlobalCore =>
      'Global ilmiy yadro — barcha davlatlarda bir xil';

  @override
  String get layerIntlStandards =>
      'Xalqaro standartlar va usullar — qabul qilinmaguncha qonun emas';

  @override
  String get layerCountryLaw =>
      'Davlat / yurisdiksiya qonuni va protseduralari — faqat tanlangan yurisdiksiya uchun';

  @override
  String get jurisdictionViewDetails => 'Huquqiy va protsessual qatlam';

  @override
  String get jurisdictionWithContent => 'Huquqiy yozuvlari bor yurisdiksiyalar';

  @override
  String get jurisdictionSearchHint => 'Davlat yoki ISO kodini qidirish';

  @override
  String get jurisdictionNotVerified =>
      'Bu yurisdiksiya uchun kontent hali tekshirilmagan. Boshqa davlat qonunlari hech qachon uning o‘rniga ko‘rsatilmaydi.';

  @override
  String get jurisdictionPilotContent =>
      'Huquqiy yozuvlar · yuridik tekshiruvda';

  @override
  String get jurisdictionNoContentShort => 'Kontent hali tekshirilmagan';

  @override
  String jurisdictionChain(String chain) {
    return 'Qo‘llanish zanjiri: $chain';
  }

  @override
  String get jurisdictionGlobalWorks =>
      'Global ilmiy kontent yurisdiksiya tanlamasdan ishlaydi. Yurisdiksiya faqat qonunlar, nazoratdagi moddalar ro‘yxatlari va milliy protseduralar uchun kerak.';

  @override
  String get jurisdictionInstruments => 'Rasmiy hujjatlar';

  @override
  String get jurisdictionIntlLayer => 'Xalqaro qatlam (hamma uchun)';

  @override
  String get jurisdictionOwnLayer => 'Aniq yurisdiksiya qatlami';

  @override
  String get jurisdictionCountryNames =>
      'Davlat nomlari: Unicode CLDR. Ro‘yxat faqat tanlash imkonini beradi — huquqiy kontent bor degani emas.';

  @override
  String get docKindLaw => 'QONUN';

  @override
  String get docKindRegulation => 'NORMATIV HUJJAT';

  @override
  String get docKindStandard => 'STANDART';

  @override
  String get docKindGuideline => 'QO‘LLANMA';

  @override
  String get docKindMethod => 'USUL';

  @override
  String get docKindSop => 'SOP';

  @override
  String get docKindArticle => 'ILMIY MAQOLA';

  @override
  String get docKindOfficial => 'RASMIY HUJJAT';

  @override
  String get bindingLegal =>
      'Kuchda bo‘lsa, o‘z yurisdiksiyasida qonuniy majburiy';

  @override
  String get bindingVoluntary =>
      'Qonun yoki akkreditatsiya qabul qilmaguncha ixtiyoriy';

  @override
  String get bindingAdvisory => 'Tavsiyaviy — qonuniy majburiy emas';

  @override
  String get bindingInstitutional =>
      'Faqat chiqargan muassasa ichida amal qiladi';

  @override
  String get bindingScientific => 'Ilmiy dalil — normativ hujjat emas';

  @override
  String get instrNumber => 'Rasmiy raqam';

  @override
  String get instrPublished => 'E’lon qilingan';

  @override
  String get instrEffectiveFrom => 'Kuchga kirgan';

  @override
  String get instrEffectiveTo => 'Amal qilish muddati';

  @override
  String get instrAmended => 'Oxirgi o‘zgartirish';

  @override
  String get instrVersion => 'Versiya / tahrir';

  @override
  String get instrLegalStatus => 'Huquqiy holat';

  @override
  String get instrLanguage => 'Rasmiy til';

  @override
  String get instrTranslation => 'Tarjima';

  @override
  String get instrLastVerified => 'Oxirgi tekshiruv';

  @override
  String get instrReview => 'Tekshiruv holati';

  @override
  String get instrSource => 'Rasmiy manba';

  @override
  String get instrAuthority => 'Vakolatli organ';

  @override
  String get translationNone => 'Faqat asl tilda';

  @override
  String get libraryHubIntro =>
      'Ilmiy yozuvlar uchun yagona markaz. Har bir yozuvda manba va tekshiruv holati ko‘rsatiladi.';

  @override
  String get libraryStandards => 'Standartlar va rasmiy hujjatlar';

  @override
  String libraryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta yozuv',
      zero: 'Hali yozuv yo‘q',
    );
    return '$_temp0';
  }

  @override
  String get libraryGroupScience => 'Ilmiy yozuvlar';

  @override
  String get libraryGroupDocs => 'Hujjatlar va dalillar';

  @override
  String get standardsIntro =>
      'Standart, qo‘llanma va usullar turi bilan belgilangan. Faqat qonun va normativ hujjatlar qonuniy majburiy — va faqat o‘z yurisdiksiyasida.';

  @override
  String get researchFilterPeer => 'Faqat taqrizdan o‘tgan';

  @override
  String get researchFilterOpen => 'Ochiq kirish';

  @override
  String get researchPeriodAll => 'Istalgan yil';

  @override
  String get researchPeriodRecent => '2020 va keyin';

  @override
  String get researchPeriod2010 => '2010–2019';

  @override
  String get researchPeriodOlder => '2010 gacha';

  @override
  String get researchDisciplineAll => 'Barcha fanlar';

  @override
  String get researchDiscipline => 'Fan';

  @override
  String get researchPeriod => 'Davr';

  @override
  String get researchClear => 'Filtrlarni tozalash';

  @override
  String get researchRelevance => 'Sud-ekspert dolzarbligi';

  @override
  String get relevanceUnassessed =>
      'Taqrizchi hali baholamagan (dalil darajasidan alohida)';

  @override
  String get relevanceDirect => 'Bevosita';

  @override
  String get relevanceSupporting => 'Yordamchi';

  @override
  String get relevanceBackground => 'Fon ma’lumoti';

  @override
  String get researchOpenAccess => 'Ochiq kirish';

  @override
  String get researchOpenPmc => 'Ha — PubMed Central';

  @override
  String get researchOpenLink => 'Ha — to‘liq matnga bepul havola';

  @override
  String get researchOpenUnknown => 'Aniqlanmagan';

  @override
  String get researchDocKind => 'Hujjat turi';

  @override
  String get detailOnThisPage => 'Shu sahifada';

  @override
  String get detailNotYetSourced => 'Hali manbasiz';

  @override
  String get detailJurisdictionShort => 'Yurisdiksiya';

  @override
  String searchMetaboliteOf(String name) {
    return 'Metabolit: $name';
  }

  @override
  String get aiBlockedOfficial =>
      'Forensic AI rasmiy ekspert xulosasi, o‘lim guvohnomasi yoki zaharlanish bo‘yicha qat’iy xulosa yozmaydi. U manbalarni topish va solishtirishda yordam beradi.';

  @override
  String get aiJurisdictionRequired =>
      'Bu huquqiy yoki protsessual savol. Avval yurisdiksiyani tanlang — Forensic AI uni hech qachon o‘zi taxmin qilmaydi.';

  @override
  String get aiSelectJurisdiction => 'Yurisdiksiyani tanlash';

  @override
  String get aiSectionEvidenceStatus => 'Dalil holati';

  @override
  String get aiSampleEvidenceStatus =>
      'Har bir fikr uchun u olingan yozuvning tekshiruv holati va dalil darajasi ko‘rsatiladi.';

  @override
  String get aiSectionJurisdiction => 'Yurisdiksiya';

  @override
  String get aiSampleJurisdiction =>
      'Huquqiy fikrlar faqat tanlangan yurisdiksiyaga tegishli; ilmiy fikrlar global.';

  @override
  String get aiSectionRelated => 'Bog‘liq yozuvlar';

  @override
  String get aiSampleRelated =>
      'Javobda ishlatilgan modda, usul va tadqiqot yozuvlariga havolalar.';

  @override
  String get tpl_overview => 'Umumiy ma’lumot';

  @override
  String get tpl_names => 'Nomlar va sinonimlar';

  @override
  String get tpl_classification => 'Tasnif';

  @override
  String get tpl_metabolism => 'Metabolizm';

  @override
  String get tpl_metabolites => 'Metabolitlar';

  @override
  String get tpl_specimens => 'Namunalar';

  @override
  String get tpl_screening => 'Skrining';

  @override
  String get tpl_confirmation => 'Tasdiqlovchi tahlil';

  @override
  String get tpl_analyticalMethods => 'Analitik usullar';

  @override
  String get tpl_reportedConcentrations => 'Xabar qilingan konsentratsiyalar';

  @override
  String get tpl_interpretation => 'Talqin';

  @override
  String get tpl_postmortem => 'O‘limdan keyingi jihatlar';

  @override
  String get tpl_stability => 'Barqarorlik';

  @override
  String get tpl_interferences => 'Interferensiyalar';

  @override
  String get tpl_jurisdiction => 'Yurisdiksiya qonuni va usullari';

  @override
  String get tpl_research => 'Tadqiqotlar va dalillar';

  @override
  String get tpl_sources => 'Manbalar';

  @override
  String get tpl_principle => 'Prinsip';

  @override
  String get tpl_forensicUse => 'Sud-ekspert qo‘llanishi';

  @override
  String get tpl_samplePreparation => 'Namuna tayyorlash';

  @override
  String get tpl_instrumentation => 'Asbob-uskunalar';

  @override
  String get tpl_qualitativeQuantitative => 'Sifat / miqdoriy qo‘llanish';

  @override
  String get tpl_validation => 'Validatsiya talablari';

  @override
  String get tpl_interference => 'Interferensiya';

  @override
  String get tpl_limitations => 'Cheklovlar';

  @override
  String get tpl_qc => 'Sifat nazorati';

  @override
  String get tpl_relatedSubstances => 'Bog‘liq moddalar';

  @override
  String get tpl_relatedReagents => 'Bog‘liq reagentlar';

  @override
  String get tpl_purpose => 'Maqsad';

  @override
  String get tpl_composition => 'Tarkib';

  @override
  String get tpl_preparation => 'Tayyorlash';

  @override
  String get tpl_storageStability => 'Saqlash va barqarorlik';

  @override
  String get tpl_safety => 'Xavfsizlik';

  @override
  String get tpl_disposal => 'Utilizatsiya';

  @override
  String get tpl_linkedMethods => 'Bog‘liq usul va testlar';

  @override
  String get tpl_technology => 'Texnologiya';

  @override
  String get tpl_targetSpecimen => 'Nishon va namuna';

  @override
  String get tpl_cutoff => 'Chegara qiymati (cut-off)';

  @override
  String get tpl_performance => 'Sezgirlik va o‘ziga xoslik';

  @override
  String get tpl_crossReactivity => 'Kesishgan reaktivlik';

  @override
  String get tpl_falseResults => 'Soxta musbat / manfiy natijalar';

  @override
  String get tpl_marker => 'Marker';

  @override
  String get tpl_specimen => 'Namuna';

  @override
  String get tpl_collectionContext => 'Namuna olish sharoiti';

  @override
  String get tpl_postmortemLimitations => 'O‘limdan keyingi cheklovlar';

  @override
  String get tpl_analyticalMethod => 'Analitik usul';

  @override
  String get tpl_interpretationLimitations => 'Talqin cheklovlari';

  @override
  String get tpl_definition => 'Ta’rif';

  @override
  String get tpl_findings => 'Topilmalar';

  @override
  String get tpl_methods => 'Usullar';

  @override
  String templateCoverage(int filled, int total) {
    return 'Manbali bo‘limlar: $filled / $total';
  }

  @override
  String get provWhereFrom => 'Bu ma’lumot qayerdan?';

  @override
  String get provSheetTitle => 'Ushbu da’voning kelib chiqishi';

  @override
  String get provStatement => 'Da’vo';

  @override
  String provLocation(String loc) {
    return 'Manbadagi joyi: $loc';
  }

  @override
  String get provSource => 'Manba';

  @override
  String provTier(String tier) {
    return 'Manba darajasi $tier';
  }

  @override
  String get provTierA => 'A — rasmiy matn, standart yoki qo‘llanma';

  @override
  String get provTierB => 'B — retsenziyalangan nashr';

  @override
  String get provTierC =>
      'C — qo‘llanma, ma’lumotlar bazasi yoki ikkilamchi manba';

  @override
  String get reuseOpen => 'Ochiq foydalanish';

  @override
  String get reuseCiteOnly => 'Faqat havola — matn ko‘chirilmaydi';

  @override
  String get reuseNonCommercial => 'Notijoriy litsenziya';

  @override
  String get reuseLicenseRequired => 'LITSENZIYA KERAK';

  @override
  String get reuseLookup => 'Faqat qidiruv';

  @override
  String get reuseUnknown => 'Litsenziya aniqlanmagan';

  @override
  String get srcLifecycleCurrent => 'Retraksiya qilinmagan';

  @override
  String get srcLifecycleRetracted => 'RETRAKSIYA QILINGAN';

  @override
  String get srcLifecycleSuperseded => 'ALMASHTIRILGAN';

  @override
  String get srcLifecycleWithdrawn => 'QAYTARIB OLINGAN';

  @override
  String provCheckedOn(String date) {
    return 'Retraksiya tekshiruvi: $date';
  }

  @override
  String get provArchiveHash => 'Arxiv nusxasi SHA-256';

  @override
  String provSourceVersion(String v) {
    return 'Versiya: $v';
  }

  @override
  String get provLifecycle => 'Hayot sikli';

  @override
  String get lcCurrent => 'Joriy';

  @override
  String get lcNeedsReview => 'Tekshirilmagan';

  @override
  String get lcOutdated => 'Eskirgan';

  @override
  String get lcSuperseded => 'Almashtirilgan';

  @override
  String get lcRetracted => 'Manba retraksiya qilingan';

  @override
  String get lcRejected => 'Rad etilgan';

  @override
  String get provHumanVerified =>
      'Malakali taqrizchilar tomonidan tasdiqlangan';

  @override
  String get provNotVerified =>
      'Ma’lumot hali ekspert tomonidan tasdiqlanmagan';

  @override
  String provRequiredRole(String role) {
    return 'Kerakli taqrizchi: $role';
  }

  @override
  String provReviewsRecorded(int n) {
    return 'Ushbu versiya bo‘yicha taqrizchi harakatlari: $n';
  }

  @override
  String provClaimId(String id, int v) {
    return 'Yozuv ID: $id · v$v';
  }

  @override
  String get roleForensicToxicology => 'Sud toksikologiyasi';

  @override
  String get roleForensicMedicine => 'Sud tibbiyoti';

  @override
  String get roleLaboratory => 'Laboratoriya / analitika';

  @override
  String get roleBiochemistry => 'Sud biokimyosi';

  @override
  String get roleLegal => 'Huquq / yurisdiksiya';

  @override
  String get roleTranslation => 'Tarjima';

  @override
  String get roleEditor => 'Ilmiy muharrir / administrator';

  @override
  String get bannerRetracted =>
      'Manba retraksiya qilingan — da’vo shaffoflik uchun saqlangan, lekin joriy dalil emas.';

  @override
  String get bannerSuperseded =>
      'Ushbu da’voning barcha manbalari almashtirilgan.';

  @override
  String get bannerOutdated => 'Taqrizchi tomonidan eskirgan deb belgilangan.';

  @override
  String get bannerConflict =>
      'DALILLAR ZIDDIYATI — manbalar mos kelmaydi yoki ustma-ust tushadi. Solishtirish uchun bosing.';

  @override
  String get conflictsTitle => 'Dalillar ziddiyatlari';

  @override
  String get conflictsIntro =>
      'Ziddiyatlar yashirilmaydi. Ularni faqat malakali taqrizchi hal qiladi; ilova «to‘g‘ri» variantni tanlamaydi.';

  @override
  String get conflictKindDirect => 'To‘g‘ridan-to‘g‘ri qarama-qarshilik';

  @override
  String get conflictKindContext => 'Sharoitga bog‘liq';

  @override
  String get conflictKindOverlap =>
      'Qiymatlar kontekstlar orasida ustma-ust tushadi';

  @override
  String get conflictKindCharacterisation => 'Turlicha tavsiflangan';

  @override
  String get conflictQuestion => 'Savol';

  @override
  String get conflictStatements => 'Ishtirok etgan da’volar';

  @override
  String get conflictStateOpen => 'Ochiq — taqrizchi qarori kutilmoqda';

  @override
  String get conflictStateResolved => 'Taqrizchi tomonidan hal qilingan';

  @override
  String get conflictNoteLabel => 'Manbalar nima deydi';

  @override
  String get ctxTitle => 'Kontekst (faqat manbada aytilgani)';

  @override
  String get ctxSpecimen => 'Namuna';

  @override
  String get ctxSampling => 'Namuna olish';

  @override
  String get ctxSubject => 'Sub’ekt';

  @override
  String get ctxPopulation => 'Populyatsiya';

  @override
  String get ctxStudySize => 'Holatlar soni';

  @override
  String get ctxCaseType => 'Holat turi';

  @override
  String get ctxCoIntoxicants => 'Birga aniqlangan moddalar';

  @override
  String get ctxMethod => 'Analitik usul';

  @override
  String get ctxTiming => 'Vaqt';

  @override
  String get ctxStatistic => 'Keltirilgan qiymatlar';

  @override
  String get ctxReporting => 'Ma’lumot kelib chiqishi';

  @override
  String get ctxLimitations => 'Cheklovlar';

  @override
  String get ctxNotStated => 'manbada ko‘rsatilmagan';

  @override
  String get ctxPostmortem => 'o‘limdan keyin';

  @override
  String get ctxAntemortem => 'hayotligida';

  @override
  String get ctxMixed => 'aralash';

  @override
  String get ctxDeceased => 'vafot etganlar';

  @override
  String get ctxLiving => 'tiriklar';

  @override
  String get ctxPrimary => 'Keltirilgan tadqiqotning birlamchi ma’lumoti';

  @override
  String get ctxSecondary => 'Boshqa tadqiqotdan iqtibos';

  @override
  String get ctxNotAssessed => 'Hali baholanmagan';

  @override
  String get ctxAutoMinimal =>
      'Ushbu yozuv bo‘yicha tekshirilgan kontekstual ma’lumot hozircha mavjud emas.';

  @override
  String get metRelationsTitle => 'Metabolitlar (manbali bog‘lanishlar)';

  @override
  String get metKindMetabolite => 'Metabolit';

  @override
  String get metKindActive => 'Faol metabolit';

  @override
  String get metKindInactive => 'Nofaol metabolit';

  @override
  String get metKindMarker => 'Marker';

  @override
  String get metKindArtifact => 'Artefakt';

  @override
  String get metRoleNote =>
      'Rol (faol, marker…) faqat manba matnida aytilgan bo‘lsa ko‘rsatiladi.';

  @override
  String metParentOf(String name) {
    return 'Asosiy modda: $name';
  }

  @override
  String get specimensTitle => 'Namunalar';

  @override
  String get specimensIntro =>
      'Manbali da’volar va keltirilgan qiymatlarga ega namuna turlari. Keltirilgan qiymatlar chegara emas.';

  @override
  String get specimenAbout => 'Namuna haqida';

  @override
  String get specimenMeasured => 'Shu namunadagi keltirilgan qiymatlar';

  @override
  String get specimenNoClaims => 'Hozircha manbali da’vo yo‘q.';

  @override
  String get specimenCatFluid => 'Biologik suyuqlik';

  @override
  String get specimenCatTissue => 'To‘qima';

  @override
  String get specimenCatKeratinous => 'Keratinli matritsa';

  @override
  String get specimenCatContent => 'Tarkib';

  @override
  String specimenRecords(int n) {
    return '$n ta yozuv';
  }

  @override
  String get detailMeasuredIn => 'Qiymat keltirilgan namunalar';

  @override
  String get detailScreenedBy => 'Skrining testlari (skrining ≠ tasdiqlash)';

  @override
  String get chainTitle => 'Bilim zanjiri';

  @override
  String get chainOpen => 'Bilim zanjirini ko‘rsatish';

  @override
  String get chainIntro =>
      'Quyidagi har bir bog‘lanishning asosi bor (manbali da’vo, rasmiy ro‘yxat yozuvi yoki katalog yozuvi). Ko‘rish uchun bosing.';

  @override
  String get chainMetabolites => 'Metabolitlar';

  @override
  String get chainSpecimens => 'Namunalar';

  @override
  String get chainScreening => 'Skrining';

  @override
  String get chainConfirmation => 'Tasdiqlovchi usullar';

  @override
  String get chainReagents => 'Reagentlar';

  @override
  String get chainResearch => 'Tadqiqotlar';

  @override
  String get chainStandards => 'Standartlar';

  @override
  String get chainLegal => 'Huquqiy holat';

  @override
  String get chainNone => 'Hozircha manbali bog‘lanish yo‘q';

  @override
  String chainBasis(String id) {
    return 'Asos: $id';
  }

  @override
  String chainResearchCount(int n) {
    return '$n ta bog‘liq nashr';
  }

  @override
  String get stdCatalogue => 'Standartlar katalogi (faqat metama’lumotlar)';

  @override
  String get stdStatusCurrent => 'Amaldagi';

  @override
  String get stdStatusProposed => 'Loyiha — hali nashr etilmagan';

  @override
  String stdStatusSuperseded(String id) {
    return 'Almashtirilgan: $id';
  }

  @override
  String get stdStatusWithdrawn => 'Bekor qilingan';

  @override
  String get stdStatusUnknown => 'Holati aniqlanmagan';

  @override
  String stdVerifiedFrom(String date) {
    return 'Metama’lumotlar $date da nashriyot yoki registrda tekshirilgan';
  }

  @override
  String get stdTextNotReproduced => 'Standart matni ilovada ko‘chirilmaydi.';

  @override
  String get reviewTitle => 'Ilmiy tekshiruv holati';

  @override
  String get reviewHumanVerified => 'Inson tomonidan tasdiqlangan';

  @override
  String get reviewReviewed => 'Ko‘rib chiqilgan';

  @override
  String get reviewAwaiting => 'Tekshiruv kutmoqda';

  @override
  String get reviewRetracted => 'Manbasi retraksiya qilingan da’volar';

  @override
  String get reviewActions => 'Yozilgan taqrizchi harakatlari';

  @override
  String get reviewReviewers => 'Ro‘yxatdagi taqrizchilar';

  @override
  String get reviewOpenConflicts => 'Ochiq dalillar ziddiyatlari';

  @override
  String get reviewExplain =>
      'Da’vo faqat o‘z sohasidagi ikki mustaqil malakali taqrizchi joriy versiyani tasdiqlagandan keyin TASDIQLANGAN bo‘ladi. Ilova va uning mualliflari hech narsani o‘zlari tasdiqlangan deb belgilay olmaydi.';

  @override
  String get reviewRolesTitle => 'Taqrizchi rollari va huquqlari';

  @override
  String get reviewRoleApprove =>
      'O‘z sohasida tasdiqlashi yoki rad etishi mumkin';

  @override
  String get reviewRoleFlagOnly =>
      'Ziddiyat, eskirganlikni belgilashi va o‘zgartirish so‘rashi mumkin — tasdiqlay olmaydi';

  @override
  String get reviewActionsList => 'Mumkin bo‘lgan harakatlar';

  @override
  String get libraryConflicts => 'Dalillar ziddiyatlari';

  @override
  String get libraryReview => 'Tekshiruv holati';

  @override
  String get methodPublishedNote =>
      'Nashr etilgan ilmiy usul — biror laboratoriya uchun validatsiya qilingan tartib emas.';

  @override
  String get reagentConcentration => 'Konsentratsiya';

  @override
  String get reagentSolvent => 'Erituvchi';

  @override
  String get reagentPh => 'pH';

  @override
  String get reagentExpiry => 'Yaroqlilik muddati';

  @override
  String get reagentPpe => 'Shaxsiy himoya vositalari';

  @override
  String get screeningResultType => 'Natija turi (sifat / yarim miqdoriy)';

  @override
  String get screeningDetectionWindow => 'Aniqlash oynasi (sharoitga bog‘liq)';

  @override
  String get screeningInterference => 'Interferensiya';

  @override
  String get evInternationalStandard => 'Xalqaro standart';

  @override
  String get evGuideline => 'Qo‘llanma';

  @override
  String get evPublishedValidated => 'Nashr etilgan validatsiyalangan usul';

  @override
  String get evNationalMethod => 'Milliy metodika';

  @override
  String get evLocalSop => 'Mahalliy SOP havolasi';

  @override
  String get evEducationalSummary => 'Ta’limiy umumlashma';

  @override
  String get disciplineSourcedTopics => 'Manbali mavzular';

  @override
  String get aiRagAnswer => 'Javob';

  @override
  String get aiRagJurisdictionNotApplicable =>
      'Huquqiy savol emas — yurisdiksiya qo‘llanmadi';

  @override
  String get aiLimNotVerified =>
      'Dalillar hali malakali taqrizchilar tomonidan tasdiqlanmagan.';

  @override
  String get aiLimConflict =>
      'Manbalar mos kelmaydi yoki ustma-ust tushadi — DALILLAR ZIDDIYATI ga qarang.';

  @override
  String aiLimRetracted(int n) {
    return 'Retraksiya qilingan yoki almashtirilgan manbalardan $n ta da’vo chiqarib tashlandi.';
  }

  @override
  String get aiLimExpert =>
      'Muayyan holatni talqin qilish malakali ekspertni talab qiladi.';

  @override
  String get aiLimMock =>
      'Namoyish provayderi — haqiqiy AI javobi yaratilmadi.';

  @override
  String get instrOriginalTitle => 'Asl nomi';

  @override
  String legalMissingFields(String fields) {
    return 'Bu hujjat uchun ko‘rsatilmagan: $fields';
  }

  @override
  String get lfOfficialTitle => 'Rasmiy nomi';

  @override
  String get lfOriginalTitle => 'Asl tildagi nomi';

  @override
  String get lfArticle => 'Modda / bo‘lim';

  @override
  String get lfOfficialUrl => 'Rasmiy havola';

  @override
  String get lfReviewStatus => 'Tekshiruv holati';

  @override
  String get legalDomainsTitle => 'Huquqiy sohalar';

  @override
  String legalDomainRecords(int n) {
    return '$n ta yozuv';
  }

  @override
  String get legalDomainNoContent => 'Tasdiqlangan kontent yo‘q';

  @override
  String get compareTopicControlStatus => 'Nazorat holati';

  @override
  String get ldExpertStatus => 'Sud eksperti maqomi';

  @override
  String get ldEvidenceHandling => 'Dalillar bilan ishlash';

  @override
  String get ldChainOfCustody => 'Saqlash zanjiri';

  @override
  String get ldSpecimenCollection => 'Namuna olish';

  @override
  String get ldDeathInvestigation => 'O‘limni tekshirish';

  @override
  String get ldAutopsy => 'Yorib ko‘rish (autopsiya)';

  @override
  String get ldToxicology => 'Toksikologiya';

  @override
  String get ldAlcoholDriving => 'Alkogol va transport boshqarish';

  @override
  String get ldControlledSubstances => 'Nazorat ostidagi moddalar';

  @override
  String get ldReporting => 'Hisobot berish';

  @override
  String get ldLaboratoryStandards => 'Laboratoriya standartlari';

  @override
  String get ldRetentionStorage => 'Saqlash muddatlari';

  @override
  String get ldTestimony => 'Sudda ko‘rsatma berish';

  @override
  String get ldQualityAccreditation => 'Sifat va akkreditatsiya';

  @override
  String get deleteLocalData => 'Qurilmadagi ma’lumotlarni o‘chirish';

  @override
  String get deleteLocalDataBody =>
      'Saralanganlar, qidiruv tarixi, yaqinda ko‘rilgan yozuvlar va darslar holati faqat shu qurilmadan o‘chiriladi. Ilmiy baza, hisobingiz va do‘kondagi obunalarga ta’sir qilmaydi — hisobni o‘chirish uchun «Hisobni o‘chirish» dan foydalaning.';

  @override
  String get deleteLocalDataConfirm => 'O‘chirish';

  @override
  String get deleteLocalDataDone => 'Qurilmadagi ma’lumotlar o‘chirildi';

  @override
  String get tierStudentPro => 'Talaba Pro';

  @override
  String get tierProfessionalPro => 'Mutaxassis Pro';

  @override
  String get tierInstitution => 'Muassasa';

  @override
  String get tierCurrent => 'Joriy tarif';

  @override
  String get tierFreeF1 => 'Ogohlantirish va manbalari bilan oflayn ilmiy baza';

  @override
  String get tierFreeF2 => 'Qidiruv va tanlangan ma’lumotnoma yozuvlari';

  @override
  String get tierFreeF3 => 'Oddiy kalkulyatorlar';

  @override
  String get tierStudentF1 =>
      'To‘liq ma’lumotnoma: moddalar, usullar, reaktivlar, sud tibbiyoti, standartlar, yurisdiksiyalar';

  @override
  String get tierStudentF2 =>
      'Barcha kurslar, testlar, kartochkalar va imtihonga tayyorgarlik';

  @override
  String get tierStudentF3 => 'Cheklanmagan qidiruv natijalari';

  @override
  String get tierProF1 => 'Talaba Pro’dagi barcha imkoniyatlar';

  @override
  String get tierProF2 =>
      'Professional kalkulyatorlar va laboratoriya vositalari';

  @override
  String get tierProF3 => 'Analitik usullar, tadqiqot va dalillar vositalari';

  @override
  String get tierProF4 => 'Professional AI funksiyalari — AI xizmati ulanganda';

  @override
  String get periodMonthly => 'Oylik';

  @override
  String get periodYearly => 'Yillik';

  @override
  String get periodUnknown => 'Obuna';

  @override
  String offerPriceLine(String price, String period) {
    return '$price · $period';
  }

  @override
  String get offerSubscribe => 'Obuna bo‘lish';

  @override
  String get offerPriceFromStore => 'Narxni App Store / Google Play ko‘rsatadi';

  @override
  String get subscriptionTerms =>
      'Obuna bekor qilinmaguncha avtomatik yangilanadi. To‘lov App Store / Google Play hisobingizdan olinadi. Davr tugashidan kamida 24 soat oldin do‘kon hisobi sozlamalarida bekor qilishingiz mumkin.';

  @override
  String get manageSubscription => 'Obunani boshqarish';

  @override
  String get manageSubscriptionFailed =>
      'Do‘kondagi obuna sozlamalarini ochib bo‘lmadi.';

  @override
  String get planLabel => 'Tarif';

  @override
  String get subscriptionStateLabel => 'Obuna holati';

  @override
  String get stActive => 'Faol';

  @override
  String get stExpired => 'Muddati tugagan';

  @override
  String get stGrace => 'To‘lov muammosi — imtiyozli davr';

  @override
  String get stBillingRetry => 'To‘lov muammosi — kirish to‘xtatilgan';

  @override
  String stCancelled(String date) {
    return 'Bekor qilingan — $date gacha amal qiladi';
  }

  @override
  String get stCancelledNoDate =>
      'Bekor qilingan — davr oxirigacha amal qiladi';

  @override
  String get stRevoked => 'Do‘kon tomonidan bekor qilingan';

  @override
  String get stUnknown => 'Holat noma’lum';

  @override
  String get stNone => 'Obuna yo‘q';

  @override
  String stRenewsOn(String date) {
    return 'Yangilanish yoki tugash sanasi: $date';
  }

  @override
  String get accountOptionalNote =>
      'Hisob ixtiyoriy. Oflayn ilmiy ma’lumotnoma tizimga kirmasdan ishlaydi; hisob faqat bulut xizmatlari uchun kerak.';

  @override
  String get accountNotConnected =>
      'Hisob xizmati hozircha mavjud emas. Barcha oflayn funksiyalar ishlaydi.';

  @override
  String get accountTestBackend =>
      'SINOV hisob serveri — haqiqiy xat yuborilmaydi, ma’lumot faqat xotirada.';

  @override
  String get accountSignIn => 'Kirish';

  @override
  String get accountCreate => 'Hisob yaratish';

  @override
  String get accountSignOut => 'Chiqish';

  @override
  String get accountSignedOut => 'Hisobdan chiqildi';

  @override
  String get accountEmail => 'Elektron pochta';

  @override
  String get accountPassword => 'Parol';

  @override
  String get accountConfirmPassword => 'Parolni tasdiqlang';

  @override
  String get accountShowPassword => 'Parolni ko‘rsatish';

  @override
  String get accountHidePassword => 'Parolni yashirish';

  @override
  String get accountVerified => 'Elektron pochta tasdiqlangan';

  @override
  String get accountNotVerified => 'Elektron pochta tasdiqlanmagan';

  @override
  String get accountVerifyNow => 'Elektron pochtani tasdiqlash';

  @override
  String get accountTermsAccept =>
      'Foydalanish shartlari va Maxfiylik siyosatini qabul qilaman';

  @override
  String get accountMinimalData =>
      'Faqat elektron pochta so‘raladi. Kasbiy, ish bo‘yicha yoki shaxsiy ma’lumot yig‘ilmaydi.';

  @override
  String get passwordRulesTitle => 'Parol talablari';

  @override
  String pwRuleMinLength(int n) {
    return 'Kamida $n ta belgi';
  }

  @override
  String get pwRuleLetter => 'Kamida bitta harf';

  @override
  String get pwRuleDigit => 'Kamida bitta raqam';

  @override
  String get pwRuleNotEmail => 'Elektron pochta bilan bir xil emas';

  @override
  String get accountForgot => 'Parolni unutdingizmi?';

  @override
  String get accountNoAccount => 'Hisob yo‘qmi? Yarating';

  @override
  String get accountHaveAccount => 'Hisobingiz bormi? Kiring';

  @override
  String get verifyTitle => 'Elektron pochtani tasdiqlang';

  @override
  String verifyBody(int n, String email) {
    return '$email manziliga $n xonali kod yubordik. Hisobni faollashtirish uchun uni kiriting.';
  }

  @override
  String get verifyCode => 'Tasdiqlash kodi';

  @override
  String get verifySubmit => 'Tasdiqlash';

  @override
  String get verifyResend => 'Yangi kod yuborish';

  @override
  String get verifyResent =>
      'Agar hisob tasdiqlanishi kerak bo‘lsa, yangi kod yuborildi.';

  @override
  String get verifyDone => 'Elektron pochta tasdiqlandi. Hisobingiz faol.';

  @override
  String get forgotTitle => 'Parolni tiklash';

  @override
  String get forgotBody =>
      'Hisobingiz elektron pochtasini kiriting. Agar hisob mavjud bo‘lsa, tiklash kodini yuboramiz.';

  @override
  String get forgotSubmit => 'Tiklash kodini yuborish';

  @override
  String forgotSent(int minutes) {
    return 'Bu elektron pochta uchun hisob mavjud bo‘lsa, tiklash kodi yuborildi. U $minutes daqiqa amal qiladi.';
  }

  @override
  String get resetTitle => 'Yangi parol tanlang';

  @override
  String get resetCode => 'Tiklash kodi';

  @override
  String get resetNewPassword => 'Yangi parol';

  @override
  String get resetSubmit => 'Yangi parolni saqlash';

  @override
  String get resetDone => 'Parol o‘zgartirildi. Yangi parol bilan kiring.';

  @override
  String get authErrInvalidEmail =>
      'To‘g‘ri elektron pochta manzilini kiriting.';

  @override
  String get authErrWeakPassword => 'Parol talablarga javob bermaydi.';

  @override
  String get authErrMismatch => 'Parollar mos emas.';

  @override
  String get authErrTerms =>
      'Foydalanish shartlari va Maxfiylik siyosatini qabul qiling.';

  @override
  String get authErrCredentials => 'Elektron pochta yoki parol noto‘g‘ri.';

  @override
  String get authErrNotVerified =>
      'Elektron pochta hali tasdiqlanmagan. Yuborilgan kodni kiriting.';

  @override
  String get authErrCodeInvalid => 'Kod noto‘g‘ri.';

  @override
  String get authErrCodeExpired => 'Kod muddati tugagan. Yangisini so‘rang.';

  @override
  String get authErrAlreadyVerified =>
      'Bu elektron pochta allaqachon tasdiqlangan. Kirishingiz mumkin.';

  @override
  String get authErrTooMany =>
      'Urinishlar juda ko‘p. Bir daqiqa kutib, qayta urinib ko‘ring.';

  @override
  String get authErrOffline =>
      'Internet aloqasi yo‘q. Oflayn funksiyalar ishlashda davom etadi.';

  @override
  String get authErrServer =>
      'Hisob xizmati vaqtincha ishlamayapti. Keyinroq qayta urinib ko‘ring.';

  @override
  String get authErrNotConfigured => 'Hisob xizmati hozircha mavjud emas.';

  @override
  String get authErrRecentLogin =>
      'Parol noto‘g‘ri. Davom etish uchun joriy parolni tasdiqlang.';

  @override
  String get authErrNotSignedIn => 'Avval hisobga kiring.';

  @override
  String get deleteAccountTitle => 'Hisobni o‘chirish';

  @override
  String get deleteAccountBody =>
      'Hisobingiz va serverlarimizdagi unga bog‘liq ma’lumotlar (elektron pochta, kirish sessiyalari, sinxronlangan ma’lumotlar, bulutdagi huquq yozuvlari) butunlay o‘chiriladi. Buni qaytarib bo‘lmaydi.';

  @override
  String get deleteAccountStoreNote =>
      'Hisobni o‘chirish App Store / Google Play obunasini bekor qilmaydi. Keyingi to‘lovlarni to‘xtatish uchun uni do‘kon hisobi sozlamalarida bekor qiling.';

  @override
  String get deleteAccountLocalNote =>
      'Qurilmadagi ma’lumotlar (saralanganlar, tarix) alohida amal: «Qurilmadagi ma’lumotlarni o‘chirish».';

  @override
  String get deleteAccountUnderstand =>
      'Buni qaytarib bo‘lmasligini tushunaman';

  @override
  String get deleteAccountPassword => 'Joriy parol';

  @override
  String get deleteAccountConfirm => 'Hisobni butunlay o‘chirish';

  @override
  String get deleteAccountFinalTitle => 'Hisob o‘chirilsinmi?';

  @override
  String get deleteAccountDone => 'Hisobingiz o‘chirildi.';

  @override
  String get aiDisclaimerLink => 'AI bo‘yicha ogohlantirish';

  @override
  String get aiDisclaimerBody =>
      'Forensic AI javoblari ilovadagi manbali lokal kontent asosida tuziladi va ekspert xulosasi emas. Ular to‘liq bo‘lmasligi yoki xato bo‘lishi mumkin, malakali taqrizchi tomonidan tekshirilmagan va sud-ekspert xulosasi, huquqiy qaror yoki davolash uchun yagona asos bo‘lmasligi kerak. Har doim keltirilgan manbalarni tekshiring va malakali ekspert bilan maslahatlashing.';

  @override
  String get accountSection => 'Hisob';

  @override
  String get subscriptionSection => 'Obuna';

  @override
  String get availNoDataTitle => 'Hozircha yozuvlar yo‘q';

  @override
  String get availNoDataBody =>
      'O‘rnatilgan ilmiy bazada bu bo‘lim uchun yozuvlar yo‘q.';

  @override
  String get availFilterTitle => 'Tanlangan filtr bo‘yicha natija yo‘q';

  @override
  String get availFilterBody =>
      'Tanlangan filtr bo‘yicha ko‘rsatish uchun tekshirilgan yozuvlar mavjud emas. Filtrni tozalang yoki butun bazadan qidiring.';

  @override
  String get availNotConnectedTitle => 'Bu versiyada mavjud emas';

  @override
  String get availNotConnectedBody =>
      'Bu funksiya uchun bu versiyada ulanmagan onlayn xizmat kerak. Barcha oflayn funksiyalar ishlashda davom etadi.';

  @override
  String get availServiceTitle => 'Xizmat vaqtincha ishlamayapti';

  @override
  String get availServiceBody =>
      'Aloqani tekshirib, keyinroq qayta urinib ko‘ring. Oflayn funksiyalar ishlashda davom etadi.';

  @override
  String get availClearFilters => 'Filtrlarni tozalash';

  @override
  String get availBrowseAll => 'Barcha yozuvlarni ko‘rish';

  @override
  String get availSearch => 'Qidirish';

  @override
  String get aiStatusPreview => 'Hozircha mavjud emas';

  @override
  String get aiPreviewPoint1 => 'Hozircha AI javobi yaratilmaydi.';

  @override
  String get aiPreviewPoint2 =>
      'Bu vaqtinchalik; ilovaning qolgan qismi oflayn ishlaydi.';

  @override
  String get aiPreviewPoint3 =>
      'Quyidagi namuna faqat javob qanday tuzilishini ko‘rsatadi.';

  @override
  String get aiPreviewPoint4 =>
      '«Manbalarni oflayn topish» lokal bazadan qidiradi va hozir ishlaydi.';

  @override
  String get aiSendUnavailable =>
      'AI vaqtincha ishlamayapti — yuborish o‘chirilgan.';

  @override
  String get concWarning =>
      'Bu qiymat alohida holat yoki tadqiqotdan olingan. Universal toksik, o‘limga olib keluvchi, terapevtik yoki huquqiy chegara sifatida talqin qilinmasligi kerak.';

  @override
  String get concTitle => 'Qayd etilgan konsentratsiya';

  @override
  String get concSubstance => 'Modda';

  @override
  String get concValue => 'Qiymat va birlik';

  @override
  String get concValueInQuote => 'Manbada keltirilganidek (iqtibosga qarang)';

  @override
  String get concLivingPostmortem => 'Tirik / o‘limdan keyin';

  @override
  String get concSourceType => 'Manba turi';

  @override
  String get concSectionCase => 'Holat tavsifi';

  @override
  String get concSectionAbstract => 'Annotatsiya';

  @override
  String get concSectionIntro => 'Kirish (umumiy ma’lumot)';

  @override
  String get concSectionResults => 'Natijalar';

  @override
  String get concSectionDiscussion => 'Muhokama';

  @override
  String get concStudyContext => 'Holat / tadqiqot konteksti';

  @override
  String get concEvidenceLevel => 'Dalil darajasi';

  @override
  String get concReviewStatus => 'Tekshiruv holati';

  @override
  String get concSource => 'Manba';

  @override
  String get concNotAvailable => 'Ma’lumot mavjud emas';

  @override
  String get concExcerpt => 'Manbadan iqtibos';

  @override
  String get calcStatusTitle => 'Holat';

  @override
  String get calcEngineLabel => 'Hisoblash moduli';

  @override
  String get calcEngineTested =>
      'Avtomatik dasturiy testlar bilan tekshirilgan — bu ilmiy ekspertiza emas';

  @override
  String get calcEngineChip => 'Modul sinovdan o‘tgan';

  @override
  String get calcReferenceLabel => 'Formula manbasi';

  @override
  String get calcInterpretationLabel => 'Talqin';

  @override
  String get calcInterpretationValue =>
      'Kontekstga bog‘liq — professional baho talab qiladi';

  @override
  String get statusRejected => 'Rad etilgan';

  @override
  String get homeHeaderSubtitle => 'Sud ekspertizasi ma’lumotnomasi';

  @override
  String get modeRoleTitle => 'Rolingiz (ixtiyoriy)';

  @override
  String get modeProfessionalNotVerified =>
      'Mutaxassis rejimini tanlash professional maqom tasdiqlanganini anglatmaydi.';

  @override
  String get modeSwitchNote =>
      'Foydalanish rejimi faqat ilova tuzilishini o‘zgartiradi. U professional tasdiqni bermaydi va bekor qilmaydi.';

  @override
  String get roleStudent => 'Talaba';

  @override
  String get roleResident => 'Rezident / stajyor';

  @override
  String get roleResearcher => 'Tadqiqotchi / o‘rganuvchi';

  @override
  String get roleForensicExpert => 'Sud eksperti';

  @override
  String get roleForensicPhysician => 'Sud-tibbiy ekspert';

  @override
  String get roleForensicToxicologist => 'Sud toksikologi';

  @override
  String get roleForensicChemist => 'Sud kimyogari';

  @override
  String get roleLaboratorySpecialist => 'Laboratoriya mutaxassisi';

  @override
  String get rolePathologist => 'Patologoanatom';

  @override
  String get roleGeneticist => 'Genetik / DNK mutaxassisi';

  @override
  String get roleForensicBiochemist => 'Sud biokimyogari';

  @override
  String get roleAnthropologist => 'Sud antropologi';

  @override
  String get roleOdontologist => 'Sud odontologi';

  @override
  String get roleOtherProfessional =>
      'Boshqa sud-ekspert / laboratoriya mutaxassisi';

  @override
  String get specForensicMedicine => 'Sud tibbiyoti';

  @override
  String get specForensicToxicology => 'Sud toksikologiyasi';

  @override
  String get specForensicChemistry => 'Sud kimyosi';

  @override
  String get specAnalyticalLaboratory => 'Analitik / laboratoriya fani';

  @override
  String get specForensicBiochemistry => 'Sud biokimyosi';

  @override
  String get specPathologyHistology => 'Patologiya / gistologiya';

  @override
  String get specGeneticsDna => 'Genetika / DNK';

  @override
  String get specForensicAnthropology => 'Sud antropologiyasi';

  @override
  String get specForensicOdontology => 'Sud odontologiyasi';

  @override
  String get specForensicRadiology => 'Sud radiologiyasi';

  @override
  String get specForensicPsychology => 'Sud psixologiyasi / psixiatriyasi';

  @override
  String get specForensicBiology => 'Sud biologiyasi';

  @override
  String get specEntomology => 'Sud entomologiyasi';

  @override
  String get specOther => 'Boshqa';

  @override
  String get scopeLegal => 'Huquq va yurisdiksiya';

  @override
  String get scopeTranslation => 'Tarjima';

  @override
  String get studyBachelor => 'Bakalavriat';

  @override
  String get studyMaster => 'Magistratura';

  @override
  String get studyResidency => 'Klinik ordinatura';

  @override
  String get studyDoctoral => 'Doktorantura';

  @override
  String get studyOther => 'Boshqa';

  @override
  String get accountChoiceTitle => 'Ilovadan hisobsiz foydalaning';

  @override
  String get accountChoiceSubtitle =>
      'Oflayn ilmiy baza, qidiruv va kalkulyatorlar hisobsiz ishlaydi. Hisob faqat bulut funksiyalari uchun kerak.';

  @override
  String get accountContinueWithout => 'Hisobsiz davom etish';

  @override
  String get accountContinueWithoutNote =>
      'Hisobni keyinroq Profil bo‘limida yaratish mumkin.';

  @override
  String get accountCreateOrSignIn => 'Hisob yaratish / Kirish';

  @override
  String get accountCloudUnavailable =>
      'Bulutdagi hisob xizmati bu versiyada ulanmagan. Oflayn funksiyalarning barchasi ishlaydi.';

  @override
  String get accountNeededFor => 'Hisob kerak bo‘ladigan funksiyalar';

  @override
  String get accountNeedVerification => 'Professional maqomni tasdiqlash';

  @override
  String get accountNeedReviews => 'Ilmiy materiallarga mutaxassis taqrizi';

  @override
  String get accountNeedSync => 'Qurilmalar o‘rtasida sinxronlash';

  @override
  String get accountNeedSubscriptions => 'Bir nechta qurilmada obuna';

  @override
  String get accountNeedCloudAi => 'Bulutli AI (ulanganda)';

  @override
  String get accountNeedInstitution => 'Muassasa funksiyalari';

  @override
  String get accountFillProfile => 'Profilni hozir to‘ldirish (ixtiyoriy)';

  @override
  String get profileLocalOnlyNote =>
      'Profil shu qurilmada saqlanadi. Faqat tasdiqlashga yuborganingizda serverga jo‘natiladi.';

  @override
  String get profileStudentTitle => 'Talaba profili';

  @override
  String get profileProTitle => 'Mutaxassis profili';

  @override
  String get profileSaved => 'Profil shu qurilmada saqlandi';

  @override
  String get profileSectionIdentity => 'Shaxsiy ma’lumotlar';

  @override
  String get profileSectionWork => 'Kasbiy ma’lumotlar';

  @override
  String get profileSectionOptional => 'Ixtiyoriy';

  @override
  String get profileStudentCannotReview =>
      'Talaba profili o‘qish uchun: u ilmiy ma’lumotni tasdiqlay olmaydi va malakali taqriz yoza olmaydi.';

  @override
  String get fieldFullName => 'F.I.Sh.';

  @override
  String get fieldCountry => 'Davlat';

  @override
  String get fieldCountryChoose => 'Davlatni tanlang';

  @override
  String get fieldCountrySearch => 'Davlatni qidirish';

  @override
  String get fieldCity => 'Shahar / viloyat (ixtiyoriy)';

  @override
  String get fieldInstitution => 'Oliy ta’lim muassasasi (ixtiyoriy)';

  @override
  String get fieldFaculty => 'Fakultet / yo‘nalish (ixtiyoriy)';

  @override
  String get fieldStudyLevel => 'Ta’lim bosqichi (ixtiyoriy)';

  @override
  String get fieldInterests => 'Qiziqish sohalari';

  @override
  String get fieldOrganization => 'Tashkilot / muassasa';

  @override
  String get fieldPosition => 'Lavozim';

  @override
  String get fieldPrimarySpecialty => 'Asosiy mutaxassislik';

  @override
  String get fieldAdditionalSpecialties => 'Qo‘shimcha mutaxassisliklar';

  @override
  String get fieldYearsExperience => 'Kasbiy tajriba (yil)';

  @override
  String get fieldEducation => 'Ma’lumoti / malakasi';

  @override
  String get fieldWorkEmail => 'Ish e-pochtasi (ixtiyoriy)';

  @override
  String get fieldPrivateHelper =>
      'Maxfiy — ochiq profilda hech qachon ko‘rsatilmaydi.';

  @override
  String get fieldLicense =>
      'Ro‘yxatdan o‘tish / litsenziya raqami (ixtiyoriy)';

  @override
  String get fieldLicenseHelper =>
      'Faqat davlatingizda bunday raqam berilsa. Maxfiy — ochiq ko‘rsatilmaydi.';

  @override
  String get fieldBio => 'Qisqa kasbiy tarjimai hol (ixtiyoriy)';

  @override
  String get fieldLanguages => 'Tillar (vergul bilan)';

  @override
  String get fieldProInterests => 'Kasbiy qiziqishlar (ixtiyoriy)';

  @override
  String get fieldShowOrganization => 'Tashkilotni ochiq profilda ko‘rsatish';

  @override
  String get fieldShowOrganizationHelper =>
      'Standart holatda o‘chiq. Ism, mutaxassislik va davlat faqat tasdiqlangandan keyin ochiq bo‘ladi.';

  @override
  String get formRequired => 'Majburiy maydon';

  @override
  String get formTooLong => 'Juda uzun';

  @override
  String get formInvalid => 'Noto‘g‘ri qiymat';

  @override
  String get formHasErrors => 'Belgilangan maydonlarni to‘g‘rilang.';

  @override
  String get actionSave => 'Saqlash';

  @override
  String get actionRemove => 'Olib tashlash';

  @override
  String get verifTitle => 'Professional maqomni tasdiqlash';

  @override
  String get verifStatusLabel => 'Joriy holat';

  @override
  String get verifUnverified => 'Tasdiqlanmagan';

  @override
  String get verifPending => 'Tekshiruv kutilmoqda';

  @override
  String get verifVerified => 'Tasdiqlangan mutaxassis';

  @override
  String get verifChangesRequested => 'Qo‘shimcha ma’lumot kerak';

  @override
  String get verifRejected => 'Rad etilgan';

  @override
  String get verifSuspended => 'Vaqtincha to‘xtatilgan';

  @override
  String get verifUnverifiedBody =>
      'Siz tasdiqlash uchun ariza bermagansiz. Barcha oflayn funksiyalar usiz ham ishlaydi.';

  @override
  String get verifPendingBody =>
      'Arizangiz vakolatli shaxs tomonidan ko‘rib chiqilishini kutmoqda.';

  @override
  String get verifVerifiedBody =>
      'Professional maqomingiz vakolatli shaxs tomonidan tasdiqlangan. Taqriz huquqi har bir soha uchun alohida beriladi.';

  @override
  String get verifChangesBody =>
      'Qo‘shimcha ma’lumot kerak. Profil yoki hujjatlarni yangilab, arizani qayta yuboring.';

  @override
  String get verifRejectedBody =>
      'Ariza tasdiqlanmadi. Yangi ariza yuborishingiz mumkin.';

  @override
  String get verifSuspendedBody =>
      'Tasdiq vaqtincha to‘xtatilgan. Taqriz huquqi faol emas.';

  @override
  String get verifServiceNotConnected =>
      'Tasdiqlash xizmati bu versiyada ulanmagan. Hozircha ariza yuborib bo‘lmaydi va hech kim tasdiqlanmaydi.';

  @override
  String get verifHowTitle => 'Tasdiqlash qanday o‘tadi';

  @override
  String get verifStep1 => 'Mutaxassis profilini to‘ldiring.';

  @override
  String get verifStep2 =>
      'Ixtiyoriy ravishda malaka hujjatini biriktiring (maxfiy saqlanadi).';

  @override
  String get verifStep3 =>
      'Vakolatli administrator yoki shu sohadagi tasdiqlangan mutaxassis ariza va hujjatni qo‘lda tekshiradi. O‘zini tasdiqlash mumkin emas.';

  @override
  String get verifStep4 => 'Taqriz huquqi har bir soha uchun alohida beriladi.';

  @override
  String get verifHumanOnly =>
      'Mutaxassis rejimini tanlash, lavozimni yozish, sertifikat yuklash yoki avtomatik/AI tekshiruv tasdiqlangan maqom bermaydi. Hujjat faqat dalil; maqom faqat qo‘lda tekshiruvdan keyin beriladi va kim tasdiqlagani, qachon, qaysi hujjat tekshirilgani va qaysi soha bo‘yicha ekani qayd etiladi.';

  @override
  String get verifApplication => 'Ariza';

  @override
  String get verifProfileMissing => 'Mutaxassis profili to‘ldirilmagan';

  @override
  String get verifSubmit => 'Arizani yuborish';

  @override
  String get verifSubmitted => 'Ariza yuborildi. Holat: tekshiruv kutilmoqda.';

  @override
  String get verifSubmitUnavailable =>
      'Tasdiqlash xizmati ulanmaguncha yuborib bo‘lmaydi.';

  @override
  String get verifSubmitNote =>
      'Ariza va hujjatlar shifrlangan aloqa orqali maxfiy omborga yuboriladi.';

  @override
  String proYearsExperience(int years) {
    return 'Tajriba: $years yil';
  }

  @override
  String proReviewCount(int count) {
    return 'Taqrizlar soni: $count';
  }

  @override
  String get proServiceNotConnected => 'Bulut xizmati bu versiyada ulanmagan.';

  @override
  String get proInvalidInput => 'Kiritilgan ma’lumotni tekshiring.';

  @override
  String get proOffline => 'Internet aloqasi yo‘q.';

  @override
  String get proServerError =>
      'Xizmat vaqtincha ishlamayapti. Keyinroq urinib ko‘ring.';

  @override
  String get credUploadTitle => 'Malaka hujjatini yuklash';

  @override
  String get credOptional => 'Ixtiyoriy';

  @override
  String credSelectedCount(int count) {
    return '$count ta fayl tanlandi';
  }

  @override
  String get credIntro =>
      'Hujjat ixtiyoriy va faqat vakolatli shaxsga arizani tekshirishda yordam beradi. Uning o‘zi tasdiqlangan maqom bermaydi.';

  @override
  String get credPrivacy =>
      'Hujjatlar maxfiy: hech qachon ochiq ko‘rsatilmaydi, ochiq havolasi yo‘q va mazmuni jurnallarga yozilmaydi. Ularni faqat vakolatli tekshiruvchi ochadi.';

  @override
  String get credNoCaseData =>
      'Ish materiallari, ashyoviy dalillar, ekspert xulosalari yoki har qanday maxfiy ish hujjatlarini yuklamang. Pasport yoki ID hujjati talab qilinmaydi.';

  @override
  String get credKindTitle => 'Hujjat turi';

  @override
  String get credProfessionalCertificate => 'Professional sertifikat';

  @override
  String get credQualificationCertificate => 'Malaka guvohnomasi';

  @override
  String get credDiploma => 'Diplom';

  @override
  String get credEmployment => 'Ish joyi / tayinlov tasdig‘i';

  @override
  String get credRegistration => 'Ro‘yxatdan o‘tish / litsenziya hujjati';

  @override
  String get credTraining => 'Tan olingan o‘quv sertifikati';

  @override
  String get credFormats =>
      'PDF, JPG yoki PNG, har biri 10 MB gacha, ko‘pi bilan 5 ta fayl.';

  @override
  String get credChooseFile => 'Faylni tanlash';

  @override
  String get credSelectedTitle => 'Tanlangan hujjatlar';

  @override
  String get credNotUploaded =>
      'Yuklanmadi: tasdiqlash xizmati ulanmagan. Fayllar faqat qurilma xotirasida turadi va ilova yopilganda o‘chadi.';

  @override
  String get credWillSendOnSubmit =>
      'Fayllar ariza bilan birga maxfiy yuboriladi.';

  @override
  String get credPickFailed => 'Faylni ochib bo‘lmadi.';

  @override
  String get credErrorEmpty => 'Fayl bo‘sh.';

  @override
  String get credErrorTooLarge => 'Fayl 10 MB dan katta.';

  @override
  String get credErrorType => 'Faqat PDF, JPG va PNG fayllar qabul qilinadi.';

  @override
  String get credErrorTooMany => '5 tadan ortiq fayl bo‘lmaydi.';

  @override
  String get reviewSectionTitle => 'Mutaxassis taqrizi';

  @override
  String get reviewEmpty =>
      'Bu material hali malakali mutaxassis tomonidan taqriz qilinmagan.';

  @override
  String get reviewWhoCanReview =>
      'Bu materialni faqat tegishli soha bo‘yicha taqriz huquqi berilgan tasdiqlangan mutaxassislar taqriz qila oladi.';

  @override
  String get reviewScopeNotAssigned =>
      'Bu yozuv uchun taqriz sohasi hali belgilanmagan.';

  @override
  String get reviewWrite => 'Taqriz yozish';

  @override
  String get reviewDecision => 'Qaror';

  @override
  String get reviewActApprove => 'Ma’qullash';

  @override
  String get reviewActRequestChange => 'Tuzatish so‘rash';

  @override
  String get reviewActConflict => 'Dalillar ziddiyatini belgilash';

  @override
  String get reviewActOutdated => 'Eskirgan deb belgilash';

  @override
  String get reviewActReject => 'Rad etish';

  @override
  String get reviewDecApprove => 'Ma’qullangan';

  @override
  String get reviewDecRequestChange => 'Tuzatish talab qilinadi';

  @override
  String get reviewDecConflict => 'Dalillar ziddiyati';

  @override
  String get reviewDecOutdated => 'Eskirgan';

  @override
  String get reviewDecReject => 'Rad etilgan';

  @override
  String get reviewStateInProgress => 'Taqriz jarayonida';

  @override
  String get reviewStateProfessional => 'Mutaxassis taqriz qilgan';

  @override
  String get reviewStateHumanVerified => 'Inson tomonidan ilmiy tasdiqlangan';

  @override
  String get reviewStateReReview => 'Qayta taqriz talab qilinadi';

  @override
  String get reviewNote => 'Taqriz matni';

  @override
  String get reviewNoteHelper =>
      'Qarorni dalillarga tayanib asoslang. Kamida 20 belgi.';

  @override
  String get reviewNoteTooShort => 'Kamida 20 belgi kerak.';

  @override
  String get reviewSourceRef => 'Tayanch manba (ixtiyoriy)';

  @override
  String get reviewSourceHelper => 'DOI, PMID yoki https havola';

  @override
  String get reviewSourceInvalid => 'DOI, PMID yoki https havolani kiriting.';

  @override
  String get reviewSubmit => 'Taqrizni yuborish';

  @override
  String get reviewSubmitted => 'Taqriz yuborildi';

  @override
  String get reviewNotVerification =>
      'Bitta taqriz materialni ilmiy tasdiqlangan qilmaydi. Tasdiq uchun tekshiruv siyosatiga ko‘ra mustaqil malakali taqrizlar kerak.';

  @override
  String reviewVersionNote(String version) {
    return 'Taqriz $version kontent versiyasiga tegishli. Kontent o‘zgarsa, qayta taqriz talab qilinadi.';
  }

  @override
  String reviewMeta(String date, String version) {
    return 'Taqriz sanasi: $date · kontent versiyasi $version';
  }

  @override
  String get reviewStale =>
      'Oldingi kontent versiyasiga yozilgan — tarixda saqlanadi; qayta taqriz talab qilinadi.';

  @override
  String get reviewPermAllowed => 'Siz bu materialni taqriz qila olasiz.';

  @override
  String get reviewPermSignIn => 'Avval hisobingizga kiring.';

  @override
  String get reviewPermNotVerified =>
      'Taqrizni faqat tasdiqlangan mutaxassislar yoza oladi.';

  @override
  String get reviewPermSuspended =>
      'Tasdig‘ingiz to‘xtatilgan; taqriz yozib bo‘lmaydi.';

  @override
  String get reviewPermScope => 'Sizda bu soha bo‘yicha taqriz huquqi yo‘q.';

  @override
  String get reviewPermStudentMode =>
      'Taqriz yozish uchun Mutaxassis rejimiga o‘ting. Tasdig‘ingiz saqlanadi.';

  @override
  String get layerSource => 'Manba biriktirilgan';

  @override
  String layerSourceCount(int count) {
    return '$count ta manba';
  }

  @override
  String get noReliableSource => 'Ishonchli manba biriktirilmagan.';

  @override
  String get layerIdentifier => 'Identifikator (DOI/PMID) tekshirilgan';

  @override
  String get layerIdentifierOk => 'Tekshirilgan';

  @override
  String get layerIdentifierPending => 'Hali tekshirilmagan';

  @override
  String get layerNotApplicable => 'Qo‘llanilmaydi';

  @override
  String get layerProfessional => 'Mutaxassis taqrizlari';

  @override
  String get layerHuman => 'Inson tomonidan ilmiy tasdiq';

  @override
  String layerHumanCount(int count, int required) {
    return '$required ta mustaqil ma’qullashdan $count tasi';
  }

  @override
  String get dashboardTitle => 'Taqrizchi ish joyi';

  @override
  String get dashboardOnlyVerified =>
      'Faqat kamida bitta soha bo‘yicha taqriz huquqi berilgan tasdiqlangan mutaxassislar uchun.';

  @override
  String get dashboardQueueEmpty => 'Bu navbatda yozuvlar yo‘q.';

  @override
  String dashboardItemMeta(
    int claims,
    int sources,
    String level,
    String version,
  ) {
    return 'Da’volar: $claims · manbalar: $sources · dalil: $level · versiya $version';
  }

  @override
  String get queueNeedsReview => 'Taqriz kerak';

  @override
  String get queueAssigned => 'Menga biriktirilgan';

  @override
  String get queueReviewedByMe => 'Men taqriz qilganlar';

  @override
  String get queueConflicts => 'Ziddiyatlar';

  @override
  String get queueReReview => 'Qayta taqriz kerak';

  @override
  String get profileSectionVerification => 'Tasdiqlash';

  @override
  String get profileSectionData => 'Ma’lumotlar va maxfiylik';

  @override
  String get profileStudentVerificationNote =>
      'Professional tasdiq Mutaxassis rejimiga tegishli. Rejimni almashtirish tasdiqqa ta’sir qilmaydi.';

  @override
  String get profileNotFilled => 'Profil to‘ldirilmagan';

  @override
  String get profileFillAction => 'Profilni to‘ldirish';

  @override
  String get profileEditAction => 'Profilni tahrirlash';

  @override
  String get moduleHubSourced => 'Manbali yozuvlar';

  @override
  String get moduleHubSourcedNote =>
      'Manbasi va joriy tekshiruv holati bilan ko‘rsatiladi. «Tekshirilmagan» — mavjud manbali ma’lumot ekspert tekshiruvini kutmoqda degani, ma’lumot yo‘q degani emas.';

  @override
  String get moduleHubOpenAll => 'Barchasini ochish';

  @override
  String methodsStandardsLink(int count) {
    return 'Xalqaro standartlar va qo‘llanmalar ($count)';
  }

  @override
  String get sourceOneTap => 'Manbalar va kelib chiqishi';

  @override
  String get researchKeyRelevance => 'Sud-ekspert ahamiyati';

  @override
  String get researchLimitationsNote =>
      'Faqat bibliografik ma’lumot va qisqa tavsif ko‘rsatiladi; to‘liq matn noshirda.';

  @override
  String get emailCodeTitle => 'Elektron pochta kodi orqali kirish';

  @override
  String get emailCodeRowHint =>
      'Elektron pochtangizga 6 xonali kod yuboriladi — parol shart emas';

  @override
  String get emailCodeSubtitle =>
      'Elektron pochtangizni kiriting. FORENSIC EXPERT bir martalik 6 xonali tasdiqlash kodini yuboradi.';

  @override
  String get emailCodeSend => 'Kodni yuborish';

  @override
  String get emailCodeEnterTitle => '6 xonali kodni kiriting';

  @override
  String get emailCodeChange => 'Elektron pochtani o‘zgartirish';

  @override
  String emailCodeResendIn(int seconds) {
    return 'Qayta yuborish ($seconds)';
  }

  @override
  String get emailCodeNotProfessional =>
      'Elektron pochtani tasdiqlash hisobga kirishni ta’minlaydi. U mutaxassis maqomini tasdiqlamaydi.';

  @override
  String get emailCodeSignedIn =>
      'Elektron pochta tasdiqlandi. Hisobga kirdingiz.';

  @override
  String get actionNext => 'Keyingi';

  @override
  String get profileSectionProfessional => 'Mutaxassis profili';

  @override
  String get profileStepPersonal => 'Shaxsiy';

  @override
  String get profileStepWork => 'Kasbiy';

  @override
  String get profileStepProfessional => 'Profil va tasdiqlash';

  @override
  String profileStepOf(int step, int total) {
    return '$step-bosqich / $total';
  }

  @override
  String get verifReceivedTitle => 'Arizangiz qabul qilindi.';

  @override
  String get verifReceivedBody => 'Mutaxassis maqomi tekshirilmoqda.';

  @override
  String get verifReceivedNote =>
      'Holat: ariza ko‘rib chiqilmoqda. «Tasdiqlangan mutaxassis» maqomini faqat vakolatli inson-tekshiruvchi beradi — hujjat yuklash avtomatik tasdiq emas.';

  @override
  String get sourceDetailTitle => 'Manba';

  @override
  String sourceLinkedRecords(int count) {
    return 'Bog‘langan yozuvlar ($count)';
  }

  @override
  String get sourceNoLinkedRecords =>
      'Oflayn bazada bu manbaga tayangan yozuv yo‘q.';

  @override
  String get sourceNotAttached => 'Ishonchli manba biriktirilmagan.';

  @override
  String get sourceNotFound => 'Manba oflayn bazada topilmadi.';

  @override
  String get sourceOpenDetails => 'Manba tafsilotlari va bog‘langan yozuvlar';

  @override
  String homeDbCounts(int substances, int sources, int claims) {
    return '$substances modda · $sources manba · $claims manbali da’vo';
  }

  @override
  String homeDbHumanVerified(int count) {
    return 'Ekspertlar tasdiqlagan (2 mustaqil ekspert): $count';
  }

  @override
  String sourcePmid(String id) {
    return 'PMID $id';
  }

  @override
  String get homeStatSubstances => 'Moddalar';

  @override
  String get homeStatSources => 'Manbalar';

  @override
  String get homeStatClaims => 'Manbali da’volar';

  @override
  String get homeStatHumanVerified => 'Ekspertlar tasdiqlagan';

  @override
  String get homeStatPolicy =>
      '«Ekspertlar tasdiqlagan» = ikki mustaqil malakali ekspert. Avtomatik tekshiruv va AI hisoblanmaydi.';

  @override
  String get aiHeroSubtitle =>
      'Faqat FORENSIC EXPERT’ning manbali ilmiy bazasidan javob — har bir fikr yozuvga iqtibos va tekshiruv holati bilan.';

  @override
  String get aiStatusConnected => 'Ulangan · beta';

  @override
  String get aiContextSources => 'Manba: oflayn baza';

  @override
  String get aiComposerTitle => 'Ilmiy so‘rov';

  @override
  String get referralTitle => 'Hamkasbingizni taklif qiling';

  @override
  String get referralLead =>
      'FORENSIC EXPERT foydali bo‘ladigan sud eksperti, laboratoriya mutaxassisi yoki talabani bilasizmi? Shaxsiy taklifingizni ulashing.';

  @override
  String get referralYourCode => 'Taklif kodingiz';

  @override
  String get referralYourLink => 'Taklif havolangiz';

  @override
  String get referralNoLinkNote =>
      'Ommaviy FORENSIC EXPERT sayti ulangach, bu yerda veb-havola paydo bo‘ladi. Hozircha kodni ulashing — hamkasbingiz uni «Profil → Taklif kodi» bo‘limida kiritadi.';

  @override
  String get referralShare => 'Taklifni ulashish';

  @override
  String get referralCopy => 'Nusxa olish';

  @override
  String get referralCopied => 'Buferga nusxa olindi';

  @override
  String get referralStatsTitle => 'Takliflaringiz';

  @override
  String get referralStatJoined => 'Qo‘shildi';

  @override
  String get referralStatVerified => 'Tasdiqlangan';

  @override
  String get referralStatPending => 'Kutilmoqda';

  @override
  String get referralStatCredits => 'FORENSIC kreditlari';

  @override
  String referralCreditsPending(String amount) {
    return '$amount kredit tasdiqlanishini kutmoqda';
  }

  @override
  String referralCreditsFuture(String percent) {
    return 'Pullik xizmatlar ishga tushgach, taklif qilgan hamkasblaringizning mos xaridlaridan sizga FORENSIC Credits hisoblanishi mumkin — xarid qiymatining $percent%. Kreditlar pul emas, ichki promo-bonus; ro‘yxatdan o‘tish uchun berilmaydi.';
  }

  @override
  String referralCreditsActive(String percent) {
    return 'Taklif qilgan hamkasblaringizning mos xaridlaridan $percent% miqdorida FORENSIC Credits olasiz. Kreditlar qaytarish muddatidan keyin tasdiqlanadi. Ular pul emas, ichki promo-bonus.';
  }

  @override
  String get referralPrivacyNote =>
      'Faqat umumiy sonlar ko‘rsatiladi. Hamkasblaringizning ismi, elektron pochtasi, profili va hujjatlari hech qachon ulashilmaydi — na sizga, na taklifda.';

  @override
  String get referralShareSubject => 'FORENSIC EXPERT’ga taklif';

  @override
  String referralShareWithLink(String link) {
    return 'Men FORENSIC EXPERT’dan sud-ekspert ishida ilmiy ma’lumotnoma sifatida foydalanaman: moddalar, usullar, manbalar va manbaga tayangan AI javoblari. Mening taklifim orqali qo‘shiling:\n$link';
  }

  @override
  String referralShareWithCode(String code) {
    return 'Men FORENSIC EXPERT’dan sud-ekspert ishida ilmiy ma’lumotnoma sifatida foydalanaman: moddalar, usullar, manbalar va manbaga tayangan AI javoblari. Ilovani o‘rnating va «Profil → Taklif kodi» bo‘limida kodimni kiriting: $code';
  }

  @override
  String get referralSignInTitle => 'Taklif olish uchun hisobga kiring';

  @override
  String get referralSignInBody =>
      'Shaxsiy kod elektron pochta orqali kirganingizdan so‘ng serverda yaratiladi. Barcha ilmiy ma’lumotlar hisobsiz ham ochiq.';

  @override
  String get referralNotConfigured =>
      'FORENSIC EXPERT hisob xizmati ulangach, takliflar ishlaydi.';

  @override
  String get referralLoadError =>
      'Taklif yuklanmadi. Aloqani tekshirib, qayta urinib ko‘ring.';

  @override
  String get referralRetry => 'Qayta urinish';

  @override
  String get referralHaveCode => 'Taklif kodi';

  @override
  String get referralHaveCodeHint =>
      'Hamkasbingizdan taklif oldingizmi? 8 belgili kodni kiriting. U faqat yangi hisoblar uchun amal qiladi.';

  @override
  String get referralCodeField => 'Taklif kodi';

  @override
  String get referralApply => 'Qo‘llash';

  @override
  String get referralLinkedNote =>
      'Hisobingiz hamkasbingiz taklifi bilan ochilgan.';

  @override
  String get referralClaimValid =>
      'Taklif qo‘llandi. FORENSIC EXPERT’ga xush kelibsiz.';

  @override
  String get referralClaimPending =>
      'Taklif saqlandi. Elektron pochta tasdiqlangach kuchga kiradi.';

  @override
  String get referralClaimInvalid =>
      'Bu kod topilmadi. Tekshirib, qayta urinib ko‘ring.';

  @override
  String get referralClaimSelf => 'O‘z taklif kodingizdan foydalana olmaysiz.';

  @override
  String get referralClaimAlready =>
      'Hisobingizga taklif allaqachon bog‘langan.';

  @override
  String get referralClaimNotEligible =>
      'Taklif kodlari faqat yangi hisoblar uchun amal qiladi.';

  @override
  String get referralClaimRateLimited =>
      'Urinishlar juda ko‘p. Keyinroq qayta urinib ko‘ring.';

  @override
  String get referralClaimSaved =>
      'Kod saqlandi. Hisobga kirganingizdan so‘ng qo‘llanadi.';

  @override
  String get referralClaimOffline =>
      'Aloqa yo‘q. Kod saqlandi va keyinroq qo‘llanadi.';

  @override
  String get referralClaimFormat =>
      '8 belgili kodni kiriting (harf va raqamlar).';

  @override
  String get referralProfileRowHint =>
      'FORENSIC EXPERT’ni hamkasblaringiz bilan ulashing';

  @override
  String get homeInviteHint =>
      'Ishonchli ma’lumotnomani hamkasblaringiz bilan ulashing';

  @override
  String get shareAction => 'Ulashish';

  @override
  String get shareFooter =>
      'FORENSIC EXPERT’dan ulashildi — sud-ekspertlar uchun ilmiy ma’lumotnoma. Foydalanishdan oldin asl manba bilan solishtiring.';

  @override
  String get shareSourcesLabel => 'Manbalar';

  @override
  String get savedAdded => 'Saqlanganlarga qo‘shildi';

  @override
  String get savedRemoved => 'Saqlanganlardan olib tashlandi';

  @override
  String get firstStepsTitle => '5 daqiqada boshlang';

  @override
  String firstStepsProgress(int done, int total) {
    return '$total tadan $done tasi bajarildi';
  }

  @override
  String get firstStepsSearch => 'Moddani qidiring';

  @override
  String get firstStepsDiscipline => 'Fan bo‘limini oching';

  @override
  String get firstStepsSource => 'Ilmiy manbani oching';

  @override
  String get firstStepsAi => 'Forensic AI’ni sinab ko‘ring';

  @override
  String get firstStepsSave => 'Foydali materialni saqlang';

  @override
  String get firstStepsHide => 'Yashirish';

  @override
  String get firstStepsDone =>
      'Hammasi tayyor. Saqlangan materiallar va so‘nggi yozuvlar shu qurilmada qoladi.';

  @override
  String get fullTextPdf => 'To‘liq matn (PDF)';

  @override
  String get fullTextPdfNote =>
      'Ochiq kirishdagi maqola (PubMed Central, Europe PMC orqali). Qurilmangizdagi PDF ko‘ruvchi yoki brauzerda ochiladi.';

  @override
  String get fullTextPdfPro =>
      'To‘liq matnni (PDF) yuklab olish Pro versiyada mavjud.';

  @override
  String get fullTextOpenFailed => 'PDF ochilmadi. Aloqani tekshiring.';

  @override
  String get adminTitle => 'Boshqaruv paneli';

  @override
  String get adminProfileHint =>
      'Foydalanuvchilar, platformalar, davlatlar, kirish';

  @override
  String get adminUsers => 'Foydalanuvchilar';

  @override
  String get adminConfirmed => 'Elektron pochta tasdiqlangan';

  @override
  String get adminSignups7d => 'Yangi (7 kun)';

  @override
  String get adminActive7d => 'Faol (7 kun)';

  @override
  String get adminAndroid => 'Android';

  @override
  String get adminIos => 'iOS';

  @override
  String get adminAiRequests => 'AI so‘rovlar';

  @override
  String get adminReferrals => 'Takliflar';

  @override
  String get adminProGrants => 'Pro berilganlar';

  @override
  String get adminRegions => 'Davlatlar (qurilma hududi)';

  @override
  String get adminDaily => 'Ro‘yxatdan o‘tish, 30 kun';

  @override
  String adminUserList(int count) {
    return 'Foydalanuvchilar ($count)';
  }

  @override
  String get adminStoreNote =>
      'Bu yerda faqat ro‘yxatdan o‘tganlar sanaladi. Ro‘yxatdan o‘tmagan yuklab olishlar App Store Connect va Google Play Console’da ko‘rinadi.';

  @override
  String get adminPrivacyNote =>
      'Shaxsiy ma’lumot (elektron pochta) bor. Skrinshotlarni tarqatmang.';

  @override
  String get adminGrantTitle => 'Pro berish yoki olib tashlash';

  @override
  String get adminEmail => 'Foydalanuvchi elektron pochtasi';

  @override
  String get adminGrantPro => 'Mutaxassis Pro berish';

  @override
  String get adminRevoke => 'Olib tashlash';

  @override
  String get adminGranted => 'Pro berildi.';

  @override
  String get adminRevoked => 'Kirish olib tashlandi.';

  @override
  String get adminNotFound => 'Bunday elektron pochtali foydalanuvchi yo‘q.';

  @override
  String get adminFailed => 'Bajarilmadi. Aloqani tekshiring.';

  @override
  String get adminForbidden => 'Bu bo‘lim faqat administratorlar uchun.';

  @override
  String get adminRefresh => 'Yangilash';

  @override
  String get adminUnknownRegion => 'Noma’lum';

  @override
  String get adminAdminBadge => 'Admin';

  @override
  String get calcSex => 'Jinsi';

  @override
  String get calcSexMale => 'Erkak';

  @override
  String get calcSexFemale => 'Ayol';

  @override
  String get calcBodyWeight => 'Tana vazni, kg';

  @override
  String get calcHeightOptional => 'Bo‘yi, sm (ixtiyoriy — Seidl r)';

  @override
  String get calcDrinkVolume => 'Ichimlik hajmi, mL';

  @override
  String get calcDrinkAbv => 'Spirt ulushi, % hajm';

  @override
  String get calcHoursSinceStart => 'Ichish boshlanganidan beri, soat';

  @override
  String get calcAddDrink => 'Ichimlik qo‘shish';

  @override
  String get calcRemoveDrink => 'Ichimlikni olib tashlash';

  @override
  String calcDrinkN(String n) {
    return '$n-ichimlik';
  }

  @override
  String get calcWidmarkEthanol => 'Ichilgan sof etanol';

  @override
  String get calcWidmarkR => 'Taqsimlanish koeffitsienti r';

  @override
  String get calcWidmarkPeak =>
      'Nazariy maksimum (defitsit va eliminatsiyasiz)';

  @override
  String get calcWidmarkMin => 'Minimal baho';

  @override
  String get calcWidmarkMax => 'Maksimal baho';

  @override
  String get calcWidmarkAssumptionDeficit =>
      'Rezorbsiya defitsiti: maksimum uchun 10 %, minimum uchun 30 %.';

  @override
  String get calcWidmarkAssumptionBeta =>
      'Eliminatsiya: maksimum uchun 0,10 ‰/soat, minimum uchun 0,20 ‰/soat, ichish boshlanganidan.';

  @override
  String get calcWidmarkAssumptionR =>
      'r: Widmark o‘rtachasi (erkak 0,7, ayol 0,6) yoki bo‘y va vazndan Seidl va boshq. (2000).';

  @override
  String get calcWidmarkLimitation =>
      'Bu o‘lchov emas, taxminiy baho. Ovqat, jigar faoliyati, ichish tarzi va dorilar natijani o‘zgartiradi. O‘lchangan konsentratsiya va ekspert xulosasi o‘rnini bosmaydi.';

  @override
  String get calcBacMeasured => 'O‘lchangan qondagi alkogol';

  @override
  String get calcHoursEventToSample => 'Hodisadan qon olishgacha, soat';

  @override
  String get calcHoursDrinkEndOptional =>
      'Ichish tugaganidan hodisagacha, soat (ixtiyoriy)';

  @override
  String get calcBackMin => 'Hodisa vaqtida, minimum';

  @override
  String get calcBackMax => 'Hodisa vaqtida, maksimum';

  @override
  String get calcBackAssumptionLinear =>
      'Eliminatsiya chiziqli (nol tartib), hodisa paytida so‘rilish tugagan.';

  @override
  String get calcBackAssumptionBeta =>
      'β = 0,10–0,25 g/L/soat (10–25 mg/100 mL/soat) ko‘pchilik odamlarni qamraydi (Jones 2010). ‰ (g/kg) uchun β qon zichligi 1,055 g/mL bilan qayta hisoblanadi.';

  @override
  String get calcBackLimitation =>
      'Ichish tugaganidan keyin ~2 soat davomida so‘rilish davom etishi mumkin — teskari hisob natijani oshirib ko‘rsatishi mumkin. Hodisadan keyin ichilgan bo‘lsa, hisob yaroqsiz.';

  @override
  String get calcWarnAbsorption =>
      'Hodisa ichish tugaganidan 2 soatdan kam vaqt o‘tib bo‘lgan: so‘rilish tugamagan bo‘lishi mumkin. Minimum qo‘shimchasiz ko‘rsatildi.';

  @override
  String get calcWarnEliminated =>
      'Bu vaqtga kelib alkogol to‘liq chiqib ketgan bo‘lishi mumkin.';

  @override
  String get calcWarnRUnusual =>
      'Hisoblangan r odatiy 0,45–0,85 oralig‘idan tashqarida — bo‘y va vaznni tekshiring.';

  @override
  String get calcEthanolMatrix => 'Namuna';

  @override
  String get calcMatrixBlood => 'To‘liq qon';

  @override
  String get calcMatrixSerum => 'Zardob / plazma';

  @override
  String get calcSerumRatio => 'Zardob / qon nisbati';

  @override
  String get calcEthanolBloodHeader => 'To‘liq qon ekvivalenti';

  @override
  String get calcEthanolAssumptionDensity =>
      '‰ — bu g/kg; g/L uchun qon zichligi 1,055 g/mL olinadi.';

  @override
  String get calcEthanolAssumptionRatio =>
      'Zardobda suv qondan ko‘p, shuning uchun etanol ham ko‘proq; standart nisbat 1,2.';

  @override
  String get calcEthanolLimitation =>
      'Zardob/qon nisbati odamga qarab farq qiladi (taxminan 1,1–1,3; Rainey 1993). Laboratoriyangiz yoki yurisdiksiyangiz talab qilgan qiymatdan foydalaning.';

  @override
  String get calcRectalTemp => 'Rektal harorat, °C';

  @override
  String get calcAmbientTemp => 'Muhit harorati, °C';

  @override
  String get calcCorrectiveFactor => 'Kiyim / muhit (tuzatish koeffitsienti)';

  @override
  String get calcFactorNakedDry => 'Yalang‘och, quruq, havo harakatsiz — 1,0';

  @override
  String get calcFactorNakedMovingAir => 'Yalang‘och, havo harakatda — 0,75';

  @override
  String get calcFactorWetStill => 'Yalang‘och, turg‘un suvda — 0,5';

  @override
  String get calcFactorWetFlowing => 'Yalang‘och, oqar suvda — 0,35';

  @override
  String get calcFactorThin => '1–2 qavat yupqa kiyim — 1,1';

  @override
  String get calcFactorLayers => '2–3 qavat kiyim — 1,2';

  @override
  String get calcFactorThick => '3–4 qavat / qalin kiyim — 1,3';

  @override
  String get calcFactorBedding => 'Qalin ko‘rpa ostida — 2,0';

  @override
  String get calcHenssgeTime =>
      'Taxminiy o‘limdan keyin o‘tgan vaqt oralig‘i (PMI)';

  @override
  String get calcHenssgeRange => '95 % chegara';

  @override
  String calcHoursValue(String h) {
    return '$h soat';
  }

  @override
  String calcHoursRange(String from, String to) {
    return '$from–$to soat';
  }

  @override
  String get calcHenssgeAssumptionNormal =>
      'O‘lim paytida tana harorati 37,2 °C.';

  @override
  String get calcHenssgeAssumptionAmbient =>
      'Muhit harorati taxminan o‘zgarmagan; ≤ 23 °C va > 23 °C uchun formula farq qiladi.';

  @override
  String get calcHenssgeAssumptionCi =>
      '95 % chegara: ±2,8 soat (≤ 23 °C), ±3,2 soat (> 23 °C), tuzatish koeffitsienti bilan ±4,5 soat.';

  @override
  String get calcHenssgeLimitation =>
      'Isitma, gipotermiya, kuchli issiqlik manbai, quyosh, jasad boshqa joyga ko‘chirilgan yoki muhit harorati keskin o‘zgargan holatlarda yaroqsiz. Boshqa belgilar (murda dog‘lari, qotish, supravital reaksiyalar) bilan birga baholang.';

  @override
  String get calcWarnNoCooling =>
      'Rektal harorat ≥ 37,2 °C — sovish boshlanmagan yoki isitma bo‘lgan.';

  @override
  String get calcWarnLatePhase =>
      'Jasad harorati muhitga yaqin — aniqlik past.';

  @override
  String get calcErrorWeight => 'Haqiqiy tana vaznini kiriting.';

  @override
  String get calcErrorTime => 'To‘g‘ri vaqtni soatda kiriting.';

  @override
  String get calcErrorAbv => 'Spirt ulushi 0 dan 100 % gacha bo‘lishi kerak.';

  @override
  String get calcErrorHeight =>
      'Bo‘y 120–230 sm bo‘lishi kerak yoki bo‘sh qoldiring.';

  @override
  String get calcErrorBac => '0 dan 8 ‰ gacha qiymat kiriting.';

  @override
  String get calcErrorRatio => 'Nisbat 1,0 dan 1,5 gacha bo‘lishi kerak.';

  @override
  String get calcErrorRectal =>
      'Rektal harorat muhitdan yuqori va 42 °C dan oshmasligi kerak.';

  @override
  String get calcErrorAmbient =>
      'Muhit harorati −20 dan 35 °C gacha bo‘lishi kerak.';

  @override
  String get guidelinesTitle => 'Yo‘riqnomalar';

  @override
  String get guidelinesSubtitle =>
      'Fanlar bo‘yicha mustaqil ilmiy-amaliy yo‘riqnomalar';

  @override
  String get guidelinesIntro =>
      'Har bir yo‘riqnoma ko‘rsatilgan va tekshirilgan adabiyot asosida yozilgan mustaqil ilmiy sintezdir. U rasmiy metodika emas, akkreditatsiyadan o‘tgan laboratoriya tartiblari va mamlakatingiz qonunchiligi o‘rnini bosmaydi. Har bir karta mutaxassis tasdiqlaguncha ko‘rik holatida qoladi.';

  @override
  String get guidelinesSearchHint => 'Yo‘riqnomalardan qidirish';

  @override
  String get guidelinesEmptyArea => 'Bu yo‘nalishda hozircha yo‘riqnoma yo‘q.';

  @override
  String get guidelinesNoResults => 'Natija topilmadi';

  @override
  String guidelinesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta yo‘riqnoma',
      zero: 'Yo‘riqnoma yo‘q',
    );
    return '$_temp0';
  }

  @override
  String get guidelineAreaForensicMedicine => 'Sud-tibbiyot';

  @override
  String get guidelineAreaForensicChemistry => 'Sud-kimyo va toksikologiya';

  @override
  String get guidelineAreaForensicHistology => 'Sud-gistologiya';

  @override
  String get guidelineAreaForensicBiology => 'Sud-biologiya va genetika';

  @override
  String get guidelineAreaMedicalCriminalistics =>
      'Tibbiy-kriminalistika va antropologiya';

  @override
  String get guidelineAreaOther => 'Boshqa fanlar';

  @override
  String get guidelineIndependentNote =>
      'Quyidagi adabiyotlar asosidagi mustaqil ilmiy sintez. Rasmiy metodika emas; laboratoriyangiz va yurisdiksiyangiz talablarini tekshiring.';

  @override
  String get guidelineTranslationDraft =>
      'Bu tarjima qoralama, hali mutaxassis tomonidan tekshirilmagan.';

  @override
  String guidelineFallbackLanguage(String language) {
    return 'Hozircha sizning tilingizda yo‘q — asl tilda ($language) ko‘rsatilmoqda.';
  }

  @override
  String get guidelineReferences => 'Manbalar';

  @override
  String guidelineUpdated(String date) {
    return 'Yangilangan: $date';
  }

  @override
  String get guidelineRelatedTools => 'Bog‘liq vositalar';

  @override
  String get guidelineOpenReference => 'Manbani ochish';

  @override
  String get languageNameUz => 'o‘zbekcha';

  @override
  String get languageNameRu => 'ruscha';

  @override
  String get languageNameEn => 'inglizcha';

  @override
  String get restrictedCatalogTitle => 'O‘zbekiston amaliyot kodlari (yopiq)';

  @override
  String get restrictedCatalogNote =>
      'Faqat administratorlarga ko‘rinadi. Cheklangan manba katalogining metama’lumotlari: to‘liq matn ilovada saqlanmaydi, AI’ga berilmaydi va tarqatilmaydi.';

  @override
  String get restrictedCatalogImport => 'Katalog faylini import qilish';

  @override
  String get restrictedCatalogRemove => 'Qurilmadan o‘chirish';

  @override
  String get restrictedCatalogEmpty =>
      'Bu qurilmada katalog yo‘q. Yopiq yo‘l bilan olingan faylni import qiling.';

  @override
  String restrictedCatalogImported(int count) {
    return 'Katalog import qilindi: $count ta yozuv.';
  }

  @override
  String get restrictedCatalogInvalid => 'Bu fayl yaroqli katalog emas.';

  @override
  String restrictedCatalogRecords(int count) {
    return '$count ta yozuv';
  }

  @override
  String restrictedCatalogPages(String from, String to) {
    return '$from–$to-betlar';
  }

  @override
  String restrictedCatalogPage(String page) {
    return '$page-bet';
  }

  @override
  String restrictedCatalogCodeOriginal(String code) {
    return 'Manbadagi asl kod: $code';
  }

  @override
  String get restrictedCatalogSearchHint =>
      'Kod, nom yoki atama bo‘yicha qidirish';

  @override
  String get restrictedCatalogLinkedCards =>
      'Bog‘langan mustaqil yo‘riqnomalar';

  @override
  String get restrictedCatalogNormative => 'Bog‘liq rasmiy hujjatlar';

  @override
  String restrictedCatalogSection(String section) {
    return '$section-bo‘lim';
  }

  @override
  String get restrictedCatalogTitleDraft => 'Sarlavha tarjimasi qoralama';

  @override
  String get aiWorking =>
      'Manbalar asosida javob tayyorlanmoqda… Bu bir daqiqagacha cho‘zilishi mumkin.';

  @override
  String get aiSearchingOffline => 'Oflayn bazadan qidirilmoqda…';

  @override
  String get aiNotCovered =>
      'Ilovadagi manbalar bu savolni yetarli darajada qamrab olmaydi, shuning uchun manbali javob tuzilmadi.';

  @override
  String get aiModelNoteTitle => 'AI izohi (manbasiz — unga tayanmang)';

  @override
  String get aiAnswerRejected =>
      'AI javobi ko‘rsatilmadi: uni ilovadagi manbalar bilan tasdiqlab bo‘lmadi.';

  @override
  String get aiErrRateLimited =>
      'AI savollarining soatlik limiti tugadi. Birozdan keyin qayta urinib ko‘ring.';

  @override
  String get aiErrSignIn =>
      'Sessiya muddati tugadi. AI’dan foydalanish uchun qayta kiring.';

  @override
  String get aiErrOffline =>
      'AI xizmati bilan aloqa yo‘q. Internet aloqasini tekshiring.';

  @override
  String get aiErrServer =>
      'AI xizmati vaqtincha ishlamayapti. Birozdan keyin qayta urinib ko‘ring.';

  @override
  String get aiErrNotConfigured => 'AI xizmati serverda hali sozlanmagan.';

  @override
  String get aiQuotaUsed =>
      'AI savollari bo‘yicha limitingiz hozircha tugagan.';

  @override
  String get aiOfflineSourcesTitle => 'Oflayn bazadan topilgan manbalar';

  @override
  String aiOfflineSourcesCount(int count) {
    return 'Foydalanilgan manbalar ($count)';
  }

  @override
  String get aiRetry => 'Qayta urinish';

  @override
  String get relationBasisSourceExcerpt => 'manba parchasi';

  @override
  String get metaHandle => 'Handle identifikatori';

  @override
  String fileSizeKb(String size) {
    return '$size KB';
  }

  @override
  String get disc_forensicSerology => 'Sud serologiyasi';

  @override
  String get disc_medicalCriminalistics => 'Tibbiy-kriminalistika';

  @override
  String get disc_traceEvidence => 'Trasologiya va mikroizlar';

  @override
  String get disc_firearmsBallistics => 'Ballistika va o‘qotar qurollar';

  @override
  String get disc_questionedDocuments => 'Hujjatlar ekspertizasi';

  @override
  String get disc_digitalForensics => 'Raqamli kriminalistika';

  @override
  String get discGroupCriminalistics => 'Kriminalistika';

  @override
  String get homeGreeting => 'Xush kelibsiz';

  @override
  String homeRoleChip(String mode) {
    return 'Rejim: $mode';
  }

  @override
  String get homeAiEntryBody =>
      'Ilmiy savol bering. Javoblar manbalarga iqtibos keltiradi.';

  @override
  String get homeResourcesHeading => 'Kutubxona va vositalar';

  @override
  String get homeLibraryBody => 'Moddalar, usullar, standartlar va manbalar';

  @override
  String get homeContinueSaved => 'Davom ettirish va saqlanganlar';

  @override
  String get loadingContent => 'Yuklanmoqda…';

  @override
  String get pubTitle => 'Ekspert maqolalari';

  @override
  String get pubIntro =>
      'Ekspertlar maqolalari moderatsiyadan so‘ng nashr etiladi. Moderatsiya rasmiylashtirish, qoidalar va shaxsiy ma’lumotlarni tekshiradi — ilmiy to‘g‘rilikni emas.';

  @override
  String get pubNotVerifiedNotice =>
      'Maqola yuborilgani uning ilmiy tasdiqlanganini bildirmaydi.';

  @override
  String get pubSearchHint => 'Sarlavha, annotatsiya yoki kalit so‘z';

  @override
  String get pubAllDisciplines => 'Barcha fanlar';

  @override
  String get pubEmpty => 'Hozircha nashr etilgan maqolalar yo‘q.';

  @override
  String get pubFilterEmpty => 'So‘rovingizga mos maqola topilmadi.';

  @override
  String get pubLoadFailed =>
      'Maqolalarni yuklab bo‘lmadi. Aloqani tekshiring.';

  @override
  String get pubReload => 'Qayta urinish';

  @override
  String get pubUnavailable => 'Bu bo‘lim hozircha mavjud emas.';

  @override
  String get pubSubmit => 'Maqola yuborish';

  @override
  String get pubMine => 'Mening maqolalarim';

  @override
  String get pubModeration => 'Moderatsiya';

  @override
  String get pubSignInRequired =>
      'Maqola yuborish yoki shikoyat qilish uchun hisobingizga kiring.';

  @override
  String get pubSignIn => 'Kirish';

  @override
  String get pubStatusDraft => 'Qoralama';

  @override
  String get pubStatusSubmitted => 'Yuborilgan';

  @override
  String get pubStatusScreening => 'Dastlabki tekshiruv';

  @override
  String get pubStatusInReview => 'Ko‘rib chiqilmoqda';

  @override
  String get pubStatusApproved => 'Nashrga ma’qullangan';

  @override
  String get pubStatusRejected => 'Muallifga qaytarilgan';

  @override
  String get pubStatusPublished => 'Nashr etilgan';

  @override
  String get pubStatusRetracted => 'Qaytarib olingan';

  @override
  String get pubStatusSuperseded => 'Yangi versiya bilan almashtirilgan';

  @override
  String get pubAbstract => 'Annotatsiya';

  @override
  String get pubKeywords => 'Kalit so‘zlar';

  @override
  String get pubAuthors => 'Mualliflar';

  @override
  String get pubAffiliation => 'Tashkilot';

  @override
  String get pubDoi => 'DOI identifikatori';

  @override
  String get pubReferences => 'Adabiyotlar ro‘yxati';

  @override
  String get pubExternalUrl => 'To‘liq matn havolasi';

  @override
  String get pubLanguage => 'Maqola tili';

  @override
  String get pubDiscipline => 'Fan sohasi';

  @override
  String pubVersion(int version) {
    return '$version-versiya';
  }

  @override
  String pubPublishedOn(String date) {
    return 'Nashr sanasi: $date';
  }

  @override
  String get pubNotFound => 'Maqola topilmadi.';

  @override
  String get pubLangUz => 'O‘zbekcha';

  @override
  String get pubLangRu => 'Ruscha';

  @override
  String get pubLangEn => 'Inglizcha';

  @override
  String get pubReport => 'Shikoyat qilish';

  @override
  String get pubReportTitle => 'Maqola ustidan shikoyat';

  @override
  String get pubReportDetails => 'Tafsilotlar (ixtiyoriy)';

  @override
  String get pubReportSend => 'Yuborish';

  @override
  String get pubCancel => 'Bekor qilish';

  @override
  String get pubReasonPlagiarism => 'Plagiat';

  @override
  String get pubReasonPersonalData => 'Shaxsiy ma’lumotlar';

  @override
  String get pubReasonCopyright => 'Mualliflik huquqi buzilgan';

  @override
  String get pubReasonMisinformation => 'Noto‘g‘ri ma’lumot';

  @override
  String get pubReasonAbuse => 'Haqoratli mazmun';

  @override
  String get pubReasonOther => 'Boshqa';

  @override
  String get pubReported => 'Rahmat. Shikoyat moderatorlarga yuborildi.';

  @override
  String get pubAlreadyReported =>
      'Siz bu maqola ustidan avval shikoyat qilgansiz.';

  @override
  String get pubActionFailed => 'Bajarilmadi. Aloqani tekshiring.';

  @override
  String get pubFormTitle => 'Maqola sarlavhasi';

  @override
  String get pubFormKeywords => 'Kalit so‘zlar (vergul bilan)';

  @override
  String get pubFormAuthors => 'Mualliflar (har biri yangi qatorda)';

  @override
  String get pubFormDoi => 'DOI (bo‘lsa)';

  @override
  String get pubFormUrl => 'To‘liq matn havolasi (https://…)';

  @override
  String get pubPiiWarning =>
      'Shaxsiy ma’lumot kiritmang: jabrlanuvchi yoki gumonlanuvchi ismlari, ish raqamlari, manzillar, tanib bo‘ladigan odamlar suratlari, tibbiy hujjatlar.';

  @override
  String get pubConfirmationsTitle => 'Majburiy tasdiqlar';

  @override
  String get pubConfirmRights =>
      'Men muallifman yoki bu matnni nashr etishga huquqim bor.';

  @override
  String get pubConfirmConsent =>
      'Moderatsiyadan so‘ng maqola FORENSIC EXPERT’da ommaga ochiq bo‘lishiga roziman.';

  @override
  String get pubConfirmNoPii =>
      'Maqolada jabrlanuvchilar, gumonlanuvchilar yoki boshqa shaxslarning shaxsiy ma’lumotlari yo‘q.';

  @override
  String get pubSaveDraft => 'Qoralamani saqlash';

  @override
  String get pubSubmitForModeration => 'Moderatsiyaga yuborish';

  @override
  String get pubSubmitHint =>
      'Yuborish uchun sarlavha, annotatsiya va fan sohasini to‘ldiring hamda uchala tasdiqni belgilang.';

  @override
  String get pubDraftSaved => 'Qoralama saqlandi.';

  @override
  String get pubSubmitted => 'Maqola moderatsiyaga yuborildi.';

  @override
  String get pubSubmitRejected =>
      'Yuborilmadi: majburiy maydonlar va tasdiqlarni to‘ldiring.';

  @override
  String get pubEditTitle => 'Qoralamani tahrirlash';

  @override
  String get pubPaidNote =>
      'Pullik obuna moderatsiya natijasiga ta’sir qilmaydi.';

  @override
  String get pubRequired => 'Majburiy';

  @override
  String get pubMineEmpty => 'Sizda hozircha maqola yo‘q.';

  @override
  String get pubTimeline => 'Holat tarixi';

  @override
  String get pubModeratorComment => 'Moderator izohi';

  @override
  String get pubEdit => 'Tahrirlash';

  @override
  String get pubQueueEmpty => 'Moderatsiyani kutayotgan maqola yo‘q.';

  @override
  String pubReports(int count) {
    return 'Shikoyatlar ($count)';
  }

  @override
  String pubMoveTo(String status) {
    return 'O‘tkazish: $status';
  }

  @override
  String get pubCommentLabel => 'Muallif uchun izoh';

  @override
  String get pubCommentRequired => 'Bu qaror uchun izoh majburiy.';

  @override
  String get pubOwnArticle =>
      'Bu sizning maqolangiz: uni boshqa moderator ko‘rib chiqishi kerak.';

  @override
  String get pubModerationDone => 'Yangilandi.';

  @override
  String get pubInvalidTransition =>
      'Joriy holatdan bu qadamga o‘tib bo‘lmaydi.';

  @override
  String get pubForbidden => 'Bu bo‘lim faqat moderatorlar uchun.';

  @override
  String get pubConfirm => 'Tasdiqlash';

  @override
  String get aiSignInTitle => 'AI’ga savol berish uchun hisobga kiring';

  @override
  String get aiSignInBody =>
      'AI xizmati ulangan va faqat ilovadagi manbalar asosida, iqtiboslar bilan javob beradi. Savol berish uchun hisobga kirish kerak; manbalarni oflayn qidirish kirmasdan ham ishlaydi.';

  @override
  String get aiSendSignIn => 'Savol yuborish uchun hisobga kiring.';

  @override
  String get aiStatusSignIn => 'Hisobga kirish kerak';

  @override
  String get searchDisciplineFilter => 'Natijalarni fan bo‘yicha saralash';

  @override
  String get searchDisciplineAll => 'Barcha fanlar';

  @override
  String searchLinkedVia(String name) {
    return '$name bilan bog‘liq (manbada tilga olingan)';
  }

  @override
  String get studyTitle => 'O‘quv rejimi';

  @override
  String get studyEntrySubtitle =>
      'Faqat ilovadagi manbali yozuvlardan tuzilgan kartochkalar va o‘z-o‘zini tekshirish testi';

  @override
  String get studyIntro =>
      'Har bir kartochka va savol ilovada mavjud yozuvdan, uning manbasi bilan birga tuziladi. Yangi matn yozilmaydi. Hali ekspert tekshiruvidan o‘tmagan material belgilab qo‘yilgan.';

  @override
  String get studySectionTopics => 'Fanlar bo‘yicha mavzular';

  @override
  String get studySectionSubstances => 'Moddalar: molekulyar formulalar';

  @override
  String get studySectionGuidelines => 'Yo‘riqnomalar';

  @override
  String studyDeckCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta kartochka',
    );
    return '$_temp0';
  }

  @override
  String studyDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Takrorlash: $count ta',
      zero: 'Takrorlash yo‘q',
    );
    return '$_temp0';
  }

  @override
  String get studyEmpty => 'Hozircha o‘qish uchun manbali material yo‘q.';

  @override
  String get studyLoading => 'O‘quv materiali yuklanmoqda';

  @override
  String get studyQuizUnavailable =>
      'Test uchun bu turdagi yozuvlar yetarli emas';

  @override
  String get studyFrontTopic => 'Keltirilgan manba bu mavzu haqida nima deydi?';

  @override
  String get studyFrontSubstance => 'Molekulyar formulasi qanday?';

  @override
  String get studyFrontGuideline => 'Bu yo‘riqnomaning qisqa mazmuni qanday?';

  @override
  String get studyTapToFlip => 'Aylantirish uchun kartochkaga bosing';

  @override
  String get studyHideAnswer => 'Javobni yashirish';

  @override
  String get studyDidntKnow => 'Bilmadim';

  @override
  String studyCardProgress(int current, int total) {
    return '$total tadan $current-kartochka';
  }

  @override
  String studyBox(int box, int total) {
    return '$total ta qutidan $box-quti';
  }

  @override
  String get studyBoxNew => 'Yangi kartochka';

  @override
  String get studyQuoteLabel => 'Manbadan aynan iqtibos (asl tilda)';

  @override
  String studyGroupLabel(String group) {
    return 'Guruh (tahririy): $group';
  }

  @override
  String get studySourcesHeader => 'Manbalar';

  @override
  String get studyOpenEntry => 'Asl yozuvni ochish';

  @override
  String get studyOpenSourceDetails => 'Manba tafsilotlarini ochish';

  @override
  String studyMoreSources(int count) {
    return 'yana $count ta';
  }

  @override
  String get studySessionDone => 'Mashg‘ulot tugadi';

  @override
  String studySessionSummary(int known, int total) {
    return '$total tadan $known tasini bildingiz';
  }

  @override
  String get studyAllCaughtUp =>
      'Hozir bu to‘plamda takrorlanadigan kartochka yo‘q. Keyinroq qayting yoki barcha kartochkalarni takrorlang.';

  @override
  String get studyReviewAll => 'Barcha kartochkalarni takrorlash';

  @override
  String get studyResetProgress => 'To‘plam natijalarini tozalash';

  @override
  String get studyResetDone => 'To‘plam natijalari tozalandi';

  @override
  String get studyBackToDecks => 'To‘plamlar ro‘yxatiga qaytish';

  @override
  String get studyQuizStemTopic =>
      'Manbadagi bu iqtibos qaysi mavzuga keltirilgan?';

  @override
  String studyQuizStemSubstance(String name) {
    return '$name moddasining molekulyar formulasi qanday?';
  }

  @override
  String get studyQuizStemGuideline =>
      'Bu qisqa mazmun qaysi yo‘riqnomaga tegishli?';

  @override
  String get studyQuizNote =>
      'Noto‘g‘ri variantlar — ilovadagi shu turdagi boshqa yozuvlar; hech narsa to‘qib chiqarilmagan.';

  @override
  String studyQuizQuestionOf(int current, int total) {
    return '$total tadan $current-savol';
  }

  @override
  String get studyQuizNext => 'Keyingi savol';

  @override
  String get studyQuizFinish => 'Natijani ko‘rish';

  @override
  String studyQuizScore(int correct, int total) {
    return 'Natija: $total tadan $correct ta';
  }

  @override
  String get studyQuizMistakes => 'Xatolar tahlili';

  @override
  String get studyQuizNoMistakes => 'Xato yo‘q — barcha javoblar to‘g‘ri.';

  @override
  String studyQuizYourAnswer(String answer) {
    return 'Sizning javobingiz: $answer';
  }

  @override
  String studyQuizCorrectAnswer(String answer) {
    return 'To‘g‘ri javob: $answer';
  }

  @override
  String get studyQuizRetry => 'Yangi test';

  @override
  String get studyDeckNotFound => 'Bu to‘plam mavjud emas.';

  @override
  String get notFoundTitle => 'Sahifa topilmadi';

  @override
  String get notFoundBody => 'Havola eskirgan yoki noto‘g‘ri bo‘lishi mumkin.';

  @override
  String get notFoundHome => 'Bosh sahifaga';

  @override
  String get accountSignInEmailCode => 'Kirish (email kod)';

  @override
  String get toolsReviewNote =>
      'Hisoblash modullari dasturiy sinovdan o‘tgan. Formulalar va ularning manbalari hali ekspert tomonidan tasdiqlanmagan.';

  @override
  String searchAllStatus(String status) {
    return 'Barcha natijalar: $status';
  }

  @override
  String get researchOpenInBrowser => 'Ochish';

  @override
  String disciplinesComingSoon(int count) {
    return 'Tez orada ($count)';
  }

  @override
  String get modeRoleExpand => 'Rolni tanlash (ixtiyoriy)';

  @override
  String get sourcesEmpty => 'Hozircha manbalar yo‘q.';

  @override
  String get analysisTitle => 'Tahlil';

  @override
  String get analysisIntro =>
      'Qaysi namuna va qaysi usul — manbalar asosida. Hali ekspert tekshirmagan.';

  @override
  String get analysisSpecimensTitle => 'Namunalar';

  @override
  String get analysisSpecimensNote =>
      'Manbada shu namunalarda qiymat keltirilgan (chegaraviy qiymat emas).';

  @override
  String get analysisNoSpecimens =>
      'Paketda bu modda uchun hozircha manbali namuna yo‘q.';

  @override
  String analysisSourcedRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta manbali yozuv',
    );
    return '$_temp0';
  }

  @override
  String analysisSpecimenMethods(String methods) {
    return 'Shu manbadagi usullar: $methods';
  }

  @override
  String get analysisScreeningTitle => 'Skrining (taxminiy)';

  @override
  String get analysisScreeningNote =>
      'Skrining natijasi taxminiy — u tasdiqlovchi usul bilan tasdiqlanishi shart.';

  @override
  String analysisConfirmedBy(String methods) {
    return 'Tasdiqlash: $methods';
  }

  @override
  String get analysisConfirmationTitle => 'Tasdiqlovchi usullar';

  @override
  String analysisAfterScreening(String tests) {
    return 'Skriningdan keyin: $tests';
  }

  @override
  String get analysisMethodsTitle => 'Tahlil usullari';

  @override
  String get analysisMethodsRoleNote =>
      'Manbada shu modda bilan tilga olingan; tasdiqlangan protsedura emas.';

  @override
  String get analysisMethodsNotPaired =>
      'Manbalar bu usullarni aniq namunaga bog‘lamaydi.';

  @override
  String get analysisMetabolitesTitle => 'Izlanadigan metabolitlar';

  @override
  String analysisMetaboliteSpecimens(String specimens) {
    return 'Namunalar: $specimens';
  }

  @override
  String get analysisEmpty =>
      'Kontent paketida bu modda uchun hozircha manbali tahlil ma’lumoti (namuna, usul yoki metabolit) yo‘q.';

  @override
  String get analysisShowSource => 'Manbani ko‘rsatish';

  @override
  String get specimenSubstancesTitle => 'Bu namunada tahlil qilingan moddalar';

  @override
  String get specimenSubstancesNote =>
      'Har bir modda uchun manbada shu namunadagi qiymat keltirilgan.';

  @override
  String get specimenSubstancesNone =>
      'Paketda bu namunaga bog‘langan modda hozircha yo‘q.';

  @override
  String get quoteMachineTranslation => 'Avtomatik tarjima · tekshirilmagan';

  @override
  String get quoteMachineTranslationSemantics =>
      'Manbadan iqtibosning avtomatik tarjimasi, ekspert tomonidan tekshirilmagan. Iqtibos — yuqoridagi asl matn.';

  @override
  String quoteOriginalTitle(String title) {
    return 'Asl sarlavha: $title';
  }

  @override
  String sourceSectionRef(String section) {
    return '§ $section';
  }

  @override
  String get sectionAbstract => 'Annotatsiya';

  @override
  String get sectionIntroduction => 'Kirish';

  @override
  String get sectionBackground => 'Asos';

  @override
  String get sectionMethods => 'Usullar';

  @override
  String get sectionResults => 'Natijalar';

  @override
  String get sectionDiscussion => 'Muhokama';

  @override
  String get sectionConclusion => 'Xulosalar';

  @override
  String get sectionCaseReport => 'Holat tavsifi';

  @override
  String get sectionFigure => 'Rasm';

  @override
  String get sectionTable => 'Jadval';

  @override
  String get sectionSupplement => 'Qo‘shimcha materiallar';

  @override
  String get sectionTitle => 'Sarlavha';

  @override
  String researchAuthorsEtAl(String author) {
    return '$author va boshq.';
  }

  @override
  String get sectionComputedProperties => 'Hisoblangan xossalar';

  @override
  String get supTitle => 'Taklif va murojaatlar';

  @override
  String get supProfileHint =>
      'G‘oya, nosozlik, ilmiy xato — jamoa shu yerda javob beradi';

  @override
  String supUnreadHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta yangi javob',
    );
    return '$_temp0';
  }

  @override
  String get supNew => 'Yangi murojaat';

  @override
  String get supEmpty =>
      'Hali murojaat yubormagansiz. G‘oya bildiring, nosozlik yoki ilmiy xato haqida xabar bering — har bir xabarni o‘qiymiz.';

  @override
  String get supLoadFailed =>
      'Murojaatlarni yuklab bo‘lmadi. Aloqani tekshiring.';

  @override
  String get supUnavailable =>
      'Murojaatlar uchun onlayn xizmat kerak, u bu yig‘mada ulanmagan.';

  @override
  String get supSignInRequired =>
      'Murojaat yuborish va javob olish uchun hisobingizga kiring.';

  @override
  String get supSignIn => 'Kirish';

  @override
  String get supCatSuggestion => 'Taklif';

  @override
  String get supCatBug => 'Ilovadagi nosozlik';

  @override
  String get supCatScientificError => 'Ilmiy xato';

  @override
  String get supCatFeatureRequest => 'Yangi imkoniyat so‘rovi';

  @override
  String get supCatTechSupport => 'Texnik yordam';

  @override
  String get supCatGeneral => 'Umumiy savol';

  @override
  String get supStatusNew => 'Yangi';

  @override
  String get supStatusInReview => 'Ko‘rib chiqilmoqda';

  @override
  String get supStatusAnswered => 'Javob berilgan';

  @override
  String get supStatusClosed => 'Yakunlandi';

  @override
  String get supCategory => 'Turkum';

  @override
  String get supSubject => 'Mavzu';

  @override
  String get supMessage => 'Xabar';

  @override
  String get supMessageHint =>
      'Nima bo‘lganini yoki taklifingizni yozing. Uchinchi shaxslarning shaxsiy ma’lumotlari va ish materiallarini kiritmang.';

  @override
  String supRelated(String id) {
    return 'Bog‘liq yozuv: $id';
  }

  @override
  String get supAttach => 'Skrinshot biriktirish';

  @override
  String get supAttachHint => 'JPEG yoki PNG, 5 MB gacha.';

  @override
  String get supAttachRemove => 'Skrinshotni olib tashlash';

  @override
  String get supAttachTooLarge => 'Rasm hajmi 5 MB dan katta.';

  @override
  String get supAttachWrongType =>
      'Faqat JPEG yoki PNG rasm biriktirish mumkin.';

  @override
  String get supAttachment => 'Skrinshot';

  @override
  String get supPrivacyNote =>
      'Xabaringiz, skrinshot va hisob elektron pochtasi serverimizda faqat sizga javob berish uchun saqlanadi. Ularni faqat FORENSIC EXPERT jamoasi ko‘radi. Hisob o‘chirilganda ular ham o‘chiriladi.';

  @override
  String get supConsent =>
      'Murojaatimga javob berish uchun ushbu xabar qayta ishlanishiga roziman.';

  @override
  String get supSend => 'Yuborish';

  @override
  String get supSending => 'Yuborilmoqda…';

  @override
  String get supSent => 'Murojaat yuborildi. Javob shu yerda paydo bo‘ladi.';

  @override
  String get supConsentRequired => 'Iltimos, roziligingizni tasdiqlang.';

  @override
  String get supSubjectRequired => 'Mavzuni kiriting.';

  @override
  String get supMessageRequired => 'Xabarni kiriting.';

  @override
  String get supRateLimited => 'Xabarlar juda ko‘p. Keyinroq urinib ko‘ring.';

  @override
  String get supFailed =>
      'Yuborilmadi. Aloqani tekshirib, qayta urinib ko‘ring.';

  @override
  String get supClosedNote =>
      'Bu murojaat yakunlangan. Yordam kerak bo‘lsa, yangisini yarating.';

  @override
  String get supReplyHint => 'Xabar yozing';

  @override
  String get supYou => 'Siz';

  @override
  String get supTeam => 'FORENSIC EXPERT jamoasi';

  @override
  String get supNotFound => 'Murojaat topilmadi.';

  @override
  String supUnreadBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta o‘qilmagan javob',
    );
    return '$_temp0';
  }

  @override
  String get supBannerText => 'Jamoa murojaatingizga javob berdi.';

  @override
  String get supBannerOpen => 'Ko‘rish';

  @override
  String get supBannerDismiss => 'Yashirish';

  @override
  String get supReportError => 'Xato haqida xabar berish';

  @override
  String supReportErrorSubject(String title) {
    return 'Xato: $title';
  }

  @override
  String supMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta xabar',
    );
    return '$_temp0';
  }

  @override
  String get supMoreActions => 'Boshqa amallar';

  @override
  String get admNavInbox => 'Murojaatlar qutisi';

  @override
  String admNavInboxHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta javob kutmoqda',
      zero: 'Javob kutayotgan murojaat yo‘q',
    );
    return '$_temp0';
  }

  @override
  String get admNavUsers => 'Foydalanuvchilar';

  @override
  String get admNavUsersHint => 'Qidiruv, saralash, kirish darajasi';

  @override
  String get admNavAudit => 'Amallar jurnali';

  @override
  String get admNavAuditHint => 'Har bir admin amali, xabar matnisiz';

  @override
  String get admNavModeration => 'Maqolalar moderatsiyasi';

  @override
  String admNavModerationHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Navbatda $count ta',
      zero: 'Navbat bo‘sh',
    );
    return '$_temp0';
  }

  @override
  String get admOverview => 'Umumiy ko‘rinish';

  @override
  String get admStatUsers => 'Foydalanuvchilar';

  @override
  String get admStatNewToday => 'Bugun yangi';

  @override
  String get admStatNew7d => '7 kunda yangi';

  @override
  String get admStatNew30d => '30 kunda yangi';

  @override
  String get admStatActive7d => '7 kunda faol';

  @override
  String get admStatActive30d => '30 kunda faol';

  @override
  String get admStatPro => 'Pro (server ruxsati)';

  @override
  String get admStatFree => 'Bepul';

  @override
  String get admStatAwaiting => 'Javob kutayotgan murojaatlar';

  @override
  String get admStatPublications => 'Moderatsiya kutayotgan maqolalar';

  @override
  String get admStatAiTotal => 'AI savollari (jami)';

  @override
  String get admStatAi7d => '7 kunda AI savollari';

  @override
  String get admStatProfiles => 'Mutaxassis profillari';

  @override
  String get admStatVerified => 'Tasdiqlangan mutaxassislar';

  @override
  String get admModesNote =>
      'Talabalar va ekspertlar: ma’lumot yo‘q — foydalanish rejimi faqat qurilmada saqlanadi, serverda emas. O‘rniga mutaxassis profillari va tasdiqlanganlar ko‘rsatilgan.';

  @override
  String get admActiveNote =>
      'Faol — davr ichida hisobga kirgan, ilovani ochgan (qurilma belgisi) yoki AI’ga savol bergan.';

  @override
  String get admProNote =>
      'Pro faqat server ruxsatini sanaydi; do‘kon xaridlari qurilmada tekshiriladi.';

  @override
  String get admChart14d => 'So‘nggi 14 kun: ro‘yxatdan o‘tish va AI savollari';

  @override
  String get admChartSignups => 'Ro‘yxatdan o‘tish';

  @override
  String get admChartAi => 'AI savollari';

  @override
  String get admByCategory => 'Turkumlar bo‘yicha murojaatlar';

  @override
  String get admStatsUnavailable => 'Statistika hozir mavjud emas.';

  @override
  String get admNotAuthorizedTitle => 'Kirish taqiqlangan';

  @override
  String get admNotAuthorized =>
      'Bu bo‘lim faqat administratorlar uchun. Ruxsat serverda tekshiriladi.';

  @override
  String get admBackToProfile => 'Profilga qaytish';

  @override
  String get admFilterAll => 'Hammasi';

  @override
  String get admFilterAwaiting => 'Javob kutmoqda';

  @override
  String get admAllCategories => 'Barcha turkumlar';

  @override
  String get admInboxSearch => 'Mavzu yoki elektron pochta';

  @override
  String get admInboxEmpty => 'Saralashga mos murojaat yo‘q.';

  @override
  String get admLoadMore => 'Yana yuklash';

  @override
  String admShown(int shown, int total) {
    return '$total tadan $shown tasi';
  }

  @override
  String get admReply => 'Javob yozish';

  @override
  String get admReplySend => 'Javobni yuborish';

  @override
  String get admReplySent =>
      'Javob yuborildi. Foydalanuvchi uni ilovada ko‘radi.';

  @override
  String get admSetStatus => 'Holatni o‘zgartirish';

  @override
  String get admStatusChanged => 'Holat yangilandi.';

  @override
  String admAuthor(String email) {
    return 'Kimdan: $email';
  }

  @override
  String admUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta yangi xabar',
    );
    return '$_temp0';
  }

  @override
  String get admUsersSearch => 'Elektron pochta yoki ism';

  @override
  String get admRoleAny => 'Har qanday rol';

  @override
  String get admRoleAdmin => 'Adminlar';

  @override
  String get admRoleModerator => 'Moderatorlar';

  @override
  String get admTierAny => 'Har qanday tarif';

  @override
  String get admTierFree => 'Bepul';

  @override
  String get admTierPro => 'Pro tarif';

  @override
  String get admUsersEmpty => 'Saralashga mos foydalanuvchi yo‘q.';

  @override
  String admUserJoined(String date) {
    return 'Ro‘yxatdan o‘tgan: $date';
  }

  @override
  String admUserLastActive(String date) {
    return 'Oxirgi faollik: $date';
  }

  @override
  String get admUserNoActivity => 'Faollik qayd etilmagan';

  @override
  String get admUserActive => 'Faol';

  @override
  String get admUserUnconfirmed => 'Elektron pochta tasdiqlanmagan';

  @override
  String get admUserBanned => 'Bloklangan';

  @override
  String get admPrev => 'Oldingi';

  @override
  String get admNext => 'Keyingi';

  @override
  String get admAuditEmpty => 'Hozircha admin amallari yo‘q.';

  @override
  String get admAuditSystem => 'tizim / konsol';

  @override
  String get admActSupportReply => 'Murojaatga javob berildi';

  @override
  String get admActSupportStatus => 'Murojaat holati o‘zgartirildi';

  @override
  String get admActSupportView => 'Murojaat ochildi';

  @override
  String get admActUsersView => 'Foydalanuvchilar ro‘yxati ko‘rildi';

  @override
  String get admActAccessSet => 'Kirish darajasi o‘zgartirildi';

  @override
  String get admActRoleGranted => 'Rol berildi';

  @override
  String get admActRoleRevoked => 'Rol olib tashlandi';

  @override
  String get admActRoleChanged => 'Rol o‘zgartirildi';

  @override
  String get admActOther => 'Admin amali';

  @override
  String get admRetry => 'Qayta urinish';

  @override
  String imageAttrPubchemRdkit(String cid) {
    return 'Struktura PubChem CID $cid SMILES asosida RDKit bilan chizilgan';
  }

  @override
  String get imageAttrOriginalSchematic => 'Asl sxema — FORENSIC EXPERT';

  @override
  String get supRelatedUnknown => 'kontent paketidagi yozuv';

  @override
  String onbStep(int current, int total) {
    return 'Qadam $current / $total';
  }

  @override
  String get disclaimerIntroTitle => 'Boshlashdan oldin';

  @override
  String get disclaimerPointReference =>
      'Ilmiy ma’lumotnoma va o‘quv vositasi — ekspert xulosasini bermaydi.';

  @override
  String get disclaimerPointLab =>
      'Validatsiyadan o‘tgan usullar, protokollar, qonun va mutaxassis fikrining o‘rnini bosmaydi.';

  @override
  String get disclaimerPointMedical =>
      'Tibbiy savollar bo‘yicha malakali shifokorga murojaat qiling.';

  @override
  String get disclaimerFullText => 'To‘liq matn';

  @override
  String get accountReadyTitle => 'Hammasi tayyor';

  @override
  String get accountReadyBody =>
      'Ilmiy baza, qidiruv va kalkulyatorlar oflayn ishlaydi — hisob shart emas.';

  @override
  String get accountStartNow => 'Boshlash';

  @override
  String get accountBenefitsNote =>
      'Hisob professional tasdiq, sinxronlash va bulutli AI imkonini beradi. Istalgan vaqtda Profil bo‘limida kirish mumkin.';

  @override
  String get homeGreetingStudent => 'Bugun nimani o‘rganamiz?';

  @override
  String get homeGreetingExpert => 'Bugun nima ustida ishlaysiz?';

  @override
  String get homeAreasTitle => 'Bo‘limlar';

  @override
  String get homeActLearnTitle => 'O‘qish va testlar';

  @override
  String get homeActLearnBody => 'Kartochkalar, testlar, imtihon';

  @override
  String get homeActGuidelinesBody => 'Fanlar bo‘yicha amaliy yo‘riqlar';

  @override
  String get homeActSubstancesBody => 'Xossalar, tahlil, manbalar';

  @override
  String get homeActMethodsBody => 'Tahlil usullari, namuna tayyorlash';

  @override
  String get homeActToolsTitle => 'Kalkulyatorlar';

  @override
  String get homeActToolsBody => 'Laboratoriya va ekspertiza hisoblari';

  @override
  String get homeActAiBody => 'Savol bering — javob manbalar bilan';

  @override
  String get homeTrustNote =>
      'Baza ekspert tekshiruvida · har bir yozuvda manba va holat ko‘rsatiladi';

  @override
  String get profileSignInBody =>
      'Sinxronlash, tasdiq va bulutli AI. Parol shart emas.';

  @override
  String get profileSectionHelp => 'Yordam va hamjamiyat';

  @override
  String get profileSectionAppearance => 'Ko‘rinish';

  @override
  String homeAllDisciplinesCount(int count) {
    return '$count ta fan';
  }

  @override
  String get calcCopyResult => 'Natijani nusxalash';

  @override
  String get calcCopied =>
      'Natija kiritilgan qiymatlar, formula va usul versiyasi bilan nusxalandi.';

  @override
  String get calcCopyInputs => 'Kiritilgan qiymatlar';

  @override
  String get calcErrorRequired => 'Barcha majburiy maydonlarni to‘ldiring.';

  @override
  String get calcEstimatedRange => 'Baholangan oraliq';

  @override
  String get calcLockedTitle => 'Mutaxassis Pro tarkibida';

  @override
  String get calcLockedBody =>
      'Bu kalkulyator Mutaxassis Pro tarifida ochiladi. Suyultirish va konsentratsiya birliklari konvertori — bepul.';

  @override
  String get calcLodUnitNote =>
      'DL va QL kalibrlash x o‘qidagi konsentratsiya birligida.';

  @override
  String get calcHenssgeFormulaLow => 'Qo‘llangan: muhit ≤ 23 °C';

  @override
  String get calcHenssgeFormulaHigh => 'Qo‘llangan: muhit > 23 °C';

  @override
  String get admRolePublicationModerator => 'Maqolalar moderatori';

  @override
  String get rdGlanceTitle => 'Qisqacha';

  @override
  String get rdGlanceNote =>
      'Quyidagi manbali bo‘limlardan. Iqtibos va holat — har bir bo‘lim ichida.';

  @override
  String get rdGlanceFormula => 'Kimyoviy formula';

  @override
  String rdGlanceMolarMass(String value) {
    return '$value g/mol';
  }

  @override
  String get rdGlanceSpecimens => 'Namunalar';

  @override
  String get rdGlanceMethods => 'Usullar';

  @override
  String get rdGlanceMetabolites => 'Metabolitlar';

  @override
  String get rdGlanceConcentrations => 'Konsentratsiyalar';

  @override
  String get rdGlanceSources => 'Manbalar';

  @override
  String rdGlanceRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta manbali yozuv',
    );
    return '$_temp0';
  }

  @override
  String rdSourcesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta manba',
    );
    return '$_temp0';
  }

  @override
  String rdGlanceMore(int count) {
    return 'yana $count ta';
  }

  @override
  String get rdGlanceLockedHint =>
      'Quyidagi tafsilotlar Pro’da ochiladi. Nomlar, ogohlantirishlar va manbalar bepul qoladi.';

  @override
  String get rdJumpTo => 'Bo‘limga o‘tish';

  @override
  String rdGuidelineMeta(int sections, String refs) {
    return '$sections bo‘lim · $refs';
  }

  @override
  String get citeCopy => 'Iqtibosni nusxalash';

  @override
  String get citeAllSources => 'Barcha manbalar ro‘yxati';

  @override
  String citeListTitle(int count) {
    return 'Manbalar ro‘yxati · $count';
  }

  @override
  String get citeStyleLabel => 'Rasmiylashtirish uslubi';

  @override
  String get citeStyleGost => 'GOST';

  @override
  String get citeStyleVancouver => 'Vancouver';

  @override
  String get citeStyleApa => 'APA 7';

  @override
  String get citeCopyButton => 'Nusxalash';

  @override
  String get citeCopied => 'Iqtibos nusxalandi';

  @override
  String citeListCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta manba nusxalandi',
    );
    return '$_temp0';
  }

  @override
  String get citeVerifyNote =>
      'Ilova — ma’lumotnoma vosita: xulosaga kiritishdan oldin har bir manbani asl nusxa bilan tekshiring.';
}
