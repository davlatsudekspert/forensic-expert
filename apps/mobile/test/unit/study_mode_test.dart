import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/learn/study_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';

import '../helpers/pilot_content.dart';
import '../helpers/study_fixtures.dart';

void main() {
  group('StudyCatalogBuilder', () {
    test('mavzu: definition claim’i manbasi bilan, status o‘zgarmaydi', () {
      final catalog = StudyCatalogBuilder.build(
        knowledge: ListKnowledgeRepository([testTopic('A')]),
      );
      expect(catalog.decks, hasLength(1));
      final deck = catalog.decks.single;
      expect(deck.kind, StudyDeckKind.discipline);
      expect(deck.key, ForensicDiscipline.forensicMedicine.name);
      final item = deck.items.single;
      expect(item.kind, StudyItemKind.topicExcerpt);
      expect(item.answer.resolve('uz'), 'TEST excerpt for A.');
      expect(item.answerIsQuote, isTrue);
      expect(item.citations.single.sourceId, 'SRC-C-A');
      expect(item.status, ScientificStatus.needsReview);
      expect(item.origin, StudyOrigin.knowledgeEntry);
      expect(item.originId, 'A');
      expect(item.isTestData, isTrue);
    });

    test('status hech qachon ko‘tarilmaydi (eng zaifi olinadi)', () {
      final catalog = StudyCatalogBuilder.build(
        knowledge: ListKnowledgeRepository([
          testTopic(
            'A',
            claims: [
              testClaim('C-A', 'definition', {
                'excerpt': 'TEST',
              }, status: ScientificStatus.verified),
            ],
          ),
        ]),
      );
      expect(
        catalog.decks.single.items.single.status,
        ScientificStatus.needsReview,
      );
    });

    test('manbasiz, retracted yoki eskirgan claim kiritilmaydi', () {
      final catalog = StudyCatalogBuilder.build(
        knowledge: ListKnowledgeRepository([
          testTopic(
            'noSource',
            claims: [
              testClaim('C-1', 'definition', {
                'excerpt': 'TEST',
              }, sources: const []),
            ],
          ),
          testTopic(
            'retracted',
            claims: [
              testClaim(
                'C-2',
                'definition',
                {'excerpt': 'TEST'},
                sources: [
                  testSource('S', lifecycle: SourceLifecycle.retracted),
                ],
              ),
            ],
          ),
          testTopic(
            'outdated',
            claims: [
              testClaim('C-3', 'definition', {
                'excerpt': 'TEST',
              }, lifecycle: ClaimLifecycle.outdated),
            ],
          ),
          testTopic('noExcerpt', claims: [testClaim('C-4', 'definition', {})]),
          testTopic(
            'otherField',
            claims: [
              testClaim('C-5', 'limitation', {'excerpt': 'TEST'}),
            ],
          ),
        ]),
      );
      expect(catalog.isEmpty, isTrue);
    });

    test('maydon ustuvorligi: definition > principle > use > marker', () {
      final catalog = StudyCatalogBuilder.build(
        knowledge: ListKnowledgeRepository([
          testTopic(
            'A',
            claims: [
              testClaim('C-M', 'marker', {'excerpt': 'TEST marker'}),
              testClaim('C-P', 'principle', {'excerpt': 'TEST principle'}),
            ],
          ),
        ]),
      );
      expect(
        catalog.decks.single.items.single.answer.resolve('en'),
        'TEST principle',
      );
    });

    test('pullik yozuvlar faqat ruxsat bo‘lsa', () {
      final knowledge = ListKnowledgeRepository([
        testTopic('A', access: EntryAccess.lifetime),
      ]);
      final library = TestLibrary([
        testSubstance('s1', access: EntryAccess.lifetime),
      ]);
      expect(
        StudyCatalogBuilder.build(
          knowledge: knowledge,
          library: library,
        ).isEmpty,
        isTrue,
      );
      final unlocked = StudyCatalogBuilder.build(
        knowledge: knowledge,
        library: library,
        substancesUnlocked: true,
        referencesUnlocked: true,
      );
      expect(unlocked.decks, hasLength(2));
    });

    test('modda: formula identity claim’idan, guruh bo‘yicha to‘plam', () {
      final catalog = StudyCatalogBuilder.build(
        library: TestLibrary([
          testSubstance('s1', formula: 'TEST-F1', group: 'g_a'),
          testSubstance('s2', formula: 'TEST-F2', group: 'g_b'),
          testSubstance('s3', formula: ''),
          testSubstance('s4', sources: const []),
        ]),
      );
      expect([for (final d in catalog.decks) d.id], ['group.g_a', 'group.g_b']);
      final item = catalog.deck('group.g_a')!.items.single;
      expect(item.answer.resolve('ru'), 'TEST-F1');
      expect(item.origin, StudyOrigin.libraryEntry);
      expect(item.citations, isNotEmpty);
      expect(item.group, 'g_a');
    });

    test('yo‘riqnoma: mazmun + adabiyot; VERIFIED fayl ham ko‘tarilmaydi', () {
      final catalog = StudyCatalogBuilder.build(guidelines: testGuidelines());
      final deck = catalog.deck('guideline.forensicChemistry')!;
      expect(deck.items, hasLength(2));
      final item = deck.items.first;
      expect(item.answer.resolve('uz'), 'TEST mazmun g1');
      expect(item.citations.single.title, contains('TEST reference g1'));
      expect(item.status, ScientificStatus.needsReview);
      expect(item.draftLanguages, {'ru', 'en'});
      expect(
        StudyCatalogBuilder.build(guidelines: testGuidelines(withRefs: false))
            .isEmpty,
        isTrue,
      );
    });

    test('tartib deterministik', () {
      final a = testStudyCatalog();
      final b = testStudyCatalog();
      expect(
        [
          for (final d in a.decks)
            for (final i in d.items) i.id,
        ],
        [
          for (final d in b.decks)
            for (final i in d.items) i.id,
        ],
      );
      expect(
        [for (final d in a.decks) d.kind],
        [
          StudyDeckKind.discipline,
          StudyDeckKind.substanceGroup,
          StudyDeckKind.guidelineArea,
        ],
      );
    });
  });

  group('Distraktorlar va test', () {
    test('faqat bir xil turdagi boshqa yozuvlar, takrorsiz', () {
      final catalog = testStudyCatalog();
      final item = catalog.deck('group.test_group')!.items.first;
      final all = [for (final d in catalog.decks) ...d.items];
      final picked = StudyQuizBuilder.distractors(item, all, Random(1));
      expect(picked, hasLength(2));
      expect(
        picked.every(
          (p) => p.kind == StudyItemKind.substanceFormula && p.id != item.id,
        ),
        isTrue,
      );
      expect({for (final p in picked) p.answer.resolve('en')}, hasLength(2));
    });

    test('ko‘rinishi bir xil variant tashlanadi', () {
      final catalog = StudyCatalogBuilder.build(
        library: TestLibrary([
          testSubstance('s1', formula: 'TEST-F1'),
          testSubstance('s2', formula: 'TEST-F1'),
          testSubstance('s3', formula: 'test-f1 '),
          testSubstance('s4', formula: 'TEST-F4'),
        ]),
      );
      final items = catalog.itemsOfKind(StudyItemKind.substanceFormula);
      final s1 = items.firstWhere((i) => i.originId == 's1');
      final picked = StudyQuizBuilder.distractors(s1, items, Random(3));
      expect([for (final p in picked) p.originId], ['s4']);
    });

    test('avval shu to‘plamdan, keyin boshqasidan', () {
      final catalog = StudyCatalogBuilder.build(
        library: TestLibrary([
          testSubstance('a1', formula: 'TEST-A1', group: 'a'),
          testSubstance('a2', formula: 'TEST-A2', group: 'a'),
          testSubstance('b1', formula: 'TEST-B1', group: 'b'),
          testSubstance('b2', formula: 'TEST-B2', group: 'b'),
          testSubstance('b3', formula: 'TEST-B3', group: 'b'),
        ]),
      );
      final items = catalog.itemsOfKind(StudyItemKind.substanceFormula);
      final a1 = items.firstWhere((i) => i.originId == 'a1');
      for (var seed = 0; seed < 20; seed++) {
        final picked = StudyQuizBuilder.distractors(a1, items, Random(seed));
        expect(picked, hasLength(3));
        expect(picked.first.originId, 'a2', reason: 'seed $seed');
      }
    });

    test('bir xil seed — bir xil test; to‘g‘ri javob o‘z joyida', () {
      final catalog = testStudyCatalog();
      final deck = catalog.decks.first;
      final a = StudyQuizBuilder.build(deck, catalog, seed: 42);
      final b = StudyQuizBuilder.build(deck, catalog, seed: 42);
      String sig(List<StudyQuestion> qs) => [
        for (final q in qs)
          '${q.item.id}:${q.correctIndex}:'
              '${[for (final o in q.options) o.id].join(',')}',
      ].join('|');
      expect(sig(a), sig(b));
      expect(a, hasLength(deck.items.length));
      for (final q in a) {
        expect(q.options[q.correctIndex].id, q.item.id);
        expect(q.options, hasLength(4));
        expect({for (final o in q.options) o.id}, hasLength(4));
        expect(q.asksForPrompt, isTrue);
        expect(q.stem.resolve('en'), q.item.answer.resolve('en'));
      }
      final seeds = {
        for (var s = 0; s < 10; s++)
          sig(StudyQuizBuilder.build(deck, catalog, seed: s)),
      };
      expect(seeds.length, greaterThan(1));
    });

    test('uzunlik cheklanadi; distraktorsiz yozuv savolga aylanmaydi', () {
      final catalog = testStudyCatalog();
      final deck = catalog.decks.first;
      expect(
        StudyQuizBuilder.build(deck, catalog, seed: 1, length: 2),
        hasLength(2),
      );
      final single = StudyCatalogBuilder.build(
        knowledge: ListKnowledgeRepository([testTopic('A')]),
      );
      expect(StudyQuizBuilder.canQuiz(single.decks.single, single), isFalse);
    });

    test('formula savoli: nom → formula', () {
      final catalog = testStudyCatalog();
      final deck = catalog.deck('group.test_group')!;
      final q = StudyQuizBuilder.build(deck, catalog, seed: 7).first;
      expect(q.asksForPrompt, isFalse);
      expect(q.stem.resolve('en'), q.item.prompt.resolve('en'));
      expect(
        q.optionText(q.correctIndex).resolve('en'),
        q.item.answer.resolve('en'),
      );
    });
  });

  group('Leitner', () {
    final t0 = DateTime.utc(2026, 1, 1, 9);

    test('bildim — keyingi quti, bilmadim — 1-quti, maksimum 5', () {
      var c = LeitnerScheduler.review(null, knew: true, now: t0);
      expect(c.box, 2);
      for (var i = 0; i < 10; i++) {
        c = LeitnerScheduler.review(c, knew: true, now: t0);
      }
      expect(c.box, LeitnerScheduler.maxBox);
      c = LeitnerScheduler.review(c, knew: false, now: t0);
      expect(c.box, 1);
      expect(LeitnerScheduler.review(null, knew: false, now: t0).box, 1);
    });

    test('muddat: quti oralig‘i bo‘yicha', () {
      final c = LeitnerCard(box: 3, reviewedAt: t0);
      expect(c.dueAt, t0.add(const Duration(days: 3)));
      expect(
        LeitnerScheduler.isDue(c, t0.add(const Duration(days: 2))),
        isFalse,
      );
      expect(
        LeitnerScheduler.isDue(c, t0.add(const Duration(days: 3))),
        isTrue,
      );
      expect(LeitnerScheduler.isDue(null, t0), isTrue);
      expect(
        LeitnerScheduler.isDue(LeitnerCard(box: 1, reviewedAt: t0), t0),
        isTrue,
      );
    });

    test('navbat: muddati kelganlar (past quti birinchi), so‘ng yangilari', () {
      final items = testStudyCatalog().decks.first.items; // A, B, C, D
      final now = t0.add(const Duration(days: 10));
      final progress = {
        items[0].id: LeitnerCard(box: 4, reviewedAt: t0), // muddat 7 kun
        items[1].id: LeitnerCard(box: 2, reviewedAt: t0), // muddat 1 kun
        items[2].id: LeitnerCard(box: 5, reviewedAt: t0), // muddati kelmagan
      };
      final queue = LeitnerScheduler.dueQueue(items, progress, now);
      expect(
        [for (final i in queue) i.id],
        [items[1].id, items[0].id, items[3].id],
      );
      expect(LeitnerScheduler.dueCount(items, progress, now), 3);
      expect(
        [for (final i in LeitnerScheduler.allByBox(items, progress)) i.id],
        [items[3].id, items[1].id, items[0].id, items[2].id],
      );
    });

    test('kodek: aylanma va buzilgan qiymat', () {
      final p = {'x': LeitnerCard(box: 3, reviewedAt: t0)};
      final back = StudyProgressCodec.decode(StudyProgressCodec.encode(p));
      expect(back['x']!.box, 3);
      expect(back['x']!.reviewedAt, t0);
      expect(StudyProgressCodec.decode('not json'), isEmpty);
      expect(StudyProgressCodec.decode('[1,2]'), isEmpty);
      expect(
        StudyProgressCodec.decode('{"a":{"b":9,"t":"2026-01-01"},"z":1}'),
        {'a': isA<LeitnerCard>().having((c) => c.box, 'box', 5)},
      );
      expect(StudyProgressCodec.decode(null), isEmpty);
    });
  });

  group('Haqiqiy kontent (pilot paket + yo‘riqnomalar)', () {
    late StudyCatalog catalog;
    late Map<String, String> excerpts;
    setUpAll(() async {
      final pilot = await loadPilotContent();
      final guidelines = GuidelineBundle.fromJson(
        (jsonDecode(
          File('assets/content/guidelines/guidelines_v1.json')
              .readAsStringSync(),
        ) as Map).cast<String, Object?>(),
      );
      catalog = StudyCatalogBuilder.build(
        knowledge: pilot.knowledge,
        library: pilot.library,
        guidelines: guidelines,
        substancesUnlocked: true,
        referencesUnlocked: true,
      );
      excerpts = {
        for (final kind in KnowledgeKind.values)
          for (final e in pilot.knowledge.byKind(kind))
            for (final c in e.claims)
              if (c.excerpt != null) '${e.id}|${c.excerpt!.trim()}': c.claimId,
      };
    });

    test('har bir kartochkada manba bor, hech biri VERIFIED emas', () {
      final items = [for (final d in catalog.decks) ...d.items];
      expect(items, isNotEmpty);
      for (final kind in StudyItemKind.values) {
        expect(items.where((i) => i.kind == kind), isNotEmpty, reason: '$kind');
      }
      for (final i in items) {
        expect(i.citations, isNotEmpty, reason: i.id);
        expect(i.status.isPublishable, isFalse, reason: i.id);
      }
    });

    test('mavzu javoblari — paketdagi asl jumla (to‘qilmagan)', () {
      for (final i in catalog.itemsOfKind(StudyItemKind.topicExcerpt)) {
        expect(
          excerpts.containsKey('${i.originId}|${i.answer.resolve('en')}'),
          isTrue,
          reason: i.id,
        );
      }
    });

    test('har bir to‘plamdan test tuzish mumkin', () {
      for (final d in catalog.decks) {
        expect(StudyQuizBuilder.canQuiz(d, catalog), isTrue, reason: d.id);
      }
    });
  });
}
