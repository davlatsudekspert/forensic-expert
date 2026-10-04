/// Kutubxona domen modeli (Library ekrani va substance kartochkasi).
library;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

enum LibrarySection { substances, methods, specimens, references, glossary }

/// Ko‘p tilli nom: `en`, `ru`, `uz`.
@immutable
class LocalizedText {
  const LocalizedText(this.values);

  final Map<String, String> values;

  String resolve(String languageCode) =>
      values[languageCode] ?? values['en'] ?? values.values.first;
}

@immutable
class LibraryEntry {
  const LibraryEntry({
    required this.id,
    required this.section,
    required this.name,
    required this.status,
    required this.isTestData,
    this.synonyms = const [],
    this.lastReviewed,
    this.access = EntryAccess.free,
    this.details,
  });

  final String id;
  final LibrarySection section;
  final LocalizedText name;
  final List<String> synonyms;
  final ScientificStatus status;

  /// TEST DATA — UI buni har doim aniq belgilaydi.
  final bool isTestData;
  final DateTime? lastReviewed;

  /// Bepul demo yoki Lifetime ([EntryAccess]).
  final EntryAccess access;

  /// Kontent paketidan kelgan to‘liq ma’lumot. TEST fixture’larda `null`.
  final EntryDetails? details;
}

/// Kutubxona yozuviga kirish darajasi (kontent paketidagi `tier_access`).
enum EntryAccess { free, lifetime }

/// Manba (provenance) — UI uchun.
@immutable
class SourceView {
  const SourceView({
    required this.sourceId,
    required this.title,
    required this.sourceType,
    required this.evidenceLevel,
    required this.licenseMode,
    required this.identifierVerified,
    this.organization,
    this.journal,
    this.year,
    this.edition,
    this.doi,
    this.pmid,
    this.url,
    this.accessedDate,
    this.locator,
  });

  final String sourceId;
  final String title;
  final String sourceType;
  final String evidenceLevel;
  final String licenseMode;
  final bool identifierVerified;
  final String? organization;
  final String? journal;
  final int? year;
  final String? edition;
  final String? doi;
  final String? pmid;
  final String? url;
  final DateTime? accessedDate;

  /// Manba ichidagi joy (bo‘lim, jadval).
  final String? locator;
}

/// Bitta ilmiy claim — qiymat, status, dalil darajasi, versiya, qatlam va
/// manbalar bilan.
@immutable
class ClaimView {
  const ClaimView({
    required this.claimId,
    required this.field,
    required this.value,
    required this.status,
    required this.evidenceLevel,
    required this.version,
    required this.layer,
    required this.sources,
    required this.reviewCount,
  });

  final String claimId;

  /// `identity`, `metabolites`, `biomarker`, `transformation_product`,
  /// `metabolism_note`.
  final String field;
  final Map<String, Object?> value;
  final ScientificStatus status;
  final String evidenceLevel;
  final int version;
  final KnowledgeLayer layer;
  final List<SourceView> sources;

  /// Shu claim versiyasiga berilgan review’lar soni.
  final int reviewCount;

  List<String> get items => [
    for (final i in (value['items'] as List? ?? const [])) '$i',
  ];

  String? get excerpt => value['excerpt'] as String?;
}

/// Yurisdiksiya qatlamidagi qoida (masalan, xalqaro nazorat jadvali).
@immutable
class LegalRuleView {
  const LegalRuleView({
    required this.ruleId,
    required this.jurisdictionId,
    required this.instrumentTitle,
    required this.instrumentVersion,
    required this.value,
    required this.status,
    required this.effectiveFrom,
    required this.source,
    this.officialReference,
    this.lastVerifiedAt,
    this.datePrecision,
  });

  final String ruleId;
  final String jurisdictionId;
  final String instrumentTitle;
  final String instrumentVersion;
  final String? officialReference;
  final Map<String, Object?> value;
  final ScientificStatus status;
  final DateTime effectiveFrom;
  final DateTime? lastVerifiedAt;

  /// `year` / `month` — sana aniqligi (manbada faqat yil berilgan bo‘lsa).
  final String? datePrecision;
  final SourceView source;

  List<String> get schedules => [
    for (final s in (value['schedules'] as List? ?? const [])) '$s',
  ];

  String? get convention => value['convention'] as String?;
}

/// Kontent paketidan kelgan to‘liq yozuv.
@immutable
class EntryDetails {
  const EntryDetails({
    required this.entityKind,
    required this.packVersion,
    required this.channel,
    required this.translationStatus,
    required this.claims,
    required this.legalRules,
  });

  final String entityKind;
  final String packVersion;

  /// `development` — reviewer tasdig‘idan o‘tmagan pilot paket.
  final String channel;
  final Map<String, String> translationStatus;
  final List<ClaimView> claims;
  final List<LegalRuleView> legalRules;

  ClaimView? claim(String field) {
    for (final c in claims) {
      if (c.field == field) return c;
    }
    return null;
  }

  /// Yozuvdagi barcha manbalar (takrorsiz).
  List<SourceView> get allSources {
    final seen = <String>{};
    return [
      for (final c in claims)
        for (final s in c.sources)
          if (seen.add(s.sourceId)) s,
      for (final r in legalRules)
        if (seen.add(r.source.sourceId)) r.source,
    ];
  }
}

/// Kutubxona manbasi: imzolangan kontent paketi (`ContentLibraryRepository`)
/// yoki testlarda TEST fixture’lar.
abstract interface class LibraryRepository {
  List<LibraryEntry> entries(LibrarySection section);

  LibraryEntry? byId(String id);
}

/// Yozuv statusi — eng zaif claim statusi (hech qachon ko‘tarilmaydi).
/// Claim bo‘lmasa — NEEDS_REVIEW.
ScientificStatus aggregateStatus(Iterable<ScientificStatus> statuses) {
  const order = [
    ScientificStatus.rejected,
    ScientificStatus.outdated,
    ScientificStatus.draft,
    ScientificStatus.needsReview,
    ScientificStatus.reviewed,
    ScientificStatus.verified,
  ];
  var weakest = ScientificStatus.verified;
  var any = false;
  for (final s in statuses) {
    any = true;
    if (order.indexOf(s) < order.indexOf(weakest)) weakest = s;
  }
  return any ? weakest : ScientificStatus.needsReview;
}
