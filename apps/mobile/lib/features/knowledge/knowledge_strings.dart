import 'package:fe_content_schema/fe_content_schema.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/knowledge/knowledge_models.dart';

/// Bilim sohalari nomlarini lokalizatsiya qiladi (ARB’dan).
extension KnowledgeStrings on AppLocalizations {
  String knowledgeKindTitle(KnowledgeKind k) => switch (k) {
    KnowledgeKind.topic => knowledgeTaxonomy,
    KnowledgeKind.reagent => moduleReagents,
    KnowledgeKind.screeningTest => moduleScreening,
    KnowledgeKind.method => moduleMethods,
    KnowledgeKind.emergingIssue => moduleEmerging,
  };

  String methodEvidenceTypeLabel(MethodEvidenceType t) => switch (t) {
    MethodEvidenceType.internationalStandard => evInternationalStandard,
    MethodEvidenceType.guideline => evGuideline,
    MethodEvidenceType.publishedValidatedMethod => evPublishedValidated,
    MethodEvidenceType.nationalMethod => evNationalMethod,
    MethodEvidenceType.localSopReference => evLocalSop,
    MethodEvidenceType.educationalSummary => evEducationalSummary,
  };

  String methodKindTitle(MethodKind k) => switch (k) {
    MethodKind.scientificMethod => methodKindScientific,
    MethodKind.internationalStandard => methodKindInternational,
    MethodKind.nationalMethod => methodKindNational,
    MethodKind.institutionalSop => methodKindSop,
  };

  String evidenceTypeName(EvidenceType t) => switch (t) {
    EvidenceType.officialAlert => evidenceTypeOfficialAlert,
    EvidenceType.peerReviewed => evidenceTypePeerReviewed,
    EvidenceType.report => evidenceTypeReport,
    EvidenceType.standard => evidenceTypeStandard,
  };

  String emergingCategoryName(EmergingCategory c) => switch (c) {
    EmergingCategory.newPsychoactiveSubstances => emergingCatNps,
    EmergingCategory.syntheticOpioids => emergingCatSyntheticOpioids,
    EmergingCategory.novelStimulants => emergingCatStimulants,
    EmergingCategory.analyticalChallenges => emergingCatAnalytical,
    EmergingCategory.newInterferences => emergingCatInterferences,
    EmergingCategory.postmortemInterpretation => emergingCatPostmortem,
    EmergingCategory.newStandards => emergingCatStandards,
    EmergingCategory.newBiomarkers => emergingCatBiomarkers,
    EmergingCategory.emergingMethods => emergingCatMethods,
    EmergingCategory.legalRegulatoryUpdates => emergingCatLegal,
    EmergingCategory.methodValidation => emergingCatValidation,
    EmergingCategory.laboratoryQuality => emergingCatQuality,
    EmergingCategory.scientificAlert => emergingCatAlert,
  };

  String fmTopicName(ForensicMedicineTopic t) => switch (t) {
    ForensicMedicineTopic.deathInvestigation => fmTopicDeathInvestigation,
    ForensicMedicineTopic.causeMechanismManner => fmTopicCauseMechanismManner,
    ForensicMedicineTopic.postmortemChanges => fmTopicPostmortemChanges,
    ForensicMedicineTopic.postmortemInterval => fmTopicPostmortemInterval,
    ForensicMedicineTopic.algorMortis => fmTopicAlgorMortis,
    ForensicMedicineTopic.rigorMortis => fmTopicRigorMortis,
    ForensicMedicineTopic.livorMortis => fmTopicLivorMortis,
    ForensicMedicineTopic.decomposition => fmTopicDecomposition,
    ForensicMedicineTopic.trauma => fmTopicTrauma,
    ForensicMedicineTopic.bluntForceInjury => fmTopicBluntForceInjury,
    ForensicMedicineTopic.sharpForceInjury => fmTopicSharpForceInjury,
    ForensicMedicineTopic.firearmInjury => fmTopicFirearmInjury,
    ForensicMedicineTopic.asphyxia => fmTopicAsphyxia,
    ForensicMedicineTopic.burns => fmTopicBurns,
    ForensicMedicineTopic.electricalInjury => fmTopicElectricalInjury,
    ForensicMedicineTopic.hypoHyperthermia => fmTopicHypoHyperthermia,
    ForensicMedicineTopic.drowning => fmTopicDrowning,
    ForensicMedicineTopic.anthropology => fmTopicAnthropology,
    ForensicMedicineTopic.ageEstimation => fmTopicAgeEstimation,
    ForensicMedicineTopic.sexEstimation => fmTopicSexEstimation,
    ForensicMedicineTopic.statureEstimation => fmTopicStatureEstimation,
    ForensicMedicineTopic.odontology => fmTopicOdontology,
    ForensicMedicineTopic.disasterVictimIdentification =>
      fmTopicDisasterVictimIdentification,
    ForensicMedicineTopic.histology => fmTopicHistology,
    ForensicMedicineTopic.postmortemImaging => fmTopicPostmortemImaging,
  };

  /// Solishtirish mavzusi (`topicKey`). Noma’lum kalit — o‘zi.
  String legalTopicName(String key) => switch (key) {
    'drink_drive.prescribed_limit' => compareTopicDrinkDrive,
    'controlled_substance.status' => compareTopicControlStatus,
    _ => key,
  };
  String templateSectionName(String code) => switch (code) {
    'overview' => tpl_overview,
    'names' => tpl_names,
    'classification' => tpl_classification,
    'metabolism' => tpl_metabolism,
    'metabolites' => tpl_metabolites,
    'specimens' => tpl_specimens,
    'screening' => tpl_screening,
    'confirmation' => tpl_confirmation,
    'analytical_methods' => tpl_analyticalMethods,
    'reported_concentrations' => tpl_reportedConcentrations,
    'interpretation' => tpl_interpretation,
    'postmortem' => tpl_postmortem,
    'stability' => tpl_stability,
    'interferences' => tpl_interferences,
    'jurisdiction' => tpl_jurisdiction,
    'research' => tpl_research,
    'sources' => tpl_sources,
    'principle' => tpl_principle,
    'forensic_use' => tpl_forensicUse,
    'sample_preparation' => tpl_samplePreparation,
    'instrumentation' => tpl_instrumentation,
    'qualitative_quantitative' => tpl_qualitativeQuantitative,
    'validation' => tpl_validation,
    'interference' => tpl_interference,
    'limitations' => tpl_limitations,
    'qc' => tpl_qc,
    'related_substances' => tpl_relatedSubstances,
    'related_reagents' => tpl_relatedReagents,
    'purpose' => tpl_purpose,
    'composition' => tpl_composition,
    'preparation' => tpl_preparation,
    'storage_stability' => tpl_storageStability,
    'safety' => tpl_safety,
    'disposal' => tpl_disposal,
    'linked_methods' => tpl_linkedMethods,
    'technology' => tpl_technology,
    'target_specimen' => tpl_targetSpecimen,
    'cutoff' => tpl_cutoff,
    'performance' => tpl_performance,
    'cross_reactivity' => tpl_crossReactivity,
    'false_results' => tpl_falseResults,
    'marker' => tpl_marker,
    'specimen' => tpl_specimen,
    'collection_context' => tpl_collectionContext,
    'postmortem_limitations' => tpl_postmortemLimitations,
    'analytical_method' => tpl_analyticalMethod,
    'interpretation_limitations' => tpl_interpretationLimitations,
    'definition' => tpl_definition,
    'findings' => tpl_findings,
    'methods' => tpl_methods,
    _ => code,
  };
}
