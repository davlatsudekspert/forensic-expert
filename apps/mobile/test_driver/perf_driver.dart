import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

/// Timeline’dan xulosa yozadi: `build/<reportKey>.timeline_summary.json`
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data == null) return;
    for (final key in ['startup_perf', 'tab_navigation']) {
      final raw = data[key];
      if (raw is! Map<String, dynamic>) continue;
      final timeline = driver.Timeline.fromJson(raw);
      final summary = driver.TimelineSummary.summarize(timeline);
      await summary.writeTimelineToFile(
        key,
        pretty: true,
        includeSummary: true,
      );
    }
    await writeResponseData(data, testOutputFilename: 'perf_metrics');
  },
);
