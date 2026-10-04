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

  test('kontrast va yurisdiksiya saqlanadi; standartlar', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = SharedPrefsSettingsRepository(
      await SharedPreferences.getInstance(),
    );
    final initial = await repo.load();
    expect(initial.contrast, ContrastPreference.system);
    expect(initial.jurisdictionId, internationalJurisdictionId);
    await repo.save(
      initial.copyWith(contrast: ContrastPreference.high, jurisdictionId: 'UZ'),
    );
    final s = await SharedPrefsSettingsRepository(
      await SharedPreferences.getInstance(),
    ).load();
    expect(s.contrast, ContrastPreference.high);
    expect(s.jurisdictionId, 'UZ');
  });

  test('noma’lum kontrast qiymati system’ga qaytadi', () async {
    SharedPreferences.setMockInitialValues({'fe.settings.contrast': 'ultra'});
    final repo = SharedPrefsSettingsRepository(
      await SharedPreferences.getInstance(),
    );
    expect((await repo.load()).contrast, ContrastPreference.system);
  });
}
