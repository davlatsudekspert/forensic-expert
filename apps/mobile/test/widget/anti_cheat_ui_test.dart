// Anti-cheat paketi (2026-10-31) — ekran testlari (Fake backend):
//  * ilova fonga o‘tganda «chiqdi» xabari (guruh testi va jonli sinf);
//  * ustoz ekranida «ilovadan chiqdi: N marta» va betaraf «tez va to‘g‘ri»;
//  * savol soni ogohlantirishi + «variantlar aralashadi» izohi;
//  * jonli sinfda erkin soniya (5..300).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/features/anti_cheat/presentation/anti_cheat_widgets.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/pump_app.dart' show testDefaultPlan;

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

void _background(WidgetTester tester) {
  final b = tester.binding;
  b.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  b.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  b.handleAppLifecycleStateChanged(AppLifecycleState.paused);
}

void _foreground(WidgetTester tester) {
  final b = tester.binding;
  b.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  b.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  b.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
}

final _fastPoll = [
  classQuizPollIntervalProvider.overrideWithValue(
    const Duration(milliseconds: 100),
  ),
];

void main() {
  setUp(() {
    floatingNavEnabled = true;
  });

  group('LeaveReporter', () {
    testWidgets(
      'hidden+paused = bir hisob; inactive sanalmaydi; qaytgach yana',
      (tester) async {
        var n = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: LeaveReporter(
              enabled: true,
              onLeave: () async => n++,
              child: const SizedBox(),
            ),
          ),
        );
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        expect(n, 0, reason: 'tizim oynasi/bildirishnoma — chiqish emas');
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        expect(n, 0);
        _background(tester);
        expect(n, 1, reason: 'hidden va paused ikki marta sanalmaydi');
        _foreground(tester);
        _background(tester);
        expect(n, 2);
      },
    );

    testWidgets('enabled=false bo‘lsa va xato bo‘lsa — jim', (tester) async {
      var n = 0;
      Widget app(bool enabled, Future<void> Function() f) => MaterialApp(
        home: LeaveReporter(
          enabled: enabled,
          onLeave: f,
          child: const SizedBox(),
        ),
      );
      await tester.pumpWidget(app(false, () async => n++));
      _background(tester);
      expect(n, 0);
      _foreground(tester);
      await tester.pumpWidget(
        app(true, () async => throw StateError('tarmoq')),
      );
      _background(tester); // xato yutiladi
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('guruh testi', () {
    Future<({String gid, String aid})> setup(GroupsWorld w) async {
      final g = w.backend.create('teacher', 'Guruh').value!;
      for (final (i, s) in ['stu1', 'stu2', 'stu3'].indexed) {
        w.backend.join(s, code: g.code!, nickname: 'Talaba ${i + 1}');
      }
      final a = (await w.backend.createAssignment(
        'teacher',
        g.id,
        const AssignmentDraft(
          topicId: 'tox-co',
          questionCount: 5,
          timeLimitMin: 15,
          variantMode: false,
        ),
      )).value!;
      return (gid: g.id, aid: a.id);
    }

    testWidgets('talaba fonga o‘tdi → ustoz panelida «chiqdi: N marta»; '
        'tez va to‘g‘ri belgisi betaraf matn bilan', (tester) async {
      final prev = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prev);
      final w = GroupsWorld();
      final s = await setup(w);

      // stu1: testni ochadi va ikki marta ilovadan chiqadi.
      await w.open(
        tester,
        uid: 'stu1',
        location: Routes.groupTest(s.gid, s.aid),
      );
      expect(find.byKey(const Key('ac.studentNote')), findsOneWidget);
      _background(tester);
      await frames(tester, 2);
      _foreground(tester);
      w.now = w.now.add(const Duration(seconds: 3));
      _background(tester);
      await frames(tester, 2);
      _foreground(tester);
      // Talabaga hech qanday xabar/snackbar ko‘rinmaydi.
      expect(find.byType(SnackBar), findsNothing);
      await closeApp(tester);

      // stu2: 5 ta savolga 3 soniyada hammasini TO‘G‘RI yuboradi (tez).
      final att = w.backend.open('stu2', s.aid).value!;
      final pool = w.backend.preview('teacher', s.aid).value!.pool;
      final answers = {
        for (final q in att.questions)
          q.id: pool.firstWhere((p) => p.id == q.id).correctIndex,
      };
      w.now = w.now.add(const Duration(seconds: 3));
      w.backend.submit('stu2', s.aid, answers);
      // stu3: shuncha vaqt sarflaydi (sekin) — belgi yo‘q.
      final att3 = w.backend.open('stu3', s.aid).value!;
      w.now = w.now.add(const Duration(minutes: 3));
      w.backend.submit('stu3', s.aid, {
        for (final q in att3.questions)
          q.id: pool.firstWhere((p) => p.id == q.id).correctIndex,
      });

      final rows = w.backend.board('teacher', s.aid).value!.rows;
      String idOf(String nick) =>
          rows.firstWhere((r) => r.nickname == nick).memberId;

      await w.open(
        tester,
        uid: 'teacher',
        location: Routes.groupAssignment(s.gid, s.aid),
      );
      await frames(tester);
      final l = _l(tester);
      final leave = find.byKey(Key('ac.leave.${idOf('Talaba 1')}'));
      expect(leave, findsOneWidget);
      expect(
        find.descendant(of: leave, matching: find.text(l.acLeftCount(2))),
        findsOneWidget,
      );
      expect(find.byKey(Key('ac.leave.${idOf('Talaba 2')}')), findsNothing);
      // Tez va to‘g‘ri: faqat stu2 da; matn betaraf, ayblov yo‘q.
      final fast = find.byKey(Key('ac.fast.${idOf('Talaba 2')}'));
      expect(fast, findsOneWidget);
      expect(find.byKey(Key('ac.fast.${idOf('Talaba 3')}')), findsNothing);
      expect(find.byKey(Key('ac.fast.${idOf('Talaba 1')}')), findsNothing);
      expect(l.acFastCorrect, 'tez va to‘g‘ri javob — tekshirib ko‘ring');
      expect(l.acFastCorrect.toLowerCase(), isNot(contains('aldov')));
      expect(l.acFastCorrect.toLowerCase(), isNot(contains('ko‘chir')));
      await closeApp(tester);
    });

    testWidgets('test yuborilgach fonga o‘tish sanalmaydi', (tester) async {
      final prev = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prev);
      final w = GroupsWorld();
      final s = await setup(w);
      await w.open(
        tester,
        uid: 'stu1',
        location: Routes.groupTest(s.gid, s.aid),
      );
      w.backend.submit('stu1', s.aid, const {});
      w.now = w.now.add(const Duration(seconds: 3));
      _background(tester);
      await frames(tester, 2);
      final row = w.backend
          .board('teacher', s.aid)
          .value!
          .rows
          .firstWhere((r) => r.nickname == 'Talaba 1');
      expect(row.leaveCount, 0);
      _foreground(tester);
      await closeApp(tester);
    });

    testWidgets('yaratishda: kichik hovuz — ogohlantirish, katta — yo‘q; '
        'variantlar aralashishi izohi doim ko‘rinadi', (tester) async {
      final prev = testDefaultPlan;
      testDefaultPlan = Plan.teacher;
      addTearDown(() => testDefaultPlan = prev);
      final w = GroupsWorld();
      final g = w.backend.create('teacher', 'Guruh').value!;
      await w.open(tester, uid: 'teacher', location: Routes.groupAssign(g.id));
      await frames(tester);
      // 24 savolli mavzu, standart 10 ta: 24 >= 20 — ogohlantirish yo‘q.
      await tester.tap(find.byKey(const Key('grp.topic.tox-co')));
      await frames(tester);
      expect(find.byKey(const Key('ac.shuffleHint')), findsOneWidget);
      expect(find.byKey(const Key('ac.countWarning')), findsNothing);
      // 15 ta: 24 < 30 — ogohlantirish, tavsiya 12.
      await tester.ensureVisible(find.byKey(const Key('grp.count.15')));
      await tester.tap(find.byKey(const Key('grp.count.15')));
      await frames(tester);
      final l = _l(tester);
      expect(find.byKey(const Key('ac.countWarning')), findsOneWidget);
      expect(
        find.textContaining(l.acCountWarning(24, 15, 12), findRichText: true),
        findsOneWidget,
      );
      expect(find.byKey(const Key('ac.shuffleHint')), findsOneWidget);
      await closeApp(tester);
    });
  });

  group('jonli sinf', () {
    late DateTime now;
    late GroupsWorld w;
    late FakeClassQuizBackend backend;
    late FakeClassQuizService teacher;
    late FakeClassQuizService fast;
    late FakeClassQuizService slow;

    FakeClassQuizService svc(String id) =>
        FakeClassQuizService(backend, userId: id, demo: false);

    setUp(() {
      now = DateTime(2026, 10, 31, 10);
      w = GroupsWorld(quizClock: () => now);
      backend = w.quiz;
      teacher = svc('teacher');
      fast = svc('fast');
      slow = svc('slow');
    });

    void tick(int ms) => now = now.add(Duration(milliseconds: ms));

    Future<ClassSessionInfo> create() async => (await teacher.createSession(
      topicId: 'tox-co',
      settings: const ClassQuizSettings(questionCount: 5, studentLimit: 5),
    )).value!;

    testWidgets('talaba fonga o‘tdi → ustoz hisobida leave_count', (
      tester,
    ) async {
      final prev = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prev);
      final s = await create();
      await fast.join(code: s.code, nickname: 'Ali');
      await teacher.start(s.id);
      await w.open(
        tester,
        uid: 'fast',
        location: Routes.classPlay(s.id),
        extra: _fastPoll,
      );
      _background(tester);
      await frames(tester, 2);
      final d = (await teacher.dashboard(s.id)).value!;
      expect(d.participants.single.leaveCount, 1);
      _foreground(tester);
      await closeApp(tester);
    });

    testWidgets('yakuniy natija: tez/to‘g‘ri belgisi faqat kerakli talabada, '
        'chiqish soni ko‘rinadi', (tester) async {
      final prev = testDefaultPlan;
      testDefaultPlan = Plan.teacher;
      addTearDown(() => testDefaultPlan = prev);
      final s = await create();
      final fastJoin = (await fast.join(
        code: s.code,
        nickname: 'Tezkor',
      )).value!;
      final slowJoin = (await slow.join(
        code: s.code,
        nickname: 'Sekin',
      )).value!;
      await teacher.start(s.id);
      for (var i = 0; i < 5; i++) {
        final correct = backend.debugCorrectOption(s.id, i);
        tick(1000); // tezkor: 1 s da to‘g‘ri
        await fast.submitAnswer(
          sessionId: s.id,
          questionIndex: i,
          optionId: correct,
        );
        tick(14000); // sekin: 15 s da to‘g‘ri
        await slow.submitAnswer(
          sessionId: s.id,
          questionIndex: i,
          optionId: correct,
        );
        if (i == 2) {
          // Sekin talaba test o‘rtasida ilovadan 2 marta chiqdi.
          await slow.reportLeave(s.id);
          tick(2000);
          await slow.reportLeave(s.id);
        }
        tick(20000);
        await teacher.next(s.id);
      }
      final dash = (await teacher.dashboard(s.id)).value!;
      expect(dash.session.status, ClassSessionStatus.finished);
      await w.open(
        tester,
        uid: 'teacher',
        location: Routes.classHost(s.id),
        extra: _fastPoll,
      );
      await frames(tester);
      final l = _l(tester);
      expect(find.byKey(const Key('class.finalBoard')), findsOneWidget);
      expect(
        find.byKey(Key('ac.fast.${fastJoin.participantId}')),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('ac.fast.${slowJoin.participantId}')),
        findsNothing,
      );
      expect(
        find.byKey(Key('ac.leave.${fastJoin.participantId}')),
        findsNothing,
      );
      final leave = find.byKey(Key('ac.leave.${slowJoin.participantId}'));
      expect(leave, findsOneWidget);
      expect(
        find.descendant(of: leave, matching: find.text(l.acLeftCount(2))),
        findsOneWidget,
      );
      await closeApp(tester);
    });

    testWidgets('yaratish: savol soni ogohlantirishi va aralashish izohi', (
      tester,
    ) async {
      final prev = testDefaultPlan;
      testDefaultPlan = Plan.teacher;
      addTearDown(() => testDefaultPlan = prev);
      await w.open(
        tester,
        uid: 'teacher',
        location: Routes.classNew,
        extra: _fastPoll,
      );
      await tester.tap(find.byKey(const Key('class.topic.tox-co')));
      await frames(tester);
      // 24 savol, standart 10: 24 >= 20 — ogohlantirish yo‘q.
      expect(find.byKey(const Key('ac.shuffleHint')), findsOneWidget);
      expect(find.byKey(const Key('ac.countWarning')), findsNothing);
      await tester.ensureVisible(find.byKey(const Key('class.count.20')));
      await tester.tap(find.byKey(const Key('class.count.20')));
      await frames(tester);
      final l = _l(tester);
      expect(find.byKey(const Key('ac.countWarning')), findsOneWidget);
      expect(
        find.textContaining(l.acCountWarning(24, 20, 12), findRichText: true),
        findsOneWidget,
      );
      await closeApp(tester);
    });

    testWidgets(
      'yaratish 320 dp, shrift 1.3x: soniya va ogohlantirish toshmaydi',
      (tester) async {
        final prev = testDefaultPlan;
        testDefaultPlan = Plan.teacher;
        addTearDown(() => testDefaultPlan = prev);
        await w.open(
          tester,
          uid: 'teacher',
          location: Routes.classNew,
          size: const Size(320, 568),
          iphone: false,
          textScale: 1.3,
          extra: _fastPoll,
        );
        await tester.tap(find.byKey(const Key('class.topic.tox-small')));
        await frames(tester);
        await tester.ensureVisible(find.byKey(const Key('class.secondsField')));
        await tester.pump();
        expect(find.byKey(const Key('ac.countWarning')), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('class.secondsField')),
          '2',
        );
        await tester.pump();
        expect(find.byKey(const Key('class.secondsField')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await closeApp(tester);
      },
    );

    testWidgets('yaratish: erkin soniya 5..300, tez tanlov chiplari, ±5, '
        'yaroqsizda tugma o‘chiq', (tester) async {
      final prev = testDefaultPlan;
      testDefaultPlan = Plan.teacher;
      addTearDown(() => testDefaultPlan = prev);
      await w.open(
        tester,
        uid: 'teacher',
        location: Routes.classNew,
        extra: _fastPoll,
      );
      await tester.tap(find.byKey(const Key('class.topic.tox-co')));
      await frames(tester);
      final l = _l(tester);

      Future<void> see(Key k) async {
        await tester.ensureVisible(find.byKey(k));
        await tester.pump();
      }

      TextField field() =>
          tester.widget<TextField>(find.byKey(const Key('class.secondsField')));
      bool createEnabled() =>
          tester
              .widget<FilledButton>(find.byKey(const Key('class.createSubmit')))
              .onPressed !=
          null;

      await see(const Key('class.secondsField'));
      expect(field().controller!.text, '30'); // standart
      await tester.tap(find.byKey(const Key('class.seconds.45')));
      await tester.pump();
      expect(field().controller!.text, '45');
      await tester.tap(find.byKey(const Key('class.secondsPlus')));
      await tester.pump();
      expect(field().controller!.text, '50');
      await tester.tap(find.byKey(const Key('class.secondsMinus')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('class.secondsMinus')));
      await tester.pump();
      expect(field().controller!.text, '40');
      // Yaroqsiz: 4, bo‘sh, 0 — xato matni va tugma o‘chiq.
      for (final bad in ['4', '', '0']) {
        await tester.enterText(
          find.byKey(const Key('class.secondsField')),
          bad,
        );
        await tester.pump();
        expect(find.text(l.acSecondsError), findsOneWidget, reason: bad);
        await see(const Key('class.createSubmit'));
        expect(createEnabled(), isFalse, reason: bad);
      }
      // 301 — 3 belgi bilan yoziladi, rad etiladi.
      await tester.enterText(
        find.byKey(const Key('class.secondsField')),
        '301',
      );
      await tester.pump();
      expect(find.text(l.acSecondsError), findsOneWidget);
      // Chegaralar: 300 va 5 yaroqli, tugmalar chegarada o‘chadi.
      await tester.enterText(
        find.byKey(const Key('class.secondsField')),
        '300',
      );
      await tester.pump();
      expect(find.text(l.acSecondsError), findsNothing);
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('class.secondsPlus')))
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byKey(const Key('class.secondsField')), '5');
      await tester.pump();
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('class.secondsMinus')))
            .onPressed,
        isNull,
      );
      // Erkin qiymat 90 → serverga (fake) 90 ketadi.
      await tester.enterText(find.byKey(const Key('class.secondsField')), '90');
      await tester.pump();
      await see(const Key('class.createSubmit'));
      expect(createEnabled(), isTrue);
      await tester.tap(find.byKey(const Key('class.createSubmit')));
      await frames(tester);
      final mine = (await teacher.mySessions()).value!;
      expect(mine.single.seconds, 90);
      await closeApp(tester);
    });
  });
}
