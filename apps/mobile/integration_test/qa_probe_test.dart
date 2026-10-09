// Kashfiyot uchun yordamchi (QA harness’ini yozishda ishlatiladi).
// QA_TAPS="matn|matn|go:/route|type:so‘z|back|scroll:600|wait" — har amaldan
// keyin ekran matnlari konsolga chiqadi va skrinshot olinadi.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/bootstrap.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'qa/harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('probe', (tester) async {
    final out = Directory(Platform.environment['QA_OUT'] ?? '/tmp/qa_probe')
      ..createSync(recursive: true);
    final mode = Platform.environment['QA_MODE'];
    SharedPreferences.setMockInitialValues({
      if (mode != null) ...{
        'fe.settings.locale': Platform.environment['QA_LANG'] ?? 'uz',
        'fe.settings.theme': 'light',
        'fe.settings.mode': mode,
        'fe.settings.disclaimer_version': 1,
      },
    });
    final qa = QaRun(tester, role: 'probe', outDir: out);
    qa.installErrorCollector();
    await bootstrap();
    await qa.setSize(const Size(390, 844));
    await qa.step('start', (s) async {});
    {
      final tx = qa
          .visibleTexts()
          .where((t) => t.runes.any((r) => r < 0xE000))
          .join(' ¦ ');
      debugPrint('TEXTS: ${tx.length > 900 ? tx.substring(0, 900) : tx}');
    }
    final taps = (Platform.environment['QA_TAPS'] ?? '').split('|');
    for (final a in taps.where((a) => a.isNotEmpty)) {
      await qa.step(a, (s) async {
        if (a.startsWith('go:')) {
          final c = ProviderScope.containerOf(
            tester.element(find.byType(MaterialApp)),
          );
          c.read(routerProvider).go(a.substring(3));
        } else if (a.startsWith('type:')) {
          await qa.enterText(find.byType(TextField), a.substring(5));
        } else if (a == 'back') {
          await qa.back();
        } else if (a.startsWith('scroll:')) {
          await qa.scrollBy(double.parse(a.substring(7)));
        } else if (a.startsWith('tip:')) {
          await qa.tapTooltip(a.substring(4));
        } else if (a == 'wait') {
          await qa.settle(maxMs: 4000);
        } else {
          await qa.tapText(a);
        }
      });
      {
        final tx = qa
            .visibleTexts()
            .where((t) => t.runes.any((r) => r < 0xE000))
            .join(' ¦ ');
        debugPrint('TEXTS: ${tx.length > 900 ? tx.substring(0, 900) : tx}');
      }
      final tips = find
          .byType(Tooltip)
          .evaluate()
          .map((e) => (e.widget as Tooltip).message)
          .toList();
      debugPrint('TIPS: $tips');
    }
    qa.restoreErrorHandler();
  });
}
