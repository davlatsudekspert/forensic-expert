/// Billing abstraksiyasi (`docs/00_ARXITEKTURA_REJASI.md`, 26-bo‘lim).
///
/// * Haqiqat manbai — Apple StoreKit va Google Play Billing.
/// * RevenueCat — afzal adapter (PHASE 9), lekin uning turlari domen
///   qatlamiga chiqmaydi. Undan voz kechilsa, faqat adapter almashtiriladi.
/// * Narxlar **hech qachon** kodda yo‘q — [Offer.localizedPrice] store’dan.
library;

import 'package:flutter/foundation.dart';

enum PlanTier { free, studentPro, professionalPro, institution }

enum EntitlementSource { none, appStore, playStore, institution, promo }

@immutable
class Entitlements {
  const Entitlements({
    required this.tier,
    required this.source,
    this.expiresAt,
    this.inGracePeriod = false,
  });

  static const free = Entitlements(
    tier: PlanTier.free,
    source: EntitlementSource.none,
  );

  final PlanTier tier;
  final EntitlementSource source;
  final DateTime? expiresAt;
  final bool inGracePeriod;

  bool get hasStudentFeatures =>
      tier == PlanTier.studentPro ||
      tier == PlanTier.professionalPro ||
      tier == PlanTier.institution;

  bool get hasProfessionalFeatures =>
      tier == PlanTier.professionalPro || tier == PlanTier.institution;
}

enum BillingPeriod { monthly, annual }

/// Store’dan kelgan taklif. Narx — store formatlagan lokal satr.
@immutable
class Offer {
  const Offer({
    required this.productId,
    required this.tier,
    required this.period,
    required this.localizedPrice,
    this.hasIntroductoryTrial = false,
  });

  final String productId;
  final PlanTier tier;
  final BillingPeriod period;
  final String localizedPrice;
  final bool hasIntroductoryTrial;
}

enum PurchaseOutcome { purchased, cancelled, pending, failed, unavailable }

/// Store’dagi mahsulot ID’lari (narx emas). Store konsollarida aynan
/// shu ID’lar yaratiladi — adapterdan mustaqil.
abstract final class ProductIds {
  static const studentMonthly = 'fe_student_pro_monthly';
  static const studentAnnual = 'fe_student_pro_annual';
  static const professionalMonthly = 'fe_professional_pro_monthly';
  static const professionalAnnual = 'fe_professional_pro_annual';

  static const all = [
    studentMonthly,
    studentAnnual,
    professionalMonthly,
    professionalAnnual,
  ];
}

abstract interface class EntitlementService {
  Stream<Entitlements> watch();

  Entitlements get current;

  Future<List<Offer>> offers();

  Future<PurchaseOutcome> purchase(String productId);

  /// Apple 3.1.1 «restore mechanism»; Google Play’da ham ko‘rsatiladi.
  Future<Entitlements> restore();

  /// Platformaning obunani boshqarish sahifasi.
  Uri get manageSubscriptionsUri;
}
