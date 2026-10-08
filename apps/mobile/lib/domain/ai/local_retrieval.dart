import '../knowledge/knowledge_models.dart';
import '../library/library_models.dart';
import '../ports/ai_ports.dart';
import 'ai_architecture.dart';
import 'retrieval_scoring.dart';

/// Qurilmadagi (offline) qidiruv: kontent paketidagi manbali claim’lar.
///
/// So‘rov hech qayerga yuborilmaydi va saqlanmaydi. Oddiy so‘z kesishmasi
/// bo‘yicha reyting — embedding yoki tarmoq yo‘q.
class LocalRetrievalProvider implements RetrievalProvider {
  LocalRetrievalProvider({
    required LibraryRepository library,
    required KnowledgeRepository knowledge,
    required String languageCode,
  }) : _chunks = [
         for (final e in library.entries(LibrarySection.substances))
           for (final c in e.details?.claims ?? const <ClaimView>[])
             ?_chunk(c, e.id, e.name.resolve(languageCode)),
         for (final kind in KnowledgeKind.values)
           for (final e in knowledge.byKind(kind))
             for (final c in e.claims)
               ?_chunk(c, e.id, e.name.resolve(languageCode)),
       ];

  final List<_Chunk> _chunks;

  static _Chunk? _chunk(ClaimView c, String entityId, String title) {
    final text = c.excerpt;
    if (text == null || c.sources.isEmpty) return null;
    return _Chunk(
      RetrievedChunk(
        chunkId: c.claimId,
        entityId: entityId,
        title: title,
        text: text,
        sourceIds: [for (final s in c.sources) s.sourceId],
        tier: switch (c.status.code) {
          'VERIFIED' => AiEvidenceTier.internalVerified,
          'REVIEWED' => AiEvidenceTier.internalReviewed,
          _ => AiEvidenceTier.externalUnverified,
        },
        score: 0,
      ),
      _tokens('$title $text ${c.items.join(' ')}'),
    );
  }

  static Set<String> _tokens(String s) => RetrievalText.docTokens(s);

  late final RetrievalScorer _scorer = RetrievalScorer([
    for (final c in _chunks) c.tokens,
  ]);

  @override
  Future<List<RetrievedChunk>> retrieve(String query, {int limit = 5}) async {
    final q = RetrievalText.queryTokens(query);
    if (q.isEmpty) return const [];
    final scores = _scorer.scores(q);
    final scored = <(double, RetrievedChunk)>[];
    for (var i = 0; i < _chunks.length; i++) {
      final score = scores[i];
      if (score == null) continue;
      final r = _chunks[i].chunk;
      scored.add((
        score,
        RetrievedChunk(
          chunkId: r.chunkId,
          entityId: r.entityId,
          title: r.title,
          text: r.text,
          sourceIds: r.sourceIds,
          tier: r.tier,
          score: score,
        ),
      ));
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return [for (final (_, c) in scored.take(limit)) c];
  }
}

class _Chunk {
  const _Chunk(this.chunk, this.tokens);

  final RetrievedChunk chunk;
  final Set<String> tokens;
}
