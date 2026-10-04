import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 6 UI unumdorligi (host VM, JIT, widget-test muhiti; real qurilma
/// o‘lchovi EMAS — RG-10). Chegaralar keng: regressiyani ushlash uchun.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  testWidgets('ochilish, navigatsiya, til va mavzu almashtirish', (
    tester,
  ) async {
    final out = <String>[];
    String ms(Stopwatch s) => '${s.elapsedMicroseconds / 1000} ms';

    var sw = Stopwatch()..start();
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      testFixtures: false,
      overrides: pilot.overrides,
    );
    out.add(
      'ilova → Home birinchi kadr (oflayn, backend kutilmaydi): ${ms(sw)}',
    );

    for (final r in [
      Routes.library,
      Routes.libraryEntry('morphine'),
      Routes.research,
      Routes.jurisdictionSelect,
      Routes.disciplines,
    ]) {
      sw = Stopwatch()..start();
      c.read(routerProvider).go(r);
      await tester.pumpAndSettle();
      out.add('navigatsiya $r: ${ms(sw)}');
    }

    sw = Stopwatch()..start();
    await c
        .read(settingsControllerProvider.notifier)
        .setLocale(const Locale('uz'));
    await tester.pumpAndSettle();
    out.add('til almashtirish (en → uz): ${ms(sw)}');

    sw = Stopwatch()..start();
    await c
        .read(settingsControllerProvider.notifier)
        .setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    out.add('mavzu almashtirish (light → dark): ${ms(sw)}');

    // ignore: avoid_print
    print('PHASE6 PERF\n${out.join('\n')}');
    expect(tester.takeException(), isNull);
  });
}
