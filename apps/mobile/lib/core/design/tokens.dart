import 'package:flutter/material.dart';

/// FORENSIC EXPERT dizayn tokenlari.
///
/// Palitra: Deep Navy · Graphite · White · Cool Gray + bitta vazmin ilmiy
/// accent (Spectral Teal). Barcha matn/fon juftliklari WCAG 2.2 AA
/// (≥ 4.5:1) talabiga avtomatik test bilan tekshiriladi
/// (`test/unit/contrast_test.dart`).
@immutable
class FeColorTokens {
  const FeColorTokens({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnBrand,
    required this.brand,
    required this.brandContainer,
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.verified,
    required this.reviewed,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.outdated,
    required this.danger,
    required this.focusRing,
  });

  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnBrand;
  final Color brand;
  final Color brandContainer;
  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color onAccentContainer;
  final Color verified;
  final Color reviewed;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color outdated;
  final Color danger;
  final Color focusRing;

  /// Kontrast testi uchun: (oldingi rang, fon, tavsif).
  List<(Color, Color, String)> get textPairs => [
    (textPrimary, background, 'textPrimary/background'),
    (textPrimary, surface, 'textPrimary/surface'),
    (textPrimary, surfaceRaised, 'textPrimary/surfaceRaised'),
    (textSecondary, background, 'textSecondary/background'),
    (textSecondary, surface, 'textSecondary/surface'),
    (textOnBrand, brand, 'textOnBrand/brand'),
    (accent, background, 'accent/background'),
    (accent, surface, 'accent/surface'),
    (onAccent, accent, 'onAccent/accent'),
    (onAccentContainer, accentContainer, 'onAccentContainer/accentContainer'),
    (verified, background, 'verified/background'),
    (reviewed, background, 'reviewed/background'),
    (onWarningContainer, warningContainer, 'onWarning/warningContainer'),
    (outdated, background, 'outdated/background'),
    (danger, background, 'danger/background'),
  ];
}

abstract final class FePalette {
  static const light = FeColorTokens(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF4F6F9),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFE9EDF2),
    border: Color(0xFFD9DFE7),
    borderStrong: Color(0xFF8A95A6),
    textPrimary: Color(0xFF0B1220),
    textSecondary: Color(0xFF4A5568),
    textOnBrand: Color(0xFFFFFFFF),
    brand: Color(0xFF0F1E3D),
    brandContainer: Color(0xFFE3E8F1),
    accent: Color(0xFF0A6F7A),
    onAccent: Color(0xFFFFFFFF),
    accentContainer: Color(0xFFE0F2F4),
    onAccentContainer: Color(0xFF053E45),
    verified: Color(0xFF1B6E47),
    reviewed: Color(0xFF2350A0),
    warning: Color(0xFF8A5A00),
    warningContainer: Color(0xFFFFF3D6),
    onWarningContainer: Color(0xFF5C3B00),
    outdated: Color(0xFF5B6575),
    danger: Color(0xFFB42318),
    focusRing: Color(0xFF0A6F7A),
  );

  static const dark = FeColorTokens(
    background: Color(0xFF0A101C),
    surface: Color(0xFF111A2B),
    surfaceRaised: Color(0xFF172235),
    surfaceSunken: Color(0xFF070C16),
    border: Color(0xFF26324A),
    borderStrong: Color(0xFF66738A),
    textPrimary: Color(0xFFE8ECF2),
    textSecondary: Color(0xFFA3AEC0),
    textOnBrand: Color(0xFF0B1220),
    brand: Color(0xFFDCE3EE),
    brandContainer: Color(0xFF1C2A44),
    accent: Color(0xFF4CC9D6),
    onAccent: Color(0xFF04262B),
    accentContainer: Color(0xFF0E3A40),
    onAccentContainer: Color(0xFFBDEFF4),
    verified: Color(0xFF6ED3A0),
    reviewed: Color(0xFF8AB4F8),
    warning: Color(0xFFF2C14E),
    warningContainer: Color(0xFF3A2B05),
    onWarningContainer: Color(0xFFFFE3A3),
    outdated: Color(0xFFA3AEC0),
    danger: Color(0xFFF97066),
    focusRing: Color(0xFF4CC9D6),
  );

  /// Yuqori kontrast (light) — barcha matn juftliklari ≥ 7:1 (WCAG AAA),
  /// chegaralar to‘q. OS «Increase contrast» yoki ilova sozlamasi bilan.
  static const lightHighContrast = FeColorTokens(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF0F2F5),
    border: Color(0xFF3D4757),
    borderStrong: Color(0xFF0B1220),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF1F2937),
    textOnBrand: Color(0xFFFFFFFF),
    brand: Color(0xFF071230),
    brandContainer: Color(0xFFD5DCEA),
    accent: Color(0xFF00474F),
    onAccent: Color(0xFFFFFFFF),
    accentContainer: Color(0xFFCDEBEE),
    onAccentContainer: Color(0xFF00262B),
    verified: Color(0xFF0B4A2E),
    reviewed: Color(0xFF12336E),
    warning: Color(0xFF573700),
    warningContainer: Color(0xFFFFEBB8),
    onWarningContainer: Color(0xFF331F00),
    outdated: Color(0xFF2E3542),
    danger: Color(0xFF7A140D),
    focusRing: Color(0xFF00474F),
  );

  /// Yuqori kontrast (dark) — barcha matn juftliklari ≥ 7:1 (WCAG AAA).
  static const darkHighContrast = FeColorTokens(
    background: Color(0xFF000000),
    surface: Color(0xFF05080F),
    surfaceRaised: Color(0xFF0B111D),
    surfaceSunken: Color(0xFF000000),
    border: Color(0xFFB8C2D3),
    borderStrong: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFDDE3EC),
    textOnBrand: Color(0xFF000000),
    brand: Color(0xFFF2F5FA),
    brandContainer: Color(0xFF1A2640),
    accent: Color(0xFF8FE6EE),
    onAccent: Color(0xFF000000),
    accentContainer: Color(0xFF003A40),
    onAccentContainer: Color(0xFFE6FBFD),
    verified: Color(0xFFA6F0C9),
    reviewed: Color(0xFFC2D8FF),
    warning: Color(0xFFFFDA85),
    warningContainer: Color(0xFF2B1F00),
    onWarningContainer: Color(0xFFFFF0CC),
    outdated: Color(0xFFDDE3EC),
    danger: Color(0xFFFFB4AB),
    focusRing: Color(0xFF8FE6EE),
  );
}

/// Masofa shkalasi — 4 pt grid.
abstract final class FeSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class FeRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

/// Harakat davomiyliklari. Reduced motion yoqilganda nolga tushiriladi.
abstract final class FeMotion {
  static const fast = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 220);

  static Duration of(BuildContext context, Duration d) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false ? Duration.zero : d;
}

/// Minimal bosiladigan maydon — Material va Apple HIG talablariga mos.
abstract final class FeTouch {
  static const double minTarget = 48;
}

/// Tildan mustaqil tipografik belgilar (matn emas — lokalizatsiya talab
/// qilmaydi).
abstract final class FeGlyphs {
  static const emDash = '—';
  static const bullet = '•  ';
  static const middleDot = ' · ';
  static const listSeparator = ', ';
}
