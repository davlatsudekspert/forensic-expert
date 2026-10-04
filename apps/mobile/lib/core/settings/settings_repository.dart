import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

/// Sozlamalarni saqlash kontrakti (testda xotiradagi implementatsiya).
abstract interface class SettingsRepository {
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);
}

/// Qurilmada saqlash (SharedPreferences). Sezgir ma’lumot saqlanmaydi.
class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kLocale = 'fe.settings.locale';
  static const _kTheme = 'fe.settings.theme';
  static const _kMode = 'fe.settings.mode';
  static const _kDisclaimer = 'fe.settings.disclaimer_version';

  @override
  Future<AppSettings> load() async => AppSettings(
    locale: SupportedLanguages.tryParse(_prefs.getString(_kLocale)),
    themeMode:
        ThemeMode.values.asNameMap()[_prefs.getString(_kTheme)] ??
        ThemeMode.system,
    userMode: UserMode.values.asNameMap()[_prefs.getString(_kMode)],
    acceptedDisclaimerVersion: _prefs.getInt(_kDisclaimer),
  );

  @override
  Future<void> save(AppSettings s) async {
    final locale = s.locale;
    if (locale != null) await _prefs.setString(_kLocale, locale.languageCode);
    await _prefs.setString(_kTheme, s.themeMode.name);
    final mode = s.userMode;
    if (mode != null) await _prefs.setString(_kMode, mode.name);
    final d = s.acceptedDisclaimerVersion;
    if (d != null) await _prefs.setInt(_kDisclaimer, d);
  }
}

/// Testlar va preview uchun.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this._value = const AppSettings()]);

  AppSettings _value;

  AppSettings get value => _value;

  @override
  Future<AppSettings> load() async => _value;

  @override
  Future<void> save(AppSettings settings) async => _value = settings;
}
