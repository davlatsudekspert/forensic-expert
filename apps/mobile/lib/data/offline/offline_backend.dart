import 'dart:async';

import '../../domain/ports/backend_ports.dart';

/// Backend ulanmagan holat (PHASE 1 default va «backend ishlamayapti»
/// ssenariysi). Hech qanday tarmoq so‘rovi yubormaydi.
class OfflineAuthRepository implements AuthRepository {
  const OfflineAuthRepository();

  @override
  AuthState get current => AuthState.signedOut;

  @override
  Stream<AuthState> watch() => Stream.value(AuthState.signedOut);

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {}
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
