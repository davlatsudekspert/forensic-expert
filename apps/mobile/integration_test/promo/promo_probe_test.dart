import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('probe', (tester) async {
    final p = Promo(tester, 'probe');
    await p.launch(mode: 'teacher');
    final ts = <FrameTiming>[];
    SchedulerBinding.instance.addTimingsCallback(ts.addAll);
    await p.wait(1000);
    ts.clear();
    await p.scroll(900, ms: 3000);
    await p.wait(300);
    var b = 0, r = 0, tot = 0;
    for (final t in ts) {
      b += t.buildDuration.inMicroseconds;
      r += t.rasterDuration.inMicroseconds;
      tot += t.totalSpan.inMicroseconds;
    }
    debugPrint(
      'PROBE frames=${ts.length} build avg=${b ~/ ts.length}us raster avg=${r ~/ ts.length}us total avg=${tot ~/ ts.length}us',
    );
    await p.go(Routes.profile);
    p.finish();
  });
}
