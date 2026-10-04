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
  String get appTagline => 'Evidence · Science · Precision';

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
  String get modeTitle => 'Forensic Expert’dan qanday foydalanasiz?';

  @override
  String get modeSubtitle =>
      'Bosh ekran shunga moslashadi. Keyinchalik Profil bo‘limida o‘zgartirish mumkin.';

  @override
  String get modeProfessional => 'Mutaxassis';

  @override
  String get modeProfessionalDescription =>
      'Sud-tibbiy ekspertlar, sud-kimyo/toksikologiya ekspertlari, laboratoriya mutaxassislari';

  @override
  String get modeStudent => 'Talaba / rezident';

  @override
  String get modeStudentDescription =>
      'Kurslar, glossariy, kartochkalar va mashqlar';

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
  String get inDevelopmentTitle => 'Ishlab chiqilmoqda';

  @override
  String get inDevelopmentBody =>
      'Bu bo‘lim keyingi ishlab chiqish bosqichlaridan birida paydo bo‘ladi. Ilmiy kontent ekspert tekshiruvidan o‘tmaguncha ko‘rsatilmaydi.';

  @override
  String get unverifiedBanner =>
      'MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK';

  @override
  String get statusVerified => 'Tasdiqlangan';

  @override
  String get statusReviewed => 'Ko‘rib chiqilgan';

  @override
  String get statusNeedsReview => 'Tekshiruv kerak';

  @override
  String get statusOutdated => 'Eskirgan';

  @override
  String get aiNotConnectedTitle => 'Forensic AI hali ulanmagan';

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
  String get legalSection => 'Huquqiy ma’lumot';

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
      'Prototip: TEST DATA belgili yozuvlar — namunaviy ma’lumot, ilmiy kontent emas.';

  @override
  String get testDataBadge => 'TEST DATA';

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
  String get toolPmiName => 'O‘lim vaqtini aniqlash (Henssge)';

  @override
  String get toolPmiDesc =>
      'Ilmiy va litsenziya tekshiruvidan so‘ng V1.1 da rejalashtirilgan.';

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
      'Bu kalkulyator hali laboratoriya reviewer’i tomonidan tekshirilmagan.';

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
  String get detailConcentrations => 'Reference konsentratsiyalar';

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
  String get detailPlaceholder => 'Namunaviy joy — ilmiy kontent hali yo‘q.';

  @override
  String get detailConcentrationsNote =>
      'Konsentratsiyaning o‘zi o‘lim sababini isbotlamaydi. Qiymatlar faqat matritsa, populyatsiya va manbalar bilan ko‘rsatiladi.';

  @override
  String get sourcesButton => 'Manbalar';

  @override
  String get sourcesNone => 'Manba yo‘q — bu test ma’lumoti.';

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
      'PubMed, PubChem va Crossref bo‘yicha qidiruv keyingi versiyalardan birida qo‘shiladi. Tashqi natijalar tekshirilgan ichki ma’lumotlar bilan hech qachon aralashtirilmaydi.';

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
  String get aiPreviewTitle => 'Javob ko‘rinishi (namuna)';

  @override
  String get aiPreviewNotice =>
      'Interfeys prototipi. Quyida — to‘ldiruvchi matn: bu AI javobi ham, ilmiy kontent ham emas.';

  @override
  String get aiSectionAvailable => 'Mavjud ma’lumotlar';

  @override
  String get aiSectionConsiderations => 'Differensial mulohazalar';

  @override
  String get aiSectionLimitations => 'Talqin cheklovlari';

  @override
  String get aiSampleInternal =>
      'Tekshirilgan ichki manba bilan tasdiqlangan namunaviy fikr.';

  @override
  String get aiSampleExternal =>
      'Tekshirilmagan tashqi manbadan olingan namunaviy fikr.';

  @override
  String get aiSampleLimitation =>
      'Namunaviy cheklov — yakuniy talqin uchun holatning to‘liq konteksti kerak.';

  @override
  String get aiEvidenceInternalVerified => 'Ichki · tasdiqlangan';

  @override
  String get aiEvidenceInternalReviewed => 'Ichki · ko‘rib chiqilgan';

  @override
  String get aiEvidenceExternal => 'Tashqi · tekshirilmagan';

  @override
  String aiPlaceholderSource(int number) {
    return 'Namunaviy manba $number';
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
  String get profileSectionAccount => 'Akkaunt va xaridlar';

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
  String get deleteAccount => 'Akkauntni o‘chirish';

  @override
  String get accountNone => 'Akkauntsiz — ilova tizimga kirmasdan ishlaydi.';

  @override
  String get legalDraftNotice =>
      'Qoralama. Hujjat professional yuridik tekshiruvdan so‘ng e’lon qilinadi.';

  @override
  String get privacySummary =>
      'Asosiy kutubxona va kalkulyatorlar oflayn ishlaydi. Qidiruv tarixi va natijalar qurilmangizda saqlanadi. Ilovada reklama SDK’lari yo‘q. Shaxsiy ma’lumot va ish tafsilotlari AI’ga hech qachon avtomatik yuborilmaydi.';

  @override
  String get aboutBody =>
      'Sud ekspertizasi uchun professional ma’lumotnoma, ta’lim va ilmiy hisob-kitob ilovasi.';

  @override
  String get aboutVersions =>
      'Ilova versiyasi va ilmiy baza versiyasi alohida yuritiladi.';

  @override
  String get storeNotConnected =>
      'Bu yig‘mada do‘kon ulanmagan, shuning uchun xarid qilib bo‘lmaydi.';

  @override
  String get restorePurchases => 'Xaridni tiklash';

  @override
  String get restoreNothing => 'Tiklanadigan xarid yo‘q.';

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
  String get purchaseTitle => 'Umrbod kirish';

  @override
  String get purchaseOneTime => 'Bir martalik xarid';

  @override
  String purchasePriceLine(String price) {
    return '$price · Bir martalik xarid';
  }

  @override
  String get purchaseReferencePriceNote =>
      'Taxminiy narx. Yakuniy narxni sizning valyutangizda App Store yoki Google Play ko‘rsatadi.';

  @override
  String get purchaseValueReference =>
      'Professional sud-ekspertiza ma’lumotnomasi';

  @override
  String get purchaseValueTools =>
      'Ilmiy kalkulyatorlar va laboratoriya vositalari';

  @override
  String get purchaseValueSources => 'Tekshirilgan manbalar va dalil holati';

  @override
  String get purchaseValueOffline => 'Oflayn professional baza';

  @override
  String get purchaseValueLearning => 'Ta’lim va kasbiy rivojlanish';

  @override
  String get purchaseValueUpdates => 'Kelgusi ilmiy kontent yangilanishlari';

  @override
  String get purchaseCta => 'FORENSIC EXPERT’ni ochish';

  @override
  String get purchaseFooter => 'Bir martalik xarid · Takroriy obuna yo‘q';

  @override
  String get purchaseFreeTitle => 'Bepul versiya';

  @override
  String get purchaseFreeBody =>
      'Xariddan oldin sinab ko‘ring: qidiruv demosi, tanlangan ma’lumotnoma yozuvlari, ayrim vositalar va demo darslar.';

  @override
  String get purchaseAiNote =>
      'Forensic AI cheklovsiz kirmaydi: uning server xarajati bor. AI hajmi xariddan oldin aniq ko‘rsatiladi.';

  @override
  String get purchaseOwned => 'Umrbod kirish faol';

  @override
  String get purchaseUnavailableSnack => 'Bu yig‘mada xarid qilib bo‘lmaydi.';

  @override
  String get accessFree => 'Bepul versiya';

  @override
  String get accessLifetime => 'Umrbod';

  @override
  String get homePilotNotice =>
      'Pilot ilmiy baza: barcha yozuvlar ekspert tekshiruvini kutmoqda. Ma’lumotlar manbalari bilan ko‘rsatiladi va yakuniy xulosa emas.';

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
  String get detailProvenance => 'Kelib chiqishi (provenance)';

  @override
  String detailEvidenceLevel(String level) {
    return 'Dalil darajasi $level';
  }

  @override
  String get detailReviewerStatus => 'Reviewer holati';

  @override
  String get detailReviewsNone =>
      'Hali ekspert review yo‘q (2 ta talab qilinadi)';

  @override
  String detailReviewsCount(int count) {
    return 'Ekspert review’lari: $count';
  }

  @override
  String get detailVersion => 'Versiya';

  @override
  String detailVersionValue(int claim, String pack) {
    return 'Claim v$claim · baza $pack';
  }

  @override
  String get detailTranslationDraft =>
      'Nomlar: mashina qoralamasi, tarjima tekshirilmagan';

  @override
  String get detailNoContentYet => 'Bu bo‘lim uchun manbali kontent hali yo‘q.';

  @override
  String detailSourceAccessed(String date) {
    return 'Murojaat sanasi: $date';
  }

  @override
  String get detailIdentifierVerified => 'Identifikator avtomatik tekshirilgan';

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
  String get lockedTitle => 'FORENSIC EXPERT Lifetime tarkibida';

  @override
  String get lockedBody =>
      'Nomlar, ogohlantirishlar va manbalar ochiq qoladi. Ilmiy tafsilotlar va yurisdiksiya qatlami Lifetime Access bilan ochiladi.';

  @override
  String get freeDemoBadge => 'Bepul demo';

  @override
  String get lockedBadge => 'Lifetime';

  @override
  String searchMoreLocked(int count) {
    return 'Lifetime bilan yana $count ta natija';
  }

  @override
  String get learnEmptyCourses =>
      'Kurslar o‘quv kontenti ekspert tekshiruvidan o‘tgach paydo bo‘ladi.';

  @override
  String get contentLoading => 'Ilmiy baza yuklanmoqda…';

  @override
  String get libraryNotInstalled => 'Bu yig‘mada ilmiy baza o‘rnatilmagan.';

  @override
  String get purchasePending => 'Xarid do‘kon tasdig‘ini kutmoqda.';

  @override
  String get purchaseFailed => 'Xarid yakunlanmadi.';

  @override
  String get purchaseCancelled => 'Xarid bekor qilindi.';

  @override
  String get purchaseSuccess => 'Umrbod kirish ochildi. Rahmat!';

  @override
  String get aboutTrademarkPending =>
      'Nom va logo: tovar belgisi tekshiruvi yakunlanmagan.';

  @override
  String get diagPurchaseNone => 'Xarid: do‘kon tasdiqlamagan';

  @override
  String get diagPurchaseStore =>
      'Xarid: faqat do‘kon tasdiqlagan — server tekshiruvi ulanmagan (release blocker)';

  @override
  String get diagPurchaseServer => 'Xarid: server tomonidan tekshirilgan';

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
  String get moduleMethods => 'Metodlar va SOP';

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
    return 'Kontent paketi $version';
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
  String get homeDbNotInstalled => 'Kontent paketi o‘rnatilmagan.';

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
      'SKRINING NATIJASI ≠ TASDIQLANGAN IDENTIFIKATSIYA. Ijobiy skrining dastlabki natija bo‘lib, validatsiyadan o‘tgan tasdiqlovchi metodni talab qiladi.';

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
  String get screeningConfirmatory => 'Tasdiqlovchi metodlar';

  @override
  String get methodKindScientific => 'Ilmiy metodlar';

  @override
  String get methodKindInternational => 'Xalqaro standartlar';

  @override
  String get methodKindNational => 'Milliy metodikalar';

  @override
  String get methodKindSop => 'Muassasa SOP’lari';

  @override
  String get methodKindNote =>
      'Metod turlari aralashtirilmaydi: ilmiy metod huquqiy talab emas, muassasa SOP’i esa faqat o‘sha muassasada amal qiladi.';

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
  String get emergingCatValidation => 'Metod validatsiyasi';

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
  String get fmTopicPostmortemInterval => 'O‘limdan keyingi vaqt';

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
      'Bu reagent retsepti emas: modda tanlovi, tartib, saqlash va barqarorlik faqat tasdiqlangan manba yoki SOP’dan.';

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
  String get aiExperienceProfessional => 'Mutaxassis';

  @override
  String get aiExperienceTutor => 'Ustoz (Tutor)';

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
  String get learnBookmarks => 'Xatcho‘plar';

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
  String get learnSimulatedCase =>
      'SIMULYATSIYA QILINGAN HOLAT — real ish emas';

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
  String get detailAnalyticalMethods => 'Analitik metodlar (manbalardan)';

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
  String get detailRelated => 'Bog‘liq professional materiallar';

  @override
  String get relationAnalysedBy => 'Tahlil metodi (manbada tilga olingan)';

  @override
  String get relationMetabolism => 'Metabolizm manbasida birga tilga olingan';

  @override
  String get relationConfirmedBy => 'Tasdiqlovchi metodlar';

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
      'Faqat metadata va havolalar — to‘liq matn ko‘chirilmaydi. Dissertatsiya, tezis va konferensiya materiallari peer-reviewed maqola bilan teng ko‘rsatilmaydi.';

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
  String get researchKindReview => 'Sharh (review)';

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
  String get licenseOriginalWork => 'Original ish (FORENSIC EXPERT)';

  @override
  String get licenseFactualDepiction => 'Faktik ma’lumotning original tasviri';

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
  String get tech_headspaceGc => 'Headspace GC';

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
  String get tech_validation => 'Metod validatsiyasi';

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
      'w/v, v/v va w/w o‘zaro almashtirilmaydi — validatsiyadan o‘tgan metod yoki SOP’dagi turni ishlating.';

  @override
  String get calcErrorPercent =>
      '0 dan katta va 100 dan oshmaydigan foiz kiriting.';

  @override
  String get calcStatsValues =>
      'Qiymatlar (bo‘sh joy, vergul yoki yangi qator bilan)';

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
      'Kalibrlash nuqtalari (har qatorda bitta «x y» juftligi)';

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
      'Faqat kalibrlangan diapazon ichida amal qiladi; vazn va chiziqlilik metod validatsiyasida belgilanadi.';

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
      'Koeffitsientlar rasmiy ICH Q2(R2) PDF bilan solishtirildi; Q2(R1) (almashtirilgan) dagidan o‘zgarmagan. Q2(R2) S/N va aniqlik/pretsizlik bilan bevosita tasdiqlashga ham ruxsat beradi. Laboratoriya reviewer tasdig‘i kutilmoqda (RG-25).';

  @override
  String get calcUseRegression =>
      'Shu regressiyadagi σ = s_y/x va S dan foydalanish';

  @override
  String get calcErrorSigma => 'σ > 0 va noldan farqli qiyalik kiriting.';

  @override
  String get researchKindGuideline => 'Qo‘llanma (guideline)';

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
  String get emergingCatMethods => 'Yangi analitik metodlar';

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
  String get homeAllDisciplinesBody => '20 ta fan — qamrov va mavjud kontent';

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
      'Platforma arxitekturasi shu fanlarni qamraydi. Kontent bosqichma-bosqich va faqat manba hamda ekspert tekshiruvi bilan qo‘shiladi — bo‘sh fan «hali manba yo‘q» degani, «bilim yo‘q» degani emas.';

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
      'Xalqaro standartlar va metodlar — qabul qilinmaguncha qonun emas';

  @override
  String get layerCountryLaw =>
      'Davlat / yurisdiksiya qonuni va protseduralari — faqat tanlangan yurisdiksiya uchun';

  @override
  String get jurisdictionViewDetails => 'Huquqiy va protsessual qatlam';

  @override
  String get jurisdictionWithContent => 'Pilot kontenti bor yurisdiksiyalar';

  @override
  String get jurisdictionSearchHint => 'Davlat yoki ISO kodini qidirish';

  @override
  String get jurisdictionNotVerified =>
      'Bu yurisdiksiya uchun kontent hali tekshirilmagan. Boshqa davlat qonunlari hech qachon uning o‘rniga ko‘rsatilmaydi.';

  @override
  String get jurisdictionPilotContent => 'Pilot kontent — tekshiruv kerak';

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
  String get docKindMethod => 'METOD';

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
      'Standart, qo‘llanma va metodlar turi bilan belgilangan. Faqat qonun va normativ hujjatlar qonuniy majburiy — va faqat o‘z yurisdiksiyasida.';

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
      'Reviewer hali baholamagan (dalil darajasidan alohida)';

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
      'Javobda ishlatilgan modda, metod va tadqiqot yozuvlariga havolalar.';

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
  String get tpl_analyticalMethods => 'Analitik metodlar';

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
  String get tpl_jurisdiction => 'Yurisdiksiya qonuni va metodlari';

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
  String get tpl_linkedMethods => 'Bog‘liq metod va testlar';

  @override
  String get tpl_technology => 'Texnologiya';

  @override
  String get tpl_targetSpecimen => 'Nishon va namuna';

  @override
  String get tpl_cutoff => 'Cutoff qiymati';

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
  String get tpl_analyticalMethod => 'Analitik metod';

  @override
  String get tpl_interpretationLimitations => 'Talqin cheklovlari';

  @override
  String get tpl_definition => 'Ta’rif';

  @override
  String get tpl_findings => 'Topilmalar';

  @override
  String get tpl_methods => 'Metodlar';

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
  String get lcNeedsReview => 'Tekshiruv kerak';

  @override
  String get lcOutdated => 'Eskirgan';

  @override
  String get lcSuperseded => 'Almashtirilgan';

  @override
  String get lcRetracted => 'Manba retraksiya qilingan';

  @override
  String get lcRejected => 'Rad etilgan';

  @override
  String get provHumanVerified => 'Malakali reviewerlar tomonidan tasdiqlangan';

  @override
  String get provNotVerified =>
      'MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK';

  @override
  String provRequiredRole(String role) {
    return 'Kerakli reviewer: $role';
  }

  @override
  String provReviewsRecorded(int n) {
    return 'Ushbu versiya bo‘yicha reviewer harakatlari: $n';
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
  String get roleEditor => 'Ilmiy muharrir / admin';

  @override
  String get bannerRetracted =>
      'Manba retraksiya qilingan — da’vo shaffoflik uchun saqlangan, lekin joriy dalil emas.';

  @override
  String get bannerSuperseded =>
      'Ushbu da’voning barcha manbalari almashtirilgan.';

  @override
  String get bannerOutdated => 'Reviewer tomonidan eskirgan deb belgilangan.';

  @override
  String get bannerConflict =>
      'DALILLAR ZIDDIYATI — manbalar mos kelmaydi yoki ustma-ust tushadi. Solishtirish uchun bosing.';

  @override
  String get conflictsTitle => 'Dalillar ziddiyatlari';

  @override
  String get conflictsIntro =>
      'Ziddiyatlar yashirilmaydi. Ularni faqat malakali reviewer hal qiladi; ilova «to‘g‘ri» variantni tanlamaydi.';

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
  String get conflictStateOpen => 'Ochiq — reviewer qarori kutilmoqda';

  @override
  String get conflictStateResolved => 'Reviewer tomonidan hal qilingan';

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
  String get ctxMethod => 'Analitik metod';

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
      'Bu yozuv konteksti hali ko‘rib chiqilmagan; faqat namuna ko‘rsatilgan.';

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
  String get chainConfirmation => 'Tasdiqlovchi metodlar';

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
  String get stdCatalogue => 'Standartlar katalogi (faqat metadata)';

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
    return 'Metadata $date da nashriyot yoki registrda tekshirilgan';
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
  String get reviewActions => 'Yozilgan reviewer harakatlari';

  @override
  String get reviewReviewers => 'Ro‘yxatdagi reviewerlar';

  @override
  String get reviewOpenConflicts => 'Ochiq dalillar ziddiyatlari';

  @override
  String get reviewExplain =>
      'Da’vo faqat o‘z sohasidagi ikki mustaqil malakali reviewer joriy versiyani tasdiqlagandan keyin VERIFIED bo‘ladi. Ilova va uning mualliflari hech narsani o‘zlari tasdiqlangan deb belgilay olmaydi.';

  @override
  String get reviewRolesTitle => 'Reviewer rollari va huquqlari';

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
      'Nashr etilgan ilmiy metod — biror laboratoriya uchun validatsiya qilingan tartib emas.';

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
  String get evPublishedValidated => 'Nashr etilgan validatsiyalangan metod';

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
      'Dalillar hali malakali reviewerlar tomonidan tasdiqlanmagan.';

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
  String get aiLimMock => 'TEST provayderi yaratgan — ishchi AI xizmati emas.';

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
      'Saralanganlar, qidiruv tarixi, yaqinda ko‘rilgan yozuvlar va darslar holati shu qurilmadan o‘chiriladi. Ilmiy baza va xaridlarga ta’sir qilmaydi. Akkaunt yo‘q: serverlarimizda siz haqingizda hech narsa saqlanmaydi.';

  @override
  String get deleteLocalDataConfirm => 'O‘chirish';

  @override
  String get deleteLocalDataDone => 'Qurilmadagi ma’lumotlar o‘chirildi';
}
