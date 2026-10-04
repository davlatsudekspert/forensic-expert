import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings.dart';
import 'settings_repository.dart';

/// Ishga tushishda yuklangan sozlamalar va repozitoriy (bootstrap override qiladi).
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => throw UnimplementedError('Overridden in bootstrap'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError('Overridden in bootstrap'),
);

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<void> _update(AppSettings next) async {
    state = next;
    await _repo.save(next);
  }

  Future<void> setLocale(Locale locale) =>
      _update(state.copyWith(locale: locale));

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  Future<void> setUserMode(UserMode mode) =>
      _update(state.copyWith(userMode: mode));

  Future<void> acceptDisclaimer() => _update(
    state.copyWith(acceptedDisclaimerVersion: currentDisclaimerVersion),
  );
}
