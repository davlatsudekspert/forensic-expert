import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'models.dart';
import 'ports.dart';

/// Audit uchun sirsiz barmoq izi (credential o‘zi yozilmaydi).
String recordFingerprint(StorePlatform p, String originalTransactionId) =>
    sha256
        .convert(utf8.encode('${p.name}:$originalTransactionId'))
        .toString()
        .substring(0, 16);

/// RG-18: server tomonida xaridni tekshirish.
///
/// Qoidalar (fail closed):
/// 1. Mahsulot ruxsat ro‘yxatida bo‘lishi shart.
/// 2. Xarid ma’lumoti faqat store’ning o‘zidan olinadi (mijozga ishonilmaydi).
/// 3. Ilova identifikatori (bundle ID / package name) mos bo‘lishi shart.
/// 4. Production’da sandbox xaridi rad etiladi.
/// 5. Refund/bekor qilingan yoki «sotib olinmagan» holat — huquq yo‘q.
/// 6. Replay: bitta xarid (originalTransactionId / purchase token) faqat
///    bitta akkauntga bog‘lanadi.
/// 7. Idempotentlik: bir xil kalit — bir xil natija, store’ga qayta
///    murojaatsiz.
/// 8. Store javob bermasa — huquq berilmaydi (`storeUnavailable`).
/// 9. Obuna holati (active / grace / cancelled-until-expiry / billing retry
///    / expired / revoked) store ma’lumotidan hisoblanadi; har o‘zgarish
///    sirsiz audit jurnaliga yoziladi; `revoked` — yakuniy.
class PurchaseVerificationService {
  PurchaseVerificationService({
    required this.config,
    required this.store,
    required Iterable<StoreVerifier> verifiers,
    Clock? clock,
  }) : _verifiers = {for (final v in verifiers) v.platform: v},
       _clock = clock ?? DateTime.now;

  final VerificationConfig config;
  final EntitlementStore store;
  final Map<StorePlatform, StoreVerifier> _verifiers;
  final Clock _clock;

  Future<VerificationResult> verify(VerificationRequest req) async {
    final cached = await store.idempotent(req.idempotencyKey);
    if (cached != null) return cached;
    final result = await _verify(req);
    // Vaqtinchalik xato keshlanmaydi — mijoz qayta urinishi mumkin.
    if (result.outcome != VerificationOutcome.storeUnavailable) {
      await store.rememberIdempotent(req.idempotencyKey, result);
    }
    return result;
  }

  Future<VerificationResult> _verify(VerificationRequest req) async {
    if (!config.allowedProductIds.contains(req.productId)) {
      return const VerificationResult(VerificationOutcome.productNotAllowed);
    }
    final verifier = _verifiers[req.platform];
    if (verifier == null) {
      return const VerificationResult(VerificationOutcome.notConfigured);
    }
    final StoreTransaction t;
    try {
      t = await verifier.fetch(req.purchaseCredential, req.productId);
    } on StoreVerifierException catch (e) {
      return VerificationResult(
        e.kind == 'unavailable'
            ? VerificationOutcome.storeUnavailable
            : VerificationOutcome.invalidCredential,
      );
    }
    final expectedApp = req.platform == StorePlatform.appStore
        ? config.appleBundleId
        : config.googlePackageName;
    if (t.appIdentifier != expectedApp || t.platform != req.platform) {
      return const VerificationResult(VerificationOutcome.wrongApp);
    }
    if (t.productId != req.productId) {
      return const VerificationResult(VerificationOutcome.productNotAllowed);
    }
    if (t.environment == StoreEnvironment.sandbox && !config.allowSandbox) {
      return const VerificationResult(VerificationOutcome.sandboxNotAllowed);
    }
    if (t.revokedAt != null) {
      return const VerificationResult(VerificationOutcome.revoked);
    }
    final state = EntitlementStateResolver.resolve(t, _clock());
    if (state == EntitlementState.expired) {
      return const VerificationResult(VerificationOutcome.expired);
    }
    if (state == EntitlementState.billingRetry) {
      return const VerificationResult(VerificationOutcome.billingRetry);
    }
    if (!t.isPurchased) {
      return const VerificationResult(VerificationOutcome.notPurchased);
    }

    final existing = await store.byOriginalTransaction(
      t.platform,
      t.originalTransactionId,
    );
    if (existing != null) {
      if (existing.accountId != req.accountId) {
        return const VerificationResult(
          VerificationOutcome.alreadyBoundToAnotherAccount,
        );
      }
      if (!existing.active) {
        return const VerificationResult(VerificationOutcome.revoked);
      }
      // Restore / yangilanish: store’dagi so‘nggi muddat va holat.
      final refreshed = await _transition(
        existing,
        state,
        'VERIFIED',
        expiresAt: t.expiresAt,
        transactionId: t.transactionId,
      );
      return VerificationResult(
        VerificationOutcome.verified,
        entitlement: refreshed,
      );
    }
    final record = EntitlementRecord(
      accountId: req.accountId,
      productId: t.productId,
      platform: t.platform,
      originalTransactionId: t.originalTransactionId,
      transactionId: t.transactionId,
      grantedAt: _clock().toUtc(),
      environment: t.environment,
      expiresAt: t.expiresAt,
      state: state,
    );
    if (!await store.insertIfAbsent(record)) {
      // Parallel so‘rov boshqa akkauntga bog‘lab ulgurdi.
      final winner = await store.byOriginalTransaction(
        t.platform,
        t.originalTransactionId,
      );
      return winner?.accountId == req.accountId
          ? VerificationResult(
              VerificationOutcome.verified,
              entitlement: winner,
            )
          : const VerificationResult(
              VerificationOutcome.alreadyBoundToAnotherAccount,
            );
    }
    await _audit(record, null, state, 'VERIFIED');
    if (t.needsAcknowledgement) {
      // Acknowledge xatosi huquqni bekor qilmaydi — qayta urinish navbati
      // (production: background job). Bu yerda xato yutilmaydi, uzatiladi.
      await verifier.acknowledge(t);
    }
    return VerificationResult(
      VerificationOutcome.verified,
      entitlement: record,
    );
  }

  Future<EntitlementRecord> _transition(
    EntitlementRecord r,
    EntitlementState to,
    String reason, {
    DateTime? expiresAt,
    String? transactionId,
  }) async {
    if (!EntitlementTransitions.isAllowed(r.state, to)) return r;
    final next = r.copyWith(
      state: to,
      expiresAt: expiresAt,
      transactionId: transactionId,
    );
    if (next.state != r.state || next.expiresAt != r.expiresAt) {
      await store.update(next);
      await _audit(r, r.state, to, reason);
    }
    return next;
  }

  Future<void> _audit(
    EntitlementRecord r,
    EntitlementState? from,
    EntitlementState to,
    String reason,
  ) => store.appendAudit(
    EntitlementAuditEntry(
      at: _clock().toUtc(),
      platform: r.platform,
      recordFingerprint: recordFingerprint(r.platform, r.originalTransactionId),
      from: from,
      to: to,
      reason: reason,
    ),
  );

  /// Mahsulot huquqi faolmi (mijoz faqat server javobiga tayanadi).
  Future<bool> hasActive(String accountId, String productId) async =>
      (await store.forAccount(accountId))
          .any((r) => r.productId == productId && r.activeAt(_clock()));

  /// Akkauntning normallashtirilgan huquqi — eng yuqori faol tarif.
  Future<AccountEntitlement> entitlementFor(String accountId) async {
    const rank = ['free', 'student_pro', 'professional_pro', 'institution'];
    var best = AccountEntitlement.free;
    for (final r in await store.forAccount(accountId)) {
      if (!r.activeAt(_clock())) continue;
      final tier = config.productTiers[r.productId];
      if (tier == null) continue;
      if (rank.indexOf(tier) > rank.indexOf(best.tier)) {
        best = AccountEntitlement(
          tier: tier,
          state: r.state,
          productId: r.productId,
          expiresAt: r.expiresAt,
        );
      }
    }
    return best;
  }

  /// Store obuna hodisasi (bildirishnoma ishlovchisi chaqiradi).
  Future<bool> applySubscriptionEvent(
    StorePlatform platform,
    String originalTransactionId,
    EntitlementState to,
    String reason, {
    DateTime? expiresAt,
  }) async {
    final r = await store.byOriginalTransaction(
      platform,
      originalTransactionId,
    );
    if (r == null) return false;
    if (to == EntitlementState.revoked) {
      if (!r.active) return false;
      await store.update(r.revoke(_clock().toUtc(), reason));
      await _audit(r, r.state, to, reason);
      return true;
    }
    final next = await _transition(r, to, reason, expiresAt: expiresAt);
    return !identical(next, r);
  }

  /// Restore: mijoz qurilmadagi xaridlarni yuboradi; har biri store orqali
  /// qayta tekshiriladi (replay himoyasi saqlanadi).
  Future<List<VerificationResult>> restore(
    String accountId,
    StorePlatform platform,
    Map<String, String> credentialsByProduct,
  ) async => [
    for (final e in credentialsByProduct.entries)
      await verify(
        VerificationRequest(
          platform: platform,
          accountId: accountId,
          productId: e.key,
          purchaseCredential: e.value,
          idempotencyKey: 'restore:$accountId:${platform.name}:${e.value}',
        ),
      ),
  ];
}

/// Store bildirishnomalari (obuna hayot sikli + refund/revoke).
///
/// * Apple App Store Server Notifications V2: `signedPayload` (JWS) —
///   [JwsChainVerifier] bilan tekshiriladi; `notificationType` (+ `subtype`)
///   normallashtirilgan holatga o‘tkaziladi ([appleState]).
/// * Google Real-time Developer Notifications (Pub/Sub push, OIDC bilan
///   autentifikatsiya — port tashqarisida): `subscriptionNotification`
///   `notificationType` raqami ([googleState]); `voidedPurchaseNotification`
///   → revoked. Google muddatni bildirishnomada bermaydi — ishlovchi
///   `purchases.subscriptionsv2.get` dan olib [expiresAt] bilan uzatadi.
class StoreNotificationHandler {
  StoreNotificationHandler({required this.service, required this.appleJws});

  final PurchaseVerificationService service;
  final JwsChainVerifier appleJws;

  /// Apple `notificationType` / `subtype` → holat. `null` — e’tiborsiz.
  static EntitlementState? appleState(
    String? type,
    String? subtype, {
    bool autoRenew = true,
  }) => switch (type) {
    'SUBSCRIBED' || 'DID_RENEW' || 'OFFER_REDEEMED' => EntitlementState.active,
    'DID_CHANGE_RENEWAL_STATUS' =>
      autoRenew
          ? EntitlementState.active
          : EntitlementState.cancelledActiveUntilExpiry,
    'DID_FAIL_TO_RENEW' =>
      subtype == 'GRACE_PERIOD'
          ? EntitlementState.gracePeriod
          : EntitlementState.billingRetry,
    'GRACE_PERIOD_EXPIRED' => EntitlementState.billingRetry,
    'EXPIRED' => EntitlementState.expired,
    'REFUND' || 'REVOKE' => EntitlementState.revoked,
    _ => null,
  };

  /// Google `subscriptionNotification.notificationType` → holat.
  static EntitlementState? googleState(int type) => switch (type) {
    1 ||
    2 ||
    4 ||
    7 => EntitlementState.active, // RECOVERED/RENEWED/PURCHASED/RESTARTED
    3 => EntitlementState.cancelledActiveUntilExpiry, // CANCELED
    5 => EntitlementState.billingRetry, // ON_HOLD
    6 => EntitlementState.gracePeriod, // IN_GRACE_PERIOD
    12 => EntitlementState.revoked, // REVOKED
    13 => EntitlementState.expired, // EXPIRED
    _ => null,
  };

  /// Apple V2 bildirishnomasi. Imzo noto‘g‘ri bo‘lsa — xato (rad).
  Future<bool> handleApple(String signedPayload) async {
    final payload = appleJws.verify(signedPayload);
    final type = payload['notificationType'] as String?;
    final subtype = payload['subtype'] as String?;
    final data = (payload['data'] as Map?)?.cast<String, Object?>() ?? {};
    final txJws = data['signedTransactionInfo'];
    if (txJws is! String) return false;
    final tx = appleJws.verify(txJws);
    final renewalJws = data['signedRenewalInfo'];
    final renewal = renewalJws is String ? appleJws.verify(renewalJws) : null;
    final state = appleState(
      type,
      subtype,
      autoRenew: renewal == null || renewal['autoRenewStatus'] != 0,
    );
    if (state == null) return false;
    final exp = tx['expiresDate'];
    return service.applySubscriptionEvent(
      StorePlatform.appStore,
      tx['originalTransactionId']! as String,
      state,
      type!,
      expiresAt: exp is int
          ? DateTime.fromMillisecondsSinceEpoch(exp, isUtc: true)
          : null,
    );
  }

  /// Google RTDN obuna bildirishnomasi (autentifikatsiyadan o‘tgan push).
  Future<bool> handleGoogleSubscription(
    String purchaseToken,
    int notificationType, {
    DateTime? expiresAt,
  }) async {
    final state = googleState(notificationType);
    if (state == null) return false;
    return service.applySubscriptionEvent(
      StorePlatform.googlePlay,
      purchaseToken,
      state,
      'RTDN_$notificationType',
      expiresAt: expiresAt,
    );
  }

  /// Google Voided Purchases — refund / chargeback.
  Future<bool> handleGoogleVoided(String purchaseToken) =>
      service.applySubscriptionEvent(
        StorePlatform.googlePlay,
        purchaseToken,
        EntitlementState.revoked,
        'VOIDED',
      );
}
