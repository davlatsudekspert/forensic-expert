import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_bank.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_demo_bank.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';

import '../helpers/pump_app.dart';

/// Sinfda test: haqiqiy savollar banki (slides-out `quiz/*.json` →
/// `tools/class_quiz/import_quiz_bank.py` → ilova asseti), kurs/fan
/// guruhlari, qidiruv, uch til va manba qatori.
void main() {
  final raw = File(classQuizBankAsset).readAsStringSync();
  final bank = ClassQuizBank.parse(raw);

  group('bank asseti', () {
    test('mavzular uch tilda, har savol manba + bet bilan', () {
      expect(bank.topics.length, greaterThanOrEqualTo(18));
      expect(bank.groups, isNotEmpty);
      expect(bank.variants.length, bank.topics.length * 3);
      for (final v in bank.variants) {
        expect(v.isDemo, isFalse);
        expect(v.questions.length, greaterThanOrEqualTo(5), reason: v.id);
        for (final q in v.questions) {
          expect(q.options, hasLength(4));
          expect(q.source.author, isNotEmpty);
          expect(q.source.title, isNotEmpty);
          // «-- bet» kabi bo‘sh bet yo‘q.
          expect(q.source.cleanPage, isNotNull, reason: v.id);
          expect(q.explanation, isNotEmpty);
        }
      }
      // ru/en — avtomatik tarjima belgisi saqlangan; uz — asl.
      final uz = bank.variants.firstWhere((v) => v.id == '4-kurs-davolash-10');
      final ru = bank.variants.firstWhere(
        (v) => v.id == '4-kurs-davolash-10~ru',
      );
      expect(uz.questions.first.source.isMachineTranslation, isFalse);
      expect(ru.questions.first.source.isMachineTranslation, isTrue);
      expect(ru.title, isNot(uz.title));
      // Har mavzu guruhga tegishli.
      for (final t in bank.topics) {
        expect(bank.group(t.groupId), isNotNull, reason: t.id);
      }
    });

    test('DEMO to‘plam faqat includeDemo (debug/test) bo‘lsa', () {
      final release = classQuizLocalTopics(bank, includeDemo: false);
      expect(release.any((t) => t.isDemo), isFalse);
      expect(release.any((t) => t.id == classQuizDemoTopic.id), isFalse);
      final debug = classQuizLocalTopics(bank, includeDemo: true);
      expect(debug.first.id, classQuizDemoTopic.id);
    });

    test('manba beti: «-»/«--» bo‘sh, raqam va joy ajratiladi', () {
      expect(const ClassSource(page: '--').cleanPage, isNull);
      expect(const ClassSource(page: ' - ').cleanPage, isNull);
      expect(const ClassSource(page: '263').pageIsNumeric, isTrue);
      expect(const ClassSource(page: '12–23').pageIsNumeric, isTrue);
      expect(const ClassSource(page: 'I bob, 1.4').pageIsNumeric, isFalse);
    });
  });

  group('ustoz: mavzu tanlash (guruhlangan, qidiruvli)', () {
    FakeClassQuizBackend world() => FakeClassQuizBackend(
      clock: () => DateTime(2026, 10, 17, 10),
      rng: Random(3),
      teachers: {'t1'},
      topics: const [],
      topicLoader: () async => bank.variants,
    );

    Future<void> open(
      WidgetTester tester,
      FakeClassQuizService svc, {
      String lang = 'uz',
    }) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(lang: lang),
        overrides: [
          classQuizServiceProvider.overrideWithValue(svc),
          classQuizBankLoaderProvider.overrideWithValue(() async => raw),
          classScannerAvailableProvider.overrideWithValue(false),
          classQuizPollIntervalProvider.overrideWithValue(
            const Duration(milliseconds: 100),
          ),
        ],
      );
      c.read(routerProvider).go(Routes.classNew);
      await tester.pumpAndSettle();
    }

    testWidgets('uz: guruhlar, qidiruv → mavzu → sinf yaratiladi', (
      tester,
    ) async {
      final backend = world();
      final svc = FakeClassQuizService(backend, userId: 't1', demo: false);
      await open(tester, svc);
      final l = lookupAppLocalizations(const Locale('uz'));
      // Kurs/fan guruhlari (yopiq) — sarlavhalar ko‘rinadi.
      expect(
        find.text('Sud tibbiyoti · 4-kurs, davolash ishi'),
        findsOneWidget,
      );
      expect(find.text('Bioetika · 2-kurs'), findsOneWidget);
      expect(find.text(l.classDemoChip), findsNothing);
      // Til variantlari bitta qatorga yig‘ilgan: ru/en kartasi yo‘q.
      await tester.enterText(
        find.byKey(const Key('class.topicSearch')),
        'toksik',
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('class.topic.4-kurs-davolash-10')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('class.topic.4-kurs-davolash-10~ru')),
        findsNothing,
      );
      // Mavzuga aloqasiz qidiruv — tushunarli bo‘sh holat.
      await tester.enterText(
        find.byKey(const Key('class.topicSearch')),
        'zzqxw',
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('class.topicNoMatch')), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('class.topicSearch')),
        'toksik',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('class.topic.4-kurs-davolash-10')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('class.selectedTopic')), findsOneWidget);
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const Key('class.createSubmit'))),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('class.createSubmit')));
      await tester.pump(const Duration(milliseconds: 300));
      final s = (await svc.mySessions()).value!.single;
      expect(s.topicId, '4-kurs-davolash-10');
      expect(s.topicTitle, contains('toksikologiya'));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('ru: ruscha variant va «Автоматический перевод» belgisi', (
      tester,
    ) async {
      final backend = world();
      final svc = FakeClassQuizService(backend, userId: 't1', demo: false);
      await open(tester, svc, lang: 'ru');
      final l = lookupAppLocalizations(const Locale('ru'));
      await tester.enterText(
        find.byKey(const Key('class.topicSearch')),
        'токсик',
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('class.topic.4-kurs-davolash-10~ru')),
        findsOneWidget,
      );
      expect(find.text(l.trStatusMachineDraft), findsWidgets);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
