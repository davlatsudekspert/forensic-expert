import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/aby_flag.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Egasi qarori (2026-10-17): ABY 2025 mazmuni hozircha ko‘rinmaydi
/// (`kShowAbyContent = false`); bundle'dagi ma’lumot o‘zgarmaydi.
void main() {
  late PilotContent pilot;
  setUpAll(() async {
    abyContentEnabled = false;
    pilot = await loadPilotContent();
  });

  test('flag standart holatda o‘chiq', () {
    expect(kShowAbyContent, isFalse);
  });

  test('ABY mavzulari bilim ro‘yxatlarida va havolada yo‘q', () {
    for (final lang in const ['uz', 'ru', 'en']) {
      final repo = LocaleFilteredKnowledgeRepository(pilot.knowledge, lang);
      final ids = [
        for (final k in KnowledgeKind.values)
          ...repo.byKind(k).map((e) => e.id),
      ];
      expect(ids.where((i) => i.startsWith('aby-')), isEmpty, reason: lang);
      expect(repo.byId('aby-tox-opiates'), isNull);
      for (final e in pilot.knowledge.byKind(KnowledgeKind.topic)) {
        expect(
          e.claims.where((c) => c.claimId.startsWith('C-ABY')),
          isEmpty,
          reason: e.id,
        );
      }
    }
  });

  for (final id in const ['phenobarbital', 'thc-cooh']) {
    testWidgets('$id sahifasida ABY matni va kaliti yo‘q', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        initialLocation: Routes.libraryEntry(id),
        testFixtures: false,
        overrides: [
          ...pilot.overrides,
          entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
        ],
      );
      for (var i = 0; i < 40; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(find.textContaining('ABY'), findsNothing);
      expect(find.byKey(Key('analysis.aby.$id')), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              ((w.key! as ValueKey<String>).value.contains('aby') ||
                  (w.key! as ValueKey<String>).value.contains('C-ABY')),
        ),
        findsNothing,
      );
    });
  }
}
