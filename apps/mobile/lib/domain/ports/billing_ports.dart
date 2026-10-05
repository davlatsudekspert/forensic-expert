/// Billing abstraksiyasi — **obuna tariflari** (Free / Student Pro /
/// Professional Pro; Institution — arxitekturada, ommaga ochilmagan).
///
/// * App Store: auto-renewable subscriptions (bitta subscription group).
/// * Google Play: subscriptions (har mahsulotda bitta auto-renewing base plan).
/// * Narx, valyuta va davr **faqat store metadata’sidan** ([Offer]); UI
///   kodida narx yo‘q.
/// * Akkaunt (identifikatsiya) va huquq (xarid) — alohida tushunchalar.
/// * Huquqning yagona manbai — [Entitlements]; mijozning «men Pro» degan
///   da’vosi yoki lokal `isPro` bayrog‘i hech qachon huquq bermaydi.
/// * Forensic AI alohida ruxsat va kvotaga ega ([AiEntitlement]).
library;

import 'package:flutter/foundation.dart';

/// Tarif. Tartib muhim: yuqorirog‘i pastdagilarning imkoniyatlarini o‘z
/// ichiga oladi (institution — kelajak, shartnoma asosida).
enum PlanTier { free, studentPro, professionalPro, institution }

/// Obuna holati (server normallashtirgan; App Store / Google Play).
enum EntitlementStatus {
  active,
  expired,

  /// To‘lov muammosi — store imtiyozli davri (kirish saqlanadi).
  gracePeriod,

  /// Apple billing retry / Google account hold — kirish YO‘Q.
  billingRetry,

  /// Avtoyangilanish o‘chirilgan, to‘langan muddat oxirigacha amal qiladi.
  cancelledActiveUntilExpiry,

  /// Refund / bekor qilingan.
  revoked,

  /// Holat noma’lum (masalan, store javob bermadi) — kirish YO‘Q.
  unknown,
}

enum EntitlementSource { none, appStore, playStore, institution, promo }

/// Huquq qanday tasdiqlangan.
///
/// * [storeConfirmed] — xaridni qurilmadagi StoreKit / Google Play Billing
///   shu Apple ID / Google akkaunti uchun tasdiqladi (ilovaning lokal
///   yozuvi EMAS). Server tekshiruvi YO‘Q — production uchun yetarli emas
///   (RG-18; [FeFlags.requireServerPurchaseVerification]).
/// * [serverVerified] — backend App Store Server API / Google Play
///   Developer API orqali tekshirdi.
enum EntitlementVerification { none, storeConfirmed, serverVerified }

/// Store’dagi obuna davri — store metadata’sidan.
enum BillingPeriod { month, year, unknown }

/// Yagona huquq modeli.
@immutable
class Entitlements {
  const Entitlements({
    required this.tier,
    required this.status,
    required this.source,
    this.verification = EntitlementVerification.none,
    this.productId,
    this.purchasedAt,
    this.expiresAt,
  });

  static const free = Entitlements(
    tier: PlanTier.free,
    status: EntitlementStatus.active,
    source: EntitlementSource.none,
  );

  final PlanTier tier;
  final EntitlementStatus status;
  final EntitlementSource source;
  final EntitlementVerification verification;
  final String? productId;
  final DateTime? purchasedAt;
  final DateTime? expiresAt;

  /// Holat kirish beradimi (grace va «bekor qilingan, muddat oxirigacha»
  /// — ha; billing retry, muddati tugagan, revoked, noma’lum — yo‘q).
  static bool statusGrantsAccess(EntitlementStatus s) => switch (s) {
    EntitlementStatus.active ||
    EntitlementStatus.gracePeriod ||
    EntitlementStatus.cancelledActiveUntilExpiry => true,
    EntitlementStatus.expired ||
    EntitlementStatus.billingRetry ||
    EntitlementStatus.revoked ||
    EntitlementStatus.unknown => false,
  };

  /// Amaldagi tarif: pullik tarif faqat store/server tasdig‘i va kirish
  /// beradigan holat bilan; aks holda — Free.
  PlanTier get effectiveTier {
    if (tier == PlanTier.free) return PlanTier.free;
    if (verification == EntitlementVerification.none) return PlanTier.free;
    return statusGrantsAccess(status) ? tier : PlanTier.free;
  }

  bool includes(PlanTier required) => effectiveTier.index >= required.index;

  bool get hasStudentAccess => includes(PlanTier.studentPro);

  /// Professional Pro (yoki institution).
  bool get hasProfessionalAccess => includes(PlanTier.professionalPro);

  /// Eski nom — professional to‘liq kirish.
  bool get hasFullAccess => hasProfessionalAccess;
}

/// Store’dan kelgan taklif. Narx, valyuta va davr — store metadata’si.
@immutable
class Offer {
  const Offer({
    required this.productId,
    required this.tier,
    required this.localizedPrice,
    required this.period,
    this.currencyCode,
  });

  final String productId;
  final PlanTier tier;

  /// Store formatlagan lokal narx satri (masalan, «12 000 so‘m»).
  final String localizedPrice;
  final BillingPeriod period;
  final String? currencyCode;
}

enum PurchaseOutcome { purchased, cancelled, pending, failed, unavailable }

/// Store mahsulot ID’lari — konfiguratsiya (narx emas). Store
/// konsollarida aynan shu ID’lar yaratiladi (`docs/STORE_PRODUCT_SETUP.md`).
/// Loyiha konvensiyasi: `fe_` prefiksi, snake_case.
abstract final class ProductIds {
  static const studentMonthly = 'fe_student_pro_monthly';
  static const studentYearly = 'fe_student_pro_yearly';
  static const professionalMonthly = 'fe_professional_pro_monthly';
  static const professionalYearly = 'fe_professional_pro_yearly';

  /// Ommaga taklif qilinadigan obunalar (Institution — yo‘q).
  static const all = [
    studentMonthly,
    studentYearly,
    professionalMonthly,
    professionalYearly,
  ];

  /// Mahsulot → tarif. Noma’lum mahsulot — `null` (huquq bermaydi).
  static PlanTier? tierOf(String productId) => switch (productId) {
    studentMonthly || studentYearly => PlanTier.studentPro,
    professionalMonthly || professionalYearly => PlanTier.professionalPro,
    _ => null,
  };

  /// Konfiguratsiyadagi kutilgan davr (store metadata bo‘lmaganda emas —
  /// faqat tartiblash uchun; UI davrni store’dan oladi).
  static BillingPeriod expectedPeriodOf(String productId) =>
      productId.endsWith('_yearly')
      ? BillingPeriod.year
      : productId.endsWith('_monthly')
      ? BillingPeriod.month
      : BillingPeriod.unknown;
}

// ---------------------------------------------------------------------------
// Xaridni server tomonida tekshirish (arxitektura; backend — RG-18).
// ---------------------------------------------------------------------------

/// Store’dan kelgan xarid dalili (backend’ga yuboriladi).
@immutable
class PurchaseEvidence {
  const PurchaseEvidence({
    required this.productId,
    required this.platform,
    required this.serverVerificationData,
    this.purchaseId,
  });

  final String productId;
  final EntitlementSource platform;

  /// iOS: StoreKit 2 JWS / tranzaksiya JSON; Android: purchase token.
  final String serverVerificationData;
  final String? purchaseId;
}

enum VerificationStatus {
  /// Backend tasdiqladi (holat va muddat [PurchaseVerification] da).
  verified,

  /// Backend rad etdi (soxta, qaytarilgan, boshqa ilova) — huquq YO‘Q.
  rejected,

  /// Backend sozlanmagan (hozirgi holat) — RELEASE BLOCKER RG-18.
  serverNotConfigured,

  /// Tarmoq yo‘q — offline foydalanuvchi uchun vaqtinchalik qaror.
  networkError,
}

/// Backend javobi — normallashtirilgan huquq holati bilan.
@immutable
class PurchaseVerification {
  const PurchaseVerification(
    this.status, {
    this.entitlementStatus,
    this.expiresAt,
  });

  static const notConfigured = PurchaseVerification(
    VerificationStatus.serverNotConfigured,
  );
  static const rejected = PurchaseVerification(VerificationStatus.rejected);
  static const networkError = PurchaseVerification(
    VerificationStatus.networkError,
  );

  final VerificationStatus status;

  /// Faqat [VerificationStatus.verified] da (server hisoblagan holat).
  final EntitlementStatus? entitlementStatus;
  final DateTime? expiresAt;
}

abstract interface class PurchaseVerifier {
  Future<PurchaseVerification> verify(PurchaseEvidence evidence);
}

/// Backend yo‘q. Hech qachon «verified» qaytarmaydi.
class UnconfiguredPurchaseVerifier implements PurchaseVerifier {
  const UnconfiguredPurchaseVerifier();

  @override
  Future<PurchaseVerification> verify(PurchaseEvidence evidence) async =>
      PurchaseVerification.notConfigured;
}

abstract interface class EntitlementService {
  Stream<Entitlements> watch();

  Entitlements get current;

  /// Store mavjud bo‘lsa — obuna takliflari (narx/davr store’dan).
  Future<List<Offer>> offers();

  Future<PurchaseOutcome> purchase(String productId);

  /// Apple 3.1.1 «restore mechanism»; Google Play’da ham ko‘rsatiladi.
  Future<Entitlements> restore();
}

// ---------------------------------------------------------------------------
// Imkoniyatlar va tarif chegarasi (yagona joy — FeatureGate).
// ---------------------------------------------------------------------------

/// Mahsulot imkoniyatlari (gating birligi).
enum ProductFeature {
  globalSearch,
  forensicMedicine,
  forensicToxicology,
  laboratoryTools,
  substanceLibrary,
  reagentsAndSolutions,
  analyticalMethods,
  expressTests,
  biochemistry,
  professionalCalculators,
  learn,
  quizzesAndFlashcards,
  researchAndEvidence,
  professionalAi,
  offlineDatabase,
  internationalStandards,
  jurisdictionLayers,
  verifiedReferences,

  /// Hech qachon pullik devor ortida emas: disclaimer, ogohlantirishlar,
  /// cheklovlar, manbalar/provenance tizimi.
  safetyAndProvenance,
}

enum FeatureAccess {
  /// To‘liq ochiq.
  full,

  /// Bepul demo: mahsulot sifatini baholash uchun yetarli qism.
  demo,
}

/// Har imkoniyat uchun to‘liq kirish talab qiladigan eng past tarif.
/// Bepul foydalanuvchi pastroq tarifda [FeatureAccess.demo] oladi.
abstract final class FeatureGate {
  static PlanTier minimumTier(ProductFeature f) => switch (f) {
    // Xavfsizlik va provenance — hamma uchun to‘liq.
    ProductFeature.safetyAndProvenance ||
    ProductFeature.offlineDatabase => PlanTier.free,
    // Ta’lim va ma’lumotnoma o‘qish — Student Pro.
    ProductFeature.learn ||
    ProductFeature.quizzesAndFlashcards ||
    ProductFeature.globalSearch ||
    ProductFeature.forensicMedicine ||
    ProductFeature.forensicToxicology ||
    ProductFeature.substanceLibrary ||
    ProductFeature.reagentsAndSolutions ||
    ProductFeature.expressTests ||
    ProductFeature.biochemistry ||
    ProductFeature.internationalStandards ||
    ProductFeature.jurisdictionLayers ||
    ProductFeature.verifiedReferences => PlanTier.studentPro,
    // Professional ish vositalari — Professional Pro.
    ProductFeature.laboratoryTools ||
    ProductFeature.professionalCalculators ||
    ProductFeature.analyticalMethods ||
    ProductFeature.researchAndEvidence ||
    ProductFeature.professionalAi => PlanTier.professionalPro,
  };

  static bool unlocks(ProductFeature f, Entitlements e) =>
      e.includes(minimumTier(f));
}

abstract final class AccessPolicy {
  /// Bepul demoda doim ochiq vositalar (katalog ID’lari).
  static const freeToolIds = {
    'tool.lab.dilution',
    'tool.conv.concentration_units',
  };

  /// Bepul demoda kutubxonadan nechta yozuv to‘liq ochiq (har bo‘limda).
  static const freeEntriesPerSection = 3;

  /// Bepul demoda nechta o‘quv kursi ochiq.
  static const freeCourses = 1;

  /// Global search: bepul demoda har guruhda ko‘rsatiladigan natijalar.
  static const freeSearchResultsPerGroup = 3;

  static FeatureAccess accessFor(ProductFeature f, Entitlements e) =>
      FeatureGate.unlocks(f, e) ? FeatureAccess.full : FeatureAccess.demo;

  static bool unlocks(ProductFeature f, Entitlements e) =>
      FeatureGate.unlocks(f, e);

  static bool isToolUnlocked(String toolId, Entitlements e) =>
      FeatureGate.unlocks(ProductFeature.professionalCalculators, e) ||
      freeToolIds.contains(toolId);
}

// ---------------------------------------------------------------------------
// Forensic AI — alohida ruxsat va kvota (tarifga «cheksiz» kirmaydi).
// ---------------------------------------------------------------------------

enum AiPlan {
  /// AI ulanmagan (PHASE 2 holati).
  none,

  /// Kelajak: Professional Pro egalariga ma’lum kvota.
  includedQuota,

  /// Kelajak: qo‘shimcha AI paketi.
  aiPackage,
}

@immutable
class AiEntitlement {
  const AiEntitlement({
    required this.plan,
    this.monthlyQuestionLimit,
    this.usedThisPeriod = 0,
  });

  static const none = AiEntitlement(plan: AiPlan.none);

  final AiPlan plan;

  /// `null` faqat [AiPlan.none] da (cheklov tushunchasi yo‘q). AI hech
  /// qachon «cheksiz» deb modellashtirilmaydi.
  final int? monthlyQuestionLimit;
  final int usedThisPeriod;

  bool get canAsk =>
      plan != AiPlan.none &&
      monthlyQuestionLimit != null &&
      usedThisPeriod < monthlyQuestionLimit!;
}

/// AI kvotasi manbai (kelajakda backend). PHASE 2 da real AI billing yo‘q.
abstract interface class AiEntitlementService {
  Future<AiEntitlement> current();
}
