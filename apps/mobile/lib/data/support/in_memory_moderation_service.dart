import '../../domain/moderation/moderation_models.dart';
import '../../domain/ports/moderation_ports.dart';
import '../../domain/support/support_models.dart';

/// FAQAT test/namoyish uchun xotiradagi taqlid (haqiqiy server emas). Server
/// qoidalarini mantiq darajasida takrorlaydi: soatiga 5 ta, admin
/// to‘xtatilmaydi, o‘zini o‘zgartirib bo‘lmaydi, post muallifi oshkor bo‘lmaydi.
class InMemoryModerationService implements ModerationService {
  InMemoryModerationService({
    this.isAdmin = false,
    this.selfId = 'self',
    this.signedIn = true,
    DateTime Function()? now,
    this.termsAccepted = false,
  }) : _now = now ?? DateTime.now;

  /// `true` bo‘lsa admin RPC’lar ishlaydi (serverdagi `admin_guard` taqlidi).
  final bool isAdmin;
  final String selfId;
  final bool signedIn;
  final DateTime Function() _now;
  bool termsAccepted;

  final reports = <AdminReport>[];
  final _sent = <DateTime>[];
  final blocks = <String>[];
  final roleCalls = <(String, ManagedRole, bool, String)>[];
  final suspensionCalls = <(String, bool, String)>[];
  final suspended = <String>{};
  final admins = <String>{};
  final lastSearches = <String>[];
  var _seq = 0;

  @override
  bool get isConfigured => true;

  @override
  Future<ReportResult> submitReport(ReportDraft d) async {
    if (d.error != null) return ReportResult.invalid;
    final since = _now().subtract(const Duration(hours: 1));
    _sent.removeWhere((t) => t.isBefore(since));
    if (_sent.length >= ReportLimits.perHour) return ReportResult.rateLimited;
    _sent.add(_now());
    reports.add(
      AdminReport(
        id: 'r${_seq++}',
        kind: d.kind,
        body: d.cleanBody,
        resolved: false,
        contact: d.contact,
        targetType: d.target?.wire,
        targetId: d.targetId,
        anonymous: !signedIn,
        reporterEmail: signedIn ? 'me@example.com' : null,
        createdAt: _now(),
      ),
    );
    return ReportResult.created;
  }

  @override
  Future<List<MyReport>?> myReports() async => signedIn
      ? [
          for (final r in reports.where((r) => !r.anonymous))
            MyReport(
              id: r.id,
              kind: r.kind,
              resolved: r.resolved,
              createdAt: r.createdAt,
            ),
        ]
      : null;

  @override
  Future<BlockResult> blockAuthor(ReportTarget target, String postId) async {
    if (blocks.contains(postId)) return BlockResult.already;
    blocks.add(postId);
    return BlockResult.blocked;
  }

  @override
  Future<List<BlockedAuthor>?> myBlocks() async => [
    for (final b in blocks) BlockedAuthor(id: b, createdAt: _now()),
  ];

  @override
  Future<bool> unblock(String blockId) async => blocks.remove(blockId);

  @override
  Future<bool?> communityTermsAccepted() async => termsAccepted;

  @override
  Future<bool> acceptCommunityTerms() async {
    termsAccepted = true;
    return true;
  }

  // ------------------------------------------------------------ admin
  @override
  Future<AdminStatsExt?> adminStatsExt() async => isAdmin
      ? AdminStatsExt(
          admins: admins.length + 1,
          suspended: suspended.length,
          reportsOpen: reports.where((r) => !r.resolved).length,
          reportsResolved: reports.where((r) => r.resolved).length,
          blocks: blocks.length,
        )
      : null;

  @override
  Future<AdminPage<AdminReport>?> adminReports(
    AdminReportFilter filter, {
    int limit = AdminReportFilter.pageSize,
    int offset = 0,
  }) async {
    if (!isAdmin) return null;
    final q = filter.query.trim();
    if (q.isNotEmpty) lastSearches.add(q);
    final items = [
      for (final r in reports.reversed)
        if ((filter.status == AdminReportStatus.all ||
                r.resolved == (filter.status == AdminReportStatus.resolved)) &&
            (filter.kind == null || r.kind == filter.kind) &&
            // `contains` — qidiruv HARFMA-HARF (%, _ , \ maxsus emas).
            (q.isEmpty ||
                r.body.toLowerCase().contains(q.toLowerCase()) ||
                (r.contact ?? '').toLowerCase().contains(q.toLowerCase())))
          r,
    ];
    return AdminPage(
      total: items.length,
      items: items.skip(offset).take(limit).toList(),
    );
  }

  @override
  Future<bool> adminReportNote(String id, String note) async {
    if (!isAdmin || note.trim().isEmpty) return false;
    return _update(id, (r) => r.copyWith(adminNote: note.trim()));
  }

  @override
  Future<bool> adminResolveReport(
    String id, {
    bool resolved = true,
    String? note,
  }) async {
    if (!isAdmin) return false;
    return _update(
      id,
      (r) => r.copyWith(
        resolved: resolved,
        adminNote: (note ?? '').trim().isEmpty ? null : note!.trim(),
      ),
    );
  }

  bool _update(String id, AdminReport Function(AdminReport) f) {
    final i = reports.indexWhere((r) => r.id == id);
    if (i < 0) return false;
    reports[i] = f(reports[i]);
    return true;
  }

  @override
  Future<RoleChangeResult> adminSetRole(
    String userId,
    ManagedRole role, {
    required bool grant,
    required String reason,
  }) async {
    if (!isAdmin) return RoleChangeResult.failed;
    roleCalls.add((userId, role, grant, reason));
    if (reason.trim().length < 5) return RoleChangeResult.invalid;
    if (role == ManagedRole.identityAdmin) {
      if (userId == selfId) return RoleChangeResult.selfAdminChange;
      if (grant) return RoleChangeResult.forbiddenRole;
    }
    return grant ? RoleChangeResult.granted : RoleChangeResult.revoked;
  }

  @override
  Future<SuspensionResult> adminSetSuspension(
    String userId, {
    required bool suspend,
    required String reason,
  }) async {
    if (!isAdmin) return SuspensionResult.failed;
    suspensionCalls.add((userId, suspend, reason));
    if (reason.trim().length < 5) return SuspensionResult.invalid;
    if (suspend) {
      if (userId == selfId) return SuspensionResult.cannotSuspendSelf;
      if (admins.contains(userId)) return SuspensionResult.cannotSuspendAdmin;
      return suspended.add(userId)
          ? SuspensionResult.suspended
          : SuspensionResult.unchanged;
    }
    return suspended.remove(userId)
        ? SuspensionResult.restored
        : SuspensionResult.unchanged;
  }
}
