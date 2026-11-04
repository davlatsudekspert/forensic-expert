import '../../domain/plan/plan_models.dart';
import '../../domain/plan/promo_models.dart';
import '../../domain/ports/plan_ports.dart';
import '../../domain/ports/promo_ports.dart';

/// Test/demo adapteri: kodlar xotirada (haqiqiy backend emas).
class FakePromoService implements PromoService {
  FakePromoService({
    Map<String, PromoOutcome>? codes,
    List<DeviceRecord>? devices,
    this.limit = 3,
    this.failure,
    this.configured = true,
    this.onRedeemed,
  }) : codes = codes ?? {},
       devices = devices ?? [];

  /// Normallashtirilgan kod → natija.
  final Map<String, PromoOutcome> codes;
  final List<DeviceRecord> devices;
  final int limit;

  /// Berilsa — har chaqiruv shu xato bilan tugaydi.
  PlanFailure? failure;
  final bool configured;

  /// Kod qabul qilinganda chaqiriladi (testda reja holatini yangilash uchun).
  final void Function(PromoOutcome outcome)? onRedeemed;

  /// Chaqiruvlar jurnali (testlar uchun).
  final calls = <String>[];

  /// Ro‘yxatdan o‘tgan joriy qurilmalar (`registerDevice` ok bo‘lganda).
  final registered = <String>{};

  @override
  bool get isConfigured => configured;

  @override
  Future<PlanResult<PromoOutcome>> redeemPromoCode(String code) async {
    calls.add('redeem:$code');
    if (failure != null) return PlanResult.fail(failure!);
    final out = codes[code] ?? const PromoOutcome(PromoResult.invalid);
    if (out.result == PromoResult.ok) onRedeemed?.call(out);
    return PlanResult.ok(out);
  }

  @override
  Future<PlanResult<DeviceRegistration>> registerDevice({
    required String deviceHash,
    String? label,
  }) async {
    calls.add('register:$deviceHash:${label ?? ''}');
    if (failure != null) return PlanResult.fail(failure!);
    final known = devices.any((d) => d.hash == deviceHash);
    if (!known && devices.length >= limit) {
      return PlanResult.ok(
        DeviceRegistration(ok: false, limit: limit, devices: [...devices]),
      );
    }
    if (!known) {
      devices.add(
        DeviceRecord(hash: deviceHash, label: label, lastSeen: DateTime.now()),
      );
    }
    registered.add(deviceHash);
    return PlanResult.ok(DeviceRegistration(ok: true, limit: limit));
  }

  @override
  Future<PlanResult<List<DeviceRecord>>> myDevices() async {
    calls.add('myDevices');
    if (failure != null) return PlanResult.fail(failure!);
    return PlanResult.ok([...devices]);
  }

  @override
  Future<PlanResult<void>> removeMyDevice(String deviceHash) async {
    calls.add('remove:$deviceHash');
    if (failure != null) return PlanResult.fail(failure!);
    devices.removeWhere((d) => d.hash == deviceHash);
    return const PlanResult.ok(null);
  }
}

/// Testda: demo Entitlements bilan birga ishlatish uchun qulay kod natijasi.
PromoOutcome promoOk({
  String label = 'institut: Test instituti',
  DateTime? until,
  Plan plan = Plan.teacher,
}) => PromoOutcome(
  PromoResult.ok,
  kind: label.startsWith('institut') ? 'institute' : 'gift',
  label: label,
  until: until ?? DateTime.now().add(const Duration(days: 365)),
  plan: plan,
);
