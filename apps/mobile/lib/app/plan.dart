import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/settings/app_settings.dart';
import '../core/settings/settings_controller.dart';
import '../data/plan/fake_plan_service.dart';
import '../data/store/fake_store_service.dart';
import '../domain/lessons/lesson_models.dart';
import '../domain/plan/plan_models.dart';
import '../domain/ports/plan_ports.dart';
import 'lessons.dart';
import 'providers.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa [SupabasePlanService] bilan
/// almashtiriladi; aks holda DEMO (Fake) — release’da ulanmagan.
final planServiceProvider = Provider<PlanService>((ref) => FakePlanService());

/// Bootstrap’da `in_app_purchase` adapteri; testlarda soxta do‘kon.
final storeServiceProvider = Provider<StoreService>(
  (ref) => FakeStoreService(available: false),
);

final adminPlanServiceProvider = Provider<AdminPlanService>(
  (ref) => const UnconfiguredAdminPlanService(),
);

final proOfferStoreProvider = Provider<ProOfferStore>(
  (ref) => InMemoryProOfferStore(shown: true),
);

/// Rejim → shu rejimning rejasi (Talaba/Ustoz/Mutaxassis).
Plan planForMode(UserMode mode) => switch (mode) {
  UserMode.student => Plan.student,
  UserMode.teacher => Plan.teacher,
  UserMode.professional => Plan.expert,
};

/// Joriy rejimga mos reja (Pro sahifasi va yumshoq taklif uchun).
final modePlanProvider = Provider<Plan>(
  (ref) => planForMode(
    ref.watch(settingsControllerProvider.select((s) => s.userMode)) ??
        UserMode.professional,
  ),
);

/// Qurilma kaliti: iOS `identifierForVendor` / Android `ANDROID_ID` →
/// sha256 (hex). Xom identifikator serverga ketmaydi. Boshqa platforma,
/// mehmon yoki xato — `null` (sinov taklif qilinmaydi).
final deviceHashProvider = FutureProvider<String?>((ref) async {
  if (kIsWeb) return null;
  try {
    String? raw;
    if (Platform.isIOS) {
      raw = (await DeviceInfoPlugin().iosInfo).identifierForVendor;
    } else if (Platform.isAndroid) {
      raw = await const AndroidId().getId();
    }
    if (raw == null || raw.isEmpty) return null;
    return sha256.convert(utf8.encode(raw)).toString();
  } on Object {
    return null;
  }
});

/// Kirgan foydalanuvchi huquqi (faqat server tasdig‘i). Mehmon — bo‘sh.
/// Tarmoq xatosida oxirgi muvaffaqiyatli server javobi saqlanadi (muddati
/// [Entitlements.allows] da baribir tekshiriladi).
final entitlementsProvider =
    AsyncNotifierProvider<EntitlementsNotifier, Entitlements>(
      EntitlementsNotifier.new,
    );

class EntitlementsNotifier extends AsyncNotifier<Entitlements> {
  Entitlements? _last;

  @override
  Future<Entitlements> build() async {
    final auth = ref.watch(authStateProvider);
    if (!auth.signedIn) {
      _last = null;
      return Entitlements.none;
    }
    final svc = ref.watch(planServiceProvider);
    if (!svc.isConfigured) return Entitlements.none;
    final hash = await ref.watch(deviceHashProvider.future);
    final r = await svc.myPlan(hash);
    final v = r.value;
    if (v != null) {
      _last = v;
      return v;
    }
    return _last ?? Entitlements.none;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// [feature] ochiqmi (yuklanayotgan yoki xatoda — yopiq).
final proAllowedProvider = Provider.family<bool, ProFeature>(
  (ref, feature) =>
      ref.watch(entitlementsProvider).value?.allows(feature) ?? false,
);

/// Funksiya shu foydalanuvchiga ochiqmi. Rejim emas, **reja** tekshiriladi.
bool proGate(WidgetRef ref, ProFeature feature) =>
    ref.watch(proAllowedProvider(feature));

/// Huquq hali yuklanayotgan bo‘lsa `true` (qulf kartasi o‘rniga skelet).
bool proLoading(WidgetRef ref) =>
    ref.watch(entitlementsProvider.select((e) => e.isLoading && !e.hasValue));

/// Dars qulflari: `topicId` → qulf sababi (ochiq darslar yo‘q). Ro‘yxat
/// yuklanmaguncha — `null` (qulf aniqlanmagan).
final lessonLocksProvider = Provider.autoDispose<Map<String, ProFeature>?>((
  ref,
) {
  final res = ref.watch(lessonListProvider('')).value?.value;
  if (res == null) return null;
  final ent = ref.watch(entitlementsProvider).value ?? Entitlements.none;
  return computeLessonLocks(res, ent);
});

/// Sof funksiya (testlanadi): Mutaxassis — «Apparatlar» 1-dars ochiq;
/// Ustoz — ro‘yxatdagi dastlabki [LessonAccess.freeTeacherLessons] dars.
Map<String, ProFeature> computeLessonLocks(
  List<LessonSummary> all,
  Entitlements ent,
) {
  final out = <String, ProFeature>{};
  var teacherIndex = 0;
  for (final s in all) {
    if (LessonAccess.isInstrument(s.topicId)) {
      if (!LessonAccess.isFreeInstrumentSample(s.topicId) &&
          !ent.allows(ProFeature.instrumentsCourseFull)) {
        out[s.topicId] = ProFeature.instrumentsCourseFull;
      }
    } else {
      final free = teacherIndex < LessonAccess.freeTeacherLessons;
      teacherIndex++;
      if (!free && !ent.allows(ProFeature.allLessons)) {
        out[s.topicId] = ProFeature.allLessons;
      }
    }
  }
  return out;
}

/// Xarid/sinov jarayoni holati (Pro sahifasi uchun).
enum ProFlow {
  idle,
  working,
  success,
  pending,
  canceled,
  storeNotConfigured,
  invalid,
  offline,
  error,
  restoreNothing,
  trialUsedDevice,
  trialUsedAccount,
  trialHasPlan,
  trialUnavailable,
}

final storeAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(storeServiceProvider).isAvailable(),
);

/// Mahsulotlar (narx faqat do‘kondan). Do‘kon yo‘q — bo‘sh ro‘yxat.
final storeProductsProvider = FutureProvider.family<List<StoreProduct>, Plan>((
  ref,
  plan,
) async {
  final list = await ref
      .watch(storeServiceProvider)
      .products(PlanProducts.idsFor(plan));
  list.sort((a, b) => a.period.index.compareTo(b.period.index));
  return list;
});

final proFlowProvider = NotifierProvider<ProFlowController, ProFlow>(
  ProFlowController.new,
);

/// Do‘kon oqimini tinglaydi, har xaridni serverda tekshirtiradi, so‘ng
/// tranzaksiyani yopadi. Ilova ildizida doim faol (kutilayotgan
/// tranzaksiyalar ishga tushishda keladi).
class ProFlowController extends Notifier<ProFlow> {
  StreamSubscription<StorePurchase>? _sub;
  Timer? _restoreTimer;

  @override
  ProFlow build() {
    final store = ref.watch(storeServiceProvider);
    _sub = store.purchaseStream.listen(_onPurchase);
    ref.onDispose(() {
      _sub?.cancel();
      _restoreTimer?.cancel();
    });
    // Do‘kon oqimiga ishga tushishdayoq ulanish (kutilayotgan tranzaksiyalar).
    unawaited(store.isAvailable());
    return ProFlow.idle;
  }

  String get _platform => Platform.isIOS ? 'ios' : 'android';

  Future<void> _onPurchase(StorePurchase p) async {
    _restoreTimer?.cancel();
    switch (p.status) {
      case StorePurchaseStatus.pending:
        state = ProFlow.pending;
      case StorePurchaseStatus.canceled:
        state = ProFlow.canceled;
        await ref.read(storeServiceProvider).complete(p);
      case StorePurchaseStatus.error:
        state = ProFlow.error;
      case StorePurchaseStatus.purchased || StorePurchaseStatus.restored:
        await _verify(p);
    }
  }

  Future<void> _verify(StorePurchase p) async {
    final proof = p.proof;
    if (proof == null || proof.isEmpty) {
      state = ProFlow.invalid;
      return;
    }
    state = ProFlow.working;
    final r = await ref
        .read(planServiceProvider)
        .verifyPurchase(
          platform: _platform,
          productId: p.productId,
          proof: proof,
          transactionId: p.transactionId,
        );
    final v = r.value;
    if (v == null) {
      // Tarmoq/server xatosi: tranzaksiya yopilmaydi — keyin qayta keladi.
      state = r.failure == PlanFailure.offline
          ? ProFlow.offline
          : ProFlow.error;
      return;
    }
    switch (v.result) {
      case VerifyResult.applied:
        await ref.read(storeServiceProvider).complete(p);
        await ref.read(entitlementsProvider.notifier).refresh();
        state = ProFlow.success;
      case VerifyResult.notConfigured:
        state = ProFlow.storeNotConfigured;
      case VerifyResult.invalid:
        await ref.read(storeServiceProvider).complete(p);
        state = ProFlow.invalid;
    }
  }

  Future<void> buy(StoreProduct product) async {
    state = ProFlow.working;
    final ok = await ref.read(storeServiceProvider).buy(product);
    if (!ok && state == ProFlow.working) state = ProFlow.error;
  }

  Future<void> restore() async {
    state = ProFlow.working;
    await ref.read(storeServiceProvider).restore();
    _restoreTimer?.cancel();
    _restoreTimer = Timer(const Duration(seconds: 8), () {
      if (state == ProFlow.working) state = ProFlow.restoreNothing;
    });
  }

  Future<void> claimTrial(Plan plan) async {
    final hash = await ref.read(deviceHashProvider.future);
    if (hash == null) {
      state = ProFlow.trialUnavailable;
      return;
    }
    state = ProFlow.working;
    final r = await ref
        .read(planServiceProvider)
        .claimTrial(deviceHash: hash, plan: plan);
    final v = r.value;
    if (v == null) {
      state = r.failure == PlanFailure.offline
          ? ProFlow.offline
          : ProFlow.error;
      return;
    }
    switch (v) {
      case TrialResult.granted:
        await ref.read(entitlementsProvider.notifier).refresh();
        state = ProFlow.success;
      case TrialResult.alreadyUsedDevice:
        state = ProFlow.trialUsedDevice;
      case TrialResult.alreadyUsedAccount:
        state = ProFlow.trialUsedAccount;
      case TrialResult.hasPlan:
        state = ProFlow.trialHasPlan;
      case TrialResult.invalid:
        state = ProFlow.error;
    }
  }

  void reset() => state = ProFlow.idle;
}

/// Birinchi kirishdagi yumshoq taklif ko‘rinishi (sessiya davomida bir marta;
/// ko‘rsatilgach lokal belgi qo‘yiladi — keyingi ishga tushirishda yo‘q).
final proFirstOfferProvider = NotifierProvider<ProFirstOffer, bool>(
  ProFirstOffer.new,
);

class ProFirstOffer extends Notifier<bool> {
  @override
  bool build() {
    final store = ref.read(proOfferStoreProvider);
    if (store.firstOfferShown) return false;
    unawaited(store.markFirstOfferShown());
    return true;
  }

  void dismiss() => state = false;
}

/// Admin: berilgan rejalar ro‘yxati (`''` — hammasi). Xato — `null`.
final adminPlanListProvider = FutureProvider.autoDispose
    .family<List<AdminPlanRow>?, String>((ref, query) async {
      final r = await ref
          .watch(adminPlanServiceProvider)
          .list(query: query.isEmpty ? null : query);
      return r.value;
    });

final adminPlanStatsProvider = FutureProvider.autoDispose<AdminPlanStats?>(
  (ref) async => (await ref.watch(adminPlanServiceProvider).stats()).value,
);
