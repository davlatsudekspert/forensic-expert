import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/remote/supabase_class_quiz.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';

import '../helpers/referral_fakes.dart';

class _Transport implements RestTransport {
  final calls = <({String path, Object? body})>[];

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async {
    calls.add((path: uri.path, body: jsonBody));
    return const RestResponse(200, {
      'ok': true,
      'finished': true,
      'session': {
        'id': 's1',
        'code': '123456',
        'status': 'lobby',
        'topic_title': 'T',
        'total': 5,
        'student_limit': 30,
        'seconds': 30,
        'pace': 'self',
      },
    });
  }
}

/// «Har kim o‘z tezligida» rejimi: fake backend = SQL funksiyalarining nusxasi
/// (haqiqiy SQL testi: supabase/tests/class_quiz_self_pace_test.sql).
void main() {
  late DateTime now;
  late FakeClassQuizBackend backend;
  late FakeClassQuizService teacher;
  late FakeClassQuizService a;
  late FakeClassQuizService b;
  late FakeClassQuizService outsider;

  void tick(int ms) => now = now.add(Duration(milliseconds: ms));

  FakeClassQuizService svc(String id) => FakeClassQuizService(
    backend,
    userId: id,
    demo: false,
    signInRequired: true,
  );

  Future<ClassSessionInfo> create(ClassPace pace) async {
    final r = await teacher.createSession(
      topicId: 'demo-topic',
      settings: ClassQuizSettings(
        questionCount: 5,
        studentLimit: 10,
        seconds: 30,
        pace: pace,
      ),
    );
    expect(r.ok, isTrue, reason: '${r.failure}');
    return r.value!;
  }

  Future<void> joinAll(ClassSessionInfo s) async {
    for (final (u, n) in [(a, 'Aziza'), (b, 'Bobur')]) {
      final r = await u.join(code: s.code, nickname: n);
      expect(r.ok, isTrue, reason: '${r.failure}');
    }
    expect((await teacher.start(s.id)).ok, isTrue);
  }

  /// Talabaning hozirgi savoli uchun to‘g‘ri/noto‘g‘ri variant.
  Future<String> optionFor(
    FakeClassQuizService u,
    String sid, {
    required bool right,
  }) async {
    final q = (await u.state(sid)).value!.question!;
    // To‘g‘ri javob faqat ustoz uchun emas: fake backend ichidan olinadi.
    final correct = backend.debugCorrectOption(sid, q.index);
    return right ? correct : q.options.firstWhere((o) => o.id != correct).id;
  }

  setUp(() async {
    now = DateTime(2026, 10, 31, 10);
    backend = FakeClassQuizBackend(
      clock: () => now,
      rng: Random(7),
      teachers: {'t1'},
    );
    teacher = FakeClassQuizService(backend, userId: 't1', demo: false);
    a = svc('a');
    b = svc('b');
    outsider = svc('out');
  });

  test('standart rejim — ustoz boshqaradi (o‘zgarmagan)', () async {
    expect(const ClassQuizSettings().pace, ClassPace.host);
    final s = await create(ClassPace.host);
    expect(s.pace, ClassPace.host);
    await joinAll(s);
    final st = (await a.state(s.id)).value!;
    expect(st.selfStage, isNull);
    expect(st.question!.index, 0);
    expect(st.phase, ClassPhase.open);
    // nextMine host rejimda rad etiladi
    expect((await a.nextMine(s.id)).failure, ClassFailure.badState);
    expect((await teacher.next(s.id)).ok, isTrue);
  });

  test('self: ustoz «Keyingi» / «Savolni yopish» ishlamaydi', () async {
    final s = await create(ClassPace.self);
    expect(s.pace, ClassPace.self);
    await joinAll(s);
    expect((await teacher.next(s.id)).failure, ClassFailure.badState);
    expect((await teacher.closeQuestion(s.id)).failure, ClassFailure.badState);
  });

  test(
    'self: boshlashdan oldin savol matni berilmaydi, taymer yurmaydi',
    () async {
      final s = await create(ClassPace.self);
      await joinAll(s);
      final st = (await a.state(s.id)).value!;
      expect(st.selfStage, ClassSelfStage.ready);
      expect(st.question, isNull);
      expect(
        (await a.submitAnswer(
          sessionId: s.id,
          questionIndex: 0,
          optionId: 'o0',
        )).failure,
        ClassFailure.notCurrent,
      );
      tick(120000); // 2 daqiqa o‘tdi — hali ochmagan, vaqt ketmaydi
      expect((await a.nextMine(s.id)).ok, isTrue);
      final open = (await a.state(s.id)).value!;
      expect(open.phase, ClassPhase.open);
      expect(open.remainingMs, 30000);
    },
  );

  test('self: ikki talaba mustaqil — birinchisi tez yechsa ikkinchisi kutmaydi', () async {
    final s = await create(ClassPace.self);
    await joinAll(s);
    await a.nextMine(s.id);
    tick(500);
    await b.nextMine(s.id);
    // A javob beradi va o‘zi keyingisiga o‘tadi
    final optA = await optionFor(a, s.id, right: true);
    final qa0 = (await a.state(s.id)).value!.question!.index;
    expect(
      (await a.submitAnswer(
        sessionId: s.id,
        questionIndex: qa0,
        optionId: optA,
      )).ok,
      isTrue,
    );
    expect((await a.nextMine(s.id)).value, isFalse);
    final a1 = (await a.state(s.id)).value!;
    expect(a1.position, 1);
    expect(a1.phase, ClassPhase.open);
    expect(a1.reveal, isNull);
    // B hali 1-savolida, o‘z vaqti bilan, hech narsa o‘zgarmagan
    final b0 = (await b.state(s.id)).value!;
    expect(b0.position, 0);
    expect(b0.phase, ClassPhase.open);
    expect(b0.myOption, isNull);
    expect(b0.reveal, isNull);
    // B ning vaqti A ning o‘tishiga bog‘liq emas: o‘zi ochgan paytdan sanaladi.
    tick(2000);
    expect((await b.state(s.id)).value!.remainingMs, 28000);
    expect((await a.state(s.id)).value!.remainingMs, 28000);
  });

  test(
    'self: tanlov tasdiqlanmaguncha serverda javob yo‘q; avto-o‘tish yo‘q',
    () async {
      final s = await create(ClassPace.self);
      await joinAll(s);
      await a.nextMine(s.id);
      // Faqat tanlash — mijoz hech narsa yubormaydi: serverda javob 0
      expect(
        (await teacher.dashboard(s.id)).value!.participants
            .firstWhere((p) => p.nickname == 'Aziza')
            .progress!
            .answered,
        0,
      );
      // Javobsiz keyingisiga o‘tib bo‘lmaydi
      expect((await a.nextMine(s.id)).failure, ClassFailure.notClosed);
      expect((await a.state(s.id)).value!.position, 0);
      // Vaqt o‘tib ketsa ham o‘zi o‘tmaydi (holat o‘zgarmaydi)
      tick(31000);
      final st = (await a.state(s.id)).value!;
      expect(st.position, 0);
      expect(st.phase, ClassPhase.closed);
      // Tugagach o‘zi o‘ta oladi
      expect((await a.nextMine(s.id)).ok, isTrue);
      expect((await a.state(s.id)).value!.position, 1);
    },
  );

  test(
    'self: to‘g‘ri javob faqat o‘z javobi/vaqti yopilgach beriladi',
    () async {
      final s = await create(ClassPace.self);
      await joinAll(s);
      await a.nextMine(s.id);
      var st = (await a.state(s.id)).value!;
      expect(st.reveal, isNull);
      final q = st.question!;
      final opt = await optionFor(a, s.id, right: false);
      await a.submitAnswer(
        sessionId: s.id,
        questionIndex: q.index,
        optionId: opt,
      );
      st = (await a.state(s.id)).value!;
      expect(st.reveal, isNotNull);
      expect(st.reveal!.myCorrect, isFalse);
      expect(st.myOption, opt);
      // takroriy javob taqiqlangan
      expect(
        (await a.submitAnswer(
          sessionId: s.id,
          questionIndex: q.index,
          optionId: opt,
        )).failure,
        ClassFailure.alreadyAnswered,
      );
      // B: javob bermagan, vaqti o‘tgan: 30.4 s da hali ochilmaydi, 31.6 s da ochiladi
      await b.nextMine(s.id);
      tick(30400);
      expect((await b.state(s.id)).value!.reveal, isNull);
      tick(1300);
      expect((await b.state(s.id)).value!.reveal, isNotNull);
    },
  );

  test('self: vaqt tugagach javob rad etiladi (o‘z soati bo‘yicha)', () async {
    final s = await create(ClassPace.self);
    await joinAll(s);
    await a.nextMine(s.id);
    await b.nextMine(s.id);
    tick(20000);
    // B shu paytda javob bera oladi, A ham; keyin A uchun vaqt tugaydi
    final qa = (await a.state(s.id)).value!.question!;
    tick(11500);
    expect(
      (await a.submitAnswer(
        sessionId: s.id,
        questionIndex: qa.index,
        optionId: 'o0',
      )).failure,
      ClassFailure.timeOver,
    );
  });

  test('self: ball talabaning o‘z vaqtidan hisoblanadi', () async {
    final s = await create(ClassPace.self);
    await joinAll(s);
    await a.nextMine(s.id);
    tick(20000);
    await b.nextMine(s.id); // B 20 s keyin ochdi
    final oa = await optionFor(a, s.id, right: true);
    final ob = await optionFor(b, s.id, right: true);
    final qa = (await a.state(s.id)).value!.question!.index;
    final qb = (await b.state(s.id)).value!.question!.index;
    await a.submitAnswer(sessionId: s.id, questionIndex: qa, optionId: oa);
    await b.submitAnswer(sessionId: s.id, questionIndex: qb, optionId: ob);
    final pa = (await a.state(s.id)).value!.reveal!.myPoints;
    final pb = (await b.state(s.id)).value!.reveal!.myPoints;
    expect(
      pa,
      ClassScoring.points(correct: true, elapsedMs: 20000, limitMs: 30000),
    );
    expect(pb, 1000);
  });

  test(
    'self: har talabaga savollar tartibi alohida, javoblar asl indeks bilan',
    () async {
      final s = await create(ClassPace.self);
      await joinAll(s);
      final firsts = <int>{};
      final orders = <List<int>>[];
      for (final u in [a, b]) {
        final seq = <int>[];
        await u.nextMine(s.id);
        for (var i = 0; i < 5; i++) {
          final st = (await u.state(s.id)).value!;
          seq.add(st.question!.index);
          final o = await optionFor(u, s.id, right: true);
          await u.submitAnswer(
            sessionId: s.id,
            questionIndex: st.question!.index,
            optionId: o,
          );
          final fin = (await u.nextMine(s.id)).value!;
          expect(fin, i == 4);
        }
        expect(seq.toSet(), {0, 1, 2, 3, 4});
        orders.add(seq);
        firsts.add(seq.first);
      }
      expect(orders[0], isNot(orders[1]));
    },
  );

  test('self: tugatgach o‘z natijasi (o‘z tartibida), reyting faqat sessiya tugagach', () async {
    final s = await create(ClassPace.self);
    await joinAll(s);
    await a.nextMine(s.id);
    // B tugatmagan: natija yopiq
    await b.nextMine(s.id);
    expect((await b.myResults(s.id)).failure, ClassFailure.notFinished);
    for (var i = 0; i < 5; i++) {
      final st = (await a.state(s.id)).value!;
      final o = await optionFor(a, s.id, right: i != 2);
      await a.submitAnswer(
        sessionId: s.id,
        questionIndex: st.question!.index,
        optionId: o,
      );
      await a.nextMine(s.id);
    }
    final done = (await a.state(s.id)).value!;
    expect(done.selfStage, ClassSelfStage.done);
    expect(done.question, isNull);
    final res = (await a.myResults(s.id)).value!;
    expect(res.correct, 4);
    expect(res.total, 5);
    expect(res.rank, isNull);
    expect([for (final i in res.items) i.index], [0, 1, 2, 3, 4]);
    expect(res.mistakes, hasLength(1));
    // «Tugatilgan» talaba boshqa talaba ma’lumotini ko‘rmaydi
    expect(done.leaderboard, isEmpty);
    expect(done.rank, isNull);
    // Ustoz yopgach reyting va o‘rin chiqadi
    expect((await teacher.finish(s.id)).ok, isTrue);
    final fin = (await b.state(s.id)).value!;
    expect(fin.status, ClassSessionStatus.finished);
    expect(fin.leaderboard, hasLength(2));
    expect(fin.leaderboard.first.nickname, 'Aziza');
    expect((await b.myResults(s.id)).value!.rank, isNotNull);
  });

  test('self: ustoz doskasi — har talabaning progressi va reyting', () async {
    final s = await create(ClassPace.self);
    await joinAll(s);
    var d = (await teacher.dashboard(s.id)).value!;
    expect(d.session.pace, ClassPace.self);
    expect(d.current, isNull);
    expect(d.selfOpened, 0);
    await a.nextMine(s.id);
    final o = await optionFor(a, s.id, right: true);
    final q = (await a.state(s.id)).value!.question!.index;
    await a.submitAnswer(sessionId: s.id, questionIndex: q, optionId: o);
    await a.nextMine(s.id);
    d = (await teacher.dashboard(s.id)).value!;
    expect(d.selfOpened, 1);
    expect(d.selfDone, 0);
    final pa = d.participants
        .firstWhere((p) => p.nickname == 'Aziza')
        .progress!;
    expect((pa.position, pa.answered, pa.correct, pa.done), (2, 1, 1, false));
    final pb = d.participants
        .firstWhere((p) => p.nickname == 'Bobur')
        .progress!;
    expect(pb.started, isFalse);
    expect(d.leaderboard.first.nickname, 'Aziza');
    expect(d.leaderboard.first.score, greaterThan(900));
  });

  test('self: boshqa foydalanuvchi va ustoz rollari (403)', () async {
    final s = await create(ClassPace.self);
    await joinAll(s);
    expect((await outsider.nextMine(s.id)).failure, ClassFailure.forbidden);
    expect((await outsider.state(s.id)).failure, ClassFailure.forbidden);
    expect((await a.dashboard(s.id)).failure, ClassFailure.forbidden);
    expect((await teacher.nextMine(s.id)).failure, ClassFailure.forbidden);
  });

  test('self: demo botlar o‘z sur’atida ishlaydi va mustaqil', () async {
    final bots = FakeClassQuizBackend(
      clock: () => now,
      rng: Random(3),
      teachers: {'t1'},
      demoBots: 3,
    );
    final t = FakeClassQuizService(bots, userId: 't1', demo: false);
    final r = await t.createSession(
      topicId: 'demo-topic',
      settings: const ClassQuizSettings(
        questionCount: 5,
        studentLimit: 10,
        seconds: 30,
        pace: ClassPace.self,
      ),
    );
    final sid = r.value!.id;
    expect((await t.start(sid)).ok, isTrue);
    tick(6000);
    final d = (await t.dashboard(sid)).value!;
    final pos = [for (final p in d.participants) p.progress!.answered];
    expect(pos.first, greaterThan(pos.last)); // tezkor bot oldinda
    tick(120000);
    final d2 = (await t.dashboard(sid)).value!;
    expect(d2.selfDone, 3);
  });

  group('Supabase adapteri', () {
    test('self: class_create_session_pace + p_pace; host: eski RPC', () async {
      final auth = await signedInMockAuth();
      final tr = _Transport();
      final svc = SupabaseClassQuizService(
        config: SupabaseConfig(
          url: Uri.parse('https://fe-test.supabase.co/'),
          anonKey: 'anon',
        ),
        auth: auth,
        transport: tr,
      );
      final r = await svc.createSession(
        topicId: 'x',
        settings: const ClassQuizSettings(pace: ClassPace.self),
      );
      expect(r.value!.pace, ClassPace.self);
      expect(tr.calls.last.path, '/rest/v1/rpc/class_create_session_pace');
      expect((tr.calls.last.body as Map)['p_pace'], 'self');
      await svc.createSession(
        topicId: 'x',
        settings: const ClassQuizSettings(),
      );
      expect(tr.calls.last.path, '/rest/v1/rpc/class_create_session');
      expect((tr.calls.last.body as Map).containsKey('p_pace'), isFalse);
      expect((await svc.nextMine('s1')).value, isTrue);
      expect(tr.calls.last.path, '/rest/v1/rpc/class_next_mine');
    });
  });

  test('modellar: eski server (pace/stage yo‘q) host sifatida o‘qiladi', () {
    final st = ClassStudentState.fromJson({
      'id': 's',
      'status': 'running',
      'phase': 'open',
      'question': {'index': 0, 'text': 'q', 'options': <Object?>[]},
    });
    expect(st.selfStage, isNull);
    expect(st.session.pace, ClassPace.host);
    expect(ClassFailure.fromServer('not_closed'), ClassFailure.notClosed);
    final p = ClassParticipant.fromJson({'id': 'p', 'nickname': 'x'});
    expect(p.progress, isNull);
  });
}
