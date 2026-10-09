import 'dart:convert';
import 'dart:io';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/domain/learn/study_models.dart';

import '../helpers/pilot_content.dart';

/// «Giyohvand moddalar tahlili» (GMT): o‘quv rejimidagi savollar va
/// glossariy terminlari — manbali, bepul, machine_draft.
void main() {
  final guidelines = GuidelineBundle.fromJson(
    (jsonDecode(
      File('assets/content/guidelines/guidelines_v1.json').readAsStringSync(),
    ) as Map).cast<String, Object?>(),
  );

  group('O‘quv rejimi: GMT savollari', () {
    // Pullik ruxsatlarsiz (bepul foydalanuvchi) qurilgan katalog.
    final free = StudyCatalogBuilder.build(guidelines: guidelines);
    final deck = free.deck(StudyCatalogBuilder.gmtDeckId);

    test('alohida bepul to‘plam, ≥30 savol (Pro ortida emas)', () {
      expect(deck, isNotNull);
      expect(deck!.kind, StudyDeckKind.teachingMaterial);
      expect(deck.key, StudyCatalogBuilder.gmtDeckKey);
      expect(deck.items.length, greaterThanOrEqualTo(30));
      expect(
        deck.items.every((i) => i.originId.startsWith('guideline.chem.gmt_')),
        isTrue,
      );
      final unlocked = StudyCatalogBuilder.build(
        guidelines: guidelines,
        substancesUnlocked: true,
        referencesUnlocked: true,
      );
      expect(
        unlocked.deck(StudyCatalogBuilder.gmtDeckId)!.items.length,
        deck.items.length,
      );
      // «Toksikologik kimyo» to‘plamiga aralashmaydi.
      final toks = free.deck(StudyCatalogBuilder.toksDeckId);
      if (toks != null) {
        expect(
          toks.items.any((i) => i.originId.startsWith('guideline.chem.gmt_')),
          isFalse,
        );
      }
    });

    test('har bir savol manbali; qo‘llanma sahifa bilan; NEEDS_REVIEW', () {
      for (final i in deck!.items) {
        expect(i.kind, StudyItemKind.guidelineQuestion);
        expect(i.citations, isNotEmpty, reason: i.id);
        expect(i.status, ScientificStatus.needsReview, reason: i.id);
        expect(i.distractors, hasLength(3), reason: i.id);
        for (final c in i.citations) {
          if (c.title.contains('Giyohvand moddalar tahlili')) {
            expect(c.pages, isNotNull, reason: i.id);
          }
        }
      }
      // Faqat PubChem/UNODC ga tayangan savol kitobni manba deb ko‘rsatmaydi.
      final fentanyl = deck.items.firstWhere((i) => i.id.endsWith('gmt.op.6'));
      expect(
        fentanyl.citations.any((c) => c.title.contains('PubChem')),
        isTrue,
      );
      final marquis = deck.items.firstWhere((i) => i.id.endsWith('gmt.op.4'));
      expect(
        marquis.citations.every((c) => !c.title.contains('Giyohvand')),
        isTrue,
      );
    });

    test('test: 3 ta aniq variant + to‘g‘ri javob, deterministik', () {
      final questions = StudyQuizBuilder.build(
        deck!,
        free,
        seed: 7,
        length: deck.items.length,
      );
      expect(questions, hasLength(deck.items.length));
      for (final q in questions) {
        expect(q.asksForPrompt, isFalse);
        expect(q.options, hasLength(4));
        expect(
          q.optionText(q.correctIndex).resolve('uz'),
          q.item.answer.resolve('uz'),
        );
      }
      final again = StudyQuizBuilder.build(
        deck,
        free,
        seed: 7,
        length: deck.items.length,
      );
      expect(
        [for (final q in again) q.item.id],
        [for (final q in questions) q.item.id],
      );
    });
  });

  group('Glossariy (term_translations)', () {
    test(
      'GMT terminlari imzolangan paketda: uz asl, ru/en, machine_draft',
      () async {
        final pilot = await loadPilotContent();
        final terms = [
          for (final t in pilot.provenance.terms)
            if (t.id.startsWith('T-GMT-')) t,
        ];
        expect(terms.length, greaterThanOrEqualTo(40));
        for (final t in terms) {
          expect(t.kind, ScientificTermKind.term, reason: t.id);
          expect(t.originalLang, 'uz', reason: t.id);
          expect(t.localized['uz'], t.original, reason: t.id);
          for (final lang in ['uz', 'ru', 'en']) {
            expect(t.localized[lang], isNotEmpty, reason: '${t.id}/$lang');
            expect(t.status[lang], TranslationStatus.machineDraft);
            // Faqat termin — ta’rif emas.
            expect(t.localized[lang]!.length, lessThan(60), reason: t.id);
          }
          expect(t.original, isNot(contains("'")), reason: t.id);
        }
        expect(
          terms.map((t) => t.original),
          containsAll([
            'giyohvandlik vositasi',
            'prekursor',
            'Markis reaktivi',
          ]),
        );
      },
    );
  });
}
