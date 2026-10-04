import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/features/shell/presentation/app_shell.dart';

/// Pastki navigatsiya yozuvlari 320 dp ekranda (5 tab) haqiqiy Inter
/// shrifti bilan bir qatorga sig‘ishini o‘lchaydi. Bu test preview’da
/// topilgan muammo (so‘z o‘rtasidan bo‘linish) qaytmasligi uchun.
void main() {
  setUpAll(() async {
    final loader = FontLoader(FeFonts.sans);
    for (final w in ['Medium', 'SemiBold']) {
      final bytes = File('assets/fonts/inter/Inter-$w.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  });

  const tabs = 5;

  for (final width in [320.0, 360.0, 390.0]) {
    for (final code in ['en', 'ru', 'uz']) {
      // Har bir destination kengligidan kichik ichki bo‘shliq ayiriladi.
      final available = width / tabs - 4;
      final scale = navLabelMaxTextScale(width);
      test(
        '$code @ ${width.toInt()} dp (×$scale): yozuvlar ${available.toStringAsFixed(0)} dp ga sig‘adi',
        () {
          final l = lookupAppLocalizations(Locale(code));
          final style = FeThemeBuilder.light()
              .navigationBarTheme
              .labelTextStyle!
              .resolve({WidgetState.selected})!;
          for (final label in [
            l.navHome,
            l.navTools,
            l.navLibrary,
            l.navAi,
            l.navProfile,
          ]) {
            final painter = TextPainter(
              text: TextSpan(text: label, style: style),
              textDirection: TextDirection.ltr,
              textScaler: TextScaler.linear(scale),
            )..layout();
            expect(
              painter.width,
              lessThanOrEqualTo(available),
              reason: '"$label" = ${painter.width.toStringAsFixed(1)} dp',
            );
            painter.dispose();
          }
        },
      );
    }
  }
}
