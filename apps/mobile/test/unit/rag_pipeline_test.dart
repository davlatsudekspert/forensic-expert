import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/offline/offline_ai.dart';
import 'package:forensic_expert/domain/ai/ai_architecture.dart';
import 'package:forensic_expert/domain/ai/provenance_retrieval.dart';
import 'package:forensic_expert/domain/ai/rag_pipeline.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/domain/ports/ai_ports.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';
import 'package:forensic_expert/domain/privacy/telemetry_policy.dart';

import '../helpers/pilot_content.dart';

/// PHASE 9: RAG quvuri — haqiqiy pilot paket bilan baholash.
void main() {
  late PilotContent pilot;
  late ProvenanceRetrieval retrieval;
  late Set<String> knownSources;

  setUpAll(() async {
    pilot = await loadPilotContent();
    final titles = <String, String>{
      for (final e in pilot.library.entries(LibrarySection.substances))
        e.id: e.name.resolve('en'),
    };
    retrieval = ProvenanceRetrieval(
      index: pilot.provenance,
      entityTitles: titles,
    );
    knownSources = {
      for (final c in pilot.provenance.claimsById.values)
        for (final s in c.sources) s.sourceId,
    };
  });

  RagPipeline pipeline({AiProvider? provider, AiProviderMode? mode}) =>
      RagPipeline(
        safety: const SafetyPolicy(RegexPiiScanner()),
        retrieve: (q, i, j) => retrieval.retrieve(q, i, jurisdictionId: j),
        provider: provider ?? const UnconfiguredAiProvider(),
        knownSourceIds: knownSources,
        providerMode: mode ?? AiProviderMode.none,
      );

  const ent = AiEntitlement(
    plan: AiPlan.includedQuota,
    monthlyQuestionLimit: 10,
  );

  Future<RagAnswer> ask(
    String q, {
    String? j,
    AiProvider? provider,
    AiProviderMode? mode,
  }) => pipeline(provider: provider, mode: mode).ask(
    AiQuestion(text: q, languageCode: 'en', jurisdictionId: j),
    experience: AiExperience.professional,
    entitlement: ent,
  );

  group('niyat va domen (EN/RU/UZ)', () {
    test('tasnif', () {
      expect(
        AiIntentClassifier.classify('What are the metabolites of morphine?')
            .domain,
        AiDomain.toxicology,
      );
      expect(
        AiIntentClassifier.classify('Метаболиты морфина').domain,
        AiDomain.toxicology,
      );
      expect(
        AiIntentClassifier.classify('rigor mortis nima').domain,
        AiDomain.forensicMedicine,
      );
      expect(
        AiIntentClassifier.classify('Is fentanyl a controlled substance?')
            .intent,
        AiIntent.legal,
      );
      expect(
        AiIntentClassifier.classify('LC-MS/MS validation').domain,
        AiDomain.laboratory,
      );
    });
  });

  group('RAG baholash fixture’lari (provayder ulanmagan)', () {
    final fixtures = <(String, String?, RagOutcome)>[
      ('What are the metabolites of morphine?', null, RagOutcome.retrievalOnly),
      ('heroin 6-monoacetylmorphine', null, RagOutcome.retrievalOnly),
      (
        'vitreous potassium postmortem interval',
        null,
        RagOutcome.retrievalOnly,
      ),
      (
        'Is fentanyl a controlled substance?',
        null,
        RagOutcome.jurisdictionRequired,
      ),
      (
        'Is fentanyl a controlled substance?',
        'INT',
        RagOutcome.jurisdictionRequired,
      ),
      (
        'Is fentanyl a controlled substance in this schedule?',
        'US',
        RagOutcome.retrievalOnly,
      ),
      ('Determine the cause of death in this case', null, RagOutcome.blocked),
      (
        'Write the official expert opinion for this autopsy',
        null,
        RagOutcome.blocked,
      ),
      ('Was the victim intoxicated?', null, RagOutcome.blocked),
      ('Is the driver guilty?', null, RagOutcome.blocked),
      ('Patient passport AA1234567 morphine', null, RagOutcome.blocked),
      ('zxqv wpfk', null, RagOutcome.noReliableContext),
    ];
    for (final (q, j, expected) in fixtures) {
      test('$q [$j] → ${expected.name}', () async {
        expect((await ask(q, j: j)).outcome, expected);
      });
    }
  });

  test('retraksiya qilingan claim dalil sifatida ishlatilmaydi', () async {
    final r = await ask('algor mortis progressive cooling ambient temperature');
    expect(
      r.evidence.map((e) => e.chunk.chunkId),
      isNot(contains('C-FM-ALGOR-MORTIS-DEFINITION')),
    );
    expect(r.excludedRetracted, greaterThanOrEqualTo(1));
    expect(r.limitations, contains('retracted_excluded'));
  });

  test('ziddiyat va «inson tasdiqlamagan» cheklovi', () async {
    final r = await ask(
      'average blood concentration of methadone in adult cases living patients MMT',
    );
    expect(r.limitations, contains('not_human_verified'));
    expect(r.limitations, contains('evidence_conflict'));
    expect(r.limitations, contains('expert_judgment_required'));
  });

  group('gallyutsinatsiyaga chidamlilik (mock provayder)', () {
    test(
      'mock javob — answered, lekin «mock_provider» deb belgilanadi',
      () async {
        final r = await ask(
          'morphine glucuronide metabolites',
          provider: MockAiProvider(),
          mode: AiProviderMode.mock,
        );
        expect(r.outcome, RagOutcome.answered);
        expect(r.providerMode, AiProviderMode.mock);
        expect(r.limitations, contains('mock_provider'));
        expect(r.sources, isNotEmpty);
      },
    );

    test('to‘qilgan bo‘lak ID — rad', () async {
      final r = await ask(
        'morphine glucuronide metabolites',
        provider: MockAiProvider(
          respond: (p) =>
              const AiDraft(text: 'x', citedChunkIds: ['C-FAKE-CLAIM']),
        ),
      );
      expect(r.outcome, RagOutcome.rejectedCitation);
    });

    test(
      'havolasiz javob — "manbalar qamramaydi", matn ko‘rsatilmaydi',
      () async {
        final r = await ask(
          'morphine glucuronide metabolites',
          provider: MockAiProvider(
            respond: (p) =>
                const AiDraft(text: 'Uncited claim.', citedChunkIds: []),
          ),
        );
        expect(r.outcome, RagOutcome.notCovered);
        expect(r.text, isNull);
        expect(r.sources, isEmpty);
      },
    );

    test('server xatosi kodi UI’ga uzatiladi (jim yutilmaydi)', () async {
      final r = await ask(
        'morphine glucuronide metabolites',
        provider: MockAiProvider(
          respond: (p) => throw const _Unavailable('too_many_requests'),
        ),
      );
      expect(r.outcome, RagOutcome.retrievalOnly);
      expect(r.failureCode, 'too_many_requests');
      expect(r.evidence, isNotEmpty);
    });

    test('matnda to‘qilgan DOI/PMID — rad', () async {
      final r = await ask(
        'morphine glucuronide metabolites',
        provider: MockAiProvider(
          respond: (p) => AiDraft(
            text: 'See doi 10.9999/fabricated.123 and PMID 11111111.',
            citedChunkIds: [p.chunks.first.chunkId],
          ),
        ),
      );
      expect(r.outcome, RagOutcome.rejectedIdentifier);
    });

    test('javobda yakuniy o‘lim sababi — rad', () async {
      final r = await ask(
        'morphine glucuronide metabolites',
        provider: MockAiProvider(
          respond: (p) => AiDraft(
            text: 'The cause of death was morphine toxicity.',
            citedChunkIds: [p.chunks.first.chunkId],
          ),
        ),
      );
      expect(r.outcome, RagOutcome.rejectedSafety);
    });
  });

  group('maxfiylik', () {
    test('AI savoli telemetriyaga tushmaydi', () {
      expect(TelemetryPolicy.forbiddenKeys, contains('question'));
      expect(TelemetryPolicy.forbiddenKeys, contains('query'));
      expect(TelemetryPolicy.allowedKeys, isNot(contains('question')));
    });

    test('PII bo‘lgan savol provayderga yuborilmaydi', () async {
      var called = false;
      final r = await ask(
        'Case number 2026/123 morphine',
        provider: MockAiProvider(
          respond: (p) {
            called = true;
            return const AiDraft(text: 'x', citedChunkIds: []);
          },
        ),
      );
      expect(r.outcome, RagOutcome.blocked);
      expect(called, isFalse);
    });
  });

  test('identifikator yaxlitligi: cited manba DOI’si ruxsat etiladi', () {
    const chunk = RankedChunk(
      chunk: RetrievedChunk(
        chunkId: 'C',
        entityId: 'e',
        text: 't',
        sourceIds: ['S'],
        tier: AiEvidenceTier.externalUnverified,
        score: 1,
      ),
      priority: AiSourcePriority.sourceCatalogue,
      identifiers: {'10.1000/abc.1', '123456'},
    );
    expect(
      IdentifierIntegrity.ok('per 10.1000/abc.1 (PMID 123456).', [chunk]),
      isTrue,
    );
    expect(IdentifierIntegrity.ok('per 10.1000/other', [chunk]), isFalse);
  });

  test('ustuvorlik: review qilingan ichki > katalog > standart > qonun', () {
    RankedChunk c(String id, AiSourcePriority p, double s) => RankedChunk(
      chunk: RetrievedChunk(
        chunkId: id,
        entityId: id,
        text: id,
        sourceIds: const [],
        tier: AiEvidenceTier.externalUnverified,
        score: s,
      ),
      priority: p,
    );
    final out = EvidenceRanker.rank([
      c('law', AiSourcePriority.officialJurisdiction, 1),
      c('std', AiSourcePriority.internationalStandard, 1),
      c('cat', AiSourcePriority.sourceCatalogue, 0.1),
      c('rev', AiSourcePriority.reviewedInternal, 0.1),
    ]);
    expect(
      [for (final x in out) x.chunk.chunkId],
      ['rev', 'cat', 'std', 'law'],
    );
  });
}

class _Unavailable implements Exception {
  const _Unavailable(this.code);

  final String code;

  @override
  String toString() => 'AiUnavailable($code)';
}
