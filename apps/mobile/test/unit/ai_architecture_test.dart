import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/offline/offline_ai.dart';
import 'package:forensic_expert/domain/ai/ai_architecture.dart';
import 'package:forensic_expert/domain/ports/ai_ports.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';

// TEST DATA — sintetik bo‘laklar; ilmiy matn emas.
const _chunk = RetrievedChunk(
  chunkId: 'TEST-C1',
  entityId: 'TEST-E1',
  text: 'TEST excerpt',
  sourceIds: ['TEST-SRC-1'],
  tier: AiEvidenceTier.externalUnverified,
  score: 1,
);

class _Retrieval implements RetrievalProvider {
  const _Retrieval(this.chunks);
  final List<RetrievedChunk> chunks;
  @override
  Future<List<RetrievedChunk>> retrieve(String q, {int limit = 5}) async =>
      chunks;
}

class _Provider implements AiProvider {
  const _Provider(this.draft);
  final AiDraft draft;
  @override
  bool get isConfigured => true;
  @override
  Future<AiDraft> generate(AiPrompt prompt) async => draft;
}

void main() {
  const safety = SafetyPolicy(RegexPiiScanner());
  const citations = CitationResolver(knownSourceIds: {'TEST-SRC-1'});
  const quota = AiEntitlement(
    plan: AiPlan.includedQuota,
    monthlyQuestionLimit: 10,
  );
  const q = AiQuestion(text: 'TEST question', languageCode: 'en');

  AiRouter router({
    List<RetrievedChunk> chunks = const [_chunk],
    AiProvider provider = const UnconfiguredAiProvider(),
  }) => AiRouter(
    safety: safety,
    retrieval: _Retrieval(chunks),
    provider: provider,
    citations: citations,
  );

  group('CitationResolver', () {
    test('noma’lum bo‘lak — javob rad etiladi', () {
      final r = citations.resolve(
        const AiDraft(text: 'x', citedChunkIds: ['FAKE']),
        const [_chunk],
      );
      expect(r.rejection, CitationRejection.unknownChunk);
    });
    test('havolasiz javob — rad etiladi', () {
      expect(
        citations.resolve(const AiDraft(text: 'x', citedChunkIds: []), const [
          _chunk,
        ]).rejection,
        CitationRejection.noCitations,
      );
    });
    test('paketda yo‘q manba — rad etiladi', () {
      const r = CitationResolver(knownSourceIds: {});
      expect(
        r.resolve(const AiDraft(text: 'x', citedChunkIds: ['TEST-C1']), const [
          _chunk,
        ]).rejection,
        CitationRejection.unknownSource,
      );
    });
    test('to‘g‘ri havola — manba bilan', () {
      final r = citations.resolve(
        const AiDraft(text: 'x', citedChunkIds: ['TEST-C1']),
        const [_chunk],
      );
      expect(r.isValid, isTrue);
      expect(r.citations.single.sourceId, 'TEST-SRC-1');
    });
  });

  group('SafetyPolicy', () {
    test('yakuniy o‘lim sababi / huquqiy xulosa / PII bloklanadi', () {
      expect(
        safety.checkQuestion('Determine the cause of death').blocks,
        contains(SafetyBlock.finalCauseOrManner),
      );
      expect(
        safety.checkQuestion('Установите причину смерти').blocks,
        contains(SafetyBlock.finalCauseOrManner),
      );
      expect(
        safety.checkQuestion('Is the driver guilty?').blocks,
        contains(SafetyBlock.legalConclusion),
      );
      expect(
        safety.checkQuestion('mail me at a@b.com').blocks,
        contains(SafetyBlock.personalData),
      );
      expect(safety.checkQuestion('What is livor mortis?').allowed, isTrue);
    });
  });

  group('AiRouter', () {
    test('LLM ulanmagan — faqat lokal manbalar (AI javobi emas)', () async {
      final r = await router().route(
        q,
        experience: AiExperience.tutor,
        entitlement: quota,
      );
      expect(r.outcome, AiRouteOutcome.retrievalOnly);
      expect(r.answer, isNull);
    });
    test('kontekst yo‘q — javob yo‘q', () async {
      final r = await router(chunks: const [])
          .route(q, experience: AiExperience.professional, entitlement: quota);
      expect(r.outcome, AiRouteOutcome.noReliableContext);
    });
    test('to‘qilgan havola — rad', () async {
      final r = await router(
        provider: const _Provider(AiDraft(text: 'x', citedChunkIds: ['FAKE'])),
      ).route(q, experience: AiExperience.professional, entitlement: quota);
      expect(r.outcome, AiRouteOutcome.rejected);
    });
    test('kvota yo‘q — LLM chaqirilmaydi', () async {
      final r =
          await router(
            provider: const _Provider(
              AiDraft(text: 'x', citedChunkIds: ['TEST-C1']),
            ),
          ).route(
            q,
            experience: AiExperience.professional,
            entitlement: AiEntitlement.none,
          );
      expect(r.outcome, AiRouteOutcome.quotaUnavailable);
    });
    test('to‘g‘ri havola — javob manbasi bilan', () async {
      final r = await router(
        provider: const _Provider(
          AiDraft(text: 'x', citedChunkIds: ['TEST-C1']),
        ),
      ).route(q, experience: AiExperience.professional, entitlement: quota);
      expect(r.outcome, AiRouteOutcome.answered);
      expect(r.answer!.isWellFormed, isTrue);
    });
  });
}
