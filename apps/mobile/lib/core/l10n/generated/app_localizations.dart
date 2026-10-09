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

  /// Mode title.
  ///
  /// In en, this message translates to:
  /// **'How will you use FORENSIC EXPERT?'**
  String get modeTitle;

  /// Mode subtitle.
  ///
  /// In en, this message translates to:
  /// **'The home screen adapts to your choice. You can change it later in Profile.'**
  String get modeSubtitle;

  /// Mode.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get modeProfessional;

  /// Mode card description (short).
  ///
  /// In en, this message translates to:
  /// **'Forensic experts, physicians, toxicologists, chemists and lab specialists'**
  String get modeProfessionalDescription;

  /// Mode.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get modeStudent;

  /// Mode description.
  ///
  /// In en, this message translates to:
  /// **'Students, residents and trainees, researchers and learners'**
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

  /// Empty state title.
  ///
  /// In en, this message translates to:
  /// **'No reviewed content to show'**
  String get inDevelopmentTitle;

  /// Empty state body.
  ///
  /// In en, this message translates to:
  /// **'No reviewed information has been added to this section yet.'**
  String get inDevelopmentBody;

  /// Mandatory banner for content that is not reviewed.
  ///
  /// In en, this message translates to:
  /// **'Not yet confirmed by an expert'**
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

  /// AI state title.
  ///
  /// In en, this message translates to:
  /// **'AI is temporarily unavailable'**
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

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Legal and safety'**
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

  /// Demo-build notice.
  ///
  /// In en, this message translates to:
  /// **'Demonstration build: entries marked SAMPLE are illustrative and are not scientific content.'**
  String get homePrototypeNotice;

  /// Badge for illustrative sample entries.
  ///
  /// In en, this message translates to:
  /// **'SAMPLE'**
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
  /// **'Postmortem interval (PMI) — Henssge'**
  String get toolPmiName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Rectal temperature nomogram (Henssge): estimate with 95 % limits.'**
  String get toolPmiDesc;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Molarity and mass concentration'**
  String get toolMolarityName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Molar concentration from weighed mass, molar mass and volume.'**
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
  /// **'mg/L, µg/mL, ng/mL, mmol/L; mass ↔ molar with a supplied molar mass.'**
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

  /// Entry without reviewed details.
  ///
  /// In en, this message translates to:
  /// **'No reviewed scientific details are available for this entry yet.'**
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

  /// No sources.
  ///
  /// In en, this message translates to:
  /// **'No sources are linked to this entry.'**
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

  /// External search note.
  ///
  /// In en, this message translates to:
  /// **'External databases (PubMed, PubChem, Crossref) are not connected in this version. External results are never mixed with the reviewed internal database.'**
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

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Answer layout (demonstration)'**
  String get aiPreviewTitle;

  /// Demo notice.
  ///
  /// In en, this message translates to:
  /// **'DEMONSTRATION — this is not an AI response and not scientific advice. It only shows how a connected answer will be structured.'**
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

  /// Demo statement.
  ///
  /// In en, this message translates to:
  /// **'Example statement linked to a reviewed internal source.'**
  String get aiSampleInternal;

  /// Demo statement.
  ///
  /// In en, this message translates to:
  /// **'Example statement from an external source that has not been reviewed.'**
  String get aiSampleExternal;

  /// Demo statement.
  ///
  /// In en, this message translates to:
  /// **'Example limitation — a final interpretation requires the full case context.'**
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

  /// Demo source.
  ///
  /// In en, this message translates to:
  /// **'Example source {number}'**
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

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Data on this device'**
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

  /// Draft notice on legal documents.
  ///
  /// In en, this message translates to:
  /// **'Draft. This document will be published after professional legal review.'**
  String get legalDraftNotice;

  /// Privacy summary.
  ///
  /// In en, this message translates to:
  /// **'The core library and calculators work offline. Search history, progress and your optional profile (name, organisation, specialty) stay on your device. Profile details and qualification documents are sent only if you submit a professional verification application once that service is connected; documents are stored privately and never shown publicly. The app contains no advertising SDKs. Personal or case data is never sent to AI automatically.\n\nInvitations: if you use a colleague’s invitation code, the server stores only the link between the two accounts and a salted hash of your email (to prevent abuse after account re-creation). Inviters see only totals — never your name, email, profile or documents. The app never reads your contacts.\n\nSuggestions & support: the message you send in «Suggestions & support», an optional screenshot (JPEG/PNG/WebP only, up to 5 MB), the request type and your account e-mail are stored on our server only to reply to you and improve the app. Only an authorised FORENSIC EXPERT team administrator can see them; other users never can. Replies are signed «FORENSIC EXPERT team», not with an administrator\'s name. Administrator actions are logged (without message text). Your consent is requested before a request is sent. Requests and screenshots are not shared with third parties and are not used for advertising or AI training. If you delete your account, your requests, messages and screenshots are deleted permanently.'**
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

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'The App Store / Google Play is not connected in this build. Prices and purchases appear only when the store provides them.'**
  String get storeNotConnected;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'No active subscriptions to restore.'**
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

  /// Paywall title.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get purchaseTitle;

  /// Locked-content button.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get purchaseCta;

  /// Tier name.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get purchaseFreeTitle;

  /// Free tier summary.
  ///
  /// In en, this message translates to:
  /// **'Core offline reference, search and basic calculators — no account required.'**
  String get purchaseFreeBody;

  /// Paywall note.
  ///
  /// In en, this message translates to:
  /// **'Professional AI features become available only when the AI service is connected; limits will be stated before purchase.'**
  String get purchaseAiNote;

  /// Snackbar after restore.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is active'**
  String get purchaseOwned;

  /// Purchase tapped while store unavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not available in this build.'**
  String get purchaseUnavailableSnack;

  /// Plan name.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get accessFree;

  /// Home review notice.
  ///
  /// In en, this message translates to:
  /// **'The scientific database is under expert review. Every entry is shown with its sources and review status and is not a final conclusion.'**
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
  /// **'Names are machine-translated and not yet reviewed'**
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
  /// **'DOI/PMID checked automatically'**
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

  /// Locked content title.
  ///
  /// In en, this message translates to:
  /// **'Included in Student Pro and Professional Pro'**
  String get lockedTitle;

  /// Locked content body.
  ///
  /// In en, this message translates to:
  /// **'Names, warnings and sources stay open. Scientific details and the jurisdiction layer unlock with a paid plan.'**
  String get lockedBody;

  /// Badge on free demo entries.
  ///
  /// In en, this message translates to:
  /// **'Free demo'**
  String get freeDemoBadge;

  /// Badge.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get lockedBadge;

  /// Search.
  ///
  /// In en, this message translates to:
  /// **'{count} more results with a paid plan'**
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

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Subscription activated. Thank you!'**
  String get purchaseSuccess;

  /// Brand status.
  ///
  /// In en, this message translates to:
  /// **'Name and logo: trademark clearance pending.'**
  String get aboutTrademarkPending;

  /// Diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Subscription: none confirmed by the store'**
  String get diagPurchaseNone;

  /// Diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Subscription: confirmed by the store only — server verification not connected (release blocker)'**
  String get diagPurchaseStore;

  /// Diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Subscription: verified by the server'**
  String get diagPurchaseServer;

  /// Scientific status: draft, not yet submitted for review.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// Search group.
  ///
  /// In en, this message translates to:
  /// **'Forensic medicine & biochemistry'**
  String get searchGroupTopics;

  /// Search group.
  ///
  /// In en, this message translates to:
  /// **'Reagents & solutions'**
  String get searchGroupReagents;

  /// Search group.
  ///
  /// In en, this message translates to:
  /// **'Screening tests'**
  String get searchGroupScreening;

  /// Search group.
  ///
  /// In en, this message translates to:
  /// **'Standards & laws'**
  String get searchGroupStandardsLaws;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Biochemistry'**
  String get moduleBiochemistry;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Reagents & solutions'**
  String get moduleReagents;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Rapid & screening tests'**
  String get moduleScreening;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Methods & SOP'**
  String get moduleMethods;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Law & jurisdictions'**
  String get moduleStandardsLaws;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Emerging issues'**
  String get moduleEmerging;

  /// Home section heading.
  ///
  /// In en, this message translates to:
  /// **'Professional areas'**
  String get homeAreasHeading;

  /// Home: offline database card title.
  ///
  /// In en, this message translates to:
  /// **'Offline database'**
  String get homeDbTitle;

  /// Content pack version.
  ///
  /// In en, this message translates to:
  /// **'Content pack {version}'**
  String homeDbPack(String version);

  /// Scientific DB component version.
  ///
  /// In en, this message translates to:
  /// **'Scientific data {version}'**
  String homeDbScientific(String version);

  /// Jurisdiction data component version.
  ///
  /// In en, this message translates to:
  /// **'Jurisdiction data {version}'**
  String homeDbJurisdiction(String version);

  /// Home: privacy/offline note.
  ///
  /// In en, this message translates to:
  /// **'Works offline. Searches and questions stay on this device.'**
  String get homeDbOffline;

  /// Home: no content pack.
  ///
  /// In en, this message translates to:
  /// **'Content pack is not installed.'**
  String get homeDbNotInstalled;

  /// Home: content pack loading.
  ///
  /// In en, this message translates to:
  /// **'Opening the offline database…'**
  String get homeDbLoading;

  /// Knowledge list empty state.
  ///
  /// In en, this message translates to:
  /// **'No records in the installed content pack yet.'**
  String get knowledgeEmpty;

  /// Taxonomy topic without content.
  ///
  /// In en, this message translates to:
  /// **'No sourced content yet'**
  String get knowledgeNoSourcedContent;

  /// Section: sourced statements (claims).
  ///
  /// In en, this message translates to:
  /// **'Sourced statements'**
  String get knowledgeStatements;

  /// Section: limitations and safety (never paywalled).
  ///
  /// In en, this message translates to:
  /// **'Limitations & safety'**
  String get knowledgeSafety;

  /// Section: sources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get knowledgeSources;

  /// Section: structured details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get knowledgeDetails;

  /// Value attribution to a source.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String knowledgeSourceRef(String source);

  /// Field not stated by any source.
  ///
  /// In en, this message translates to:
  /// **'Not stated in the sources — not estimated'**
  String get knowledgeNotInSource;

  /// Section: topic taxonomy.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get knowledgeTaxonomy;

  /// Topics with content count.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} topics have sourced content'**
  String knowledgeTopicCount(int count, int total);

  /// Reagent: preparation section.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get reagentPreparation;

  /// Reagent without verified recipe.
  ///
  /// In en, this message translates to:
  /// **'No verified preparation recipe was found in the sources. Ingredients, amounts, order of addition, storage and shelf life are not shown and are never estimated.'**
  String get reagentNoRecipe;

  /// Recipe ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get reagentIngredients;

  /// Recipe final volume.
  ///
  /// In en, this message translates to:
  /// **'Final volume'**
  String get reagentFinalVolume;

  /// Recipe steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get reagentSteps;

  /// Source does not state order.
  ///
  /// In en, this message translates to:
  /// **'The source does not state the order of addition — steps are listed without numbering.'**
  String get reagentOrderNotStated;

  /// Recipe storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get reagentStorage;

  /// Recipe temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get reagentTemperature;

  /// Recipe stability / shelf life.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get reagentStability;

  /// Recipe field.
  ///
  /// In en, this message translates to:
  /// **'Hazard'**
  String get reagentHazards;

  /// Recipe disposal reference.
  ///
  /// In en, this message translates to:
  /// **'Disposal'**
  String get reagentDisposal;

  /// Recipe QC requirement.
  ///
  /// In en, this message translates to:
  /// **'Quality control'**
  String get reagentQc;

  /// Button to the solution preparation calculator.
  ///
  /// In en, this message translates to:
  /// **'Solution preparation calculator'**
  String get reagentOpenCalculator;

  /// Permanent screening disclaimer.
  ///
  /// In en, this message translates to:
  /// **'SCREENING RESULT ≠ CONFIRMED IDENTIFICATION. A positive screen is presumptive and requires a validated confirmatory method.'**
  String get screeningBanner;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'Analyte'**
  String get screeningAnalyte;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'Specimen'**
  String get screeningSpecimen;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'Principle'**
  String get screeningPrinciple;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'Cut-off'**
  String get screeningCutoff;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get screeningSensitivity;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'Specificity'**
  String get screeningSpecificity;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'Cross-reactivity'**
  String get screeningCrossReactivity;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'False positives'**
  String get screeningFalsePositive;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'False negatives'**
  String get screeningFalseNegative;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get screeningLimitations;

  /// Screening: confirmatory methods.
  ///
  /// In en, this message translates to:
  /// **'Confirmatory methods'**
  String get screeningConfirmatory;

  /// Method kind.
  ///
  /// In en, this message translates to:
  /// **'Scientific methods'**
  String get methodKindScientific;

  /// Method kind.
  ///
  /// In en, this message translates to:
  /// **'International standards'**
  String get methodKindInternational;

  /// Method kind.
  ///
  /// In en, this message translates to:
  /// **'National methods'**
  String get methodKindNational;

  /// Method kind.
  ///
  /// In en, this message translates to:
  /// **'Institutional SOPs (standard operating procedures)'**
  String get methodKindSop;

  /// Explains that method kinds are never mixed.
  ///
  /// In en, this message translates to:
  /// **'Method types are kept separate: a scientific method is not a legal requirement, and an institutional SOP applies only to its institution.'**
  String get methodKindNote;

  /// No method records of a kind.
  ///
  /// In en, this message translates to:
  /// **'No records of this type yet.'**
  String get methodNoKindEntries;

  /// Method field.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get methodOrganization;

  /// Method field.
  ///
  /// In en, this message translates to:
  /// **'Jurisdiction'**
  String get methodJurisdiction;

  /// Method field.
  ///
  /// In en, this message translates to:
  /// **'Techniques'**
  String get methodTechniques;

  /// Method field.
  ///
  /// In en, this message translates to:
  /// **'Document version'**
  String get methodDocumentVersion;

  /// Emerging issue date.
  ///
  /// In en, this message translates to:
  /// **'Published {date}'**
  String emergingDate(String date);

  /// Emerging issue field.
  ///
  /// In en, this message translates to:
  /// **'Evidence type'**
  String get emergingEvidenceType;

  /// Emerging issue scope.
  ///
  /// In en, this message translates to:
  /// **'Scope: global'**
  String get emergingScopeGlobal;

  /// Evidence type.
  ///
  /// In en, this message translates to:
  /// **'Official alert'**
  String get evidenceTypeOfficialAlert;

  /// Evidence type.
  ///
  /// In en, this message translates to:
  /// **'Peer-reviewed publication'**
  String get evidenceTypePeerReviewed;

  /// Evidence type.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get evidenceTypeReport;

  /// Evidence type.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get evidenceTypeStandard;

  /// Emerging issues explainer.
  ///
  /// In en, this message translates to:
  /// **'Each item has a source, a date, an evidence type and a scope. This is not a news feed.'**
  String get emergingNote;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'New psychoactive substances'**
  String get emergingCatNps;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'Synthetic opioids'**
  String get emergingCatSyntheticOpioids;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'Novel stimulants'**
  String get emergingCatStimulants;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'Analytical challenges'**
  String get emergingCatAnalytical;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'New interferences'**
  String get emergingCatInterferences;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'Postmortem interpretation'**
  String get emergingCatPostmortem;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'New standards'**
  String get emergingCatStandards;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'Method validation'**
  String get emergingCatValidation;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'Laboratory quality'**
  String get emergingCatQuality;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'Scientific alert'**
  String get emergingCatAlert;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Death investigation'**
  String get fmTopicDeathInvestigation;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Cause, mechanism and manner of death'**
  String get fmTopicCauseMechanismManner;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Postmortem changes'**
  String get fmTopicPostmortemChanges;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Postmortem interval (PMI)'**
  String get fmTopicPostmortemInterval;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Algor mortis'**
  String get fmTopicAlgorMortis;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Rigor mortis'**
  String get fmTopicRigorMortis;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Livor mortis'**
  String get fmTopicLivorMortis;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Decomposition'**
  String get fmTopicDecomposition;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Trauma'**
  String get fmTopicTrauma;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Blunt force injury'**
  String get fmTopicBluntForceInjury;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Sharp force injury'**
  String get fmTopicSharpForceInjury;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Firearm injury'**
  String get fmTopicFirearmInjury;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Asphyxia'**
  String get fmTopicAsphyxia;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Burns'**
  String get fmTopicBurns;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Electrical injury'**
  String get fmTopicElectricalInjury;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Hypothermia and hyperthermia'**
  String get fmTopicHypoHyperthermia;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Drowning'**
  String get fmTopicDrowning;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Forensic anthropology'**
  String get fmTopicAnthropology;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Age estimation'**
  String get fmTopicAgeEstimation;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Sex estimation'**
  String get fmTopicSexEstimation;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Stature estimation'**
  String get fmTopicStatureEstimation;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Forensic odontology'**
  String get fmTopicOdontology;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Disaster victim identification'**
  String get fmTopicDisasterVictimIdentification;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Forensic histology'**
  String get fmTopicHistology;

  /// Forensic medicine taxonomy topic name.
  ///
  /// In en, this message translates to:
  /// **'Postmortem imaging'**
  String get fmTopicPostmortemImaging;

  /// Compare jurisdictions screen title.
  ///
  /// In en, this message translates to:
  /// **'Compare jurisdictions'**
  String get compareTitle;

  /// Comparison topic: drink-driving limit.
  ///
  /// In en, this message translates to:
  /// **'Drink-driving: prescribed alcohol limit'**
  String get compareTopicDrinkDrive;

  /// Comparison cell without data.
  ///
  /// In en, this message translates to:
  /// **'No data — no conclusion is drawn'**
  String get compareNoData;

  /// No comparable legal data.
  ///
  /// In en, this message translates to:
  /// **'No comparable legal data in the content pack yet.'**
  String get compareNoTopics;

  /// Comparison disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Reference information, not legal advice. Always check the current official text.'**
  String get compareNotAdvice;

  /// Explains noData semantics.
  ///
  /// In en, this message translates to:
  /// **'Missing data never means “allowed”, “not controlled” or “prohibited”.'**
  String get compareNoInference;

  /// Rule overrides a less specific one.
  ///
  /// In en, this message translates to:
  /// **'Overrides the rule of {jurisdiction}'**
  String compareOverrides(String jurisdiction);

  /// Article / section of instrument.
  ///
  /// In en, this message translates to:
  /// **'Section: {section}'**
  String compareArticle(String section);

  /// Issuing authority.
  ///
  /// In en, this message translates to:
  /// **'Authority: {name}'**
  String compareAuthority(String name);

  /// Official text excerpt label.
  ///
  /// In en, this message translates to:
  /// **'Official text'**
  String get compareOfficialExcerpt;

  /// Specimen.
  ///
  /// In en, this message translates to:
  /// **'Breath'**
  String get specimenBreath;

  /// Specimen.
  ///
  /// In en, this message translates to:
  /// **'Blood'**
  String get specimenBlood;

  /// Specimen.
  ///
  /// In en, this message translates to:
  /// **'Urine'**
  String get specimenUrine;

  /// Legal threshold rule title.
  ///
  /// In en, this message translates to:
  /// **'Legal limit'**
  String get legalThresholdTitle;

  /// Legal layer chip: national/regional law.
  ///
  /// In en, this message translates to:
  /// **'National / regional law'**
  String get legalLayerNational;

  /// Button opening jurisdiction comparison.
  ///
  /// In en, this message translates to:
  /// **'Compare jurisdictions'**
  String get legalOpenCompare;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Solution preparation (mass required)'**
  String get toolSolutionName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Mass of substance for a target concentration and final volume: m = C·V(·M)/p. Molar mass and purity come from you (certificate/label).'**
  String get toolSolutionDesc;

  /// Calculator field.
  ///
  /// In en, this message translates to:
  /// **'Target concentration'**
  String get calcTargetConc;

  /// Calculator field.
  ///
  /// In en, this message translates to:
  /// **'Molar mass (g/mol)'**
  String get calcMolarMass;

  /// Calculator field.
  ///
  /// In en, this message translates to:
  /// **'Purity (0–1)'**
  String get calcPurity;

  /// Calculator result label.
  ///
  /// In en, this message translates to:
  /// **'Mass required'**
  String get calcMassRequired;

  /// Calculator error.
  ///
  /// In en, this message translates to:
  /// **'Enter the molar mass from the certificate or label for a molar concentration.'**
  String get calcErrorMolarMass;

  /// Calculator error.
  ///
  /// In en, this message translates to:
  /// **'Purity must be greater than 0 and at most 1.'**
  String get calcErrorPurity;

  /// Calculator assumption.
  ///
  /// In en, this message translates to:
  /// **'Definitional calculation of concentration (no empirical coefficients).'**
  String get calcSolutionAssumptionDefinition;

  /// Calculator assumption.
  ///
  /// In en, this message translates to:
  /// **'Molar mass and purity are supplied by the user; nothing is estimated.'**
  String get calcSolutionAssumptionInputs;

  /// Calculator limitation.
  ///
  /// In en, this message translates to:
  /// **'This is not a reagent recipe: substance choice, order, storage and stability come only from a verified source or SOP.'**
  String get calcSolutionLimitationRecipe;

  /// Calculator limitation.
  ///
  /// In en, this message translates to:
  /// **'Volume change on dissolution is ignored.'**
  String get calcSolutionLimitationVolume;

  /// Calculator warning.
  ///
  /// In en, this message translates to:
  /// **'Purity correction applied.'**
  String get calcWarnPurity;

  /// Territorial extent of a legal provision.
  ///
  /// In en, this message translates to:
  /// **'Territorial extent: {extent}'**
  String legalExtent(String extent);

  /// Rule applies to listed subdivisions.
  ///
  /// In en, this message translates to:
  /// **'Applies to: {places}'**
  String legalAppliesTo(String places);

  /// Instrument legal status.
  ///
  /// In en, this message translates to:
  /// **'In force'**
  String get legalStatusInForce;

  /// Instrument legal status.
  ///
  /// In en, this message translates to:
  /// **'Amended'**
  String get legalStatusAmended;

  /// Instrument legal status.
  ///
  /// In en, this message translates to:
  /// **'Superseded'**
  String get legalStatusSuperseded;

  /// Instrument legal status.
  ///
  /// In en, this message translates to:
  /// **'Repealed'**
  String get legalStatusRepealed;

  /// AI experience toggle.
  ///
  /// In en, this message translates to:
  /// **'Short answer'**
  String get aiExperienceProfessional;

  /// AI experience toggle.
  ///
  /// In en, this message translates to:
  /// **'Explain it to me'**
  String get aiExperienceTutor;

  /// AI experience hint.
  ///
  /// In en, this message translates to:
  /// **'Concise, source-first answers for practitioners.'**
  String get aiExperienceProfessionalHint;

  /// AI experience hint.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step explanations for learning, always with sources.'**
  String get aiExperienceTutorHint;

  /// Button: offline retrieval.
  ///
  /// In en, this message translates to:
  /// **'Find sources offline'**
  String get aiFindSources;

  /// Retrieval results heading.
  ///
  /// In en, this message translates to:
  /// **'Matching statements in the offline database'**
  String get aiRetrievalTitle;

  /// Retrieval results disclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is not an AI answer: these are local search results, each with its source.'**
  String get aiRetrievalNote;

  /// No retrieval context.
  ///
  /// In en, this message translates to:
  /// **'No reliable context in the offline database — no answer is given.'**
  String get aiNoContext;

  /// Safety block.
  ///
  /// In en, this message translates to:
  /// **'Final conclusions on the cause or manner of death are not provided. That decision belongs to the expert with the full case.'**
  String get aiBlockedConclusion;

  /// Safety block.
  ///
  /// In en, this message translates to:
  /// **'Legal conclusions (guilt, charges, sentencing) are not provided.'**
  String get aiBlockedLegal;

  /// Safety block.
  ///
  /// In en, this message translates to:
  /// **'Remove personal data before searching or asking.'**
  String get aiBlockedPii;

  /// Study level filter.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get learnLevelAll;

  /// Study level.
  ///
  /// In en, this message translates to:
  /// **'Foundation'**
  String get learnLevelFoundation;

  /// Study level.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get learnLevelIntermediate;

  /// Study level.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get learnLevelAdvanced;

  /// Lessons completed.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} lessons completed'**
  String learnProgressValue(int done, int total);

  /// Recently opened lessons.
  ///
  /// In en, this message translates to:
  /// **'Recently studied'**
  String get learnHistory;

  /// Bookmarks section.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get learnBookmarks;

  /// No bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Mark a topic with the star to find it here.'**
  String get learnBookmarksEmpty;

  /// Toggle lesson completion.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get learnMarkComplete;

  /// Lesson completed chip.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get learnCompleted;

  /// Explains content-based course.
  ///
  /// In en, this message translates to:
  /// **'Lessons show original source statements. No new scientific text is written; content awaits expert review.'**
  String get learnCourseSourceNote;

  /// Exam mode tile/title.
  ///
  /// In en, this message translates to:
  /// **'Exam mode'**
  String get learnExam;

  /// Exam mode intro.
  ///
  /// In en, this message translates to:
  /// **'Answer all questions. Results and explanations appear only after you submit.'**
  String get learnExamIntro;

  /// Exam submit button.
  ///
  /// In en, this message translates to:
  /// **'Submit exam'**
  String get learnExamSubmit;

  /// Exam score.
  ///
  /// In en, this message translates to:
  /// **'Score: {correct} of {total}'**
  String learnExamScore(int correct, int total);

  /// No exam questions.
  ///
  /// In en, this message translates to:
  /// **'No reviewed exam questions yet. Questions are not generated automatically.'**
  String get learnExamEmpty;

  /// Exam retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get learnExamRetry;

  /// Label for simulated (non-real) case studies.
  ///
  /// In en, this message translates to:
  /// **'SIMULATED CASE — not a real case'**
  String get learnSimulatedCase;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Forensic histology'**
  String get moduleHistology;

  /// Home module.
  ///
  /// In en, this message translates to:
  /// **'Research & evidence'**
  String get moduleResearch;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Alcohols & volatiles'**
  String get group_alcohols_volatiles;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Toxic gases'**
  String get group_toxic_gases;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Opioids'**
  String get group_opioids;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Stimulants'**
  String get group_stimulants;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Cannabinoids'**
  String get group_cannabinoids;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Hallucinogens & dissociatives'**
  String get group_hallucinogens_dissociatives;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Benzodiazepines'**
  String get group_benzodiazepines;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Sedatives & hypnotics'**
  String get group_sedatives_hypnotics;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Barbiturates'**
  String get group_barbiturates;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Antidepressants'**
  String get group_antidepressants;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Antipsychotics'**
  String get group_antipsychotics;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Anticonvulsants'**
  String get group_anticonvulsants;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Common pharmaceuticals'**
  String get group_pharmaceuticals;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Adulterants'**
  String get group_adulterants;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Pesticides & rodenticides'**
  String get group_pesticides;

  /// Substance group (editorial navigation).
  ///
  /// In en, this message translates to:
  /// **'Metals & inorganic poisons'**
  String get group_metals_inorganic;

  /// Substance group filter: all.
  ///
  /// In en, this message translates to:
  /// **'All groups'**
  String get groupAll;

  /// Explains groups are editorial.
  ///
  /// In en, this message translates to:
  /// **'Groups are editorial navigation, not a scientific classification claim.'**
  String get groupEditorialNote;

  /// Substance section.
  ///
  /// In en, this message translates to:
  /// **'Analytical methods (from sources)'**
  String get detailAnalyticalMethods;

  /// Substance section.
  ///
  /// In en, this message translates to:
  /// **'Reported concentrations'**
  String get detailReportedConcentrations;

  /// Permanent banner for reported concentrations.
  ///
  /// In en, this message translates to:
  /// **'Reported values from individual studies or cases — NOT toxic, lethal or legal thresholds. Interpretation depends on specimen, case context, tolerance and postmortem changes.'**
  String get concentrationNotThreshold;

  /// Specimen chips label.
  ///
  /// In en, this message translates to:
  /// **'Specimen'**
  String get concentrationSpecimen;

  /// Context label.
  ///
  /// In en, this message translates to:
  /// **'Context: {context}'**
  String concentrationContext(String context);

  /// Chemical structure section.
  ///
  /// In en, this message translates to:
  /// **'Chemical structure'**
  String get detailStructure;

  /// Entry page section header.
  ///
  /// In en, this message translates to:
  /// **'Related materials'**
  String get detailRelated;

  /// Graph relation label.
  ///
  /// In en, this message translates to:
  /// **'Analysed by (mentioned in source)'**
  String get relationAnalysedBy;

  /// Graph relation label.
  ///
  /// In en, this message translates to:
  /// **'Mentioned together in a metabolism source'**
  String get relationMetabolism;

  /// Graph relation label.
  ///
  /// In en, this message translates to:
  /// **'Confirmatory methods'**
  String get relationConfirmedBy;

  /// Graph relation label.
  ///
  /// In en, this message translates to:
  /// **'Related topics'**
  String get relationRelatedTopic;

  /// Graph relation label.
  ///
  /// In en, this message translates to:
  /// **'Research & evidence'**
  String get relationResearch;

  /// Basis of a link.
  ///
  /// In en, this message translates to:
  /// **'Basis: {basis}'**
  String relationBasis(String basis);

  /// Show all research for entity.
  ///
  /// In en, this message translates to:
  /// **'All research ({count})'**
  String researchMore(int count);

  /// Research library title.
  ///
  /// In en, this message translates to:
  /// **'Research & evidence library'**
  String get researchTitle;

  /// Research library explainer.
  ///
  /// In en, this message translates to:
  /// **'Metadata and links only — full texts are not copied. Dissertations, theses and conference papers are not shown at the level of peer-reviewed full articles.'**
  String get researchNote;

  /// Research filter all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get researchAll;

  /// Badge.
  ///
  /// In en, this message translates to:
  /// **'Peer-reviewed'**
  String get researchPeerReviewed;

  /// Badge.
  ///
  /// In en, this message translates to:
  /// **'Not a peer-reviewed article'**
  String get researchNotPeerReviewed;

  /// Evidence level badge.
  ///
  /// In en, this message translates to:
  /// **'Evidence {level}'**
  String researchEvidence(String level);

  /// Copy link action.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get researchCopyLink;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get researchLinkCopied;

  /// Linked entities heading.
  ///
  /// In en, this message translates to:
  /// **'Linked records'**
  String get researchLinked;

  /// Count.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String researchCount(int count);

  /// Source API.
  ///
  /// In en, this message translates to:
  /// **'Indexed via {api}'**
  String researchSourceApi(String api);

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Journal article'**
  String get researchKindJournalArticle;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get researchKindReview;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Systematic review'**
  String get researchKindSystematicReview;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Meta-analysis'**
  String get researchKindMetaAnalysis;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Case report'**
  String get researchKindCaseReport;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Conference abstract'**
  String get researchKindConferenceAbstract;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Conference paper'**
  String get researchKindConferencePaper;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Doctoral dissertation'**
  String get researchKindDissertation;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Thesis (Master’s / other)'**
  String get researchKindThesis;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Official report'**
  String get researchKindOfficialReport;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Standard / guideline'**
  String get researchKindStandard;

  /// Image badge.
  ///
  /// In en, this message translates to:
  /// **'Schematic — not experimental data'**
  String get imageSchematic;

  /// Image badge.
  ///
  /// In en, this message translates to:
  /// **'Figure from a published study'**
  String get imageRealData;

  /// Image badge.
  ///
  /// In en, this message translates to:
  /// **'Structure depiction (computed)'**
  String get imageDepiction;

  /// Image license.
  ///
  /// In en, this message translates to:
  /// **'License: {license}'**
  String imageLicense(String license);

  /// Attribution heading.
  ///
  /// In en, this message translates to:
  /// **'Attribution'**
  String get imageAttribution;

  /// Original caption heading.
  ///
  /// In en, this message translates to:
  /// **'Original caption (source language)'**
  String get imageOriginalCaption;

  /// Open image semantics.
  ///
  /// In en, this message translates to:
  /// **'Open image: {title}'**
  String imageOpen(String title);

  /// Image fallback.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable offline'**
  String get imageUnavailable;

  /// Gallery heading.
  ///
  /// In en, this message translates to:
  /// **'Scientific visuals'**
  String get imagesHeading;

  /// License label.
  ///
  /// In en, this message translates to:
  /// **'Original work (FORENSIC EXPERT)'**
  String get licenseOriginalWork;

  /// License label.
  ///
  /// In en, this message translates to:
  /// **'Original depiction of factual data'**
  String get licenseFactualDepiction;

  /// Histology disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Reference information for professionals. The app and Forensic AI do not provide histological diagnoses.'**
  String get histologyNote;

  /// Claim field.
  ///
  /// In en, this message translates to:
  /// **'Case observation (single case)'**
  String get fieldCaseObservation;

  /// Claim field.
  ///
  /// In en, this message translates to:
  /// **'Composition (as stated in source)'**
  String get fieldComposition;

  /// Claim field.
  ///
  /// In en, this message translates to:
  /// **'Confirmation requirement'**
  String get fieldConfirmation;

  /// Research metadata label.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get metaAuthors;

  /// Research metadata label.
  ///
  /// In en, this message translates to:
  /// **'Journal / conference'**
  String get metaContainer;

  /// Research metadata label.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get metaInstitution;

  /// Research metadata label.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get metaDegree;

  /// Research metadata label.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get metaYear;

  /// Image metadata label.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get metaCreator;

  /// Image metadata label.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get metaSource;

  /// Image metadata label.
  ///
  /// In en, this message translates to:
  /// **'Accessed'**
  String get metaAccessed;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'TLC (thin-layer chromatography)'**
  String get tech_tlc;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'GC'**
  String get tech_gc;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'GC-FID'**
  String get tech_gcFid;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'Headspace GC'**
  String get tech_headspaceGc;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'GC-MS'**
  String get tech_gcMs;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'HPLC'**
  String get tech_hplc;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'LC-MS/MS'**
  String get tech_lcMsMs;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'UV-Vis spectrophotometry'**
  String get tech_uvVis;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'Immunoassay'**
  String get tech_immunoassay;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'Spectroscopy'**
  String get tech_spectroscopy;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'Sample preparation'**
  String get tech_samplePreparation;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'Extraction'**
  String get tech_extraction;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get tech_calibration;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'Quality control'**
  String get tech_qualityControl;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'Method validation'**
  String get tech_validation;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'Measurement uncertainty'**
  String get tech_uncertainty;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get tech_statistics;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get methodSection_purpose;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get methodSection_scope;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Analytes'**
  String get methodSection_analytes;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get methodSection_specimens;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Principle'**
  String get methodSection_principle;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get methodSection_equipment;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Reagents'**
  String get methodSection_reagents;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Sample preparation'**
  String get methodSection_samplePreparation;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Calibration and QC'**
  String get methodSection_calibrationQc;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get methodSection_workflow;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Interpretation'**
  String get methodSection_interpretation;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get methodSection_limitations;

  /// Method section heading.
  ///
  /// In en, this message translates to:
  /// **'Validation status'**
  String get methodSection_validationStatus;

  /// Tool name.
  ///
  /// In en, this message translates to:
  /// **'Percentage solutions'**
  String get toolPercentName;

  /// Tool description.
  ///
  /// In en, this message translates to:
  /// **'Solute amount for % (w/v), (v/v) or (w/w) by definition.'**
  String get toolPercentDesc;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get calcValue;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get calcFrom;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get calcTo;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'Unit prefixes are SI definitions; mass ↔ molar conversion uses ρ = c · M.'**
  String get calcConvertAssumption;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'The molar mass must come from a certificate or verified identity data; the calculator never estimates it.'**
  String get calcConvertLimitation;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Weighed mass'**
  String get calcMolarityMass;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Final volume'**
  String get calcMolarityVolume;

  /// Calculator output.
  ///
  /// In en, this message translates to:
  /// **'Molar concentration'**
  String get calcMolarityResult;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'Definition of amount-of-substance concentration: c = n / V, with n = m · p / M.'**
  String get calcMolarityAssumption;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Percentage basis'**
  String get calcPercentBasis;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'% (w/v) — g per 100 mL'**
  String get calcPercentWv;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'% (v/v) — mL per 100 mL'**
  String get calcPercentVv;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'% (w/w) — g per 100 g'**
  String get calcPercentWw;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Percentage (%)'**
  String get calcPercentValue;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Total solution volume (mL)'**
  String get calcPercentTotalMl;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Total solution mass (g)'**
  String get calcPercentTotalG;

  /// Calculator output.
  ///
  /// In en, this message translates to:
  /// **'Solute amount'**
  String get calcPercentSolute;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'Percentage definitions as stated for each basis.'**
  String get calcPercentAssumption;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'w/v, v/v and w/w are not interchangeable — use the basis stated in the validated method or SOP.'**
  String get calcPercentLimitationBasis;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Enter a percentage greater than 0 and at most 100.'**
  String get calcErrorPercent;

  /// Field label: list of values.
  ///
  /// In en, this message translates to:
  /// **'Values (separate with spaces, “;” or new lines; decimal 0.5 or 0,5)'**
  String get calcStatsValues;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'n'**
  String get calcStatsN;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'Mean'**
  String get calcStatsMean;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'Median'**
  String get calcStatsMedian;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'SD (n − 1)'**
  String get calcStatsSd;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'CV %'**
  String get calcStatsCv;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get calcStatsMin;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get calcStatsMax;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'Sample standard deviation with an n − 1 denominator.'**
  String get calcStatsAssumption;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'No outlier test or normality check is performed.'**
  String get calcStatsLimitation;

  /// Warning.
  ///
  /// In en, this message translates to:
  /// **'At least two values are needed for SD and CV.'**
  String get calcStatsWarnSd;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Enter numeric values only.'**
  String get calcErrorValues;

  /// Field label: calibration points.
  ///
  /// In en, this message translates to:
  /// **'Calibration points: one “x y” or “x; y” pair per line'**
  String get calcRegPoints;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'Slope (b)'**
  String get calcRegSlope;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'Intercept (a)'**
  String get calcRegIntercept;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'R²'**
  String get calcRegR2;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'Residual SD (s_y/x)'**
  String get calcRegSyx;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'Ordinary least squares, unweighted, y = a + b·x.'**
  String get calcRegAssumptionOls;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'Valid only within the calibrated range; weighting and linearity are decided by method validation.'**
  String get calcRegLimitationRange;

  /// Warning.
  ///
  /// In en, this message translates to:
  /// **'Fewer than five calibration points — interpret with caution.'**
  String get calcRegWarnFew;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Enter at least three “x y” pairs with different x values.'**
  String get calcErrorPoints;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Standard deviation of the response (σ)'**
  String get calcLodSigma;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Slope of the calibration curve (S)'**
  String get calcLodSlope;

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Basis of σ'**
  String get calcLodSigmaBasis;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'SD of blank responses'**
  String get calcLodBasisBlank;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'Residual SD of the regression line'**
  String get calcLodBasisResidual;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'SD of y-intercepts of regression lines'**
  String get calcLodBasisIntercept;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'Detection limit (DL = 3.3σ/S)'**
  String get calcLodLod;

  /// Statistic.
  ///
  /// In en, this message translates to:
  /// **'Quantitation limit (QL = 10σ/S)'**
  String get calcLodLoq;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'σ is estimated by one of the approaches named in the source: blank SD, residual SD or SD of y-intercepts.'**
  String get calcLodAssumptionSigma;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'The response is linear near the limit.'**
  String get calcLodAssumptionLinear;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'This is one of several accepted approaches; visual evaluation and signal-to-noise are others.'**
  String get calcLodLimitationOne;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'The source requires calculated limits to be confirmed by analysing samples near the limit.'**
  String get calcLodLimitationVerify;

  /// Reference.
  ///
  /// In en, this message translates to:
  /// **'ICH Q2(R2) Validation of Analytical Procedures (2023) — §3.2.3.3'**
  String get calcLodReference;

  /// Reference note.
  ///
  /// In en, this message translates to:
  /// **'Factors checked against the official ICH Q2(R2) PDF; they are unchanged from Q2(R1) (superseded). Q2(R2) also allows S/N and direct accuracy/precision confirmation. Laboratory reviewer confirmation pending (RG-25).'**
  String get calcLodReferenceNote;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Use σ = s_y/x and S from this regression'**
  String get calcUseRegression;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Enter σ > 0 and a non-zero slope.'**
  String get calcErrorSigma;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Guideline'**
  String get researchKindGuideline;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Validation study'**
  String get researchKindValidationStudy;

  /// Research kind.
  ///
  /// In en, this message translates to:
  /// **'Case series'**
  String get researchKindCaseSeries;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'GC-MS/MS'**
  String get tech_gcMsMs;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'LC-MS'**
  String get tech_lcMs;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'HRMS (high-resolution mass spectrometry)'**
  String get tech_hrms;

  /// Analytical technique name.
  ///
  /// In en, this message translates to:
  /// **'Spectrophotometry'**
  String get tech_spectrophotometry;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'New biomarkers'**
  String get emergingCatBiomarkers;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'Emerging analytical methods'**
  String get emergingCatMethods;

  /// Emerging category.
  ///
  /// In en, this message translates to:
  /// **'Legal / regulatory updates'**
  String get emergingCatLegal;

  /// Banner level for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get severityCritical;

  /// Banner level for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get severityWarning;

  /// Banner level for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get severityInfo;

  /// Banner level for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Review status'**
  String get severityReview;

  /// Quick access block.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed'**
  String get homeRecentlyViewed;

  /// Quick access empty state.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed records, tools, favourites and searches will appear here. They are stored only on this device.'**
  String get homeQuickEmpty;

  /// Home jurisdiction context.
  ///
  /// In en, this message translates to:
  /// **'Jurisdiction: {name}'**
  String homeJurisdictionChip(String name);

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get homeChange;

  /// Home tile.
  ///
  /// In en, this message translates to:
  /// **'All forensic disciplines'**
  String get homeAllDisciplines;

  /// Home tile body.
  ///
  /// In en, this message translates to:
  /// **'{count} disciplines — scope and currently available content'**
  String homeAllDisciplinesBody(int count);

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic medicine'**
  String get disc_forensicMedicine;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic pathology'**
  String get disc_forensicPathology;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Clinical forensic medicine'**
  String get disc_clinicalForensicMedicine;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic radiology & imaging'**
  String get disc_forensicRadiology;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic psychiatry & psychology'**
  String get disc_forensicPsychiatry;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic toxicology'**
  String get disc_forensicToxicology;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic chemistry'**
  String get disc_forensicChemistry;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic biochemistry'**
  String get disc_forensicBiochemistry;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Analytical science'**
  String get disc_analyticalScience;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic biology'**
  String get disc_forensicBiology;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic genetics / DNA'**
  String get disc_forensicGenetics;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic histology'**
  String get disc_forensicHistology;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic anthropology'**
  String get disc_forensicAnthropology;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic odontology'**
  String get disc_forensicOdontology;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic microbiology'**
  String get disc_forensicMicrobiology;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Forensic entomology'**
  String get disc_forensicEntomology;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'DVI / human identification'**
  String get disc_humanIdentification;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Laboratory quality & validation'**
  String get disc_laboratoryQuality;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Evidence handling & chain of custody'**
  String get disc_evidenceHandling;

  /// Forensic discipline name.
  ///
  /// In en, this message translates to:
  /// **'Education & research'**
  String get disc_educationResearch;

  /// Discipline group.
  ///
  /// In en, this message translates to:
  /// **'Medicine & pathology'**
  String get discGroupMedicine;

  /// Discipline group.
  ///
  /// In en, this message translates to:
  /// **'Toxicology & chemistry'**
  String get discGroupToxChem;

  /// Discipline group.
  ///
  /// In en, this message translates to:
  /// **'Biology & identification'**
  String get discGroupBioId;

  /// Discipline group.
  ///
  /// In en, this message translates to:
  /// **'Laboratory & quality'**
  String get discGroupLab;

  /// Discipline group.
  ///
  /// In en, this message translates to:
  /// **'Education & research'**
  String get discGroupEdu;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Forensic disciplines'**
  String get disciplinesTitle;

  /// Disciplines intro.
  ///
  /// In en, this message translates to:
  /// **'FORENSIC EXPERT covers these disciplines. Content is added gradually and only with sources and expert review — an empty discipline means “no sourced content yet”, not “no knowledge exists”.'**
  String get disciplinesIntro;

  /// Discipline record count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sourced records yet} one{1 sourced record} other{{count} sourced records}}'**
  String disciplineRecords(int count);

  /// Badge.
  ///
  /// In en, this message translates to:
  /// **'Professional reference scope only'**
  String get disciplineReferenceOnly;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get disciplineModules;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Planned topic structure'**
  String get disciplineTopics;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'No sourced content in this discipline yet. Records will be added only with verifiable sources and expert review.'**
  String get disciplineEmpty;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Law & jurisdictions'**
  String get jurisdictionsTitle;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Current jurisdiction'**
  String get jurisdictionCurrent;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Three separate layers'**
  String get jurisdictionLayersTitle;

  /// Layer name.
  ///
  /// In en, this message translates to:
  /// **'Global scientific core — the same in every country'**
  String get layerGlobalCore;

  /// Layer name.
  ///
  /// In en, this message translates to:
  /// **'International standards & methods — not law unless adopted'**
  String get layerIntlStandards;

  /// Layer name.
  ///
  /// In en, this message translates to:
  /// **'Country / jurisdiction law & procedures — only for the selected jurisdiction'**
  String get layerCountryLaw;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Legal & procedural layer'**
  String get jurisdictionViewDetails;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Jurisdictions with legal records'**
  String get jurisdictionWithContent;

  /// Search hint.
  ///
  /// In en, this message translates to:
  /// **'Search country or ISO code'**
  String get jurisdictionSearchHint;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'Content not yet verified for this jurisdiction. Laws of other countries are never shown as a substitute.'**
  String get jurisdictionNotVerified;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Legal records · under legal review'**
  String get jurisdictionPilotContent;

  /// Coverage label.
  ///
  /// In en, this message translates to:
  /// **'Content not yet verified'**
  String get jurisdictionNoContentShort;

  /// Detail line.
  ///
  /// In en, this message translates to:
  /// **'Applies via: {chain}'**
  String jurisdictionChain(String chain);

  /// Info banner.
  ///
  /// In en, this message translates to:
  /// **'Global scientific content works without selecting a jurisdiction. A jurisdiction is needed only for laws, controlled-substance schedules and national procedures.'**
  String get jurisdictionGlobalWorks;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Official documents'**
  String get jurisdictionInstruments;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'International layer (applies to all)'**
  String get jurisdictionIntlLayer;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Jurisdiction-specific layer'**
  String get jurisdictionOwnLayer;

  /// Footnote.
  ///
  /// In en, this message translates to:
  /// **'Country names: Unicode CLDR. The list only enables selection — it does not mean legal content exists.'**
  String get jurisdictionCountryNames;

  /// Document kind label.
  ///
  /// In en, this message translates to:
  /// **'LAW'**
  String get docKindLaw;

  /// Document kind label.
  ///
  /// In en, this message translates to:
  /// **'REGULATION'**
  String get docKindRegulation;

  /// Document kind label.
  ///
  /// In en, this message translates to:
  /// **'STANDARD'**
  String get docKindStandard;

  /// Document kind label.
  ///
  /// In en, this message translates to:
  /// **'GUIDELINE'**
  String get docKindGuideline;

  /// Document kind label.
  ///
  /// In en, this message translates to:
  /// **'METHOD'**
  String get docKindMethod;

  /// Document kind label.
  ///
  /// In en, this message translates to:
  /// **'SOP'**
  String get docKindSop;

  /// Document kind label.
  ///
  /// In en, this message translates to:
  /// **'SCIENTIFIC ARTICLE'**
  String get docKindArticle;

  /// Document kind label.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL DOCUMENT'**
  String get docKindOfficial;

  /// Binding nature.
  ///
  /// In en, this message translates to:
  /// **'Legally binding in its jurisdiction while in force'**
  String get bindingLegal;

  /// Binding nature.
  ///
  /// In en, this message translates to:
  /// **'Voluntary unless adopted by law or accreditation'**
  String get bindingVoluntary;

  /// Binding nature.
  ///
  /// In en, this message translates to:
  /// **'Advisory — not legally binding'**
  String get bindingAdvisory;

  /// Binding nature.
  ///
  /// In en, this message translates to:
  /// **'Applies only within the issuing institution'**
  String get bindingInstitutional;

  /// Binding nature.
  ///
  /// In en, this message translates to:
  /// **'Scientific evidence — not a normative document'**
  String get bindingScientific;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Official number'**
  String get instrNumber;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get instrPublished;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'In force from'**
  String get instrEffectiveFrom;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'In force until'**
  String get instrEffectiveTo;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Last amended'**
  String get instrAmended;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Version / edition'**
  String get instrVersion;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Legal status'**
  String get instrLegalStatus;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Official language'**
  String get instrLanguage;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get instrTranslation;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Last verified'**
  String get instrLastVerified;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Review status'**
  String get instrReview;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Official source'**
  String get instrSource;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Authority'**
  String get instrAuthority;

  /// Translation status.
  ///
  /// In en, this message translates to:
  /// **'Original language only'**
  String get translationNone;

  /// Library hub intro.
  ///
  /// In en, this message translates to:
  /// **'One umbrella for scientific records. Every record shows its source and review status.'**
  String get libraryHubIntro;

  /// Library section.
  ///
  /// In en, this message translates to:
  /// **'Standards & official documents'**
  String get libraryStandards;

  /// Record count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No records yet} one{1 record} other{{count} records}}'**
  String libraryCount(int count);

  /// Library group.
  ///
  /// In en, this message translates to:
  /// **'Scientific records'**
  String get libraryGroupScience;

  /// Library group.
  ///
  /// In en, this message translates to:
  /// **'Documents & evidence'**
  String get libraryGroupDocs;

  /// Standards screen intro.
  ///
  /// In en, this message translates to:
  /// **'Standards, guidelines and methods are labelled by type. Only laws and regulations are legally binding — and only in their own jurisdiction.'**
  String get standardsIntro;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'Peer-reviewed only'**
  String get researchFilterPeer;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'Open access'**
  String get researchFilterOpen;

  /// Filter option.
  ///
  /// In en, this message translates to:
  /// **'Any year'**
  String get researchPeriodAll;

  /// Filter option.
  ///
  /// In en, this message translates to:
  /// **'2020 or later'**
  String get researchPeriodRecent;

  /// Filter option.
  ///
  /// In en, this message translates to:
  /// **'2010–2019'**
  String get researchPeriod2010;

  /// Filter option.
  ///
  /// In en, this message translates to:
  /// **'Before 2010'**
  String get researchPeriodOlder;

  /// Filter option.
  ///
  /// In en, this message translates to:
  /// **'All disciplines'**
  String get researchDisciplineAll;

  /// Filter label.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get researchDiscipline;

  /// Filter label.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get researchPeriod;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get researchClear;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Forensic relevance'**
  String get researchRelevance;

  /// Relevance.
  ///
  /// In en, this message translates to:
  /// **'Not yet assessed by a reviewer (separate from evidence level)'**
  String get relevanceUnassessed;

  /// Relevance.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get relevanceDirect;

  /// Relevance.
  ///
  /// In en, this message translates to:
  /// **'Supporting'**
  String get relevanceSupporting;

  /// Relevance.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get relevanceBackground;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Open access'**
  String get researchOpenAccess;

  /// Open access value.
  ///
  /// In en, this message translates to:
  /// **'Yes — PubMed Central'**
  String get researchOpenPmc;

  /// Open access value.
  ///
  /// In en, this message translates to:
  /// **'Yes — free full-text link'**
  String get researchOpenLink;

  /// Open access value.
  ///
  /// In en, this message translates to:
  /// **'Not determined'**
  String get researchOpenUnknown;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Document type'**
  String get researchDocKind;

  /// Section index header.
  ///
  /// In en, this message translates to:
  /// **'On this page'**
  String get detailOnThisPage;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Not yet sourced'**
  String get detailNotYetSourced;

  /// Index chip.
  ///
  /// In en, this message translates to:
  /// **'Jurisdiction'**
  String get detailJurisdictionShort;

  /// Search result meta.
  ///
  /// In en, this message translates to:
  /// **'Metabolite of {name}'**
  String searchMetaboliteOf(String name);

  /// AI safety block.
  ///
  /// In en, this message translates to:
  /// **'Forensic AI does not write official expert opinions, death certificates or definitive intoxication conclusions. It can help you find and compare sources.'**
  String get aiBlockedOfficial;

  /// AI notice.
  ///
  /// In en, this message translates to:
  /// **'This is a legal or procedural question. Select a jurisdiction first — Forensic AI never assumes one.'**
  String get aiJurisdictionRequired;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Select jurisdiction'**
  String get aiSelectJurisdiction;

  /// AI answer section.
  ///
  /// In en, this message translates to:
  /// **'Evidence status'**
  String get aiSectionEvidenceStatus;

  /// Placeholder.
  ///
  /// In en, this message translates to:
  /// **'Each statement shows the review status and evidence level of the record it comes from.'**
  String get aiSampleEvidenceStatus;

  /// AI answer section.
  ///
  /// In en, this message translates to:
  /// **'Jurisdiction'**
  String get aiSectionJurisdiction;

  /// Placeholder.
  ///
  /// In en, this message translates to:
  /// **'Legal statements apply only to the selected jurisdiction; scientific statements are global.'**
  String get aiSampleJurisdiction;

  /// AI answer section.
  ///
  /// In en, this message translates to:
  /// **'Related records'**
  String get aiSectionRelated;

  /// Placeholder.
  ///
  /// In en, this message translates to:
  /// **'Links to the substance, method and research records used in the answer.'**
  String get aiSampleRelated;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tpl_overview;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Names & synonyms'**
  String get tpl_names;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get tpl_classification;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Metabolism'**
  String get tpl_metabolism;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Metabolites'**
  String get tpl_metabolites;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get tpl_specimens;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Screening'**
  String get tpl_screening;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Confirmatory analysis'**
  String get tpl_confirmation;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Analytical methods'**
  String get tpl_analyticalMethods;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Reported concentrations'**
  String get tpl_reportedConcentrations;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Interpretation'**
  String get tpl_interpretation;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Postmortem considerations'**
  String get tpl_postmortem;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get tpl_stability;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Interferences'**
  String get tpl_interferences;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Jurisdiction-specific law & methods'**
  String get tpl_jurisdiction;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Research & evidence'**
  String get tpl_research;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get tpl_sources;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Principle'**
  String get tpl_principle;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Forensic use'**
  String get tpl_forensicUse;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Sample preparation'**
  String get tpl_samplePreparation;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Instrumentation'**
  String get tpl_instrumentation;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Qualitative / quantitative use'**
  String get tpl_qualitativeQuantitative;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Validation requirements'**
  String get tpl_validation;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Interference'**
  String get tpl_interference;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get tpl_limitations;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Quality control'**
  String get tpl_qc;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Related substances'**
  String get tpl_relatedSubstances;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Related reagents'**
  String get tpl_relatedReagents;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get tpl_purpose;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Composition'**
  String get tpl_composition;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get tpl_preparation;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Storage & stability'**
  String get tpl_storageStability;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get tpl_safety;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Disposal'**
  String get tpl_disposal;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Linked methods & tests'**
  String get tpl_linkedMethods;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get tpl_technology;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Target & specimen'**
  String get tpl_targetSpecimen;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Cutoff'**
  String get tpl_cutoff;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity & specificity'**
  String get tpl_performance;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Cross-reactivity'**
  String get tpl_crossReactivity;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'False positives / negatives'**
  String get tpl_falseResults;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get tpl_marker;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Specimen'**
  String get tpl_specimen;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Collection context'**
  String get tpl_collectionContext;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Postmortem limitations'**
  String get tpl_postmortemLimitations;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Analytical method'**
  String get tpl_analyticalMethod;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Interpretation limitations'**
  String get tpl_interpretationLimitations;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get tpl_definition;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Findings'**
  String get tpl_findings;

  /// Content template section.
  ///
  /// In en, this message translates to:
  /// **'Methods'**
  String get tpl_methods;

  /// Template coverage.
  ///
  /// In en, this message translates to:
  /// **'Sections with sourced data: {filled} of {total}'**
  String templateCoverage(int filled, int total);

  /// Button on a claim.
  ///
  /// In en, this message translates to:
  /// **'Where does this come from?'**
  String get provWhereFrom;

  /// Sheet title.
  ///
  /// In en, this message translates to:
  /// **'Provenance of this statement'**
  String get provSheetTitle;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Statement'**
  String get provStatement;

  /// Location in source.
  ///
  /// In en, this message translates to:
  /// **'Location in source: {loc}'**
  String provLocation(String loc);

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get provSource;

  /// Source tier.
  ///
  /// In en, this message translates to:
  /// **'Source tier {tier}'**
  String provTier(String tier);

  /// Tier A.
  ///
  /// In en, this message translates to:
  /// **'A — official text, standard or guideline'**
  String get provTierA;

  /// Tier B.
  ///
  /// In en, this message translates to:
  /// **'B — peer-reviewed publication'**
  String get provTierB;

  /// Tier C.
  ///
  /// In en, this message translates to:
  /// **'C — handbook, database or secondary source'**
  String get provTierC;

  /// Reuse status.
  ///
  /// In en, this message translates to:
  /// **'Open reuse'**
  String get reuseOpen;

  /// Reuse status.
  ///
  /// In en, this message translates to:
  /// **'Cite only — text not reproduced'**
  String get reuseCiteOnly;

  /// Reuse status.
  ///
  /// In en, this message translates to:
  /// **'Non-commercial licence'**
  String get reuseNonCommercial;

  /// Reuse status.
  ///
  /// In en, this message translates to:
  /// **'LICENSE REQUIRED'**
  String get reuseLicenseRequired;

  /// Reuse status.
  ///
  /// In en, this message translates to:
  /// **'Lookup only'**
  String get reuseLookup;

  /// Reuse status.
  ///
  /// In en, this message translates to:
  /// **'Licence not determined'**
  String get reuseUnknown;

  /// Source lifecycle.
  ///
  /// In en, this message translates to:
  /// **'Not retracted'**
  String get srcLifecycleCurrent;

  /// Source lifecycle.
  ///
  /// In en, this message translates to:
  /// **'RETRACTED'**
  String get srcLifecycleRetracted;

  /// Source lifecycle.
  ///
  /// In en, this message translates to:
  /// **'SUPERSEDED'**
  String get srcLifecycleSuperseded;

  /// Source lifecycle.
  ///
  /// In en, this message translates to:
  /// **'WITHDRAWN'**
  String get srcLifecycleWithdrawn;

  /// Retraction check date.
  ///
  /// In en, this message translates to:
  /// **'Retraction check: {date}'**
  String provCheckedOn(String date);

  /// Hash label.
  ///
  /// In en, this message translates to:
  /// **'Archived copy SHA-256'**
  String get provArchiveHash;

  /// Version.
  ///
  /// In en, this message translates to:
  /// **'Version: {v}'**
  String provSourceVersion(String v);

  /// Claim lifecycle label.
  ///
  /// In en, this message translates to:
  /// **'Lifecycle'**
  String get provLifecycle;

  /// Lifecycle.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get lcCurrent;

  /// Lifecycle.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get lcNeedsReview;

  /// Lifecycle.
  ///
  /// In en, this message translates to:
  /// **'Outdated'**
  String get lcOutdated;

  /// Lifecycle.
  ///
  /// In en, this message translates to:
  /// **'Superseded'**
  String get lcSuperseded;

  /// Lifecycle.
  ///
  /// In en, this message translates to:
  /// **'Retracted source'**
  String get lcRetracted;

  /// Lifecycle.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get lcRejected;

  /// Verified marker.
  ///
  /// In en, this message translates to:
  /// **'Verified by qualified human reviewers'**
  String get provHumanVerified;

  /// Unverified marker.
  ///
  /// In en, this message translates to:
  /// **'Not yet confirmed by an expert'**
  String get provNotVerified;

  /// Reviewer role.
  ///
  /// In en, this message translates to:
  /// **'Required reviewer: {role}'**
  String provRequiredRole(String role);

  /// Review count.
  ///
  /// In en, this message translates to:
  /// **'Reviewer actions on this version: {n}'**
  String provReviewsRecorded(int n);

  /// Claim id.
  ///
  /// In en, this message translates to:
  /// **'Record ID: {id} · v{v}'**
  String provClaimId(String id, int v);

  /// Reviewer role.
  ///
  /// In en, this message translates to:
  /// **'Forensic toxicology'**
  String get roleForensicToxicology;

  /// Reviewer role.
  ///
  /// In en, this message translates to:
  /// **'Forensic medicine'**
  String get roleForensicMedicine;

  /// Reviewer role.
  ///
  /// In en, this message translates to:
  /// **'Laboratory / analytical'**
  String get roleLaboratory;

  /// Reviewer role.
  ///
  /// In en, this message translates to:
  /// **'Forensic biochemistry'**
  String get roleBiochemistry;

  /// Reviewer role.
  ///
  /// In en, this message translates to:
  /// **'Legal / jurisdiction'**
  String get roleLegal;

  /// Reviewer role.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get roleTranslation;

  /// Reviewer role.
  ///
  /// In en, this message translates to:
  /// **'Scientific editor / admin'**
  String get roleEditor;

  /// Retracted source banner.
  ///
  /// In en, this message translates to:
  /// **'Source retracted — this statement is kept for transparency but is not current evidence.'**
  String get bannerRetracted;

  /// Superseded banner.
  ///
  /// In en, this message translates to:
  /// **'All sources of this statement have been superseded.'**
  String get bannerSuperseded;

  /// Outdated banner.
  ///
  /// In en, this message translates to:
  /// **'Flagged as outdated by a reviewer.'**
  String get bannerOutdated;

  /// Conflict banner.
  ///
  /// In en, this message translates to:
  /// **'EVIDENCE CONFLICT — sources disagree or overlap. Tap to compare.'**
  String get bannerConflict;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Evidence conflicts'**
  String get conflictsTitle;

  /// Intro.
  ///
  /// In en, this message translates to:
  /// **'Conflicts are shown, not hidden. Only a qualified reviewer can resolve one; the app never picks a winner.'**
  String get conflictsIntro;

  /// Conflict kind.
  ///
  /// In en, this message translates to:
  /// **'Direct contradiction'**
  String get conflictKindDirect;

  /// Conflict kind.
  ///
  /// In en, this message translates to:
  /// **'Depends on context'**
  String get conflictKindContext;

  /// Conflict kind.
  ///
  /// In en, this message translates to:
  /// **'Values overlap between contexts'**
  String get conflictKindOverlap;

  /// Conflict kind.
  ///
  /// In en, this message translates to:
  /// **'Described differently'**
  String get conflictKindCharacterisation;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get conflictQuestion;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Statements involved'**
  String get conflictStatements;

  /// State.
  ///
  /// In en, this message translates to:
  /// **'Open — awaiting reviewer decision'**
  String get conflictStateOpen;

  /// State.
  ///
  /// In en, this message translates to:
  /// **'Resolved by reviewer'**
  String get conflictStateResolved;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Summary of what the sources say'**
  String get conflictNoteLabel;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Context (only what the source states)'**
  String get ctxTitle;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Specimen'**
  String get ctxSpecimen;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Sampling'**
  String get ctxSampling;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get ctxSubject;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get ctxPopulation;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Number of cases'**
  String get ctxStudySize;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Case type'**
  String get ctxCaseType;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Co-intoxicants'**
  String get ctxCoIntoxicants;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Analytical method'**
  String get ctxMethod;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get ctxTiming;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Reported values'**
  String get ctxStatistic;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Data origin'**
  String get ctxReporting;

  /// Context field.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get ctxLimitations;

  /// Missing value.
  ///
  /// In en, this message translates to:
  /// **'not stated in the source'**
  String get ctxNotStated;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'post-mortem'**
  String get ctxPostmortem;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'ante-mortem'**
  String get ctxAntemortem;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'mixed'**
  String get ctxMixed;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'deceased'**
  String get ctxDeceased;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'living'**
  String get ctxLiving;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'Primary data of the cited study'**
  String get ctxPrimary;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'Quoted from another study'**
  String get ctxSecondary;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'Not yet assessed'**
  String get ctxNotAssessed;

  /// Concentration context not curated.
  ///
  /// In en, this message translates to:
  /// **'Reviewed contextual data for this record is not yet available.'**
  String get ctxAutoMinimal;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Metabolites (sourced relations)'**
  String get metRelationsTitle;

  /// Relation kind.
  ///
  /// In en, this message translates to:
  /// **'Metabolite'**
  String get metKindMetabolite;

  /// Relation kind.
  ///
  /// In en, this message translates to:
  /// **'Active metabolite'**
  String get metKindActive;

  /// Relation kind.
  ///
  /// In en, this message translates to:
  /// **'Inactive metabolite'**
  String get metKindInactive;

  /// Relation kind.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get metKindMarker;

  /// Relation kind.
  ///
  /// In en, this message translates to:
  /// **'Artifact'**
  String get metKindArtifact;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'A role (active, marker…) is shown only when the cited text states it.'**
  String get metRoleNote;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Parent substance: {name}'**
  String metParentOf(String name);

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get specimensTitle;

  /// Intro.
  ///
  /// In en, this message translates to:
  /// **'Specimen types with sourced statements and reported values. Reported values are never thresholds.'**
  String get specimensIntro;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'About this specimen'**
  String get specimenAbout;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Reported values in this specimen'**
  String get specimenMeasured;

  /// Empty.
  ///
  /// In en, this message translates to:
  /// **'No sourced statements yet.'**
  String get specimenNoClaims;

  /// Category.
  ///
  /// In en, this message translates to:
  /// **'Body fluid'**
  String get specimenCatFluid;

  /// Category.
  ///
  /// In en, this message translates to:
  /// **'Tissue'**
  String get specimenCatTissue;

  /// Category.
  ///
  /// In en, this message translates to:
  /// **'Keratinous matrix'**
  String get specimenCatKeratinous;

  /// Category.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get specimenCatContent;

  /// Count.
  ///
  /// In en, this message translates to:
  /// **'{n} records'**
  String specimenRecords(int n);

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Specimens with reported values'**
  String get detailMeasuredIn;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Screening tests (screening ≠ confirmation)'**
  String get detailScreenedBy;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Knowledge chain'**
  String get chainTitle;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Show knowledge chain'**
  String get chainOpen;

  /// Intro.
  ///
  /// In en, this message translates to:
  /// **'Every link below has a recorded basis (a sourced statement, an official list entry or a catalogue record). Tap a link to see it.'**
  String get chainIntro;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Metabolites'**
  String get chainMetabolites;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get chainSpecimens;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Screening'**
  String get chainScreening;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Confirmatory methods'**
  String get chainConfirmation;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Reagents'**
  String get chainReagents;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get chainResearch;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Standards'**
  String get chainStandards;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Legal status'**
  String get chainLegal;

  /// Empty step.
  ///
  /// In en, this message translates to:
  /// **'No sourced link yet'**
  String get chainNone;

  /// Basis label.
  ///
  /// In en, this message translates to:
  /// **'Basis: {id}'**
  String chainBasis(String id);

  /// Count.
  ///
  /// In en, this message translates to:
  /// **'{n} linked publications'**
  String chainResearchCount(int n);

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Standards catalogue (metadata only)'**
  String get stdCatalogue;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get stdStatusCurrent;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Proposed — not yet published'**
  String get stdStatusProposed;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Superseded by {id}'**
  String stdStatusSuperseded(String id);

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get stdStatusWithdrawn;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Status not determined'**
  String get stdStatusUnknown;

  /// Verification.
  ///
  /// In en, this message translates to:
  /// **'Metadata checked on {date} at the publisher or registry'**
  String stdVerifiedFrom(String date);

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'The text of the standard is not reproduced in the app.'**
  String get stdTextNotReproduced;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Scientific review status'**
  String get reviewTitle;

  /// Metric.
  ///
  /// In en, this message translates to:
  /// **'Verified by humans'**
  String get reviewHumanVerified;

  /// Metric.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewReviewed;

  /// Metric.
  ///
  /// In en, this message translates to:
  /// **'Awaiting review'**
  String get reviewAwaiting;

  /// Metric.
  ///
  /// In en, this message translates to:
  /// **'Statements with a retracted source'**
  String get reviewRetracted;

  /// Metric.
  ///
  /// In en, this message translates to:
  /// **'Reviewer actions recorded'**
  String get reviewActions;

  /// Metric.
  ///
  /// In en, this message translates to:
  /// **'Registered reviewers'**
  String get reviewReviewers;

  /// Metric.
  ///
  /// In en, this message translates to:
  /// **'Open evidence conflicts'**
  String get reviewOpenConflicts;

  /// Explanation.
  ///
  /// In en, this message translates to:
  /// **'A statement becomes VERIFIED only after two independent qualified reviewers in its specialty approve the current version. The app and its authors cannot mark anything verified themselves.'**
  String get reviewExplain;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Reviewer roles and permissions'**
  String get reviewRolesTitle;

  /// Permission.
  ///
  /// In en, this message translates to:
  /// **'Can approve or reject in its specialty'**
  String get reviewRoleApprove;

  /// Permission.
  ///
  /// In en, this message translates to:
  /// **'Can flag conflicts, outdated content and request changes — cannot approve'**
  String get reviewRoleFlagOnly;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Possible actions'**
  String get reviewActionsList;

  /// Hub entry.
  ///
  /// In en, this message translates to:
  /// **'Evidence conflicts'**
  String get libraryConflicts;

  /// Hub entry.
  ///
  /// In en, this message translates to:
  /// **'Review status'**
  String get libraryReview;

  /// Method note.
  ///
  /// In en, this message translates to:
  /// **'Published scientific method — not a validated procedure for any particular laboratory.'**
  String get methodPublishedNote;

  /// Recipe field.
  ///
  /// In en, this message translates to:
  /// **'Concentration'**
  String get reagentConcentration;

  /// Recipe field.
  ///
  /// In en, this message translates to:
  /// **'Solvent'**
  String get reagentSolvent;

  /// Recipe field.
  ///
  /// In en, this message translates to:
  /// **'pH'**
  String get reagentPh;

  /// Recipe field.
  ///
  /// In en, this message translates to:
  /// **'Expiry / shelf life'**
  String get reagentExpiry;

  /// Recipe field.
  ///
  /// In en, this message translates to:
  /// **'Personal protective equipment'**
  String get reagentPpe;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'Result type (qualitative / semi-quantitative)'**
  String get screeningResultType;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'Detection window (context-dependent)'**
  String get screeningDetectionWindow;

  /// Screening field.
  ///
  /// In en, this message translates to:
  /// **'Interference'**
  String get screeningInterference;

  /// Method evidence type.
  ///
  /// In en, this message translates to:
  /// **'International standard'**
  String get evInternationalStandard;

  /// Method evidence type.
  ///
  /// In en, this message translates to:
  /// **'Guideline'**
  String get evGuideline;

  /// Method evidence type.
  ///
  /// In en, this message translates to:
  /// **'Published validated method'**
  String get evPublishedValidated;

  /// Method evidence type.
  ///
  /// In en, this message translates to:
  /// **'National method'**
  String get evNationalMethod;

  /// Method evidence type.
  ///
  /// In en, this message translates to:
  /// **'Local SOP reference'**
  String get evLocalSop;

  /// Method evidence type.
  ///
  /// In en, this message translates to:
  /// **'Educational summary'**
  String get evEducationalSummary;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Sourced topics'**
  String get disciplineSourcedTopics;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get aiRagAnswer;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'Not a legal question — no jurisdiction applied'**
  String get aiRagJurisdictionNotApplicable;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'Evidence is not yet verified by qualified human reviewers.'**
  String get aiLimNotVerified;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'Sources disagree or overlap — see EVIDENCE CONFLICT.'**
  String get aiLimConflict;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'{n} statement(s) from retracted or superseded sources were excluded.'**
  String aiLimRetracted(int n);

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'Interpretation of an individual case requires a qualified expert.'**
  String get aiLimExpert;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'Demonstration provider — no real AI answer was generated.'**
  String get aiLimMock;

  /// Instrument field.
  ///
  /// In en, this message translates to:
  /// **'Original title'**
  String get instrOriginalTitle;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'Not recorded for this document: {fields}'**
  String legalMissingFields(String fields);

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Official title'**
  String get lfOfficialTitle;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Original-language title'**
  String get lfOriginalTitle;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Article / section'**
  String get lfArticle;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Official URL'**
  String get lfOfficialUrl;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Review status'**
  String get lfReviewStatus;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Legal domains'**
  String get legalDomainsTitle;

  /// Count.
  ///
  /// In en, this message translates to:
  /// **'{n} records'**
  String legalDomainRecords(int n);

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'No verified content'**
  String get legalDomainNoContent;

  /// Compare topic.
  ///
  /// In en, this message translates to:
  /// **'Control status'**
  String get compareTopicControlStatus;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Forensic expert status'**
  String get ldExpertStatus;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Evidence handling'**
  String get ldEvidenceHandling;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Chain of custody'**
  String get ldChainOfCustody;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Specimen collection'**
  String get ldSpecimenCollection;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Death investigation'**
  String get ldDeathInvestigation;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Autopsy'**
  String get ldAutopsy;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Toxicology'**
  String get ldToxicology;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Alcohol and driving'**
  String get ldAlcoholDriving;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Controlled substances'**
  String get ldControlledSubstances;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get ldReporting;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Laboratory standards'**
  String get ldLaboratoryStandards;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Retention and storage'**
  String get ldRetentionStorage;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Testimony'**
  String get ldTestimony;

  /// Legal domain.
  ///
  /// In en, this message translates to:
  /// **'Quality and accreditation'**
  String get ldQualityAccreditation;

  /// Profile action.
  ///
  /// In en, this message translates to:
  /// **'Delete data on this device'**
  String get deleteLocalData;

  /// Dialog.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks, search history, recently viewed records and lesson progress will be deleted from this device only. The scientific database, your account and store subscriptions are not affected — use “Delete account” to delete the account.'**
  String get deleteLocalDataBody;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLocalDataConfirm;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Local data deleted'**
  String get deleteLocalDataDone;

  /// Tier name.
  ///
  /// In en, this message translates to:
  /// **'Student Pro'**
  String get tierStudentPro;

  /// Tier name.
  ///
  /// In en, this message translates to:
  /// **'Professional Pro'**
  String get tierProfessionalPro;

  /// Tier name.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get tierInstitution;

  /// Badge.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get tierCurrent;

  /// Feature.
  ///
  /// In en, this message translates to:
  /// **'Offline scientific database with safety warnings and sources'**
  String get tierFreeF1;

  /// Feature.
  ///
  /// In en, this message translates to:
  /// **'Search and selected reference entries'**
  String get tierFreeF2;

  /// Feature.
  ///
  /// In en, this message translates to:
  /// **'Basic calculators'**
  String get tierFreeF3;

  /// Feature.
  ///
  /// In en, this message translates to:
  /// **'Full reference: substances, methods, reagents, forensic medicine, standards, jurisdictions'**
  String get tierStudentF1;

  /// Feature.
  ///
  /// In en, this message translates to:
  /// **'All courses, quizzes, flashcards and exam practice'**
  String get tierStudentF2;

  /// Feature.
  ///
  /// In en, this message translates to:
  /// **'Unlimited search results'**
  String get tierStudentF3;

  /// Feature.
  ///
  /// In en, this message translates to:
  /// **'Everything in Student Pro'**
  String get tierProF1;

  /// Feature.
  ///
  /// In en, this message translates to:
  /// **'Professional calculators and laboratory tools'**
  String get tierProF2;

  /// Feature.
  ///
  /// In en, this message translates to:
  /// **'Analytical methods, research and evidence tools'**
  String get tierProF3;

  /// Feature.
  ///
  /// In en, this message translates to:
  /// **'Professional AI features — when the AI service is connected'**
  String get tierProF4;

  /// Billing period.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get periodMonthly;

  /// Billing period.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get periodYearly;

  /// Billing period.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get periodUnknown;

  /// Price line.
  ///
  /// In en, this message translates to:
  /// **'{price} · {period}'**
  String offerPriceLine(String price, String period);

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get offerSubscribe;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Price is shown by the App Store / Google Play'**
  String get offerPriceFromStore;

  /// Apple/Google required disclosure.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions renew automatically until cancelled. Payment is charged to your App Store / Google Play account. You can cancel at least 24 hours before the end of the period in your store account settings.'**
  String get subscriptionTerms;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Could not open the store subscription settings.'**
  String get manageSubscriptionFailed;

  /// Profile row.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planLabel;

  /// Profile row.
  ///
  /// In en, this message translates to:
  /// **'Subscription status'**
  String get subscriptionStateLabel;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get stActive;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get stExpired;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Payment issue — grace period'**
  String get stGrace;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Payment issue — access paused'**
  String get stBillingRetry;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Cancelled — active until {date}'**
  String stCancelled(String date);

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Cancelled — active until the end of the period'**
  String get stCancelledNoDate;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Revoked by the store'**
  String get stRevoked;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Status unknown'**
  String get stUnknown;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'No subscription'**
  String get stNone;

  /// Status detail.
  ///
  /// In en, this message translates to:
  /// **'Renews or ends on {date}'**
  String stRenewsOn(String date);

  /// Profile note.
  ///
  /// In en, this message translates to:
  /// **'An account is optional. The offline scientific reference works without signing in; an account is needed only for cloud services.'**
  String get accountOptionalNote;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'The account service is not yet connected in this build. All offline features remain available.'**
  String get accountNotConnected;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'TEST account backend — no real emails are sent and data is kept only in memory.'**
  String get accountTestBackend;

  /// Button / title.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accountSignIn;

  /// Button / title.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get accountCreate;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get accountSignedOut;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmail;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPassword;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get accountConfirmPassword;

  /// Semantics.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get accountShowPassword;

  /// Semantics.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get accountHidePassword;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get accountVerified;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get accountNotVerified;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get accountVerifyNow;

  /// Checkbox.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Use and the Privacy Policy'**
  String get accountTermsAccept;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'We only ask for your email. No professional, case or personal details are collected.'**
  String get accountMinimalData;

  /// Heading.
  ///
  /// In en, this message translates to:
  /// **'Password requirements'**
  String get passwordRulesTitle;

  /// Rule.
  ///
  /// In en, this message translates to:
  /// **'At least {n} characters'**
  String pwRuleMinLength(int n);

  /// Rule.
  ///
  /// In en, this message translates to:
  /// **'At least one letter'**
  String get pwRuleLetter;

  /// Rule.
  ///
  /// In en, this message translates to:
  /// **'At least one digit'**
  String get pwRuleDigit;

  /// Rule.
  ///
  /// In en, this message translates to:
  /// **'Not the same as your email'**
  String get pwRuleNotEmail;

  /// Link.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get accountForgot;

  /// Link.
  ///
  /// In en, this message translates to:
  /// **'No account? Create one'**
  String get accountNoAccount;

  /// Link.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get accountHaveAccount;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyTitle;

  /// Body.
  ///
  /// In en, this message translates to:
  /// **'We sent a {n}-digit code to {email}. Enter it below to activate your account.'**
  String verifyBody(int n, String email);

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verifyCode;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifySubmit;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get verifyResend;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'If the account needs verification, a new code has been sent.'**
  String get verifyResent;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Email verified. Your account is active.'**
  String get verifyDone;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotTitle;

  /// Body.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email. If an account exists, we will send a reset code.'**
  String get forgotBody;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Send reset code'**
  String get forgotSubmit;

  /// Notice.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, a reset code has been sent. It expires in {minutes} minutes.'**
  String forgotSent(int minutes);

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get resetTitle;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Reset code'**
  String get resetCode;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get resetNewPassword;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get resetSubmit;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Please sign in with the new password.'**
  String get resetDone;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authErrInvalidEmail;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'The password does not meet the requirements.'**
  String get authErrWeakPassword;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authErrMismatch;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms of Use and the Privacy Policy.'**
  String get authErrTerms;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get authErrCredentials;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Your email is not verified yet. Enter the code we sent.'**
  String get authErrNotVerified;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'The code is incorrect.'**
  String get authErrCodeInvalid;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'The code has expired. Request a new one.'**
  String get authErrCodeExpired;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'This email is already verified. You can sign in.'**
  String get authErrAlreadyVerified;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a minute and try again.'**
  String get authErrTooMany;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Offline features keep working.'**
  String get authErrOffline;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'The account service is temporarily unavailable. Please try again later.'**
  String get authErrServer;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'The account service is not yet connected in this build.'**
  String get authErrNotConfigured;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'The password is incorrect. Confirm your current password to continue.'**
  String get authErrRecentLogin;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first.'**
  String get authErrNotSignedIn;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// Body.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and the data linked to it on our servers (email, sign-in sessions, synced data, cloud entitlement records). This cannot be undone.'**
  String get deleteAccountBody;

  /// Body.
  ///
  /// In en, this message translates to:
  /// **'Deleting the account does not cancel an App Store / Google Play subscription. Cancel it in your store account settings to stop future charges.'**
  String get deleteAccountStoreNote;

  /// Body.
  ///
  /// In en, this message translates to:
  /// **'Data on this device (bookmarks, history) is a separate action: “Delete data on this device”.'**
  String get deleteAccountLocalNote;

  /// Checkbox.
  ///
  /// In en, this message translates to:
  /// **'I understand that this cannot be undone'**
  String get deleteAccountUnderstand;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get deleteAccountPassword;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Delete account permanently'**
  String get deleteAccountConfirm;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountFinalTitle;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get deleteAccountDone;

  /// Profile row.
  ///
  /// In en, this message translates to:
  /// **'AI disclaimer'**
  String get aiDisclaimerLink;

  /// Legal text.
  ///
  /// In en, this message translates to:
  /// **'Forensic AI answers are generated from the app’s local, source-linked content and are not expert opinions. They may be incomplete or wrong, are not verified by a qualified human reviewer and must not be used as the sole basis for a forensic conclusion, legal decision or patient care. Always check the cited sources and consult a qualified expert.'**
  String get aiDisclaimerBody;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionSection;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get availNoDataTitle;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'The installed scientific database has no records for this section.'**
  String get availNoDataBody;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'No results for the selected filter'**
  String get availFilterTitle;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'No reviewed records match the selected filter. Clear the filter or search the whole database.'**
  String get availFilterBody;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'Not available in this version'**
  String get availNotConnectedTitle;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'This feature needs an online service that is not connected in this version. All offline features keep working.'**
  String get availNotConnectedBody;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'Service temporarily unavailable'**
  String get availServiceTitle;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'Check the connection and try again later. Offline features keep working.'**
  String get availServiceBody;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get availClearFilters;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Browse all records'**
  String get availBrowseAll;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get availSearch;

  /// AI status chip.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get aiStatusPreview;

  /// AI preview bullet.
  ///
  /// In en, this message translates to:
  /// **'No AI answers are generated right now.'**
  String get aiPreviewPoint1;

  /// AI preview bullet.
  ///
  /// In en, this message translates to:
  /// **'This is temporary; the rest of the app works offline.'**
  String get aiPreviewPoint2;

  /// AI preview bullet.
  ///
  /// In en, this message translates to:
  /// **'The sample below only shows how an answer is laid out.'**
  String get aiPreviewPoint3;

  /// AI preview bullet.
  ///
  /// In en, this message translates to:
  /// **'“Find sources offline” searches the local database and works now.'**
  String get aiPreviewPoint4;

  /// AI send note.
  ///
  /// In en, this message translates to:
  /// **'AI is temporarily unavailable — sending is disabled.'**
  String get aiSendUnavailable;

  /// Critical warning on concentration values.
  ///
  /// In en, this message translates to:
  /// **'This value comes from an individual case or study. It must not be interpreted as a universal toxic, lethal, therapeutic or legal threshold.'**
  String get concWarning;

  /// Card title.
  ///
  /// In en, this message translates to:
  /// **'Reported concentration'**
  String get concTitle;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Substance'**
  String get concSubstance;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Value and unit'**
  String get concValue;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'As quoted in the source (see excerpt)'**
  String get concValueInQuote;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Living / post-mortem'**
  String get concLivingPostmortem;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Source type'**
  String get concSourceType;

  /// Source section.
  ///
  /// In en, this message translates to:
  /// **'Case description'**
  String get concSectionCase;

  /// Source section.
  ///
  /// In en, this message translates to:
  /// **'Abstract'**
  String get concSectionAbstract;

  /// Source section.
  ///
  /// In en, this message translates to:
  /// **'Introduction (background)'**
  String get concSectionIntro;

  /// Source section.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get concSectionResults;

  /// Source section.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get concSectionDiscussion;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Case / study context'**
  String get concStudyContext;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Evidence level'**
  String get concEvidenceLevel;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Review status'**
  String get concReviewStatus;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get concSource;

  /// Missing metadata.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get concNotAvailable;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Source excerpt'**
  String get concExcerpt;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get calcStatusTitle;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Calculation engine'**
  String get calcEngineLabel;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'Checked by automated software tests — this is not a scientific review'**
  String get calcEngineTested;

  /// Tile chip.
  ///
  /// In en, this message translates to:
  /// **'Engine tested'**
  String get calcEngineChip;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Formula reference'**
  String get calcReferenceLabel;

  /// Row.
  ///
  /// In en, this message translates to:
  /// **'Interpretation'**
  String get calcInterpretationLabel;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'Context dependent — requires professional judgement'**
  String get calcInterpretationValue;

  /// Review status.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// Home header subtitle.
  ///
  /// In en, this message translates to:
  /// **'Forensic science reference'**
  String get homeHeaderSubtitle;

  /// Sub-role title.
  ///
  /// In en, this message translates to:
  /// **'Your role (optional)'**
  String get modeRoleTitle;

  /// Professional mode notice.
  ///
  /// In en, this message translates to:
  /// **'Choosing Professional mode does not mean that your professional status is verified.'**
  String get modeProfessionalNotVerified;

  /// Mode picker notice.
  ///
  /// In en, this message translates to:
  /// **'Usage mode only changes how the app is arranged. It does not grant or remove professional verification.'**
  String get modeSwitchNote;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Resident / trainee'**
  String get roleResident;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Researcher / learner'**
  String get roleResearcher;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Forensic expert'**
  String get roleForensicExpert;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Forensic physician'**
  String get roleForensicPhysician;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Forensic toxicologist'**
  String get roleForensicToxicologist;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Forensic chemist'**
  String get roleForensicChemist;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Laboratory specialist'**
  String get roleLaboratorySpecialist;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Pathologist'**
  String get rolePathologist;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Geneticist / DNA specialist'**
  String get roleGeneticist;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Forensic biochemist'**
  String get roleForensicBiochemist;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Forensic anthropologist'**
  String get roleAnthropologist;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Forensic odontologist'**
  String get roleOdontologist;

  /// Role.
  ///
  /// In en, this message translates to:
  /// **'Other forensic / laboratory professional'**
  String get roleOtherProfessional;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Forensic medicine'**
  String get specForensicMedicine;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Forensic toxicology'**
  String get specForensicToxicology;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Forensic chemistry'**
  String get specForensicChemistry;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Analytical / laboratory science'**
  String get specAnalyticalLaboratory;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Forensic biochemistry'**
  String get specForensicBiochemistry;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Pathology / histology'**
  String get specPathologyHistology;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Genetics / DNA'**
  String get specGeneticsDna;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Forensic anthropology'**
  String get specForensicAnthropology;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Forensic odontology'**
  String get specForensicOdontology;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Forensic radiology'**
  String get specForensicRadiology;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Forensic psychology / psychiatry'**
  String get specForensicPsychology;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Forensic biology'**
  String get specForensicBiology;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Forensic entomology'**
  String get specEntomology;

  /// Specialty.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get specOther;

  /// Reviewer scope.
  ///
  /// In en, this message translates to:
  /// **'Law and jurisdiction'**
  String get scopeLegal;

  /// Reviewer scope.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get scopeTranslation;

  /// Study level.
  ///
  /// In en, this message translates to:
  /// **'Bachelor’s'**
  String get studyBachelor;

  /// Study level.
  ///
  /// In en, this message translates to:
  /// **'Master’s'**
  String get studyMaster;

  /// Study level.
  ///
  /// In en, this message translates to:
  /// **'Residency / clinical training'**
  String get studyResidency;

  /// Study level.
  ///
  /// In en, this message translates to:
  /// **'Doctoral'**
  String get studyDoctoral;

  /// Study level.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get studyOther;

  /// Account step title.
  ///
  /// In en, this message translates to:
  /// **'Use the app without an account'**
  String get accountChoiceTitle;

  /// Account step subtitle.
  ///
  /// In en, this message translates to:
  /// **'The offline scientific database, search and calculators work without an account. An account is needed only for cloud features.'**
  String get accountChoiceSubtitle;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get accountContinueWithout;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'You can create an account later in Profile.'**
  String get accountContinueWithoutNote;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Create account / Sign in'**
  String get accountCreateOrSignIn;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'The cloud account service is not connected in this version. Everything offline keeps working.'**
  String get accountCloudUnavailable;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'An account is needed for'**
  String get accountNeededFor;

  /// Item.
  ///
  /// In en, this message translates to:
  /// **'Professional verification'**
  String get accountNeedVerification;

  /// Item.
  ///
  /// In en, this message translates to:
  /// **'Professional reviews of scientific content'**
  String get accountNeedReviews;

  /// Item.
  ///
  /// In en, this message translates to:
  /// **'Synchronisation between devices'**
  String get accountNeedSync;

  /// Item.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions across devices'**
  String get accountNeedSubscriptions;

  /// Item.
  ///
  /// In en, this message translates to:
  /// **'Cloud AI (when connected)'**
  String get accountNeedCloudAi;

  /// Item.
  ///
  /// In en, this message translates to:
  /// **'Institutional features'**
  String get accountNeedInstitution;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Fill in profile now (optional)'**
  String get accountFillProfile;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Your profile is stored on this device. It is sent to the server only when you submit it for verification.'**
  String get profileLocalOnlyNote;

  /// Screen.
  ///
  /// In en, this message translates to:
  /// **'Student profile'**
  String get profileStudentTitle;

  /// Screen.
  ///
  /// In en, this message translates to:
  /// **'Professional profile'**
  String get profileProTitle;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Profile saved on this device'**
  String get profileSaved;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get profileSectionIdentity;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Professional details'**
  String get profileSectionWork;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get profileSectionOptional;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Student profiles are for learning: they cannot verify scientific content or perform qualified reviews.'**
  String get profileStudentCannotReview;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get fieldCountry;

  /// Field hint.
  ///
  /// In en, this message translates to:
  /// **'Choose a country'**
  String get fieldCountryChoose;

  /// Search hint.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get fieldCountrySearch;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'City / region (optional)'**
  String get fieldCity;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'University / institution (optional)'**
  String get fieldInstitution;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Faculty / programme (optional)'**
  String get fieldFaculty;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Study level (optional)'**
  String get fieldStudyLevel;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Areas of interest'**
  String get fieldInterests;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Organisation / institution'**
  String get fieldOrganization;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Position / job title'**
  String get fieldPosition;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Primary specialty'**
  String get fieldPrimarySpecialty;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Additional specialties'**
  String get fieldAdditionalSpecialties;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Years of professional experience'**
  String get fieldYearsExperience;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Education / qualification'**
  String get fieldEducation;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Work e-mail (optional)'**
  String get fieldWorkEmail;

  /// Helper.
  ///
  /// In en, this message translates to:
  /// **'Private — never shown on your public profile.'**
  String get fieldPrivateHelper;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Professional registration / licence number (optional)'**
  String get fieldLicense;

  /// Helper.
  ///
  /// In en, this message translates to:
  /// **'Only if your country issues one. Private — never shown publicly.'**
  String get fieldLicenseHelper;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Short professional biography (optional)'**
  String get fieldBio;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Languages (comma separated)'**
  String get fieldLanguages;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Professional interests (optional)'**
  String get fieldProInterests;

  /// Switch.
  ///
  /// In en, this message translates to:
  /// **'Show organisation on public profile'**
  String get fieldShowOrganization;

  /// Helper.
  ///
  /// In en, this message translates to:
  /// **'Off by default. Name, specialty and country are public only after verification.'**
  String get fieldShowOrganizationHelper;

  /// Form error.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get formRequired;

  /// Form error.
  ///
  /// In en, this message translates to:
  /// **'Too long'**
  String get formTooLong;

  /// Form error.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get formInvalid;

  /// Form error summary.
  ///
  /// In en, this message translates to:
  /// **'Please correct the highlighted fields.'**
  String get formHasErrors;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// Screen.
  ///
  /// In en, this message translates to:
  /// **'Professional verification'**
  String get verifTitle;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Current status'**
  String get verifStatusLabel;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get verifUnverified;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Review pending'**
  String get verifPending;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Verified professional'**
  String get verifVerified;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'More information needed'**
  String get verifChangesRequested;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get verifRejected;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Temporarily suspended'**
  String get verifSuspended;

  /// Status body.
  ///
  /// In en, this message translates to:
  /// **'You have not applied for verification. All offline features are available without it.'**
  String get verifUnverifiedBody;

  /// Status body.
  ///
  /// In en, this message translates to:
  /// **'Your application is waiting for review by an authorised person.'**
  String get verifPendingBody;

  /// Status body.
  ///
  /// In en, this message translates to:
  /// **'Your professional status was confirmed by an authorised person. Review rights are granted separately for each specialty.'**
  String get verifVerifiedBody;

  /// Status body.
  ///
  /// In en, this message translates to:
  /// **'Additional information is needed. Update your profile or documents and resubmit.'**
  String get verifChangesBody;

  /// Status body.
  ///
  /// In en, this message translates to:
  /// **'The application was not approved. You can submit a new application.'**
  String get verifRejectedBody;

  /// Status body.
  ///
  /// In en, this message translates to:
  /// **'Verification is temporarily suspended. Review rights are not active.'**
  String get verifSuspendedBody;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'The verification service is not connected in this version. Applications cannot be sent and nobody can be verified yet.'**
  String get verifServiceNotConnected;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'How verification works'**
  String get verifHowTitle;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Fill in your professional profile.'**
  String get verifStep1;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Optionally attach a qualification document (stored privately).'**
  String get verifStep2;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'An authorised administrator or a verified professional of the same specialty reviews the application and the document manually. Self-approval is impossible.'**
  String get verifStep3;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Review rights are granted separately for each specialty.'**
  String get verifStep4;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Selecting Professional mode, entering a job title, uploading a certificate or an automated/AI check never grants verified status. A document is evidence only; status is granted only after manual review, and who approved it, when, which document was checked and for which specialty are recorded.'**
  String get verifHumanOnly;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get verifApplication;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'Professional profile is not filled in'**
  String get verifProfileMissing;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Submit application'**
  String get verifSubmit;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Application sent. Status: review pending.'**
  String get verifSubmitted;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Submitting is unavailable until the verification service is connected.'**
  String get verifSubmitUnavailable;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'The application and documents are sent over an encrypted connection to private storage.'**
  String get verifSubmitNote;

  /// Public profile.
  ///
  /// In en, this message translates to:
  /// **'{years} years of experience'**
  String proYearsExperience(int years);

  /// Public profile.
  ///
  /// In en, this message translates to:
  /// **'Professional reviews: {count}'**
  String proReviewCount(int count);

  /// Failure.
  ///
  /// In en, this message translates to:
  /// **'The cloud service is not connected in this version.'**
  String get proServiceNotConnected;

  /// Failure.
  ///
  /// In en, this message translates to:
  /// **'Check the entered data.'**
  String get proInvalidInput;

  /// Failure.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get proOffline;

  /// Failure.
  ///
  /// In en, this message translates to:
  /// **'The service is temporarily unavailable. Try again later.'**
  String get proServerError;

  /// Screen.
  ///
  /// In en, this message translates to:
  /// **'Upload qualification document'**
  String get credUploadTitle;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get credOptional;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file selected} other{{count} files selected}}'**
  String credSelectedCount(int count);

  /// Intro.
  ///
  /// In en, this message translates to:
  /// **'A document is optional and only helps an authorised person check your application. It never grants verified status by itself.'**
  String get credIntro;

  /// Privacy banner.
  ///
  /// In en, this message translates to:
  /// **'Documents are private: they are never shown publicly, have no public link and their contents are not logged. Only an authorised verifier can open them.'**
  String get credPrivacy;

  /// Warning.
  ///
  /// In en, this message translates to:
  /// **'Do not upload case materials, evidence, expert reports or any confidential case records. Passport or ID documents are not required.'**
  String get credNoCaseData;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Document type'**
  String get credKindTitle;

  /// Document type.
  ///
  /// In en, this message translates to:
  /// **'Professional certificate'**
  String get credProfessionalCertificate;

  /// Document type.
  ///
  /// In en, this message translates to:
  /// **'Qualification certificate'**
  String get credQualificationCertificate;

  /// Document type.
  ///
  /// In en, this message translates to:
  /// **'Diploma'**
  String get credDiploma;

  /// Document type.
  ///
  /// In en, this message translates to:
  /// **'Employment / appointment evidence'**
  String get credEmployment;

  /// Document type.
  ///
  /// In en, this message translates to:
  /// **'Professional registration / licence document'**
  String get credRegistration;

  /// Document type.
  ///
  /// In en, this message translates to:
  /// **'Recognised training certificate'**
  String get credTraining;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'PDF, JPG or PNG, up to 10 MB per file, up to 5 files.'**
  String get credFormats;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get credChooseFile;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Selected documents'**
  String get credSelectedTitle;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded: the verification service is not connected. Files stay only in memory on this device and are discarded when the app closes.'**
  String get credNotUploaded;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Files will be sent privately together with the application.'**
  String get credWillSendOnSubmit;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file.'**
  String get credPickFailed;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'The file is empty.'**
  String get credErrorEmpty;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'The file is larger than 10 MB.'**
  String get credErrorTooLarge;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Only PDF, JPG and PNG files are accepted.'**
  String get credErrorType;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'No more than 5 files.'**
  String get credErrorTooMany;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Professional review'**
  String get reviewSectionTitle;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'This material has not yet been reviewed by a qualified professional.'**
  String get reviewEmpty;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Only verified professionals with review rights in the relevant specialty can review this material.'**
  String get reviewWhoCanReview;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'A review specialty has not yet been assigned to this record.'**
  String get reviewScopeNotAssigned;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Write a professional review'**
  String get reviewWrite;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get reviewDecision;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get reviewActApprove;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Request correction'**
  String get reviewActRequestChange;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Flag conflicting evidence'**
  String get reviewActConflict;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Flag as outdated'**
  String get reviewActOutdated;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reviewActReject;

  /// Decision.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get reviewDecApprove;

  /// Decision.
  ///
  /// In en, this message translates to:
  /// **'Correction required'**
  String get reviewDecRequestChange;

  /// Decision.
  ///
  /// In en, this message translates to:
  /// **'Conflicting evidence'**
  String get reviewDecConflict;

  /// Decision.
  ///
  /// In en, this message translates to:
  /// **'Outdated'**
  String get reviewDecOutdated;

  /// Decision.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get reviewDecReject;

  /// Review state.
  ///
  /// In en, this message translates to:
  /// **'Review in progress'**
  String get reviewStateInProgress;

  /// Review state.
  ///
  /// In en, this message translates to:
  /// **'Professionally reviewed'**
  String get reviewStateProfessional;

  /// Review state.
  ///
  /// In en, this message translates to:
  /// **'Scientifically verified by humans'**
  String get reviewStateHumanVerified;

  /// Review state.
  ///
  /// In en, this message translates to:
  /// **'Re-review required'**
  String get reviewStateReReview;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Review note'**
  String get reviewNote;

  /// Helper.
  ///
  /// In en, this message translates to:
  /// **'Explain the decision with reference to the evidence. At least 20 characters.'**
  String get reviewNoteHelper;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'At least 20 characters are required.'**
  String get reviewNoteTooShort;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Supporting source (optional)'**
  String get reviewSourceRef;

  /// Helper.
  ///
  /// In en, this message translates to:
  /// **'DOI, PMID or an https link'**
  String get reviewSourceHelper;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Enter a DOI, PMID or https link.'**
  String get reviewSourceInvalid;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get reviewSubmit;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Review submitted'**
  String get reviewSubmitted;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'A single review does not make content scientifically verified. Verification requires independent qualified reviews under the verification policy.'**
  String get reviewNotVerification;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'The review applies to content version {version}. If the content changes, a re-review is required.'**
  String reviewVersionNote(String version);

  /// Review footer.
  ///
  /// In en, this message translates to:
  /// **'Reviewed {date} · content version {version}'**
  String reviewMeta(String date, String version);

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Written for an earlier content version — kept in the history; a re-review is required.'**
  String get reviewStale;

  /// Permission.
  ///
  /// In en, this message translates to:
  /// **'You can review this material.'**
  String get reviewPermAllowed;

  /// Permission.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account first.'**
  String get reviewPermSignIn;

  /// Permission.
  ///
  /// In en, this message translates to:
  /// **'Reviews can be written only by verified professionals.'**
  String get reviewPermNotVerified;

  /// Permission.
  ///
  /// In en, this message translates to:
  /// **'Your verification is suspended; reviewing is unavailable.'**
  String get reviewPermSuspended;

  /// Permission.
  ///
  /// In en, this message translates to:
  /// **'You do not have review rights for this specialty.'**
  String get reviewPermScope;

  /// Permission.
  ///
  /// In en, this message translates to:
  /// **'Switch to Professional mode to write reviews. Your verification is kept.'**
  String get reviewPermStudentMode;

  /// Layer.
  ///
  /// In en, this message translates to:
  /// **'Source attached'**
  String get layerSource;

  /// Layer value.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 source} other{{count} sources}}'**
  String layerSourceCount(int count);

  /// Missing source.
  ///
  /// In en, this message translates to:
  /// **'No reliable source attached.'**
  String get noReliableSource;

  /// Layer.
  ///
  /// In en, this message translates to:
  /// **'Identifier (DOI/PMID) checked'**
  String get layerIdentifier;

  /// Layer value.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get layerIdentifierOk;

  /// Layer value.
  ///
  /// In en, this message translates to:
  /// **'Not yet checked'**
  String get layerIdentifierPending;

  /// Layer value.
  ///
  /// In en, this message translates to:
  /// **'Not applicable'**
  String get layerNotApplicable;

  /// Layer.
  ///
  /// In en, this message translates to:
  /// **'Professional reviews'**
  String get layerProfessional;

  /// Layer.
  ///
  /// In en, this message translates to:
  /// **'Human scientific verification'**
  String get layerHuman;

  /// Layer value.
  ///
  /// In en, this message translates to:
  /// **'{count} of {required} independent approvals'**
  String layerHumanCount(int count, int required);

  /// Screen.
  ///
  /// In en, this message translates to:
  /// **'Review workspace'**
  String get dashboardTitle;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'Available only to verified professionals with review rights in at least one specialty.'**
  String get dashboardOnlyVerified;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'No records in this queue.'**
  String get dashboardQueueEmpty;

  /// Item meta.
  ///
  /// In en, this message translates to:
  /// **'Claims: {claims} · sources: {sources} · evidence: {level} · version {version}'**
  String dashboardItemMeta(
    int claims,
    int sources,
    String level,
    String version,
  );

  /// Queue.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get queueNeedsReview;

  /// Queue.
  ///
  /// In en, this message translates to:
  /// **'Assigned to me'**
  String get queueAssigned;

  /// Queue.
  ///
  /// In en, this message translates to:
  /// **'Reviewed by me'**
  String get queueReviewedByMe;

  /// Queue.
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get queueConflicts;

  /// Queue.
  ///
  /// In en, this message translates to:
  /// **'Re-review required'**
  String get queueReReview;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get profileSectionVerification;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Data and privacy'**
  String get profileSectionData;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Professional verification applies to Professional mode. Switching mode does not change verification.'**
  String get profileStudentVerificationNote;

  /// Identity card.
  ///
  /// In en, this message translates to:
  /// **'Profile not filled in'**
  String get profileNotFilled;

  /// Identity card.
  ///
  /// In en, this message translates to:
  /// **'Fill in profile'**
  String get profileFillAction;

  /// Identity card.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditAction;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Sourced records'**
  String get moduleHubSourced;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Shown with their sources and current review status. “Needs review” means available sourced content that is still awaiting expert review — not missing content.'**
  String get moduleHubSourcedNote;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Open all'**
  String get moduleHubOpenAll;

  /// Link.
  ///
  /// In en, this message translates to:
  /// **'International standards and guidelines ({count})'**
  String methodsStandardsLink(int count);

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Sources and provenance'**
  String get sourceOneTap;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Forensic relevance'**
  String get researchKeyRelevance;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Only bibliographic data and a short description are shown; the full text is available from the publisher.'**
  String get researchLimitationsNote;

  /// Email code screen title.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email code'**
  String get emailCodeTitle;

  /// Profile row hint.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code is sent to your email — no password needed'**
  String get emailCodeRowHint;

  /// Email code subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email. We will send a one-time 6-digit FORENSIC EXPERT verification code.'**
  String get emailCodeSubtitle;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get emailCodeSend;

  /// Code stage title.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get emailCodeEnterTitle;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get emailCodeChange;

  /// Resend countdown.
  ///
  /// In en, this message translates to:
  /// **'Resend ({seconds})'**
  String emailCodeResendIn(int seconds);

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Confirming your email signs you in. It does not verify professional status.'**
  String get emailCodeNotProfessional;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed. You are signed in.'**
  String get emailCodeSignedIn;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Professional profile'**
  String get profileSectionProfessional;

  /// Step title.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get profileStepPersonal;

  /// Step title.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get profileStepWork;

  /// Step title.
  ///
  /// In en, this message translates to:
  /// **'Profile and verification'**
  String get profileStepProfessional;

  /// Step counter.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String profileStepOf(int step, int total);

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Your application has been received.'**
  String get verifReceivedTitle;

  /// Dialog body.
  ///
  /// In en, this message translates to:
  /// **'Your professional status is being reviewed.'**
  String get verifReceivedBody;

  /// Dialog note.
  ///
  /// In en, this message translates to:
  /// **'Status: application pending. Only an authorised human verifier can grant Verified Professional status — submitting documents does not verify you automatically.'**
  String get verifReceivedNote;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceDetailTitle;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Linked records ({count})'**
  String sourceLinkedRecords(int count);

  /// Empty.
  ///
  /// In en, this message translates to:
  /// **'No records in the offline database cite this source.'**
  String get sourceNoLinkedRecords;

  /// No source.
  ///
  /// In en, this message translates to:
  /// **'No reliable source attached.'**
  String get sourceNotAttached;

  /// Not found.
  ///
  /// In en, this message translates to:
  /// **'Source not found in the offline database.'**
  String get sourceNotFound;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Source details and linked records'**
  String get sourceOpenDetails;

  /// Home DB counts.
  ///
  /// In en, this message translates to:
  /// **'{substances} substances · {sources} sources · {claims} sourced claims'**
  String homeDbCounts(int substances, int sources, int claims);

  /// Home DB human-verified count.
  ///
  /// In en, this message translates to:
  /// **'Expert verified (2 independent experts): {count}'**
  String homeDbHumanVerified(int count);

  /// Source identifier.
  ///
  /// In en, this message translates to:
  /// **'PMID {id}'**
  String sourcePmid(String id);

  /// Stat label.
  ///
  /// In en, this message translates to:
  /// **'Substances'**
  String get homeStatSubstances;

  /// Stat label.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get homeStatSources;

  /// Stat label.
  ///
  /// In en, this message translates to:
  /// **'Sourced claims'**
  String get homeStatClaims;

  /// Stat label.
  ///
  /// In en, this message translates to:
  /// **'Expert verified'**
  String get homeStatHumanVerified;

  /// Stat footnote.
  ///
  /// In en, this message translates to:
  /// **'Expert verified = two independent qualified experts. Automated checks and AI are never counted.'**
  String get homeStatPolicy;

  /// AI header subtitle.
  ///
  /// In en, this message translates to:
  /// **'Answers only from FORENSIC EXPERT’s sourced scientific database — every statement cites a record and shows its review status.'**
  String get aiHeroSubtitle;

  /// AI status.
  ///
  /// In en, this message translates to:
  /// **'Connected · beta'**
  String get aiStatusConnected;

  /// AI context chip.
  ///
  /// In en, this message translates to:
  /// **'Source: offline database'**
  String get aiContextSources;

  /// Composer title.
  ///
  /// In en, this message translates to:
  /// **'Scientific query'**
  String get aiComposerTitle;

  /// Invite screen title.
  ///
  /// In en, this message translates to:
  /// **'Invite a colleague'**
  String get referralTitle;

  /// Invite lead.
  ///
  /// In en, this message translates to:
  /// **'Know a forensic scientist, laboratory specialist or student who would find FORENSIC EXPERT useful? Share your personal invitation.'**
  String get referralLead;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Your invitation code'**
  String get referralYourCode;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Your invitation link'**
  String get referralYourLink;

  /// Note when no public link.
  ///
  /// In en, this message translates to:
  /// **'A web link will appear here once the public FORENSIC EXPERT site is connected. For now, share your code — a colleague enters it in Profile → Invitation code.'**
  String get referralNoLinkNote;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Share invitation'**
  String get referralShare;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get referralCopy;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get referralCopied;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Your invitations'**
  String get referralStatsTitle;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get referralStatJoined;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get referralStatVerified;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get referralStatPending;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'FORENSIC Credits'**
  String get referralStatCredits;

  /// Pending credits line.
  ///
  /// In en, this message translates to:
  /// **'{amount} credits awaiting confirmation'**
  String referralCreditsPending(String amount);

  /// Credits note (rewards not live).
  ///
  /// In en, this message translates to:
  /// **'When paid services launch, eligible purchases by colleagues you invite may earn you FORENSIC Credits — {percent}% of the purchase value. Credits are an internal promotional bonus, not cash, and are not awarded for registration.'**
  String referralCreditsFuture(String percent);

  /// Credits note (rewards live).
  ///
  /// In en, this message translates to:
  /// **'You receive FORENSIC Credits worth {percent}% of eligible purchases by colleagues you invite. Credits are confirmed after the refund period. They are an internal promotional bonus, not cash.'**
  String referralCreditsActive(String percent);

  /// Privacy note.
  ///
  /// In en, this message translates to:
  /// **'Only totals are shown. Your colleagues’ names, emails, profiles and documents are never shared — neither with you nor in the invitation.'**
  String get referralPrivacyNote;

  /// Share subject.
  ///
  /// In en, this message translates to:
  /// **'Invitation to FORENSIC EXPERT'**
  String get referralShareSubject;

  /// Share text with link.
  ///
  /// In en, this message translates to:
  /// **'I use FORENSIC EXPERT as a scientific reference for forensic work — substances, methods, sources and source-linked AI answers. You can join with my invitation:\n{link}'**
  String referralShareWithLink(String link);

  /// Share text with code.
  ///
  /// In en, this message translates to:
  /// **'I use FORENSIC EXPERT as a scientific reference for forensic work — substances, methods, sources and source-linked AI answers. Install the app and enter my invitation code in Profile → Invitation code: {code}'**
  String referralShareWithCode(String code);

  /// Signed-out title.
  ///
  /// In en, this message translates to:
  /// **'Sign in to get your invitation'**
  String get referralSignInTitle;

  /// Signed-out body.
  ///
  /// In en, this message translates to:
  /// **'Your personal code is created on the server after you sign in with your email. All scientific content stays available without an account.'**
  String get referralSignInBody;

  /// Not connected.
  ///
  /// In en, this message translates to:
  /// **'Invitations will be available once the FORENSIC EXPERT account service is connected.'**
  String get referralNotConfigured;

  /// Load error.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your invitation. Check the connection and try again.'**
  String get referralLoadError;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get referralRetry;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Invitation code'**
  String get referralHaveCode;

  /// Hint.
  ///
  /// In en, this message translates to:
  /// **'Received an invitation from a colleague? Enter the 8-character code. It applies only to new accounts.'**
  String get referralHaveCodeHint;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Invitation code'**
  String get referralCodeField;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get referralApply;

  /// Already has referrer.
  ///
  /// In en, this message translates to:
  /// **'Your account was created with a colleague’s invitation.'**
  String get referralLinkedNote;

  /// Outcome.
  ///
  /// In en, this message translates to:
  /// **'Invitation applied. Welcome to FORENSIC EXPERT.'**
  String get referralClaimValid;

  /// Outcome.
  ///
  /// In en, this message translates to:
  /// **'Invitation saved. It becomes valid once your email is confirmed.'**
  String get referralClaimPending;

  /// Outcome.
  ///
  /// In en, this message translates to:
  /// **'This code was not found. Check it and try again.'**
  String get referralClaimInvalid;

  /// Outcome.
  ///
  /// In en, this message translates to:
  /// **'You can’t use your own invitation code.'**
  String get referralClaimSelf;

  /// Outcome.
  ///
  /// In en, this message translates to:
  /// **'An invitation is already linked to your account.'**
  String get referralClaimAlready;

  /// Outcome.
  ///
  /// In en, this message translates to:
  /// **'Invitation codes apply only to new accounts.'**
  String get referralClaimNotEligible;

  /// Outcome.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get referralClaimRateLimited;

  /// Outcome.
  ///
  /// In en, this message translates to:
  /// **'Code saved. It will be applied after you sign in.'**
  String get referralClaimSaved;

  /// Outcome.
  ///
  /// In en, this message translates to:
  /// **'No connection. The code is saved and will be applied later.'**
  String get referralClaimOffline;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Enter the 8-character code (letters and digits).'**
  String get referralClaimFormat;

  /// Profile row hint.
  ///
  /// In en, this message translates to:
  /// **'Share FORENSIC EXPERT with colleagues'**
  String get referralProfileRowHint;

  /// Home action hint.
  ///
  /// In en, this message translates to:
  /// **'Share a reference you trust with colleagues'**
  String get homeInviteHint;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// Footer for shared scientific records.
  ///
  /// In en, this message translates to:
  /// **'Shared from FORENSIC EXPERT — scientific reference for forensic professionals. Verify against the original source before use.'**
  String get shareFooter;

  /// Label in shared text.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get shareSourcesLabel;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Saved to your library'**
  String get savedAdded;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get savedRemoved;

  /// Card title.
  ///
  /// In en, this message translates to:
  /// **'Get started in 5 minutes'**
  String get firstStepsTitle;

  /// Progress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String firstStepsProgress(int done, int total);

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Search a substance'**
  String get firstStepsSearch;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Explore a discipline'**
  String get firstStepsDiscipline;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Open a scientific source'**
  String get firstStepsSource;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Try Forensic AI'**
  String get firstStepsAi;

  /// Step.
  ///
  /// In en, this message translates to:
  /// **'Save useful material'**
  String get firstStepsSave;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get firstStepsHide;

  /// Completed state.
  ///
  /// In en, this message translates to:
  /// **'You’re all set. Your saved materials and recent records stay on this device.'**
  String get firstStepsDone;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Full text (PDF)'**
  String get fullTextPdf;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Open-access article (PubMed Central via Europe PMC). Opens in your device’s PDF viewer or browser.'**
  String get fullTextPdfNote;

  /// Locked note.
  ///
  /// In en, this message translates to:
  /// **'Downloading full-text PDFs is available with Pro.'**
  String get fullTextPdfPro;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the PDF. Check your connection.'**
  String get fullTextOpenFailed;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get adminTitle;

  /// Profile row hint.
  ///
  /// In en, this message translates to:
  /// **'Users, platforms, countries, access'**
  String get adminProfileHint;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsers;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed'**
  String get adminConfirmed;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'New (7 days)'**
  String get adminSignups7d;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'Active (7 days)'**
  String get adminActive7d;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'Android'**
  String get adminAndroid;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'iOS'**
  String get adminIos;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'AI requests'**
  String get adminAiRequests;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get adminReferrals;

  /// Stat.
  ///
  /// In en, this message translates to:
  /// **'Pro granted'**
  String get adminProGrants;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Countries (device region)'**
  String get adminRegions;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Sign-ups, last 30 days'**
  String get adminDaily;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Users ({count})'**
  String adminUserList(int count);

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Only registered users are counted here. Installs without sign-up are shown in App Store Connect and Google Play Console.'**
  String get adminStoreNote;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Contains personal data (emails). Do not share screenshots.'**
  String get adminPrivacyNote;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Give or remove Pro'**
  String get adminGrantTitle;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'User email'**
  String get adminEmail;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Give Professional Pro'**
  String get adminGrantPro;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adminRevoke;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Pro granted.'**
  String get adminGranted;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Access removed.'**
  String get adminRevoked;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'No user with this email.'**
  String get adminNotFound;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Action failed. Check the connection.'**
  String get adminFailed;

  /// Empty.
  ///
  /// In en, this message translates to:
  /// **'This section is for administrators only.'**
  String get adminForbidden;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get adminRefresh;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get adminUnknownRegion;

  /// Badge.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminAdminBadge;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get calcSex;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get calcSexMale;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get calcSexFemale;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Body weight, kg'**
  String get calcBodyWeight;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Height, cm (optional — Seidl r)'**
  String get calcHeightOptional;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Drink volume, mL'**
  String get calcDrinkVolume;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Alcohol, % vol'**
  String get calcDrinkAbv;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Hours since drinking started'**
  String get calcHoursSinceStart;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Add drink'**
  String get calcAddDrink;

  /// Tooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove drink'**
  String get calcRemoveDrink;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Drink {n}'**
  String calcDrinkN(String n);

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Pure ethanol consumed'**
  String get calcWidmarkEthanol;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Distribution factor r'**
  String get calcWidmarkR;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Theoretical maximum (no deficit, no elimination)'**
  String get calcWidmarkPeak;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Minimum estimate'**
  String get calcWidmarkMin;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Maximum estimate'**
  String get calcWidmarkMax;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'Resorption deficit 10 % (maximum) and 30 % (minimum).'**
  String get calcWidmarkAssumptionDeficit;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'Elimination 0.10 ‰/h (maximum) and 0.20 ‰/h (minimum), from the start of drinking.'**
  String get calcWidmarkAssumptionBeta;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'r: Widmark mean (male 0.7, female 0.6), or Seidl et al. (2000) from height and weight.'**
  String get calcWidmarkAssumptionR;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'An estimate, not a measurement. Food, liver function, drinking pattern and medications change the result. Does not replace a measured blood alcohol concentration or an expert opinion.'**
  String get calcWidmarkLimitation;

  /// Field label: measured blood alcohol.
  ///
  /// In en, this message translates to:
  /// **'Measured blood alcohol'**
  String get calcBacMeasured;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Hours from event to blood sampling'**
  String get calcHoursEventToSample;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Hours from end of drinking to event (optional)'**
  String get calcHoursDrinkEndOptional;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'At the event, minimum'**
  String get calcBackMin;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'At the event, maximum'**
  String get calcBackMax;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'Elimination is linear (zero order) and absorption was complete at the event.'**
  String get calcBackAssumptionLinear;

  /// Assumption bullet.
  ///
  /// In en, this message translates to:
  /// **'β = 0.10–0.25 g/L/h (10–25 mg/100 mL/h) covers most people (Jones 2010). For ‰ (g/kg) β is converted with blood density 1.055 g/mL.'**
  String get calcBackAssumptionBeta;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'Within about 2 hours after the end of drinking the person may still be absorbing alcohol; then back-calculation may overestimate. Drinking after the event makes it invalid.'**
  String get calcBackLimitation;

  /// Warning.
  ///
  /// In en, this message translates to:
  /// **'The event was less than 2 hours after drinking ended: absorption may not be complete. Minimum is shown without back-extrapolation.'**
  String get calcWarnAbsorption;

  /// Warning.
  ///
  /// In en, this message translates to:
  /// **'By this time alcohol is likely fully eliminated.'**
  String get calcWarnEliminated;

  /// Warning.
  ///
  /// In en, this message translates to:
  /// **'Calculated r is outside the usual 0.45–0.85 range — check height and weight.'**
  String get calcWarnRUnusual;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get calcEthanolMatrix;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'Whole blood'**
  String get calcMatrixBlood;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'Serum / plasma'**
  String get calcMatrixSerum;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Serum / blood ratio'**
  String get calcSerumRatio;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Whole blood equivalent'**
  String get calcEthanolBloodHeader;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'‰ means g/kg; blood density 1.055 g/mL is used for g/L.'**
  String get calcEthanolAssumptionDensity;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'Serum contains more water than blood, so serum ethanol is higher; default ratio 1.2.'**
  String get calcEthanolAssumptionRatio;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'The serum/blood ratio varies between people (about 1.1–1.3; Rainey 1993). Use the value required by your laboratory or jurisdiction.'**
  String get calcEthanolLimitation;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Rectal temperature, °C'**
  String get calcRectalTemp;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Ambient temperature, °C'**
  String get calcAmbientTemp;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Clothing / environment (corrective factor)'**
  String get calcCorrectiveFactor;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'Naked, dry, still air — 1.0'**
  String get calcFactorNakedDry;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'Naked, moving air — 0.75'**
  String get calcFactorNakedMovingAir;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'Naked, in still water — 0.5'**
  String get calcFactorWetStill;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'Naked, in flowing water — 0.35'**
  String get calcFactorWetFlowing;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'1–2 thin layers of clothing — 1.1'**
  String get calcFactorThin;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'2–3 layers of clothing — 1.2'**
  String get calcFactorLayers;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'3–4 layers / thick clothing — 1.3'**
  String get calcFactorThick;

  /// Option.
  ///
  /// In en, this message translates to:
  /// **'Under a thick blanket — 2.0'**
  String get calcFactorBedding;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Estimated postmortem interval (PMI)'**
  String get calcHenssgeTime;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'95 % limits'**
  String get calcHenssgeRange;

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'{h} h'**
  String calcHoursValue(String h);

  /// Value.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to} h'**
  String calcHoursRange(String from, String to);

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'Body temperature at death 37.2 °C.'**
  String get calcHenssgeAssumptionNormal;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'Ambient temperature was roughly constant; formula for ≤ 23 °C and > 23 °C differs.'**
  String get calcHenssgeAssumptionAmbient;

  /// Assumption.
  ///
  /// In en, this message translates to:
  /// **'95 % limits: ±2.8 h (≤ 23 °C), ±3.2 h (> 23 °C), ±4.5 h when a corrective factor is used.'**
  String get calcHenssgeAssumptionCi;

  /// Limitation.
  ///
  /// In en, this message translates to:
  /// **'Not valid with fever, hypothermia, strong heat sources, sun, body moved between environments, or major changes in ambient temperature. Combine with other signs (lividity, rigor, supravital reactions).'**
  String get calcHenssgeLimitation;

  /// Warning.
  ///
  /// In en, this message translates to:
  /// **'Rectal temperature is at or above 37.2 °C — the body has not started cooling, or there was fever.'**
  String get calcWarnNoCooling;

  /// Warning.
  ///
  /// In en, this message translates to:
  /// **'Body is close to ambient temperature — accuracy is low.'**
  String get calcWarnLatePhase;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Enter a realistic body weight.'**
  String get calcErrorWeight;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid time in hours.'**
  String get calcErrorTime;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Alcohol content must be between 0 and 100 %.'**
  String get calcErrorAbv;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Height must be 120–230 cm, or leave it empty.'**
  String get calcErrorHeight;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Enter a blood alcohol between 0 and 8 ‰.'**
  String get calcErrorBac;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Ratio must be between 1.0 and 1.5.'**
  String get calcErrorRatio;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Rectal temperature must be higher than ambient and at most 42 °C.'**
  String get calcErrorRectal;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Ambient temperature must be between −20 and 35 °C.'**
  String get calcErrorAmbient;

  /// Section title.
  ///
  /// In en, this message translates to:
  /// **'Guidelines'**
  String get guidelinesTitle;

  /// Hub subtitle.
  ///
  /// In en, this message translates to:
  /// **'Independent scientific-practical guidance by discipline'**
  String get guidelinesSubtitle;

  /// Intro banner.
  ///
  /// In en, this message translates to:
  /// **'Each guideline is an independent scientific synthesis written from the cited, verified literature. It is not an official methodology and does not replace accredited laboratory procedures or the law of your country. Every card stays under review until a specialist confirms it.'**
  String get guidelinesIntro;

  /// Search field.
  ///
  /// In en, this message translates to:
  /// **'Search guidelines'**
  String get guidelinesSearchHint;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'No guidelines in this area yet.'**
  String get guidelinesEmptyArea;

  /// Empty search.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get guidelinesNoResults;

  /// Count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No guidelines} =1{1 guideline} other{{count} guidelines}}'**
  String guidelinesCount(int count);

  /// Area.
  ///
  /// In en, this message translates to:
  /// **'Forensic medicine'**
  String get guidelineAreaForensicMedicine;

  /// Area.
  ///
  /// In en, this message translates to:
  /// **'Forensic chemistry and toxicology'**
  String get guidelineAreaForensicChemistry;

  /// Area.
  ///
  /// In en, this message translates to:
  /// **'Forensic histology'**
  String get guidelineAreaForensicHistology;

  /// Area.
  ///
  /// In en, this message translates to:
  /// **'Forensic biology and genetics'**
  String get guidelineAreaForensicBiology;

  /// Area.
  ///
  /// In en, this message translates to:
  /// **'Medical criminalistics and anthropology'**
  String get guidelineAreaMedicalCriminalistics;

  /// Area.
  ///
  /// In en, this message translates to:
  /// **'Other disciplines'**
  String get guidelineAreaOther;

  /// Detail banner.
  ///
  /// In en, this message translates to:
  /// **'Independent scientific synthesis based on the references below. Not an official methodology; check the requirements of your laboratory and jurisdiction.'**
  String get guidelineIndependentNote;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'This translation is a draft and has not been reviewed by a specialist yet.'**
  String get guidelineTranslationDraft;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'Not yet available in your language — shown in the original language ({language}).'**
  String guidelineFallbackLanguage(String language);

  /// Header.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get guidelineReferences;

  /// Meta.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String guidelineUpdated(String date);

  /// Header.
  ///
  /// In en, this message translates to:
  /// **'Related tools'**
  String get guidelineRelatedTools;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get guidelineOpenReference;

  /// Language name.
  ///
  /// In en, this message translates to:
  /// **'Uzbek'**
  String get languageNameUz;

  /// Language name.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageNameRu;

  /// Language name.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEn;

  /// Admin section.
  ///
  /// In en, this message translates to:
  /// **'Uzbekistan practice codes (restricted)'**
  String get restrictedCatalogTitle;

  /// Admin banner.
  ///
  /// In en, this message translates to:
  /// **'Visible to administrators only. Catalogue metadata of a restricted source: the full text is not stored in the app, is not sent to AI and must not be distributed.'**
  String get restrictedCatalogNote;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Import catalogue file'**
  String get restrictedCatalogImport;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Remove from this device'**
  String get restrictedCatalogRemove;

  /// Empty.
  ///
  /// In en, this message translates to:
  /// **'No catalogue on this device. Import the file you received privately.'**
  String get restrictedCatalogEmpty;

  /// Snack.
  ///
  /// In en, this message translates to:
  /// **'Catalogue imported: {count} records.'**
  String restrictedCatalogImported(int count);

  /// Snack.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid catalogue.'**
  String get restrictedCatalogInvalid;

  /// Count.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String restrictedCatalogRecords(int count);

  /// Meta.
  ///
  /// In en, this message translates to:
  /// **'pp. {from}–{to}'**
  String restrictedCatalogPages(String from, String to);

  /// Meta.
  ///
  /// In en, this message translates to:
  /// **'p. {page}'**
  String restrictedCatalogPage(String page);

  /// Meta.
  ///
  /// In en, this message translates to:
  /// **'Code as written in the source: {code}'**
  String restrictedCatalogCodeOriginal(String code);

  /// Search.
  ///
  /// In en, this message translates to:
  /// **'Search by code, title or term'**
  String get restrictedCatalogSearchHint;

  /// Header.
  ///
  /// In en, this message translates to:
  /// **'Linked independent guidelines'**
  String get restrictedCatalogLinkedCards;

  /// Header.
  ///
  /// In en, this message translates to:
  /// **'Related official documents'**
  String get restrictedCatalogNormative;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Section {section}'**
  String restrictedCatalogSection(String section);

  /// Meta.
  ///
  /// In en, this message translates to:
  /// **'Title translation is a draft'**
  String get restrictedCatalogTitleDraft;

  /// Progress.
  ///
  /// In en, this message translates to:
  /// **'Preparing an answer from sources… This can take up to a minute.'**
  String get aiWorking;

  /// Progress.
  ///
  /// In en, this message translates to:
  /// **'Searching the offline database…'**
  String get aiSearchingOffline;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'The sources in the app do not cover this question well enough, so no sourced answer was produced.'**
  String get aiNotCovered;

  /// Header.
  ///
  /// In en, this message translates to:
  /// **'AI note (no sources — do not rely on it)'**
  String get aiModelNoteTitle;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'The AI answer was not shown because it could not be verified against the app\'s sources.'**
  String get aiAnswerRejected;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'The hourly limit of AI questions has been reached. Please try again later.'**
  String get aiErrRateLimited;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again to use AI.'**
  String get aiErrSignIn;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'No connection to the AI service. Check the internet connection.'**
  String get aiErrOffline;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'The AI service is temporarily unavailable. Please try again later.'**
  String get aiErrServer;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'The AI service is not configured on the server yet.'**
  String get aiErrNotConfigured;

  /// Banner.
  ///
  /// In en, this message translates to:
  /// **'Your AI question allowance is used up for now.'**
  String get aiQuotaUsed;

  /// Header.
  ///
  /// In en, this message translates to:
  /// **'Sources found in the offline database'**
  String get aiOfflineSourcesTitle;

  /// Expander.
  ///
  /// In en, this message translates to:
  /// **'Sources used ({count})'**
  String aiOfflineSourcesCount(int count);

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get aiRetry;

  /// Basis of a metabolism co-mention link (inserted into relationBasis).
  ///
  /// In en, this message translates to:
  /// **'source excerpt'**
  String get relationBasisSourceExcerpt;

  /// Metadata row label: Handle System persistent identifier (hdl.handle.net).
  ///
  /// In en, this message translates to:
  /// **'Handle'**
  String get metaHandle;

  /// Attached file size in kilobytes.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String fileSizeKb(String size);

  /// Discipline.
  ///
  /// In en, this message translates to:
  /// **'Forensic serology'**
  String get disc_forensicSerology;

  /// Discipline.
  ///
  /// In en, this message translates to:
  /// **'Medical criminalistics'**
  String get disc_medicalCriminalistics;

  /// Discipline.
  ///
  /// In en, this message translates to:
  /// **'Trace evidence and traceology'**
  String get disc_traceEvidence;

  /// Discipline.
  ///
  /// In en, this message translates to:
  /// **'Firearms and ballistics'**
  String get disc_firearmsBallistics;

  /// Discipline.
  ///
  /// In en, this message translates to:
  /// **'Questioned documents'**
  String get disc_questionedDocuments;

  /// Discipline.
  ///
  /// In en, this message translates to:
  /// **'Digital forensics'**
  String get disc_digitalForensics;

  /// Discipline group.
  ///
  /// In en, this message translates to:
  /// **'Criminalistics'**
  String get discGroupCriminalistics;

  /// Home header greeting above the role chip.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get homeGreeting;

  /// Home header: current usage mode (Professional / Student). Opens mode settings.
  ///
  /// In en, this message translates to:
  /// **'Mode: {mode}'**
  String homeRoleChip(String mode);

  /// Home: subtitle of the AI entry card.
  ///
  /// In en, this message translates to:
  /// **'Ask a scientific question. Answers cite their sources.'**
  String get homeAiEntryBody;

  /// Home section: scientific library and professional tools.
  ///
  /// In en, this message translates to:
  /// **'Library & tools'**
  String get homeResourcesHeading;

  /// Home: subtitle of the scientific library entry.
  ///
  /// In en, this message translates to:
  /// **'Substances, methods, standards and references'**
  String get homeLibraryBody;

  /// Home section: recently viewed, recent tools, favourites, recent searches.
  ///
  /// In en, this message translates to:
  /// **'Continue & saved'**
  String get homeContinueSaved;

  /// Screen reader label for a loading skeleton.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingContent;

  /// Section title.
  ///
  /// In en, this message translates to:
  /// **'Expert publications'**
  String get pubTitle;

  /// Intro.
  ///
  /// In en, this message translates to:
  /// **'Articles by experts, published after moderation. Moderation checks format, rules and personal data — not scientific correctness.'**
  String get pubIntro;

  /// Notice on every article.
  ///
  /// In en, this message translates to:
  /// **'Submitting an article does not mean it has been scientifically verified.'**
  String get pubNotVerifiedNotice;

  /// Search field.
  ///
  /// In en, this message translates to:
  /// **'Title, abstract or keyword'**
  String get pubSearchHint;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'All disciplines'**
  String get pubAllDisciplines;

  /// Empty list.
  ///
  /// In en, this message translates to:
  /// **'No published articles yet.'**
  String get pubEmpty;

  /// Empty filter result.
  ///
  /// In en, this message translates to:
  /// **'No articles match your query.'**
  String get pubFilterEmpty;

  /// Load error.
  ///
  /// In en, this message translates to:
  /// **'Could not load articles. Check the connection.'**
  String get pubLoadFailed;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get pubReload;

  /// Gated section.
  ///
  /// In en, this message translates to:
  /// **'This section is not available yet.'**
  String get pubUnavailable;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Submit an article'**
  String get pubSubmit;

  /// Action / screen title.
  ///
  /// In en, this message translates to:
  /// **'My articles'**
  String get pubMine;

  /// Action / screen title.
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get pubModeration;

  /// Signed-out note.
  ///
  /// In en, this message translates to:
  /// **'Sign in to submit articles or report them.'**
  String get pubSignInRequired;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get pubSignIn;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get pubStatusDraft;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get pubStatusSubmitted;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Initial check'**
  String get pubStatusScreening;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get pubStatusInReview;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Approved for publication'**
  String get pubStatusApproved;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Returned to the author'**
  String get pubStatusRejected;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get pubStatusPublished;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Retracted'**
  String get pubStatusRetracted;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Replaced by a new version'**
  String get pubStatusSuperseded;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Abstract'**
  String get pubAbstract;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Keywords'**
  String get pubKeywords;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get pubAuthors;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Affiliation'**
  String get pubAffiliation;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'DOI identifier'**
  String get pubDoi;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get pubReferences;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Full text link'**
  String get pubExternalUrl;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Article language'**
  String get pubLanguage;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get pubDiscipline;

  /// Meta.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String pubVersion(int version);

  /// Meta.
  ///
  /// In en, this message translates to:
  /// **'Published {date}'**
  String pubPublishedOn(String date);

  /// Detail empty.
  ///
  /// In en, this message translates to:
  /// **'Article not found.'**
  String get pubNotFound;

  /// Language.
  ///
  /// In en, this message translates to:
  /// **'Uzbek'**
  String get pubLangUz;

  /// Language.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get pubLangRu;

  /// Language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get pubLangEn;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get pubReport;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Report this article'**
  String get pubReportTitle;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get pubReportDetails;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get pubReportSend;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pubCancel;

  /// Reason.
  ///
  /// In en, this message translates to:
  /// **'Plagiarism'**
  String get pubReasonPlagiarism;

  /// Reason.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get pubReasonPersonalData;

  /// Reason.
  ///
  /// In en, this message translates to:
  /// **'Copyright violation'**
  String get pubReasonCopyright;

  /// Reason.
  ///
  /// In en, this message translates to:
  /// **'Misleading content'**
  String get pubReasonMisinformation;

  /// Reason.
  ///
  /// In en, this message translates to:
  /// **'Offensive content'**
  String get pubReasonAbuse;

  /// Reason.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pubReasonOther;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Thank you. The report was sent to moderators.'**
  String get pubReported;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'You have already reported this article.'**
  String get pubAlreadyReported;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Action failed. Check the connection.'**
  String get pubActionFailed;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Article title'**
  String get pubFormTitle;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Keywords (comma-separated)'**
  String get pubFormKeywords;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Authors (one per line)'**
  String get pubFormAuthors;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'DOI (if any)'**
  String get pubFormDoi;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Full text link (https://…)'**
  String get pubFormUrl;

  /// Warning.
  ///
  /// In en, this message translates to:
  /// **'Do not include personal data: names of victims or suspects, case numbers, addresses, photos of identifiable people, medical records.'**
  String get pubPiiWarning;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Required confirmations'**
  String get pubConfirmationsTitle;

  /// Checkbox.
  ///
  /// In en, this message translates to:
  /// **'I am the author or have the right to publish this text.'**
  String get pubConfirmRights;

  /// Checkbox.
  ///
  /// In en, this message translates to:
  /// **'I agree that after moderation the article will be publicly available in FORENSIC EXPERT.'**
  String get pubConfirmConsent;

  /// Checkbox.
  ///
  /// In en, this message translates to:
  /// **'The article contains no personal data of victims, suspects or other people.'**
  String get pubConfirmNoPii;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get pubSaveDraft;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Submit for moderation'**
  String get pubSubmitForModeration;

  /// Hint.
  ///
  /// In en, this message translates to:
  /// **'To submit, fill in the title, abstract and discipline and tick all three confirmations.'**
  String get pubSubmitHint;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Draft saved.'**
  String get pubDraftSaved;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'The article was sent for moderation.'**
  String get pubSubmitted;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Not sent: fill in the required fields and confirmations.'**
  String get pubSubmitRejected;

  /// Screen title.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get pubEditTitle;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'A paid subscription does not affect moderation.'**
  String get pubPaidNote;

  /// Field error.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get pubRequired;

  /// Empty list.
  ///
  /// In en, this message translates to:
  /// **'You have no articles yet.'**
  String get pubMineEmpty;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get pubTimeline;

  /// Label.
  ///
  /// In en, this message translates to:
  /// **'Moderator comment'**
  String get pubModeratorComment;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get pubEdit;

  /// Empty queue.
  ///
  /// In en, this message translates to:
  /// **'No articles awaiting moderation.'**
  String get pubQueueEmpty;

  /// Section.
  ///
  /// In en, this message translates to:
  /// **'Reports ({count})'**
  String pubReports(int count);

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Move to: {status}'**
  String pubMoveTo(String status);

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Comment for the author'**
  String get pubCommentLabel;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'A comment is required for this decision.'**
  String get pubCommentRequired;

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Your own article: another moderator must review it.'**
  String get pubOwnArticle;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Updated.'**
  String get pubModerationDone;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'This step is not allowed from the current state.'**
  String get pubInvalidTransition;

  /// Empty.
  ///
  /// In en, this message translates to:
  /// **'This section is for moderators only.'**
  String get pubForbidden;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get pubConfirm;

  /// Card title.
  ///
  /// In en, this message translates to:
  /// **'Sign in to ask the AI'**
  String get aiSignInTitle;

  /// Card body.
  ///
  /// In en, this message translates to:
  /// **'The AI service is connected and answers only from the app\'s sources, with citations. Asking questions requires a signed-in account; offline source search works without it.'**
  String get aiSignInBody;

  /// Hint under the send button.
  ///
  /// In en, this message translates to:
  /// **'Sign in to send questions to the AI.'**
  String get aiSendSignIn;

  /// Header status chip.
  ///
  /// In en, this message translates to:
  /// **'Sign-in required'**
  String get aiStatusSignIn;

  /// Semantics label of the discipline filter chip row on the search screen.
  ///
  /// In en, this message translates to:
  /// **'Filter results by discipline'**
  String get searchDisciplineFilter;

  /// Chip: no discipline filter.
  ///
  /// In en, this message translates to:
  /// **'All disciplines'**
  String get searchDisciplineAll;

  /// Result meta: a method shown because a matching substance is linked to it in the sources.
  ///
  /// In en, this message translates to:
  /// **'Linked to {name} (mentioned in source)'**
  String searchLinkedVia(String name);

  /// Study mode title.
  ///
  /// In en, this message translates to:
  /// **'Study mode'**
  String get studyTitle;

  /// Learn screen entry.
  ///
  /// In en, this message translates to:
  /// **'Flashcards and a self-check quiz built only from sourced records in the app'**
  String get studyEntrySubtitle;

  /// Hub banner.
  ///
  /// In en, this message translates to:
  /// **'Every card and question is built from a record that already exists in the app, together with its source. Nothing new is written. Material that is still under expert review is labelled.'**
  String get studyIntro;

  /// Hub section.
  ///
  /// In en, this message translates to:
  /// **'Topics by discipline'**
  String get studySectionTopics;

  /// Hub section.
  ///
  /// In en, this message translates to:
  /// **'Substances: molecular formulas'**
  String get studySectionSubstances;

  /// Hub section.
  ///
  /// In en, this message translates to:
  /// **'Guidelines'**
  String get studySectionGuidelines;

  /// Deck size.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String studyDeckCount(int count);

  /// Cards due now.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing due} other{{count} due now}}'**
  String studyDueCount(int count);

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'No sourced material is available for study yet.'**
  String get studyEmpty;

  /// Skeleton semantics.
  ///
  /// In en, this message translates to:
  /// **'Loading study material'**
  String get studyLoading;

  /// Deck note.
  ///
  /// In en, this message translates to:
  /// **'Not enough records of this type for a quiz'**
  String get studyQuizUnavailable;

  /// Flashcard front hint.
  ///
  /// In en, this message translates to:
  /// **'What does the cited source say about this topic?'**
  String get studyFrontTopic;

  /// Flashcard front hint.
  ///
  /// In en, this message translates to:
  /// **'What is the molecular formula?'**
  String get studyFrontSubstance;

  /// Flashcard front hint.
  ///
  /// In en, this message translates to:
  /// **'What is the summary of this guideline?'**
  String get studyFrontGuideline;

  /// Flashcard hint.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to flip it'**
  String get studyTapToFlip;

  /// Flashcard action.
  ///
  /// In en, this message translates to:
  /// **'Hide answer'**
  String get studyHideAnswer;

  /// Flashcard grade.
  ///
  /// In en, this message translates to:
  /// **'Didn’t know'**
  String get studyDidntKnow;

  /// Flashcard progress.
  ///
  /// In en, this message translates to:
  /// **'Card {current} of {total}'**
  String studyCardProgress(int current, int total);

  /// Leitner box.
  ///
  /// In en, this message translates to:
  /// **'Box {box} of {total}'**
  String studyBox(int box, int total);

  /// Leitner box.
  ///
  /// In en, this message translates to:
  /// **'New card'**
  String get studyBoxNew;

  /// Answer label.
  ///
  /// In en, this message translates to:
  /// **'Verbatim quote from the source (original language)'**
  String get studyQuoteLabel;

  /// Answer meta.
  ///
  /// In en, this message translates to:
  /// **'Group (editorial): {group}'**
  String studyGroupLabel(String group);

  /// Header.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get studySourcesHeader;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Open the original entry'**
  String get studyOpenEntry;

  /// Semantics.
  ///
  /// In en, this message translates to:
  /// **'Open source details'**
  String get studyOpenSourceDetails;

  /// Overflow.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String studyMoreSources(int count);

  /// Session end.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get studySessionDone;

  /// Session end.
  ///
  /// In en, this message translates to:
  /// **'Knew {known} of {total}'**
  String studySessionSummary(int known, int total);

  /// Nothing due.
  ///
  /// In en, this message translates to:
  /// **'Nothing is due in this deck right now. Come back later or review all cards.'**
  String get studyAllCaughtUp;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Review all cards'**
  String get studyReviewAll;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Reset deck progress'**
  String get studyResetProgress;

  /// Snack.
  ///
  /// In en, this message translates to:
  /// **'Deck progress reset'**
  String get studyResetDone;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Back to decks'**
  String get studyBackToDecks;

  /// Quiz stem.
  ///
  /// In en, this message translates to:
  /// **'Which topic is this source quote cited for?'**
  String get studyQuizStemTopic;

  /// Quiz stem.
  ///
  /// In en, this message translates to:
  /// **'What is the molecular formula of {name}?'**
  String studyQuizStemSubstance(String name);

  /// Quiz stem.
  ///
  /// In en, this message translates to:
  /// **'Which guideline does this summary describe?'**
  String get studyQuizStemGuideline;

  /// Quiz banner.
  ///
  /// In en, this message translates to:
  /// **'Wrong options are other records of the same type from the app; nothing is invented.'**
  String get studyQuizNote;

  /// Quiz progress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String studyQuizQuestionOf(int current, int total);

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get studyQuizNext;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get studyQuizFinish;

  /// Quiz result.
  ///
  /// In en, this message translates to:
  /// **'Score: {correct} of {total}'**
  String studyQuizScore(int correct, int total);

  /// Header.
  ///
  /// In en, this message translates to:
  /// **'Review your mistakes'**
  String get studyQuizMistakes;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'No mistakes — every answer was correct.'**
  String get studyQuizNoMistakes;

  /// Mistake review.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {answer}'**
  String studyQuizYourAnswer(String answer);

  /// Mistake review.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String studyQuizCorrectAnswer(String answer);

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'New quiz'**
  String get studyQuizRetry;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'This deck is not available.'**
  String get studyDeckNotFound;

  /// Router error page title.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// Router error page body.
  ///
  /// In en, this message translates to:
  /// **'The link may be outdated or incorrect.'**
  String get notFoundBody;

  /// Router error page action.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get notFoundHome;

  /// Single sign-in row / action (email one-time code).
  ///
  /// In en, this message translates to:
  /// **'Sign in (email code)'**
  String get accountSignInEmailCode;

  /// One note at the top of the Tools screen (replaces per-tile chips).
  ///
  /// In en, this message translates to:
  /// **'Calculation modules are software-tested. Formulas and their sources have not yet been confirmed by an expert.'**
  String get toolsReviewNote;

  /// One line above search results when every result has the same review status.
  ///
  /// In en, this message translates to:
  /// **'All results: {status}'**
  String searchAllStatus(String status);

  /// Open a research link in the browser.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get researchOpenInBrowser;

  /// Collapsed group of disciplines without records.
  ///
  /// In en, this message translates to:
  /// **'Coming soon ({count})'**
  String disciplinesComingSoon(int count);

  /// Collapsed role picker on the mode screen.
  ///
  /// In en, this message translates to:
  /// **'Choose a role (optional)'**
  String get modeRoleExpand;

  /// Sources list empty state.
  ///
  /// In en, this message translates to:
  /// **'No sources are available yet.'**
  String get sourcesEmpty;

  /// Substance page: analysis section header.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisTitle;

  /// Analysis section banner.
  ///
  /// In en, this message translates to:
  /// **'Which specimens and methods — from sources. Not yet expert-reviewed.'**
  String get analysisIntro;

  /// Analysis subsection.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get analysisSpecimensTitle;

  /// Specimens note.
  ///
  /// In en, this message translates to:
  /// **'A source reports a value in these specimens (not a threshold).'**
  String get analysisSpecimensNote;

  /// Specimens empty.
  ///
  /// In en, this message translates to:
  /// **'The pack has no sourced specimen for this substance yet.'**
  String get analysisNoSpecimens;

  /// Count of basis records.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sourced record} other{{count} sourced records}}'**
  String analysisSourcedRecords(int count);

  /// Methods linked to a specimen via the same source.
  ///
  /// In en, this message translates to:
  /// **'Methods in the same source: {methods}'**
  String analysisSpecimenMethods(String methods);

  /// Analysis subsection.
  ///
  /// In en, this message translates to:
  /// **'Screening (presumptive)'**
  String get analysisScreeningTitle;

  /// Screening warning.
  ///
  /// In en, this message translates to:
  /// **'A screening result is presumptive and must be confirmed by a confirmation method.'**
  String get analysisScreeningNote;

  /// Screening row: confirmation methods.
  ///
  /// In en, this message translates to:
  /// **'Confirmation: {methods}'**
  String analysisConfirmedBy(String methods);

  /// Analysis subsection.
  ///
  /// In en, this message translates to:
  /// **'Confirmation methods'**
  String get analysisConfirmationTitle;

  /// Confirmation row: screening tests.
  ///
  /// In en, this message translates to:
  /// **'After screening: {tests}'**
  String analysisAfterScreening(String tests);

  /// Analysis subsection.
  ///
  /// In en, this message translates to:
  /// **'Analytical methods'**
  String get analysisMethodsTitle;

  /// Analytical methods note.
  ///
  /// In en, this message translates to:
  /// **'Mentioned with this substance in a source; not a validated procedure.'**
  String get analysisMethodsRoleNote;

  /// Methods not linked to specimens.
  ///
  /// In en, this message translates to:
  /// **'Sources do not tie these methods to a specific specimen.'**
  String get analysisMethodsNotPaired;

  /// Analysis subsection.
  ///
  /// In en, this message translates to:
  /// **'Metabolites to target'**
  String get analysisMetabolitesTitle;

  /// Metabolite row: specimens.
  ///
  /// In en, this message translates to:
  /// **'Specimens: {specimens}'**
  String analysisMetaboliteSpecimens(String specimens);

  /// Analysis empty state.
  ///
  /// In en, this message translates to:
  /// **'The content pack has no sourced analysis data (specimens, methods or metabolites) for this substance yet.'**
  String get analysisEmpty;

  /// Tooltip: open basis claim provenance.
  ///
  /// In en, this message translates to:
  /// **'Show the source'**
  String get analysisShowSource;

  /// Specimen page section.
  ///
  /// In en, this message translates to:
  /// **'Substances analysed in this specimen'**
  String get specimenSubstancesTitle;

  /// Specimen page note.
  ///
  /// In en, this message translates to:
  /// **'A source reports a value for each of these substances in this specimen.'**
  String get specimenSubstancesNote;

  /// Specimen page empty.
  ///
  /// In en, this message translates to:
  /// **'No substance in the pack is linked to this specimen yet.'**
  String get specimenSubstancesNone;

  /// Label above an automatic translation shown under a verbatim source excerpt. Must say it is automatic and not verified.
  ///
  /// In en, this message translates to:
  /// **'Automatic translation · not verified'**
  String get quoteMachineTranslation;

  /// Screen-reader label for the automatic translation block.
  ///
  /// In en, this message translates to:
  /// **'Automatic translation of the source excerpt, not verified by an expert. The original text above is the citation.'**
  String get quoteMachineTranslationSemantics;

  /// Secondary line under a translated research title.
  ///
  /// In en, this message translates to:
  /// **'Original title: {title}'**
  String quoteOriginalTitle(String title);

  /// Locator of the quoted passage inside the source.
  ///
  /// In en, this message translates to:
  /// **'§ {section}'**
  String sourceSectionRef(String section);

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Abstract'**
  String get sectionAbstract;

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get sectionIntroduction;

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get sectionBackground;

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Methods'**
  String get sectionMethods;

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get sectionResults;

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get sectionDiscussion;

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Conclusions'**
  String get sectionConclusion;

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Case report'**
  String get sectionCaseReport;

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Figure'**
  String get sectionFigure;

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get sectionTable;

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Supplementary material'**
  String get sectionSupplement;

  /// Article section name.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sectionTitle;

  /// Short author list: first author followed by et al.
  ///
  /// In en, this message translates to:
  /// **'{author} et al.'**
  String researchAuthorsEtAl(String author);

  /// PubChem record section name.
  ///
  /// In en, this message translates to:
  /// **'Computed properties'**
  String get sectionComputedProperties;

  /// Screen title / Profile row.
  ///
  /// In en, this message translates to:
  /// **'Suggestions & support'**
  String get supTitle;

  /// Profile row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Ideas, bugs, scientific errors — the team replies here'**
  String get supProfileHint;

  /// Profile row subtitle with unread replies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new reply} other{{count} new replies}}'**
  String supUnreadHint(int count);

  /// Action / screen title.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get supNew;

  /// Empty list.
  ///
  /// In en, this message translates to:
  /// **'You have not sent any requests yet. Share an idea, report a bug or a scientific error — we read every message.'**
  String get supEmpty;

  /// Load error.
  ///
  /// In en, this message translates to:
  /// **'Could not load requests. Check the connection.'**
  String get supLoadFailed;

  /// Backend not connected.
  ///
  /// In en, this message translates to:
  /// **'Requests need the online service, which is not connected in this build.'**
  String get supUnavailable;

  /// Signed-out note.
  ///
  /// In en, this message translates to:
  /// **'Sign in to send a request and receive replies.'**
  String get supSignInRequired;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get supSignIn;

  /// Category.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get supCatSuggestion;

  /// Category.
  ///
  /// In en, this message translates to:
  /// **'Bug in the app'**
  String get supCatBug;

  /// Category.
  ///
  /// In en, this message translates to:
  /// **'Scientific error'**
  String get supCatScientificError;

  /// Category.
  ///
  /// In en, this message translates to:
  /// **'Feature request'**
  String get supCatFeatureRequest;

  /// Category.
  ///
  /// In en, this message translates to:
  /// **'Technical support'**
  String get supCatTechSupport;

  /// Category.
  ///
  /// In en, this message translates to:
  /// **'General question'**
  String get supCatGeneral;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get supStatusNew;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get supStatusInReview;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get supStatusAnswered;

  /// Status.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get supStatusClosed;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get supCategory;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get supSubject;

  /// Field.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get supMessage;

  /// Field hint.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened or what you suggest. Do not include personal data of third parties or case materials.'**
  String get supMessageHint;

  /// Prefilled related record.
  ///
  /// In en, this message translates to:
  /// **'Related record: {id}'**
  String supRelated(String id);

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Attach screenshot'**
  String get supAttach;

  /// Attachment rules.
  ///
  /// In en, this message translates to:
  /// **'JPEG or PNG, up to 5 MB.'**
  String get supAttachHint;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Remove screenshot'**
  String get supAttachRemove;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'The image is larger than 5 MB.'**
  String get supAttachTooLarge;

  /// Error.
  ///
  /// In en, this message translates to:
  /// **'Only JPEG or PNG images can be attached.'**
  String get supAttachWrongType;

  /// Attachment label in a message.
  ///
  /// In en, this message translates to:
  /// **'Screenshot'**
  String get supAttachment;

  /// Privacy note on the form.
  ///
  /// In en, this message translates to:
  /// **'Your message, the screenshot and your account email are stored on our server only to answer you. Only the FORENSIC EXPERT team can read them. They are deleted together with your account.'**
  String get supPrivacyNote;

  /// Consent checkbox.
  ///
  /// In en, this message translates to:
  /// **'I agree that this message is processed to answer my request.'**
  String get supConsent;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get supSend;

  /// Progress.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get supSending;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Request sent. We will reply here.'**
  String get supSent;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your consent.'**
  String get supConsentRequired;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a subject.'**
  String get supSubjectRequired;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Enter a message.'**
  String get supMessageRequired;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Too many messages. Please try again later.'**
  String get supRateLimited;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Not sent. Check the connection and try again.'**
  String get supFailed;

  /// Closed thread.
  ///
  /// In en, this message translates to:
  /// **'This request is closed. Create a new one if you need more help.'**
  String get supClosedNote;

  /// Reply field.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get supReplyHint;

  /// Bubble author.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get supYou;

  /// Bubble author (admin).
  ///
  /// In en, this message translates to:
  /// **'FORENSIC EXPERT team'**
  String get supTeam;

  /// Thread missing.
  ///
  /// In en, this message translates to:
  /// **'Request not found.'**
  String get supNotFound;

  /// Semantic label for unread badge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread reply} other{{count} unread replies}}'**
  String supUnreadBadge(int count);

  /// In-app banner on open.
  ///
  /// In en, this message translates to:
  /// **'The team replied to your request.'**
  String get supBannerText;

  /// Banner action.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get supBannerOpen;

  /// Banner action (tooltip).
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get supBannerDismiss;

  /// App bar menu item on content pages.
  ///
  /// In en, this message translates to:
  /// **'Report an error'**
  String get supReportError;

  /// Prefilled subject.
  ///
  /// In en, this message translates to:
  /// **'Error in: {title}'**
  String supReportErrorSubject(String title);

  /// Count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message} other{{count} messages}}'**
  String supMessages(int count);

  /// Overflow tooltip.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get supMoreActions;

  /// Admin section.
  ///
  /// In en, this message translates to:
  /// **'Requests inbox'**
  String get admNavInbox;

  /// Admin section hint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing awaiting a reply} =1{1 awaiting a reply} other{{count} awaiting a reply}}'**
  String admNavInboxHint(int count);

  /// Admin section.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get admNavUsers;

  /// Admin section hint.
  ///
  /// In en, this message translates to:
  /// **'Search, filters, access level'**
  String get admNavUsersHint;

  /// Admin section.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get admNavAudit;

  /// Admin section hint.
  ///
  /// In en, this message translates to:
  /// **'Every admin action, without message text'**
  String get admNavAuditHint;

  /// Admin section.
  ///
  /// In en, this message translates to:
  /// **'Publication moderation'**
  String get admNavModeration;

  /// Admin section hint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Queue is empty} other{{count} in the queue}}'**
  String admNavModerationHint(int count);

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get admOverview;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get admStatUsers;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'New today'**
  String get admStatNewToday;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'New in 7 days'**
  String get admStatNew7d;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'New in 30 days'**
  String get admStatNew30d;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'Active in 7 days'**
  String get admStatActive7d;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'Active in 30 days'**
  String get admStatActive30d;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'Pro (server grants)'**
  String get admStatPro;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get admStatFree;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'Requests awaiting reply'**
  String get admStatAwaiting;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'Articles awaiting moderation'**
  String get admStatPublications;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'AI questions (all time)'**
  String get admStatAiTotal;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'AI questions in 7 days'**
  String get admStatAi7d;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'Professional profiles'**
  String get admStatProfiles;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'Verified professionals'**
  String get admStatVerified;

  /// Explains missing student/expert split.
  ///
  /// In en, this message translates to:
  /// **'Students vs experts: not available — the usage mode is a device setting and is not stored on the server. Professional profiles and verified professionals are shown instead.'**
  String get admModesNote;

  /// Definition of active users.
  ///
  /// In en, this message translates to:
  /// **'Active = signed in, opened the app (device check-in) or asked the AI within the window.'**
  String get admActiveNote;

  /// Definition of Pro count.
  ///
  /// In en, this message translates to:
  /// **'Pro counts server grants only; store purchases are verified on the device.'**
  String get admProNote;

  /// Chart title.
  ///
  /// In en, this message translates to:
  /// **'Last 14 days: sign-ups and AI questions'**
  String get admChart14d;

  /// Chart legend.
  ///
  /// In en, this message translates to:
  /// **'Sign-ups'**
  String get admChartSignups;

  /// Chart legend.
  ///
  /// In en, this message translates to:
  /// **'AI questions'**
  String get admChartAi;

  /// Chart title.
  ///
  /// In en, this message translates to:
  /// **'Requests by category'**
  String get admByCategory;

  /// Stats failed.
  ///
  /// In en, this message translates to:
  /// **'Statistics are unavailable right now.'**
  String get admStatsUnavailable;

  /// Not-authorized page title.
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get admNotAuthorizedTitle;

  /// Not-authorized page body.
  ///
  /// In en, this message translates to:
  /// **'This section is for administrators only. Access is checked on the server.'**
  String get admNotAuthorized;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Back to Profile'**
  String get admBackToProfile;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get admFilterAll;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'Awaiting reply'**
  String get admFilterAwaiting;

  /// Dropdown.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get admAllCategories;

  /// Search hint.
  ///
  /// In en, this message translates to:
  /// **'Subject or email'**
  String get admInboxSearch;

  /// Empty inbox.
  ///
  /// In en, this message translates to:
  /// **'No requests match the filter.'**
  String get admInboxEmpty;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get admLoadMore;

  /// Pagination info.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total}'**
  String admShown(int shown, int total);

  /// Action / field label.
  ///
  /// In en, this message translates to:
  /// **'Write a reply'**
  String get admReply;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Send reply'**
  String get admReplySend;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Reply sent. The user will see it in the app.'**
  String get admReplySent;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get admSetStatus;

  /// Result.
  ///
  /// In en, this message translates to:
  /// **'Status updated.'**
  String get admStatusChanged;

  /// Thread meta.
  ///
  /// In en, this message translates to:
  /// **'From: {email}'**
  String admAuthor(String email);

  /// Inbox badge semantic label.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new message} other{{count} new messages}}'**
  String admUnread(int count);

  /// Search hint.
  ///
  /// In en, this message translates to:
  /// **'Email or name'**
  String get admUsersSearch;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'Any role'**
  String get admRoleAny;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admRoleAdmin;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'Moderators'**
  String get admRoleModerator;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'Any plan'**
  String get admTierAny;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get admTierFree;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'Pro plan'**
  String get admTierPro;

  /// Empty list.
  ///
  /// In en, this message translates to:
  /// **'No users match the filter.'**
  String get admUsersEmpty;

  /// User meta.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String admUserJoined(String date);

  /// User meta.
  ///
  /// In en, this message translates to:
  /// **'Last activity {date}'**
  String admUserLastActive(String date);

  /// User meta.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded'**
  String get admUserNoActivity;

  /// Account status.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get admUserActive;

  /// Account status.
  ///
  /// In en, this message translates to:
  /// **'Email not confirmed'**
  String get admUserUnconfirmed;

  /// Account status.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get admUserBanned;

  /// Pagination.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get admPrev;

  /// Pagination.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get admNext;

  /// Empty audit log.
  ///
  /// In en, this message translates to:
  /// **'No admin actions yet.'**
  String get admAuditEmpty;

  /// Actor unknown (SQL console).
  ///
  /// In en, this message translates to:
  /// **'system / console'**
  String get admAuditSystem;

  /// Audit action.
  ///
  /// In en, this message translates to:
  /// **'Replied to a request'**
  String get admActSupportReply;

  /// Audit action.
  ///
  /// In en, this message translates to:
  /// **'Request status changed'**
  String get admActSupportStatus;

  /// Audit action.
  ///
  /// In en, this message translates to:
  /// **'Opened a request'**
  String get admActSupportView;

  /// Audit action.
  ///
  /// In en, this message translates to:
  /// **'Viewed the users list'**
  String get admActUsersView;

  /// Audit action.
  ///
  /// In en, this message translates to:
  /// **'Access level changed'**
  String get admActAccessSet;

  /// Audit action.
  ///
  /// In en, this message translates to:
  /// **'Role granted'**
  String get admActRoleGranted;

  /// Audit action.
  ///
  /// In en, this message translates to:
  /// **'Role revoked'**
  String get admActRoleRevoked;

  /// Audit action.
  ///
  /// In en, this message translates to:
  /// **'Role changed'**
  String get admActRoleChanged;

  /// Audit action fallback.
  ///
  /// In en, this message translates to:
  /// **'Admin action'**
  String get admActOther;

  /// Action.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get admRetry;

  /// Attribution of a computed structure image (PubChem SMILES rendered with RDKit).
  ///
  /// In en, this message translates to:
  /// **'Structure drawn from PubChem CID {cid} SMILES with RDKit'**
  String imageAttrPubchemRdkit(String cid);

  /// Attribution of an original schematic drawn by the app team.
  ///
  /// In en, this message translates to:
  /// **'Original schematic — FORENSIC EXPERT'**
  String get imageAttrOriginalSchematic;

  /// Fallback when the related record is not in this content pack.
  ///
  /// In en, this message translates to:
  /// **'record in the content pack'**
  String get supRelatedUnknown;

  /// Onboarding progress label.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onbStep(int current, int total);

  /// Onboarding disclaimer headline.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get disclaimerIntroTitle;

  /// Disclaimer summary point.
  ///
  /// In en, this message translates to:
  /// **'A scientific reference and learning tool — it never issues expert conclusions.'**
  String get disclaimerPointReference;

  /// Disclaimer summary point.
  ///
  /// In en, this message translates to:
  /// **'It does not replace validated lab methods, protocols, the law or a specialist’s judgement.'**
  String get disclaimerPointLab;

  /// Disclaimer summary point.
  ///
  /// In en, this message translates to:
  /// **'For medical questions, consult a qualified doctor.'**
  String get disclaimerPointMedical;

  /// Expandable full disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Full text'**
  String get disclaimerFullText;

  /// Last onboarding step title.
  ///
  /// In en, this message translates to:
  /// **'You’re all set'**
  String get accountReadyTitle;

  /// Last onboarding step body.
  ///
  /// In en, this message translates to:
  /// **'The scientific database, search and calculators work offline — no account needed.'**
  String get accountReadyBody;

  /// Primary button: open the app without an account.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get accountStartNow;

  /// What an account adds (one line).
  ///
  /// In en, this message translates to:
  /// **'An account adds professional verification, sync and cloud AI. You can sign in any time in Profile.'**
  String get accountBenefitsNote;

  /// Home headline, student mode.
  ///
  /// In en, this message translates to:
  /// **'What shall we study today?'**
  String get homeGreetingStudent;

  /// Home headline, professional mode.
  ///
  /// In en, this message translates to:
  /// **'What are you working on today?'**
  String get homeGreetingExpert;

  /// Home section: subject areas.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get homeAreasTitle;

  /// Quick action.
  ///
  /// In en, this message translates to:
  /// **'Study & quizzes'**
  String get homeActLearnTitle;

  /// Quick action hint.
  ///
  /// In en, this message translates to:
  /// **'Flashcards, quizzes, exam practice'**
  String get homeActLearnBody;

  /// Quick action hint.
  ///
  /// In en, this message translates to:
  /// **'Practical guidance by discipline'**
  String get homeActGuidelinesBody;

  /// Quick action hint.
  ///
  /// In en, this message translates to:
  /// **'Properties, analysis, sources'**
  String get homeActSubstancesBody;

  /// Quick action hint.
  ///
  /// In en, this message translates to:
  /// **'Analytical methods, sample prep'**
  String get homeActMethodsBody;

  /// Quick action.
  ///
  /// In en, this message translates to:
  /// **'Calculators'**
  String get homeActToolsTitle;

  /// Quick action hint.
  ///
  /// In en, this message translates to:
  /// **'Lab and forensic calculations'**
  String get homeActToolsBody;

  /// Quick action hint.
  ///
  /// In en, this message translates to:
  /// **'Ask a question — answers cite sources'**
  String get homeActAiBody;

  /// Calm one-line honesty note at the bottom of Home.
  ///
  /// In en, this message translates to:
  /// **'Database under expert review · every entry shows its source and status'**
  String get homeTrustNote;

  /// Signed-out account card hint.
  ///
  /// In en, this message translates to:
  /// **'Sync, verification and cloud AI. No password needed.'**
  String get profileSignInBody;

  /// Profile section.
  ///
  /// In en, this message translates to:
  /// **'Help and community'**
  String get profileSectionHelp;

  /// Profile section.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileSectionAppearance;

  /// Card hint: number of disciplines.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} discipline} other{{count} disciplines}}'**
  String homeAllDisciplinesCount(int count);

  /// Button: copy the calculation result as text.
  ///
  /// In en, this message translates to:
  /// **'Copy result'**
  String get calcCopyResult;

  /// Snackbar after copying a result.
  ///
  /// In en, this message translates to:
  /// **'Result copied with inputs, formula and method version.'**
  String get calcCopied;

  /// Heading inside the copied text.
  ///
  /// In en, this message translates to:
  /// **'Inputs'**
  String get calcCopyInputs;

  /// Validation: a required field is empty.
  ///
  /// In en, this message translates to:
  /// **'Fill in all required fields.'**
  String get calcErrorRequired;

  /// Headline row: estimated min–max range.
  ///
  /// In en, this message translates to:
  /// **'Estimated range'**
  String get calcEstimatedRange;

  /// Locked calculator card title.
  ///
  /// In en, this message translates to:
  /// **'Included in Expert Pro'**
  String get calcLockedTitle;

  /// Locked calculator card body.
  ///
  /// In en, this message translates to:
  /// **'This calculator opens with the Expert Pro plan. Dilution and the concentration unit converter are free.'**
  String get calcLockedBody;

  /// Note under LOD/LOQ result.
  ///
  /// In en, this message translates to:
  /// **'DL and QL are in the concentration units of the calibration x axis.'**
  String get calcLodUnitNote;

  /// Caption: which Henssge equation is applied.
  ///
  /// In en, this message translates to:
  /// **'Applied: ambient ≤ 23 °C'**
  String get calcHenssgeFormulaLow;

  /// Caption: which Henssge equation is applied.
  ///
  /// In en, this message translates to:
  /// **'Applied: ambient > 23 °C'**
  String get calcHenssgeFormulaHigh;

  /// Role name of a publication moderator (admin users list, audit log).
  ///
  /// In en, this message translates to:
  /// **'Publication moderator'**
  String get admRolePublicationModerator;

  /// Substance page: compact summary card title.
  ///
  /// In en, this message translates to:
  /// **'At a glance'**
  String get rdGlanceTitle;

  /// Substance page: summary card note (no new facts; built from the sections below).
  ///
  /// In en, this message translates to:
  /// **'From the sourced sections below. Quotes and status are inside each section.'**
  String get rdGlanceNote;

  /// Summary row: molecular formula and weight.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get rdGlanceFormula;

  /// Summary row: molecular weight value from the identity record (PubChem), with unit.
  ///
  /// In en, this message translates to:
  /// **'{value} g/mol'**
  String rdGlanceMolarMass(String value);

  /// Summary row: specimens with sourced values.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get rdGlanceSpecimens;

  /// Summary row: analytical methods named in sources.
  ///
  /// In en, this message translates to:
  /// **'Methods'**
  String get rdGlanceMethods;

  /// Summary row: metabolites.
  ///
  /// In en, this message translates to:
  /// **'Metabolites'**
  String get rdGlanceMetabolites;

  /// Summary row: reported concentrations (count).
  ///
  /// In en, this message translates to:
  /// **'Concentrations'**
  String get rdGlanceConcentrations;

  /// Summary row: sources (count).
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get rdGlanceSources;

  /// Count of sourced records.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sourced record} other{{count} sourced records}}'**
  String rdGlanceRecords(int count);

  /// Count of sources / references.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 source} other{{count} sources}}'**
  String rdSourcesCount(int count);

  /// Suffix after a shortened list of names.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String rdGlanceMore(int count);

  /// Summary card when details are locked: what is behind Pro (counts only).
  ///
  /// In en, this message translates to:
  /// **'Details below open with Pro. Names, warnings and sources stay free.'**
  String get rdGlanceLockedHint;

  /// Semantics hint: tap to jump to a section on this page.
  ///
  /// In en, this message translates to:
  /// **'Go to section'**
  String get rdJumpTo;

  /// Guideline list row: number of sections and references.
  ///
  /// In en, this message translates to:
  /// **'{sections} sections · {refs}'**
  String rdGuidelineMeta(int sections, String refs);

  /// Tool name: Beer–Lambert calculator.
  ///
  /// In en, this message translates to:
  /// **'Beer–Lambert law (A = ε·l·c)'**
  String get toolBeerLambertName;

  /// Tool description: Beer–Lambert calculator.
  ///
  /// In en, this message translates to:
  /// **'Find absorbance, concentration or absorptivity from A = ε·l·c, on a molar or mass basis, with units.'**
  String get toolBeerLambertDesc;

  /// Field/result label: absorbance A.
  ///
  /// In en, this message translates to:
  /// **'Absorbance'**
  String get calcBeerAbsorbance;

  /// Field/result label: molar absorptivity ε.
  ///
  /// In en, this message translates to:
  /// **'Molar absorptivity'**
  String get calcBeerAbsorptivityMolar;

  /// Field/result label: specific (mass) absorptivity a.
  ///
  /// In en, this message translates to:
  /// **'Specific (mass) absorptivity'**
  String get calcBeerAbsorptivityMass;

  /// Field/result label: concentration c.
  ///
  /// In en, this message translates to:
  /// **'Concentration'**
  String get calcBeerConcentration;

  /// Field label: optical path length l.
  ///
  /// In en, this message translates to:
  /// **'Path length (l)'**
  String get calcBeerPath;

  /// Dropdown label: unit of the calculated concentration.
  ///
  /// In en, this message translates to:
  /// **'Result unit (c)'**
  String get calcBeerResultUnit;

  /// Label above the basis choice (molar or mass).
  ///
  /// In en, this message translates to:
  /// **'Absorptivity basis'**
  String get calcBeerBasis;

  /// Choice: molar basis.
  ///
  /// In en, this message translates to:
  /// **'Molar (ε, mol/L)'**
  String get calcBeerBasisMolar;

  /// Choice: mass basis.
  ///
  /// In en, this message translates to:
  /// **'Mass (a, g/L)'**
  String get calcBeerBasisMass;

  /// Note under the formula: symbols and units.
  ///
  /// In en, this message translates to:
  /// **'A — absorbance (dimensionless); ε — molar absorptivity, L·mol⁻¹·cm⁻¹ (or a — mass absorptivity, L·g⁻¹·cm⁻¹); l — path length, cm; c — concentration, mol/L (or g/L).'**
  String get calcBeerFormulaNote;

  /// Validation: concentration unit does not match the basis.
  ///
  /// In en, this message translates to:
  /// **'The concentration unit does not match the absorptivity basis: use mol/L units with molar ε and g/L-type units with mass a.'**
  String get calcBeerErrorBasis;

  /// Assumption bullet.
  ///
  /// In en, this message translates to:
  /// **'Definitional relationship: absorbance is proportional to path length and concentration. No absorptivity values are built in — enter a value from your own calibration or a verified source for the same wavelength, solvent and pH.'**
  String get calcBeerAssumptionDefinition;

  /// Assumption bullet.
  ///
  /// In en, this message translates to:
  /// **'A is the sample absorbance corrected for the blank (reagent or matrix blank) at the chosen wavelength.'**
  String get calcBeerAssumptionBlank;

  /// Limitation bullet.
  ///
  /// In en, this message translates to:
  /// **'Valid only within the working range where linearity has been shown by calibration; ICH Q2(R2) §3.2.2.1 recommends at least five concentrations across the range. Outside it, dilute the sample or use the calibration curve.'**
  String get calcBeerLimitationLinear;

  /// Limitation bullet.
  ///
  /// In en, this message translates to:
  /// **'Absorbance does not identify a substance. UV-Vis has low specificity; identity must be confirmed by another technique (for example, chromatography with mass spectrometry).'**
  String get calcBeerLimitationIdentity;

  /// Reference bullet for the Beer–Lambert calculator.
  ///
  /// In en, this message translates to:
  /// **'IUPAC Gold Book: “Beer–Lambert law”, doi:10.1351/goldbook.B00626 · Swinehart DF. The Beer-Lambert law. J Chem Educ 1962;39(7):333, doi:10.1021/ed039p333 · Linearity: ICH Q2(R2) (2023), §3.2.2.1.'**
  String get calcBeerReference;

  /// Section header: links to calibration and LOD/LOQ tools.
  ///
  /// In en, this message translates to:
  /// **'Related tools: calibration and limits'**
  String get calcBeerRelatedTools;

  /// Action on a source/reference: open the sheet to copy a formatted bibliographic citation.
  ///
  /// In en, this message translates to:
  /// **'Copy citation'**
  String get citeCopy;

  /// Page action (substance/guideline): copy a numbered list of all sources on this page.
  ///
  /// In en, this message translates to:
  /// **'Copy reference list'**
  String get citeAllSources;

  /// Citation sheet title for the page-level reference list.
  ///
  /// In en, this message translates to:
  /// **'Reference list · {count}'**
  String citeListTitle(int count);

  /// Citation sheet: label above the style selector.
  ///
  /// In en, this message translates to:
  /// **'Citation style'**
  String get citeStyleLabel;

  /// Citation style name: GOST R 7.0.100-2018.
  ///
  /// In en, this message translates to:
  /// **'GOST'**
  String get citeStyleGost;

  /// Citation style name: Vancouver.
  ///
  /// In en, this message translates to:
  /// **'Vancouver'**
  String get citeStyleVancouver;

  /// Citation style name: APA 7th edition.
  ///
  /// In en, this message translates to:
  /// **'APA 7'**
  String get citeStyleApa;

  /// Citation sheet: copy button.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get citeCopyButton;

  /// Snackbar after copying one citation.
  ///
  /// In en, this message translates to:
  /// **'Citation copied'**
  String get citeCopied;

  /// Snackbar after copying the reference list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reference copied} other{{count} references copied}}'**
  String citeListCopied(int count);

  /// One-line note under citations: the app is a reference tool; the expert must verify sources.
  ///
  /// In en, this message translates to:
  /// **'The app is a reference tool: verify each source against the original before citing it in an expert conclusion.'**
  String get citeVerifyNote;

  /// Attribution line on guideline cards based on Prof. Yuldashev's teaching materials.
  ///
  /// In en, this message translates to:
  /// **'Source: Prof. Yuldashev Z.A. and co-authors, «Toxicological chemistry» teaching complexes (Tashkent Pharmaceutical Institute, 2025) — used with the author’s permission, free for everyone.'**
  String get guidelineToksAttribution;

  /// Study hub section for decks built from teaching complexes.
  ///
  /// In en, this message translates to:
  /// **'Teaching complexes'**
  String get studySectionTeaching;

  /// Deck title: questions based on the toxicological chemistry teaching complex.
  ///
  /// In en, this message translates to:
  /// **'Toxicological chemistry (Yuldashev Z.A.)'**
  String get studyDeckToks;

  /// Flashcard front hint for a question card.
  ///
  /// In en, this message translates to:
  /// **'Recall the answer, then flip the card'**
  String get studyFrontQuestion;

  /// Quiz banner for decks with written answer options.
  ///
  /// In en, this message translates to:
  /// **'Questions and wrong options were written independently from the facts in the guideline cards; the correct answer and its page are given in the cited source.'**
  String get studyQuizNoteAuthored;

  /// Page numbers in the cited source.
  ///
  /// In en, this message translates to:
  /// **'pp. {pages}'**
  String studySourcePages(String pages);
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
