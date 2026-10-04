import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_database/fe_database.dart';

import '../../domain/library/library_models.dart';

/// Kutubxona — imzolangan kontent paketidagi `content.db` dan.
///
/// Pilot hajmi kichik (≈20 yozuv), shuning uchun ochilganda bir marta
/// xotiraga yuklanadi; qidiruv indeksi ham shu ma’lumotdan quriladi.
class ContentLibraryRepository implements LibraryRepository {
  ContentLibraryRepository._(this._entries);

  final List<LibraryEntry> _entries;

  static Future<ContentLibraryRepository> load(ContentDatabase db) async {
    final packVersion = await db.metaValue('pack_version') ?? '—';
    final channel = await db.metaValue('channel') ?? 'unknown';

    final sources = <String, Map<String, Object?>>{
      for (final r in await db.customSelect('SELECT * FROM sources').get())
        r.read<String>('source_id'): r.data,
    };
    SourceView source(String id, String? locator) {
      final s = sources[id]!;
      return SourceView(
        sourceId: id,
        title: s['title']! as String,
        sourceType: s['source_type']! as String,
        evidenceLevel: s['evidence_level']! as String,
        licenseMode: s['license_mode']! as String,
        identifierVerified: s['identifier_verified'] == 1,
        organization: s['organization'] as String?,
        journal: s['journal'] as String?,
        year: s['publication_year'] as int?,
        edition: s['edition'] as String?,
        doi: s['doi'] as String?,
        pmid: s['pmid'] as String?,
        url: s['official_url'] as String?,
        accessedDate: _date(s['accessed_date']),
        locator: locator,
      );
    }

    final citations = <String, List<SourceView>>{};
    for (final r in await db.customSelect('SELECT * FROM citations').get()) {
      citations
          .putIfAbsent(r.read<String>('claim_id'), () => [])
          .add(
            source(
              r.read<String>('source_id'),
              r.readNullable<String>('locator'),
            ),
          );
    }

    final reviewCounts = <String, int>{
      for (final r
          in await db
              .customSelect(
                'SELECT target_id, target_version, COUNT(*) AS n FROM reviews '
                "WHERE target_type = 'claim' GROUP BY target_id, target_version",
              )
              .get())
        '${r.read<String>('target_id')}#${r.read<int>('target_version')}': r
            .read<int>('n'),
    };

    final claimsByEntity = <String, List<ClaimView>>{};
    for (final r
        in await db
            .customSelect('SELECT * FROM claims ORDER BY claim_id')
            .get()) {
      final id = r.read<String>('claim_id');
      final version = r.read<int>('version');
      claimsByEntity
          .putIfAbsent(r.read<String>('entity_id'), () => [])
          .add(
            ClaimView(
              claimId: id,
              field: r.read<String>('field'),
              value: (jsonDecode(r.read<String>('value_json')) as Map)
                  .cast<String, Object?>(),
              status: ScientificStatus.fromCode(
                r.read<String>('review_status'),
              ),
              evidenceLevel: r.read<String>('evidence_level'),
              version: version,
              layer: KnowledgeLayer.values.firstWhere(
                (l) => l.code == r.read<String>('knowledge_layer'),
              ),
              sources: citations[id] ?? const [],
              reviewCount: reviewCounts['$id#$version'] ?? 0,
            ),
          );
    }

    final rulesBySubject = <String, List<LegalRuleView>>{};
    for (final r
        in await db
            .customSelect(
              'SELECT r.*, i.jurisdiction_id, i.titles_json, i.version AS iv, '
              'i.official_reference, i.official_source_id, i.last_verified_at '
              'FROM jurisdictional_rules r JOIN jurisdictional_instruments i '
              'ON i.instrument_id = r.instrument_id',
            )
            .get()) {
      final titles = (jsonDecode(r.read<String>('titles_json')) as Map)
          .cast<String, Object?>();
      rulesBySubject
          .putIfAbsent(r.read<String>('subject_id'), () => [])
          .add(
            LegalRuleView(
              ruleId: r.read<String>('rule_id'),
              jurisdictionId: r.read<String>('jurisdiction_id'),
              instrumentTitle: (titles['en'] ?? '') as String,
              instrumentVersion: r.read<String>('iv'),
              officialReference: r.readNullable<String>('official_reference'),
              value: (jsonDecode(r.read<String>('value_json')) as Map)
                  .cast<String, Object?>(),
              status: ScientificStatus.fromCode(
                r.read<String>('review_status'),
              ),
              effectiveFrom: DateTime.parse(r.read<String>('effective_from')),
              lastVerifiedAt: _date(r.data['last_verified_at']),
              datePrecision: titles['_date_precision'] as String?,
              source: source(r.read<String>('official_source_id'), null),
            ),
          );
    }

    final i18n = <String, Map<String, (String, String)>>{};
    for (final r
        in await db.customSelect('SELECT * FROM substance_i18n').get()) {
      i18n.putIfAbsent(r.read<String>('substance_id'), () => {})[r.read<String>(
        'lang',
      )] = (
        r.read<String>('name'),
        r.read<String>('translation_status'),
      );
    }

    final synonyms = <String, List<String>>{};
    for (final r
        in await db
            .customSelect(
              "SELECT entity_id, term FROM search_terms WHERE term_kind = 'synonym' "
              'AND weight >= 1.0 ORDER BY term_id',
            )
            .get()) {
      synonyms
          .putIfAbsent(r.read<String>('entity_id'), () => [])
          .add(r.read<String>('term'));
    }

    final entries = <LibraryEntry>[];
    for (final r
        in await db
            .customSelect('SELECT * FROM substances ORDER BY canonical_name')
            .get()) {
      final id = r.read<String>('substance_id');
      final names = i18n[id] ?? const {};
      final claims = claimsByEntity[id] ?? const <ClaimView>[];
      entries.add(
        LibraryEntry(
          id: id,
          section: LibrarySection.substances,
          name: LocalizedText({
            for (final e in names.entries) e.key: e.value.$1,
          }),
          synonyms: synonyms[id] ?? const [],
          status: _aggregate(claims),
          isTestData: r.read<int>('is_test_data') == 1,
          lastReviewed: _date(r.data['last_reviewed_at']),
          access: r.read<String>('tier_access') == 'free'
              ? EntryAccess.free
              : EntryAccess.lifetime,
          details: EntryDetails(
            entityKind: r.read<String>('entity_kind'),
            packVersion: packVersion,
            channel: channel,
            translationStatus: {
              for (final e in names.entries) e.key: e.value.$2,
            },
            claims: claims,
            legalRules: rulesBySubject[id] ?? const [],
          ),
        ),
      );
    }
    return ContentLibraryRepository._(entries);
  }

  /// Yozuv statusi — eng zaif claim statusi (hech qachon ko‘tarilmaydi).
  static ScientificStatus _aggregate(List<ClaimView> claims) {
    if (claims.isEmpty) return ScientificStatus.needsReview;
    const order = [
      ScientificStatus.rejected,
      ScientificStatus.outdated,
      ScientificStatus.needsReview,
      ScientificStatus.reviewed,
      ScientificStatus.verified,
    ];
    return claims
        .map((c) => c.status)
        .reduce((a, b) => order.indexOf(a) <= order.indexOf(b) ? a : b);
  }

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.tryParse(v as String);

  @override
  List<LibraryEntry> entries(LibrarySection section) => [
    for (final e in _entries)
      if (e.section == section) e,
  ];

  @override
  LibraryEntry? byId(String id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }
}
