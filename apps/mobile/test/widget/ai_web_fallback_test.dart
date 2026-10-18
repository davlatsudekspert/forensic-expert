import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/ai/ai_architecture.dart';
import 'package:forensic_expert/domain/ports/ai_entitlement.dart';
import 'package:forensic_expert/domain/ports/ai_ports.dart';

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

class _WebProvider implements AiProvider, WebAiProvider {
  _WebProvider({this.error});

  final Exception? error;
  int webCalls = 0;
  int kbCalls = 0;

  @override
  bool get isConfigured => true;

  @override
  Future<AiDraft> generate(AiPrompt prompt) async {
    kbCalls++;
    final c = prompt.chunks.first;
    return AiDraft(text: c.text, citedChunkIds: [c.chunkId]);
  }

  @override
  Future<WebAnswer> askWeb(AiQuestion q, AiExperience e) async {
    webCalls++;
    if (error != null) throw error!;
    return const WebAnswer(
      text: 'Web summary text',
      sources: [WebSource(title: 'example.org', uri: 'https://example.org/a')],
    );
  }
}

class _Fail implements Exception {
  const _Fail(this.code);
  final String code;
  @override
  String toString() => 'AiUnavailable($code)';
}

void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> open(WidgetTester tester, _WebProvider p, String q) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.ai,
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        aiAssistantProvider.overrideWithValue(const _Available()),
        aiEntitlementServiceProvider.overrideWithValue(const _Entitled()),
        aiProviderProvider.overrideWithValue(p),
      ],
    );
    await tester.enterText(find.byKey(const Key('ai.input')), q);
    await tester.ensureVisible(find.byKey(const Key('ai.send')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai.send')));
    await tester.pumpAndSettle();
  }

  Future<void> see(WidgetTester tester, Finder f) async {
    await tester.dragUntilVisible(
      f,
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'baza bo‘sh: avtomatik internet javobi, amber yorliq va manbalar',
    (tester) async {
      final p = _WebProvider();
      await open(tester, p, 'zxqv wpfk');
      expect(p.kbCalls, 0);
      expect(p.webCalls, 1);
      await see(tester, find.byKey(const Key('ai.web.label')));
      expect(
        find.textContaining('Internetdan — tekshirilmagan'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('ai.web.text')), findsOneWidget);
      expect(
        find.byKey(const Key('ai.web.source.https://example.org/a')),
        findsOneWidget,
      );
      // Tasdiqlangan baza javobi sifatida ko‘rsatilmaydi.
      expect(find.byKey(const Key('ai.answer')), findsNothing);
      expect(find.byKey(const Key('ai.sources.collapsed')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('baza javobi ostida «Internetdan qidirish» tugmasi', (
    tester,
  ) async {
    final p = _WebProvider();
    await open(tester, p, 'morphine glucuronide metabolites');
    expect(p.kbCalls, 1);
    expect(p.webCalls, 0);
    expect(find.byKey(const Key('ai.web')), findsNothing);
    final btn = find.byKey(const Key('ai.webSearch'));
    await see(tester, btn);
    expect(find.text('Internetdan qidirish'), findsOneWidget);
    await tester.tap(btn);
    await tester.pumpAndSettle();
    expect(p.webCalls, 1);
    await see(tester, find.byKey(const Key('ai.web.label')));
    // Baza javobi ham joyida.
    expect(find.byKey(const Key('ai.answer')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kvota xatosi: tushunarli o‘zbekcha xabar', (tester) async {
    final p = _WebProvider(error: const _Fail('quota'));
    await open(tester, p, 'zxqv wpfk');
    await see(tester, find.byKey(const Key('ai.failure.quota')));
    expect(
      find.text(
        'AI xizmati limiti vaqtincha tugadi. Bazadagi natijalar ko‘rsatildi.',
      ),
      findsOneWidget,
    );
  });
}
