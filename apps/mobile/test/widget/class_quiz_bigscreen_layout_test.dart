// Proyektor/TV (keng ekran) «Sinfda test» ustoz ekrani: har bosqich (kutish
// zali, ochiq savol, javob ochilgan, yakun) 1920×1080, 1280×720, 1024×600 va
// 844×390 da BIR ekranga sig‘adi: overflow yo‘q, asosiy tugma to‘liq ekran
// ichida va bosiladigan, uzun izoh ixcham (…), reyting sig‘adigan top N.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';

import '../helpers/pump_app.dart';

class _Awake implements ClassScreenAwake {
  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

class _Orient implements ClassOrientationControl {
  @override
  Future<void> landscape() async {}

  @override
  Future<void> restore() async {}
}

const _sizes = <(String, Size)>[
  ('1920x1080', Size(1920, 1080)),
  ('1280x720', Size(1280, 720)),
  ('1024x600', Size(1024, 600)),
  ('844x390', Size(844, 390)),
];

final _longExplanation = List.filled(
  14,
  'Izoh: jarayonning har bir bosqichi alohida tekshiriladi va natija '
  'manba bilan solishtiriladi; bu yerda uzun matn ataylab yozilgan.',
).join(' ');

const _longQuestion =
    'Murakkab holatda ekspert birinchi navbatda qaysi qadamni bajarishi '
    'kerak, agar ob’ekt qadoqlanmagan va zanjir hujjatlari to‘liq bo‘lmasa?';

final _topic = ClassBankTopic(
  id: 'long-topic',
  title: 'Uzun matnli mavzu',
  questions: [
    for (var i = 0; i < 6; i++)
      ClassBankQuestion(
        question: '$_longQuestion ($i)',
        options: [
          'Birinchi variant: ob’ektni darhol tahlilga yuborish va hujjat '
              'to‘ldirmaslik',
          'Ikkinchi variant: holatni yozib, fotosuratga olib, rahbarni xabardor qilish',
          'Uchinchi variant: so‘rov yuborgan tomonga qaytarib berish',
          'To‘rtinchi variant: ekspertiza muddatini ikki baravar uzaytirish',
        ],
        correctIndex: i % 4,
        explanation: _longExplanation,
        source: const ClassSource(author: 'Test', title: 'Test', page: '1'),
      ),
  ],
);

class _World {
  var now = DateTime(2026, 10, 18, 10);
  late final FakeClassQuizBackend backend;
  late final FakeClassQuizService teacher;
  late final String sessionId;
  final students = <FakeClassQuizService>[];

  Future<void> init({required int joined}) async {
    backend = FakeClassQuizBackend(
      clock: () => now,
      rng: Random(5),
      teachers: {'t1'},
      topics: [_topic],
    );
    teacher = FakeClassQuizService(backend, userId: 't1', demo: false);
    final s = (await teacher.createSession(
      topicId: _topic.id,
      settings: const ClassQuizSettings(questionCount: 5, studentLimit: 30),
    )).value!;
    sessionId = s.id;
    for (var i = 0; i < joined; i++) {
      final st = FakeClassQuizService(backend, userId: 'u$i', demo: false);
      final nick = 'Talaba ${String.fromCharCode(65 + i ~/ 10)}${i % 10}';
      expect((await st.join(code: s.code, nickname: nick)).ok, isTrue);
      students.add(st);
    }
  }

  /// Hamma javob beradi (yarmi to‘g‘ri) — reytingda ballar bo‘ladi.
  Future<void> everyoneAnswers() async {
    final cur = (await teacher.dashboard(sessionId)).value!.current!;
    for (var i = 0; i < students.length; i++) {
      final opt = i.isEven
          ? cur.correctOption
          : cur.options.firstWhere((o) => o.id != cur.correctOption).id;
      await students[i].submitAnswer(
        sessionId: sessionId,
        questionIndex: cur.index,
        optionId: opt,
      );
    }
  }
}

Future<void> _frames(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _open(WidgetTester tester, _World w, Size size) async {
  await pumpApp(
    tester,
    settings: completedSettings(),
    size: size,
    overrides: [
      classQuizServiceProvider.overrideWithValue(w.teacher),
      classQuizPollIntervalProvider.overrideWithValue(
        const Duration(milliseconds: 100),
      ),
      classScannerAvailableProvider.overrideWithValue(false),
      classLandscapePromptEnabledProvider.overrideWithValue(false),
      classScreenAwakeProvider.overrideWithValue(_Awake()),
      classOrientationControlProvider.overrideWithValue(_Orient()),
    ],
  ).then((c) => c.read(routerProvider).go(Routes.classHost(w.sessionId)));
  await _frames(tester);
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

/// Tugma to‘liq ekran ichida va bosiladigan (ustida boshqa vidjet yo‘q).
void _expectPinned(WidgetTester tester, Key key, Size size) {
  final f = find.byKey(key);
  expect(f, findsOneWidget, reason: '$key topilmadi');
  final rect = tester.getRect(f);
  expect(
    Rect.fromLTWH(0, 0, size.width, size.height).contains(rect.topLeft) &&
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ).contains(rect.bottomRight - const Offset(0.01, 0.01)),
    isTrue,
    reason: '$key ekrandan chiqib ketdi: $rect (ekran $size)',
  );
  expect(f.hitTestable(), findsOneWidget, reason: '$key bosilmaydi');
}

void main() {
  for (final (name, size) in _sizes) {
    group('proyektor $name', () {
      testWidgets(
        'kutish zali (30 ishtirokchi): sig‘adi, «Boshlash» ko‘rinadi',
        (tester) async {
          final w = _World();
          await w.init(joined: 30);
          await _open(tester, w, size);
          expect(tester.takeException(), isNull);
          _expectPinned(tester, const Key('class.startButton'), size);
          expect(find.byKey(const Key('class.code')), findsOneWidget);
          expect(find.byKey(const Key('class.qr')), findsOneWidget);
          await _close(tester);
        },
      );

      testWidgets('ochiq savol: savol, variantlar, «Keyingi» ko‘rinadi', (
        tester,
      ) async {
        final w = _World();
        await w.init(joined: 30);
        await w.teacher.start(w.sessionId);
        await _open(tester, w, size);
        expect(tester.takeException(), isNull);
        _expectPinned(tester, const Key('class.nextButton'), size);
        _expectPinned(tester, const Key('class.closeButton'), size);
        _expectPinned(tester, const Key('class.hostQuestion'), size);
        expect(
          find.byKey(const Key('class.participantStatus')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('class.hostExplanation')), findsNothing);
        await _close(tester);
      });

      testWidgets('javob ochilgan (uzun izoh, 30 ishtirokchi): '
          'sig‘adi, «Keyingi savol» ko‘rinadi, reyting bor', (tester) async {
        final w = _World();
        await w.init(joined: 30);
        await w.teacher.start(w.sessionId);
        await w.everyoneAnswers();
        w.now = w.now.add(const Duration(milliseconds: 31800));
        await _open(tester, w, size);
        expect(tester.takeException(), isNull);
        final l = AppLocalizations.of(
          tester.element(find.byType(Scaffold).first),
        );
        expect(find.text(l.classNextQuestion), findsOneWidget);
        _expectPinned(tester, const Key('class.nextButton'), size);
        for (final k in [
          'class.hostQuestion',
          'class.hostExplanation',
          'class.leaderboard',
          'class.liveStats',
          'class.correctPct',
        ]) {
          _expectPinned(tester, Key(k), size);
        }
        // Barcha 4 variant ekranda.
        for (final o in ['o0', 'o1', 'o2', 'o3']) {
          _expectPinned(tester, Key('class.hostOption.$o'), size);
        }
        // Reyting: kamida bitta qator ko‘rinadi (sig‘adigan top N).
        expect(
          find.descendant(
            of: find.byKey(const Key('class.leaderboard')),
            matching: find.textContaining('Talaba'),
          ),
          findsWidgets,
        );
        // Izoh ixcham: bosilsa to‘liq matn oynada ochiladi.
        await tester.tap(find.byKey(const Key('class.hostExplanation')));
        await _frames(tester);
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _close(tester);
      });

      testWidgets('yakun (30 ishtirokchi): sig‘adi, tugmalar ko‘rinadi', (
        tester,
      ) async {
        final w = _World();
        await w.init(joined: 30);
        await w.teacher.start(w.sessionId);
        await w.everyoneAnswers();
        await w.teacher.finish(w.sessionId);
        await _open(tester, w, size);
        expect(tester.takeException(), isNull);
        _expectPinned(tester, const Key('class.exportButton'), size);
        _expectPinned(tester, const Key('class.doneButton'), size);
        _expectPinned(tester, const Key('class.finalBoard'), size);
        await _close(tester);
      });
    });
  }
}
