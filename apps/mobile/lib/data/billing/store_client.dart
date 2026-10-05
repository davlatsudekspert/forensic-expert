/// Store’ga bog‘liq bo‘lmagan, test qilinadigan ingichka port.
///
/// Haqiqiy implementatsiya — [InAppPurchaseStoreClient] (StoreKit / Play
/// Billing, `in_app_purchase` plagini orqali). Domen qatlamiga plagin
/// turlari chiqmaydi.
library;

enum StoreEventStatus { pending, purchased, restored, error, canceled }

class StoreEvent {
  const StoreEvent({
    required this.productId,
    required this.status,
    this.pendingCompletion = false,
    this.handle,
    this.purchaseId,
    this.serverVerificationData,
    this.expiresAt,
  });

  final String productId;
  final StoreEventStatus status;

  /// Store tranzaksiyani yakunlashni kutyaptimi (`completePurchase`).
  final bool pendingCompletion;

  /// Plagin obyekti (faqat adapter ichida ishlatiladi).
  final Object? handle;
  final String? purchaseId;

  /// Server tekshiruvi uchun dalil (Android purchase token / iOS JWS).
  final String? serverVerificationData;

  /// Store bergan obuna muddati (iOS StoreKit 2 tranzaksiyasi). Android
  /// mijoz API’si muddatni bermaydi — faqat faol obunalarni qaytaradi.
  final DateTime? expiresAt;
}

/// Store metadata’si (narx, valyuta, davr — store’ning o‘zidan).
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.price,
    this.currencyCode,
    this.billingPeriod,
  });

  final String id;

  /// Store formatlagan lokal narx satri.
  final String price;
  final String? currencyCode;

  /// ISO 8601 davr (`P1M`, `P1Y`) — App Store `subscriptionPeriod` yoki
  /// Google Play base plan `billingPeriod`. Noma’lum bo‘lsa `null`.
  final String? billingPeriod;
}

abstract interface class StoreClient {
  Future<bool> isAvailable();

  /// So‘ralgan mahsulotlarning store metadata’si (topilmaganlari yo‘q).
  Future<List<StoreProduct>> queryProducts(Set<String> productIds);

  /// Auto-renewable subscription (App Store) / subscription (Google Play).
  /// Xarid natijasi [events] orqali keladi.
  Future<bool> buySubscription(String productId);

  Future<void> restore();

  /// Store’ning o‘zidan (jim, UI’siz) shu akkaunt egalik qiladigan
  /// xaridlar: Android `queryPurchases`, iOS StoreKit 2 `Transaction.all`.
  /// Ilovaning lokal yozuvlariga tayanmaydi.
  Future<List<StoreEvent>> ownedPurchases();

  Stream<List<StoreEvent>> get events;

  Future<void> complete(StoreEvent event);
}
