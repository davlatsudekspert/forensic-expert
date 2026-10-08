import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/learn/study_models.dart';

/// O‘quv rejimi (Leitner qutilari) — faqat qurilmada, serverga yoki
/// telemetriyaga yuborilmaydi.
class SharedPrefsStudyProgressStore implements StudyProgressStore {
  SharedPrefsStudyProgressStore(this._prefs);

  final SharedPreferences _prefs;

  static const _k = 'fe.study.leitner';

  @override
  Map<String, LeitnerCard> load() =>
      StudyProgressCodec.decode(_prefs.getString(_k));

  @override
  Future<void> save(Map<String, LeitnerCard> progress) =>
      _prefs.setString(_k, StudyProgressCodec.encode(progress));
}
