import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/remote/http_purchase_verifier.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';

/// Lokal HTTP server bilan kontrakt sinovi (haqiqiy backend emas).
void main() {
  late HttpServer server;
  late List<Map<String, Object?>> requests;
  var reply = (HttpResponse r) => r
    ..statusCode = 200
    ..write(
      '{"status":"verified","entitlement_status":"grace_period",'
      '"expires_at":"2026-11-05T00:00:00Z"}',
    );

  setUp(() async {
    requests = [];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      requests.add(
        (jsonDecode(await utf8.decoder.bind(req).join()) as Map).cast(),
      );
      reply(req.response);
      await req.response.close();
    });
  });
  tearDown(() => server.close(force: true));

  HttpPurchaseVerifier verifier() => HttpPurchaseVerifier(
    endpoint: Uri.parse('http://127.0.0.1:${server.port}/verify'),
    bundleId: 'TEST.bundle',
  );

  const evidence = PurchaseEvidence(
    productId: ProductIds.professionalMonthly,
    platform: EntitlementSource.playStore,
    serverVerificationData: 'TEST-TOKEN',
    purchaseId: 'TEST-ORDER',
  );

  test('kontrakt: so‘rov maydonlari va «verified»', () async {
    final r = await verifier().verify(evidence);
    expect(r.status, VerificationStatus.verified);
    expect(r.entitlementStatus, EntitlementStatus.gracePeriod);
    expect(r.expiresAt, DateTime.utc(2026, 11, 5));
    expect(requests.single, {
      'platform': 'google_play',
      'product_id': 'fe_professional_pro_monthly',
      'purchase_id': 'TEST-ORDER',
      'verification_data': 'TEST-TOKEN',
      'bundle_id': 'TEST.bundle',
    });
  });

  test('«rejected» va 4xx — rad etiladi', () async {
    reply = (r) => r
      ..statusCode = 200
      ..write('{"status":"rejected"}');
    expect(
      (await verifier().verify(evidence)).status,
      VerificationStatus.rejected,
    );
    reply = (r) => r..statusCode = 403;
    expect(
      (await verifier().verify(evidence)).status,
      VerificationStatus.rejected,
    );
  });

  test('5xx va server yo‘q — networkError', () async {
    reply = (r) => r..statusCode = 503;
    expect(
      (await verifier().verify(evidence)).status,
      VerificationStatus.networkError,
    );
    final dead = HttpPurchaseVerifier(
      endpoint: Uri.parse('http://127.0.0.1:1/verify'),
      bundleId: 'TEST.bundle',
    );
    expect(
      (await dead.verify(evidence)).status,
      VerificationStatus.networkError,
    );
  });

  test('buzilgan javob — rad etiladi', () async {
    reply = (r) => r
      ..statusCode = 200
      ..write('not json');
    expect(
      (await verifier().verify(evidence)).status,
      VerificationStatus.rejected,
    );
  });

  test('endpoint berilmagan / https emas — sozlanmagan verifier', () async {
    final v = HttpPurchaseVerifier.fromEnvironment(bundleId: 'x');
    expect(v, isA<UnconfiguredPurchaseVerifier>());
    expect(
      (await v.verify(evidence)).status,
      VerificationStatus.serverNotConfigured,
    );
  });

  test('noma’lum yoki yo‘q holat — kirish bermaydigan «unknown»', () {
    final r = HttpPurchaseVerifier.parse({'status': 'verified'});
    expect(r.entitlementStatus, EntitlementStatus.unknown);
    expect(
      HttpPurchaseVerifier.parse({
        'status': 'verified',
        'entitlement_status': 'billing_retry',
      }).entitlementStatus,
      EntitlementStatus.billingRetry,
    );
    expect(
      HttpPurchaseVerifier.parse(['x']).status,
      VerificationStatus.rejected,
    );
  });

  test('akkaunt tokeni Authorization sarlavhasida; tanada emas', () async {
    String? auth;
    final s2 = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    s2.listen((req) async {
      auth = req.headers.value(HttpHeaders.authorizationHeader);
      final body = await utf8.decoder.bind(req).join();
      expect(body, isNot(contains('TEST-ACCESS')));
      req.response.write('{"status":"rejected"}');
      await req.response.close();
    });
    final v = HttpPurchaseVerifier(
      endpoint: Uri.parse('http://127.0.0.1:${s2.port}/verify'),
      bundleId: 'TEST.bundle',
      accessToken: () async => 'TEST-ACCESS',
    );
    await v.verify(evidence);
    expect(auth, 'Bearer TEST-ACCESS');
    await s2.close(force: true);
  });
}
