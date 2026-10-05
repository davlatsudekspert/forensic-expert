import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/ports/professional_ports.dart';
import '../../domain/professional/professional_models.dart';

/// Profil faqat qurilmada. Malaka hujjatlari bu yerda **saqlanmaydi**.
class SharedPrefsProfileStore implements LocalProfileStore {
  SharedPrefsProfileStore(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'fe.user.profile';

  @override
  Future<LocalUserProfile> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return const LocalUserProfile();
    try {
      final v = jsonDecode(raw);
      if (v is Map) return LocalUserProfile.fromJson(v.cast<String, Object?>());
    } on FormatException {
      // Buzilgan yozuv — bo‘sh profil (ma’lumot to‘qilmaydi).
    }
    return const LocalUserProfile();
  }

  @override
  Future<void> save(LocalUserProfile profile) =>
      _prefs.setString(_key, jsonEncode(profile.toJson()));

  @override
  Future<void> clear() => _prefs.remove(_key);
}

class InMemoryProfileStore implements LocalProfileStore {
  InMemoryProfileStore([this.value = const LocalUserProfile()]);

  LocalUserProfile value;

  @override
  Future<LocalUserProfile> load() async => value;

  @override
  Future<void> save(LocalUserProfile profile) async => value = profile;

  @override
  Future<void> clear() async => value = const LocalUserProfile();
}
