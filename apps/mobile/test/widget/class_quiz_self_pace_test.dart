import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/domain/ports/class_quiz_ports.dart';

import '../helpers/pump_app.dart';

class _FakeShare implements ClassFileShare {
  final shared = <({String name, String content})>[];

  @override
  Future<void> shareCsv({
    required String fileName,
    required String content,
    String? subject,
  }) async => shared.add((name: fileName, content: content));
}

/// “Server” va ikki ko‘rinish: ustoz (t1) va talaba (stu). Soat qo‘lda suriladi.
class _World {
  _World() {
    backend = FakeClassQuizBackend(
      clock: () => now,
      rng: Random(5),
      teachers: {'t1'},
    );
    teacher = FakeClassQuizService(backend, userId: 't1', demo: false);
    student = FakeClassQuizService(backend, userId: 'stu', demo: false);
  }

  var now = DateTime(2026, 10, 17, 10);
  late final FakeClassQuizBackend backend;
  late final FakeClassQuizService teacher;
  late final FakeClassQuizService student;
  final share = _FakeShare();

  void tick(int ms) => now = now.add(Duration(milliseconds: ms));
}

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

Future<void> _frames(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<ProviderContainer> _open(
  WidgetTester tester,
  _World w, {
  required ClassQuizService as,
  required String location,
  Size size = const Size(390, 844),
  Brightness brightness = Brightness.light,
}) async {
  final c = await pumpApp(
    tester,
    settings: completedSettings(lang: 'uz'),
    size: size,
    platformBrightness: brightness,
    overrides: [
      classQuizServiceProvider.overrideWithValue(as),
      classQuizPollIntervalProvider.overrideWithValue(
        const Duration(milliseconds: 100),
      ),
      classFileShareProvider.overrideWithValue(w.share),
      classScannerAvailableProvider.overrideWithValue(false),
      classLandscapePromptEnabledProvider.overrideWithValue(false),
    ],
  );
  c.read(routerProvider).go(location);
  await _frames(tester);
  return c;
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUpAll(() => testDefaultPlan = Plan.teacher);
  tearDownAll(() => testDefaultPlan = null);

  Future<ClassSessionInfo> createSelf(_World w) async =>
      (await w.teacher.createSession(
        topicId: 'demo-topic',
        settings: const ClassQuizSettings(
          questionCount: 5,
          studentLimit: 5,
          pace: ClassPace.self,
        ),
      )).value!;

  for (final size in const [Size(390, 844), Size(320, 640)]) {
    testWidgets('ustoz: rejim tanlovi ko‘rinadi, standart — ustoz boshqaradi; self tanlansa '
        'sessiya self bo‘ladi (${size.width.toInt()} dp)', (tester) async {
      final w = _World();
      await _open(
        tester,
        w,
        as: w.teacher,
        location: Routes.classNew,
        size: size,
      );
      final l = _l(tester);
      await tester.tap(find.byKey(const Key('class.topic.demo-topic')));
      await _frames(tester);
      await tester.ensureVisible(find.byKey(const Key('class.pace.self')));
      await tester.pump();
      expect(find.byKey(const Key('class.pace')), findsOneWidget);
      expect(find.text(l.classPaceHost), findsOneWidget);
      expect(find.text(l.classPaceSelf), findsOneWidget);
      // Har variant tagida bir qatorli izoh.
      expect(find.text(l.classPaceHostHint), findsOneWidget);
      expect(find.text(l.classPaceSelfHint), findsOneWidget);
      // Standart: ustoz boshqaradi (radio belgisi).
      Icon radio(String k) => tester.widget<Icon>(
        find.descendant(of: find.byKey(Key(k)), matching: find.byType(Icon)),
      );
      expect(radio('class.pace.host').icon, Icons.radio_button_checked);
      expect(radio('class.pace.self').icon, Icons.radio_button_unchecked);

      await tester.tap(find.byKey(const Key('class.pace.self')));
      await _frames(tester);
      expect(radio('class.pace.self').icon, Icons.radio_button_checked);
      await tester.ensureVisible(find.byKey(const Key('class.createSubmit')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('class.createSubmit')));
      await _frames(tester);
      final created = (await w.teacher.mySessions()).value!.single;
      expect(created.pace, ClassPace.self);
      expect(find.byKey(const Key('class.paceLine')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _close(tester);
    });
  }

  testWidgets('ustoz: standart rejimda sessiya host bo‘lib yaratiladi', (
    tester,
  ) async {
    final w = _World();
    await _open(tester, w, as: w.teacher, location: Routes.classNew);
    await tester.tap(find.byKey(const Key('class.topic.demo-topic')));
    await _frames(tester);
    await tester.ensureVisible(find.byKey(const Key('class.createSubmit')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('class.createSubmit')));
    await _frames(tester);
    expect((await w.teacher.mySessions()).value!.single.pace, ClassPace.host);
    expect(find.byKey(const Key('class.paceLine')), findsNothing);
    await _close(tester);
  });

  for (final size in const [Size(390, 844), Size(320, 640)]) {
    testWidgets('talaba (self): tanlov server\'ga tasdiqlamaguncha ketmaydi, avto-o\'tmaydi, '
        'o\'zi o\'tadi (${size.width.toInt()} dp)', (tester) async {
      final prevPlan = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prevPlan);
      final w = _World();
      final s = await createSelf(w);
      expect((await w.student.join(code: s.code, nickname: 'Ali')).ok, isTrue);
      await _open(
        tester,
        w,
        as: w.student,
        location: Routes.classPlay(s.id),
        size: size,
      );
      final l = _l(tester);
      // Ustoz boshlamaguncha — lobby va izoh.
      expect(find.byKey(const Key('class.lobby')), findsOneWidget);
      expect(find.byKey(const Key('class.lobbySelfHint')), findsOneWidget);
      await w.teacher.start(s.id);
      await _frames(tester);

      // Tayyor ekrani: savol matni yo‘q; «Boshlash» bosilganda taymer boshlanadi.
      expect(find.byKey(const Key('class.selfReady')), findsOneWidget);
      expect(find.byKey(const Key('class.question')), findsNothing);
      w.tick(90000); // 1.5 daqiqa kutdi: vaqt ketmaydi
      await tester.tap(find.byKey(const Key('class.selfStart')));
      await _frames(tester);
      expect(find.byKey(const Key('class.question')), findsOneWidget);
      expect(find.text(l.classQuestionOf(1, 5)), findsOneWidget);
      expect(find.byKey(const Key('class.flowHint')), findsOneWidget);
      expect(find.text(l.classAnswerFlowHint), findsOneWidget);
      expect(find.byKey(const Key('class.selfNext')), findsNothing);

      // Variantni tanlash — serverga ketmaydi.
      final q = (await w.student.state(s.id)).value!.question!;
      final correct = w.backend.debugCorrectOption(s.id, q.index);
      final wrong = q.options.firstWhere((o) => o.id != correct).id;
      await tester.tap(find.byKey(Key('class.option.$wrong')));
      await _frames(tester);
      expect((await w.student.state(s.id)).value!.myOption, isNull);
      // Vaqtdan oldin ham, o‘zi o‘tmaydi.
      w.tick(5000);
      await _frames(tester);
      expect(find.byKey(const Key('class.question')), findsOneWidget);
      expect((await w.student.state(s.id)).value!.myOption, isNull);

      // Tasdiqlash — endi serverda; to‘g‘ri javob ochiladi, «Keyingi» paydo bo‘ladi.
      await tester.ensureVisible(find.byKey(const Key('class.confirm')));
      await tester.tap(find.byKey(const Key('class.confirm')));
      await _frames(tester);
      expect((await w.student.state(s.id)).value!.myOption, wrong);
      expect(find.text(l.classResultWrong), findsOneWidget);
      expect(find.byKey(const Key('class.explanation')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('class.selfNext')));
      // Avto-o‘tish yo‘q: vaqt o‘tsa ham shu savolda turadi.
      w.tick(60000);
      await _frames(tester);
      expect(find.text(l.classQuestionOf(1, 5)), findsOneWidget);

      // O‘zi o‘tadi: yangi savol, yangi taymer, natija yo‘q.
      await tester.tap(find.byKey(const Key('class.selfNext')));
      await _frames(tester);
      expect(find.text(l.classQuestionOf(2, 5)), findsOneWidget);
      expect(find.byKey(const Key('class.explanation')), findsNothing);
      expect(find.byKey(const Key('class.selfNext')), findsNothing);
      expect((await w.student.state(s.id)).value!.remainingMs, 30000);
      expect(tester.takeException(), isNull);
      await _close(tester);
    });
  }

  testWidgets(
    'talaba (self): ikki talaba mustaqil — biri tez yechsa ikkinchisi kutmaydi',
    (tester) async {
      final prevPlan = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prevPlan);
      final w = _World();
      final s = await createSelf(w);
      final fast = FakeClassQuizService(w.backend, userId: 'fast', demo: false);
      await fast.join(code: s.code, nickname: 'Tez');
      await w.student.join(code: s.code, nickname: 'Sekin');
      await w.teacher.start(s.id);
      await _open(tester, w, as: w.student, location: Routes.classPlay(s.id));
      final l = _l(tester);
      await tester.tap(find.byKey(const Key('class.selfStart')));
      await _frames(tester);
      expect(find.text(l.classQuestionOf(1, 5)), findsOneWidget);
      // «Tez» barcha 5 savolni bir zumda yechib tugatadi.
      await fast.nextMine(s.id);
      for (var i = 0; i < 5; i++) {
        final q = (await fast.state(s.id)).value!.question!;
        await fast.submitAnswer(
          sessionId: s.id,
          questionIndex: q.index,
          optionId: w.backend.debugCorrectOption(s.id, q.index),
        );
        await fast.nextMine(s.id);
      }
      expect((await fast.state(s.id)).value!.selfStage, ClassSelfStage.done);
      await _frames(tester);
      // «Sekin» hamon 1-savolida, to‘liq 30 s vaqti bilan, hech narsa o‘zgarmadi.
      expect(find.text(l.classQuestionOf(1, 5)), findsOneWidget);
      expect(find.byKey(const Key('class.question')), findsOneWidget);
      expect((await w.student.state(s.id)).value!.remainingMs, 30000);
      expect(find.byKey(const Key('class.selfDone')), findsNothing);
      await _close(tester);
    },
  );

  testWidgets(
    'talaba (self): vaqt tugashi — javobsiz yopiladi, o‘zi o‘tadi; tugagach o‘z natijasi',
    (tester) async {
      final prevPlan = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prevPlan);
      final w = _World();
      final s = await createSelf(w);
      await w.student.join(code: s.code, nickname: 'Ali');
      await w.teacher.start(s.id);
      await _open(tester, w, as: w.student, location: Routes.classPlay(s.id));
      final l = _l(tester);
      for (var i = 0; i < 5; i++) {
        await tester.tap(
          find.byKey(Key(i == 0 ? 'class.selfStart' : 'class.selfNext')),
        );
        await _frames(tester);
        expect(find.text(l.classQuestionOf(i + 1, 5)), findsOneWidget);
        w.tick(32000); // vaqt tugadi
        await _frames(tester);
        expect(find.text(l.classResultNoAnswer), findsWidgets);
        expect(find.byKey(const Key('class.explanation')), findsOneWidget);
        await tester.ensureVisible(find.byKey(const Key('class.selfNext')));
      }
      // Oxirgi savolda tugma «Yakunlash».
      expect(find.text(l.classSelfFinish), findsOneWidget);
      await tester.tap(find.byKey(const Key('class.selfNext')));
      await _frames(tester);
      expect(find.byKey(const Key('class.selfDone')), findsOneWidget);
      expect(find.text(l.classSelfDoneTitle), findsOneWidget);
      expect(find.byKey(const Key('class.finalCorrect')), findsOneWidget);
      expect(find.byKey(const Key('class.mistake.0')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _close(tester);
    },
  );

  for (final size in const [Size(390, 844), Size(320, 640)]) {
    testWidgets(
      'ustoz doskasi (self): progress, reyting, tugatish (${size.width.toInt()} dp)',
      (tester) async {
        final w = _World();
        final s = await createSelf(w);
        final u1 = FakeClassQuizService(w.backend, userId: 'u1', demo: false);
        final u2 = FakeClassQuizService(w.backend, userId: 'u2', demo: false);
        final j1 = (await u1.join(code: s.code, nickname: 'Aziza')).value!;
        final j2 = (await u2.join(code: s.code, nickname: 'Bobur')).value!;
        await w.teacher.start(s.id);
        await u1.nextMine(s.id);
        final q = (await u1.state(s.id)).value!.question!;
        await u1.submitAnswer(
          sessionId: s.id,
          questionIndex: q.index,
          optionId: w.backend.debugCorrectOption(s.id, q.index),
        );
        await u1.nextMine(s.id);
        await _open(
          tester,
          w,
          as: w.teacher,
          location: Routes.classHost(s.id),
          size: size,
        );
        final l = _l(tester);
        expect(find.byKey(const Key('class.selfBoard')), findsOneWidget);
        // Shared «Keyingi savol» tugmalari yo‘q.
        expect(find.byKey(const Key('class.nextButton')), findsNothing);
        expect(find.byKey(const Key('class.closeButton')), findsNothing);
        expect(find.text(l.classBoardSummary(1, 0, 2)), findsOneWidget);
        expect(
          tester
              .widget<Text>(
                find.byKey(Key('class.progressStatus.${j1.participantId}')),
              )
              .data,
          l.classQuestionOf(2, 5),
        );
        expect(
          tester
              .widget<Text>(
                find.byKey(Key('class.progressStatus.${j2.participantId}')),
              )
              .data,
          l.classBoardNotStarted,
        );
        expect(
          find.byKey(Key('class.progressDetail.${j1.participantId}')),
          findsOneWidget,
        );
        expect(
          find.byKey(Key('class.boardRank.${j1.participantId}')),
          findsOneWidget,
        );
        // Hamma tugatmaguncha banner yo‘q; tugatish tasdiq bilan.
        expect(find.byKey(const Key('class.boardAllDone')), findsNothing);
        await tester.ensureVisible(
          find.byKey(const Key('class.endSelfButton')),
        );
        await tester.tap(find.byKey(const Key('class.endSelfButton')));
        await _frames(tester);
        await tester.tap(find.byKey(const Key('class.confirmYes')));
        await _frames(tester);
        expect(
          (await w.teacher.mySessions()).value!.single.status,
          ClassSessionStatus.finished,
        );
        expect(tester.takeException(), isNull);
        await _close(tester);
      },
    );
  }
}
