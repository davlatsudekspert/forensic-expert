import 'package:meta/meta.dart';

enum StorePlatform { appStore, googlePlay }

/// Store muhiti. Production serverda sandbox xaridi rad etiladi.
enum StoreEnvironment { production, sandbox }

/// Mijozdan keladigan so‘rov. Mijoz «xarid qildim» deb da’vo qiladi —
/// server buni store’ning o‘zidan tekshiradi; mijoz ma’lumotiga ishonilmaydi.
@immutable
class VerificationRequest {
  const VerificationRequest({
    required this.platform,
    required this.accountId,
    required this.productId,
    required this.purchaseCredential,
    required this.idempotencyKey,
  });

  final StorePlatform platform;

  /// Ilova akkaunti (server auth’dan; mijoz yuborgan ID emas).
  final String accountId;
  final String productId;

  /// App Store: transaction ID (yoki JWS); Google Play: purchase token.
  final String purchaseCredential;

  /// Takroriy so‘rov bir xil natija qaytaradi (tarmoq qayta urinishi).
  final String idempotencyKey;
}

/// Store’ning o‘zi tasdiqlagan xarid (verifier natijasi).
@immutable
class StoreTransaction {
  const StoreTransaction({
    required this.platform,
    required this.transactionId,
    required this.originalTransactionId,
    required this.productId,
    required this.appIdentifier,
    required this.environment,
    required this.purchasedAt,
    this.revokedAt,
    this.isPurchased = true,
    this.needsAcknowledgement = false,
    this.expiresAt,
    this.gracePeriodExpiresAt,
    this.autoRenewing = false,
    this.inBillingRetry = false,
  });

  final StorePlatform platform;

  /// Apple `transactionId` / Google `orderId`.
  final String transactionId;

  /// Apple `originalTransactionId` / Google purchase token — replay kaliti.
  final String originalTransactionId;
  final String productId;

  /// Apple `bundleId` / Google `packageName`.
  final String appIdentifier;
  final StoreEnvironment environment;
  final DateTime purchasedAt;

  /// Refund yoki bekor qilish vaqti (bo‘lsa — huquq yo‘q).
  final DateTime? revokedAt;

  /// Google `purchaseState == 0` (PURCHASED); Apple’da doim true.
  final bool isPurchased;

  /// Google: 3 kun ichida acknowledge qilinmasa, xarid qaytariladi.
  final bool needsAcknowledgement;

  /// Obuna (Student Pro / Institution) muddati; bir martalik (Lifetime)
  /// xaridda `null`.
  final DateTime? expiresAt;

  /// To‘lov muammosida store bergan imtiyozli davr oxiri.
  final DateTime? gracePeriodExpiresAt;

  /// Avtomatik yangilanish yoqilganmi (bekor qilingan obuna muddat
  /// oxirigacha amal qiladi).
  final bool autoRenewing;

  /// Apple `isInBillingRetryPeriod` / Google `SUBSCRIPTION_ON_HOLD`
  /// (account hold) — imtiyozli davrdan keyin to‘lov qayta urinilmoqda.
  final bool inBillingRetry;
}

/// Huquq holati — faqat server hisoblaydi; mijoz Pro holatiga ishonilmaydi.
enum EntitlementState {
  /// Amalda (Lifetime yoki muddati tugamagan obuna).
  active,

  /// Obuna bekor qilingan, lekin to‘langan muddat oxirigacha amal qiladi.
  cancelledActiveUntilExpiry,

  /// To‘lov muammosi — store imtiyozli davri.
  gracePeriod,

  /// Imtiyozli davr tugagan, to‘lov qayta urinilmoqda — kirish YO‘Q.
  billingRetry,

  /// Muddati tugagan.
  expired,

  /// Refund / bekor qilingan.
  revoked,
}

/// Deterministik holat hisoblovchisi.
abstract final class EntitlementStateResolver {
  static EntitlementState resolve(StoreTransaction t, DateTime now) {
    if (t.revokedAt != null) return EntitlementState.revoked;
    final exp = t.expiresAt;
    if (exp == null) return EntitlementState.active;
    if (now.isBefore(exp)) {
      return t.autoRenewing
          ? EntitlementState.active
          : EntitlementState.cancelledActiveUntilExpiry;
    }
    final grace = t.gracePeriodExpiresAt;
    if (grace != null && now.isBefore(grace)) {
      return EntitlementState.gracePeriod;
    }
    if (t.inBillingRetry) return EntitlementState.billingRetry;
    return EntitlementState.expired;
  }

  /// Ilovada Pro funksiyalar ochiqmi.
  static bool grantsAccess(EntitlementState s) => switch (s) {
    EntitlementState.active ||
    EntitlementState.cancelledActiveUntilExpiry ||
    EntitlementState.gracePeriod => true,
    EntitlementState.billingRetry ||
    EntitlementState.expired ||
    EntitlementState.revoked => false,
  };

  /// Mijoz kontrakti (`entitlement_status`) — ilova shu satrlarni o‘qiydi.
  static String wireName(EntitlementState s) => switch (s) {
    EntitlementState.active => 'active',
    EntitlementState.cancelledActiveUntilExpiry =>
      'cancelled_active_until_expiry',
    EntitlementState.gracePeriod => 'grace_period',
    EntitlementState.billingRetry => 'billing_retry',
    EntitlementState.expired => 'expired',
    EntitlementState.revoked => 'revoked',
  };
}

/// Ruxsat etilgan holat o‘tishlari. `revoked` — yakuniy (refund qilingan
/// xarid qayta tiklanmaydi; yangi xarid — yangi tranzaksiya). Boshqa
/// o‘tishlar store hodisalaridan kelib chiqadi.
abstract final class EntitlementTransitions {
  static bool isAllowed(EntitlementState from, EntitlementState to) {
    if (from == to) return true;
    if (from == EntitlementState.revoked) return false;
    return true;
  }
}

/// Audit yozuvi — sirsiz: tranzaksiya ID / purchase token o‘rniga uning
/// SHA-256 barmoq izi; credential, token, JWS yozilmaydi.
@immutable
class EntitlementAuditEntry {
  const EntitlementAuditEntry({
    required this.at,
    required this.platform,
    required this.recordFingerprint,
    required this.from,
    required this.to,
    required this.reason,
  });

  final DateTime at;
  final StorePlatform platform;

  /// `sha256(platform:originalTransactionId)` ning boshidagi 16 belgi.
  final String recordFingerprint;
  final EntitlementState? from;
  final EntitlementState to;

  /// Masalan: `VERIFIED`, `DID_RENEW`, `EXPIRED`, `REFUND`, `VOIDED`.
  final String reason;
}

enum VerificationOutcome {
  verified,
  invalidCredential,
  productNotAllowed,
  wrongApp,
  sandboxNotAllowed,
  notPurchased,
  revoked,

  /// Obuna muddati tugagan (imtiyozli davr ham).
  expired,

  /// Imtiyozli davrdan keyin to‘lov qayta urinilmoqda — kirish yo‘q.
  billingRetry,

  /// Bu xarid boshqa akkauntga bog‘langan (replay / ulashish).
  alreadyBoundToAnotherAccount,

  /// Store API vaqtincha javob bermadi — mijoz keyinroq qayta urinadi;
  /// huquq BERILMAYDI (fail closed).
  storeUnavailable,

  /// Server store kalitlari bilan sozlanmagan — production’da tekshiruv yo‘q.
  notConfigured,
}

@immutable
class VerificationResult {
  const VerificationResult(this.outcome, {this.entitlement});

  final VerificationOutcome outcome;
  final EntitlementRecord? entitlement;

  bool get granted => outcome == VerificationOutcome.verified;
}

/// Server bazasidagi huquq yozuvi (haqiqat manbai).
@immutable
class EntitlementRecord {
  const EntitlementRecord({
    required this.accountId,
    required this.productId,
    required this.platform,
    required this.originalTransactionId,
    required this.transactionId,
    required this.grantedAt,
    required this.environment,
    this.revokedAt,
    this.revocationReason,
    this.expiresAt,
    this.state = EntitlementState.active,
  });

  final String accountId;
  final String productId;
  final StorePlatform platform;
  final String originalTransactionId;
  final String transactionId;
  final DateTime grantedAt;
  final StoreEnvironment environment;
  final DateTime? revokedAt;
  final String? revocationReason;

  /// Obuna muddati (bir martalik xaridda `null`).
  final DateTime? expiresAt;

  /// Oxirgi normallashtirilgan holat (store hodisalari yangilaydi).
  final EntitlementState state;

  bool get active => revokedAt == null;

  /// Vaqtga bog‘liq faollik: holat kirish beradi va muddat o‘tmagan
  /// (grace — muddatdan keyin ham ochiq).
  bool activeAt(DateTime now) =>
      active &&
      EntitlementStateResolver.grantsAccess(state) &&
      (state == EntitlementState.gracePeriod ||
          expiresAt == null ||
          now.isBefore(expiresAt!));

  EntitlementRecord copyWith({
    EntitlementState? state,
    DateTime? expiresAt,
    String? transactionId,
  }) => EntitlementRecord(
    accountId: accountId,
    productId: productId,
    platform: platform,
    originalTransactionId: originalTransactionId,
    transactionId: transactionId ?? this.transactionId,
    grantedAt: grantedAt,
    environment: environment,
    revokedAt: revokedAt,
    revocationReason: revocationReason,
    expiresAt: expiresAt ?? this.expiresAt,
    state: state ?? this.state,
  );

  EntitlementRecord revoke(DateTime at, String reason) => EntitlementRecord(
    accountId: accountId,
    productId: productId,
    platform: platform,
    originalTransactionId: originalTransactionId,
    transactionId: transactionId,
    grantedAt: grantedAt,
    environment: environment,
    revokedAt: at,
    revocationReason: reason,
    expiresAt: expiresAt,
    state: EntitlementState.revoked,
  );
}

/// Server konfiguratsiyasi — sir emas (sirlar store mijozlari ichida,
/// server muhitidan o‘qiladi).
@immutable
class VerificationConfig {
  const VerificationConfig({
    required this.appleBundleId,
    required this.googlePackageName,
    required this.allowedProductIds,
    this.allowSandbox = false,
    this.productTiers = const {},
  });

  final String appleBundleId;
  final String googlePackageName;
  final Set<String> allowedProductIds;

  /// Faqat staging/test serverda true.
  final bool allowSandbox;

  /// Mahsulot → tarif (`student_pro`, `professional_pro`, `institution`).
  /// Ilovadagi `ProductIds` bilan bir xil bo‘lishi shart.
  final Map<String, String> productTiers;
}

/// Akkauntning normallashtirilgan huquqi (mijozga yuboriladigan yagona
/// javob; mijoz Pro holatini o‘zi hisoblamaydi).
@immutable
class AccountEntitlement {
  const AccountEntitlement({
    required this.tier,
    required this.state,
    this.productId,
    this.expiresAt,
  });

  static const free = AccountEntitlement(
    tier: 'free',
    state: EntitlementState.active,
  );

  /// `free`, `student_pro`, `professional_pro`, `institution`.
  final String tier;
  final EntitlementState state;
  final String? productId;
  final DateTime? expiresAt;

  Map<String, Object?> toClientJson() => {
    'tier': tier,
    'entitlement_status': EntitlementStateResolver.wireName(state),
    'product_id': productId,
    'expires_at': expiresAt?.toUtc().toIso8601String(),
  };
}
