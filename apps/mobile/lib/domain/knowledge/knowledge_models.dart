/// Global bilim sohalari (PHASE 4): sud tibbiyoti va biokimyo mavzulari,
/// reagentlar, skrining testlari, metodlar, yangi muammolar.
///
/// Mazmun **faqat** imzolangan kontent paketidan (yoki testlarda TEST
/// fixture’lardan) keladi. Bu qatlamda hech qanday ilmiy qiymat yo‘q.
library;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

import '../library/library_models.dart';

enum KnowledgeKind { topic, reagent, screeningTest, method, emergingIssue }

/// Paywall’ga hech qachon tushmaydigan claim maydonlari: cheklovlar,
/// cross-reactivity, «presumptive» tabiati (xavfsizlik ma’lumoti).
const safetyClaimFields = {
  'limitation',
  'test_class_limitation',
  'cross_reactivity',
  'presumptive_nature',
  'confirmation_requirement',
};

@immutable
class KnowledgeEntry {
  const KnowledgeEntry({
    required this.id,
    required this.kind,
    required this.area,
    required this.name,
    required this.status,
    required this.access,
    required this.isTestData,
    required this.claims,
    required this.sources,
    this.version = 1,
    this.packVersion,
    this.forensicMedicineTopic,
    this.discipline,
    this.recipe,
    this.screening,
    this.method,
    this.emerging,
  });

  final String id;
  final KnowledgeKind kind;
  final KnowledgeArea area;
  final LocalizedText name;

  /// Yozuvning o‘z statusi (mavzu uchun — eng zaif claim statusi).
  final ScientificStatus status;
  final EntryAccess access;
  final bool isTestData;
  final int version;
  final String? packVersion;

  /// Manbali claim’lar (ta’rif, marker, cheklov…).
  final List<ClaimView> claims;

  /// Yozuvning o‘ziga bog‘langan manbalar (paywall ortida emas).
  final List<SourceView> sources;

  final ForensicMedicineTopic? forensicMedicineTopic;

  /// PHASE 8: aniq fan (berilmasa — maydon / FM mavzusidan).
  final ForensicDiscipline? discipline;

  ForensicDiscipline get effectiveDiscipline =>
      discipline ??
      (forensicMedicineTopic != null
          ? disciplineOfFmTopic(forensicMedicineTopic!)
          : disciplineOfArea(area));
  final SolutionRecipe? recipe;
  final ScreeningTest? screening;
  final MethodRecord? method;
  final EmergingIssue? emerging;

  /// Yozuv shu tilda ko‘rinadimi.
  ///
  /// Milliy yo‘riqnomadan olingan mavzular faqat o‘zbek tilida yoziladi
  /// (`value.locale_only`, egasining qarori — `docs/DECISIONS.md`, 2026-10-10).
  /// Boshqa tilda ko‘rsatiladigan hech narsasi qolmasa, yozuv ro‘yxatda ham,
  /// qidiruvda ham, kursda ham chiqmaydi — bo‘sh sahifa ochilmasligi uchun.
  /// Claim’i yo‘q yozuv (reagent, metod) bu qoidaga tushmaydi.
  bool visibleIn(String languageCode) =>
      claims.isEmpty || claims.any((c) => c.visibleIn(languageCode));

  /// Barcha manbalar (yozuv + claim’lar), takrorsiz.
  List<SourceView> get allSources {
    final seen = <String>{};
    return [
      for (final s in sources)
        if (seen.add(s.sourceId)) s,
      for (final c in claims)
        for (final s in c.sources)
          if (seen.add(s.sourceId)) s,
    ];
  }

  /// Manba ID → ko‘rinish (SourcedValue/SourcedNote havolalari uchun).
  SourceView? sourceById(String id) {
    for (final s in allSources) {
      if (s.sourceId == id) return s;
    }
    return null;
  }
}

abstract interface class KnowledgeRepository {
  List<KnowledgeEntry> byKind(KnowledgeKind kind);

  List<KnowledgeEntry> topicsIn(KnowledgeArea area);

  KnowledgeEntry? byId(String id);
}

class EmptyKnowledgeRepository implements KnowledgeRepository {
  const EmptyKnowledgeRepository();

  @override
  List<KnowledgeEntry> byKind(KnowledgeKind kind) => const [];

  @override
  List<KnowledgeEntry> topicsIn(KnowledgeArea area) => const [];

  @override
  KnowledgeEntry? byId(String id) => null;
}

/// Ro‘yxatdan tayyor repository (kontent paketi va fixture’lar uchun).
class ListKnowledgeRepository implements KnowledgeRepository {
  const ListKnowledgeRepository(this.entries);

  final List<KnowledgeEntry> entries;

  @override
  List<KnowledgeEntry> byKind(KnowledgeKind kind) => [
    for (final e in entries)
      if (e.kind == kind) e,
  ];

  @override
  List<KnowledgeEntry> topicsIn(KnowledgeArea area) => [
    for (final e in entries)
      if (e.kind == KnowledgeKind.topic && e.area == area) e,
  ];

  @override
  KnowledgeEntry? byId(String id) {
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }
}

/// Interfeys tiliga ko‘ra filtrlangan repository: faqat bitta tilda mavjud
/// yozuvlar boshqa tilda umuman ko‘rinmaydi (ro‘yxat, qidiruv, kurslar).
class LocaleFilteredKnowledgeRepository implements KnowledgeRepository {
  const LocaleFilteredKnowledgeRepository(this.inner, this.languageCode);

  final KnowledgeRepository inner;
  final String languageCode;

  @override
  List<KnowledgeEntry> byKind(KnowledgeKind kind) => [
    for (final e in inner.byKind(kind))
      if (e.visibleIn(languageCode)) e,
  ];

  @override
  List<KnowledgeEntry> topicsIn(KnowledgeArea area) => [
    for (final e in inner.topicsIn(area))
      if (e.visibleIn(languageCode)) e,
  ];

  /// To‘g‘ridan-to‘g‘ri havola (deep link) bilan kelgan yozuv ham yashiriladi:
  /// aks holda ru/en interfeysda mazmunsiz sahifa ochilardi.
  @override
  KnowledgeEntry? byId(String id) {
    final e = inner.byId(id);
    return e != null && e.visibleIn(languageCode) ? e : null;
  }
}

/// Kontent paketidagi yurisdiksiya ma’lumoti (organlar, hujjat manbalari).
@immutable
class LegalCatalog {
  const LegalCatalog({
    this.authorities = const {},
    this.instrumentSources = const {},
    this.componentVersions = const {},
    this.instrumentDatePrecision = const {},
  });

  static const empty = LegalCatalog();

  /// authority_id → nomlar.
  final Map<String, LocalizedText> authorities;

  /// instrument_id → rasmiy manba.
  final Map<String, SourceView> instrumentSources;

  /// `scientific`, `jurisdiction` … (ilova versiyasidan alohida).
  final Map<String, String> componentVersions;

  /// instrument_id → `year` / `month` / `day` (manba aniqligi).
  final Map<String, String> instrumentDatePrecision;
}
