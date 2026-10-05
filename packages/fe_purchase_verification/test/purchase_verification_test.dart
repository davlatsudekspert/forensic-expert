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
    expect(await service.hasActive('acc-1', _product), isTrue);
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
    expect(await service.hasActive('acc-1', _product), isFalse);
  });

  test('replay: bitta xarid ikkinchi akkauntga bog‘lanmaydi', () async {
    await service.verify(_req('ok'));
    final r = await service.verify(_req('ok', account: 'acc-2', key: 'k2'));
    expect(r.outcome, VerificationOutcome.alreadyBoundToAnotherAccount);
    expect(await service.hasActive('acc-2', _product), isFalse);
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
    final h = StoreNotificationHandler(service: service, appleJws: jws);
    expect(() => h.handleApple('forged'), throwsFormatException);
    expect(await h.handleApple('notif'), isTrue);
    expect(await service.hasActive('acc-1', _product), isFalse);
    // Bekor qilingan xarid qayta tekshiruvda ham tiklanmaydi.
    expect(
      (await service.verify(_req('ok', key: 'after'))).outcome,
      VerificationOutcome.revoked,
    );
  });

  test('Google voided purchase → bekor', () async {
    await service.verify(_req('gtoken', p: StorePlatform.googlePlay));
    final h = StoreNotificationHandler(
      service: service,
      appleJws: MockJwsChainVerifier(const {}),
    );
    expect(await h.handleGoogleVoided('O-g1'), isTrue);
    expect(await service.hasActive('acc-1', _product), isFalse);
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

  group('obuna holatlari (Student Pro / Institution)', () {
    final now = DateTime.utc(2026, 10, 4);
    StoreTransaction sub({
      DateTime? exp,
      DateTime? grace,
      bool renew = true,
      DateTime? revoked,
    }) => StoreTransaction(
      platform: StorePlatform.appStore,
      transactionId: 'T',
      originalTransactionId: 'O',
      productId: 'fe.student',
      appIdentifier: 'com.example.forensic',
      environment: StoreEnvironment.production,
      purchasedAt: DateTime.utc(2026, 9, 1),
      expiresAt: exp,
      gracePeriodExpiresAt: grace,
      autoRenewing: renew,
      revokedAt: revoked,
    );
    EntitlementState st(StoreTransaction t) =>
        EntitlementStateResolver.resolve(t, now);

    test('holatlar mashinasi', () {
      expect(st(sub()), EntitlementState.active); // Lifetime (muddatsiz)
      expect(st(sub(exp: DateTime.utc(2026, 11, 1))), EntitlementState.active);
      expect(
        st(sub(exp: DateTime.utc(2026, 11, 1), renew: false)),
        EntitlementState.cancelledActiveUntilExpiry,
      );
      expect(
        st(
          sub(
            exp: DateTime.utc(2026, 10, 1),
            grace: DateTime.utc(2026, 10, 10),
          ),
        ),
        EntitlementState.gracePeriod,
      );
      expect(st(sub(exp: DateTime.utc(2026, 10, 1))), EntitlementState.expired);
      expect(
        st(sub(exp: DateTime.utc(2026, 11, 1), revoked: now)),
        EntitlementState.revoked,
      );
      expect(
        EntitlementStateResolver.grantsAccess(EntitlementState.gracePeriod),
        isTrue,
      );
      expect(
        EntitlementStateResolver.grantsAccess(EntitlementState.expired),
        isFalse,
      );
    });

    test('muddati tugagan obuna server tomonida rad etiladi', () async {
      final s = PurchaseVerificationService(
        config: const VerificationConfig(
          appleBundleId: 'com.example.forensic',
          googlePackageName: 'com.example.forensic',
          allowedProductIds: {'fe.student'},
        ),
        store: InMemoryEntitlementStore(),
        verifiers: [
          MockStoreVerifier(StorePlatform.appStore, {
            'old': sub(exp: DateTime.utc(2026, 9, 30)),
            'cur': StoreTransaction(
              platform: StorePlatform.appStore,
              transactionId: 'T2',
              originalTransactionId: 'O2',
              productId: 'fe.student',
              appIdentifier: 'com.example.forensic',
              environment: StoreEnvironment.production,
              purchasedAt: DateTime.utc(2026, 10, 1),
              expiresAt: DateTime.utc(2026, 11, 1),
              autoRenewing: true,
            ),
          }),
        ],
        clock: () => now,
      );
      final results = await s.restore('acc', StorePlatform.appStore, {
        'fe.student': 'old',
      });
      expect(results.single.outcome, VerificationOutcome.expired);
      final ok = await s.restore('acc', StorePlatform.appStore, {
        'fe.student': 'cur',
      });
      expect(ok.single.outcome, VerificationOutcome.verified);
      expect(await s.hasActive('acc', 'fe.student'), isTrue);
    });
  });

  group('RG-18 obuna hayot sikli (tarif, audit, bildirishnomalar)', () {
    final now = DateTime.utc(2026, 10, 4);
    late InMemoryEntitlementStore st;
    late PurchaseVerificationService svc;
    StoreTransaction t(
      String id,
      String product, {
      DateTime? exp,
      DateTime? grace,
      bool retry = false,
      StorePlatform p = StorePlatform.appStore,
    }) => StoreTransaction(
      platform: p,
      transactionId: 'T-$id',
      originalTransactionId: 'O-$id',
      productId: product,
      appIdentifier: 'com.example.forensic',
      environment: StoreEnvironment.production,
      purchasedAt: DateTime.utc(2026, 9, 1),
      expiresAt: exp,
      gracePeriodExpiresAt: grace,
      autoRenewing: true,
      inBillingRetry: retry,
    );
    final future = DateTime.utc(2026, 11, 4);
    final past = DateTime.utc(2026, 10, 1);

    setUp(() {
      st = InMemoryEntitlementStore();
      svc = PurchaseVerificationService(
        config: const VerificationConfig(
          appleBundleId: 'com.example.forensic',
          googlePackageName: 'com.example.forensic',
          allowedProductIds: {'fe_student_pro_monthly', 'fe_pro_monthly'},
          productTiers: {
            'fe_student_pro_monthly': 'student_pro',
            'fe_pro_monthly': 'professional_pro',
          },
        ),
        store: st,
        verifiers: [
          MockStoreVerifier(StorePlatform.appStore, {
            'stu': t('s', 'fe_student_pro_monthly', exp: future),
            'pro': t('p', 'fe_pro_monthly', exp: future),
            'retry': t('r', 'fe_pro_monthly', exp: past, retry: true),
            'grace': t('g', 'fe_pro_monthly', exp: past, grace: future),
          }),
        ],
        clock: () => now,
      );
    });

    VerificationRequest req(String c, {String acc = 'a1', String? key}) =>
        VerificationRequest(
          platform: StorePlatform.appStore,
          accountId: acc,
          productId: c == 'stu' ? 'fe_student_pro_monthly' : 'fe_pro_monthly',
          purchaseCredential: c,
          idempotencyKey: key ?? 'k-$c-$acc',
        );

    test('normallashtirilgan huquq: eng yuqori faol tarif', () async {
      expect((await svc.entitlementFor('a1')).tier, 'free');
      await svc.verify(req('stu'));
      expect((await svc.entitlementFor('a1')).tier, 'student_pro');
      await svc.verify(req('pro'));
      final e = await svc.entitlementFor('a1');
      expect(e.tier, 'professional_pro');
      expect(e.toClientJson()['entitlement_status'], 'active');
      expect(e.toClientJson()['expires_at'], future.toIso8601String());
    });

    test('billing retry — kirish yo‘q; grace — kirish bor', () async {
      expect(
        (await svc.verify(req('retry'))).outcome,
        VerificationOutcome.billingRetry,
      );
      final g = await svc.verify(req('grace'));
      expect(g.outcome, VerificationOutcome.verified);
      expect(g.entitlement!.state, EntitlementState.gracePeriod);
      expect(await svc.hasActive('a1', 'fe_pro_monthly'), isTrue);
    });

    test('Apple bildirishnomalari: renew, fail-to-renew, expired, refund '
        '(yakuniy) va sirsiz audit', () async {
      await svc.verify(req('pro'));
      final jws = MockJwsChainVerifier({
        'fail': {
          'notificationType': 'DID_FAIL_TO_RENEW',
          'data': {'signedTransactionInfo': 'tx'},
        },
        'renew': {
          'notificationType': 'DID_RENEW',
          'data': {'signedTransactionInfo': 'tx2'},
        },
        'cancel': {
          'notificationType': 'DID_CHANGE_RENEWAL_STATUS',
          'data': {'signedTransactionInfo': 'tx2', 'signedRenewalInfo': 'ri'},
        },
        'refund': {
          'notificationType': 'REFUND',
          'data': {'signedTransactionInfo': 'tx2'},
        },
        'tx': {'originalTransactionId': 'O-p'},
        'tx2': {
          'originalTransactionId': 'O-p',
          'expiresDate': DateTime.utc(2026, 12, 4).millisecondsSinceEpoch,
        },
        'ri': {'autoRenewStatus': 0},
      });
      final h = StoreNotificationHandler(service: svc, appleJws: jws);
      expect(await h.handleApple('fail'), isTrue);
      expect(await svc.hasActive('a1', 'fe_pro_monthly'), isFalse);
      expect(await h.handleApple('renew'), isTrue);
      expect(await svc.hasActive('a1', 'fe_pro_monthly'), isTrue);
      expect(
        (await svc.entitlementFor('a1')).expiresAt,
        DateTime.utc(2026, 12, 4),
      );
      expect(await h.handleApple('cancel'), isTrue);
      expect(
        (await svc.entitlementFor('a1')).state,
        EntitlementState.cancelledActiveUntilExpiry,
      );
      expect(await h.handleApple('refund'), isTrue);
      expect((await svc.entitlementFor('a1')).tier, 'free');
      // Revoked — yakuniy: keyingi renew uni tiklamaydi.
      expect(await h.handleApple('renew'), isFalse);
      expect(await svc.hasActive('a1', 'fe_pro_monthly'), isFalse);

      final reasons = [for (final a in st.audit) a.reason];
      expect(reasons, [
        'VERIFIED',
        'DID_FAIL_TO_RENEW',
        'DID_RENEW',
        'DID_CHANGE_RENEWAL_STATUS',
        'REFUND',
      ]);
      for (final a in st.audit) {
        expect(a.recordFingerprint, hasLength(16));
        expect(a.recordFingerprint, isNot(contains('O-p')));
      }
    });

    test('Google RTDN holatlari', () {
      expect(
        StoreNotificationHandler.googleState(6),
        EntitlementState.gracePeriod,
      );
      expect(
        StoreNotificationHandler.googleState(5),
        EntitlementState.billingRetry,
      );
      expect(
        StoreNotificationHandler.googleState(3),
        EntitlementState.cancelledActiveUntilExpiry,
      );
      expect(
        StoreNotificationHandler.googleState(12),
        EntitlementState.revoked,
      );
      expect(
        StoreNotificationHandler.googleState(13),
        EntitlementState.expired,
      );
      expect(StoreNotificationHandler.googleState(99), isNull);
    });

    test('restore: yangi qurilma, o‘sha akkaunt — tiklanadi; boshqa akkaunt '
        '— replay rad', () async {
      await svc.verify(req('pro'));
      final again = await svc.restore('a1', StorePlatform.appStore, {
        'fe_pro_monthly': 'pro',
      });
      expect(again.single.outcome, VerificationOutcome.verified);
      final other = await svc.restore('a2', StorePlatform.appStore, {
        'fe_pro_monthly': 'pro',
      });
      expect(
        other.single.outcome,
        VerificationOutcome.alreadyBoundToAnotherAccount,
      );
      expect((await svc.entitlementFor('a2')).tier, 'free');
    });
  });
}
