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
import 'package:forensic_expert/domain/grading/grade_scale.dart';
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
  testWidgets('hub: noto‘g‘ri kod tushunarli xato beradi; ustoz bo‘limi yo‘q', (
    tester,
  ) async {
    final w = _World();
    await _open(tester, w, as: w.student, location: Routes.classQuiz);
    final l = _l(tester);
    expect(find.byKey(const Key('class.codeField')), findsOneWidget);
    expect(find.byKey(const Key('class.newButton')), findsNothing);
    expect(find.byKey(const Key('class.notTeacherNote')), findsOneWidget);
    expect(find.byKey(const Key('class.scanButton')), findsNothing);
    await tester.enterText(find.byKey(const Key('class.codeField')), '12');
    await tester.tap(find.byKey(const Key('class.joinButton')));
    await _frames(tester);
    expect(find.text(l.classErrBadCode), findsOneWidget);
    await _close(tester);
  });

  testWidgets('rol: ustoz bo‘lmagan ustoz ekranlarini ko‘rmaydi', (
    tester,
  ) async {
    final w = _World();
    await _open(tester, w, as: w.student, location: Routes.classNew);
    expect(find.byKey(const Key('class.forbidden')), findsOneWidget);
    expect(find.byKey(const Key('class.createSubmit')), findsNothing);
    await _close(tester);
    // Boshqaruv ekrani ham yopiq.
    final w2 = _World();
    await _open(tester, w2, as: w2.student, location: Routes.classHost('s-1'));
    expect(find.byKey(const Key('class.forbidden')), findsOneWidget);
    expect(find.byKey(const Key('class.startButton')), findsNothing);
    await _close(tester);
  });

  testWidgets('ustoz: hubda yangi test tugmasi bor', (tester) async {
    final w = _World();
    await _open(tester, w, as: w.teacher, location: Routes.classQuiz);
    expect(find.byKey(const Key('class.newButton')), findsOneWidget);
    await _close(tester);
  });

  testWidgets(
    'TO‘LIQ OQIM (ustoz UI): yaratish → talaba → savol → natija → CSV',
    (tester) async {
      final w = _World();
      await _open(tester, w, as: w.teacher, location: Routes.classNew);
      final l = _l(tester);

      // Mavzu tanlash va yaratish.
      await tester.tap(find.byKey(const Key('class.topic.demo-topic')));
      await _frames(tester);
      await tester.tap(find.byKey(const Key('class.seconds')).first);
      await tester.ensureVisible(find.byKey(const Key('class.createSubmit')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('class.createSubmit')));
      await _frames(tester);

      // Lobby: katta kod va QR.
      expect(find.byKey(const Key('class.code')), findsOneWidget);
      expect(find.byKey(const Key('class.qr')), findsOneWidget);
      final sessionId = (await w.teacher.mySessions()).value!.single.id;
      final code = (await w.teacher.mySessions()).value!.single.code;
      final shown = tester.widget<Text>(find.byKey(const Key('class.code')));
      expect(shown.data, ClassCode.display(code));
      expect(
        find.text('forensicexpert://app/join/$code'),
        findsOneWidget,
        reason: 'QR ichidagi havola ekranda ham ko‘rinadi',
      );
      expect(find.text(l.classJoinedCount(0, 30)), findsOneWidget);
      // Hech kim yo‘q bo‘lsa — boshlab bo‘lmaydi.
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('class.startButton')))
            .onPressed,
        isNull,
      );

      // Talaba qo‘shiladi (boshqa qurilma).
      final join = await w.student.join(code: code, nickname: 'Ali');
      expect(join.ok, isTrue);
      await _frames(tester);
      expect(find.text(l.classJoinedCount(1, 30)), findsOneWidget);
      expect(find.text('Ali'), findsOneWidget);

      // Boshlash.
      await tester.tap(find.byKey(const Key('class.startButton')));
      await _frames(tester);
      expect(find.byKey(const Key('class.hostQuestion')), findsOneWidget);
      expect(find.text(l.classAnswered(0, 1)), findsOneWidget);

      // Talaba to‘g‘ri javob beradi; panel jonli yangilanadi.
      final cur = (await w.teacher.dashboard(sessionId)).value!.current!;
      await w.student.submitAnswer(
        sessionId: sessionId,
        questionIndex: 0,
        optionId: cur.correctOption,
      );
      await _frames(tester);
      expect(find.text(l.classAnswered(1, 1)), findsOneWidget);
      // Proyektorda ochiq savol paytida to‘g‘ri javob ko‘rsatilmaydi.
      expect(find.byKey(const Key('class.correctPct')), findsNothing);
      expect(find.text(l.classOptionCorrect), findsNothing);

      // Savolni yopish: natija va foiz ochiladi.
      await tester.tap(find.byKey(const Key('class.closeButton')));
      await _frames(tester);
      expect(find.byKey(const Key('class.correctPct')), findsOneWidget);
      expect(find.text(l.classCorrectPct(100)), findsOneWidget);

      // Qolgan savollar (sukut bo‘yicha 10 ta): oxirgisida tugma “yakunlash”.
      var guard = 0;
      while (find.text(l.classFinishAction).evaluate().isEmpty &&
          guard++ < 15) {
        await tester.tap(find.byKey(const Key('class.nextButton')));
        await _frames(tester);
      }
      expect(find.text(l.classFinishAction), findsOneWidget);
      await tester.tap(find.byKey(const Key('class.nextButton')));
      await _frames(tester);

      // Yakun: reyting, eng qiyin savol va CSV.
      expect(find.byKey(const Key('class.finishedTitle')), findsOneWidget);
      expect(find.byKey(const Key('class.finalBoard')), findsOneWidget);
      // Ustoz natijasi: 100 ballik ball + taxminiy baho (1/10 → 10.0), reyting
      // va tezlik ballari o‘zgarmagan; taxminiy baho izohi bir marta.
      expect(find.byKey(const Key('class.scoreApproxNote')), findsOneWidget);
      expect(
        find.text(l.scoringRowLine('10.0', l.scoringGradeBelowMin)),
        findsOneWidget,
      );
      expect(find.textContaining('qarzdor'), findsNothing);
      await tester.ensureVisible(find.byKey(const Key('class.exportButton')));
      await tester.tap(find.byKey(const Key('class.exportButton')));
      await _frames(tester);
      final file = w.share.shared.single;
      expect(
        file.name,
        matches(RegExp(r'^guruh_test_[0-9]{6}_\d{4}-\d{2}-\d{2}\.csv$')),
      );
      expect(
        file.content.split('\r\n').first,
        'laqab,ball,togri_soni,javob_vaqti_s,Ball (100),Baho',
      );
      expect(file.content, contains('Ali,1000,1,'));
      expect(file.content, contains(',10.0,${l.scoringGradeBelowMin}'));
      expect(file.content.contains('@'), isFalse);
      await _close(tester);
    },
  );

  testWidgets(
    'TO‘LIQ OQIM (talaba UI): kod → laqab → savol → natija → izoh+manba',
    (tester) async {
      final prevPlan = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prevPlan);
      final w = _World();
      final session = (await w.teacher.createSession(
        topicId: 'demo-topic',
        settings: const ClassQuizSettings(questionCount: 5, studentLimit: 5),
      )).value!;
      await _open(
        tester,
        w,
        as: w.student,
        location: Routes.classJoinWith(session.code),
      );
      final l = _l(tester);

      // Kod oldindan to‘ldirilgan; noto‘g‘ri laqab rad etiladi.
      expect(find.text(ClassCode.display(session.code)), findsNothing);
      await tester.enterText(find.byKey(const Key('class.nickField')), 'Sh1t');
      await tester.tap(find.byKey(const Key('class.joinSubmit')));
      await _frames(tester);
      expect(find.text(l.classErrNickBlocked), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('class.nickField')),
        'Gulnora',
      );
      await tester.tap(find.byKey(const Key('class.joinSubmit')));
      await _frames(tester);
      expect(find.byKey(const Key('class.lobby')), findsOneWidget);
      expect(find.text(l.classLobbyWelcome('Gulnora')), findsOneWidget);

      // Ustoz boshlaydi.
      await w.teacher.start(session.id);
      await _frames(tester);
      expect(find.byKey(const Key('class.question')), findsOneWidget);
      expect(find.text(l.classChooseAnswer), findsOneWidget);
      expect(find.byKey(const Key('class.explanation')), findsNothing);

      // Ustoz to‘g‘ri variantni biladi, talaba — yo‘q: birinchi ko‘ringanini bosadi.
      final cur = (await w.teacher.dashboard(session.id)).value!.current!;
      final wrong = cur.options.firstWhere((o) => o.id != cur.correctOption).id;
      await tester.tap(find.byKey(Key('class.option.$wrong')));
      await _frames(tester);
      // Selection remains editable and has not reached the server.
      expect((await w.student.state(session.id)).value!.myOption, isNull);
      await tester.tap(find.byKey(Key('class.option.${cur.correctOption}')));
      await _frames(tester);
      await tester.tap(find.byKey(Key('class.option.$wrong')));
      await _frames(tester);
      await tester.ensureVisible(find.byKey(const Key('class.confirm')));
      await tester.tap(find.byKey(const Key('class.confirm')));
      await _frames(tester);
      expect(find.text(l.classAnswerAccepted), findsOneWidget);
      // Ikkinchi marta bosib bo‘lmaydi (tugma o‘chiq), to‘g‘ri javob hali yo‘q.
      expect(find.text(l.classOptionCorrect), findsNothing);

      // Vaqt tugaydi (server soati) → to‘g‘ri javob va izoh ochiladi.
      w.tick(32000);
      await _frames(tester);
      expect(find.byKey(const Key('class.explanation')), findsOneWidget);
      expect(find.text(l.classResultWrong), findsOneWidget);

      // Qolgan savollar javobsiz o‘tadi; ustoz yakunlaydi.
      await w.teacher.finish(session.id);
      await _frames(tester);
      expect(find.byKey(const Key('class.summary')), findsOneWidget);
      expect(find.text(l.classScoreLine(0)), findsOneWidget);
      // 100 ballik natija va taxminiy baho (0/5 → 0.0): tezlik balli ham qoladi.
      expect(find.byKey(const Key('score100.block')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('score100.value'))).data,
        '0.0',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('score100.grade'))).data,
        l.scoringGradeBelowMin,
      );
      expect(
        find.text(l.scoringGradeApproxTitle(GradeScale.academicYear)),
        findsOneWidget,
      );
      expect(find.byKey(const Key('score100.note')), findsOneWidget);
      expect(find.textContaining('qarzdor'), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('class.mistake.0')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('class.mistake.0')), findsOneWidget);
      expect(find.byKey(const Key('class.source.0')), findsOneWidget);
      expect(find.textContaining('DEMO'), findsWidgets);
      // DEMO manbasining beti «-» — «--bet» / «- bet» kabi bo‘sh qiymat
      // ko‘rsatilmaydi.
      final src = tester
          .widget<Text>(find.byKey(const Key('class.source.0')))
          .data!;
      expect(src, isNot(contains('-bet')));
      expect(src, isNot(contains('- bet')));
      await _close(tester);
    },
  );

  testWidgets('qo‘shilish: hisobsiz bo‘lsa avval kirish kartasi', (
    tester,
  ) async {
    final prevPlan = testDefaultPlan;
    testDefaultPlan = Plan.student;
    addTearDown(() => testDefaultPlan = prevPlan);
    final w = _World();
    final strict = FakeClassQuizService(
      w.backend,
      userId: 'stu',
      demo: false,
      signInRequired: true,
    );
    await _open(
      tester,
      w,
      as: strict,
      location: Routes.classJoinWith('123456'),
    );
    expect(find.byKey(const Key('class.signInCard')), findsOneWidget);
    expect(find.byKey(const Key('class.nickField')), findsNothing);
    await _close(tester);
  });

  for (final cfg in [
    (name: '320 dp qorong‘i', size: const Size(320, 640), dark: true),
    (
      name: 'proyektor 16:9 landshaft',
      size: const Size(1280, 720),
      dark: false,
    ),
  ]) {
    testWidgets('ustoz ekrani overflowsiz: ${cfg.name}', (tester) async {
      final w = _World();
      final s = (await w.teacher.createSession(
        topicId: 'demo-topic',
        settings: const ClassQuizSettings(questionCount: 5, studentLimit: 5),
      )).value!;
      for (var i = 0; i < 4; i++) {
        await w.student.join(code: s.code, nickname: 'Talaba$i');
        // bitta foydalanuvchi — qayta kirish; boshqa id kerak:
      }
      for (var i = 0; i < 5; i++) {
        await FakeClassQuizService(
          w.backend,
          userId: 'u$i',
          demo: false,
        ).join(code: s.code, nickname: 'Uzunlaqabli talaba $i');
      }
      await _open(
        tester,
        w,
        as: w.teacher,
        location: Routes.classHost(s.id),
        size: cfg.size,
        brightness: cfg.dark ? Brightness.dark : Brightness.light,
      );
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('class.code')), findsOneWidget);
      if (cfg.size.width < 600) {
        await tester.scrollUntilVisible(
          find.byKey(const Key('class.startButton')),
          300,
          scrollable: find.byType(Scrollable).first,
        );
      }
      await tester.tap(find.byKey(const Key('class.startButton')));
      await _frames(tester);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('class.hostQuestion')), findsOneWidget);
      await _close(tester);
    });
  }

  testWidgets('talaba savol ekrani 320 dp va qorong‘i rejimda overflowsiz', (
    tester,
  ) async {
    final prevPlan = testDefaultPlan;
    testDefaultPlan = Plan.student;
    addTearDown(() => testDefaultPlan = prevPlan);
    final w = _World();
    final s = (await w.teacher.createSession(
      topicId: 'demo-topic',
      settings: const ClassQuizSettings(questionCount: 5, studentLimit: 5),
    )).value!;
    await w.student.join(code: s.code, nickname: 'Ali');
    await w.teacher.start(s.id);
    final c = await _open(
      tester,
      w,
      as: w.student,
      location: Routes.classPlay(s.id),
      size: const Size(320, 640),
      brightness: Brightness.dark,
    );
    expect(c, isNotNull);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('class.question')), findsOneWidget);
    await _close(tester);
  });

  testWidgets('deep link /join/<kod> qo‘shilish ekraniga olib boradi', (
    tester,
  ) async {
    final prevPlan = testDefaultPlan;
    testDefaultPlan = Plan.student;
    addTearDown(() => testDefaultPlan = prevPlan);
    final w = _World();
    final c = await _open(tester, w, as: w.student, location: '/join/123456');
    expect(find.byKey(const Key('class.nickField')), findsOneWidget);
    expect(c.read(pendingClassCodeProvider), '123456');
    await _close(tester);
  });
}
