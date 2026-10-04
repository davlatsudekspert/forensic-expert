import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('sozlamalar saqlanadi va qayta o‘qiladi', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = SharedPrefsSettingsRepository(
      await SharedPreferences.getInstance(),
    );
    expect((await repo.load()).hasLanguage, isFalse);
    await repo.save(
      const AppSettings(
        locale: Locale('uz'),
        themeMode: ThemeMode.dark,
        userMode: UserMode.research,
        acceptedDisclaimerVersion: currentDisclaimerVersion,
      ),
    );
    final again = SharedPrefsSettingsRepository(
      await SharedPreferences.getInstance(),
    );
    final s = await again.load();
    expect(s.locale, const Locale('uz'));
    expect(s.themeMode, ThemeMode.dark);
    expect(s.userMode, UserMode.research);
    expect(s.onboardingComplete, isTrue);
  });

  test('qo‘llab-quvvatlanmaydigan til kodi e’tiborga olinmaydi', () async {
    SharedPreferences.setMockInitialValues({'fe.settings.locale': 'xx'});
    final repo = SharedPrefsSettingsRepository(
      await SharedPreferences.getInstance(),
    );
    expect((await repo.load()).locale, isNull);
  });
}
