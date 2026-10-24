import 'dart:async';

import '../../domain/plan/plan_models.dart';
import '../../domain/ports/plan_ports.dart';

/// Test/demo do‘koni: haqiqiy to‘lov yo‘q. [available] `false` bo‘lsa —
/// do‘kon ulanmagan holat.
class FakeStoreService implements StoreService {
  FakeStoreService({this.available = true, List<StoreProduct>? catalog})
    : _catalog = catalog ?? sampleProducts();

  final bool available;
  final List<StoreProduct> _catalog;
  final _controller = StreamController<StorePurchase>.broadcast();

  /// Chaqiruvlar jurnali (testlar uchun).
  final calls = <String>[];
  final completed = <StorePurchase>[];

  /// TEST narxlari (haqiqiy narx emas; narx do‘kondan keladi).
  static List<StoreProduct> sampleProducts() => [
    for (final plan in Plan.values)
      for (final period in PlanPeriod.values)
        StoreProduct(
          id: PlanProducts.idFor(plan, period),
          plan: plan,
          period: period,
          title: 'TEST ${plan.name} ${period.name}',
          price: period == PlanPeriod.monthly ? '\$0.00 m' : '\$0.00 y',
        ),
  ];

  /// Testda do‘kon hodisasini yuborish.
  void emit(StorePurchase p) => _controller.add(p);

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<List<StoreProduct>> products(Set<String> ids) async => available
      ? [
          for (final p in _catalog)
            if (ids.contains(p.id)) p,
        ]
      : const [];

  @override
  Future<bool> buy(StoreProduct product) async {
    calls.add('buy:${product.id}');
    return available;
  }

  @override
  Future<void> restore() async {
    calls.add('restore');
  }

  @override
  Stream<StorePurchase> get purchaseStream => _controller.stream;

  @override
  Future<void> complete(StorePurchase purchase) async {
    completed.add(purchase);
  }
}
