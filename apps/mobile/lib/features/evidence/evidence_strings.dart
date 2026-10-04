import 'package:fe_content_schema/fe_content_schema.dart';

import '../../core/l10n/generated/app_localizations.dart';

extension EvidenceStrings on AppLocalizations {
  String researchKindName(ResearchKind k) => switch (k) {
    ResearchKind.journalArticle => researchKindJournalArticle,
    ResearchKind.review => researchKindReview,
    ResearchKind.systematicReview => researchKindSystematicReview,
    ResearchKind.metaAnalysis => researchKindMetaAnalysis,
    ResearchKind.caseReport => researchKindCaseReport,
    ResearchKind.conferenceAbstract => researchKindConferenceAbstract,
    ResearchKind.conferencePaper => researchKindConferencePaper,
    ResearchKind.dissertation => researchKindDissertation,
    ResearchKind.thesis => researchKindThesis,
    ResearchKind.officialReport => researchKindOfficialReport,
    ResearchKind.standard => researchKindStandard,
  };

  String licenseName(String license) => switch (license) {
    'original_work' => licenseOriginalWork,
    'original_depiction_of_factual_data' => licenseFactualDepiction,
    _ => license,
  };

  String substanceGroupName(String g) => switch (g) {
    'alcohols_volatiles' => group_alcohols_volatiles,
    'toxic_gases' => group_toxic_gases,
    'opioids' => group_opioids,
    'stimulants' => group_stimulants,
    'cannabinoids' => group_cannabinoids,
    'hallucinogens_dissociatives' => group_hallucinogens_dissociatives,
    'benzodiazepines' => group_benzodiazepines,
    'sedatives_hypnotics' => group_sedatives_hypnotics,
    'barbiturates' => group_barbiturates,
    'antidepressants' => group_antidepressants,
    'antipsychotics' => group_antipsychotics,
    'anticonvulsants' => group_anticonvulsants,
    'pharmaceuticals' => group_pharmaceuticals,
    'adulterants' => group_adulterants,
    'pesticides' => group_pesticides,
    'metals_inorganic' => group_metals_inorganic,
    _ => g,
  };

  String techniqueName(AnalyticalTechnique t) => switch (t) {
    AnalyticalTechnique.tlc => tech_tlc,
    AnalyticalTechnique.gc => tech_gc,
    AnalyticalTechnique.gcFid => tech_gcFid,
    AnalyticalTechnique.headspaceGc => tech_headspaceGc,
    AnalyticalTechnique.gcMs => tech_gcMs,
    AnalyticalTechnique.hplc => tech_hplc,
    AnalyticalTechnique.lcMsMs => tech_lcMsMs,
    AnalyticalTechnique.uvVis => tech_uvVis,
    AnalyticalTechnique.immunoassay => tech_immunoassay,
    AnalyticalTechnique.spectroscopy => tech_spectroscopy,
    AnalyticalTechnique.samplePreparation => tech_samplePreparation,
    AnalyticalTechnique.extraction => tech_extraction,
    AnalyticalTechnique.calibration => tech_calibration,
    AnalyticalTechnique.qualityControl => tech_qualityControl,
    AnalyticalTechnique.validation => tech_validation,
    AnalyticalTechnique.uncertainty => tech_uncertainty,
    AnalyticalTechnique.statistics => tech_statistics,
  };

  String methodSectionName(MethodSection s) => switch (s) {
    MethodSection.purpose => methodSection_purpose,
    MethodSection.scope => methodSection_scope,
    MethodSection.analytes => methodSection_analytes,
    MethodSection.specimens => methodSection_specimens,
    MethodSection.principle => methodSection_principle,
    MethodSection.equipment => methodSection_equipment,
    MethodSection.reagents => methodSection_reagents,
    MethodSection.samplePreparation => methodSection_samplePreparation,
    MethodSection.calibrationQc => methodSection_calibrationQc,
    MethodSection.workflow => methodSection_workflow,
    MethodSection.interpretation => methodSection_interpretation,
    MethodSection.limitations => methodSection_limitations,
    MethodSection.validationStatus => methodSection_validationStatus,
  };
}
