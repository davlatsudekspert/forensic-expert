import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/evidence/citation_format.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';

void main() {
  test('Yuldashev majmuasi iqtibosida nashr joyi va nashriyot bor', () {
    final raw = jsonDecode(
      File('assets/content/guidelines/guidelines_v1.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final refs = [
      for (final r in raw['references']! as List<Object?>)
        GuidelineReference.fromJson(r! as Map<String, Object?>),
    ];
    final toks = refs.firstWhere((r) => r.key == 'toks_majmua2025');
    expect(toks.isYuldashevMaterial, isTrue);
    expect(toks.place, 'Toshkent');
    final data = CitationData.fromGuidelineReference(toks);
    expect(data.place, 'Toshkent');
    expect(data.publisher, isNotNull);
  });
}
