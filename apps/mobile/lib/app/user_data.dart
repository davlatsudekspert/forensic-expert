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

  Future<void> clearSearchHistory() =>
      _set(state.copyWith(recentSearches: const []));
}
