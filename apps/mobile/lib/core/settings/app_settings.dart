import 'package:flutter/material.dart';

/// Foydalanuvchi rejimi (19-bo‘lim).
enum UserMode { professional, student, research }

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

@immutable
class AppSettings {
  const AppSettings({
    this.locale,
    this.themeMode = ThemeMode.system,
    this.userMode,
    this.acceptedDisclaimerVersion,
  });

  /// `null` — foydalanuvchi hali til tanlamagan (birinchi ishga tushirish).
  final Locale? locale;
  final ThemeMode themeMode;
  final UserMode? userMode;
  final int? acceptedDisclaimerVersion;

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
  }) => AppSettings(
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    userMode: userMode ?? this.userMode,
    acceptedDisclaimerVersion:
        acceptedDisclaimerVersion ?? this.acceptedDisclaimerVersion,
  );
}
