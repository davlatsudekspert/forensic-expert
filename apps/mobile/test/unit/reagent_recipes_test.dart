import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/search_service.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';

import '../helpers/pilot_content.dart';

/// Ilova egasi to‘plami «Приготовление реактивов» (74 band) — HAQIQIY
/// imzolangan pilot paketdan.
void main() {
  late PilotContent pilot;
  late List<KnowledgeEntry> owner;

  setUpAll(() async {
    pilot = await loadPilotContent();
    owner = [
      for (final e in pilot.knowledge.byKind(KnowledgeKind.reagent))
        if (e.recipe?.originalSourceId == 'SRC-OWNER-REAGENTS') e,
    ];
  });

  test(
    '74 band → 74 retsept (2 tasi mavjud Dragendorf/Marki bilan birlashgan)',
    () {
      expect(owner, hasLength(74));
      final ids = owner.map((e) => e.id).toSet();
      expect(ids, containsAll(['reagent-dragendorff', 'reagent-marquis']));
      // Manbasiz qolgan reaktivlar «retsept yo‘q» holatida qoladi.
      final mecke = pilot.knowledge.byId('reagent-mecke')!;
      expect(mecke.recipe!.hasPreparationData, isFalse);
    },
  );

  test(
    'har bir retsept: tarkib, bosqich, NEEDS_REVIEW, machine_draft, asl matn',
    () {
      for (final e in owner) {
        final r = e.recipe!;
        expect(e.status, ScientificStatus.needsReview, reason: e.id);
        expect(r.status, ScientificStatus.needsReview, reason: e.id);
        expect(r.ingredients, isNotEmpty, reason: e.id);
        expect(r.steps, isNotEmpty, reason: e.id);
        expect(r.translationStatus, 'machine_draft', reason: e.id);
        expect(r.originalLanguage, 'ru', reason: e.id);
        expect(r.originalText, isNotEmpty, reason: e.id);
        for (final lang in ['uz', 'ru', 'en']) {
          expect(e.name.values[lang], isNotEmpty, reason: '${e.id} $lang');
        }
        for (final s in r.steps.where((s) => s.variant != 'pmc')) {
          expect(s.order, isNotNull, reason: e.id);
          for (final lang in ['uz', 'ru', 'en']) {
            expect(s.texts[lang], isNotEmpty, reason: '${e.id} step $lang');
          }
        }
        for (final i in r.ingredients) {
          // Raqam yo‘q bo‘lsa — manbadagi izoh bor (taxmin qilinmaydi).
          expect(
            i.amount != null || i.quantityNote.isNotEmpty,
            isTrue,
            reason: '${e.id} ${i.name}',
          );
        }
        // Xavf izohi faqat PubChem yoki tahririy manbaga bog‘langan.
        for (final h in r.hazards) {
          expect(['ghs', 'general'], contains(h.kind), reason: e.id);
          expect(
            h.sourceId == 'SRC-FE-EDITORIAL' ||
                h.sourceId.startsWith('SRC-PUBCHEM-'),
            isTrue,
            reason: e.id,
          );
        }
      }
    },
  );

  test(
    'Dragendorf: raqamlar manbadagidek (8 g, 20 ml, 27,2 g, 30 ml, 100 ml)',
    () {
      final r = pilot.knowledge.byId('reagent-dragendorff')!.recipe!;
      final own = [
        for (final i in r.ingredients)
          if (i.variant == 'own') (i.amount, i.unit, i.makeUpTo),
      ];
      expect(own, [
        (8, 'g', false),
        (20, 'mL', false),
        (27.2, 'g', false),
        (30, 'mL', false),
        (100, 'mL', true),
      ]);
      // Oldingi PMC retsepti yo‘qolmagan — alohida variant.
      expect(r.variants.map((v) => v.id), ['own', 'pmc']);
      expect(
        r.steps.where((s) => s.variant == 'pmc').single.text,
        startsWith('Dragendorff’s reagent was prepared by mixing'),
      );
      expect(r.originalText, startsWith('32. Реактив Драгендорфа.'));
    },
  );

  test(
    'benzidin: kanserogen ogohlantirish (umumiy tavsiya + PubChem H350)',
    () {
      final r = pilot.knowledge.byId('reagent-benzidine-paper')!.recipe!;
      final general = r.hazards.where((h) => h.kind == 'general');
      expect(general.first.resolve('uz'), contains('kanserogen'));
      expect(general.first.resolve('uz'), contains('tayyorlamaslik'));
      expect(
        r.hazards.any((h) => h.kind == 'ghs' && h.text.contains('H350')),
        isTrue,
      );
    },
  );

  test('simob tuzlari va brom: GHS xavf izohlari bor', () {
    for (final id in [
      'reagent-mayer',
      'reagent-nessler',
      'reagent-bromine-water',
      'reagent-millon',
    ]) {
      final r = pilot.knowledge.byId(id)!.recipe!;
      expect(r.hazards.where((h) => h.kind == 'ghs'), isNotEmpty, reason: id);
    }
  });

  group('qidiruv sinonimlari', () {
    late AppSearchService service;
    setUpAll(() {
      service = AppSearchService.build(
        library: pilot.library,
        learn: const EmptyLearnRepository(),
        knowledge: pilot.knowledge,
      );
    });

    Future<List<String>> reagents(String q) async => [
      for (final h in (await service.search(q)).groups[SearchGroup.reagents]!)
        h.entityId,
    ];

    for (final (q, id) in [
      ('Dragendorf', 'reagent-dragendorff'),
      ('Драгендорф', 'reagent-dragendorff'),
      ('Dragendorff', 'reagent-dragendorff'),
      ('Marki', 'reagent-marquis'),
      ('Марки', 'reagent-marquis'),
      ('Marquis', 'reagent-marquis'),
      ('Mayer', 'reagent-mayer'),
      ('Несслер', 'reagent-nessler'),
      ('Erdman', 'reagent-erdmann'),
      ('Frede', 'reagent-frohde'),
    ]) {
      test('«$q» → $id', () async {
        expect(await reagents(q), contains(id));
      });
    }
  });
}
