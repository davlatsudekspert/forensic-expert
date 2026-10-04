import 'models.dart';

/// Store tekshiruvchi xato turlari.
class StoreVerifierException implements Exception {
  const StoreVerifierException(this.kind, [this.message = '']);

  /// `invalid` — store xaridni tanimadi; `unavailable` — tarmoq/5xx/kvota.
  final String kind;
  final String message;

  @override
  String toString() => 'StoreVerifierException($kind: $message)';
}

/// Bitta platforma uchun tekshiruvchi.
///
/// Production implementatsiyalari (bu repozitoriyda YO‘Q — kalit kerak):
/// * **Apple** — App Store Server API `GET /inApps/v1/transactions/{id}`
///   (ES256 JWT: Issuer ID, Key ID, `.p8` kalit — faqat server muhitida).
///   Javobdagi `signedTransactionInfo` JWS’ining x5c zanjiri Apple Root CA
///   G3 ga qadar tekshiriladi ([JwsChainVerifier]).
/// * **Google** — Play Developer API `purchases.products.get`
///   (service account, `androidpublisher` scope); `purchaseState`,
///   `acknowledgementState`; so‘ng `purchases.products.acknowledge`.
abstract interface class StoreVerifier {
  StorePlatform get platform;

  /// Store’ning o‘zidan xarid ma’lumoti. Topilmasa —
  /// `StoreVerifierException('invalid')`; vaqtincha xato —
  /// `StoreVerifierException('unavailable')`.
  Future<StoreTransaction> fetch(String purchaseCredential, String productId);

  /// Google: xaridni tasdiqlash (acknowledge). Apple’da no-op.
  Future<void> acknowledge(StoreTransaction t);
}

/// JWS (Apple signed payload) imzosi va sertifikat zanjirini tekshirish.
/// Production: x5c zanjiri → Apple Root CA G3 (pinned), ES256 imzo, muddat.
abstract interface class JwsChainVerifier {
  /// Tekshirilgan payload (JSON) yoki xato.
  Map<String, Object?> verify(String jws);
}

/// Server huquqlar ombori (haqiqat manbai). Production: tranzaksion DB.
abstract interface class EntitlementStore {
  Future<EntitlementRecord?> byOriginalTransaction(
    StorePlatform platform,
    String originalTransactionId,
  );

  Future<List<EntitlementRecord>> forAccount(String accountId);

  /// Atomik: (platform, originalTransactionId) noyob. Allaqachon boshqa
  /// akkauntga bog‘langan bo‘lsa — false.
  Future<bool> insertIfAbsent(EntitlementRecord r);

  Future<void> update(EntitlementRecord r);

  /// Idempotentlik: kalit → oldingi natija.
  Future<VerificationResult?> idempotent(String key);
  Future<void> rememberIdempotent(String key, VerificationResult r);
}

/// Server vaqti (test uchun almashtiriladi).
typedef Clock = DateTime Function();
