import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
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
  test('kirmagan foydalanuvchi — tarmoqqa chiqmaydi', () async {
    final t = _Transport((p, b) => const RestResponse(200, {'ok': true}));
    final s = SupabaseClassQuizService(
      config: _cfg,
      auth: MockAuthRepository(),
      transport: t,
    );
    expect(
      (await s.join(code: '123456', nickname: 'Ali')).failure,
      ClassFailure.notSignedIn,
    );
    expect(t.calls, isEmpty);
  });

  test('join: RPC nomi, parametrlar va javob', () async {
    final auth = await signedInMockAuth();
    final t = _Transport(
      (p, b) => const RestResponse(200, {
        'ok': true,
        'session_id': 's1',
        'participant_id': 'p1',
        'nickname': 'Ali',
        'session': {
          'id': 's1',
          'code': '123456',
          'status': 'lobby',
          'topic_title': 'T',
          'total': 5,
          'student_limit': 30,
          'seconds': 30,
        },
      }),
    );
    final s = SupabaseClassQuizService(config: _cfg, auth: auth, transport: t);
    final r = await s.join(code: '123456', nickname: 'Ali');
    expect(r.value!.sessionId, 's1');
    expect(r.value!.session.code, '123456');
    expect(t.calls.single.path, '/rest/v1/rpc/class_join_session');
    expect(t.calls.single.body, {'p_code': '123456', 'p_nickname': 'Ali'});
  });

  test('server xatolari aniq turga aylanadi', () async {
    final auth = await signedInMockAuth();
    RestResponse next = const RestResponse(200, {'ok': false, 'error': 'full'});
    final s = SupabaseClassQuizService(
      config: _cfg,
      auth: auth,
      transport: _Transport((p, b) => next),
    );
    Future<ClassFailure?> f() async =>
        (await s.join(code: '123456', nickname: 'Ali')).failure;
    expect(await f(), ClassFailure.full);
    next = const RestResponse(403, {'message': 'forbidden'});
    expect(await f(), ClassFailure.forbidden);
    next = const RestResponse(401, null);
    expect(await f(), ClassFailure.notSignedIn);
    next = const RestResponse(404, null);
    expect(
      await f(),
      ClassFailure.notConfigured,
      reason: 'migratsiya hali qo‘llanmagan',
    );
    next = const RestResponse(500, null);
    expect(await f(), ClassFailure.server);
    next = const RestResponse(200, {'ok': false, 'error': 'rate_limited'});
    expect(await f(), ClassFailure.rateLimited);
  });

  test('submitAnswer: parametrlar; ustoz amallari va ro‘yxat javobi', () async {
    final auth = await signedInMockAuth();
    final t = _Transport((p, b) {
      if (p.endsWith('class_topics')) {
        return const RestResponse(200, [
          {'topic_id': 'x', 'title': 'Mavzu', 'count': 12, 'is_demo': false},
        ]);
      }
      if (p.endsWith('class_next')) {
        return const RestResponse(200, {'ok': true, 'finished': true});
      }
      return const RestResponse(200, {'ok': true});
    });
    final s = SupabaseClassQuizService(config: _cfg, auth: auth, transport: t);
    expect((await s.topics()).value!.single.count, 12);
    expect((await s.next('s1')).value, isTrue);
    expect(
      (await s.submitAnswer(
        sessionId: 's1',
        questionIndex: 2,
        optionId: 'o3',
      )).ok,
      isTrue,
    );
    expect(t.calls.last.path, '/rest/v1/rpc/class_submit_answer');
    expect(t.calls.last.body, {
      'p_session': 's1',
      'p_index': 2,
      'p_option': 'o3',
    });
    await s.createSession(
      topicId: 'x',
      settings: const ClassQuizSettings(
        questionCount: 7,
        studentLimit: 40,
        seconds: 45,
      ),
    );
    expect(t.calls.last.body, {
      'p_topic': 'x',
      'p_question_count': 7,
      'p_student_limit': 40,
      'p_seconds': 45,
    });
  });

  test('so‘rovda to‘g‘ri javob yoki email yuborilmaydi', () async {
    final auth = await signedInMockAuth();
    final t = _Transport((p, b) => const RestResponse(200, {'ok': true}));
    final s = SupabaseClassQuizService(config: _cfg, auth: auth, transport: t);
    await s.submitAnswer(sessionId: 's1', questionIndex: 0, optionId: 'o1');
    final body = t.calls.single.body.toString();
    expect(body.contains('correct'), isFalse);
    expect(body.contains('@'), isFalse);
  });
}
