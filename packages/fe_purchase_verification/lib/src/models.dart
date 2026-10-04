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
}

enum VerificationOutcome {
  verified,
  invalidCredential,
  productNotAllowed,
  wrongApp,
  sandboxNotAllowed,
  notPurchased,
  revoked,

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

  bool get active => revokedAt == null;

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
