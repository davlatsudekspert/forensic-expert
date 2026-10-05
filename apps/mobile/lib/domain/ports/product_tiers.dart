import 'package:flutter/foundation.dart';

import 'billing_ports.dart';

/// Tariflar katalogi. **Narx kodda yo‘q** — narx, valyuta va davr faqat
/// store’dan ([Offer]). Institution arxitekturada bor, lekin ommaga
/// ko‘rsatilmaydi (shartnoma asosida; store mahsuloti yo‘q).
@immutable
class TierDefinition {
  const TierDefinition({
    required this.tier,
    required this.publiclyOffered,
    this.storeProductIds = const [],
  });

  final PlanTier tier;

  /// Paywall’da ko‘rsatiladimi.
  final bool publiclyOffered;

  /// Store’da yaratilishi kerak bo‘lgan obuna ID’lari.
  final List<String> storeProductIds;
}

abstract final class ProductTiers {
  static const all = [
    TierDefinition(tier: PlanTier.free, publiclyOffered: true),
    TierDefinition(
      tier: PlanTier.studentPro,
      publiclyOffered: true,
      storeProductIds: [ProductIds.studentMonthly, ProductIds.studentYearly],
    ),
    TierDefinition(
      tier: PlanTier.professionalPro,
      publiclyOffered: true,
      storeProductIds: [
        ProductIds.professionalMonthly,
        ProductIds.professionalYearly,
      ],
    ),
    TierDefinition(tier: PlanTier.institution, publiclyOffered: false),
  ];

  static List<TierDefinition> get publicTiers => [
    for (final t in all)
      if (t.publiclyOffered) t,
  ];

  /// Joriy huquqlardan amaldagi tarif (taxmin yo‘q).
  static PlanTier tierOf(Entitlements e) => e.effectiveTier;

  /// Xarid qilinadigan store mahsulotlari.
  static List<String> get purchasableProductIds => [
    for (final t in all)
      if (t.publiclyOffered) ...t.storeProductIds,
  ];
}
