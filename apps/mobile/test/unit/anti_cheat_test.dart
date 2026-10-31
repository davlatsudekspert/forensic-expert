import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/class_groups/fake_class_groups_service.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/anti_cheat/anti_cheat_rules.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';

import 'class_groups_test.dart' show topic;

GroupBoardRow _row({
  int? score = 9,
  int? total = 10,
  int spentSec = 20,
  BoardState state = BoardState.finished,
}) => GroupBoardRow(
  memberId: 'm',
  nickname: 'Ali',
  state: state,
  score: score,
  total: total,
  startedAt: DateTime(2026, 10, 31, 10),
  submittedAt: DateTime(2026, 10, 31, 10).add(Duration(seconds: spentSec)),
);

void main() {
  group('«tez va to‘g‘ri» qoidasi (yagona funksiya)', () {
    bool f(int correct, int total, int avgMs) => looksTooFastAndCorrect(
      correct: correct,
      total: total,
      avgPerQuestion: Duration(milliseconds: avgMs),
    );

    test('chegaralar: ball >= 80% VA o‘rtacha < 2.5 s', () {
      expect(AntiCheatRules.highScoreFraction, 0.8);
      expect(AntiCheatRules.minAvgSecondsPerQuestion, 2.5);
      expect(f(10, 10, 2000), isTrue);
      expect(f(8, 10, 2499), isTrue); // aynan 80%
      expect(f(8, 10, 2500), isFalse); // 2.5 s — hali shubhali emas
      expect(f(7, 10, 1000), isFalse); // 70% — ball yetmaydi
      expect(f(10, 10, 6000), isFalse); // sekin — odatiy
    });

    test('juda kam savol yoki noma’lum vaqt — belgi yo‘q', () {
      expect(f(3, 3, 500), isFalse);
      expect(f(4, 4, 500), isFalse);
      expect(f(5, 5, 500), isTrue);
      expect(f(10, 10, 0), isFalse);
      expect(f(10, 10, -5), isFalse);
      expect(f(0, 0, 100), isFalse);
    });

    test('guruh testi: sarflangan vaqt / savollar soni', () {
      // 10 savol, 20 s => 2 s/savol, 9/10
      expect(groupRowLooksTooFast(_row()), isTrue);
      // 10 savol, 25 s => aynan 2.5 s — belgi yo‘q
      expect(groupRowLooksTooFast(_row(spentSec: 25)), isFalse);
      // past ball
      expect(groupRowLooksTooFast(_row(score: 6)), isFalse);
      // tugatmagan (spent == null)
      expect(
        groupRowLooksTooFast(_row(state: BoardState.solving, score: null)),
        isFalse,
      );
      // ma’lumot yo‘q
      expect(groupRowLooksTooFast(_row(total: null)), isFalse);
      expect(groupRowLooksTooFast(_row(total: 0)), isFalse);
    });

    test('jonli sinf: avg_ms (to‘g‘ri javoblar) bo‘yicha', () {
      ClassLeaderRow r({int? avg, int correct = 9}) => ClassLeaderRow(
        participantId: 'p',
        nickname: 'Ali',
        score: 5000,
        correct: correct,
        rank: 1,
        avgMs: avg,
      );
      expect(classLeaderLooksTooFast(r(avg: 1800), 10), isTrue);
      expect(classLeaderLooksTooFast(r(avg: 3000), 10), isFalse);
      expect(classLeaderLooksTooFast(r(avg: null), 10), isFalse);
      expect(classLeaderLooksTooFast(r(avg: 1800, correct: 5), 10), isFalse);
    });
  });

  group('savol soni maslahati', () {
    test('hovuz < 2 × savol => ogohlantirish, tavsiya <= 15', () {
      var a = questionCountAdvice(poolSize: 24, count: 20);
      expect(a.warn, isTrue);
      expect(a.recommended, 12);
      a = questionCountAdvice(poolSize: 100, count: 50);
      expect(a.warn, isFalse);
      a = questionCountAdvice(poolSize: 100, count: 51);
      expect(a.warn, isTrue);
      expect(a.recommended, 15);
      a = questionCountAdvice(poolSize: 8, count: 6);
      expect(a.warn, isTrue);
      expect(a.recommended, 4);
      a = questionCountAdvice(poolSize: 24, count: 12);
      expect(a.warn, isFalse); // aynan 2×
    });

    test('minCount: tavsiya testning eng kam savol sonidan kichik emas', () {
      // Jonli sinf: kamida 5 ta savol; hovuz 6 => tavsiya 5 (3 emas).
      final a = questionCountAdvice(poolSize: 6, count: 6, minCount: 5);
      expect(a.warn, isTrue);
      expect(a.recommended, 5);
      // Hovuzdan katta tavsiya bo‘lmaydi.
      expect(
        questionCountAdvice(poolSize: 4, count: 4, minCount: 5).recommended,
        4,
      );
    });

    test('tavsiya hech qachon 15 dan oshmaydi va 1 dan kam emas', () {
      for (final pool in [0, 1, 2, 5, 30, 31, 200]) {
        for (final count in [1, 5, 15, 16, 50, 200]) {
          final a = questionCountAdvice(poolSize: pool, count: count);
          expect(a.recommended, inInclusiveRange(1, 15));
        }
      }
    });
  });

  group('server javoblari', () {
    test('GroupBoardRow: leave_count / last_left_at (eski serverda 0)', () {
      final j = GroupBoardRow.fromJson({
        'member_id': 'm',
        'nickname': 'Ali',
        'state': 'finished',
        'leave_count': 3,
        'last_left_at': '2026-10-31T10:00:00Z',
      });
      expect(j.leaveCount, 3);
      expect(j.lastLeftAt, DateTime.utc(2026, 10, 31, 10));
      final old = GroupBoardRow.fromJson({'member_id': 'm', 'nickname': 'A'});
      expect(old.leaveCount, 0);
      expect(old.lastLeftAt, isNull);
    });

    test('ClassParticipant: leave_count / last_left_at (eski serverda 0)', () {
      final p = ClassParticipant.fromJson({
        'id': 'p',
        'nickname': 'Ali',
        'leave_count': 2,
        'last_left_at': '2026-10-31T10:00:00Z',
      });
      expect(p.leaveCount, 2);
      expect(p.lastLeftAt, isNotNull);
      final old = ClassParticipant.fromJson({'id': 'p', 'nickname': 'A'});
      expect(old.leaveCount, 0);
    });
  });

  group('jonli sinf fake: erkin soniya va chiqish hisobi', () {
    late DateTime now;
    late FakeClassQuizBackend backend;
    late FakeClassQuizService teacher;
    late FakeClassQuizService a;
    late FakeClassQuizService outsider;

    FakeClassQuizService svc(String id) => FakeClassQuizService(
      backend,
      userId: id,
      demo: false,
      signInRequired: true,
    );

    setUp(() {
      now = DateTime(2026, 10, 31, 10);
      backend = FakeClassQuizBackend(
        clock: () => now,
        rng: Random(3),
        teachers: {'t1'},
      );
      teacher = FakeClassQuizService(backend, userId: 't1', demo: false);
      a = svc('a');
      outsider = svc('out');
    });

    Future<ClassSessionInfo> create(int seconds, {ClassPace? pace}) async {
      final r = await teacher.createSession(
        topicId: 'demo-topic',
        settings: ClassQuizSettings(
          questionCount: 5,
          studentLimit: 5,
          seconds: seconds,
          pace: pace ?? ClassPace.host,
        ),
      );
      expect(r.ok, isTrue, reason: '$seconds ${r.failure}');
      return r.value!;
    }

    test('soniya 5..300: 5, 20, 90, 300 qabul; 4 va 301 rad', () async {
      for (final s in [5, 20, 90, 300]) {
        final info = await create(s);
        expect(info.seconds, s);
        await teacher.finish(info.id); // 10 ta ochiq sinf chegarasi
      }
      for (final bad in [4, 301, 0, -3]) {
        final r = await teacher.createSession(
          topicId: 'demo-topic',
          settings: ClassQuizSettings(
            questionCount: 5,
            studentLimit: 5,
            seconds: bad,
          ),
        );
        expect(r.failure, ClassFailure.invalidSettings, reason: '$bad');
      }
    });

    test(
      'host: lobbida sanalmaydi, test ketayotganda sanaladi (1 s limit)',
      () async {
        final s = await create(20);
        await a.join(code: s.code, nickname: 'Aziza');
        await a.reportLeave(s.id);
        var d = (await teacher.dashboard(s.id)).value!;
        expect(d.participants.single.leaveCount, 0);
        await teacher.start(s.id);
        expect((await a.reportLeave(s.id)).ok, isTrue);
        // 1 soniya ichida takror — sanalmaydi
        now = now.add(const Duration(milliseconds: 500));
        await a.reportLeave(s.id);
        now = now.add(const Duration(seconds: 2));
        await a.reportLeave(s.id);
        d = (await teacher.dashboard(s.id)).value!;
        expect(d.participants.single.leaveCount, 2);
        expect(d.participants.single.lastLeftAt, isNotNull);
        expect(d.leaveCountOf(d.participants.single.id), 2);
        expect(d.leaveCountOf('yo‘q'), 0);
      },
    );

    test(
      'begona foydalanuvchi — forbidden; talaba natijasida maydon yo‘q',
      () async {
        final s = await create(20);
        await a.join(code: s.code, nickname: 'Aziza');
        await teacher.start(s.id);
        expect(
          (await outsider.reportLeave(s.id)).failure,
          ClassFailure.forbidden,
        );
      },
    );

    test('self rejim: savol ochilmaguncha sanalmaydi, tugagach ham', () async {
      final s = await create(30, pace: ClassPace.self);
      await a.join(code: s.code, nickname: 'Aziza');
      await teacher.start(s.id);
      await a.reportLeave(s.id); // hali savol ochmagan
      var d = (await teacher.dashboard(s.id)).value!;
      expect(d.participants.single.leaveCount, 0);
      await a.nextMine(s.id); // birinchi savol
      now = now.add(const Duration(seconds: 2));
      await a.reportLeave(s.id);
      d = (await teacher.dashboard(s.id)).value!;
      expect(d.participants.single.leaveCount, 1);
    });
  });

  group('guruh testi fake: chiqish hisobi', () {
    late DateTime now;
    late FakeClassGroupsBackend backend;
    late String gid;
    late String aid;

    setUp(() async {
      now = DateTime(2026, 10, 31, 10);
      backend = FakeClassGroupsBackend(
        topics: () async => [topic('t1', 12)],
        teachers: {'teacher'},
        clock: () => now,
      );
      final g = backend.create('teacher', 'Guruh').value!;
      gid = g.id;
      backend.join('stu', code: g.code!, nickname: 'Ali');
      aid = (await backend.createAssignment(
        'teacher',
        gid,
        const AssignmentDraft(
          topicId: 't1',
          questionCount: 5,
          timeLimitMin: 15,
          variantMode: false,
        ),
      )).value!.id;
    });

    GroupBoardRow row() => backend.board('teacher', aid).value!.rows.single;

    test('urinish yo‘q — sanalmaydi; ochilgach sanaladi; 1 s limit', () {
      expect(backend.reportLeave('stu', aid).ok, isTrue);
      expect(row().leaveCount, 0);
      backend.open('stu', aid);
      backend.reportLeave('stu', aid);
      backend.reportLeave('stu', aid); // shu soniyada — sanalmaydi
      expect(row().leaveCount, 1);
      now = now.add(const Duration(seconds: 3));
      backend.reportLeave('stu', aid);
      expect(row().leaveCount, 2);
      expect(row().lastLeftAt, now);
    });

    test('yuborilgach sanalmaydi; a’zo bo‘lmasa forbidden', () {
      backend.open('stu', aid);
      now = now.add(const Duration(seconds: 3));
      backend.submit('stu', aid, const {});
      now = now.add(const Duration(seconds: 3));
      backend.reportLeave('stu', aid);
      expect(row().leaveCount, 0);
      expect(
        backend.reportLeave('begona', aid).failure,
        GroupFailure.forbidden,
      );
    });

    test('ustoz doskasida tez va to‘g‘ri belgisi uchun vaqtlar bor', () {
      final att = backend.open('stu', aid).value!;
      // 3 s ichida hammasini to‘g‘ri belgilab yuboradi (5 savol => 0.6 s/savol)
      final answers = <String, int>{};
      final pool = backend.preview('teacher', aid).value!.pool;
      for (final q in att.questions) {
        answers[q.id] = pool.firstWhere((p) => p.id == q.id).correctIndex;
      }
      now = now.add(const Duration(seconds: 3));
      backend.submit('stu', aid, answers);
      final r = row();
      expect(r.score, 5);
      expect(groupRowLooksTooFast(r), isTrue);
    });
  });
}
