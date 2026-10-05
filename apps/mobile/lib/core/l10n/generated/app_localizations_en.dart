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
  String get inDevelopmentTitle => 'No reviewed content to show';

  @override
  String get inDevelopmentBody =>
      'Content appears here only when it has a verifiable source and has passed expert review. Nothing is filled in just to make the screen look complete.';

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
  String get aiNotConnectedTitle => 'Production AI service is not connected';

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
  String get legalSection => 'Legal and safety';

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
      'Demonstration build: entries marked SAMPLE are illustrative and are not scientific content.';

  @override
  String get testDataBadge => 'SAMPLE';

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
      'Molar concentration from weighed mass, molar mass and volume.';

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
  String get toolUnitsDesc =>
      'mg/L, µg/mL, ng/mL, mmol/L; mass ↔ molar with a supplied molar mass.';

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
  String get detailPlaceholder =>
      'No reviewed scientific details are available for this entry yet.';

  @override
  String get detailConcentrationsNote =>
      'A concentration alone does not establish a cause of death. Values will be shown only with matrix, population and sources.';

  @override
  String get sourcesButton => 'Sources';

  @override
  String get sourcesNone => 'No sources are linked to this entry.';

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
      'External databases (PubMed, PubChem, Crossref) are not connected in this version. External results are never mixed with the reviewed internal database.';

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
  String get aiPreviewTitle => 'Answer layout (demonstration)';

  @override
  String get aiPreviewNotice =>
      'DEMONSTRATION — this is not an AI response and not scientific advice. It only shows how a connected answer will be structured.';

  @override
  String get aiSectionAvailable => 'Available information';

  @override
  String get aiSectionConsiderations => 'Differential considerations';

  @override
  String get aiSectionLimitations => 'Limitations of interpretation';

  @override
  String get aiSampleInternal =>
      'Example statement linked to a reviewed internal source.';

  @override
  String get aiSampleExternal =>
      'Example statement from an external source that has not been reviewed.';

  @override
  String get aiSampleLimitation =>
      'Example limitation — a final interpretation requires the full case context.';

  @override
  String get aiEvidenceInternalVerified => 'Internal · verified';

  @override
  String get aiEvidenceInternalReviewed => 'Internal · reviewed';

  @override
  String get aiEvidenceExternal => 'External · not reviewed';

  @override
  String aiPlaceholderSource(int number) {
    return 'Example source $number';
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
  String get profileSectionAccount => 'Data on this device';

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
      'The App Store / Google Play is not connected in this build. Prices and purchases appear only when the store provides them.';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get restoreNothing => 'No active subscriptions to restore.';

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
  String get purchaseTitle => 'Plans';

  @override
  String get purchaseCta => 'See plans';

  @override
  String get purchaseFreeTitle => 'Free';

  @override
  String get purchaseFreeBody =>
      'Core offline reference, search and basic calculators — no account required.';

  @override
  String get purchaseAiNote =>
      'Professional AI features become available only when the AI service is connected; limits will be stated before purchase.';

  @override
  String get purchaseOwned => 'Your subscription is active';

  @override
  String get purchaseUnavailableSnack =>
      'Purchases are not available in this build.';

  @override
  String get accessFree => 'Free';

  @override
  String get homePilotNotice =>
      'The scientific database is under expert review. Every entry is shown with its sources and review status and is not a final conclusion.';

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
  String get lockedTitle => 'Included in Student Pro and Professional Pro';

  @override
  String get lockedBody =>
      'Names, warnings and sources stay open. Scientific details and the jurisdiction layer unlock with a paid plan.';

  @override
  String get freeDemoBadge => 'Free demo';

  @override
  String get lockedBadge => 'Pro';

  @override
  String searchMoreLocked(int count) {
    return '$count more results with a paid plan';
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
  String get purchaseSuccess => 'Subscription activated. Thank you!';

  @override
  String get aboutTrademarkPending =>
      'Name and logo: trademark clearance pending.';

  @override
  String get diagPurchaseNone => 'Subscription: none confirmed by the store';

  @override
  String get diagPurchaseStore =>
      'Subscription: confirmed by the store only — server verification not connected (release blocker)';

  @override
  String get diagPurchaseServer => 'Subscription: verified by the server';

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
  String get moduleScreening => 'Rapid & screening tests';

  @override
  String get moduleMethods => 'Methods & SOP';

  @override
  String get moduleStandardsLaws => 'Law & jurisdictions';

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
  String get reagentHazards => 'Hazard';

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

  @override
  String get metaAuthors => 'Authors';

  @override
  String get metaContainer => 'Journal / conference';

  @override
  String get metaInstitution => 'Institution';

  @override
  String get metaDegree => 'Degree';

  @override
  String get metaYear => 'Year';

  @override
  String get metaCreator => 'Creator';

  @override
  String get metaSource => 'Source';

  @override
  String get metaAccessed => 'Accessed';

  @override
  String get tech_tlc => 'TLC (thin-layer chromatography)';

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
  String get tech_uvVis => 'UV-Vis spectrophotometry';

  @override
  String get tech_immunoassay => 'Immunoassay';

  @override
  String get tech_spectroscopy => 'Spectroscopy';

  @override
  String get tech_samplePreparation => 'Sample preparation';

  @override
  String get tech_extraction => 'Extraction';

  @override
  String get tech_calibration => 'Calibration';

  @override
  String get tech_qualityControl => 'Quality control';

  @override
  String get tech_validation => 'Method validation';

  @override
  String get tech_uncertainty => 'Measurement uncertainty';

  @override
  String get tech_statistics => 'Statistics';

  @override
  String get methodSection_purpose => 'Purpose';

  @override
  String get methodSection_scope => 'Scope';

  @override
  String get methodSection_analytes => 'Analytes';

  @override
  String get methodSection_specimens => 'Specimens';

  @override
  String get methodSection_principle => 'Principle';

  @override
  String get methodSection_equipment => 'Equipment';

  @override
  String get methodSection_reagents => 'Reagents';

  @override
  String get methodSection_samplePreparation => 'Sample preparation';

  @override
  String get methodSection_calibrationQc => 'Calibration and QC';

  @override
  String get methodSection_workflow => 'Workflow';

  @override
  String get methodSection_interpretation => 'Interpretation';

  @override
  String get methodSection_limitations => 'Limitations';

  @override
  String get methodSection_validationStatus => 'Validation status';

  @override
  String get toolPercentName => 'Percentage solutions';

  @override
  String get toolPercentDesc =>
      'Solute amount for % (w/v), (v/v) or (w/w) by definition.';

  @override
  String get calcValue => 'Value';

  @override
  String get calcFrom => 'From';

  @override
  String get calcTo => 'To';

  @override
  String get calcConvertAssumption =>
      'Unit prefixes are SI definitions; mass ↔ molar conversion uses ρ = c · M.';

  @override
  String get calcConvertLimitation =>
      'The molar mass must come from a certificate or verified identity data; the calculator never estimates it.';

  @override
  String get calcMolarityMass => 'Weighed mass';

  @override
  String get calcMolarityVolume => 'Final volume';

  @override
  String get calcMolarityResult => 'Molar concentration';

  @override
  String get calcMolarityAssumption =>
      'Definition of amount-of-substance concentration: c = n / V, with n = m · p / M.';

  @override
  String get calcPercentBasis => 'Percentage basis';

  @override
  String get calcPercentWv => '% (w/v) — g per 100 mL';

  @override
  String get calcPercentVv => '% (v/v) — mL per 100 mL';

  @override
  String get calcPercentWw => '% (w/w) — g per 100 g';

  @override
  String get calcPercentValue => 'Percentage (%)';

  @override
  String get calcPercentTotalMl => 'Total solution volume (mL)';

  @override
  String get calcPercentTotalG => 'Total solution mass (g)';

  @override
  String get calcPercentSolute => 'Solute amount';

  @override
  String get calcPercentAssumption =>
      'Percentage definitions as stated for each basis.';

  @override
  String get calcPercentLimitationBasis =>
      'w/v, v/v and w/w are not interchangeable — use the basis stated in the validated method or SOP.';

  @override
  String get calcErrorPercent =>
      'Enter a percentage greater than 0 and at most 100.';

  @override
  String get calcStatsValues =>
      'Values (separated by spaces, commas or new lines)';

  @override
  String get calcStatsN => 'n';

  @override
  String get calcStatsMean => 'Mean';

  @override
  String get calcStatsMedian => 'Median';

  @override
  String get calcStatsSd => 'SD (n − 1)';

  @override
  String get calcStatsCv => 'CV %';

  @override
  String get calcStatsMin => 'Minimum';

  @override
  String get calcStatsMax => 'Maximum';

  @override
  String get calcStatsAssumption =>
      'Sample standard deviation with an n − 1 denominator.';

  @override
  String get calcStatsLimitation =>
      'No outlier test or normality check is performed.';

  @override
  String get calcStatsWarnSd => 'At least two values are needed for SD and CV.';

  @override
  String get calcErrorValues => 'Enter numeric values only.';

  @override
  String get calcRegPoints => 'Calibration points (one “x y” pair per line)';

  @override
  String get calcRegSlope => 'Slope (b)';

  @override
  String get calcRegIntercept => 'Intercept (a)';

  @override
  String get calcRegR2 => 'R²';

  @override
  String get calcRegSyx => 'Residual SD (s_y/x)';

  @override
  String get calcRegAssumptionOls =>
      'Ordinary least squares, unweighted, y = a + b·x.';

  @override
  String get calcRegLimitationRange =>
      'Valid only within the calibrated range; weighting and linearity are decided by method validation.';

  @override
  String get calcRegWarnFew =>
      'Fewer than five calibration points — interpret with caution.';

  @override
  String get calcErrorPoints =>
      'Enter at least three “x y” pairs with different x values.';

  @override
  String get calcLodSigma => 'Standard deviation of the response (σ)';

  @override
  String get calcLodSlope => 'Slope of the calibration curve (S)';

  @override
  String get calcLodSigmaBasis => 'Basis of σ';

  @override
  String get calcLodBasisBlank => 'SD of blank responses';

  @override
  String get calcLodBasisResidual => 'Residual SD of the regression line';

  @override
  String get calcLodBasisIntercept => 'SD of y-intercepts of regression lines';

  @override
  String get calcLodLod => 'Detection limit (DL = 3.3σ/S)';

  @override
  String get calcLodLoq => 'Quantitation limit (QL = 10σ/S)';

  @override
  String get calcLodAssumptionSigma =>
      'σ is estimated by one of the approaches named in the source: blank SD, residual SD or SD of y-intercepts.';

  @override
  String get calcLodAssumptionLinear =>
      'The response is linear near the limit.';

  @override
  String get calcLodLimitationOne =>
      'This is one of several accepted approaches; visual evaluation and signal-to-noise are others.';

  @override
  String get calcLodLimitationVerify =>
      'The source requires calculated limits to be confirmed by analysing samples near the limit.';

  @override
  String get calcLodReference =>
      'ICH Q2(R2) Validation of Analytical Procedures (2023) — §3.2.3.3';

  @override
  String get calcLodReferenceNote =>
      'Factors checked against the official ICH Q2(R2) PDF; they are unchanged from Q2(R1) (superseded). Q2(R2) also allows S/N and direct accuracy/precision confirmation. Laboratory reviewer confirmation pending (RG-25).';

  @override
  String get calcUseRegression => 'Use σ = s_y/x and S from this regression';

  @override
  String get calcErrorSigma => 'Enter σ > 0 and a non-zero slope.';

  @override
  String get researchKindGuideline => 'Guideline';

  @override
  String get researchKindValidationStudy => 'Validation study';

  @override
  String get researchKindCaseSeries => 'Case series';

  @override
  String get tech_gcMsMs => 'GC-MS/MS';

  @override
  String get tech_lcMs => 'LC-MS';

  @override
  String get tech_hrms => 'HRMS (high-resolution mass spectrometry)';

  @override
  String get tech_spectrophotometry => 'Spectrophotometry';

  @override
  String get emergingCatBiomarkers => 'New biomarkers';

  @override
  String get emergingCatMethods => 'Emerging analytical methods';

  @override
  String get emergingCatLegal => 'Legal / regulatory updates';

  @override
  String get severityCritical => 'Critical';

  @override
  String get severityWarning => 'Warning';

  @override
  String get severityInfo => 'Information';

  @override
  String get severityReview => 'Review status';

  @override
  String get homeRecentlyViewed => 'Recently viewed';

  @override
  String get homeQuickEmpty =>
      'Recently viewed records, tools, favourites and searches will appear here. They are stored only on this device.';

  @override
  String homeJurisdictionChip(String name) {
    return 'Jurisdiction: $name';
  }

  @override
  String get homeChange => 'Change';

  @override
  String get homeAllDisciplines => 'All forensic disciplines';

  @override
  String get homeAllDisciplinesBody =>
      '20 disciplines — scope and currently available content';

  @override
  String get disc_forensicMedicine => 'Forensic medicine';

  @override
  String get disc_forensicPathology => 'Forensic pathology';

  @override
  String get disc_clinicalForensicMedicine => 'Clinical forensic medicine';

  @override
  String get disc_forensicRadiology => 'Forensic radiology & imaging';

  @override
  String get disc_forensicPsychiatry => 'Forensic psychiatry & psychology';

  @override
  String get disc_forensicToxicology => 'Forensic toxicology';

  @override
  String get disc_forensicChemistry => 'Forensic chemistry';

  @override
  String get disc_forensicBiochemistry => 'Forensic biochemistry';

  @override
  String get disc_analyticalScience => 'Analytical science';

  @override
  String get disc_forensicBiology => 'Forensic biology';

  @override
  String get disc_forensicGenetics => 'Forensic genetics / DNA';

  @override
  String get disc_forensicHistology => 'Forensic histology';

  @override
  String get disc_forensicAnthropology => 'Forensic anthropology';

  @override
  String get disc_forensicOdontology => 'Forensic odontology';

  @override
  String get disc_forensicMicrobiology => 'Forensic microbiology';

  @override
  String get disc_forensicEntomology => 'Forensic entomology';

  @override
  String get disc_humanIdentification => 'DVI / human identification';

  @override
  String get disc_laboratoryQuality => 'Laboratory quality & validation';

  @override
  String get disc_evidenceHandling => 'Evidence handling & chain of custody';

  @override
  String get disc_educationResearch => 'Education & research';

  @override
  String get discGroupMedicine => 'Medicine & pathology';

  @override
  String get discGroupToxChem => 'Toxicology & chemistry';

  @override
  String get discGroupBioId => 'Biology & identification';

  @override
  String get discGroupLab => 'Laboratory & quality';

  @override
  String get discGroupEdu => 'Education & research';

  @override
  String get disciplinesTitle => 'Forensic disciplines';

  @override
  String get disciplinesIntro =>
      'FORENSIC EXPERT covers these disciplines. Content is added gradually and only with sources and expert review — an empty discipline means “no sourced content yet”, not “no knowledge exists”.';

  @override
  String disciplineRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sourced records',
      one: '1 sourced record',
      zero: 'No sourced records yet',
    );
    return '$_temp0';
  }

  @override
  String get disciplineReferenceOnly => 'Professional reference scope only';

  @override
  String get disciplineModules => 'Modules';

  @override
  String get disciplineTopics => 'Planned topic structure';

  @override
  String get disciplineEmpty =>
      'No sourced content in this discipline yet. Records will be added only with verifiable sources and expert review.';

  @override
  String get jurisdictionsTitle => 'Law & jurisdictions';

  @override
  String get jurisdictionCurrent => 'Current jurisdiction';

  @override
  String get jurisdictionLayersTitle => 'Three separate layers';

  @override
  String get layerGlobalCore =>
      'Global scientific core — the same in every country';

  @override
  String get layerIntlStandards =>
      'International standards & methods — not law unless adopted';

  @override
  String get layerCountryLaw =>
      'Country / jurisdiction law & procedures — only for the selected jurisdiction';

  @override
  String get jurisdictionViewDetails => 'Legal & procedural layer';

  @override
  String get jurisdictionWithContent => 'Jurisdictions with legal records';

  @override
  String get jurisdictionSearchHint => 'Search country or ISO code';

  @override
  String get jurisdictionNotVerified =>
      'Content not yet verified for this jurisdiction. Laws of other countries are never shown as a substitute.';

  @override
  String get jurisdictionPilotContent => 'Legal records · under legal review';

  @override
  String get jurisdictionNoContentShort => 'Content not yet verified';

  @override
  String jurisdictionChain(String chain) {
    return 'Applies via: $chain';
  }

  @override
  String get jurisdictionGlobalWorks =>
      'Global scientific content works without selecting a jurisdiction. A jurisdiction is needed only for laws, controlled-substance schedules and national procedures.';

  @override
  String get jurisdictionInstruments => 'Official documents';

  @override
  String get jurisdictionIntlLayer => 'International layer (applies to all)';

  @override
  String get jurisdictionOwnLayer => 'Jurisdiction-specific layer';

  @override
  String get jurisdictionCountryNames =>
      'Country names: Unicode CLDR. The list only enables selection — it does not mean legal content exists.';

  @override
  String get docKindLaw => 'LAW';

  @override
  String get docKindRegulation => 'REGULATION';

  @override
  String get docKindStandard => 'STANDARD';

  @override
  String get docKindGuideline => 'GUIDELINE';

  @override
  String get docKindMethod => 'METHOD';

  @override
  String get docKindSop => 'SOP';

  @override
  String get docKindArticle => 'SCIENTIFIC ARTICLE';

  @override
  String get docKindOfficial => 'OFFICIAL DOCUMENT';

  @override
  String get bindingLegal =>
      'Legally binding in its jurisdiction while in force';

  @override
  String get bindingVoluntary =>
      'Voluntary unless adopted by law or accreditation';

  @override
  String get bindingAdvisory => 'Advisory — not legally binding';

  @override
  String get bindingInstitutional =>
      'Applies only within the issuing institution';

  @override
  String get bindingScientific =>
      'Scientific evidence — not a normative document';

  @override
  String get instrNumber => 'Official number';

  @override
  String get instrPublished => 'Published';

  @override
  String get instrEffectiveFrom => 'In force from';

  @override
  String get instrEffectiveTo => 'In force until';

  @override
  String get instrAmended => 'Last amended';

  @override
  String get instrVersion => 'Version / edition';

  @override
  String get instrLegalStatus => 'Legal status';

  @override
  String get instrLanguage => 'Official language';

  @override
  String get instrTranslation => 'Translation';

  @override
  String get instrLastVerified => 'Last verified';

  @override
  String get instrReview => 'Review status';

  @override
  String get instrSource => 'Official source';

  @override
  String get instrAuthority => 'Authority';

  @override
  String get translationNone => 'Original language only';

  @override
  String get libraryHubIntro =>
      'One umbrella for scientific records. Every record shows its source and review status.';

  @override
  String get libraryStandards => 'Standards & official documents';

  @override
  String libraryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
      zero: 'No records yet',
    );
    return '$_temp0';
  }

  @override
  String get libraryGroupScience => 'Scientific records';

  @override
  String get libraryGroupDocs => 'Documents & evidence';

  @override
  String get standardsIntro =>
      'Standards, guidelines and methods are labelled by type. Only laws and regulations are legally binding — and only in their own jurisdiction.';

  @override
  String get researchFilterPeer => 'Peer-reviewed only';

  @override
  String get researchFilterOpen => 'Open access';

  @override
  String get researchPeriodAll => 'Any year';

  @override
  String get researchPeriodRecent => '2020 or later';

  @override
  String get researchPeriod2010 => '2010–2019';

  @override
  String get researchPeriodOlder => 'Before 2010';

  @override
  String get researchDisciplineAll => 'All disciplines';

  @override
  String get researchDiscipline => 'Discipline';

  @override
  String get researchPeriod => 'Period';

  @override
  String get researchClear => 'Clear filters';

  @override
  String get researchRelevance => 'Forensic relevance';

  @override
  String get relevanceUnassessed =>
      'Not yet assessed by a reviewer (separate from evidence level)';

  @override
  String get relevanceDirect => 'Direct';

  @override
  String get relevanceSupporting => 'Supporting';

  @override
  String get relevanceBackground => 'Background';

  @override
  String get researchOpenAccess => 'Open access';

  @override
  String get researchOpenPmc => 'Yes — PubMed Central';

  @override
  String get researchOpenLink => 'Yes — free full-text link';

  @override
  String get researchOpenUnknown => 'Not determined';

  @override
  String get researchDocKind => 'Document type';

  @override
  String get detailOnThisPage => 'On this page';

  @override
  String get detailNotYetSourced => 'Not yet sourced';

  @override
  String get detailJurisdictionShort => 'Jurisdiction';

  @override
  String searchMetaboliteOf(String name) {
    return 'Metabolite of $name';
  }

  @override
  String get aiBlockedOfficial =>
      'Forensic AI does not write official expert opinions, death certificates or definitive intoxication conclusions. It can help you find and compare sources.';

  @override
  String get aiJurisdictionRequired =>
      'This is a legal or procedural question. Select a jurisdiction first — Forensic AI never assumes one.';

  @override
  String get aiSelectJurisdiction => 'Select jurisdiction';

  @override
  String get aiSectionEvidenceStatus => 'Evidence status';

  @override
  String get aiSampleEvidenceStatus =>
      'Each statement shows the review status and evidence level of the record it comes from.';

  @override
  String get aiSectionJurisdiction => 'Jurisdiction';

  @override
  String get aiSampleJurisdiction =>
      'Legal statements apply only to the selected jurisdiction; scientific statements are global.';

  @override
  String get aiSectionRelated => 'Related records';

  @override
  String get aiSampleRelated =>
      'Links to the substance, method and research records used in the answer.';

  @override
  String get tpl_overview => 'Overview';

  @override
  String get tpl_names => 'Names & synonyms';

  @override
  String get tpl_classification => 'Classification';

  @override
  String get tpl_metabolism => 'Metabolism';

  @override
  String get tpl_metabolites => 'Metabolites';

  @override
  String get tpl_specimens => 'Specimens';

  @override
  String get tpl_screening => 'Screening';

  @override
  String get tpl_confirmation => 'Confirmatory analysis';

  @override
  String get tpl_analyticalMethods => 'Analytical methods';

  @override
  String get tpl_reportedConcentrations => 'Reported concentrations';

  @override
  String get tpl_interpretation => 'Interpretation';

  @override
  String get tpl_postmortem => 'Postmortem considerations';

  @override
  String get tpl_stability => 'Stability';

  @override
  String get tpl_interferences => 'Interferences';

  @override
  String get tpl_jurisdiction => 'Jurisdiction-specific law & methods';

  @override
  String get tpl_research => 'Research & evidence';

  @override
  String get tpl_sources => 'Sources';

  @override
  String get tpl_principle => 'Principle';

  @override
  String get tpl_forensicUse => 'Forensic use';

  @override
  String get tpl_samplePreparation => 'Sample preparation';

  @override
  String get tpl_instrumentation => 'Instrumentation';

  @override
  String get tpl_qualitativeQuantitative => 'Qualitative / quantitative use';

  @override
  String get tpl_validation => 'Validation requirements';

  @override
  String get tpl_interference => 'Interference';

  @override
  String get tpl_limitations => 'Limitations';

  @override
  String get tpl_qc => 'Quality control';

  @override
  String get tpl_relatedSubstances => 'Related substances';

  @override
  String get tpl_relatedReagents => 'Related reagents';

  @override
  String get tpl_purpose => 'Purpose';

  @override
  String get tpl_composition => 'Composition';

  @override
  String get tpl_preparation => 'Preparation';

  @override
  String get tpl_storageStability => 'Storage & stability';

  @override
  String get tpl_safety => 'Safety';

  @override
  String get tpl_disposal => 'Disposal';

  @override
  String get tpl_linkedMethods => 'Linked methods & tests';

  @override
  String get tpl_technology => 'Technology';

  @override
  String get tpl_targetSpecimen => 'Target & specimen';

  @override
  String get tpl_cutoff => 'Cutoff';

  @override
  String get tpl_performance => 'Sensitivity & specificity';

  @override
  String get tpl_crossReactivity => 'Cross-reactivity';

  @override
  String get tpl_falseResults => 'False positives / negatives';

  @override
  String get tpl_marker => 'Marker';

  @override
  String get tpl_specimen => 'Specimen';

  @override
  String get tpl_collectionContext => 'Collection context';

  @override
  String get tpl_postmortemLimitations => 'Postmortem limitations';

  @override
  String get tpl_analyticalMethod => 'Analytical method';

  @override
  String get tpl_interpretationLimitations => 'Interpretation limitations';

  @override
  String get tpl_definition => 'Definition';

  @override
  String get tpl_findings => 'Findings';

  @override
  String get tpl_methods => 'Methods';

  @override
  String templateCoverage(int filled, int total) {
    return 'Sections with sourced data: $filled of $total';
  }

  @override
  String get provWhereFrom => 'Where does this come from?';

  @override
  String get provSheetTitle => 'Provenance of this statement';

  @override
  String get provStatement => 'Statement';

  @override
  String provLocation(String loc) {
    return 'Location in source: $loc';
  }

  @override
  String get provSource => 'Source';

  @override
  String provTier(String tier) {
    return 'Source tier $tier';
  }

  @override
  String get provTierA => 'A — official text, standard or guideline';

  @override
  String get provTierB => 'B — peer-reviewed publication';

  @override
  String get provTierC => 'C — handbook, database or secondary source';

  @override
  String get reuseOpen => 'Open reuse';

  @override
  String get reuseCiteOnly => 'Cite only — text not reproduced';

  @override
  String get reuseNonCommercial => 'Non-commercial licence';

  @override
  String get reuseLicenseRequired => 'LICENSE REQUIRED';

  @override
  String get reuseLookup => 'Lookup only';

  @override
  String get reuseUnknown => 'Licence not determined';

  @override
  String get srcLifecycleCurrent => 'Not retracted';

  @override
  String get srcLifecycleRetracted => 'RETRACTED';

  @override
  String get srcLifecycleSuperseded => 'SUPERSEDED';

  @override
  String get srcLifecycleWithdrawn => 'WITHDRAWN';

  @override
  String provCheckedOn(String date) {
    return 'Retraction check: $date';
  }

  @override
  String get provArchiveHash => 'Archived copy SHA-256';

  @override
  String provSourceVersion(String v) {
    return 'Version: $v';
  }

  @override
  String get provLifecycle => 'Lifecycle';

  @override
  String get lcCurrent => 'Current';

  @override
  String get lcNeedsReview => 'Needs review';

  @override
  String get lcOutdated => 'Outdated';

  @override
  String get lcSuperseded => 'Superseded';

  @override
  String get lcRetracted => 'Retracted source';

  @override
  String get lcRejected => 'Rejected';

  @override
  String get provHumanVerified => 'Verified by qualified human reviewers';

  @override
  String get provNotVerified => 'NOT VERIFIED — EXPERT CONFIRMATION REQUIRED';

  @override
  String provRequiredRole(String role) {
    return 'Required reviewer: $role';
  }

  @override
  String provReviewsRecorded(int n) {
    return 'Reviewer actions on this version: $n';
  }

  @override
  String provClaimId(String id, int v) {
    return 'Record ID: $id · v$v';
  }

  @override
  String get roleForensicToxicology => 'Forensic toxicology';

  @override
  String get roleForensicMedicine => 'Forensic medicine';

  @override
  String get roleLaboratory => 'Laboratory / analytical';

  @override
  String get roleBiochemistry => 'Forensic biochemistry';

  @override
  String get roleLegal => 'Legal / jurisdiction';

  @override
  String get roleTranslation => 'Translation';

  @override
  String get roleEditor => 'Scientific editor / admin';

  @override
  String get bannerRetracted =>
      'Source retracted — this statement is kept for transparency but is not current evidence.';

  @override
  String get bannerSuperseded =>
      'All sources of this statement have been superseded.';

  @override
  String get bannerOutdated => 'Flagged as outdated by a reviewer.';

  @override
  String get bannerConflict =>
      'EVIDENCE CONFLICT — sources disagree or overlap. Tap to compare.';

  @override
  String get conflictsTitle => 'Evidence conflicts';

  @override
  String get conflictsIntro =>
      'Conflicts are shown, not hidden. Only a qualified reviewer can resolve one; the app never picks a winner.';

  @override
  String get conflictKindDirect => 'Direct contradiction';

  @override
  String get conflictKindContext => 'Depends on context';

  @override
  String get conflictKindOverlap => 'Values overlap between contexts';

  @override
  String get conflictKindCharacterisation => 'Described differently';

  @override
  String get conflictQuestion => 'Question';

  @override
  String get conflictStatements => 'Statements involved';

  @override
  String get conflictStateOpen => 'Open — awaiting reviewer decision';

  @override
  String get conflictStateResolved => 'Resolved by reviewer';

  @override
  String get conflictNoteLabel => 'Summary of what the sources say';

  @override
  String get ctxTitle => 'Context (only what the source states)';

  @override
  String get ctxSpecimen => 'Specimen';

  @override
  String get ctxSampling => 'Sampling';

  @override
  String get ctxSubject => 'Subject';

  @override
  String get ctxPopulation => 'Population';

  @override
  String get ctxStudySize => 'Number of cases';

  @override
  String get ctxCaseType => 'Case type';

  @override
  String get ctxCoIntoxicants => 'Co-intoxicants';

  @override
  String get ctxMethod => 'Analytical method';

  @override
  String get ctxTiming => 'Timing';

  @override
  String get ctxStatistic => 'Reported values';

  @override
  String get ctxReporting => 'Data origin';

  @override
  String get ctxLimitations => 'Limitations';

  @override
  String get ctxNotStated => 'not stated in the source';

  @override
  String get ctxPostmortem => 'post-mortem';

  @override
  String get ctxAntemortem => 'ante-mortem';

  @override
  String get ctxMixed => 'mixed';

  @override
  String get ctxDeceased => 'deceased';

  @override
  String get ctxLiving => 'living';

  @override
  String get ctxPrimary => 'Primary data of the cited study';

  @override
  String get ctxSecondary => 'Quoted from another study';

  @override
  String get ctxNotAssessed => 'Not yet assessed';

  @override
  String get ctxAutoMinimal =>
      'Reviewed contextual data for this record is not yet available.';

  @override
  String get metRelationsTitle => 'Metabolites (sourced relations)';

  @override
  String get metKindMetabolite => 'Metabolite';

  @override
  String get metKindActive => 'Active metabolite';

  @override
  String get metKindInactive => 'Inactive metabolite';

  @override
  String get metKindMarker => 'Marker';

  @override
  String get metKindArtifact => 'Artifact';

  @override
  String get metRoleNote =>
      'A role (active, marker…) is shown only when the cited text states it.';

  @override
  String metParentOf(String name) {
    return 'Parent substance: $name';
  }

  @override
  String get specimensTitle => 'Specimens';

  @override
  String get specimensIntro =>
      'Specimen types with sourced statements and reported values. Reported values are never thresholds.';

  @override
  String get specimenAbout => 'About this specimen';

  @override
  String get specimenMeasured => 'Reported values in this specimen';

  @override
  String get specimenNoClaims => 'No sourced statements yet.';

  @override
  String get specimenCatFluid => 'Body fluid';

  @override
  String get specimenCatTissue => 'Tissue';

  @override
  String get specimenCatKeratinous => 'Keratinous matrix';

  @override
  String get specimenCatContent => 'Contents';

  @override
  String specimenRecords(int n) {
    return '$n records';
  }

  @override
  String get detailMeasuredIn => 'Specimens with reported values';

  @override
  String get detailScreenedBy => 'Screening tests (screening ≠ confirmation)';

  @override
  String get chainTitle => 'Knowledge chain';

  @override
  String get chainOpen => 'Show knowledge chain';

  @override
  String get chainIntro =>
      'Every link below has a recorded basis (a sourced statement, an official list entry or a catalogue record). Tap a link to see it.';

  @override
  String get chainMetabolites => 'Metabolites';

  @override
  String get chainSpecimens => 'Specimens';

  @override
  String get chainScreening => 'Screening';

  @override
  String get chainConfirmation => 'Confirmatory methods';

  @override
  String get chainReagents => 'Reagents';

  @override
  String get chainResearch => 'Research';

  @override
  String get chainStandards => 'Standards';

  @override
  String get chainLegal => 'Legal status';

  @override
  String get chainNone => 'No sourced link yet';

  @override
  String chainBasis(String id) {
    return 'Basis: $id';
  }

  @override
  String chainResearchCount(int n) {
    return '$n linked publications';
  }

  @override
  String get stdCatalogue => 'Standards catalogue (metadata only)';

  @override
  String get stdStatusCurrent => 'Current';

  @override
  String get stdStatusProposed => 'Proposed — not yet published';

  @override
  String stdStatusSuperseded(String id) {
    return 'Superseded by $id';
  }

  @override
  String get stdStatusWithdrawn => 'Withdrawn';

  @override
  String get stdStatusUnknown => 'Status not determined';

  @override
  String stdVerifiedFrom(String date) {
    return 'Metadata checked on $date at the publisher or registry';
  }

  @override
  String get stdTextNotReproduced =>
      'The text of the standard is not reproduced in the app.';

  @override
  String get reviewTitle => 'Scientific review status';

  @override
  String get reviewHumanVerified => 'Verified by humans';

  @override
  String get reviewReviewed => 'Reviewed';

  @override
  String get reviewAwaiting => 'Awaiting review';

  @override
  String get reviewRetracted => 'Statements with a retracted source';

  @override
  String get reviewActions => 'Reviewer actions recorded';

  @override
  String get reviewReviewers => 'Registered reviewers';

  @override
  String get reviewOpenConflicts => 'Open evidence conflicts';

  @override
  String get reviewExplain =>
      'A statement becomes VERIFIED only after two independent qualified reviewers in its specialty approve the current version. The app and its authors cannot mark anything verified themselves.';

  @override
  String get reviewRolesTitle => 'Reviewer roles and permissions';

  @override
  String get reviewRoleApprove => 'Can approve or reject in its specialty';

  @override
  String get reviewRoleFlagOnly =>
      'Can flag conflicts, outdated content and request changes — cannot approve';

  @override
  String get reviewActionsList => 'Possible actions';

  @override
  String get libraryConflicts => 'Evidence conflicts';

  @override
  String get libraryReview => 'Review status';

  @override
  String get methodPublishedNote =>
      'Published scientific method — not a validated procedure for any particular laboratory.';

  @override
  String get reagentConcentration => 'Concentration';

  @override
  String get reagentSolvent => 'Solvent';

  @override
  String get reagentPh => 'pH';

  @override
  String get reagentExpiry => 'Expiry / shelf life';

  @override
  String get reagentPpe => 'Personal protective equipment';

  @override
  String get screeningResultType =>
      'Result type (qualitative / semi-quantitative)';

  @override
  String get screeningDetectionWindow => 'Detection window (context-dependent)';

  @override
  String get screeningInterference => 'Interference';

  @override
  String get evInternationalStandard => 'International standard';

  @override
  String get evGuideline => 'Guideline';

  @override
  String get evPublishedValidated => 'Published validated method';

  @override
  String get evNationalMethod => 'National method';

  @override
  String get evLocalSop => 'Local SOP reference';

  @override
  String get evEducationalSummary => 'Educational summary';

  @override
  String get disciplineSourcedTopics => 'Sourced topics';

  @override
  String get aiRagAnswer => 'Answer';

  @override
  String get aiRagJurisdictionNotApplicable =>
      'Not a legal question — no jurisdiction applied';

  @override
  String get aiLimNotVerified =>
      'Evidence is not yet verified by qualified human reviewers.';

  @override
  String get aiLimConflict =>
      'Sources disagree or overlap — see EVIDENCE CONFLICT.';

  @override
  String aiLimRetracted(int n) {
    return '$n statement(s) from retracted or superseded sources were excluded.';
  }

  @override
  String get aiLimExpert =>
      'Interpretation of an individual case requires a qualified expert.';

  @override
  String get aiLimMock =>
      'Demonstration provider — no real AI answer was generated.';

  @override
  String get instrOriginalTitle => 'Original title';

  @override
  String legalMissingFields(String fields) {
    return 'Not recorded for this document: $fields';
  }

  @override
  String get lfOfficialTitle => 'Official title';

  @override
  String get lfOriginalTitle => 'Original-language title';

  @override
  String get lfArticle => 'Article / section';

  @override
  String get lfOfficialUrl => 'Official URL';

  @override
  String get lfReviewStatus => 'Review status';

  @override
  String get legalDomainsTitle => 'Legal domains';

  @override
  String legalDomainRecords(int n) {
    return '$n records';
  }

  @override
  String get legalDomainNoContent => 'No verified content';

  @override
  String get compareTopicControlStatus => 'Control status';

  @override
  String get ldExpertStatus => 'Forensic expert status';

  @override
  String get ldEvidenceHandling => 'Evidence handling';

  @override
  String get ldChainOfCustody => 'Chain of custody';

  @override
  String get ldSpecimenCollection => 'Specimen collection';

  @override
  String get ldDeathInvestigation => 'Death investigation';

  @override
  String get ldAutopsy => 'Autopsy';

  @override
  String get ldToxicology => 'Toxicology';

  @override
  String get ldAlcoholDriving => 'Alcohol and driving';

  @override
  String get ldControlledSubstances => 'Controlled substances';

  @override
  String get ldReporting => 'Reporting';

  @override
  String get ldLaboratoryStandards => 'Laboratory standards';

  @override
  String get ldRetentionStorage => 'Retention and storage';

  @override
  String get ldTestimony => 'Testimony';

  @override
  String get ldQualityAccreditation => 'Quality and accreditation';

  @override
  String get deleteLocalData => 'Delete data on this device';

  @override
  String get deleteLocalDataBody =>
      'Bookmarks, search history, recently viewed records and lesson progress will be deleted from this device only. The scientific database, your account and store subscriptions are not affected — use “Delete account” to delete the account.';

  @override
  String get deleteLocalDataConfirm => 'Delete';

  @override
  String get deleteLocalDataDone => 'Local data deleted';

  @override
  String get tierStudentPro => 'Student Pro';

  @override
  String get tierProfessionalPro => 'Professional Pro';

  @override
  String get tierInstitution => 'Institution';

  @override
  String get tierCurrent => 'Current plan';

  @override
  String get tierFreeF1 =>
      'Offline scientific database with safety warnings and sources';

  @override
  String get tierFreeF2 => 'Search and selected reference entries';

  @override
  String get tierFreeF3 => 'Basic calculators';

  @override
  String get tierStudentF1 =>
      'Full reference: substances, methods, reagents, forensic medicine, standards, jurisdictions';

  @override
  String get tierStudentF2 =>
      'All courses, quizzes, flashcards and exam practice';

  @override
  String get tierStudentF3 => 'Unlimited search results';

  @override
  String get tierProF1 => 'Everything in Student Pro';

  @override
  String get tierProF2 => 'Professional calculators and laboratory tools';

  @override
  String get tierProF3 => 'Analytical methods, research and evidence tools';

  @override
  String get tierProF4 =>
      'Professional AI features — when the AI service is connected';

  @override
  String get periodMonthly => 'Monthly';

  @override
  String get periodYearly => 'Yearly';

  @override
  String get periodUnknown => 'Subscription';

  @override
  String offerPriceLine(String price, String period) {
    return '$price · $period';
  }

  @override
  String get offerSubscribe => 'Subscribe';

  @override
  String get offerPriceFromStore =>
      'Price is shown by the App Store / Google Play';

  @override
  String get subscriptionTerms =>
      'Subscriptions renew automatically until cancelled. Payment is charged to your App Store / Google Play account. You can cancel at least 24 hours before the end of the period in your store account settings.';

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get manageSubscriptionFailed =>
      'Could not open the store subscription settings.';

  @override
  String get planLabel => 'Plan';

  @override
  String get subscriptionStateLabel => 'Subscription status';

  @override
  String get stActive => 'Active';

  @override
  String get stExpired => 'Expired';

  @override
  String get stGrace => 'Payment issue — grace period';

  @override
  String get stBillingRetry => 'Payment issue — access paused';

  @override
  String stCancelled(String date) {
    return 'Cancelled — active until $date';
  }

  @override
  String get stCancelledNoDate =>
      'Cancelled — active until the end of the period';

  @override
  String get stRevoked => 'Revoked by the store';

  @override
  String get stUnknown => 'Status unknown';

  @override
  String get stNone => 'No subscription';

  @override
  String stRenewsOn(String date) {
    return 'Renews or ends on $date';
  }

  @override
  String get accountOptionalNote =>
      'An account is optional. The offline scientific reference works without signing in; an account is needed only for cloud services.';

  @override
  String get accountNotConnected =>
      'The account service is not yet connected in this build. All offline features remain available.';

  @override
  String get accountTestBackend =>
      'TEST account backend — no real emails are sent and data is kept only in memory.';

  @override
  String get accountSignIn => 'Sign in';

  @override
  String get accountCreate => 'Create account';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSignedOut => 'Signed out';

  @override
  String get accountEmail => 'Email';

  @override
  String get accountPassword => 'Password';

  @override
  String get accountConfirmPassword => 'Confirm password';

  @override
  String get accountShowPassword => 'Show password';

  @override
  String get accountHidePassword => 'Hide password';

  @override
  String get accountVerified => 'Email verified';

  @override
  String get accountNotVerified => 'Email not verified';

  @override
  String get accountVerifyNow => 'Verify email';

  @override
  String get accountTermsAccept =>
      'I accept the Terms of Use and the Privacy Policy';

  @override
  String get accountMinimalData =>
      'We only ask for your email. No professional, case or personal details are collected.';

  @override
  String get passwordRulesTitle => 'Password requirements';

  @override
  String pwRuleMinLength(int n) {
    return 'At least $n characters';
  }

  @override
  String get pwRuleLetter => 'At least one letter';

  @override
  String get pwRuleDigit => 'At least one digit';

  @override
  String get pwRuleNotEmail => 'Not the same as your email';

  @override
  String get accountForgot => 'Forgot password?';

  @override
  String get accountNoAccount => 'No account? Create one';

  @override
  String get accountHaveAccount => 'Already have an account? Sign in';

  @override
  String get verifyTitle => 'Verify your email';

  @override
  String verifyBody(int n, String email) {
    return 'We sent a $n-digit code to $email. Enter it below to activate your account.';
  }

  @override
  String get verifyCode => 'Verification code';

  @override
  String get verifySubmit => 'Verify';

  @override
  String get verifyResend => 'Send a new code';

  @override
  String get verifyResent =>
      'If the account needs verification, a new code has been sent.';

  @override
  String get verifyDone => 'Email verified. Your account is active.';

  @override
  String get forgotTitle => 'Reset password';

  @override
  String get forgotBody =>
      'Enter your account email. If an account exists, we will send a reset code.';

  @override
  String get forgotSubmit => 'Send reset code';

  @override
  String forgotSent(int minutes) {
    return 'If an account exists for this email, a reset code has been sent. It expires in $minutes minutes.';
  }

  @override
  String get resetTitle => 'Choose a new password';

  @override
  String get resetCode => 'Reset code';

  @override
  String get resetNewPassword => 'New password';

  @override
  String get resetSubmit => 'Set new password';

  @override
  String get resetDone =>
      'Password changed. Please sign in with the new password.';

  @override
  String get authErrInvalidEmail => 'Enter a valid email address.';

  @override
  String get authErrWeakPassword =>
      'The password does not meet the requirements.';

  @override
  String get authErrMismatch => 'Passwords do not match.';

  @override
  String get authErrTerms =>
      'Please accept the Terms of Use and the Privacy Policy.';

  @override
  String get authErrCredentials => 'Email or password is incorrect.';

  @override
  String get authErrNotVerified =>
      'Your email is not verified yet. Enter the code we sent.';

  @override
  String get authErrCodeInvalid => 'The code is incorrect.';

  @override
  String get authErrCodeExpired => 'The code has expired. Request a new one.';

  @override
  String get authErrAlreadyVerified =>
      'This email is already verified. You can sign in.';

  @override
  String get authErrTooMany =>
      'Too many attempts. Please wait a minute and try again.';

  @override
  String get authErrOffline =>
      'No internet connection. Offline features keep working.';

  @override
  String get authErrServer =>
      'The account service is temporarily unavailable. Please try again later.';

  @override
  String get authErrNotConfigured =>
      'The account service is not yet connected in this build.';

  @override
  String get authErrRecentLogin =>
      'The password is incorrect. Confirm your current password to continue.';

  @override
  String get authErrNotSignedIn => 'Please sign in first.';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountBody =>
      'This permanently deletes your account and the data linked to it on our servers (email, sign-in sessions, synced data, cloud entitlement records). This cannot be undone.';

  @override
  String get deleteAccountStoreNote =>
      'Deleting the account does not cancel an App Store / Google Play subscription. Cancel it in your store account settings to stop future charges.';

  @override
  String get deleteAccountLocalNote =>
      'Data on this device (bookmarks, history) is a separate action: “Delete data on this device”.';

  @override
  String get deleteAccountUnderstand =>
      'I understand that this cannot be undone';

  @override
  String get deleteAccountPassword => 'Current password';

  @override
  String get deleteAccountConfirm => 'Delete account permanently';

  @override
  String get deleteAccountFinalTitle => 'Delete your account?';

  @override
  String get deleteAccountDone => 'Your account has been deleted.';

  @override
  String get aiDisclaimerLink => 'AI disclaimer';

  @override
  String get aiDisclaimerBody =>
      'Forensic AI answers are generated from the app’s local, source-linked content and are not expert opinions. They may be incomplete or wrong, are not verified by a qualified human reviewer and must not be used as the sole basis for a forensic conclusion, legal decision or patient care. Always check the cited sources and consult a qualified expert.';

  @override
  String get accountSection => 'Account';

  @override
  String get subscriptionSection => 'Subscription';

  @override
  String get availNoDataTitle => 'No records yet';

  @override
  String get availNoDataBody =>
      'The installed scientific database has no records for this section.';

  @override
  String get availFilterTitle => 'No results for the selected filter';

  @override
  String get availFilterBody =>
      'No reviewed records match the selected filter. Clear the filter or search the whole database.';

  @override
  String get availNotConnectedTitle => 'Not available in this version';

  @override
  String get availNotConnectedBody =>
      'This feature needs an online service that is not connected in this version. All offline features keep working.';

  @override
  String get availServiceTitle => 'Service temporarily unavailable';

  @override
  String get availServiceBody =>
      'Check the connection and try again later. Offline features keep working.';

  @override
  String get availClearFilters => 'Clear filters';

  @override
  String get availBrowseAll => 'Browse all records';

  @override
  String get availSearch => 'Search';

  @override
  String get aiStatusPreview => 'Preview · not connected';

  @override
  String get aiPreviewPoint1 => 'This screen is an interface preview.';

  @override
  String get aiPreviewPoint2 =>
      'The production AI service is not connected, so no AI answer is generated.';

  @override
  String get aiPreviewPoint3 =>
      'The sample answer below is a demonstration of the layout only.';

  @override
  String get aiPreviewPoint4 =>
      '“Find sources offline” searches the local database and works now.';

  @override
  String get aiSendUnavailable =>
      'Sending is disabled until the AI service is connected.';

  @override
  String get concWarning =>
      'This value comes from an individual case or study. It must not be interpreted as a universal toxic, lethal, therapeutic or legal threshold.';

  @override
  String get concTitle => 'Reported concentration';

  @override
  String get concSubstance => 'Substance';

  @override
  String get concValue => 'Value and unit';

  @override
  String get concValueInQuote => 'As quoted in the source (see excerpt)';

  @override
  String get concLivingPostmortem => 'Living / post-mortem';

  @override
  String get concSourceType => 'Source type';

  @override
  String get concSectionCase => 'Case description';

  @override
  String get concSectionAbstract => 'Abstract';

  @override
  String get concSectionIntro => 'Introduction (background)';

  @override
  String get concSectionResults => 'Results';

  @override
  String get concSectionDiscussion => 'Discussion';

  @override
  String get concStudyContext => 'Case / study context';

  @override
  String get concEvidenceLevel => 'Evidence level';

  @override
  String get concReviewStatus => 'Review status';

  @override
  String get concSource => 'Source';

  @override
  String get concNotAvailable => 'Not available';

  @override
  String get concExcerpt => 'Source excerpt';

  @override
  String get calcStatusTitle => 'Status';

  @override
  String get calcEngineLabel => 'Calculation engine';

  @override
  String get calcEngineTested =>
      'Checked by automated software tests — this is not a scientific review';

  @override
  String get calcEngineChip => 'Engine tested';

  @override
  String get calcReferenceLabel => 'Formula reference';

  @override
  String get calcInterpretationLabel => 'Interpretation';

  @override
  String get calcInterpretationValue =>
      'Context dependent — requires professional judgement';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get homeHeaderSubtitle => 'Forensic science reference';
}
