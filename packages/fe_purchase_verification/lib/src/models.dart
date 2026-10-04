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
}

/// Huquq holati — faqat server hisoblaydi; mijoz Pro holatiga ishonilmaydi.
enum EntitlementState {
  /// Amalda (Lifetime yoki muddati tugamagan obuna).
  active,

  /// Obuna bekor qilingan, lekin to‘langan muddat oxirigacha amal qiladi.
  cancelledActiveUntilExpiry,

  /// To‘lov muammosi — store imtiyozli davri.
  gracePeriod,

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
    return EntitlementState.expired;
  }

  /// Ilovada Pro funksiyalar ochiqmi.
  static bool grantsAccess(EntitlementState s) => switch (s) {
    EntitlementState.active ||
    EntitlementState.cancelledActiveUntilExpiry ||
    EntitlementState.gracePeriod => true,
    EntitlementState.expired || EntitlementState.revoked => false,
  };
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

  /// Obuna muddati (Lifetime’da `null`).
  final DateTime? expiresAt;

  bool get active => revokedAt == null;

  /// Vaqtga bog‘liq faollik (obuna muddati bilan).
  bool activeAt(DateTime now) =>
      active && (expiresAt == null || now.isBefore(expiresAt!));

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
  });

  final String appleBundleId;
  final String googlePackageName;
  final Set<String> allowedProductIds;

  /// Faqat staging/test serverda true.
  final bool allowSandbox;
}
