import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/ports/billing_ports.dart';

/// Store ulanmagan holat: faqat FREE tarif, takliflar yo‘q.
/// PHASE 9 da `RevenueCatEntitlementService` (data/remote/revenuecat/)
/// shu interfeysni amalga oshiradi.
class StoreUnavailableEntitlementService implements EntitlementService {
  const StoreUnavailableEntitlementService();

  @override
  Entitlements get current => Entitlements.free;

  @override
  Stream<Entitlements> watch() => Stream.value(Entitlements.free);

  @override
  Future<List<Offer>> offers() async => const [];

  @override
  Future<PurchaseOutcome> purchase(String productId) async =>
      PurchaseOutcome.unavailable;

  @override
  Future<Entitlements> restore() async => Entitlements.free;

  @override
  Uri get manageSubscriptionsUri => defaultTargetPlatform == TargetPlatform.iOS
      ? Uri.parse('https://apps.apple.com/account/subscriptions')
      : Uri.parse('https://play.google.com/store/account/subscriptions');
}
