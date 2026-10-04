import 'dart:io';

import 'package:drift/native.dart';
import 'package:fe_database/fe_database.dart' show ContentDatabase;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/search_service.dart';
import 'package:forensic_expert/data/content/bundled_pack.dart';
import 'package:forensic_expert/data/content/content_provenance.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 7 unumdorligi (host VM, JIT, widget-test muhiti; real qurilma
/// o‘lchovi EMAS — RG-10). Chegaralar keng: regressiyani ushlash uchun.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  String ms(Stopwatch s) => '${s.elapsedMicroseconds / 1000} ms';

  test('provenance qatlamini content.db dan yuklash', () async {
    final root = Directory.systemTemp.createTempSync('fe_p7perf');
    await BundledPackInstaller(
      root: root,
      assets: DiskAssetBundle(),
      acceptedChannel: 'development',
    ).ensureInstalled();
    final db = ContentDatabase(
      NativeDatabase(File('${root.path}/active/content.db')),
    );
    final sw = Stopwatch()..start();
    final p = await ContentProvenance.load(db);
    sw.stop();
    await db.close();
    // ignore: avoid_print
    print(
      'PHASE7 PERF provenance load (${p.index.claimsById.length} claims): '
      '${ms(sw)}',
    );
    expect(sw.elapsed, lessThan(const Duration(seconds: 5)));
  });

  test('qidiruv (EN/RU/UZ) — median', () async {
    final s = AppSearchService.build(
      library: pilot.library,
      learn: const EmptyLearnRepository(),
      knowledge: pilot.knowledge,
      instruments: pilot.legal.instruments,
      research: pilot.evidence.research,
      provenance: pilot.provenance,
    );
    final times = <int>[];
    for (final q in [
      'morphine',
      'метамфетамин',
      'shishasimon',
      'vitreous',
      'E2329',
      'fentanyl',
      'oral fluid',
      'rigor',
    ]) {
      final sw = Stopwatch()..start();
      await s.search(q);
      times.add(sw.elapsedMicroseconds);
    }
    times.sort();
    final median = times[times.length ~/ 2] / 1000;
    // ignore: avoid_print
    print('PHASE7 PERF search median: $median ms (n=${times.length})');
    expect(median, lessThan(500));
  });

  testWidgets('ekranlar: Home, modda, research, tanlovchi, provenance', (
    tester,
  ) async {
    final out = <String>[];
    var sw = Stopwatch()..start();
    final c = await pumpApp(
      tester,
      settings: completedSettings(),
      testFixtures: false,
      overrides: [
        ...pilot.overrides,
        entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
      ],
    );
    out.add('cold start → Home birinchi kadr: ${ms(sw)}');

    for (final r in [
      Routes.libraryEntry('morphine'),
      Routes.research,
      Routes.jurisdictionSelect,
      Routes.specimens,
      Routes.conflicts,
      Routes.chain('cocaine'),
      Routes.reviewStatus,
      Routes.libraryStandards,
    ]) {
      sw = Stopwatch()..start();
      c.read(routerProvider).go(r);
      await tester.pumpAndSettle();
      out.add('navigatsiya $r: ${ms(sw)}');
    }

    c.read(routerProvider).go(Routes.libraryEntry('morphine'));
    await tester.pumpAndSettle();
    const key = Key('claim.provenance.C-MORPHINE-REPORTED_CONCENTRATION-P5');
    await tester.dragUntilVisible(
      find.byKey(key),
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    sw = Stopwatch()..start();
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
    out.add('provenance oynasini ochish: ${ms(sw)}');
    expect(find.byKey(const Key('provenance.sheet')), findsOneWidget);

    // ignore: avoid_print
    print('PHASE7 PERF\n${out.join('\n')}');
    expect(tester.takeException(), isNull);
  });
}
