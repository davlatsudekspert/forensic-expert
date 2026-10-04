// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FORENSIC EXPERT';

  @override
  String get appTagline => 'Evidence · Science · Precision';

  @override
  String get languageNameNative => 'English';

  @override
  String get chooseLanguageTitle => 'Choose your language';

  @override
  String languageOptionSemantics(String language, String state) {
    return '$language. $state';
  }

  @override
  String get stateSelected => 'Selected';

  @override
  String get stateNotSelected => 'Not selected';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionBack => 'Back';

  @override
  String get disclaimerTitle => 'Scientific disclaimer';

  @override
  String get disclaimerBody =>
      'Forensic Expert is intended for professional reference, education and scientific calculation. It does not replace validated laboratory procedures, institutional protocols, applicable law or qualified professional judgment.';

  @override
  String get disclaimerNoConclusions =>
      'The app never issues forensic expert conclusions. A measured concentration alone does not establish a cause of death. Final professional judgment belongs to a qualified specialist.';

  @override
  String get disclaimerConsult =>
      'For medical advice, diagnosis or treatment, consult a qualified healthcare professional.';

  @override
  String get disclaimerAccept => 'I understand';

  @override
  String get modeTitle => 'How will you use Forensic Expert?';

  @override
  String get modeSubtitle =>
      'This adapts your dashboard. You can change it later in Profile.';

  @override
  String get modeProfessional => 'Professional';

  @override
  String get modeProfessionalDescription =>
      'Forensic medical and toxicology experts, laboratory specialists';

  @override
  String get modeStudent => 'Student / Resident';

  @override
  String get modeStudentDescription =>
      'Courses, glossary, flashcards and practice';

  @override
  String get modeResearch => 'Research / Education';

  @override
  String get modeResearchDescription =>
      'Scientific library, references and teaching';

  @override
  String get navHome => 'Home';

  @override
  String get navTools => 'Tools';

  @override
  String get navLibrary => 'Library';

  @override
  String get navAi => 'AI';

  @override
  String get navProfile => 'Profile';

  @override
  String get searchHint => 'Search substances, methods, tools, references…';

  @override
  String get searchUnavailable =>
      'Search will become available when the verified scientific database is installed.';

  @override
  String get moduleForensicMedicine => 'Forensic Medicine';

  @override
  String get moduleToxicology => 'Forensic Toxicology';

  @override
  String get moduleLaboratory => 'Laboratory';

  @override
  String get moduleSubstances => 'Substance Library';

  @override
  String get moduleLearn => 'Learn';

  @override
  String get moduleAi => 'Forensic AI';

  @override
  String get homeModulesHeading => 'Modules';

  @override
  String get inDevelopmentTitle => 'In development';

  @override
  String get inDevelopmentBody =>
      'This section will be available in a later development phase. No scientific content is shown until it has passed expert review.';

  @override
  String get unverifiedBanner =>
      'UNVERIFIED DATA — EXPERT CONFIRMATION REQUIRED';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusReviewed => 'Reviewed';

  @override
  String get statusNeedsReview => 'Needs review';

  @override
  String get statusOutdated => 'Outdated';

  @override
  String get aiNotConnectedTitle => 'Forensic AI is not connected yet';

  @override
  String get aiNotConnectedBody =>
      'Forensic AI will answer only from the reviewed internal knowledge base, always show its sources and never issue expert conclusions. The core library and calculators work without AI.';

  @override
  String get aiPiiWarning =>
      'Do not enter names, case numbers, passport data, phone numbers, addresses or other personal information.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsMode => 'Usage mode';

  @override
  String get scientificDatabaseLabel => 'Scientific database';

  @override
  String get scientificDatabaseNotInstalled => 'Not installed yet';

  @override
  String get appVersionLabel => 'App version';

  @override
  String get legalSection => 'Legal';

  @override
  String get scientificDisclaimerLink => 'Scientific disclaimer';

  @override
  String get diagnosticsSection => 'Diagnostics';

  @override
  String diagnosticsStartup(int ms) {
    return 'Time to first frame: $ms ms';
  }

  @override
  String diagnosticsSettingsLoad(int ms) {
    return 'Settings load: $ms ms';
  }

  @override
  String get diagnosticsNotMeasured => 'Not measured';

  @override
  String get toolsTitle => 'Tools';

  @override
  String get libraryTitle => 'Library';

  @override
  String get homeQuickAccess => 'Quick access';

  @override
  String get homeRecentTools => 'Recent tools';

  @override
  String get homeFavorites => 'Favorites';

  @override
  String get homeRecentSearches => 'Recent searches';

  @override
  String get homeEmptyRecentTools => 'Tools you open will appear here.';

  @override
  String get homeEmptyFavorites =>
      'Add tools or library entries to favorites to keep them here.';

  @override
  String get homeEmptyRecentSearches =>
      'Your searches are stored only on this device.';

  @override
  String get homeContinueLearning => 'Continue learning';

  @override
  String get homeStudyHubBody =>
      'Courses, quizzes, flashcards and case studies.';

  @override
  String get homePrototypeNotice =>
      'Prototype build: entries marked TEST DATA are placeholders, not scientific content.';

  @override
  String get testDataBadge => 'TEST DATA';

  @override
  String get seeAll => 'See all';

  @override
  String get openAction => 'Open';

  @override
  String get toolsSubtitle =>
      'Calculators and conversions with formula, assumptions and limitations.';

  @override
  String get toolCategoryToxicology => 'Toxicology';

  @override
  String get toolCategoryConversions => 'Conversions';

  @override
  String get toolDilutionName => 'Dilution (C₁V₁ = C₂V₂)';

  @override
  String get toolDilutionDesc =>
      'Solve for any one of the four values of a dilution.';

  @override
  String get toolWidmarkName => 'Blood alcohol (Widmark)';

  @override
  String get toolWidmarkDesc =>
      'Estimate with stated assumptions, uncertainty and limitations.';

  @override
  String get toolBackCalcName => 'Ethanol back-calculation';

  @override
  String get toolBackCalcDesc =>
      'Range-based estimate for an earlier point in time.';

  @override
  String get toolPmiName => 'Time since death (Henssge)';

  @override
  String get toolPmiDesc =>
      'Planned for V1.1 after scientific and licensing review.';

  @override
  String get toolMolarityName => 'Molarity and mass concentration';

  @override
  String get toolMolarityDesc =>
      'Convert between mass and molar concentration.';

  @override
  String get toolCalibrationName => 'Calibration and linear regression';

  @override
  String get toolCalibrationDesc =>
      'Calibration curve, residuals and fit statistics.';

  @override
  String get toolLodName => 'LOD / LOQ';

  @override
  String get toolLodDesc =>
      'Limits of detection and quantitation from calibration data.';

  @override
  String get toolStatsName => 'Descriptive statistics';

  @override
  String get toolStatsDesc => 'Mean, median, SD and CV.';

  @override
  String get toolUnitsName => 'Concentration unit converter';

  @override
  String get toolUnitsDesc => 'mg/L, µg/mL, ng/mL, mmol/L and more.';

  @override
  String get toolEthanolUnitsName => 'Ethanol unit converter';

  @override
  String get toolEthanolUnitsDesc => 'g/L, ‰, mg/dL and g/100 mL.';

  @override
  String get toolStatusAvailable => 'Available';

  @override
  String get toolStatusPlanned => 'Planned';

  @override
  String get toolPlannedBody =>
      'This tool is planned. It will be added only after its method, formula and sources pass expert review.';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String get calcInput => 'Input';

  @override
  String get calcMethod => 'Method';

  @override
  String get calcFormula => 'Formula';

  @override
  String get calcResult => 'Result';

  @override
  String get calcAssumptions => 'Assumptions';

  @override
  String get calcLimitations => 'Limitations';

  @override
  String get calcReferences => 'References';

  @override
  String get calcSolveFor => 'Solve for';

  @override
  String get calcStockConc => 'Stock concentration (C₁)';

  @override
  String get calcStockVol => 'Stock volume (V₁)';

  @override
  String get calcFinalConc => 'Final concentration (C₂)';

  @override
  String get calcFinalVol => 'Final volume (V₂)';

  @override
  String get calcUnit => 'Unit';

  @override
  String get calcCalculate => 'Calculate';

  @override
  String get calcEnterValues => 'Enter three values to calculate the fourth.';

  @override
  String get calcErrorPositive => 'Enter a positive number.';

  @override
  String get calcErrorUnits =>
      'Both concentrations must use compatible units (mass or molar).';

  @override
  String get calcWarnExceeds =>
      'The final concentration is higher than the stock — check the input.';

  @override
  String get calcDilutionAssumptionConservation =>
      'The amount of substance is conserved during dilution.';

  @override
  String get calcDilutionAssumptionMixing =>
      'Volumes are additive and mixing is complete.';

  @override
  String get calcDilutionLimitationContraction =>
      'Not suitable where volume contraction on mixing is significant (for example, concentrated ethanol and water).';

  @override
  String get calcDefinitional =>
      'Definitional relationship (conservation of the amount of substance); no literature values are used.';

  @override
  String get calcNeedsReviewNotice =>
      'This calculator has not yet been reviewed by a laboratory reviewer.';

  @override
  String calcResultSemantics(String value) {
    return 'Result: $value';
  }

  @override
  String get librarySubstances => 'Substances';

  @override
  String get libraryMethods => 'Analytical methods';

  @override
  String get librarySpecimens => 'Specimens';

  @override
  String get libraryReferences => 'References';

  @override
  String get libraryGlossary => 'Glossary';

  @override
  String get libraryFilterHint => 'Filter this section…';

  @override
  String get filterAll => 'All';

  @override
  String get libraryEmptyFiltered => 'No entries match the filter.';

  @override
  String get detailNames => 'Names and synonyms';

  @override
  String get detailClass => 'Class';

  @override
  String get detailMetabolites => 'Metabolites';

  @override
  String get detailSpecimens => 'Specimens';

  @override
  String get detailMethods => 'Analytical methods';

  @override
  String get detailConcentrations => 'Reference concentrations';

  @override
  String get detailInterpretation => 'Interpretation';

  @override
  String get detailStability => 'Stability and storage';

  @override
  String get detailInterferences => 'Interferences';

  @override
  String get detailReferences => 'References';

  @override
  String get detailEvidenceStatus => 'Evidence status';

  @override
  String get detailLastReviewed => 'Last reviewed';

  @override
  String get detailNotReviewed => 'Not reviewed';

  @override
  String get detailPlaceholder => 'Placeholder — no scientific content yet.';

  @override
  String get detailConcentrationsNote =>
      'A concentration alone does not establish a cause of death. Values will be shown only with matrix, population and sources.';

  @override
  String get sourcesButton => 'Sources';

  @override
  String get sourcesNone => 'No sources — this entry is test data.';

  @override
  String get searchGroupTools => 'Tools';

  @override
  String get searchGroupLearning => 'Learning';

  @override
  String get searchClearHistory => 'Clear history';

  @override
  String get searchClearQuery => 'Clear';

  @override
  String searchNoResultsTitle(String query) {
    return 'No results for “$query”';
  }

  @override
  String get searchNoResultsBody =>
      'Check the spelling or try another language — English, Russian and Uzbek names are supported.';

  @override
  String get searchOfflineLabel => 'On this device · offline';

  @override
  String get searchExternalTitle => 'Scientific databases (online)';

  @override
  String get searchExternalBody =>
      'PubMed, PubChem and Crossref search will be added in a later version. External results are never mixed with reviewed internal data.';

  @override
  String get searchTypeToStart => 'Type at least two characters.';

  @override
  String searchResultsSemantics(int count) {
    return '$count results';
  }

  @override
  String get aiAskTitle => 'Ask Forensic AI';

  @override
  String get aiInputHint =>
      'Ask about substances, methods or limits of interpretation…';

  @override
  String get aiSend => 'Send';

  @override
  String aiPiiDetected(String kinds) {
    return 'Possible personal data detected: $kinds. Remove it before sending.';
  }

  @override
  String get piiKindEmail => 'email';

  @override
  String get piiKindPhone => 'phone number';

  @override
  String get piiKindPassport => 'passport/ID number';

  @override
  String get piiKindCase => 'case number';

  @override
  String get piiKindName => 'full name';

  @override
  String get piiKindAddress => 'address';

  @override
  String get aiPreviewTitle => 'Answer layout preview';

  @override
  String get aiPreviewNotice =>
      'UI prototype. The sample below is placeholder text — not AI output and not scientific content.';

  @override
  String get aiSectionAvailable => 'Available information';

  @override
  String get aiSectionConsiderations => 'Differential considerations';

  @override
  String get aiSectionLimitations => 'Limitations of interpretation';

  @override
  String get aiSampleInternal =>
      'Placeholder statement supported by a reviewed internal source.';

  @override
  String get aiSampleExternal =>
      'Placeholder statement from an external source that has not been reviewed.';

  @override
  String get aiSampleLimitation =>
      'Placeholder limitation — a final interpretation requires the full case context.';

  @override
  String get aiEvidenceInternalVerified => 'Internal · verified';

  @override
  String get aiEvidenceInternalReviewed => 'Internal · reviewed';

  @override
  String get aiEvidenceExternal => 'External · not reviewed';

  @override
  String aiPlaceholderSource(int number) {
    return 'Placeholder source $number';
  }

  @override
  String aiCitationSemantics(int number) {
    return 'Source $number';
  }

  @override
  String get aiExpertJudgment =>
      'Final professional judgment belongs to a qualified specialist. Forensic AI does not issue expert conclusions.';

  @override
  String get aiReport => 'Report this answer';

  @override
  String get learnCourses => 'Courses';

  @override
  String get learnLessons => 'Lessons';

  @override
  String get learnQuiz => 'Quiz';

  @override
  String get learnFlashcards => 'Flashcards';

  @override
  String get learnCases => 'Case studies';

  @override
  String get learnProgress => 'Progress';

  @override
  String get learnNotStarted => 'Not started';

  @override
  String get learnProgressEmpty =>
      'Progress is saved on this device once you start.';

  @override
  String learnLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$_temp0';
  }

  @override
  String get learnStart => 'Start';

  @override
  String get quizCheck => 'Check answer';

  @override
  String get quizCorrect => 'Correct';

  @override
  String get quizIncorrect => 'Incorrect';

  @override
  String get quizExplanation => 'Explanation';

  @override
  String get flashcardShowAnswer => 'Show answer';

  @override
  String get flashcardKnew => 'Knew it';

  @override
  String get flashcardAgain => 'Review again';

  @override
  String get profileSectionPreferences => 'Preferences';

  @override
  String get profileSectionAccount => 'Account and purchases';

  @override
  String get profileSectionAbout => 'About and legal';

  @override
  String get settingsContrast => 'Contrast';

  @override
  String get contrastStandard => 'Standard';

  @override
  String get contrastHigh => 'High';

  @override
  String get contrastSystemHint =>
      'System follows the device accessibility setting.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get aboutApp => 'About';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get accountNone => 'No account — the app works without signing in.';

  @override
  String get legalDraftNotice =>
      'Draft. This document will be published after professional legal review.';

  @override
  String get privacySummary =>
      'The core library and calculators work offline. Search history and progress stay on your device. The app contains no advertising SDKs. Personal or case data is never sent to AI automatically.';

  @override
  String get aboutBody =>
      'Professional forensic reference, education and scientific calculation software.';

  @override
  String get aboutVersions =>
      'The app version and the scientific database version are tracked separately.';

  @override
  String get storeNotConnected =>
      'The store is not connected in this build, so purchase is unavailable.';

  @override
  String get restorePurchases => 'Restore Purchase';

  @override
  String get restoreNothing => 'No purchases to restore.';

  @override
  String get subscriptionSafetyNote =>
      'Disclaimers, limitations and sources are never behind a paywall.';

  @override
  String get moduleHubTools => 'Tools in this section';

  @override
  String get moduleHubReference => 'Reference';

  @override
  String get settingsJurisdiction => 'Jurisdiction';

  @override
  String get jurisdictionPickerIntro =>
      'Scientific evidence is international and the same in every country. The jurisdiction only selects the legal and procedural layer (laws, controlled-substance schedules, national methods), which is always shown separately.';

  @override
  String get jurisdictionGroupGlobal => 'International and regional';

  @override
  String get jurisdictionGroupCountries => 'Countries';

  @override
  String get jurisdictionNoContent =>
      'No legal or procedural content has been loaded for this jurisdiction yet. Every future entry will show its official source, effective date, version and last verification date.';

  @override
  String get jurisdictionCompare => 'Compare jurisdictions';

  @override
  String get jurisdictionCompareSoon =>
      'Planned. Becomes available once verified legal content exists for at least two jurisdictions.';

  @override
  String get jurisdictionInternationalHint =>
      'International is selected: only international conventions and standards apply here. Choose a country to see its legal layer.';

  @override
  String get detailLayerScientific => 'International scientific evidence';

  @override
  String get detailLayerScientificNote =>
      'Not country-specific. Legal status and national procedures are shown separately below.';

  @override
  String detailLayerJurisdiction(String name) {
    return 'Jurisdiction layer: $name';
  }

  @override
  String get detailLegalStatus => 'Legal status';

  @override
  String get detailNationalMethods => 'National methods and procedures';

  @override
  String get detailChangeJurisdiction => 'Change jurisdiction';

  @override
  String get purchaseTitle => 'Lifetime Access';

  @override
  String get purchaseOneTime => 'One-time purchase';

  @override
  String purchasePriceLine(String price) {
    return '$price · One-time purchase';
  }

  @override
  String get purchaseReferencePriceNote =>
      'Reference price. The final price in your currency is shown by the App Store or Google Play.';

  @override
  String get purchaseValueReference => 'Professional forensic reference';

  @override
  String get purchaseValueTools => 'Scientific calculators & laboratory tools';

  @override
  String get purchaseValueSources => 'Verified sources & evidence status';

  @override
  String get purchaseValueOffline => 'Offline professional database';

  @override
  String get purchaseValueLearning => 'Learning & professional development';

  @override
  String get purchaseValueUpdates => 'Future scientific content updates';

  @override
  String get purchaseCta => 'Unlock FORENSIC EXPERT';

  @override
  String get purchaseFooter => 'One-time purchase · No recurring subscription';

  @override
  String get purchaseFreeTitle => 'Free version';

  @override
  String get purchaseFreeBody =>
      'Try before you buy: a search demo, selected reference entries, selected tools and demo lessons.';

  @override
  String get purchaseAiNote =>
      'Forensic AI is not included without limits: it has server costs. Any AI allowance will be stated clearly before purchase.';

  @override
  String get purchaseOwned => 'Lifetime access is active';

  @override
  String get purchaseUnavailableSnack =>
      'Purchases are not available in this build.';

  @override
  String get accessFree => 'Free version';

  @override
  String get accessLifetime => 'Lifetime';

  @override
  String get homePilotNotice =>
      'Pilot scientific database: every entry is awaiting expert review. Information is shown with its sources and is not a final conclusion.';

  @override
  String get detailIdentity => 'Identifiers';

  @override
  String get detailMolecularFormula => 'Molecular formula';

  @override
  String get detailMolecularWeight => 'Molecular weight (g/mol)';

  @override
  String get detailIupac => 'IUPAC name';

  @override
  String get detailBiomarker => 'Biomarker';

  @override
  String get detailTransformationProduct => 'Transformation product';

  @override
  String get detailMetabolismNote => 'Metabolism';

  @override
  String get detailExcerpt => 'Source excerpt';

  @override
  String get detailExcerptWithheld =>
      'The quotation is not shown because the source licence does not permit reuse. Open the source to read it.';

  @override
  String get detailProvenance => 'Provenance';

  @override
  String detailEvidenceLevel(String level) {
    return 'Evidence level $level';
  }

  @override
  String get detailReviewerStatus => 'Reviewer status';

  @override
  String get detailReviewsNone => 'No expert reviews yet (2 required)';

  @override
  String detailReviewsCount(int count) {
    return 'Expert reviews: $count';
  }

  @override
  String get detailVersion => 'Version';

  @override
  String detailVersionValue(int claim, String pack) {
    return 'Claim v$claim · database $pack';
  }

  @override
  String get detailTranslationDraft =>
      'Names: machine draft, translation not reviewed';

  @override
  String get detailNoContentYet => 'No sourced content for this section yet.';

  @override
  String detailSourceAccessed(String date) {
    return 'Accessed $date';
  }

  @override
  String get detailIdentifierVerified => 'Identifier checked automatically';

  @override
  String detailSourceLicence(String mode) {
    return 'Licence mode: $mode';
  }

  @override
  String legalSchedule(String convention, String schedules) {
    return '$convention: Schedule $schedules';
  }

  @override
  String get legalListRow => 'Row in the official list';

  @override
  String legalEffective(String date) {
    return 'Edition in force from $date';
  }

  @override
  String get legalDateYearOnly => '(source gives the year only)';

  @override
  String legalLastVerified(String date) {
    return 'Last verified $date';
  }

  @override
  String get legalInternationalLayer => 'International (UN conventions)';

  @override
  String get legalNotInListNote =>
      'Absence from these lists does not mean a substance is uncontrolled: national law may differ.';

  @override
  String legalNoNational(String name) {
    return 'No national legal content has been loaded for $name yet.';
  }

  @override
  String get lockedTitle => 'Included in FORENSIC EXPERT Lifetime';

  @override
  String get lockedBody =>
      'Names, warnings and sources stay open. Scientific details and the jurisdiction layer unlock with Lifetime Access.';

  @override
  String get freeDemoBadge => 'Free demo';

  @override
  String get lockedBadge => 'Lifetime';

  @override
  String searchMoreLocked(int count) {
    return '$count more results with Lifetime';
  }

  @override
  String get learnEmptyCourses =>
      'Courses will appear after expert review of the learning content.';

  @override
  String get contentLoading => 'Loading scientific database…';

  @override
  String get libraryNotInstalled =>
      'The scientific database is not installed in this build.';

  @override
  String get purchasePending =>
      'Purchase is waiting for confirmation from the store.';

  @override
  String get purchaseFailed => 'The purchase was not completed.';

  @override
  String get purchaseCancelled => 'Purchase cancelled.';

  @override
  String get purchaseSuccess => 'Lifetime access unlocked. Thank you!';

  @override
  String get aboutTrademarkPending =>
      'Name and logo: trademark clearance pending.';

  @override
  String get diagPurchaseNone => 'Purchase: none confirmed by the store';

  @override
  String get diagPurchaseStore =>
      'Purchase: confirmed by the store only — server verification not connected (release blocker)';

  @override
  String get diagPurchaseServer => 'Purchase: verified by the server';

  @override
  String get statusDraft => 'Draft';

  @override
  String get searchGroupTopics => 'Forensic medicine & biochemistry';

  @override
  String get searchGroupReagents => 'Reagents & solutions';

  @override
  String get searchGroupScreening => 'Screening tests';

  @override
  String get searchGroupStandardsLaws => 'Standards & laws';

  @override
  String get moduleBiochemistry => 'Biochemistry';

  @override
  String get moduleReagents => 'Reagents & solutions';

  @override
  String get moduleScreening => 'Screening & express tests';

  @override
  String get moduleMethods => 'Methods & SOP';

  @override
  String get moduleStandardsLaws => 'Standards & laws';

  @override
  String get moduleEmerging => 'Emerging issues';

  @override
  String get homeAreasHeading => 'Professional areas';

  @override
  String get homeDbTitle => 'Offline database';

  @override
  String homeDbPack(String version) {
    return 'Content pack $version';
  }

  @override
  String homeDbScientific(String version) {
    return 'Scientific data $version';
  }

  @override
  String homeDbJurisdiction(String version) {
    return 'Jurisdiction data $version';
  }

  @override
  String get homeDbOffline =>
      'Works offline. Searches and questions stay on this device.';

  @override
  String get homeDbNotInstalled => 'Content pack is not installed.';

  @override
  String get homeDbLoading => 'Opening the offline database…';

  @override
  String get knowledgeEmpty => 'No records in the installed content pack yet.';

  @override
  String get knowledgeNoSourcedContent => 'No sourced content yet';

  @override
  String get knowledgeStatements => 'Sourced statements';

  @override
  String get knowledgeSafety => 'Limitations & safety';

  @override
  String get knowledgeSources => 'Sources';

  @override
  String get knowledgeDetails => 'Details';

  @override
  String knowledgeSourceRef(String source) {
    return 'Source: $source';
  }

  @override
  String get knowledgeNotInSource =>
      'Not stated in the sources — not estimated';

  @override
  String get knowledgeTaxonomy => 'Topics';

  @override
  String knowledgeTopicCount(int count, int total) {
    return '$count of $total topics have sourced content';
  }

  @override
  String get reagentPreparation => 'Preparation';

  @override
  String get reagentNoRecipe =>
      'No verified preparation recipe was found in the sources. Ingredients, amounts, order of addition, storage and shelf life are not shown and are never estimated.';

  @override
  String get reagentIngredients => 'Ingredients';

  @override
  String get reagentFinalVolume => 'Final volume';

  @override
  String get reagentSteps => 'Steps';

  @override
  String get reagentOrderNotStated =>
      'The source does not state the order of addition — steps are listed without numbering.';

  @override
  String get reagentStorage => 'Storage';

  @override
  String get reagentTemperature => 'Temperature';

  @override
  String get reagentStability => 'Stability';

  @override
  String get reagentHazards => 'Hazards';

  @override
  String get reagentDisposal => 'Disposal';

  @override
  String get reagentQc => 'Quality control';

  @override
  String get reagentOpenCalculator => 'Solution preparation calculator';

  @override
  String get screeningBanner =>
      'SCREENING RESULT ≠ CONFIRMED IDENTIFICATION. A positive screen is presumptive and requires a validated confirmatory method.';

  @override
  String get screeningAnalyte => 'Analyte';

  @override
  String get screeningSpecimen => 'Specimen';

  @override
  String get screeningPrinciple => 'Principle';

  @override
  String get screeningCutoff => 'Cut-off';

  @override
  String get screeningSensitivity => 'Sensitivity';

  @override
  String get screeningSpecificity => 'Specificity';

  @override
  String get screeningCrossReactivity => 'Cross-reactivity';

  @override
  String get screeningFalsePositive => 'False positives';

  @override
  String get screeningFalseNegative => 'False negatives';

  @override
  String get screeningLimitations => 'Limitations';

  @override
  String get screeningConfirmatory => 'Confirmatory methods';

  @override
  String get methodKindScientific => 'Scientific methods';

  @override
  String get methodKindInternational => 'International standards';

  @override
  String get methodKindNational => 'National methods';

  @override
  String get methodKindSop => 'Institutional SOPs';

  @override
  String get methodKindNote =>
      'Method types are kept separate: a scientific method is not a legal requirement, and an institutional SOP applies only to its institution.';

  @override
  String get methodNoKindEntries => 'No records of this type yet.';

  @override
  String get methodOrganization => 'Organization';

  @override
  String get methodJurisdiction => 'Jurisdiction';

  @override
  String get methodTechniques => 'Techniques';

  @override
  String get methodDocumentVersion => 'Document version';

  @override
  String emergingDate(String date) {
    return 'Published $date';
  }

  @override
  String get emergingEvidenceType => 'Evidence type';

  @override
  String get emergingScopeGlobal => 'Scope: global';

  @override
  String get evidenceTypeOfficialAlert => 'Official alert';

  @override
  String get evidenceTypePeerReviewed => 'Peer-reviewed publication';

  @override
  String get evidenceTypeReport => 'Report';

  @override
  String get evidenceTypeStandard => 'Standard';

  @override
  String get emergingNote =>
      'Each item has a source, a date, an evidence type and a scope. This is not a news feed.';

  @override
  String get emergingCatNps => 'New psychoactive substances';

  @override
  String get emergingCatSyntheticOpioids => 'Synthetic opioids';

  @override
  String get emergingCatStimulants => 'Novel stimulants';

  @override
  String get emergingCatAnalytical => 'Analytical challenges';

  @override
  String get emergingCatInterferences => 'New interferences';

  @override
  String get emergingCatPostmortem => 'Postmortem interpretation';

  @override
  String get emergingCatStandards => 'New standards';

  @override
  String get emergingCatValidation => 'Method validation';

  @override
  String get emergingCatQuality => 'Laboratory quality';

  @override
  String get emergingCatAlert => 'Scientific alert';

  @override
  String get fmTopicDeathInvestigation => 'Death investigation';

  @override
  String get fmTopicCauseMechanismManner =>
      'Cause, mechanism and manner of death';

  @override
  String get fmTopicPostmortemChanges => 'Postmortem changes';

  @override
  String get fmTopicPostmortemInterval => 'Postmortem interval';

  @override
  String get fmTopicAlgorMortis => 'Algor mortis';

  @override
  String get fmTopicRigorMortis => 'Rigor mortis';

  @override
  String get fmTopicLivorMortis => 'Livor mortis';

  @override
  String get fmTopicDecomposition => 'Decomposition';

  @override
  String get fmTopicTrauma => 'Trauma';

  @override
  String get fmTopicBluntForceInjury => 'Blunt force injury';

  @override
  String get fmTopicSharpForceInjury => 'Sharp force injury';

  @override
  String get fmTopicFirearmInjury => 'Firearm injury';

  @override
  String get fmTopicAsphyxia => 'Asphyxia';

  @override
  String get fmTopicBurns => 'Burns';

  @override
  String get fmTopicElectricalInjury => 'Electrical injury';

  @override
  String get fmTopicHypoHyperthermia => 'Hypothermia and hyperthermia';

  @override
  String get fmTopicDrowning => 'Drowning';

  @override
  String get fmTopicAnthropology => 'Forensic anthropology';

  @override
  String get fmTopicAgeEstimation => 'Age estimation';

  @override
  String get fmTopicSexEstimation => 'Sex estimation';

  @override
  String get fmTopicStatureEstimation => 'Stature estimation';

  @override
  String get fmTopicOdontology => 'Forensic odontology';

  @override
  String get fmTopicDisasterVictimIdentification =>
      'Disaster victim identification';

  @override
  String get fmTopicHistology => 'Forensic histology';

  @override
  String get fmTopicPostmortemImaging => 'Postmortem imaging';

  @override
  String get compareTitle => 'Compare jurisdictions';

  @override
  String get compareTopicDrinkDrive =>
      'Drink-driving: prescribed alcohol limit';

  @override
  String get compareNoData => 'No data — no conclusion is drawn';

  @override
  String get compareNoTopics =>
      'No comparable legal data in the content pack yet.';

  @override
  String get compareNotAdvice =>
      'Reference information, not legal advice. Always check the current official text.';

  @override
  String get compareNoInference =>
      'Missing data never means “allowed”, “not controlled” or “prohibited”.';

  @override
  String compareOverrides(String jurisdiction) {
    return 'Overrides the rule of $jurisdiction';
  }

  @override
  String compareArticle(String section) {
    return 'Section: $section';
  }

  @override
  String compareAuthority(String name) {
    return 'Authority: $name';
  }

  @override
  String get compareOfficialExcerpt => 'Official text';

  @override
  String get specimenBreath => 'Breath';

  @override
  String get specimenBlood => 'Blood';

  @override
  String get specimenUrine => 'Urine';

  @override
  String get legalThresholdTitle => 'Legal limit';

  @override
  String get legalLayerNational => 'National / regional law';

  @override
  String get legalOpenCompare => 'Compare jurisdictions';

  @override
  String get toolSolutionName => 'Solution preparation (mass required)';

  @override
  String get toolSolutionDesc =>
      'Mass of substance for a target concentration and final volume: m = C·V(·M)/p. Molar mass and purity come from you (certificate/label).';

  @override
  String get calcTargetConc => 'Target concentration';

  @override
  String get calcMolarMass => 'Molar mass (g/mol)';

  @override
  String get calcPurity => 'Purity (0–1)';

  @override
  String get calcMassRequired => 'Mass required';

  @override
  String get calcErrorMolarMass =>
      'Enter the molar mass from the certificate or label for a molar concentration.';

  @override
  String get calcErrorPurity => 'Purity must be greater than 0 and at most 1.';

  @override
  String get calcSolutionAssumptionDefinition =>
      'Definitional calculation of concentration (no empirical coefficients).';

  @override
  String get calcSolutionAssumptionInputs =>
      'Molar mass and purity are supplied by the user; nothing is estimated.';

  @override
  String get calcSolutionLimitationRecipe =>
      'This is not a reagent recipe: substance choice, order, storage and stability come only from a verified source or SOP.';

  @override
  String get calcSolutionLimitationVolume =>
      'Volume change on dissolution is ignored.';

  @override
  String get calcWarnPurity => 'Purity correction applied.';

  @override
  String legalExtent(String extent) {
    return 'Territorial extent: $extent';
  }

  @override
  String legalAppliesTo(String places) {
    return 'Applies to: $places';
  }

  @override
  String get legalStatusInForce => 'In force';

  @override
  String get legalStatusAmended => 'Amended';

  @override
  String get legalStatusSuperseded => 'Superseded';

  @override
  String get legalStatusRepealed => 'Repealed';

  @override
  String get aiExperienceProfessional => 'Professional';

  @override
  String get aiExperienceTutor => 'Tutor';

  @override
  String get aiExperienceProfessionalHint =>
      'Concise, source-first answers for practitioners.';

  @override
  String get aiExperienceTutorHint =>
      'Step-by-step explanations for learning, always with sources.';

  @override
  String get aiFindSources => 'Find sources offline';

  @override
  String get aiRetrievalTitle => 'Matching statements in the offline database';

  @override
  String get aiRetrievalNote =>
      'This is not an AI answer: these are local search results, each with its source.';

  @override
  String get aiNoContext =>
      'No reliable context in the offline database — no answer is given.';

  @override
  String get aiBlockedConclusion =>
      'Final conclusions on the cause or manner of death are not provided. That decision belongs to the expert with the full case.';

  @override
  String get aiBlockedLegal =>
      'Legal conclusions (guilt, charges, sentencing) are not provided.';

  @override
  String get aiBlockedPii => 'Remove personal data before searching or asking.';

  @override
  String get learnLevelAll => 'All levels';

  @override
  String get learnLevelFoundation => 'Foundation';

  @override
  String get learnLevelIntermediate => 'Intermediate';

  @override
  String get learnLevelAdvanced => 'Advanced';

  @override
  String learnProgressValue(int done, int total) {
    return '$done of $total lessons completed';
  }

  @override
  String get learnHistory => 'Recently studied';

  @override
  String get learnBookmarks => 'Bookmarks';

  @override
  String get learnBookmarksEmpty =>
      'Bookmark a topic with the star to find it here.';

  @override
  String get learnMarkComplete => 'Mark as completed';

  @override
  String get learnCompleted => 'Completed';

  @override
  String get learnCourseSourceNote =>
      'Lessons show original source statements. No new scientific text is written; content awaits expert review.';

  @override
  String get learnExam => 'Exam mode';

  @override
  String get learnExamIntro =>
      'Answer all questions. Results and explanations appear only after you submit.';

  @override
  String get learnExamSubmit => 'Submit exam';

  @override
  String learnExamScore(int correct, int total) {
    return 'Score: $correct of $total';
  }

  @override
  String get learnExamEmpty =>
      'No reviewed exam questions yet. Questions are not generated automatically.';

  @override
  String get learnExamRetry => 'Try again';

  @override
  String get learnSimulatedCase => 'SIMULATED CASE — not a real case';

  @override
  String get moduleHistology => 'Forensic histology';

  @override
  String get moduleResearch => 'Research & evidence';

  @override
  String get group_alcohols_volatiles => 'Alcohols & volatiles';

  @override
  String get group_toxic_gases => 'Toxic gases';

  @override
  String get group_opioids => 'Opioids';

  @override
  String get group_stimulants => 'Stimulants';

  @override
  String get group_cannabinoids => 'Cannabinoids';

  @override
  String get group_hallucinogens_dissociatives =>
      'Hallucinogens & dissociatives';

  @override
  String get group_benzodiazepines => 'Benzodiazepines';

  @override
  String get group_sedatives_hypnotics => 'Sedatives & hypnotics';

  @override
  String get group_barbiturates => 'Barbiturates';

  @override
  String get group_antidepressants => 'Antidepressants';

  @override
  String get group_antipsychotics => 'Antipsychotics';

  @override
  String get group_anticonvulsants => 'Anticonvulsants';

  @override
  String get group_pharmaceuticals => 'Common pharmaceuticals';

  @override
  String get group_adulterants => 'Adulterants';

  @override
  String get group_pesticides => 'Pesticides & rodenticides';

  @override
  String get group_metals_inorganic => 'Metals & inorganic poisons';

  @override
  String get groupAll => 'All groups';

  @override
  String get groupEditorialNote =>
      'Groups are editorial navigation, not a scientific classification claim.';

  @override
  String get detailAnalyticalMethods => 'Analytical methods (from sources)';

  @override
  String get detailReportedConcentrations => 'Reported concentrations';

  @override
  String get concentrationNotThreshold =>
      'Reported values from individual studies or cases — NOT toxic, lethal or legal thresholds. Interpretation depends on specimen, case context, tolerance and postmortem changes.';

  @override
  String get concentrationSpecimen => 'Specimen';

  @override
  String concentrationContext(String context) {
    return 'Context: $context';
  }

  @override
  String get detailStructure => 'Chemical structure';

  @override
  String get detailRelated => 'Related professional content';

  @override
  String get relationAnalysedBy => 'Analysed by (mentioned in source)';

  @override
  String get relationMetabolism => 'Mentioned together in a metabolism source';

  @override
  String get relationConfirmedBy => 'Confirmatory methods';

  @override
  String get relationRelatedTopic => 'Related topics';

  @override
  String get relationResearch => 'Research & evidence';

  @override
  String relationBasis(String basis) {
    return 'Basis: $basis';
  }

  @override
  String researchMore(int count) {
    return 'All research ($count)';
  }

  @override
  String get researchTitle => 'Research & evidence library';

  @override
  String get researchNote =>
      'Metadata and links only — full texts are not copied. Dissertations, theses and conference papers are not shown at the level of peer-reviewed full articles.';

  @override
  String get researchAll => 'All';

  @override
  String get researchPeerReviewed => 'Peer-reviewed';

  @override
  String get researchNotPeerReviewed => 'Not a peer-reviewed article';

  @override
  String researchEvidence(String level) {
    return 'Evidence $level';
  }

  @override
  String get researchCopyLink => 'Copy link';

  @override
  String get researchLinkCopied => 'Link copied';

  @override
  String get researchLinked => 'Linked records';

  @override
  String researchCount(int count) {
    return '$count records';
  }

  @override
  String researchSourceApi(String api) {
    return 'Indexed via $api';
  }

  @override
  String get researchKindJournalArticle => 'Journal article';

  @override
  String get researchKindReview => 'Review';

  @override
  String get researchKindSystematicReview => 'Systematic review';

  @override
  String get researchKindMetaAnalysis => 'Meta-analysis';

  @override
  String get researchKindCaseReport => 'Case report';

  @override
  String get researchKindConferenceAbstract => 'Conference abstract';

  @override
  String get researchKindConferencePaper => 'Conference paper';

  @override
  String get researchKindDissertation => 'Doctoral dissertation';

  @override
  String get researchKindThesis => 'Thesis (Master’s / other)';

  @override
  String get researchKindOfficialReport => 'Official report';

  @override
  String get researchKindStandard => 'Standard / guideline';

  @override
  String get imageSchematic => 'Schematic — not experimental data';

  @override
  String get imageRealData => 'Figure from a published study';

  @override
  String get imageDepiction => 'Structure depiction (computed)';

  @override
  String imageLicense(String license) {
    return 'License: $license';
  }

  @override
  String get imageAttribution => 'Attribution';

  @override
  String get imageOriginalCaption => 'Original caption (source language)';

  @override
  String imageOpen(String title) {
    return 'Open image: $title';
  }

  @override
  String get imageUnavailable => 'Image unavailable offline';

  @override
  String get imagesHeading => 'Scientific visuals';

  @override
  String get licenseOriginalWork => 'Original work (FORENSIC EXPERT)';

  @override
  String get licenseFactualDepiction => 'Original depiction of factual data';

  @override
  String get histologyNote =>
      'Reference information for professionals. The app and Forensic AI do not provide histological diagnoses.';

  @override
  String get fieldCaseObservation => 'Case observation (single case)';

  @override
  String get fieldComposition => 'Composition (as stated in source)';

  @override
  String get fieldConfirmation => 'Confirmation requirement';
}
