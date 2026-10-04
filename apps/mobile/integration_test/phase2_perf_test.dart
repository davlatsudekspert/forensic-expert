// PHASE 2 ishlash o‘lchovlari (profile rejimida, haqiqiy dvigatel bilan).
//
// Ishga tushirish (qurilma, emulator yoki desktop):
//   flutter drive --profile \
//     --driver=test_driver/perf_driver.dart \
//     --target=integration_test/phase2_perf_test.dart
//
// O‘lchanadi (devor soati, Stopwatch):
// * main() → birinchi kadr, sozlamalarni o‘qish;
// * navigatsiya: tap/go → maqsad ekranning birinchi kadri;
// * mavzu va til almashtirish → keyingi kadr;
// * lokal qidiruv (birinchi va keyingi so‘rovlar).
// Natija: build/perf_metrics.json (`phase2` kaliti).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/search_service.dart';
import 'package:forensic_expert/core/perf/startup_metrics.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:forensic_expert/main.dart' as app;
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PHASE 2 perf', (tester) async {
    // Onboarding tugagan foydalanuvchi (lokal sozlamalar).
    SharedPreferences.setMockInitialValues({
      'fe.settings.locale': 'en',
      'fe.settings.theme': 'light',
      'fe.settings.mode': 'professional',
      'fe.settings.disclaimer_version': 1,
    });
    await app.main();
    await tester.pumpAndSettle();

    final results = <String, Object?>{
      'first_frame_since_main_us':
          StartupMetrics.instance[PerfMarks.firstFrame]?.inMicroseconds,
      'settings_load_us': StartupMetrics
          .instance['${PerfMarks.settingsLoad}.duration']
          ?.inMicroseconds,
    };

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    /// Amal → `target` ko‘ringan birinchi kadr (mikrosekund).
    Future<int> timeToFrame(
      Future<void> Function() action,
      Finder target,
    ) async {
      final sw = Stopwatch()..start();
      await action();
      await tester.pump();
      var guard = 0;
      while (target.evaluate().isEmpty && guard++ < 120) {
        await tester.pump(const Duration(milliseconds: 1));
      }
      sw.stop();
      // Maqsad topilmasa — o‘lchov yaroqsiz (soxta raqam yozilmaydi).
      expect(target, findsWidgets);
      await tester.pumpAndSettle();
      return sw.elapsedMicroseconds;
    }

    final nav = <String, List<int>>{};
    // 1) Tablar (har bir tab o‘z ildiz ekraniga ega bo‘lganda).
    for (var round = 0; round < 5; round++) {
      for (final (key, target) in [
        ('nav.tools', 'tool.tool.lab.dilution'),
        ('nav.library', 'library.filter'),
        ('nav.ai', 'ai.input'),
        ('nav.profile', 'profile.language'),
        ('nav.home', 'home.search'),
      ]) {
        final us = await timeToFrame(
          () => tester.tap(find.byKey(Key(key))),
          find.byKey(Key(target)),
        );
        nav.putIfAbsent(key, () => []).add(us);
      }
    }
    // 2) Ichki sahifalar (go_router orqali).
    final router = container.read(routerProvider);
    for (var round = 0; round < 5; round++) {
      for (final (route, target, back) in [
        (Routes.tool('tool.lab.dilution'), 'calc.calculate', Routes.tools),
        (Routes.libraryEntry('TEST-SUB-ETOH'), 'entry.sources', Routes.library),
        (Routes.search, 'search.field', Routes.home),
      ]) {
        final us = await timeToFrame(
          () async => router.go(route),
          find.byKey(Key(target)),
        );
        nav.putIfAbsent(route, () => []).add(us);
        router.go(back);
        await tester.pumpAndSettle();
      }
    }
    router.go(Routes.home);
    await tester.pumpAndSettle();
    results['navigation_to_first_frame_us'] = nav;

    final settings = container.read(settingsControllerProvider.notifier);
    final theme = <int>[];
    final lang = <int>[];
    for (var i = 0; i < 6; i++) {
      final sw = Stopwatch()..start();
      await settings.setThemeMode(i.isEven ? ThemeMode.dark : ThemeMode.light);
      await tester.pump();
      theme.add(sw.elapsedMicroseconds);
      await tester.pumpAndSettle();

      final sw2 = Stopwatch()..start();
      await settings.setLocale(Locale(const ['ru', 'uz', 'en'][i % 3]));
      await tester.pump();
      lang.add(sw2.elapsedMicroseconds);
      await tester.pumpAndSettle();
    }
    results['theme_switch_next_frame_us'] = theme;
    results['language_switch_next_frame_us'] = lang;

    final search = container.read(searchServiceProvider);
    final searchUs = <int>[];
    for (final q in [
      'etanol',
      'метамфетамин',
      'fentanly',
      'GC-MS',
      'dilution',
      'zzzz',
      'paracet',
      'o‘lim',
    ]) {
      searchUs.add((await search.search(q)).latency.inMicroseconds);
    }
    results['local_search_latency_us'] = searchUs;

    binding.reportData = {'phase2': results};
    // ignore: avoid_print
    print('PHASE2_PERF $results');
  });
}
