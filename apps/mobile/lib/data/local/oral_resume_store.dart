import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/oral_group/oral_group_models.dart';
import '../../domain/ports/oral_group_ports.dart';

/// Oxirgi guruh og‘zaki imtihoni (kod + sessiya id) — faqat shu qurilmada.
class SharedPrefsOralResumeStore implements OralResumeStore {
  SharedPrefsOralResumeStore(this._prefs);

  static const key = 'fe.oralgroup.resume.v1';

  final SharedPreferences _prefs;

  @override
  OralResume? load() {
    final s = _prefs.getString(key);
    if (s == null) return null;
    try {
      final r = OralResume.fromJson(
        (jsonDecode(s) as Map).cast<String, Object?>(),
      );
      return r.sessionId.isEmpty ? null : r;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(OralResume? value) => value == null
      ? _prefs.remove(key)
      : _prefs.setString(key, jsonEncode(value.toJson()));
}
