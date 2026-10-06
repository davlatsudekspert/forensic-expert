import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/library/full_text.dart';
import 'package:forensic_expert/domain/library/library_models.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

SourceView _src(String id, {String? url}) => SourceView(
  sourceId: id,
  title: 'T',
  sourceType: 'journal_article',
  evidenceLevel: 'B',
  licenseMode: 'metadata_only',
  identifierVerified: true,
  url: url,
);

void main() {
  test('faqat PubMed Central (ochiq kirish) maqolalari uchun PDF havola', () {
    expect(
      openAccessPdfUrl(_src('SRC-PMC8400298')).toString(),
      'https://europepmc.org/articles/PMC8400298?pdf=render',
    );
    expect(
      pmcidOf(
        _src('X', url: 'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC123456/'),
      ),
      'PMC123456',
    );
    expect(openAccessPdfUrl(_src('SRC-DOI-10.1/x')), isNull);
  });

  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  for (final pro in [false, true]) {
    testWidgets('manba sahifasi: PDF tugmasi (pro=$pro)', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.source('SRC-PMC8400298'),
        testFixtures: false,
        overrides: [
          ...pilot.overrides,
          entitlementServiceProvider.overrideWithValue(FakeStore(owned: pro)),
        ],
      );
      expect(find.byKey(const Key('source.fullTextPdf')), findsOneWidget);
      expect(find.text('Full text (PDF)'), findsOneWidget);
      expect(
        find.textContaining(pro ? 'Open-access article' : 'available with Pro'),
        findsOneWidget,
      );
      expect(
        find.byIcon(pro ? Icons.picture_as_pdf_outlined : Icons.lock_outline),
        findsOneWidget,
      );
    });
  }
}
