// «Guruh og‘zaki imtihoni» Supabase adapteri: RPC nomlari, parametrlar
// (javob kaliti yuborilmaydi), javob turlari va xato xaritasi.
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_oral_group.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/oral_group/oral_group_models.dart';

import '../helpers/referral_fakes.dart';

class _Transport implements RestTransport {
  _Transport(this.handler);

  RestResponse Function(String path, Object? body) handler;
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
    return handler(uri.path, jsonBody);
  }
}

final _cfg = SupabaseConfig(
  url: Uri.parse('https://fe-test.supabase.co/'),
  anonKey: 'anon-public-test-key',
);

const _session = {
  'id': 's1',
  'code': '123456',
  'title': 'Mavzu',
  'status': 'open',
  'ticket_count': 2,
  'prep_seconds': 600,
};

void main() {
  test('kirmagan foydalanuvchi — tarmoqqa chiqmaydi', () async {
    final t = _Transport((p, b) => const RestResponse(200, {'ok': true}));
    final s = SupabaseOralGroupService(
      config: _cfg,
      auth: MockAuthRepository(),
      transport: t,
    );
    expect(
      (await s.join(code: '123456', name: 'Ali')).failure,
      ClassFailure.notSignedIn,
    );
    expect(t.calls, isEmpty);
  });

  test('createSession: faqat id va matn yuboriladi (kalit yo‘q)', () async {
    final auth = await signedInMockAuth();
    final t = _Transport(
      (p, b) => const RestResponse(200, {'ok': true, 'session': _session}),
    );
    final s = SupabaseOralGroupService(config: _cfg, auth: auth, transport: t);
    final r = await s.createSession(
      title: 'Mavzu',
      tickets: const [
        [OralGroupQuestion(id: 'a#1', text: 'Savol 1')],
        [OralGroupQuestion(id: 'a#2', text: 'Savol 2')],
      ],
      prepSeconds: 600,
    );
    expect(r.value!.code, '123456');
    expect(r.value!.prepSeconds, 600);
    expect(t.calls.single.path, '/rest/v1/rpc/oral_create_session');
    expect(t.calls.single.body, {
      'p_title': 'Mavzu',
      'p_tickets': [
        [
          {'id': 'a#1', 'text': 'Savol 1'},
        ],
        [
          {'id': 'a#2', 'text': 'Savol 2'},
        ],
      ],
      'p_prep_seconds': 600,
    });
  });

  test('ustoz RPC’lari: nomlar va parametrlar', () async {
    final auth = await signedInMockAuth();
    final t = _Transport((p, b) {
      if (p.endsWith('oral_my_sessions')) {
        return const RestResponse(200, [
          {..._session, 'joined': 2, 'graded': 1},
        ]);
      }
      if (p.endsWith('oral_teacher_state')) {
        return const RestResponse(200, {
          'ok': true,
          'session': _session,
          'tickets': <Object>[],
          'participants': <Object>[],
        });
      }
      if (p.endsWith('oral_grade')) {
        return const RestResponse(200, {'ok': true, 'total': 75});
      }
      return const RestResponse(200, {'ok': true});
    });
    final s = SupabaseOralGroupService(config: _cfg, auth: auth, transport: t);
    final mine = (await s.mySessions()).value!;
    expect(mine.single.joined, 2);
    expect(mine.single.graded, 1);
    expect((await s.teacherState('s1')).value!.session.id, 's1');
    expect((await s.call('s1', 'p1')).ok, isTrue);
    expect((await s.grade('s1', 'p1', [20, 20, 15, 10, 10])).value, 75);
    expect((await s.kick('s1', 'p1')).ok, isTrue);
    expect((await s.finish('s1')).ok, isTrue);
    expect(
      [for (final c in t.calls) c.path.split('/').last],
      [
        'oral_my_sessions',
        'oral_teacher_state',
        'oral_call',
        'oral_grade',
        'oral_kick',
        'oral_finish',
      ],
    );
    expect(t.calls[1].body, {'p_session': 's1'});
    expect(t.calls[2].body, {'p_session': 's1', 'p_participant': 'p1'});
    expect(t.calls[3].body, {
      'p_session': 's1',
      'p_participant': 'p1',
      'p_scores': [20, 20, 15, 10, 10],
    });
  });

  test('talaba RPC’lari: join, my_state, ready', () async {
    final auth = await signedInMockAuth();
    final t = _Transport((p, b) {
      if (p.endsWith('oral_join_session')) {
        return const RestResponse(200, {
          'ok': true,
          'participant_id': 'p1',
          'session': _session,
        });
      }
      if (p.endsWith('oral_my_state')) {
        return const RestResponse(200, {
          'ok': true,
          'session': _session,
          'name': 'Ali',
          'ticket_no': 2,
          'questions': [
            {'id': 'a#1', 'text': 'Savol'},
          ],
          'joined_at': '2026-11-03T10:00:00Z',
          'scores': null,
          'total': null,
          'server_now': '2026-11-03T10:01:00Z',
        });
      }
      return const RestResponse(200, {'ok': true});
    });
    final s = SupabaseOralGroupService(config: _cfg, auth: auth, transport: t);
    final j = (await s.join(code: '123456', name: 'Ali')).value!;
    expect(j.participantId, 'p1');
    expect(j.session.id, 's1');
    expect(t.calls.first.body, {'p_code': '123456', 'p_name': 'Ali'});
    final my = (await s.myState('s1')).value!;
    expect(my.ticketNo, 2);
    expect(my.isGraded, isFalse);
    expect(my.serverNow, DateTime.utc(2026, 11, 3, 10, 1));
    expect((await s.ready('s1')).ok, isTrue);
    expect(t.calls.last.path, '/rest/v1/rpc/oral_ready');
    expect((await s.reportLeave('s1')).ok, isTrue);
    expect(t.calls.last.path, '/rest/v1/rpc/oral_report_leave');
    expect(t.calls.last.body, {'p_session': 's1'});
  });

  test('server xatolari va HTTP holatlari aniq turga aylanadi', () async {
    final auth = await signedInMockAuth();
    var next = const RestResponse(200, {'ok': false, 'error': 'full'});
    final t = _Transport((p, b) => next);
    final s = SupabaseOralGroupService(config: _cfg, auth: auth, transport: t);
    Future<ClassFailure?> join() async =>
        (await s.join(code: '123456', name: 'Ali')).failure;
    expect(await join(), ClassFailure.full);
    for (final (code, f) in [
      ('name_length', ClassFailure.nickLength),
      ('name_chars', ClassFailure.nickChars),
      ('name_blocked', ClassFailure.nickBlocked),
      ('kicked', ClassFailure.kicked),
      ('finished', ClassFailure.finished),
      ('bad_code', ClassFailure.badCode),
      ('not_found', ClassFailure.notFound),
      ('own_session', ClassFailure.ownSession),
      ('rate_limited', ClassFailure.rateLimited),
    ]) {
      next = RestResponse(200, {'ok': false, 'error': code});
      expect(await join(), f, reason: code);
    }
    next = const RestResponse(200, {'ok': false, 'error': 'invalid_scores'});
    expect(
      (await s.grade('s1', 'p1', [1])).failure,
      ClassFailure.invalidScores,
    );
    next = const RestResponse(200, {'ok': false, 'error': 'not_allowed'});
    expect((await s.ready('s1')).failure, ClassFailure.notAllowed);
    next = const RestResponse(200, {'ok': false, 'error': 'not_joined'});
    expect((await s.myState('s1')).failure, ClassFailure.notJoined);
    next = const RestResponse(200, {'ok': false, 'error': 'invalid_ticket'});
    expect(
      (await s.createSession(
        title: '',
        tickets: const [],
        prepSeconds: 0,
      )).failure,
      ClassFailure.invalidTicket,
    );
    next = const RestResponse(403, {'message': 'forbidden'});
    expect(await join(), ClassFailure.forbidden);
    next = const RestResponse(401, null);
    expect(await join(), ClassFailure.notSignedIn);
    next = const RestResponse(404, null);
    expect(await join(), ClassFailure.notConfigured);
    next = const RestResponse(500, null);
    expect(await join(), ClassFailure.server);
  });
}
