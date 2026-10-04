import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/user_data.dart';
import 'package:forensic_expert/data/local/user_data_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late InMemoryUserDataRepository repo;
  late ProviderContainer container;
  UserDataController ctl() => container.read(userDataProvider.notifier);
  UserDataSnapshot state() => container.read(userDataProvider);

  setUp(() {
    repo = InMemoryUserDataRepository();
    container = ProviderContainer(
      overrides: [userDataRepositoryProvider.overrideWithValue(repo)],
    );
  });
  tearDown(() => container.dispose());

  test('saralanganlar: qo‘shish va olib tashlash, saqlanadi', () async {
    await ctl().toggleFavorite('tool.lab.dilution');
    await ctl().toggleFavorite('TEST-SUB-ETOH');
    expect(state().favorites, ['TEST-SUB-ETOH', 'tool.lab.dilution']);
    expect(ctl().isFavorite('tool.lab.dilution'), isTrue);
    await ctl().toggleFavorite('tool.lab.dilution');
    expect(state().favorites, ['TEST-SUB-ETOH']);
    expect(repo.value.favorites, ['TEST-SUB-ETOH']);
  });

  test('so‘nggi vositalar: takrorlanmaydi, eng ko‘pi bilan 6 ta', () async {
    for (var i = 0; i < 8; i++) {
      await ctl().recordToolOpened('tool.$i');
    }
    await ctl().recordToolOpened('tool.5');
    expect(state().recentTools.first, 'tool.5');
    expect(state().recentTools, hasLength(UserDataController.maxRecentTools));
    expect(state().recentTools.toSet(), hasLength(6));
  });

  test('qidiruv tarixi: trim, registrsiz dedupe, qisqa so‘rov yozilmaydi, '
      'tozalash', () async {
    await ctl().recordSearch('  Ethanol ');
    await ctl().recordSearch('e');
    await ctl().recordSearch('ETHANOL');
    await ctl().recordSearch('Морфин');
    expect(state().recentSearches, ['Морфин', 'ETHANOL']);
    for (var i = 0; i < 12; i++) {
      await ctl().recordSearch('query $i');
    }
    expect(
      state().recentSearches,
      hasLength(UserDataController.maxRecentSearches),
    );
    await ctl().clearSearchHistory();
    expect(state().recentSearches, isEmpty);
    expect(repo.value.recentSearches, isEmpty);
  });

  test(
    'SharedPreferences repozitoriysi — faqat qurilmadagi kalitlar',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final r = SharedPrefsUserDataRepository(prefs);
      await r.save(
        const UserDataSnapshot(
          favorites: ['a'],
          recentTools: ['b'],
          recentSearches: ['c'],
        ),
      );
      final loaded = await r.load();
      expect(loaded.favorites, ['a']);
      expect(loaded.recentTools, ['b']);
      expect(loaded.recentSearches, ['c']);
      expect(prefs.getKeys(), {
        'fe.user.favorites',
        'fe.user.recent_tools',
        'fe.user.recent_searches',
        'fe.user.completed_lessons',
        'fe.user.recent_lessons',
      });
    },
  );
}
