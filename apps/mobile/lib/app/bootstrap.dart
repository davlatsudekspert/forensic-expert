import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/perf/startup_metrics.dart';
import '../core/settings/settings_controller.dart';
import '../core/settings/settings_repository.dart';
import 'app.dart';

/// Ilovani ishga tushirish.
///
/// Startup yo‘lida faqat **lokal** va tez ishlar: sozlamalarni o‘qish.
/// Tarmoq so‘rovi, kontent bazasini ochish yoki og‘ir hisob yo‘q —
/// ular birinchi kadrdan keyin, kerak bo‘lganda bajariladi.
Future<void> bootstrap() async {
  final metrics = StartupMetrics.instance..start();
  WidgetsFlutterBinding.ensureInitialized();

  _registerFontLicenses();

  final repo = await metrics.measure(PerfMarks.settingsLoad, () async {
    return SharedPrefsSettingsRepository(await SharedPreferences.getInstance());
  });
  final settings = await repo.load();
  metrics.mark(PerfMarks.settingsLoaded);

  SchedulerBinding.instance.addPostFrameCallback((_) {
    metrics.mark(PerfMarks.firstFrame);
  });

  runApp(
    ProviderScope(
      overrides: [
        initialSettingsProvider.overrideWithValue(settings),
        settingsRepositoryProvider.overrideWithValue(repo),
      ],
      child: const ForensicExpertApp(),
    ),
  );
}

/// Ilovaga o‘rnatilgan shriftlar litsenziyasi (SIL OFL 1.1) — «Licenses»
/// sahifasida ko‘rinadi.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (pkg, path) in const [
      ('Inter', 'assets/fonts/inter/OFL.txt'),
      ('JetBrains Mono', 'assets/fonts/jetbrains_mono/OFL.txt'),
    ]) {
      final text = await rootBundle.loadString(path);
      yield LicenseEntryWithLineBreaks([pkg], text);
    }
  });
}
