import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';

import '../helpers/pump_app.dart';

/// Ekranlar katalogi ko‘rigi (2026-10-17): «abc» kiritilganda faqat
/// o‘chirilgan tugma ko‘rinardi. Endi maydon ostida tushunarli inline xato
/// (uz/ru/en); yozish paytida emas — maydondan chiqqanda; tuzatilsa yo‘qoladi.
void main() {
  for (final lang in ['uz', 'ru', 'en']) {
    testWidgets('$lang: noto‘g‘ri email → inline xato, to‘g‘risi → yo‘q', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: lang),
        initialLocation: Routes.accountEmailCode,
      );
      final l = lookupAppLocalizations(Locale(lang));
      final field = find.byKey(const Key('auth.email'));
      await tester.enterText(field, 'abc');
      await tester.pump();
      // Yozayotganda xato chiqmaydi.
      expect(find.text(l.authErrInvalidEmail), findsNothing);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text(l.authErrInvalidEmail), findsOneWidget);
      // Tuzatildi — xato yo‘qoladi.
      await tester.enterText(field, 'ism@pochta.uz');
      await tester.pumpAndSettle();
      expect(find.text(l.authErrInvalidEmail), findsNothing);
    });
  }
}
