/// Billing abstraksiyasi — **FORENSIC EXPERT Lifetime** modeli.
///
/// Mahsulot qarori (PHASE 2, egasi): asosiy monetizatsiya — bitta
/// **bir martalik xarid** (lifetime unlock), obuna emas.
///
/// * App Store: `Non-Consumable In-App Purchase`.
/// * Google Play: `one-time product` (in-app product, iste’mol qilinmaydi).
/// * Haqiqat manbai — Apple StoreKit va Google Play Billing (RevenueCat —
///   ixtiyoriy adapter, turlari domen qatlamiga chiqmaydi).
/// * Narx **UI kodida yo‘q**. Production’da [Offer.localizedPrice] —
///   storefront qaytargan lokal narx. [BillingConfig.referenceLifetimePrice]
///   faqat mahsulot/dizayn maqsadi (mock / reference) va store ulanmaganda
///   «reference price» deb aniq belgilangan holda ko‘rsatiladi.
/// * Forensic AI Lifetime’ga «cheksiz» kirmaydi — AI ruxsati va kvotasi
///   alohida ([AiEntitlement]); server xarajati bor.
library;

import 'package:flutter/foundation.dart';

/// Kirish darajasi. `institution` — kelajak (tashkilot litsenziyasi).
enum AccessLevel { free, lifetime, institution }

enum EntitlementSource { none, appStore, playStore, institution, promo }

/// Huquq qanday tasdiqlangan.
///
/// * [storeConfirmed] — xaridni qurilmadagi StoreKit / Google Play Billing
///   shu Apple ID / Google akkaunti uchun tasdiqladi (ilovaning lokal
///   yozuvi EMAS). Server tekshiruvi YO‘Q — production uchun yetarli emas.
/// * [serverVerified] — backend App Store Server API / Google Play
///   Developer API orqali tekshirdi.
enum EntitlementVerification { none, storeConfirmed, serverVerified }

@immutable
class Entitlements {
  const Entitlements({
    required this.access,
    required this.source,
    this.purchasedAt,
    this.verification = EntitlementVerification.none,
  });

  static const free = Entitlements(
    access: AccessLevel.free,
    source: EntitlementSource.none,
  );

  final AccessLevel access;
  final EntitlementSource source;
  final DateTime? purchasedAt;
  final EntitlementVerification verification;

  /// Asosiy professional mahsulot ochiqmi (Lifetime yoki tashkilot).
  bool get hasFullAccess =>
      access == AccessLevel.lifetime || access == AccessLevel.institution;
}

/// Store’dagi mahsulot turi (adapter shunga qarab so‘rov yuboradi).
enum StoreProductType {
  /// App Store Non-Consumable / Google Play one-time product.
  lifetimeUnlock,

  /// Kelajak: qo‘shimcha AI paketi (consumable yoki alohida mahsulot).
  aiPackage,
}

/// Store’dan kelgan taklif. Narx — store formatlagan lokal satr.
@immutable
class Offer {
  const Offer({
    required this.productId,
    required this.type,
    required this.localizedPrice,
  });

  final String productId;
  final StoreProductType type;
  final String localizedPrice;
}

enum PurchaseOutcome { purchased, cancelled, pending, failed, unavailable }

/// Store’dagi mahsulot ID’lari (narx emas). Store konsollarida aynan
/// shu ID’lar yaratiladi — adapterdan mustaqil.
abstract final class ProductIds {
  /// FORENSIC EXPERT Lifetime — Non-Consumable / one-time product.
  static const lifetime = 'fe_lifetime_unlock';

  static const all = [lifetime];
}

/// Mahsulot konfiguratsiyasi (UI’dan tashqarida).
abstract final class BillingConfig {
  /// Mahsulot/dizayn maqsadi — **reference narx**, real narx emas.
  /// Store ulangach har doim storefront qaytargan lokal narx ko‘rsatiladi.
  static const referenceLifetimePrice = r'$59.99';
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
  /// Backend tasdiqladi.
  verified,

  /// Backend rad etdi (soxta, qaytarilgan, boshqa ilova) — huquq YO‘Q.
  rejected,

  /// Backend sozlanmagan (hozirgi holat) — RELEASE BLOCKER RG-18.
  serverNotConfigured,

  /// Tarmoq yo‘q — offline foydalanuvchi uchun vaqtinchalik qaror.
  networkError,
}

abstract interface class PurchaseVerifier {
  Future<VerificationStatus> verify(PurchaseEvidence evidence);
}

/// PHASE 3 holati: backend yo‘q. Hech qachon «verified» qaytarmaydi.
class UnconfiguredPurchaseVerifier implements PurchaseVerifier {
  const UnconfiguredPurchaseVerifier();

  @override
  Future<VerificationStatus> verify(PurchaseEvidence evidence) async =>
      VerificationStatus.serverNotConfigured;
}

abstract interface class EntitlementService {
  Stream<Entitlements> watch();

  Entitlements get current;

  /// Store mavjud bo‘lsa — Lifetime taklifi (lokal narx bilan).
  Future<List<Offer>> offers();

  Future<PurchaseOutcome> purchase(String productId);

  /// Apple 3.1.1 «restore mechanism»; Google Play’da ham ko‘rsatiladi.
  Future<Entitlements> restore();
}

// ---------------------------------------------------------------------------
// Bepul demo va Lifetime chegarasi.
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
  offlineDatabase,
  internationalStandards,
  jurisdictionLayers,
  verifiedReferences,

  /// Hech qachon pullik devor ortida emas: disclaimer, cheklovlar,
  /// manbalar/provenance tizimi.
  safetyAndProvenance,
}

/// Bepul foydalanuvchi uchun demo hajmi.
enum FeatureAccess {
  /// To‘liq ochiq (Lifetime yoki hamma uchun).
  full,

  /// Bepul demo: mahsulot sifatini baholash uchun yetarli qism.
  demo,
}

/// Qaysi imkoniyat bepul demoda qanday ochiq — bitta joyda.
///
/// Bepul versiya foydasiz yoki sun’iy buzilgan emas: har bir asosiy
/// bo‘limdan haqiqiy demo bor, xavfsizlik va manbalar esa doim to‘liq.
abstract final class AccessPolicy {
  /// Bepul demoda doim ochiq vositalar (katalog ID’lari).
  static const freeToolIds = {'tool.lab.dilution'};

  /// Bepul demoda kutubxonadan nechta yozuv to‘liq ochiq (har bo‘limda).
  static const freeEntriesPerSection = 3;

  /// Bepul demoda nechta o‘quv kursi ochiq.
  static const freeCourses = 1;

  /// Global search: bepul demoda har guruhda ko‘rsatiladigan natijalar.
  static const freeSearchResultsPerGroup = 3;

  static FeatureAccess accessFor(ProductFeature f, Entitlements e) {
    if (f == ProductFeature.safetyAndProvenance) return FeatureAccess.full;
    return e.hasFullAccess ? FeatureAccess.full : FeatureAccess.demo;
  }

  static bool isToolUnlocked(String toolId, Entitlements e) =>
      e.hasFullAccess || freeToolIds.contains(toolId);
}

// ---------------------------------------------------------------------------
// Forensic AI — alohida ruxsat va kvota (Lifetime’ga «cheksiz» kirmaydi).
// ---------------------------------------------------------------------------

enum AiPlan {
  /// AI ulanmagan (PHASE 2 holati).
  none,

  /// Kelajak: Lifetime egalariga ma’lum bepul kvota.
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
