import 'dart:async';
import 'dart:io';

import '../../domain/class_groups/class_groups_models.dart';
import '../../domain/class_quiz/class_quiz_models.dart' show ClassHardDetail;
import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/class_groups_ports.dart';
import 'supabase_rest.dart';

/// «Ustoz–talaba testi» uchun Supabase adapteri.
///
/// RPC (hammasi SECURITY DEFINER, `supabase/migrations/20261018050000_class_groups.sql`):
/// `group_create`, `group_list`, `group_detail`, `group_remove_member`,
/// `group_assignment_create`, `group_assignment_close`, `group_assignment_board`,
/// `group_assignment_preview`, `group_assignment_hardest_detail`, `group_join`, `group_leave`,
/// `group_assignment_open`, `group_assignment_save`, `group_assignment_submit`,
/// `group_assignment_result`. Jadvalga to‘g‘ridan-to‘g‘ri kirish yo‘q.
/// Kutilgan xatolar `{ok:false,error}`; huquq xatosi HTTP 403/401.
class SupabaseClassGroupsService implements ClassGroupsService {
  SupabaseClassGroupsService({
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
  String? get userId => auth.current.userId;

  Future<GroupCall<Map<String, Object?>>> _rpc(
    String name,
    Map<String, Object?> body,
  ) async {
    if (!auth.current.signedIn) {
      return const GroupCall.fail(GroupFailure.notSignedIn);
    }
    final token = await auth.accessToken();
    if (token == null) return const GroupCall.fail(GroupFailure.notSignedIn);
    try {
      final r = await _http.send(
        'POST',
        _cfg.url.resolve('rest/v1/rpc/$name'),
        headers: {'apikey': _cfg.anonKey, 'Authorization': 'Bearer $token'},
        jsonBody: body,
      );
      if (r.status == 401) {
        return const GroupCall.fail(GroupFailure.notSignedIn);
      }
      if (r.status == 403) return const GroupCall.fail(GroupFailure.forbidden);
      // Migratsiya hali qo‘llanmagan.
      if (r.status == 404) {
        return const GroupCall.fail(GroupFailure.notConfigured);
      }
      if (!r.ok) return const GroupCall.fail(GroupFailure.server);
      final m = r.map;
      if (m['ok'] == false) {
        return GroupCall.fail(GroupFailure.fromServer(m['error']), m);
      }
      return GroupCall.ok(m);
    } on FormatException {
      return const GroupCall.fail(GroupFailure.server);
    } on SocketException {
      return const GroupCall.fail(GroupFailure.offline);
    } on TimeoutException {
      return const GroupCall.fail(GroupFailure.offline);
    } on HandshakeException {
      return const GroupCall.fail(GroupFailure.offline);
    }
  }

  GroupCall<T> _map<T>(
    GroupCall<Map<String, Object?>> r,
    T Function(Map<String, Object?>) f,
  ) {
    final v = r.value;
    if (v == null) return GroupCall.fail(r.failure!, r.extra);
    try {
      return GroupCall.ok(f(v));
    } on Object {
      return const GroupCall.fail(GroupFailure.server);
    }
  }

  GroupCall<void> _void(GroupCall<Map<String, Object?>> r) =>
      r.ok ? const GroupCall.ok(null) : GroupCall.fail(r.failure!, r.extra);

  Map<String, Object?> _a(String id) => {'p_assignment': id};

  @override
  Future<GroupCall<GroupList>> list() async =>
      _map(await _rpc('group_list', const {}), GroupList.fromJson);

  @override
  Future<GroupCall<GroupDetail>> detail(String groupId) async => _map(
    await _rpc('group_detail', {'p_group': groupId}),
    GroupDetail.fromJson,
  );

  @override
  Future<GroupCall<GroupInfo>> create(String name) async => _map(
    await _rpc('group_create', {'p_name': name}),
    (m) => GroupInfo.fromJson((m['group']! as Map).cast()),
  );

  @override
  Future<GroupCall<void>> removeMember(String groupId, String memberId) async =>
      _void(
        await _rpc('group_remove_member', {
          'p_group': groupId,
          'p_member': memberId,
        }),
      );

  @override
  Future<GroupCall<GroupAssignment>> createAssignment(
    String groupId,
    AssignmentDraft d,
  ) async => _map(
    await _rpc(
      d.isMixed ? 'group_assignment_create_mixed' : 'group_assignment_create',
      {
        'p_group': groupId,
        if (d.isMixed) 'p_title': d.title,
        if (d.isMixed) 'p_topics': d.topicIds else 'p_topic': d.topicId,
        'p_count': d.questionCount,
        'p_time_limit_min': d.timeLimitMin,
        'p_due_at': d.dueAt?.toUtc().toIso8601String(),
        'p_variant': d.variantMode,
        'p_reveal': d.reveal.wire,
      },
    ),
    (m) => GroupAssignment.fromJson((m['assignment']! as Map).cast()),
  );

  @override
  Future<GroupCall<void>> closeAssignment(String assignmentId) async =>
      _void(await _rpc('group_assignment_close', _a(assignmentId)));

  @override
  Future<GroupCall<GroupBoard>> board(String assignmentId) async => _map(
    await _rpc('group_assignment_board', _a(assignmentId)),
    GroupBoard.fromJson,
  );

  @override
  Future<GroupCall<GroupPreview>> preview(String assignmentId) async => _map(
    await _rpc('group_assignment_preview', _a(assignmentId)),
    GroupPreview.fromJson,
  );

  @override
  Future<GroupCall<List<ClassHardDetail>>> hardestDetail(
    String assignmentId, {
    int limit = 5,
  }) async => _map(
    await _rpc('group_assignment_hardest_detail', {
      ..._a(assignmentId),
      'p_limit': limit,
    }),
    (m) => [
      for (final h in (m['items'] as List? ?? const []))
        if (h is Map) ClassHardDetail.fromJson(h.cast<String, Object?>()),
    ],
  );

  @override
  Future<GroupCall<GroupJoinInfo>> join({
    required String code,
    String? nickname,
    String? assignmentId,
  }) async => _map(
    await _rpc('group_join', {
      'p_code': code,
      'p_nickname': nickname == null ? null : ClassNickname.clean(nickname),
      'p_assignment': assignmentId,
    }),
    GroupJoinInfo.fromJson,
  );

  @override
  Future<GroupCall<void>> leave(String groupId) async =>
      _void(await _rpc('group_leave', {'p_group': groupId}));

  @override
  Future<GroupCall<GroupAttempt>> open(String assignmentId) async => _map(
    await _rpc('group_assignment_open', _a(assignmentId)),
    GroupAttempt.fromJson,
  );

  @override
  Future<GroupCall<void>> save(
    String assignmentId,
    Map<String, int> answers,
  ) async => _void(
    await _rpc('group_assignment_save', {
      'p_assignment': assignmentId,
      'p_answers': answers,
    }),
  );

  @override
  Future<GroupCall<GroupSubmitInfo>> submit(
    String assignmentId,
    Map<String, int> answers,
  ) async => _map(
    await _rpc('group_assignment_submit', {
      'p_assignment': assignmentId,
      'p_answers': answers,
    }),
    GroupSubmitInfo.fromJson,
  );

  @override
  Future<GroupCall<GroupTestResult>> result(String assignmentId) async => _map(
    await _rpc('group_assignment_result', _a(assignmentId)),
    GroupTestResult.fromJson,
  );
}
