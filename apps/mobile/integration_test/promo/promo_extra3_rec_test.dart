// PROMO REVISION 5: world_lit sahnasi. PROMO_KIND=lit (Simpson’s slaydi,
// ktp26-davolash-MR09) yoki spe (SPE sahifasi, xalqaro manbalar ro‘yxati).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo extra3', (tester) async {
    final kind = Platform.environment['PROMO_KIND'] ?? 'lit';
    final p = Promo(tester, Platform.environment['PROMO_NAME'] ?? 'extra3');
    await p.launch(mode: Platform.environment['PROMO_MODE'] ?? 'student');

    await p.scene('world_lit', () async {
      if (kind == 'lit') {
        await p.go(Routes.lesson('ktp26-davolash-MR09'), after: 1800);
        await p.tapKey('lesson.outlineButton', after: 1200);
        p.screen('outline');
        final sc = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byKey(const Key('lesson.outline')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        final from = sc.position.pixels;
        final to = (21 * 56.0 - 120).clamp(0.0, sc.position.maxScrollExtent);
        final sw = Stopwatch()..start();
        final real = 1800 * p.k;
        while (sw.elapsedMilliseconds < real) {
          final e = Curves.easeInOut.transform(sw.elapsedMilliseconds / real);
          sc.position.jumpTo(from + (to - from) * e);
          await tester.pump(const Duration(milliseconds: 16));
        }
        sc.position.jumpTo(to);
        await p.wait(700);
        await p.tapKey('lesson.outline.21', after: 1500);
        p.screen('simpson slide');
        await p.wait(1500);
      } else {
        await p.go(Routes.equipmentItem('spe'), after: 1500);
        final f = p.text('Restek');
        if (!await p.scrollTo(f, maxSteps: 40, step: 380)) {
          await p.scroll(4000, ms: 3000);
        }
        p.screen('spe sources');
        await p.wait(1500);
      }
    });
    await p.wait(2500);
    p.finish();
  });
}
