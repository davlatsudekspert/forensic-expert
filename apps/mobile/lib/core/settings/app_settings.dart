import 'package:flutter/material.dart';

/// Foydalanish rejimi — faqat UI tanlovi. Professional rejim professional
/// maqom tasdiqlanganini **anglatmaydi** (maqom — alohida, server tomonida).
enum UserMode { professional, student }

/// Kontrast afzalligi. `system` — OS sozlamasini hurmat qiladi
/// (iOS «Increase Contrast», Android yuqori kontrastli matn).
enum ContrastPreference { system, standard, high }

/// Qo‘llab-quvvatlanadigan UI tillari. Yangi til qo‘shish: ARB fayl +
/// shu ro‘yxatga kod. Arxitektura RTL (arab) uchun tayyor —
/// `Directionality` MaterialApp tomonidan avtomatik boshqariladi.
abstract final class SupportedLanguages {
  static const codes = <String>['en', 'ru', 'uz'];

  static const locales = <Locale>[Locale('en'), Locale('ru'), Locale('uz')];

  static Locale? tryParse(String? code) =>
      code != null && codes.contains(code) ? Locale(code) : null;
}

/// Disclaimer matni o‘zgarsa, versiya oshiriladi — foydalanuvchi qayta
/// tasdiqlaydi.
const currentDisclaimerVersion = 1;

/// Standart yurisdiksiya — «Xalqaro» (faqat Global Scientific Core).
const internationalJurisdictionId = 'INT';

@immutable
class AppSettings {
  const AppSettings({
    this.locale,
    this.themeMode = ThemeMode.system,
    this.userMode,
    this.acceptedDisclaimerVersion,
    this.contrast = ContrastPreference.system,
    this.jurisdictionId = internationalJurisdictionId,
    this.declaredRole,
  });

  /// `null` — foydalanuvchi hali til tanlamagan (birinchi ishga tushirish).
  final Locale? locale;
  final ThemeMode themeMode;
  final UserMode? userMode;
  final int? acceptedDisclaimerVersion;
  final ContrastPreference contrast;

  /// Tanlangan yurisdiksiya (`INT`, `UZ`, `US-CA`…). Faqat huquqiy va
  /// protsedura qatlamiga ta’sir qiladi — ilmiy dalillar hamma uchun bir xil.
  final String jurisdictionId;

  /// Onboarding’da tanlangan kichik rol (`StudentRole` / `ProfessionalRole`
  /// nomi). Faqat UI’ni moslashtiradi — hech qanday huquq bermaydi.
  final String? declaredRole;

  bool get hasLanguage => locale != null;

  bool get disclaimerAccepted =>
      acceptedDisclaimerVersion == currentDisclaimerVersion;

  bool get onboardingComplete =>
      hasLanguage && disclaimerAccepted && userMode != null;

  AppSettings copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    UserMode? userMode,
    int? acceptedDisclaimerVersion,
    ContrastPreference? contrast,
    String? jurisdictionId,
    String? declaredRole,
  }) => AppSettings(
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    userMode: userMode ?? this.userMode,
    acceptedDisclaimerVersion:
        acceptedDisclaimerVersion ?? this.acceptedDisclaimerVersion,
    contrast: contrast ?? this.contrast,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    declaredRole: declaredRole ?? this.declaredRole,
  );
}
