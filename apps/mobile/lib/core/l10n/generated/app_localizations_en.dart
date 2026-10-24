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
  String get moduleSubstances => 'Substances';

  @override
  String get moduleLearn => 'Learning';

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
  String get settingsMode => 'Mode';

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
  String get legalDraftNotice => 'Last updated: 18 Oct 2026';

  @override
  String get privacySummary =>
      'The core library and calculators work offline. Search history, progress and your optional profile (name, organisation, specialty) stay on your device. Profile details and qualification documents are sent only if you submit a professional verification application once that service is connected; documents are stored privately and never shown publicly. The app contains no advertising SDKs. Personal or case data is never sent to AI automatically. Your profile photo (if you set one) stays on this device only.\n\nInvitations: if you use a colleague’s invitation code, the server stores only the link between the two accounts and a salted hash of your email (to prevent abuse after account re-creation). Inviters see only totals — never your name, email, profile or documents. The app never reads your contacts.\n\nSuggestions & support: the message you send in «Suggestions & support», an optional screenshot (JPEG/PNG/WebP only, up to 5 MB), the request type and your account e-mail are stored on our server only to reply to you and improve the app. Only an authorised FORENSIC EXPERT team administrator can see them; other users never can. Replies are signed «FORENSIC EXPERT team», not with an administrator\'s name. Administrator actions are logged (without message text). Your consent is requested before a request is sent. Requests and screenshots are not shared with third parties and are not used for advertising or AI training. If you delete your account, your requests, messages and screenshots are deleted permanently.\n\nExpert casebook: your entries (title, case reference, text, linked items and copied statements) are stored only on this device. They are not sent to a server, to telemetry, to AI or to other users, and are not included in backups. An entry is shared or copied only when you press the button. You can delete the casebook at any time via “Casebook → Clear entire casebook”; if you delete the app, the entries are gone too.';

  @override
  String get aboutBody =>
      'Professional forensic reference, education and scientific calculation software.';

  @override
  String get aboutVersions =>
      'The app version and the scientific database version are tracked separately.';

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
  String get learnEmptyCourses =>
      'Courses will appear after expert review of the learning content.';

  @override
  String get contentLoading => 'Loading scientific database…';

  @override
  String get libraryNotInstalled =>
      'The scientific database is not installed in this build.';

  @override
  String get aboutTrademarkPending =>
      'Name and logo: trademark clearance pending.';

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
      'A screening result is not a confirmed identification. A positive screen is presumptive and requires a validated confirmatory method.';

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
  String get aiExperienceProfessional => 'Short';

  @override
  String get aiExperienceTutor => 'Detailed';

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
      'Bookmarks, search history, recently viewed records and lesson progress will be deleted from this device only. The scientific database and your account are not affected — use “Delete account” to delete the account.';

  @override
  String get deleteLocalDataConfirm => 'Delete';

  @override
  String get deleteLocalDataDone => 'Local data deleted';

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
  String get homeLibraryBody =>
      'Everything: substances, methods, standards, references';

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
  String get studyTitle => 'Practice';

  @override
  String get studyEntrySubtitle =>
      'Flashcards and a self-check quiz built only from sourced records in the app';

  @override
  String get studyIntro =>
      'Every card and question is built from a record or guideline that already exists in the app, together with its source. Guideline questions are written by the editors from the card’s facts. Material that is still under expert review is labelled.';

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
      'Too few related options for a test — flashcards only';

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
      'Wrong options are other records of the same field or group only; nothing is invented. Practice only — not part of the graded exam.';

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
  String get quoteMachineTranslation => 'Machine translation — not reviewed';

  @override
  String get quoteMachineTranslationSemantics =>
      'Machine translation of a source quote, not reviewed by an expert. The original quote is available under «Original text».';

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
  String get homeActLearnTitle => 'Learning';

  @override
  String get homeActLearnBody => 'Courses, practice, group test';

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

  @override
  String get guidelineToksAttribution =>
      'Source: Prof. Yuldashev Z.A. and co-authors, «Toxicological chemistry» teaching complexes (Tashkent Pharmaceutical Institute, 2025) — used with the author’s permission, free for everyone.';

  @override
  String get studySectionTeaching => 'Teaching complexes';

  @override
  String get studyDeckToks => 'Toxicological chemistry (Yuldashev Z.A.)';

  @override
  String get studyFrontQuestion => 'Recall the answer, then flip the card';

  @override
  String get studyQuizNoteAuthored =>
      'Questions and wrong options were written independently from the facts in the guideline cards; the correct answer and its page are given in the cited source.';

  @override
  String studySourcePages(String pages) {
    return 'pp. $pages';
  }

  @override
  String reagentHazardBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hazard notes — read before preparing',
      one: '1 hazard note — read before preparing',
    );
    return '$_temp0';
  }

  @override
  String get reagentHazardGhs => 'GHS hazard statements (PubChem)';

  @override
  String get reagentHazardGeneral => 'General safety advice (app guidance)';

  @override
  String reagentRecipeSource(String title) {
    return 'Source: $title';
  }

  @override
  String get reagentMachineDraft =>
      'Translation is an automatic draft and has not been reviewed by a specialist. Numbers are copied from the source unchanged; check them against the original text below.';

  @override
  String reagentVariant(String label) {
    return 'Method $label';
  }

  @override
  String reagentMakeUpTo(String value) {
    return 'to $value';
  }

  @override
  String get reagentUnitG => 'g';

  @override
  String get reagentUnitMl => 'mL';

  @override
  String get reagentUnitL => 'L';

  @override
  String reagentDropsAmount(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$value drops',
      one: '$value drop',
    );
    return '$_temp0';
  }

  @override
  String get reagentPurpose => 'Purpose (from the source)';

  @override
  String get reagentNote => 'Note from the source';

  @override
  String get reagentAmbiguity => 'Check against the original';

  @override
  String get reagentOriginalText => 'Original text (Russian)';

  @override
  String get reagentOriginalHint =>
      'Verbatim from the source, kept for traceability (OCR errors not corrected).';

  @override
  String get reusePermissionGranted => 'RIGHTS HOLDER\'S PERMISSION';

  @override
  String get guidelineGmtAttribution =>
      'Source: Yuldashev Z.A. et al., «Analysis of narcotic substances. Teaching manual» (Tashkent Pharmaceutical Institute, Tashkent, 2024) — used with the author’s permission, free for everyone.';

  @override
  String get studyDeckGmt => 'Drug analysis (Yuldashev Z.A.)';

  @override
  String get courtTitle => 'Court testimony: preparation';

  @override
  String get courtSubtitle =>
      'Questions experts are asked about their conclusions, and how to prepare a scientifically sound answer';

  @override
  String get courtDisclaimer =>
      'Preparation material; not legal advice; a conclusion rests only on the expert\'s own examination.';

  @override
  String get courtSearchHint => 'Search questions';

  @override
  String get courtNoResults => 'Nothing found. Try another word.';

  @override
  String get courtEmpty => 'The section content could not be loaded.';

  @override
  String get courtTopics => 'Topics';

  @override
  String courtQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String get courtTests => 'What the court is testing';

  @override
  String get courtPrepare => 'Preparing your answer';

  @override
  String get courtBlockDocuments => 'Have ready: documents and data';

  @override
  String get courtBlockExplain => 'Principles to explain';

  @override
  String get courtBlockPitfalls => 'Typical pitfalls';

  @override
  String get courtRelated => 'Related in the app';

  @override
  String get courtCopyCitation => 'Copy citation';

  @override
  String get courtCitationCopied => 'Citation copied';

  @override
  String get courtPractice => 'Practice mode';

  @override
  String get courtPracticeBody =>
      'A random question: think through your answer, then open the checklist.';

  @override
  String get courtPracticeThink =>
      'First prepare your own answer: which documents and which principles would you rely on?';

  @override
  String get courtPracticeReveal => 'Show the checklist';

  @override
  String get courtPracticeHint => 'Tap to show what the court is testing';

  @override
  String get courtPracticeNext => 'Next question';

  @override
  String get courtPracticeOpen => 'Open full question';

  @override
  String courtPracticeProgress(int count) {
    return 'Questions practised: $count';
  }

  @override
  String courtQuestionOf(int index, int count) {
    return 'Question $index of $count';
  }

  @override
  String get courtShortAnswer => 'Short answer';

  @override
  String get courtBasisHeader => 'Scientific and legal basis of the answer';

  @override
  String get courtBasis => 'Scientific / legal basis';

  @override
  String get courtWhereWritten => 'Where is it written?';

  @override
  String get courtSourceUnverified => 'Source not verified';

  @override
  String get courtSourceUnverifiedNote =>
      'The exact location in this source has not been confirmed from the original text.';

  @override
  String get courtFollowups => 'Follow-up questions';

  @override
  String get courtLimitations => 'Limitations, exceptions and uncertainties';

  @override
  String get courtExport => 'Copy sources';

  @override
  String get courtExportText => 'As text';

  @override
  String get courtExportBibtex => 'BibTeX';

  @override
  String get courtExportCopied => 'Sources copied';

  @override
  String courtLawNote(String date) {
    return 'Uzbekistan · lex.uz · text as of $date';
  }

  @override
  String get courtBookNote =>
      'Used with the author\'s permission; free for everyone';

  @override
  String courtLocArticle(String article) {
    return 'Art. $article';
  }

  @override
  String courtLocArticlePart(String article, String part) {
    return 'Art. $article, part $part';
  }

  @override
  String courtLocSection(String section) {
    return '§ $section';
  }

  @override
  String courtLocPdfPage(String page) {
    return 'PDF p. $page';
  }

  @override
  String courtLocPages(String pages) {
    return 'pp. $pages';
  }

  @override
  String courtLocRecommendation(String n) {
    return 'Recommendation $n';
  }

  @override
  String courtLocGuidanceNote(String n) {
    return 'Guidance Note $n';
  }

  @override
  String get courtLocAbstract => 'Abstract';

  @override
  String get courtLocScope => 'Scope (official page)';

  @override
  String get courtLocTitle => 'Title and bibliographic record';

  @override
  String get courtLocGlossary => 'Glossary';

  @override
  String get courtPrinciples => 'Integrity principles';

  @override
  String get courtPrinciplesBody =>
      'Report everything, say “I don\'t know”, correct your errors, stay independent';

  @override
  String get courtPrinciplesIntro =>
      'This section never teaches hiding, softening or misrepresenting real results.';

  @override
  String get courtJurisdictionUz =>
      'Legal questions: under the law of Uzbekistan';

  @override
  String get courtJurisdictionIntl =>
      'Legal questions: general international principles. Select Uzbekistan to see its laws.';

  @override
  String get courtJurisdictionChange => 'Choose jurisdiction';

  @override
  String get courtPendingTopic => 'In preparation — sources being verified';

  @override
  String get courtSimulator => 'Court questioning simulator';

  @override
  String get courtSimulatorBody =>
      'Answer a judge, prosecutor, defence lawyer or another expert — scored on accuracy, sources, limitations and impartiality.';

  @override
  String get courtSimulatorNote =>
      'The simulator never predetermines a case outcome and never teaches false testimony, evasion or hiding results.';

  @override
  String get courtRoleJudge => 'Judge';

  @override
  String get courtRoleProsecutor => 'Prosecutor';

  @override
  String get courtRoleDefense => 'Defence lawyer';

  @override
  String get courtRoleExpert => 'Another expert';

  @override
  String get courtSimContext => 'Situation';

  @override
  String get courtSimYourAnswer => 'Your own answer (optional)';

  @override
  String get courtSimYourAnswerHint => 'Type your answer…';

  @override
  String get courtSimEvaluateText => 'Check my wording';

  @override
  String get courtSimChoose => 'Choose the best answer';

  @override
  String get courtSimCheck => 'Check answer';

  @override
  String get courtSimResult => 'Evaluation';

  @override
  String courtSimTotal(int score, int max) {
    return 'Total: $score/$max';
  }

  @override
  String get courtSimBest => 'Model answer';

  @override
  String get courtSimNext => 'Next scenario';

  @override
  String get courtSimOpenQuestion => 'Open the related card';

  @override
  String get courtSimFreeTextNote =>
      'Automatic, keyword-based and approximate. Compare scientific accuracy with the model answer yourself.';

  @override
  String get courtSimFlagOverstatement =>
      'Absolute wording found (“100%”, “definitely”…) — certainty may be overstated.';

  @override
  String get courtSimFlagEvasion =>
      'Evasive wording found — give the reason and what lies within your field.';

  @override
  String get courtSimTooShort => 'The answer is too short.';

  @override
  String get courtCritAccuracy => 'Scientific accuracy';

  @override
  String get courtCritSources => 'Reliance on sources';

  @override
  String get courtCritLimitations => 'Explaining limitations';

  @override
  String get courtCritImpartiality => 'Impartiality';

  @override
  String courtScenarioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scenarios',
      one: '1 scenario',
    );
    return '$_temp0';
  }

  @override
  String courtScoreSemantics(String criterion, int score) {
    return '$criterion: $score of 2';
  }

  @override
  String get courtDrill => 'Role drill';

  @override
  String get courtDrillBody =>
      'Judge → prosecutor → defence → another expert, one after another';

  @override
  String courtDrillStep(int index, int count) {
    return 'Step $index of $count';
  }

  @override
  String get courtDrillNext => 'Next role';

  @override
  String get courtDrillDone => 'Role drill complete';

  @override
  String get courtStats => 'Statistics and history';

  @override
  String get courtStatsBody =>
      'Your scores and attempt history — stored on this device only';

  @override
  String courtStatsAttempts(int count) {
    return 'Attempts: $count';
  }

  @override
  String get courtStatsAverage => 'Average score by criterion';

  @override
  String get courtStatsHistory => 'History';

  @override
  String get courtStatsEmpty => 'No attempts yet.';

  @override
  String get courtStatsClear => 'Clear history';

  @override
  String get courtAi => 'AI analysis';

  @override
  String get courtAiUnavailable =>
      'AI analysis is not connected yet — coming soon. Your answer was not sent anywhere.';

  @override
  String get courtSimPartialUnverified =>
      'Partial — unverified source: this answer relies on a source whose location is not verified.';

  @override
  String get courtSimReviewNote =>
      'Scores are based on material awaiting expert review (NEEDS_REVIEW); the model answer is not a verified truth either.';

  @override
  String get glossaryTitle => 'Scientific glossary';

  @override
  String get glossaryIntro =>
      'Terms in Uzbek, Russian and English. Translations remain machine drafts until a terminologist reviews them.';

  @override
  String get glossaryFilterHint => 'Filter terms (uz, ru, en)';

  @override
  String get glossaryEmpty => 'No terms match the filter.';

  @override
  String get glossaryMachineDraft => 'Machine translation — not verified';

  @override
  String get glossaryMachineDraftNote =>
      'These translations were produced automatically and have not been checked by a terminologist. Use them for orientation; for reports, check the term in an authoritative source.';

  @override
  String get glossaryStatusTranslated => 'Translated — not reviewed';

  @override
  String get glossaryStatusReviewed => 'Reviewed translation';

  @override
  String glossaryOriginal(String language, String term) {
    return 'In the source ($language): $term';
  }

  @override
  String get glossaryKindTerm => 'Term';

  @override
  String get glossaryKindAbbreviation => 'Abbreviation';

  @override
  String get glossaryKindIdentifier => 'Identifier';

  @override
  String get glossaryKindFormula => 'Formula';

  @override
  String get glossaryUsedIn => 'Used in guideline cards';

  @override
  String get glossaryNoCards => 'Not linked to a guideline card yet.';

  @override
  String get glossaryOpenInGlossary => 'Open in glossary';

  @override
  String get guidelineTerms => 'Terms';

  @override
  String get guidelineTermsHint =>
      'Tap a term to see it in Uzbek, Russian and English.';

  @override
  String get studyModePractice => 'Practice';

  @override
  String get studyModeExam => 'Exam';

  @override
  String get studyModePracticeBanner =>
      'Practice mode — not graded. After each answer you see whether it is right, why, and the source.';

  @override
  String get studyModeExamBanner =>
      'Graded exam — only questions with an author-written answer key, three related wrong options, an explanation and a page or section in the source. Answers and explanations are shown at the end.';

  @override
  String studyExamCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exam: $count questions',
      one: 'Exam: 1 question',
      zero: 'No exam questions',
    );
    return '$_temp0';
  }

  @override
  String get studyPracticeOnly => 'Practice only';

  @override
  String get studyExamUnavailable =>
      'No exam for this set: its questions are generated automatically or lack an explanation or page in the source. Use Practice.';

  @override
  String get studyExamDraftLanguage =>
      'The exam is available in Uzbek: the English translation of these questions is still a draft.';

  @override
  String get studyQuizFlashcardsOnly =>
      'Too few related options for a test — flashcards only';

  @override
  String get studyTfQuestion => 'Is this answer correct?';

  @override
  String get studyTfProposed => 'Proposed answer';

  @override
  String get studyTrue => 'Correct';

  @override
  String get studyFalse => 'Incorrect';

  @override
  String get studyTfNote =>
      'Where fewer than three related wrong options exist, the question is shown as Correct / Incorrect.';

  @override
  String studyExplainTopic(String topic) {
    return 'This statement is cited for “$topic”. The other options are topics of the same field whose sources say something else.';
  }

  @override
  String get studyExplainSourceSays => 'The source states:';

  @override
  String studyExplainSubstance(String name, String formula) {
    return 'Molecular formula of $name in its identity record: $formula. The other options are formulas of substances from the same group.';
  }

  @override
  String studyExplainGuideline(String title) {
    return 'This summary belongs to the guideline card “$title”. The other options are cards of the same area.';
  }

  @override
  String get studyOpenSource => 'Open source';

  @override
  String get studyQuoteTranslated =>
      'Quote from the source — machine translation, not reviewed';

  @override
  String get studyShowOriginalQuote => 'Show the original quote';

  @override
  String studySourceSection(String section) {
    return 'Section: $section';
  }

  @override
  String get studyExamResultTitle => 'Exam result';

  @override
  String get studyExamReview => 'Answers and explanations';

  @override
  String studyExamPercent(int percent) {
    return '$percent% correct';
  }

  @override
  String get studyDeckMixedTopics => 'Other topics (small sets combined)';

  @override
  String get studyDeckMixedSubstances => 'Other groups (small sets combined)';

  @override
  String get studyDeckMixedGuidelines =>
      'Other guidelines (small sets combined)';

  @override
  String get glossaryShortExplanation => 'Short explanation';

  @override
  String glossaryAbbrevSemantics(String abbr) {
    return 'Abbreviation $abbr: tap for a short explanation';
  }

  @override
  String get trStatusMachineDraft => 'Machine translation — not reviewed';

  @override
  String get trStatusTerminologyChecked =>
      'Machine translation — terminology checked, content not reviewed';

  @override
  String get trStatusClaimChecked =>
      'Machine translation — numbers and units checked, not reviewed by an expert';

  @override
  String get trStatusReviewed => 'Translation reviewed by an expert';

  @override
  String get trStatusOfficial => 'Official text';

  @override
  String get trOriginalShow => 'Original text';

  @override
  String get trOriginalHide => 'Hide original text';

  @override
  String get trOriginalQuoteShow => 'Show the quote from the original source';

  @override
  String trOriginalTitle(String title) {
    return 'Original title: $title';
  }

  @override
  String trNotTranslated(String language) {
    return 'An English translation of this text is not available yet — original language: $language';
  }

  @override
  String trTitleNotTranslated(String language) {
    return 'No English translation of the title yet — original language: $language';
  }

  @override
  String trInOriginalLanguage(String language) {
    return 'original: $language';
  }

  @override
  String trLanguageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'en': 'English',
      'ru': 'Russian',
      'uz': 'Uzbek',
      'de': 'German',
      'fr': 'French',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String get trQuoteTranslatedLabel => 'Source quote (translation)';

  @override
  String trTranslationSemantics(String status) {
    return 'Translation of the original text. $status. The original is available under «Original text».';
  }

  @override
  String get imageCaptionSection => 'Caption in the source';

  @override
  String get trTopicSummaryLabel => 'Brief explanation';

  @override
  String get trTopicSummaryNote =>
      'Compiled from the sourced statements on this card; the original quote is below.';

  @override
  String get legalTitleUnofficial =>
      'Unofficial translation of the title — not reviewed';

  @override
  String legalTitleOfficialIn(String language) {
    return 'Official title ($language)';
  }

  @override
  String get glossaryLibraryArticles => 'Glossary articles in the library';

  @override
  String get trStatusDerivedDraft => 'Automatic explanation — not reviewed';

  @override
  String get casebookTitle => 'Expert casebook';

  @override
  String get casebookTileHint =>
      'Private notes with source-backed limitations — stored only on this device';

  @override
  String get casebookPrivacyBanner =>
      'Stored only on this device. Nothing is sent to a server, to AI or to other users. Deleting the app or clearing the casebook removes it permanently. Do not enter personal data of people involved in a case.';

  @override
  String get casebookEmptyTitle => 'Your casebook is empty';

  @override
  String get casebookEmptyBody =>
      'Create an entry for your work and add source-backed limitations from guideline cards. Everything stays on this device.';

  @override
  String get casebookNewEntry => 'New entry';

  @override
  String get casebookUntitled => 'Untitled entry';

  @override
  String get casebookEntryTitleField => 'Title';

  @override
  String get casebookCaseRefField => 'Case reference (optional)';

  @override
  String get casebookCaseRefHint => 'Your own label, e.g. an internal number';

  @override
  String get casebookDateField => 'Date';

  @override
  String get casebookBodyField => 'Notes';

  @override
  String get casebookSave => 'Save';

  @override
  String get casebookSaved => 'Saved on this device';

  @override
  String get casebookLinksTitle => 'Linked items';

  @override
  String get casebookLinksEmpty =>
      'No linked substances, methods, guideline cards or sources yet.';

  @override
  String get casebookAddLink => 'Link an item';

  @override
  String get casebookLinkSearchHint =>
      'Search substance, method, guideline, source…';

  @override
  String get casebookLinkNoResults => 'Nothing found. Try another term.';

  @override
  String get casebookLinkRemove => 'Remove link';

  @override
  String get casebookBlocksTitle => 'Source-backed statements';

  @override
  String get casebookBlocksEmpty =>
      'No statements yet. Add a limitation or caution from a guideline card — the source and its section are copied with it.';

  @override
  String get casebookAddBlock => 'Add limitation or caution';

  @override
  String get casebookPickerTitle => 'Choose a statement';

  @override
  String get casebookPickerSearchHint => 'Filter by card or text';

  @override
  String get casebookPickerEmpty => 'No matching limitations found.';

  @override
  String get casebookKindLimitation => 'Limitation';

  @override
  String get casebookKindCaution => 'Caution';

  @override
  String get casebookKindAi => 'AI answer';

  @override
  String get casebookAiUnverified => 'AI-generated — unverified';

  @override
  String get casebookSourceLabel => 'Source';

  @override
  String get casebookLocationLabel => 'Section';

  @override
  String get casebookPagesLabel => 'pp.';

  @override
  String get casebookSourcesLabel => 'Sources';

  @override
  String get casebookBlockRemove => 'Remove statement';

  @override
  String get casebookAddToCasebook => 'Add to casebook';

  @override
  String get casebookChooseEntry => 'Add to which entry?';

  @override
  String get casebookChooseNew => 'New entry';

  @override
  String get casebookAiAddNote =>
      'This AI text will be marked “AI-generated — unverified”. Check it against the sources before relying on it.';

  @override
  String casebookAddedTo(String title) {
    return 'Added to “$title”';
  }

  @override
  String get casebookOpen => 'Open';

  @override
  String get casebookShare => 'Share';

  @override
  String get casebookCopy => 'Copy text';

  @override
  String get casebookCopied => 'Copied to clipboard';

  @override
  String get casebookExportDisclaimer =>
      'This is a personal working note, NOT an expert opinion or conclusion. Statements are copied from reference material and do not replace examination of the actual case materials.';

  @override
  String get casebookExportFooter =>
      'Exported from the FORENSIC EXPERT casebook (kept on the author’s device). Verify every statement against the original source.';

  @override
  String get casebookExportLinks => 'Linked items';

  @override
  String get casebookExportBlocks => 'Source-backed statements';

  @override
  String get casebookDeleteEntry => 'Delete entry';

  @override
  String get casebookDeleteEntryTitle => 'Delete this entry?';

  @override
  String get casebookDeleteEntryBody =>
      'The entry will be removed from this device. This cannot be undone.';

  @override
  String get casebookDeleteConfirm => 'Delete';

  @override
  String get casebookCancel => 'Cancel';

  @override
  String get casebookClearAll => 'Clear entire casebook';

  @override
  String get casebookClearTitle => 'Clear the whole casebook?';

  @override
  String get casebookClearBody =>
      'All entries will be deleted from this device permanently. They are not stored anywhere else, so they cannot be restored.';

  @override
  String get casebookCleared => 'Casebook cleared';

  @override
  String casebookCount(int n) {
    return '$n entries';
  }

  @override
  String casebookBlockCount(int n) {
    return '$n statements';
  }

  @override
  String get casebookNotFound => 'This entry no longer exists.';

  @override
  String get admNavVerify => 'Verification applications';

  @override
  String get admNavVerifyHint => 'Review professional applications and decide';

  @override
  String get admVfEmpty => 'No applications are waiting.';

  @override
  String get admVfUnavailable =>
      'Verification needs the online service, which is not connected in this build.';

  @override
  String get admVfLoadFailed =>
      'Could not load applications. Check the connection and try again.';

  @override
  String admVfSubmitted(String date) {
    return 'Submitted $date';
  }

  @override
  String admVfDocsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents',
      one: '1 document',
      zero: 'No documents',
    );
    return '$_temp0';
  }

  @override
  String get admVfSelfBadge => 'Your own application';

  @override
  String get admVfSelfNote =>
      'You cannot approve your own application — another authorised admin will decide it.';

  @override
  String get admVfApplicant => 'Applicant';

  @override
  String get admVfFieldSpecialty => 'Specialty';

  @override
  String get admVfFieldExperience => 'Experience';

  @override
  String admVfYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String get admVfFieldEducation => 'Education';

  @override
  String get admVfFieldCountry => 'Country';

  @override
  String get admVfDocs => 'Credential documents';

  @override
  String get admVfDocsHint =>
      'Tick every document you have checked. Approval needs at least one checked document.';

  @override
  String get admVfDocsNone =>
      'The applicant has not uploaded any documents, so the application cannot be approved yet.';

  @override
  String get admVfDocsNote =>
      'The app shows document details only (type, size, SHA-256). Check the file itself in the secure server storage.';

  @override
  String admVfDocMeta(String type, String size, String hash) {
    return '$type · $size · SHA-256 $hash';
  }

  @override
  String get admVfDecision => 'Decision';

  @override
  String get admVfScope => 'Area of the decision';

  @override
  String get admVfScopeRequired =>
      'Choose the specialty area this decision refers to.';

  @override
  String get admVfReason => 'Reason (at least 5 characters)';

  @override
  String get admVfReasonShort => 'Enter a reason of at least 5 characters.';

  @override
  String get admVfMessage => 'Message to the applicant (optional)';

  @override
  String get admVfApprove => 'Approve';

  @override
  String get admVfRequestInfo => 'Request more information';

  @override
  String get admVfReject => 'Reject';

  @override
  String get admVfNoScientific =>
      'Identity verification does not grant scientific review rights.';

  @override
  String get admVfDoneVerified => 'Application approved.';

  @override
  String get admVfDoneInfo => 'More information requested.';

  @override
  String get admVfDoneRejected => 'Application rejected.';

  @override
  String get admVfErrSelf =>
      'You cannot approve your own application — another authorised admin will decide it.';

  @override
  String get admVfErrForbidden =>
      'You have no authority to verify in this area.';

  @override
  String get admVfErrNoCredential => 'Mark at least one document as checked.';

  @override
  String get admVfErrUnknownCredential =>
      'A selected document does not belong to this applicant. Refresh the list.';

  @override
  String get admVfErrTransition =>
      'This application has already been decided. Refresh the list.';

  @override
  String get admVfErrNoApplication => 'Application not found.';

  @override
  String get admVfErrMfa => 'Sign in with two-step verification to continue.';

  @override
  String get admVfErrSignIn => 'Please sign in again.';

  @override
  String get admVfErrOffline =>
      'No connection. Check the internet and try again.';

  @override
  String get admVfErrServer => 'The decision was not saved. Try again later.';

  @override
  String get admActVerificationsView => 'Viewed verification applications';

  @override
  String get legalOpenOnline => 'Open the full policy online';

  @override
  String get legalPublishedNotice =>
      'This is the published policy. The same text is available online.';

  @override
  String get detailSourcedStatement =>
      'Based on the source (not a direct quotation)';

  @override
  String get proSearchTitle => 'Advanced search';

  @override
  String get proSearchEntry => 'Filters and reverse lookups';

  @override
  String get proSearchIntro =>
      'Narrow the offline pack by specimen, method, reagent, evidence level and more, or go from a specimen, method or reagent to the substances documented for it.';

  @override
  String get proSearchHint => 'Name, synonym or \"phrase\"';

  @override
  String get proSearchExact => 'Exact match';

  @override
  String get proTabSearch => 'Search';

  @override
  String get proTabReverse => 'Reverse lookup';

  @override
  String get proFilters => 'Filters';

  @override
  String get proFiltersClear => 'Clear filters';

  @override
  String get proFacetAny => 'Any';

  @override
  String get proFacetDiscipline => 'Discipline';

  @override
  String get proFacetClass => 'Substance class';

  @override
  String get proFacetSpecimen => 'Specimen';

  @override
  String get proFacetFamily => 'Method family';

  @override
  String get proFacetReagent => 'Reagent';

  @override
  String get proFacetEvidence => 'Evidence level';

  @override
  String get proFacetStatus => 'Review status';

  @override
  String get proFacetJurisdiction => 'Jurisdiction';

  @override
  String get proFacetYear => 'Source year';

  @override
  String proEvidenceAtLeast(String level) {
    return 'Level $level or higher';
  }

  @override
  String proYearSince(int year) {
    return 'Since $year';
  }

  @override
  String proFamilyName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'colourTest': 'Colour (spot) test',
      'tlc': 'TLC (thin-layer chromatography)',
      'microcrystal': 'Microcrystal test',
      'uvVis': 'UV/Vis spectrophotometry',
      'immunoassay': 'Immunoassay',
      'gcMs': 'GC-MS',
      'lcMs': 'LC-MS, LC-MS/MS',
      'hrms': 'HRMS (high-resolution MS)',
      'gcFid': 'GC-FID, headspace GC',
      'hplc': 'HPLC',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String proResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get proResultsNoneTitle => 'No match in the pack';

  @override
  String get proResultsNoneBody =>
      'Nothing matches this combination. Remove a filter, switch off exact match or try another spelling or language.';

  @override
  String get proResultsStart => 'Type a name or pick a filter to see results.';

  @override
  String get proReverseReagent => 'Reagent → substances';

  @override
  String get proReverseSpecimen => 'Specimen → analytes';

  @override
  String get proReverseMethod => 'Method → substances';

  @override
  String get proReversePick =>
      'Choose one to see which substances the pack documents for it.';

  @override
  String proReverseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count substances',
      one: '1 substance',
    );
    return '$_temp0';
  }

  @override
  String proReverseNoReagents(int count) {
    return 'The pack documents no link between a reagent and a substance yet ($count reagent recipes exist). Nothing is guessed.';
  }

  @override
  String get proReverseEmpty =>
      'No substance is documented for this item in the pack.';

  @override
  String get proReverseNote =>
      'Only links stated in the sources. Not found here does not mean not possible.';

  @override
  String get proRoleAnalysed => 'analysed with this method (source)';

  @override
  String get proRoleConfirmation => 'confirmation after screening';

  @override
  String get proRoleScreened => 'screened with this test';

  @override
  String get proRoleMeasured =>
      'value reported in this specimen (not a threshold)';

  @override
  String proViaLabel(String names) {
    return 'via $names';
  }

  @override
  String get planEntryTitle => 'Analysis plan for this substance';

  @override
  String get planEntryBody =>
      'Specimens, presumptive tests, confirmation, interferences, limits and a note for your conclusion on one page, with sources.';

  @override
  String get planTitle => 'Analysis plan';

  @override
  String get planIntro =>
      'Assembled only from sourced statements already in the pack. It is a reference outline, not a validated procedure and not an expert conclusion.';

  @override
  String planSummary(int s, int p, int c, int l) {
    return 'Specimens: $s · Presumptive tests: $p · Confirmation: $c · Limits: $l';
  }

  @override
  String get planSecSpecimens => 'Specimens and sampling notes';

  @override
  String get planSecPresumptive =>
      'Presumptive tests (reagent and observation)';

  @override
  String get planSecBench => 'TLC, microcrystal and UV/Vis';

  @override
  String get planSecConfirmation => 'Confirmation step';

  @override
  String get planSecInstrumental => 'Other instrumental methods in the sources';

  @override
  String get planSecInterferences =>
      'Interferences, cross-reactivity and false results';

  @override
  String get planSecLimits => 'Interpretation limits';

  @override
  String get planSecReminder => 'Note for the conclusion';

  @override
  String get planNoSpecimens =>
      'No specimen is documented for this substance in the pack.';

  @override
  String get planNoSamplingNotes =>
      'No collection or preservation note is documented for these specimens in the pack.';

  @override
  String get planNoPresumptive =>
      'No presumptive test is documented for this substance in the pack.';

  @override
  String get planNoReagents =>
      'No reagent and expected observation pair is documented for this test in the pack.';

  @override
  String get planNoBench =>
      'No TLC, microcrystal or UV/Vis system is documented for this substance in the pack.';

  @override
  String get planNoConfirmation =>
      'No confirmation method is documented for this substance in the pack.';

  @override
  String get planNoInstrumental =>
      'No other instrumental method is mentioned with this substance in the pack.';

  @override
  String get planNoInterferences =>
      'No interference, cross-reactivity or false result is documented for the tests of this substance in the pack.';

  @override
  String get planNoLimits =>
      'No sourced limitation statement for these specimens and methods in the pack.';

  @override
  String get planConfirmRequired => 'Confirmation required';

  @override
  String get planReagentsLabel => 'Reagents linked in the sources';

  @override
  String get planReagentRecipe => 'Reagent recipe';

  @override
  String planPrinciple(String principle) {
    return 'Principle: $principle';
  }

  @override
  String get planNotDefinitive =>
      'The sources do not present this test as definitive identification.';

  @override
  String planAbout(String name) {
    return 'Applies to: $name';
  }

  @override
  String planSourceLine(String title) {
    return 'Source: $title';
  }

  @override
  String planLocatorLine(String locator) {
    return 'Location: $locator';
  }

  @override
  String get planNoSource => 'Source not stated';

  @override
  String planRoleName(String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'basis': 'Source statement',
      'presumptive': 'Presumptive nature',
      'confirmationRequirement': 'Confirmation requirement',
      'limitation': 'Limitation',
      'crossReactivity': 'Cross-reactivity',
      'falsePositive': 'False positive',
      'falseNegative': 'False negative',
      'interference': 'Interference',
      'detectionWindow': 'Detection window',
      'use': 'Collection / use note',
      'principle': 'Principle',
      'application': 'Application',
      'observation': 'Expected observation',
      'other': '$role',
    });
    return '$_temp0';
  }

  @override
  String get planMayHeading => 'May rely on';

  @override
  String get planMayNotHeading => 'Do not state';

  @override
  String planRemPresumptiveOnly(String tests) {
    return 'The sources do not support definitive identification by: $tests. State such a result as presumptive only.';
  }

  @override
  String planRemConfirmDocumented(String methods) {
    return 'The pack names these confirmation methods: $methods. Cite them only if your laboratory actually performed them.';
  }

  @override
  String get planRemConfirmMissing =>
      'No confirmation method is documented in the pack for the tests above. Do not state a confirmed identification on the basis of this pack.';

  @override
  String planRemNotThreshold(int count) {
    return 'Concentration records in the pack ($count) are reported observations, not thresholds or cut-offs. Do not present them as reference limits.';
  }

  @override
  String get planRemNotPaired =>
      'The sources do not tie the methods to the specimens. Do not state which method was used on which specimen on the basis of this pack.';

  @override
  String get planRemNothingVerified =>
      'No statement here has been verified by an expert reviewer. Do not present it as verified scientific data.';

  @override
  String planRemConflict(int count) {
    return 'Open evidence conflicts recorded for this substance: $count. Check before relying on it.';
  }

  @override
  String get planRemNoData =>
      'The pack has no analysis data for this substance. This page cannot support a conclusion.';

  @override
  String get planReminderFootnote =>
      'Based only on flags and sourced limitation statements in the pack. It adds no new scientific claim and is not an expert opinion.';

  @override
  String get planCopy => 'Copy the plan with citations';

  @override
  String get planCopied => 'Plan copied with full citations';

  @override
  String planExportHeader(String name) {
    return 'ANALYSIS PLAN — $name';
  }

  @override
  String get planExportDisclaimer =>
      'Reference outline compiled from the sourced statements of the content pack. Not a validated procedure and not an expert conclusion; check every statement against the original source.';

  @override
  String get planExportSources => 'SOURCES';

  @override
  String get planExportOriginal => 'Original';

  @override
  String planExportStatus(String status, String level) {
    return 'status: $status; evidence level: $level';
  }

  @override
  String get imageOtherSubstanceChip => 'Example: another substance';

  @override
  String get imageOtherSubstanceNote =>
      'This figure is from another substance\'s example; it shows how the method works and does not belong to the substance you came from. The title names the substance shown.';

  @override
  String get detailMethodRecords => 'Method conditions and limits (sourced)';

  @override
  String get claimFieldSamplePreparation => 'Sample preparation';

  @override
  String get claimFieldInstrumentation => 'Instrument set-up';

  @override
  String get claimFieldQc => 'Calibration and quality control';

  @override
  String get claimFieldInterference => 'Identification and interference';

  @override
  String get claimFieldValidation => 'Method performance';

  @override
  String get claimFieldSpecimens => 'Other specimens';

  @override
  String get claimFieldLimitation => 'Limitation';

  @override
  String get qaTitle => 'Questions & answers';

  @override
  String get qaIntro =>
      'Forensic physicians and forensic chemists ask each other practical questions here. Only verified specialists may answer.';

  @override
  String get qaNotice =>
      'An answer here is a colleague\'s opinion, not a scientific conclusion and not an expert opinion for a case file.';

  @override
  String get qaUnavailable => 'This section is not available yet.';

  @override
  String get qaSignInRequired => 'Sign in to read and ask questions.';

  @override
  String get qaSignIn => 'Sign in';

  @override
  String get qaSearchHint => 'Search questions';

  @override
  String get qaAllTopics => 'All topics';

  @override
  String get qaEmpty => 'No questions yet. Be the first to ask.';

  @override
  String get qaLoadFailed =>
      'Could not load the questions. Check the connection.';

  @override
  String qaAnswersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answers',
      one: '1 answer',
      zero: 'No answers',
    );
    return '$_temp0';
  }

  @override
  String get qaAcceptedAnswer => 'Best answer';

  @override
  String get qaPinned => 'Pinned';

  @override
  String get qaOpenMine => 'My questions';

  @override
  String get qaAsk => 'Ask a question';

  @override
  String get qaOpenModeration => 'Moderation';

  @override
  String get qaTagToxicology => 'Toxicology';

  @override
  String get qaTagAlcohol => 'Alcohol';

  @override
  String get qaTagDrugs => 'Narcotic drugs';

  @override
  String get qaTagDna => 'DNA';

  @override
  String get qaTagHistology => 'Histology';

  @override
  String get qaTagThanatology => 'Thanatology';

  @override
  String get qaTagMethods => 'Methods';

  @override
  String get qaTagRegulations => 'Regulations';

  @override
  String get qaTagBiology => 'Biology';

  @override
  String get qaTagCriminalistics => 'Criminalistics';

  @override
  String get qaTagDocumentation => 'Documentation';

  @override
  String get qaRolePhysician => 'Forensic physician';

  @override
  String get qaRoleChemist => 'Forensic chemist';

  @override
  String get qaRoleTechnician => 'Laboratory technician';

  @override
  String get qaRoleStudent => 'Student';

  @override
  String get qaRoleOther => 'Other';

  @override
  String get qaVerifiedBadge => 'Verified specialist';

  @override
  String get qaManualBadge => 'Checked by hand';

  @override
  String get qaAskTitle => 'Ask a question';

  @override
  String get qaFieldTitle => 'Question';

  @override
  String get qaFieldBody => 'Details';

  @override
  String get qaFieldTopics => 'Topics (up to 5)';

  @override
  String get qaPrivacyWarning =>
      'Never write case material: case or examination numbers, a person\'s name, an address, a date together with a place, or anything else that identifies someone. Describe the question in general terms. Photographs cannot be attached.';

  @override
  String get qaNoImages => 'Images cannot be attached to posts.';

  @override
  String get qaTitleTooShort => 'Write the question in at least 10 characters.';

  @override
  String get qaBodyTooShort => 'Add at least 30 characters of detail.';

  @override
  String get qaSend => 'Send';

  @override
  String get qaPosted => 'Published.';

  @override
  String get qaHeldForReview =>
      'Held for review: the text looks like it contains case material. An administrator will look at it.';

  @override
  String get qaFlagCaseNumber => 'a case or examination number';

  @override
  String get qaFlagPersonName => 'a person\'s name';

  @override
  String get qaFlagDateAndPlace => 'a date together with a place';

  @override
  String get qaFlagContact => 'a phone number or an address';

  @override
  String get qaFlagIdentifier => 'an identity document number';

  @override
  String qaFlagsFound(String flags) {
    return 'Found: $flags';
  }

  @override
  String get qaDailyLimit =>
      'You have reached today\'s limit. Try again tomorrow.';

  @override
  String get qaSendFailed => 'Could not send. Check the connection.';

  @override
  String get qaAnswerHint => 'Write your answer';

  @override
  String get qaOnlyVerifiedMayAnswer =>
      'Only verified specialists may answer. Get verified to join in.';

  @override
  String get qaNoAnswers => 'No answers yet.';

  @override
  String get qaMarkBest => 'Mark as best answer';

  @override
  String get qaUnmarkBest => 'Remove the best-answer mark';

  @override
  String get qaUpvote => 'Useful answer';

  @override
  String get qaDownvote => 'Not a useful answer';

  @override
  String get qaOnlyVerifiedMayVote => 'Only verified specialists may vote.';

  @override
  String get qaReport => 'Report';

  @override
  String get qaReportReasonHint => 'What is wrong with this post?';

  @override
  String get qaReportSent => 'Thank you. An administrator will look at it.';

  @override
  String get qaReportHidden =>
      'Hidden until an administrator decides: three different users reported it.';

  @override
  String get qaMachineTranslation => 'Machine translation';

  @override
  String get qaShowTranslation => 'Translate';

  @override
  String get qaShowOriginal => 'Original text';

  @override
  String get qaTranslationFailed => 'Could not translate right now.';

  @override
  String get qaVerifyTitle => 'Verify as a specialist';

  @override
  String get qaVerifyIntro =>
      'Send a photograph or a PDF of your professional credential — a diploma, certificate, licence or qualification certificate. It is checked automatically.';

  @override
  String get qaVerifyFileNotStored =>
      'The file is NOT stored. It is held only in memory during the check and goes to no database, no storage and no log. Only this is kept: your account id, role, country, the outcome and the date. The document number and your full name are not written down.';

  @override
  String get qaVerifyRole => 'Your role';

  @override
  String get qaVerifyCountry => 'Country (two letters)';

  @override
  String get qaVerifyPickFile => 'Choose the document';

  @override
  String qaVerifyFileChosen(String size) {
    return 'Document chosen ($size)';
  }

  @override
  String get qaVerifySend => 'Send for checking';

  @override
  String qaVerifyAttemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts left today',
      one: '1 attempt left today',
      zero: 'No attempts left today',
    );
    return '$_temp0';
  }

  @override
  String get qaVerifyChecking => 'Checking the document…';

  @override
  String get qaVerifyAccepted =>
      'Verified. You may now answer questions and vote.';

  @override
  String qaVerifyRejected(String reason) {
    return 'Not verified: $reason';
  }

  @override
  String get qaReasonNotACredential =>
      'the file does not look like a professional credential';

  @override
  String get qaReasonUnreadable => 'the document could not be read';

  @override
  String get qaReasonRoleMismatch =>
      'the document shows a different profession from the one you chose';

  @override
  String get qaReasonLowConfidence => 'the check was not confident enough';

  @override
  String get qaReasonExpired => 'the document looks expired';

  @override
  String get qaReasonReported => 'other users reported the profile';

  @override
  String get qaVerifyBadDocument =>
      'Choose a JPEG, PNG, WebP or PDF file no larger than 6 MB.';

  @override
  String get qaVerifyUnavailable =>
      'The check is unavailable right now. Your attempt was not used.';

  @override
  String get qaStatusUnverified => 'Not verified';

  @override
  String get qaStatusVerified => 'Verified';

  @override
  String get qaStatusRejected => 'Rejected';

  @override
  String get qaStatusSuspended => 'Suspended';

  @override
  String get qaMineTitle => 'My questions and answers';

  @override
  String get qaMineQuestions => 'Questions';

  @override
  String get qaMineAnswers => 'Answers';

  @override
  String get qaMineEmpty => 'You have not posted anything yet.';

  @override
  String get qaPostPublished => 'Published';

  @override
  String get qaPostModeration => 'Under review';

  @override
  String get qaPostRemoved => 'Removed';

  @override
  String qaScore(int score) {
    return 'Rating: $score';
  }

  @override
  String get qaModerationTitle => 'Q&A moderation';

  @override
  String get qaModerationEmpty => 'Nothing is waiting.';

  @override
  String get qaModerationQuestions => 'Questions under review';

  @override
  String get qaModerationAnswers => 'Answers under review';

  @override
  String get qaModerationSuspended => 'Suspended badges';

  @override
  String qaReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports',
      one: '1 report',
    );
    return '$_temp0';
  }

  @override
  String get qaActionPublish => 'Publish';

  @override
  String get qaActionRemove => 'Remove';

  @override
  String get qaActionPin => 'Pin';

  @override
  String get qaActionUnpin => 'Unpin';

  @override
  String get qaActionReinstate => 'Reinstate the badge';

  @override
  String get qaActionSuspend => 'Suspend the badge';

  @override
  String get qaActionDone => 'Done.';

  @override
  String get qaActionFailed => 'Could not do that.';

  @override
  String get qaAdminOnly => 'Only an administrator can open this.';

  @override
  String get admNavQa => 'Community Q&A';

  @override
  String admNavQaHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts waiting',
      one: '1 post waiting',
      zero: 'Nothing is waiting',
    );
    return '$_temp0';
  }

  @override
  String get qaRulesOpen => 'Community rules';

  @override
  String get qaRulesTitle => 'Community rules';

  @override
  String get qaRulesIntro =>
      'This section is a professional conversation between forensic practitioners. Two rules decide everything else: no case material, and nothing that works against the law.';

  @override
  String get qaRulesPurposeTitle => 'What this section is for';

  @override
  String get qaRulesPurposeBody =>
      'Questions about method, reagent, specimen, instrument, interpretation of a result, a standard or a regulation — asked in general terms, the way they would be asked at a conference, not about a particular case.';

  @override
  String get qaRulesGoodTitle => 'How to ask well';

  @override
  String get qaRulesGood1 =>
      'Name the substance, the method and the specimen type. Without them an answer is guesswork.';

  @override
  String get qaRulesGood2 =>
      'Say what you already tried and where exactly you got stuck.';

  @override
  String get qaRulesGood3 =>
      'Write numbers with their units, and say which guideline or edition you are working from.';

  @override
  String get qaRulesGood4 =>
      'Choose the topics, so the right specialists see the question.';

  @override
  String get qaRulesForbiddenTitle => 'Never write this';

  @override
  String get qaRulesForbidden1 =>
      'Case material: a case or examination number, a person\'s name, an address, a date together with a place, a photograph, or anything else by which someone could be identified.';

  @override
  String get qaRulesForbidden2 =>
      'Material from an examination in progress, or a draft opinion.';

  @override
  String get qaRulesForbidden3 =>
      'Anything aimed at bending a result: how to make a conclusion come out a particular way, how to alter or hide a finding, how to backdate or forge a document, how to make evidence disappear.';

  @override
  String get qaRulesForbidden4 =>
      'How to obtain, make, conceal or use a substance in order to harm someone or to avoid detection.';

  @override
  String get qaRulesForbidden5 =>
      'Legal advice, a diagnosis, a treatment or a dose for a particular person. This section is not a consultation.';

  @override
  String get qaRulesForbidden6 =>
      'Advertising, spam, and anything insulting to a colleague.';

  @override
  String get qaRulesAnswerTitle => 'Answering';

  @override
  String get qaRulesAnswer1 =>
      'Only verified specialists may answer, and only within what they actually practise.';

  @override
  String get qaRulesAnswer2 =>
      'Lean on a source and name it. Where you are guessing, say that you are guessing.';

  @override
  String get qaRulesAnswer3 =>
      'An answer here is a colleague\'s opinion. It is not an expert opinion for a case file and cannot be cited as one.';

  @override
  String get qaRulesEnforceTitle => 'What happens if a rule is broken';

  @override
  String get qaRulesEnforceBody =>
      'Text that looks like case material is held for review automatically. Reports from three different users hide a post, or suspend a specialist badge, until an administrator decides. A post that works against the law is removed and the badge goes with it.';

  @override
  String get provOwnWordsNote =>
      'The content of the source is given in our own words; the original text is not copied. The exact place is below.';

  @override
  String get confirmedSourceBannerTextbook =>
      'Based on a confirmed source: the teacher\'s textbook. The exact place is given.';

  @override
  String get confirmedSourceChip => 'Confirmed source';

  @override
  String get needsConfirmationChip => 'Needs confirmation';

  @override
  String get needsConfirmationBanner =>
      'From international literature (article, thesis): needs confirmation.';

  @override
  String get avatarSemantics => 'Profile photo';

  @override
  String get avatarChange => 'Change photo';

  @override
  String get avatarChoose => 'Choose from gallery';

  @override
  String get avatarView => 'View larger';

  @override
  String get avatarRemove => 'Remove photo';

  @override
  String get avatarCropTitle => 'Adjust photo';

  @override
  String get avatarCropHint => 'Drag and pinch to zoom';

  @override
  String get avatarSave => 'Save';

  @override
  String get avatarCancel => 'Cancel';

  @override
  String get avatarDeviceOnly =>
      'The photo stays on this phone only and is never sent to a server.';

  @override
  String get avatarError => 'Could not open the photo. Choose another one.';

  @override
  String get bookMethodsTitle => 'Methods from the textbooks and manuals';

  @override
  String get bookMethodsNote =>
      'Analytical methods from confirmed sources (the teacher\'s books and manuals): colour tests, microcrystal tests, TLC, UV spectrum, confirmatory method. Each entry gives the full description, source and exact place.';

  @override
  String get extraInfoTitle =>
      'Additional information: articles, theses, literature';

  @override
  String get extraInfoNote =>
      'This part comes from international sources (SWGDRUG, UNODC, articles, theses). Not a primary source — needs confirmation. GC-MS and LC-MS/MS methods and forensic cases are in the international scientific layer below.';

  @override
  String get litClaimsTitle => 'Evidence from the literature (in full)';

  @override
  String get analysisS1Title => '1. Tests (rapid / screening)';

  @override
  String get analysisS1Note =>
      'Quick presumptive tests: immunoassays, test strips. The result is preliminary only and must be confirmed by a confirmation method.';

  @override
  String get analysisS2Title => '2. Qualitative reactions (colour reagents)';

  @override
  String get analysisS2Note =>
      'Reagent, colour, comment, selectivity and false positives. Presumptive: it does not prove identity by itself.';

  @override
  String get analysisS3Title =>
      '3. Quantification (GC-MS, LC-MS/MS, spectrophotometry)';

  @override
  String get analysisS3Note =>
      'Sample preparation, key parameters, LOD/LOQ (if the source gives them) and limitations. Numbers only as stated in the source; not a substitute for a validated laboratory method.';

  @override
  String get analysisSectionEmpty =>
      'No sourced information for this section yet — a source is needed. Nothing is guessed.';

  @override
  String get trPendingTranslation =>
      'Translation pending — the original Uzbek text is shown';

  @override
  String contactLine(String email) {
    return 'Contact: $email';
  }

  @override
  String get repTitle => 'Send a report';

  @override
  String get repProfileHint =>
      'Inappropriate content, a bug, advertising or anything else';

  @override
  String get repIntro =>
      'Tell us about inappropriate content, a bug or another problem. You can send a report without signing in.';

  @override
  String get repKindField => 'Type';

  @override
  String get repKindComplaint => 'Complaint';

  @override
  String get repKindInappropriate => 'Inappropriate content';

  @override
  String get repKindBug => 'Bug';

  @override
  String get repKindAdvertising => 'Advertising';

  @override
  String get repKindOther => 'Other';

  @override
  String get repBody => 'What happened?';

  @override
  String get repBodyHint =>
      'Do not write personal data, case numbers or patient information.';

  @override
  String repBodyShort(int min) {
    return 'Write at least $min characters.';
  }

  @override
  String get repContact => 'E-mail for a reply (optional)';

  @override
  String get repContactHint =>
      'If you are not signed in, leave an address if you want a reply.';

  @override
  String get repPrivacy =>
      'The text is stored only to review your report. To fight spam, an irreversible hash of the device or network address is kept; the address itself is not.';

  @override
  String get repSend => 'Send';

  @override
  String get repSent => 'Your report was sent. Thank you.';

  @override
  String get repInvalid => 'Check the text and try again.';

  @override
  String repRateLimited(int n) {
    return 'You can send up to $n reports per hour. Try again later.';
  }

  @override
  String get repFailed => 'Not sent. Check your connection and try again.';

  @override
  String get repSuspended =>
      'This account is suspended. Write to us by e-mail for help.';

  @override
  String get repUnavailable =>
      'The report service is not connected in this build. Write to us by e-mail.';

  @override
  String get repMine => 'My reports';

  @override
  String get repStatusOpen => 'Under review';

  @override
  String get repStatusResolved => 'Resolved';

  @override
  String get ctTitle => 'Community rules';

  @override
  String get ctDraft =>
      'This text is a draft and must be checked by a lawyer before the public release.';

  @override
  String get ctZeroTolerance =>
      'Abusive, hateful, violent, illegal or spam content is not allowed. Every post has «Report» and «Block author» buttons. Content that breaks the rules can be removed and the account suspended.';

  @override
  String get ctOpenTerms => 'Terms of Use (draft)';

  @override
  String get ctAgree => 'I have read the rules and accept them';

  @override
  String get ctAccept => 'Accept';

  @override
  String get ctDecline => 'Not now';

  @override
  String get ctSaveFailed => 'Not saved. Try again.';

  @override
  String get blkTitle => 'Blocked authors';

  @override
  String get blkIntro =>
      'Posts of blocked authors are hidden from you. You are not shown who they are.';

  @override
  String get blkEmpty => 'You have not blocked anyone.';

  @override
  String get blkItem => 'Blocked author';

  @override
  String blkSince(String date) {
    return 'since $date';
  }

  @override
  String get blkUnblock => 'Unblock';

  @override
  String get blkUnblocked => 'Unblocked.';

  @override
  String get blkAction => 'Block author';

  @override
  String get blkConfirmTitle => 'Block this author?';

  @override
  String get blkConfirmBody =>
      'You will no longer see this author\'s questions and answers. You are not told who it is. You can undo this in the blocked list.';

  @override
  String get blkDone => 'Author blocked.';

  @override
  String get blkAlready => 'This author is already blocked.';

  @override
  String get blkSelf => 'You cannot block yourself.';

  @override
  String get blkFailed => 'Could not complete. Try again.';

  @override
  String get admxNavReports => 'Reports';

  @override
  String admxNavReportsHint(int n) {
    return '$n open';
  }

  @override
  String get admxReportsTitle => 'Reports';

  @override
  String get admxReportsSearch => 'Search by text or e-mail';

  @override
  String get admxOpen => 'Open';

  @override
  String get admxResolvedFilter => 'Resolved';

  @override
  String get admxAll => 'All';

  @override
  String get admxKindAny => 'All types';

  @override
  String get admxQaLink =>
      'Open Q&A moderation (posts reported by three people)';

  @override
  String get admxReportsEmpty => 'No reports.';

  @override
  String get admxLoadMore => 'Load more';

  @override
  String get admxAnonymous => 'Not signed in';

  @override
  String admxContact(String value) {
    return 'Contact: $value';
  }

  @override
  String admxTarget(String type) {
    return 'About: $type';
  }

  @override
  String get admxNoteLabel => 'Note (admins only)';

  @override
  String get admxNoteSave => 'Save note';

  @override
  String get admxNoteSaved => 'Note saved.';

  @override
  String get admxResolve => 'Mark as resolved';

  @override
  String get admxReopen => 'Reopen';

  @override
  String get admxResolvedDone => 'Report marked as resolved.';

  @override
  String get admxReopened => 'Report reopened.';

  @override
  String get admxActionFailed => 'Action failed. Try again.';

  @override
  String get admxActions => 'Actions';

  @override
  String get admxActionsHint =>
      'Every action is checked by the server and written to the audit log.';

  @override
  String get admxReason => 'Reason';

  @override
  String get admxReasonHint => 'At least 5 characters. Saved in the audit log.';

  @override
  String get admxReasonShort => 'The reason must be at least 5 characters.';

  @override
  String get admxCancel => 'Cancel';

  @override
  String get admxConfirm => 'Confirm';

  @override
  String get admxSelfNote =>
      'You cannot change your own role or suspend your own account.';

  @override
  String get admxModeratorGrant => 'Make publication moderator';

  @override
  String get admxModeratorRemove => 'Remove moderator role';

  @override
  String get admxRemoveAdmin => 'Remove admin role';

  @override
  String get admxRemoveAdminTitle => 'Remove admin role?';

  @override
  String get admxRemoveAdminBody =>
      'This person loses access to the admin panel at once. The last admin cannot be removed. A scientific reviewer role is separate and is not changed here.';

  @override
  String get admxAdminNotSuspendable => 'An admin account cannot be suspended.';

  @override
  String get admxSuspend => 'Suspend account';

  @override
  String get admxRestore => 'Restore account';

  @override
  String get admxSuspendTitle => 'Suspend this account?';

  @override
  String get admxSuspendConfirmBody =>
      'The person is signed out everywhere and cannot sign in again until you restore the account. The action is written to the audit log.';

  @override
  String get admxRoleGranted => 'Role granted.';

  @override
  String get admxRoleRevoked => 'Role removed.';

  @override
  String get admxNoChange => 'Nothing changed.';

  @override
  String get admxUserNotFound => 'User not found.';

  @override
  String get admxRoleForbidden =>
      'This role cannot be granted from the app. The owner does it on the server.';

  @override
  String get admxEmailUnconfirmed => 'The e-mail address is not confirmed.';

  @override
  String get admxSelfAdmin => 'You cannot change your own admin role.';

  @override
  String get admxLastAdmin => 'The last admin cannot be removed.';

  @override
  String get admxCannotSuspendAdmin => 'An admin cannot be suspended.';

  @override
  String get admxCannotSuspendSelf => 'You cannot suspend yourself.';

  @override
  String get admxSuspended => 'Account suspended. Its sessions were closed.';

  @override
  String get admxRestored => 'Account restored.';

  @override
  String get admxExtTitle => 'Roles, reports and objects';

  @override
  String get admxStatAdmins => 'Admins';

  @override
  String get admxStatModerators => 'Moderators';

  @override
  String get admxStatSuspended => 'Suspended';

  @override
  String get admxStatReportsOpen => 'Open reports';

  @override
  String get admxStatReportsResolved => 'Resolved reports';

  @override
  String get admxStatQaQuestions => 'Q&A questions';

  @override
  String get admxStatQaAnswers => 'Q&A answers';

  @override
  String get admxStatQaModeration => 'In moderation';

  @override
  String get admxStatBlocks => 'Blocks';

  @override
  String get admxCasebookNote =>
      'Casebooks: stored on the device, not counted.';

  @override
  String get admxOnlineNote =>
      'Online now: not available (there is no activity tracking).';

  @override
  String get admxStoresTitle => 'Downloads';

  @override
  String get admxDownloadsNote =>
      'Downloads: the server cannot see them. Open the store consoles.';

  @override
  String get admxSalesNote => 'Sales: 0 — there is no payment system.';

  @override
  String get admxOpenAsc => 'App Store Connect';

  @override
  String get admxOpenPlay => 'Google Play Console';

  @override
  String get admxOpenFailed => 'Could not open the link.';

  @override
  String get admActAdminRoleSet => 'Role changed from the panel';

  @override
  String get admActUserSuspended => 'Account suspended';

  @override
  String get admActUserRestored => 'Account restored';

  @override
  String get admActReportsView => 'Report list viewed';

  @override
  String get admActReportNote => 'Note on a report';

  @override
  String get admActReportResolved => 'Report resolved';

  @override
  String get admActReportReopened => 'Report reopened';

  @override
  String get admActAdminBootstrap => 'First admin assigned (owner bootstrap)';

  @override
  String get socialOr => 'or';

  @override
  String get socialContinueGoogle => 'Continue with Google';

  @override
  String get socialContinueApple => 'Continue with Apple';

  @override
  String get socialErrUnavailable =>
      'Sign-in with this provider is unavailable right now. Try again or use your email.';

  @override
  String get socialTermsNote =>
      'By continuing you accept the Terms of Use and the Privacy Policy.';

  @override
  String get deleteAccountSocialNote =>
      'This account was created with Google or Apple, so no password is needed. Confirm below to delete it.';

  @override
  String get deleteAccountAppleNote =>
      'This account was created with Apple, so no password is needed. After you confirm, Apple will ask you to verify it is you, and the app\'s access to your Apple ID will be revoked.';

  @override
  String get classQuizTitle => 'Group test (live)';

  @override
  String get classQuizCardSubtitle =>
      'Live quiz run by your teacher: join with a code or QR';

  @override
  String get classQuizIntro =>
      'The teacher shows a 6-digit code and QR on the screen. Students join with a nickname and answer each question before the timer ends.';

  @override
  String get classDemoBanner =>
      'Demo mode: data stays on this device only. A real group test needs the server connection.';

  @override
  String get classDemoChip => 'DEMO';

  @override
  String get classJoinSection => 'Join a group test';

  @override
  String get classJoinHint =>
      'Enter the 6-digit code from the teacher’s screen or scan the QR.';

  @override
  String get classJoinTitle => 'Join group test';

  @override
  String get classJoinAction => 'Join';

  @override
  String get classCodeLabel => 'Test code';

  @override
  String classCodeSpoken(String code) {
    return 'Test code $code';
  }

  @override
  String get classNickLabel => 'Nickname';

  @override
  String get classNickHelper =>
      '2–20 characters. The teacher sees only this nickname — not your name or e-mail.';

  @override
  String get classScanAction => 'Scan QR';

  @override
  String get classScanTitle => 'Scan the test QR';

  @override
  String get classScanHint =>
      'Point the camera at the QR on the teacher’s screen.';

  @override
  String get classScanPermission =>
      'Camera access is off. Allow it in Settings or enter the code by hand.';

  @override
  String get classScanUnavailable =>
      'The camera can’t be used here. Enter the code by hand.';

  @override
  String get classScanManual => 'Enter code by hand';

  @override
  String classResume(String topic) {
    return 'Continue: $topic';
  }

  @override
  String get classTeacherSection => 'For teachers';

  @override
  String get classNotTeacherNote =>
      'The test is run by a teacher. The teacher role is granted by the FORENSIC EXPERT team on the server; ask us if you teach a class.';

  @override
  String get classNewAction => 'Run a quiz';

  @override
  String get classNewTitle => 'Run a quiz';

  @override
  String get classRecentSection => 'Recent tests';

  @override
  String classSessionLine(String code, String status) {
    return '$code · $status';
  }

  @override
  String get classStatusLobby => 'Waiting for students';

  @override
  String get classStatusRunning => 'In progress';

  @override
  String get classStatusFinished => 'Finished';

  @override
  String get classPrivacyNote =>
      'The teacher sees only your name. Finished tests are deleted automatically after 30 days. Offensive names can be reported and removed.';

  @override
  String get classSignInTitle => 'Sign in to join';

  @override
  String get classSignInBody =>
      'Your result is tied to your account on the server. Other students and the teacher only see your nickname.';

  @override
  String get classSignInAction => 'Sign in';

  @override
  String get classTeacherOnlyTitle => 'Teachers only';

  @override
  String get classTeacherOnlyBody =>
      'This screen is available to accounts with the teacher role. The server enforces this.';

  @override
  String get classTopicSection => 'Topic';

  @override
  String get classNoTopics => 'No question bank is available yet.';

  @override
  String classQuestionsAvailable(int count) {
    return '$count questions';
  }

  @override
  String get classSettingsSection => 'Settings';

  @override
  String get classQuestionCount => 'Number of questions';

  @override
  String get classStudentLimit => 'Student limit';

  @override
  String get classSecondsPerQuestion => 'Time per question';

  @override
  String classSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String classSecondsLeft(int seconds) {
    return '$seconds seconds left';
  }

  @override
  String get classCreateAction => 'Start the test';

  @override
  String get classHostJoinHint =>
      'Open FORENSIC EXPERT → Group test and enter this code, or scan the QR:';

  @override
  String get classQrSemantics => 'QR code to join the test';

  @override
  String classJoinedCount(int joined, int limit) {
    return 'Joined: $joined / $limit';
  }

  @override
  String get classWaitingForStudents => 'Waiting for students to join…';

  @override
  String classReportsCount(int count) {
    return '$count nickname report(s) — review the list';
  }

  @override
  String get classStartAction => 'Start';

  @override
  String get classKickTitle => 'Remove from the test?';

  @override
  String classKickBody(String nickname) {
    return '“$nickname” will be removed and cannot rejoin.';
  }

  @override
  String get classKickAction => 'Remove';

  @override
  String get classCancel => 'Cancel';

  @override
  String classQuestionOf(int n, int total) {
    return 'Question $n of $total';
  }

  @override
  String classAnswered(int count, int total) {
    return 'Answered: $count of $total';
  }

  @override
  String classCorrectPct(int pct) {
    return '$pct% correct';
  }

  @override
  String get classLeaderboard => 'Leaderboard';

  @override
  String get classNoScoresYet => 'No scores yet.';

  @override
  String get classCloseQuestion => 'Close question';

  @override
  String get classNextQuestion => 'Next question';

  @override
  String get classFinishAction => 'Finish quiz';

  @override
  String get classEndAction => 'End quiz';

  @override
  String get classEndTitle => 'End the quiz now?';

  @override
  String get classEndBody =>
      'Students will see their results. This can’t be undone.';

  @override
  String get classFinishedTitle => 'Quiz finished';

  @override
  String classFinishedSummary(int students, int questions) {
    return '$students students · $questions questions';
  }

  @override
  String get classHardestTitle => 'Hardest questions';

  @override
  String get classNoAnswersYet => 'No answers recorded.';

  @override
  String get classExportCsv => 'Save / share results (CSV)';

  @override
  String get classCsvSubject => 'Group test results';

  @override
  String get classDone => 'Done';

  @override
  String classRetentionNote(int days) {
    return 'The test is deleted automatically $days days after it ends.';
  }

  @override
  String get classRetry => 'Try again';

  @override
  String get classExit => 'Leave';

  @override
  String classLobbyWelcome(String nickname) {
    return 'You’re in, $nickname!';
  }

  @override
  String get classLobbyWait => 'Wait for the teacher to start the quiz.';

  @override
  String get classChooseAnswer => 'Choose an answer.';

  @override
  String get classAnswerAccepted =>
      'Answer received. The result appears when the time is up.';

  @override
  String get classTimeUpWaiting => 'Time’s up. Checking the answer…';

  @override
  String classResultCorrect(int points) {
    return 'Correct! +$points points';
  }

  @override
  String get classResultWrong => 'Not correct.';

  @override
  String get classResultNoAnswer => 'No answer given.';

  @override
  String get classWaitNext => 'Wait for the teacher to open the next question.';

  @override
  String classScoreLine(int score) {
    return 'Score: $score';
  }

  @override
  String classRankLine(int rank, int total) {
    return 'Rank $rank of $total';
  }

  @override
  String classCorrectOfTotal(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String get classTopFive => 'Top 5';

  @override
  String get classMistakesTitle => 'Questions to review';

  @override
  String get classNoMistakes => 'Every answer was correct. Well done!';

  @override
  String classQuestionNumber(int n) {
    return 'Question $n';
  }

  @override
  String classYourAnswer(String text) {
    return 'Your answer: $text';
  }

  @override
  String classCorrectAnswer(String text) {
    return 'Correct answer: $text';
  }

  @override
  String get classSourceChecked => 'Checked against the source';

  @override
  String classSourceLine(String author, String title, String page) {
    return 'Source: $author, $title, p. $page';
  }

  @override
  String get classOptionCorrect => 'correct';

  @override
  String get classOptionWrong => 'your answer, wrong';

  @override
  String get classOptionChosen => 'your choice';

  @override
  String get classReportTitle => 'Report this nickname?';

  @override
  String classReportBody(String nickname) {
    return '“$nickname” will be sent to the teacher for review.';
  }

  @override
  String get classReportAction => 'Report';

  @override
  String get classReportReason => 'Inappropriate nickname';

  @override
  String get classReportSent => 'Report sent. Thank you.';

  @override
  String get classErrNotConfigured =>
      'Group tests will be available once the FORENSIC EXPERT server is connected.';

  @override
  String get classErrNotSignedIn => 'Please sign in first.';

  @override
  String get classErrOffline =>
      'No connection. Check the internet and try again.';

  @override
  String get classErrServer =>
      'Something went wrong on the server. Try again in a moment.';

  @override
  String get classErrForbidden => 'You don’t have access to this test.';

  @override
  String get classErrBadCode => 'Enter the 6-digit code.';

  @override
  String get classErrNotFound =>
      'No test with this code. Check it and try again.';

  @override
  String get classErrRateLimited => 'Too many attempts. Try again in an hour.';

  @override
  String get classErrOwnSession =>
      'You are the teacher of this test and can’t join it as a student.';

  @override
  String get classErrFinished => 'This quiz has already finished.';

  @override
  String get classErrKicked => 'The teacher removed you from this test.';

  @override
  String get classErrAlreadyStarted =>
      'The quiz has already started — new students can’t join.';

  @override
  String get classErrFull => 'This test is full.';

  @override
  String get classErrNickLength => 'Nickname must be 2–20 characters.';

  @override
  String get classErrNickChars =>
      'This nickname contains characters that aren’t allowed.';

  @override
  String get classErrNickBlocked => 'Please choose a different nickname.';

  @override
  String get classErrInvalidSettings =>
      'Check the settings: 5–20 questions, 5–200 students, 15/30/45/60 seconds.';

  @override
  String get classErrTooManySessions =>
      'Too many open tests. Finish one first.';

  @override
  String get classErrNotEnoughQuestions =>
      'This topic has too few questions (at least 5 are needed).';

  @override
  String get classErrBadState => 'That action isn’t possible right now.';

  @override
  String get classErrNoParticipants =>
      'Wait until at least one student has joined.';

  @override
  String get classErrNotCurrent => 'This question is already closed.';

  @override
  String get classErrTimeOver => 'Time is up — your answer was not counted.';

  @override
  String get classErrAlreadyAnswered =>
      'You have already answered this question.';

  @override
  String get classErrNotFinished =>
      'Results will be available when the quiz ends.';

  @override
  String get classErrBadReason => 'Reason is too short.';

  @override
  String get unverifiedChip => 'Not yet expert-confirmed';

  @override
  String get legalNationalMethodsEmpty =>
      'National methods are not loaded yet.';

  @override
  String get teacherPanelTitle => 'Teacher panel';

  @override
  String get teacherPanelHomeBody =>
      'Run a group test and get the results as CSV';

  @override
  String get teacherPanelHomeBodyStudent =>
      'Join a group test with your teacher\'s code';

  @override
  String get teacherPanelIntro =>
      'Run a live group test, give a topic test to a group, and see the results.';

  @override
  String get teacherRunTitle => 'Group test (live)';

  @override
  String get teacherRunBody =>
      'Pick a topic — a 6-digit code and QR appear for the group';

  @override
  String get teacherResultsTitle => 'Results and CSV';

  @override
  String get teacherResultsBody => 'Past quizzes, leaderboard and a CSV file';

  @override
  String get teacherJoinTitle => 'Join a group test (student)';

  @override
  String get teacherJoinBody => 'With the code or QR from the teacher';

  @override
  String get teacherRoleNeeded => 'Teacher role required — see the note below';

  @override
  String get teacherResultsEmpty =>
      'No quizzes yet. Start with “Run a quiz” — the results will appear here.';

  @override
  String get disciplineNextTitle => 'Next steps';

  @override
  String get disciplineSearchCta => 'Search this discipline';

  @override
  String get disciplineSearchBody => 'Across substances, methods and sources';

  @override
  String get referralHowTitle => 'How it works';

  @override
  String get referralHow1 =>
      'You send your personal code or link to a colleague.';

  @override
  String get referralHow2 =>
      'Your colleague creates a new account with that code.';

  @override
  String get referralHow3 =>
      'You see only totals — never names or personal data.';

  @override
  String get pubEmptyTitle => 'No articles yet';

  @override
  String get pubEmptyBody =>
      'Be the first to share your experience: the “Submit an article” button is below. After moderation the article appears here.';

  @override
  String get calcWarnZeroMeasured =>
      'No ethanol in the sample (0): back-calculation cannot show the level at the time of the event — the ethanol may have been fully eliminated before sampling.';

  @override
  String get calcTechInfo => 'Technical details';

  @override
  String calcTechModule(String id, String version) {
    return 'Calculation module: $id, version $version';
  }

  @override
  String classSourceLineNoPage(String author, String title) {
    return 'Source: $author, $title';
  }

  @override
  String classSourceLineLocator(String author, String title, String locator) {
    return 'Source: $author, $title, $locator';
  }

  @override
  String get classTopicSearchHint => 'Search a topic or course';

  @override
  String get classTopicGroupOther => 'Other topics';

  @override
  String get classTopicNoMatch => 'No matching topics.';

  @override
  String get classTopicSelected => 'Selected topic';

  @override
  String classTopicGroupCount(int count) {
    return '$count topics';
  }

  @override
  String ghsPCodesDetails(int count) {
    return 'Details: precautionary statements ($count P-codes)';
  }

  @override
  String get studyExamUnavailableHub =>
      'Sets marked “Practice only” have no exam: their questions are generated automatically or lack an explanation or page in the source. Use Practice for them.';

  @override
  String get studyQuizAboutPractice => 'About practice mode and options';

  @override
  String get classLandscapePrompt => 'Switch to landscape?';

  @override
  String get classLandscapeYes => 'Yes';

  @override
  String get classLandscapeNo => 'No';

  @override
  String get classParticipantAnswered => 'Answered';

  @override
  String get classParticipantWaiting => 'Waiting';

  @override
  String get lessonsTitle => 'Lessons';

  @override
  String get lessonsTeacherBody =>
      'Lecture presentations — view and projector only';

  @override
  String get lessonsSearchHint => 'Search lessons';

  @override
  String get lessonsSearchClear => 'Clear search';

  @override
  String lessonsSlideCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slides',
      one: '$count slide',
    );
    return '$_temp0';
  }

  @override
  String get lessonsEmpty => 'No lessons yet.';

  @override
  String lessonsNoMatch(String query) {
    return 'Nothing found for “$query”.';
  }

  @override
  String get lessonsForbidden =>
      'This lesson opens with the teacher role. The «Working with instruments» course is open to everyone.';

  @override
  String get lessonsRetry => 'Try again';

  @override
  String get lessonsTranslationPending => 'translation pending';

  @override
  String get lessonsOriginalUzNote =>
      'Lessons are in Uzbek for now — translation pending.';

  @override
  String get lessonViewerPrev => 'Previous slide';

  @override
  String get lessonViewerNext => 'Next slide';

  @override
  String lessonViewerCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get lessonViewerOutline => 'Slide list';

  @override
  String get lessonViewerNotes => 'Teacher notes';

  @override
  String get lessonViewerNotesEmpty => 'No notes for this slide.';

  @override
  String get lessonViewerProjector => 'Projector mode';

  @override
  String get lessonViewerProjectorExit => 'Exit projector mode';

  @override
  String lessonViewerSource(String source) {
    return 'Source: $source';
  }

  @override
  String lessonViewerPage(String page) {
    return 'p. $page';
  }

  @override
  String get lessonViewerReferences => 'References';

  @override
  String get lessonViewerExtras => 'Interesting facts';

  @override
  String get lessonViewerUncertain => 'Needs verification against the source';

  @override
  String lessonViewerSlideLabel(int n) {
    return 'Slide $n';
  }

  @override
  String get lessonViewerHintNav => 'Swipe or tap to move between slides';

  @override
  String get lessonQuizStart => 'Start a quiz on this topic';

  @override
  String get lessonQuizSoon =>
      'Quiz questions for this topic will be added soon';

  @override
  String get aiWebLabel => 'From the internet — unverified';

  @override
  String get aiWebNote =>
      'Not found in the app’s knowledge base. This answer comes from a web search and is NOT verified by experts. Check it against primary sources.';

  @override
  String get aiWebSourcesTitle => 'Web sources';

  @override
  String get aiWebSearch => 'Search the internet';

  @override
  String get aiWebSearching => 'Searching the internet…';

  @override
  String get aiErrQuota =>
      'The AI service quota is temporarily exhausted. Results from the knowledge base are shown.';

  @override
  String get aiErrOverloaded =>
      'The AI service is busy right now. Results from the knowledge base are shown; try again in a minute.';

  @override
  String get aiWebOpenFailed => 'Could not open the link.';

  @override
  String get classReconnecting => 'Reconnecting…';

  @override
  String get grpTitle => 'Groups and topic tests';

  @override
  String get grpEntrySubtitle =>
      'Your teacher’s groups: topic tests with a deadline';

  @override
  String get grpTeacherTileBody =>
      'Create a group, give a topic test, follow results live';

  @override
  String get grpStudentTileBody =>
      'Join your teacher’s group with a code or QR';

  @override
  String get grpIntro =>
      'The teacher gives a topic test to the group. You solve it in your own time before the deadline; the server counts the score.';

  @override
  String get grpDemoBanner =>
      'Demo mode: data stays on this device only. Real groups need the server connection.';

  @override
  String get grpPrivacyNote =>
      'The teacher and your group see your name and score — never your e-mail. Other students don’t see your answers.';

  @override
  String get grpSignInTitle => 'Sign in to join';

  @override
  String get grpSignInBody =>
      'Only registered accounts can join a group — your result is tied to your account. The invite is kept while you sign in.';

  @override
  String get grpSignInAction => 'Sign in';

  @override
  String get grpJoinByCode => 'Join with a code';

  @override
  String get grpScanAction => 'Scan QR';

  @override
  String get grpScanTitle => 'Scan group QR';

  @override
  String get grpScanHint =>
      'Point the camera at the QR on the teacher’s screen.';

  @override
  String get grpTeachingSection => 'My groups (teacher)';

  @override
  String get grpMemberSection => 'Groups I’m in';

  @override
  String get grpTeachingEmpty =>
      'No groups yet. Create one and share its code or QR with students.';

  @override
  String get grpMemberEmpty =>
      'You haven’t joined a group yet. Ask your teacher for the code or scan the QR.';

  @override
  String grpMembersCount(int count, int limit) {
    return 'Students: $count / $limit';
  }

  @override
  String grpMyNickname(String nickname) {
    return 'My name: $nickname';
  }

  @override
  String get grpRetry => 'Try again';

  @override
  String get grpRefresh => 'Refresh';

  @override
  String get grpCancel => 'Cancel';

  @override
  String get grpOk => 'OK';

  @override
  String get grpCreateAction => 'Create group';

  @override
  String get grpCreateTitle => 'New group';

  @override
  String get grpNameLabel => 'Group name';

  @override
  String get grpNameHelper =>
      'For example: “4th year, group 2”. Students see this name.';

  @override
  String get grpAssignAction => 'Give a topic test';

  @override
  String get grpInviteTitle => 'Invite code';

  @override
  String get grpInviteHint =>
      'Students scan the QR or enter the code in Learn → Groups.';

  @override
  String get grpCopyCode => 'Copy code';

  @override
  String get grpCodeCopied => 'Code copied';

  @override
  String grpCodeSpoken(String code) {
    return 'Group code $code';
  }

  @override
  String get grpTestsSection => 'Topic tests';

  @override
  String get grpTestsEmptyTeacher => 'No tests yet. Tap “Give a topic test”.';

  @override
  String get grpTestsEmptyStudent => 'The teacher hasn’t given a test yet.';

  @override
  String get grpMembersSection => 'Students';

  @override
  String get grpMembersEmpty =>
      'No students yet. Show the QR or code to the group.';

  @override
  String grpProgress(int started, int finished, int total) {
    return 'Started: $started · finished: $finished of $total';
  }

  @override
  String grpClosedProgress(int finished, int total) {
    return 'Closed · finished: $finished of $total';
  }

  @override
  String get grpRemoveAction => 'Remove from group';

  @override
  String get grpRemoveTitle => 'Remove the student?';

  @override
  String grpRemoveBody(String nickname) {
    return '“$nickname” will leave the group; their results in this group are deleted.';
  }

  @override
  String get grpLeaveAction => 'Leave group';

  @override
  String get grpLeaveTitle => 'Leave the group?';

  @override
  String get grpLeaveBody => 'You’ll need the code again to rejoin.';

  @override
  String get grpStartTest => 'Start test';

  @override
  String get grpContinueTest => 'Continue test';

  @override
  String grpMyScore(int score, int total) {
    return 'Result: $score / $total';
  }

  @override
  String get grpAssignTitle => 'Topic test for the group';

  @override
  String get grpTopicSection => 'Topic';

  @override
  String get grpChangeTopic => 'Change';

  @override
  String get grpTimeLimitLabel => 'Time limit';

  @override
  String get grpNoTimeLimit => 'No time limit';

  @override
  String grpMinutesN(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String grpQuestionsN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String grpDueLabel(String date) {
    return 'Due: $date';
  }

  @override
  String get grpVariantLabel => 'Different questions for each student';

  @override
  String get grpVariantShort => 'variants';

  @override
  String get grpVariantHelp =>
      'Each student gets their own set from the topic (fixed by the server).';

  @override
  String grpVariantTooFew(int available, int needed) {
    return 'Variants are off: the topic has $available questions, at least $needed are needed (twice the number per student). Otherwise the sets would be almost the same.';
  }

  @override
  String get grpRevealSection => 'When are correct answers shown?';

  @override
  String get grpRevealAfterDue =>
      'After the deadline (or when I close the test)';

  @override
  String get grpRevealAfterClose => 'Only when I close the test';

  @override
  String get grpAssignSubmit => 'Give the test';

  @override
  String get grpLiveTitle => 'Test results (live)';

  @override
  String get grpTestQrTitle => 'One QR for everyone';

  @override
  String get grpTestQrHint =>
      'Students scan it; their name is filled in automatically — and the test opens.';

  @override
  String get grpBigScreen => 'Big screen';

  @override
  String get grpPreviewShort => 'Try as student';

  @override
  String grpCounts(int joined, int solving, int finished) {
    return 'Joined: $joined · solving: $solving · finished: $finished';
  }

  @override
  String get grpStateJoined => 'Joined';

  @override
  String get grpStateSolving => 'Solving';

  @override
  String get grpStateFinished => 'Finished';

  @override
  String get grpCloseAction => 'Close the test';

  @override
  String get grpCloseTitle => 'Close the test?';

  @override
  String get grpCloseBody =>
      'New attempts won’t start. Students who are solving get 30 seconds to send; then their saved answers are counted. Correct answers open to students.';

  @override
  String get grpClosedBanner =>
      'The test is closed — correct answers are open to students.';

  @override
  String get grpBoardHint =>
      'FORENSIC EXPERT → Learn → Groups: scan the QR or enter the code';

  @override
  String get grpBoardWaiting => 'Waiting for students…';

  @override
  String grpRevealAfterDueNote(String date) {
    return 'Correct answers open after the deadline ($date) or when the teacher closes the test.';
  }

  @override
  String get grpRevealAfterCloseNote =>
      'Correct answers open when the teacher closes the test.';

  @override
  String get grpJoinTitle => 'Join a group';

  @override
  String get grpCodeLabel => 'Group code';

  @override
  String get grpCodeHelper =>
      '8 characters. The code has no 0, O, 1, I or L. A pasted link also works.';

  @override
  String get grpContinue => 'Continue';

  @override
  String get grpJoinAction => 'Join and open the test';

  @override
  String grpJoinGroupName(String name) {
    return 'Group: $name';
  }

  @override
  String get grpNickLabel => 'Your name';

  @override
  String get grpNickHelper =>
      'Filled in from your profile — change it if you like. 2–20 characters, asked only once. The teacher and the group see this name (never your e-mail).';

  @override
  String get grpNickNeeded => 'Enter your name to join.';

  @override
  String get grpOwnerTitle => 'You are the teacher of this group';

  @override
  String grpOwnerBody(String group) {
    return 'This is your own invite for “$group”. A teacher can’t join their own group as a student — you can open it as the teacher or try the test as a student would see it.';
  }

  @override
  String get grpPreviewAction => 'Try as a student';

  @override
  String get grpOwnerOpen => 'Open as teacher';

  @override
  String get grpOwnerOtherAccount =>
      'To take the test for real, sign in with a different (student) account.';

  @override
  String get grpTestTitle => 'Topic test';

  @override
  String grpQuestionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String grpAnsweredOf(int answered, int total) {
    return 'Answered $answered of $total';
  }

  @override
  String grpTimeLeftSemantics(String time) {
    return 'Time left: $time';
  }

  @override
  String get grpPrev => 'Back';

  @override
  String get grpNext => 'Next';

  @override
  String get grpFinish => 'Finish';

  @override
  String get grpSubmitTitle => 'Send your answers?';

  @override
  String get grpSubmitBodyAll =>
      'All questions are answered. After sending you can’t change them.';

  @override
  String grpSubmitBodyLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions have no answer.',
      one: '1 question has no answer.',
    );
    return '$_temp0 After sending you can’t change them.';
  }

  @override
  String get grpSubmitAction => 'Send';

  @override
  String get grpLateSubmitted =>
      'Time was up — your last saved answers were counted.';

  @override
  String get grpPreviewBanner =>
      'Trial mode: this is what students see. Nothing is sent to the server.';

  @override
  String grpPreviewDone(int score, int total) {
    return 'Trial finished: $score / $total';
  }

  @override
  String get grpPreviewNothingSent =>
      'Nothing was sent to the server — students’ results are not affected.';

  @override
  String get grpBackToGroup => 'Back to the group';

  @override
  String get grpResultTitle => 'My result';

  @override
  String get grpScoreCaption => 'correct answers (counted by the server)';

  @override
  String get grpExpiredNote =>
      'Time ran out — your saved answers were counted.';

  @override
  String get grpAnswersSection => 'Answers and explanations';

  @override
  String grpYourAnswer(String answer) {
    return 'Your answer: $answer';
  }

  @override
  String grpCorrectAnswer(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get grpNoAnswer => 'No answer';

  @override
  String grpPage(String page) {
    return 'p. $page';
  }

  @override
  String get grpErrNotConfigured =>
      'Groups will work once the FORENSIC EXPERT server is connected.';

  @override
  String get grpErrSessionExpired =>
      'Your session has ended. Please sign in again.';

  @override
  String get grpErrOffline => 'No internet connection. Check it and try again.';

  @override
  String get grpErrServer =>
      'Something went wrong on the server. Try again in a moment.';

  @override
  String get grpErrForbidden => 'You don’t have access to this group.';

  @override
  String get grpErrRateLimited => 'Too many attempts. Try again in an hour.';

  @override
  String get grpErrBadCode => 'Enter the 8-character group code.';

  @override
  String get grpErrCodeAmbiguous =>
      'Group codes never contain 0, O, 1, I or L. Check the code on the teacher’s screen: it may be a similar letter or digit (for example 2 or Z, 8 or B).';

  @override
  String get grpErrNotFound =>
      'No group with this code. Check it and try again.';

  @override
  String get grpErrGroupFull =>
      'The group is full (200 students). Tell your teacher.';

  @override
  String get grpErrNickLength => 'The name must be 2–20 characters.';

  @override
  String get grpErrNickChars =>
      'Use letters, digits, spaces and . _ \' - only (no e-mail or links).';

  @override
  String get grpErrNickBlocked => 'Please write a different name.';

  @override
  String get grpErrNickTaken =>
      'This name is already in the group. Add the first letter of your surname.';

  @override
  String get grpErrBadName => 'The group name must be 2–60 characters.';

  @override
  String get grpErrTooManyGroups => 'You already have 30 groups — the maximum.';

  @override
  String get grpErrInvalidSettings =>
      'Check the settings: 1–50 questions, time limit 1–180 minutes.';

  @override
  String get grpErrBadDue =>
      'The deadline must be in the future (within a year).';

  @override
  String get grpErrRevealNeedsDue => '“After the deadline” needs a deadline.';

  @override
  String grpErrNotEnoughQuestions(int available) {
    return 'The topic has only $available questions.';
  }

  @override
  String get grpErrTooManyAssignments =>
      'The group already has 50 open tests. Close some first.';

  @override
  String get grpErrClosed => 'The teacher has closed this test.';

  @override
  String get grpErrPastDue => 'The deadline for this test has passed.';

  @override
  String get grpErrAlreadySubmitted => 'You have already sent this test.';

  @override
  String get grpErrTimeOver =>
      'Time is up — new answers are no longer accepted.';

  @override
  String get grpErrNotSubmitted => 'You haven’t sent this test yet.';

  @override
  String get grpChoiceTitle => 'Topic test';

  @override
  String get grpChoiceAssign => 'Give to a group';

  @override
  String get grpChoiceAssignHint =>
      'Students solve it in their own time; results come to you';

  @override
  String get grpChoiceSelf => 'Try it myself';

  @override
  String get grpChoiceSelfHint =>
      '10 questions on this device; nothing is sent';

  @override
  String get grpChoiceLive => 'Live group test';

  @override
  String get grpChoiceLiveHint =>
      'Code and QR on the screen, questions one by one';

  @override
  String get grpChoicePickGroup => 'Which group?';

  @override
  String get grpCountSection => 'Number of questions';

  @override
  String grpCountAll(int count) {
    return 'All $count';
  }

  @override
  String get grpCustom => 'Other…';

  @override
  String grpCustomValue(int value) {
    return 'Other: $value';
  }

  @override
  String grpCountCustomHint(int max) {
    return 'Any number from 1 to $max (all available questions).';
  }

  @override
  String grpCountHint(int count, int pool) {
    return 'Each student gets $count questions; $pool are available.';
  }

  @override
  String get grpNoTimeLimitShort => 'No limit';

  @override
  String get grpTimeCustomHint => 'Minutes, from 1 to 180.';

  @override
  String get grpTimeLimitHint =>
      'Counted from the moment the student starts; when time is up, the answers are sent automatically.';

  @override
  String get grpOpenSection => 'How long the test stays open';

  @override
  String grpDaysN(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get grpPickDate => 'Pick a date';

  @override
  String grpOpenHint(String date) {
    return 'Students can start until $date. This is not the time for solving — that is the time limit above.';
  }

  @override
  String get grpMixedAction => 'Give a combined test';

  @override
  String get grpMixedTitle => 'Combined test';

  @override
  String get grpMixedPrefix => 'Combined test';

  @override
  String get grpMixedIntro =>
      'Pick topics from one or more sources. Questions are taken from the topics in turn and never repeat.';

  @override
  String get grpMixedSources => 'Sources';

  @override
  String get grpMixedOtherSource => 'Other topics';

  @override
  String grpMixedSourceLine(int count, int picked) {
    return 'Topics: $count · selected: $picked';
  }

  @override
  String get grpSelectAll => 'Select all';

  @override
  String grpMixedSelected(int topics, int questions) {
    return 'Selected: $topics topics, $questions questions';
  }

  @override
  String get grpMixedTitleLabel => 'Test name';

  @override
  String get grpMixedTitleHint =>
      'Filled in automatically — you can change it.';

  @override
  String get grpMixedPreviewAction => 'Preview the questions';

  @override
  String grpMixedPreviewTitle(int count) {
    return '$count questions, by topic:';
  }

  @override
  String get grpMixedPreviewNote =>
      'Example of the selection. The server picks the exact questions at random within each topic, with the same split.';

  @override
  String get grpPracticeBanner =>
      'Trying it yourself: nothing is sent to the server.';

  @override
  String get grpPracticeNothingSent =>
      'This was a trial on your device — nothing was sent.';

  @override
  String grpCountMax(int count) {
    return 'Max $count';
  }

  @override
  String classQuestionCountAll(int n) {
    return 'All · $n';
  }

  @override
  String get classQuestionCountOther => 'Other';

  @override
  String classQuestionCountLimited(int n) {
    return 'This topic has only $n questions, so larger choices are not available.';
  }

  @override
  String get classTranslationPending =>
      'Translation pending — original Uzbek text';

  @override
  String get classHardestOpenHint => 'Tap a question to discuss it';

  @override
  String get classDiscussTitle => 'Question discussion';

  @override
  String classDiscussPosition(int n, int total) {
    return 'Hard question $n / $total';
  }

  @override
  String classDiscussWrongPct(int pct) {
    return '$pct% wrong';
  }

  @override
  String classDiscussAnswered(int n) {
    return '$n answers';
  }

  @override
  String get classDiscussCorrectMark => 'Correct answer';

  @override
  String get classDiscussExplanation => 'Explanation';

  @override
  String get classDiscussNoExplanation => 'No explanation for this question.';

  @override
  String get classDiscussSource => 'Source';

  @override
  String get classDiscussPrev => 'Previous';

  @override
  String get classDiscussNext => 'Next';

  @override
  String get classDiscussUnavailable =>
      'Details are not available right now. Showing the question text and wrong-answer share only.';

  @override
  String get classDiscussBigFont => 'Large text';

  @override
  String classDiscussPicked(int n) {
    return '$n chose this';
  }

  @override
  String get classDiscussClose => 'Close';

  @override
  String classLeaderCorrect(int correct, int total) {
    return '$correct/$total correct';
  }

  @override
  String classLeaderAvgTime(String seconds) {
    return 'avg $seconds s';
  }

  @override
  String get grpLessonGroupTest => 'Give a test to a group';

  @override
  String get grpLessonGroupTestHint =>
      'Students join by QR; results appear on screen by name, with places.';

  @override
  String get grpLessonTitle => 'Group test';

  @override
  String get grpLessonGroupSection => 'Group';

  @override
  String get grpLessonNewGroup => 'New group';

  @override
  String get grpLessonNoGroups =>
      'You have no group yet. Type a name — the group is created right here.';

  @override
  String get grpLessonCreateGroup => 'Create group';

  @override
  String get grpLessonCancelNew => 'Pick an existing group';

  @override
  String get grpLessonTopicSection => 'Topic (from this lesson)';

  @override
  String get grpLessonTopicFixed =>
      'The test is built from this lesson’s topic.';

  @override
  String get grpLessonNoTopic =>
      'No test questions were found for this lesson.';

  @override
  String get grpLessonStart => 'Start the test';

  @override
  String get grpLessonPickGroup => 'Choose a group first.';

  @override
  String get grpLessonStartedTitle => 'The test has started';

  @override
  String get grpLessonStartedHint =>
      'Students scan the QR or enter the code. They join the group under their own name and the test opens.';

  @override
  String get grpLessonLiveResults => 'Live results';

  @override
  String get grpLessonTeacherPanel => 'Teacher panel';

  @override
  String get grpLessonJoinLink => 'Group code';

  @override
  String get grpColRank => 'Place';

  @override
  String get grpColName => 'Name';

  @override
  String get grpColCorrect => 'Correct';

  @override
  String get grpColTime => 'Time';

  @override
  String get grpColState => 'Status';

  @override
  String grpRankSpoken(int rank) {
    return 'Place $rank';
  }

  @override
  String get grpBoardClosed => 'The test is closed';

  @override
  String get grpHardestTitle => 'Hard questions';

  @override
  String get grpHardestBody =>
      'The questions most students got wrong, picked automatically. Discuss them together.';

  @override
  String get grpHardestOpen => 'Discuss hard questions';

  @override
  String get grpHardestLocked =>
      'Close the test to see the hard questions here.';

  @override
  String get grpErrNotFinished =>
      'Hard questions appear after the test is closed.';

  @override
  String get lessonImageFailed => 'Image failed to load';

  @override
  String get lessonImageClose => 'Close';

  @override
  String get lessonImageZoom => 'Enlarge image';

  @override
  String lessonImageCredit(String credit) {
    return 'Image: $credit';
  }

  @override
  String get modeTeacher => 'Teacher';

  @override
  String get modeTeacherDescription =>
      'Lecturers: lecture decks by discipline, a group test after every topic, live results with places';

  @override
  String get modeTeacherNote =>
      'Lessons and tests open with the teacher role on the server. The role is granted by the administrator — see the note in the Teacher panel.';

  @override
  String get disciplineLessonsTitle => 'Lessons: presentation and group test';

  @override
  String disciplineLessonsBody(int count) {
    return '$count lessons. Open a lesson — at the end, «Give a test to a group»: students join by QR, results by name with places, hard questions for discussion.';
  }

  @override
  String get disciplineLessonGroupTest => 'Group test';

  @override
  String get disciplineLessonsTeacherOnly =>
      'Lessons and group tests open with the teacher role. Open the Teacher panel to see how to get it.';

  @override
  String get disciplineLessonsAll => 'All lessons';

  @override
  String get homeInstrumentsTitle => 'Working with instruments';

  @override
  String get homeInstrumentsBody =>
      'Ethanol by GC (Kristallyuks), COHb on UV-1900, GC-MS basics: procedure, photos, test';

  @override
  String get lessonsOpenNote =>
      'You see the open courses. Lecture decks for teaching open with the teacher role.';

  @override
  String disciplineLessonsMore(int count) {
    return 'Show $count more lessons';
  }

  @override
  String get proUnlock => 'Unlock with Pro';

  @override
  String get proTitle => 'Pro plan';

  @override
  String get proPlanStudent => 'Student Pro';

  @override
  String get proPlanTeacher => 'Teacher Pro';

  @override
  String get proPlanExpert => 'Expert Pro';

  @override
  String get proProfileRow => 'Plan';

  @override
  String get proFreeAlways =>
      'Safety information, sources and provenance are always free.';

  @override
  String get proBenefitFullQuizBank =>
      'Full question bank: 4,370 questions in 211 topics';

  @override
  String get proBenefitExamMode => 'Exam mode with a review of every answer';

  @override
  String get proBenefitAllFlashcards => 'Flashcards for all subjects';

  @override
  String get proBenefitErrorAnalytics => 'Error analysis and statistics';

  @override
  String get proBenefitOfflineDownload =>
      'Download materials for offline study';

  @override
  String get proBenefitAllLessons => 'All 211 lecture presentations';

  @override
  String get proBenefitUnlimitedGroupTests =>
      'Unlimited groups and group tests of more than 10 questions';

  @override
  String get proBenefitResultsCsv => 'Export results to CSV';

  @override
  String get proBenefitHardestDiscussion =>
      'Discussion of the hardest questions';

  @override
  String get proBenefitLiveTestLarge => 'Live tests for large audiences';

  @override
  String get proBenefitInstrumentsCourseFull =>
      'The full «Working with instruments» course';

  @override
  String get proBenefitProCalculators =>
      'Professional calculators: PMI, concentration, LOD/LOQ and more';

  @override
  String get proBenefitCaseNotebook =>
      'Expert casebook with sourced blocks for your conclusions';

  @override
  String get proBenefitCourtPrep =>
      'Court testimony preparation: simulator, drills and statistics';

  @override
  String get proBenefitAiExtended => 'A higher daily AI limit';

  @override
  String get proCtxAllLessons =>
      'All 211 lecture presentations and their tests open with Teacher Pro.';

  @override
  String get proCtxInstrumentsRest =>
      'All lessons of this course and their tests open with Expert Pro.';

  @override
  String get proCtxGroupLimit =>
      'The free plan includes one group. Create more groups with Teacher Pro.';

  @override
  String get proStateFree => 'Free plan';

  @override
  String get proStateFreeBody =>
      'Reference, sources and safety information are always free. Pro adds extra tools for your mode.';

  @override
  String proStateTrial(String plan) {
    return '$plan: free trial';
  }

  @override
  String proStateActive(String plan) {
    return '$plan is active';
  }

  @override
  String proStateUntil(String date) {
    return 'Until $date';
  }

  @override
  String get proStateNoEnd => 'No end date';

  @override
  String get proAutoRenewOn => 'Auto-renews';

  @override
  String get proAutoRenewOff => 'Does not renew';

  @override
  String get proSourceStore => 'Store subscription';

  @override
  String get proSourceAdmin => 'Granted by administrator';

  @override
  String get proSourceTrial => 'Free trial';

  @override
  String get proOwnModeNote =>
      'A plan unlocks features of its own mode only. Switching the mode does not unlock another plan’s features.';

  @override
  String get proTeacherRoleNote =>
      'The Teacher panel still requires the teacher role on the server; Pro does not grant the role.';

  @override
  String get proIncludesStudent1 =>
      'Full question bank: 4,370 questions in 211 topics';

  @override
  String get proIncludesStudent2 => 'Exam mode with a review of every answer';

  @override
  String get proIncludesStudent3 => 'Flashcards for all subjects';

  @override
  String get proIncludesStudent4 => 'Error analysis and statistics';

  @override
  String get proIncludesTeacher1 =>
      'All 211 lecture presentations (projector mode)';

  @override
  String get proIncludesTeacher2 =>
      'Unlimited groups and tests of more than 10 questions';

  @override
  String get proIncludesTeacher3 => 'Results export to CSV';

  @override
  String get proIncludesTeacher4 => 'Discussion of the hardest questions';

  @override
  String get proIncludesExpert1 =>
      'The full «Working with instruments» course: Kristallyuks/ethanol, UV-1900/COHb, GC-MS';

  @override
  String get proIncludesExpert2 =>
      'Professional calculators: PMI, concentration, LOD/LOQ and more';

  @override
  String get proIncludesExpert3 =>
      'Expert casebook and court testimony preparation';

  @override
  String get proIncludesExpert4 => 'A higher daily AI limit';

  @override
  String get proGuestTitle => 'Sign in to use Pro';

  @override
  String get proGuestBody =>
      'A plan is tied to your account and works on all your devices. The reference and safety information stay free without an account.';

  @override
  String get proGuestSignIn => 'Sign in with an email code';

  @override
  String get proChoose => 'Choose a subscription';

  @override
  String get proAlreadyActive => 'This plan is already active on your account.';

  @override
  String get proStoreUnavailable =>
      'The store is not available right now (for example on an emulator or without a store account). The price is shown in the store when you subscribe.';

  @override
  String get proStoreNoProducts =>
      'The store did not return this plan’s subscriptions yet. Try again later; the price is shown in the store.';

  @override
  String get proMonthly => 'Monthly';

  @override
  String get proYearly => 'Yearly';

  @override
  String get proBuy => 'Buy';

  @override
  String get proTrialButton => 'Try free for 30 days';

  @override
  String get proTrialNote =>
      'The free trial is available once per device and once per account. It ends on its own and nothing is charged.';

  @override
  String get proRestore => 'Restore purchases';

  @override
  String get proFlowWorking => 'Please wait…';

  @override
  String get proFlowSuccess => 'Done. Your plan is active.';

  @override
  String get proFlowPending =>
      'The purchase is waiting for approval. The plan turns on after it is confirmed.';

  @override
  String get proFlowCanceled =>
      'The purchase was cancelled. Nothing was charged.';

  @override
  String get proFlowStoreNotConfigured =>
      'Store purchase verification is not connected on the server yet. Your purchase is kept and will be checked once it is connected.';

  @override
  String get proFlowInvalid =>
      'The purchase could not be verified. If you were charged, contact support.';

  @override
  String get proFlowOffline =>
      'No connection. The purchase will be checked when the internet is back.';

  @override
  String get proFlowError => 'Something went wrong. Please try again.';

  @override
  String get proFlowRestoreNothing =>
      'No purchases to restore were found for this store account.';

  @override
  String get proTrialUsedDevice =>
      'The free trial has already been used on this device.';

  @override
  String get proTrialUsedAccount =>
      'The free trial has already been used on this account.';

  @override
  String get proTrialHasPlan =>
      'You already have an active plan, so the trial is not needed.';

  @override
  String get proTrialUnavailable =>
      'The trial cannot be offered on this device.';

  @override
  String get proTermsTitle => 'Subscription terms';

  @override
  String get proTermsBody =>
      'Subscriptions are monthly or yearly and renew automatically. The price and billing period are shown in the store before you confirm. Payment is charged to your Apple ID or Google Play account at confirmation. The subscription renews unless it is cancelled at least 24 hours before the end of the current period, and your account is charged for the next period within 24 hours before the end. You can manage or cancel it at any time in your store account settings; cancelling takes effect at the end of the paid period. A free trial or introductory offer shown by the store ends automatically.';

  @override
  String get proCancelHowIos =>
      'To cancel on iPhone: Settings → your name → Subscriptions → FORENSIC EXPERT → Cancel Subscription.';

  @override
  String get proCancelHowAndroid =>
      'To cancel on Android: Google Play → profile icon → Payments & subscriptions → Subscriptions → FORENSIC EXPERT → Cancel subscription.';

  @override
  String get proManage => 'Manage or cancel subscription';

  @override
  String get proManageFailed =>
      'Could not open the store page. Open your store account settings manually.';

  @override
  String get proTermsLink => 'Terms of Use';

  @override
  String get proPrivacyLink => 'Privacy Policy';

  @override
  String get proOfferStudentTitle => 'Study without limits';

  @override
  String get proOfferStudentBody =>
      'Student Pro opens the full question bank, exam mode, all flashcards and error analysis. A free trial, if available, is shown on the Pro page.';

  @override
  String get proOfferTeacherTitle => 'Teach with more tools';

  @override
  String get proOfferTeacherBody =>
      'Teacher Pro opens all 211 presentations, unlimited groups, longer tests, CSV export and discussion of the hardest questions. A free trial, if available, is shown on the Pro page.';

  @override
  String get proOfferExpertTitle => 'Tools for your casework';

  @override
  String get proOfferExpertBody =>
      'Expert Pro opens the full instruments course, professional calculators, the casebook, court testimony preparation and a higher AI limit. A free trial, if available, is shown on the Pro page.';

  @override
  String get proOfferOpen => 'Learn more';

  @override
  String get proOfferDismiss => 'Dismiss';

  @override
  String get studyStatsTitle => 'Error statistics';

  @override
  String get studyStatsEmpty =>
      'Review some cards first — statistics will appear here.';

  @override
  String studyStatsSummary(int reviewed, int weak, int learned) {
    return 'Reviewed: $reviewed · difficult: $weak · mastered: $learned';
  }

  @override
  String studyStatsWeakDeck(String deck, int count) {
    return '$deck: $count difficult';
  }

  @override
  String get admProTitle => 'Grant Pro';

  @override
  String get admProHint => 'Plan for an email, duration, list, revoke';

  @override
  String get admProNote =>
      'A plan granted here is recorded in the audit log with the source “administrator”. A store subscription takes precedence.';

  @override
  String get admProGrantTitle => 'Grant a plan';

  @override
  String get admProEmail => 'User email';

  @override
  String get admProPlan => 'Plan';

  @override
  String get admProUntil => 'Duration';

  @override
  String get admProDays30 => '30 days';

  @override
  String get admProDays90 => '90 days';

  @override
  String get admProYear => '1 year';

  @override
  String get admProNoLimit => 'No limit';

  @override
  String get admProGrant => 'Grant';

  @override
  String get admProRevoke => 'Revoke';

  @override
  String get admProGranted => 'The plan has been granted.';

  @override
  String get admProRevoked => 'The plan has been revoked.';

  @override
  String get admProNotFound => 'No user with this email.';

  @override
  String get admProInvalid => 'Enter a valid email address.';

  @override
  String get admProError => 'Could not complete the request. Try again.';

  @override
  String get admProListTitle => 'Granted plans';

  @override
  String get admProSearch => 'Search by email';

  @override
  String get admProEmpty => 'No plans yet.';

  @override
  String get studyNoGuaranteeNote =>
      'Practice questions are prepared for study from open sources. They are not a guarantee that the same questions will appear in an official exam.';

  @override
  String get proPlanPremium => 'Premium';

  @override
  String get proIncludesPremium1 =>
      'Everything in Student Pro, Teacher Pro and Expert Pro in one plan';

  @override
  String get proIncludesPremium2 =>
      'All lessons and presentations, tests, exam mode, flashcards and error analytics';

  @override
  String get proIncludesPremium3 =>
      'Groups and group tests, results CSV, the instruments course, professional calculators, casebook and court preparation';

  @override
  String get proPremiumBest => 'Best value: Premium — everything unlocked';

  @override
  String get proPremiumBody =>
      'Cheaper than buying the three plans separately.';

  @override
  String get proPremiumSee => 'See Premium';

  @override
  String get proPremiumBack => 'Back to my plan';
}
