import 'package:flutter/material.dart';

/// FORENSIC EXPERT dizayn tokenlari — «Scientific Luxury».
///
/// Palitra: grafit / deyarli qora qatlamlar (qorong‘i), fil suyagi (yorug‘),
/// iliq fil suyagi matn va **bitta** vazmin aksent — xira shampan oltini.
/// Oltin faqat tanlangan holat, asosiy ta’kid va premium detallarda
/// ishlatiladi (hamma joyda emas). Barcha matn/fon juftliklari WCAG 2.2 AA
/// (≥ 4.5:1), ikonka/chegara juftliklari ≥ 3:1 — avtomatik test bilan
/// tekshiriladi (`test/unit/contrast_test.dart`).
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
    required this.accentBorder,
    required this.verified,
    required this.reviewed,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.outdated,
    required this.danger,
    required this.focusRing,
  });

  /// Sahifa foni (qorong‘ida grafit, yorug‘da fil suyagi).
  final Color background;

  /// Ikkilamchi fon — bo‘limlar, sarlavha paneli, tonal bloklar.
  final Color surface;

  /// Karta sirti.
  final Color surfaceRaised;
  final Color surfaceSunken;

  /// Juda nozik, past kontrastli ajratuvchi chegara (bezak).
  final Color border;

  /// Ma’noli chegara (input, tugma) — fonga nisbatan ≥ 3:1.
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnBrand;
  final Color brand;
  final Color brandContainer;

  /// Shampan oltini (qorong‘i) / iliq bronza (yorug‘). Matn sifatida ham
  /// ≥ 4.5:1.
  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color onAccentContainer;

  /// Premium detallar uchun ingichka oltin chiziq (bezak, ma’no tashimaydi).
  final Color accentBorder;
  final Color verified;
  final Color reviewed;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color outdated;
  final Color danger;
  final Color focusRing;

  /// Kontrast testi uchun: (oldingi rang, fon, tavsif) — matn, ≥ 4.5:1.
  List<(Color, Color, String)> get textPairs => [
    (textPrimary, background, 'textPrimary/background'),
    (textPrimary, surface, 'textPrimary/surface'),
    (textPrimary, surfaceRaised, 'textPrimary/surfaceRaised'),
    (textSecondary, background, 'textSecondary/background'),
    (textSecondary, surface, 'textSecondary/surface'),
    (textSecondary, surfaceRaised, 'textSecondary/surfaceRaised'),
    (textOnBrand, brand, 'textOnBrand/brand'),
    (accent, background, 'accent/background'),
    (accent, surface, 'accent/surface'),
    (accent, surfaceRaised, 'accent/surfaceRaised'),
    (onAccent, accent, 'onAccent/accent'),
    (onAccentContainer, accentContainer, 'onAccentContainer/accentContainer'),
    (textPrimary, accentContainer, 'textPrimary/accentContainer'),
    (verified, background, 'verified/background'),
    (reviewed, background, 'reviewed/background'),
    (onWarningContainer, warningContainer, 'onWarning/warningContainer'),
    (outdated, background, 'outdated/background'),
    (danger, background, 'danger/background'),
  ];

  /// Ikonka va ma’noli chegaralar (WCAG 1.4.11, ≥ 3:1).
  List<(Color, Color, String)> get uiPairs => [
    (borderStrong, background, 'borderStrong/background'),
    (borderStrong, surfaceRaised, 'borderStrong/surfaceRaised'),
    (accent, surfaceRaised, 'accent icon/surfaceRaised'),
    (focusRing, background, 'focusRing/background'),
    (focusRing, surfaceRaised, 'focusRing/surfaceRaised'),
  ];
}

abstract final class FePalette {
  // Fil suyagi sahifa, oq kartalar, grafit matn, iliq bronza aksent.
  static const light = FeColorTokens(
    background: Color(0xFFF7F5EF),
    surface: Color(0xFFEFECE4),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFE8E4DA),
    border: Color(0xFFE3DED3),
    borderStrong: Color(0xFF85807A),
    textPrimary: Color(0xFF161B22),
    textSecondary: Color(0xFF525A66),
    textOnBrand: Color(0xFFFFFFFF),
    brand: Color(0xFF1A212C),
    brandContainer: Color(0xFFE9E6DE),
    accent: Color(0xFF7D5F27),
    onAccent: Color(0xFFFFFFFF),
    accentContainer: Color(0xFFF3EBD8),
    onAccentContainer: Color(0xFF4A3810),
    accentBorder: Color(0xFFD9C9A3),
    verified: Color(0xFF1B6E47),
    reviewed: Color(0xFF2350A0),
    warning: Color(0xFF8A5A00),
    warningContainer: Color(0xFFFFF3D6),
    onWarningContainer: Color(0xFF5C3B00),
    outdated: Color(0xFF5B6575),
    danger: Color(0xFFB42318),
    focusRing: Color(0xFF7D5F27),
  );

  // Grafit / deyarli qora qatlamlar, iliq fil suyagi matn, shampan oltini.
  static const dark = FeColorTokens(
    background: Color(0xFF0B1017),
    surface: Color(0xFF121A25),
    surfaceRaised: Color(0xFF192332),
    surfaceSunken: Color(0xFF080C12),
    border: Color(0xFF253042),
    borderStrong: Color(0xFF6B7789),
    textPrimary: Color(0xFFF4F4F1),
    textSecondary: Color(0xFF9AA4B2),
    textOnBrand: Color(0xFF0B1017),
    brand: Color(0xFFE8E4DA),
    brandContainer: Color(0xFF1E2A3B),
    accent: Color(0xFFC8A86B),
    onAccent: Color(0xFF0B1017),
    accentContainer: Color(0xFF2A2417),
    onAccentContainer: Color(0xFFE9D3A6),
    accentBorder: Color(0xFF4A3F2B),
    verified: Color(0xFF6ED3A0),
    reviewed: Color(0xFF8AB4F8),
    warning: Color(0xFFF2C14E),
    warningContainer: Color(0xFF3A2B05),
    onWarningContainer: Color(0xFFFFE3A3),
    outdated: Color(0xFF9AA4B2),
    danger: Color(0xFFF97066),
    focusRing: Color(0xFFC8A86B),
  );

  /// Yuqori kontrast (light) — barcha matn juftliklari ≥ 7:1 (WCAG AAA),
  /// chegaralar to‘q. OS «Increase contrast» yoki ilova sozlamasi bilan.
  static const lightHighContrast = FeColorTokens(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF2F0EA),
    border: Color(0xFF3D4450),
    borderStrong: Color(0xFF0B1017),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF1F252E),
    textOnBrand: Color(0xFFFFFFFF),
    brand: Color(0xFF0B1017),
    brandContainer: Color(0xFFE2DFD6),
    accent: Color(0xFF5A4314),
    onAccent: Color(0xFFFFFFFF),
    accentContainer: Color(0xFFF2E6CC),
    onAccentContainer: Color(0xFF2B1F05),
    accentBorder: Color(0xFF5A4314),
    verified: Color(0xFF0B4A2E),
    reviewed: Color(0xFF12336E),
    warning: Color(0xFF573700),
    warningContainer: Color(0xFFFFEBB8),
    onWarningContainer: Color(0xFF331F00),
    outdated: Color(0xFF2E3542),
    danger: Color(0xFF7A140D),
    focusRing: Color(0xFF5A4314),
  );

  /// Yuqori kontrast (dark) — barcha matn juftliklari ≥ 7:1 (WCAG AAA).
  static const darkHighContrast = FeColorTokens(
    background: Color(0xFF000000),
    surface: Color(0xFF06090D),
    surfaceRaised: Color(0xFF0D131B),
    surfaceSunken: Color(0xFF000000),
    border: Color(0xFFBFC6D0),
    borderStrong: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFE0E4EA),
    textOnBrand: Color(0xFF000000),
    brand: Color(0xFFF7F5EF),
    brandContainer: Color(0xFF1E2733),
    accent: Color(0xFFE6CF9C),
    onAccent: Color(0xFF000000),
    accentContainer: Color(0xFF2E2410),
    onAccentContainer: Color(0xFFFFF3DA),
    accentBorder: Color(0xFFE6CF9C),
    verified: Color(0xFFA6F0C9),
    reviewed: Color(0xFFC2D8FF),
    warning: Color(0xFFFFDA85),
    warningContainer: Color(0xFF2B1F00),
    onWarningContainer: Color(0xFFFFF0CC),
    outdated: Color(0xFFE0E4EA),
    danger: Color(0xFFFFB4AB),
    focusRing: Color(0xFFE6CF9C),
  );
}

/// Brend (logotip) ranglari — `design/brand/source/logo_original.webp` dan
/// o‘lchangan (docs/BRAND.md). UI palitrasi ([FePalette]) o‘zgarmaydi:
/// bular faqat emblema, wordmark va splash/ikon fonlari uchun.
abstract final class FeBrand {
  /// Qalqon ichi va «FORENSIC» so‘zi.
  static const navy = Color(0xFF021A31);

  /// Qorong‘i fonda qalqon ichi (grafitda yo‘qolmasligi uchun ochroq).
  static const navyLifted = Color(0xFF102C52);

  /// App icon fon gradienti (markaz → chekka).
  static const navyIconCenter = Color(0xFF173155);
  static const navyIconEdge = Color(0xFF061224);

  /// Metall oltin hoshiya (o‘rta ton) — faqat bezak.
  static const goldMetal = Color(0xFFD0B076);

  /// «EXPERT» oltini: yorug‘ fonda (yirik matn, ≥ 3:1) va to‘q fonda.
  static const goldOnLight = Color(0xFFAB864B);
  static const goldOnDark = Color(0xFFD0B076);

  /// DNK spirali (emblemada, xira).
  static const dnaBlue = Color(0xFF3F6381);

  /// To‘q fonda wordmark (= dark textPrimary).
  static const ivory = Color(0xFFF4F4F1);
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

  /// Kartalar — bitta radius butun ilovada.
  static const double card = 14;
  static const double lg = 16;

  /// Brend «hero» panellari (Home, AI, Profil sarlavhasi).
  static const double hero = 24;
}

/// Yengil soya — faqat yorug‘ mavzuda (qorong‘ida tonal sirtlar).
abstract final class FeShadow {
  static List<BoxShadow> card(Brightness b) => b == Brightness.dark
      ? const []
      : const [
          BoxShadow(
            color: Color(0x0F161B22),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x08161B22),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ];
}

/// Fanlar uchun vazmin, ammo farqlanadigan ranglar (bitta tizim ichida).
/// Har biri (ikonka, fon) juftligi; qorong‘i mavzu uchun alohida.
@immutable
class FeHue {
  const FeHue(this.lightFg, this.lightBg, this.darkFg, this.darkBg);

  final Color lightFg;
  final Color lightBg;
  final Color darkFg;
  final Color darkBg;

  Color fg(Brightness b) => b == Brightness.dark ? darkFg : lightFg;
  Color bg(Brightness b) => b == Brightness.dark ? darkBg : lightBg;
}

abstract final class FeHues {
  /// Ilmiy teal — asosiy.
  static const teal = FeHue(
    Color(0xFF0A6F7A),
    Color(0xFFE0F2F4),
    Color(0xFF7FDDE6),
    Color(0xFF0E3A40),
  );

  /// Institutsional indigo — sud tibbiyoti, huquq.
  static const indigo = FeHue(
    Color(0xFF2F4A8A),
    Color(0xFFE6EBF7),
    Color(0xFFA9BCF0),
    Color(0xFF1C2A4D),
  );

  /// Vazmin plum — toksikologiya.
  static const plum = FeHue(
    Color(0xFF6B3E78),
    Color(0xFFF2E9F5),
    Color(0xFFD6B3E2),
    Color(0xFF33223D),
  );

  /// Grafit-moviy — laboratoriya, metodlar.
  static const slate = FeHue(
    Color(0xFF3E5873),
    Color(0xFFE8EEF4),
    Color(0xFFB4C6D9),
    Color(0xFF1E2C3B),
  );

  /// Mo‘tadil yashil — biokimyo, gistologiya.
  static const sage = FeHue(
    Color(0xFF2F6B4F),
    Color(0xFFE5F1EA),
    Color(0xFF9FD8B9),
    Color(0xFF173528),
  );

  /// Vazmin oltin — ta’lim, tadqiqot (juda kam ishlatiladi).
  static const ochre = FeHue(
    Color(0xFF7A5A12),
    Color(0xFFF6EFDD),
    Color(0xFFE5C77A),
    Color(0xFF382A0B),
  );
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
