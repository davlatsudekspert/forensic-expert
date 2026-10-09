/// «Taklif va murojaatlar» va admin panel modellari. Huquq va cheklovlar
/// (muallif, admin roli, uzunlik, tezlik) faqat serverda tekshiriladi —
/// bu yerdagi qiymatlar faqat UI uchun.
library;

import 'package:flutter/foundation.dart';

/// Server bilan bir xil cheklovlar (UI tekshiruvi; server baribir tekshiradi).
abstract final class SupportLimits {
  static const subject = 200;
  static const body = 4000;
  static const attachmentBytes = 5 * 1024 * 1024;
}

enum SupportCategory {
  suggestion('SUGGESTION'),
  bug('BUG'),
  scientificError('SCIENTIFIC_ERROR'),
  featureRequest('FEATURE_REQUEST'),
  techSupport('TECH_SUPPORT'),
  general('GENERAL');

  const SupportCategory(this.wire);
  final String wire;

  static SupportCategory fromWire(Object? v) => values.firstWhere(
    (c) => c.wire == v,
    orElse: () => SupportCategory.general,
  );
}

enum SupportStatus {
  newRequest('NEW'),
  inReview('IN_REVIEW'),
  answered('ANSWERED'),
  closed('CLOSED');

  const SupportStatus(this.wire);
  final String wire;

  static SupportStatus fromWire(Object? v) => values.firstWhere(
    (s) => s.wire == v,
    orElse: () => SupportStatus.newRequest,
  );

  bool get awaiting => this == newRequest || this == inReview;
}

int _int(Object? v) => switch (v) {
  final num x => x.toInt(),
  final String s => int.tryParse(s) ?? 0,
  _ => 0,
};

int? _intOrNull(Object? v) => v == null ? null : _int(v);

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

List<Map<String, Object?>> _maps(Object? v) => [
  if (v is List)
    for (final e in v)
      if (e is Map) e.cast<String, Object?>(),
];

Map<String, Object?> _map(Object? v) =>
    v is Map ? v.cast<String, Object?>() : const {};

@immutable
class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.fromAdmin,
    required this.body,
    this.attachmentPath,
    this.createdAt,
    this.mine = false,
  });

  factory SupportMessage.fromJson(Map<String, Object?> j) => SupportMessage(
    id: _int(j['id']),
    fromAdmin: j['sender_role'] == 'ADMIN',
    body: j['body'] as String? ?? '',
    attachmentPath: j['attachment_path'] as String?,
    createdAt: _date(j['created_at']),
    mine: j['mine'] == true,
  );

  final int id;
  final bool fromAdmin;
  final String body;
  final String? attachmentPath;
  final DateTime? createdAt;

  /// Joriy foydalanuvchi yozganmi (admin ko‘rinishida — o‘z javobi).
  final bool mine;
}

@immutable
class SupportThread {
  const SupportThread({
    required this.id,
    required this.category,
    required this.subject,
    required this.status,
    this.relatedEntity,
    this.createdAt,
    this.updatedAt,
    this.lastAdminReplyAt,
    this.messageCount = 0,
    this.unread = 0,
    this.lastMessage,
    this.authorEmail,
    this.hasAttachment = false,
    this.messages = const [],
  });

  factory SupportThread.fromJson(Map<String, Object?> j) {
    final messages = [
      for (final m in _maps(j['messages'])) SupportMessage.fromJson(m),
    ];
    return SupportThread(
      id: j['id'] as String? ?? '',
      category: SupportCategory.fromWire(j['category']),
      subject: j['subject'] as String? ?? '',
      status: SupportStatus.fromWire(j['status']),
      relatedEntity: j['related_entity'] as String?,
      createdAt: _date(j['created_at']),
      updatedAt: _date(j['updated_at']),
      lastAdminReplyAt: _date(j['last_admin_reply_at']),
      messageCount: j.containsKey('message_count')
          ? _int(j['message_count'])
          : messages.length,
      unread: _int(j['unread']),
      lastMessage: j['last_message'] as String?,
      authorEmail: j['author_email'] as String?,
      hasAttachment:
          j['has_attachment'] == true ||
          messages.any((m) => m.attachmentPath != null),
      messages: messages,
    );
  }

  final String id;
  final SupportCategory category;
  final String subject;
  final SupportStatus status;
  final String? relatedEntity;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastAdminReplyAt;
  final int messageCount;

  /// Muallif uchun: o‘qilmagan admin javoblari; admin uchun: o‘qilmagan
  /// foydalanuvchi xabarlari.
  final int unread;
  final String? lastMessage;

  /// Faqat admin ko‘rinishida (server faqat adminga beradi).
  final String? authorEmail;
  final bool hasAttachment;
  final List<SupportMessage> messages;
}

/// Biriktirilgan rasm (yuborishdan oldin; faqat JPEG/PNG).
@immutable
class SupportAttachment {
  const SupportAttachment({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;

  String get extension => mimeType == 'image/png' ? 'png' : 'jpg';
}

@immutable
class SupportDraft {
  const SupportDraft({
    required this.category,
    required this.subject,
    required this.body,
    required this.consent,
    this.relatedEntity,
    this.attachment,
  });

  final SupportCategory category;
  final String subject;
  final String body;
  final bool consent;
  final String? relatedEntity;
  final SupportAttachment? attachment;
}

enum SupportCreateOutcome {
  created,
  consentRequired,
  invalid,
  rateLimited,
  failed,
}

@immutable
class SupportCreateResult {
  const SupportCreateResult(this.outcome, [this.id]);

  factory SupportCreateResult.fromJson(Map<String, Object?> j) =>
      switch (j['result']) {
        'CREATED' when j['id'] is String => SupportCreateResult(
          SupportCreateOutcome.created,
          j['id']! as String,
        ),
        'CONSENT_REQUIRED' => const SupportCreateResult(
          SupportCreateOutcome.consentRequired,
        ),
        'INVALID' => const SupportCreateResult(SupportCreateOutcome.invalid),
        'RATE_LIMITED' => const SupportCreateResult(
          SupportCreateOutcome.rateLimited,
        ),
        _ => failed,
      };

  static const failed = SupportCreateResult(SupportCreateOutcome.failed);

  final SupportCreateOutcome outcome;
  final String? id;
}

enum SupportSendResult {
  sent,
  notFound,
  closed,
  invalid,
  rateLimited,
  failed;

  static SupportSendResult fromWire(Object? v) => switch (v) {
    'SENT' => sent,
    'NOT_FOUND' => notFound,
    'CLOSED' => closed,
    'INVALID' => invalid,
    'RATE_LIMITED' => rateLimited,
    _ => failed,
  };
}

/// Sahifalangan ro‘yxat (admin inbox / foydalanuvchilar).
@immutable
class AdminPage<T> {
  const AdminPage({required this.total, required this.items});

  final int total;
  final List<T> items;
}

/// `admin_stats()` — faqat agregat sonlar (matn yoki email yo‘q).
@immutable
class AdminStats {
  const AdminStats({
    this.usersTotal = 0,
    this.newToday = 0,
    this.new7d = 0,
    this.new30d = 0,
    this.students,
    this.experts,
    this.professionalProfiles = 0,
    this.verifiedProfessionals = 0,
    this.pro = 0,
    this.free = 0,
    this.active7d = 0,
    this.active30d = 0,
    this.supportAwaiting = 0,
    this.supportByStatus = const {},
    this.supportByCategory = const {},
    this.publicationsAwaiting = 0,
    this.publicationReports = 0,
    this.aiTotal = 0,
    this.ai7d = 0,
    this.daily = const [],
  });

  factory AdminStats.fromJson(Map<String, Object?> j) {
    final users = _map(j['users']);
    final modes = _map(j['modes']);
    final tiers = _map(j['tiers']);
    final active = _map(j['active']);
    final support = _map(j['support']);
    final pubs = _map(j['publications']);
    final ai = _map(j['ai']);
    return AdminStats(
      usersTotal: _int(users['total']),
      newToday: _int(users['new_today']),
      new7d: _int(users['new_7d']),
      new30d: _int(users['new_30d']),
      students: _intOrNull(modes['students']),
      experts: _intOrNull(modes['experts']),
      professionalProfiles: _int(modes['professional_profiles']),
      verifiedProfessionals: _int(modes['verified_professionals']),
      pro: _int(tiers['pro']),
      free: _int(tiers['free']),
      active7d: _int(active['d7']),
      active30d: _int(active['d30']),
      supportAwaiting: _int(support['awaiting']),
      supportByStatus: {
        for (final s in SupportStatus.values)
          s: _int(
            support[switch (s) {
              SupportStatus.newRequest => 'new',
              SupportStatus.inReview => 'in_review',
              SupportStatus.answered => 'answered',
              SupportStatus.closed => 'closed',
            }],
          ),
      },
      supportByCategory: {
        for (final e in _map(support['by_category']).entries)
          SupportCategory.fromWire(e.key): _int(e.value),
      },
      publicationsAwaiting: _int(pubs['awaiting_moderation']),
      publicationReports: _int(pubs['open_reports']),
      aiTotal: _int(ai['total']),
      ai7d: _int(ai['d7']),
      daily: [
        for (final d in _maps(j['daily']))
          (
            day: d['day'] as String? ?? '',
            signups: _int(d['signups']),
            ai: _int(d['ai']),
          ),
      ],
    );
  }

  final int usersTotal;
  final int newToday;
  final int new7d;
  final int new30d;

  /// Foydalanuvchi rejimi serverda saqlanmaydi — `null` (to‘qib chiqarilmaydi).
  final int? students;
  final int? experts;
  final int professionalProfiles;
  final int verifiedProfessionals;
  final int pro;
  final int free;
  final int active7d;
  final int active30d;
  final int supportAwaiting;
  final Map<SupportStatus, int> supportByStatus;
  final Map<SupportCategory, int> supportByCategory;
  final int publicationsAwaiting;
  final int publicationReports;
  final int aiTotal;
  final int ai7d;
  final List<({String day, int signups, int ai})> daily;
}

enum AdminAccountStatus { active, unconfirmed, banned }

@immutable
class AdminUserSummary {
  const AdminUserSummary({
    required this.id,
    required this.email,
    this.displayName,
    this.createdAt,
    this.lastActivity,
    this.specialty,
    this.locale,
    this.platforms = const [],
    this.verification,
    this.tier,
    this.roles = const [],
    this.status = AdminAccountStatus.active,
  });

  factory AdminUserSummary.fromJson(Map<String, Object?> j) => AdminUserSummary(
    id: j['id'] as String? ?? '',
    email: j['email'] as String? ?? '—',
    displayName: j['display_name'] as String?,
    createdAt: _date(j['created_at']),
    lastActivity: _date(j['last_activity']),
    specialty: j['specialty'] as String?,
    locale: j['locale'] as String?,
    platforms: (j['platforms'] as String? ?? '')
        .split(',')
        .where((p) => p.isNotEmpty)
        .toList(),
    verification: j['verification'] as String?,
    tier: j['tier'] as String?,
    roles: [
      for (final r in (j['roles'] as List?) ?? const [])
        if (r is String) r,
    ],
    status: switch (j['status']) {
      'BANNED' => AdminAccountStatus.banned,
      'UNCONFIRMED' => AdminAccountStatus.unconfirmed,
      _ => AdminAccountStatus.active,
    },
  );

  final String id;
  final String email;
  final String? displayName;
  final DateTime? createdAt;
  final DateTime? lastActivity;
  final String? specialty;
  final String? locale;
  final List<String> platforms;
  final String? verification;
  final String? tier;
  final List<String> roles;
  final AdminAccountStatus status;

  bool get isAdmin => roles.contains('identity_admin');
}

@immutable
class AdminAuditEntry {
  const AdminAuditEntry({
    required this.id,
    required this.action,
    this.actorEmail,
    this.targetType,
    this.targetId,
    this.detail = const {},
    this.createdAt,
  });

  factory AdminAuditEntry.fromJson(Map<String, Object?> j) => AdminAuditEntry(
    id: _int(j['id']),
    action: j['action'] as String? ?? '',
    actorEmail: j['actor_email'] as String?,
    targetType: j['target_type'] as String?,
    targetId: j['target_id'] as String?,
    detail: _map(j['detail']),
    createdAt: _date(j['created_at']),
  );

  final int id;
  final String action;
  final String? actorEmail;
  final String? targetType;
  final String? targetId;
  final Map<String, Object?> detail;
  final DateTime? createdAt;
}

/// Inbox saralashi.
@immutable
class SupportInboxFilter {
  const SupportInboxFilter({this.status, this.category, this.query = ''});

  /// `null` — hammasi; `'AWAITING'` — NEW + IN_REVIEW; aks holda status wire.
  final String? status;
  final SupportCategory? category;
  final String query;

  @override
  bool operator ==(Object other) =>
      other is SupportInboxFilter &&
      other.status == status &&
      other.category == category &&
      other.query == query;

  @override
  int get hashCode => Object.hash(status, category, query);
}

/// Foydalanuvchilar saralashi.
@immutable
class AdminUserFilter {
  const AdminUserFilter({
    this.search = '',
    this.role,
    this.tier,
    this.offset = 0,
  });

  final String search;

  /// `admin` | `moderator` | `null`.
  final String? role;

  /// `free` | `pro` | `null`.
  final String? tier;
  final int offset;

  static const pageSize = 25;

  AdminUserFilter copyWith({
    String? search,
    String? Function()? role,
    String? Function()? tier,
    int? offset,
  }) => AdminUserFilter(
    search: search ?? this.search,
    role: role == null ? this.role : role(),
    tier: tier == null ? this.tier : tier(),
    offset: offset ?? this.offset,
  );

  @override
  bool operator ==(Object other) =>
      other is AdminUserFilter &&
      other.search == search &&
      other.role == role &&
      other.tier == tier &&
      other.offset == offset;

  @override
  int get hashCode => Object.hash(search, role, tier, offset);
}

/// Kontent yozuvi identifikatorini server qoidasiga moslaydi
/// (`^[A-Za-z0-9_.:/-]{1,160}$`).
String sanitizeRelatedEntity(String raw) {
  final s = raw.replaceAll(RegExp(r'[^A-Za-z0-9_.:/-]'), '_');
  return s.length > 160 ? s.substring(0, 160) : s;
}
