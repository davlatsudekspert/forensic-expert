import '../../domain/plan/plan_models.dart';
import '../../domain/ports/plan_ports.dart';

/// Test/demo adapteri: reja xotirada saqlanadi (haqiqiy backend emas).
class FakePlanService implements PlanService {
  FakePlanService({
    this.entitlements = Entitlements.none,
    this.trialResult = TrialResult.granted,
    this.verifyResult = const VerifyOutcome(VerifyResult.notConfigured),
    this.failure,
    this.configured = true,
  });

  Entitlements entitlements;
  TrialResult trialResult;
  VerifyOutcome verifyResult;

  /// Berilsa — har chaqiruv shu xato bilan tugaydi.
  PlanFailure? failure;
  final bool configured;

  /// Chaqiruvlar jurnali (testlar uchun).
  final calls = <String>[];
  String? lastDeviceHash;

  @override
  bool get isConfigured => configured;
  @override
  bool get isDemo => true;

  @override
  Future<PlanResult<Entitlements>> myPlan(String? deviceHash) async {
    calls.add('myPlan');
    lastDeviceHash = deviceHash;
    if (failure != null) return PlanResult.fail(failure!);
    return PlanResult.ok(entitlements);
  }

  @override
  Future<PlanResult<TrialResult>> claimTrial({
    required String deviceHash,
    required Plan plan,
  }) async {
    calls.add('claimTrial:${plan.name}');
    if (failure != null) return PlanResult.fail(failure!);
    if (trialResult == TrialResult.granted) {
      entitlements = Entitlements(
        plan: plan,
        source: PlanSource.trial,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
    }
    return PlanResult.ok(trialResult);
  }

  @override
  Future<PlanResult<VerifyOutcome>> verifyPurchase({
    required String platform,
    required String productId,
    required String proof,
    String? transactionId,
  }) async {
    calls.add('verify:$productId');
    if (failure != null) return PlanResult.fail(failure!);
    final v = verifyResult;
    if (v.result == VerifyResult.applied && v.plan != null) {
      entitlements = Entitlements(
        plan: v.plan,
        source: PlanSource.store,
        expiresAt: v.expiresAt,
        autoRenew: true,
        productId: productId,
      );
    }
    return PlanResult.ok(v);
  }
}

/// Test/demo admin xizmati.
class FakeAdminPlanService implements AdminPlanService {
  FakeAdminPlanService({List<AdminPlanRow>? rows, this.failure})
    : rows = rows ?? [];

  final List<AdminPlanRow> rows;
  PlanFailure? failure;
  final calls = <String>[];

  @override
  bool get isConfigured => true;

  @override
  Future<PlanResult<AdminPlanResult>> setPlan({
    required String email,
    required Plan? plan,
    DateTime? until,
  }) async {
    calls.add('set:$email:${plan?.name}');
    if (failure != null) return PlanResult.fail(failure!);
    final e = email.trim().toLowerCase();
    if (!e.contains('@')) return const PlanResult.ok(AdminPlanResult.invalid);
    rows.removeWhere((r) => r.email == e);
    if (plan == null) return const PlanResult.ok(AdminPlanResult.revoked);
    rows.add(
      AdminPlanRow(
        email: e,
        plan: plan,
        source: PlanSource.admin,
        expiresAt: until,
        updatedAt: DateTime.now(),
      ),
    );
    return const PlanResult.ok(AdminPlanResult.granted);
  }

  @override
  Future<PlanResult<List<AdminPlanRow>>> list({
    String? query,
    int limit = 50,
  }) async {
    calls.add('list');
    if (failure != null) return PlanResult.fail(failure!);
    final q = (query ?? '').trim().toLowerCase();
    return PlanResult.ok([
      for (final r in rows)
        if (q.isEmpty || r.email.contains(q)) r,
    ]);
  }

  @override
  Future<PlanResult<AdminPlanStats>> stats() async {
    if (failure != null) return PlanResult.fail(failure!);
    int n(Plan p) => rows.where((r) => r.plan == p).length;
    return PlanResult.ok(
      AdminPlanStats(
        student: n(Plan.student),
        teacher: n(Plan.teacher),
        expert: n(Plan.expert),
        premium: n(Plan.premium),
        adminActive: rows.length,
      ),
    );
  }
}
