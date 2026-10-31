import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/tts.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/ports/tts_ports.dart';
import 'package:forensic_expert/features/tts/presentation/listen_button.dart';

import '../helpers/tts_fakes.dart';

Widget host({
  required FakeTtsService service,
  required FakeTtsPlayer player,
  String text = 'Salom dunyo',
  Locale locale = const Locale('uz'),
  bool show = true,
}) => ProviderScope(
  overrides: [
    ttsServiceProvider.overrideWithValue(service),
    ttsPlayerFactoryProvider.overrideWithValue(() => player),
  ],
  child: MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(child: show ? ListenButton(text: text) : const SizedBox()),
    ),
  ),
);

void main() {
  const listen = Key('tts.listen');
  Finder icon(String s) => find.byKey(Key('tts.icon.$s'));

  testWidgets(
    'idle → loading → playing → paused → playing → finished → replay',
    (tester) async {
      final svc = FakeTtsService()..pending = Completer();
      final player = FakeTtsPlayer();
      await tester.pumpWidget(host(service: svc, player: player));
      expect(icon('idle'), findsOneWidget);
      expect(find.byTooltip('Tinglash'), findsOneWidget);
      expect(player.calls, isEmpty, reason: 'ijrochi lazy yaratiladi');

      await tester.tap(find.byKey(listen));
      await tester.pump();
      expect(find.byKey(const Key('tts.loading')), findsOneWidget);
      expect(find.byTooltip('Ovoz tayyorlanmoqda…'), findsOneWidget);
      expect(svc.texts, ['Salom dunyo']);

      svc.pending!.complete(svc.audio);
      await tester.pump();
      await tester.pump();
      expect(icon('playing'), findsOneWidget);
      expect(find.byTooltip('Pauza'), findsOneWidget);
      expect(player.calls, ['play:/tmp/a.wav']);

      await tester.tap(find.byKey(listen));
      await tester.pump();
      expect(icon('paused'), findsOneWidget);
      expect(find.byTooltip('Davom etish'), findsOneWidget);
      expect(player.calls.last, 'pause');

      await tester.tap(find.byKey(listen));
      await tester.pump();
      expect(icon('playing'), findsOneWidget);
      expect(player.calls.last, 'resume');

      player.complete.add(null);
      await tester.pump();
      expect(icon('finished'), findsOneWidget);
      expect(find.byTooltip('Qayta tinglash'), findsOneWidget);

      await tester.tap(find.byKey(listen));
      await tester.pump();
      expect(icon('playing'), findsOneWidget);
      expect(player.calls.last, 'play:/tmp/a.wav');
      expect(
        svc.texts,
        hasLength(1),
        reason: 'qayta tinglash — qayta so‘rovsiz',
      );
    },
  );

  testWidgets('bir nechta bo‘lak ketma-ket ijro etiladi', (tester) async {
    final svc = FakeTtsService()
      ..audio = const TtsAudio(['/tmp/1.wav', '/tmp/2.wav']);
    final player = FakeTtsPlayer();
    await tester.pumpWidget(host(service: svc, player: player));
    await tester.tap(find.byKey(listen));
    await tester.pump();
    await tester.pump();
    expect(player.calls, ['play:/tmp/1.wav']);
    player.complete.add(null);
    await tester.pump();
    await tester.pump();
    expect(player.calls, ['play:/tmp/1.wav', 'play:/tmp/2.wav']);
    expect(icon('playing'), findsOneWidget);
    player.complete.add(null);
    await tester.pump();
    expect(icon('finished'), findsOneWidget);
  });

  group('xatolar: SnackBar, tugma idle’ga qaytadi', () {
    const cases = {
      TtsFailure.offline: 'Ovoz yuklanmadi. Internetni tekshiring.',
      TtsFailure.dailyLimit:
          'Bugungi ovoz limiti tugadi, ertaga qayta urinib ko‘ring.',
      TtsFailure.notSignedIn: 'Tinglash uchun hisobingizga kiring.',
      TtsFailure.busy:
          'Ovoz xizmati band. Birozdan keyin qayta urinib ko‘ring.',
      TtsFailure.notConfigured: 'Ovoz xizmati hozircha ulanmagan.',
      TtsFailure.tooLong: 'Bu matn tinglash uchun juda uzun.',
      TtsFailure.empty: 'Ovoz ijro etilmadi. Qayta urinib ko‘ring.',
    };
    for (final e in cases.entries) {
      testWidgets(e.key.name, (tester) async {
        final svc = FakeTtsService()..fail = e.key;
        final player = FakeTtsPlayer();
        await tester.pumpWidget(host(service: svc, player: player));
        await tester.tap(find.byKey(listen));
        await tester.pump();
        await tester.pump();
        expect(find.text(e.value), findsOneWidget);
        expect(icon('idle'), findsOneWidget);
        expect(player.calls, isEmpty);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('ijro boshlanmasa — tushunarli xato, crash yo‘q', (tester) async {
    final svc = FakeTtsService();
    final player = FakeTtsPlayer()..playError = StateError('codec');
    await tester.pumpWidget(host(service: svc, player: player));
    await tester.tap(find.byKey(listen));
    await tester.pump();
    await tester.pump();
    expect(
      find.text('Ovoz ijro etilmadi. Qayta urinib ko‘ring.'),
      findsOneWidget,
    );
    expect(icon('idle'), findsOneWidget);
  });

  testWidgets('yuklash vaqtida olib tashlansa — hech narsa ijro etilmaydi', (
    tester,
  ) async {
    final svc = FakeTtsService()..pending = Completer();
    final player = FakeTtsPlayer();
    await tester.pumpWidget(host(service: svc, player: player));
    await tester.tap(find.byKey(listen));
    await tester.pump();
    await tester.pumpWidget(host(service: svc, player: player, show: false));
    svc.pending!.complete(svc.audio);
    await tester.pump();
    expect(player.calls, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ijro vaqtida olib tashlansa — to‘xtatiladi va bo‘shatiladi', (
    tester,
  ) async {
    final svc = FakeTtsService();
    final player = FakeTtsPlayer();
    await tester.pumpWidget(host(service: svc, player: player));
    await tester.tap(find.byKey(listen));
    await tester.pump();
    await tester.pump();
    expect(icon('playing'), findsOneWidget);
    await tester.pumpWidget(host(service: svc, player: player, show: false));
    await tester.pump();
    expect(player.calls, containsAllInOrder(['stop', 'dispose']));
    expect(player.disposed, isTrue);
  });

  testWidgets('matn o‘zgarsa — ijro to‘xtaydi, tugma idle', (tester) async {
    final svc = FakeTtsService();
    final player = FakeTtsPlayer();
    await tester.pumpWidget(host(service: svc, player: player, text: 'A'));
    await tester.tap(find.byKey(listen));
    await tester.pump();
    await tester.pump();
    await tester.pumpWidget(host(service: svc, player: player, text: 'B'));
    await tester.pump();
    expect(icon('idle'), findsOneWidget);
    expect(player.calls, contains('stop'));
    await tester.tap(find.byKey(listen));
    await tester.pump();
    expect(svc.texts, ['A', 'B']);
  });

  testWidgets('server sozlanmagan yoki matn bo‘sh — tugma yo‘q', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(service: FakeTtsService(configured: false), player: FakeTtsPlayer()),
    );
    expect(find.byKey(listen), findsNothing);
    await tester.pumpWidget(
      host(service: FakeTtsService(), player: FakeTtsPlayer(), text: '  '),
    );
    expect(find.byKey(listen), findsNothing);
  });

  for (final loc in const {
    'ru': ['Слушать', 'Пауза'],
    'en': ['Listen', 'Pause'],
  }.entries) {
    testWidgets('${loc.key}: maslahat matnlari', (tester) async {
      await tester.pumpWidget(
        host(
          service: FakeTtsService(),
          player: FakeTtsPlayer(),
          locale: Locale(loc.key),
        ),
      );
      expect(find.byTooltip(loc.value[0]), findsOneWidget);
      await tester.tap(find.byKey(listen));
      await tester.pump();
      await tester.pump();
      expect(find.byTooltip(loc.value[1]), findsOneWidget);
    });
  }
}
