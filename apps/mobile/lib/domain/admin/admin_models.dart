/// Server tomonidan berilgan kirish va egasi uchun admin panel ma’lumotlari.
/// Huquq faqat serverdan (`my_access`, `admin_dashboard`) — mijoz bayrog‘i
/// hech qachon Pro yoki admin bermaydi.
library;

import 'package:flutter/foundation.dart';

import '../ports/billing_ports.dart';

@immutable
class ServerAccess {
  const ServerAccess({this.tier, this.isAdmin = false});

  factory ServerAccess.fromJson(Map<String, Object?> j) => ServerAccess(
    tier: switch (j['tier']) {
      'studentPro' => PlanTier.studentPro,
      'professionalPro' => PlanTier.professionalPro,
      _ => null,
    },
    isAdmin: j['is_admin'] == true,
  );

  static const none = ServerAccess();

  /// Bepul yoki xodim kirishi (masalan, egasi). `null` — grant yo‘q.
  final PlanTier? tier;
  final bool isAdmin;
}

/// Store huquqi + server grant: yuqorisi olinadi.
Entitlements mergeServerGrant(Entitlements store, ServerAccess server) {
  final grant = server.tier;
  if (grant == null || store.effectiveTier.index >= grant.index) return store;
  return Entitlements(
    tier: grant,
    status: EntitlementStatus.active,
    source: EntitlementSource.promo,
    verification: EntitlementVerification.serverVerified,
  );
}

@immutable
class AdminUserRow {
  const AdminUserRow({
    required this.email,
    this.createdAt,
    this.lastSignInAt,
    this.confirmed = false,
    this.platforms = const [],
    this.region,
    this.tier,
    this.isAdmin = false,
  });

  factory AdminUserRow.fromJson(Map<String, Object?> j) => AdminUserRow(
    email: j['email'] as String? ?? '—',
    createdAt: DateTime.tryParse(j['created_at'] as String? ?? ''),
    lastSignInAt: DateTime.tryParse(j['last_sign_in_at'] as String? ?? ''),
    confirmed: j['confirmed'] == true,
    platforms: (j['platforms'] as String? ?? '')
        .split(',')
        .where((p) => p.isNotEmpty)
        .toList(),
    region: j['region'] as String?,
    tier: j['tier'] as String?,
    isAdmin: j['is_admin'] == true,
  );

  final String email;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final bool confirmed;
  final List<String> platforms;
  final String? region;
  final String? tier;
  final bool isAdmin;
}

@immutable
class AdminDashboard {
  const AdminDashboard({
    required this.totals,
    this.regions = const [],
    this.daily = const [],
    this.users = const [],
  });

  factory AdminDashboard.fromJson(Map<String, Object?> j) {
    int n(Object? v) => switch (v) {
      final num x => x.toInt(),
      final String s => int.tryParse(s) ?? 0,
      _ => 0,
    };
    List<Map<String, Object?>> list(Object? v) => [
      if (v is List)
        for (final e in v)
          if (e is Map) e.cast<String, Object?>(),
    ];
    final t = (j['totals'] as Map?)?.cast<String, Object?>() ?? const {};
    return AdminDashboard(
      totals: {for (final e in t.entries) e.key: n(e.value)},
      regions: [
        for (final r in list(j['regions']))
          (r['region'] as String? ?? '??', n(r['users'])),
      ],
      daily: [
        for (final d in list(j['daily']))
          (d['day'] as String? ?? '', n(d['signups'])),
      ],
      users: [for (final u in list(j['users'])) AdminUserRow.fromJson(u)],
    );
  }

  final Map<String, int> totals;
  final List<(String, int)> regions;
  final List<(String, int)> daily;
  final List<AdminUserRow> users;

  int total(String key) => totals[key] ?? 0;
}

enum AdminGrantResult { granted, revoked, notFound, invalid, failed }
