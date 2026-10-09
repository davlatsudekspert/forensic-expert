import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Future<InMemoryStudyProgressStore> open(
    WidgetTester tester,
    String route, {
    Map<String, LeitnerCard>? progress,
    ThemeMode theme = ThemeMode.light,
    String lang = 'en',
    bool fixtures = true,
  }) async {
    final store = InMemoryStudyProgressStore(progress);
    await pumpApp(
      tester,
      settings: completedSettings(
        lang: lang,
        theme: theme,
        mode: UserMode.student,
      ),
      initialLocation: route,
      testFixtures: fixtures,
      overrides: [
        studyCatalogProvider.overrideWithValue(testStudyCatalog()),
        studyProgressStoreProvider.overrideWithValue(store),
        studyClockProvider.overrideWithValue(() => now),
        studySeedProvider.overrideWithValue(() => 7),
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
    expect(
      find.byKey(const Key('study.deck.guideline.forensicChemistry')),
      findsOneWidget,
    );
    expect(find.text('4 cards'), findsOneWidget);
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

    // Yana bosilsa — old tomonga qaytadi.
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

  testWidgets('test: javob berish, natija va xatolar tahlili', (tester) async {
    final catalog = testStudyCatalog();
    final questions = StudyQuizBuilder.build(
      catalog.deck(substanceDeck)!,
      catalog,
      seed: 7,
    );
    expect(questions, hasLength(3));
    await open(tester, Routes.studyQuiz(substanceDeck));
    expect(find.text('Question 1 of 3'), findsOneWidget);

    for (final (n, q) in questions.indexed) {
      expect(
        find.text(
          'What is the molecular formula of '
          '${q.item.prompt.resolve('en')}?',
        ),
        findsOneWidget,
      );
      // Birinchi savolda ataylab xato javob.
      final pick = n == 0 ? (q.correctIndex + 1) % 3 : q.correctIndex;
      await tap(tester, 'study.quiz.option.$pick');
      await tap(tester, 'study.quiz.check');
      expect(
        find.byKey(Key('study.quiz.feedback.${n == 0 ? 'wrong' : 'ok'}')),
        findsOneWidget,
      );
      expect(find.byKey(Key('study.source.${q.item.id}.0')), findsOneWidget);
      await tap(tester, 'study.quiz.next');
    }

    expect(find.text('Score: 2 of 3'), findsOneWidget);
    expect(find.byKey(const Key('study.quiz.mistake.0')), findsOneWidget);
    final first = questions.first;
    expect(
      find.text('Correct answer: ${first.item.answer.resolve('en')}'),
      findsOneWidget,
    );
    expect(find.byKey(Key('study.openEntry.${first.item.id}')), findsOneWidget);

    await tap(tester, 'study.quiz.retry');
    expect(find.text('Question 1 of 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('qorong‘i rejim va o‘zbekcha: xatosiz chiziladi', (tester) async {
    await open(tester, Routes.study, theme: ThemeMode.dark, lang: 'uz');
    expect(find.text('O‘quv rejimi'), findsOneWidget);
    await tap(tester, 'study.quiz.guideline.forensicChemistry');
    expect(
      find.text('TEST mazmun g1').evaluate().isNotEmpty ||
          find.text('TEST mazmun g2').evaluate().isNotEmpty,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('noma’lum to‘plam — bo‘sh holat', (tester) async {
    await open(tester, Routes.studyCards('nope'));
    expect(find.byKey(const Key('study.deckNotFound')), findsOneWidget);
  });
}
