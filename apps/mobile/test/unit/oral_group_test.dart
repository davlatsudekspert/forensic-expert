// «Guruh og‘zaki imtihoni» (QR): bilet tuzish (noyoblik, mavzu aralashuvi,
// havza tugashi), modellar (fromJson), xotiradagi server qoidalari va CSV.
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/oral_group/fake_oral_group_service.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/oral_group/oral_group_models.dart';
import 'package:forensic_expert/domain/oral_group/oral_group_tickets.dart';

Map<String, List<String>> _pools(Map<String, int> sizes) => {
  for (final e in sizes.entries)
    e.key: [for (var i = 0; i < e.value; i++) '${e.key}#$i'],
};

List<List<OralGroupQuestion>> _tickets(int n, {int size = 5}) => [
  for (var t = 0; t < n; t++)
    [
      for (var q = 0; q < size; q++)
        OralGroupQuestion(
          id: 'x#${t * size + q}',
          text: 'Savol ${t * size + q}',
        ),
    ],
];

void main() {
  group('bilet tuzish', () {
    test('havza yetsa: biletlar orasida takror yo‘q, har bilet 5 ta', () {
      final plan = buildOralGroupTickets(
        pools: _pools({'a': 20, 'b': 20, 'c': 20}),
        count: 12,
        rng: math.Random(1),
      );
      expect(plan.tickets, hasLength(12));
      expect(plan.tickets.every((t) => t.length == 5), isTrue);
      final all = plan.tickets.expand((t) => t).toList();
      expect(all.toSet(), hasLength(60));
      expect(plan.repeats, isFalse);
      expect(plan.available, 60);
      expect(oralTicketsWillRepeat(available: 60, count: 12), isFalse);
    });

    test('mavzular aralashadi: har bilet bir necha mavzudan', () {
      final plan = buildOralGroupTickets(
        pools: _pools({'a': 30, 'b': 30, 'c': 30}),
        count: 10,
        rng: math.Random(2),
      );
      for (final t in plan.tickets) {
        final topics = {for (final id in t) id.split('#').first};
        expect(topics.length, greaterThanOrEqualTo(2), reason: '$t');
      }
    });

    test('bitta mavzuli havzada ham noyob', () {
      final plan = buildOralGroupTickets(
        pools: _pools({'a': 25}),
        count: 5,
        rng: math.Random(3),
      );
      expect(plan.tickets.expand((t) => t).toSet(), hasLength(25));
      expect(plan.repeats, isFalse);
    });

    test('havza tugasa: yangi aylanish, takror bor, bilet ichida yo‘q', () {
      final plan = buildOralGroupTickets(
        pools: _pools({'a': 6, 'b': 4}),
        count: 7,
        rng: math.Random(4),
      );
      expect(plan.tickets, hasLength(7));
      expect(plan.repeats, isTrue);
      expect(plan.available, 10);
      for (final t in plan.tickets) {
        expect(t, hasLength(5));
        expect(t.toSet(), hasLength(5), reason: 'bilet ichida takror: $t');
      }
      // Birinchi ikki bilet — butun havza (10 ta noyob).
      expect(plan.tickets.take(2).expand((t) => t).toSet(), hasLength(10));
      expect(oralTicketsWillRepeat(available: 10, count: 7), isTrue);
    });

    test('havza 5 tadan kam: bilet kichik, hammasi', () {
      final plan = buildOralGroupTickets(
        pools: _pools({'a': 3}),
        count: 2,
        rng: math.Random(5),
      );
      expect(plan.tickets, hasLength(2));
      expect(plan.tickets.every((t) => t.length == 3), isTrue);
      expect(plan.repeats, isTrue);
    });

    test('bo‘sh havza yoki 0 ta bilet', () {
      expect(
        buildOralGroupTickets(pools: {}, count: 3, rng: math.Random(1)).tickets,
        isEmpty,
      );
      expect(
        buildOralGroupTickets(
          pools: _pools({'a': 9}),
          count: 0,
          rng: math.Random(1),
        ).tickets,
        isEmpty,
      );
    });
  });

  group('modellar', () {
    test('OralGroupSession.fromJson (kam maydonlarga chidamli)', () {
      final s = OralGroupSession.fromJson({
        'id': 's1',
        'code': '123456',
        'status': 'finished',
        'ticket_count': 25,
        'prep_seconds': 600,
        'created_at': '2026-11-03T10:00:00Z',
        'joined': 3,
        'graded': 1,
      });
      expect(s.isOpen, isFalse);
      expect(s.ticketCount, 25);
      expect(s.prepSeconds, 600);
      expect(s.joined, 3);
      expect(s.title, '');
      expect(s.finishedAt, isNull);
      final empty = OralGroupSession.fromJson(const {});
      expect(empty.id, '');
      expect(empty.isOpen, isTrue);
    });

    test('OralGroupTeacherState.fromJson', () {
      final st = OralGroupTeacherState.fromJson({
        'ok': true,
        'session': {'id': 's', 'code': '111222', 'ticket_count': 2},
        'tickets': [
          {
            'no': 1,
            'questions': [
              {'id': 'a#1', 'text': 'Savol'},
            ],
          },
          {'no': 2},
        ],
        'participants': [
          {
            'id': 'p1',
            'name': 'Ali',
            'ticket_no': 2,
            'joined_at': '2026-11-03T10:00:00Z',
            'ready_at': '2026-11-03T10:05:00Z',
            'scores': [20, 10, 0, 5, 5],
            'graded_at': '2026-11-03T10:30:00Z',
          },
        ],
      });
      expect(st.tickets, hasLength(2));
      expect(st.ticket(1)!.questions.single.id, 'a#1');
      expect(st.ticket(2)!.questions, isEmpty);
      final p = st.participant('p1')!;
      expect(p.isGraded, isTrue);
      expect(p.isReady, isTrue);
      expect(p.isCalled, isFalse);
      expect(p.total, 40);
      expect(p.leaveCount, 0);
      expect(
        OralGroupParticipant.fromJson({
          'id': 'x',
          'leave_count': 3,
          'last_left_at': '2026-11-03T10:07:00Z',
        }).lastLeftAt,
        DateTime.utc(2026, 11, 3, 10, 7),
      );
      expect(st.participantByTicket(2), same(p));
      expect(st.gradedCount, 1);
    });

    test('OralGroupMyState.fromJson va ball yo‘q holati', () {
      final m = OralGroupMyState.fromJson({
        'session': {'id': 's', 'prep_seconds': 300},
        'name': 'Vali',
        'ticket_no': 7,
        'questions': [
          {'id': 'a#1', 'text': 'Birinchi'},
        ],
        'joined_at': '2026-11-03T10:00:00Z',
        'scores': null,
        'total': null,
        'server_now': '2026-11-03T10:01:00Z',
      });
      expect(m.ticketNo, 7);
      expect(m.isGraded, isFalse);
      expect(m.scores, isNull);
      expect(m.total, isNull);
      final g = OralGroupMyState.fromJson({
        'session': {'id': 's'},
        'name': 'Vali',
        'ticket_no': 1,
        'questions': <Object>[],
        'graded_at': '2026-11-03T10:30:00Z',
        'scores': [1, 2, 3, 4, 5],
        'total': 15,
      });
      expect(g.isGraded, isTrue);
      expect(g.total, 15);
      expect(g.scores, [1, 2, 3, 4, 5]);
    });

    test('tayyorlanish sanog‘i server soatiga qarab tuzatiladi', () {
      final m = OralGroupMyState.fromJson({
        'session': {'id': 's', 'prep_seconds': 600},
        'name': 'V',
        'ticket_no': 1,
        'questions': <Object>[],
        'joined_at': '2026-11-03T10:00:00Z',
        'server_now': '2026-11-03T10:02:00Z',
      });
      // Qurilma soati 1 soat oldinda, ammo server 2 daqiqa deydi.
      final fetched = DateTime.utc(2026, 11, 3, 11, 0, 0);
      expect(
        m.prepRemaining(localNow: fetched, fetchedLocalAt: fetched),
        const Duration(minutes: 8),
      );
      expect(
        m.prepRemaining(
          localNow: fetched.add(const Duration(minutes: 3)),
          fetchedLocalAt: fetched,
        ),
        const Duration(minutes: 5),
      );
      expect(
        m.prepRemaining(
          localNow: fetched.add(const Duration(minutes: 30)),
          fetchedLocalAt: fetched,
        ),
        Duration.zero,
      );
      final none = OralGroupMyState.fromJson({
        'session': {'id': 's', 'prep_seconds': 0},
        'name': 'V',
        'ticket_no': 1,
        'questions': <Object>[],
        'joined_at': '2026-11-03T10:00:00Z',
      });
      expect(
        none.prepRemaining(localNow: fetched, fetchedLocalAt: fetched),
        Duration.zero,
      );
    });

    test('server xato kodlari', () {
      expect(oralFailureFromServer('name_length'), ClassFailure.nickLength);
      expect(oralFailureFromServer('name_chars'), ClassFailure.nickChars);
      expect(oralFailureFromServer('name_blocked'), ClassFailure.nickBlocked);
      expect(
        oralFailureFromServer('invalid_ticket'),
        ClassFailure.invalidTicket,
      );
      expect(
        oralFailureFromServer('invalid_scores'),
        ClassFailure.invalidScores,
      );
      expect(oralFailureFromServer('not_joined'), ClassFailure.notJoined);
      expect(oralFailureFromServer('not_allowed'), ClassFailure.notAllowed);
      expect(oralFailureFromServer('try_again'), ClassFailure.tryAgain);
      expect(oralFailureFromServer('full'), ClassFailure.full);
      expect(oralFailureFromServer('finished'), ClassFailure.finished);
      expect(oralFailureFromServer('kicked'), ClassFailure.kicked);
      expect(oralFailureFromServer('own_session'), ClassFailure.ownSession);
      expect(oralFailureFromServer('rate_limited'), ClassFailure.rateLimited);
      expect(oralFailureFromServer('???'), ClassFailure.server);
    });

    test('QR havolasi ajratib olinadi', () {
      final uri = OralGroupLink.joinLink('123456');
      expect(uri.toString(), 'forensicexpert://app/join/123456?t=oral');
      expect(OralGroupLink.isOral(uri), isTrue);
      expect(ClassCode.extract(uri), '123456');
      expect(ClassCode.fromScanned(uri.toString()), '123456');
      expect(OralGroupLink.isOral(ClassCode.joinLink('123456')), isFalse);
      // Skaner: faqat oral havola oral deb tanlanadi.
      expect(OralGroupLink.codeFromScanned(uri.toString()), '123456');
      expect(
        OralGroupLink.codeFromScanned('https://x.uz/join/654321?t=oral'),
        '654321',
      );
      expect(
        OralGroupLink.codeFromScanned(ClassCode.joinLink('123456').toString()),
        isNull,
      );
      expect(OralGroupLink.codeFromScanned('123456'), isNull);
      expect(OralGroupLink.codeFromScanned(null), isNull);
      expect(
        OralGroupLink.codeFromScanned('forensicexpert://app/join/12?t=oral'),
        isNull,
      );
    });

    test('ism tozalash va uzunlik', () {
      expect(OralName.clean('  Ali   Valiyev '), 'Ali Valiyev');
      expect(OralName.validLength('A'), isFalse);
      expect(OralName.validLength('Al'), isTrue);
      expect(OralName.validLength('x' * 40), isTrue);
      expect(OralName.validLength('x' * 41), isFalse);
      expect(OralName.fromProfile('y' * 60).runes.length, 40);
      expect(OralName.fromProfile(null), '');
    });

    test('savol serverga uzunlik chegarasi bilan ketadi', () {
      final j = OralGroupQuestion(id: 'i' * 300, text: 'm' * 900).toJson();
      expect((j['id']! as String).length, 160);
      expect((j['text']! as String).length, 500);
    });
  });

  group('xotiradagi server qoidalari', () {
    late DateTime now;
    late FakeOralGroupBackend backend;
    late FakeOralGroupService teacher;

    FakeOralGroupService user(String id) =>
        FakeOralGroupService(backend, userId: id, demo: false);

    setUp(() {
      now = DateTime.utc(2026, 11, 3, 10);
      backend = FakeOralGroupBackend(
        clock: () => now,
        rng: math.Random(9),
        teachers: {'t1'},
      );
      teacher = user('t1');
    });

    Future<OralGroupSession> create({int tickets = 3, int prep = 0}) async =>
        (await teacher.createSession(
          title: 'Mavzu',
          tickets: _tickets(tickets),
          prepSeconds: prep,
        )).value!;

    test('faqat ustoz yaratadi; sozlamalar va biletlar tekshiriladi', () async {
      expect(
        (await user('s1').createSession(
          title: '',
          tickets: _tickets(2),
          prepSeconds: 0,
        )).failure,
        ClassFailure.forbidden,
      );
      expect(
        (await teacher.createSession(
          title: '',
          tickets: const [],
          prepSeconds: 0,
        )).failure,
        ClassFailure.invalidSettings,
      );
      expect(
        (await teacher.createSession(
          title: '',
          tickets: _tickets(201),
          prepSeconds: 0,
        )).failure,
        ClassFailure.invalidSettings,
      );
      expect(
        (await teacher.createSession(
          title: '',
          tickets: _tickets(2),
          prepSeconds: 3601,
        )).failure,
        ClassFailure.invalidSettings,
      );
      expect(
        (await teacher.createSession(
          title: '',
          tickets: [const []],
          prepSeconds: 0,
        )).failure,
        ClassFailure.invalidTicket,
      );
      expect(
        (await teacher.createSession(
          title: '',
          tickets: [
            [const OralGroupQuestion(id: 'a', text: '')],
          ],
          prepSeconds: 0,
        )).failure,
        ClassFailure.invalidTicket,
      );
      final s = await create(tickets: 4, prep: 600);
      expect(s.code, matches(RegExp(r'^[0-9]{6}$')));
      expect(s.ticketCount, 4);
      expect(s.prepSeconds, 600);
      expect(s.isOpen, isTrue);
    });

    test('10 tadan ortiq ochiq imtihon yo‘q', () async {
      for (var i = 0; i < 10; i++) {
        await create(tickets: 1);
      }
      expect(
        (await teacher.createSession(
          title: '',
          tickets: _tickets(1),
          prepSeconds: 0,
        )).failure,
        ClassFailure.tooManySessions,
      );
    });

    test('kod «Guruh testi» kodi bilan to‘qnashmaydi', () async {
      final first = (await teacher.createSession(
        title: '',
        tickets: _tickets(1),
        prepSeconds: 0,
      )).value!;
      // Xuddi shu urug‘ bilan yangi backend: birinchi kod «Guruh testi»da band.
      final b2 = FakeOralGroupBackend(
        clock: () => now,
        rng: math.Random(9),
        teachers: {'t1'},
        takenCodes: {first.code},
      );
      final second = (await FakeOralGroupService(
        b2,
        userId: 't1',
      ).createSession(title: '', tickets: _tickets(1), prepSeconds: 0)).value!;
      expect(second.code, isNot(first.code));
    });

    test('qo‘shilish: tasodifiy bo‘sh bilet, qayta kirish bir xil', () async {
      final s = await create(tickets: 3);
      final a = user('a');
      final r = await a.join(code: s.code, name: ' Ali  Valiyev ');
      final info = r.value!;
      final my = (await a.myState(s.id)).value!;
      expect(my.name, 'Ali Valiyev');
      expect(my.ticketNo, inInclusiveRange(1, 3));
      expect(my.questions, hasLength(5));
      expect(my.isReady, isFalse);
      expect(my.serverNow, now);
      final again = (await a.join(code: s.code, name: 'Boshqa ism')).value!;
      expect(again.participantId, info.participantId);
      expect((await a.myState(s.id)).value!.name, 'Ali Valiyev');
      expect((await a.myState(s.id)).value!.ticketNo, my.ticketNo);
    });

    test(
      'bir xil bilet ikki talabaga berilmaydi; band bo‘lsa «full»',
      () async {
        final s = await create(tickets: 3);
        final tickets = <int>{};
        for (final id in ['a', 'b', 'c']) {
          final u = user(id);
          expect((await u.join(code: s.code, name: 'Talaba $id')).ok, isTrue);
          tickets.add((await u.myState(s.id)).value!.ticketNo);
        }
        expect(tickets, {1, 2, 3});
        expect(
          (await user('d').join(code: s.code, name: 'To‘rtinchi')).failure,
          ClassFailure.full,
        );
      },
    );

    test('ism qoidalari: uzunlik 2..40, belgilar, taqiqlangan so‘z', () async {
      final s = await create();
      final a = user('a');
      Future<ClassFailure?> tryName(String n) async =>
          (await a.join(code: s.code, name: n)).failure;
      expect(await tryName('A'), ClassFailure.nickLength);
      expect(await tryName('x' * 41), ClassFailure.nickLength);
      expect(await tryName('a<b>c'), ClassFailure.nickChars);
      expect(await tryName('Sh1t Ali'), ClassFailure.nickBlocked);
      expect(await tryName('Ali ${'v' * 30} fuck'), ClassFailure.nickBlocked);
      expect(
        (await a.join(code: s.code, name: 'v' * 40)).ok,
        isTrue,
        reason: '40 belgi — ruxsat',
      );
    });

    test('kod va rol xatolari', () async {
      final s = await create();
      expect(
        (await user('a').join(code: '12', name: 'Ali')).failure,
        ClassFailure.badCode,
      );
      final other = s.code == '000000' ? '000001' : '000000';
      expect(
        (await user('a').join(code: other, name: 'Ali')).failure,
        ClassFailure.notFound,
      );
      expect(
        (await teacher.join(code: s.code, name: 'Ustoz')).failure,
        ClassFailure.ownSession,
      );
      expect(
        (await user('a').join(
          code: '${s.code.substring(0, 3)} ${s.code.substring(3)}',
          name: 'Ali',
        )).ok,
        isTrue,
        reason: 'bo‘shliqli kod ham qabul qilinadi',
      );
    });

    test('urinishlar cheklangan (soatiga 30)', () async {
      final a = user('a');
      for (var i = 0; i < 30; i++) {
        await a.join(code: '999999', name: 'Ali');
      }
      expect(
        (await a.join(code: '999999', name: 'Ali')).failure,
        ClassFailure.rateLimited,
      );
    });

    test('chetlatilgan qayta kira olmaydi, bilet bo‘shaydi', () async {
      final s = await create(tickets: 1);
      final a = user('a');
      final pid = (await a.join(
        code: s.code,
        name: 'Ali',
      )).value!.participantId;
      expect(
        (await user('b').join(code: s.code, name: 'Vali')).failure,
        ClassFailure.full,
      );
      expect((await teacher.kick(s.id, pid)).ok, isTrue);
      expect(
        (await a.join(code: s.code, name: 'Ali')).failure,
        ClassFailure.kicked,
      );
      expect((await a.myState(s.id)).failure, ClassFailure.notJoined);
      expect((await user('b').join(code: s.code, name: 'Vali')).ok, isTrue);
      expect((await teacher.kick(s.id, pid)).failure, ClassFailure.notFound);
    });

    test(
      'yakunlangan imtihonga yangi talaba kirmaydi, eskisi kiradi',
      () async {
        final s = await create();
        final a = user('a');
        expect((await a.join(code: s.code, name: 'Ali')).ok, isTrue);
        expect((await teacher.finish(s.id)).ok, isTrue);
        expect(
          (await user('b').join(code: s.code, name: 'Vali')).failure,
          ClassFailure.finished,
        );
        expect((await a.join(code: s.code, name: 'Ali')).ok, isTrue);
        expect((await a.ready(s.id)).failure, ClassFailure.notAllowed);
        final mine = (await teacher.mySessions()).value!;
        expect(mine.single.isOpen, isFalse);
        expect(mine.single.joined, 1);
      },
    );

    test(
      'tayyor / chaqirish / baholash va talaba faqat o‘z ballini ko‘radi',
      () async {
        final s = await create(tickets: 2);
        final a = user('a');
        final b = user('b');
        final pa = (await a.join(
          code: s.code,
          name: 'Ali',
        )).value!.participantId;
        final pb = (await b.join(
          code: s.code,
          name: 'Vali',
        )).value!.participantId;
        expect((await a.myState(s.id)).value!.isCalled, isFalse);
        now = now.add(const Duration(minutes: 1));
        expect((await a.ready(s.id)).ok, isTrue);
        expect((await teacher.call(s.id, pa)).ok, isTrue);
        expect((await a.myState(s.id)).value!.isCalled, isTrue);
        // Ball: uzunlik va oraliq tekshiruvi.
        expect(
          (await teacher.grade(s.id, pa, [1, 2, 3])).failure,
          ClassFailure.invalidScores,
        );
        expect(
          (await teacher.grade(s.id, pa, [1, 2, 3, 4, 21])).failure,
          ClassFailure.invalidScores,
        );
        expect(
          (await teacher.grade(s.id, pa, [1, 2, 3, 4, -1])).failure,
          ClassFailure.invalidScores,
        );
        expect((await a.myState(s.id)).value!.isGraded, isFalse);
        expect((await teacher.grade(s.id, pa, [20, 20, 20, 20, 5])).value, 85);
        final mine = (await a.myState(s.id)).value!;
        expect(mine.scores, [20, 20, 20, 20, 5]);
        expect(mine.total, 85);
        // Qayta baholash mumkin.
        expect((await teacher.grade(s.id, pa, [10, 10, 10, 10, 10])).value, 50);
        expect((await a.myState(s.id)).value!.total, 50);
        // Boshqa talaba ballni ko‘rmaydi.
        expect((await b.myState(s.id)).value!.scores, isNull);
        expect((await b.myState(s.id)).value!.total, isNull);
        // Baholangan «tayyor» bosa olmaydi.
        expect((await a.ready(s.id)).failure, ClassFailure.notAllowed);
        expect(
          (await teacher.grade(s.id, 'yo‘q', [1, 1, 1, 1, 1])).failure,
          ClassFailure.notFound,
        );
        // Ustoz bo‘lmagan odam ustoz amallarini bajara olmaydi.
        expect((await b.call(s.id, pa)).failure, ClassFailure.forbidden);
        expect((await b.teacherState(s.id)).failure, ClassFailure.forbidden);
        expect((await b.finish(s.id)).failure, ClassFailure.forbidden);
        expect((await b.kick(s.id, pa)).failure, ClassFailure.forbidden);
        expect(
          (await b.grade(s.id, pb, [1, 1, 1, 1, 1])).failure,
          ClassFailure.forbidden,
        );
      },
    );

    test(
      'ustoz ko‘rinishi tartibi: baholanmagan, tayyor (vaqt), qo‘shilgan',
      () async {
        final s = await create(tickets: 4);
        final ids = <String, String>{};
        for (final n in ['a', 'b', 'c', 'd']) {
          ids[n] = (await user(
            n,
          ).join(code: s.code, name: 'Ism $n')).value!.participantId;
          now = now.add(const Duration(seconds: 10));
        }
        // d avval, so‘ng b tayyor; a baholanadi.
        expect((await user('d').ready(s.id)).ok, isTrue);
        now = now.add(const Duration(seconds: 10));
        expect((await user('b').ready(s.id)).ok, isTrue);
        expect(
          (await teacher.grade(s.id, ids['a']!, [5, 5, 5, 5, 5])).ok,
          isTrue,
        );
        final order = [
          for (final p in (await teacher.teacherState(
            s.id,
          )).value!.participants)
            p.name,
        ];
        expect(order, ['Ism d', 'Ism b', 'Ism c', 'Ism a']);
      },
    );

    test(
      'ilovadan chiqish hisobi: faqat ochiq, baholanmagan talaba uchun',
      () async {
        final s = await create(tickets: 2);
        final a = user('a');
        final pa = (await a.join(
          code: s.code,
          name: 'Ali',
        )).value!.participantId;
        expect((await a.reportLeave(s.id)).value, 1);
        now = now.add(const Duration(minutes: 5));
        expect((await a.reportLeave(s.id)).value, 2);
        expect((await a.myState(s.id)).value!.leaveCount, 2);
        final p = (await teacher.teacherState(s.id)).value!.participants.single;
        expect(p.leaveCount, 2);
        expect(p.lastLeftAt, now);
        expect(
          (await user('x').reportLeave(s.id)).failure,
          ClassFailure.notAllowed,
          reason: 'qo‘shilmagan',
        );
        await teacher.grade(s.id, pa, [1, 1, 1, 1, 1]);
        expect((await a.reportLeave(s.id)).failure, ClassFailure.notAllowed);
        final b = user('b');
        await b.join(code: s.code, name: 'Vali');
        await teacher.finish(s.id);
        expect((await b.reportLeave(s.id)).failure, ClassFailure.notAllowed);
      },
    );

    test('javob kaliti biletda yo‘q: talabaga faqat id va matn', () async {
      final s = await create(tickets: 1);
      final a = user('a');
      await a.join(code: s.code, name: 'Ali');
      final q = (await a.myState(s.id)).value!.questions.first;
      expect(q.toJson().keys.toSet(), {'id', 'text'});
    });
  });

  group('CSV', () {
    test('sarlavha, ballar, formula himoyasi va fayl nomi', () {
      final csv = OralGroupCsv.build(
        [
          const OralGroupParticipant(
            id: 'p2',
            name: '=Evil, "Ism"',
            ticketNo: 2,
          ),
          OralGroupParticipant(
            id: 'p1',
            name: 'Ali',
            ticketNo: 1,
            scores: const [20, 18, 12, 10, 0],
            gradedAt: DateTime.utc(2026, 11, 3),
          ),
        ],
        nameLabel: 'Ism',
        ticketLabel: 'Bilet',
        totalLabel: 'Jami',
        questionLabel: (n) => '$n-savol',
      );
      final lines = csv.trimRight().split('\r\n');
      expect(
        lines[0],
        'Ism,Bilet,1-savol,2-savol,3-savol,4-savol,5-savol,Jami',
      );
      expect(lines[1], 'Ali,1,20,18,12,10,0,60');
      expect(lines[2], '"\'=Evil, ""Ism""",2,,,,,,');
      expect(
        OralGroupCsv.fileName('123 456', DateTime.utc(2026, 11, 3)),
        'og_zaki_imtihon_123456_2026-11-03.csv',
      );
    });
  });
}
