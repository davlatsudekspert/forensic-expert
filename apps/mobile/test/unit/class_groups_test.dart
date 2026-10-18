import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/widgets/in_bounds_scroll.dart';
import 'package:forensic_expert/data/class_groups/fake_class_groups_service.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_demo_bank.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/class_groups/variant_draw.dart';

import '../helpers/pump_app.dart' show completedSettings;

/// Umumiy test vektorlari (Python generatori, SQL testi va shu Dart testi).
List<Map<String, Object?>> loadVectors() {
  final j = jsonDecode(
    File('test/fixtures/class_group_variant_vectors.json').readAsStringSync(),
  ) as Map<String, Object?>;
  return [for (final c in j['cases']! as List) (c as Map).cast()];
}

ClassBankTopic topic(String id, int n) => ClassBankTopic(
  id: id,
  title: 'Mavzu $id',
  questions: [
    for (var i = 0; i < n; i++)
      ClassBankQuestion(
        question: 'Savol $i',
        options: ['A$i', 'B$i', 'C$i', 'D$i'],
        correctIndex: i % 4,
        explanation: 'Izoh $i',
        source: const ClassSource(
          author: 'Muallif',
          title: 'Darslik',
          page: '9',
        ),
      ),
  ],
);

void main() {
  group('variant tanlovi (server bilan bir xil)', () {
    test('Dart drawVariant == umumiy vektorlar', () {
      final cases = loadVectors();
      expect(cases.length, greaterThanOrEqualTo(10));
      for (final c in cases) {
        expect(
          drawVariant(
            assignmentId: c['assignment_id']! as String,
            userId: c['user_id']! as String,
            pool: [for (final q in c['pool']! as List) q as String],
            count: c['n']! as int,
          ),
          [for (final q in c['expected']! as List) q as String],
          reason: '${c['assignment_id']} / ${c['user_id']}',
        );
      }
    });

    test('hovuz tartibiga bog‘liq emas; 3 talaba — 3 xil to‘plam', () {
      final pool = [for (var i = 0; i < 30; i++) 'q$i'];
      final a = drawVariant(
        assignmentId: 'A',
        userId: 'u1',
        pool: pool,
        count: 10,
      );
      final b = drawVariant(
        assignmentId: 'A',
        userId: 'u1',
        pool: pool.reversed.toList(),
        count: 10,
      );
      expect(a, b);
      final sets = {
        for (final u in ['u1', 'u2', 'u3'])
          (drawVariant(
            assignmentId: 'A',
            userId: u,
            pool: pool,
            count: 10,
          )..sort()).join(','),
      };
      expect(sets.length, 3);
    });

    test('variant faqat hovuz ≥ 2 × N bo‘lsa', () {
      expect(variantAllowed(20, 10), isTrue);
      expect(variantAllowed(19, 10), isFalse);
      expect(variantAllowed(12, 6), isTrue);
      expect(variantAllowed(5, 0), isFalse);
    });
  });

  group('guruh kodi (0/O/1/I/L yo‘q)', () {
    test('alifbo va tekshiruv', () {
      for (final ch in ['0', 'O', '1', 'I', 'L']) {
        expect(GroupCode.alphabet.contains(ch), isFalse, reason: ch);
      }
      expect(GroupCode.check('ABCD2345'), GroupCodeCheck.ok);
      expect(GroupCode.check(' abcd-2345 '), GroupCodeCheck.ok);
      expect(GroupCode.normalize('abcd 2345'), 'ABCD2345');
      for (final bad in [
        'ABCD0345',
        'ABCO2345',
        'ABC12345',
        'ABCI2345',
        'ABCL2345',
      ]) {
        expect(GroupCode.check(bad), GroupCodeCheck.ambiguous, reason: bad);
      }
      expect(GroupCode.check('ABC'), GroupCodeCheck.bad);
      expect(GroupCode.display('ABCD2345'), 'ABCD 2345');
    });

    test('havola va matndan kod va test id', () {
      const aid = '8d6f0a4e-1b2c-4d3e-9f80-112233445566';
      final link = GroupCode.link('ABCD2345', assignmentId: aid);
      expect(link.toString(), 'forensicexpert://app/g/ABCD2345?a=$aid');
      expect(
        GroupCode.fromUri(link),
        const GroupInvite(code: 'ABCD2345', assignmentId: aid),
      );
      expect(
        GroupCode.fromText('Kod: abcd 2345'),
        const GroupInvite(code: 'ABCD2345'),
      );
      expect(GroupCode.fromText('Qo‘shiling: $link'), isNotNull);
      expect(GroupCode.fromText('salom'), isNull);
      // Noto‘g‘ri test id e’tiborsiz.
      expect(
        GroupCode.fromUri(Uri.parse('forensicexpert://app/g/ABCD2345?a=x')),
        const GroupInvite(code: 'ABCD2345'),
      );
    });
  });

  group('taxallus: iPhone apostroflari', () {
    test('’ ‘ ʻ ʼ ` ´ ′ → \' (server nick_fold bilan bir xil)', () {
      for (final ch in ['’', '‘', 'ʻ', 'ʼ', '`', '´', '′']) {
        expect(ClassNickname.clean('G${ch}ayrat'), "G'ayrat", reason: ch);
        expect(
          ClassNickname.check('G${ch}ayrat'),
          NicknameCheck.ok,
          reason: ch,
        );
      }
      expect(ClassNickname.clean('  O’tkir   Ali '), "O'tkir Ali");
    });
  });

  group('vaqt ko‘rinishi', () {
    GroupAttempt attempt({int? limit, DateTime? ends}) => GroupAttempt(
      assignment: GroupAssignment(
        id: 'a',
        groupId: 'g',
        topicId: 't',
        topicTitle: 'T',
        questionCount: 5,
        variantMode: false,
        reveal: RevealPolicy.afterClose,
        closed: false,
        revealed: false,
        timeLimitMin: limit,
      ),
      finished: false,
      questions: const [],
      answers: const {},
      endsAt: ends,
      serverNow: DateTime.utc(2026, 10, 18, 12),
    );

    test('faqat muddat: sana; teskari sanoq faqat oxirgi soatda', () {
      // Qurilma soati 5 daqiqa orqada — server soati bo‘yicha hisob.
      final device = DateTime.utc(2026, 10, 18, 11, 55);
      final far = GroupClock.of(
        attempt(ends: DateTime.utc(2026, 10, 20, 13)),
        device,
      );
      expect(far.showCountdown(device), isFalse);
      final near = GroupClock.of(
        attempt(ends: DateTime.utc(2026, 10, 18, 12, 50)),
        device,
      );
      expect(near.showCountdown(device), isTrue);
      expect(near.remaining(device), const Duration(minutes: 50));
    });

    test('vaqt chegarasi bor: har doim teskari sanoq', () {
      final device = DateTime.utc(2026, 10, 18, 12);
      final c = GroupClock.of(
        attempt(limit: 120, ends: DateTime.utc(2026, 10, 18, 14)),
        device,
      );
      expect(c.showCountdown(device), isTrue);
      expect(
        GroupClock.of(attempt(), device).remaining(device),
        isNull,
        reason: 'chegarasiz',
      );
    });
  });

  test('sozlamalar tekshiruvi', () {
    final now = DateTime(2026, 10, 18, 12);
    AssignmentDraft d({
      int n = 5,
      int? t,
      DateTime? due,
      bool v = false,
      RevealPolicy r = RevealPolicy.afterClose,
    }) => AssignmentDraft(
      topicId: 'x',
      questionCount: n,
      timeLimitMin: t,
      dueAt: due,
      variantMode: v,
      reveal: r,
    );
    expect(d().validate(poolSize: 10, now: now), isNull);
    expect(
      d(t: 181).validate(poolSize: 10, now: now),
      GroupFailure.invalidSettings,
    );
    expect(
      d(t: 0).validate(poolSize: 10, now: now),
      GroupFailure.invalidSettings,
    );
    expect(d(t: 180).validate(poolSize: 10, now: now), isNull);
    expect(
      d(n: 6, v: true).validate(poolSize: 10, now: now),
      GroupFailure.variantPoolSmall,
    );
    expect(
      d(r: RevealPolicy.afterDue).validate(poolSize: 10, now: now),
      GroupFailure.revealNeedsDue,
    );
    expect(
      d(n: 11).validate(poolSize: 10, now: now),
      GroupFailure.notEnoughQuestions,
    );
  });

  test('chegara ichidagi skroll: overscroll/bounce hisoblanmaydi', () {
    ScrollMetrics m(double pixels) => FixedScrollMetrics(
      minScrollExtent: 0,
      maxScrollExtent: 1000,
      pixels: pixels,
      viewportDimension: 700,
      axisDirection: AxisDirection.down,
      devicePixelRatio: 3,
    );
    expect(inBoundsScrollDelta(m(500), 20), 20);
    // Oxiridan cho‘zilgan holatdan qaytish (bounce) — 0.
    expect(inBoundsScrollDelta(m(1030), -20), 0);
    // Tepadagi overscroll — 0.
    expect(inBoundsScrollDelta(m(-40), -10), 0);
    // Chegarani kesib o‘tgan qism faqat ichkaridagisi.
    expect(inBoundsScrollDelta(m(1010), 30), 20);
  });

  group('kutilayotgan taklif (onboarding/ro‘yxatdan o‘tish)', () {
    const inv = GroupInvite(code: 'ABCD2345', assignmentId: 'a-1');
    test('onboarding tugamagan — taklif kutadi', () {
      expect(
        pendingGroupInviteRedirect(const AppSettings(), Routes.home, inv),
        isNull,
      );
    });
    test('onboarding tugagach Asosiyda — qo‘shilish sahifasi', () {
      expect(
        pendingGroupInviteRedirect(completedSettings(), Routes.home, inv),
        Routes.groupJoinWith('ABCD2345', assignmentId: 'a-1'),
      );
      expect(
        pendingGroupInviteRedirect(completedSettings(), Routes.groups, inv),
        isNull,
      );
      expect(
        pendingGroupInviteRedirect(completedSettings(), Routes.home, null),
        isNull,
      );
    });
  });

  group('xotiradagi server — SQL qoidalari nusxasi', () {
    late DateTime now;
    late FakeClassGroupsBackend b;
    setUp(() {
      now = DateTime(2026, 10, 18, 10);
      b = FakeClassGroupsBackend(
        topics: () async => [topic('t20', 20), topic('t5', 5)],
        teachers: {'teacher'},
        clock: () => now,
      );
    });

    test('ustoz o‘z kodini ochadi — a’zo qilinmaydi; anonim yo‘q', () async {
      final g = b.create('teacher', '4-kurs').value!;
      final j = b.join('teacher', code: g.code!, nickname: 'Ustoz').value!;
      expect(j.isTeacher, isTrue);
      expect(b.detail('teacher', g.id).value!.members, isEmpty);
      final anon = FakeClassGroupsService(b, userIdOf: () => null);
      expect(
        (await anon.join(code: g.code!, nickname: 'Ali')).failure,
        GroupFailure.notSignedIn,
      );
      expect(b.create('student', 'X').failure, GroupFailure.forbidden);
    });

    test('taxallus: birinchi marta so‘raladi, ’ bilan, yagona', () {
      final g = b.create('teacher', '4-kurs').value!;
      final r = b.join('s1', code: g.code!);
      expect(r.failure, GroupFailure.nicknameRequired);
      expect(r.extra['group_name'], '4-kurs');
      expect(
        b.join('s1', code: g.code!, nickname: 'G’ayrat').value!.nickname,
        "G'ayrat",
      );
      expect(
        b.join('s2', code: g.code!, nickname: 'gʻayrat').failure,
        GroupFailure.nickTaken,
      );
      expect(b.join('s1', code: g.code!).value!.alreadyMember, isTrue);
      expect(
        b.join('s3', code: 'ABCO2345').failure,
        GroupFailure.codeAmbiguous,
      );
    });

    test('200 chegara va rate limit', () {
      final g = b.create('teacher', 'Katta').value!;
      for (var i = 0; i < GroupRules.maxMembers; i++) {
        expect(b.join('u$i', code: g.code!, nickname: 'Talaba $i').ok, isTrue);
      }
      expect(
        b.join('late', code: g.code!, nickname: 'Kechikdi').failure,
        GroupFailure.groupFull,
      );
      for (var i = 0; i < 30; i++) {
        b.join('rl', code: 'ZZZZZZZZ');
      }
      expect(
        b.join('rl', code: g.code!, nickname: 'Rl').failure,
        GroupFailure.rateLimited,
      );
    });

    test('variant, server ball, vaqt imtiyozi, ochilish qoidasi', () async {
      final g = b.create('teacher', 'G-1').value!;
      for (final u in ['s1', 's2', 's3']) {
        b.join(u, code: g.code!, nickname: 'Nick $u');
      }
      expect(
        (await b.createAssignment(
          'teacher',
          g.id,
          const AssignmentDraft(
            topicId: 't5',
            questionCount: 3,
            variantMode: true,
          ),
        )).failure,
        GroupFailure.variantPoolSmall,
      );
      final a = (await b.createAssignment(
        'teacher',
        g.id,
        const AssignmentDraft(
          topicId: 't20',
          questionCount: 5,
          timeLimitMin: 10,
          variantMode: true,
        ),
      )).value!;
      final sets = <String>{};
      for (final u in ['s1', 's2', 's3']) {
        final att = b.open(u, a.id).value!;
        expect(att.questions, hasLength(5));
        expect(
          att.questions.map((q) => q.id).toList(),
          drawVariant(
            assignmentId: a.id,
            userId: u,
            pool: b
                .preview('teacher', a.id)
                .value!
                .pool
                .map((q) => q.id)
                .toList(),
            count: 5,
          ),
        );
        sets.add((att.questions.map((q) => q.id).toList()..sort()).join());
      }
      expect(sets, hasLength(3));
      // s1 — imtiyoz ichida (10 daqiqa + 20 s), s2 — kech (11 daqiqa).
      final key = {
        for (final q in b.preview('teacher', a.id).value!.pool)
          q.id: q.correctIndex,
      };
      final s1q = b.open('s1', a.id).value!.questions;
      b.save('s2', a.id, {b.open('s2', a.id).value!.questions.first.id: 0});
      now = now.add(const Duration(minutes: 10, seconds: 20));
      final r1 = b.submit('s1', a.id, {
        for (final q in s1q) q.id: key[q.id]!,
      }).value!;
      expect((r1.score, r1.late, r1.revealed), (5, false, false));
      expect(b.result('s1', a.id).value!.items.first.correctIndex, isNull);
      now = now.add(const Duration(minutes: 1));
      expect(b.save('s2', a.id, const {}).failure, GroupFailure.timeOver);
      expect(b.submit('s2', a.id, const {}).value!.late, isTrue);
      // s3 hech narsa yubormadi — panel o‘qilganda yakunlanadi.
      final board = b.board('teacher', a.id).value!;
      expect(board.rows.every((r) => r.state == BoardState.finished), isTrue);
      expect(board.rows.first.score, 5);
      b.closeAssignment('teacher', a.id);
      expect(b.result('s1', a.id).value!.revealed, isTrue);
      expect(b.result('s1', a.id).value!.items.first.correctIndex, isNotNull);
      expect(b.board('s1', a.id).failure, GroupFailure.forbidden);
    });
  });
}
