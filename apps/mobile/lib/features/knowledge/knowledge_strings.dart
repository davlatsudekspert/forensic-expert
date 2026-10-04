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
    _ => key,
  };
}
