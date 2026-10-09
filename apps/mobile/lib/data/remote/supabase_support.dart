import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/support_ports.dart';
import '../../domain/support/support_models.dart';
import 'supabase_rest.dart';

/// Supabase RPC: `create_support_thread`, `add_support_message`,
/// `my_support_threads`, `support_thread`, `support_unread_count`,
/// `mark_support_read`; admin: `admin_stats`, `admin_support_inbox`,
/// `admin_reply_support`, `admin_set_support_status`, `admin_users`,
/// `admin_audit_log`. Jadvalga to‘g‘ridan-to‘g‘ri kirish yo‘q — faqat
/// SECURITY DEFINER RPC. Rasmlar: shaxsiy bucket `support-attachments`,
/// yo‘l `<uid>/<uuid>.<ext>` (storage siyosati boshqa papkaga yozdirmaydi).
/// Xabar matni jurnalga yozilmaydi.
class SupabaseSupportService implements SupportService {
  SupabaseSupportService({
    required SupabaseConfig config,
    required this.auth,
    RestTransport? transport,
    Random? random,
  }) : _cfg = config,
       _http = transport ?? HttpClientTransport(),
       _random = random ?? Random.secure();

  static const bucket = 'support-attachments';

  final SupabaseConfig _cfg;
  final AuthRepository auth;
  final RestTransport _http;
  final Random _random;

  @override
  bool get isConfigured => true;

  Future<String?> _token() async {
    if (!auth.current.signedIn) return null;
    return auth.accessToken();
  }

  Future<RestResponse?> _send(
    String path, {
    Object? json,
    List<int>? bytes,
    String? contentType,
  }) async {
    final token = await _token();
    if (token == null) return null;
    try {
      return await _http.send(
        'POST',
        _cfg.url.resolve(path),
        headers: {'apikey': _cfg.anonKey, 'Authorization': 'Bearer $token'},
        jsonBody: json,
        bytes: bytes,
        contentType: contentType,
      );
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    } on HandshakeException {
      return null;
    }
  }

  Future<RestResponse?> _rpc(String name, Map<String, Object?> body) =>
      _send('rest/v1/rpc/$name', json: body);

  /// RFC 4122 v4 (kriptografik tasodifiy).
  String _uuid() {
    final b = List<int>.generate(16, (_) => _random.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }

  /// Rasmni yuklaydi; storage yo‘li yoki `null` (xato / ruxsat yo‘q).
  Future<String?> _upload(SupportAttachment a) async {
    final uid = auth.current.account?.userId;
    if (uid == null || uid.isEmpty) return null;
    if (a.bytes.length > SupportLimits.attachmentBytes) return null;
    if (a.mimeType != 'image/jpeg' && a.mimeType != 'image/png') return null;
    final path = '$uid/${_uuid()}.${a.extension}';
    final r = await _send(
      'storage/v1/object/$bucket/$path',
      bytes: a.bytes,
      contentType: a.mimeType,
    );
    return r != null && r.ok ? path : null;
  }

  @override
  Future<SupportCreateResult> createThread(SupportDraft d) async {
    String? path;
    if (d.attachment case final a?) {
      path = await _upload(a);
      if (path == null) return SupportCreateResult.failed;
    }
    final r = await _rpc('create_support_thread', {
      'p_category': d.category.wire,
      'p_subject': d.subject.trim(),
      'p_body': d.body.trim(),
      'p_attachment_path': path,
      'p_consent': d.consent,
      'p_related_entity': d.relatedEntity,
    });
    return r != null && r.ok
        ? SupportCreateResult.fromJson(r.map)
        : SupportCreateResult.failed;
  }

  @override
  Future<SupportSendResult> sendMessage(
    String threadId,
    String body, {
    SupportAttachment? attachment,
  }) async {
    String? path;
    if (attachment != null) {
      path = await _upload(attachment);
      if (path == null) return SupportSendResult.failed;
    }
    final r = await _rpc('add_support_message', {
      'p_thread_id': threadId,
      'p_body': body.trim(),
      'p_attachment_path': path,
    });
    return r != null && r.ok
        ? SupportSendResult.fromWire(r.json)
        : SupportSendResult.failed;
  }

  @override
  Future<List<SupportThread>?> myThreads() async {
    final r = await _rpc('my_support_threads', const {});
    if (r == null || !r.ok) return null;
    return [
      for (final e in r.list)
        if (e is Map) SupportThread.fromJson(e.cast<String, Object?>()),
    ];
  }

  @override
  Future<SupportThread?> thread(String id) async {
    final r = await _rpc('support_thread', {'p_thread_id': id});
    return r != null && r.ok && r.json is Map
        ? SupportThread.fromJson(r.map)
        : null;
  }

  @override
  Future<int> unreadCount() async {
    final r = await _rpc('support_unread_count', const {});
    return r != null && r.ok && r.json is num ? (r.json! as num).toInt() : 0;
  }

  @override
  Future<void> markRead(String id) async {
    await _rpc('mark_support_read', {'p_thread_id': id});
  }

  @override
  Future<Uri?> attachmentUrl(String path) async {
    final r = await _send(
      'storage/v1/object/sign/$bucket/$path',
      json: const {'expiresIn': 300},
    );
    final signed = r != null && r.ok ? r.map['signedURL'] : null;
    if (signed is! String || signed.isEmpty) return null;
    final rel = signed.startsWith('/') ? signed.substring(1) : signed;
    return _cfg.url.resolve('storage/v1/$rel');
  }

  // ------------------------------------------------------------ admin
  @override
  Future<AdminStats?> adminStats() async {
    final r = await _rpc('admin_stats', const {});
    return r != null && r.ok && r.json is Map
        ? AdminStats.fromJson(r.map)
        : null;
  }

  @override
  Future<AdminPage<SupportThread>?> adminInbox(
    SupportInboxFilter filter, {
    int limit = 25,
    int offset = 0,
  }) async {
    final q = filter.query.trim();
    final r = await _rpc('admin_support_inbox', {
      'p_status': filter.status,
      'p_category': filter.category?.wire,
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
          if (e is Map) SupportThread.fromJson(e.cast<String, Object?>()),
      ],
    );
  }

  @override
  Future<SupportSendResult> adminReply(String threadId, String body) async {
    final r = await _rpc('admin_reply_support', {
      'p_thread_id': threadId,
      'p_body': body.trim(),
    });
    return r != null && r.ok
        ? SupportSendResult.fromWire(r.json)
        : SupportSendResult.failed;
  }

  @override
  Future<SupportStatus?> adminSetStatus(
    String threadId,
    SupportStatus status,
  ) async {
    final r = await _rpc('admin_set_support_status', {
      'p_thread_id': threadId,
      'p_status': status.wire,
    });
    return r != null && r.ok && r.json == status.wire ? status : null;
  }

  @override
  Future<AdminPage<AdminUserSummary>?> adminUsers(
    AdminUserFilter filter,
  ) async {
    final q = filter.search.trim();
    final r = await _rpc('admin_users', {
      'p_search': q.isEmpty ? null : q,
      'p_role': filter.role,
      'p_tier': filter.tier,
      'p_limit': AdminUserFilter.pageSize,
      'p_offset': filter.offset,
    });
    if (r == null || !r.ok || r.json is! Map) return null;
    final m = r.map;
    return AdminPage(
      total: (m['total'] as num?)?.toInt() ?? 0,
      items: [
        for (final e in (m['items'] as List?) ?? const [])
          if (e is Map) AdminUserSummary.fromJson(e.cast<String, Object?>()),
      ],
    );
  }

  @override
  Future<List<AdminAuditEntry>?> adminAuditLog({int limit = 100}) async {
    final r = await _rpc('admin_audit_log', {'p_limit': limit});
    if (r == null || !r.ok) return null;
    return [
      for (final e in r.list)
        if (e is Map) AdminAuditEntry.fromJson(e.cast<String, Object?>()),
    ];
  }
}
