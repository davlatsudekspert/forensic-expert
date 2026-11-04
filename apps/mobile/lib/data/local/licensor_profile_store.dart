import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/admin/institute_models.dart';
import '../../domain/ports/institute_ports.dart';

/// Litsenziar rekvizitlari — faqat admin qurilmasida (SharedPreferences);
/// kodga yozilmaydi, serverga ketmaydi, faqat shartnoma PDF’iga qo‘yiladi.
class SharedPrefsLicensorProfileStore implements LicensorProfileStore {
  SharedPrefsLicensorProfileStore(this._prefs);

  final SharedPreferences _prefs;

  static const _k = 'fe.admin.licensor_profile';

  @override
  LicensorProfile load() {
    try {
      final raw = _prefs.getString(_k);
      if (raw == null) return LicensorProfile.empty;
      final j = jsonDecode(raw);
      if (j is Map) return LicensorProfile.fromJson(j.cast<String, Object?>());
    } on Object {
      // Buzilgan yozuv: bo‘sh rekvizit (PDF’da bo‘sh chiziqlar).
    }
    return LicensorProfile.empty;
  }

  @override
  Future<void> save(LicensorProfile profile) async {
    if (profile.isEmpty) {
      await _prefs.remove(_k);
      return;
    }
    await _prefs.setString(_k, jsonEncode(profile.toJson()));
  }
}
