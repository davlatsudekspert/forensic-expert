import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// Brand name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'FORENSIC EXPERT'**
  String get appTitle;

  /// Brand tagline. Kept in English in all locales.
  ///
  /// In en, this message translates to:
  /// **'Evidence · Science · Precision'**
  String get appTagline;

  /// Name of this language written in this language (endonym).
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameNative;

  /// First-launch language screen heading, shown in each language.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguageTitle;

  /// Screen reader label for a language option.
  ///
  /// In en, this message translates to:
  /// **'{language}. {state}'**
  String languageOptionSemantics(String language, String state);

  /// Screen reader state for a selected option.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get stateSelected;

  /// Screen reader state for an unselected option.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get stateNotSelected;

  /// Primary button to proceed.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// Back navigation.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// Onboarding disclaimer heading.
  ///
  /// In en, this message translates to:
  /// **'Scientific disclaimer'**
  String get disclaimerTitle;

  /// Mandatory scientific disclaimer (owner-approved English wording).
  ///
  /// In en, this message translates to:
  /// **'Forensic Expert is intended for professional reference, education and scientific calculation. It does not replace validated laboratory procedures, institutional protocols, applicable law or qualified professional judgment.'**
  String get disclaimerBody;

  /// Additional onboarding notice about interpretation limits.
  ///
  /// In en, this message translates to:
  /// **'The app never issues forensic expert conclusions. A measured concentration alone does not establish a cause of death. Final professional judgment belongs to a qualified specialist.'**
  String get disclaimerNoConclusions;

  /// Reminder required by store health policies.
  ///
  /// In en, this message translates to:
  /// **'For medical advice, diagnosis or treatment, consult a qualified healthcare professional.'**
  String get disclaimerConsult;

  /// Accept disclaimer button.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get disclaimerAccept;

  /// Onboarding usage mode question.
  ///
  /// In en, this message translates to:
  /// **'How will you use Forensic Expert?'**
  String get modeTitle;

  /// Explains that mode can be changed.
  ///
  /// In en, this message translates to:
  /// **'This adapts your dashboard. You can change it later in Profile.'**
  String get modeSubtitle;

  /// Usage mode.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get modeProfessional;

  /// Usage mode description.
  ///
  /// In en, this message translates to:
  /// **'Forensic medical and toxicology experts, laboratory specialists'**
  String get modeProfessionalDescription;

  /// Usage mode.
  ///
  /// In en, this message translates to:
  /// **'Student / Resident'**
  String get modeStudent;

  /// Usage mode description.
  ///
  /// In en, this message translates to:
  /// **'Courses, glossary, flashcards and practice'**
  String get modeStudentDescription;

  /// Usage mode.
  ///
  /// In en, this message translates to:
  /// **'Research / Education'**
  String get modeResearch;

  /// Usage mode description.
  ///
  /// In en, this message translates to:
  /// **'Scientific library, references and teaching'**
  String get modeResearchDescription;

  /// Bottom navigation tab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation tab.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navTools;

  /// Bottom navigation tab.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Bottom navigation tab.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navAi;

  /// Bottom navigation tab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Global search field hint on Home.
  ///
  /// In en, this message translates to:
  /// **'Search a substance, method, formula, topic or source…'**
  String get searchHint;

  /// Shown in PHASE 1 because no content pack exists yet.
  ///
  /// In en, this message translates to:
  /// **'Search will become available when the verified scientific database is installed.'**
  String get searchUnavailable;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Forensic Medicine'**
  String get moduleForensicMedicine;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Forensic Toxicology'**
  String get moduleToxicology;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Laboratory'**
  String get moduleLaboratory;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Substance Library'**
  String get moduleSubstances;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get moduleLearn;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Forensic AI'**
  String get moduleAi;

  /// Section heading on Home.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get homeModulesHeading;

  /// Placeholder title for sections not built yet.
  ///
  /// In en, this message translates to:
  /// **'In development'**
  String get inDevelopmentTitle;

  /// Placeholder body.
  ///
  /// In en, this message translates to:
  /// **'This section will be available in a later development phase. No scientific content is shown until it has passed expert review.'**
  String get inDevelopmentBody;

  /// Mandatory banner for content that is not reviewed.
  ///
  /// In en, this message translates to:
  /// **'UNVERIFIED DATA — EXPERT CONFIRMATION REQUIRED'**
  String get unverifiedBanner;

  /// Scientific review status.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// Scientific review status.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get statusReviewed;

  /// Scientific review status.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get statusNeedsReview;

  /// Scientific review status.
  ///
  /// In en, this message translates to:
  /// **'Outdated'**
  String get statusOutdated;

  /// AI tab title in PHASE 1.
  ///
  /// In en, this message translates to:
  /// **'Forensic AI is not connected yet'**
  String get aiNotConnectedTitle;

  /// AI tab body.
  ///
  /// In en, this message translates to:
  /// **'Forensic AI will answer only from the reviewed internal knowledge base, always show its sources and never issue expert conclusions. The core library and calculators work without AI.'**
  String get aiNotConnectedBody;

  /// Permanent privacy warning in the AI tab.
  ///
  /// In en, this message translates to:
  /// **'Do not enter names, case numbers, passport data, phone numbers, addresses or other personal information.'**
  String get aiPiiWarning;

  /// Profile screen title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Usage mode'**
  String get settingsMode;

  /// Settings row showing content pack version.
  ///
  /// In en, this message translates to:
  /// **'Scientific database'**
  String get scientificDatabaseLabel;

  /// No content pack installed.
  ///
  /// In en, this message translates to:
  /// **'Not installed yet'**
  String get scientificDatabaseNotInstalled;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersionLabel;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalSection;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Scientific disclaimer'**
  String get scientificDisclaimerLink;

  /// Developer diagnostics section (debug/profile builds only).
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnosticsSection;

  /// Startup metric.
  ///
  /// In en, this message translates to:
  /// **'Time to first frame: {ms} ms'**
  String diagnosticsStartup(int ms);

  /// Startup metric.
  ///
  /// In en, this message translates to:
  /// **'Settings load: {ms} ms'**
  String diagnosticsSettingsLoad(int ms);

  /// Metric not available.
  ///
  /// In en, this message translates to:
  /// **'Not measured'**
  String get diagnosticsNotMeasured;

  /// Tools tab title.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsTitle;

  /// Library tab title.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
