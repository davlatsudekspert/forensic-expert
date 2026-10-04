import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/jurisdiction/country_directory.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 10: global huquq va yurisdiksiya.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> open(WidgetTester tester, String location) => pumpApp(
    tester,
    settings: completedSettings(),
    initialLocation: location,
    testFixtures: false,
    overrides: [
      ...pilot.overrides,
      entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
    ],
  );

  Future<void> see(WidgetTester tester, Finder f) async {
    await tester.dragUntilVisible(
      f.first,
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(f, findsWidgets);
  }

  test('249 davlat katalogi bor, lekin huquqiy kontent faqat 5 ta '
      'yurisdiksiyada', () {
    expect(CountryDirectory.all.length, 249);
    final withContent = {
      for (final i in pilot.legal.instruments) i.jurisdictionId,
    };
    expect(withContent, containsAll(['INT', 'GB', 'US', 'DE', 'UZ']));
    expect(withContent.length, lessThan(10));
  });

  test(
    'har bir rasmiy hujjat: manba, versiya, oxirgi tekshiruv, NEEDS_REVIEW',
    () {
      for (final i in pilot.legal.instruments) {
        expect(i.officialSourceId, isNotEmpty, reason: i.id);
        expect(i.version, isNotEmpty, reason: i.id);
        expect(i.lastVerifiedAt, isNotNull, reason: i.id);
        expect(i.status, ScientificStatus.needsReview, reason: i.id);
      }
    },
  );

  test('INCB qoidalari mavzu kalitisiz (milliy ro‘yxat bilan almashmaydi)', () {
    final byInstrument = {for (final i in pilot.legal.instruments) i.id: i};
    for (final r in pilot.legal.rules) {
      final j = byInstrument[r.instrumentId]!.jurisdictionId;
      if (j == 'INT' && r.ruleType == JurisdictionalRuleType.controlStatus) {
        expect(r.topicKey, isNull, reason: r.id);
      }
      if (j != 'INT' && r.ruleType == JurisdictionalRuleType.controlStatus) {
        expect(r.topicKey, 'controlled_substance.status', reason: r.id);
        expect(legalDomainOf(r), LegalDomain.controlledSubstances);
      }
    }
  });

  testWidgets('DE: huquqiy domenlar, yetishmayotgan maydonlar ochiq', (
    tester,
  ) async {
    await open(tester, Routes.jurisdiction('DE'));
    await see(tester, find.byKey(const Key('instrument.missing.DE-BTMG-ANL')));
    await see(
      tester,
      find.byKey(const Key('jurisdiction.domain.controlledSubstances')),
    );
    await see(tester, find.byKey(const Key('jurisdiction.domain.autopsy')));
    expect(find.text('No verified content'), findsWidgets);
  });

  testWidgets('Compare: modda nazorat holati — GB/US/DE, boshqasi «ma’lumot '
      'yo‘q»', (tester) async {
    await open(tester, Routes.compare);
    final chip = find.byKey(
      const Key('compare.topic.fentanyl.controlled_substance.status'),
    );
    await see(tester, chip);
    await tester.tap(chip.first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Control status'), findsWidgets);
  });
}
