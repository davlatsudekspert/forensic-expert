// «Sinfda test» audit tuzatishlari (2026-10-18) — regression testlari:
//  1b  ochiq savolda ball ko‘rinmaydi (ekran + Fake server qoidasi);
//  3b  proyektor to‘g‘ri javobni faqat `revealed` bo‘lganda ochadi;
//  4   bitta polling xatosi ekranni xato ekraniga almashtirmaydi;
//  UX  talaba telefoni va proyektorda variant tartibi va harflari bir xil;
//  5   tugagan sessiyaga qayta kirish → natijalar;
//  6   javob bermagan talaba noto‘g‘ri javob berganidan yuqori turmaydi;
//  7   laqab filtri: real ismlar o‘tadi, so‘kinish to‘siladi; SQL bilan bir xil.
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
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

/// Polling xatosini qo‘lda yoqib-o‘chiradigan ko‘rinish.
class _Flaky extends FakeClassQuizService {
  _Flaky(super.backend, {required super.userId}) : super(demo: false);

  ClassFailure? fail;

  @override
  Future<ClassResult<ClassStudentState>> state(String sessionId) async =>
      fail != null ? ClassResult.fail(fail!) : super.state(sessionId);

  @override
  Future<ClassResult<ClassDashboard>> dashboard(String sessionId) async =>
      fail != null ? ClassResult.fail(fail!) : super.dashboard(sessionId);
}

class _World {
  _World() {
    backend = FakeClassQuizBackend(
      clock: () => now,
      rng: Random(5),
      teachers: {'t1'},
    );
    teacher = _Flaky(backend, userId: 't1');
    student = _Flaky(backend, userId: 'stu');
    s2 = FakeClassQuizService(backend, userId: 'stu2', demo: false);
    s3 = FakeClassQuizService(backend, userId: 'stu3', demo: false);
  }

  var now = DateTime(2026, 10, 17, 10);
  late final FakeClassQuizBackend backend;
  late final _Flaky teacher;
  late final _Flaky student;
  late final FakeClassQuizService s2;
  late final FakeClassQuizService s3;

  void tick(int ms) => now = now.add(Duration(milliseconds: ms));

  /// Sessiya: stu (+ stu2, stu3) qo‘shilgan, boshlangan.
  Future<ClassSessionInfo> started() async {
    final s = (await teacher.createSession(
      topicId: 'demo-topic',
      settings: const ClassQuizSettings(questionCount: 5, studentLimit: 5),
    )).value!;
    await student.join(code: s.code, nickname: 'Ali');
    await s2.join(code: s.code, nickname: 'Vali');
    await s3.join(code: s.code, nickname: 'Gulnora');
    await teacher.start(s.id);
    return s;
  }

  Future<ClassCurrentQuestion> current(String id) async =>
      (await teacher.dashboard(id)).value!.current!;
}

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

Future<void> _frames(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _open(
  WidgetTester tester, {
  required ClassQuizService as,
  required String location,
  Size size = const Size(390, 844),
}) async {
  final c = await pumpApp(
    tester,
    settings: completedSettings(lang: 'uz'),
    size: size,
    overrides: [
      classQuizServiceProvider.overrideWithValue(as),
      classQuizPollIntervalProvider.overrideWithValue(
        const Duration(milliseconds: 100),
      ),
      classScannerAvailableProvider.overrideWithValue(false),
      classLandscapePromptEnabledProvider.overrideWithValue(false),
    ],
  );
  c.read(routerProvider).go(location);
  await _frames(tester);
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

/// Ekrandagi variant kalitlari (yuqoridan pastga) — `prefix` + option id.
List<String> _optionOrder(WidgetTester tester, String prefix) {
  final found = find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith(prefix),
  );
  final items = [
    for (final e in found.evaluate())
      (
        id: ((e.widget.key! as ValueKey<String>).value).substring(
          prefix.length,
        ),
        y: tester.getTopLeft(find.byKey(e.widget.key!)).dy,
        x: tester.getTopLeft(find.byKey(e.widget.key!)).dx,
      ),
  ]..sort((a, b) => a.y != b.y ? a.y.compareTo(b.y) : a.x.compareTo(b.x));
  return [for (final i in items) i.id];
}

void main() {
  group('Fake server = SQL qoidasi', () {
    test(
      '1: ochiq savolda ball/to‘g‘ri soni/reyting oshkor bo‘lmaydi',
      () async {
        final w = _World();
        final s = await w.started();
        final cur = await w.current(s.id);
        final wrong = cur.options
            .firstWhere((o) => o.id != cur.correctOption)
            .id;
        await w.student.submitAnswer(
          sessionId: s.id,
          questionIndex: 0,
          optionId: cur.correctOption,
        );
        await w.s2.submitAnswer(
          sessionId: s.id,
          questionIndex: 0,
          optionId: wrong,
        );
        final right = (await w.student.state(s.id)).value!;
        final bad = (await w.s2.state(s.id)).value!;
        expect(right.score, 0);
        expect(right.correct, 0);
        expect(right.rank, bad.rank, reason: 'o‘rin ham hech narsa aytmaydi');
        final d = (await w.teacher.dashboard(s.id)).value!;
        expect(d.revealed, isFalse);
        expect(d.leaderboard.every((r) => r.score == 0), isTrue);

        // Muddat o‘tdi, lekin javob qabul qilish imtiyozi ichida.
        w.tick(30300);
        final grace = (await w.teacher.dashboard(s.id)).value!;
        expect(grace.phase, ClassPhase.closed);
        expect(grace.revealed, isFalse);
        expect(grace.hardest, isEmpty);
        expect((await w.student.state(s.id)).value!.score, 0);

        w.tick(1300); // 31.6 s — revealed
        final shown = (await w.teacher.dashboard(s.id)).value!;
        expect(shown.revealed, isTrue);
        expect(shown.leaderboard.first.nickname, 'Ali');
        expect(shown.leaderboard.first.score, greaterThan(0));
        final after = (await w.student.state(s.id)).value!;
        expect(after.score, greaterThan(0));
        expect(after.correct, 1);
        expect(after.rank, 1);
      },
    );

    test('6: javob bermagan va noto‘g‘ri javob bergan — teng o‘rin', () async {
      final w = _World();
      final s = await w.started();
      final cur = await w.current(s.id);
      final wrong = cur.options.firstWhere((o) => o.id != cur.correctOption).id;
      await w.s2.submitAnswer(
        sessionId: s.id,
        questionIndex: 0,
        optionId: wrong,
      );
      w.tick(31600);
      final board = (await w.teacher.dashboard(s.id)).value!.leaderboard;
      final vali = board.firstWhere((r) => r.nickname == 'Vali');
      final ali = board.firstWhere((r) => r.nickname == 'Ali');
      expect(vali.rank, ali.rank);
    });

    test(
      '5: tugagan sessiyaga mavjud ishtirokchi qaytadi; yangisi — yo‘q',
      () async {
        final w = _World();
        final s = await w.started();
        final gul = (await w.teacher.dashboard(s.id)).value!.participants
            .firstWhere((p) => p.nickname == 'Gulnora');
        await w.teacher.kick(s.id, gul.id);
        await w.teacher.finish(s.id);
        final back = await w.student.join(code: s.code, nickname: 'Boshqa');
        expect(back.ok, isTrue);
        expect(back.value!.nickname, 'Ali');
        expect(back.value!.session.status, ClassSessionStatus.finished);
        expect((await w.student.myResults(s.id)).ok, isTrue);
        expect(
          (await w.s3.join(code: s.code, nickname: 'Gulnora')).failure,
          ClassFailure.kicked,
        );
        final fresh = FakeClassQuizService(
          w.backend,
          userId: 'new',
          demo: false,
        );
        expect(
          (await fresh.join(code: s.code, nickname: 'Yangi')).failure,
          ClassFailure.finished,
        );
      },
    );
  });

  group('7: laqab filtri', () {
    test('real ismlar bloklanmaydi', () {
      for (final ok in [
        'Себастьян',
        'Глеба',
        'Глеб',
        'Ebaldiyev',
        'Rebalance',
        'Алишер',
        'Ўткир',
        'O‘tkir',
        'Sikl',
        'Sexta',
      ]) {
        expect(ClassNickname.check(ok), NicknameCheck.ok, reason: ok);
      }
    });

    test('haqiqiy so‘kinish hamon bloklanadi', () {
      for (final bad in [
        'сука',
        'СУКА',
        'Ебать',
        'ебанат',
        'Ali заебал',
        'е.б.а.т.ь',
        'ebal',
        'Ali ebal',
        'yebat',
        'долбоеб',
        'f.u.c.k',
        'PIDOR',
      ]) {
        expect(ClassNickname.check(bad), NicknameCheck.blocked, reason: bad);
      }
    });

    test('Dart va SQL ro‘yxatlari bir xil (migratsiyadan o‘qiladi)', () {
      final sql = File(
        '../../supabase/migrations/20261018040000_class_quiz_fixes.sql',
      ).readAsStringSync();
      final dart = File('lib/domain/class_quiz/class_quiz_models.dart')
          .readAsStringSync();
      List<String> sqlArray(String name) {
        final m = RegExp(
          '$name text\\[\\] := array\\[(.*?)\\];',
          dotAll: true,
        ).firstMatch(sql)!;
        return [
          for (final x in RegExp(r"'([^']*)'").allMatches(m.group(1)!))
            x.group(1)!,
        ];
      }

      List<String> dartList(String name) {
        final m = RegExp(
          'static const $name = \\[(.*?)\\];',
          dotAll: true,
        ).firstMatch(dart)!;
        return [
          for (final x in RegExp(r"'([^']*)'").allMatches(m.group(1)!))
            x.group(1)!,
        ];
      }

      expect(dartList('_stems'), sqlArray('stems'));
      expect(dartList('_prefixes'), sqlArray('prefixes'));
      expect(dartList('_exact'), sqlArray('exact'));
      for (final w in [
        ...sqlArray('stems'),
        ...sqlArray('prefixes'),
        ...sqlArray('exact'),
      ]) {
        expect(ClassNickname.check(w), NicknameCheck.blocked, reason: w);
      }
    });
  });

  testWidgets('1b: talaba ekranida ball faqat natija ochilgach', (
    tester,
  ) async {
    final prevPlan = testDefaultPlan;
    testDefaultPlan = Plan.student;
    addTearDown(() => testDefaultPlan = prevPlan);
    final w = _World();
    final s = await w.started();
    final cur = await w.current(s.id);
    await _open(tester, as: w.student, location: Routes.classPlay(s.id));
    expect(find.byKey(const Key('class.question')), findsOneWidget);
    expect(find.byKey(const Key('class.score')), findsNothing);
    await tester.tap(find.byKey(Key('class.option.${cur.correctOption}')));
    await _frames(tester);
    await tester.ensureVisible(find.byKey(const Key('class.confirm')));
    await tester.tap(find.byKey(const Key('class.confirm')));
    await _frames(tester);
    expect(find.byKey(const Key('class.score')), findsNothing);
    w.tick(30300); // yopildi, lekin hali revealed emas
    await _frames(tester);
    expect(find.byKey(const Key('class.score')), findsNothing);
    w.tick(1300);
    await _frames(tester);
    expect(find.byKey(const Key('class.explanation')), findsOneWidget);
    final score = tester.widget<Text>(find.byKey(const Key('class.score')));
    expect(score.data, isNot(_l(tester).classScoreLine(0)));
    await _close(tester);
  });

  testWidgets(
    '4: talaba — polling xatosi oxirgi holatni saqlaydi, kichik belgi',
    (tester) async {
      final prevPlan = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prevPlan);
      final w = _World();
      final s = await w.started();
      await _open(tester, as: w.student, location: Routes.classPlay(s.id));
      expect(find.byKey(const Key('class.question')), findsOneWidget);
      w.student.fail = ClassFailure.offline;
      await _frames(tester, 4);
      expect(find.byKey(const Key('class.question')), findsOneWidget);
      expect(find.byKey(const Key('class.playError')), findsNothing);
      expect(find.byKey(const Key('class.reconnecting')), findsOneWidget);
      expect(find.text(_l(tester).classReconnecting), findsOneWidget);
      w.student.fail = ClassFailure.server;
      await _frames(tester, 3);
      expect(find.byKey(const Key('class.question')), findsOneWidget);
      w.student.fail = null;
      await _frames(tester, 3);
      expect(find.byKey(const Key('class.reconnecting')), findsNothing);
      expect(find.byKey(const Key('class.question')), findsOneWidget);
      await _close(tester);
    },
  );

  testWidgets('4: hech holat kelmagan bo‘lsa — to‘liq xato ekrani', (
    tester,
  ) async {
    final prevPlan = testDefaultPlan;
    testDefaultPlan = Plan.student;
    addTearDown(() => testDefaultPlan = prevPlan);
    final w = _World();
    final s = await w.started();
    w.student.fail = ClassFailure.offline;
    await _open(tester, as: w.student, location: Routes.classPlay(s.id));
    expect(find.byKey(const Key('class.playError')), findsOneWidget);
    expect(find.byKey(const Key('class.reconnecting')), findsNothing);
    await _close(tester);
  });

  testWidgets('4: proyektor — polling xatosi panelni saqlaydi', (tester) async {
    final w = _World();
    final s = await w.started();
    await _open(
      tester,
      as: w.teacher,
      location: Routes.classHost(s.id),
      size: const Size(1280, 720),
    );
    expect(find.byKey(const Key('class.hostQuestion')), findsOneWidget);
    w.teacher.fail = ClassFailure.offline;
    await _frames(tester, 4);
    expect(find.byKey(const Key('class.hostQuestion')), findsOneWidget);
    expect(find.byKey(const Key('class.hostError')), findsNothing);
    expect(find.byKey(const Key('class.reconnecting')), findsOneWidget);
    w.teacher.fail = null;
    await _frames(tester, 3);
    expect(find.byKey(const Key('class.reconnecting')), findsNothing);
    await _close(tester);
  });

  testWidgets(
    '3b: proyektor to‘g‘ri javob/izohni faqat revealed bo‘lganda ochadi',
    (tester) async {
      final w = _World();
      final s = await w.started();
      final cur = await w.current(s.id);
      await _open(
        tester,
        as: w.teacher,
        location: Routes.classHost(s.id),
        size: const Size(1280, 720),
      );
      final l = _l(tester);
      Finder correctTile() => find.descendant(
        of: find.byKey(Key('class.hostOption.${cur.correctOption}')),
        matching: find.byIcon(Icons.check_circle),
      );
      expect(correctTile(), findsNothing);
      w.tick(30300); // faza closed, javob hali qabul qilinadi
      await _frames(tester);
      expect(correctTile(), findsNothing);
      expect(find.byKey(const Key('class.hostExplanation')), findsNothing);
      expect(find.byKey(const Key('class.correctPct')), findsNothing);
      expect(find.text(l.classOptionCorrect), findsNothing);
      w.tick(1300); // revealed
      await _frames(tester);
      expect(correctTile(), findsOneWidget);
      expect(find.byKey(const Key('class.hostExplanation')), findsOneWidget);
      await _close(tester);
    },
  );

  testWidgets(
    'UX: talaba telefoni va proyektorda variant tartibi va harfi bir xil',
    (tester) async {
      final prevPlan = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prevPlan);
      final w = _World();
      final s = await w.started();
      final serverOrder = [
        for (final o in (await w.current(s.id)).options) o.id,
      ];

      await _open(
        tester,
        as: w.teacher,
        location: Routes.classHost(s.id),
        size: const Size(1280, 720),
      );
      final host = _optionOrder(tester, 'class.hostOption.');
      await _close(tester);

      for (final stu in [w.student, w.s2, w.s3]) {
        await _open(tester, as: stu, location: Routes.classPlay(s.id));
        final phone = _optionOrder(tester, 'class.option.');
        expect(phone, host, reason: 'har talabada proyektor tartibi');
        // Harf: A, B, C, D — bir xil variant.
        for (var i = 0; i < phone.length; i++) {
          final letter = String.fromCharCode(0x41 + i);
          expect(
            find.descendant(
              of: find.byKey(Key('class.option.${phone[i]}')),
              matching: find.text(letter),
            ),
            findsOneWidget,
          );
        }
        await _close(tester);
      }
      expect(host, serverOrder);
    },
  );

  testWidgets(
    '5: ilova qayta ochildi — tugagan sinf kodini kiritib natijaga o‘tadi',
    (tester) async {
      final prevPlan = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prevPlan);
      final w = _World();
      final s = await w.started();
      await w.teacher.finish(s.id);
      await _open(
        tester,
        as: w.student,
        location: Routes.classJoinWith(s.code),
      );
      await tester.enterText(find.byKey(const Key('class.nickField')), 'Ali');
      await tester.tap(find.byKey(const Key('class.joinSubmit')));
      await _frames(tester);
      expect(find.byKey(const Key('class.summary')), findsOneWidget);
      expect(find.text(_l(tester).classErrFinished), findsNothing);
      await _close(tester);
    },
  );
}
