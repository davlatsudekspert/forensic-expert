/// Institut kodi / promokod va qurilmalar limiti domen modeli (sof Dart).
/// Qaror serverda: `redeem_promo_code`, `register_device`, `my_devices`.
library;

import 'plan_models.dart';

/// `redeem_promo_code` natijasi.
enum PromoResult {
  ok,
  invalid,
  used,
  alreadyYours,
  expired,
  revoked,
  tooMany,
  notSigned,
  unknown;

  static PromoResult fromWire(Object? v) => switch (v) {
    'OK' => ok,
    'INVALID' => invalid,
    'USED' => used,
    'ALREADY_YOURS' => alreadyYours,
    'EXPIRED' => expired,
    'REVOKED' => revoked,
    'TOO_MANY' => tooMany,
    'NOT_SIGNED' => notSigned,
    _ => unknown,
  };
}

class PromoOutcome {
  const PromoOutcome(
    this.result, {
    this.kind,
    this.label,
    this.until,
    this.plan,
  });

  factory PromoOutcome.fromJson(Map<String, Object?> j) => PromoOutcome(
    PromoResult.fromWire(j['result']),
    kind: j['kind'] as String?,
    label: j['label'] as String?,
    until: DateTime.tryParse('${j['until'] ?? ''}')?.toLocal(),
    plan: Plan.fromWire(j['plan']),
  );

  final PromoResult result;

  /// `institute` | `gift`.
  final String? kind;

  /// «institut: Nomi» yoki «sovg‘a: Kim».
  final String? label;
  final DateTime? until;
  final Plan? plan;
}

/// Foydalanuvchi kiritgan kodni serverga yuboriladigan shaklga keltiradi:
/// katta harf, bo‘shliq/defis/boshqa belgilar tashlanadi (server ham shunday
/// normallashtiradi).
String normalizePromoCode(String raw) =>
    raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

enum PromoKind { institute, gift, other }

/// Server yozuvi («institut: Nomi» / «sovg‘a: Kim») ni ajratadi.
class PromoLabel {
  const PromoLabel(this.kind, this.name);

  final PromoKind kind;
  final String name;

  static final _re = RegExp(
    r'^\s*(institut|tashkilot|sovg[‘’ʻ`'
    "'"
    r']?a)\s*:\s*(.+?)\s*$',
    caseSensitive: false,
  );

  static PromoLabel? parse(String? label) {
    if (label == null || label.trim().isEmpty) return null;
    final m = _re.firstMatch(label);
    if (m == null) return PromoLabel(PromoKind.other, label.trim());
    final head = m.group(1)!.toLowerCase();
    return PromoLabel(
      head == 'institut' || head == 'tashkilot'
          ? PromoKind.institute
          : PromoKind.gift,
      m.group(2)!,
    );
  }
}

/// Akkauntga bog‘langan qurilma (server: `account_devices`).
class DeviceRecord {
  const DeviceRecord({required this.hash, this.label, this.lastSeen});

  static DeviceRecord? tryParse(Object? v) {
    if (v is! Map) return null;
    final hash = v['hash'];
    if (hash is! String || hash.isEmpty) return null;
    final label = v['label'];
    return DeviceRecord(
      hash: hash,
      label: label is String && label.trim().isNotEmpty ? label.trim() : null,
      lastSeen: DateTime.tryParse('${v['last_seen'] ?? ''}')?.toLocal(),
    );
  }

  final String hash;
  final String? label;
  final DateTime? lastSeen;
}

/// `register_device` natijasi: [ok] `false` — limit to‘lgan, [devices] bor.
class DeviceRegistration {
  const DeviceRegistration({
    required this.ok,
    this.limit = 3,
    this.devices = const [],
  });

  factory DeviceRegistration.fromJson(Map<String, Object?> j) {
    final raw = j['devices'];
    return DeviceRegistration(
      ok: j['ok'] != false,
      limit: j['limit'] is num ? (j['limit']! as num).toInt() : 3,
      devices: [
        if (raw is List)
          for (final e in raw) ?DeviceRecord.tryParse(e),
      ],
    );
  }

  final bool ok;
  final int limit;
  final List<DeviceRecord> devices;
}
