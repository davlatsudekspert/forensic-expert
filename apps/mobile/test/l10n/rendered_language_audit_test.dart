import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 6 lokalizatsiya auditi: RU va UZ tilida ekrandagi **UI matni**
/// inglizcha ARB qiymati bilan aynan bir xil bo‘lmasligi kerak (tasodifiy
/// «Home / Tools / Library» qolmasin).
///
/// Istisno (hujjatlashtirilgan): xalqaro qisqartmalar va belgilar (ARB
/// parity allowlist’i bilan bir xil), hamda kontent tili — ilmiy manba
/// sarlavhalari, asl iqtiboslar va nashr nomlari manba tilida qoladi.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  final en = jsonDecode(
    File('lib/core/l10n/arb/app_en.arb').readAsStringSync(),
  ) as Map<String, Object?>;
  // ARB parity allowlist bilan bir xil: bu kalitlar har tilda bir xil.
  const sameEverywhere = {
    'appTitle',
    'appTagline',
    'moduleAi',
    'navAi',
    'testDataBadge',
    'toolLodName',
    'calcFormula',
    'detailBiomarker',
    'lockedBadge',
    'tech_gc',
    'tech_gcFid',
    'tech_gcMs',
    'tech_hplc',
    'tech_lcMsMs',
    'tech_headspaceGc',
    'tech_gcMsMs',
    'tech_lcMs',
    'calcStatsN',
    'calcRegR2',
    'calcStatsMin',
    'calcLodReference',
    'docKindSop',
    'researchPeriod2010',
    'tpl_marker',
    'metKindMarker',
  };
  // Allowlist’dagi kalit qiymati (masalan, «Lifetime» brendi) boshqa
  // kalitda ham uchrasa — u ham ruxsat etilgan.
  final allowedValues = {for (final k in sameEverywhere) en[k]};
  final englishUi = <String>{
    for (final e in en.entries)
      if (!e.key.startsWith('@') &&
          !sameEverywhere.contains(e.key) &&
          !allowedValues.contains(e.value) &&
          e.value is String &&
          !(e.value! as String).contains('{') &&
          RegExp('[A-Za-z]{3,}').hasMatch(e.value! as String))
        e.value! as String,
  };

  final routes = [
    Routes.home,
    Routes.search,
    Routes.tools,
    Routes.library,
    Routes.librarySection('substances'),
    Routes.libraryEntry('morphine'),
    Routes.knowledgeEntry('method-lcmsms'),
    Routes.knowledgeEntry('reagent-dragendorff'),
    Routes.knowledgeEntry('scr-fentanyl-test-strips'),
    Routes.forensicMedicine,
    Routes.histology,
    Routes.biochemistry,
    Routes.research,
    Routes.disciplines,
    Routes.jurisdictions,
    Routes.jurisdiction('GB'),
    Routes.jurisdictionSelect,
    Routes.learn,
    Routes.ai,
    Routes.profile,
    Routes.purchase,
    Routes.tool('tool.lab.lod_loq'),
  ];

  for (final lang in ['ru', 'uz']) {
    for (final route in routes) {
      testWidgets('$lang $route — inglizcha UI matni yo‘q', (tester) async {
        await pumpApp(
          tester,
          settings: completedSettings(lang: lang),
          initialLocation: route,
          testFixtures: false,
          overrides: [
            ...pilot.overrides,
            entitlementServiceProvider.overrideWithValue(
              FakeStore(owned: true),
            ),
          ],
        );
        final leaked = <String>{
          for (final w in tester.widgetList<Text>(find.byType(Text)))
            if (w.data != null && englishUi.contains(w.data!.trim())) w.data!,
          for (final w in tester.widgetList<RichText>(find.byType(RichText)))
            if (englishUi.contains(w.text.toPlainText().trim()))
              w.text.toPlainText(),
        };
        expect(leaked, isEmpty, reason: '$lang $route: $leaked');
      });
    }
  }
}
