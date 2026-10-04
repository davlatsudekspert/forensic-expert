import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

void main() {
  const fresh = AppSettings();
  const langOnly = AppSettings(locale: Locale('ru'));
  const accepted = AppSettings(
    locale: Locale('ru'),
    acceptedDisclaimerVersion: currentDisclaimerVersion,
  );
  const done = AppSettings(
    locale: Locale('ru'),
    acceptedDisclaimerVersion: currentDisclaimerVersion,
    userMode: UserMode.professional,
  );

  test('yangi foydalanuvchi har qanday sahifadan til ekraniga', () {
    for (final loc in [
      Routes.home,
      Routes.profile,
      Routes.disclaimer,
      Routes.mode,
    ]) {
      expect(onboardingRedirect(fresh, loc), Routes.language, reason: loc);
    }
    expect(onboardingRedirect(fresh, Routes.language), isNull);
  });

  test('onboarding qadamlari ketma-ket; orqaga qaytish mumkin', () {
    expect(onboardingRedirect(langOnly, Routes.home), Routes.disclaimer);
    expect(onboardingRedirect(langOnly, Routes.language), isNull);
    expect(onboardingRedirect(langOnly, Routes.mode), Routes.disclaimer);
    expect(onboardingRedirect(accepted, Routes.mode), isNull);
    expect(onboardingRedirect(accepted, Routes.disclaimer), isNull);
  });

  test('onboarding tugagach onboarding sahifalari Home’ga yo‘naltiriladi', () {
    expect(onboardingRedirect(done, Routes.language), Routes.home);
    expect(onboardingRedirect(done, Routes.profile), isNull);
  });

  test('disclaimer versiyasi oshsa qayta tasdiqlash kerak', () {
    const old = AppSettings(
      locale: Locale('en'),
      acceptedDisclaimerVersion: currentDisclaimerVersion - 1,
      userMode: UserMode.student,
    );
    expect(onboardingRedirect(old, Routes.home), Routes.disclaimer);
  });
}
