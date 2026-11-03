import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/assessment/oral_exam.dart';

/// Og‘zaki imtihon natijalari va ishlatilgan savollar — bitta JSON qatori,
/// faqat qurilmada (serverga yuborilmaydi).
class SharedPrefsOralExamStore implements OralExamStore {
  SharedPrefsOralExamStore(this._prefs, {this.storageKey = assessmentKey});

  final SharedPreferences _prefs;

  /// Mutaxassis: «Bilim va malakani baholash» bileti.
  static const assessmentKey = 'fe.assessment.oralexam.v1';

  /// Ustoz: mavzu bo‘yicha bilet (alohida — aralashmaydi).
  static const teacherKey = 'fe.teacher.oralexam.v1';

  final String storageKey;

  @override
  OralExamData load() {
    final s = _prefs.getString(storageKey);
    if (s == null) return OralExamData.empty;
    try {
      return OralExamData.fromJson(jsonDecode(s));
    } on Object {
      return OralExamData.empty;
    }
  }

  @override
  Future<void> save(OralExamData data) =>
      _prefs.setString(storageKey, data.encode());
}
