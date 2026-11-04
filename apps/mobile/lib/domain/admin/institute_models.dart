/// Tashkilot (ustozlar uchun ommaviy promokodlar) va sovg‘a promokodlari —
/// admin tomoni domen modeli (sof Dart). Qaror serverda
/// (`admin_institute_*`, `admin_gift_codes_create`, `admin_revoke_code`).
library;

/// «Yangi tashkilot» formasi qiymatlari.
class InstituteDraft {
  const InstituteDraft({
    required this.name,
    this.seats = 0,
    this.months = 0,
    this.termStart,
  });

  final String name;
  final int seats;
  final int months;
  final DateTime? termStart;

  /// Server chegaralari: nom ≥ 2 belgi, 1–500 o‘rin, 1–60 oy.
  bool get isValid =>
      name.trim().length >= 2 &&
      seats >= 1 &&
      seats <= 500 &&
      months >= 1 &&
      months <= 60;
}

/// `admin_list_institutes` qatori.
class InstituteSummary {
  const InstituteSummary({
    required this.id,
    required this.name,
    required this.seats,
    required this.redeemed,
    required this.revoked,
    this.termStart,
    this.termEnd,
  });

  static InstituteSummary? tryParse(Object? v) {
    if (v is! Map) return null;
    final id = v['id'];
    if (id is! String || id.isEmpty) return null;
    return InstituteSummary(
      id: id,
      name: '${v['name'] ?? ''}',
      seats: _int(v['seats']),
      redeemed: _int(v['redeemed']),
      revoked: _int(v['revoked']),
      termStart: DateTime.tryParse('${v['term_start'] ?? ''}')?.toLocal(),
      termEnd: DateTime.tryParse('${v['term_end'] ?? ''}')?.toLocal(),
    );
  }

  final String id;
  final String name;
  final int seats;
  final int redeemed;
  final int revoked;
  final DateTime? termStart;
  final DateTime? termEnd;
}

/// `admin_institute_get` — tashkilot ma’lumoti (nom, o‘rin, muddat).
class InstituteDetail {
  const InstituteDetail({
    required this.id,
    required this.name,
    this.seats = 0,
    this.months = 0,
    this.termStart,
    this.termEnd,
  });

  static InstituteDetail? tryParse(Object? v) {
    if (v is! Map) return null;
    final id = v['id'];
    if (id is! String || id.isEmpty) return null;
    return InstituteDetail(
      id: id,
      name: v['name'] is String ? (v['name']! as String).trim() : '',
      seats: _int(v['seats']),
      months: _int(v['months']),
      termStart: DateTime.tryParse('${v['term_start'] ?? ''}')?.toLocal(),
      termEnd: DateTime.tryParse('${v['term_end'] ?? ''}')?.toLocal(),
    );
  }

  final String id;
  final String name;
  final int seats;
  final int months;
  final DateTime? termStart;
  final DateTime? termEnd;
}

enum InstituteCodeStatus { free, redeemed, revoked }

/// `admin_institute_codes` qatori. Kodlar faqat adminga ochiq ko‘rinadi.
class InstituteCode {
  const InstituteCode({
    required this.n,
    required this.code,
    required this.revoked,
    this.redeemedAt,
    this.email,
  });

  static InstituteCode? tryParse(Object? v) {
    if (v is! Map) return null;
    final code = v['code'];
    if (code is! String || code.isEmpty) return null;
    return InstituteCode(
      n: _int(v['n']),
      code: code,
      revoked: v['revoked'] == true,
      redeemedAt: DateTime.tryParse('${v['redeemed_at'] ?? ''}')?.toLocal(),
      email: v['email'] as String?,
    );
  }

  final int n;
  final String code;
  final bool revoked;
  final DateTime? redeemedAt;
  final String? email;

  InstituteCodeStatus get status => redeemedAt != null
      ? InstituteCodeStatus.redeemed
      : revoked
      ? InstituteCodeStatus.revoked
      : InstituteCodeStatus.free;
}

/// `admin_institute_create` / `admin_gift_codes_create` muvaffaqiyatli javobi.
class IssuedCodes {
  const IssuedCodes({required this.codes, this.instituteId});

  final String? instituteId;
  final List<String> codes;
}

int _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
