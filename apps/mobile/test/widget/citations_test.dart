import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/guidelines.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';

import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Iqtibos eksporti: manba kartasidan va sahifadagi barcha manbalardan
/// nusxalash (HAQIQIY pilot paket; Clipboard — mock).
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  final uz = lookupAppLocalizations(const Locale('uz'));
  final en = lookupAppLocalizations(const Locale('en'));
  final ru = lookupAppLocalizations(const Locale('ru'));

  Future<void> scrollTo(WidgetTester tester, Finder f) async {
    await tester.scrollUntilVisible(
      f,
      400,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('etanol: manba kartasi → GOST iqtibos nusxalanadi', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.libraryEntry('ethanol'),
      testFixtures: false,
      overrides: pilot.overrides,
    );
    await settleImages(tester);
    final cite = find.byKey(const Key('source.cite.SRC-PUBCHEM-702'));
    await scrollTo(tester, cite);
    await tester.tap(cite);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cite.sheet')), findsOneWidget);
    expect(find.byKey(const Key('cite.note')), findsOneWidget);
    await tester.tap(find.byKey(const Key('cite.copy')));
    await tester.pumpAndSettle();
    expect(
      copied,
      'PubChem Compound Summary for CID 702 (ethanol) [Elektron resurs] / '
      'National Center for Biotechnology Information (NCBI), U.S. National '
      'Library of Medicine. – URL: https://pubchem.ncbi.nlm.nih.gov/compound/702 '
      '(murojaat sanasi: 04.10.2026).',
    );
    expect(find.text(uz.citeCopied), findsOneWidget);
    expect(find.byKey(const Key('cite.sheet')), findsNothing);
  });

  testWidgets('etanol: «Barcha manbalar ro‘yxati» — raqamlangan GOST ro‘yxat', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.libraryEntry('ethanol'),
      testFixtures: false,
      overrides: pilot.overrides,
    );
    await settleImages(tester);
    final action = find.text(uz.citeAllSources);
    await scrollTo(tester, action);
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cite.note')), findsOneWidget);
    await tester.tap(find.byKey(const Key('cite.copy')));
    await tester.pumpAndSettle();
    final lines = const LineSplitter().convert(copied!);
    expect(lines.length, greaterThan(1));
    for (final (i, line) in lines.indexed) {
      expect(line, startsWith('${i + 1}. '));
      expect(line, endsWith('.'));
    }
    expect(copied, contains('[Elektron resurs]'));
    expect(copied, contains('murojaat sanasi: '));
    expect(find.text(uz.citeListCopied(lines.length)), findsOneWidget);
  });

  testWidgets('provenance oynasi: manba iqtibosi (ru → ГОСТ)', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'ru'),
      initialLocation: Routes.libraryEntry('ethanol'),
      testFixtures: false,
      overrides: pilot.overrides,
    );
    await settleImages(tester);
    bool isProv(Widget w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('claim.provenance.');
    final prov = find.byWidgetPredicate(isProv).first;
    await scrollTo(tester, prov);
    await tester.tap(prov);
    await tester.pumpAndSettle();
    bool isCite(Widget w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('provenance.cite.');
    final cite = find.byWidgetPredicate(isCite).first;
    await tester.ensureVisible(cite);
    await tester.pumpAndSettle();
    await tester.tap(cite);
    await tester.pumpAndSettle();
    expect(find.text(ru.citeStyleGost), findsOneWidget);
    await tester.tap(find.byKey(const Key('cite.copy')));
    await tester.pumpAndSettle();
    expect(copied, isNotNull);
    expect(copied, endsWith('.'));
    expect(copied, isNot(startsWith('1. ')));
    expect(find.text(ru.citeCopied), findsOneWidget);
  });

  testWidgets('yo‘riqnoma (en): APA standart, Vancouver’ga almashtirish', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'en'),
      initialLocation: Routes.guideline('gl.test'),
      overrides: [
        guidelineBundleLoaderProvider.overrideWithValue(() async => _bundle),
      ],
    );
    // Bitta adabiyot qatoridagi tugma.
    final cite = find.byKey(const Key('guideline.cite.r1'));
    await scrollTo(tester, cite);
    await tester.tap(cite);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cite.copy')));
    await tester.pumpAndSettle();
    expect(
      copied,
      'Author, A. (2000). Test reference. Test Journal, 1(2), 3–4. '
      'https://doi.org/10.0000/test',
    );
    expect(find.text(en.citeCopied), findsOneWidget);

    // Sahifadagi barcha adabiyotlar — Vancouver.
    final all = find.text(en.citeAllSources);
    await scrollTo(tester, all);
    await tester.tap(all);
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.citeStyleVancouver));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cite.copy')));
    await tester.pumpAndSettle();
    expect(
      copied,
      '1. Author A. Test reference. Test Journal. 2000;1(2):3-4. '
      'doi:10.0000/test.\n'
      '2. Test Body. Test standard [Internet]. 2019 [cited 2026 Oct 8]. '
      'Available from: https://example.org/std',
    );
  });
}

// Test kontenti — haqiqiy ilmiy da’vo emas (faqat tuzilma tekshiruvi).
final _bundle = jsonEncode({
  'schema': 'fe-guidelines/1',
  'cards': [
    {
      'id': 'gl.test',
      'discipline_codes': ['forensic_chemistry'],
      'status': 'NEEDS_REVIEW',
      'updated': '2026-10-08',
      'title': {'en': 'Test card'},
      'translation_status': {'en': 'AUTHORED'},
      'sections': [
        {
          'key': 'basis',
          'title': {'en': 'Scientific basis'},
          'body': {'en': 'Test text [r1] [r2].'},
          'citations': ['r1', 'r2'],
        },
      ],
    },
  ],
  'references': [
    {
      'key': 'r1',
      'type': 'journal_article',
      'authors': ['Author A'],
      'title': 'Test reference',
      'journal': 'Test Journal',
      'year': 2000,
      'volume': '1',
      'issue': '2',
      'pages': '3-4',
      'doi': '10.0000/test',
    },
    {
      'key': 'r2',
      'type': 'standard',
      'authors': ['Test Body'],
      'title': 'Test standard',
      'year': 2019,
      'url': 'https://example.org/std',
      'verified_on': '2026-10-08',
    },
  ],
});
