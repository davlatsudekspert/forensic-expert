import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/ports/billing_ports.dart';

/// Backend orqali xaridni tekshirish (klient tomoni).
///
/// Kontrakt (`docs/12_PURCHASE_VERIFICATION.md`):
/// `POST {endpoint}` JSON (+ `Authorization: Bearer <akkaunt tokeni>`, agar
/// foydalanuvchi tizimga kirgan bo‘lsa)
/// `{platform, product_id, purchase_id, verification_data, bundle_id}` →
/// `200 {"status": "verified" | "rejected", "entitlement_status":
/// "active" | "grace_period" | "billing_retry" |
/// "cancelled_active_until_expiry" | "expired" | "revoked",
/// "expires_at": ISO-8601 | null}`.
///
/// Backend App Store Server API (iOS) yoki Google Play Developer API
/// `purchases.products.get` (Android) orqali tekshiradi; maxfiy kalitlar
/// faqat serverda. Endpoint `--dart-define=FE_PURCHASE_VERIFY_URL=...`;
/// bo‘lmasa [UnconfiguredPurchaseVerifier] ishlatiladi.
///
/// Javobga ishonch: hozir TLS + server javobi. Kelajakda javob server
/// kaliti bilan imzolanadi (replay himoyasi) — RG-18 doirasida.
class HttpPurchaseVerifier implements PurchaseVerifier {
  HttpPurchaseVerifier({
    required this.endpoint,
    required this.bundleId,
    HttpClient? client,
    this.timeout = const Duration(seconds: 10),
    this.accessToken,
  }) : _client = client ?? HttpClient();

  /// Joriy akkaunt tokeni (bo‘lmasa so‘rov anonim; server huquqni akkauntga
  /// bog‘lay olmaydi va faqat holatni qaytaradi).
  final Future<String?> Function()? accessToken;

  final Uri endpoint;
  final String bundleId;
  final Duration timeout;
  final HttpClient _client;

  static PurchaseVerifier fromEnvironment({
    required String bundleId,
    Future<String?> Function()? accessToken,
  }) {
    const url = String.fromEnvironment('FE_PURCHASE_VERIFY_URL');
    final uri = Uri.tryParse(url);
    if (url.isEmpty || uri == null || uri.scheme != 'https') {
      return const UnconfiguredPurchaseVerifier();
    }
    return HttpPurchaseVerifier(
      endpoint: uri,
      bundleId: bundleId,
      accessToken: accessToken,
    );
  }

  @override
  Future<PurchaseVerification> verify(PurchaseEvidence e) async {
    try {
      final req = await _client.postUrl(endpoint).timeout(timeout);
      req.headers.contentType = ContentType.json;
      final token = await accessToken?.call();
      if (token != null && token.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      req.write(
        jsonEncode({
          'platform': switch (e.platform) {
            EntitlementSource.appStore => 'app_store',
            EntitlementSource.playStore => 'google_play',
            _ => e.platform.name,
          },
          'product_id': e.productId,
          'purchase_id': e.purchaseId,
          'verification_data': e.serverVerificationData,
          'bundle_id': bundleId,
        }),
      );
      final res = await req.close().timeout(timeout);
      final body = await res.transform(utf8.decoder).join().timeout(timeout);
      if (res.statusCode != 200) {
        // 4xx — rad etilgan so‘rov; 5xx — server muammosi (tarmoq kabi).
        return res.statusCode >= 500
            ? PurchaseVerification.networkError
            : PurchaseVerification.rejected;
      }
      return parse(jsonDecode(body));
    } on SocketException {
      return PurchaseVerification.networkError;
    } on TimeoutException {
      return PurchaseVerification.networkError;
    } on HandshakeException {
      return PurchaseVerification.networkError;
    } on FormatException {
      return PurchaseVerification.rejected;
    }
  }

  /// Server javobini qat’iy o‘qish: noma’lum maydon / holat — huquq yo‘q.
  static PurchaseVerification parse(Object? json) {
    if (json is! Map || json['status'] != 'verified') {
      return PurchaseVerification.rejected;
    }
    final status = switch (json['entitlement_status']) {
      'active' => EntitlementStatus.active,
      'grace_period' => EntitlementStatus.gracePeriod,
      'billing_retry' => EntitlementStatus.billingRetry,
      'cancelled_active_until_expiry' =>
        EntitlementStatus.cancelledActiveUntilExpiry,
      'expired' => EntitlementStatus.expired,
      'revoked' => EntitlementStatus.revoked,
      _ => EntitlementStatus.unknown,
    };
    final exp = json['expires_at'];
    return PurchaseVerification(
      VerificationStatus.verified,
      entitlementStatus: status,
      expiresAt: exp is String ? DateTime.tryParse(exp)?.toUtc() : null,
    );
  }
}
