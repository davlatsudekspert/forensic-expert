import 'dart:async';

import '../../domain/auth/auth_models.dart';
import '../../domain/ports/backend_ports.dart';

/// Akkaunt backend’i ulanmagan holat (hozirgi production standarti).
/// Hech qanday tarmoq so‘rovi yubormaydi va hech qachon «muvaffaqiyat»
/// qaytarmaydi — UI «akkaunt xizmati hali ulanmagan» deb ochiq aytadi.
/// Oflayn ilmiy funksiyalar bunga bog‘liq emas.
class OfflineAuthRepository implements AuthRepository {
  const OfflineAuthRepository();

  static const _nc = AuthOutcome.fail(AuthFailure.backendNotConfigured);

  @override
  AuthState get current => AuthState.signedOut;

  @override
  Stream<AuthState> watch() => Stream.value(AuthState.signedOut);

  @override
  bool get isConfigured => false;

  @override
  bool get isTestBackend => false;

  @override
  Future<void> restoreSession() async {}

  @override
  Future<AuthOutcome> requestEmailCode(String email, {String? locale}) async =>
      _nc;

  @override
  Future<AuthOutcome> verifyEmailCode({
    required String email,
    required String code,
  }) async => _nc;

  @override
  Future<AuthOutcome> register({
    required String email,
    required String password,
    required String acceptedTermsVersion,
  }) async => _nc;

  @override
  Future<AuthOutcome> signIn({
    required String email,
    required String password,
  }) async => _nc;

  @override
  Future<AuthOutcome> resendVerification(String email) async => _nc;

  @override
  Future<AuthOutcome> verifyEmail({
    required String email,
    required String code,
  }) async => _nc;

  @override
  Future<AuthOutcome> requestPasswordReset(String email) async => _nc;

  @override
  Future<AuthOutcome> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async => _nc;

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthOutcome> deleteAccount({required String password}) async => _nc;

  @override
  Future<String?> accessToken() async => null;
}

class DisabledSyncRepository implements SyncRepository {
  const DisabledSyncRepository();

  @override
  bool get isAvailable => false;

  @override
  Future<void> syncNow() async {}
}

class DisabledContentUpdateRepository implements ContentUpdateRepository {
  const DisabledContentUpdateRepository();

  @override
  Future<RemoteContentInfo?> checkForUpdate({
    required String? currentVersion,
  }) async => null;
}
