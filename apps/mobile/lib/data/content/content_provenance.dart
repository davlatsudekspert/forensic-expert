import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_database/fe_database.dart';

import '../../domain/library/library_models.dart';

/// `content.db` dan manbalar va claim’larni (citation, review soni bilan)
/// o‘qiydi — kutubxona va bilim sohalari uchun umumiy.
class ContentProvenance {
  ContentProvenance._(this._sources, this.claimsByEntity);

  final Map<String, Map<String, Object?>> _sources;

  /// entity_id → claim’lar.
  final Map<String, List<ClaimView>> claimsByEntity;

  static Future<ContentProvenance> load(ContentDatabase db) async {
    final sources = <String, Map<String, Object?>>{
      for (final r in await db.customSelect('SELECT * FROM sources').get())
        r.read<String>('source_id'): r.data,
    };
    final p = ContentProvenance._(sources, {});

    final citations = <String, List<SourceView>>{};
    for (final r in await db.customSelect('SELECT * FROM citations').get()) {
      citations
          .putIfAbsent(r.read<String>('claim_id'), () => [])
          .add(
            p.source(
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

    for (final r
        in await db
            .customSelect('SELECT * FROM claims ORDER BY claim_id')
            .get()) {
      final id = r.read<String>('claim_id');
      final version = r.read<int>('version');
      p.claimsByEntity
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
    return p;
  }

  SourceView source(String id, String? locator) {
    final s = _sources[id]!;
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
      accessedDate: date(s['accessed_date']),
      locator: locator,
    );
  }

  static DateTime? date(Object? v) =>
      v == null ? null : DateTime.tryParse(v as String);
}
