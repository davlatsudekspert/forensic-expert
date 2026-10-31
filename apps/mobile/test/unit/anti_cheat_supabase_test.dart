import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/remote/supabase_class_groups.dart';
import 'package:forensic_expert/data/remote/supabase_class_quiz.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';

import '../helpers/referral_fakes.dart';

class _Transport implements RestTransport {
  _Transport(this.handler);

  final RestResponse Function(String path, Object? body) handler;
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

void main() {
  test('class_report_leave: RPC nomi va p_session', () async {
    final t = _Transport(
      (p, b) => const RestResponse(200, {'ok': true, 'counted': true}),
    );
    final s = SupabaseClassQuizService(
      config: _cfg,
      auth: await signedInMockAuth(),
      transport: t,
    );
    final r = await s.reportLeave('sess-1');
    expect(r.ok, isTrue);
    expect(t.calls.single.path, '/rest/v1/rpc/class_report_leave');
    expect(t.calls.single.body, {'p_session': 'sess-1'});
  });

  test('group_report_leave: RPC nomi va p_assignment', () async {
    final t = _Transport(
      (p, b) => const RestResponse(200, {'ok': true, 'counted': false}),
    );
    final s = SupabaseClassGroupsService(
      config: _cfg,
      auth: await signedInMockAuth(),
      transport: t,
    );
    expect((await s.reportLeave('asg-1')).ok, isTrue);
    expect(t.calls.single.path, '/rest/v1/rpc/group_report_leave');
    expect(t.calls.single.body, {'p_assignment': 'asg-1'});
  });

  test('chiqish xabari: xato (403/500) ham yiqilmaydi, natija fail', () async {
    final t = _Transport((p, b) => const RestResponse(500, {}));
    final auth = await signedInMockAuth();
    final q = SupabaseClassQuizService(config: _cfg, auth: auth, transport: t);
    final g = SupabaseClassGroupsService(
      config: _cfg,
      auth: auth,
      transport: t,
    );
    expect((await q.reportLeave('x')).ok, isFalse);
    expect((await g.reportLeave('x')).ok, isFalse);
  });

  test(
    'class_create_session: erkin soniya (90) p_seconds sifatida ketadi',
    () async {
      final t = _Transport(
        (p, b) => const RestResponse(200, {
          'ok': true,
          'session': {
            'id': 's1',
            'code': '123456',
            'status': 'lobby',
            'topic_title': 'T',
            'total': 5,
            'student_limit': 30,
            'seconds': 90,
          },
        }),
      );
      final s = SupabaseClassQuizService(
        config: _cfg,
        auth: await signedInMockAuth(),
        transport: t,
      );
      final r = await s.createSession(
        topicId: 'tox',
        settings: const ClassQuizSettings(questionCount: 5, seconds: 90),
      );
      expect(r.value!.seconds, 90);
      expect(t.calls.single.path, '/rest/v1/rpc/class_create_session');
      expect((t.calls.single.body! as Map)['p_seconds'], 90);
    },
  );

  test('guruh doskasi: leave_count server javobidan o‘qiladi', () async {
    final t = _Transport(
      (p, b) => const RestResponse(200, {
        'ok': true,
        'assignment': {'id': 'a1', 'group_id': 'g1', 'topic_title': 'T'},
        'group': {'id': 'g1', 'name': 'G'},
        'rows': [
          {
            'member_id': 'm1',
            'nickname': 'Ali',
            'state': 'finished',
            'leave_count': 4,
          },
        ],
      }),
    );
    final s = SupabaseClassGroupsService(
      config: _cfg,
      auth: await signedInMockAuth(),
      transport: t,
    );
    final b = (await s.board('a1')).value!;
    expect(b.rows.single.leaveCount, 4);
  });
}
