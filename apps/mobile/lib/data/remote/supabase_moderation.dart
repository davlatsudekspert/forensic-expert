import 'dart:async';
import 'dart:io';

import '../../domain/moderation/moderation_models.dart';
import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/moderation_ports.dart';
import '../../domain/support/support_models.dart';
import 'supabase_rest.dart';

/// Supabase RPC: `submit_report` (anon + kirgan), `my_reports`,
/// `qa_block_author`, `my_blocks`, `qa_unblock`, `my_terms`, `accept_terms`;
/// admin: `admin_stats_ext`, `admin_reports`, `admin_report_note`,
/// `admin_resolve_report`, `admin_set_role`, `admin_set_suspension`.
/// Jadvalga to‘g‘ridan-to‘g‘ri kirish yo‘q. Admin huquqini, rol qoidalarini va
/// soatiga 5 ta cheklovni server tekshiradi.
class SupabaseModerationService implements ModerationService {
  SupabaseModerationService({
    required SupabaseConfig config,
    required this.auth,
    required this.deviceKey,
    RestTransport? transport,
  }) : _cfg = config,
       _http = transport ?? HttpClientTransport();

  final SupabaseConfig _cfg;
  final AuthRepository auth;

  /// Qurilmaga bog‘langan tasodifiy kalit (shaxsiy ma’lumot emas): kirmagan
  /// foydalanuvchining soatiga limitini server shu kalit (va IP) xeshi
  /// bo‘yicha hisoblaydi.
  final Future<String> Function() deviceKey;
  final RestTransport _http;

  @override
  bool get isConfigured => true;

  /// [anonymous] — kirmagan foydalanuvchi ham yuborishi mumkin bo‘lgan RPC.
  Future<RestResponse?> _rpc(
    String name,
    Map<String, Object?> body, {
    bool anonymous = false,
  }) async {
    String? token;
    if (auth.current.signedIn) {
      token = await auth.accessToken();
    }
    if (token == null && !anonymous) return null;
    try {
      return await _http.send(
        'POST',
        _cfg.url.resolve('rest/v1/rpc/$name'),
        headers: {
          'apikey': _cfg.anonKey,
          'Authorization': 'Bearer ${token ?? _cfg.anonKey}',
        },
        jsonBody: body,
      );
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    } on HandshakeException {
      return null;
    }
  }

  // ------------------------------------------------------------ user
  @override
  Future<ReportResult> submitReport(ReportDraft d) async {
    if (d.error != null) return ReportResult.invalid;
    final contact = (d.contact ?? '').trim();
    final r = await _rpc('submit_report', {
      'p_kind': d.kind.wire,
      'p_body': d.cleanBody,
      'p_target_type': d.target?.wire,
      'p_target_id': d.targetId,
      'p_contact': contact.isEmpty ? null : contact,
      'p_device_key': await deviceKey(),
    }, anonymous: true);
    if (r == null || !r.ok || r.json is! Map) return ReportResult.failed;
    return ReportResult.fromWire(r.map['result']);
  }

  @override
  Future<List<MyReport>?> myReports() async {
    final r = await _rpc('my_reports', const {});
    if (r == null || !r.ok) return null;
    return [
      for (final e in r.list)
        if (e is Map) MyReport.fromJson(e.cast<String, Object?>()),
    ];
  }

  @override
  Future<BlockResult> blockAuthor(ReportTarget target, String postId) async {
    final r = await _rpc('qa_block_author', {
      'p_target_type': target == ReportTarget.qaQuestion
          ? 'question'
          : 'answer',
      'p_target_id': postId,
    });
    return r != null && r.ok
        ? BlockResult.fromWire(r.json)
        : BlockResult.failed;
  }

  @override
  Future<List<BlockedAuthor>?> myBlocks() async {
    final r = await _rpc('my_blocks', const {});
    if (r == null || !r.ok) return null;
    return [
      for (final e in r.list)
        if (e is Map) BlockedAuthor.fromJson(e.cast<String, Object?>()),
    ];
  }

  @override
  Future<bool> unblock(String blockId) async {
    final r = await _rpc('qa_unblock', {'p_block_id': blockId});
    return r != null && r.ok && r.json == true;
  }

  @override
  Future<bool?> communityTermsAccepted() async {
    final r = await _rpc('my_terms', const {});
    if (r == null || !r.ok) return null;
    return r.list.any(
      (e) =>
          e is Map &&
          e['doc'] == CommunityTerms.doc &&
          e['version'] == CommunityTerms.version,
    );
  }

  @override
  Future<bool> acceptCommunityTerms() async {
    final r = await _rpc('accept_terms', {
      'p_doc': CommunityTerms.doc,
      'p_version': CommunityTerms.version,
    });
    return r != null && r.ok && r.json == 'ACCEPTED';
  }

  // ------------------------------------------------------------ admin
  @override
  Future<AdminStatsExt?> adminStatsExt() async {
    final r = await _rpc('admin_stats_ext', const {});
    return r != null && r.ok && r.json is Map
        ? AdminStatsExt.fromJson(r.map)
        : null;
  }

  @override
  Future<AdminPage<AdminReport>?> adminReports(
    AdminReportFilter filter, {
    int limit = AdminReportFilter.pageSize,
    int offset = 0,
  }) async {
    final q = filter.query.trim();
    final r = await _rpc('admin_reports', {
      'p_status': filter.status.wire,
      'p_kind': filter.kind?.wire,
      // Xom qidiruv: `%`, `_`, `\` ni server ekranlaydi (ilova o‘zgartirmaydi).
      'p_query': q.isEmpty ? null : q,
      'p_limit': limit,
      'p_offset': offset,
    });
    if (r == null || !r.ok || r.json is! Map) return null;
    final m = r.map;
    return AdminPage(
      total: (m['total'] as num?)?.toInt() ?? 0,
      items: [
        for (final e in (m['items'] as List?) ?? const [])
          if (e is Map) AdminReport.fromJson(e.cast<String, Object?>()),
      ],
    );
  }

  @override
  Future<bool> adminReportNote(String id, String note) async {
    final r = await _rpc('admin_report_note', {
      'p_id': id,
      'p_note': note.trim(),
    });
    return r != null && r.ok && r.json == 'SAVED';
  }

  @override
  Future<bool> adminResolveReport(
    String id, {
    bool resolved = true,
    String? note,
  }) async {
    final n = (note ?? '').trim();
    final r = await _rpc('admin_resolve_report', {
      'p_id': id,
      'p_resolved': resolved,
      'p_note': n.isEmpty ? null : n,
    });
    return r != null && r.ok && (r.json == 'RESOLVED' || r.json == 'REOPENED');
  }

  @override
  Future<RoleChangeResult> adminSetRole(
    String userId,
    ManagedRole role, {
    required bool grant,
    required String reason,
  }) async {
    final r = await _rpc('admin_set_role', {
      'p_user': userId,
      'p_role': role.wire,
      'p_grant': grant,
      'p_reason': reason.trim(),
    });
    return r != null && r.ok
        ? RoleChangeResult.fromWire(r.json)
        : RoleChangeResult.failed;
  }

  @override
  Future<SuspensionResult> adminSetSuspension(
    String userId, {
    required bool suspend,
    required String reason,
  }) async {
    final r = await _rpc('admin_set_suspension', {
      'p_user': userId,
      'p_suspend': suspend,
      'p_reason': reason.trim(),
    });
    return r != null && r.ok
        ? SuspensionResult.fromWire(r.json)
        : SuspensionResult.failed;
  }
}
