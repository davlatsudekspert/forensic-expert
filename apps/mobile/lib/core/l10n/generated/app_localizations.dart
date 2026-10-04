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
  /// **'Search substances, methods, tools, references…'**
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

  /// Home section.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get homeQuickAccess;

  /// Home quick access block.
  ///
  /// In en, this message translates to:
  /// **'Recent tools'**
  String get homeRecentTools;

  /// Home quick access block.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get homeFavorites;

  /// Home quick access block.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get homeRecentSearches;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'Tools you open will appear here.'**
  String get homeEmptyRecentTools;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'Add tools or library entries to favorites to keep them here.'**
  String get homeEmptyFavorites;

  /// Empty state; also privacy note.
  ///
  /// In en, this message translates to:
  /// **'Your searches are stored only on this device.'**
  String get homeEmptyRecentSearches;

  /// Student home card title.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get homeContinueLearning;

  /// Student home card body.
  ///
  /// In en, this message translates to:
  /// **'Courses, quizzes, flashcards and case studies.'**
  String get homeStudyHubBody;

  /// Honest notice in prototype builds.
  ///
  /// In en, this message translates to:
  /// **'Prototype build: entries marked TEST DATA are placeholders, not scientific content.'**
  String get homePrototypeNotice;

  /// Badge for fixture data. Kept in English as a technical marker.
  ///
  /// In en, this message translates to:
  /// **'TEST DATA'**
  String get testDataBadge;

  /// Link to full list.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Generic open action.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openAction;

  /// Tools screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculators and conversions with formula, assumptions and limitations.'**
  String get toolsSubtitle;

  /// Tools category.
  ///
  /// In en, this message translates to:
  /// **'Toxicology'**
  String get toolCategoryToxicology;

  /// Tools category.
  ///
  /// In en, this message translates to:
  /// **'Conversions'**
  String get toolCategoryConversions;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Dilution (C₁V₁ = C₂V₂)'**
  String get toolDilutionName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Solve for any one of the four values of a dilution.'**
  String get toolDilutionDesc;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Blood alcohol (Widmark)'**
  String get toolWidmarkName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Estimate with stated assumptions, uncertainty and limitations.'**
  String get toolWidmarkDesc;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Ethanol back-calculation'**
  String get toolBackCalcName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Range-based estimate for an earlier point in time.'**
  String get toolBackCalcDesc;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Time since death (Henssge)'**
  String get toolPmiName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Planned for V1.1 after scientific and licensing review.'**
  String get toolPmiDesc;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Molarity and mass concentration'**
  String get toolMolarityName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Convert between mass and molar concentration.'**
  String get toolMolarityDesc;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Calibration and linear regression'**
  String get toolCalibrationName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Calibration curve, residuals and fit statistics.'**
  String get toolCalibrationDesc;

  /// Tool name (technical abbreviations).
  ///
  /// In en, this message translates to:
  /// **'LOD / LOQ'**
  String get toolLodName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Limits of detection and quantitation from calibration data.'**
  String get toolLodDesc;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Descriptive statistics'**
  String get toolStatsName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Mean, median, SD and CV.'**
  String get toolStatsDesc;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Concentration unit converter'**
  String get toolUnitsName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'mg/L, µg/mL, ng/mL, mmol/L and more.'**
  String get toolUnitsDesc;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Ethanol unit converter'**
  String get toolEthanolUnitsName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'g/L, ‰, mg/dL and g/100 mL.'**
  String get toolEthanolUnitsDesc;

  /// Tool availability.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get toolStatusAvailable;

  /// Tool availability.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get toolStatusPlanned;

  /// Planned tool notice.
  ///
  /// In en, this message translates to:
  /// **'This tool is planned. It will be added only after its method, formula and sources pass expert review.'**
  String get toolPlannedBody;

  /// Favorite toggle (screen reader).
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favoriteAdd;

  /// Favorite toggle (screen reader).
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoriteRemove;

  /// Calculator section.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get calcInput;

  /// Calculator section.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get calcMethod;

  /// Calculator section.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get calcFormula;

  /// Calculator section.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get calcResult;

  /// Calculator section.
  ///
  /// In en, this message translates to:
  /// **'Assumptions'**
  String get calcAssumptions;

  /// Calculator section.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get calcLimitations;

  /// Calculator section.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get calcReferences;

  /// Label for the unknown selector.
  ///
  /// In en, this message translates to:
  /// **'Solve for'**
  String get calcSolveFor;

  /// Dilution input.
  ///
  /// In en, this message translates to:
  /// **'Stock concentration (C₁)'**
  String get calcStockConc;

  /// Dilution input.
  ///
  /// In en, this message translates to:
  /// **'Stock volume (V₁)'**
  String get calcStockVol;

  /// Dilution input.
  ///
  /// In en, this message translates to:
  /// **'Final concentration (C₂)'**
  String get calcFinalConc;

  /// Dilution input.
  ///
  /// In en, this message translates to:
  /// **'Final volume (V₂)'**
  String get calcFinalVol;

  /// Unit selector label.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get calcUnit;

  /// Calculate button.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calcCalculate;

  /// Hint.
  ///
  /// In en, this message translates to:
  /// **'Enter three values to calculate the fourth.'**
  String get calcEnterValues;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number.'**
  String get calcErrorPositive;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Both concentrations must use compatible units (mass or molar).'**
  String get calcErrorUnits;

  /// Result warning.
  ///
  /// In en, this message translates to:
  /// **'The final concentration is higher than the stock — check the input.'**
  String get calcWarnExceeds;

  /// Dilution assumption.
  ///
  /// In en, this message translates to:
  /// **'The amount of substance is conserved during dilution.'**
  String get calcDilutionAssumptionConservation;

  /// Dilution assumption.
  ///
  /// In en, this message translates to:
  /// **'Volumes are additive and mixing is complete.'**
  String get calcDilutionAssumptionMixing;

  /// Dilution limitation.
  ///
  /// In en, this message translates to:
  /// **'Not suitable where volume contraction on mixing is significant (for example, concentrated ethanol and water).'**
  String get calcDilutionLimitationContraction;

  /// Reference note for definitional formulas.
  ///
  /// In en, this message translates to:
  /// **'Definitional relationship (conservation of the amount of substance); no literature values are used.'**
  String get calcDefinitional;

  /// Calculator review notice.
  ///
  /// In en, this message translates to:
  /// **'This calculator has not yet been reviewed by a laboratory reviewer.'**
  String get calcNeedsReviewNotice;

  /// Screen reader label for the result.
  ///
  /// In en, this message translates to:
  /// **'Result: {value}'**
  String calcResultSemantics(String value);

  /// Library section.
  ///
  /// In en, this message translates to:
  /// **'Substances'**
  String get librarySubstances;

  /// Library section.
  ///
  /// In en, this message translates to:
  /// **'Analytical methods'**
  String get libraryMethods;

  /// Library section.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get librarySpecimens;

  /// Library section.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get libraryReferences;

  /// Library section.
  ///
  /// In en, this message translates to:
  /// **'Glossary'**
  String get libraryGlossary;

  /// Filter field hint.
  ///
  /// In en, this message translates to:
  /// **'Filter this section…'**
  String get libraryFilterHint;

  /// Status filter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'No entries match the filter.'**
  String get libraryEmptyFiltered;

  /// Substance card section.
  ///
  /// In en, this message translates to:
  /// **'Names and synonyms'**
  String get detailNames;

  /// Substance card section.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get detailClass;

  /// Substance card section.
  ///
  /// In en, this message translates to:
  /// **'Metabolites'**
  String get detailMetabolites;

  /// Substance card section.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get detailSpecimens;

  /// Substance card section.
  ///
  /// In en, this message translates to:
  /// **'Analytical methods'**
  String get detailMethods;

  /// Substance card section.
  ///
  /// In en, this message translates to:
  /// **'Reference concentrations'**
  String get detailConcentrations;

  /// Substance card section.
  ///
  /// In en, this message translates to:
  /// **'Interpretation'**
  String get detailInterpretation;

  /// Substance card section.
  ///
  /// In en, this message translates to:
  /// **'Stability and storage'**
  String get detailStability;

  /// Substance card section.
  ///
  /// In en, this message translates to:
  /// **'Interferences'**
  String get detailInterferences;

  /// Substance card section.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get detailReferences;

  /// Card field.
  ///
  /// In en, this message translates to:
  /// **'Evidence status'**
  String get detailEvidenceStatus;

  /// Card field.
  ///
  /// In en, this message translates to:
  /// **'Last reviewed'**
  String get detailLastReviewed;

  /// Card field value.
  ///
  /// In en, this message translates to:
  /// **'Not reviewed'**
  String get detailNotReviewed;

  /// Placeholder section body.
  ///
  /// In en, this message translates to:
  /// **'Placeholder — no scientific content yet.'**
  String get detailPlaceholder;

  /// Mandatory interpretation note.
  ///
  /// In en, this message translates to:
  /// **'A concentration alone does not establish a cause of death. Values will be shown only with matrix, population and sources.'**
  String get detailConcentrationsNote;

  /// Opens provenance sheet.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesButton;

  /// Sources sheet empty state.
  ///
  /// In en, this message translates to:
  /// **'No sources — this entry is test data.'**
  String get sourcesNone;

  /// Search result group.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get searchGroupTools;

  /// Search result group.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get searchGroupLearning;

  /// Clears local search history.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get searchClearHistory;

  /// Clears the query field.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearQuery;

  /// No results heading.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String searchNoResultsTitle(String query);

  /// No results hint.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling or try another language — English, Russian and Uzbek names are supported.'**
  String get searchNoResultsBody;

  /// Label for internal results.
  ///
  /// In en, this message translates to:
  /// **'On this device · offline'**
  String get searchOfflineLabel;

  /// External search section.
  ///
  /// In en, this message translates to:
  /// **'Scientific databases (online)'**
  String get searchExternalTitle;

  /// External search placeholder.
  ///
  /// In en, this message translates to:
  /// **'PubMed, PubChem and Crossref search will be added in a later version. External results are never mixed with reviewed internal data.'**
  String get searchExternalBody;

  /// Hint before typing.
  ///
  /// In en, this message translates to:
  /// **'Type at least two characters.'**
  String get searchTypeToStart;

  /// Screen reader summary.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String searchResultsSemantics(int count);

  /// AI input heading.
  ///
  /// In en, this message translates to:
  /// **'Ask Forensic AI'**
  String get aiAskTitle;

  /// AI input hint.
  ///
  /// In en, this message translates to:
  /// **'Ask about substances, methods or limits of interpretation…'**
  String get aiInputHint;

  /// Send button.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiSend;

  /// Live PII warning.
  ///
  /// In en, this message translates to:
  /// **'Possible personal data detected: {kinds}. Remove it before sending.'**
  String aiPiiDetected(String kinds);

  /// PII kind.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get piiKindEmail;

  /// PII kind.
  ///
  /// In en, this message translates to:
  /// **'phone number'**
  String get piiKindPhone;

  /// PII kind.
  ///
  /// In en, this message translates to:
  /// **'passport/ID number'**
  String get piiKindPassport;

  /// PII kind.
  ///
  /// In en, this message translates to:
  /// **'case number'**
  String get piiKindCase;

  /// PII kind.
  ///
  /// In en, this message translates to:
  /// **'full name'**
  String get piiKindName;

  /// PII kind.
  ///
  /// In en, this message translates to:
  /// **'address'**
  String get piiKindAddress;

  /// Answer layout preview heading.
  ///
  /// In en, this message translates to:
  /// **'Answer layout preview'**
  String get aiPreviewTitle;

  /// Prototype notice.
  ///
  /// In en, this message translates to:
  /// **'UI prototype. The sample below is placeholder text — not AI output and not scientific content.'**
  String get aiPreviewNotice;

  /// AI answer section.
  ///
  /// In en, this message translates to:
  /// **'Available information'**
  String get aiSectionAvailable;

  /// AI answer section.
  ///
  /// In en, this message translates to:
  /// **'Differential considerations'**
  String get aiSectionConsiderations;

  /// AI answer section.
  ///
  /// In en, this message translates to:
  /// **'Limitations of interpretation'**
  String get aiSectionLimitations;

  /// Placeholder sentence.
  ///
  /// In en, this message translates to:
  /// **'Placeholder statement supported by a reviewed internal source.'**
  String get aiSampleInternal;

  /// Placeholder sentence.
  ///
  /// In en, this message translates to:
  /// **'Placeholder statement from an external source that has not been reviewed.'**
  String get aiSampleExternal;

  /// Placeholder sentence.
  ///
  /// In en, this message translates to:
  /// **'Placeholder limitation — a final interpretation requires the full case context.'**
  String get aiSampleLimitation;

  /// Evidence tier label.
  ///
  /// In en, this message translates to:
  /// **'Internal · verified'**
  String get aiEvidenceInternalVerified;

  /// Evidence tier label.
  ///
  /// In en, this message translates to:
  /// **'Internal · reviewed'**
  String get aiEvidenceInternalReviewed;

  /// Evidence tier label.
  ///
  /// In en, this message translates to:
  /// **'External · not reviewed'**
  String get aiEvidenceExternal;

  /// Placeholder source title.
  ///
  /// In en, this message translates to:
  /// **'Placeholder source {number}'**
  String aiPlaceholderSource(int number);

  /// Screen reader label for a citation marker.
  ///
  /// In en, this message translates to:
  /// **'Source {number}'**
  String aiCitationSemantics(int number);

  /// Mandatory footer.
  ///
  /// In en, this message translates to:
  /// **'Final professional judgment belongs to a qualified specialist. Forensic AI does not issue expert conclusions.'**
  String get aiExpertJudgment;

  /// Report AI content (Google Play policy).
  ///
  /// In en, this message translates to:
  /// **'Report this answer'**
  String get aiReport;

  /// Learn section.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get learnCourses;

  /// Learn section.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get learnLessons;

  /// Learn section.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get learnQuiz;

  /// Learn section.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get learnFlashcards;

  /// Learn section.
  ///
  /// In en, this message translates to:
  /// **'Case studies'**
  String get learnCases;

  /// Learn section.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get learnProgress;

  /// Progress state.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get learnNotStarted;

  /// Progress empty state.
  ///
  /// In en, this message translates to:
  /// **'Progress is saved on this device once you start.'**
  String get learnProgressEmpty;

  /// Lesson count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lesson} other{{count} lessons}}'**
  String learnLessonCount(int count);

  /// Start action.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get learnStart;

  /// Quiz action.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get quizCheck;

  /// Quiz feedback.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get quizCorrect;

  /// Quiz feedback.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get quizIncorrect;

  /// Quiz explanation heading.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get quizExplanation;

  /// Flashcard action.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get flashcardShowAnswer;

  /// Flashcard rating.
  ///
  /// In en, this message translates to:
  /// **'Knew it'**
  String get flashcardKnew;

  /// Flashcard rating.
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get flashcardAgain;

  /// Profile section.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// Profile section.
  ///
  /// In en, this message translates to:
  /// **'Account and purchases'**
  String get profileSectionAccount;

  /// Profile section.
  ///
  /// In en, this message translates to:
  /// **'About and legal'**
  String get profileSectionAbout;

  /// Settings row.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get settingsContrast;

  /// Contrast option.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get contrastStandard;

  /// Contrast option.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get contrastHigh;

  /// Explains system contrast.
  ///
  /// In en, this message translates to:
  /// **'System follows the device accessibility setting.'**
  String get contrastSystemHint;

  /// Legal link.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Legal link.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// Legal link.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// About link.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// Account deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No account state.
  ///
  /// In en, this message translates to:
  /// **'No account — the app works without signing in.'**
  String get accountNone;

  /// Draft notice on legal documents.
  ///
  /// In en, this message translates to:
  /// **'Draft. This document will be published after professional legal review.'**
  String get legalDraftNotice;

  /// Privacy draft summary.
  ///
  /// In en, this message translates to:
  /// **'The core library and calculators work offline. Search history and progress stay on your device. The app contains no advertising SDKs. Personal or case data is never sent to AI automatically.'**
  String get privacySummary;

  /// About text.
  ///
  /// In en, this message translates to:
  /// **'Professional forensic reference, education and scientific calculation software.'**
  String get aboutBody;

  /// About text.
  ///
  /// In en, this message translates to:
  /// **'The app version and the scientific database version are tracked separately.'**
  String get aboutVersions;

  /// Store not connected notice.
  ///
  /// In en, this message translates to:
  /// **'The store is not connected in this build, so purchase is unavailable.'**
  String get storeNotConnected;

  /// Restore purchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get restorePurchases;

  /// Restore result.
  ///
  /// In en, this message translates to:
  /// **'No purchases to restore.'**
  String get restoreNothing;

  /// Subscription principle.
  ///
  /// In en, this message translates to:
  /// **'Disclaimers, limitations and sources are never behind a paywall.'**
  String get subscriptionSafetyNote;

  /// Module hub section.
  ///
  /// In en, this message translates to:
  /// **'Tools in this section'**
  String get moduleHubTools;

  /// Module hub section.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get moduleHubReference;

  /// Settings row: country/jurisdiction for the legal layer.
  ///
  /// In en, this message translates to:
  /// **'Jurisdiction'**
  String get settingsJurisdiction;

  /// Picker intro. Explains layer separation.
  ///
  /// In en, this message translates to:
  /// **'Scientific evidence is international and the same in every country. The jurisdiction only selects the legal and procedural layer (laws, controlled-substance schedules, national methods), which is always shown separately.'**
  String get jurisdictionPickerIntro;

  /// Picker group header.
  ///
  /// In en, this message translates to:
  /// **'International and regional'**
  String get jurisdictionGroupGlobal;

  /// Picker group header.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get jurisdictionGroupCountries;

  /// Honest empty state for the legal layer.
  ///
  /// In en, this message translates to:
  /// **'No legal or procedural content has been loaded for this jurisdiction yet. Every future entry will show its official source, effective date, version and last verification date.'**
  String get jurisdictionNoContent;

  /// Planned feature title.
  ///
  /// In en, this message translates to:
  /// **'Compare jurisdictions'**
  String get jurisdictionCompare;

  /// Planned feature note.
  ///
  /// In en, this message translates to:
  /// **'Planned. Becomes available once verified legal content exists for at least two jurisdictions.'**
  String get jurisdictionCompareSoon;

  /// Detail hint when International is selected.
  ///
  /// In en, this message translates to:
  /// **'International is selected: only international conventions and standards apply here. Choose a country to see its legal layer.'**
  String get jurisdictionInternationalHint;

  /// Detail section: global scientific core.
  ///
  /// In en, this message translates to:
  /// **'International scientific evidence'**
  String get detailLayerScientific;

  /// Detail note under scientific layer.
  ///
  /// In en, this message translates to:
  /// **'Not country-specific. Legal status and national procedures are shown separately below.'**
  String get detailLayerScientificNote;

  /// Detail section: jurisdiction layer header.
  ///
  /// In en, this message translates to:
  /// **'Jurisdiction layer: {name}'**
  String detailLayerJurisdiction(String name);

  /// Detail row in jurisdiction layer.
  ///
  /// In en, this message translates to:
  /// **'Legal status'**
  String get detailLegalStatus;

  /// Detail row in jurisdiction layer.
  ///
  /// In en, this message translates to:
  /// **'National methods and procedures'**
  String get detailNationalMethods;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Change jurisdiction'**
  String get detailChangeJurisdiction;

  /// Purchase screen title and profile row.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access'**
  String get purchaseTitle;

  /// Purchase type label.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase'**
  String get purchaseOneTime;

  /// Price line; {price} comes from the store (or reference price).
  ///
  /// In en, this message translates to:
  /// **'{price} · One-time purchase'**
  String purchasePriceLine(String price);

  /// Shown when the store price is not available.
  ///
  /// In en, this message translates to:
  /// **'Reference price. The final price in your currency is shown by the App Store or Google Play.'**
  String get purchaseReferencePriceNote;

  /// Lifetime value.
  ///
  /// In en, this message translates to:
  /// **'Professional forensic reference'**
  String get purchaseValueReference;

  /// Lifetime value.
  ///
  /// In en, this message translates to:
  /// **'Scientific calculators & laboratory tools'**
  String get purchaseValueTools;

  /// Lifetime value.
  ///
  /// In en, this message translates to:
  /// **'Verified sources & evidence status'**
  String get purchaseValueSources;

  /// Lifetime value.
  ///
  /// In en, this message translates to:
  /// **'Offline professional database'**
  String get purchaseValueOffline;

  /// Lifetime value.
  ///
  /// In en, this message translates to:
  /// **'Learning & professional development'**
  String get purchaseValueLearning;

  /// Lifetime value.
  ///
  /// In en, this message translates to:
  /// **'Future scientific content updates'**
  String get purchaseValueUpdates;

  /// Primary purchase button.
  ///
  /// In en, this message translates to:
  /// **'Unlock FORENSIC EXPERT'**
  String get purchaseCta;

  /// Below the purchase button.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase · No recurring subscription'**
  String get purchaseFooter;

  /// Free version section.
  ///
  /// In en, this message translates to:
  /// **'Free version'**
  String get purchaseFreeTitle;

  /// What the free version includes.
  ///
  /// In en, this message translates to:
  /// **'Try before you buy: a search demo, selected reference entries, selected tools and demo lessons.'**
  String get purchaseFreeBody;

  /// AI is not unlimited.
  ///
  /// In en, this message translates to:
  /// **'Forensic AI is not included without limits: it has server costs. Any AI allowance will be stated clearly before purchase.'**
  String get purchaseAiNote;

  /// Shown when lifetime is active.
  ///
  /// In en, this message translates to:
  /// **'Lifetime access is active'**
  String get purchaseOwned;

  /// Purchase tapped while store unavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not available in this build.'**
  String get purchaseUnavailableSnack;

  /// Profile value: free access.
  ///
  /// In en, this message translates to:
  /// **'Free version'**
  String get accessFree;

  /// Profile value: lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get accessLifetime;

  /// Home notice while the content pack is the unreviewed pilot.
  ///
  /// In en, this message translates to:
  /// **'Pilot scientific database: every entry is awaiting expert review. Information is shown with its sources and is not a final conclusion.'**
  String get homePilotNotice;

  /// Detail section.
  ///
  /// In en, this message translates to:
  /// **'Identifiers'**
  String get detailIdentity;

  /// Identifier row.
  ///
  /// In en, this message translates to:
  /// **'Molecular formula'**
  String get detailMolecularFormula;

  /// Identifier row.
  ///
  /// In en, this message translates to:
  /// **'Molecular weight (g/mol)'**
  String get detailMolecularWeight;

  /// Identifier row.
  ///
  /// In en, this message translates to:
  /// **'IUPAC name'**
  String get detailIupac;

  /// Detail section.
  ///
  /// In en, this message translates to:
  /// **'Biomarker'**
  String get detailBiomarker;

  /// Detail section.
  ///
  /// In en, this message translates to:
  /// **'Transformation product'**
  String get detailTransformationProduct;

  /// Detail section.
  ///
  /// In en, this message translates to:
  /// **'Metabolism'**
  String get detailMetabolismNote;

  /// Quoted sentence from the source.
  ///
  /// In en, this message translates to:
  /// **'Source excerpt'**
  String get detailExcerpt;

  /// Licence does not allow showing the quote.
  ///
  /// In en, this message translates to:
  /// **'The quotation is not shown because the source licence does not permit reuse. Open the source to read it.'**
  String get detailExcerptWithheld;

  /// Provenance block heading.
  ///
  /// In en, this message translates to:
  /// **'Provenance'**
  String get detailProvenance;

  /// Evidence level chip.
  ///
  /// In en, this message translates to:
  /// **'Evidence level {level}'**
  String detailEvidenceLevel(String level);

  /// Row label.
  ///
  /// In en, this message translates to:
  /// **'Reviewer status'**
  String get detailReviewerStatus;

  /// No reviews yet.
  ///
  /// In en, this message translates to:
  /// **'No expert reviews yet (2 required)'**
  String get detailReviewsNone;

  /// Review count.
  ///
  /// In en, this message translates to:
  /// **'Expert reviews: {count}'**
  String detailReviewsCount(int count);

  /// Row label.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get detailVersion;

  /// Claim and database version.
  ///
  /// In en, this message translates to:
  /// **'Claim v{claim} · database {pack}'**
  String detailVersionValue(int claim, String pack);

  /// Names are machine draft.
  ///
  /// In en, this message translates to:
  /// **'Names: machine draft, translation not reviewed'**
  String get detailTranslationDraft;

  /// Section without sourced content.
  ///
  /// In en, this message translates to:
  /// **'No sourced content for this section yet.'**
  String get detailNoContentYet;

  /// Source access date.
  ///
  /// In en, this message translates to:
  /// **'Accessed {date}'**
  String detailSourceAccessed(String date);

  /// Identifier auto-check.
  ///
  /// In en, this message translates to:
  /// **'Identifier checked automatically'**
  String get detailIdentifierVerified;

  /// Licence row.
  ///
  /// In en, this message translates to:
  /// **'Licence mode: {mode}'**
  String detailSourceLicence(String mode);

  /// Control schedule line.
  ///
  /// In en, this message translates to:
  /// **'{convention}: Schedule {schedules}'**
  String legalSchedule(String convention, String schedules);

  /// Row from the official list.
  ///
  /// In en, this message translates to:
  /// **'Row in the official list'**
  String get legalListRow;

  /// Effective date.
  ///
  /// In en, this message translates to:
  /// **'Edition in force from {date}'**
  String legalEffective(String date);

  /// Year-only precision.
  ///
  /// In en, this message translates to:
  /// **'(source gives the year only)'**
  String get legalDateYearOnly;

  /// Last verified.
  ///
  /// In en, this message translates to:
  /// **'Last verified {date}'**
  String legalLastVerified(String date);

  /// INT jurisdiction label.
  ///
  /// In en, this message translates to:
  /// **'International (UN conventions)'**
  String get legalInternationalLayer;

  /// Absence is not proof.
  ///
  /// In en, this message translates to:
  /// **'Absence from these lists does not mean a substance is uncontrolled: national law may differ.'**
  String get legalNotInListNote;

  /// No national content.
  ///
  /// In en, this message translates to:
  /// **'No national legal content has been loaded for {name} yet.'**
  String legalNoNational(String name);

  /// Paywall card title.
  ///
  /// In en, this message translates to:
  /// **'Included in FORENSIC EXPERT Lifetime'**
  String get lockedTitle;

  /// What stays open.
  ///
  /// In en, this message translates to:
  /// **'Names, warnings and sources stay open. Scientific details and the jurisdiction layer unlock with Lifetime Access.'**
  String get lockedBody;

  /// Badge on free demo entries.
  ///
  /// In en, this message translates to:
  /// **'Free demo'**
  String get freeDemoBadge;

  /// Badge on locked entries.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lockedBadge;

  /// Hidden results count.
  ///
  /// In en, this message translates to:
  /// **'{count} more results with Lifetime'**
  String searchMoreLocked(int count);

  /// No real courses yet.
  ///
  /// In en, this message translates to:
  /// **'Courses will appear after expert review of the learning content.'**
  String get learnEmptyCourses;

  /// Loading DB.
  ///
  /// In en, this message translates to:
  /// **'Loading scientific database…'**
  String get contentLoading;

  /// No pack.
  ///
  /// In en, this message translates to:
  /// **'The scientific database is not installed in this build.'**
  String get libraryNotInstalled;

  /// Store pending.
  ///
  /// In en, this message translates to:
  /// **'Purchase is waiting for confirmation from the store.'**
  String get purchasePending;

  /// Purchase failed.
  ///
  /// In en, this message translates to:
  /// **'The purchase was not completed.'**
  String get purchaseFailed;

  /// Purchase cancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled.'**
  String get purchaseCancelled;

  /// Unlocked.
  ///
  /// In en, this message translates to:
  /// **'Lifetime access unlocked. Thank you!'**
  String get purchaseSuccess;

  /// Brand status.
  ///
  /// In en, this message translates to:
  /// **'Name and logo: trademark clearance pending.'**
  String get aboutTrademarkPending;

  /// Diagnostics (debug/profile only).
  ///
  /// In en, this message translates to:
  /// **'Purchase: none confirmed by the store'**
  String get diagPurchaseNone;

  /// Diagnostics (debug/profile only).
  ///
  /// In en, this message translates to:
  /// **'Purchase: confirmed by the store only — server verification not connected (release blocker)'**
  String get diagPurchaseStore;

  /// Diagnostics (debug/profile only).
  ///
  /// In en, this message translates to:
  /// **'Purchase: verified by the server'**
  String get diagPurchaseServer;

  /// Scientific status: draft, not yet submitted for review.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;
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
