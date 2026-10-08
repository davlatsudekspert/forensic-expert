import 'package:meta/meta.dart';

import 'evidence_graph.dart';
import 'jurisdiction.dart';
import 'knowledge.dart';

/// PHASE 6: global multidisiplinar forensic platforma taksonomiyasi.
///
/// Bu yerda faqat **axborot arxitekturasi** bor (nomlar, guruhlar,
/// bo‘limlar). Hech qanday ilmiy qiymat, diagnostik qoida yoki formula yo‘q —
/// mazmun har doim claim + manba sifatida keladi.

/// Fanlar guruhi (Home / Disciplines hub’da intellektual guruhlash).
enum DisciplineGroup {
  medicine,
  toxicologyChemistry,
  biologyIdentification,
  laboratory,

  /// Kriminalistika: tibbiy-kriminalistika, izshunoslik, ballistika,
  /// hujjatlar va raqamli kriminalistika.
  criminalistics,
  education,
}

/// Forensic fanlar (26 ta; kontenti yo‘q fanlar bo‘sh holatda ko‘rsatiladi,
/// soxta kontent qo‘shilmaydi). Kod barqaror (bookmark, qidiruv, URL).
enum ForensicDiscipline {
  forensicMedicine('forensic_medicine', DisciplineGroup.medicine),
  forensicPathology('forensic_pathology', DisciplineGroup.medicine),
  clinicalForensicMedicine(
    'clinical_forensic_medicine',
    DisciplineGroup.medicine,
  ),
  forensicRadiology('forensic_radiology', DisciplineGroup.medicine),

  /// Faqat professional ma’lumotnoma qamrovi (baholash vositasi emas).
  forensicPsychiatry(
    'forensic_psychiatry',
    DisciplineGroup.medicine,
    referenceOnly: true,
  ),
  forensicToxicology(
    'forensic_toxicology',
    DisciplineGroup.toxicologyChemistry,
  ),
  forensicChemistry('forensic_chemistry', DisciplineGroup.toxicologyChemistry),
  forensicBiochemistry(
    'forensic_biochemistry',
    DisciplineGroup.toxicologyChemistry,
  ),
  analyticalScience('analytical_science', DisciplineGroup.toxicologyChemistry),
  forensicBiology('forensic_biology', DisciplineGroup.biologyIdentification),
  forensicGenetics('forensic_genetics', DisciplineGroup.biologyIdentification),

  /// Sud serologiyasi (biologik iz va suyuqliklar, guruh mansubligi).
  forensicSerology('forensic_serology', DisciplineGroup.biologyIdentification),
  forensicHistology(
    'forensic_histology',
    DisciplineGroup.biologyIdentification,
  ),
  forensicAnthropology(
    'forensic_anthropology',
    DisciplineGroup.biologyIdentification,
  ),
  forensicOdontology(
    'forensic_odontology',
    DisciplineGroup.biologyIdentification,
  ),
  forensicMicrobiology(
    'forensic_microbiology',
    DisciplineGroup.biologyIdentification,
  ),
  forensicEntomology(
    'forensic_entomology',
    DisciplineGroup.biologyIdentification,
  ),
  humanIdentification(
    'human_identification',
    DisciplineGroup.biologyIdentification,
  ),
  medicalCriminalistics(
    'medical_criminalistics',
    DisciplineGroup.criminalistics,
  ),

  /// Trasologiya: izlar (oyoq, asbob, transport vositasi, mikroizlar).
  traceEvidence('trace_evidence', DisciplineGroup.criminalistics),
  firearmsBallistics('firearms_ballistics', DisciplineGroup.criminalistics),
  questionedDocuments('questioned_documents', DisciplineGroup.criminalistics),
  digitalForensics('digital_forensics', DisciplineGroup.criminalistics),
  laboratoryQuality('laboratory_quality', DisciplineGroup.laboratory),
  evidenceHandling('evidence_handling', DisciplineGroup.laboratory),
  educationResearch('education_research', DisciplineGroup.education);

  const ForensicDiscipline(this.code, this.group, {this.referenceOnly = false});

  final String code;
  final DisciplineGroup group;

  /// Faqat ma’lumotnoma (masalan, sud psixiatriyasi — klinik baholash emas).
  final bool referenceOnly;

  static ForensicDiscipline? fromCode(String c) {
    for (final d in values) {
      if (d.code == c) return d;
    }
    return null;
  }
}

/// Mavjud bilim sohasi qaysi fanga tegishli (aniq xarita, taxmin yo‘q).
ForensicDiscipline disciplineOfArea(KnowledgeArea a) => switch (a) {
  KnowledgeArea.forensicMedicine => ForensicDiscipline.forensicMedicine,
  KnowledgeArea.toxicology => ForensicDiscipline.forensicToxicology,
  KnowledgeArea.biochemistry => ForensicDiscipline.forensicBiochemistry,
  KnowledgeArea.histology => ForensicDiscipline.forensicHistology,
  KnowledgeArea.laboratory ||
  KnowledgeArea.methods => ForensicDiscipline.analyticalScience,
  KnowledgeArea.reagents ||
  KnowledgeArea.screening => ForensicDiscipline.forensicChemistry,
  KnowledgeArea.emergingIssues => ForensicDiscipline.forensicToxicology,
  KnowledgeArea.education => ForensicDiscipline.educationResearch,
  KnowledgeArea.jurisdiction => ForensicDiscipline.evidenceHandling,
};

/// Sud tibbiyoti taksonomiyasi mavzusining fani.
ForensicDiscipline disciplineOfFmTopic(ForensicMedicineTopic t) => switch (t) {
  ForensicMedicineTopic.anthropology ||
  ForensicMedicineTopic.ageEstimation ||
  ForensicMedicineTopic.sexEstimation ||
  ForensicMedicineTopic.statureEstimation =>
    ForensicDiscipline.forensicAnthropology,
  ForensicMedicineTopic.odontology => ForensicDiscipline.forensicOdontology,
  ForensicMedicineTopic.disasterVictimIdentification =>
    ForensicDiscipline.humanIdentification,
  ForensicMedicineTopic.histology => ForensicDiscipline.forensicHistology,
  ForensicMedicineTopic.postmortemImaging =>
    ForensicDiscipline.forensicRadiology,
  ForensicMedicineTopic.deathInvestigation ||
  ForensicMedicineTopic.causeMechanismManner =>
    ForensicDiscipline.forensicPathology,
  _ => ForensicDiscipline.forensicMedicine,
};

/// Hujjat turi — UI’da aniq yorliq: STANDARD / GUIDELINE / METHOD / SOP /
/// LAW / REGULATION / SCIENTIFIC ARTICLE / OFFICIAL DOCUMENT.
enum DocumentKind {
  law(BindingNature.legallyBinding),
  regulation(BindingNature.legallyBinding),
  standard(BindingNature.voluntaryUnlessAdopted),
  guideline(BindingNature.advisory),
  method(BindingNature.advisory),
  sop(BindingNature.institutional),
  scientificArticle(BindingNature.scientificEvidence),
  officialDocument(BindingNature.advisory);

  const DocumentKind(this.binding);

  /// Har bir qo‘llanma qonuniy majburiy emas — UI buni aniq aytadi.
  final BindingNature binding;
}

enum BindingNature {
  /// Faqat o‘z yurisdiksiyasida va kuchga kirgan bo‘lsa.
  legallyBinding,

  /// Qonun yoki akkreditatsiya qabul qilmaguncha ixtiyoriy.
  voluntaryUnlessAdopted,

  /// Tavsiya / eng yaxshi amaliyot.
  advisory,

  /// Faqat o‘sha muassasa ichida.
  institutional,

  /// Ilmiy dalil — normativ hujjat emas.
  scientificEvidence,
}

DocumentKind documentKindOfInstrument(InstrumentType t) => switch (t) {
  InstrumentType.law ||
  InstrumentType.internationalConvention => DocumentKind.law,
  InstrumentType.regulation ||
  InstrumentType.controlledSubstanceSchedule => DocumentKind.regulation,
  InstrumentType.standard => DocumentKind.standard,
  InstrumentType.nationalMethod => DocumentKind.method,
  InstrumentType.officialGuideline => DocumentKind.guideline,
};

DocumentKind documentKindOfMethod(MethodKind k) => switch (k) {
  MethodKind.scientificMethod => DocumentKind.method,
  MethodKind.internationalStandard => DocumentKind.standard,
  MethodKind.nationalMethod => DocumentKind.method,
  MethodKind.institutionalSop => DocumentKind.sop,
};

DocumentKind documentKindOfResearch(ResearchKind k) => switch (k) {
  ResearchKind.standard => DocumentKind.standard,
  ResearchKind.guideline => DocumentKind.guideline,
  ResearchKind.officialReport => DocumentKind.officialDocument,
  _ => DocumentKind.scientificArticle,
};

/// Forensik dolzarblik — dalil sifatidan **alohida** tushuncha.
/// Reviewer belgilamaguncha `unassessed`.
enum ForensicRelevance {
  unassessed('unassessed'),
  direct('direct'),
  supporting('supporting'),
  background('background');

  const ForensicRelevance(this.code);

  final String code;

  static ForensicRelevance fromCode(String? c) => values.firstWhere(
    (x) => x.code == c,
    orElse: () => ForensicRelevance.unassessed,
  );
}

// ---------------------------------------------------------------------------
// Kontent shablonlari (progressive disclosure va qamrov hisobi)
// ---------------------------------------------------------------------------

/// Shablon bo‘limi: qaysi claim maydonlari yoki graf bog‘lanishlari shu
/// bo‘limni to‘ldiradi. Bo‘sh bo‘lim UI’da «manbali ma’lumot hali yo‘q» deb
/// bitta qatorda ko‘rsatiladi — hech narsa to‘qilmaydi.
@immutable
class TemplateSection {
  const TemplateSection(
    this.code, {
    this.claimFields = const {},
    this.relations = const {},
    this.structural = false,
  });

  final String code;
  final Set<String> claimFields;
  final Set<LinkRelation> relations;

  /// Yozuvning o‘z tuzilmasidan to‘ladi (nomlar, retsept, ...).
  final bool structural;
}

enum TemplateKind {
  substance,
  method,
  reagent,
  rapidTest,
  biomarker,
  forensicMedicineTopic,
}

abstract final class ContentTemplates {
  static const substance = [
    TemplateSection('overview', claimFields: {'identity'}),
    TemplateSection('names', structural: true),
    TemplateSection('classification', structural: true),
    TemplateSection('metabolism', claimFields: {'metabolism_note'}),
    TemplateSection(
      'metabolites',
      claimFields: {'metabolites', 'transformation_product', 'biomarker'},
    ),
    TemplateSection('specimens', claimFields: {'specimen_note'}),
    TemplateSection('screening', claimFields: {'screening_note'}),
    TemplateSection('confirmation', claimFields: {'confirmation_note'}),
    TemplateSection(
      'analytical_methods',
      claimFields: {'analytical_method'},
      relations: {LinkRelation.analysedBy},
    ),
    TemplateSection(
      'reported_concentrations',
      claimFields: {'reported_concentration'},
    ),
    TemplateSection('interpretation', claimFields: {'interpretation'}),
    TemplateSection('postmortem', claimFields: {'postmortem_note'}),
    TemplateSection('stability', claimFields: {'stability'}),
    TemplateSection(
      'interferences',
      claimFields: {'interference', 'cross_reactivity'},
    ),
    TemplateSection('jurisdiction', structural: true),
    TemplateSection('research', relations: {LinkRelation.research}),
    TemplateSection('sources', structural: true),
  ];

  static const method = [
    TemplateSection('principle', claimFields: {'principle'}),
    TemplateSection(
      'forensic_use',
      claimFields: {'application', 'role_in_forensic_toxicology'},
    ),
    TemplateSection('specimens', claimFields: {'specimen_note'}),
    TemplateSection('sample_preparation', claimFields: {'sample_preparation'}),
    TemplateSection('instrumentation', claimFields: {'instrumentation'}),
    TemplateSection(
      'qualitative_quantitative',
      claimFields: {'quantitative_use'},
    ),
    TemplateSection('validation', claimFields: {'validation_requirement'}),
    TemplateSection('interference', claimFields: {'interference'}),
    TemplateSection('limitations', claimFields: {'limitation'}),
    TemplateSection('qc', claimFields: {'qc_requirement'}),
    TemplateSection('related_substances', relations: {LinkRelation.analysedBy}),
    TemplateSection('related_reagents', relations: {LinkRelation.usedIn}),
    TemplateSection('research', relations: {LinkRelation.research}),
  ];

  static const reagent = [
    TemplateSection('purpose', claimFields: {'use_context'}),
    TemplateSection(
      'composition',
      claimFields: {'composition_statement'},
      structural: true,
    ),
    TemplateSection('preparation', structural: true),
    TemplateSection('storage_stability', structural: true),
    TemplateSection(
      'safety',
      claimFields: {'hazard', 'test_class_limitation'},
      structural: true,
    ),
    TemplateSection('disposal', structural: true),
    TemplateSection('qc', structural: true),
    TemplateSection('linked_methods', relations: {LinkRelation.usedIn}),
    TemplateSection('research', relations: {LinkRelation.research}),
  ];

  static const rapidTest = [
    TemplateSection('technology', structural: true),
    TemplateSection('target_specimen', structural: true),
    TemplateSection('cutoff', structural: true),
    TemplateSection(
      'performance',
      claimFields: {'sensitivity', 'specificity'},
      structural: true,
    ),
    TemplateSection(
      'cross_reactivity',
      claimFields: {'cross_reactivity'},
      structural: true,
    ),
    TemplateSection('false_results', structural: true),
    TemplateSection(
      'limitations',
      claimFields: {
        'limitation',
        'test_class_limitation',
        'presumptive_nature',
      },
      structural: true,
    ),
    TemplateSection(
      'confirmation',
      claimFields: {'confirmation_requirement'},
      relations: {LinkRelation.confirmedBy},
    ),
    TemplateSection('research', relations: {LinkRelation.research}),
  ];

  static const biomarker = [
    TemplateSection('marker', claimFields: {'marker', 'application'}),
    TemplateSection('specimen', claimFields: {'specimen_note'}),
    TemplateSection('collection_context', claimFields: {'collection_context'}),
    TemplateSection(
      'postmortem_limitations',
      claimFields: {'limitation', 'postmortem_note'},
    ),
    TemplateSection('stability', claimFields: {'stability'}),
    TemplateSection('analytical_method', claimFields: {'analytical_method'}),
    TemplateSection(
      'interpretation_limitations',
      claimFields: {'interpretation'},
    ),
    TemplateSection('research', relations: {LinkRelation.research}),
  ];

  static const forensicMedicineTopic = [
    TemplateSection('definition', claimFields: {'definition', 'summary'}),
    TemplateSection(
      'findings',
      claimFields: {'marker', 'principle', 'application', 'case_observation'},
    ),
    TemplateSection('methods', claimFields: {'method_note'}),
    TemplateSection('limitations', claimFields: {'limitation'}),
    TemplateSection('research', relations: {LinkRelation.research}),
  ];

  static List<TemplateSection> of(TemplateKind k) => switch (k) {
    TemplateKind.substance => substance,
    TemplateKind.method => method,
    TemplateKind.reagent => reagent,
    TemplateKind.rapidTest => rapidTest,
    TemplateKind.biomarker => biomarker,
    TemplateKind.forensicMedicineTopic => forensicMedicineTopic,
  };
}
