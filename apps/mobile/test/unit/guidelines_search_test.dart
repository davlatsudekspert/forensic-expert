import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/search_service.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';

/// Yo‘riqnomalar global qidiruvda uch tilda topiladi.
void main() {
  final bundle = GuidelineBundle.fromJson(
    (jsonDecode(
      File('assets/content/guidelines/guidelines_v1.json').readAsStringSync(),
    ) as Map).cast<String, Object?>(),
  );
  final service = AppSearchService.build(
    library: const FixtureLibraryRepository(),
    learn: const FixtureLearnRepository(),
    guidelines: bundle,
  );

  for (final (q, lang) in [
    ('diatom', 'en'),
    ('диатом', 'ru'),
    ('diatom testi', 'uz'),
  ]) {
    test('«$q» → yo‘riqnoma', () async {
      final r = await service.search(q, lang: lang);
      expect(
        r.groups[SearchGroup.guidelines]!.map((h) => h.entityId),
        contains('guideline.path.diatom_test'),
      );
    });
  }
}
