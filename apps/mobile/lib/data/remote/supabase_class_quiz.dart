import 'dart:async';
import 'dart:io';

import '../../domain/class_quiz/class_quiz_models.dart';
import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/class_quiz_ports.dart';
import 'supabase_rest.dart';

/// «Sinfda test» uchun Supabase adapteri.
///
/// RPC (hammasi SECURITY DEFINER, `supabase/migrations/20261017010000_class_quiz.sql`):
/// `class_status`, `class_topics`, `class_create_session`, `class_my_sessions`,
/// `class_join_session`, `class_start`, `class_next`, `class_close_question`,
/// `class_finish`, `class_kick`, `class_submit_answer`, `class_session_state`,
/// `class_my_results`, `class_teacher_dashboard`, `class_export_results`,
/// `class_report_nickname`. Jadvalga to‘g‘ridan-to‘g‘ri kirish yo‘q.
///
/// Realtime: SDK’siz REST mijoz va yopiq RLS tufayli polling (2 s) — qarang
/// `docs/CLASS_QUIZ.md`. Kutilgan xatolar `{ok:false,error}` ko‘rinishida
/// keladi; huquq xatosi HTTP 403/401.
class SupabaseClassQuizService implements ClassQuizService {
  SupabaseClassQuizService({
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
  @override
  bool get requiresSignIn => true;

  /// RPC chaqiruvi: muvaffaqiyatda javob JSON’i, aks holda aniq xato.
  Future<ClassResult<Map<String, Object?>>> _rpc(
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
      // Migratsiya hali qo‘llanmagan: funksiya topilmadi.
      if (r.status == 404) {
        return const ClassResult.fail(ClassFailure.notConfigured);
      }
      if (!r.ok) return const ClassResult.fail(ClassFailure.server);
      final j = r.json;
      if (j is List) {
        return ClassResult.ok({'items': j});
      }
      final m = r.map;
      if (m['ok'] == false) {
        return ClassResult.fail(ClassFailure.fromServer(m['error']));
      }
      return ClassResult.ok(m);
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

  ClassResult<T> _map<T>(
    ClassResult<Map<String, Object?>> r,
    T Function(Map<String, Object?>) f,
  ) {
    final v = r.value;
    if (v == null) return ClassResult.fail(r.failure!);
    try {
      return ClassResult.ok(f(v));
    } on Object {
      return const ClassResult.fail(ClassFailure.server);
    }
  }

  ClassResult<void> _void(ClassResult<Map<String, Object?>> r) =>
      r.ok ? const ClassResult.ok(null) : ClassResult.fail(r.failure!);

  Map<String, Object?> _sid(String id) => {'p_session': id};

  @override
  Future<ClassResult<ClassQuizMe>> me() async =>
      _map(await _rpc('class_status', const {}), ClassQuizMe.fromJson);

  @override
  Future<ClassResult<List<ClassTopic>>> topics() async => _map(
    await _rpc('class_topics', const {}),
    (m) => [
      for (final t in (m['items'] as List? ?? const []))
        ClassTopic.fromJson((t as Map).cast<String, Object?>()),
    ],
  );

  @override
  Future<ClassResult<ClassSessionInfo>> createSession({
    required String topicId,
    required ClassQuizSettings settings,
  }) async => _map(
    await _rpc('class_create_session', {
      'p_topic': topicId,
      'p_question_count': settings.questionCount,
      'p_student_limit': settings.studentLimit,
      'p_seconds': settings.seconds,
    }),
    (m) => ClassSessionInfo.fromJson((m['session'] as Map).cast()),
  );

  @override
  Future<ClassResult<List<ClassSessionInfo>>> mySessions() async => _map(
    await _rpc('class_my_sessions', const {}),
    (m) => [
      for (final s in (m['items'] as List? ?? const []))
        ClassSessionInfo.fromJson((s as Map).cast<String, Object?>()),
    ],
  );

  @override
  Future<ClassResult<ClassDashboard>> dashboard(String sessionId) async => _map(
    await _rpc('class_teacher_dashboard', _sid(sessionId)),
    ClassDashboard.fromJson,
  );

  @override
  Future<ClassResult<void>> start(String sessionId) async =>
      _void(await _rpc('class_start', _sid(sessionId)));

  @override
  Future<ClassResult<bool>> next(String sessionId) async => _map(
    await _rpc('class_next', _sid(sessionId)),
    (m) => m['finished'] == true,
  );

  @override
  Future<ClassResult<void>> closeQuestion(String sessionId) async =>
      _void(await _rpc('class_close_question', _sid(sessionId)));

  @override
  Future<ClassResult<void>> finish(String sessionId) async =>
      _void(await _rpc('class_finish', _sid(sessionId)));

  @override
  Future<ClassResult<void>> kick(
    String sessionId,
    String participantId,
  ) async => _void(
    await _rpc('class_kick', {
      'p_session': sessionId,
      'p_participant': participantId,
    }),
  );

  @override
  Future<ClassResult<ClassExport>> exportResults(String sessionId) async =>
      _map(
        await _rpc('class_export_results', _sid(sessionId)),
        ClassExport.fromJson,
      );

  @override
  Future<ClassResult<List<ClassHardDetail>>> hardestDetail(
    String sessionId, {
    int limit = 5,
  }) async => _map(
    await _rpc('class_hardest_detail', {..._sid(sessionId), 'p_limit': limit}),
    (m) => [
      for (final h in (m['items'] as List? ?? const []))
        if (h is Map) ClassHardDetail.fromJson(h.cast<String, Object?>()),
    ],
  );

  @override
  Future<ClassResult<ClassJoinInfo>> join({
    required String code,
    required String nickname,
  }) async => _map(
    await _rpc('class_join_session', {'p_code': code, 'p_nickname': nickname}),
    ClassJoinInfo.fromJson,
  );

  @override
  Future<ClassResult<ClassStudentState>> state(String sessionId) async => _map(
    await _rpc('class_session_state', _sid(sessionId)),
    ClassStudentState.fromJson,
  );

  @override
  Future<ClassResult<void>> submitAnswer({
    required String sessionId,
    required int questionIndex,
    required String optionId,
  }) async => _void(
    await _rpc('class_submit_answer', {
      'p_session': sessionId,
      'p_index': questionIndex,
      'p_option': optionId,
    }),
  );

  @override
  Future<ClassResult<ClassMyResults>> myResults(String sessionId) async => _map(
    await _rpc('class_my_results', _sid(sessionId)),
    ClassMyResults.fromJson,
  );

  @override
  Future<ClassResult<void>> reportNickname({
    required String sessionId,
    required String participantId,
    required String reason,
  }) async => _void(
    await _rpc('class_report_nickname', {
      'p_session': sessionId,
      'p_participant': participantId,
      'p_reason': reason,
    }),
  );
}
