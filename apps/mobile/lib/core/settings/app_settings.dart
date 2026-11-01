import 'package:flutter/material.dart';

/// Foydalanish rejimi — faqat UI tanlovi. Professional rejim professional
/// maqom tasdiqlanganini **anglatmaydi** (maqom — alohida, server tomonida).
/// `teacher` — o‘qituvchi (egasi topshirig‘i, 2026-10-24): fan → prezentatsiya →
/// har mavzu ostida guruh testi. Darslar serverdagi `teacher` roli bilan ochiladi.
enum UserMode { professional, student, teacher }

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
    this.newUzAlphabet = false,
    this.textScale = 1.0,
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

  /// O‘zbekcha matnni yangi alifboda ko‘rsatish (O‘RQ-1184: ö, ğ, ş, ç, ʼ).
  /// Standart — o‘chiq (qonun 22.04.2027 dan majburiy; egasi qarori,
  /// 2026-11-01). Faqat ko‘rsatish: ma’lumot asl yozuvda qoladi.
  final bool newUzAlphabet;

  /// Ilova ichidagi shrift o‘lchami (egasi talabi, 2026-11-01): telefon
  /// sozlamasiga qo‘shimcha ko‘paytiruvchi — 1.0, 1.15, 1.3.
  final double textScale;

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
    bool? newUzAlphabet,
    double? textScale,
  }) => AppSettings(
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    userMode: userMode ?? this.userMode,
    acceptedDisclaimerVersion:
        acceptedDisclaimerVersion ?? this.acceptedDisclaimerVersion,
    contrast: contrast ?? this.contrast,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    declaredRole: declaredRole ?? this.declaredRole,
    newUzAlphabet: newUzAlphabet ?? this.newUzAlphabet,
    textScale: textScale ?? this.textScale,
  );
}
