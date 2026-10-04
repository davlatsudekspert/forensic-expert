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
}

abstract interface class StoreClient {
  Future<bool> isAvailable();

  /// productId → store formatlagan lokal narx.
  Future<Map<String, String>> localizedPrices(Set<String> productIds);

  /// Non-Consumable (App Store) / one-time product (Google Play).
  Future<bool> buyNonConsumable(String productId);

  Future<void> restore();

  /// Store’ning o‘zidan (jim, UI’siz) shu akkaunt egalik qiladigan
  /// xaridlar: Android `queryPurchases`, iOS StoreKit 2 `Transaction.all`.
  /// Ilovaning lokal yozuvlariga tayanmaydi.
  Future<List<StoreEvent>> ownedPurchases();

  Stream<List<StoreEvent>> get events;

  Future<void> complete(StoreEvent event);
}
