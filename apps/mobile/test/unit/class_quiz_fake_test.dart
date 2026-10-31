import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_demo_bank.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';

/// Fake adapter = SQL funksiyalarining nusxasi: butun oqim va xavfsizlik
/// qoidalari shu yerda tekshiriladi (server testlari: supabase/tests).
void main() {
  late DateTime now;
  late FakeClassQuizBackend backend;
  late FakeClassQuizService teacher;
  late FakeClassQuizService other;
  late FakeClassQuizService outsider;

  FakeClassQuizService student(String id) => FakeClassQuizService(
    backend,
    userId: id,
    demo: false,
    signInRequired: true,
  );

  void tick(int ms) => now = now.add(Duration(milliseconds: ms));

  setUp(() {
    now = DateTime(2026, 10, 17, 10);
    backend = FakeClassQuizBackend(
      clock: () => now,
      rng: Random(42),
      teachers: {'t1', 't2'},
    );
    teacher = FakeClassQuizService(backend, userId: 't1', demo: false);
    other = FakeClassQuizService(backend, userId: 't2', demo: false);
    outsider = student('out');
  });

  Future<ClassSessionInfo> create({
    ClassQuizSettings s = const ClassQuizSettings(
      questionCount: 5,
      studentLimit: 5,
      seconds: 30,
    ),
  }) async {
    final r = await teacher.createSession(topicId: 'demo-topic', settings: s);
    expect(r.ok, isTrue, reason: '${r.failure}');
    return r.value!;
  }

  Future<ClassJoinInfo> join(
    FakeClassQuizService s,
    ClassSessionInfo session,
    String nick,
  ) async {
    final r = await s.join(code: session.code, nickname: nick);
    expect(r.ok, isTrue, reason: '${r.failure}');
    return r.value!;
  }

  /// Hozirgi savolning to‘g‘ri variant id’si (ustoz paneli orqali).
  Future<String> correctOf(String sessionId) async =>
      (await teacher.dashboard(sessionId)).value!.current!.correctOption;

  group('rol va yaratish', () {
    test('ustoz bo‘lmagan sinf yarata olmaydi (403)', () async {
      final r = await outsider.createSession(
        topicId: 'demo-topic',
        settings: const ClassQuizSettings(),
      );
      expect(r.failure, ClassFailure.forbidden);
      expect((await outsider.me()).value!.isTeacher, isFalse);
      expect((await outsider.topics()).failure, ClassFailure.forbidden);
      expect((await teacher.me()).value!.isTeacher, isTrue);
    });

    test('sozlamalar va savollar yetarliligi tekshiriladi', () async {
      Future<ClassFailure?> f(
        ClassQuizSettings s, [
        String t = 'demo-topic',
      ]) async =>
          (await teacher.createSession(topicId: t, settings: s)).failure;
      expect(
        await f(const ClassQuizSettings(questionCount: 4)),
        ClassFailure.invalidSettings,
      );
      expect(
        await f(const ClassQuizSettings(studentLimit: 4)),
        ClassFailure.invalidSettings,
      );
      // Soniya 5..300 (erkin); chegaradan tashqarisi — rad etiladi.
      for (final bad in [4, 0, 301]) {
        expect(
          await f(ClassQuizSettings(seconds: bad)),
          ClassFailure.invalidSettings,
          reason: '$bad',
        );
      }
      expect(
        await f(const ClassQuizSettings(), 'yo‘q-mavzu'),
        ClassFailure.notEnoughQuestions,
      );
      // 10 ta demo savol bor: 11 so‘ralsa yetmaydi.
      expect(
        await f(const ClassQuizSettings(questionCount: 11)),
        ClassFailure.notEnoughQuestions,
      );
    });

    test(
      'sessiya: 6 xonali kod, variantlar server tomonida aralashadi',
      () async {
        final s = await create();
        expect(s.code, matches(RegExp(r'^[0-9]{6}$')));
        expect(s.status, ClassSessionStatus.lobby);
        expect(s.total, 5);
        await join(student('s1'), s, 'Ali');
        await teacher.start(s.id);
        final d = (await teacher.dashboard(s.id)).value!;
        final cur = d.current!;
        // Aralashtirishdan keyin to‘g‘ri variant matni bankdagi bilan bir xil.
        final bank = classQuizDemoTopic.questions.firstWhere(
          (q) => q.question == cur.text,
        );
        final correctText = cur.options
            .firstWhere((o) => o.id == cur.correctOption)
            .text;
        expect(correctText, bank.options[bank.correctIndex]);
      },
    );

    test('ochiq sinflar soni cheklangan (10)', () async {
      for (var i = 0; i < 10; i++) {
        await create();
      }
      final r = await teacher.createSession(
        topicId: 'demo-topic',
        settings: const ClassQuizSettings(),
      );
      expect(r.failure, ClassFailure.tooManySessions);
    });

    test('mySessions: faqat o‘zimniki', () async {
      await create();
      expect((await teacher.mySessions()).value!.length, 1);
      expect((await other.mySessions()).value!, isEmpty);
    });
  });

  group('qo‘shilish', () {
    test('noto‘g‘ri/yo‘q kod', () async {
      final s = student('s1');
      expect(
        (await s.join(code: '12', nickname: 'Ali')).failure,
        ClassFailure.badCode,
      );
      expect(
        (await s.join(code: '000000', nickname: 'Ali')).failure,
        ClassFailure.notFound,
      );
    });

    test('laqab qoidalari va takror laqab', () async {
      final session = await create();
      final a = student('a');
      expect(
        (await a.join(code: session.code, nickname: 'A')).failure,
        ClassFailure.nickLength,
      );
      expect(
        (await a.join(code: session.code, nickname: 'Sh1t')).failure,
        ClassFailure.nickBlocked,
      );
      expect(
        (await a.join(code: session.code, nickname: 'a<b>')).failure,
        ClassFailure.nickChars,
      );
      expect((await join(a, session, ' Ali ')).nickname, 'Ali');
      expect((await join(student('b'), session, 'ali')).nickname, 'ali2');
    });

    test('qayta kirish laqabni o‘zgartirmaydi', () async {
      final session = await create();
      final a = student('a');
      final first = await join(a, session, 'Ali');
      final again = await join(a, session, 'Boshqa');
      expect(again.nickname, 'Ali');
      expect(again.participantId, first.participantId);
    });

    test(
      'chegara: 5 talabadan keyin to‘lgan; ustoz o‘zi qo‘shila olmaydi',
      () async {
        final session = await create();
        for (var i = 0; i < 5; i++) {
          await join(student('s$i'), session, 'Talaba$i');
        }
        expect(
          (await student(
            'late',
          ).join(code: session.code, nickname: 'Kech')).failure,
          ClassFailure.full,
        );
        expect(
          (await teacher.join(code: session.code, nickname: 'Ustoz')).failure,
          ClassFailure.ownSession,
        );
      },
    );

    test('boshlangan sinfga yangi talaba kirmaydi', () async {
      final session = await create();
      await join(student('a'), session, 'Ali');
      await teacher.start(session.id);
      expect(
        (await student('b').join(code: session.code, nickname: 'Vali')).failure,
        ClassFailure.alreadyStarted,
      );
      // Allaqachon a’zo bo‘lgan qayta kira oladi.
      expect(
        (await student('a').join(code: session.code, nickname: 'Ali')).ok,
        isTrue,
      );
    });

    test('kod taxmin qilish: soatiga 30 urinishdan keyin rad', () async {
      final s = student('guesser');
      for (var i = 0; i < 30; i++) {
        final f = (await s.join(code: '999999', nickname: 'Mehmon')).failure;
        expect(f, ClassFailure.notFound);
      }
      expect(
        (await s.join(code: '999999', nickname: 'Mehmon')).failure,
        ClassFailure.rateLimited,
      );
      // Soat o‘tgach yana ruxsat.
      tick(61 * 60 * 1000);
      expect(
        (await s.join(code: '999999', nickname: 'Mehmon')).failure,
        ClassFailure.notFound,
      );
    });
  });

  group('o‘yin: javob, vaqt, to‘g‘ri javobni yashirish', () {
    late ClassSessionInfo session;
    late FakeClassQuizService a;
    late FakeClassQuizService b;

    setUp(() async {
      session = await create();
      a = student('a');
      b = student('b');
      await join(a, session, 'Ali');
      await join(b, session, 'Vali');
      expect((await teacher.start(session.id)).ok, isTrue);
    });

    test('ochiq savolda to‘g‘ri javob mijozga kelmaydi', () async {
      final st = (await a.state(session.id)).value!;
      expect(st.phase, ClassPhase.open);
      expect(st.question!.options.length, 4);
      expect(st.reveal, isNull);
      expect(st.remainingMs, 30000);
      // Vaqt tugadi, lekin 1.5 s kutish oynasi ichida hali yopiq.
      tick(30500);
      final closed = (await a.state(session.id)).value!;
      expect(closed.phase, ClassPhase.closed);
      expect(closed.reveal, isNull);
      tick(1100);
      final shown = (await a.state(session.id)).value!;
      expect(shown.reveal, isNotNull);
      expect(shown.reveal!.explanation, isNotEmpty);
    });

    test('bir marta javob; ikkinchisi rad; to‘g‘riligi aytilmaydi', () async {
      final correct = await correctOf(session.id);
      final r = await a.submitAnswer(
        sessionId: session.id,
        questionIndex: 0,
        optionId: correct,
      );
      expect(r.ok, isTrue);
      final again = await a.submitAnswer(
        sessionId: session.id,
        questionIndex: 0,
        optionId: 'o0',
      );
      expect(again.failure, ClassFailure.alreadyAnswered);
      final st = (await a.state(session.id)).value!;
      expect(st.myOption, correct);
      expect(st.reveal, isNull);
      // Savol ochiq: ball/o‘rin/to‘g‘ri soni hali oshkor qilinmaydi.
      expect(st.score, 0, reason: 'ochiq savol balli hali sanalmaydi');
      expect(st.correct, 0);
      tick(31500);
      final after = (await a.state(session.id)).value!;
      expect(after.reveal, isNotNull);
      expect(after.score, 1000, reason: 'darrov to‘g‘ri javob');
      expect(after.correct, 1);
    });

    test('noto‘g‘ri savol raqami, noto‘g‘ri variant, begona sessiya', () async {
      expect(
        (await a.submitAnswer(
          sessionId: session.id,
          questionIndex: 1,
          optionId: 'o0',
        )).failure,
        ClassFailure.notCurrent,
      );
      expect(
        (await a.submitAnswer(
          sessionId: session.id,
          questionIndex: 0,
          optionId: 'o9',
        )).failure,
        ClassFailure.badOption,
      );
      expect(
        (await outsider.submitAnswer(
          sessionId: session.id,
          questionIndex: 0,
          optionId: 'o0',
        )).failure,
        ClassFailure.forbidden,
      );
      expect(
        (await outsider.state(session.id)).failure,
        ClassFailure.forbidden,
      );
    });

    test('1 s imtiyozdan keyin javob rad (server vaqti)', () async {
      tick(30800);
      expect(
        (await a.submitAnswer(
          sessionId: session.id,
          questionIndex: 0,
          optionId: 'o0',
        )).ok,
        isTrue,
        reason: 'imtiyoz ichida',
      );
      tick(1000);
      expect(
        (await b.submitAnswer(
          sessionId: session.id,
          questionIndex: 0,
          optionId: 'o0',
        )).failure,
        ClassFailure.timeOver,
      );
    });

    test('ball: vaqtga qarab; noto‘g‘ri — 0', () async {
      final correct = await correctOf(session.id);
      tick(15000);
      await a.submitAnswer(
        sessionId: session.id,
        questionIndex: 0,
        optionId: correct,
      );
      final wrong = correct == 'o0' ? 'o1' : 'o0';
      await b.submitAnswer(
        sessionId: session.id,
        questionIndex: 0,
        optionId: wrong,
      );
      expect((await a.state(session.id)).value!.score, 0, reason: 'ochiq');
      tick(16500); // muddat + 1.5 s → natija ochiladi
      expect((await a.state(session.id)).value!.score, 750);
      expect((await b.state(session.id)).value!.score, 0);
    });

    test('ustoz paneli: jonli agregatlar, talaba ko‘rmaydi', () async {
      final correct = await correctOf(session.id);
      await a.submitAnswer(
        sessionId: session.id,
        questionIndex: 0,
        optionId: correct,
      );
      final d = (await teacher.dashboard(session.id)).value!;
      expect(d.joined, 2);
      expect(d.current!.answered, 1);
      expect(d.current!.correctCount, 1);
      expect(d.current!.correctPct, 100);
      expect(d.leaderboard.first.nickname, 'Ali');
      expect((await a.dashboard(session.id)).failure, ClassFailure.forbidden);
      expect(
        (await other.dashboard(session.id)).failure,
        ClassFailure.forbidden,
      );
      expect((await a.start(session.id)).failure, ClassFailure.forbidden);
      expect((await a.next(session.id)).failure, ClassFailure.forbidden);
      expect(
        (await a.exportResults(session.id)).failure,
        ClassFailure.forbidden,
      );
    });

    test('ustoz paneli: laqabdan boshqa shaxsiy ma’lumot yo‘q', () async {
      final d = (await teacher.dashboard(session.id)).value!;
      final text = [
        for (final p in d.participants) '${p.id} ${p.nickname}',
        for (final r in d.leaderboard) r.nickname,
      ].join(' ');
      expect(text.contains('@'), isFalse);
      expect(text.contains('a'), isTrue); // laqablar bor
      expect(d.participants.map((p) => p.nickname), ['Ali', 'Vali']);
    });

    test('yopish va keyingi savol; qiyin savollar', () async {
      final correct = await correctOf(session.id);
      await a.submitAnswer(
        sessionId: session.id,
        questionIndex: 0,
        optionId: correct,
      );
      await b.submitAnswer(
        sessionId: session.id,
        questionIndex: 0,
        optionId: correct == 'o0' ? 'o1' : 'o0',
      );
      expect((await teacher.closeQuestion(session.id)).ok, isTrue);
      var d = (await teacher.dashboard(session.id)).value!;
      expect(d.phase, ClassPhase.closed);
      expect(d.hardest.single.correctPct, 50);
      final st = (await a.state(session.id)).value!;
      expect(st.reveal, isNotNull, reason: 'ustoz yopgach darrov ochiladi');
      expect((await teacher.next(session.id)).value, isFalse);
      d = (await teacher.dashboard(session.id)).value!;
      expect(d.session.currentIndex, 1);
      // Eski savolga javob — rad.
      expect(
        (await a.submitAnswer(
          sessionId: session.id,
          questionIndex: 0,
          optionId: 'o0',
        )).failure,
        ClassFailure.notCurrent,
      );
    });

    test(
      'chiqarish: talaba holatda ko‘radi, javob bera olmaydi, qayta kirmaydi',
      () async {
        final d = (await teacher.dashboard(session.id)).value!;
        final bobId = d.participants.firstWhere((p) => p.nickname == 'Vali').id;
        expect((await teacher.kick(session.id, bobId)).ok, isTrue);
        expect((await teacher.dashboard(session.id)).value!.joined, 1);
        expect((await b.state(session.id)).value!.kicked, isTrue);
        expect(
          (await b.submitAnswer(
            sessionId: session.id,
            questionIndex: 0,
            optionId: 'o0',
          )).failure,
          ClassFailure.forbidden,
        );
        expect(
          (await b.join(code: session.code, nickname: 'Vali')).failure,
          ClassFailure.kicked,
        );
      },
    );

    test('laqabga shikoyat', () async {
      final d = (await teacher.dashboard(session.id)).value!;
      final id = d.participants.last.id;
      expect(
        (await a.reportNickname(
          sessionId: session.id,
          participantId: id,
          reason: 'x',
        )).failure,
        ClassFailure.badReason,
      );
      expect(
        (await a.reportNickname(
          sessionId: session.id,
          participantId: id,
          reason: 'Nomaqbul laqab',
        )).ok,
        isTrue,
      );
      expect(
        (await outsider.reportNickname(
          sessionId: session.id,
          participantId: id,
          reason: 'Nomaqbul laqab',
        )).failure,
        ClassFailure.forbidden,
      );
      expect((await teacher.dashboard(session.id)).value!.reports, 1);
    });
  });

  group('to‘liq oqim va natijalar', () {
    test(
      '5 savol → tugash → natija, xato savol izohi va manbasi, CSV',
      () async {
        final session = await create();
        final a = student('a');
        final b = student('b');
        await join(a, session, 'Ali');
        await join(b, session, 'Vali');
        await teacher.start(session.id);
        for (var q = 0; q < 5; q++) {
          final correct = await correctOf(session.id);
          // Ali — hammasiga to‘g‘ri; Vali — faqat 0-savolga to‘g‘ri.
          await a.submitAnswer(
            sessionId: session.id,
            questionIndex: q,
            optionId: correct,
          );
          if (q == 0) {
            await b.submitAnswer(
              sessionId: session.id,
              questionIndex: q,
              optionId: correct,
            );
          } else if (q == 1) {
            await b.submitAnswer(
              sessionId: session.id,
              questionIndex: q,
              optionId: correct == 'o0' ? 'o1' : 'o0',
            );
          }
          tick(2000);
          final r = await teacher.next(session.id);
          expect(r.value, q == 4, reason: 'faqat oxirgisida tugaydi');
        }

        // Tugamaguncha natija yo‘q; tugagach bor.
        final res = (await b.myResults(session.id)).value!;
        expect(res.total, 5);
        expect(res.correct, 1);
        expect(res.rank, 2);
        expect(res.participants, 2);
        expect(res.mistakes.length, 4);
        final wrongOne = res.items[1];
        expect(wrongOne.isCorrect, isFalse);
        expect(wrongOne.explanation, isNotEmpty);
        expect(wrongOne.source.author, 'DEMO');
        expect(res.items[2].unanswered, isTrue);

        final st = (await a.state(session.id)).value!;
        expect(st.status, ClassSessionStatus.finished);
        expect(st.leaderboard.first.nickname, 'Ali');
        expect(st.leaderboard.first.rank, 1);

        final ex = (await teacher.exportResults(session.id)).value!;
        expect(ex.rows.map((r) => r.nickname), ['Ali', 'Vali']);
        expect(ex.rows.first.correct, 5);
        expect(ex.rows.first.score, greaterThan(ex.rows.last.score));
        final csv = ClassResultsCsv.build(ex.rows);
        expect(csv.split('\r\n').first, ClassResultsCsv.header);
        expect(csv, contains('Ali,'));
      },
    );

    test('natija tugamaguncha berilmaydi', () async {
      final session = await create();
      final a = student('a');
      await join(a, session, 'Ali');
      expect((await a.myResults(session.id)).failure, ClassFailure.notFinished);
      await teacher.start(session.id);
      expect((await a.myResults(session.id)).failure, ClassFailure.notFinished);
    });

    test('ustoz tugatsa — barcha talaba natija ko‘radi', () async {
      final session = await create();
      final a = student('a');
      await join(a, session, 'Ali');
      await teacher.start(session.id);
      expect((await teacher.finish(session.id)).ok, isTrue);
      expect((await a.myResults(session.id)).ok, isTrue);
      expect(
        (await student(
          'late',
        ).join(code: session.code, nickname: 'Kech')).failure,
        ClassFailure.finished,
      );
    });

    test('30 kundan keyin tozalash', () async {
      final session = await create();
      await join(student('a'), session, 'Ali');
      await teacher.start(session.id);
      await teacher.finish(session.id);
      tick(29 * 24 * 3600 * 1000);
      expect(backend.cleanup(), 0);
      tick(2 * 24 * 3600 * 1000);
      expect(backend.cleanup(), 1);
      expect(backend.sessionCount, 0);
    });
  });

  group('demo rejimi', () {
    test('DEMO ishtirokchilar vaqt o‘tishi bilan javob beradi', () async {
      final demo = FakeClassQuizBackend(
        clock: () => now,
        rng: Random(3),
        teachers: {'u'},
        allowSelfJoin: true,
        demoBots: 3,
      );
      final svc = FakeClassQuizService(demo, userId: 'u');
      final s = (await svc.createSession(
        topicId: 'demo-topic',
        settings: const ClassQuizSettings(questionCount: 5),
      )).value!;
      expect((await svc.dashboard(s.id)).value!.joined, 3);
      // Ustoz o‘z sinfiga demo’da qo‘shila oladi.
      expect((await svc.join(code: s.code, nickname: 'Men')).ok, isTrue);
      await svc.start(s.id);
      tick(10000);
      final d = (await svc.dashboard(s.id)).value!;
      expect(d.current!.answered, 3);
    });
  });
}
