import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/remote/supabase_class_groups.dart';
import 'package:forensic_expert/data/remote/supabase_class_quiz.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';

import '../helpers/referral_fakes.dart';

/// Sinf/guruh testi savollari ilova tilida: `class_quiz_question_translations`
/// ustiga qo‘yiladi, yo‘q bo‘lsa — asl o‘zbekcha; to‘g‘ri javob o‘zgarmaydi.
class _Transport implements RestTransport {
  _Transport(this.handler);

  final RestResponse Function(String method, Uri uri, Object? body) handler;
  final calls = <({String method, Uri uri, Object? body})>[];

  Iterable<Object?> bodiesOf(String path) =>
      calls.where((c) => c.uri.path == path).map((c) => c.body);

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async {
    calls.add((method: method, uri: uri, body: jsonBody));
    return handler(method, uri, jsonBody);
  }
}

final _cfg = SupabaseConfig(
  url: Uri.parse('https://fe-test.supabase.co/'),
  anonKey: 'anon-public-test-key',
);

/// Haqiqiy javob kabi o‘zgaruvchan JSON (jsonDecode).
RestResponse _ok(Object v) => RestResponse(200, jsonDecode(jsonEncode(v)));

const _localizePath = '/rest/v1/rpc/class_quiz_localize';

Map<String, Object?> _state({bool revealed = false}) => {
  'ok': true,
  'id': 's1',
  'status': 'running',
  'phase': revealed ? 'closed' : 'open',
  'question': {
    'index': 0,
    'text': 'Savol matni?',
    'options': [
      {'id': 'o0', 'text': 'B javob'},
      {'id': 'o1', 'text': 'A javob'},
      {'id': 'o2', 'text': 'D javob'},
      {'id': 'o3', 'text': 'C javob'},
    ],
  },
  if (revealed)
    'reveal': {
      'correct_option': 'o1',
      'explanation': 'Izoh',
      'my_correct': true,
      'my_points': 900,
    },
};

void main() {
  test('uz interfeys: tarjima so‘ralmaydi, matn asl', () async {
    final auth = await signedInMockAuth();
    final t = _Transport((m, u, b) => _ok(_state()));
    final s = SupabaseClassQuizService(
      config: _cfg,
      auth: auth,
      transport: t,
      lang: () => 'uz',
    );
    final r = await s.state('s1');
    expect(r.value!.question!.text, 'Savol matni?');
    expect(t.bodiesOf(_localizePath), isEmpty);
  });

  test('ru: sessiya savoli, variantlar va izoh tarjimasi; to‘g‘ri javob '
      'id’si o‘zgarmaydi; keyingi poll keshdan', () async {
    final auth = await signedInMockAuth();
    final t = _Transport((m, u, b) {
      if (u.path == _localizePath) {
        return _ok({
          'ok': true,
          'items': [
            {
              'question': 'Текст вопроса?',
              'options': ['Ответ B', 'Ответ A', 'Ответ D', 'Ответ C'],
              'explanation': 'Пояснение',
            },
          ],
        });
      }
      return _ok(_state(revealed: true));
    });
    final s = SupabaseClassQuizService(
      config: _cfg,
      auth: auth,
      transport: t,
      lang: () => 'ru',
    );
    final r = (await s.state('s1')).value!;
    expect(r.question!.text, 'Текст вопроса?');
    expect(r.question!.options.map((o) => o.text), [
      'Ответ B',
      'Ответ A',
      'Ответ D',
      'Ответ C',
    ]);
    expect(r.question!.options.map((o) => o.id), ['o0', 'o1', 'o2', 'o3']);
    expect(r.reveal!.correctOption, 'o1');
    expect(r.reveal!.explanation, 'Пояснение');
    final req = t.bodiesOf(_localizePath).single! as Map;
    expect(req['p_lang'], 'ru');
    expect(req['p_items'], [
      {
        'question': 'Savol matni?',
        'options': ['B javob', 'A javob', 'D javob', 'C javob'],
        'explanation': 'Izoh',
      },
    ]);
    await s.state('s1');
    expect(t.bodiesOf(_localizePath), hasLength(1));
  });

  test('ru: tarjima yo‘q yoki RPC hali yo‘q (404) — asl matn', () async {
    final auth = await signedInMockAuth();
    var missing = false;
    final t = _Transport((m, u, b) {
      if (u.path == _localizePath) {
        return missing
            ? const RestResponse(404, null)
            : _ok({
                'ok': true,
                'items': [null],
              });
      }
      return _ok(_state());
    });
    final s = SupabaseClassQuizService(
      config: _cfg,
      auth: auth,
      transport: t,
      lang: () => 'en',
    );
    expect((await s.state('s1')).value!.question!.text, 'Savol matni?');

    missing = true;
    final s2 = SupabaseClassQuizService(
      config: _cfg,
      auth: auth,
      transport: t,
      lang: () => 'en',
    );
    expect((await s2.state('s1')).value!.question!.text, 'Savol matni?');
    expect((await s2.state('s1')).value!.question!.text, 'Savol matni?');
    // 1 (s: null) + 1 (s2: 404, keyin qayta so‘ralmaydi).
    expect(t.bodiesOf(_localizePath), hasLength(2));
  });

  test('mashq: tarjima jadvali bitta so‘rov bilan; yo‘q/mos kelmagan — asl; '
      'correct_index o‘zgarmaydi', () async {
    final auth = await signedInMockAuth();
    const a = '11111111-1111-4111-8111-111111111111';
    const b = '22222222-2222-4222-8222-222222222222';
    const c = '33333333-3333-4333-8333-333333333333';
    Map<String, Object?> row(String id, String q) => {
      'id': id,
      'question': q,
      'options': ['$q 1', '$q 2', '$q 3', '$q 4'],
      'correct_index': 2,
      'explanation': '$q izoh',
      'source': {'author': 'X', 'title': 'Y', 'page': '5'},
    };
    final t = _Transport((m, u, body) {
      if (u.path == '/rest/v1/class_quiz_question_translations') {
        return _ok([
          {
            'question_id': a,
            'question': 'Question A',
            'options': ['A1', 'A2', 'A3', 'A4'],
            'explanation': null,
          },
          // Variantlar soni mos emas — qo‘llanmaydi.
          {
            'question_id': c,
            'question': 'Question C',
            'options': ['C1', 'C2'],
            'explanation': 'Expl C',
          },
        ]);
      }
      return _ok({
        'ok': true,
        'items': [row(a, 'Birinchi'), row(b, 'Ikkinchi'), row(c, 'Uchinchi')],
      });
    });
    final s = SupabaseClassQuizService(
      config: _cfg,
      auth: auth,
      transport: t,
      lang: () => 'en',
    );
    final rows = (await s.practiceQuestions('toks-01')).value!;
    expect(rows[0]['question'], 'Question A');
    expect(rows[0]['options'], ['A1', 'A2', 'A3', 'A4']);
    expect(rows[0]['explanation'], 'Birinchi izoh');
    expect(rows[0]['correct_index'], 2);
    expect(rows[1]['question'], 'Ikkinchi');
    expect(rows[2]['question'], 'Uchinchi');
    expect(rows[2]['options'], hasLength(4));
    final get = t.calls.singleWhere((x) => x.method == 'GET').uri;
    expect(get.queryParameters['lang'], 'eq.en');
    expect(get.queryParameters['question_id'], 'in.($a,$b,$c)');
  });

  test('mavzular: ~ru/~en nusxalari yashiriladi (asli bo‘lsa), nom '
      'tarjimasi qo‘yiladi; tarjima nomi yo‘q — o‘zbekcha', () async {
    final auth = await signedInMockAuth();
    Map<String, Object?> topic(String id, String title) => {
      'topic_id': id,
      'title': title,
      'count': 12,
    };
    var titlesMissing = false;
    final t = _Transport((m, u, b) {
      if (u.path == '/rest/v1/rpc/class_topic_titles') {
        return titlesMissing
            ? const RestResponse(404, null)
            : _ok({'toks-01': 'Введение в токсикологию'});
      }
      return _ok([
        topic('toks-01', 'Toksikologiyaga kirish'),
        topic('toks-01~ru', 'Toksikologiyaga kirish'),
        topic('toks-01~en', 'Toksikologiyaga kirish'),
        topic('toks-02', 'Ikkinchi mavzu'),
        topic('yolgiz~ru', 'Faqat nusxa'),
      ]);
    });
    final s = SupabaseClassQuizService(
      config: _cfg,
      auth: auth,
      transport: t,
      lang: () => 'ru',
    );
    final list = (await s.topics()).value!;
    expect(list.map((x) => x.id), ['toks-01', 'toks-02', 'yolgiz~ru']);
    expect(list.first.title, 'Введение в токсикологию');
    expect(list[1].title, 'Ikkinchi mavzu');
    expect(list.first.count, 12);

    titlesMissing = true;
    final s2 = SupabaseClassQuizService(
      config: _cfg,
      auth: auth,
      transport: t,
      lang: () => 'ru',
    );
    final l2 = (await s2.practiceTopics()).value!;
    expect(l2.first.title, 'Toksikologiyaga kirish');
    expect(l2.map((x) => x.id), isNot(contains('toks-01~ru')));
  });

  test('uz: mavzu nomlari so‘ralmaydi, nusxalar baribir yashiriladi', () async {
    final auth = await signedInMockAuth();
    final t = _Transport(
      (m, u, b) => _ok([
        {'topic_id': 'a', 'title': 'A', 'count': 5},
        {'topic_id': 'a~ru', 'title': 'A', 'count': 5},
      ]),
    );
    final s = SupabaseClassQuizService(
      config: _cfg,
      auth: auth,
      transport: t,
      lang: () => 'uz',
    );
    expect((await s.topics()).value!.map((x) => x.id), ['a']);
    expect(t.calls, hasLength(1));
  });

  test('guruh testi: bank id (qid) bilan so‘raladi, matnli variantlar '
      'almashtiriladi', () async {
    final auth = await signedInMockAuth();
    const qid = '44444444-4444-4444-8444-444444444444';
    final t = _Transport((m, u, b) {
      if (u.path == _localizePath) {
        return _ok({
          'ok': true,
          'items': [
            {
              'question': 'Question?',
              'options': ['w', 'x', 'y', 'z'],
              'explanation': null,
            },
          ],
        });
      }
      return _ok({
        'ok': true,
        'state': 'solving',
        'assignment': {'id': 'as1', 'group_id': 'g1', 'topic_id': 't1'},
        'answers': <String, Object?>{},
        'questions': [
          {
            'id': qid,
            'text': 'Savol?',
            'options': ['a', 'b', 'c', 'd'],
          },
        ],
      });
    });
    final s = SupabaseClassGroupsService(
      config: _cfg,
      auth: auth,
      transport: t,
      lang: () => 'en',
    );
    final r = (await s.open('as1')).value!;
    expect(r.questions.single.id, qid);
    expect(r.questions.single.text, 'Question?');
    expect(r.questions.single.options, ['w', 'x', 'y', 'z']);
    final req = t.bodiesOf(_localizePath).single! as Map;
    expect((req['p_items'] as List).single, {
      'id': qid,
      'question': 'Savol?',
      'options': ['a', 'b', 'c', 'd'],
    });
  });

  test('QR/kod bilan qo‘shilgan ru talaba: savolni o‘z tilida ko‘radi, '
      'uz ustoz paneli esa asl matnda', () async {
    final auth = await signedInMockAuth();
    final t = _Transport((m, u, b) {
      switch (u.path) {
        case '/rest/v1/rpc/class_join_session':
          return _ok({
            'ok': true,
            'session_id': 's1',
            'participant_id': 'p1',
            'nickname': 'Ali',
            'session': {'id': 's1', 'code': '123456', 'status': 'lobby'},
          });
        case _localizePath:
          return _ok({
            'ok': true,
            'items': [
              {
                'question': 'Текст вопроса?',
                'options': ['Ответ B', 'Ответ A', 'Ответ D', 'Ответ C'],
                'explanation': null,
              },
            ],
          });
        case '/rest/v1/rpc/class_teacher_dashboard':
          return _ok({
            'ok': true,
            'session': {'id': 's1', 'status': 'running'},
            'current': (_state()['question']! as Map),
          });
      }
      return _ok(_state());
    });
    final student = SupabaseClassQuizService(
      config: _cfg,
      auth: auth,
      transport: t,
      lang: () => 'ru',
    );
    final j = (await student.join(code: '123456', nickname: 'Ali')).value!;
    final st = (await student.state(j.sessionId)).value!;
    expect(st.question!.text, 'Текст вопроса?');
    expect(st.question!.options.first.text, 'Ответ B');
    // Jonli savol: izoh so‘ralmaydi (oshkor bo‘lmasin).
    final item =
        ((t.bodiesOf(_localizePath).single! as Map)['p_items'] as List).single
            as Map;
    expect(item.containsKey('explanation'), isFalse);

    final teacher = SupabaseClassQuizService(
      config: _cfg,
      auth: auth,
      transport: t,
      lang: () => 'uz',
    );
    final d = await teacher.dashboard('s1');
    expect(d.ok, isTrue);
    expect(t.bodiesOf(_localizePath), hasLength(1));
  });
}
