/// Akkaunt (identifikatsiya) domeni. Huquq (obuna) — alohida
/// (`billing_ports.dart`): akkaunt bo‘lishi Pro degani emas, Pro esa
/// akkauntsiz ham store orqali bo‘lishi mumkin.
///
/// Minimal ma’lumot: faqat email. Ism, kasb, muassasa, sud-ekspert
/// ma’lumotlari so‘ralmaydi va saqlanmaydi. Parol mijozda saqlanmaydi va
/// jurnalga yozilmaydi.
library;

import 'package:flutter/foundation.dart';

abstract final class EmailAddress {
  static const maxLength = 254;

  static final _pattern = RegExp(
    r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?"
    r'(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+$',
  );

  /// Bo‘shliqlarni olib tashlash va kichik harflarga keltirish (domen
  /// registrga bog‘liq emas; amalda provayderlar local qismni ham shunday
  /// ko‘radi — dublikat akkauntlarning oldini oladi).
  static String normalize(String raw) => raw.trim().toLowerCase();

  static bool isValid(String raw) {
    final e = normalize(raw);
    if (e.isEmpty || e.length > maxLength) return false;
    if (e.contains('..') || e.startsWith('.') || e.contains('.@')) {
      return false;
    }
    final local = e.split('@').first;
    if (local.length > 64) return false;
    return _pattern.hasMatch(e);
  }
}

enum PasswordRule { minLength, maxLength, letter, digit, notEmail }

/// Parol siyosati — UI’da qoidalar ro‘yxati sifatida ko‘rsatiladi.
/// NIST SP 800-63B ruhida: uzunlik asosiy talab, murakkab belgilar
/// majburiy emas; harf + raqam — minimal xilma-xillik.
abstract final class PasswordPolicy {
  static const minLength = 10;
  static const maxLength = 128;

  static const rules = [
    PasswordRule.minLength,
    PasswordRule.letter,
    PasswordRule.digit,
    PasswordRule.notEmail,
  ];

  static bool satisfies(PasswordRule r, String password, {String? email}) =>
      switch (r) {
        PasswordRule.minLength => password.runes.length >= minLength,
        PasswordRule.maxLength => password.runes.length <= maxLength,
        PasswordRule.letter => RegExp(
          r'\p{L}',
          unicode: true,
        ).hasMatch(password),
        PasswordRule.digit => RegExp(r'\d').hasMatch(password),
        PasswordRule.notEmail =>
          email == null ||
              EmailAddress.normalize(email).isEmpty ||
              password.toLowerCase() != EmailAddress.normalize(email) &&
                  password.toLowerCase() !=
                      EmailAddress.normalize(email).split('@').first,
      };

  static List<PasswordRule> violations(String password, {String? email}) => [
    for (final r in [...rules, PasswordRule.maxLength])
      if (!satisfies(r, password, email: email)) r,
  ];

  static bool isAcceptable(String password, {String? email}) =>
      violations(password, email: email).isEmpty;
}

/// Xato kodlari (UI lokalizatsiya qiladi; server matni ko‘rsatilmaydi).
enum AuthFailure {
  invalidEmail,
  weakPassword,
  passwordMismatch,
  termsNotAccepted,

  /// Email yoki parol noto‘g‘ri (qaysi biri — aytilmaydi).
  invalidCredentials,

  /// Parol to‘g‘ri, lekin email hali tasdiqlanmagan.
  emailNotVerified,
  codeInvalid,
  codeExpired,
  alreadyVerified,
  tooManyRequests,
  offline,
  server,

  /// Akkaunt xizmati sozlanmagan (backend ulanmagan) — ochiq aytiladi.
  backendNotConfigured,

  /// Xavfli amal uchun parol qayta kiritilishi kerak.
  requiresRecentLogin,
  notSignedIn,
}

@immutable
class AuthOutcome {
  const AuthOutcome.ok() : failure = null;
  const AuthOutcome.fail(AuthFailure this.failure);

  final AuthFailure? failure;

  bool get ok => failure == null;
}

@immutable
class AuthAccount {
  const AuthAccount({
    required this.userId,
    required this.email,
    required this.emailVerified,
  });

  /// Ichki identifikator (server bergan).
  final String userId;
  final String email;
  final bool emailVerified;
}

/// Tasdiqlash / tiklash kodlarining amal qilish muddati (server bilan bir
/// xil kontrakt; `docs/AUTH_AND_SUBSCRIPTIONS.md`).
abstract final class AuthCodePolicy {
  static const verificationTtl = Duration(hours: 24);
  static const resetTtl = Duration(minutes: 30);

  /// Parolsiz kirish kodi (email OTP) muddati.
  static const otpTtl = Duration(minutes: 10);
  static const resendCooldown = Duration(seconds: 60);
  static const codeLength = 6;

  static bool looksLikeCode(String raw) =>
      RegExp('^\\d{$codeLength}\$').hasMatch(raw.trim());
}

/// Mijoz tomonidagi kirish tekshiruvi (server baribir qayta tekshiradi).
abstract final class AuthInput {
  static AuthFailure? registration({
    required String email,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
  }) {
    if (!EmailAddress.isValid(email)) return AuthFailure.invalidEmail;
    if (!PasswordPolicy.isAcceptable(password, email: email)) {
      return AuthFailure.weakPassword;
    }
    if (password != confirmPassword) return AuthFailure.passwordMismatch;
    if (!termsAccepted) return AuthFailure.termsNotAccepted;
    return null;
  }

  static AuthFailure? newPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (!PasswordPolicy.isAcceptable(password, email: email)) {
      return AuthFailure.weakPassword;
    }
    if (password != confirmPassword) return AuthFailure.passwordMismatch;
    return null;
  }
}
