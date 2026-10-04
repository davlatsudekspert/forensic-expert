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
      'Modda, metod, formula, mavzu yoki manbani qidiring…';

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
}
