import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/billing/store_client.dart';
import 'package:forensic_expert/data/billing/store_entitlement_service.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';

/// TEST: store simulyatori (narx va token — ma’nosiz TEST qiymat).
class FakeStoreClient implements StoreClient {
  FakeStoreClient({this.available = true, this.owned = const []});

  bool available;

  /// Store’ning o‘zida shu akkaunt egalik qiladigan xaridlar.
  List<StoreEvent> owned;
  final controller = StreamController<List<StoreEvent>>.broadcast();
  final bought = <String>[];
  final completed = <String>[];
  int restores = 0;
  List<StoreEvent> Function(String productId)? onBuy;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<Map<String, String>> localizedPrices(Set<String> ids) async => {
    for (final id in ids) id: 'TEST-PRICE 1.00',
  };

  @override
  Future<bool> buyNonConsumable(String productId) async {
    bought.add(productId);
    final events = onBuy?.call(productId);
    if (events != null) scheduleMicrotask(() => controller.add(events));
    return true;
  }

  @override
  Future<void> restore() async => restores++;

  @override
  Future<List<StoreEvent>> ownedPurchases() async => owned;

  @override
  Stream<List<StoreEvent>> get events => controller.stream;

  @override
  Future<void> complete(StoreEvent event) async =>
      completed.add(event.productId);
}

class _Verifier implements PurchaseVerifier {
  _Verifier(this.result);

  final VerificationStatus result;
  final seen = <PurchaseEvidence>[];

  @override
  Future<VerificationStatus> verify(PurchaseEvidence e) async {
    seen.add(e);
    return result;
  }
}

StoreEvent ev(
  StoreEventStatus s, {
  bool complete = true,
  String? token = 'TEST-TOKEN',
}) => StoreEvent(
  productId: ProductIds.lifetime,
  status: s,
  pendingCompletion: complete,
  purchaseId: 'TEST-ORDER-1',
  serverVerificationData: token,
);

void main() {
  StoreEntitlementService service(
    FakeStoreClient c, {
    PurchaseVerifier verifier = const UnconfiguredPurchaseVerifier(),
    bool requireServer = false,
  }) => StoreEntitlementService(
    client: c,
    platformSource: EntitlementSource.playStore,
    verifier: verifier,
    requireServerVerification: requireServer,
    restoreTimeout: const Duration(milliseconds: 100),
  );

  group('lokal holat premium ochmaydi', () {
    test('yangi sessiya: store tasdig‘isiz — bepul', () async {
      final s = service(FakeStoreClient());
      await s.refreshOwnership();
      expect(s.current.hasFullAccess, isFalse);
    });

    test('ilova/APK boshqa qurilmaga ko‘chirildi: store’da xarid yo‘q — '
        'bepul', () async {
      // Avvalgi qurilmada xarid bo‘lgan, lekin yangi qurilmaning store
      // akkauntida bu xarid yo‘q.
      final s = service(FakeStoreClient(owned: const []));
      await s.refreshOwnership();
      expect(s.current.access, AccessLevel.free);
    });

    test('billing kodida SharedPreferences / lokal saqlash yo‘q', () {
      for (final f in Directory('lib/data/billing').listSync()) {
        final src = File(f.path).readAsStringSync();
        expect(
          src.contains("import 'package:shared_preferences"),
          isFalse,
          reason: f.path,
        );
        expect(
          src.contains("import 'dart:io'") && src.contains('File('),
          isFalse,
          reason: f.path,
        );
      }
    });

    test('store yo‘q: taklif yo‘q, xarid «unavailable»', () async {
      final s = service(FakeStoreClient(available: false));
      expect(await s.offers(), isEmpty);
      expect(
        await s.purchase(ProductIds.lifetime),
        PurchaseOutcome.unavailable,
      );
      expect(s.current.hasFullAccess, isFalse);
    });
  });

  test('narx faqat store’dan (lokal satr)', () async {
    final offers = await service(FakeStoreClient()).offers();
    expect(offers.single.localizedPrice, 'TEST-PRICE 1.00');
    expect(offers.single.type, StoreProductType.lifetimeUnlock);
  });

  group('xarid', () {
    test(
      'store tasdiqlasa: huquq (storeConfirmed), completePurchase',
      () async {
        final c = FakeStoreClient()
          ..onBuy = (_) => [ev(StoreEventStatus.purchased)];
        final v = _Verifier(VerificationStatus.serverNotConfigured);
        final s = service(c, verifier: v);
        expect(
          await s.purchase(ProductIds.lifetime),
          PurchaseOutcome.purchased,
        );
        expect(s.current.access, AccessLevel.lifetime);
        expect(s.current.verification, EntitlementVerification.storeConfirmed);
        expect(v.seen.single.serverVerificationData, 'TEST-TOKEN');
        expect(c.completed, [ProductIds.lifetime]);
      },
    );

    test('server tasdiqlasa — serverVerified', () async {
      final c = FakeStoreClient()
        ..onBuy = (_) => [ev(StoreEventStatus.purchased)];
      final s = service(c, verifier: _Verifier(VerificationStatus.verified));
      await s.purchase(ProductIds.lifetime);
      expect(s.current.verification, EntitlementVerification.serverVerified);
    });

    test('server rad etsa — huquq yo‘q, tranzaksiya yakunlanmaydi', () async {
      final c = FakeStoreClient()
        ..onBuy = (_) => [ev(StoreEventStatus.purchased)];
      final s = service(c, verifier: _Verifier(VerificationStatus.rejected));
      expect(await s.purchase(ProductIds.lifetime), PurchaseOutcome.failed);
      expect(s.current.hasFullAccess, isFalse);
      expect(c.completed, isEmpty);
    });

    test('server tekshiruvi majburiy, backend yo‘q — huquq yo‘q '
        '(release blocker holati)', () async {
      final c = FakeStoreClient()
        ..onBuy = (_) => [ev(StoreEventStatus.purchased)];
      final s = service(c, requireServer: true);
      expect(await s.purchase(ProductIds.lifetime), PurchaseOutcome.failed);
      expect(s.current.hasFullAccess, isFalse);
    });

    test('dalil (token) yo‘q xarid — rad etiladi', () async {
      final c = FakeStoreClient()
        ..onBuy = (_) => [ev(StoreEventStatus.purchased, token: null)];
      final s = service(c);
      expect(await s.purchase(ProductIds.lifetime), PurchaseOutcome.failed);
      expect(s.current.hasFullAccess, isFalse);
    });

    test('bekor qilish, xato, pending', () async {
      final c = FakeStoreClient()
        ..onBuy = (_) => [ev(StoreEventStatus.canceled, complete: false)];
      final s = service(c);
      expect(await s.purchase(ProductIds.lifetime), PurchaseOutcome.cancelled);
      c.onBuy = (_) => [ev(StoreEventStatus.error)];
      expect(await s.purchase(ProductIds.lifetime), PurchaseOutcome.failed);
      c.onBuy = (_) => [ev(StoreEventStatus.pending, complete: false)];
      expect(await s.purchase(ProductIds.lifetime), PurchaseOutcome.pending);
      expect(s.current.hasFullAccess, isFalse);
      c.controller.add([ev(StoreEventStatus.purchased)]);
      await Future<void>.delayed(Duration.zero);
      expect(s.current.hasFullAccess, isTrue);
    });

    test('boshqa mahsulot hodisasi huquq bermaydi', () async {
      final c = FakeStoreClient();
      final s = service(c);
      c.controller.add([
        const StoreEvent(
          productId: 'other.product',
          status: StoreEventStatus.purchased,
          serverVerificationData: 'TEST-TOKEN',
        ),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(s.current.hasFullAccess, isFalse);
    });
  });

  group('Restore Purchases / yangi telefon', () {
    test('o‘sha akkaunt: store egalikni tasdiqlaydi — tiklanadi', () async {
      final c = FakeStoreClient(owned: [ev(StoreEventStatus.restored)]);
      final s = service(c);
      final e = await s.restore();
      expect(c.restores, 1);
      expect(e.hasFullAccess, isTrue);
    });

    test('ilova ochilganda egalik store’dan jim tiklanadi', () async {
      final c = FakeStoreClient(owned: [ev(StoreEventStatus.restored)]);
      final s = service(c);
      final states = <bool>[];
      final sub = s.watch().listen((e) => states.add(e.hasFullAccess));
      await s.refreshOwnership();
      await Future<void>.delayed(Duration.zero);
      expect(states.first, isFalse);
      expect(states.last, isTrue);
      await sub.cancel();
    });

    test('xarid yo‘q akkaunt — bepul qoladi', () async {
      final s = service(FakeStoreClient());
      expect((await s.restore()).hasFullAccess, isFalse);
    });
  });
}
