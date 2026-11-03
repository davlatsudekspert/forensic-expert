import 'dart:async';
import 'dart:io';

import '../../domain/class_quiz/class_quiz_models.dart';
import '../../domain/oral_group/oral_group_models.dart';
import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/oral_group_ports.dart';
import 'supabase_rest.dart';

/// «Guruh og‘zaki imtihoni» uchun Supabase adapteri.
///
/// RPC (hammasi SECURITY DEFINER, `supabase/migrations/20261103010000_oral_sessions.sql`):
/// `oral_create_session`, `oral_my_sessions`, `oral_teacher_state`,
/// `oral_call`, `oral_grade`, `oral_kick`, `oral_finish`, `oral_join_session`,
/// `oral_my_state`, `oral_ready`, `oral_report_leave`. Jadvalga to‘g‘ridan-to‘g‘ri kirish yo‘q.
/// Javob kaliti serverga yuborilmaydi. Kutilgan xatolar `{ok:false,error}`;
/// huquq xatosi (42501) — HTTP 403/401. Polling (REST, realtime yo‘q).
class SupabaseOralGroupService implements OralGroupService {
  SupabaseOralGroupService({
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
      if (j is List) return ClassResult.ok({'items': j});
      final m = r.map;
      if (m['ok'] == false) {
        return ClassResult.fail(oralFailureFromServer(m['error']));
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
  Future<ClassResult<OralGroupSession>> createSession({
    required String title,
    required List<List<OralGroupQuestion>> tickets,
    required int prepSeconds,
  }) async => _map(
    await _rpc('oral_create_session', {
      'p_title': title,
      'p_tickets': [
        for (final t in tickets) [for (final q in t) q.toJson()],
      ],
      'p_prep_seconds': prepSeconds,
    }),
    (m) => OralGroupSession.fromJson((m['session'] as Map).cast()),
  );

  @override
  Future<ClassResult<List<OralGroupSession>>> mySessions() async => _map(
    await _rpc('oral_my_sessions', const {}),
    (m) => [
      for (final s in (m['items'] as List? ?? const []))
        if (s is Map) OralGroupSession.fromJson(s.cast<String, Object?>()),
    ],
  );

  @override
  Future<ClassResult<OralGroupTeacherState>> teacherState(
    String sessionId,
  ) async => _map(
    await _rpc('oral_teacher_state', _sid(sessionId)),
    OralGroupTeacherState.fromJson,
  );

  @override
  Future<ClassResult<void>> call(
    String sessionId,
    String participantId,
  ) async => _void(
    await _rpc('oral_call', {
      ..._sid(sessionId),
      'p_participant': participantId,
    }),
  );

  @override
  Future<ClassResult<int>> grade(
    String sessionId,
    String participantId,
    List<int> scores,
  ) async => _map(
    await _rpc('oral_grade', {
      ..._sid(sessionId),
      'p_participant': participantId,
      'p_scores': scores,
    }),
    (m) => (m['total'] as num).toInt(),
  );

  @override
  Future<ClassResult<void>> kick(
    String sessionId,
    String participantId,
  ) async => _void(
    await _rpc('oral_kick', {
      ..._sid(sessionId),
      'p_participant': participantId,
    }),
  );

  @override
  Future<ClassResult<void>> finish(String sessionId) async =>
      _void(await _rpc('oral_finish', _sid(sessionId)));

  @override
  Future<ClassResult<OralGroupJoinInfo>> join({
    required String code,
    required String name,
  }) async => _map(
    await _rpc('oral_join_session', {'p_code': code, 'p_name': name}),
    OralGroupJoinInfo.fromJson,
  );

  @override
  Future<ClassResult<OralGroupMyState>> myState(String sessionId) async => _map(
    await _rpc('oral_my_state', _sid(sessionId)),
    OralGroupMyState.fromJson,
  );

  @override
  Future<ClassResult<void>> ready(String sessionId) async =>
      _void(await _rpc('oral_ready', _sid(sessionId)));

  @override
  Future<ClassResult<int>> reportLeave(String sessionId) async => _map(
    await _rpc('oral_report_leave', _sid(sessionId)),
    (m) => (m['leave_count'] as num?)?.toInt() ?? 0,
  );
}
