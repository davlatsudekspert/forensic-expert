import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ports/backend_ports.dart';
import '../domain/ports/referral_ports.dart';
import '../domain/referral/referral_models.dart';
import 'providers.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa almashtiriladi.
final referralServiceProvider = Provider<ReferralService>(
  (ref) => const UnconfiguredReferralService(),
);

final referralLinksProvider = Provider<ReferralLinks>(
  (ref) => ReferralLinks.fromEnvironment(),
);

final pendingReferralStoreProvider = Provider<PendingReferralStore>(
  (ref) => InMemoryPendingReferralStore(),
);

/// O‘z referral paneli — kirgan foydalanuvchi uchun, server agregatlari.
final referralDashboardProvider = FutureProvider.autoDispose<ReferralResult>((
  ref,
) async {
  final auth = ref.watch(authStateProvider);
  final svc = ref.watch(referralServiceProvider);
  if (!svc.isConfigured) {
    return const ReferralResult.fail(ReferralFailure.notConfigured);
  }
  if (!auth.signedIn) {
    return const ReferralResult.fail(ReferralFailure.notSignedIn);
  }
  return svc.fetch();
});

/// Kutilayotgan taklif kodi va uni qo‘llash natijasi.
class PendingReferralState {
  const PendingReferralState({this.code, this.lastOutcome});

  final String? code;
  final ReferralClaimOutcome? lastOutcome;
}

final pendingReferralProvider =
    NotifierProvider<PendingReferralController, PendingReferralState>(
      PendingReferralController.new,
    );

/// Deep link yoki qo‘lda kiritilgan kodni saqlaydi; foydalanuvchi kirgach
/// serverga **bir marta** yuboradi. Qaror (VALID/PENDING/rad) — serverda.
class PendingReferralController extends Notifier<PendingReferralState> {
  bool _claiming = false;

  @override
  PendingReferralState build() {
    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.signedIn && !(prev?.signedIn ?? false)) unawaited(claimNow());
    });
    return PendingReferralState(
      code: ref.read(pendingReferralStoreProvider).read(),
    );
  }

  /// Havola yoki kiritilgan kod. Noto‘g‘ri formatli kod e’tiborsiz qoldiriladi.
  Future<bool> remember(String raw) async {
    final code = ReferralCode.normalize(raw);
    if (code == null) return false;
    await ref.read(pendingReferralStoreProvider).write(code);
    state = PendingReferralState(code: code);
    if (ref.read(authStateProvider).signedIn) await claimNow();
    return true;
  }

  Future<ReferralClaimOutcome?> claimNow() async {
    final code = state.code;
    if (code == null || _claiming) return null;
    _claiming = true;
    try {
      final outcome = await ref.read(referralServiceProvider).claim(code);
      if (outcome.terminal) {
        await ref.read(pendingReferralStoreProvider).write(null);
        state = PendingReferralState(lastOutcome: outcome);
      } else {
        state = PendingReferralState(code: code, lastOutcome: outcome);
      }
      if (outcome.accepted) ref.invalidate(referralDashboardProvider);
      return outcome;
    } finally {
      _claiming = false;
    }
  }

  Future<void> discard() async {
    await ref.read(pendingReferralStoreProvider).write(null);
    state = const PendingReferralState();
  }
}
