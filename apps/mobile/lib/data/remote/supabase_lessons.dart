import 'dart:async';
import 'dart:io';

import '../../domain/class_quiz/class_quiz_models.dart'
    show ClassFailure, ClassResult;
import '../../domain/lessons/lesson_models.dart';
import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/lessons_ports.dart';
import 'supabase_rest.dart';

/// «Darslar» Supabase adapteri: `lesson_list(p_query)`, `lesson_get(p_topic_id)`
/// (`supabase/migrations/20261018020000_lesson_decks.sql`). Ustoz bo‘lmasa
/// server 42501 `forbidden` (HTTP 403) qaytaradi.
class SupabaseLessonsService implements LessonsService {
  SupabaseLessonsService({
    required SupabaseConfig config,
    required this.auth,
    RestTransport? transport,
  }) : _cfg = config,
       _http = transport ?? HttpClientTransport();

  final SupabaseConfig _cfg;
  final AuthRepository auth;
  final RestTransport _http;

  @override
  bool get isConfigured => true;
  @override
  bool get isDemo => false;

  Future<ClassResult<Object?>> _rpc(
    String name,
    Map<String, Object?> body,
  ) async {
    if (!auth.current.signedIn) {
      return const ClassResult.fail(ClassFailure.notSignedIn);
    }
    final token = await auth.accessToken();
    if (token == null) return const ClassResult.fail(ClassFailure.notSignedIn);
    try {
      final r = await _http.send(
        'POST',
        _cfg.url.resolve('rest/v1/rpc/$name'),
        headers: {'apikey': _cfg.anonKey, 'Authorization': 'Bearer $token'},
        jsonBody: body,
      );
      if (r.status == 401) {
        return const ClassResult.fail(ClassFailure.notSignedIn);
      }
      if (r.status == 403) {
        return const ClassResult.fail(ClassFailure.forbidden);
      }
      if (r.status == 404) {
        return const ClassResult.fail(ClassFailure.notConfigured);
      }
      if (!r.ok) return const ClassResult.fail(ClassFailure.server);
      return ClassResult.ok(r.json);
    } on FormatException {
      return const ClassResult.fail(ClassFailure.server);
    } on SocketException {
      return const ClassResult.fail(ClassFailure.offline);
    } on TimeoutException {
      return const ClassResult.fail(ClassFailure.offline);
    } on HandshakeException {
      return const ClassResult.fail(ClassFailure.offline);
    }
  }

  @override
  Future<ClassResult<List<LessonSummary>>> list({String? query}) async {
    final q = query?.trim();
    final r = await _rpc('lesson_list', {
      'p_query': (q == null || q.isEmpty) ? null : q,
    });
    if (!r.ok) return ClassResult.fail(r.failure!);
    final v = r.value;
    if (v is! List) return const ClassResult.fail(ClassFailure.server);
    try {
      return ClassResult.ok([
        for (final e in v)
          if (e is Map) LessonSummary.fromJson(e.cast<String, Object?>()),
      ]);
    } on Object {
      return const ClassResult.fail(ClassFailure.server);
    }
  }

  @override
  Future<ClassResult<LessonDeck>> get(String topicId) async {
    final r = await _rpc('lesson_get', {'p_topic_id': topicId});
    if (!r.ok) return ClassResult.fail(r.failure!);
    final v = r.value;
    if (v is! Map) return const ClassResult.fail(ClassFailure.server);
    final m = v.cast<String, Object?>();
    if (m['ok'] == false) {
      return ClassResult.fail(
        m['error'] == 'not_found'
            ? ClassFailure.notFound
            : m['error'] == 'forbidden'
            ? ClassFailure.forbidden
            : ClassFailure.server,
      );
    }
    try {
      final d = LessonDeck.fromJson(m);
      if (d.slides.isEmpty) return const ClassResult.fail(ClassFailure.server);
      return ClassResult.ok(d);
    } on Object {
      return const ClassResult.fail(ClassFailure.server);
    }
  }
}
