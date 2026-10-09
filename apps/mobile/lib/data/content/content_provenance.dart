import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_database/fe_database.dart' show ContentDatabase;

import '../../domain/evidence/machine_translations.dart';
import '../../domain/evidence/provenance_models.dart';
import '../../domain/library/library_models.dart';

/// `content.db` dan manbalar va claim’larni (citation, review soni bilan)
/// o‘qiydi — kutubxona va bilim sohalari uchun umumiy.
class ContentProvenance {
  ContentProvenance._(this._sources, this.claimsByEntity);

  final Map<String, Map<String, Object?>> _sources;

  /// entity_id → claim’lar.
  final Map<String, List<ClaimView>> claimsByEntity;

  /// PHASE 7 provenance qatlami.
  ProvenanceIndex index = ProvenanceIndex.empty;

  /// Asl iqtibos/sarlavhalarning avtomatik (machine_draft) tarjimalari.
  MachineTranslations translations = MachineTranslations.empty;

  /// `text_translations` (sxema v7). Jadval yo‘q eski paketda — bo‘sh.
  static Future<MachineTranslations> loadTranslations(
    ContentDatabase db,
  ) async {
    final exists = await db
        .customSelect(
          "SELECT 1 FROM sqlite_master WHERE type = 'table' "
          "AND name = 'text_translations'",
        )
        .get();
    if (exists.isEmpty) return MachineTranslations.empty;
    return MachineTranslations.of([
      for (final r
          in await db.customSelect('SELECT * FROM text_translations').get())
        TextTranslation(
          target: TextTranslationTarget.fromCode(r.read<String>('target_type')),
          targetId: r.read<String>('target_id'),
          lang: r.read<String>('lang'),
          sourceSha256: r.read<String>('source_sha256'),
          text: r.read<String>('translated_text'),
          status: r.read<String>('status'),
        ),
    ]);
  }

  static Future<ContentProvenance> load(ContentDatabase db) async {
    // PHASE 7: source_provenance ustunlari manba qatoriga qo‘shiladi.
    final sources = <String, Map<String, Object?>>{
      for (final r
          in await db
              .customSelect(
                'SELECT s.*, p.hierarchy, p.reuse_status, p.language AS '
                'src_language, p.sha256, p.source_version, p.lifecycle, '
                'p.lifecycle_basis, p.lifecycle_checked_at FROM sources s '
                'LEFT JOIN source_provenance p USING (source_id)',
              )
              .get())
        r.read<String>('source_id'): r.data,
    };
    final p = ContentProvenance._(sources, {});

    final lifecycle = <String, (ClaimLifecycle, String)>{
      for (final r
          in await db.customSelect('SELECT * FROM claim_lifecycle').get())
        r.read<String>('claim_id'): (
          ClaimLifecycle.fromCode(r.read<String>('lifecycle')),
          r.read<String>('reason'),
        ),
    };
    final conflictRows = await db
        .customSelect('SELECT * FROM evidence_conflicts ORDER BY conflict_id')
        .get();
    final conflictClaims = <String, List<String>>{};
    final claimConflicts = <String, List<String>>{};
    for (final r
        in await db
            .customSelect('SELECT * FROM conflict_claims ORDER BY claim_id')
            .get()) {
      final k = r.read<String>('conflict_id');
      final c = r.read<String>('claim_id');
      conflictClaims.putIfAbsent(k, () => []).add(c);
      claimConflicts.putIfAbsent(c, () => []).add(k);
    }

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
              lifecycle: lifecycle[id]?.$1 ?? ClaimLifecycle.needsReview,
              lifecycleReason: lifecycle[id]?.$2,
              conflictIds: claimConflicts[id] ?? const [],
              entityId: r.read<String>('entity_id'),
            ),
          );
    }

    List<String> strings(String json) =>
        (jsonDecode(json) as List).cast<String>();
    final claimsById = {
      for (final list in p.claimsByEntity.values)
        for (final c in list) c.claimId: c,
    };
    final byStatus = <ScientificStatus, int>{};
    final byLifecycle = <ClaimLifecycle, int>{};
    for (final c in claimsById.values) {
      byStatus[c.status] = (byStatus[c.status] ?? 0) + 1;
      byLifecycle[c.lifecycle] = (byLifecycle[c.lifecycle] ?? 0) + 1;
    }
    Future<int> count(String table) async =>
        (await db.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle())
            .read<int>('n');
    final conflicts = [
      for (final r in conflictRows)
        ConflictView(
          id: r.read<String>('conflict_id'),
          entityId: r.read<String>('entity_id'),
          question: r.read<String>('question'),
          kind: ConflictKind.fromCode(r.read<String>('kind')),
          note: r.read<String>('note'),
          state: EvidenceConflictState.fromCode(r.read<String>('state')),
          claimIds: conflictClaims[r.read<String>('conflict_id')] ?? const [],
          detectedAt: date(r.data['detected_at']),
        ),
    ];
    p.translations = await loadTranslations(db);
    p.index = ProvenanceIndex(
      conflicts: conflicts,
      claimsById: claimsById,
      metabolites: [
        for (final r
            in await db
                .customSelect(
                  'SELECT * FROM metabolite_relations ORDER BY relation_id',
                )
                .get())
          MetaboliteRelation(
            id: r.read<String>('relation_id'),
            parentId: r.read<String>('parent_id'),
            metaboliteId: r.readNullable<String>('metabolite_id'),
            metaboliteName: r.read<String>('metabolite_name'),
            kind: MetaboliteRelationKind.fromCode(r.read<String>('kind')),
            specimens: strings(r.read<String>('specimens_json')),
            basisClaimId: r.read<String>('basis_claim_id'),
          ),
      ],
      specimens: [
        for (final r
            in (await db.customSelect('SELECT * FROM specimens').get())..sort(
              (a, b) =>
                  _specimenRank(a.read<String>('specimen_id'))
                      .compareTo(_specimenRank(b.read<String>('specimen_id'))),
            ))
          SpecimenView(
            id: r.read<String>('specimen_id'),
            category: r.read<String>('category'),
            names: LocalizedText(
              (jsonDecode(r.read<String>('names_json')) as Map)
                  .cast<String, String>(),
            ),
            aliases: strings(r.read<String>('aliases_json')),
          ),
      ],
      standards: [
        for (final r
            in await db
                .customSelect('SELECT * FROM standards ORDER BY designation')
                .get())
          StandardView(
            id: r.read<String>('standard_id'),
            designation: r.read<String>('designation'),
            title: r.read<String>('title'),
            publisher: r.read<String>('publisher'),
            documentKind: DocumentKind.values.byName(
              r.read<String>('document_kind'),
            ),
            status: StandardStatus.fromCode(r.read<String>('status')),
            reuse: ReuseStatus.fromCode(r.read<String>('reuse_status')),
            verifiedFrom: r.read<String>('verified_from'),
            verifiedAt: date(r.data['verified_at'])!,
            year: r.readNullable<String>('pub_year'),
            edition: r.readNullable<String>('edition'),
            supersededBy: r.readNullable<String>('superseded_by'),
            url: r.readNullable<String>('url'),
            sha256: r.readNullable<String>('sha256'),
            note: r.readNullable<String>('note'),
          ),
      ],
      terms: [
        for (final r
            in await db
                .customSelect(
                  'SELECT * FROM term_translations ORDER BY term_id',
                )
                .get())
          ProvenanceJson.termFrom({
            'term_id': r.read<String>('term_id'),
            'kind': r.read<String>('kind'),
            'original': r.read<String>('original'),
            'original_lang': r.read<String>('original_lang'),
            'canonical': r.read<String>('canonical'),
            'localized': jsonDecode(r.read<String>('localized_json')),
            'status': jsonDecode(r.read<String>('status_json')),
          }),
      ],
      review: ReviewSummary(
        claimsByStatus: byStatus,
        claimsByLifecycle: byLifecycle,
        reviewers: await count('reviewers'),
        reviewActions: await count('review_actions'),
        openConflicts: conflicts
            .where((c) => c.state == EvidenceConflictState.open)
            .length,
      ),
    );
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
      hierarchy: switch (s['hierarchy']) {
        'A' => SourceHierarchy.a,
        'B' => SourceHierarchy.b,
        'C' => SourceHierarchy.c,
        _ => null,
      },
      reuseStatus: s['reuse_status'] == null
          ? ReuseStatus.unknown
          : ReuseStatus.fromCode(s['reuse_status']! as String),
      lifecycle: s['lifecycle'] == null
          ? SourceLifecycle.current
          : SourceLifecycle.fromCode(s['lifecycle']! as String),
      lifecycleBasis: s['lifecycle_basis'] as String?,
      lifecycleCheckedAt: date(s['lifecycle_checked_at']),
      sha256: s['sha256'] as String?,
      sourceVersion: s['source_version'] as String?,
      language: s['src_language'] as String?,
      authors: switch (s['authors_json']) {
        final String j when j.isNotEmpty => [
          for (final a in (jsonDecode(j) as List? ?? const []))
            if ('$a'.trim().isNotEmpty) '$a'.trim(),
        ],
        _ => const [],
      },
      licenseAgreementId: switch (s['license_agreement_id']) {
        final String a when a.trim().isNotEmpty => a.trim(),
        _ => null,
      },
    );
  }

  /// Namunalarning amaliy tartibi (qon birinchi); noma’lumlari oxirida.
  static int _specimenRank(String id) {
    const order = [
      'blood',
      'serum-plasma',
      'urine',
      'vitreous',
      'oral-fluid',
      'hair',
      'gastric',
      'liver',
      'bile',
      'kidney',
      'brain',
      'csf',
    ];
    final i = order.indexOf(id);
    return i < 0 ? order.length : i;
  }

  static DateTime? date(Object? v) =>
      v == null ? null : DateTime.tryParse(v as String);
}
