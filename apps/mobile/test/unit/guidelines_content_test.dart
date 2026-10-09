import 'dart:convert';
import 'dart:io';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/catalog/tools_catalog.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/features/guidelines/presentation/guidelines_screens.dart';

/// Ilovaga qo‘shilgan haqiqiy yo‘riqnoma paketi: tuzilma, til to‘liqligi,
/// iqtiboslar va ichki maydonlar sizib chiqmasligi.
void main() {
  final raw = File('assets/content/guidelines/guidelines_v1.json')
      .readAsStringSync();
  final json = (jsonDecode(raw) as Map).cast<String, Object?>();
  final bundle = GuidelineBundle.fromJson(json);

  test('kartalar: NEEDS_REVIEW, uch til, manbalar tekshirilgan', () {
    expect(bundle.cards, isNotEmpty);
    for (final c in bundle.cards) {
      expect(c.status, ScientificStatus.needsReview, reason: c.id);
      for (final lang in ['uz', 'ru', 'en']) {
        expect(c.title.pick(lang).isFallback, isFalse, reason: c.id);
        for (final s in c.sections) {
          expect(s.body.pick(lang).isFallback, isFalse, reason: s.key);
        }
      }
      final refs = bundle.referencesOf(c);
      expect(refs, isNotEmpty, reason: c.id);
      expect(refs.every((r) => r.verifiedVia != null), isTrue);
    }
  });

  test('matndagi barcha [kalit] iqtiboslar raqamga aylanadi', () {
    for (final c in bundle.cards) {
      final refs = bundle.referencesOf(c);
      final index = {for (var i = 0; i < refs.length; i++) refs[i].key: i + 1};
      for (final s in c.sections) {
        for (final lang in ['uz', 'ru', 'en']) {
          final out = numberCitations(s.body.of(lang), s.citations, index);
          expect(
            RegExp(r'\[[a-z][a-z0-9_]*[0-9]{4}[a-z]?').hasMatch(out),
            isFalse,
            reason: '${c.id}/${s.key}/$lang',
          );
        }
      }
    }
  });

  test('UB-ko‘rinadigan spektrofotometriya kartasi: manbalar va vositalar', () {
    final card = bundle.cards.singleWhere(
      (c) => c.id == 'guideline.chem.uvvis_drug_analysis',
    );
    expect(card.disciplineCodes, contains('forensic_chemistry'));
    expect(card.sections.map((s) => s.key), [
      'basis',
      'scope',
      'methods',
      'advantages',
      'limitations',
      'factors',
      'cautions',
      'alternatives',
    ]);
    // Bog‘langan vositalar katalogda mavjud (Ber–Lambert, kalibrlash, LOD/LOQ).
    expect(card.relatedToolIds, [
      'tool.lab.beer_lambert',
      'tool.lab.calibration',
      'tool.lab.lod_loq',
    ]);
    for (final id in card.relatedToolIds) {
      expect(ToolsCatalog.byId(id)?.isAvailable, isTrue, reason: id);
    }
    final keys = bundle.referencesOf(card).map((r) => r.key).toSet();
    // Tekshirilgan asosiy manbalar: Ber–Lambert (IUPAC), ICH Q2(R2), SWGDRUG,
    // HPLC-DAD kutubxonasi selektivligi.
    expect(
      keys,
      containsAll([
        'iupac_beer_lambert',
        'ich_q2r2_2023',
        'swgdrug2024',
        'herzler2003',
      ]),
    );
    final herzler = bundle.references['herzler2003']!;
    expect(herzler.doi, '10.1093/jat/27.4.233');
    expect(herzler.pmid, '12820746');
    expect(
      bundle.references['iupac_beer_lambert']!.doi,
      '10.1351/goldbook.B00626',
    );
    // Past o‘ziga xoslik va tasdiqlash talabi uch tilda ham aytilgan.
    final cautions = card.sections.singleWhere((s) => s.key == 'cautions');
    expect(cautions.body.of('en'), contains('UV spectrum alone'));
    expect(cautions.body.of('uz'), contains('faqat UB spektri'));
  });

  test('ichki maydonlar ilova paketida yo‘q; yopiq manbaga havola yo‘q', () {
    expect(raw.contains('omitted_unverified'), isFalse);
    expect(raw.contains('ABY'), isFalse);
  });
}
