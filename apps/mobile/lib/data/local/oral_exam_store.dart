import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/assessment/oral_exam.dart';

/// Og‘zaki imtihon natijalari va ishlatilgan savollar — bitta JSON qatori,
/// faqat qurilmada (serverga yuborilmaydi).
class SharedPrefsOralExamStore implements OralExamStore {
  SharedPrefsOralExamStore(this._prefs);

  final SharedPreferences _prefs;

  static const _k = 'fe.assessment.oralexam.v1';

  @override
  OralExamData load() {
    final s = _prefs.getString(_k);
    if (s == null) return OralExamData.empty;
    try {
      return OralExamData.fromJson(jsonDecode(s));
    } on Object {
      return OralExamData.empty;
    }
  }

  @override
  Future<void> save(OralExamData data) => _prefs.setString(_k, data.encode());
}
