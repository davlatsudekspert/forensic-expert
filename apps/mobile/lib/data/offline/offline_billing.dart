import 'dart:async';

import '../../domain/ports/billing_ports.dart';

/// Store ulanmagan holat: faqat bepul demo, takliflar yo‘q.
/// Keyinroq store adapteri (StoreKit Non-Consumable / Play one-time
/// product, yoki RevenueCat) shu interfeysni amalga oshiradi.
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
}

/// PHASE 2: Forensic AI ulanmagan — kvota yo‘q, billing yo‘q.
class NoAiEntitlementService implements AiEntitlementService {
  const NoAiEntitlementService();

  @override
  Future<AiEntitlement> current() async => AiEntitlement.none;
}
