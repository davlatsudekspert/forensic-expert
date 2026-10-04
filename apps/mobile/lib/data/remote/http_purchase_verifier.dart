import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/ports/billing_ports.dart';

/// Backend orqali xaridni tekshirish (klient tomoni).
///
/// Kontrakt (`docs/12_PURCHASE_VERIFICATION.md`):
/// `POST {endpoint}` JSON
/// `{platform, product_id, purchase_id, verification_data, bundle_id}` →
/// `200 {"status": "verified" | "rejected"}`.
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
  }) : _client = client ?? HttpClient();

  final Uri endpoint;
  final String bundleId;
  final Duration timeout;
  final HttpClient _client;

  static PurchaseVerifier fromEnvironment({required String bundleId}) {
    const url = String.fromEnvironment('FE_PURCHASE_VERIFY_URL');
    final uri = Uri.tryParse(url);
    if (url.isEmpty || uri == null || uri.scheme != 'https') {
      return const UnconfiguredPurchaseVerifier();
    }
    return HttpPurchaseVerifier(endpoint: uri, bundleId: bundleId);
  }

  @override
  Future<VerificationStatus> verify(PurchaseEvidence e) async {
    try {
      final req = await _client.postUrl(endpoint).timeout(timeout);
      req.headers.contentType = ContentType.json;
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
            ? VerificationStatus.networkError
            : VerificationStatus.rejected;
      }
      final status = (jsonDecode(body) as Map)['status'];
      return status == 'verified'
          ? VerificationStatus.verified
          : VerificationStatus.rejected;
    } on SocketException {
      return VerificationStatus.networkError;
    } on TimeoutException {
      return VerificationStatus.networkError;
    } on HandshakeException {
      return VerificationStatus.networkError;
    } on FormatException {
      return VerificationStatus.rejected;
    }
  }
}
