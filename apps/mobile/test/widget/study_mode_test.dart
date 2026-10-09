import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/glossary.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/study.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/learn/study_models.dart';

import '../helpers/pump_app.dart';
import '../helpers/study_fixtures.dart';

void main() {
  final now = DateTime.utc(2026, 3, 1, 10);
  const topicDeck = 'discipline.forensicMedicine';
  const substanceDeck = 'group.test_group';
  const guidelineDeck = 'guideline.forensicChemistry';

  Future<InMemoryStudyProgressStore> open(
    WidgetTester tester,
    String route, {
    Map<String, LeitnerCard>? progress,
    ThemeMode theme = ThemeMode.light,
    String lang = 'en',
    bool fixtures = true,
    StudyCatalog? catalog,
    Size size = const Size(390, 844),
  }) async {
    final store = InMemoryStudyProgressStore(progress);
    await pumpApp(
      tester,
      size: size,
      settings: completedSettings(
        lang: lang,
        theme: theme,
        mode: UserMode.student,
      ),
      initialLocation: route,
      testFixtures: fixtures,
      overrides: [
        studyCatalogProvider.overrideWithValue(catalog ?? testStudyCatalog()),
        studyProgressStoreProvider.overrideWithValue(store),
        studyClockProvider.overrideWithValue(() => now),
        studySeedProvider.overrideWithValue(() => 7),
        abbreviationNotesLoaderProvider.overrideWithValue(
          () async =>
              File('assets/content/terminology/abbreviation_glossary.json')
                  .readAsStringSync(),
        ),
      ],
    );
    return store;
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('Ta’lim ekranidan o‘quv rejimiga kirish', (tester) async {
    await open(tester, Routes.learn);
    await tap(tester, 'learn.study');
    expect(find.byKey(const Key('study.deck.$topicDeck')), findsOneWidget);
    expect(find.byKey(const Key('study.deck.$substanceDeck')), findsOneWidget);
    expect(find.byKey(const Key('study.deck.$guidelineDeck')), findsOneWidget);
    expect(find.text('4 cards'), findsWidgets);
    // Avtomatik to‘plamlar — faqat mashq, imtihon tugmasi o‘chiq.
    expect(find.text('Practice only'), findsWidgets);
    final exam = tester.widget<OutlinedButton>(
      find.byKey(const Key('study.exam.$substanceDeck')),
    );
    expect(exam.onPressed, isNull);
    expect(
      find.byKey(const Key('study.examUnavailable.$substanceDeck')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('namuna to‘plamlari bo‘sh: Test/Kartochkalar/Imtihon alohida '
      'plitka emas — yagona «O‘quv rejimi» kirishi', (tester) async {
    // Production: namuna (fixture) to‘plamlari yo‘q.
    await open(tester, Routes.learn, fixtures: false);
    for (final key in ['learn.quiz', 'learn.flashcards', 'learn.exam']) {
      expect(find.byKey(Key(key), skipOffstage: false), findsNothing);
    }
    await tap(tester, 'learn.study');
    expect(find.byKey(const Key('study.deck.$topicDeck')), findsOneWidget);
  });

  testWidgets('kartochka aylanadi, manba ko‘rinadi, Leitner saqlanadi', (
    tester,
  ) async {
    final store = await open(tester, Routes.studyCards(topicDeck));
    expect(find.text('Card 1 of 4'), findsOneWidget);
    expect(find.text('TEST topic A'), findsOneWidget);
    expect(find.text('TEST excerpt for A.'), findsNothing);
    expect(find.text('New card'), findsOneWidget);
    expect(find.text('Needs review'), findsWidgets);

    await tap(tester, 'study.card');
    expect(find.text('TEST excerpt for A.'), findsOneWidget);
    expect(find.byKey(const Key('study.source.topic.A.0')), findsOneWidget);
    expect(find.text('TEST source SRC-C-A'), findsOneWidget);
    expect(find.byKey(const Key('study.openEntry.topic.A')), findsOneWidget);

    await tap(tester, 'study.card');
    expect(find.text('TEST excerpt for A.'), findsNothing);
    await tap(tester, 'study.reveal');

    await tap(tester, 'study.knew');
    expect(find.text('Card 2 of 4'), findsOneWidget);
    expect(store.load()['topic.A']!.box, 2);

    for (final _ in [1, 2, 3]) {
      await tap(tester, 'study.reveal');
      await tap(tester, 'study.didntKnow');
    }
    expect(find.byKey(const Key('study.sessionDone')), findsOneWidget);
    expect(find.text('Knew 1 of 4'), findsOneWidget);
    expect(store.load()['topic.B']!.box, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muddati kelmagan to‘plam: «barchasini takrorlash»', (
    tester,
  ) async {
    await open(
      tester,
      Routes.studyCards(topicDeck),
      progress: {
        for (final id in ['A', 'B', 'C', 'D'])
          'topic.$id': LeitnerCard(box: 3, reviewedAt: now),
      },
    );
    expect(find.byKey(const Key('study.caughtUp')), findsOneWidget);
    await tap(tester, 'study.reviewAll');
    expect(find.text('Card 1 of 4'), findsOneWidget);
    expect(find.text('Box 3 of 5'), findsOneWidget);
  });

  testWidgets('mashq: javob → To‘g‘ri/Noto‘g‘ri + izoh + «Manbani ochish»', (
    tester,
  ) async {
    final catalog = testStudyCatalog();
    final questions = StudyQuizBuilder.build(
      catalog.deck(substanceDeck)!,
      catalog,
      seed: 7,
    );
    expect(questions, hasLength(4));
    await open(tester, Routes.studyQuiz(substanceDeck));
    expect(find.text('Question 1 of 4'), findsOneWidget);
    expect(find.byKey(const Key('study.mode.practice')), findsOneWidget);
    expect(find.byKey(const Key('study.mode.banner.practice')), findsOneWidget);
    expect(find.byKey(const Key('study.quiz.practiceOnly')), findsOneWidget);

    for (final (n, q) in questions.indexed) {
      expect(
        find.text(
          'What is the molecular formula of '
          '${q.item.prompt.resolve('en')}?',
        ),
        findsOneWidget,
      );
      final pick = n == 0 ? (q.correctIndex + 1) % 4 : q.correctIndex;
      await tap(tester, 'study.quiz.option.$pick');
      await tap(tester, 'study.quiz.check');
      expect(
        find.byKey(Key('study.quiz.feedback.${n == 0 ? 'wrong' : 'ok'}')),
        findsOneWidget,
      );
      expect(find.byKey(Key('study.explanation.${q.item.id}')), findsOneWidget);
      expect(
        find.text(
          'Molecular formula of ${q.item.prompt.resolve('en')} in its '
          'identity record: ${q.item.answer.resolve('en')}. The other '
          'options are formulas of substances from the same group.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('study.quiz.openSource.${q.item.id}')),
        findsOneWidget,
      );
      expect(find.byKey(Key('study.source.${q.item.id}.0')), findsOneWidget);
      await tap(tester, 'study.quiz.next');
    }

    expect(find.text('Score: 3 of 4'), findsOneWidget);
    expect(find.byKey(const Key('study.quiz.mistake.0')), findsOneWidget);
    final first = questions.first;
    expect(
      find.text('Correct answer: ${first.item.answer.resolve('en')}'),
      findsWidgets,
    );
    expect(find.byKey(Key('study.openEntry.${first.item.id}')), findsOneWidget);

    await tap(tester, 'study.quiz.retry');
    expect(find.text('Question 1 of 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('«Manbani ochish» manba sahifasiga olib boradi', (tester) async {
    final catalog = testStudyCatalog();
    final q = StudyQuizBuilder.build(
      catalog.deck(substanceDeck)!,
      catalog,
      seed: 7,
    ).first;
    await open(tester, Routes.studyQuiz(substanceDeck));
    await tap(tester, 'study.quiz.option.${q.correctIndex}');
    await tap(tester, 'study.quiz.check');
    await tap(tester, 'study.quiz.openSource.${q.item.id}');
    expect(find.byKey(Key('study.explanation.${q.item.id}')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('imtihon (uz): faqat mos savollar, izoh oxirida, GC-MS — '
      'lug‘at izohi', (tester) async {
    final catalog = testStudyCatalog(quiz: true);
    await open(tester, Routes.study, lang: 'uz', catalog: catalog);
    expect(find.byKey(const Key('study.examCount.$guidelineDeck')), findsOne);
    expect(find.text('Imtihon: 5 ta savol'), findsOneWidget);
    await tap(tester, 'study.exam.$guidelineDeck');

    expect(find.byKey(const Key('study.mode.exam')), findsOneWidget);
    expect(find.byKey(const Key('study.mode.banner.exam')), findsOneWidget);
    expect(find.text('1-savol / 5 ta'), findsOneWidget);
    for (var n = 0; n < 5; n++) {
      // Imtihonda savol — faqat muallif savoli; javobdan keyin izoh yo‘q.
      expect(find.textContaining('TEST savol'), findsOneWidget);
      await tap(tester, 'study.quiz.option.0');
      expect(find.byKey(const Key('study.quiz.check')), findsNothing);
      expect(find.byKey(const Key('study.quiz.feedback.ok')), findsNothing);
      expect(find.byKey(const Key('study.quiz.feedback.wrong')), findsNothing);
      await tap(tester, 'study.quiz.next');
    }
    expect(find.text('Imtihon natijasi'), findsOneWidget);
    expect(find.byKey(const Key('study.exam.percent')), findsOneWidget);
    expect(find.byKey(const Key('study.quiz.review.0')), findsOneWidget);
    expect(find.textContaining('TEST izoh'), findsWidgets);
    expect(find.textContaining('Bo‘lim: TEST bo‘lim'), findsWidgets);
    expect(find.text('Manbani ochish'), findsWidgets);

    // Izohdagi «GC-MS» — bosilganda lug‘at varag‘i (qisqa izoh bilan).
    final span = find.byWidgetPredicate((w) {
      if (w is! RichText) return false;
      var hit = false;
      w.text.visitChildren((s) {
        if (s is TextSpan && s.text == 'GC-MS' && s.recognizer != null) {
          hit = true;
          return false;
        }
        return true;
      });
      return hit;
    });
    expect(span, findsWidgets);
    await tester.ensureVisible(span.first);
    await tester.pumpAndSettle();
    await tester.tapOnText(find.textRange.ofSubstring('GC-MS').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('glossary.sheet')), findsOneWidget);
    expect(find.byKey(const Key('glossary.explanation')), findsOneWidget);
    expect(find.textContaining('Gaz xromatografiyasi'), findsWidgets);
    expect(find.byKey(const Key('glossary.badge.machineDraft')), findsOne);
    expect(tester.takeException(), isNull);
  });

  testWidgets('imtihon: ru/en tarjimasi qoralama — imtihon yo‘q (sababi '
      'ko‘rsatiladi)', (tester) async {
    await open(
      tester,
      Routes.study,
      lang: 'ru',
      catalog: testStudyCatalog(quiz: true),
    );
    final exam = tester.widget<OutlinedButton>(
      find.byKey(const Key('study.exam.$guidelineDeck')),
    );
    expect(exam.onPressed, isNull);
    expect(
      find.text(
        'Экзамен доступен на узбекском: русский перевод этих вопросов пока '
        'черновой.',
      ),
      findsOneWidget,
    );
  });

  for (final (lang, practice, explain, correct) in const [
    ('uz', 'Mashq', 'TEST izoh', 'To‘g‘ri'),
    ('ru', 'Тренировка', 'TEST пояснение', 'Верно'),
    ('en', 'Practice', 'TEST explanation', 'Correct'),
  ]) {
    testWidgets('320 dp, $lang: mashq va imtihonda javob izohi', (
      tester,
    ) async {
      final catalog = testStudyCatalog(quiz: true, authored: true);
      final deck = catalog.deck(guidelineDeck)!;
      await open(
        tester,
        Routes.studyQuiz(guidelineDeck),
        lang: lang,
        catalog: catalog,
        size: const Size(320, 640),
      );
      expect(find.text(practice), findsWidgets);
      final q = StudyQuizBuilder.build(deck, catalog, seed: 7).first;
      await tap(tester, 'study.quiz.option.${q.correctIndex}');
      await tap(tester, 'study.quiz.check');
      expect(find.byKey(const Key('study.quiz.feedback.ok')), findsOneWidget);
      expect(find.byKey(Key('study.explanation.${q.item.id}')), findsOneWidget);
      expect(
        find.byKey(Key('study.quiz.openSource.${q.item.id}')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      // Imtihon: shu tilda (AUTHORED) — natijada izoh shu tilda.
      await open(
        tester,
        Routes.studyQuiz(guidelineDeck, exam: true),
        lang: lang,
        catalog: catalog,
        size: const Size(320, 640),
      );
      for (var n = 0; n < 5; n++) {
        await tap(tester, 'study.quiz.option.1');
        await tap(tester, 'study.quiz.next');
      }
      expect(find.byKey(const Key('study.exam.percent')), findsOneWidget);
      expect(find.textContaining(explain), findsWidgets);
      expect(find.textContaining(correct), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('«To‘g‘ri / Noto‘g‘ri» savol (mos distraktor 3 tadan kam)', (
    tester,
  ) async {
    final catalog = StudyCatalogBuilder.build(
      library: TestLibrary([
        testSubstance('s1', formula: 'C1H4-T', group: 'small'),
        testSubstance('s2', formula: 'C2H6-T', group: 'small'),
      ]),
    );
    final deck = catalog.decks.single;
    final q = StudyQuizBuilder.build(deck, catalog, seed: 7).first;
    expect(q.isTrueFalse, isTrue);
    await open(
      tester,
      Routes.studyQuiz(deck.id),
      lang: 'uz',
      catalog: catalog,
      size: const Size(320, 640),
    );
    expect(find.text('Bu javob to‘g‘rimi?'), findsOneWidget);
    expect(find.byKey(const Key('study.quiz.proposed')), findsOneWidget);
    expect(find.text('To‘g‘ri'), findsOneWidget);
    expect(find.text('Noto‘g‘ri'), findsOneWidget);
    await tap(tester, 'study.quiz.option.${q.correctIndex}');
    await tap(tester, 'study.quiz.check');
    expect(find.byKey(const Key('study.quiz.feedback.ok')), findsOneWidget);
    expect(
      find.text('To‘g‘ri javob: ${q.item.answer.resolve('uz')}'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('qorong‘i rejim va o‘zbekcha: xatosiz chiziladi', (tester) async {
    await open(tester, Routes.study, theme: ThemeMode.dark, lang: 'uz');
    expect(find.text('O‘quv rejimi'), findsOneWidget);
    await tap(tester, 'study.quiz.$guidelineDeck');
    expect(find.textContaining('TEST mazmun g'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('noma’lum to‘plam — bo‘sh holat', (tester) async {
    await open(tester, Routes.studyCards('nope'));
    expect(find.byKey(const Key('study.deckNotFound')), findsOneWidget);
  });
}
