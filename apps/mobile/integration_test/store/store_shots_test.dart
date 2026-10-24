// App Store skrinshotlari — HAQIQIY ilova (bootstrap), haqiqiy backend va
// App Review demo akkaunti (faqat o‘qish; AI’ga bitta savol).
//
//   STORE_EMAIL=... STORE_PASSWORD=... STORE_LANG=en STORE_OUT=/tmp/x \
//   xvfb-run -a flutter test integration_test/store/store_shots_test.dart \
//     -d linux --dart-define-from-file=config/backend.json \
//     --dart-define=FE_AI_REMOTE=true
//
// iPhone 6.9″ → 1320×2868, iPad 13″ → 2064×2752.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/bootstrap.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _devices = [
  ('iphone69', Size(440, 956), 3.0, 62.0, 34.0),
  ('ipad13', Size(1032, 1376), 2.0, 24.0, 20.0),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final env = Platform.environment;
  final lang = env['STORE_LANG'] ?? 'en';
  final out = env['STORE_OUT'] ?? 'build/store_shots';
  final only = env['STORE_ONLY'];

  testWidgets('store shots $lang', (tester) async {
    Future<void> settle([int ms = 2500]) async {
      final end = DateTime.now().millisecondsSinceEpoch + ms;
      while (DateTime.now().millisecondsSinceEpoch < end) {
        await tester.pump(const Duration(milliseconds: 50));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
      }
    }

    Future<bool> waitFor(Finder f, {int secs = 20}) async {
      final end = DateTime.now().add(Duration(seconds: secs));
      while (DateTime.now().isBefore(end)) {
        await settle(300);
        if (f.evaluate().isNotEmpty) return true;
      }
      return false;
    }

    SharedPreferences.setMockInitialValues({
      'fe.settings.locale': lang,
      'fe.settings.theme': 'light',
      'fe.settings.mode': 'professional',
      'fe.settings.disclaimer_version': 1,
    });
    await bootstrap();
    await settle(4000);
    final c = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    try {
      final r = await c
          .read(authRepositoryProvider)
          .signIn(email: env['STORE_EMAIL']!, password: env['STORE_PASSWORD']!);
      // ignore: avoid_print
      print('STORE sign-in ok=${r.ok} failure=${r.failure}');
    } catch (e) {
      // ignore: avoid_print
      print('STORE sign-in error: $e');
    }
    await settle(3000);

    Future<void> go(String loc, [int ms = 3500]) async {
      c.read(routerProvider).go(loc);
      await settle(ms);
    }

    Future<void> shot(String device, String name, double scale) async {
      await settle(800);
      final view = tester.binding.renderViews.first;
      final layer = view.debugLayer! as OffsetLayer;
      await tester.runAsync(() async {
        final dpr = tester.view.devicePixelRatio;
        final img = await layer.toImage(
          Offset.zero & (view.size * dpr),
          pixelRatio: scale / dpr,
        );
        final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
        File('$out/$lang/$device/$name.png')
          ..parent.createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      // ignore: avoid_print
      print('STORE shot $lang/$device/$name');
    }

    for (final (device, size, scale, top, bottom) in _devices) {
      if (only != null && only != device) continue;
      tester.view.devicePixelRatio = scale;
      tester.view.physicalSize = size * scale;
      tester.view.padding = FakeViewPadding(
        top: top * scale,
        bottom: bottom * scale,
      );
      tester.view.viewPadding = tester.view.padding;
      await settle(1500);

      await go(Routes.home);
      await shot(device, '01_home', scale);

      await go(Routes.library);
      await shot(device, '02_library', scale);

      await go('/home/substance/morphine');
      await shot(device, '03_substance', scale);

      await go(Routes.lessons, 6000);
      await shot(device, '05_lessons', scale);

      await go('${Routes.lessons}/toks-01-toks-kirish', 6000);
      final next = find.byKey(const Key('lesson.next'));
      if (next.evaluate().isNotEmpty) {
        await tester.tap(next);
        await settle(1500);
      }
      await shot(device, '06_lesson_slide', scale);

      await go(Routes.learn);
      await shot(device, '07_learn', scale);

      await go(Routes.classQuiz);
      await shot(device, '08_class_quiz', scale);

      await go(Routes.groups, 5000);
      await shot(device, '09_groups', scale);

      await go(Routes.ai);
      final input = find.byKey(const Key('ai.input'));
      if (await waitFor(input, secs: 5)) {
        await tester.enterText(
          input,
          lang == 'ru'
              ? 'Какими методами подтверждают морфин в крови?'
              : 'Which methods confirm morphine in blood?',
        );
        await settle(500);
        FocusManager.instance.primaryFocus?.unfocus();
        await settle(500);
        final send = find.byKey(const Key('ai.send'));
        if (send.evaluate().isNotEmpty) {
          await tester.tap(send);
          await settle(45000);
        }
      }
      await shot(device, '04_ai', scale);
    }
  });
}
