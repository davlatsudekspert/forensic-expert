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
      // Bitta elementli to‘plam alohida chiqmaydi — aralash to‘plamga.
      expect(deck.key, StudyCatalogBuilder.mixedDeckKey);
      expect(deck.id, 'discipline.mixed');
      final item = deck.items.single;
      expect(item.domain, 'topic:forensic_medicine');
      expect(item.claimId, 'C-A');
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
      // Kichik guruhlar aralash to‘plamga; soha (guruh) saqlanadi.
      expect([for (final d in catalog.decks) d.id], ['group.mixed']);
      final item = catalog
          .deck('group.mixed')!
          .items
          .firstWhere((i) => i.originId == 's1');
      expect(item.domain, 'substance:g_a');
      expect(item.answer.resolve('ru'), 'TEST-F1');
      expect(item.origin, StudyOrigin.libraryEntry);
      expect(item.citations, isNotEmpty);
      expect(item.group, 'g_a');
    });

    test('yo‘riqnoma: mazmun + adabiyot; VERIFIED fayl ham ko‘tarilmaydi', () {
      final catalog = StudyCatalogBuilder.build(guidelines: testGuidelines());
      final deck = catalog.deck('guideline.forensicChemistry')!;
      expect(deck.items, hasLength(4));
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

  group('Distraktorlar: faqat bir soha, semantik cheklovlar', () {
    test('faqat shu sohadagi boshqa yozuvlar, takrorsiz', () {
      final catalog = testStudyCatalog();
      final item = catalog.deck('group.test_group')!.items.first;
      final all = [for (final d in catalog.decks) ...d.items];
      final picked = StudyQuizBuilder.distractors(item, all, Random(1));
      expect(picked, hasLength(3));
      for (final p in picked) {
        expect(p.kind, StudyItemKind.substanceFormula);
        expect(p.domain, item.domain);
        expect(p.id, isNot(item.id));
      }
      expect({for (final p in picked) p.answer.resolve('en')}, hasLength(3));
    });

    test('boshqa fan hech qachon distraktor emas (yetmasa ham)', () {
      // 2 ta sud-tibbiyot mavzusi + 4 ta biokimyo: sud-tibbiyot mavzusiga
      // biokimyodan variant olinmaydi — «To‘g‘ri / Noto‘g‘ri» ga o‘tadi.
      final catalog = StudyCatalogBuilder.build(
        knowledge: ListKnowledgeRepository([
          testTopic('M1'),
          testTopic('M2'),
          for (final id in ['B1', 'B2', 'B3', 'B4'])
            testTopic(id, area: KnowledgeArea.biochemistry),
        ]),
      );
      final all = [for (final d in catalog.decks) ...d.items];
      final m1 = all.firstWhere((i) => i.originId == 'M1');
      final b1 = all.firstWhere((i) => i.originId == 'B1');
      expect(m1.domain, isNot(b1.domain));
      for (var seed = 0; seed < 20; seed++) {
        final picked = StudyQuizBuilder.distractors(m1, all, Random(seed));
        expect([for (final p in picked) p.originId], ['M2']);
      }
      expect(catalog.formatOf(m1), StudyQuizFormat.trueFalse);
      expect(catalog.formatOf(b1), StudyQuizFormat.multipleChoice);
      expect(
        catalog.plausibleDistractors(b1).every((p) => p.domain == b1.domain),
        isTrue,
      );
    });

    test('fan oilasi: sud patologiyasi sud-tibbiyot bilan bir soha', () {
      expect(
        StudyCatalogBuilder.topicDomain(ForensicDiscipline.forensicPathology),
        StudyCatalogBuilder.topicDomain(ForensicDiscipline.forensicMedicine),
      );
      expect(
        StudyCatalogBuilder.topicDomain(ForensicDiscipline.forensicGenetics),
        isNot(
          StudyCatalogBuilder.topicDomain(ForensicDiscipline.forensicMedicine),
        ),
      );
    });

    test('mos distraktor yo‘q — faqat kartochka, test tuzilmaydi', () {
      final single = StudyCatalogBuilder.build(
        knowledge: ListKnowledgeRepository([testTopic('A')]),
      );
      final item = single.decks.single.items.single;
      expect(single.formatOf(item), StudyQuizFormat.flashcardOnly);
      expect(StudyQuizBuilder.canQuiz(single.decks.single, single), isFalse);
      expect(
        StudyQuizBuilder.build(single.decks.single, single, seed: 1),
        isEmpty,
      );
    });

    test(
      'formula: organik / noorganik aralashmaydi, yaqin formulalar oldin',
      () {
        final catalog = StudyCatalogBuilder.build(
          library: TestLibrary([
            testSubstance('p1', formula: 'C10H14NO5PS', group: 'pest'),
            testSubstance('p2', formula: 'C12H21N2O3PS', group: 'pest'),
            testSubstance('p3', formula: 'C9H11Cl3NO3PS', group: 'pest'),
            testSubstance('p4', formula: 'C31H23BrO3', group: 'pest'),
            testSubstance('p5', formula: 'AlP', group: 'pest'),
          ]),
        );
        final items = catalog.itemsOfKind(StudyItemKind.substanceFormula);
        final alp = items.firstWhere((i) => i.originId == 'p5');
        expect(catalog.plausibleDistractors(alp), isEmpty);
        expect(catalog.formatOf(alp), StudyQuizFormat.flashcardOnly);
        final p1 = items.firstWhere((i) => i.originId == 'p1');
        final ranked = catalog.plausibleDistractors(p1);
        expect(ranked.map((p) => p.originId), isNot(contains('p5')));
        // Eng yaqin (P va S saqlovchi, uglerod soni yaqin) — birinchi.
        expect(ranked.first.originId, anyOf('p2', 'p3'));
        expect(ranked.last.originId, 'p4');
      },
    );

    test('birlik: raqamli variantlar faqat bir xil birlikda', () {
      expect(StudyQuizBuilder.unitSignature('2.5 mg/L'), {'mg/L'});
      expect(StudyQuizBuilder.unitSignature('pH 8,5–9'), {'pH'});
      expect(StudyQuizBuilder.unitSignature('C2H6O'), isEmpty);
      const a = StudyItem(
        id: 'a',
        kind: StudyItemKind.substanceFormula,
        deckId: 'x',
        domain: 'substance:x',
        prompt: LocalizedText({'en': 'A'}),
        answer: LocalizedText({'en': '10 mg/L'}),
        status: ScientificStatus.needsReview,
        isTestData: true,
        citations: [],
        origin: StudyOrigin.libraryEntry,
        originId: 'a',
      );
      StudyItem other(String id, String answer) => StudyItem(
        id: id,
        kind: a.kind,
        deckId: 'x',
        domain: a.domain,
        prompt: LocalizedText({'en': id}),
        answer: LocalizedText({'en': answer}),
        status: a.status,
        isTestData: true,
        citations: const [],
        origin: a.origin,
        originId: id,
      );
      expect(StudyQuizBuilder.compatible(a, other('b', '20 mg/L')), isTrue);
      expect(StudyQuizBuilder.compatible(a, other('c', '20 %')), isFalse);
      expect(StudyQuizBuilder.compatible(a, other('d', '20 µg/mL')), isFalse);
    });

    test('ko‘rinishi bir xil variant tashlanadi', () {
      final catalog = StudyCatalogBuilder.build(
        library: TestLibrary([
          testSubstance('s1', formula: 'C1H4'),
          testSubstance('s2', formula: 'C1H4'),
          testSubstance('s3', formula: 'c1h4 '),
          testSubstance('s4', formula: 'C4H10'),
        ]),
      );
      final items = catalog.itemsOfKind(StudyItemKind.substanceFormula);
      final s1 = items.firstWhere((i) => i.originId == 's1');
      final picked = StudyQuizBuilder.distractors(s1, items, Random(3));
      expect([for (final p in picked) p.originId], ['s4']);
    });
  });

  group('Test: mashq / imtihon, izoh', () {
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
        expect(q.format, StudyQuizFormat.multipleChoice);
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

    test('«To‘g‘ri / Noto‘g‘ri»: taklif — o‘zi yoki shu sohadan', () {
      final catalog = StudyCatalogBuilder.build(
        knowledge: ListKnowledgeRepository([testTopic('A'), testTopic('B')]),
      );
      final deck = catalog.decks.single;
      final seen = <int>{};
      for (var seed = 0; seed < 30; seed++) {
        for (final q in StudyQuizBuilder.build(deck, catalog, seed: seed)) {
          expect(q.format, StudyQuizFormat.trueFalse);
          expect(q.choiceCount, 2);
          final shown = q.options.single;
          expect(shown.domain, q.item.domain);
          expect(q.correctIndex, shown.id == q.item.id ? 0 : 1);
          expect(q.isCorrect(q.correctIndex), isTrue);
          seen.add(q.correctIndex);
        }
      }
      expect(seen, {0, 1});
    });

    test('uzunlik cheklanadi', () {
      final catalog = testStudyCatalog();
      final deck = catalog.decks.first;
      expect(
        StudyQuizBuilder.build(deck, catalog, seed: 1, length: 2),
        hasLength(2),
      );
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

    test('imtihon: faqat muallif savollari (sahifa/bo‘lim + izoh, til '
        'qoralama emas)', () {
      final catalog = testStudyCatalog(quiz: true);
      final deck = catalog.deck('guideline.forensicChemistry')!;
      final gq = [
        for (final i in deck.items)
          if (i.kind == StudyItemKind.guidelineQuestion) i,
      ];
      expect(gq, hasLength(5));
      for (final i in gq) {
        expect(StudyEligibility.examEligible(i, 'uz'), isTrue, reason: i.id);
        // ru/en — DRAFT: imtihonga kirmaydi.
        expect(StudyEligibility.examEligible(i, 'en'), isFalse);
        expect(
          StudyEligibility.reason(i, 'en'),
          StudyIneligibility.draftTranslation,
        );
        expect(i.citations.single.section?.resolve('uz'), 'TEST bo‘lim');
      }
      final summaries = deck.items.where(
        (i) => i.kind == StudyItemKind.guidelineSummary,
      );
      for (final i in summaries) {
        expect(StudyEligibility.examEligible(i, 'uz'), isFalse);
        expect(
          StudyEligibility.reason(i, 'uz'),
          StudyIneligibility.autoGenerated,
        );
      }
      final exam = StudyQuizBuilder.build(
        deck,
        catalog,
        seed: 1,
        mode: StudyQuizMode.exam,
        lang: 'uz',
      );
      expect(exam, hasLength(5));
      expect(
        exam.every((q) => q.item.kind == StudyItemKind.guidelineQuestion),
        isTrue,
      );
      expect(StudyQuizBuilder.canExam(deck, catalog, 'uz'), isTrue);
      expect(StudyQuizBuilder.canExam(deck, catalog, 'en'), isFalse);
      expect(
        StudyQuizBuilder.build(
          deck,
          catalog,
          seed: 1,
          mode: StudyQuizMode.exam,
          lang: 'en',
        ),
        isEmpty,
      );
      // Mashqda hammasi bor (savollar + mazmun kartalari).
      expect(
        StudyQuizBuilder.build(deck, catalog, seed: 1, length: 50),
        hasLength(deck.items.length),
      );
    });

    test('imtihon: izohsiz yoki sahifasiz savol — faqat mashq', () {
      StudyItem gq({LocalizedText? e, StudyCitation? c}) => StudyItem(
        id: 'gq.x',
        kind: StudyItemKind.guidelineQuestion,
        deckId: 'd',
        prompt: const LocalizedText({'uz': 'Q'}),
        answer: const LocalizedText({'uz': 'A'}),
        status: ScientificStatus.needsReview,
        isTestData: false,
        citations: [c ?? const StudyCitation(title: 'T', pages: '12')],
        origin: StudyOrigin.guideline,
        originId: 'g',
        distractors: const [
          LocalizedText({'uz': 'x'}),
          LocalizedText({'uz': 'y'}),
          LocalizedText({'uz': 'z'}),
        ],
        explanation: e,
      );
      const e = LocalizedText({'uz': 'Izoh'});
      expect(StudyEligibility.examEligible(gq(e: e), 'uz'), isTrue);
      expect(
        StudyEligibility.reason(gq(), 'uz'),
        StudyIneligibility.noExplanation,
      );
      expect(
        StudyEligibility.reason(
          gq(
            e: e,
            c: const StudyCitation(title: 'T'),
          ),
          'uz',
        ),
        StudyIneligibility.noLocator,
      );
    });

    test('izoh: har savolda (muallif yoki manbali claim + manba)', () {
      final catalog = testStudyCatalog(quiz: true);
      for (final d in catalog.decks) {
        for (final q in StudyQuizBuilder.build(
          d,
          catalog,
          seed: 2,
          length: 50,
        )) {
          for (final lang in const ['uz', 'ru', 'en']) {
            expect(q.item.hasExplanation(lang), isTrue, reason: q.item.id);
          }
          expect(
            q.item.explanationKind,
            q.item.kind == StudyItemKind.guidelineQuestion
                ? StudyExplanationKind.authored
                : isNot(StudyExplanationKind.authored),
          );
        }
      }
    });

    test('kichik to‘plamlar aralash to‘plamga, katta to‘plam o‘z joyida', () {
      final catalog = StudyCatalogBuilder.build(
        knowledge: ListKnowledgeRepository([
          for (final id in ['A', 'B', 'C', 'D']) testTopic(id),
          testTopic('G', area: KnowledgeArea.biochemistry),
        ]),
      );
      expect(
        [for (final d in catalog.decks) d.id],
        ['discipline.forensicMedicine', 'discipline.mixed'],
      );
      final mixed = catalog.deck('discipline.mixed')!;
      expect(mixed.isMixed, isTrue);
      expect(mixed.items.single.deckId, 'discipline.mixed');
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

    test('aralash bo‘lmagan har bir to‘plamdan test tuzish mumkin', () {
      for (final d in catalog.decks) {
        if (d.isMixed) continue;
        expect(StudyQuizBuilder.canQuiz(d, catalog), isTrue, reason: d.id);
      }
    });
  });

  group('«Toksikologik kimyo» savollari (Yuldashev Z.A., bepul)', () {
    late GuidelineBundle guidelines;
    late StudyCatalog catalog;
    setUpAll(() {
      guidelines = GuidelineBundle.fromJson(
        (jsonDecode(
          File('assets/content/guidelines/guidelines_v1.json')
              .readAsStringSync(),
        ) as Map).cast<String, Object?>(),
      );
      // Pro ruxsatisiz (bepul foydalanuvchi).
      catalog = StudyCatalogBuilder.build(guidelines: guidelines);
    });

    test('bepul foydalanuvchida alohida to‘plam, ≥30 savol', () {
      final deck = catalog.deck(StudyCatalogBuilder.toksDeckId);
      expect(deck, isNotNull);
      expect(deck!.kind, StudyDeckKind.teachingMaterial);
      expect(deck.key, StudyCatalogBuilder.toksDeckKey);
      expect(deck.items.length, greaterThanOrEqualTo(30));
      for (final i in deck.items) {
        expect(i.kind, StudyItemKind.guidelineQuestion);
        expect(i.distractors, hasLength(3), reason: i.id);
        expect(i.status.isPublishable, isFalse, reason: i.id);
        expect(i.citations, isNotEmpty, reason: i.id);
        expect(
          i.citations.every(
            (c) => c.pages != null && c.title.contains('Yuldashev'),
          ),
          isTrue,
          reason: i.id,
        );
        final card = guidelines.byId(i.originId)!;
        expect(card.isFree, isTrue, reason: i.id);
      }
    });

    test('test: savol matni → 4 variant, to‘g‘ri javob bitta', () {
      final deck = catalog.deck(StudyCatalogBuilder.toksDeckId)!;
      final qs = StudyQuizBuilder.build(deck, catalog, seed: 7, length: 50);
      expect(qs.length, deck.items.length);
      for (final q in qs) {
        expect(q.asksForPrompt, isFalse);
        expect(q.options, hasLength(4));
        expect(q.options[q.correctIndex], same(q.item));
        expect(q.stem.resolve('uz'), q.item.prompt.resolve('uz'));
        final texts = {
          for (var i = 0; i < 4; i++) q.optionText(i).resolve('ru'),
        };
        expect(texts, hasLength(4), reason: q.item.id);
      }
      expect(StudyQuizBuilder.canQuiz(deck, catalog), isTrue);
    });

    test(
      'glossariy: T-TOKS terminlari paketda, uch tilda, machine_draft',
      () async {
        final pilot = await loadPilotContent();
        final terms = [
          for (final t in pilot.provenance.terms)
            if (t.id.startsWith('T-TOKS-')) t,
        ];
        expect(terms.length, greaterThanOrEqualTo(30));
        for (final t in terms) {
          expect(t.originalLang, 'uz');
          for (final lang in ['uz', 'ru', 'en']) {
            expect(t.localized[lang], isNotNull, reason: t.id);
            expect(
              t.status[lang],
              TranslationStatus.machineDraft,
              reason: t.id,
            );
          }
        }
      },
    );
  });
}
