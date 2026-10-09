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
  String get modeTitle => 'How will you use FORENSIC EXPERT?';

  @override
  String get modeSubtitle =>
      'The home screen adapts to your choice. You can change it later in Profile.';

  @override
  String get modeProfessional => 'Professional';

  @override
  String get modeProfessionalDescription =>
      'Forensic experts, physicians, toxicologists, chemists and lab specialists';

  @override
  String get modeStudent => 'Student';

  @override
  String get modeStudentDescription =>
      'Students, residents and trainees, researchers and learners';

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
      'No reviewed information has been added to this section yet.';

  @override
  String get unverifiedBanner => 'Not yet confirmed by an expert';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusReviewed => 'Reviewed';

  @override
  String get statusNeedsReview => 'Needs review';

  @override
  String get statusOutdated => 'Outdated';

  @override
  String get aiNotConnectedTitle => 'AI is temporarily unavailable';

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
  String get toolPmiName => 'Postmortem interval (PMI) — Henssge';

  @override
  String get toolPmiDesc =>
      'Rectal temperature nomogram (Henssge): estimate with 95 % limits.';

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
      'The core library and calculators work offline. Search history, progress and your optional profile (name, organisation, specialty) stay on your device. Profile details and qualification documents are sent only if you submit a professional verification application once that service is connected; documents are stored privately and never shown publicly. The app contains no advertising SDKs. Personal or case data is never sent to AI automatically.\n\nInvitations: if you use a colleague’s invitation code, the server stores only the link between the two accounts and a salted hash of your email (to prevent abuse after account re-creation). Inviters see only totals — never your name, email, profile or documents. The app never reads your contacts.\n\nSuggestions & support: the message you send in «Suggestions & support», an optional screenshot (JPEG/PNG/WebP only, up to 5 MB), the request type and your account e-mail are stored on our server only to reply to you and improve the app. Only an authorised FORENSIC EXPERT team administrator can see them; other users never can. Replies are signed «FORENSIC EXPERT team», not with an administrator\'s name. Administrator actions are logged (without message text). Your consent is requested before a request is sent. Requests and screenshots are not shared with third parties and are not used for advertising or AI training. If you delete your account, your requests, messages and screenshots are deleted permanently.';

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
      'Names are machine-translated and not yet reviewed';

  @override
  String get detailNoContentYet => 'No sourced content for this section yet.';

  @override
  String detailSourceAccessed(String date) {
    return 'Accessed $date';
  }

  @override
  String get detailIdentifierVerified => 'DOI/PMID checked automatically';

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
  String get methodKindSop =>
      'Institutional SOPs (standard operating procedures)';

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
  String get fmTopicPostmortemInterval => 'Postmortem interval (PMI)';

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
  String get aiExperienceProfessional => 'Short answer';

  @override
  String get aiExperienceTutor => 'Explain it to me';

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
  String get learnBookmarks => 'Favorites';

  @override
  String get learnBookmarksEmpty =>
      'Mark a topic with the star to find it here.';

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
  String get detailRelated => 'Related materials';

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
      'Values (separate with spaces, “;” or new lines; decimal 0.5 or 0,5)';

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
  String get calcRegPoints =>
      'Calibration points: one “x y” or “x; y” pair per line';

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
  String homeAllDisciplinesBody(int count) {
    return '$count disciplines — scope and currently available content';
  }

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
  String get provNotVerified => 'Not yet confirmed by an expert';

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
  String get aiStatusPreview => 'Not available yet';

  @override
  String get aiPreviewPoint1 => 'No AI answers are generated right now.';

  @override
  String get aiPreviewPoint2 =>
      'This is temporary; the rest of the app works offline.';

  @override
  String get aiPreviewPoint3 =>
      'The sample below only shows how an answer is laid out.';

  @override
  String get aiPreviewPoint4 =>
      '“Find sources offline” searches the local database and works now.';

  @override
  String get aiSendUnavailable =>
      'AI is temporarily unavailable — sending is disabled.';

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

  @override
  String get modeRoleTitle => 'Your role (optional)';

  @override
  String get modeProfessionalNotVerified =>
      'Choosing Professional mode does not mean that your professional status is verified.';

  @override
  String get modeSwitchNote =>
      'Usage mode only changes how the app is arranged. It does not grant or remove professional verification.';

  @override
  String get roleStudent => 'Student';

  @override
  String get roleResident => 'Resident / trainee';

  @override
  String get roleResearcher => 'Researcher / learner';

  @override
  String get roleForensicExpert => 'Forensic expert';

  @override
  String get roleForensicPhysician => 'Forensic physician';

  @override
  String get roleForensicToxicologist => 'Forensic toxicologist';

  @override
  String get roleForensicChemist => 'Forensic chemist';

  @override
  String get roleLaboratorySpecialist => 'Laboratory specialist';

  @override
  String get rolePathologist => 'Pathologist';

  @override
  String get roleGeneticist => 'Geneticist / DNA specialist';

  @override
  String get roleForensicBiochemist => 'Forensic biochemist';

  @override
  String get roleAnthropologist => 'Forensic anthropologist';

  @override
  String get roleOdontologist => 'Forensic odontologist';

  @override
  String get roleOtherProfessional =>
      'Other forensic / laboratory professional';

  @override
  String get specForensicMedicine => 'Forensic medicine';

  @override
  String get specForensicToxicology => 'Forensic toxicology';

  @override
  String get specForensicChemistry => 'Forensic chemistry';

  @override
  String get specAnalyticalLaboratory => 'Analytical / laboratory science';

  @override
  String get specForensicBiochemistry => 'Forensic biochemistry';

  @override
  String get specPathologyHistology => 'Pathology / histology';

  @override
  String get specGeneticsDna => 'Genetics / DNA';

  @override
  String get specForensicAnthropology => 'Forensic anthropology';

  @override
  String get specForensicOdontology => 'Forensic odontology';

  @override
  String get specForensicRadiology => 'Forensic radiology';

  @override
  String get specForensicPsychology => 'Forensic psychology / psychiatry';

  @override
  String get specForensicBiology => 'Forensic biology';

  @override
  String get specEntomology => 'Forensic entomology';

  @override
  String get specOther => 'Other';

  @override
  String get scopeLegal => 'Law and jurisdiction';

  @override
  String get scopeTranslation => 'Translation';

  @override
  String get studyBachelor => 'Bachelor’s';

  @override
  String get studyMaster => 'Master’s';

  @override
  String get studyResidency => 'Residency / clinical training';

  @override
  String get studyDoctoral => 'Doctoral';

  @override
  String get studyOther => 'Other';

  @override
  String get accountChoiceTitle => 'Use the app without an account';

  @override
  String get accountChoiceSubtitle =>
      'The offline scientific database, search and calculators work without an account. An account is needed only for cloud features.';

  @override
  String get accountContinueWithout => 'Continue without an account';

  @override
  String get accountContinueWithoutNote =>
      'You can create an account later in Profile.';

  @override
  String get accountCreateOrSignIn => 'Create account / Sign in';

  @override
  String get accountCloudUnavailable =>
      'The cloud account service is not connected in this version. Everything offline keeps working.';

  @override
  String get accountNeededFor => 'An account is needed for';

  @override
  String get accountNeedVerification => 'Professional verification';

  @override
  String get accountNeedReviews => 'Professional reviews of scientific content';

  @override
  String get accountNeedSync => 'Synchronisation between devices';

  @override
  String get accountNeedSubscriptions => 'Subscriptions across devices';

  @override
  String get accountNeedCloudAi => 'Cloud AI (when connected)';

  @override
  String get accountNeedInstitution => 'Institutional features';

  @override
  String get accountFillProfile => 'Fill in profile now (optional)';

  @override
  String get profileLocalOnlyNote =>
      'Your profile is stored on this device. It is sent to the server only when you submit it for verification.';

  @override
  String get profileStudentTitle => 'Student profile';

  @override
  String get profileProTitle => 'Professional profile';

  @override
  String get profileSaved => 'Profile saved on this device';

  @override
  String get profileSectionIdentity => 'Personal details';

  @override
  String get profileSectionWork => 'Professional details';

  @override
  String get profileSectionOptional => 'Optional';

  @override
  String get profileStudentCannotReview =>
      'Student profiles are for learning: they cannot verify scientific content or perform qualified reviews.';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldCountry => 'Country';

  @override
  String get fieldCountryChoose => 'Choose a country';

  @override
  String get fieldCountrySearch => 'Search country';

  @override
  String get fieldCity => 'City / region (optional)';

  @override
  String get fieldInstitution => 'University / institution (optional)';

  @override
  String get fieldFaculty => 'Faculty / programme (optional)';

  @override
  String get fieldStudyLevel => 'Study level (optional)';

  @override
  String get fieldInterests => 'Areas of interest';

  @override
  String get fieldOrganization => 'Organisation / institution';

  @override
  String get fieldPosition => 'Position / job title';

  @override
  String get fieldPrimarySpecialty => 'Primary specialty';

  @override
  String get fieldAdditionalSpecialties => 'Additional specialties';

  @override
  String get fieldYearsExperience => 'Years of professional experience';

  @override
  String get fieldEducation => 'Education / qualification';

  @override
  String get fieldWorkEmail => 'Work e-mail (optional)';

  @override
  String get fieldPrivateHelper =>
      'Private — never shown on your public profile.';

  @override
  String get fieldLicense =>
      'Professional registration / licence number (optional)';

  @override
  String get fieldLicenseHelper =>
      'Only if your country issues one. Private — never shown publicly.';

  @override
  String get fieldBio => 'Short professional biography (optional)';

  @override
  String get fieldLanguages => 'Languages (comma separated)';

  @override
  String get fieldProInterests => 'Professional interests (optional)';

  @override
  String get fieldShowOrganization => 'Show organisation on public profile';

  @override
  String get fieldShowOrganizationHelper =>
      'Off by default. Name, specialty and country are public only after verification.';

  @override
  String get formRequired => 'Required field';

  @override
  String get formTooLong => 'Too long';

  @override
  String get formInvalid => 'Invalid value';

  @override
  String get formHasErrors => 'Please correct the highlighted fields.';

  @override
  String get actionSave => 'Save';

  @override
  String get actionRemove => 'Remove';

  @override
  String get verifTitle => 'Professional verification';

  @override
  String get verifStatusLabel => 'Current status';

  @override
  String get verifUnverified => 'Not verified';

  @override
  String get verifPending => 'Review pending';

  @override
  String get verifVerified => 'Verified professional';

  @override
  String get verifChangesRequested => 'More information needed';

  @override
  String get verifRejected => 'Rejected';

  @override
  String get verifSuspended => 'Temporarily suspended';

  @override
  String get verifUnverifiedBody =>
      'You have not applied for verification. All offline features are available without it.';

  @override
  String get verifPendingBody =>
      'Your application is waiting for review by an authorised person.';

  @override
  String get verifVerifiedBody =>
      'Your professional status was confirmed by an authorised person. Review rights are granted separately for each specialty.';

  @override
  String get verifChangesBody =>
      'Additional information is needed. Update your profile or documents and resubmit.';

  @override
  String get verifRejectedBody =>
      'The application was not approved. You can submit a new application.';

  @override
  String get verifSuspendedBody =>
      'Verification is temporarily suspended. Review rights are not active.';

  @override
  String get verifServiceNotConnected =>
      'The verification service is not connected in this version. Applications cannot be sent and nobody can be verified yet.';

  @override
  String get verifHowTitle => 'How verification works';

  @override
  String get verifStep1 => 'Fill in your professional profile.';

  @override
  String get verifStep2 =>
      'Optionally attach a qualification document (stored privately).';

  @override
  String get verifStep3 =>
      'An authorised administrator or a verified professional of the same specialty reviews the application and the document manually. Self-approval is impossible.';

  @override
  String get verifStep4 =>
      'Review rights are granted separately for each specialty.';

  @override
  String get verifHumanOnly =>
      'Selecting Professional mode, entering a job title, uploading a certificate or an automated/AI check never grants verified status. A document is evidence only; status is granted only after manual review, and who approved it, when, which document was checked and for which specialty are recorded.';

  @override
  String get verifApplication => 'Application';

  @override
  String get verifProfileMissing => 'Professional profile is not filled in';

  @override
  String get verifSubmit => 'Submit application';

  @override
  String get verifSubmitted => 'Application sent. Status: review pending.';

  @override
  String get verifSubmitUnavailable =>
      'Submitting is unavailable until the verification service is connected.';

  @override
  String get verifSubmitNote =>
      'The application and documents are sent over an encrypted connection to private storage.';

  @override
  String proYearsExperience(int years) {
    return '$years years of experience';
  }

  @override
  String proReviewCount(int count) {
    return 'Professional reviews: $count';
  }

  @override
  String get proServiceNotConnected =>
      'The cloud service is not connected in this version.';

  @override
  String get proInvalidInput => 'Check the entered data.';

  @override
  String get proOffline => 'No internet connection.';

  @override
  String get proServerError =>
      'The service is temporarily unavailable. Try again later.';

  @override
  String get credUploadTitle => 'Upload qualification document';

  @override
  String get credOptional => 'Optional';

  @override
  String credSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files selected',
      one: '1 file selected',
    );
    return '$_temp0';
  }

  @override
  String get credIntro =>
      'A document is optional and only helps an authorised person check your application. It never grants verified status by itself.';

  @override
  String get credPrivacy =>
      'Documents are private: they are never shown publicly, have no public link and their contents are not logged. Only an authorised verifier can open them.';

  @override
  String get credNoCaseData =>
      'Do not upload case materials, evidence, expert reports or any confidential case records. Passport or ID documents are not required.';

  @override
  String get credKindTitle => 'Document type';

  @override
  String get credProfessionalCertificate => 'Professional certificate';

  @override
  String get credQualificationCertificate => 'Qualification certificate';

  @override
  String get credDiploma => 'Diploma';

  @override
  String get credEmployment => 'Employment / appointment evidence';

  @override
  String get credRegistration => 'Professional registration / licence document';

  @override
  String get credTraining => 'Recognised training certificate';

  @override
  String get credFormats =>
      'PDF, JPG or PNG, up to 10 MB per file, up to 5 files.';

  @override
  String get credChooseFile => 'Choose file';

  @override
  String get credSelectedTitle => 'Selected documents';

  @override
  String get credNotUploaded =>
      'Not uploaded: the verification service is not connected. Files stay only in memory on this device and are discarded when the app closes.';

  @override
  String get credWillSendOnSubmit =>
      'Files will be sent privately together with the application.';

  @override
  String get credPickFailed => 'Could not open the file.';

  @override
  String get credErrorEmpty => 'The file is empty.';

  @override
  String get credErrorTooLarge => 'The file is larger than 10 MB.';

  @override
  String get credErrorType => 'Only PDF, JPG and PNG files are accepted.';

  @override
  String get credErrorTooMany => 'No more than 5 files.';

  @override
  String get reviewSectionTitle => 'Professional review';

  @override
  String get reviewEmpty =>
      'This material has not yet been reviewed by a qualified professional.';

  @override
  String get reviewWhoCanReview =>
      'Only verified professionals with review rights in the relevant specialty can review this material.';

  @override
  String get reviewScopeNotAssigned =>
      'A review specialty has not yet been assigned to this record.';

  @override
  String get reviewWrite => 'Write a professional review';

  @override
  String get reviewDecision => 'Decision';

  @override
  String get reviewActApprove => 'Approve';

  @override
  String get reviewActRequestChange => 'Request correction';

  @override
  String get reviewActConflict => 'Flag conflicting evidence';

  @override
  String get reviewActOutdated => 'Flag as outdated';

  @override
  String get reviewActReject => 'Reject';

  @override
  String get reviewDecApprove => 'Approved';

  @override
  String get reviewDecRequestChange => 'Correction required';

  @override
  String get reviewDecConflict => 'Conflicting evidence';

  @override
  String get reviewDecOutdated => 'Outdated';

  @override
  String get reviewDecReject => 'Rejected';

  @override
  String get reviewStateInProgress => 'Review in progress';

  @override
  String get reviewStateProfessional => 'Professionally reviewed';

  @override
  String get reviewStateHumanVerified => 'Scientifically verified by humans';

  @override
  String get reviewStateReReview => 'Re-review required';

  @override
  String get reviewNote => 'Review note';

  @override
  String get reviewNoteHelper =>
      'Explain the decision with reference to the evidence. At least 20 characters.';

  @override
  String get reviewNoteTooShort => 'At least 20 characters are required.';

  @override
  String get reviewSourceRef => 'Supporting source (optional)';

  @override
  String get reviewSourceHelper => 'DOI, PMID or an https link';

  @override
  String get reviewSourceInvalid => 'Enter a DOI, PMID or https link.';

  @override
  String get reviewSubmit => 'Submit review';

  @override
  String get reviewSubmitted => 'Review submitted';

  @override
  String get reviewNotVerification =>
      'A single review does not make content scientifically verified. Verification requires independent qualified reviews under the verification policy.';

  @override
  String reviewVersionNote(String version) {
    return 'The review applies to content version $version. If the content changes, a re-review is required.';
  }

  @override
  String reviewMeta(String date, String version) {
    return 'Reviewed $date · content version $version';
  }

  @override
  String get reviewStale =>
      'Written for an earlier content version — kept in the history; a re-review is required.';

  @override
  String get reviewPermAllowed => 'You can review this material.';

  @override
  String get reviewPermSignIn => 'Sign in to your account first.';

  @override
  String get reviewPermNotVerified =>
      'Reviews can be written only by verified professionals.';

  @override
  String get reviewPermSuspended =>
      'Your verification is suspended; reviewing is unavailable.';

  @override
  String get reviewPermScope =>
      'You do not have review rights for this specialty.';

  @override
  String get reviewPermStudentMode =>
      'Switch to Professional mode to write reviews. Your verification is kept.';

  @override
  String get layerSource => 'Source attached';

  @override
  String layerSourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources',
      one: '1 source',
    );
    return '$_temp0';
  }

  @override
  String get noReliableSource => 'No reliable source attached.';

  @override
  String get layerIdentifier => 'Identifier (DOI/PMID) checked';

  @override
  String get layerIdentifierOk => 'Checked';

  @override
  String get layerIdentifierPending => 'Not yet checked';

  @override
  String get layerNotApplicable => 'Not applicable';

  @override
  String get layerProfessional => 'Professional reviews';

  @override
  String get layerHuman => 'Human scientific verification';

  @override
  String layerHumanCount(int count, int required) {
    return '$count of $required independent approvals';
  }

  @override
  String get dashboardTitle => 'Review workspace';

  @override
  String get dashboardOnlyVerified =>
      'Available only to verified professionals with review rights in at least one specialty.';

  @override
  String get dashboardQueueEmpty => 'No records in this queue.';

  @override
  String dashboardItemMeta(
    int claims,
    int sources,
    String level,
    String version,
  ) {
    return 'Claims: $claims · sources: $sources · evidence: $level · version $version';
  }

  @override
  String get queueNeedsReview => 'Needs review';

  @override
  String get queueAssigned => 'Assigned to me';

  @override
  String get queueReviewedByMe => 'Reviewed by me';

  @override
  String get queueConflicts => 'Conflicts';

  @override
  String get queueReReview => 'Re-review required';

  @override
  String get profileSectionVerification => 'Verification';

  @override
  String get profileSectionData => 'Data and privacy';

  @override
  String get profileStudentVerificationNote =>
      'Professional verification applies to Professional mode. Switching mode does not change verification.';

  @override
  String get profileNotFilled => 'Profile not filled in';

  @override
  String get profileFillAction => 'Fill in profile';

  @override
  String get profileEditAction => 'Edit profile';

  @override
  String get moduleHubSourced => 'Sourced records';

  @override
  String get moduleHubSourcedNote =>
      'Shown with their sources and current review status. “Needs review” means available sourced content that is still awaiting expert review — not missing content.';

  @override
  String get moduleHubOpenAll => 'Open all';

  @override
  String methodsStandardsLink(int count) {
    return 'International standards and guidelines ($count)';
  }

  @override
  String get sourceOneTap => 'Sources and provenance';

  @override
  String get researchKeyRelevance => 'Forensic relevance';

  @override
  String get researchLimitationsNote =>
      'Only bibliographic data and a short description are shown; the full text is available from the publisher.';

  @override
  String get emailCodeTitle => 'Sign in with email code';

  @override
  String get emailCodeRowHint =>
      'A 6-digit code is sent to your email — no password needed';

  @override
  String get emailCodeSubtitle =>
      'Enter your email. We will send a one-time 6-digit FORENSIC EXPERT verification code.';

  @override
  String get emailCodeSend => 'Send code';

  @override
  String get emailCodeEnterTitle => 'Enter the 6-digit code';

  @override
  String get emailCodeChange => 'Change email';

  @override
  String emailCodeResendIn(int seconds) {
    return 'Resend ($seconds)';
  }

  @override
  String get emailCodeNotProfessional =>
      'Confirming your email signs you in. It does not verify professional status.';

  @override
  String get emailCodeSignedIn => 'Email confirmed. You are signed in.';

  @override
  String get actionNext => 'Next';

  @override
  String get profileSectionProfessional => 'Professional profile';

  @override
  String get profileStepPersonal => 'Personal';

  @override
  String get profileStepWork => 'Professional';

  @override
  String get profileStepProfessional => 'Profile and verification';

  @override
  String profileStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get verifReceivedTitle => 'Your application has been received.';

  @override
  String get verifReceivedBody => 'Your professional status is being reviewed.';

  @override
  String get verifReceivedNote =>
      'Status: application pending. Only an authorised human verifier can grant Verified Professional status — submitting documents does not verify you automatically.';

  @override
  String get sourceDetailTitle => 'Source';

  @override
  String sourceLinkedRecords(int count) {
    return 'Linked records ($count)';
  }

  @override
  String get sourceNoLinkedRecords =>
      'No records in the offline database cite this source.';

  @override
  String get sourceNotAttached => 'No reliable source attached.';

  @override
  String get sourceNotFound => 'Source not found in the offline database.';

  @override
  String get sourceOpenDetails => 'Source details and linked records';

  @override
  String homeDbCounts(int substances, int sources, int claims) {
    return '$substances substances · $sources sources · $claims sourced claims';
  }

  @override
  String homeDbHumanVerified(int count) {
    return 'Expert verified (2 independent experts): $count';
  }

  @override
  String sourcePmid(String id) {
    return 'PMID $id';
  }

  @override
  String get homeStatSubstances => 'Substances';

  @override
  String get homeStatSources => 'Sources';

  @override
  String get homeStatClaims => 'Sourced claims';

  @override
  String get homeStatHumanVerified => 'Expert verified';

  @override
  String get homeStatPolicy =>
      'Expert verified = two independent qualified experts. Automated checks and AI are never counted.';

  @override
  String get aiHeroSubtitle =>
      'Answers only from FORENSIC EXPERT’s sourced scientific database — every statement cites a record and shows its review status.';

  @override
  String get aiStatusConnected => 'Connected · beta';

  @override
  String get aiContextSources => 'Source: offline database';

  @override
  String get aiComposerTitle => 'Scientific query';

  @override
  String get referralTitle => 'Invite a colleague';

  @override
  String get referralLead =>
      'Know a forensic scientist, laboratory specialist or student who would find FORENSIC EXPERT useful? Share your personal invitation.';

  @override
  String get referralYourCode => 'Your invitation code';

  @override
  String get referralYourLink => 'Your invitation link';

  @override
  String get referralNoLinkNote =>
      'A web link will appear here once the public FORENSIC EXPERT site is connected. For now, share your code — a colleague enters it in Profile → Invitation code.';

  @override
  String get referralShare => 'Share invitation';

  @override
  String get referralCopy => 'Copy';

  @override
  String get referralCopied => 'Copied to clipboard';

  @override
  String get referralStatsTitle => 'Your invitations';

  @override
  String get referralStatJoined => 'Joined';

  @override
  String get referralStatVerified => 'Verified';

  @override
  String get referralStatPending => 'Pending';

  @override
  String get referralStatCredits => 'FORENSIC Credits';

  @override
  String referralCreditsPending(String amount) {
    return '$amount credits awaiting confirmation';
  }

  @override
  String referralCreditsFuture(String percent) {
    return 'When paid services launch, eligible purchases by colleagues you invite may earn you FORENSIC Credits — $percent% of the purchase value. Credits are an internal promotional bonus, not cash, and are not awarded for registration.';
  }

  @override
  String referralCreditsActive(String percent) {
    return 'You receive FORENSIC Credits worth $percent% of eligible purchases by colleagues you invite. Credits are confirmed after the refund period. They are an internal promotional bonus, not cash.';
  }

  @override
  String get referralPrivacyNote =>
      'Only totals are shown. Your colleagues’ names, emails, profiles and documents are never shared — neither with you nor in the invitation.';

  @override
  String get referralShareSubject => 'Invitation to FORENSIC EXPERT';

  @override
  String referralShareWithLink(String link) {
    return 'I use FORENSIC EXPERT as a scientific reference for forensic work — substances, methods, sources and source-linked AI answers. You can join with my invitation:\n$link';
  }

  @override
  String referralShareWithCode(String code) {
    return 'I use FORENSIC EXPERT as a scientific reference for forensic work — substances, methods, sources and source-linked AI answers. Install the app and enter my invitation code in Profile → Invitation code: $code';
  }

  @override
  String get referralSignInTitle => 'Sign in to get your invitation';

  @override
  String get referralSignInBody =>
      'Your personal code is created on the server after you sign in with your email. All scientific content stays available without an account.';

  @override
  String get referralNotConfigured =>
      'Invitations will be available once the FORENSIC EXPERT account service is connected.';

  @override
  String get referralLoadError =>
      'Couldn’t load your invitation. Check the connection and try again.';

  @override
  String get referralRetry => 'Try again';

  @override
  String get referralHaveCode => 'Invitation code';

  @override
  String get referralHaveCodeHint =>
      'Received an invitation from a colleague? Enter the 8-character code. It applies only to new accounts.';

  @override
  String get referralCodeField => 'Invitation code';

  @override
  String get referralApply => 'Apply';

  @override
  String get referralLinkedNote =>
      'Your account was created with a colleague’s invitation.';

  @override
  String get referralClaimValid =>
      'Invitation applied. Welcome to FORENSIC EXPERT.';

  @override
  String get referralClaimPending =>
      'Invitation saved. It becomes valid once your email is confirmed.';

  @override
  String get referralClaimInvalid =>
      'This code was not found. Check it and try again.';

  @override
  String get referralClaimSelf => 'You can’t use your own invitation code.';

  @override
  String get referralClaimAlready =>
      'An invitation is already linked to your account.';

  @override
  String get referralClaimNotEligible =>
      'Invitation codes apply only to new accounts.';

  @override
  String get referralClaimRateLimited =>
      'Too many attempts. Please try again later.';

  @override
  String get referralClaimSaved =>
      'Code saved. It will be applied after you sign in.';

  @override
  String get referralClaimOffline =>
      'No connection. The code is saved and will be applied later.';

  @override
  String get referralClaimFormat =>
      'Enter the 8-character code (letters and digits).';

  @override
  String get referralProfileRowHint => 'Share FORENSIC EXPERT with colleagues';

  @override
  String get homeInviteHint => 'Share a reference you trust with colleagues';

  @override
  String get shareAction => 'Share';

  @override
  String get shareFooter =>
      'Shared from FORENSIC EXPERT — scientific reference for forensic professionals. Verify against the original source before use.';

  @override
  String get shareSourcesLabel => 'Sources';

  @override
  String get savedAdded => 'Saved to your library';

  @override
  String get savedRemoved => 'Removed from saved';

  @override
  String get firstStepsTitle => 'Get started in 5 minutes';

  @override
  String firstStepsProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get firstStepsSearch => 'Search a substance';

  @override
  String get firstStepsDiscipline => 'Explore a discipline';

  @override
  String get firstStepsSource => 'Open a scientific source';

  @override
  String get firstStepsAi => 'Try Forensic AI';

  @override
  String get firstStepsSave => 'Save useful material';

  @override
  String get firstStepsHide => 'Hide';

  @override
  String get firstStepsDone =>
      'You’re all set. Your saved materials and recent records stay on this device.';

  @override
  String get fullTextPdf => 'Full text (PDF)';

  @override
  String get fullTextPdfNote =>
      'Open-access article (PubMed Central via Europe PMC). Opens in your device’s PDF viewer or browser.';

  @override
  String get fullTextPdfPro =>
      'Downloading full-text PDFs is available with Pro.';

  @override
  String get fullTextOpenFailed =>
      'Couldn’t open the PDF. Check your connection.';

  @override
  String get adminTitle => 'Admin panel';

  @override
  String get adminProfileHint => 'Users, platforms, countries, access';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminConfirmed => 'Email confirmed';

  @override
  String get adminSignups7d => 'New (7 days)';

  @override
  String get adminActive7d => 'Active (7 days)';

  @override
  String get adminAndroid => 'Android';

  @override
  String get adminIos => 'iOS';

  @override
  String get adminAiRequests => 'AI requests';

  @override
  String get adminReferrals => 'Referrals';

  @override
  String get adminProGrants => 'Pro granted';

  @override
  String get adminRegions => 'Countries (device region)';

  @override
  String get adminDaily => 'Sign-ups, last 30 days';

  @override
  String adminUserList(int count) {
    return 'Users ($count)';
  }

  @override
  String get adminStoreNote =>
      'Only registered users are counted here. Installs without sign-up are shown in App Store Connect and Google Play Console.';

  @override
  String get adminPrivacyNote =>
      'Contains personal data (emails). Do not share screenshots.';

  @override
  String get adminGrantTitle => 'Give or remove Pro';

  @override
  String get adminEmail => 'User email';

  @override
  String get adminGrantPro => 'Give Professional Pro';

  @override
  String get adminRevoke => 'Remove';

  @override
  String get adminGranted => 'Pro granted.';

  @override
  String get adminRevoked => 'Access removed.';

  @override
  String get adminNotFound => 'No user with this email.';

  @override
  String get adminFailed => 'Action failed. Check the connection.';

  @override
  String get adminForbidden => 'This section is for administrators only.';

  @override
  String get adminRefresh => 'Refresh';

  @override
  String get adminUnknownRegion => 'Unknown';

  @override
  String get adminAdminBadge => 'Admin';

  @override
  String get calcSex => 'Sex';

  @override
  String get calcSexMale => 'Male';

  @override
  String get calcSexFemale => 'Female';

  @override
  String get calcBodyWeight => 'Body weight, kg';

  @override
  String get calcHeightOptional => 'Height, cm (optional — Seidl r)';

  @override
  String get calcDrinkVolume => 'Drink volume, mL';

  @override
  String get calcDrinkAbv => 'Alcohol, % vol';

  @override
  String get calcHoursSinceStart => 'Hours since drinking started';

  @override
  String get calcAddDrink => 'Add drink';

  @override
  String get calcRemoveDrink => 'Remove drink';

  @override
  String calcDrinkN(String n) {
    return 'Drink $n';
  }

  @override
  String get calcWidmarkEthanol => 'Pure ethanol consumed';

  @override
  String get calcWidmarkR => 'Distribution factor r';

  @override
  String get calcWidmarkPeak =>
      'Theoretical maximum (no deficit, no elimination)';

  @override
  String get calcWidmarkMin => 'Minimum estimate';

  @override
  String get calcWidmarkMax => 'Maximum estimate';

  @override
  String get calcWidmarkAssumptionDeficit =>
      'Resorption deficit 10 % (maximum) and 30 % (minimum).';

  @override
  String get calcWidmarkAssumptionBeta =>
      'Elimination 0.10 ‰/h (maximum) and 0.20 ‰/h (minimum), from the start of drinking.';

  @override
  String get calcWidmarkAssumptionR =>
      'r: Widmark mean (male 0.7, female 0.6), or Seidl et al. (2000) from height and weight.';

  @override
  String get calcWidmarkLimitation =>
      'An estimate, not a measurement. Food, liver function, drinking pattern and medications change the result. Does not replace a measured blood alcohol concentration or an expert opinion.';

  @override
  String get calcBacMeasured => 'Measured blood alcohol';

  @override
  String get calcHoursEventToSample => 'Hours from event to blood sampling';

  @override
  String get calcHoursDrinkEndOptional =>
      'Hours from end of drinking to event (optional)';

  @override
  String get calcBackMin => 'At the event, minimum';

  @override
  String get calcBackMax => 'At the event, maximum';

  @override
  String get calcBackAssumptionLinear =>
      'Elimination is linear (zero order) and absorption was complete at the event.';

  @override
  String get calcBackAssumptionBeta =>
      'β = 0.10–0.25 g/L/h (10–25 mg/100 mL/h) covers most people (Jones 2010). For ‰ (g/kg) β is converted with blood density 1.055 g/mL.';

  @override
  String get calcBackLimitation =>
      'Within about 2 hours after the end of drinking the person may still be absorbing alcohol; then back-calculation may overestimate. Drinking after the event makes it invalid.';

  @override
  String get calcWarnAbsorption =>
      'The event was less than 2 hours after drinking ended: absorption may not be complete. Minimum is shown without back-extrapolation.';

  @override
  String get calcWarnEliminated =>
      'By this time alcohol is likely fully eliminated.';

  @override
  String get calcWarnRUnusual =>
      'Calculated r is outside the usual 0.45–0.85 range — check height and weight.';

  @override
  String get calcEthanolMatrix => 'Sample';

  @override
  String get calcMatrixBlood => 'Whole blood';

  @override
  String get calcMatrixSerum => 'Serum / plasma';

  @override
  String get calcSerumRatio => 'Serum / blood ratio';

  @override
  String get calcEthanolBloodHeader => 'Whole blood equivalent';

  @override
  String get calcEthanolAssumptionDensity =>
      '‰ means g/kg; blood density 1.055 g/mL is used for g/L.';

  @override
  String get calcEthanolAssumptionRatio =>
      'Serum contains more water than blood, so serum ethanol is higher; default ratio 1.2.';

  @override
  String get calcEthanolLimitation =>
      'The serum/blood ratio varies between people (about 1.1–1.3; Rainey 1993). Use the value required by your laboratory or jurisdiction.';

  @override
  String get calcRectalTemp => 'Rectal temperature, °C';

  @override
  String get calcAmbientTemp => 'Ambient temperature, °C';

  @override
  String get calcCorrectiveFactor =>
      'Clothing / environment (corrective factor)';

  @override
  String get calcFactorNakedDry => 'Naked, dry, still air — 1.0';

  @override
  String get calcFactorNakedMovingAir => 'Naked, moving air — 0.75';

  @override
  String get calcFactorWetStill => 'Naked, in still water — 0.5';

  @override
  String get calcFactorWetFlowing => 'Naked, in flowing water — 0.35';

  @override
  String get calcFactorThin => '1–2 thin layers of clothing — 1.1';

  @override
  String get calcFactorLayers => '2–3 layers of clothing — 1.2';

  @override
  String get calcFactorThick => '3–4 layers / thick clothing — 1.3';

  @override
  String get calcFactorBedding => 'Under a thick blanket — 2.0';

  @override
  String get calcHenssgeTime => 'Estimated postmortem interval (PMI)';

  @override
  String get calcHenssgeRange => '95 % limits';

  @override
  String calcHoursValue(String h) {
    return '$h h';
  }

  @override
  String calcHoursRange(String from, String to) {
    return '$from–$to h';
  }

  @override
  String get calcHenssgeAssumptionNormal =>
      'Body temperature at death 37.2 °C.';

  @override
  String get calcHenssgeAssumptionAmbient =>
      'Ambient temperature was roughly constant; formula for ≤ 23 °C and > 23 °C differs.';

  @override
  String get calcHenssgeAssumptionCi =>
      '95 % limits: ±2.8 h (≤ 23 °C), ±3.2 h (> 23 °C), ±4.5 h when a corrective factor is used.';

  @override
  String get calcHenssgeLimitation =>
      'Not valid with fever, hypothermia, strong heat sources, sun, body moved between environments, or major changes in ambient temperature. Combine with other signs (lividity, rigor, supravital reactions).';

  @override
  String get calcWarnNoCooling =>
      'Rectal temperature is at or above 37.2 °C — the body has not started cooling, or there was fever.';

  @override
  String get calcWarnLatePhase =>
      'Body is close to ambient temperature — accuracy is low.';

  @override
  String get calcErrorWeight => 'Enter a realistic body weight.';

  @override
  String get calcErrorTime => 'Enter a valid time in hours.';

  @override
  String get calcErrorAbv => 'Alcohol content must be between 0 and 100 %.';

  @override
  String get calcErrorHeight => 'Height must be 120–230 cm, or leave it empty.';

  @override
  String get calcErrorBac => 'Enter a blood alcohol between 0 and 8 ‰.';

  @override
  String get calcErrorRatio => 'Ratio must be between 1.0 and 1.5.';

  @override
  String get calcErrorRectal =>
      'Rectal temperature must be higher than ambient and at most 42 °C.';

  @override
  String get calcErrorAmbient =>
      'Ambient temperature must be between −20 and 35 °C.';

  @override
  String get guidelinesTitle => 'Guidelines';

  @override
  String get guidelinesSubtitle =>
      'Independent scientific-practical guidance by discipline';

  @override
  String get guidelinesIntro =>
      'Each guideline is an independent scientific synthesis written from the cited, verified literature. It is not an official methodology and does not replace accredited laboratory procedures or the law of your country. Every card stays under review until a specialist confirms it.';

  @override
  String get guidelinesSearchHint => 'Search guidelines';

  @override
  String get guidelinesEmptyArea => 'No guidelines in this area yet.';

  @override
  String get guidelinesNoResults => 'No results found';

  @override
  String guidelinesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guidelines',
      one: '1 guideline',
      zero: 'No guidelines',
    );
    return '$_temp0';
  }

  @override
  String get guidelineAreaForensicMedicine => 'Forensic medicine';

  @override
  String get guidelineAreaForensicChemistry =>
      'Forensic chemistry and toxicology';

  @override
  String get guidelineAreaForensicHistology => 'Forensic histology';

  @override
  String get guidelineAreaForensicBiology => 'Forensic biology and genetics';

  @override
  String get guidelineAreaMedicalCriminalistics =>
      'Medical criminalistics and anthropology';

  @override
  String get guidelineAreaOther => 'Other disciplines';

  @override
  String get guidelineIndependentNote =>
      'Independent scientific synthesis based on the references below. Not an official methodology; check the requirements of your laboratory and jurisdiction.';

  @override
  String get guidelineTranslationDraft =>
      'This translation is a draft and has not been reviewed by a specialist yet.';

  @override
  String guidelineFallbackLanguage(String language) {
    return 'Not yet available in your language — shown in the original language ($language).';
  }

  @override
  String get guidelineReferences => 'References';

  @override
  String guidelineUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get guidelineRelatedTools => 'Related tools';

  @override
  String get guidelineOpenReference => 'Open source';

  @override
  String get languageNameUz => 'Uzbek';

  @override
  String get languageNameRu => 'Russian';

  @override
  String get languageNameEn => 'English';

  @override
  String get restrictedCatalogTitle => 'Uzbekistan practice codes (restricted)';

  @override
  String get restrictedCatalogNote =>
      'Visible to administrators only. Catalogue metadata of a restricted source: the full text is not stored in the app, is not sent to AI and must not be distributed.';

  @override
  String get restrictedCatalogImport => 'Import catalogue file';

  @override
  String get restrictedCatalogRemove => 'Remove from this device';

  @override
  String get restrictedCatalogEmpty =>
      'No catalogue on this device. Import the file you received privately.';

  @override
  String restrictedCatalogImported(int count) {
    return 'Catalogue imported: $count records.';
  }

  @override
  String get restrictedCatalogInvalid => 'This file is not a valid catalogue.';

  @override
  String restrictedCatalogRecords(int count) {
    return '$count records';
  }

  @override
  String restrictedCatalogPages(String from, String to) {
    return 'pp. $from–$to';
  }

  @override
  String restrictedCatalogPage(String page) {
    return 'p. $page';
  }

  @override
  String restrictedCatalogCodeOriginal(String code) {
    return 'Code as written in the source: $code';
  }

  @override
  String get restrictedCatalogSearchHint => 'Search by code, title or term';

  @override
  String get restrictedCatalogLinkedCards => 'Linked independent guidelines';

  @override
  String get restrictedCatalogNormative => 'Related official documents';

  @override
  String restrictedCatalogSection(String section) {
    return 'Section $section';
  }

  @override
  String get restrictedCatalogTitleDraft => 'Title translation is a draft';

  @override
  String get aiWorking =>
      'Preparing an answer from sources… This can take up to a minute.';

  @override
  String get aiSearchingOffline => 'Searching the offline database…';

  @override
  String get aiNotCovered =>
      'The sources in the app do not cover this question well enough, so no sourced answer was produced.';

  @override
  String get aiModelNoteTitle => 'AI note (no sources — do not rely on it)';

  @override
  String get aiAnswerRejected =>
      'The AI answer was not shown because it could not be verified against the app\'s sources.';

  @override
  String get aiErrRateLimited =>
      'The hourly limit of AI questions has been reached. Please try again later.';

  @override
  String get aiErrSignIn =>
      'Your session has expired. Please sign in again to use AI.';

  @override
  String get aiErrOffline =>
      'No connection to the AI service. Check the internet connection.';

  @override
  String get aiErrServer =>
      'The AI service is temporarily unavailable. Please try again later.';

  @override
  String get aiErrNotConfigured =>
      'The AI service is not configured on the server yet.';

  @override
  String get aiQuotaUsed => 'Your AI question allowance is used up for now.';

  @override
  String get aiOfflineSourcesTitle => 'Sources found in the offline database';

  @override
  String aiOfflineSourcesCount(int count) {
    return 'Sources used ($count)';
  }

  @override
  String get aiRetry => 'Try again';

  @override
  String get relationBasisSourceExcerpt => 'source excerpt';

  @override
  String get metaHandle => 'Handle';

  @override
  String fileSizeKb(String size) {
    return '$size KB';
  }

  @override
  String get disc_forensicSerology => 'Forensic serology';

  @override
  String get disc_medicalCriminalistics => 'Medical criminalistics';

  @override
  String get disc_traceEvidence => 'Trace evidence and traceology';

  @override
  String get disc_firearmsBallistics => 'Firearms and ballistics';

  @override
  String get disc_questionedDocuments => 'Questioned documents';

  @override
  String get disc_digitalForensics => 'Digital forensics';

  @override
  String get discGroupCriminalistics => 'Criminalistics';

  @override
  String get homeGreeting => 'Welcome';

  @override
  String homeRoleChip(String mode) {
    return 'Mode: $mode';
  }

  @override
  String get homeAiEntryBody =>
      'Ask a scientific question. Answers cite their sources.';

  @override
  String get homeResourcesHeading => 'Library & tools';

  @override
  String get homeLibraryBody => 'Substances, methods, standards and references';

  @override
  String get homeContinueSaved => 'Continue & saved';

  @override
  String get loadingContent => 'Loading…';

  @override
  String get pubTitle => 'Expert publications';

  @override
  String get pubIntro =>
      'Articles by experts, published after moderation. Moderation checks format, rules and personal data — not scientific correctness.';

  @override
  String get pubNotVerifiedNotice =>
      'Submitting an article does not mean it has been scientifically verified.';

  @override
  String get pubSearchHint => 'Title, abstract or keyword';

  @override
  String get pubAllDisciplines => 'All disciplines';

  @override
  String get pubEmpty => 'No published articles yet.';

  @override
  String get pubFilterEmpty => 'No articles match your query.';

  @override
  String get pubLoadFailed => 'Could not load articles. Check the connection.';

  @override
  String get pubReload => 'Try again';

  @override
  String get pubUnavailable => 'This section is not available yet.';

  @override
  String get pubSubmit => 'Submit an article';

  @override
  String get pubMine => 'My articles';

  @override
  String get pubModeration => 'Moderation';

  @override
  String get pubSignInRequired => 'Sign in to submit articles or report them.';

  @override
  String get pubSignIn => 'Sign in';

  @override
  String get pubStatusDraft => 'Draft';

  @override
  String get pubStatusSubmitted => 'Submitted';

  @override
  String get pubStatusScreening => 'Initial check';

  @override
  String get pubStatusInReview => 'Under review';

  @override
  String get pubStatusApproved => 'Approved for publication';

  @override
  String get pubStatusRejected => 'Returned to the author';

  @override
  String get pubStatusPublished => 'Published';

  @override
  String get pubStatusRetracted => 'Retracted';

  @override
  String get pubStatusSuperseded => 'Replaced by a new version';

  @override
  String get pubAbstract => 'Abstract';

  @override
  String get pubKeywords => 'Keywords';

  @override
  String get pubAuthors => 'Authors';

  @override
  String get pubAffiliation => 'Affiliation';

  @override
  String get pubDoi => 'DOI identifier';

  @override
  String get pubReferences => 'References';

  @override
  String get pubExternalUrl => 'Full text link';

  @override
  String get pubLanguage => 'Article language';

  @override
  String get pubDiscipline => 'Discipline';

  @override
  String pubVersion(int version) {
    return 'Version $version';
  }

  @override
  String pubPublishedOn(String date) {
    return 'Published $date';
  }

  @override
  String get pubNotFound => 'Article not found.';

  @override
  String get pubLangUz => 'Uzbek';

  @override
  String get pubLangRu => 'Russian';

  @override
  String get pubLangEn => 'English';

  @override
  String get pubReport => 'Report';

  @override
  String get pubReportTitle => 'Report this article';

  @override
  String get pubReportDetails => 'Details (optional)';

  @override
  String get pubReportSend => 'Send';

  @override
  String get pubCancel => 'Cancel';

  @override
  String get pubReasonPlagiarism => 'Plagiarism';

  @override
  String get pubReasonPersonalData => 'Personal data';

  @override
  String get pubReasonCopyright => 'Copyright violation';

  @override
  String get pubReasonMisinformation => 'Misleading content';

  @override
  String get pubReasonAbuse => 'Offensive content';

  @override
  String get pubReasonOther => 'Other';

  @override
  String get pubReported => 'Thank you. The report was sent to moderators.';

  @override
  String get pubAlreadyReported => 'You have already reported this article.';

  @override
  String get pubActionFailed => 'Action failed. Check the connection.';

  @override
  String get pubFormTitle => 'Article title';

  @override
  String get pubFormKeywords => 'Keywords (comma-separated)';

  @override
  String get pubFormAuthors => 'Authors (one per line)';

  @override
  String get pubFormDoi => 'DOI (if any)';

  @override
  String get pubFormUrl => 'Full text link (https://…)';

  @override
  String get pubPiiWarning =>
      'Do not include personal data: names of victims or suspects, case numbers, addresses, photos of identifiable people, medical records.';

  @override
  String get pubConfirmationsTitle => 'Required confirmations';

  @override
  String get pubConfirmRights =>
      'I am the author or have the right to publish this text.';

  @override
  String get pubConfirmConsent =>
      'I agree that after moderation the article will be publicly available in FORENSIC EXPERT.';

  @override
  String get pubConfirmNoPii =>
      'The article contains no personal data of victims, suspects or other people.';

  @override
  String get pubSaveDraft => 'Save draft';

  @override
  String get pubSubmitForModeration => 'Submit for moderation';

  @override
  String get pubSubmitHint =>
      'To submit, fill in the title, abstract and discipline and tick all three confirmations.';

  @override
  String get pubDraftSaved => 'Draft saved.';

  @override
  String get pubSubmitted => 'The article was sent for moderation.';

  @override
  String get pubSubmitRejected =>
      'Not sent: fill in the required fields and confirmations.';

  @override
  String get pubEditTitle => 'Edit draft';

  @override
  String get pubPaidNote => 'A paid subscription does not affect moderation.';

  @override
  String get pubRequired => 'Required';

  @override
  String get pubMineEmpty => 'You have no articles yet.';

  @override
  String get pubTimeline => 'History';

  @override
  String get pubModeratorComment => 'Moderator comment';

  @override
  String get pubEdit => 'Edit';

  @override
  String get pubQueueEmpty => 'No articles awaiting moderation.';

  @override
  String pubReports(int count) {
    return 'Reports ($count)';
  }

  @override
  String pubMoveTo(String status) {
    return 'Move to: $status';
  }

  @override
  String get pubCommentLabel => 'Comment for the author';

  @override
  String get pubCommentRequired => 'A comment is required for this decision.';

  @override
  String get pubOwnArticle =>
      'Your own article: another moderator must review it.';

  @override
  String get pubModerationDone => 'Updated.';

  @override
  String get pubInvalidTransition =>
      'This step is not allowed from the current state.';

  @override
  String get pubForbidden => 'This section is for moderators only.';

  @override
  String get pubConfirm => 'Confirm';

  @override
  String get aiSignInTitle => 'Sign in to ask the AI';

  @override
  String get aiSignInBody =>
      'The AI service is connected and answers only from the app\'s sources, with citations. Asking questions requires a signed-in account; offline source search works without it.';

  @override
  String get aiSendSignIn => 'Sign in to send questions to the AI.';

  @override
  String get aiStatusSignIn => 'Sign-in required';

  @override
  String get searchDisciplineFilter => 'Filter results by discipline';

  @override
  String get searchDisciplineAll => 'All disciplines';

  @override
  String searchLinkedVia(String name) {
    return 'Linked to $name (mentioned in source)';
  }

  @override
  String get studyTitle => 'Study mode';

  @override
  String get studyEntrySubtitle =>
      'Flashcards and a self-check quiz built only from sourced records in the app';

  @override
  String get studyIntro =>
      'Every card and question is built from a record that already exists in the app, together with its source. Nothing new is written. Material that is still under expert review is labelled.';

  @override
  String get studySectionTopics => 'Topics by discipline';

  @override
  String get studySectionSubstances => 'Substances: molecular formulas';

  @override
  String get studySectionGuidelines => 'Guidelines';

  @override
  String studyDeckCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String studyDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count due now',
      zero: 'Nothing due',
    );
    return '$_temp0';
  }

  @override
  String get studyEmpty => 'No sourced material is available for study yet.';

  @override
  String get studyLoading => 'Loading study material';

  @override
  String get studyQuizUnavailable =>
      'Not enough records of this type for a quiz';

  @override
  String get studyFrontTopic =>
      'What does the cited source say about this topic?';

  @override
  String get studyFrontSubstance => 'What is the molecular formula?';

  @override
  String get studyFrontGuideline => 'What is the summary of this guideline?';

  @override
  String get studyTapToFlip => 'Tap the card to flip it';

  @override
  String get studyHideAnswer => 'Hide answer';

  @override
  String get studyDidntKnow => 'Didn’t know';

  @override
  String studyCardProgress(int current, int total) {
    return 'Card $current of $total';
  }

  @override
  String studyBox(int box, int total) {
    return 'Box $box of $total';
  }

  @override
  String get studyBoxNew => 'New card';

  @override
  String get studyQuoteLabel =>
      'Verbatim quote from the source (original language)';

  @override
  String studyGroupLabel(String group) {
    return 'Group (editorial): $group';
  }

  @override
  String get studySourcesHeader => 'Sources';

  @override
  String get studyOpenEntry => 'Open the original entry';

  @override
  String get studyOpenSourceDetails => 'Open source details';

  @override
  String studyMoreSources(int count) {
    return '+$count more';
  }

  @override
  String get studySessionDone => 'Session complete';

  @override
  String studySessionSummary(int known, int total) {
    return 'Knew $known of $total';
  }

  @override
  String get studyAllCaughtUp =>
      'Nothing is due in this deck right now. Come back later or review all cards.';

  @override
  String get studyReviewAll => 'Review all cards';

  @override
  String get studyResetProgress => 'Reset deck progress';

  @override
  String get studyResetDone => 'Deck progress reset';

  @override
  String get studyBackToDecks => 'Back to decks';

  @override
  String get studyQuizStemTopic =>
      'Which topic is this source quote cited for?';

  @override
  String studyQuizStemSubstance(String name) {
    return 'What is the molecular formula of $name?';
  }

  @override
  String get studyQuizStemGuideline =>
      'Which guideline does this summary describe?';

  @override
  String get studyQuizNote =>
      'Wrong options are other records of the same type from the app; nothing is invented.';

  @override
  String studyQuizQuestionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get studyQuizNext => 'Next question';

  @override
  String get studyQuizFinish => 'See results';

  @override
  String studyQuizScore(int correct, int total) {
    return 'Score: $correct of $total';
  }

  @override
  String get studyQuizMistakes => 'Review your mistakes';

  @override
  String get studyQuizNoMistakes => 'No mistakes — every answer was correct.';

  @override
  String studyQuizYourAnswer(String answer) {
    return 'Your answer: $answer';
  }

  @override
  String studyQuizCorrectAnswer(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get studyQuizRetry => 'New quiz';

  @override
  String get studyDeckNotFound => 'This deck is not available.';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody => 'The link may be outdated or incorrect.';

  @override
  String get notFoundHome => 'Go to Home';

  @override
  String get accountSignInEmailCode => 'Sign in (email code)';

  @override
  String get toolsReviewNote =>
      'Calculation modules are software-tested. Formulas and their sources have not yet been confirmed by an expert.';

  @override
  String searchAllStatus(String status) {
    return 'All results: $status';
  }

  @override
  String get researchOpenInBrowser => 'Open';

  @override
  String disciplinesComingSoon(int count) {
    return 'Coming soon ($count)';
  }

  @override
  String get modeRoleExpand => 'Choose a role (optional)';

  @override
  String get sourcesEmpty => 'No sources are available yet.';

  @override
  String get analysisTitle => 'Analysis';

  @override
  String get analysisIntro =>
      'Which specimens and methods — from sources. Not yet expert-reviewed.';

  @override
  String get analysisSpecimensTitle => 'Specimens';

  @override
  String get analysisSpecimensNote =>
      'A source reports a value in these specimens (not a threshold).';

  @override
  String get analysisNoSpecimens =>
      'The pack has no sourced specimen for this substance yet.';

  @override
  String analysisSourcedRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sourced records',
      one: '1 sourced record',
    );
    return '$_temp0';
  }

  @override
  String analysisSpecimenMethods(String methods) {
    return 'Methods in the same source: $methods';
  }

  @override
  String get analysisScreeningTitle => 'Screening (presumptive)';

  @override
  String get analysisScreeningNote =>
      'A screening result is presumptive and must be confirmed by a confirmation method.';

  @override
  String analysisConfirmedBy(String methods) {
    return 'Confirmation: $methods';
  }

  @override
  String get analysisConfirmationTitle => 'Confirmation methods';

  @override
  String analysisAfterScreening(String tests) {
    return 'After screening: $tests';
  }

  @override
  String get analysisMethodsTitle => 'Analytical methods';

  @override
  String get analysisMethodsRoleNote =>
      'Mentioned with this substance in a source; not a validated procedure.';

  @override
  String get analysisMethodsNotPaired =>
      'Sources do not tie these methods to a specific specimen.';

  @override
  String get analysisMetabolitesTitle => 'Metabolites to target';

  @override
  String analysisMetaboliteSpecimens(String specimens) {
    return 'Specimens: $specimens';
  }

  @override
  String get analysisEmpty =>
      'The content pack has no sourced analysis data (specimens, methods or metabolites) for this substance yet.';

  @override
  String get analysisShowSource => 'Show the source';

  @override
  String get specimenSubstancesTitle => 'Substances analysed in this specimen';

  @override
  String get specimenSubstancesNote =>
      'A source reports a value for each of these substances in this specimen.';

  @override
  String get specimenSubstancesNone =>
      'No substance in the pack is linked to this specimen yet.';

  @override
  String get quoteMachineTranslation => 'Automatic translation · not verified';

  @override
  String get quoteMachineTranslationSemantics =>
      'Automatic translation of the source excerpt, not verified by an expert. The original text above is the citation.';

  @override
  String quoteOriginalTitle(String title) {
    return 'Original title: $title';
  }

  @override
  String sourceSectionRef(String section) {
    return '§ $section';
  }

  @override
  String get sectionAbstract => 'Abstract';

  @override
  String get sectionIntroduction => 'Introduction';

  @override
  String get sectionBackground => 'Background';

  @override
  String get sectionMethods => 'Methods';

  @override
  String get sectionResults => 'Results';

  @override
  String get sectionDiscussion => 'Discussion';

  @override
  String get sectionConclusion => 'Conclusions';

  @override
  String get sectionCaseReport => 'Case report';

  @override
  String get sectionFigure => 'Figure';

  @override
  String get sectionTable => 'Table';

  @override
  String get sectionSupplement => 'Supplementary material';

  @override
  String get sectionTitle => 'Title';

  @override
  String researchAuthorsEtAl(String author) {
    return '$author et al.';
  }

  @override
  String get sectionComputedProperties => 'Computed properties';

  @override
  String get supTitle => 'Suggestions & support';

  @override
  String get supProfileHint =>
      'Ideas, bugs, scientific errors — the team replies here';

  @override
  String supUnreadHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new replies',
      one: '1 new reply',
    );
    return '$_temp0';
  }

  @override
  String get supNew => 'New request';

  @override
  String get supEmpty =>
      'You have not sent any requests yet. Share an idea, report a bug or a scientific error — we read every message.';

  @override
  String get supLoadFailed => 'Could not load requests. Check the connection.';

  @override
  String get supUnavailable =>
      'Requests need the online service, which is not connected in this build.';

  @override
  String get supSignInRequired =>
      'Sign in to send a request and receive replies.';

  @override
  String get supSignIn => 'Sign in';

  @override
  String get supCatSuggestion => 'Suggestion';

  @override
  String get supCatBug => 'Bug in the app';

  @override
  String get supCatScientificError => 'Scientific error';

  @override
  String get supCatFeatureRequest => 'Feature request';

  @override
  String get supCatTechSupport => 'Technical support';

  @override
  String get supCatGeneral => 'General question';

  @override
  String get supStatusNew => 'New';

  @override
  String get supStatusInReview => 'In review';

  @override
  String get supStatusAnswered => 'Answered';

  @override
  String get supStatusClosed => 'Closed';

  @override
  String get supCategory => 'Category';

  @override
  String get supSubject => 'Subject';

  @override
  String get supMessage => 'Message';

  @override
  String get supMessageHint =>
      'Describe what happened or what you suggest. Do not include personal data of third parties or case materials.';

  @override
  String supRelated(String id) {
    return 'Related record: $id';
  }

  @override
  String get supAttach => 'Attach screenshot';

  @override
  String get supAttachHint => 'JPEG or PNG, up to 5 MB.';

  @override
  String get supAttachRemove => 'Remove screenshot';

  @override
  String get supAttachTooLarge => 'The image is larger than 5 MB.';

  @override
  String get supAttachWrongType => 'Only JPEG or PNG images can be attached.';

  @override
  String get supAttachment => 'Screenshot';

  @override
  String get supPrivacyNote =>
      'Your message, the screenshot and your account email are stored on our server only to answer you. Only the FORENSIC EXPERT team can read them. They are deleted together with your account.';

  @override
  String get supConsent =>
      'I agree that this message is processed to answer my request.';

  @override
  String get supSend => 'Send';

  @override
  String get supSending => 'Sending…';

  @override
  String get supSent => 'Request sent. We will reply here.';

  @override
  String get supConsentRequired => 'Please confirm your consent.';

  @override
  String get supSubjectRequired => 'Enter a subject.';

  @override
  String get supMessageRequired => 'Enter a message.';

  @override
  String get supRateLimited => 'Too many messages. Please try again later.';

  @override
  String get supFailed => 'Not sent. Check the connection and try again.';

  @override
  String get supClosedNote =>
      'This request is closed. Create a new one if you need more help.';

  @override
  String get supReplyHint => 'Write a message';

  @override
  String get supYou => 'You';

  @override
  String get supTeam => 'FORENSIC EXPERT team';

  @override
  String get supNotFound => 'Request not found.';

  @override
  String supUnreadBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread replies',
      one: '1 unread reply',
    );
    return '$_temp0';
  }

  @override
  String get supBannerText => 'The team replied to your request.';

  @override
  String get supBannerOpen => 'View';

  @override
  String get supBannerDismiss => 'Dismiss';

  @override
  String get supReportError => 'Report an error';

  @override
  String supReportErrorSubject(String title) {
    return 'Error in: $title';
  }

  @override
  String supMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$_temp0';
  }

  @override
  String get supMoreActions => 'More actions';

  @override
  String get admNavInbox => 'Requests inbox';

  @override
  String admNavInboxHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count awaiting a reply',
      one: '1 awaiting a reply',
      zero: 'Nothing awaiting a reply',
    );
    return '$_temp0';
  }

  @override
  String get admNavUsers => 'Users';

  @override
  String get admNavUsersHint => 'Search, filters, access level';

  @override
  String get admNavAudit => 'Audit log';

  @override
  String get admNavAuditHint => 'Every admin action, without message text';

  @override
  String get admNavModeration => 'Publication moderation';

  @override
  String admNavModerationHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in the queue',
      zero: 'Queue is empty',
    );
    return '$_temp0';
  }

  @override
  String get admOverview => 'Overview';

  @override
  String get admStatUsers => 'Users';

  @override
  String get admStatNewToday => 'New today';

  @override
  String get admStatNew7d => 'New in 7 days';

  @override
  String get admStatNew30d => 'New in 30 days';

  @override
  String get admStatActive7d => 'Active in 7 days';

  @override
  String get admStatActive30d => 'Active in 30 days';

  @override
  String get admStatPro => 'Pro (server grants)';

  @override
  String get admStatFree => 'Free';

  @override
  String get admStatAwaiting => 'Requests awaiting reply';

  @override
  String get admStatPublications => 'Articles awaiting moderation';

  @override
  String get admStatAiTotal => 'AI questions (all time)';

  @override
  String get admStatAi7d => 'AI questions in 7 days';

  @override
  String get admStatProfiles => 'Professional profiles';

  @override
  String get admStatVerified => 'Verified professionals';

  @override
  String get admModesNote =>
      'Students vs experts: not available — the usage mode is a device setting and is not stored on the server. Professional profiles and verified professionals are shown instead.';

  @override
  String get admActiveNote =>
      'Active = signed in, opened the app (device check-in) or asked the AI within the window.';

  @override
  String get admProNote =>
      'Pro counts server grants only; store purchases are verified on the device.';

  @override
  String get admChart14d => 'Last 14 days: sign-ups and AI questions';

  @override
  String get admChartSignups => 'Sign-ups';

  @override
  String get admChartAi => 'AI questions';

  @override
  String get admByCategory => 'Requests by category';

  @override
  String get admStatsUnavailable => 'Statistics are unavailable right now.';

  @override
  String get admNotAuthorizedTitle => 'Access denied';

  @override
  String get admNotAuthorized =>
      'This section is for administrators only. Access is checked on the server.';

  @override
  String get admBackToProfile => 'Back to Profile';

  @override
  String get admFilterAll => 'All';

  @override
  String get admFilterAwaiting => 'Awaiting reply';

  @override
  String get admAllCategories => 'All categories';

  @override
  String get admInboxSearch => 'Subject or email';

  @override
  String get admInboxEmpty => 'No requests match the filter.';

  @override
  String get admLoadMore => 'Load more';

  @override
  String admShown(int shown, int total) {
    return '$shown of $total';
  }

  @override
  String get admReply => 'Write a reply';

  @override
  String get admReplySend => 'Send reply';

  @override
  String get admReplySent => 'Reply sent. The user will see it in the app.';

  @override
  String get admSetStatus => 'Change status';

  @override
  String get admStatusChanged => 'Status updated.';

  @override
  String admAuthor(String email) {
    return 'From: $email';
  }

  @override
  String admUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new messages',
      one: '1 new message',
    );
    return '$_temp0';
  }

  @override
  String get admUsersSearch => 'Email or name';

  @override
  String get admRoleAny => 'Any role';

  @override
  String get admRoleAdmin => 'Admins';

  @override
  String get admRoleModerator => 'Moderators';

  @override
  String get admTierAny => 'Any plan';

  @override
  String get admTierFree => 'Free';

  @override
  String get admTierPro => 'Pro plan';

  @override
  String get admUsersEmpty => 'No users match the filter.';

  @override
  String admUserJoined(String date) {
    return 'Joined $date';
  }

  @override
  String admUserLastActive(String date) {
    return 'Last activity $date';
  }

  @override
  String get admUserNoActivity => 'No activity recorded';

  @override
  String get admUserActive => 'Active';

  @override
  String get admUserUnconfirmed => 'Email not confirmed';

  @override
  String get admUserBanned => 'Blocked';

  @override
  String get admPrev => 'Previous';

  @override
  String get admNext => 'Next';

  @override
  String get admAuditEmpty => 'No admin actions yet.';

  @override
  String get admAuditSystem => 'system / console';

  @override
  String get admActSupportReply => 'Replied to a request';

  @override
  String get admActSupportStatus => 'Request status changed';

  @override
  String get admActSupportView => 'Opened a request';

  @override
  String get admActUsersView => 'Viewed the users list';

  @override
  String get admActAccessSet => 'Access level changed';

  @override
  String get admActRoleGranted => 'Role granted';

  @override
  String get admActRoleRevoked => 'Role revoked';

  @override
  String get admActRoleChanged => 'Role changed';

  @override
  String get admActOther => 'Admin action';

  @override
  String get admRetry => 'Try again';

  @override
  String imageAttrPubchemRdkit(String cid) {
    return 'Structure drawn from PubChem CID $cid SMILES with RDKit';
  }

  @override
  String get imageAttrOriginalSchematic =>
      'Original schematic — FORENSIC EXPERT';

  @override
  String get supRelatedUnknown => 'record in the content pack';

  @override
  String onbStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get disclaimerIntroTitle => 'Before you start';

  @override
  String get disclaimerPointReference =>
      'A scientific reference and learning tool — it never issues expert conclusions.';

  @override
  String get disclaimerPointLab =>
      'It does not replace validated lab methods, protocols, the law or a specialist’s judgement.';

  @override
  String get disclaimerPointMedical =>
      'For medical questions, consult a qualified doctor.';

  @override
  String get disclaimerFullText => 'Full text';

  @override
  String get accountReadyTitle => 'You’re all set';

  @override
  String get accountReadyBody =>
      'The scientific database, search and calculators work offline — no account needed.';

  @override
  String get accountStartNow => 'Start';

  @override
  String get accountBenefitsNote =>
      'An account adds professional verification, sync and cloud AI. You can sign in any time in Profile.';

  @override
  String get homeGreetingStudent => 'What shall we study today?';

  @override
  String get homeGreetingExpert => 'What are you working on today?';

  @override
  String get homeAreasTitle => 'Areas';

  @override
  String get homeActLearnTitle => 'Study & quizzes';

  @override
  String get homeActLearnBody => 'Flashcards, quizzes, exam practice';

  @override
  String get homeActGuidelinesBody => 'Practical guidance by discipline';

  @override
  String get homeActSubstancesBody => 'Properties, analysis, sources';

  @override
  String get homeActMethodsBody => 'Analytical methods, sample prep';

  @override
  String get homeActToolsTitle => 'Calculators';

  @override
  String get homeActToolsBody => 'Lab and forensic calculations';

  @override
  String get homeActAiBody => 'Ask a question — answers cite sources';

  @override
  String get homeTrustNote =>
      'Database under expert review · every entry shows its source and status';

  @override
  String get profileSignInBody =>
      'Sync, verification and cloud AI. No password needed.';

  @override
  String get profileSectionHelp => 'Help and community';

  @override
  String get profileSectionAppearance => 'Appearance';

  @override
  String homeAllDisciplinesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count disciplines',
      one: '$count discipline',
    );
    return '$_temp0';
  }

  @override
  String get calcCopyResult => 'Copy result';

  @override
  String get calcCopied =>
      'Result copied with inputs, formula and method version.';

  @override
  String get calcCopyInputs => 'Inputs';

  @override
  String get calcErrorRequired => 'Fill in all required fields.';

  @override
  String get calcEstimatedRange => 'Estimated range';

  @override
  String get calcLockedTitle => 'Included in Expert Pro';

  @override
  String get calcLockedBody =>
      'This calculator opens with the Expert Pro plan. Dilution and the concentration unit converter are free.';

  @override
  String get calcLodUnitNote =>
      'DL and QL are in the concentration units of the calibration x axis.';

  @override
  String get calcHenssgeFormulaLow => 'Applied: ambient ≤ 23 °C';

  @override
  String get calcHenssgeFormulaHigh => 'Applied: ambient > 23 °C';

  @override
  String get admRolePublicationModerator => 'Publication moderator';

  @override
  String get rdGlanceTitle => 'At a glance';

  @override
  String get rdGlanceNote =>
      'From the sourced sections below. Quotes and status are inside each section.';

  @override
  String get rdGlanceFormula => 'Formula';

  @override
  String rdGlanceMolarMass(String value) {
    return '$value g/mol';
  }

  @override
  String get rdGlanceSpecimens => 'Specimens';

  @override
  String get rdGlanceMethods => 'Methods';

  @override
  String get rdGlanceMetabolites => 'Metabolites';

  @override
  String get rdGlanceConcentrations => 'Concentrations';

  @override
  String get rdGlanceSources => 'Sources';

  @override
  String rdGlanceRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sourced records',
      one: '1 sourced record',
    );
    return '$_temp0';
  }

  @override
  String rdSourcesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources',
      one: '1 source',
    );
    return '$_temp0';
  }

  @override
  String rdGlanceMore(int count) {
    return '+$count more';
  }

  @override
  String get rdGlanceLockedHint =>
      'Details below open with Pro. Names, warnings and sources stay free.';

  @override
  String get rdJumpTo => 'Go to section';

  @override
  String rdGuidelineMeta(int sections, String refs) {
    return '$sections sections · $refs';
  }

  @override
  String get toolBeerLambertName => 'Beer–Lambert law (A = ε·l·c)';

  @override
  String get toolBeerLambertDesc =>
      'Find absorbance, concentration or absorptivity from A = ε·l·c, on a molar or mass basis, with units.';

  @override
  String get calcBeerAbsorbance => 'Absorbance';

  @override
  String get calcBeerAbsorptivityMolar => 'Molar absorptivity';

  @override
  String get calcBeerAbsorptivityMass => 'Specific (mass) absorptivity';

  @override
  String get calcBeerConcentration => 'Concentration';

  @override
  String get calcBeerPath => 'Path length (l)';

  @override
  String get calcBeerResultUnit => 'Result unit (c)';

  @override
  String get calcBeerBasis => 'Absorptivity basis';

  @override
  String get calcBeerBasisMolar => 'Molar (ε, mol/L)';

  @override
  String get calcBeerBasisMass => 'Mass (a, g/L)';

  @override
  String get calcBeerFormulaNote =>
      'A — absorbance (dimensionless); ε — molar absorptivity, L·mol⁻¹·cm⁻¹ (or a — mass absorptivity, L·g⁻¹·cm⁻¹); l — path length, cm; c — concentration, mol/L (or g/L).';

  @override
  String get calcBeerErrorBasis =>
      'The concentration unit does not match the absorptivity basis: use mol/L units with molar ε and g/L-type units with mass a.';

  @override
  String get calcBeerAssumptionDefinition =>
      'Definitional relationship: absorbance is proportional to path length and concentration. No absorptivity values are built in — enter a value from your own calibration or a verified source for the same wavelength, solvent and pH.';

  @override
  String get calcBeerAssumptionBlank =>
      'A is the sample absorbance corrected for the blank (reagent or matrix blank) at the chosen wavelength.';

  @override
  String get calcBeerLimitationLinear =>
      'Valid only within the working range where linearity has been shown by calibration; ICH Q2(R2) §3.2.2.1 recommends at least five concentrations across the range. Outside it, dilute the sample or use the calibration curve.';

  @override
  String get calcBeerLimitationIdentity =>
      'Absorbance does not identify a substance. UV-Vis has low specificity; identity must be confirmed by another technique (for example, chromatography with mass spectrometry).';

  @override
  String get calcBeerReference =>
      'IUPAC Gold Book: “Beer–Lambert law”, doi:10.1351/goldbook.B00626 · Swinehart DF. The Beer-Lambert law. J Chem Educ 1962;39(7):333, doi:10.1021/ed039p333 · Linearity: ICH Q2(R2) (2023), §3.2.2.1.';

  @override
  String get calcBeerRelatedTools => 'Related tools: calibration and limits';

  @override
  String get citeCopy => 'Copy citation';

  @override
  String get citeAllSources => 'Copy reference list';

  @override
  String citeListTitle(int count) {
    return 'Reference list · $count';
  }

  @override
  String get citeStyleLabel => 'Citation style';

  @override
  String get citeStyleGost => 'GOST';

  @override
  String get citeStyleVancouver => 'Vancouver';

  @override
  String get citeStyleApa => 'APA 7';

  @override
  String get citeCopyButton => 'Copy';

  @override
  String get citeCopied => 'Citation copied';

  @override
  String citeListCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count references copied',
      one: '1 reference copied',
    );
    return '$_temp0';
  }

  @override
  String get citeVerifyNote =>
      'The app is a reference tool: verify each source against the original before citing it in an expert conclusion.';
}
