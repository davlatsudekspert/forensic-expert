import 'package:shared_preferences/shared_preferences.dart';

/// Foydalanuvchining lokal ma’lumotlari: saralanganlar, so‘nggi vositalar,
/// so‘nggi qidiruvlar. **Faqat qurilmada** saqlanadi, serverga yoki
/// telemetriyaga yuborilmaydi.
abstract interface class UserDataRepository {
  Future<UserDataSnapshot> load();

  Future<void> save(UserDataSnapshot data);
}

class UserDataSnapshot {
  const UserDataSnapshot({
    this.favorites = const [],
    this.recentTools = const [],
    this.recentSearches = const [],
  });

  final List<String> favorites;
  final List<String> recentTools;
  final List<String> recentSearches;

  UserDataSnapshot copyWith({
    List<String>? favorites,
    List<String>? recentTools,
    List<String>? recentSearches,
  }) => UserDataSnapshot(
    favorites: favorites ?? this.favorites,
    recentTools: recentTools ?? this.recentTools,
    recentSearches: recentSearches ?? this.recentSearches,
  );
}

class SharedPrefsUserDataRepository implements UserDataRepository {
  SharedPrefsUserDataRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kFav = 'fe.user.favorites';
  static const _kTools = 'fe.user.recent_tools';
  static const _kSearch = 'fe.user.recent_searches';

  @override
  Future<UserDataSnapshot> load() async => UserDataSnapshot(
    favorites: _prefs.getStringList(_kFav) ?? const [],
    recentTools: _prefs.getStringList(_kTools) ?? const [],
    recentSearches: _prefs.getStringList(_kSearch) ?? const [],
  );

  @override
  Future<void> save(UserDataSnapshot d) async {
    await _prefs.setStringList(_kFav, d.favorites);
    await _prefs.setStringList(_kTools, d.recentTools);
    await _prefs.setStringList(_kSearch, d.recentSearches);
  }
}

class InMemoryUserDataRepository implements UserDataRepository {
  InMemoryUserDataRepository([this.value = const UserDataSnapshot()]);

  UserDataSnapshot value;

  @override
  Future<UserDataSnapshot> load() async => value;

  @override
  Future<void> save(UserDataSnapshot data) async => value = data;
}
