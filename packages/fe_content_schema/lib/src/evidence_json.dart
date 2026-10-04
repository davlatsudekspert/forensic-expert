import 'enums.dart';
import 'evidence_graph.dart';
import 'taxonomy.dart';

/// Research, bog‘lanish va rasm metadatasining JSON ko‘rinishi
/// (`fe-bundle/3`). Noma’lum qiymat — [FormatException].
abstract final class EvidenceJson {
  static ResearchRecord researchFrom(Map<String, Object?> m) => ResearchRecord(
    id: _s(m, 'research_id'),
    kind: ResearchKind.fromCode(_s(m, 'kind')),
    title: _s(m, 'title'),
    authors: [...?(m['authors'] as List?)?.cast<String>()],
    organization: m['organization'] as String?,
    container: m['container'] as String?,
    year: m['year'] as String?,
    doi: m['doi'] as String?,
    pmid: m['pmid'] as String?,
    pmcid: m['pmcid'] as String?,
    handle: m['handle'] as String?,
    url: m['url'] as String?,
    degree: m['degree'] as String?,
    openAccess: m['open_access'] as String?,
    sourceApi: m['source_api'] as String?,
    accessedDate: _d(m['accessed']),
    evidenceLevel: EvidenceLevel.values.firstWhere(
      (e) => e.code == _s(m, 'evidence_level'),
      orElse: () =>
          throw FormatException('bad evidence_level in ${m['research_id']}'),
    ),
    status: ScientificStatus.fromCode(_s(m, 'review_status')),
    isTestData: m['is_test_data'] == true,
    forensicRelevance: ForensicRelevance.fromCode(
      m['forensic_relevance'] as String?,
    ),
    language: m['language'] as String?,
  );

  static EntityLink linkFrom(Map<String, Object?> m) => EntityLink(
    fromId: _s(m, 'from'),
    toId: _s(m, 'to'),
    relation: LinkRelation.fromCode(_s(m, 'relation')),
    basis: _s(m, 'basis'),
  );

  static ScientificImage imageFrom(Map<String, Object?> m) => ScientificImage(
    id: _s(m, 'image_id'),
    kind: ImageKind.fromCode(_s(m, 'kind')),
    entityId: _s(m, 'entity_id'),
    title: (m['title']! as Map).cast<String, String>(),
    alt: (m['alt']! as Map).cast<String, String>(),
    license: _s(m, 'license'),
    attribution: _s(m, 'attribution'),
    isOriginalDiagram: m['is_original_diagram'] == true,
    representsRealData: m['represents_real_data'] == true,
    creator: m['creator'] as String?,
    sourceName: m['source_name'] as String?,
    sourceUrl: m['source_url'] as String?,
    doi: m['doi'] as String?,
    captionOriginal: m['caption_original'] as String?,
    graphic: m['graphic'] == true,
    accessedDate: _d(m['accessed']),
    sha256: m['sha256'] as String?,
    file: m['file'] as String?,
  );

  static String _s(Map<String, Object?> m, String k) {
    final v = m[k];
    if (v is! String || v.isEmpty) throw FormatException('missing "$k"');
    return v;
  }

  static DateTime? _d(Object? v) =>
      v == null ? null : DateTime.parse(v as String);
}
