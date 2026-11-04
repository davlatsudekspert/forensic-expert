import '../plan/promo_models.dart';
import 'plan_ports.dart' show PlanFailure, PlanResult;

/// Institut kodi / promokod va qurilmalar limiti (server RPC).
abstract interface class PromoService {
  bool get isConfigured;

  /// [code] — [normalizePromoCode] dan o‘tgan.
  Future<PlanResult<PromoOutcome>> redeemPromoCode(String code);

  /// [label] — faqat platforma («iOS», «Android»); shaxsiy ma’lumot emas.
  Future<PlanResult<DeviceRegistration>> registerDevice({
    required String deviceHash,
    String? label,
  });

  Future<PlanResult<List<DeviceRecord>>> myDevices();

  Future<PlanResult<void>> removeMyDevice(String deviceHash);
}

class UnconfiguredPromoService implements PromoService {
  const UnconfiguredPromoService();

  @override
  bool get isConfigured => false;

  @override
  Future<PlanResult<PromoOutcome>> redeemPromoCode(String code) async =>
      const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<DeviceRegistration>> registerDevice({
    required String deviceHash,
    String? label,
  }) async => const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<List<DeviceRecord>>> myDevices() async =>
      const PlanResult.fail(PlanFailure.notConfigured);

  @override
  Future<PlanResult<void>> removeMyDevice(String deviceHash) async =>
      const PlanResult.fail(PlanFailure.notConfigured);
}
