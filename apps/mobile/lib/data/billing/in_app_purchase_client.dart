import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';

import 'store_client.dart';

/// `in_app_purchase` (StoreKit 2 / Google Play Billing) adapteri.
class InAppPurchaseStoreClient implements StoreClient {
  InAppPurchaseStoreClient([InAppPurchase? iap])
    : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;
  final _details = <String, ProductDetails>{};

  @override
  Future<bool> isAvailable() async {
    try {
      return await _iap.isAvailable();
    } on Object {
      return false;
    }
  }

  @override
  Future<Map<String, String>> localizedPrices(Set<String> productIds) async {
    final r = await _iap.queryProductDetails(productIds);
    for (final d in r.productDetails) {
      _details[d.id] = d;
    }
    return {for (final d in r.productDetails) d.id: d.price};
  }

  @override
  Future<bool> buyNonConsumable(String productId) async {
    var d = _details[productId];
    if (d == null) {
      await localizedPrices({productId});
      d = _details[productId];
    }
    if (d == null) return false;
    return _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: d),
    );
  }

  @override
  Future<void> restore() => _iap.restorePurchases();

  @override
  Future<List<StoreEvent>> ownedPurchases() async {
    if (Platform.isAndroid) {
      final r = await _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
          .queryPastPurchases();
      return [for (final p in r.pastPurchases) _event(p)];
    }
    if (Platform.isIOS) {
      final txs = await SK2Transaction.transactions();
      return [
        for (final t in txs)
          StoreEvent(
            productId: t.productId,
            status: StoreEventStatus.restored,
            purchaseId: t.id,
            serverVerificationData: t.jsonRepresentation,
          ),
      ];
    }
    return const [];
  }

  @override
  Stream<List<StoreEvent>> get events =>
      _iap.purchaseStream.map((list) => [for (final p in list) _event(p)]);

  static StoreEvent _event(PurchaseDetails p) => StoreEvent(
    productId: p.productID,
    status: switch (p.status) {
      PurchaseStatus.pending => StoreEventStatus.pending,
      PurchaseStatus.purchased => StoreEventStatus.purchased,
      PurchaseStatus.restored => StoreEventStatus.restored,
      PurchaseStatus.error => StoreEventStatus.error,
      PurchaseStatus.canceled => StoreEventStatus.canceled,
    },
    pendingCompletion: p.pendingCompletePurchase,
    handle: p,
    purchaseId: p.purchaseID,
    serverVerificationData: p.verificationData.serverVerificationData,
  );

  @override
  Future<void> complete(StoreEvent event) async {
    final h = event.handle;
    if (h is PurchaseDetails) await _iap.completePurchase(h);
  }
}
