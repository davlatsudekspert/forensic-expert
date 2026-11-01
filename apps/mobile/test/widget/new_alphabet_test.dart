import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/fe_localizations_delegate.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';

import '../helpers/pump_app.dart';

/// Yangi alifbo (O‘RQ-1184): Profildagi tugma, standart — o‘chiq.
void main() {
  testWidgets('standart: eski alifbo; tugma yoqilsa UI yangi alifboda', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      size: const Size(390, 2400),
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.profile,
    );
    await tester.pumpAndSettle();
    expect(UzAlphabetMode.newAlphabet, isFalse);
    final toggle = find.byKey(const Key('profile.newAlphabet'));
    expect(toggle, findsOneWidget);
    expect(find.textContaining('Ko‘rinish'), findsWidgets);

    await container
        .read(settingsControllerProvider.notifier)
        .setNewUzAlphabet(true);
    await tester.pumpAndSettle();
    expect(UzAlphabetMode.newAlphabet, isTrue);
    expect(find.textContaining('Ko‘rinish'), findsNothing);
    expect(find.textContaining('Köriniş'), findsWidgets);
    expect(container.read(settingsControllerProvider).newUzAlphabet, isTrue);
  });

  testWidgets('ru UI’da tugma ko‘rinmaydi va matn o‘zgarmaydi', (tester) async {
    await pumpApp(
      tester,
      size: const Size(390, 2400),
      settings: completedSettings(lang: 'ru').copyWith(newUzAlphabet: true),
      initialLocation: Routes.profile,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile.newAlphabet')), findsNothing);
    expect(UzAlphabetMode.newAlphabet, isFalse);
  });
}
