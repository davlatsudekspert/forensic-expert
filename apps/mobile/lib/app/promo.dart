import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/plan/promo_models.dart';
import '../domain/ports/plan_ports.dart';
import '../domain/ports/promo_ports.dart';
import 'class_quiz.dart' show classIsTeacherProvider;
import 'plan.dart';
import 'providers.dart';

/// Institut kodi va qurilmalar xizmati. Bootstrap’da Supabase bo‘lsa
/// almashtiriladi; aks holda ulanmagan (UI ko‘rinmaydi).
final promoServiceProvider = Provider<PromoService>(
  (ref) => const UnconfiguredPromoService(),
);

/// Qurilma yorlig‘i: faqat platforma — shaxsiy ma’lumot yuborilmaydi.
final devicePlatformLabelProvider = Provider<String?>((ref) {
  if (kIsWeb) return null;
  try {
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
  } on Object {
    return null;
  }
  return null;
});

/// Kodni faollashtiradi. OK bo‘lsa reja (va ustoz roli) qayta o‘qiladi.
Future<PlanResult<PromoOutcome>> redeemPromo(WidgetRef ref, String raw) async {
  final r = await ref
      .read(promoServiceProvider)
      .redeemPromoCode(normalizePromoCode(raw));
  final v = r.value;
  if (v != null &&
      (v.result == PromoResult.ok || v.result == PromoResult.alreadyYours)) {
    ref.invalidate(classIsTeacherProvider);
    await ref.read(entitlementsProvider.notifier).refresh();
  }
  return r;
}

/// Qurilmalar limiti holati. [full] — server «3 ta qurilma to‘lgan» dedi.
class DeviceLimitState {
  const DeviceLimitState({
    this.full = false,
    this.devices = const [],
    this.limit = 3,
  });

  final bool full;
  final List<DeviceRecord> devices;
  final int limit;
}

final deviceLimitProvider =
    NotifierProvider<DeviceLimitController, DeviceLimitState>(
      DeviceLimitController.new,
    );

/// Kirgandan va reja yuklangandan keyin bu qurilmani serverda ro‘yxatga oladi
/// (fonda; xatoda jim). Limit to‘lgan bo‘lsa — [DeviceLimitState.full]:
/// ekran ro‘yxat va «Chiqarish» taklif qiladi. Qattiq bloklash YO‘Q — limit
/// hozircha faqat server hisobida.
class DeviceLimitController extends Notifier<DeviceLimitState> {
  /// Bekor qilingan foydalanuvchi (sessiya davomida qayta bezovta qilinmaydi).
  String? _dismissedUser;

  @override
  DeviceLimitState build() {
    final user = ref.watch(authStateProvider.select((s) => s.userId));
    final signedIn = ref.watch(authStateProvider.select((s) => s.signedIn));
    final svc = ref.watch(promoServiceProvider);
    final loaded = ref.watch(entitlementsProvider.select((e) => e.hasValue));
    if (!signedIn || !svc.isConfigured || !loaded) {
      return const DeviceLimitState();
    }
    unawaited(_register(user));
    return const DeviceLimitState();
  }

  Future<bool> _register(String? user) async {
    try {
      final hash = await ref.read(deviceHashProvider.future);
      if (hash == null) return true;
      final r = await ref
          .read(promoServiceProvider)
          .registerDevice(
            deviceHash: hash,
            label: ref.read(devicePlatformLabelProvider),
          );
      final v = r.value;
      if (!ref.mounted || v == null) return true;
      if (v.ok) {
        state = const DeviceLimitState();
        return true;
      }
      if (user != null && _dismissedUser == user) return false;
      state = DeviceLimitState(full: true, devices: v.devices, limit: v.limit);
      return false;
    } on Object {
      return true;
    }
  }

  /// Foydalanuvchi oynani yopdi: ilova ishlashda davom etadi.
  void dismiss() {
    _dismissedUser = ref.read(authStateProvider).userId;
    state = const DeviceLimitState();
  }

  /// [hash] qurilmani chiqaradi va bu qurilmani qayta ro‘yxatga oladi.
  /// `true` — endi joy bor (oyna yopiladi).
  Future<bool> removeAndRetry(String hash) async {
    final r = await ref.read(promoServiceProvider).removeMyDevice(hash);
    if (!r.ok) return false;
    // Joy bo‘lsa — ro‘yxatga olinadi; yo‘q bo‘lsa — yangi ro‘yxat ko‘rsatiladi.
    final ok = await _register(null);
    return ok;
  }
}
