// «Tinglash» ijro etilayotganda ekran o‘chmaydi; pauza/tugash/dispose/fon —
// bo‘shatiladi; boshqa egalar (proyektor) bilan bir-birini bekor qilmaydi.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/keep_awake.dart';
import 'package:forensic_expert/app/tts.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/features/tts/presentation/listen_button.dart';

import '../helpers/tts_fakes.dart';

class _Awake implements ClassScreenAwake {
  int enabled = 0;
  int disabled = 0;

  @override
  Future<void> enable() async => enabled++;

  @override
  Future<void> disable() async => disabled++;
}

void main() {
  const listen = Key('tts.listen');

  Future<ProviderContainer> pump(
    WidgetTester tester,
    _Awake awake,
    FakeTtsPlayer player, {
    bool show = true,
  }) async {
    final c = ProviderContainer(
      overrides: [
        ttsServiceProvider.overrideWithValue(FakeTtsService()),
        ttsPlayerFactoryProvider.overrideWithValue(() => player),
        classScreenAwakeProvider.overrideWithValue(awake),
      ],
    );
    addTearDown(c.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          locale: const Locale('uz'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: show
                ? const ListenButton(text: 'Salom dunyo')
                : const SizedBox(),
          ),
        ),
      ),
    );
    return c;
  }

  testWidgets('ijro ekranni ushlaydi; pauza, davom, tugash — bo‘shatadi', (
    tester,
  ) async {
    final awake = _Awake();
    final player = FakeTtsPlayer();
    final c = await pump(tester, awake, player);
    expect(c.read(keepAwakeProvider).held, isFalse);

    await tester.tap(find.byKey(listen));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('tts.icon.playing')), findsOneWidget);
    expect((awake.enabled, awake.disabled), (1, 0));

    await tester.tap(find.byKey(listen)); // pauza
    await tester.pump();
    expect((awake.enabled, awake.disabled), (1, 1));

    await tester.tap(find.byKey(listen)); // davom
    await tester.pump();
    expect((awake.enabled, awake.disabled), (2, 1));

    player.complete.add(null); // tugadi
    await tester.pump();
    expect(find.byKey(const Key('tts.icon.finished')), findsOneWidget);
    expect((awake.enabled, awake.disabled), (2, 2));
  });

  testWidgets('fonga o‘tganda bo‘shatiladi, qaytganda yana ushlanadi', (
    tester,
  ) async {
    final awake = _Awake();
    await pump(tester, awake, FakeTtsPlayer());
    await tester.tap(find.byKey(listen));
    await tester.pump();
    await tester.pump();
    expect(awake.enabled, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(awake.disabled, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(awake.enabled, 2);
  });

  testWidgets('ijro paytida vidjet olib tashlansa — bo‘shatiladi', (
    tester,
  ) async {
    final awake = _Awake();
    final player = FakeTtsPlayer();
    final c = await pump(tester, awake, player);
    await tester.tap(find.byKey(listen));
    await tester.pump();
    await tester.pump();
    expect(c.read(keepAwakeProvider).held, isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(c.read(keepAwakeProvider).held, isFalse);
    expect(awake.disabled, 1);
  });

  testWidgets('proyektor ushlab turganda tinglash tugashi uni bo‘shatmaydi', (
    tester,
  ) async {
    final awake = _Awake();
    final player = FakeTtsPlayer();
    final c = await pump(tester, awake, player);
    final projector = Object();
    c.read(keepAwakeProvider).acquire('projector', projector);
    expect(awake.enabled, 1);
    await tester.tap(find.byKey(listen));
    await tester.pump();
    await tester.pump();
    expect(awake.enabled, 1, reason: 'qayta yoqilmaydi');
    player.complete.add(null);
    await tester.pump();
    expect(awake.disabled, 0, reason: 'proyektor hali ushlab turibdi');
    c.read(keepAwakeProvider).release('projector', projector);
    expect(awake.disabled, 1);
  });
}
