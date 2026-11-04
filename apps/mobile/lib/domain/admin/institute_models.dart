/// Institut (ustozlar uchun ommaviy litsenziya) va sovg‘a promokodlari —
/// admin tomoni domen modeli (sof Dart). Qaror serverda
/// (`admin_institute_*`, `admin_gift_codes_create`, `admin_revoke_code`).
library;

/// Raqamni minglik bo‘shliq bilan yozadi: `12000000` → `12 000 000`.
/// Butun bo‘lmasa, ikki xonali kasr bilan.
String formatSom(num v) {
  final neg = v < 0;
  final abs = v.abs();
  final whole = abs.truncate();
  final frac = abs - whole;
  final digits = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  var out = buf.toString();
  if (frac > 0.0049) {
    out += ',${(frac * 100).round().toString().padLeft(2, '0')}';
  }
  return neg ? '-$out' : out;
}

/// Litsenziar rekvizitlari — kodga/gitga yozilmaydi: admin qurilmasida bir
/// marta kiritiladi (mahalliy saqlash) va faqat PDF’ga qo‘yiladi.
class LicensorProfile {
  const LicensorProfile({
    this.address = '',
    this.phone = '',
    this.bank = '',
    this.mfo = '',
    this.account = '',
    this.transitAccount = '',
  });

  static const empty = LicensorProfile();

  factory LicensorProfile.fromJson(Map<String, Object?> j) {
    String s(String k) => j[k] is String ? (j[k]! as String).trim() : '';
    return LicensorProfile(
      address: s('address'),
      phone: s('phone'),
      bank: s('bank'),
      mfo: s('mfo'),
      account: s('account'),
      transitAccount: s('transit'),
    );
  }

  final String address;
  final String phone;
  final String bank;
  final String mfo;
  final String account;
  final String transitAccount;

  bool get isEmpty =>
      address.isEmpty &&
      phone.isEmpty &&
      bank.isEmpty &&
      mfo.isEmpty &&
      account.isEmpty &&
      transitAccount.isEmpty;

  Map<String, Object?> toJson() => {
    'address': address,
    'phone': phone,
    'bank': bank,
    'mfo': mfo,
    'account': account,
    'transit': transitAccount,
  };
}

/// «Yangi institut» formasi qiymatlari.
class InstituteDraft {
  const InstituteDraft({
    required this.name,
    this.address = '',
    this.stir = '',
    this.bank = '',
    this.account = '',
    this.mfo = '',
    this.director = '',
    this.phone = '',
    this.contractNo = '',
    this.contractDate,
    this.seats = 0,
    this.months = 0,
    this.pricePerSeat = 0,
    this.termStart,
  });

  final String name;
  final String address;
  final String stir;
  final String bank;
  final String account;
  final String mfo;
  final String director;
  final String phone;
  final String contractNo;
  final DateTime? contractDate;
  final int seats;
  final int months;

  /// Bitta o‘rin narxi, so‘m/oy.
  final num pricePerSeat;
  final DateTime? termStart;

  /// Jami = o‘rinlar × oylar × narx.
  num get total => instituteTotal(seats, months, pricePerSeat);

  /// Server chegaralari: nom ≥ 2 belgi, 1–500 o‘rin, 1–60 oy.
  bool get isValid =>
      name.trim().length >= 2 &&
      seats >= 1 &&
      seats <= 500 &&
      months >= 1 &&
      months <= 60 &&
      pricePerSeat >= 0;
}

num instituteTotal(int seats, int months, num pricePerSeat) =>
    seats * months * pricePerSeat;

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
    this.contractNo,
    this.pricePerSeat,
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
      contractNo: v['contract_no'] as String?,
      pricePerSeat: v['price_per_seat'] is num
          ? v['price_per_seat']! as num
          : num.tryParse('${v['price_per_seat'] ?? ''}'),
    );
  }

  final String id;
  final String name;
  final int seats;
  final int redeemed;
  final int revoked;
  final DateTime? termStart;
  final DateTime? termEnd;
  final String? contractNo;
  final num? pricePerSeat;
}

/// `admin_institute_get` — to‘liq institut (shartnoma PDF uchun).
class InstituteDetail {
  const InstituteDetail({
    required this.id,
    required this.name,
    this.address = '',
    this.stir = '',
    this.bank = '',
    this.account = '',
    this.mfo = '',
    this.director = '',
    this.phone = '',
    this.contractNo = '',
    this.contractDate,
    this.seats = 0,
    this.months = 0,
    this.pricePerSeat = 0,
    this.termStart,
    this.termEnd,
  });

  static InstituteDetail? tryParse(Object? v) {
    if (v is! Map) return null;
    String s(String k) => v[k] is String ? (v[k]! as String).trim() : '';
    final id = v['id'];
    if (id is! String || id.isEmpty) return null;
    return InstituteDetail(
      id: id,
      name: s('name'),
      address: s('address'),
      stir: s('stir'),
      bank: s('bank'),
      account: s('account'),
      mfo: s('mfo'),
      director: s('director'),
      phone: s('phone'),
      contractNo: s('contract_no'),
      contractDate: DateTime.tryParse('${v['contract_date'] ?? ''}'),
      seats: _int(v['seats']),
      months: _int(v['months']),
      pricePerSeat: v['price_per_seat'] is num
          ? v['price_per_seat']! as num
          : num.tryParse('${v['price_per_seat'] ?? ''}') ?? 0,
      termStart: DateTime.tryParse('${v['term_start'] ?? ''}')?.toLocal(),
      termEnd: DateTime.tryParse('${v['term_end'] ?? ''}')?.toLocal(),
    );
  }

  final String id;
  final String name;
  final String address;
  final String stir;
  final String bank;
  final String account;
  final String mfo;
  final String director;
  final String phone;
  final String contractNo;
  final DateTime? contractDate;
  final int seats;
  final int months;
  final num pricePerSeat;
  final DateTime? termStart;
  final DateTime? termEnd;

  num get total => instituteTotal(seats, months, pricePerSeat);
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
