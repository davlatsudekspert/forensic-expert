import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/guidelines.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';

import '../helpers/pump_app.dart';

/// Test kontenti — haqiqiy ilmiy da’vo emas (faqat tuzilma tekshiruvi).
final _bundle = jsonEncode({
  'schema': 'fe-guidelines/1',
  'cards': [
    {
      'id': 'gl.chem.test',
      'discipline_codes': ['forensic_chemistry'],
      // Fayl VERIFIED desa ham — ekspert ko‘rigisiz NEEDS_REVIEW bo‘ladi.
      'status': 'VERIFIED',
      'updated': '2026-10-08',
      'title': {'uz': 'Sinov kartasi', 'en': 'Test card'},
      'translation_status': {'uz': 'AUTHORED', 'en': 'DRAFT'},
      'keywords': {
        'ru': ['газовая хроматография'],
        'en': ['gas chromatography'],
      },
      'related_tool_ids': ['tool.conv.ethanol_units'],
      'sections': [
        {
          'key': 'basis',
          'title': {'uz': 'Ilmiy asos', 'en': 'Scientific basis'},
          'body': {'uz': 'Sinov matni.', 'en': 'Test text.'},
          'citations': ['r1'],
        },
      ],
    },
  ],
  'references': [
    {
      'key': 'r1',
      'authors': ['Author A'],
      'title': 'Test reference',
      'journal': 'Test Journal',
      'year': 2000,
      'doi': '10.0000/test',
      'verified_via': 'fixture',
    },
  ],
});

void main() {
  test('model: VERIFIED fayl ham NEEDS_REVIEW; fallback til belgilanadi', () {
    final b = GuidelineBundle.fromJson(
      (jsonDecode(_bundle) as Map).cast<String, Object?>(),
    );
    final card = b.cards.single;
    expect(card.status, ScientificStatus.needsReview);
    expect(card.area, GuidelineArea.forensicChemistry);
    expect(card.title.pick('ru').isFallback, isTrue);
    expect(card.title.pick('en').text, 'Test card');
    expect(
      b.referencesOf(card).single.link.toString(),
      'https://doi.org/10.0000/test',
    );
    expect(
      () => GuidelineBundle.fromJson({'schema': 'other'}),
      throwsFormatException,
    );
  });

  testWidgets('Yo‘riqnomalar: ro‘yxat, uch tilli qidiruv, karta va manba', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz'),
      initialLocation: Routes.guidelines,
      overrides: [
        guidelineBundleLoaderProvider.overrideWithValue(() async => _bundle),
      ],
    );
    expect(find.text('Yo‘riqnomalar'), findsWidgets);
    expect(find.byKey(const Key('guidelines.card.gl.chem.test')), findsOne);

    await tester.enterText(
      find.byKey(const Key('guidelines.search')),
      'газовая',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('guidelines.card.gl.chem.test')), findsOne);
    await tester.enterText(
      find.byKey(const Key('guidelines.search')),
      'vjvjvj',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('guidelines.noResults')), findsOne);

    await tester.enterText(find.byKey(const Key('guidelines.search')), '');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guidelines.card.gl.chem.test')));
    await tester.pumpAndSettle();
    expect(find.text('Sinov kartasi'), findsOne);
    // Bo‘lim sarlavhasi va «Shu sahifada» qatoridagi havola.
    expect(
      find.textContaining(RegExp('ilmiy asos', caseSensitive: false)),
      findsWidgets,
    );
    expect(find.byKey(const Key('guideline.index')), findsOne);
    expect(find.byKey(const Key('guideline.ref.r1')), findsOne);
    // «Adabiyotlar» havolasi ro‘yxatga olib boradi.
    await tester.tap(find.byKey(const Key('guideline.index.refs')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('guideline.ref.r1')).hitTestable(), findsOne);
    // O‘zbekcha — asl matn: qoralama ogohlantirishi yo‘q.
    expect(find.byKey(const Key('guideline.draftTranslation')), findsNothing);
  });

  testWidgets('ruscha: tarjima yo‘q — asl til ochiq ko‘rsatiladi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'ru'),
      initialLocation: Routes.guideline('gl.chem.test'),
      overrides: [
        guidelineBundleLoaderProvider.overrideWithValue(() async => _bundle),
      ],
    );
    expect(find.byKey(const Key('guideline.fallback')), findsOne);
  });
}
