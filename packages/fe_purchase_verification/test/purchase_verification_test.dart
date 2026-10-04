import 'package:fe_purchase_verification/fe_purchase_verification.dart';
import 'package:test/test.dart';

const _product = 'fe.lifetime';
const _config = VerificationConfig(
  appleBundleId: 'com.example.forensic',
  googlePackageName: 'com.example.forensic',
  allowedProductIds: {_product},
);

StoreTransaction _tx(
  String id, {
  StorePlatform p = StorePlatform.appStore,
  String app = 'com.example.forensic',
  String product = _product,
  StoreEnvironment env = StoreEnvironment.production,
  DateTime? revokedAt,
  bool purchased = true,
  bool ack = false,
}) => StoreTransaction(
  platform: p,
  transactionId: 'T-$id',
  originalTransactionId: 'O-$id',
  productId: product,
  appIdentifier: app,
  environment: env,
  purchasedAt: DateTime.utc(2026, 10, 1),
  revokedAt: revokedAt,
  isPurchased: purchased,
  needsAcknowledgement: ack,
);

VerificationRequest _req(
  String credential, {
  String account = 'acc-1',
  String key = 'k1',
  StorePlatform p = StorePlatform.appStore,
  String product = _product,
}) => VerificationRequest(
  platform: p,
  accountId: account,
  productId: product,
  purchaseCredential: credential,
  idempotencyKey: key,
);

void main() {
  late InMemoryEntitlementStore store;
  late MockStoreVerifier apple;
  late MockStoreVerifier google;
  late PurchaseVerificationService service;

  setUp(() {
    store = InMemoryEntitlementStore();
    apple = MockStoreVerifier(StorePlatform.appStore, {
      'ok': _tx('1'),
      'other-app': _tx('2', app: 'com.evil.clone'),
      'sandbox': _tx('3', env: StoreEnvironment.sandbox),
      'refunded': _tx('4', revokedAt: DateTime.utc(2026, 10, 2)),
      'down': null,
      'wrong-product': _tx('5', product: 'fe.other'),
    });
    google = MockStoreVerifier(StorePlatform.googlePlay, {
      'gtoken': _tx('g1', p: StorePlatform.googlePlay, ack: true),
      'pending': _tx('g2', p: StorePlatform.googlePlay, purchased: false),
    });
    service = PurchaseVerificationService(
      config: _config,
      store: store,
      verifiers: [apple, google],
      clock: () => DateTime.utc(2026, 10, 4),
    );
  });

  test('to‘g‘ri xarid — server tasdiqlaydi va huquq yoziladi', () async {
    final r = await service.verify(_req('ok'));
    expect(r.outcome, VerificationOutcome.verified);
    expect(await service.hasLifetime('acc-1', _product), isTrue);
  });

  test('soxta credential, boshqa ilova, sandbox, refund — rad', () async {
    expect(
      (await service.verify(_req('forged', key: 'a'))).outcome,
      VerificationOutcome.invalidCredential,
    );
    expect(
      (await service.verify(_req('other-app', key: 'b'))).outcome,
      VerificationOutcome.wrongApp,
    );
    expect(
      (await service.verify(_req('sandbox', key: 'c'))).outcome,
      VerificationOutcome.sandboxNotAllowed,
    );
    expect(
      (await service.verify(_req('refunded', key: 'd'))).outcome,
      VerificationOutcome.revoked,
    );
    expect(
      (await service.verify(_req('wrong-product', key: 'e'))).outcome,
      VerificationOutcome.productNotAllowed,
    );
    expect(
      (await service.verify(_req('ok', key: 'f', product: 'fe.unknown')))
          .outcome,
      VerificationOutcome.productNotAllowed,
    );
    expect(await service.hasLifetime('acc-1', _product), isFalse);
  });

  test('replay: bitta xarid ikkinchi akkauntga bog‘lanmaydi', () async {
    await service.verify(_req('ok'));
    final r = await service.verify(_req('ok', account: 'acc-2', key: 'k2'));
    expect(r.outcome, VerificationOutcome.alreadyBoundToAnotherAccount);
    expect(await service.hasLifetime('acc-2', _product), isFalse);
    // Xuddi shu akkaunt qayta tiklash (restore) — ruxsat.
    final again = await service.verify(_req('ok', key: 'k3'));
    expect(again.outcome, VerificationOutcome.verified);
  });

  test('idempotentlik: bir xil kalit — store’ga qayta murojaat yo‘q', () async {
    await service.verify(_req('ok'));
    await service.verify(_req('ok'));
    expect(apple.calls, 1);
  });

  test('store ishlamasa — fail closed va keshlanmaydi', () async {
    final r = await service.verify(_req('down', key: 'x'));
    expect(r.outcome, VerificationOutcome.storeUnavailable);
    expect(r.granted, isFalse);
    await service.verify(_req('down', key: 'x'));
    expect(apple.calls, 2);
  });

  test(
    'Google: sotib olinmagan rad; sotib olingani acknowledge qilinadi',
    () async {
      expect(
        (await service.verify(
          _req('pending', p: StorePlatform.googlePlay, key: 'g0'),
        )).outcome,
        VerificationOutcome.notPurchased,
      );
      final r = await service.verify(
        _req('gtoken', p: StorePlatform.googlePlay, key: 'g1'),
      );
      expect(r.outcome, VerificationOutcome.verified);
      expect(google.acknowledged, ['O-g1']);
    },
  );

  test('platforma sozlanmagan — notConfigured (huquq yo‘q)', () async {
    final s = PurchaseVerificationService(
      config: _config,
      store: store,
      verifiers: const [],
    );
    expect(
      (await s.verify(_req('ok'))).outcome,
      VerificationOutcome.notConfigured,
    );
  });

  test('refund bildirishnomasi huquqni bekor qiladi; soxta imzo rad', () async {
    await service.verify(_req('ok'));
    final jws = MockJwsChainVerifier({
      'notif': {
        'notificationType': 'REFUND',
        'data': {'signedTransactionInfo': 'tx'},
      },
      'tx': {'originalTransactionId': 'O-1'},
    });
    final h = StoreNotificationHandler(store: store, appleJws: jws);
    expect(() => h.handleApple('forged'), throwsFormatException);
    expect(await h.handleApple('notif'), isTrue);
    expect(await service.hasLifetime('acc-1', _product), isFalse);
    // Bekor qilingan xarid qayta tekshiruvda ham tiklanmaydi.
    expect(
      (await service.verify(_req('ok', key: 'after'))).outcome,
      VerificationOutcome.revoked,
    );
  });

  test('Google voided purchase → bekor', () async {
    await service.verify(_req('gtoken', p: StorePlatform.googlePlay));
    final h = StoreNotificationHandler(
      store: store,
      appleJws: MockJwsChainVerifier(const {}),
    );
    expect(await h.handleGoogleVoided('O-g1'), isTrue);
    expect(await service.hasLifetime('acc-1', _product), isFalse);
  });

  test('production’da mock taqiqlangan', () {
    expect(
      () => assertNoMocksInProduction(production: true, components: [apple]),
      throwsStateError,
    );
    expect(
      () => assertNoMocksInProduction(production: false, components: [apple]),
      returnsNormally,
    );
  });
}
