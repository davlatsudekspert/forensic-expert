import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/dna.dart';
import 'package:forensic_expert/app/routes.dart';

import '../helpers/pump_app.dart';

/// DNK bo‘limi — HAQIQIY paket (assets/content/dna/dna_v1.json) bilan.
void main() {
  final overrides = [
    dnaLoaderProvider.overrideWithValue(
      () async => File(dnaAsset).readAsStringSync(),
    ),
  ];
  for (final (name, loc) in [
    ('dna_hub_uz', Routes.dna),
    ('dna_samples_uz', Routes.dnaTopic('samples')),
    ('dna_court_uz', Routes.dnaCourt),
  ]) {
    testWidgets(name, (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        size: const Size(390, 1600),
        pixelRatio: 1.5,
        testFixtures: false,
        initialLocation: loc,
        overrides: overrides,
      );
      await settleImages(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }
}
