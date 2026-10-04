import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_database/fe_database.dart';

import '../../domain/library/library_models.dart';
import 'content_provenance.dart';

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

    final prov = await ContentProvenance.load(db);
    final source = prov.source;
    final claimsByEntity = prov.claimsByEntity;

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
          status: aggregateStatus([for (final c in claims) c.status]),
          isTestData: r.read<int>('is_test_data') == 1,
          lastReviewed: _date(r.data['last_reviewed_at']),
          access: r.read<String>('tier_access') == 'free'
              ? EntryAccess.free
              : EntryAccess.lifetime,
          group: r.readNullable<String>('substance_group'),
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
