import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';

import '../helpers/pump_app.dart';

/// Har bir tilda asosiy ekranlar Material lokalizatsiyasi bilan birga
/// xatosiz quriladi (masalan, `uz` uchun GlobalMaterialLocalizations).
void main() {
  for (final code in ['en', 'ru', 'uz']) {
    testWidgets('$code: shell va barcha tablar', (tester) async {
      await pumpApp(tester, settings: completedSettings(lang: code));
      final l = lookupAppLocalizations(Locale(code));
      expect(find.text(l.navHome), findsWidgets);
      for (final key in ['nav.tools', 'nav.library', 'nav.ai', 'nav.profile']) {
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(find.text(l.profileTitle), findsWidgets);
      // Material lokalizatsiyasi ham shu tilda.
      final material = MaterialLocalizations.of(
        tester.element(find.byType(Scaffold).last),
      );
      expect(material, isNotNull);
    });
  }
}
