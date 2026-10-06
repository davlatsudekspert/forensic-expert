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
    this.completedLessons = const [],
    this.recentLessons = const [],
    this.recentlyViewed = const [],
    this.milestones = const [],
  });

  final List<String> favorites;
  final List<String> recentTools;
  final List<String> recentSearches;

  /// Student Mode: tugatilgan darslar va o‘qish tarixi (faqat lokal).
  final List<String> completedLessons;
  final List<String> recentLessons;

  /// So‘nggi ochilgan yozuvlar (modda, metod, research) — faqat lokal.
  final List<String> recentlyViewed;

  /// «Birinchi qadamlar» (masalan `discipline`, `source`, `ai`, `hidden`) —
  /// faqat lokal; hech qanday faollik lentasi yoki telemetriya emas.
  final List<String> milestones;

  UserDataSnapshot copyWith({
    List<String>? favorites,
    List<String>? recentTools,
    List<String>? recentSearches,
    List<String>? completedLessons,
    List<String>? recentLessons,
    List<String>? recentlyViewed,
    List<String>? milestones,
  }) => UserDataSnapshot(
    favorites: favorites ?? this.favorites,
    recentTools: recentTools ?? this.recentTools,
    recentSearches: recentSearches ?? this.recentSearches,
    completedLessons: completedLessons ?? this.completedLessons,
    recentLessons: recentLessons ?? this.recentLessons,
    recentlyViewed: recentlyViewed ?? this.recentlyViewed,
    milestones: milestones ?? this.milestones,
  );
}

class SharedPrefsUserDataRepository implements UserDataRepository {
  SharedPrefsUserDataRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kFav = 'fe.user.favorites';
  static const _kTools = 'fe.user.recent_tools';
  static const _kSearch = 'fe.user.recent_searches';
  static const _kCompleted = 'fe.user.completed_lessons';
  static const _kLessons = 'fe.user.recent_lessons';
  static const _kViewed = 'fe.user.recently_viewed';
  static const _kMilestones = 'fe.user.milestones';

  @override
  Future<UserDataSnapshot> load() async => UserDataSnapshot(
    favorites: _prefs.getStringList(_kFav) ?? const [],
    recentTools: _prefs.getStringList(_kTools) ?? const [],
    recentSearches: _prefs.getStringList(_kSearch) ?? const [],
    completedLessons: _prefs.getStringList(_kCompleted) ?? const [],
    recentLessons: _prefs.getStringList(_kLessons) ?? const [],
    recentlyViewed: _prefs.getStringList(_kViewed) ?? const [],
    milestones: _prefs.getStringList(_kMilestones) ?? const [],
  );

  @override
  Future<void> save(UserDataSnapshot d) async {
    await _prefs.setStringList(_kFav, d.favorites);
    await _prefs.setStringList(_kTools, d.recentTools);
    await _prefs.setStringList(_kSearch, d.recentSearches);
    await _prefs.setStringList(_kCompleted, d.completedLessons);
    await _prefs.setStringList(_kLessons, d.recentLessons);
    await _prefs.setStringList(_kViewed, d.recentlyViewed);
    await _prefs.setStringList(_kMilestones, d.milestones);
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
