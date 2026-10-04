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

/// Hujjat chiqargan vakolatli organ (parlament, vazirlik, BMT organi…).
@immutable
class Authority {
  const Authority({
    required this.id,
    required this.jurisdictionId,
    required this.names,
  });

  final String id;
  final String jurisdictionId;
  final Map<String, String> names;
}

/// Hujjatning huquqiy holati.
enum InstrumentLegalStatus { inForce, amended, superseded, repealed }

/// Ma’lumot turlari — hech biri boshqasidan **xulosa qilinmaydi**.
enum LegalLayerKind {
  internationalStandard,
  internationalControl,
  nationalLaw,
  regionalLaw,
  nationalMethod,
  institutionalProcedure,
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
    this.authorityId,
    this.publicationDate,
    this.lastAmendedAt,
    this.legalStatus = InstrumentLegalStatus.inForce,
    this.language,
    this.translationStatus,
  });

  final String id;
  final String jurisdictionId;
  final InstrumentType type;
  final String? authorityId;
  final DateTime? publicationDate;
  final DateTime? lastAmendedAt;
  final InstrumentLegalStatus legalStatus;

  /// Rasmiy matn tili (ISO 639-1).
  final String? language;
  final TranslationStatus? translationStatus;
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
      legalStatus != InstrumentLegalStatus.repealed &&
      legalStatus != InstrumentLegalStatus.superseded &&
      !date.isBefore(effectiveFrom) &&
      (effectiveTo == null || date.isBefore(effectiveTo!));
}

/// Hujjat qaysi qatlamga tegishli — yurisdiksiya darajasi va hujjat
/// turidan **aniq** aniqlanadi (taxmin yo‘q).
LegalLayerKind legalLayerOf(
  JurisdictionalInstrument instrument,
  JurisdictionLevel level,
) => switch ((level, instrument.type)) {
  (_, InstrumentType.nationalMethod) => LegalLayerKind.nationalMethod,
  (_, InstrumentType.officialGuideline)
      when level == JurisdictionLevel.international =>
    LegalLayerKind.internationalStandard,
  (_, InstrumentType.standard) when level == JurisdictionLevel.international =>
    LegalLayerKind.internationalStandard,
  (JurisdictionLevel.international || JurisdictionLevel.supranational, _) =>
    LegalLayerKind.internationalControl,
  (JurisdictionLevel.subdivision, _) => LegalLayerKind.regionalLaw,
  (JurisdictionLevel.country, _) => LegalLayerKind.nationalLaw,
};

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
    this.articleSection,
    this.version = 1,
    this.topicKey,
    this.appliesTo,
  });

  final String id;
  final String instrumentId;

  /// Bir xil mavzudagi qoidalar kaliti (masalan `drink_drive.prescribed_limit`).
  /// Zanjirda bir xil kalit bo‘lsa — **eng aniq** yurisdiksiya qoidasi
  /// amal qiladi (hudud > davlat > xalqaro).
  final String? topicKey;

  /// Hududiy qamrov: `null` — butun yurisdiksiya; aks holda faqat shu
  /// hududlar (masalan RTA 1988 s.11: `{GB-ENG, GB-WLS, GB-SCT}`).
  final Set<String>? appliesTo;

  /// Hujjat ichidagi aniq joy (masalan «s.11(2)», «2-modda»).
  final String? articleSection;

  /// Qoida yozuvi versiyasi (review shu versiyaga bog‘lanadi).
  final int version;
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
    this.overridden = const [],
  });

  final Jurisdiction jurisdiction;

  /// Tanlangan → ota yurisdiksiyalar (masalan `US-CA`, `US`, `INT`).
  final List<Jurisdiction> chain;

  /// Shu sanada kuchda bo‘lgan va publish qilish mumkin bo‘lgan qoidalar.
  final List<(JurisdictionalRule, JurisdictionalInstrument)> rules;

  /// Aniqroq yurisdiksiya qoidasi bilan almashtirilgan qoidalar (shaffoflik).
  final List<(JurisdictionalRule, JurisdictionalInstrument)> overridden;
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

  Iterable<JurisdictionalRule> get rules => _rules;

  Iterable<JurisdictionalInstrument> get instruments => _instruments.values;

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
    bool includeUnreviewed = false,
  }) {
    final chain = chainOf(jurisdictionId);
    if (chain.isEmpty) return null;
    final ids = {for (final j in chain) j.id};
    final depth = {for (var i = 0; i < chain.length; i++) chain[i].id: i};
    final result = <(JurisdictionalRule, JurisdictionalInstrument)>[];
    for (final r in _rules) {
      if (r.subjectType != subjectType || r.subjectId != subjectId) continue;
      if (!_shown(r.status, includeUnreviewed) || !r.isInForceAt(at)) {
        continue;
      }
      final inst = _instruments[r.instrumentId];
      if (inst == null || !ids.contains(inst.jurisdictionId)) continue;
      if (!_shown(inst.status, includeUnreviewed) || !inst.isInForceAt(at)) {
        continue;
      }
      // Hududiy qamrov: tanlangan hudud qoida qamrovida bo‘lmasa — o‘tadi.
      final applies = r.appliesTo;
      if (applies != null &&
          inst.jurisdictionId != chain.first.id &&
          !applies.contains(chain.first.id)) {
        continue;
      }
      result.add((r, inst));
    }
    // Bir xil topicKey: eng aniq yurisdiksiya ustun; qolganlari overridden.
    final best = <String, int>{};
    for (final (r, i) in result) {
      final k = r.topicKey;
      if (k == null) continue;
      final d = depth[i.jurisdictionId]!;
      if (!best.containsKey(k) || d < best[k]!) best[k] = d;
    }
    final kept = <(JurisdictionalRule, JurisdictionalInstrument)>[];
    final overridden = <(JurisdictionalRule, JurisdictionalInstrument)>[];
    for (final e in result) {
      final k = e.$1.topicKey;
      if (k != null && depth[e.$2.jurisdictionId]! > best[k]!) {
        overridden.add(e);
      } else {
        kept.add(e);
      }
    }
    return JurisdictionView(
      jurisdiction: chain.first,
      chain: chain,
      rules: kept,
      overridden: overridden,
    );
  }

  /// Development kanalida tekshirilmagan qoidalar UI’da belgisi bilan
  /// ko‘rsatilishi mumkin; production’da faqat publishable.
  static bool _shown(ScientificStatus s, bool includeUnreviewed) =>
      s.isPublishable ||
      (includeUnreviewed &&
          (s == ScientificStatus.needsReview || s == ScientificStatus.draft));

  /// «Compare jurisdictions»: har bir yurisdiksiya uchun **faqat o‘z
  /// zanjiridagi manbali qoidalar**. Qoida yo‘q bo‘lsa — [ComparisonCell.noData]
  /// (hech qachon «ruxsat / taqiqlangan / nazoratda emas» deb xulosa
  /// qilinmaydi).
  List<ComparisonCell> compareCells({
    required List<String> jurisdictionIds,
    required String subjectType,
    required String subjectId,
    required DateTime at,
    bool includeUnreviewed = false,
  }) => [
    for (final id in jurisdictionIds)
      if (_jurisdictions[id] case final j?)
        () {
          final v = view(
            jurisdictionId: id,
            subjectType: subjectType,
            subjectId: subjectId,
            at: at,
            includeUnreviewed: includeUnreviewed,
          )!;
          return v.rules.isEmpty
              ? ComparisonCell.noData(j)
              : ComparisonCell(j, v.rules);
        }(),
  ];

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

/// Solishtirish katakchasi.
@immutable
class ComparisonCell {
  const ComparisonCell(this.jurisdiction, this.rules);

  /// Ma’lumot yo‘q — xulosa ham yo‘q.
  const ComparisonCell.noData(this.jurisdiction) : rules = const [];

  final Jurisdiction jurisdiction;
  final List<(JurisdictionalRule, JurisdictionalInstrument)> rules;

  bool get hasData => rules.isNotEmpty;
}
