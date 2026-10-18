import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';

import '../helpers/pump_app.dart';

class _Awake implements ClassScreenAwake {
  int enabled = 0;
  int disabled = 0;

  @override
  Future<void> enable() async => enabled++;

  @override
  Future<void> disable() async => disabled++;
}

class _Orient implements ClassOrientationControl {
  final calls = <String>[];

  @override
  Future<void> landscape() async => calls.add('landscape');

  @override
  Future<void> restore() async => calls.add('restore');
}

const _nicks = [
  'Ali',
  'Gulnora',
  'Abdurahmonov-Muham',
  'Sherzod',
  'Malika',
  'Bobur',
  'Dilnoza',
  'Jasur',
  'Nigora',
  'Otabek',
  'Zarina',
  'Sardor',
];

Future<void> _frames(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// Ishlayotgan savol: 12 ishtirokchi, 3 tasi javob bergan. Variant ID’lari
/// qaytariladi (UI’da ko‘rinmasligini tekshirish uchun).
Future<
  ({
    FakeClassQuizService teacher,
    String sessionId,
    String firstNickAnswered,
    _Awake awake,
    _Orient orient,
  })
>
openRunningClassHost(
  WidgetTester tester, {
  required Size size,
  String lang = 'uz',
  bool prompt = false,
}) async {
  final now = DateTime(2026, 10, 17, 10);
  final backend = FakeClassQuizBackend(
    clock: () => now,
    rng: Random(5),
    teachers: {'t1'},
  );
  final teacher = FakeClassQuizService(backend, userId: 't1', demo: false);
  final s = (await teacher.createSession(
    topicId: 'demo-topic',
    settings: const ClassQuizSettings(questionCount: 5, studentLimit: 30),
  )).value!;
  final students = <FakeClassQuizService>[];
  for (var i = 0; i < _nicks.length; i++) {
    final st = FakeClassQuizService(backend, userId: 'u$i', demo: false);
    expect((await st.join(code: s.code, nickname: _nicks[i])).ok, isTrue);
    students.add(st);
  }
  await teacher.start(s.id);
  final cur = (await teacher.dashboard(s.id)).value!.current!;
  for (var i = 0; i < 3; i++) {
    await students[i].submitAnswer(
      sessionId: s.id,
      questionIndex: 0,
      optionId: cur.options[i % cur.options.length].id,
    );
  }
  final awake = _Awake();
  final orient = _Orient();
  await pumpApp(
    tester,
    settings: completedSettings(lang: lang),
    size: size,
    overrides: [
      classQuizServiceProvider.overrideWithValue(teacher),
      classQuizPollIntervalProvider.overrideWithValue(
        const Duration(milliseconds: 100),
      ),
      classScannerAvailableProvider.overrideWithValue(false),
      classLandscapePromptEnabledProvider.overrideWithValue(prompt),
      classScreenAwakeProvider.overrideWithValue(awake),
      classOrientationControlProvider.overrideWithValue(orient),
    ],
  ).then((c) => c.read(routerProvider).go(Routes.classHost(s.id)));
  await _frames(tester);
  return (
    teacher: teacher,
    sessionId: s.id,
    firstNickAnswered: _nicks[0],
    awake: awake,
    orient: orient,
  );
}

void main() {
  test('model: participants[].answered parse (default false)', () {
    final p = ClassParticipant.fromJson({
      'id': 'p1',
      'nickname': 'Ali',
      'answered': true,
    });
    expect(p.answered, isTrue);
    final old = ClassParticipant.fromJson({'id': 'p2', 'nickname': 'Vali'});
    expect(old.answered, isFalse);
    final bad = ClassParticipant.fromJson({
      'id': 'p3',
      'nickname': 'X',
      'answered': 'yes',
      'email': 'a@b.c',
    });
    expect(bad.answered, isFalse);
  });

  for (final (name, size) in [
    ('1920x1080', const Size(1920, 1080)),
    ('1280x720', const Size(1280, 720)),
    ('phone portrait', const Size(390, 844)),
    ('phone landscape', const Size(844, 390)),
    ('small phone 320', const Size(320, 568)),
  ]) {
    testWidgets('proyektor: ishtirokchi holati ($name), overflow yo‘q', (
      tester,
    ) async {
      final r = await openRunningClassHost(tester, size: size);
      final l = AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      );
      final status = find.byKey(const Key('class.participantStatus'));
      if (status.evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          status,
          300,
          scrollable: find.byType(Scrollable).first,
        );
      }
      expect(status, findsOneWidget);
      await tester.ensureVisible(status);
      await tester.pump();
      expect(find.text(l.classAnswered(3, 12)), findsOneWidget);
      expect(find.text(l.classParticipantAnswered), findsNWidgets(3));
      expect(find.text(l.classParticipantWaiting), findsNWidgets(9));
      expect(
        find.descendant(
          of: find.byKey(const Key('class.participantStatus')),
          matching: find.text('Ali'),
        ),
        findsOneWidget,
      );
      // Variant tanlovi/email ochilmaydi.
      expect(find.textContaining('@'), findsNothing);
      expect(tester.takeException(), isNull);
      expect(r.awake.enabled, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(r.awake.disabled, 1);
    });
  }

  testWidgets('telefon tik holatda: gorizontal so‘rovi — Ha → landscape, '
      'chiqishda tiklanadi', (tester) async {
    final r = await openRunningClassHost(
      tester,
      size: const Size(390, 844),
      prompt: true,
    );
    final l = AppLocalizations.of(tester.element(find.byType(Scaffold).first));
    expect(find.text(l.classLandscapePrompt), findsOneWidget);
    await tester.tap(find.byKey(const Key('class.landscapeYes')));
    await _frames(tester);
    expect(find.byKey(const Key('class.landscapeDialog')), findsNothing);
    expect(r.orient.calls, ['landscape']);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(r.orient.calls, ['landscape', 'restore']);
  });

  testWidgets(
    'telefon tik holatda: Yo‘q → o‘zgarmaydi; planshetda so‘rov yo‘q',
    (tester) async {
      final r = await openRunningClassHost(
        tester,
        size: const Size(390, 844),
        prompt: true,
      );
      await tester.tap(find.byKey(const Key('class.landscapeNo')));
      await _frames(tester);
      expect(r.orient.calls, isEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(r.orient.calls, isEmpty);

      final r2 = await openRunningClassHost(
        tester,
        size: const Size(1280, 720),
        prompt: true,
      );
      expect(find.byKey(const Key('class.landscapeDialog')), findsNothing);
      expect(r2.orient.calls, isEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    },
  );

  test(
    'SystemChrome yo‘q muhitda ham wakelock/orientation yiqilmaydi',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await const WakelockClassScreenAwake().enable();
      await const WakelockClassScreenAwake().disable();
      await const SystemClassOrientationControl().restore();
      expect(SystemChrome.setPreferredOrientations, isNotNull);
    },
  );
}
