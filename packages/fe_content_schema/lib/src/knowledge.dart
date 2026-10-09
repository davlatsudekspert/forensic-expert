import 'package:meta/meta.dart';

import 'enums.dart';
import 'taxonomy.dart';

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
  const SourcedNote({
    required this.text,
    required this.sourceId,
    this.locator,
    this.texts = const {},
    this.kind,
  });

  final String text;
  final String sourceId;
  final String? locator;

  /// Tilga moslangan matn (uz/ru/en). Bo‘sh bo‘lsa — [text] (asl til).
  /// Tarjimalar retseptning `translation_status` iga bo‘ysunadi.
  final Map<String, String> texts;

  /// Izoh turi (ixtiyoriy): `ghs` — PubChem GHS bayonoti, `general` —
  /// ilovaning umumiy ehtiyot tavsiyasi (manbadagi xavf asosida),
  /// `purpose`, `ambiguity` — manbadagi noaniqlik/OCR xatosi, `info`.
  final String? kind;

  /// [lang] uchun matn; topilmasa `en`, so‘ng [text].
  String resolve(String lang) => texts[lang] ?? texts['en'] ?? text;
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
    this.grade,
    this.names = const {},
    this.amountMax,
    this.makeUpTo = false,
    this.quantityNote = const {},
    this.variant,
  });

  final String name;

  /// Manbadagi miqdor. Manba raqam bermagan bo‘lsa (`небольшое
  /// количество`, `до растворения`) — `null` va [quantityNote] majburiy
  /// (validator FE022). Raqam hech qachon taxmin qilinmaydi.
  final num? amount;
  final String? unit;
  final String? role;

  /// Tozalik / sinf (masalan «analytical grade») — faqat manbada bo‘lsa.
  final String? grade;

  /// Ko‘rsatiladigan nom (uz/ru/en), konsentratsiya bilan.
  final Map<String, String> names;

  /// Oraliq yuqori chegarasi (`10—15 мл` → amount 10, amountMax 15).
  final num? amountMax;

  /// «… gacha suyultiriladi» (`до 100 мл`) — [amount] yakuniy hajm.
  final bool makeUpTo;

  /// Raqamsiz miqdor izohi (uz/ru/en).
  final Map<String, String> quantityNote;

  /// Retsept varianti (`a`, `b`…) — [SolutionRecipe.variants] dan.
  final String? variant;

  String displayName(String lang) => names[lang] ?? names['en'] ?? name;
}

@immutable
class PreparationStep {
  const PreparationStep({
    required this.text,
    this.order,
    this.texts = const {},
    this.variant,
  });

  final String text;

  /// Tartib raqami — faqat manba tartibni **aniq** aytgan bo‘lsa.
  final int? order;

  /// Tilga moslangan matn (uz/ru/en).
  final Map<String, String> texts;

  /// Retsept varianti (`a`, `b`…).
  final String? variant;

  String resolve(String lang) => texts[lang] ?? texts['en'] ?? text;
}

/// Bir reaktivning muqobil tayyorlash usuli (manbada «а)», «б)» yoki
/// boshqa manbadagi retsept).
@immutable
class RecipeVariant {
  const RecipeVariant({
    required this.id,
    this.labels = const {},
    this.sourceId,
  });

  final String id;
  final Map<String, String> labels;

  /// Variant manbasi (retsept `source_ids` ichida bo‘lishi shart).
  final String? sourceId;
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
    this.concentration,
    this.solvent,
    this.ph,
    this.expiry,
    this.ppe = const [],
    this.calculatorIds = const [],
    this.synonyms = const [],
    this.variants = const [],
    this.notes = const [],
    this.originalText,
    this.originalLanguage,
    this.originalSourceId,
    this.translationStatus,
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

  // PHASE 8: to‘liq professional shablon. Har biri manbali yoki yo‘q.
  final SourcedValue? concentration;
  final SourcedNote? solvent;
  final SourcedValue? ph;
  final SourcedNote? expiry;
  final List<SourcedNote> ppe;

  /// Deterministik kalkulyatorlar (molarlik, foizli eritma) — tahririy
  /// bog‘lanish; ilmiy qiymat emas, hisob foydalanuvchi kiritganidan.
  final List<String> calculatorIds;

  /// Qidiruv sinonimlari (boshqa yozilishlar: «Dragendorf», «Марки»…).
  final List<String> synonyms;

  /// Muqobil tayyorlash usullari; ingredient/qadam `variant` i shu ID’lar.
  final List<RecipeVariant> variants;

  /// Manbadagi maqsad, noaniqlik (OCR) va boshqa izohlar ([SourcedNote.kind]).
  final List<SourcedNote> notes;

  /// Kuzatuvchanlik uchun asl matn (masalan, rus tilidagi manba bandi).
  /// Faqat qayta foydalanishga ruxsat bergan manbadan (FE025).
  final String? originalText;
  final String? originalLanguage;
  final String? originalSourceId;

  /// Tuzilgan matnlar (nom, qadam, izoh) tarjimasi holati —
  /// hozircha faqat `machine_draft` (FE043).
  final String? translationStatus;

  bool get hasPreparationData =>
      ingredients.isNotEmpty ||
      steps.isNotEmpty ||
      finalVolume != null ||
      storage != null ||
      temperature != null ||
      stability != null ||
      concentration != null ||
      solvent != null ||
      ph != null ||
      expiry != null;
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
    this.resultType,
    this.interferences = const [],
    this.detectionWindow,
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

  // PHASE 8.
  /// Sifat / yarim miqdoriy — manba aytgan bo‘lsa.
  final SourcedNote? resultType;
  final List<SourcedNote> interferences;

  /// Aniqlash oynasi — doim kontekst bilan (namuna, doza, populyatsiya);
  /// universal muddat sifatida ko‘rsatilmaydi.
  final SourcedNote? detectionWindow;
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

/// PHASE 8: metod yozuvi qanday hujjat ekani (UI va validator uchun).
enum MethodEvidenceType {
  internationalStandard,
  guideline,

  /// Nashr etilgan, validatsiya ma’lumoti keltirilgan metod — baribir har
  /// laboratoriya uchun validatsiya qilingan degani emas.
  publishedValidatedMethod,
  nationalMethod,
  localSopReference,

  /// Adabiyotdan ta’limiy umumlashma (protokol emas).
  educationalSummary,
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
    this.evidenceType,
  });

  final String id;
  final MethodKind kind;

  /// Aniq berilmasa — [kind] dan konservativ xulosa.
  final MethodEvidenceType? evidenceType;

  MethodEvidenceType get effectiveEvidenceType =>
      evidenceType ??
      switch (kind) {
        MethodKind.internationalStandard =>
          MethodEvidenceType.internationalStandard,
        MethodKind.nationalMethod => MethodEvidenceType.nationalMethod,
        MethodKind.institutionalSop => MethodEvidenceType.localSopReference,
        MethodKind.scientificMethod => MethodEvidenceType.educationalSummary,
      };
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
    this.discipline,
  });

  final String id;
  final KnowledgeArea area;
  final Map<String, String> names;
  final ForensicMedicineTopic? forensicMedicineTopic;
  final bool isTestData;

  /// PHASE 8: aniq fan (genetika, entomologiya, mikrobiologiya…). Berilmasa
  /// — maydon / FM mavzusidan.
  final ForensicDiscipline? discipline;
}
