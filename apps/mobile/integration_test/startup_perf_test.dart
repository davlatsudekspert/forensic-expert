// Haqiqiy qurilmada cold start va navigatsiya o‘lchovi.
//
// Ishga tushirish (profile rejimida, real qurilma yoki emulator):
//   flutter drive --profile \
//     --driver=test_driver/perf_driver.dart \
//     --target=integration_test/startup_perf_test.dart
//
// Natija: build/startup_perf.timeline_summary.json (frame build/raster
// vaqtlari, jank) va `fe.startup.*` Timeline hodisalari.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/perf/startup_metrics.dart';
import 'package:forensic_expert/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start → birinchi kadr va tab navigatsiyasi', (
    tester,
  ) async {
    await binding.traceAction(() async {
      await app.main();
      await tester.pumpAndSettle();
    }, reportKey: 'startup_perf');

    final first = StartupMetrics.instance[PerfMarks.firstFrame];
    binding.reportData = {
      ...?binding.reportData,
      'first_frame_ms': first?.inMilliseconds,
      'settings_load_ms': StartupMetrics
          .instance['${PerfMarks.settingsLoad}.duration']
          ?.inMilliseconds,
    };
    expect(first, isNotNull);

    // Onboarding tugagan bo‘lsa — tablar bo‘ylab navigatsiya o‘lchovi.
    final tools = find.byKey(const Key('nav.tools'));
    if (tools.evaluate().isNotEmpty) {
      await binding.traceAction(() async {
        for (final key in [
          'nav.tools',
          'nav.library',
          'nav.ai',
          'nav.profile',
          'nav.home',
        ]) {
          await tester.tap(find.byKey(Key(key)));
          await tester.pumpAndSettle();
        }
      }, reportKey: 'tab_navigation');
    }
  });
}
