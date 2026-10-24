import '../plan/plan_models.dart';

/// Reja xizmati xatolari.
enum PlanFailure {
  notConfigured,
  notSignedIn,
  offline,
  server,
  forbidden,
  invalid,
}

class PlanResult<T> {
  const PlanResult.ok(T this.value) : failure = null;
  const PlanResult.fail(PlanFailure this.failure) : value = null;

  final T? value;
  final PlanFailure? failure;

  bool get ok => failure == null;
}

/// `plan_claim_trial` natijasi.
enum TrialResult {
  granted,
  alreadyUsedDevice,
  alreadyUsedAccount,
  hasPlan,
  invalid;

  static TrialResult fromWire(Object? v) => switch (v) {
    'GRANTED' => granted,
    'ALREADY_USED_DEVICE' => alreadyUsedDevice,
    'ALREADY_USED_ACCOUNT' => alreadyUsedAccount,
    'HAS_PLAN' => hasPlan,
    _ => invalid,
  };
}

/// `verify-purchase` natijasi.
enum VerifyResult {
  applied,
  notConfigured,
  invalid;

  static VerifyResult fromWire(Object? v) => switch (v) {
    'APPLIED' => applied,
    'NOT_CONFIGURED' => notConfigured,
    _ => invalid,
  };
}

class VerifyOutcome {
  const VerifyOutcome(this.result, {this.plan, this.expiresAt});

  final VerifyResult result;
  final Plan? plan;
  final DateTime? expiresAt;
}

/// Server reja xizmati (`my_plan`, `plan_claim_trial`, `verify-purchase`).
abstract interface class PlanService {
  bool get isConfigured;

  /// Demo (Fake) — haqiqiy backend emas.
  bool get isDemo;

  Future<PlanResult<Entitlements>> myPlan(String? deviceHash);

  Future<PlanResult<TrialResult>> claimTrial({
    required String deviceHash,
    required Plan plan,
  });

  /// Do‘kon xaridini server tekshiradi. [platform]: `ios` | `android`.
  /// [proof] — iOS: imzolangan tranzaksiya (JWS); Android: purchase token.
  Future<PlanResult<VerifyOutcome>> verifyPurchase({
    required String platform,
    required String productId,
    required String proof,
    String? transactionId,
  });
}

/// Backend yo‘q — hech narsa soxtalashtirilmaydi.
class UnconfiguredPlanService implements PlanService {
  const UnconfiguredPlanService();

  @override
  bool get isConfigured => false;
  @override
  bool get isDemo => false;

  @override
  Future<PlanResult<Entitlements>> myPlan(String? deviceHash) async =>
      const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<TrialResult>> claimTrial({
    required String deviceHash,
    required Plan plan,
  }) async => const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<VerifyOutcome>> verifyPurchase({
    required String platform,
    required String productId,
    required String proof,
    String? transactionId,
  }) async => const PlanResult.fail(PlanFailure.notConfigured);
}

/// Do‘kon mahsuloti (narx faqat do‘kondan; kodga yozilmaydi).
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.plan,
    required this.period,
    required this.title,
    required this.price,
  });

  final String id;
  final Plan plan;
  final PlanPeriod period;
  final String title;

  /// Do‘kon formatlagan narx (masalan «$1.49»).
  final String price;
}

enum StorePurchaseStatus { purchased, restored, pending, canceled, error }

/// Do‘kondan kelgan xarid hodisasi.
class StorePurchase {
  const StorePurchase({
    required this.productId,
    required this.status,
    this.proof,
    this.transactionId,
    this.handle,
  });

  final String productId;
  final StorePurchaseStatus status;

  /// iOS: JWS; Android: purchase token.
  final String? proof;
  final String? transactionId;

  /// Do‘kon-ichki ob’ekt (`complete` uchun).
  final Object? handle;
}

/// Do‘kon (App Store / Google Play) xizmati.
abstract interface class StoreService {
  /// Do‘kon ishlayaptimi (emulyator/test/web’da `false`).
  Future<bool> isAvailable();

  Future<List<StoreProduct>> products(Set<String> ids);

  /// Xarid oynasini ochadi; natija [purchaseStream] orqali keladi.
  Future<bool> buy(StoreProduct product);

  Future<void> restore();

  Stream<StorePurchase> get purchaseStream;

  /// Server tasdiqlagach tranzaksiyani yopadi.
  Future<void> complete(StorePurchase purchase);
}

/// Admin: reja berish/olib tashlash (faqat identity_admin; server tekshiradi).
class AdminPlanRow {
  const AdminPlanRow({
    required this.email,
    required this.plan,
    required this.source,
    required this.expiresAt,
    required this.updatedAt,
  });

  factory AdminPlanRow.fromJson(Map<String, Object?> j) => AdminPlanRow(
    email: '${j['email'] ?? ''}',
    plan: Plan.fromWire(j['plan']),
    source: PlanSource.fromWire(j['source']),
    expiresAt: DateTime.tryParse('${j['expires_at'] ?? ''}'),
    updatedAt: DateTime.tryParse('${j['updated_at'] ?? ''}'),
  );

  final String email;
  final Plan? plan;
  final PlanSource? source;
  final DateTime? expiresAt;
  final DateTime? updatedAt;
}

class AdminPlanStats {
  const AdminPlanStats({
    this.student = 0,
    this.teacher = 0,
    this.expert = 0,
    this.trialsActive = 0,
    this.storeActive = 0,
    this.adminActive = 0,
  });

  static const empty = AdminPlanStats();

  factory AdminPlanStats.fromJson(Map<String, Object?> j) {
    int n(Object? v) => v is num ? v.toInt() : 0;
    final a = j['active'] is Map
        ? (j['active']! as Map).cast<String, Object?>()
        : const <String, Object?>{};
    return AdminPlanStats(
      student: n(a['student']),
      teacher: n(a['teacher']),
      expert: n(a['expert']),
      trialsActive: n(j['trials_active']),
      storeActive: n(j['store_active']),
      adminActive: n(j['admin_active']),
    );
  }

  final int student;
  final int teacher;
  final int expert;
  final int trialsActive;
  final int storeActive;
  final int adminActive;
}

enum AdminPlanResult { granted, revoked, notFound, invalid }

abstract interface class AdminPlanService {
  bool get isConfigured;

  Future<PlanResult<AdminPlanResult>> setPlan({
    required String email,
    required Plan? plan,
    DateTime? until,
  });

  Future<PlanResult<List<AdminPlanRow>>> list({String? query, int limit});

  Future<PlanResult<AdminPlanStats>> stats();
}

class UnconfiguredAdminPlanService implements AdminPlanService {
  const UnconfiguredAdminPlanService();

  @override
  bool get isConfigured => false;

  @override
  Future<PlanResult<AdminPlanResult>> setPlan({
    required String email,
    required Plan? plan,
    DateTime? until,
  }) async => const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<List<AdminPlanRow>>> list({
    String? query,
    int limit = 50,
  }) async => const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<AdminPlanStats>> stats() async =>
      const PlanResult.fail(PlanFailure.notConfigured);
}

/// «Birinchi kirishdagi yumshoq taklif» faqat bir marta ko‘rsatiladi
/// (lokal; Pro holati emas — faqat UI belgisi).
abstract interface class ProOfferStore {
  bool get firstOfferShown;

  Future<void> markFirstOfferShown();
}

class InMemoryProOfferStore implements ProOfferStore {
  InMemoryProOfferStore({this._shown = false});

  bool _shown;

  @override
  bool get firstOfferShown => _shown;

  @override
  Future<void> markFirstOfferShown() async => _shown = true;
}
