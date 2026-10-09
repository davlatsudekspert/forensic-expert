import '../../domain/ports/support_ports.dart';
import '../../domain/support/support_models.dart';

/// Xotiradagi soxta xizmat — TESTLAR va oflayn namoyish uchun. Server
/// qoidalarini (muallif, admin, rozilik, uzunlik, holatlar) soddalashtirib
/// takrorlaydi; tarmoqqa chiqmaydi. Ishlab chiqarishda ishlatilmaydi.
class InMemorySupportService implements SupportService {
  InMemorySupportService({this.isAdmin = false, this.stats});

  /// Test sozlamasi: joriy foydalanuvchi admin (serverdagi roli taqlidi).
  bool isAdmin;
  AdminStats? stats;
  final users = <AdminUserSummary>[];
  final audit = <AdminAuditEntry>[];
  final _threads = <_Thread>[];
  int _seq = 0;
  int _msg = 0;

  /// Barcha murojaatlar (test tekshiruvlari uchun).
  List<String> get threadIds => [for (final t in _threads) t.id];

  void _log(String action, String target, [Map<String, Object?>? d]) =>
      audit.insert(
        0,
        AdminAuditEntry(
          id: audit.length + 1,
          action: action,
          actorEmail: 'admin@test',
          targetType: 'support_thread',
          targetId: target,
          detail: d ?? const {},
          createdAt: DateTime.now(),
        ),
      );

  /// Boshqa foydalanuvchi yuborgan murojaat (admin inbox testlari uchun).
  String seedThread({
    required SupportCategory category,
    required String subject,
    required String body,
    String authorEmail = 'student@test.uz',
    String? relatedEntity,
    bool mine = false,
  }) {
    final t = _Thread(
      id: 'thread-${++_seq}',
      category: category,
      subject: subject,
      relatedEntity: relatedEntity,
      authorEmail: authorEmail,
      mine: mine,
    );
    t.messages.add(_Msg(++_msg, false, body, null, mine));
    _threads.insert(0, t);
    return t.id;
  }

  /// Admin javobini taqlid qiladi (muallif ko‘rinishi testlari uchun).
  void simulateAdminReply(String threadId, String body) {
    final t = _threads.firstWhere((x) => x.id == threadId);
    t.messages.add(_Msg(++_msg, true, body, null, false));
    t.status = SupportStatus.answered;
    t.unreadForAuthor++;
  }

  SupportThread _view(_Thread t, {bool full = false, bool admin = false}) =>
      SupportThread(
        id: t.id,
        category: t.category,
        subject: t.subject,
        status: t.status,
        relatedEntity: t.relatedEntity,
        createdAt: t.createdAt,
        updatedAt: t.createdAt,
        messageCount: t.messages.length,
        unread: admin ? t.unreadForAdmin : t.unreadForAuthor,
        lastMessage: t.messages.last.body,
        authorEmail: admin ? t.authorEmail : null,
        hasAttachment: t.messages.any((m) => m.attachment != null),
        messages: full
            ? [
                for (final m in t.messages)
                  SupportMessage(
                    id: m.id,
                    fromAdmin: m.admin,
                    body: m.body,
                    attachmentPath: m.attachment,
                    createdAt: t.createdAt,
                    mine: admin ? m.admin : m.mine,
                  ),
              ]
            : const [],
      );

  @override
  bool get isConfigured => true;

  @override
  Future<SupportCreateResult> createThread(SupportDraft d) async {
    if (!d.consent) {
      return const SupportCreateResult(SupportCreateOutcome.consentRequired);
    }
    final subject = d.subject.trim();
    final body = d.body.trim();
    if (subject.isEmpty ||
        subject.length > SupportLimits.subject ||
        body.isEmpty ||
        body.length > SupportLimits.body) {
      return const SupportCreateResult(SupportCreateOutcome.invalid);
    }
    final t = _Thread(
      id: 'thread-${++_seq}',
      category: d.category,
      subject: subject,
      relatedEntity: d.relatedEntity,
      authorEmail: 'me@test.uz',
      mine: true,
    );
    t.messages.add(
      _Msg(
        ++_msg,
        false,
        body,
        d.attachment == null ? null : 'me/${t.id}.${d.attachment!.extension}',
        true,
      ),
    );
    t.unreadForAdmin = 1;
    _threads.insert(0, t);
    return SupportCreateResult(SupportCreateOutcome.created, t.id);
  }

  @override
  Future<SupportSendResult> sendMessage(
    String threadId,
    String body, {
    SupportAttachment? attachment,
  }) async {
    final t = _threads.where((x) => x.id == threadId && x.mine).firstOrNull;
    if (t == null) return SupportSendResult.notFound;
    if (t.status == SupportStatus.closed) return SupportSendResult.closed;
    if (body.trim().isEmpty) return SupportSendResult.invalid;
    t.messages.add(_Msg(++_msg, false, body.trim(), null, true));
    t.unreadForAdmin++;
    if (t.status == SupportStatus.answered) {
      t.status = SupportStatus.newRequest;
    }
    return SupportSendResult.sent;
  }

  @override
  Future<List<SupportThread>?> myThreads() async => [
    for (final t in _threads)
      if (t.mine) _view(t),
  ];

  @override
  Future<SupportThread?> thread(String id) async {
    final t = _threads.where((x) => x.id == id).firstOrNull;
    if (t == null) return null;
    if (t.mine) return _view(t, full: true);
    if (!isAdmin) return null;
    _log('SUPPORT_THREAD_VIEW', id);
    return _view(t, full: true, admin: true);
  }

  @override
  Future<int> unreadCount() async => _threads
      .where((t) => t.mine)
      .fold<int>(0, (s, t) => s + t.unreadForAuthor);

  @override
  Future<void> markRead(String id) async {
    final t = _threads.where((x) => x.id == id).firstOrNull;
    if (t == null) return;
    if (t.mine) {
      t.unreadForAuthor = 0;
    } else if (isAdmin) {
      t.unreadForAdmin = 0;
    }
  }

  @override
  Future<Uri?> attachmentUrl(String path) async => null;

  @override
  Future<AdminStats?> adminStats() async => isAdmin ? stats : null;

  @override
  Future<AdminPage<SupportThread>?> adminInbox(
    SupportInboxFilter filter, {
    int limit = 25,
    int offset = 0,
  }) async {
    if (!isAdmin) return null;
    final q = filter.query.trim().toLowerCase();
    final all = [
      for (final t in _threads)
        if ((filter.status == null ||
                t.status.wire == filter.status ||
                (filter.status == 'AWAITING' && t.status.awaiting)) &&
            (filter.category == null || t.category == filter.category) &&
            (q.isEmpty ||
                t.subject.toLowerCase().contains(q) ||
                t.authorEmail.toLowerCase().contains(q)))
          _view(t, admin: true),
    ];
    return AdminPage(
      total: all.length,
      items: all.skip(offset).take(limit).toList(),
    );
  }

  @override
  Future<SupportSendResult> adminReply(String threadId, String body) async {
    if (!isAdmin) return SupportSendResult.failed;
    final t = _threads.where((x) => x.id == threadId).firstOrNull;
    if (t == null) return SupportSendResult.notFound;
    if (body.trim().isEmpty) return SupportSendResult.invalid;
    simulateAdminReply(threadId, body.trim());
    t.unreadForAdmin = 0;
    _log('SUPPORT_REPLY', threadId, {'length': body.trim().length});
    return SupportSendResult.sent;
  }

  @override
  Future<SupportStatus?> adminSetStatus(
    String threadId,
    SupportStatus status,
  ) async {
    if (!isAdmin) return null;
    final t = _threads.where((x) => x.id == threadId).firstOrNull;
    if (t == null) return null;
    final from = t.status;
    t.status = status;
    _log('SUPPORT_STATUS', threadId, {'from': from.wire, 'to': status.wire});
    return status;
  }

  @override
  Future<AdminPage<AdminUserSummary>?> adminUsers(
    AdminUserFilter filter,
  ) async {
    if (!isAdmin) return null;
    final q = filter.search.trim().toLowerCase();
    final all = [
      for (final u in users)
        if ((q.isEmpty ||
                u.email.toLowerCase().contains(q) ||
                (u.displayName ?? '').toLowerCase().contains(q)) &&
            (filter.role == null ||
                (filter.role == 'admin' && u.isAdmin) ||
                (filter.role == 'moderator' &&
                    u.roles.contains('publication_moderator'))) &&
            (filter.tier == null ||
                (filter.tier == 'free' && u.tier == null) ||
                (filter.tier == 'pro' && u.tier != null)))
          u,
    ];
    return AdminPage(
      total: all.length,
      items: all.skip(filter.offset).take(AdminUserFilter.pageSize).toList(),
    );
  }

  @override
  Future<List<AdminAuditEntry>?> adminAuditLog({int limit = 100}) async =>
      isAdmin ? audit.take(limit).toList() : null;
}

class _Thread {
  _Thread({
    required this.id,
    required this.category,
    required this.subject,
    required this.authorEmail,
    required this.mine,
    this.relatedEntity,
  }) : createdAt = DateTime(2026, 10, 9, 10, 30);

  final String id;
  final SupportCategory category;
  final String subject;
  final String? relatedEntity;
  final String authorEmail;
  final bool mine;
  final DateTime createdAt;
  SupportStatus status = SupportStatus.newRequest;
  int unreadForAuthor = 0;
  int unreadForAdmin = 1;
  final messages = <_Msg>[];
}

class _Msg {
  _Msg(this.id, this.admin, this.body, this.attachment, this.mine);

  final int id;
  final bool admin;
  final String body;
  final String? attachment;
  final bool mine;
}
