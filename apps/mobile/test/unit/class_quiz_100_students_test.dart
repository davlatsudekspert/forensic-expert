import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/results_export/results_pdf.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/results_export/results_table.dart';
import 'package:forensic_expert/domain/results_export/results_xlsx.dart';

/// Yuk sinovi (egasi, 2026-11-07): 100 talaba bitta guruh testida —
/// qo‘shilish, javob, reyting, natija va Excel/PDF eksporti.
void main() {
  test('100 talaba: qo‘shilish, 10 savol, reyting va eksport', () async {
    var now = DateTime(2026, 11, 7, 10);
    final backend = FakeClassQuizBackend(
      clock: () => now,
      rng: Random(7),
      teachers: {'t1'},
    );
    final teacher = FakeClassQuizService(backend, userId: 't1', demo: false);
    final created = await teacher.createSession(
      topicId: 'demo-topic',
      settings: const ClassQuizSettings(
        questionCount: 10,
        studentLimit: 100,
        seconds: 30,
      ),
    );
    expect(created.ok, isTrue, reason: '${created.failure}');
    final session = created.value!;

    final students = <FakeClassQuizService>[];
    for (var i = 0; i < 100; i++) {
      final s = FakeClassQuizService(
        backend,
        userId: 's$i',
        demo: false,
        signInRequired: true,
      );
      final j = await s.join(code: session.code, nickname: 'Talaba ${i + 1}');
      expect(j.ok, isTrue, reason: 'talaba $i: ${j.failure}');
      students.add(s);
    }
    // 101-talaba — chegaradan oshadi.
    final extra = FakeClassQuizService(
      backend,
      userId: 'extra',
      demo: false,
      signInRequired: true,
    );
    expect(
      (await extra.join(code: session.code, nickname: 'Ortiqcha')).ok,
      isFalse,
    );

    final dash0 = (await teacher.dashboard(session.id)).value!;
    expect(dash0.participants.length, 100);

    expect((await teacher.start(session.id)).ok, isTrue);
    // Talaba i — i % 11 ta savolga to‘g‘ri javob beradi (0..10), qolganiga xato.
    for (var q = 0; q < 10; q++) {
      final correct = (await teacher.dashboard(session.id))
          .value!
          .current!
          .correctOption;
      final wrong = correct == 'o0' ? 'o1' : 'o0';
      for (var i = 0; i < 100; i++) {
        final r = await students[i].submitAnswer(
          sessionId: session.id,
          questionIndex: q,
          optionId: q < i % 11 ? correct : wrong,
        );
        expect(r.ok, isTrue, reason: 'savol $q talaba $i: ${r.failure}');
      }
      now = now.add(const Duration(seconds: 3));
      final n = await teacher.next(session.id);
      expect(n.value, q == 9);
    }

    final ex = (await teacher.exportResults(session.id)).value!;
    expect(ex.rows.length, 100);
    // Reyting to‘g‘ri javoblar bo‘yicha kamaymaydi.
    for (var k = 1; k < ex.rows.length; k++) {
      expect(ex.rows[k - 1].correct >= ex.rows[k].correct, isTrue);
    }
    expect(ex.rows.first.correct, 10);
    expect(ex.rows.last.correct, 0);

    // Har talaba o‘z natijasini ko‘radi.
    for (final i in [0, 10, 55, 99]) {
      final my = (await students[i].myResults(session.id)).value!;
      expect(my.total, 10);
      expect(my.correct, i % 11);
      expect(my.participants, 100);
    }

    // Eksport: CSV → Excel va PDF, 100 qator.
    final csv = ClassResultsCsv.build(
      ex.rows,
      total: ex.session.total,
      belowMinLabel: 'Minimal o‘tish balidan past',
    );
    final table = ResultsTable.fromCsv(csv);
    expect(table.rows.length, 100);
    final xlsx = ResultsXlsx.build(table);
    final sheet = ZipDecoder()
        .decodeBytes(xlsx)
        .files
        .firstWhere((f) => f.name == 'xl/worksheets/sheet1.xml');
    expect(
      '<row '
          .allMatches(String.fromCharCodes(sheet.content as List<int>))
          .length,
      101,
    );
    final pdf = await ResultsPdf.build(
      table: table,
      title: 'Guruh testi natijalari',
      dateLabel: '07.11.2026',
      regular: File('assets/fonts/inter/Inter-Regular.ttf').readAsBytesSync(),
      bold: File('assets/fonts/inter/Inter-Bold.ttf').readAsBytesSync(),
    );
    expect(String.fromCharCodes(pdf.sublist(0, 5)), '%PDF-');
  });

  group('chekka holatlar', () {
    late DateTime now;
    late FakeClassQuizBackend backend;
    late FakeClassQuizService teacher;
    FakeClassQuizService student(String id) => FakeClassQuizService(
      backend,
      userId: id,
      demo: false,
      signInRequired: true,
    );
    setUp(() {
      now = DateTime(2026, 11, 7, 11);
      backend = FakeClassQuizBackend(
        clock: () => now,
        rng: Random(3),
        teachers: {'t1'},
      );
      teacher = FakeClassQuizService(backend, userId: 't1', demo: false);
    });
    Future<ClassSessionInfo> create() async => (await teacher.createSession(
      topicId: 'demo-topic',
      settings: const ClassQuizSettings(
        questionCount: 5,
        studentLimit: 10,
        seconds: 30,
      ),
    )).value!;

    test(
      'ustoz erta tugatsa: keyingi javob rad, javobsizlar natijada',
      () async {
        final session = await create();
        final a = student('a');
        final b = student('b');
        await a.join(code: session.code, nickname: 'Ali');
        await b.join(code: session.code, nickname: 'Vali');
        await teacher.start(session.id);
        final correct = (await teacher.dashboard(session.id))
            .value!
            .current!
            .correctOption;
        await a.submitAnswer(
          sessionId: session.id,
          questionIndex: 0,
          optionId: correct,
        );
        expect((await teacher.finish(session.id)).ok, isTrue);
        final late = await b.submitAnswer(
          sessionId: session.id,
          questionIndex: 0,
          optionId: correct,
        );
        expect(late.ok, isFalse);
        final ex = (await teacher.exportResults(session.id)).value!;
        expect(ex.rows.length, 2);
        expect(ex.rows.first.nickname, 'Ali');
        expect(ex.rows.first.correct, 1);
        expect(ex.rows.last.correct, 0);
        expect((await b.myResults(session.id)).value!.correct, 0);
      },
    );

    test(
      'test o‘rtasida chiqib qayta kirgan talaba: javoblari saqlanadi',
      () async {
        final session = await create();
        final a = student('a');
        await a.join(code: session.code, nickname: 'Ali');
        await teacher.start(session.id);
        final c0 = (await teacher.dashboard(session.id))
            .value!
            .current!
            .correctOption;
        await a.submitAnswer(
          sessionId: session.id,
          questionIndex: 0,
          optionId: c0,
        );
        await a.reportLeave(session.id);
        // Qayta kirish (xuddi shu akkaunt) — yangi ishtirokchi emas.
        final again = await a.join(code: session.code, nickname: 'Ali');
        expect(again.ok, isTrue, reason: '${again.failure}');
        expect(
          (await teacher.dashboard(session.id)).value!.participants.length,
          1,
        );
        // Bir savolga ikkinchi marta javob berib bo‘lmaydi.
        final dup = await a.submitAnswer(
          sessionId: session.id,
          questionIndex: 0,
          optionId: c0,
        );
        expect(dup.ok, isFalse);
        now = now.add(const Duration(seconds: 3));
        await teacher.next(session.id);
        await teacher.finish(session.id);
        final my = (await a.myResults(session.id)).value!;
        expect(my.correct, 1);
      },
    );
  });
}
