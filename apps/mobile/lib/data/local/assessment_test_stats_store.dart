import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/assessment/assessment_test_stats.dart';

/// Test statistikasi (blok rekordlari, xatolar, o‘zlashtirilganlar) —
/// bitta JSON qatori, faqat qurilmada.
class SharedPrefsAssessmentTestStatsStore implements AssessmentTestStatsStore {
  SharedPrefsAssessmentTestStatsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _k = 'fe.assessment.teststats.v1';

  @override
  AssessmentTestStats load() {
    final s = _prefs.getString(_k);
    if (s == null) return AssessmentTestStats.empty;
    try {
      return AssessmentTestStats.fromJson(jsonDecode(s));
    } on Object {
      return AssessmentTestStats.empty;
    }
  }

  @override
  Future<void> save(AssessmentTestStats stats) =>
      _prefs.setString(_k, stats.encode());
}
