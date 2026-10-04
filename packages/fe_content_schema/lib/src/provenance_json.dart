import 'enums.dart';
import 'provenance.dart';
import 'taxonomy.dart';

/// PHASE 7 yozuvlarining JSON ko‘rinishi (bundle va DB payload bilan bir
/// xil). Noma’lum kod — [FormatException] (jim o‘tkazib yuborish yo‘q).
abstract final class ProvenanceJson {
  static SourceProvenance sourceFrom(Map<String, Object?> m) =>
      SourceProvenance(
        sourceId: _s(m, 'source_id'),
        language: m['language'] as String?,
        sha256: m['sha256'] as String?,
        sourceVersion: m['source_version'] as String?,
        lifecycle: SourceLifecycle.fromCode(
          (m['lifecycle'] as String?) ?? 'current',
        ),
        supersededBy: m['superseded_by'] as String?,
        lifecycleCheckedAt: _d(m['lifecycle_checked_at']),
        lifecycleBasis: m['lifecycle_basis'] as String?,
        forensicRelevance: ForensicRelevance.fromCode(
          m['forensic_relevance'] as String?,
        ),
      );

  static EvidenceConflict conflictFrom(Map<String, Object?> m) =>
      EvidenceConflict(
        id: _s(m, 'conflict_id'),
        entityId: _s(m, 'entity_id'),
        question: _s(m, 'question'),
        kind: ConflictKind.fromCode(_s(m, 'kind')),
        claimIds: _l(m, 'claim_ids'),
        note: _s(m, 'note'),
        state: EvidenceConflictState.fromCode(
          (m['state'] as String?) ?? 'open',
        ),
        detectedAt: _d(m['detected_at']),
      );

  static Map<String, Object?> conflictTo(EvidenceConflict c) => {
    'conflict_id': c.id,
    'entity_id': c.entityId,
    'question': c.question,
    'kind': c.kind.code,
    'claim_ids': c.claimIds,
    'note': c.note,
    'state': c.state.code,
    if (c.detectedAt != null) 'detected_at': _ds(c.detectedAt!),
  };

  static ReviewAction actionFrom(Map<String, Object?> m) => ReviewAction(
    id: _s(m, 'action_id'),
    subjectId: _s(m, 'subject_id'),
    subjectVersion: m['subject_version']! as int,
    contentVersion: _s(m, 'content_version'),
    domain: ContentDomain.values.firstWhere(
      (d) => d.code == _s(m, 'domain'),
      orElse: () => throw FormatException('unknown domain ${m['domain']}'),
    ),
    reviewerId: _s(m, 'reviewer_id'),
    role: ReviewerRole.fromCode(_s(m, 'role')),
    action: ReviewActionType.fromCode(_s(m, 'action')),
    at: DateTime.parse(_s(m, 'at')),
    note: (m['note'] as String?) ?? '',
  );

  static MetaboliteRelation metaboliteFrom(Map<String, Object?> m) =>
      MetaboliteRelation(
        id: _s(m, 'relation_id'),
        parentId: _s(m, 'parent_id'),
        metaboliteId: m['metabolite_id'] as String?,
        metaboliteName: _s(m, 'metabolite_name'),
        kind: MetaboliteRelationKind.fromCode(_s(m, 'kind')),
        specimens: [...?(m['specimens'] as List?)?.cast<String>()],
        basisClaimId: _s(m, 'basis_claim_id'),
      );

  static Map<String, Object?> metaboliteTo(MetaboliteRelation r) => {
    'relation_id': r.id,
    'parent_id': r.parentId,
    if (r.metaboliteId != null) 'metabolite_id': r.metaboliteId,
    'metabolite_name': r.metaboliteName,
    'kind': r.kind.code,
    'specimens': r.specimens,
    'basis_claim_id': r.basisClaimId,
  };

  static SpecimenRecord specimenFrom(Map<String, Object?> m) => SpecimenRecord(
    id: _s(m, 'specimen_id'),
    names: (m['names']! as Map).cast<String, String>(),
    category: _s(m, 'category'),
    aliases: [...?(m['aliases'] as List?)?.cast<String>()],
  );

  static StandardRecord standardFrom(Map<String, Object?> m) => StandardRecord(
    id: _s(m, 'standard_id'),
    designation: _s(m, 'designation'),
    title: _s(m, 'title'),
    publisher: _s(m, 'publisher'),
    documentKind: DocumentKind.values.byName(_s(m, 'document_kind')),
    status: StandardStatus.fromCode(_s(m, 'status')),
    reuse: ReuseStatus.fromCode(_s(m, 'reuse')),
    verifiedFrom: _s(m, 'verified_from'),
    verifiedAt: DateTime.parse(_s(m, 'verified_at')),
    year: m['year'] as String?,
    edition: m['edition'] as String?,
    supersededBy: m['superseded_by'] as String?,
    url: m['url'] as String?,
    sha256: m['sha256'] as String?,
    disciplines: [
      for (final d in (m['disciplines'] as List? ?? const []))
        ForensicDiscipline.fromCode(d as String) ??
            (throw FormatException('unknown discipline $d')),
    ],
    note: m['note'] as String?,
  );

  static Map<String, Object?> standardTo(StandardRecord s) => {
    'standard_id': s.id,
    'designation': s.designation,
    'title': s.title,
    'publisher': s.publisher,
    'document_kind': s.documentKind.name,
    'status': s.status.code,
    'reuse': s.reuse.code,
    'verified_from': s.verifiedFrom,
    'verified_at': _ds(s.verifiedAt),
    if (s.year != null) 'year': s.year,
    if (s.edition != null) 'edition': s.edition,
    if (s.supersededBy != null) 'superseded_by': s.supersededBy,
    if (s.url != null) 'url': s.url,
    if (s.sha256 != null) 'sha256': s.sha256,
    'disciplines': [for (final d in s.disciplines) d.code],
    if (s.note != null) 'note': s.note,
  };

  static TermTranslation termFrom(Map<String, Object?> m) => TermTranslation(
    id: _s(m, 'term_id'),
    kind: ScientificTermKind.fromCode(_s(m, 'kind')),
    original: _s(m, 'original'),
    originalLang: _s(m, 'original_lang'),
    canonical: _s(m, 'canonical'),
    localized: (m['localized']! as Map).cast<String, String>(),
    status: {
      for (final e in (m['status']! as Map).entries)
        e.key as String: TranslationStatus.values.firstWhere(
          (t) => t.code == e.value,
          orElse: () =>
              throw FormatException('unknown translation status ${e.value}'),
        ),
    },
  );

  static String _s(Map<String, Object?> m, String k) {
    final v = m[k];
    if (v is! String || v.isEmpty) throw FormatException('missing "$k"');
    return v;
  }

  static List<String> _l(Map<String, Object?> m, String k) {
    final v = m[k];
    if (v is! List) throw FormatException('missing "$k"');
    return v.cast<String>();
  }

  static DateTime? _d(Object? v) =>
      v == null ? null : DateTime.parse(v as String);

  static String _ds(DateTime d) => d.toIso8601String().substring(0, 10);
}
