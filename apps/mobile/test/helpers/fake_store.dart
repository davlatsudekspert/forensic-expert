import 'package:forensic_expert/domain/ports/billing_ports.dart';

/// TEST: store adapteri o‘rnida (narx — ma’nosiz TEST qiymat; haqiqiy
/// narx faqat store’dan).
class FakeStore implements EntitlementService {
  FakeStore({
    this.price = 'TEST-PRICE 1.00',
    bool owned = false,
    PlanTier? tier,
    this.status = EntitlementStatus.active,
    this.restoreResult,
    this.withOffers = true,
    this.outcome = PurchaseOutcome.cancelled,
  }) : tier = tier ?? (owned ? PlanTier.professionalPro : PlanTier.free);

  final String price;
  PlanTier tier;
  EntitlementStatus status;
  final Entitlements? restoreResult;
  final bool withOffers;
  final PurchaseOutcome outcome;
  final purchased = <String>[];
  var restoreCalls = 0;

  bool get owned => tier != PlanTier.free;
  set owned(bool v) => tier = v ? PlanTier.professionalPro : PlanTier.free;

  @override
  Entitlements get current => tier == PlanTier.free
      ? Entitlements.free
      : Entitlements(
          tier: tier,
          status: status,
          source: EntitlementSource.appStore,
          verification: EntitlementVerification.storeConfirmed,
          productId: tier == PlanTier.studentPro
              ? ProductIds.studentMonthly
              : ProductIds.professionalMonthly,
          expiresAt: DateTime.utc(2026, 11, 5),
        );

  @override
  Stream<Entitlements> watch() => Stream.value(current);

  @override
  Future<List<Offer>> offers() async => withOffers
      ? [
          for (final id in ProductIds.all)
            Offer(
              productId: id,
              tier: ProductIds.tierOf(id)!,
              localizedPrice: price,
              period: ProductIds.expectedPeriodOf(id),
              currencyCode: 'TST',
            ),
        ]
      : const [];

  @override
  Future<PurchaseOutcome> purchase(String productId) async {
    purchased.add(productId);
    return outcome;
  }

  @override
  Future<Entitlements> restore() async {
    restoreCalls++;
    return restoreResult ?? current;
  }
}
