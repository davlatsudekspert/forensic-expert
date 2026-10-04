import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tokens.dart';

/// Tema kengaytmasi — Material ColorScheme’da yo‘q tokenlar (status ranglari).
@immutable
class FeTheme extends ThemeExtension<FeTheme> {
  const FeTheme(this.colors);

  final FeColorTokens colors;

  static FeColorTokens of(BuildContext context) =>
      Theme.of(context).extension<FeTheme>()!.colors;

  @override
  FeTheme copyWith({FeColorTokens? colors}) => FeTheme(colors ?? this.colors);

  @override
  FeTheme lerp(covariant FeTheme? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

abstract final class FeFonts {
  static const sans = 'Inter';
  static const mono = 'JetBrainsMono';
}

/// Light / Dark mavzularini tokenlardan quradi.
abstract final class FeThemeBuilder {
  static ThemeData light() => _build(FePalette.light, Brightness.light);

  static ThemeData dark() => _build(FePalette.dark, Brightness.dark);

  static ThemeData _build(FeColorTokens c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.brand,
      onPrimary: c.textOnBrand,
      primaryContainer: c.brandContainer,
      onPrimaryContainer: c.textPrimary,
      secondary: c.accent,
      onSecondary: c.onAccent,
      secondaryContainer: c.accentContainer,
      onSecondaryContainer: c.onAccentContainer,
      tertiary: c.accent,
      onTertiary: c.onAccent,
      error: c.danger,
      onError: brightness == Brightness.light ? Colors.white : Colors.black,
      surface: c.background,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerLowest: c.surfaceSunken,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surfaceRaised,
      surfaceContainerHighest: c.surfaceRaised,
      outline: c.borderStrong,
      outlineVariant: c.border,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: FeFonts.sans,
      scaffoldBackgroundColor: c.background,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      extensions: [FeTheme(c)],
    );

    final text = base.textTheme.apply(
      bodyColor: c.textPrimary,
      displayColor: c.textPrimary,
      fontFamily: FeFonts.sans,
    );

    return base.copyWith(
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          side: BorderSide(color: c.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.brand,
          foregroundColor: c.textOnBrand,
          minimumSize: const Size(FeTouch.minTarget * 2, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FeRadius.md),
          ),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          minimumSize: const Size(FeTouch.minTarget, FeTouch.minTarget),
          side: BorderSide(color: c.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FeRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: TextStyle(color: c.textSecondary),
        prefixIconColor: c.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FeSpace.md,
          vertical: FeSpace.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          borderSide: BorderSide(color: c.focusRing, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.accentContainer,
        elevation: 0,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? c.onAccentContainer
                : c.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            fontSize: 11,
            letterSpacing: 0,
            color: states.contains(WidgetState.selected)
                ? c.textPrimary
                : c.textSecondary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        minVerticalPadding: FeSpace.sm,
        contentPadding: const EdgeInsets.symmetric(horizontal: FeSpace.md),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Raqamlar uchun uslub — tabular figures (natijalar ustunlarda tekis).
  static TextStyle numeric(TextStyle base) => base.copyWith(
    fontFamily: FeFonts.mono,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
