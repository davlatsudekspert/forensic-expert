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
}
