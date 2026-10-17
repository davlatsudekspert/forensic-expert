import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tokens.dart';

/// Tema kengaytmasi — Material ColorScheme’da yo‘q tokenlar (status ranglari).
@immutable
class FeTheme extends ThemeExtension<FeTheme> {
  const FeTheme(this.colors, {this.highContrast = false});

  final FeColorTokens colors;

  /// Yuqori kontrast rejimi faolmi (chegaralar qalinroq, AAA ranglar).
  final bool highContrast;

  static bool isHighContrast(BuildContext context) =>
      Theme.of(context).extension<FeTheme>()!.highContrast;

  static FeColorTokens of(BuildContext context) =>
      Theme.of(context).extension<FeTheme>()!.colors;

  @override
  FeTheme copyWith({FeColorTokens? colors, bool? highContrast}) => FeTheme(
    colors ?? this.colors,
    highContrast: highContrast ?? this.highContrast,
  );

  @override
  FeTheme lerp(covariant FeTheme? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

/// Ilovaga qo‘shilgan (offline) shriftlar — hammasi SIL OFL 1.1.
///
/// * [serif] — Source Serif 4: display/headline/title (jurnal uslubi).
/// * [sans] — Inter: asosiy matn, interfeys yorliqlari.
/// * [mono] — JetBrains Mono: formulalar, kodlar, aniq raqamlar.
abstract final class FeFonts {
  static const serif = 'SourceSerif4';
  static const sans = 'Inter';
  static const mono = 'JetBrainsMono';

  /// JetBrains Mono’da yo‘q belgilar (masalan, «ʻ», «Ҳ») Inter’dan olinadi.
  static const monoFallback = [sans];
}

/// Light / Dark mavzularini tokenlardan quradi.
abstract final class FeThemeBuilder {
  static ThemeData light() => _build(FePalette.light, Brightness.light);

  static ThemeData lightHighContrast() =>
      _build(FePalette.lightHighContrast, Brightness.light, highContrast: true);

  static ThemeData darkHighContrast() =>
      _build(FePalette.darkHighContrast, Brightness.dark, highContrast: true);

  static ThemeData dark() => _build(FePalette.dark, Brightness.dark);

  static ThemeData _build(
    FeColorTokens c,
    Brightness brightness, {
    bool highContrast = false,
  }) {
    final borderWidth = highContrast ? 1.5 : 1.0;
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
      extensions: [FeTheme(c, highContrast: highContrast)],
    );

    final sansText = base.textTheme.apply(
      bodyColor: c.textPrimary,
      displayColor: c.textPrimary,
      fontFamily: FeFonts.sans,
    );
    // Jurnal uslubidagi serif — faqat display / headline / katta title.
    TextStyle? serif(TextStyle? s, {double tracking = -0.2, double? h}) =>
        s?.copyWith(
          fontFamily: FeFonts.serif,
          fontWeight: FontWeight.w600,
          letterSpacing: tracking,
          height: h,
        );
    final text = sansText.copyWith(
      displayLarge: serif(sansText.displayLarge, tracking: -0.8, h: 1.12),
      displayMedium: serif(sansText.displayMedium, tracking: -0.6, h: 1.14),
      displaySmall: serif(sansText.displaySmall, tracking: -0.4, h: 1.18),
      headlineLarge: serif(sansText.headlineLarge, tracking: -0.4, h: 1.2),
      headlineMedium: serif(sansText.headlineMedium, tracking: -0.3, h: 1.22),
      headlineSmall: serif(sansText.headlineSmall, tracking: -0.2, h: 1.25),
      titleLarge: serif(sansText.titleLarge, tracking: -0.1, h: 1.27),
      titleMedium: serif(sansText.titleMedium, tracking: 0, h: 1.3),
      titleSmall: sansText.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: sansText.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: sansText.bodyMedium?.copyWith(height: 1.45),
      labelLarge: sansText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      textTheme: text,
      // AppBar sarlavhasi: aniq o‘lcham (serif 20 sp) — `text.titleLarge`
      // bu yerda hali mahalliylashtirilmagan (fontSize null → 14 sp edi).
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 60,
        titleSpacing: FeSpace.xxs,
        titleTextStyle: TextStyle(
          fontFamily: FeFonts.serif,
          fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: c.textPrimary,
        ),
        iconTheme: IconThemeData(color: c.textPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: c.textPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.card),
          side: BorderSide(color: c.border, width: borderWidth),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.hero),
        ),
        titleTextStyle: text.titleLarge?.copyWith(
          fontSize: 20,
          color: c.textPrimary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        dragHandleColor: c.borderStrong.withValues(alpha: 0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(FeRadius.hero),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.surfaceRaised,
        foregroundColor: c.textPrimary,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.lg),
          side: BorderSide(color: c.border),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.surfaceSunken,
        linearMinHeight: 6,
        borderRadius: BorderRadius.circular(FeRadius.pill),
      ),
      // Snackbar: bitta uslub — suzuvchi, yumaloq, brend rangida (matn
      // kontrasti textOnBrand/brand juftligi bilan kafolatlangan).
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.brand,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.textOnBrand),
        actionTextColor: c.textOnBrand,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.brand,
          foregroundColor: c.textOnBrand,
          minimumSize: const Size(FeTouch.minTarget * 2, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FeRadius.md),
          ),
          textStyle: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          animationDuration: FeMotion.fast,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          minimumSize: const Size(FeTouch.minTarget, FeTouch.minTarget),
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
          animationDuration: FeMotion.fast,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceRaised,
        hintStyle: TextStyle(color: c.textSecondary),
        prefixIconColor: c.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FeSpace.md,
          vertical: FeSpace.md,
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
        backgroundColor: c.surfaceRaised,
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
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceRaised,
        selectedColor: c.accentContainer,
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.sm),
        ),
        labelStyle: text.labelLarge?.copyWith(
          color: c.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        checkmarkColor: c.onAccentContainer,
        padding: const EdgeInsets.symmetric(horizontal: FeSpace.xs),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.surfaceRaised,
          selectedBackgroundColor: c.accentContainer,
          selectedForegroundColor: c.onAccentContainer,
          side: BorderSide(color: c.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FeRadius.md),
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
          TargetPlatform.android: FePageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FePageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FePageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Raqamlar uchun uslub — tabular figures (natijalar ustunlarda tekis).
  /// Formulalar va kodlar uchun monoshirift; yo‘q belgilar Inter’dan.
  static TextStyle numeric(TextStyle base) => base.copyWith(
    fontFamily: FeFonts.mono,
    fontFamilyFallback: FeFonts.monoFallback,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Statistik raqamlar (sanoq, foiz) — Inter tabular figures — matn
  /// bilan bir oilada, ustunlarda tekis turadi.
  static TextStyle figures(TextStyle base) => base.copyWith(
    fontFamily: FeFonts.sans,
    fontFeatures: const [
      FontFeature.tabularFigures(),
      FontFeature.liningFigures(),
    ],
  );
}

/// Tez va sokin sahifa o‘tishi: yengil fade + 2 % ko‘tarilish.
/// Reduced motion (OS «Remove animations») yoqilganda — animatsiyasiz.
class FePageTransitionsBuilder extends PageTransitionsBuilder {
  const FePageTransitionsBuilder();

  @override
  Duration get transitionDuration => FeMotion.page;

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: FeMotion.curve,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
