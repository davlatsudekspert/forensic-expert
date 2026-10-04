import '../knowledge/knowledge_models.dart';
import '../library/library_models.dart';
import '../ports/ai_ports.dart';
import 'ai_architecture.dart';

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

  static final _split = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

  static Set<String> _tokens(String s) => {
    for (final t in s.toLowerCase().split(_split))
      if (t.length >= 3) t,
  };

  @override
  Future<List<RetrievedChunk>> retrieve(String query, {int limit = 5}) async {
    final q = _tokens(query);
    if (q.isEmpty) return const [];
    final scored = <(double, RetrievedChunk)>[];
    for (final c in _chunks) {
      var hits = 0;
      for (final t in q) {
        if (c.tokens.any((x) => x.startsWith(t) || t.startsWith(x))) hits++;
      }
      if (hits == 0) continue;
      final score = hits / q.length;
      final r = c.chunk;
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
