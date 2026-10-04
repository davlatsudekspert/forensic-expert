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
      'Massa va molyar konsentratsiya o‘rtasida o‘tkazish.';

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
  String get toolUnitsDesc => 'mg/L, µg/mL, ng/mL, mmol/L va boshqalar.';

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
}
