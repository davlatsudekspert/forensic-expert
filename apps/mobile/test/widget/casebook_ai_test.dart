import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/casebook.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/ai/rag_pipeline.dart';
import 'package:forensic_expert/domain/casebook/casebook_models.dart';
import 'package:forensic_expert/domain/ports/ai_ports.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

class _Available implements AiAssistant {
  const _Available();

  @override
  AiAvailability get availability => AiAvailability.available;

  @override
  Future<AiAnswer> ask(AiQuestion question) async =>
      const AiAnswer(text: '', citations: [], noReliableAnswer: true);
}

class _Entitled implements AiEntitlementService {
  const _Entitled();

  @override
  Future<AiEntitlement> current() async => const AiEntitlement(
    plan: AiPlan.includedQuota,
    monthlyQuestionLimit: 100,
  );
}

/// AI javobi daftarga faqat foydalanuvchi o‘zi qo‘shsa kiradi va doim
/// «tekshirilmagan» deb belgilanadi.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  testWidgets('AI javobini daftarga qo‘shish: «tekshirilmagan» belgisi bilan', (
    tester,
  ) async {
    final store = InMemoryCasebookStore();
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.ai,
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
        aiAssistantProvider.overrideWithValue(const _Available()),
        aiEntitlementServiceProvider.overrideWithValue(const _Entitled()),
        aiProviderProvider.overrideWithValue(MockAiProvider()),
        casebookStoreProvider.overrideWithValue(store),
      ],
    );
    await tester.enterText(
      find.byKey(const Key('ai.input')),
      'morphine glucuronide metabolites',
    );
    await tester.ensureVisible(find.byKey(const Key('ai.send')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai.send')));
    await tester.pumpAndSettle();
    // Avtomatik kirmaydi.
    expect(store.load(), isEmpty);
    final add = find.byKey(const Key('ai.addToCasebook'));
    await tester.dragUntilVisible(
      add,
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('casebook.choose.aiNote')), findsOne);
    await tester.tap(find.byKey(const Key('casebook.choose.new')));
    await tester.pumpAndSettle();
    final block = store.load().single.blocks.single;
    expect(block.kind, CasebookBlockKind.ai);
    expect(block.isAiUnverified, isTrue);
    expect(block.text, isNotEmpty);
  });
}
