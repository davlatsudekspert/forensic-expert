/// «Hamkasbingizni taklif qiling» — referral domeni.
///
/// Xavfsizlik: kod serverda yaratiladi, attribution va mukofotlar faqat
/// serverda (`supabase/migrations/20261006030000_referrals.sql`). Mijoz
/// faqat o‘z kodini va **agregat** sonlarni ko‘radi; taklif qilinganlarning
/// email yoki ismi hech qachon qaytarilmaydi. Mijoz mukofot yoza olmaydi.
library;

import 'package:flutter/foundation.dart';

/// Kod formati: 8 belgi, chalkash 0/O/1/I yo‘q (server bilan bir xil).
abstract final class ReferralCode {
  static final _re = RegExp(r'^[A-HJ-NP-Z2-9]{8}$');

  /// Bo‘shliq/defislarni olib tashlab, katta harfga o‘tkazadi; noto‘g‘ri
  /// bo‘lsa `null`.
  static String? normalize(String? raw) {
    if (raw == null) return null;
    final s = raw.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
    return _re.hasMatch(s) ? s : null;
  }
}

/// Taklif havolalari. Ommaviy domen faqat konfiguratsiyadan
/// (`FE_REFERRAL_BASE_URL`, HTTPS) olinadi — egalik qilinmagan domen
/// kodga yozilmaydi. Domen sozlanmagan bo‘lsa — faqat kod ulashiladi.
@immutable
class ReferralLinks {
  const ReferralLinks({this.publicBase});

  factory ReferralLinks.fromEnvironment() {
    const raw = String.fromEnvironment('FE_REFERRAL_BASE_URL');
    final uri = Uri.tryParse(raw);
    final ok =
        raw.isNotEmpty &&
        uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty;
    return ReferralLinks(publicBase: ok ? uri : null);
  }

  /// Ilova ichidagi sxema (o‘rnatilgan ilova uchun):
  /// `forensicexpert://app/invite/<CODE>`.
  static const appScheme = 'forensicexpert';

  final Uri? publicBase;

  bool get hasPublicLink => publicBase != null;

  /// `https://<base>/invite/<CODE>` yoki `null` (domen sozlanmagan).
  Uri? inviteLink(String code) {
    final base = publicBase;
    if (base == null) return null;
    final path = base.path.endsWith('/') ? base.path : '${base.path}/';
    return base.replace(path: '${path}invite/$code');
  }

  /// Ilmiy yozuvga ommaviy havola (`https://<base>/record/<id>`) yoki `null`.
  /// Faqat ommaviy ma’lumotnoma ID’si — shaxsiy yoki ish ma’lumoti yo‘q.
  Uri? recordLink(String id) {
    final base = publicBase;
    if (base == null) return null;
    final path = base.path.endsWith('/') ? base.path : '${base.path}/';
    return base.replace(path: '${path}record/${Uri.encodeComponent(id)}');
  }

  /// Ilova ichidagi yo‘l: `/invite/<CODE>` (deep link → router).
  static String routeFor(String code) => '/invite/$code';

  /// Har qanday kiruvchi havoladan kodni ajratadi:
  /// `https://<base>/invite/CODE`, `forensicexpert://app/invite/CODE`,
  /// `/invite/CODE` yoki `?ref=CODE`.
  static String? extractCode(Uri uri) {
    final segs = uri.pathSegments;
    final i = segs.indexOf('invite');
    if (i >= 0 && i + 1 < segs.length) {
      return ReferralCode.normalize(segs[i + 1]);
    }
    return ReferralCode.normalize(uri.queryParameters['ref']);
  }
}

/// Foydalanuvchining o‘z referral paneli (faqat agregatlar).
@immutable
class ReferralDashboard {
  const ReferralDashboard({
    required this.code,
    this.joined = 0,
    this.verified = 0,
    this.pending = 0,
    this.creditsEarnedMinor = 0,
    this.creditsPendingMinor = 0,
    this.currency = 'USD',
    this.rewardPercent = 10,
    this.rewardsEnabled = false,
    this.hasReferrer = false,
  });

  factory ReferralDashboard.fromJson(Map<String, Object?> j) {
    int i(String k) => switch (j[k]) {
      final num n => n.toInt(),
      final String s => int.tryParse(s) ?? 0,
      _ => 0,
    };
    final code = ReferralCode.normalize(j['code'] as String?);
    if (code == null) throw const FormatException('referral code');
    return ReferralDashboard(
      code: code,
      joined: i('joined'),
      verified: i('verified'),
      pending: i('pending'),
      creditsEarnedMinor: i('credits_earned_minor'),
      creditsPendingMinor: i('credits_pending_minor'),
      currency: j['currency'] is String ? j['currency']! as String : 'USD',
      rewardPercent: switch (j['reward_percent']) {
        final num n => n.toDouble(),
        final String s => double.tryParse(s) ?? 10,
        _ => 10,
      },
      rewardsEnabled: j['rewards_enabled'] == true,
      hasReferrer: j['has_referrer'] == true,
    );
  }

  final String code;

  /// Kod bilan akkaunt ochganlar (tasdiqlangan + kutilayotgan).
  final int joined;

  /// Email tasdiqlangan — muvaffaqiyatli taklif.
  final int verified;

  /// Email hali tasdiqlanmagan.
  final int pending;

  /// FORENSIC Credits (minor birlik, masalan sent ekvivalenti). Pul emas.
  final int creditsEarnedMinor;
  final int creditsPendingMinor;
  final String currency;

  /// Server sozlamasi (standart 10 %).
  final double rewardPercent;

  /// Pullik xizmatlar ishga tushganda yoqiladi.
  final bool rewardsEnabled;

  /// Bu akkaunt o‘zi taklif orqali kelganmi (kod kiritish maydonini yashirish).
  final bool hasReferrer;
}

enum ReferralClaimOutcome {
  valid,
  pendingVerification,
  invalidCode,
  selfReferral,
  alreadyAttributed,
  notEligible,
  rateLimited,
  notSignedIn,
  offline,
  notConfigured,
  server;

  static ReferralClaimOutcome fromServer(Object? s) => switch (s) {
    'VALID' => valid,
    'PENDING_VERIFICATION' => pendingVerification,
    'INVALID_CODE' => invalidCode,
    'SELF_REFERRAL' => selfReferral,
    'ALREADY_ATTRIBUTED' => alreadyAttributed,
    'NOT_ELIGIBLE' => notEligible,
    'RATE_LIMITED' => rateLimited,
    _ => server,
  };

  bool get accepted => this == valid || this == pendingVerification;

  /// Qayta urinish ma’nosiz (kodni lokal saqlashni to‘xtatish).
  bool get terminal =>
      accepted ||
      this == invalidCode ||
      this == selfReferral ||
      this == alreadyAttributed ||
      this == notEligible;
}

enum ReferralFailure { notSignedIn, offline, notConfigured, server }

@immutable
class ReferralResult {
  const ReferralResult.ok(ReferralDashboard this.dashboard) : failure = null;
  const ReferralResult.fail(ReferralFailure this.failure) : dashboard = null;

  final ReferralDashboard? dashboard;
  final ReferralFailure? failure;
}

/// FORENSIC Credits ko‘rinishi: minor birlikdan (sent) — `12.50`.
String formatCredits(int minor) {
  final whole = minor ~/ 100;
  final frac = (minor % 100).toString().padLeft(2, '0');
  return '$whole.$frac';
}
