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
  /// **'Institutional SOPs'**
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
  /// **'Postmortem interval'**
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
  /// **'Professional'**
  String get aiExperienceProfessional;

  /// AI experience toggle.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
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
  /// **'Bookmarks'**
  String get learnBookmarks;

  /// No bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmark a topic with the star to find it here.'**
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

  /// Knowledge graph section.
  ///
  /// In en, this message translates to:
  /// **'Related professional content'**
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

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Values (separated by spaces, commas or new lines)'**
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

  /// Calculator input.
  ///
  /// In en, this message translates to:
  /// **'Calibration points (one “x y” pair per line)'**
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
  /// **'20 disciplines — scope and currently available content'**
  String get homeAllDisciplinesBody;

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

  /// Screen intro.
  ///
  /// In en, this message translates to:
  /// **'The platform architecture covers these disciplines. Content is added gradually and only with sources and expert review — an empty discipline means “not yet sourced”, not “no knowledge exists”.'**
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

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Jurisdictions with pilot content'**
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

  /// Coverage label.
  ///
  /// In en, this message translates to:
  /// **'Pilot content — needs review'**
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
  /// **'NOT VERIFIED — EXPERT CONFIRMATION REQUIRED'**
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

  /// Note.
  ///
  /// In en, this message translates to:
  /// **'Context for this record has not been curated yet; only the specimen is shown.'**
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
  /// **'Generated by a TEST provider — not a production AI service.'**
  String get aiLimMock;
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
