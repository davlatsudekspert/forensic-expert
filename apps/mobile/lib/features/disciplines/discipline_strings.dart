import 'package:fe_content_schema/fe_content_schema.dart';

import '../../core/l10n/generated/app_localizations.dart';

extension DisciplineStrings on AppLocalizations {
  String disciplineName(ForensicDiscipline d) => switch (d) {
    ForensicDiscipline.forensicMedicine => disc_forensicMedicine,
    ForensicDiscipline.forensicPathology => disc_forensicPathology,
    ForensicDiscipline.clinicalForensicMedicine =>
      disc_clinicalForensicMedicine,
    ForensicDiscipline.forensicRadiology => disc_forensicRadiology,
    ForensicDiscipline.forensicPsychiatry => disc_forensicPsychiatry,
    ForensicDiscipline.forensicToxicology => disc_forensicToxicology,
    ForensicDiscipline.forensicChemistry => disc_forensicChemistry,
    ForensicDiscipline.forensicBiochemistry => disc_forensicBiochemistry,
    ForensicDiscipline.analyticalScience => disc_analyticalScience,
    ForensicDiscipline.forensicBiology => disc_forensicBiology,
    ForensicDiscipline.forensicGenetics => disc_forensicGenetics,
    ForensicDiscipline.forensicSerology => disc_forensicSerology,
    ForensicDiscipline.forensicHistology => disc_forensicHistology,
    ForensicDiscipline.forensicAnthropology => disc_forensicAnthropology,
    ForensicDiscipline.forensicOdontology => disc_forensicOdontology,
    ForensicDiscipline.forensicMicrobiology => disc_forensicMicrobiology,
    ForensicDiscipline.forensicEntomology => disc_forensicEntomology,
    ForensicDiscipline.humanIdentification => disc_humanIdentification,
    ForensicDiscipline.medicalCriminalistics => disc_medicalCriminalistics,
    ForensicDiscipline.traceEvidence => disc_traceEvidence,
    ForensicDiscipline.firearmsBallistics => disc_firearmsBallistics,
    ForensicDiscipline.questionedDocuments => disc_questionedDocuments,
    ForensicDiscipline.digitalForensics => disc_digitalForensics,
    ForensicDiscipline.laboratoryQuality => disc_laboratoryQuality,
    ForensicDiscipline.evidenceHandling => disc_evidenceHandling,
    ForensicDiscipline.educationResearch => disc_educationResearch,
  };

  String disciplineGroupName(DisciplineGroup g) => switch (g) {
    DisciplineGroup.medicine => discGroupMedicine,
    DisciplineGroup.toxicologyChemistry => discGroupToxChem,
    DisciplineGroup.biologyIdentification => discGroupBioId,
    DisciplineGroup.laboratory => discGroupLab,
    DisciplineGroup.criminalistics => discGroupCriminalistics,
    DisciplineGroup.education => discGroupEdu,
  };
}
