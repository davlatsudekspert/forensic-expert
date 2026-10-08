import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/ai/ai_architecture.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 9: AI ekranida RAG tuzilgan javobi (provayder ulanmagan).
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> ask(WidgetTester tester, String q, {String lang = 'en'}) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: lang),
      initialLocation: Routes.ai,
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
      ],
    );
    await tester.enterText(find.byKey(const Key('ai.input')), q);
    await tester.ensureVisible(find.byKey(const Key('ai.findSources')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai.findSources')));
    await tester.pumpAndSettle();
  }

  Future<void> see(WidgetTester tester, Finder f) async {
    await tester.dragUntilVisible(
      f.first,
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(f, findsWidgets);
  }

  testWidgets('manbalar: dalil holati, cheklovlar, bog‘liq yozuvlar', (
    tester,
  ) async {
    await ask(tester, 'morphine glucuronide metabolites');
    await see(tester, find.byKey(const Key('ai.rag.retrievalOnly')));
    await see(
      tester,
      find.byKey(const Key('ai.rag.limitation.not_human_verified')),
    );
    await see(
      tester,
      find.byKey(const Key('ai.rag.limitation.expert_judgment_required')),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('retraksiya qilingan manba chiqarib tashlangani ko‘rsatiladi', (
    tester,
  ) async {
    await ask(tester, 'algor mortis progressive cooling ambient temperature');
    await see(
      tester,
      find.byKey(const Key('ai.rag.limitation.retracted_excluded')),
    );
    expect(
      find.byKey(const Key('ai.rag.evidence.C-FM-ALGOR-MORTIS-DEFINITION')),
      findsNothing,
    );
  });

  testWidgets('rasmiy xulosa so‘rovi — blok (RU)', (tester) async {
    await ask(
      tester,
      'Напишите заключение эксперта по этому вскрытию',
      lang: 'ru',
    );
    expect(find.byKey(const Key('ai.blocked.officialOpinion')), findsOneWidget);
    expect(find.byKey(const Key('ai.rag.blocked')), findsNothing);
  });

  testWidgets('«oflayn topish» serverga chiqmaydi; manbalar alohida blokda', (
    tester,
  ) async {
    final spy = _SpyProvider();
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.ai,
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
        aiProviderProvider.overrideWithValue(spy),
      ],
    );
    await tester.enterText(
      find.byKey(const Key('ai.input')),
      'yupqa qatlam xromatografiyasi',
    );
    await tester.ensureVisible(find.byKey(const Key('ai.findSources')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai.findSources')));
    await tester.pumpAndSettle();
    expect(spy.calls, 0);
    expect(find.byKey(const Key('ai.answer')), findsNothing);
    await see(tester, find.byKey(const Key('ai.sources.offline')));
    expect(
      find.byKey(const Key('ai.chunk.C-METHOD-TLC-APPLICATION-P5')),
      findsOneWidget,
    );
  });
}

class _SpyProvider implements AiProvider {
  int calls = 0;

  @override
  bool get isConfigured => true;

  @override
  Future<AiDraft> generate(AiPrompt prompt) async {
    calls++;
    throw UnimplementedError();
  }
}
