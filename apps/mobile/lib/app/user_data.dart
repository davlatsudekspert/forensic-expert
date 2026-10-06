import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/user_data_repository.dart';

/// Bootstrap’da (yoki testda) override qilinadi.
final userDataRepositoryProvider = Provider<UserDataRepository>(
  (ref) => InMemoryUserDataRepository(),
);

final initialUserDataProvider = Provider<UserDataSnapshot>(
  (ref) => const UserDataSnapshot(),
);

final userDataProvider = NotifierProvider<UserDataController, UserDataSnapshot>(
  UserDataController.new,
);

/// Saralanganlar, so‘nggi vositalar va qidiruv tarixi (faqat lokal).
class UserDataController extends Notifier<UserDataSnapshot> {
  static const maxRecentTools = 6;
  static const maxRecentSearches = 8;

  @override
  UserDataSnapshot build() => ref.read(initialUserDataProvider);

  Future<void> _set(UserDataSnapshot next) async {
    state = next;
    await ref.read(userDataRepositoryProvider).save(next);
  }

  bool isFavorite(String id) => state.favorites.contains(id);

  Future<void> toggleFavorite(String id) => _set(
    state.copyWith(
      favorites: isFavorite(id)
          ? [
              for (final f in state.favorites)
                if (f != id) f,
            ]
          : [id, ...state.favorites],
    ),
  );

  Future<void> recordToolOpened(String id) => _set(
    state.copyWith(
      recentTools: [
        id,
        for (final t in state.recentTools)
          if (t != id) t,
      ].take(maxRecentTools).toList(),
    ),
  );

  Future<void> recordSearch(String query) async {
    final q = query.trim();
    if (q.length < 2) return;
    await _set(
      state.copyWith(
        recentSearches: [
          q,
          for (final s in state.recentSearches)
            if (s.toLowerCase() != q.toLowerCase()) s,
        ].take(maxRecentSearches).toList(),
      ),
    );
  }

  static const maxRecentLessons = 10;

  bool isLessonCompleted(String id) => state.completedLessons.contains(id);

  Future<void> toggleLessonCompleted(String id) => _set(
    state.copyWith(
      completedLessons: isLessonCompleted(id)
          ? [
              for (final x in state.completedLessons)
                if (x != id) x,
            ]
          : [...state.completedLessons, id],
    ),
  );

  Future<void> recordLessonOpened(String id) => _set(
    state.copyWith(
      recentLessons: [
        id,
        for (final x in state.recentLessons)
          if (x != id) x,
      ].take(maxRecentLessons).toList(),
    ),
  );

  static const maxRecentlyViewed = 8;

  /// Yozuv ochildi (faqat ID; matn yoki holat ma’lumoti saqlanmaydi).
  Future<void> recordViewed(String id) => _set(
    state.copyWith(
      recentlyViewed: [
        id,
        for (final x in state.recentlyViewed)
          if (x != id) x,
      ].take(maxRecentlyViewed).toList(),
    ),
  );

  /// Birinchi qadam bajarildi (idempotent, faqat lokal).
  Future<void> recordMilestone(String id) async {
    if (state.milestones.contains(id)) return;
    await _set(state.copyWith(milestones: [...state.milestones, id]));
  }

  Future<void> clearSearchHistory() =>
      _set(state.copyWith(recentSearches: const []));

  /// PHASE 11: qurilmadagi barcha shaxsiy ma’lumotni o‘chirish
  /// (saralanganlar, tarix, darslar). Akkaunt tizimi yo‘q — serverda
  /// foydalanuvchi ma’lumoti saqlanmaydi.
  Future<void> deleteAllLocalData() => _set(const UserDataSnapshot());
}
