import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/guidelines.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/evidence/provenance_models.dart';

import '../helpers/pump_app.dart';

/// Test kontenti — tuzilma tekshiruvi (haqiqiy ilmiy da’vo emas).
TermTranslation _term(String id, String uz, String ru, String en) =>
    TermTranslation(
      id: id,
      kind: ScientificTermKind.term,
      original: uz,
      originalLang: 'uz',
      canonical: en,
      localized: {'uz': uz, 'ru': ru, 'en': en},
      status: const {
        'uz': TranslationStatus.machineDraft,
        'ru': TranslationStatus.machineDraft,
        'en': TranslationStatus.machineDraft,
      },
    );

final _provenance = ProvenanceIndex(
  terms: [
    _term(
      'T-TEST-STEAM',
      'suv bug‘i bilan haydash',
      'перегонка с водяным паром',
      'steam distillation',
    ),
    _term('T-TEST-DIALYSIS', 'dializ', 'диализ', 'dialysis'),
  ],
);

final _bundle = jsonEncode({
  'schema': 'fe-guidelines/1',
  'cards': [
    {
      'id': 'gl.chem.iso',
      'discipline_codes': ['forensic_chemistry'],
      'status': 'NEEDS_REVIEW',
      'title': {
        'uz': 'Ajratib olish kartasi',
        'ru': 'Карточка изолирования',
        'en': 'Isolation card',
      },
      'translation_status': {'uz': 'AUTHORED', 'ru': 'DRAFT', 'en': 'DRAFT'},
      'term_ids': ['T-TEST-STEAM', 'T-NOT-IN-PACK'],
      'sections': [
        {
          'key': 'basis',
          'title': {'uz': 'Asos', 'ru': 'Основа', 'en': 'Basis'},
          'body': {'uz': 'Matn.', 'ru': 'Текст.', 'en': 'Text.'},
          'citations': <String>[],
        },
      ],
    },
  ],
  'references': <Object>[],
});

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required String lang,
    required String location,
    Size size = const Size(390, 844),
    double textScale = 1,
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: lang),
    size: size,
    textScale: textScale,
    initialLocation: location,
    overrides: [
      provenanceIndexProvider.overrideWithValue(_provenance),
      guidelineBundleLoaderProvider.overrideWithValue(() async => _bundle),
    ],
  );

  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('Kutubxona → Ilmiy lug‘at: ro‘yxat, filtr, atama, karta', (
    tester,
  ) async {
    await pump(tester, lang: 'uz', location: Routes.library);
    await tapKey(tester, 'library.hub.terms');
    expect(find.text('Ilmiy lug‘at'), findsWidgets);
    // Joriy til (uz) + ostida ru/en.
    expect(find.text('suv bug‘i bilan haydash'), findsOne);
    expect(find.text('RU  перегонка с водяным паром'), findsOne);
    expect(find.text('EN  steam distillation'), findsOne);

    // Rus va ingliz tilida filtr.
    await tester.enterText(find.byKey(const Key('glossary.filter')), 'диализ');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('glossary.term.T-TEST-DIALYSIS')), findsOne);
    expect(find.byKey(const Key('glossary.term.T-TEST-STEAM')), findsNothing);
    await tester.enterText(find.byKey(const Key('glossary.filter')), 'steam');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('glossary.term.T-TEST-STEAM')), findsOne);
    await tester.enterText(find.byKey(const Key('glossary.filter')), 'zzqq');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('glossary.empty')), findsOne);
    await tester.enterText(find.byKey(const Key('glossary.filter')), 'steam');
    await tester.pumpAndSettle();

    await tapKey(tester, 'glossary.term.T-TEST-STEAM');
    expect(find.byKey(const Key('glossary.badge.machineDraft')), findsOne);
    expect(find.text('Mashina tarjimasi — tekshirilmagan'), findsOne);
    expect(find.byKey(const Key('glossary.machineDraftNote')), findsOne);
    for (final code in ['uz', 'ru', 'en']) {
      expect(find.byKey(Key('glossary.lang.$code')), findsOne);
    }
    expect(find.text('перегонка с водяным паром'), findsOne);

    await tapKey(tester, 'glossary.card.gl.chem.iso');
    expect(find.text('Ajratib olish kartasi'), findsOne);
    // Kartadagi «Atamalar»: faqat paketda bor atama (noma’lumi tashlanadi).
    expect(find.byKey(const Key('guideline.terms')), findsOne);
    expect(find.byKey(const Key('guideline.index.terms')), findsOne);
    expect(find.byKey(const Key('guideline.term.T-TEST-STEAM')), findsOne);
    expect(find.byKey(const Key('guideline.term.T-NOT-IN-PACK')), findsNothing);

    await tapKey(tester, 'guideline.term.T-TEST-STEAM');
    expect(find.byKey(const Key('glossary.sheet')), findsOne);
    expect(
      find.descendant(
        of: find.byKey(const Key('glossary.sheet')),
        matching: find.byKey(const Key('glossary.badge.machineDraft')),
      ),
      findsOne,
    );
    await tapKey(tester, 'glossary.sheet.open');
    expect(find.byKey(const Key('glossary.detail')), findsOne);
  });

  testWidgets('Global qidiruv: ruscha so‘rov → lug‘at yozuvi (en UI)', (
    tester,
  ) async {
    await pump(tester, lang: 'en', location: Routes.searchWith('перегонка'));
    final hit = find.byKey(const Key('search.hit.T-TEST-STEAM'));
    expect(hit, findsOne);
    // Sarlavha — joriy tilda; meta — lug‘at va topilgan rus atamasi.
    expect(
      find.descendant(of: hit, matching: find.text('steam distillation')),
      findsOne,
    );
    expect(
      find.descendant(
        of: hit,
        matching: find.textContaining('Scientific glossary'),
      ),
      findsOne,
    );
    await tester.tap(hit);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('glossary.detail')), findsOne);
    expect(find.text('Machine translation — not verified'), findsOne);
  });

  for (final lang in ['ru', 'en', 'uz']) {
    testWidgets('320 dp, 2x matn: lug‘at va atama toshmaydi ($lang)', (
      tester,
    ) async {
      await pump(
        tester,
        lang: lang,
        location: Routes.glossary,
        size: const Size(320, 640),
        textScale: 2,
      );
      expect(find.byKey(const Key('glossary.list')), findsOne);
      await tapKey(tester, 'glossary.term.T-TEST-STEAM');
      expect(find.byKey(const Key('glossary.badge.machineDraft')), findsOne);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
