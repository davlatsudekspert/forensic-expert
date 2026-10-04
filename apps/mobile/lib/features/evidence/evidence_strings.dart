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
}
