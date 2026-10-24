import 'dart:async';
import 'dart:io';

import '../../domain/plan/plan_models.dart';
import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/plan_ports.dart';
import 'supabase_rest.dart';

/// Umumiy RPC/Edge chaqiruvi (token, xato xaritasi).
class _PlanRpc {
  _PlanRpc(this.cfg, this.auth, this.http);

  final SupabaseConfig cfg;
  final AuthRepository auth;
  final RestTransport http;

  Future<PlanResult<Object?>> call(
    String path,
    Map<String, Object?> body,
  ) async {
    if (!auth.current.signedIn) {
      return const PlanResult.fail(PlanFailure.notSignedIn);
    }
    final token = await auth.accessToken();
    if (token == null) return const PlanResult.fail(PlanFailure.notSignedIn);
    try {
      final r = await http.send(
        'POST',
        cfg.url.resolve(path),
        headers: {'apikey': cfg.anonKey, 'Authorization': 'Bearer $token'},
        jsonBody: body,
      );
      if (r.status == 401) {
        return const PlanResult.fail(PlanFailure.notSignedIn);
      }
      if (r.status == 403) return const PlanResult.fail(PlanFailure.forbidden);
      if (r.status == 404) {
        return const PlanResult.fail(PlanFailure.notConfigured);
      }
      if (r.status == 400 || r.status == 422) {
        return const PlanResult.fail(PlanFailure.invalid);
      }
      if (!r.ok) return const PlanResult.fail(PlanFailure.server);
      return PlanResult.ok(r.json);
    } on FormatException {
      return const PlanResult.fail(PlanFailure.server);
    } on SocketException {
      return const PlanResult.fail(PlanFailure.offline);
    } on TimeoutException {
      return const PlanResult.fail(PlanFailure.offline);
    } on HandshakeException {
      return const PlanResult.fail(PlanFailure.offline);
    }
  }

  Future<PlanResult<Object?>> rpc(String name, Map<String, Object?> body) =>
      call('rest/v1/rpc/$name', body);
}

Map<String, Object?>? _map(Object? v) =>
    v is Map ? v.cast<String, Object?>() : null;

/// Reja Supabase adapteri: `my_plan(p_device_hash)`, `plan_claim_trial`,
/// edge function `verify-purchase` (shartnoma: `docs/PRO_IMPL_0.4.0.md` §2).
/// Reja holati faqat server tasdig‘i bilan; lokal bayroq yo‘q.
class SupabasePlanService implements PlanService {
  SupabasePlanService({
    required SupabaseConfig config,
    required AuthRepository auth,
    RestTransport? transport,
  }) : _r = _PlanRpc(config, auth, transport ?? HttpClientTransport());

  final _PlanRpc _r;

  @override
  bool get isConfigured => true;
  @override
  bool get isDemo => false;

  @override
  Future<PlanResult<Entitlements>> myPlan(String? deviceHash) async {
    final res = await _r.rpc('my_plan', {'p_device_hash': deviceHash});
    if (!res.ok) return PlanResult.fail(res.failure!);
    final m = _map(res.value);
    if (m == null) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok(Entitlements.fromJson(m));
  }

  @override
  Future<PlanResult<TrialResult>> claimTrial({
    required String deviceHash,
    required Plan plan,
  }) async {
    final res = await _r.rpc('plan_claim_trial', {
      'p_device_hash': deviceHash,
      'p_plan': plan.wire,
    });
    if (!res.ok) return PlanResult.fail(res.failure!);
    final m = _map(res.value);
    if (m == null) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok(TrialResult.fromWire(m['result']));
  }

  @override
  Future<PlanResult<VerifyOutcome>> verifyPurchase({
    required String platform,
    required String productId,
    required String proof,
    String? transactionId,
  }) async {
    final res = await _r.call('functions/v1/verify-purchase', {
      'platform': platform,
      'product_id': productId,
      if (platform == 'ios')
        'signed_transaction': proof
      else
        'purchase_token': proof,
      'transaction_id': ?transactionId,
    });
    if (!res.ok) return PlanResult.fail(res.failure!);
    final m = _map(res.value);
    if (m == null) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok(
      VerifyOutcome(
        VerifyResult.fromWire(m['result']),
        plan: Plan.fromWire(m['plan']),
        expiresAt: DateTime.tryParse('${m['expires_at'] ?? ''}'),
      ),
    );
  }
}

/// Admin: `admin_set_plan`, `admin_list_plans`, `admin_plan_stats`.
class SupabaseAdminPlanService implements AdminPlanService {
  SupabaseAdminPlanService({
    required SupabaseConfig config,
    required AuthRepository auth,
    RestTransport? transport,
  }) : _r = _PlanRpc(config, auth, transport ?? HttpClientTransport());

  final _PlanRpc _r;

  @override
  bool get isConfigured => true;

  @override
  Future<PlanResult<AdminPlanResult>> setPlan({
    required String email,
    required Plan? plan,
    DateTime? until,
  }) async {
    final res = await _r.rpc('admin_set_plan', {
      'p_email': email.trim(),
      'p_plan': plan?.wire,
      'p_until': until?.toUtc().toIso8601String(),
    });
    if (!res.ok) return PlanResult.fail(res.failure!);
    final m = _map(res.value);
    if (m == null) return const PlanResult.fail(PlanFailure.server);
    return switch (m['result']) {
      'GRANTED' => const PlanResult.ok(AdminPlanResult.granted),
      'REVOKED' => const PlanResult.ok(AdminPlanResult.revoked),
      'NOT_FOUND' => const PlanResult.ok(AdminPlanResult.notFound),
      'INVALID' => const PlanResult.ok(AdminPlanResult.invalid),
      _ => const PlanResult.fail(PlanFailure.server),
    };
  }

  @override
  Future<PlanResult<List<AdminPlanRow>>> list({
    String? query,
    int limit = 50,
  }) async {
    final q = query?.trim();
    final res = await _r.rpc('admin_list_plans', {
      'p_query': (q == null || q.isEmpty) ? null : q,
      'p_limit': limit,
    });
    if (!res.ok) return PlanResult.fail(res.failure!);
    final v = res.value;
    if (v is! List) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok([
      for (final e in v)
        if (_map(e) case final m?) AdminPlanRow.fromJson(m),
    ]);
  }

  @override
  Future<PlanResult<AdminPlanStats>> stats() async {
    final res = await _r.rpc('admin_plan_stats', const {});
    if (!res.ok) return PlanResult.fail(res.failure!);
    final m = _map(res.value);
    if (m == null) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok(AdminPlanStats.fromJson(m));
  }
}
