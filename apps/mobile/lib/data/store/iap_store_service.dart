import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../domain/plan/plan_models.dart';
import '../../domain/ports/plan_ports.dart';

/// `in_app_purchase` (StoreKit 2 / Google Play Billing) adapteri. Narx va
/// nom faqat do‘kondan olinadi. Xarid holati ilovada saqlanmaydi — har
/// tranzaksiya serverda tekshiriladi (`verify-purchase`), keyin yopiladi.
class IapStoreService implements StoreService {
  IapStoreService({InAppPurchase? iap}) : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;
  final _controller = StreamController<StorePurchase>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final _details = <String, ProductDetails>{};

  void _listen() {
    _sub ??= _iap.purchaseStream.listen(
      (list) {
        for (final d in list) {
          _controller.add(_map(d));
        }
      },
      onError: (Object _) => _controller.add(
        const StorePurchase(productId: '', status: StorePurchaseStatus.error),
      ),
    );
  }

  StorePurchase _map(PurchaseDetails d) {
    final status = switch (d.status) {
      PurchaseStatus.purchased => StorePurchaseStatus.purchased,
      PurchaseStatus.restored => StorePurchaseStatus.restored,
      PurchaseStatus.pending => StorePurchaseStatus.pending,
      PurchaseStatus.canceled => StorePurchaseStatus.canceled,
      PurchaseStatus.error => StorePurchaseStatus.error,
    };
    return StorePurchase(
      productId: d.productID,
      status: status,
      proof: d.verificationData.serverVerificationData,
      transactionId: d.purchaseID,
      handle: d,
    );
  }

  @override
  Future<bool> isAvailable() async {
    if (kIsWeb || !(Platform.isIOS || Platform.isAndroid)) return false;
    try {
      final ok = await _iap.isAvailable();
      if (ok) _listen();
      return ok;
    } on Object {
      return false;
    }
  }

  @override
  Future<List<StoreProduct>> products(Set<String> ids) async {
    if (!await isAvailable()) return const [];
    try {
      final r = await _iap.queryProductDetails(ids);
      final out = <StoreProduct>[];
      for (final p in r.productDetails) {
        final plan = PlanProducts.planOf(p.id);
        final period = PlanProducts.periodOf(p.id);
        if (plan == null || period == null) continue;
        _details[p.id] = p;
        out.add(
          StoreProduct(
            id: p.id,
            plan: plan,
            period: period,
            title: p.title,
            price: p.price,
          ),
        );
      }
      return out;
    } on Object {
      return const [];
    }
  }

  @override
  Future<bool> buy(StoreProduct product) async {
    final d = _details[product.id];
    if (d == null || !await isAvailable()) return false;
    try {
      return await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: d),
      );
    } on Object {
      return false;
    }
  }

  @override
  Future<void> restore() async {
    if (!await isAvailable()) return;
    try {
      await _iap.restorePurchases();
    } on Object {
      // Natija oqim orqali keladi; xato — foydalanuvchiga holat matni.
    }
  }

  @override
  Stream<StorePurchase> get purchaseStream => _controller.stream;

  @override
  Future<void> complete(StorePurchase purchase) async {
    final h = purchase.handle;
    if (h is PurchaseDetails && h.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(h);
      } on Object {
        // Keyingi ishga tushishda oqim qayta yuboradi.
      }
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}
