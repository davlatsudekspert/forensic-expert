import 'package:meta/meta.dart';

import 'enums.dart';

/// Global Forensic Science Platform — bilim sohalari (PHASE 4).
///
/// Har bir soha bir xil provenance qoidalariga bo‘ysunadi: manba, dalil
/// darajasi, review statusi, versiya. Qiymatlar (retsept, cutoff, chegara)
/// faqat manba bilan — validator FE018–FE026.
enum KnowledgeArea {
  forensicMedicine,
  toxicology,
  biochemistry,
  histology,
  laboratory,
  reagents,
  screening,
  methods,
  emergingIssues,
  education,
  jurisdiction,
}

/// Sud tibbiyoti mavzulari — **faqat taksonomiya** (nomlar). Diagnostik
/// qoida yoki formula bu yerda yo‘q; mazmun claim + manba sifatida keladi.
enum ForensicMedicineTopic {
  deathInvestigation,
  causeMechanismManner,
  postmortemChanges,
  postmortemInterval,
  algorMortis,
  rigorMortis,
  livorMortis,
  decomposition,
  trauma,
  bluntForceInjury,
  sharpForceInjury,
  firearmInjury,
  asphyxia,
  burns,
  electricalInjury,
  hypoHyperthermia,
  drowning,
  anthropology,
  ageEstimation,
  sexEstimation,
  statureEstimation,
  odontology,
  disasterVictimIdentification,
  histology,
  postmortemImaging,
}

/// Toksikantlar sinflari (taksonomiya).
enum ToxicantClass {
  ethanol,
  drugsOfAbuse,
  pharmaceuticals,
  newPsychoactiveSubstances,
  syntheticOpioids,
  stimulants,
  sedatives,
  cannabinoids,
  volatileSubstances,
  toxicGases,
  metals,
  pesticides,
  poisons,
  other,
}

/// Laboratoriya texnikalari (taksonomiya).
enum AnalyticalTechnique {
  tlc,
  gc,
  gcFid,
  headspaceGc,
  gcMs,
  gcMsMs,
  hplc,
  lcMs,
  lcMsMs,
  hrms,
  uvVis,
  spectrophotometry,
  immunoassay,
  spectroscopy,
  samplePreparation,
  extraction,
  calibration,
  qualityControl,
  validation,
  uncertainty,
  statistics,
}

/// Manba bilan bog‘langan qiymat (cutoff, sezgirlik, konsentratsiya…).
/// Manbasiz raqam modelda bo‘lishi mumkin emas.
@immutable
class SourcedValue {
  const SourcedValue({
    required this.value,
    required this.unit,
    required this.sourceId,
    this.locator,
    this.context,
  });

  final num value;
  final String unit;
  final String sourceId;
  final String? locator;

  /// Masalan: matritsa, populyatsiya, qurilma modeli.
  final String? context;
}

/// Manba bilan bog‘langan matn (cross-reactivity, cheklov, xavf).
@immutable
class SourcedNote {
  const SourcedNote({required this.text, required this.sourceId, this.locator});

  final String text;
  final String sourceId;
  final String? locator;
}

// ---------------------------------------------------------------------------
// Reagents & Solutions
// ---------------------------------------------------------------------------

@immutable
class Ingredient {
  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.role,
  });

  final String name;
  final num amount;
  final String unit;
  final String? role;
}

@immutable
class PreparationStep {
  const PreparationStep({required this.text, this.order});

  final String text;

  /// Tartib raqami — faqat manba tartibni **aniq** aytgan bo‘lsa.
  final int? order;
}

/// Eritma / reagent tayyorlash retsepti.
///
/// Qat’iy qoida: ingredient miqdori, konsentratsiya, saqlash, harorat,
/// barqarorlik/yaroqlilik va tartib — **faqat manbadan** (FE018–FE020).
/// Manba yo‘q bo‘lsa retsept bo‘sh qoladi va UI «MA’LUMOT TEKSHIRILMAGAN»
/// ko‘rsatadi; hech narsa taxmin qilinmaydi.
@immutable
class SolutionRecipe {
  const SolutionRecipe({
    required this.id,
    required this.reagentId,
    required this.names,
    required this.domain,
    required this.status,
    this.purpose,
    this.associatedMethodIds = const [],
    this.ingredients = const [],
    this.finalVolume,
    this.steps = const [],
    this.orderExplicitInSource = false,
    this.storage,
    this.temperature,
    this.stability,
    this.hazards = const [],
    this.disposalReference,
    this.qcRequirement,
    this.sourceIds = const [],
    this.version = 1,
    this.isTestData = false,
  });

  final String id;
  final String reagentId;
  final Map<String, String> names;
  final ContentDomain domain;
  final ScientificStatus status;
  final String? purpose;
  final List<String> associatedMethodIds;
  final List<Ingredient> ingredients;
  final SourcedValue? finalVolume;
  final List<PreparationStep> steps;

  /// Manba qo‘shish tartibini aniq aytganmi.
  final bool orderExplicitInSource;
  final SourcedNote? storage;
  final SourcedValue? temperature;
  final SourcedNote? stability;
  final List<SourcedNote> hazards;
  final SourcedNote? disposalReference;
  final SourcedNote? qcRequirement;
  final List<String> sourceIds;
  final int version;
  final bool isTestData;

  bool get hasPreparationData =>
      ingredients.isNotEmpty ||
      steps.isNotEmpty ||
      finalVolume != null ||
      storage != null ||
      temperature != null ||
      stability != null;
}

// ---------------------------------------------------------------------------
// Screening & Express Tests
// ---------------------------------------------------------------------------

/// Skrining / ekspress test. **SKRINING NATIJASI ≠ TASDIQLANGAN
/// IDENTIFIKATSIYA** — tasdiqlovchi metod majburiy (FE021).
@immutable
class ScreeningTest {
  const ScreeningTest({
    required this.id,
    required this.names,
    required this.analyte,
    required this.specimen,
    required this.principle,
    required this.confirmatoryMethodIds,
    required this.limitations,
    required this.status,
    required this.sourceIds,
    this.manufacturer,
    this.model,
    this.cutoff,
    this.sensitivity,
    this.specificity,
    this.crossReactivity = const [],
    this.falsePositive = const [],
    this.falseNegative = const [],
    this.storage,
    this.supportsDefinitiveIdentification = false,
    this.definitiveIdentificationSourceId,
    this.version = 1,
    this.isTestData = false,
  });

  final String id;
  final Map<String, String> names;
  final String analyte;
  final String specimen;
  final String principle;
  final String? manufacturer;
  final String? model;
  final SourcedValue? cutoff;
  final SourcedValue? sensitivity;
  final SourcedValue? specificity;
  final List<SourcedNote> crossReactivity;
  final List<SourcedNote> falsePositive;
  final List<SourcedNote> falseNegative;
  final List<SourcedNote> limitations;
  final List<String> confirmatoryMethodIds;
  final SourcedNote? storage;

  /// Faqat avtoritet metod buni aniq qo‘llab-quvvatlasa (FE023).
  final bool supportsDefinitiveIdentification;
  final String? definitiveIdentificationSourceId;
  final ScientificStatus status;
  final List<String> sourceIds;
  final int version;
  final bool isTestData;
}

// ---------------------------------------------------------------------------
// Methods & SOP
// ---------------------------------------------------------------------------

/// Metod turlari — **aralashtirilmaydi** (FE024).
enum MethodKind {
  /// Ilmiy metod (adabiyot). Yurisdiksiyaga bog‘lanmaydi.
  scientificMethod,

  /// Xalqaro standart / qo‘llanma (tashkilot majburiy).
  internationalStandard,

  /// Milliy metod (davlat/hudud va tashkilot majburiy).
  nationalMethod,

  /// Institut SOP havolasi (tashkilot majburiy; global ko‘rsatilmaydi).
  institutionalSop,
}

enum MethodSection {
  purpose,
  scope,
  analytes,
  specimens,
  principle,
  equipment,
  reagents,
  samplePreparation,
  calibrationQc,
  workflow,
  interpretation,
  limitations,
  validationStatus,
}

/// Matn kelib chiqishi — mualliflik huquqi (FE025).
enum TextOrigin {
  /// Mustaqil yozilgan qisqa mazmun (har qanday litsenziyada mumkin).
  originalSummary,

  /// Ochiq litsenziyali manbadan iqtibos.
  openLicenseExcerpt,
}

@immutable
class MethodRecord {
  const MethodRecord({
    required this.id,
    required this.kind,
    required this.titles,
    required this.status,
    required this.sourceIds,
    this.techniques = const [],
    this.organization,
    this.jurisdictionId,
    this.documentVersion,
    this.effectiveFrom,
    this.supersededAt,
    this.sections = const {},
    this.textOrigin = TextOrigin.originalSummary,
    this.version = 1,
    this.isTestData = false,
  });

  final String id;
  final MethodKind kind;
  final Map<String, String> titles;
  final List<AnalyticalTechnique> techniques;
  final String? organization;
  final String? jurisdictionId;

  /// Hujjat versiyasi (masalan, standart nashri).
  final String? documentVersion;
  final DateTime? effectiveFrom;
  final DateTime? supersededAt;
  final Map<MethodSection, String> sections;
  final TextOrigin textOrigin;
  final ScientificStatus status;
  final List<String> sourceIds;

  /// Yozuv versiyasi (review qaysi versiyaga tegishli).
  final int version;
  final bool isTestData;
}

// ---------------------------------------------------------------------------
// Emerging issues
// ---------------------------------------------------------------------------

enum EmergingCategory {
  newPsychoactiveSubstances,
  syntheticOpioids,
  novelStimulants,
  analyticalChallenges,
  newInterferences,
  postmortemInterpretation,
  newBiomarkers,
  emergingMethods,
  newStandards,
  legalRegulatoryUpdates,
  methodValidation,
  laboratoryQuality,
  scientificAlert,
}

enum EvidenceType { officialAlert, peerReviewed, report, standard }

/// Sensatsion yangilik emas: har biri manba + sana + dalil turi + qamrov.
@immutable
class EmergingIssue {
  const EmergingIssue({
    required this.id,
    required this.category,
    required this.titles,
    required this.sourceIds,
    required this.evidenceType,
    required this.status,
    this.date,
    this.scopeJurisdictionId,
    this.isTestData = false,
    this.lastCheckedAt,
  });

  final String id;
  final EmergingCategory category;

  /// Oxirgi marta manba bilan solishtirilgan sana (yangilik lentasi emas).
  final DateTime? lastCheckedAt;
  final Map<String, String> titles;
  final List<String> sourceIds;
  final DateTime? date;
  final EvidenceType evidenceType;

  /// `null` — global; aks holda yurisdiksiya ID.
  final String? scopeJurisdictionId;
  final ScientificStatus status;
  final bool isTestData;
}

/// Mavzu yozuvi (sud tibbiyoti, biokimyo, glossariy). Mazmuni — claim’lar.
@immutable
class KnowledgeTopic {
  const KnowledgeTopic({
    required this.id,
    required this.area,
    required this.names,
    this.forensicMedicineTopic,
    this.isTestData = false,
  });

  final String id;
  final KnowledgeArea area;
  final Map<String, String> names;
  final ForensicMedicineTopic? forensicMedicineTopic;
  final bool isTestData;
}
