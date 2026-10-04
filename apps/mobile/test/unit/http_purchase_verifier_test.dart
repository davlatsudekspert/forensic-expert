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
    ..write('{"status":"verified"}');

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
    productId: ProductIds.lifetime,
    platform: EntitlementSource.playStore,
    serverVerificationData: 'TEST-TOKEN',
    purchaseId: 'TEST-ORDER',
  );

  test('kontrakt: so‘rov maydonlari va «verified»', () async {
    expect(await verifier().verify(evidence), VerificationStatus.verified);
    expect(requests.single, {
      'platform': 'google_play',
      'product_id': 'fe_lifetime_unlock',
      'purchase_id': 'TEST-ORDER',
      'verification_data': 'TEST-TOKEN',
      'bundle_id': 'TEST.bundle',
    });
  });

  test('«rejected» va 4xx — rad etiladi', () async {
    reply = (r) => r
      ..statusCode = 200
      ..write('{"status":"rejected"}');
    expect(await verifier().verify(evidence), VerificationStatus.rejected);
    reply = (r) => r..statusCode = 403;
    expect(await verifier().verify(evidence), VerificationStatus.rejected);
  });

  test('5xx va server yo‘q — networkError', () async {
    reply = (r) => r..statusCode = 503;
    expect(await verifier().verify(evidence), VerificationStatus.networkError);
    final dead = HttpPurchaseVerifier(
      endpoint: Uri.parse('http://127.0.0.1:1/verify'),
      bundleId: 'TEST.bundle',
    );
    expect(await dead.verify(evidence), VerificationStatus.networkError);
  });

  test('buzilgan javob — rad etiladi', () async {
    reply = (r) => r
      ..statusCode = 200
      ..write('not json');
    expect(await verifier().verify(evidence), VerificationStatus.rejected);
  });

  test('endpoint berilmagan / https emas — sozlanmagan verifier', () async {
    final v = HttpPurchaseVerifier.fromEnvironment(bundleId: 'x');
    expect(v, isA<UnconfiguredPurchaseVerifier>());
    expect(await v.verify(evidence), VerificationStatus.serverNotConfigured);
  });
}
