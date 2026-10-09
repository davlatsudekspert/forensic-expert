import 'dart:convert';
import 'dart:io';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/glossary/glossary.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/features/glossary/presentation/glossary_linked_text.dart';

/// Phase F: kanonik terminologiya (content/terminology/canonical_terms.json).
/// UI matnlari (ARB uz/ru) va o‘quv savollarida taqiqlangan shakllar yo‘q;
/// lug‘at barcha kanonik qisqartmalarni qisqa izoh bilan qamraydi.
void main() {
  final canon = jsonDecode(
    File('../../content/terminology/canonical_terms.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final terms = (canon['terms']! as List).cast<Map<String, Object?>>();

  List<String> forbidden(String lang) => [
    for (final t in terms)
      for (final v in ((t['forbidden'] as Map?)?[lang] as List? ?? const []))
        '$v',
  ];

  // Qisqartma alohida turganda (GC-MS/MS ichidagi GC-MS emas va h.k.).
  RegExp word(String v) => RegExp(
    '(?<![\\w\\u0400-\\u04FF-])${RegExp.escape(v)}'
    '(?![\\w\\u0400-\\u04FF-])',
  );

  test('kanonik ro‘yxat: 9 ta qisqartma, uz/ru/en kengaytma', () {
    expect(
      [for (final t in terms) t['abbreviation']],
      ['PMI', 'PMR', 'GC-MS', 'LC-MS/MS', 'HPLC', 'TLC', 'Rf', 'Vd', 'COHb'],
    );
    for (final t in terms) {
      for (final lang in const ['uz', 'ru', 'en']) {
        expect((t['expansion']! as Map)[lang], isNotEmpty, reason: '$t');
      }
    }
    expect(forbidden('uz'), containsAll(['GX-MS', 'SX-MS', 'YuSSX']));
  });

  for (final lang in const ['uz', 'ru']) {
    test('ARB ($lang): taqiqlangan terminologik shakllar yo‘q', () {
      final arb = jsonDecode(
        File('lib/core/l10n/arb/app_$lang.arb').readAsStringSync(),
      ) as Map<String, Object?>;
      final hits = <String>[];
      for (final e in arb.entries) {
        if (e.key.startsWith('@') || e.value is! String) continue;
        for (final bad in forbidden(lang)) {
          if (word(bad).hasMatch(e.value! as String)) {
            hits.add('${e.key}: $bad');
          }
        }
      }
      expect(hits, isEmpty);
    });
  }

  test('o‘quv savollari (quiz) — taqiqlangan shakllar yo‘q', () {
    final bundle = File('assets/content/guidelines/guidelines_v1.json')
        .readAsStringSync();
    final data = jsonDecode(bundle) as Map<String, Object?>;
    final hits = <String>[];
    for (final card in (data['cards']! as List).cast<Map<String, Object?>>()) {
      for (final q in (card['quiz'] as List? ?? const [])) {
        final blob = jsonEncode(q);
        for (final lang in const ['uz', 'ru']) {
          for (final bad in forbidden(lang)) {
            if (word(bad).hasMatch(blob)) hits.add('${(q as Map)['id']}: $bad');
          }
        }
      }
    }
    expect(hits, isEmpty);
  });

  group('Qisqartmalar lug‘ati', () {
    final notes = AbbreviationNote.listFromJson(
      jsonDecode(
        File('assets/content/terminology/abbreviation_glossary.json')
            .readAsStringSync(),
      ),
    );
    final glossary = Glossary.build(
      const <TermTranslation>[],
      GuidelineBundle.empty,
      abbreviations: notes,
    );

    test('9 ta qisqartma, uch tilda qisqa izoh, machine_draft', () {
      expect(glossary.abbreviations.toSet(), {
        for (final t in terms) '${t['abbreviation']}',
      });
      for (final abbr in glossary.abbreviations) {
        final term = glossary.byAbbreviation(abbr)!;
        expect(term.kind, ScientificTermKind.abbreviation);
        expect(term.hasMachineDraft, isTrue, reason: abbr);
        expect(term.isReviewed, isFalse, reason: abbr);
        for (final lang in const ['uz', 'ru', 'en']) {
          expect(term.explanationIn(lang), isNotEmpty, reason: '$abbr/$lang');
          expect(term.textIn(lang), startsWith('$abbr — '));
        }
      }
      expect(
        glossary.byAbbreviation('PMI')!.textIn('uz'),
        'PMI — o‘limdan keyin o‘tgan vaqt oralig‘i',
      );
      expect(
        glossary.byAbbreviation('LC-MS/MS')!.textIn('uz'),
        'LC-MS/MS — suyuqlik xromatografiyasi — tandem mass-spektrometriya',
      );
    });

    test('matnda havola: faqat alohida turgan qisqartma', () {
      expect(
        GlossaryLinkedText.abbreviationsIn(
          'GC-MS/MS va GC-MS, LC-MS/MS; TLC (Rf), COHb% · HS-GC-FID · PMIx',
          glossary,
        ),
        ['GC-MS', 'LC-MS/MS', 'TLC', 'Rf', 'COHb'],
      );
      expect(
        GlossaryLinkedText.abbreviationsIn('PMR va PMI, Vd 2 L/kg', glossary),
        ['PMR', 'PMI', 'Vd'],
      );
    });
  });
}
