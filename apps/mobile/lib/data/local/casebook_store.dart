import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/casebook/casebook_models.dart';

/// «Ekspert ish daftari» — faqat qurilmada (SharedPreferences). Serverga,
/// telemetriyaga yoki zaxira nusxaga yuborilmaydi (Android `allowBackup=false`).
class SharedPrefsCasebookStore implements CasebookStore {
  SharedPrefsCasebookStore(this._prefs);

  final SharedPreferences _prefs;

  static const _k = 'fe.casebook.v1';

  @override
  List<CasebookEntry> load() => CasebookCodec.decode(_prefs.getString(_k));

  @override
  Future<void> save(List<CasebookEntry> entries) =>
      _prefs.setString(_k, CasebookCodec.encode(entries));

  @override
  Future<void> clear() => _prefs.remove(_k);
}
