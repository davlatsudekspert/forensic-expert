import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/features/legal/presentation/norms_screen.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// O‘zbekiston: sud-ekspertiza normalari (JPK 68, JK 238–240, yangi/eski
/// sud-ekspertlik qonuni) — HAQIQIY paket bilan.
void main() {
  setUpAll(() => testDefaultPlan = Plan.expert);
  tearDownAll(() => testDefaultPlan = null);
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> open(WidgetTester tester, String loc, {String lang = 'uz'}) =>
      pumpApp(
        tester,
        settings: completedSettings(
          lang: lang,
          mode: UserMode.professional,
        ).copyWith(jurisdictionId: 'UZ'),
        initialLocation: loc,
        testFixtures: false,
        overrides: [...pilot.overrides],
      );

  test('paketda kerakli normalar va sanalar bor', () {
    final rules = pilot.legal.rules
        .where((r) => r.subjectType == kExpertNormSubject)
        .toList();
    final ids = {for (final r in rules) r.id};
    for (final id in [
      'R-UZ-JPK-68',
      'R-UZ-JK-238',
      'R-UZ-JK-240',
      'R-UZ-LAW-1152-39',
    ]) {
      expect(ids, contains(id));
    }
    final byId = {for (final i in pilot.legal.instruments) i.id: i};
    expect(byId['UZ-LAW-1152']!.effectiveFrom, DateTime(2026, 12, 13));
    expect(byId['UZ-LAW-249']!.effectiveTo, DateTime(2026, 12, 13));
  });

  test('normTimingOf: sanadan aniq holat', () {
    final byId = {for (final i in pilot.legal.instruments) i.id: i};
    final before = DateTime(2026, 11, 7);
    final after = DateTime(2026, 12, 20);
    expect(normTimingOf(byId['UZ-LAW-1152']!, before), NormTiming.notYet);
    expect(normTimingOf(byId['UZ-LAW-249']!, before), NormTiming.endsOn);
    expect(normTimingOf(byId['UZ-LAW-1152']!, after), NormTiming.inForce);
    expect(normTimingOf(byId['UZ-LAW-249']!, after), NormTiming.inForce);
    expect(normTimingOf(byId['UZ-JPK']!, before), NormTiming.inForce);
  });

  testWidgets('UZ sahifasida «Sud-ekspertiza normalari» kirish nuqtasi', (
    tester,
  ) async {
    await open(tester, Routes.jurisdiction('UZ'));
    expect(find.byKey(const Key('jurisdiction.norms')), findsOneWidget);
    expect(find.text('Sud-ekspertiza normalari'), findsWidgets);
  });

  testWidgets('Normalar ekrani: hujjatlar, JPK 68, ogohlantirish, ru/en', (
    tester,
  ) async {
    await open(tester, Routes.jurisdictionNorms('UZ'));
    expect(find.byKey(const Key('norms.review')), findsOneWidget);
    expect(find.byKey(const Key('norms.instrument.UZ-JPK')), findsOneWidget);
    expect(find.byKey(const Key('norm.R-UZ-JPK-68')), findsOneWidget);
    // Yangi qonun: «kuchga kirmagan» belgisi (bugun 2026-12-13 gacha).
    if (DateTime.now().isBefore(DateTime(2026, 12, 13))) {
      expect(find.byKey(const Key('norms.timing.UZ-LAW-1152')), findsOneWidget);
      expect(find.byKey(const Key('norms.timing.UZ-LAW-249')), findsOneWidget);
    }
  });

  testWidgets('Normalar ekrani ruscha va inglizcha ochiladi', (tester) async {
    for (final lang in ['ru', 'en']) {
      await open(tester, Routes.jurisdictionNorms('UZ'), lang: lang);
      expect(find.byKey(const Key('norms.review')), findsOneWidget);
      expect(find.byKey(const Key('norm.R-UZ-JPK-68')), findsOneWidget);
    }
  });
}
