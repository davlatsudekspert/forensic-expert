import 'package:fe_content_schema/fe_content_schema.dart'
    show ForensicDiscipline;
import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/search_service.dart';

import '../helpers/pump_app.dart';

// TEST DATA — faqat nomlar va fan xaritasi (ilmiy qiymat yo‘q).
AppSearchService _service() => AppSearchService(
  MultiTokenSearchIndex(const [
    SearchTerm(
      entityId: 'TEST-TOX',
      category: SearchCategory.forensicMedicineTopic,
      term: 'Testanol toxicology topic',
      kind: TermKind.localized,
      lang: 'en',
    ),
    SearchTerm(
      entityId: 'TEST-PATH',
      category: SearchCategory.forensicMedicineTopic,
      term: 'Testanol pathology topic',
      kind: TermKind.localized,
      lang: 'en',
    ),
    SearchTerm(
      entityId: 'TEST-ODONTO',
      category: SearchCategory.forensicMedicineTopic,
      term: 'Unrelated odontology topic',
      kind: TermKind.localized,
      lang: 'en',
    ),
  ]),
  disciplines: const {
    'TEST-TOX': {ForensicDiscipline.forensicToxicology},
    'TEST-PATH': {ForensicDiscipline.forensicPathology},
    'TEST-ODONTO': {ForensicDiscipline.forensicOdontology},
  },
);

void main() {
  testWidgets('fan filtri: faqat natijasi bor fanlar, tanlash cheklaydi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.searchWith('testanol'),
      overrides: [searchServiceProvider.overrideWithValue(_service())],
    );
    await tester.pumpAndSettle();

    Finder chip(String code) => find.byKey(Key('search.discipline.$code'));
    Finder hit(String id) => find.byKey(Key('search.hit.$id'));

    expect(find.byKey(const Key('search.disciplines')), findsOneWidget);
    expect(chip('all'), findsOneWidget);
    expect(chip('forensic_toxicology'), findsOneWidget);
    expect(chip('forensic_pathology'), findsOneWidget);
    // So‘rovga mos natijasi yo‘q fan ko‘rsatilmaydi.
    expect(chip('forensic_odontology'), findsNothing);
    expect(find.text('All disciplines'), findsOneWidget);
    expect(find.text('Forensic pathology'), findsOneWidget);
    expect(hit('TEST-TOX'), findsOneWidget);
    expect(hit('TEST-PATH'), findsOneWidget);

    await tester.ensureVisible(chip('forensic_pathology'));
    await tester.pumpAndSettle();
    await tester.tap(chip('forensic_pathology'));
    await tester.pumpAndSettle();
    expect(hit('TEST-PATH'), findsOneWidget);
    expect(hit('TEST-TOX'), findsNothing);
    expect(
      tester.widget<ChoiceChip>(chip('forensic_pathology')).selected,
      isTrue,
    );
    // Chiplar ro‘yxati filtrlangan natijadan emas — boshqa fan qoladi.
    expect(chip('forensic_toxicology'), findsOneWidget);

    await tester.ensureVisible(chip('all'));
    await tester.pumpAndSettle();
    await tester.tap(chip('all'));
    await tester.pumpAndSettle();
    expect(hit('TEST-TOX'), findsOneWidget);
    expect(hit('TEST-PATH'), findsOneWidget);
  });

  testWidgets('natijasiz so‘rovda fan filtri ko‘rinmaydi', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(),
      initialLocation: Routes.searchWith('zzzzqqq'),
      overrides: [searchServiceProvider.overrideWithValue(_service())],
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search.noResults')), findsOneWidget);
    expect(find.byKey(const Key('search.disciplines')), findsNothing);
  });
}
