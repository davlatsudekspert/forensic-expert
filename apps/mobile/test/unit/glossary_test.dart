import 'dart:convert';
import 'dart:io';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/search_service.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart';
import 'package:forensic_expert/domain/glossary/glossary.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';

import '../helpers/pilot_content.dart';

/// «Ilmiy lug‘at»: HAQIQIY pilot paketdagi `term_translations` va
/// yo‘riqnoma kartalaridagi aniq `term_ids` bog‘lanishi.
void main() {
  late PilotContent pilot;
  late GuidelineBundle guidelines;
  late Glossary glossary;
  late AppSearchService search;

  setUpAll(() async {
    pilot = await loadPilotContent();
    guidelines = GuidelineBundle.fromJson(
      (jsonDecode(
        File('assets/content/guidelines/guidelines_v1.json').readAsStringSync(),
      ) as Map).cast<String, Object?>(),
    );
    glossary = Glossary.build(pilot.provenance.terms, guidelines);
    search = AppSearchService.build(
      library: const FixtureLibraryRepository(),
      learn: const FixtureLearnRepository(),
      provenance: pilot.provenance,
      guidelines: guidelines,
    );
  });

  const toksCards = [
    'guideline.chem.toks_isolation',
    'guideline.chem.toks_mineralization',
    'guideline.chem.toks_metal_poisons',
    'guideline.chem.toks_volatile_poisons',
    'guideline.chem.toks_pesticides',
  ];

  const gmtCards = [
    'guideline.chem.gmt_analysis_scheme',
    'guideline.chem.gmt_opioids',
    'guideline.chem.gmt_cocaine',
    'guideline.chem.gmt_cannabis',
    'guideline.chem.gmt_phenylalkylamines',
    'guideline.chem.gmt_barbiturates',
    'guideline.chem.gmt_benzodiazepines',
    'guideline.chem.gmt_precursors',
    'guideline.chem.gmt_uz_control_lists',
  ];

  group('yuklash', () {
    test('paketdagi barcha atamalar (38 T-TOKS, 48 T-GMT) lug‘atda', () {
      expect(glossary.terms.length, pilot.provenance.terms.length);
      expect(glossary.terms.length, greaterThanOrEqualTo(58));
      expect(
        glossary.terms.where((t) => t.id.startsWith('T-TOKS-')).length,
        38,
      );
      expect(glossary.terms.where((t) => t.id.startsWith('T-GMT-')).length, 48);
    });

    test('mashina tarjimasi hech qachon tasdiqlangan deb ko‘rsatilmaydi', () {
      for (final t in glossary.terms) {
        if (t.translation.status.values.contains(
          TranslationStatus.machineDraft,
        )) {
          expect(t.hasMachineDraft, isTrue, reason: t.id);
          expect(t.isReviewed, isFalse, reason: t.id);
        }
      }
    });

    test('har bir toks kartasida atamalar bor; bog‘lanish ikki tomonlama', () {
      for (final id in toksCards) {
        final terms = glossary.termsOfCard(id);
        expect(terms, isNotEmpty, reason: id);
        for (final t in terms) {
          expect(t.cardIds, contains(id), reason: '${t.id} ← $id');
        }
      }
      final steam = glossary.byId('T-TOKS-STEAM-DISTILLATION')!;
      expect(
        steam.cardIds,
        containsAll([
          'guideline.chem.toks_isolation',
          'guideline.chem.toks_volatile_poisons',
        ]),
      );
      for (final id in gmtCards) {
        expect(glossary.termsOfCard(id), isNotEmpty, reason: id);
      }
      expect(
        glossary.byId('T-GMT-MARQUIS-REAGENT')!.cardIds,
        containsAll([
          'guideline.chem.gmt_opioids',
          'guideline.chem.gmt_phenylalkylamines',
        ]),
      );
      // Umumiy atama — kartaga bog‘lanmagan (taxmin yo‘q).
      expect(glossary.byId('T-TOKS-XENOBIOTIC')!.cardIds, isEmpty);
      // Toks bo‘lmagan karta — atamasiz.
      expect(glossary.termsOfCard('guideline.chem.ethanol_gc'), isEmpty);
    });

    test('mavjud bo‘lmagan atama ID si e’tiborsiz qoldiriladi', () {
      final g = Glossary.build(
        pilot.provenance.terms,
        const GuidelineBundle(
          cards: [
            GuidelineCard(
              id: 'x',
              title: Tri({'uz': 'X'}),
              disciplineCodes: [],
              status: ScientificStatus.needsReview,
              sections: [],
              termIds: ['T-NOPE', 'T-TOKS-DIALYSIS'],
            ),
          ],
        ),
      );
      expect(g.termsOfCard('x').map((t) => t.id), ['T-TOKS-DIALYSIS']);
    });

    test('joriy til + qolgan ikki til (bir xil matn takrorlanmaydi)', () {
      final steam = glossary.byId('T-TOKS-STEAM-DISTILLATION')!;
      expect(steam.textIn('ru'), 'перегонка с водяным паром');
      expect(steam.othersFor('ru').map((e) => e.$1), ['uz', 'en']);
      expect(glossary.byId('T-GC-MS')!.othersFor('uz'), isEmpty);
    });
  });

  group('filtr (uch tilda)', () {
    for (final (q, lang) in [
      ('перегонка', 'uz'),
      ('steam distillation', 'ru'),
      ('suv bug‘i', 'en'),
      ('suv bugi', 'uz'), // apostrofsiz yozilsa ham
    ]) {
      test('«$q» ($lang) → T-TOKS-STEAM-DISTILLATION', () {
        expect(
          glossary.list(lang, query: q).map((t) => t.id),
          contains('T-TOKS-STEAM-DISTILLATION'),
        );
      });
    }

    test('alifbo tartibi joriy tilda; mos kelmasa — bo‘sh', () {
      final ru = glossary.list('ru').map((t) => t.textIn('ru').toLowerCase());
      expect(ru.toList(), [...ru]..sort());
      expect(glossary.list('uz', query: 'qwxzqwxz'), isEmpty);
    });
  });

  group('global qidiruv (uch tilda)', () {
    for (final (q, lang, id) in [
      ('перегонка с водяным паром', 'uz', 'T-TOKS-STEAM-DISTILLATION'),
      ('steam distillation', 'uz', 'T-TOKS-STEAM-DISTILLATION'),
      ('suv bug‘i bilan haydash', 'en', 'T-TOKS-STEAM-DISTILLATION'),
      ('дитизон', 'en', 'T-TOKS-DITHIZONE'),
      ('Marsh test', 'ru', 'T-TOKS-MARSH-TEST'),
      ('murda dog‘lari', 'uz', 'T-LIVOR-MORTIS'),
      ('реактив Марки', 'uz', 'T-GMT-MARQUIS-REAGENT'),
      ('hashish', 'ru', 'T-GMT-HASHISH-CANNABIS-RESIN'),
    ]) {
      test('«$q» ($lang) → $id', () async {
        final r = await search.search(q, lang: lang);
        final hits = r.groups[SearchGroup.learning]!;
        final hit = hits.where((h) => h.entityId == id).firstOrNull;
        expect(hit, isNotNull, reason: hits.map((h) => h.entityId).join(','));
        expect(hit!.category, SearchCategory.glossary);
      });
    }

    test('fan filtri: toks atamasi kimyo fani bilan topiladi', () async {
      final r = await search.search(
        'дитизон',
        lang: 'ru',
        discipline: ForensicDiscipline.forensicChemistry,
      );
      expect(r.discipline, ForensicDiscipline.forensicChemistry);
      expect(
        r.groups[SearchGroup.learning]!.map((h) => h.entityId),
        contains('T-TOKS-DITHIZONE'),
      );
    });
  });
}
