import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/evidence/content_translations.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Haqiqiy pilot paket + Phase D yon fayli (`localized_texts`): D agenti
/// yozgan tarjimalar ekranda ko‘rinadi (tarjima birinchi, holat belgisi).
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<void> open(WidgetTester tester, String lang, String route) => pumpApp(
    tester,
    settings: completedSettings(lang: lang),
    initialLocation: route,
    testFixtures: false,
    overrides: [
      ...pilot.overrides,
      entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
    ],
  );

  test(
    'yon fayl: format, faqat avtomatik statuslar, noma’lum — e’tiborsiz',
    () {
      final json = jsonDecode(
        File('assets/content/translations/localized_texts.json')
            .readAsStringSync(),
      );
      final rows = ContentTranslations.rowsFromLocalizedTextsJson(json);
      expect(rows.length, greaterThan(200));
      expect(rows.every((r) => !r.status.isHumanVerified), isTrue);
      // Imzolanmagan manba «reviewed» deb ko‘rsata olmaydi.
      final forged = ContentTranslations.rowsFromLocalizedTextsJson({
        'format': 'fe-localized-texts/1',
        'records': [
          {
            'target_type': 'conflict_text',
            'target_id': 'X#note',
            'source_sha256': 'a' * 64,
            'text': {'uz': 'soxta'},
            'status': 'reviewed',
          },
          {'target_type': 'future', 'text': 'bad'},
          'junk',
        ],
      });
      expect(forged, isEmpty);
      expect(
        ContentTranslations.rowsFromLocalizedTextsJson({'format': 'x'}),
        isEmpty,
      );
      expect(ContentTranslations.rowsFromLocalizedTextsJson(null), isEmpty);
    },
  );

  testWidgets('uz: «O‘limdan keyingi o‘zgarishlar» tadqiqotlari — tarjima', (
    tester,
  ) async {
    await open(tester, 'uz', Routes.researchFor('fm-postmortem-changes'));
    expect(
      find.text(
        'O‘limdan keyingi o‘zgarishlarga oid adabiyotlarning 19-asrgacha '
        'bo‘lgan qisqacha tarixi',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('research.originalTitle.RS-e364a9179136')),
      findsOneWidget,
    );
    expect(find.text('Avtomatik tarjima — tekshirilmagan'), findsWidgets);
    // Tarjimasi yo‘q yozuv — ochiq belgi.
    expect(
      find.byKey(const Key('research.originalLang.RS-27c0a417360d')),
      findsOneWidget,
    );
  });

  testWidgets('uz: ziddiyat savoli va skrining maydoni (yon fayl)', (
    tester,
  ) async {
    await open(tester, 'uz', Routes.conflict('CF-VITREOUS-K-PMI'));
    expect(
      find.textContaining('Ko‘z shishasimon tanasidagi kaliy bo‘yicha'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Can vitreous potassium be used to estimate the '
        'post-mortem interval?',
      ),
      findsNothing,
    );
    await open(tester, 'ru', Routes.knowledgeEntry('scr-immunoassay-opiates'));
    expect(find.textContaining('опиаты (по классу)'), findsOneWidget);
  });

  testWidgets('uz: morfin metabolitlari — «morfin-3-glyukuronid (M3G)»', (
    tester,
  ) async {
    await open(tester, 'uz', Routes.libraryEntry('morphine'));
    expect(find.textContaining('morfin-3-glyukuronid (M3G)'), findsWidgets);
    expect(find.textContaining('morphine-3-glucuronide'), findsNothing);
  });

  testWidgets('uz: PMR kartasi — qisqacha tushuntirish birinchi', (
    tester,
  ) async {
    await open(
      tester,
      'uz',
      Routes.knowledgeEntry('tox-postmortem-redistribution'),
    );
    final body = find.byKey(
      const Key('topic.body.tox-postmortem-redistribution'),
    );
    expect(body, findsOneWidget);
    expect(
      find.descendant(of: body, matching: find.text('Qisqacha tushuntirish')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: body,
        matching: find.text('Avtomatik tarjima — tekshirilmagan'),
      ),
      findsOneWidget,
    );
  });
}
