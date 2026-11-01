import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/pump_app.dart';

/// GC-MS «Natijani o‘qish»: diagrammalar, manba va «spektrga qarab moddani
/// toping» mashqi (javob, izoh, keyingi savol).
void main() {
  testWidgets('mashq: efedron — to‘g‘ri javob, izoh va keyingi savol', (
    t,
  ) async {
    await pumpApp(
      t,
      settings: completedSettings(lang: 'uz', mode: UserMode.professional),
      initialLocation: Routes.gcmsReading,
      size: const Size(390, 6000),
    );
    expect(find.byKey(const Key('gcms.source')), findsOneWidget);
    expect(find.text('Sxema — eksperimental ma’lumot emas'), findsNWidgets(2));
    // 1-savol: efedron (58, 77, 51 …).
    await t.tap(find.byKey(const Key('gcms.quiz.opt.1')));
    await t.pumpAndSettle();
    final explain = t.widget<Text>(find.byKey(const Key('gcms.quiz.explain')));
    expect(explain.data, contains('✓ Efedron'));
    expect(explain.data, contains('146 / 77'));
    expect(find.text('To‘g‘ri: 1 tadan 1 ta'), findsOneWidget);
    await t.tap(find.byKey(const Key('gcms.quiz.next')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('gcms.quiz.explain')), findsNothing);
    expect(find.textContaining('2/10'), findsOneWidget);
  });
}
