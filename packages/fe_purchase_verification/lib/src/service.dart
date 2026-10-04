import 'models.dart';
import 'ports.dart';

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
      return VerificationResult(
        VerificationOutcome.verified,
        entitlement: existing,
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

  /// Akkaunt huquqlari (mijoz faqat shu javobga tayanadi).
  Future<bool> hasLifetime(String accountId, String productId) async =>
      (await store.forAccount(accountId))
          .any((r) => r.productId == productId && r.active);
}

/// Store bildirishnomalari: refund / revoke / voided purchase.
///
/// * Apple App Store Server Notifications V2: `signedPayload` (JWS) —
///   [JwsChainVerifier] bilan tekshiriladi; `notificationType`
///   `REFUND` yoki `REVOKE` → huquq bekor qilinadi.
/// * Google Real-time Developer Notifications (Pub/Sub push) +
///   Voided Purchases API: push so‘rovi Pub/Sub OIDC tokeni bilan
///   autentifikatsiya qilinadi (bu yerda port orqali tekshirilgan deb
///   uzatiladi), `voidedPurchaseNotification` → bekor qilish.
class StoreNotificationHandler {
  StoreNotificationHandler({
    required this.store,
    required this.appleJws,
    Clock? clock,
  }) : _clock = clock ?? DateTime.now;

  final EntitlementStore store;
  final JwsChainVerifier appleJws;
  final Clock _clock;

  static const _appleRevoking = {'REFUND', 'REVOKE'};

  /// Apple V2 bildirishnomasi. Imzo noto‘g‘ri bo‘lsa — xato (rad).
  Future<bool> handleApple(String signedPayload) async {
    final payload = appleJws.verify(signedPayload);
    final type = payload['notificationType'];
    if (!_appleRevoking.contains(type)) return false;
    final data = (payload['data'] as Map?)?.cast<String, Object?>() ?? {};
    final tx = appleJws.verify(data['signedTransactionInfo']! as String);
    return _revoke(
      StorePlatform.appStore,
      tx['originalTransactionId']! as String,
      '$type',
    );
  }

  /// Google RTDN — autentifikatsiyadan o‘tgan push’dan purchase token.
  Future<bool> handleGoogleVoided(String purchaseToken) =>
      _revoke(StorePlatform.googlePlay, purchaseToken, 'VOIDED');

  Future<bool> _revoke(StorePlatform p, String original, String reason) async {
    final r = await store.byOriginalTransaction(p, original);
    if (r == null || !r.active) return false;
    await store.update(r.revoke(_clock().toUtc(), reason));
    return true;
  }
}
