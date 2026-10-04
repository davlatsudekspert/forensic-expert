import 'package:fe_content_schema/fe_content_schema.dart';

import '../evidence/provenance_models.dart';
import '../library/library_models.dart' show ClaimView;
import '../ports/ai_ports.dart';
import 'ai_architecture.dart';
import 'rag_pipeline.dart';

/// Qurilmadagi (offline) RAG qidiruvi: manbali claim’lar (hayot sikli va
/// ziddiyat bilan), standartlar katalogi va rasmiy yurisdiksion qoidalar.
///
/// So‘rov tarmoqqa yuborilmaydi va saqlanmaydi.
class ProvenanceRetrieval {
  ProvenanceRetrieval({
    required ProvenanceIndex index,
    required Map<String, String> entityTitles,
    List<(JurisdictionalRule, JurisdictionalInstrument)> legalRules = const [],
  }) : _items = [
         for (final c in index.claimsById.values)
           if (c.excerpt != null && c.sources.isNotEmpty)
             _claimItem(c, entityTitles[c.entityId] ?? c.entityId ?? ''),
         for (final s in index.standards)
           _Item(
             RankedChunk(
               chunk: RetrievedChunk(
                 chunkId: s.id,
                 entityId: s.id,
                 title: s.designation,
                 text: '${s.designation}: ${s.title} (${s.publisher})',
                 sourceIds: const [],
                 tier: AiEvidenceTier.externalUnverified,
                 score: 0,
               ),
               priority: AiSourcePriority.internationalStandard,
               lifecycle: s.status == StandardStatus.superseded
                   ? 'SUPERSEDED'
                   : 'NEEDS_REVIEW',
             ),
             _tokens('${s.designation} ${s.title}'),
           ),
         for (final (r, i) in legalRules)
           _Item(
             RankedChunk(
               chunk: RetrievedChunk(
                 chunkId: r.id,
                 entityId: r.subjectId,
                 title: i.titles['en'] ?? i.titles.values.first,
                 text:
                     '${i.titles['en'] ?? i.titles.values.first}: '
                     '${r.value['schedule'] ?? (r.value['schedules'] as List?)?.join(', ') ?? ''}',
                 sourceIds: [i.officialSourceId],
                 tier: AiEvidenceTier.externalUnverified,
                 score: 0,
               ),
               priority: AiSourcePriority.officialJurisdiction,
             ),
             _tokens('${r.subjectId} ${i.titles.values.join(' ')}'),
             jurisdictionId: i.jurisdictionId,
           ),
       ];

  final List<_Item> _items;

  static _Item _claimItem(ClaimView c, String title) => _Item(
    RankedChunk(
      chunk: RetrievedChunk(
        chunkId: c.claimId,
        entityId: c.entityId ?? '',
        title: title,
        text: c.excerpt!,
        sourceIds: [for (final s in c.sources) s.sourceId],
        tier: switch (c.status) {
          ScientificStatus.verified => AiEvidenceTier.internalVerified,
          ScientificStatus.reviewed => AiEvidenceTier.internalReviewed,
          _ => AiEvidenceTier.externalUnverified,
        },
        score: 0,
      ),
      priority: c.status.isPublishable
          ? AiSourcePriority.reviewedInternal
          : AiSourcePriority.sourceCatalogue,
      lifecycle: c.lifecycle.code,
      hasConflict: c.conflictIds.isNotEmpty,
      identifiers: {
        for (final s in c.sources) ...[?s.doi?.toLowerCase(), ?s.pmid],
      },
    ),
    _tokens('$title ${c.excerpt} ${c.items.join(' ')} ${c.entityId}'),
  );

  static final _split = RegExp(r'[^\p{L}\p{N}]+', unicode: true);
  static const _stop = {
    'the',
    'and',
    'what',
    'which',
    'with',
    'for',
    'are',
    'how',
    'что',
    'как',
    'для',
    'nima',
    'qanday',
    'uchun',
  };

  static Set<String> _tokens(String s) => {
    for (final t in s.toLowerCase().split(_split))
      if (t.length >= 3 && !_stop.contains(t)) t,
  };

  Future<List<RankedChunk>> retrieve(
    String query,
    AiIntentResult intent, {
    String? jurisdictionId,
    int limit = 12,
  }) async {
    final q = _tokens(query);
    if (q.isEmpty) return const [];
    final scored = <(double, RankedChunk)>[];
    for (final it in _items) {
      if (it.jurisdictionId != null &&
          it.jurisdictionId != jurisdictionId &&
          it.jurisdictionId != 'INT') {
        continue;
      }
      var hits = 0;
      for (final t in q) {
        if (it.tokens.any((x) => x.startsWith(t) || t.startsWith(x))) hits++;
      }
      if (hits == 0) continue;
      final score = hits / q.length;
      final r = it.ranked;
      scored.add((
        score,
        RankedChunk(
          chunk: RetrievedChunk(
            chunkId: r.chunk.chunkId,
            entityId: r.chunk.entityId,
            title: r.chunk.title,
            text: r.chunk.text,
            sourceIds: r.chunk.sourceIds,
            tier: r.chunk.tier,
            score: score,
          ),
          priority: r.priority,
          lifecycle: r.lifecycle,
          hasConflict: r.hasConflict,
          identifiers: r.identifiers,
        ),
      ));
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return [for (final (_, c) in scored.take(limit)) c];
  }
}

class _Item {
  const _Item(this.ranked, this.tokens, {this.jurisdictionId});

  final RankedChunk ranked;
  final Set<String> tokens;
  final String? jurisdictionId;
}
