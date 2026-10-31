import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/professional.dart';
import 'package:forensic_expert/app/study.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/domain/learn/study_models.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/features/home/daily_fact.dart';

import '../helpers/home_desk_world.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Ekspert «Ish stolim» + «Bugungi ma’lumot» va talaba «O‘qish stolim» +
/// «Bugungi savol»: HAQIQIY pilot paket va yo‘riqnomalar bilan, qotirilgan
/// sana (2026-10-31). Egasi uchun nusxa: `test/golden/goldens/`.
/// Yangilash:
/// `flutter test test/golden/home_desks_golden_test.dart --update-goldens`
void main() {
  late PilotContent content;
  setUpAll(() async => content = await loadPilotContent());

  final fixedNow = DateTime(2026, 10, 31, 9);

  Future<void> shot(
    WidgetTester tester, {
    required String name,
    required UserMode mode,
    Specialty? specialty,
    ThemeMode theme = ThemeMode.light,
    String lang = 'uz',
    Size size = const Size(390, 1500),
  }) async {
    final guidelines = GuidelineBundle.fromJson(
      jsonDecode(
        File('assets/content/guidelines/guidelines_v1.json').readAsStringSync(),
      ) as Map<String, dynamic>,
    );
    final catalog = StudyCatalogBuilder.build(
      knowledge: content.knowledge,
      library: content.library,
      guidelines: guidelines,
    );
    await pumpApp(
      tester,
      settings: completedSettings(lang: lang, mode: mode, theme: theme),
      size: size,
      pixelRatio: 1.5,
      testFixtures: false,
      overrides: [
        ...content.overrides,
        if (specialty != null)
          initialProfileProvider.overrideWithValue(profileOf(specialty)),
        workbenchClockProvider.overrideWithValue(() => fixedNow),
        studyCatalogProvider.overrideWithValue(catalog),
      ],
    );
    await settleImages(tester);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('expert_home_workbench_uz', (t) async {
    await shot(
      t,
      name: 'expert_home_workbench_uz',
      mode: UserMode.professional,
      specialty: Specialty.forensicChemistry,
    );
  });

  testWidgets('expert_home_workbench_medicine_uz', (t) async {
    await shot(
      t,
      name: 'expert_home_workbench_medicine_uz',
      mode: UserMode.professional,
      specialty: Specialty.forensicMedicine,
    );
  });

  testWidgets('student_home_desk_uz', (t) async {
    await shot(t, name: 'student_home_desk_uz', mode: UserMode.student);
  });
}
