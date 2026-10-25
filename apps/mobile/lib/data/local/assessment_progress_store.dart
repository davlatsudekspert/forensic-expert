import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/assessment/assessment_models.dart';

/// «Bilim va malakani baholash»: tayyor deb belgilangan savollar — faqat
/// qurilmada, serverga yuborilmaydi.
class SharedPrefsAssessmentProgressStore implements AssessmentProgressStore {
  SharedPrefsAssessmentProgressStore(this._prefs);

  final SharedPreferences _prefs;

  static const _k = 'fe.assessment.ready.v1';

  @override
  Set<String> load() => (_prefs.getStringList(_k) ?? const <String>[]).toSet();

  @override
  Future<void> save(Set<String> ready) =>
      _prefs.setStringList(_k, ready.toList()..sort());
}
