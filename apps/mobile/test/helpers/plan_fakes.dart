import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:forensic_expert/app/plan.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

/// Testda aniq huquq (server chaqirilmaydi).
class FixedEntitlements extends EntitlementsNotifier {
  FixedEntitlements(this.value);

  final Entitlements value;

  @override
  Future<Entitlements> build() async => value;
}

/// Faol [plan] (admin bergan, 30 kun) — `null` bo‘lsa bepul.
Entitlements activeEntitlements(
  Plan? plan, {
  PlanSource source = PlanSource.admin,
  Duration left = const Duration(days: 30),
}) => plan == null
    ? Entitlements.none
    : Entitlements(
        plan: plan,
        source: source,
        expiresAt: DateTime.now().add(left),
      );

/// Gate sinovlari uchun: `entitlementsProvider` ni qat’iy qiymatga o‘rnatadi.
List<Override> planOverrides(Plan? plan, {PlanSource? source}) => [
  entitlementsProvider.overrideWith(
    () => FixedEntitlements(
      activeEntitlements(plan, source: source ?? PlanSource.admin),
    ),
  ),
];
