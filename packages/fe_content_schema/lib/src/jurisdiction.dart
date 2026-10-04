import 'package:meta/meta.dart';

import 'enums.dart';

/// Bilim qatlami — **Global Scientific Core + Jurisdiction Layer** tamoyili.
///
/// * [internationalScientific] — xalqaro ilmiy dalillar (farmakologiya,
///   metabolizm, analitik kimyo). Davlatga bog‘liq EMAS.
/// * [internationalStandard] — xalqaro standartlar va konvensiyalar
///   (masalan, BMT konvensiyalari, ISO/ASB kabi standartlar).
/// * [jurisdictional] — muayyan davlat/hudud qonuni, regulation’i,
///   milliy metodi yoki protsedurasi.
///
/// Qatlamlar bir-biriga aralashtirilmaydi: ilmiy claim yurisdiksiyaga
/// bog‘lanmaydi, yurisdiksion claim esa albatta yurisdiksiya va rasmiy
/// hujjatga bog‘lanadi (validator FE012–FE016).
enum KnowledgeLayer {
  internationalScientific('international_scientific'),
  internationalStandard('international_standard'),
  jurisdictional('jurisdictional');

  const KnowledgeLayer(this.code);

  final String code;
}

/// Yurisdiksiya darajasi.
enum JurisdictionLevel {
  /// Xalqaro (BMT va h.k.) — hech qaysi davlatga tegishli emas.
  international,

  /// Davlatlararo birlashma (masalan, Yevropa Ittifoqi).
  supranational,

  /// Davlat (ISO 3166-1).
  country,

  /// Hudud / shtat / viloyat (ISO 3166-2).
  subdivision,
}

/// Yurisdiksiya. ID’lar barqaror: `INT`, `EU`, `UZ`, `US`, `US-CA`.
@immutable
class Jurisdiction {
  const Jurisdiction({
    required this.id,
    required this.level,
    required this.names,
    this.parentId,
    this.iso3166,
  });

  final String id;
  final JurisdictionLevel level;

  /// `en` / `ru` / `uz` va boshqa tillardagi nom (ma’lumot, UI matni emas).
  final Map<String, String> names;

  /// Yuqori yurisdiksiya: `US-CA` → `US`; davlat → `INT` yoki `EU`.
  final String? parentId;

  /// ISO 3166-1 alpha-2 yoki ISO 3166-2 kodi.
  final String? iso3166;

  String name(String lang) => names[lang] ?? names['en'] ?? id;
}

/// Rasmiy hujjat turi.
enum InstrumentType {
  law,
  regulation,
  controlledSubstanceSchedule,
  standard,
  nationalMethod,
  officialGuideline,
  internationalConvention,
}

/// Yurisdiksiyaga tegishli rasmiy hujjat (qonun, regulation, standart,
/// milliy metod). Har biri rasmiy manba, kuchga kirish sanasi, versiya va
/// oxirgi tekshiruv sanasiga ega.
@immutable
class JurisdictionalInstrument {
  const JurisdictionalInstrument({
    required this.id,
    required this.jurisdictionId,
    required this.type,
    required this.titles,
    required this.officialSourceId,
    required this.effectiveFrom,
    required this.version,
    required this.status,
    this.officialReference,
    this.effectiveTo,
    this.lastVerifiedAt,
    this.isTestData = false,
  });

  final String id;
  final String jurisdictionId;
  final InstrumentType type;
  final Map<String, String> titles;

  /// `Source.sourceId` — rasmiy huquqiy bazadagi manba (masalan lex.uz).
  final String officialSourceId;

  /// Rasmiy raqam (masalan, «ZRU-1152», «21 CFR 1308»).
  final String? officialReference;
  final DateTime effectiveFrom;

  /// `null` — hozir ham kuchda.
  final DateTime? effectiveTo;

  /// Tahrir/versiya identifikatori (rasmiy bazadagi tahrir sanasi va h.k.).
  final String version;
  final DateTime? lastVerifiedAt;
  final ScientificStatus status;
  final bool isTestData;

  bool isInForceAt(DateTime date) =>
      !date.isBefore(effectiveFrom) &&
      (effectiveTo == null || date.isBefore(effectiveTo!));
}

/// Yurisdiksion qoida turi.
enum JurisdictionalRuleType {
  /// Moddaning nazorat maqomi (ro‘yxat/jadval).
  controlStatus,

  /// Majburiy protsedura yoki namuna olish talabi.
  procedureRequirement,

  /// Milliy metod yoki chegara qiymati (huquqiy, ilmiy emas).
  legalThreshold,
}

/// Hujjatdan kelib chiqadigan aniq qoida (masalan: «X modda — II ro‘yxat»).
@immutable
class JurisdictionalRule {
  const JurisdictionalRule({
    required this.id,
    required this.instrumentId,
    required this.ruleType,
    required this.subjectType,
    required this.subjectId,
    required this.value,
    required this.effectiveFrom,
    required this.status,
    this.effectiveTo,
    this.isTestData = false,
  });

  final String id;
  final String instrumentId;
  final JurisdictionalRuleType ruleType;

  /// Masalan `substance`.
  final String subjectType;
  final String subjectId;
  final Map<String, Object?> value;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final ScientificStatus status;
  final bool isTestData;

  bool isInForceAt(DateTime date) =>
      !date.isBefore(effectiveFrom) &&
      (effectiveTo == null || date.isBefore(effectiveTo!));
}

/// Bitta yurisdiksiya uchun natija (Compare jurisdictions qatori).
@immutable
class JurisdictionView {
  const JurisdictionView({
    required this.jurisdiction,
    required this.chain,
    required this.rules,
  });

  final Jurisdiction jurisdiction;

  /// Tanlangan → ota yurisdiksiyalar (masalan `US-CA`, `US`, `INT`).
  final List<Jurisdiction> chain;

  /// Shu sanada kuchda bo‘lgan va publish qilish mumkin bo‘lgan qoidalar.
  final List<(JurisdictionalRule, JurisdictionalInstrument)> rules;
}

/// Yurisdiksiya qatlamini hal qiluvchi.
///
/// * Ota yurisdiksiyalar zanjiri bo‘yicha (hudud → davlat → xalqaro)
///   qoidalarni yig‘adi.
/// * Faqat [ScientificStatus.isPublishable] statusdagi va shu sanada
///   kuchda bo‘lgan qoidalar qaytariladi.
/// * [compare] — kelajakdagi «Compare jurisdictions» funksiyasi uchun.
class JurisdictionResolver {
  JurisdictionResolver({
    required Iterable<Jurisdiction> jurisdictions,
    required Iterable<JurisdictionalInstrument> instruments,
    required Iterable<JurisdictionalRule> rules,
  }) : _jurisdictions = {for (final j in jurisdictions) j.id: j},
       _instruments = {for (final i in instruments) i.id: i},
       _rules = List.unmodifiable(rules);

  final Map<String, Jurisdiction> _jurisdictions;
  final Map<String, JurisdictionalInstrument> _instruments;
  final List<JurisdictionalRule> _rules;

  /// Barcha ma’lum yurisdiksiyalar (tanlash ro‘yxati uchun).
  Iterable<Jurisdiction> get jurisdictions => _jurisdictions.values;

  Jurisdiction? byId(String id) => _jurisdictions[id];

  /// `US-CA` → [`US-CA`, `US`, `INT`]. Aylanma bog‘lanishdan himoyalangan.
  List<Jurisdiction> chainOf(String jurisdictionId) {
    final chain = <Jurisdiction>[];
    final seen = <String>{};
    String? id = jurisdictionId;
    while (id != null && seen.add(id)) {
      final j = _jurisdictions[id];
      if (j == null) break;
      chain.add(j);
      id = j.parentId;
    }
    return chain;
  }

  JurisdictionView? view({
    required String jurisdictionId,
    required String subjectType,
    required String subjectId,
    required DateTime at,
  }) {
    final chain = chainOf(jurisdictionId);
    if (chain.isEmpty) return null;
    final ids = {for (final j in chain) j.id};
    final result = <(JurisdictionalRule, JurisdictionalInstrument)>[];
    for (final r in _rules) {
      if (r.subjectType != subjectType || r.subjectId != subjectId) continue;
      if (!r.status.isPublishable || !r.isInForceAt(at)) continue;
      final inst = _instruments[r.instrumentId];
      if (inst == null || !ids.contains(inst.jurisdictionId)) continue;
      if (!inst.status.isPublishable || !inst.isInForceAt(at)) continue;
      result.add((r, inst));
    }
    return JurisdictionView(
      jurisdiction: chain.first,
      chain: chain,
      rules: result,
    );
  }

  /// Bir nechta yurisdiksiyani yonma-yon solishtirish (kelajak funksiyasi).
  List<JurisdictionView> compare({
    required List<String> jurisdictionIds,
    required String subjectType,
    required String subjectId,
    required DateTime at,
  }) => [
    for (final id in jurisdictionIds)
      ?view(
        jurisdictionId: id,
        subjectType: subjectType,
        subjectId: subjectId,
        at: at,
      ),
  ];
}
