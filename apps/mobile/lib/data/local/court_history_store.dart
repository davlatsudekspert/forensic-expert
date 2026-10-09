import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/court_prep/court_prep_models.dart';

/// «Sud so‘rog‘i simulyatori» urinishlari tarixi — faqat qurilmada,
/// serverga yoki telemetriyaga yuborilmaydi.
class SharedPrefsCourtHistoryStore implements CourtHistoryStore {
  SharedPrefsCourtHistoryStore(this._prefs);

  final SharedPreferences _prefs;

  static const _k = 'fe.court.history.v1';

  @override
  List<CourtAttempt> load() => CourtHistoryCodec.decode(_prefs.getString(_k));

  @override
  Future<void> save(List<CourtAttempt> attempts) =>
      _prefs.setString(_k, CourtHistoryCodec.encode(attempts));
}
