import '../admin/institute_models.dart';
import '../plan/plan_models.dart';
import 'plan_ports.dart' show PlanFailure, PlanResult;

/// Admin: institutlar va sovg‘a promokodlari (faqat identity_admin; server
/// har bir RPC’da tekshiradi).
abstract interface class AdminInstituteService {
  bool get isConfigured;

  Future<PlanResult<IssuedCodes>> create(InstituteDraft draft);

  Future<PlanResult<List<InstituteSummary>>> list();

  Future<PlanResult<InstituteDetail>> get(String id);

  Future<PlanResult<List<InstituteCode>>> codes(String id);

  /// [count] 1–50, [days] 1–1100.
  Future<PlanResult<IssuedCodes>> createGiftCodes({
    required String from,
    required int count,
    required int days,
    required Plan plan,
  });

  /// `true` — bekor qilindi; `false` — topilmadi yoki allaqachon ishlatilgan.
  Future<PlanResult<bool>> revokeCode(String code);
}

class UnconfiguredAdminInstituteService implements AdminInstituteService {
  const UnconfiguredAdminInstituteService();

  @override
  bool get isConfigured => false;

  @override
  Future<PlanResult<IssuedCodes>> create(InstituteDraft draft) async =>
      const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<List<InstituteSummary>>> list() async =>
      const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<InstituteDetail>> get(String id) async =>
      const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<List<InstituteCode>>> codes(String id) async =>
      const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<IssuedCodes>> createGiftCodes({
    required String from,
    required int count,
    required int days,
    required Plan plan,
  }) async => const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<bool>> revokeCode(String code) async =>
      const PlanResult.fail(PlanFailure.notConfigured);
}
