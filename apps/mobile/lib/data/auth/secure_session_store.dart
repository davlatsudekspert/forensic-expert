import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/ports/backend_ports.dart';

/// Refresh token — iOS Keychain (`first_unlock_this_device`, iCloud’ga
/// sinxronlanmaydi) / Android Keystore bilan shifrlangan saqlash.
/// SharedPreferences ishlatilmaydi; token jurnalga yozilmaydi.
class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  static const _key = 'fe.auth.refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(String refreshToken) =>
      _storage.write(key: _key, value: refreshToken);

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } on Object {
      // Saqlash xatosi — sessiya baribir bekor (xotirada token yo‘q).
    }
  }
}
