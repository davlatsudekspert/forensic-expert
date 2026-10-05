import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

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
  Future<List<StoreProduct>> queryProducts(Set<String> productIds) async {
    final r = await _iap.queryProductDetails(productIds);
    final out = <String, StoreProduct>{};
    for (final d in r.productDetails) {
      // Google Play: har base plan / offer alohida ProductDetails bo‘lib
      // keladi — birinchi (asosiy) yozuv saqlanadi.
      _details.putIfAbsent(d.id, () => d);
      out.putIfAbsent(
        d.id,
        () => StoreProduct(
          id: d.id,
          price: d.price,
          currencyCode: d.currencyCode,
          billingPeriod: _period(d),
        ),
      );
    }
    return out.values.toList();
  }

  /// ISO 8601 davr store metadata’sidan.
  static String? _period(ProductDetails d) {
    if (d is GooglePlayProductDetails) {
      final offers = d.productDetails.subscriptionOfferDetails;
      final i = d.subscriptionIndex;
      if (offers == null || i == null || i >= offers.length) return null;
      final phases = offers[i].pricingPhases;
      return phases.isEmpty ? null : phases.last.billingPeriod;
    }
    if (d is AppStoreProduct2Details) {
      final p = d.sk2Product.subscription?.subscriptionPeriod;
      if (p == null) return null;
      return switch (p.unit) {
        SK2SubscriptionPeriodUnit.day => 'P${p.value}D',
        SK2SubscriptionPeriodUnit.week => 'P${p.value}W',
        SK2SubscriptionPeriodUnit.month => 'P${p.value}M',
        SK2SubscriptionPeriodUnit.year => 'P${p.value}Y',
      };
    }
    if (d is AppStoreProductDetails) {
      final p = d.skProduct.subscriptionPeriod;
      if (p == null || p.numberOfUnits == 0) return null;
      return switch (p.unit) {
        SKSubscriptionPeriodUnit.day => 'P${p.numberOfUnits}D',
        SKSubscriptionPeriodUnit.week => 'P${p.numberOfUnits}W',
        SKSubscriptionPeriodUnit.month => 'P${p.numberOfUnits}M',
        SKSubscriptionPeriodUnit.year => 'P${p.numberOfUnits}Y',
      };
    }
    return null;
  }

  @override
  Future<bool> buySubscription(String productId) async {
    var d = _details[productId];
    if (d == null) {
      await queryProducts({productId});
      d = _details[productId];
    }
    if (d == null) return false;
    // in_app_purchase’da obunalar ham buyNonConsumable orqali boshlanadi.
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
            expiresAt: _epochMs(t.expirationDate),
          ),
      ];
    }
    return const [];
  }

  static DateTime? _epochMs(String? ms) {
    final v = ms == null ? null : int.tryParse(ms);
    return v == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
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
