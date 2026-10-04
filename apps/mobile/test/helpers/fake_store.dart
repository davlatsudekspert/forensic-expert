import 'package:forensic_expert/domain/ports/billing_ports.dart';

/// TEST: store adapteri o‘rnida (narx — ma’nosiz TEST qiymat).
class FakeStore implements EntitlementService {
  FakeStore({this.price = 'TEST-PRICE 1.00', this.owned = false});

  final String price;
  bool owned;
  final purchased = <String>[];

  @override
  Entitlements get current => owned
      ? const Entitlements(
          access: AccessLevel.lifetime,
          source: EntitlementSource.appStore,
        )
      : Entitlements.free;

  @override
  Stream<Entitlements> watch() => Stream.value(current);

  @override
  Future<List<Offer>> offers() async => [
    Offer(
      productId: ProductIds.lifetime,
      type: StoreProductType.lifetimeUnlock,
      localizedPrice: price,
    ),
  ];

  @override
  Future<PurchaseOutcome> purchase(String productId) async {
    purchased.add(productId);
    return PurchaseOutcome.cancelled;
  }

  @override
  Future<Entitlements> restore() async => current;
}
