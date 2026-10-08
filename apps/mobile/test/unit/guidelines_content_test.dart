import 'dart:convert';
import 'dart:io';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
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

  test('ichki maydonlar ilova paketida yo‘q; yopiq manbaga havola yo‘q', () {
    expect(raw.contains('omitted_unverified'), isFalse);
    expect(raw.contains('ABY'), isFalse);
  });
}
