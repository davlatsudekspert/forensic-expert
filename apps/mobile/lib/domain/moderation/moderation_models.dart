/// Shikoyat/murojaat, bloklash va admin kengaytmasi modellari. Huquq,
/// tezlik (soatiga 5 ta), ekranlash va rol qoidalari faqat serverda
/// tekshiriladi — bu yerdagi qiymatlar faqat UI uchun.
library;

import 'package:flutter/foundation.dart';

/// Server bilan bir xil cheklovlar (UI tekshiruvi; server baribir tekshiradi).
abstract final class ReportLimits {
  static const bodyMin = 5;
  static const bodyMax = 2000;
  static const contactMax = 200;

  /// Bir foydalanuvchi/qurilma soatiga eng ko‘pi bilan (server: `submit_report`).
  static const perHour = 5;
}

/// Shikoyat turkumi (server `user_reports.kind`).
enum ReportKind {
  complaint('COMPLAINT'),
  inappropriate('INAPPROPRIATE_CONTENT'),
  bug('BUG'),
  advertising('ADVERTISING'),
  other('OTHER');

  const ReportKind(this.wire);
  final String wire;

  static ReportKind fromWire(Object? v) =>
      values.firstWhere((k) => k.wire == v, orElse: () => ReportKind.other);
}

/// Shikoyat nimaga qaratilgan (ixtiyoriy; Savol-javob posti uchun).
enum ReportTarget {
  qaQuestion('qa_question'),
  qaAnswer('qa_answer');

  const ReportTarget(this.wire);
  final String wire;
}

@immutable
class ReportDraft {
  const ReportDraft({
    required this.kind,
    required this.body,
    this.contact,
    this.target,
    this.targetId,
  });

  final ReportKind kind;
  final String body;

  /// Kirmagan odam javob olishi uchun ixtiyoriy manzil.
  final String? contact;
  final ReportTarget? target;
  final String? targetId;

  String get cleanBody => body.trim();

  ReportDraftError? get error {
    final b = cleanBody;
    if (b.length < ReportLimits.bodyMin) return ReportDraftError.bodyTooShort;
    if (b.length > ReportLimits.bodyMax) return ReportDraftError.bodyTooLong;
    if ((contact ?? '').trim().length > ReportLimits.contactMax) {
      return ReportDraftError.contactTooLong;
    }
    return null;
  }
}

enum ReportDraftError { bodyTooShort, bodyTooLong, contactTooLong }

/// `submit_report` natijasi. [failed] — tarmoq/server xatosi.
enum ReportResult {
  created,
  invalid,
  rateLimited,
  suspended,
  failed;

  static ReportResult fromWire(Object? v) => switch (v) {
    'CREATED' => created,
    'INVALID' => invalid,
    'RATE_LIMITED' => rateLimited,
    'SUSPENDED' => suspended,
    _ => failed,
  };
}

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

int _int(Object? v) => switch (v) {
  final num x => x.toInt(),
  final String s => int.tryParse(s) ?? 0,
  _ => 0,
};

Map<String, Object?> _map(Object? v) =>
    v is Map ? v.cast<String, Object?>() : const {};

/// Foydalanuvchining o‘z shikoyati: faqat tur va holat (matn/izoh yo‘q).
@immutable
class MyReport {
  const MyReport({
    required this.id,
    required this.kind,
    required this.resolved,
    this.createdAt,
    this.resolvedAt,
  });

  factory MyReport.fromJson(Map<String, Object?> j) => MyReport(
    id: j['id'] as String? ?? '',
    kind: ReportKind.fromWire(j['kind']),
    resolved: j['status'] == 'RESOLVED',
    createdAt: _date(j['created_at']),
    resolvedAt: _date(j['resolved_at']),
  );

  final String id;
  final ReportKind kind;
  final bool resolved;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
}

/// Admin ko‘rinishidagi shikoyat.
@immutable
class AdminReport {
  const AdminReport({
    required this.id,
    required this.kind,
    required this.body,
    required this.resolved,
    this.contact,
    this.targetType,
    this.targetId,
    this.reporterEmail,
    this.anonymous = false,
    this.adminNote,
    this.createdAt,
    this.resolvedAt,
  });

  factory AdminReport.fromJson(Map<String, Object?> j) => AdminReport(
    id: j['id'] as String? ?? '',
    kind: ReportKind.fromWire(j['kind']),
    body: j['body'] as String? ?? '',
    resolved: j['status'] == 'RESOLVED',
    contact: j['contact'] as String?,
    targetType: j['target_type'] as String?,
    targetId: j['target_id'] as String?,
    reporterEmail: j['reporter_email'] as String?,
    anonymous: j['anonymous'] == true,
    adminNote: j['admin_note'] as String?,
    createdAt: _date(j['created_at']),
    resolvedAt: _date(j['resolved_at']),
  );

  final String id;
  final ReportKind kind;
  final String body;
  final bool resolved;
  final String? contact;
  final String? targetType;
  final String? targetId;
  final String? reporterEmail;
  final bool anonymous;
  final String? adminNote;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  AdminReport copyWith({bool? resolved, String? adminNote}) => AdminReport(
    id: id,
    kind: kind,
    body: body,
    resolved: resolved ?? this.resolved,
    contact: contact,
    targetType: targetType,
    targetId: targetId,
    reporterEmail: reporterEmail,
    anonymous: anonymous,
    adminNote: adminNote ?? this.adminNote,
    createdAt: createdAt,
    resolvedAt: resolved == true ? DateTime.now() : resolvedAt,
  );
}

@immutable
class AdminReportFilter {
  const AdminReportFilter({
    this.status = AdminReportStatus.open,
    this.kind,
    this.query = '',
  });

  static const pageSize = 25;

  final AdminReportStatus status;
  final ReportKind? kind;

  /// Qidiruv xom holda yuboriladi; `%`, `_`, `\` ni server ekranlaydi.
  final String query;

  AdminReportFilter copyWith({
    AdminReportStatus? status,
    ReportKind? Function()? kind,
    String? query,
  }) => AdminReportFilter(
    status: status ?? this.status,
    kind: kind != null ? kind() : this.kind,
    query: query ?? this.query,
  );

  @override
  bool operator ==(Object other) =>
      other is AdminReportFilter &&
      other.status == status &&
      other.kind == kind &&
      other.query == query;

  @override
  int get hashCode => Object.hash(status, kind, query);
}

enum AdminReportStatus {
  open('OPEN'),
  resolved('RESOLVED'),
  all(null);

  const AdminReportStatus(this.wire);
  final String? wire;
}

/// `admin_set_role` natijasi.
enum RoleChangeResult {
  granted,
  revoked,
  unchanged,
  notFound,
  invalid,
  forbiddenRole,
  emailUnconfirmed,
  selfAdminChange,
  lastAdmin,
  failed;

  static RoleChangeResult fromWire(Object? v) => switch (v) {
    'GRANTED' => granted,
    'REVOKED' => revoked,
    'UNCHANGED' => unchanged,
    'NOT_FOUND' => notFound,
    'INVALID' => invalid,
    'FORBIDDEN_ROLE' => forbiddenRole,
    'EMAIL_UNCONFIRMED' => emailUnconfirmed,
    'SELF_ADMIN_CHANGE' => selfAdminChange,
    'LAST_ADMIN' => lastAdmin,
    _ => failed,
  };

  bool get ok => this == granted || this == revoked || this == unchanged;
}

/// `admin_set_suspension` natijasi.
enum SuspensionResult {
  suspended,
  restored,
  unchanged,
  notFound,
  invalid,
  cannotSuspendAdmin,
  cannotSuspendSelf,
  failed;

  static SuspensionResult fromWire(Object? v) => switch (v) {
    'SUSPENDED' => suspended,
    'RESTORED' => restored,
    'UNCHANGED' => unchanged,
    'NOT_FOUND' => notFound,
    'INVALID' => invalid,
    'CANNOT_SUSPEND_ADMIN' => cannotSuspendAdmin,
    'CANNOT_SUSPEND_SELF' => cannotSuspendSelf,
    _ => failed,
  };

  bool get ok => this == suspended || this == restored || this == unchanged;
}

/// Admin boshqaradigan rollar (serverda `account_roles`). Ilmiy reviewer
/// (`scope_grantor`) bu yerdan berilmaydi: admin ≠ reviewer.
enum ManagedRole {
  publicationModerator('publication_moderator'),
  identityAdmin('identity_admin');

  const ManagedRole(this.wire);
  final String wire;
}

/// `admin_stats_ext()` — faqat agregat sonlar. Serverga ko‘rinmaydigan
/// narsalar (yuklab olish, sotuv, «hozir tizimda», casebook) `null`/`false`
/// — o‘ylab topilgan son yo‘q.
@immutable
class AdminStatsExt {
  const AdminStatsExt({
    this.admins = 0,
    this.moderators = 0,
    this.reviewers = 0,
    this.suspended = 0,
    this.reportsOpen = 0,
    this.reportsResolved = 0,
    this.qaQuestions = 0,
    this.qaAnswers = 0,
    this.qaInModeration = 0,
    this.blocks = 0,
    this.onlineNowAvailable = false,
    this.salesAvailable = false,
    this.downloadsAvailable = false,
    this.casebooksOnServer = false,
  });

  factory AdminStatsExt.fromJson(Map<String, Object?> j) {
    final roles = _map(j['roles']);
    final reports = _map(j['reports']);
    final qa = _map(j['qa']);
    return AdminStatsExt(
      admins: _int(roles['identity_admin']),
      moderators: _int(roles['publication_moderator']),
      reviewers: _int(roles['scope_grantor']),
      suspended: _int(j['suspended']),
      reportsOpen: _int(reports['open']),
      reportsResolved: _int(reports['resolved']),
      qaQuestions: _int(qa['questions']),
      qaAnswers: _int(qa['answers']),
      qaInModeration: _int(qa['in_moderation']),
      blocks: _int(j['blocks']),
      onlineNowAvailable: _map(j['online_now'])['available'] == true,
      salesAvailable: _map(j['sales'])['available'] == true,
      downloadsAvailable: _map(j['downloads'])['available'] == true,
      casebooksOnServer: _map(j['casebooks'])['stored_server_side'] == true,
    );
  }

  final int admins;
  final int moderators;
  final int reviewers;
  final int suspended;
  final int reportsOpen;
  final int reportsResolved;
  final int qaQuestions;
  final int qaAnswers;
  final int qaInModeration;
  final int blocks;
  final bool onlineNowAvailable;
  final bool salesAvailable;
  final bool downloadsAvailable;
  final bool casebooksOnServer;
}

/// Bloklangan muallif: faqat ichki belgi va sana — kimligi ko‘rsatilmaydi.
@immutable
class BlockedAuthor {
  const BlockedAuthor({required this.id, this.createdAt});

  factory BlockedAuthor.fromJson(Map<String, Object?> j) => BlockedAuthor(
    id: j['id'] as String? ?? '',
    createdAt: _date(j['created_at']),
  );

  final String id;
  final DateTime? createdAt;
}

enum BlockResult {
  blocked,
  already,
  notFound,
  self,
  invalid,
  failed;

  static BlockResult fromWire(Object? v) => switch (v) {
    'BLOCKED' => blocked,
    'ALREADY' => already,
    'NOT_FOUND' => notFound,
    'SELF' => self,
    'INVALID' => invalid,
    _ => failed,
  };

  bool get ok => this == blocked || this == already;
}

/// Hamjamiyat qoidalari matni versiyasi: matn o‘zgarsa — oshiriladi va
/// foydalanuvchidan qayta qabul so‘raladi.
abstract final class CommunityTerms {
  static const doc = 'ugc_rules';
  static const version = '2026-10-17';
}

/// Ko‘rinadigan aloqa va do‘kon konsollari (admin).
abstract final class AdminLinks {
  static final appStoreConnect = Uri.parse(
    'https://appstoreconnect.apple.com/',
  );
  static final playConsole = Uri.parse('https://play.google.com/console/');
}
