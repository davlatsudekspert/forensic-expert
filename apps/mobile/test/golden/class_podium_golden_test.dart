import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/pump_app.dart';

/// Guruh testi yakuni: 1–2–3-o‘rinlar (oltin/kumush/bronza medal) — ustoz
/// ekrani (proyektor) va 2-o‘rindagi talabaning ekrani.
/// Yangilash:
/// `flutter test test/golden/class_podium_golden_test.dart --update-goldens`
class _NoShare implements ClassFileShare {
  @override
  Future<void> shareFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? subject,
  }) async {}
  @override
  Future<void> shareCsv({
    required String fileName,
    required String content,
    String? subject,
  }) async {}
}

void main() {
  setUpAll(() => testDefaultPlan = Plan.teacher);
  tearDownAll(() => testDefaultPlan = null);

  Future<void> shot(WidgetTester tester, {required bool student}) async {
    var now = DateTime(2026, 11, 1, 10);
    final backend = FakeClassQuizBackend(
      clock: () => now,
      rng: Random(5),
      teachers: {'t1'},
    );
    final teacher = FakeClassQuizService(backend, userId: 't1', demo: false);
    // Laqab → to‘g‘ri javoblar soni (5 savoldan) va javob tezligi (ms).
    const kids = [
      ('Dilnoza', 5, 2200),
      ('Jasur', 4, 3100),
      ('Madina', 4, 5200),
      ('Sardor', 3, 4000),
      ('Aziz', 2, 6000),
    ];
    final svc = [
      for (var i = 0; i < kids.length; i++)
        FakeClassQuizService(backend, userId: 's$i', demo: false),
    ];
    final created = await teacher.createSession(
      topicId: 'demo-topic',
      settings: const ClassQuizSettings(questionCount: 5, seconds: 30),
    );
    final id = created.value!.id;
    for (var i = 0; i < kids.length; i++) {
      await svc[i].join(code: created.value!.code, nickname: kids[i].$1);
    }
    await teacher.start(id);
    for (var q = 0; q < 5; q++) {
      final cur = (await teacher.dashboard(id)).value!.current!;
      final wrong = cur.options
          .map((o) => o.id)
          .firstWhere((o) => o != cur.correctOption);
      final order = [for (var i = 0; i < kids.length; i++) i]
        ..sort((a, b) => kids[a].$3.compareTo(kids[b].$3));
      var t = 0;
      for (final i in order) {
        now = now.add(Duration(milliseconds: kids[i].$3 - t));
        t = kids[i].$3;
        await svc[i].submitAnswer(
          sessionId: id,
          questionIndex: q,
          optionId: q < kids[i].$2 ? cur.correctOption : wrong,
        );
      }
      await teacher.closeQuestion(id);
      now = now.add(const Duration(seconds: 3));
      await teacher.next(id);
    }

    final as = student ? svc[1] : teacher;
    final c = await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      size: const Size(390, 1100),
      pixelRatio: 1.5,
      overrides: [
        classQuizServiceProvider.overrideWithValue(as),
        classQuizPollIntervalProvider.overrideWithValue(
          const Duration(milliseconds: 100),
        ),
        classFileShareProvider.overrideWithValue(_NoShare()),
        classScannerAvailableProvider.overrideWithValue(false),
        classLandscapePromptEnabledProvider.overrideWithValue(false),
      ],
    );
    c
        .read(routerProvider)
        .go(student ? Routes.classPlay(id) : Routes.classHost(id));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        student
            ? 'goldens/class_podium_student_uz.png'
            : 'goldens/class_podium_teacher_uz.png',
      ),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets(
    'ustoz: yakuniy reyting 1–2–3 medal',
    (t) => shot(t, student: false),
  );
  testWidgets('talaba: 2-o‘rin medali', (t) => shot(t, student: true));
}
