import '../../domain/admin/institute_models.dart';
import '../../domain/plan/plan_models.dart';
import '../../domain/plan/promo_models.dart';
import '../../domain/ports/backend_ports.dart';
import '../../domain/ports/institute_ports.dart';
import '../../domain/ports/plan_ports.dart';
import '../../domain/ports/promo_ports.dart';
import 'supabase_plan.dart' show PlanRpc;
import 'supabase_rest.dart';

Map<String, Object?>? _map(Object? v) =>
    v is Map ? v.cast<String, Object?>() : null;

/// Institut kodi va qurilmalar: `redeem_promo_code`, `register_device`,
/// `my_devices`, `remove_my_device`.
class SupabasePromoService implements PromoService {
  SupabasePromoService({
    required SupabaseConfig config,
    required AuthRepository auth,
    RestTransport? transport,
  }) : _r = PlanRpc(config, auth, transport ?? HttpClientTransport());

  final PlanRpc _r;

  @override
  bool get isConfigured => true;

  @override
  Future<PlanResult<PromoOutcome>> redeemPromoCode(String code) async {
    final res = await _r.rpc('redeem_promo_code', {'p_code': code});
    if (!res.ok) return PlanResult.fail(res.failure!);
    final m = _map(res.value);
    if (m == null) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok(PromoOutcome.fromJson(m));
  }

  @override
  Future<PlanResult<DeviceRegistration>> registerDevice({
    required String deviceHash,
    String? label,
  }) async {
    final res = await _r.rpc('register_device', {
      'p_device_hash': deviceHash,
      'p_label': label,
    });
    if (!res.ok) return PlanResult.fail(res.failure!);
    final m = _map(res.value);
    if (m == null) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok(DeviceRegistration.fromJson(m));
  }

  @override
  Future<PlanResult<List<DeviceRecord>>> myDevices() async {
    final res = await _r.rpc('my_devices', const {});
    if (!res.ok) return PlanResult.fail(res.failure!);
    final v = res.value;
    if (v is! List) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok([for (final e in v) ?DeviceRecord.tryParse(e)]);
  }

  @override
  Future<PlanResult<void>> removeMyDevice(String deviceHash) async {
    final res = await _r.rpc('remove_my_device', {'p_device_hash': deviceHash});
    if (!res.ok) return PlanResult.fail(res.failure!);
    return const PlanResult.ok(null);
  }
}

/// Admin: `admin_institute_create`, `admin_list_institutes`,
/// `admin_institute_get`, `admin_institute_codes`,
/// `admin_gift_codes_create`, `admin_revoke_code`.
class SupabaseAdminInstituteService implements AdminInstituteService {
  SupabaseAdminInstituteService({
    required SupabaseConfig config,
    required AuthRepository auth,
    RestTransport? transport,
  }) : _r = PlanRpc(config, auth, transport ?? HttpClientTransport());

  final PlanRpc _r;

  @override
  bool get isConfigured => true;

  static PlanResult<IssuedCodes> _issued(Object? v) {
    final m = _map(v);
    if (m == null) return const PlanResult.fail(PlanFailure.server);
    if (m['result'] == 'INVALID') {
      return const PlanResult.fail(PlanFailure.invalid);
    }
    final codes = m['codes'];
    if (m['result'] != 'OK' || codes is! List) {
      return const PlanResult.fail(PlanFailure.server);
    }
    return PlanResult.ok(
      IssuedCodes(
        instituteId: m['institute_id'] as String?,
        codes: [
          for (final c in codes)
            if (c is String) c,
        ],
      ),
    );
  }

  @override
  Future<PlanResult<IssuedCodes>> create(InstituteDraft d) async {
    final res = await _r.rpc('admin_institute_create', {
      'p_name': d.name.trim(),
      'p_seats': d.seats,
      'p_months': d.months,
      'p_price': null,
      'p_term_start': d.termStart?.toUtc().toIso8601String(),
      'p_contract_no': null,
      'p_contract_date': null,
      'p_director': null,
      'p_phone': null,
      'p_stir': null,
      'p_bank': null,
      'p_account': null,
      'p_mfo': null,
      'p_address': null,
    });
    if (!res.ok) return PlanResult.fail(res.failure!);
    return _issued(res.value);
  }

  @override
  Future<PlanResult<List<InstituteSummary>>> list() async {
    final res = await _r.rpc('admin_list_institutes', const {});
    if (!res.ok) return PlanResult.fail(res.failure!);
    final v = res.value;
    if (v is! List) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok([for (final e in v) ?InstituteSummary.tryParse(e)]);
  }

  @override
  Future<PlanResult<InstituteDetail>> get(String id) async {
    final res = await _r.rpc('admin_institute_get', {'p_id': id});
    if (!res.ok) return PlanResult.fail(res.failure!);
    final d = InstituteDetail.tryParse(res.value);
    if (d == null) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok(d);
  }

  @override
  Future<PlanResult<List<InstituteCode>>> codes(String id) async {
    final res = await _r.rpc('admin_institute_codes', {'p_id': id});
    if (!res.ok) return PlanResult.fail(res.failure!);
    final v = res.value;
    if (v is! List) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok([for (final e in v) ?InstituteCode.tryParse(e)]);
  }

  @override
  Future<PlanResult<IssuedCodes>> createGiftCodes({
    required String from,
    required int count,
    required int days,
    required Plan plan,
  }) async {
    final res = await _r.rpc('admin_gift_codes_create', {
      'p_from': from.trim(),
      'p_count': count,
      'p_days': days,
      'p_plan': plan.wire,
    });
    if (!res.ok) return PlanResult.fail(res.failure!);
    return _issued(res.value);
  }

  @override
  Future<PlanResult<bool>> revokeCode(String code) async {
    final res = await _r.rpc('admin_revoke_code', {'p_code': code.trim()});
    if (!res.ok) return PlanResult.fail(res.failure!);
    final m = _map(res.value);
    if (m == null) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok(m['result'] == 'REVOKED');
  }

  @override
  Future<PlanResult<bool>> setArchived(
    String id, {
    required bool archived,
  }) async {
    final res = await _r.rpc('admin_institute_set_archived', {
      'p_id': id,
      'p_archived': archived,
    });
    if (!res.ok) return PlanResult.fail(res.failure!);
    final m = _map(res.value);
    if (m == null) return const PlanResult.fail(PlanFailure.server);
    if (m['result'] == 'NOT_FOUND') {
      return const PlanResult.fail(PlanFailure.invalid);
    }
    if (m['result'] != 'OK') return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok(
      m['archived'] is bool ? m['archived']! as bool : archived,
    );
  }

  @override
  Future<PlanResult<InstituteExtension>> extend(String id, int months) async {
    final res = await _r.rpc('admin_institute_extend', {
      'p_id': id,
      'p_months': months,
    });
    if (!res.ok) return PlanResult.fail(res.failure!);
    final m = _map(res.value);
    if (m == null) return const PlanResult.fail(PlanFailure.server);
    if (m['result'] == 'INVALID' || m['result'] == 'NOT_FOUND') {
      return const PlanResult.fail(PlanFailure.invalid);
    }
    final e = InstituteExtension.tryParse(m);
    if (e == null) return const PlanResult.fail(PlanFailure.server);
    return PlanResult.ok(e);
  }
}
