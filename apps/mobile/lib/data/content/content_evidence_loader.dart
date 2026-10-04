import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Variable;
import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_database/fe_database.dart' show ContentDatabase;

import '../../domain/evidence/evidence_models.dart';
import '../../domain/library/library_models.dart';
import 'content_provenance.dart';

/// `research_records`, `entity_links` va `images` (metadata) — `content.db`.
abstract final class ContentEvidenceLoader {
  static Future<EvidenceData> load(ContentDatabase db) async {
    final links = [
      for (final r in await db.customSelect('SELECT * FROM entity_links').get())
        GraphLink(
          fromId: r.read<String>('from_id'),
          toId: r.read<String>('to_id'),
          relation: LinkRelation.fromCode(r.read<String>('relation')),
          basis: r.read<String>('basis'),
        ),
    ];
    final linked = <String, List<String>>{};
    for (final l in links) {
      if (l.relation == LinkRelation.research) {
        linked.putIfAbsent(l.toId, () => []).add(l.fromId);
      }
    }
    final research = [
      for (final r
          in await db
              .customSelect(
                'SELECT * FROM research_records ORDER BY pub_year DESC, title',
              )
              .get())
        ResearchEntry(
          id: r.read<String>('research_id'),
          kind: ResearchKind.fromCode(r.read<String>('kind')),
          title: r.read<String>('title'),
          authors: (jsonDecode(r.read<String>('authors_json')) as List)
              .cast<String>(),
          organization: r.readNullable<String>('organization'),
          container: r.readNullable<String>('container'),
          year: r.readNullable<String>('pub_year'),
          doi: r.readNullable<String>('doi'),
          pmid: r.readNullable<String>('pmid'),
          pmcid: r.readNullable<String>('pmcid'),
          handle: r.readNullable<String>('handle'),
          url: r.readNullable<String>('url'),
          degree: r.readNullable<String>('degree'),
          sourceApi: r.readNullable<String>('source_api'),
          accessedDate: ContentProvenance.date(r.data['accessed_date']),
          evidenceLevel: r.read<String>('evidence_level'),
          peerReviewed: r.read<int>('peer_reviewed') == 1,
          status: ScientificStatus.fromCode(r.read<String>('review_status')),
          linkedEntityIds: linked[r.read<String>('research_id')] ?? const [],
          isTestData: r.read<int>('is_test_data') == 1,
          openAccess: r.readNullable<String>('open_access'),
          forensicRelevance: ForensicRelevance.fromCode(
            r.readNullable<String>('forensic_relevance'),
          ),
          language: r.readNullable<String>('language'),
        ),
    ];
    LocalizedText lt(String json) =>
        LocalizedText((jsonDecode(json) as Map).cast<String, String>());
    final images = [
      for (final r
          in await db
              .customSelect(
                'SELECT image_id, kind, entity_id, title_json, alt_json, '
                'license, attribution, is_original_diagram, '
                'represents_real_data, creator, source_name, source_url, doi, '
                'caption_original, accessed_date FROM images ORDER BY image_id',
              )
              .get())
        ImageMeta(
          id: r.read<String>('image_id'),
          kind: ImageKind.fromCode(r.read<String>('kind')),
          entityId: r.read<String>('entity_id'),
          title: lt(r.read<String>('title_json')),
          alt: lt(r.read<String>('alt_json')),
          license: r.read<String>('license'),
          attribution: r.read<String>('attribution'),
          isOriginalDiagram: r.read<int>('is_original_diagram') == 1,
          representsRealData: r.read<int>('represents_real_data') == 1,
          creator: r.readNullable<String>('creator'),
          sourceName: r.readNullable<String>('source_name'),
          sourceUrl: r.readNullable<String>('source_url'),
          doi: r.readNullable<String>('doi'),
          captionOriginal: r.readNullable<String>('caption_original'),
          accessedDate: ContentProvenance.date(r.data['accessed_date']),
        ),
    ];
    return EvidenceData(research: research, links: links, images: images);
  }
}

/// Rasm baytlari — bitta so‘rov, xotirada kesh.
class DbImageBytesLoader implements ImageBytesLoader {
  DbImageBytesLoader(this._db);

  final ContentDatabase _db;
  final _cache = <String, Uint8List?>{};

  @override
  Future<Uint8List?> load(String imageId) async {
    if (_cache.containsKey(imageId)) return _cache[imageId];
    final row = await _db
        .customSelect(
          'SELECT bytes FROM images WHERE image_id = ?',
          variables: [Variable.withString(imageId)],
        )
        .getSingleOrNull();
    return _cache[imageId] = row?.read<Uint8List>('bytes');
  }
}
