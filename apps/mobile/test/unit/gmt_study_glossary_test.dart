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
    final quiz = [
      for (final d in free.decks)
        for (final i in d.items)
          if (i.kind == StudyItemKind.guidelineQuiz &&
              i.originId.startsWith('guideline.chem.gmt_'))
            i,
    ];

    test('bepul foydalanuvchida ham ≥30 savol bor (Pro ortida emas)', () {
      expect(quiz.length, greaterThanOrEqualTo(30));
      final unlocked = StudyCatalogBuilder.build(
        guidelines: guidelines,
        substancesUnlocked: true,
        referencesUnlocked: true,
      );
      final all = unlocked.itemsOfKind(StudyItemKind.guidelineQuiz);
      expect(
        quiz.length,
        all.where((i) => i.id.startsWith('gquiz.gmt.')).length,
      );
    });

    test('har bir savol manbali, sahifa ko‘rsatilgan, NEEDS_REVIEW', () {
      for (final i in quiz) {
        expect(i.citations, isNotEmpty, reason: i.id);
        expect(i.status, ScientificStatus.needsReview, reason: i.id);
        expect(i.origin, StudyOrigin.guideline);
        expect(i.choices, hasLength(3), reason: i.id);
        for (final c in i.citations) {
          if (c.title.contains('Giyohvand moddalar tahlili')) {
            expect(c.detail, startsWith('p. '), reason: i.id);
          }
        }
      }
      expect(
        quiz.any((i) => i.citations.any((c) => c.title.contains('Yuldashev'))),
        isTrue,
      );
    });

    test('test: kartadagi 3 ta variant + to‘g‘ri javob, savol — prompt', () {
      final deck = free.decks.firstWhere(
        (d) => d.items.any((i) => i.kind == StudyItemKind.guidelineQuiz),
      );
      final questions = StudyQuizBuilder.build(
        deck,
        free,
        seed: 7,
        length: deck.items.length,
      );
      final qs = [
        for (final q in questions)
          if (q.item.kind == StudyItemKind.guidelineQuiz) q,
      ];
      expect(qs, isNotEmpty);
      for (final q in qs) {
        expect(q.asksForPrompt, isFalse);
        expect(q.stem.resolve('uz'), q.item.prompt.resolve('uz'));
        expect(q.options, hasLength(4));
        expect(
          q.optionText(q.correctIndex).resolve('uz'),
          q.item.answer.resolve('uz'),
        );
        final wrong = {
          for (var i = 0; i < 4; i++)
            if (i != q.correctIndex) q.optionText(i).resolve('en'),
        };
        expect(wrong, {for (final c in q.item.choices) c.resolve('en')});
      }
      // Bir xil seed — bir xil test.
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
