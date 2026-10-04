import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/pump_app.dart';
import '../helpers/screens.dart';

/// 320 dp kenglikdagi kichik ekran va katta shrift (Dynamic Type) da
/// hech bir ekranda overflow yoki layout xatosi bo‘lmasligi kerak.
///
/// Flutter test overflow’ni (RenderFlex overflowed) xato sifatida
/// qaytaradi — `takeException()` null bo‘lishi shart.
void main() {
  const small = Size(320, 568);
  const scales = [1.0, 1.3, 2.0];
  const languages = ['en', 'ru', 'uz'];

  for (final lang in languages) {
    for (final scale in scales) {
      group('$lang · 320dp · text ×$scale', () {
        testWidgets('til tanlash ekrani', (tester) async {
          await pumpApp(tester, size: small, textScale: scale);
          expect(tester.takeException(), isNull);
        });
        testWidgets('disclaimer', (tester) async {
          await pumpApp(
            tester,
            size: small,
            textScale: scale,
            settings: AppSettings(locale: Locale(lang)),
          );
          expect(tester.takeException(), isNull);
        });
        testWidgets('rejim tanlash', (tester) async {
          await pumpApp(
            tester,
            size: small,
            textScale: scale,
            settings: AppSettings(
              locale: Locale(lang),
              acceptedDisclaimerVersion: currentDisclaimerVersion,
            ),
          );
          expect(tester.takeException(), isNull);
        });
        for (final route in shellScreens) {
          testWidgets(route, (tester) async {
            await pumpApp(
              tester,
              size: small,
              textScale: scale,
              settings: completedSettings(lang: lang),
              initialLocation: route,
            );
            expect(tester.takeException(), isNull);
          });
        }
      });
    }
  }

  testWidgets('juda katta shrift (×3.0) — til ekrani va Home', (tester) async {
    await pumpApp(tester, size: small, textScale: 3.0);
    expect(tester.takeException(), isNull);
    await pumpApp(
      tester,
      size: small,
      textScale: 3.0,
      settings: completedSettings(lang: 'ru'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('planshet kengligi (1024dp) — kontent markazda cheklangan', (
    tester,
  ) async {
    await pumpApp(
      tester,
      size: const Size(1024, 768),
      settings: completedSettings(),
    );
    expect(tester.takeException(), isNull);
  });
}
