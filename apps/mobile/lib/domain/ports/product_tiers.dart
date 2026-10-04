import 'package:flutter/foundation.dart';

import 'billing_ports.dart';

/// Mahsulot darajalari arxitekturasi (PHASE 6). **Narx kodda yo‘q** — narx
/// faqat store’dan keladi; rejalashtirilgan darajalarda store mahsuloti
/// hali yaratilmagan (RG-16) va xarid faollashtirilmaydi.
enum ProductTier {
  free,

  /// Talaba / rezident (kelajak; store mahsuloti yo‘q).
  studentPro,

  /// Professional — hozirgi bir martalik «FORENSIC EXPERT Lifetime».
  professionalPro,

  /// Universitet / muassasa litsenziyasi (kelajak; shartnoma asosida).
  institution,
}

enum TierAvailability { active, planned }

@immutable
class TierDefinition {
  const TierDefinition({
    required this.tier,
    required this.availability,
    this.storeProductId,
  });

  final ProductTier tier;
  final TierAvailability availability;

  /// Faqat store’da haqiqatan yaratilgan mahsulot uchun.
  final String? storeProductId;
}

abstract final class ProductTiers {
  static const all = [
    TierDefinition(
      tier: ProductTier.free,
      availability: TierAvailability.active,
    ),
    TierDefinition(
      tier: ProductTier.studentPro,
      availability: TierAvailability.planned,
    ),
    TierDefinition(
      tier: ProductTier.professionalPro,
      availability: TierAvailability.active,
      storeProductId: ProductIds.lifetime,
    ),
    TierDefinition(
      tier: ProductTier.institution,
      availability: TierAvailability.planned,
    ),
  ];

  /// Joriy huquqlardan daraja (taxmin yo‘q: noma’lum — free).
  static ProductTier tierOf(Entitlements e) => switch (e.access) {
    AccessLevel.institution => ProductTier.institution,
    AccessLevel.lifetime => ProductTier.professionalPro,
    AccessLevel.free => ProductTier.free,
  };

  /// Xarid qilinadigan (store’da mavjud) mahsulotlar.
  static List<String> get purchasableProductIds => [
    for (final t in all)
      if (t.availability == TierAvailability.active && t.storeProductId != null)
        t.storeProductId!,
  ];
}
