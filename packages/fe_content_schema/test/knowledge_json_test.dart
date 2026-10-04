import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

// TEST DATA — sintetik qiymatlar; ilmiy ma’lumot emas.
void main() {
  const recipe = SolutionRecipe(
    id: 'test-recipe',
    reagentId: 'test-reagent',
    names: {'en': 'TEST reagent'},
    domain: ContentDomain.lab,
    status: ScientificStatus.needsReview,
    ingredients: [Ingredient(name: 'TEST A', amount: 1, unit: 'mL')],
    steps: [PreparationStep(text: 'TEST step', order: 1)],
    orderExplicitInSource: true,
    temperature: SourcedValue(value: 4, unit: '°C', sourceId: 'src-test'),
    hazards: [SourcedNote(text: 'TEST hazard', sourceId: 'src-test')],
    sourceIds: ['src-test'],
    isTestData: true,
  );

  test('SolutionRecipe JSON aylanmasi o‘zgarishsiz', () {
    final j = KnowledgeJson.recipe(recipe);
    final back = KnowledgeJson.recipeFrom(jsonDecode(jsonEncode(j)));
    expect(KnowledgeJson.recipe(back), j);
    expect(back.hasPreparationData, isTrue);
    expect(back.steps.single.order, 1);
  });

  test('MethodRecord, ScreeningTest, EmergingIssue, Topic aylanmasi', () {
    final m = MethodRecord(
      id: 'm',
      kind: MethodKind.nationalMethod,
      titles: const {'en': 'TEST'},
      techniques: const [AnalyticalTechnique.gcMs],
      organization: 'TEST org',
      jurisdictionId: 'XX',
      effectiveFrom: DateTime.utc(2020),
      sections: const {MethodSection.principle: 'TEST'},
      status: ScientificStatus.draft,
      sourceIds: const ['s'],
    );
    expect(
      KnowledgeJson.method(KnowledgeJson.methodFrom(KnowledgeJson.method(m))),
      KnowledgeJson.method(m),
    );
    const t = ScreeningTest(
      id: 't',
      names: {'en': 'TEST'},
      analyte: 'a',
      specimen: 'urine',
      principle: 'immunoassay',
      confirmatoryMethodIds: ['m'],
      limitations: [SourcedNote(text: 'x', sourceId: 's')],
      status: ScientificStatus.needsReview,
      sourceIds: ['s'],
    );
    expect(
      KnowledgeJson.screening(
        KnowledgeJson.screeningFrom(KnowledgeJson.screening(t)),
      ),
      KnowledgeJson.screening(t),
    );
    final e = EmergingIssue(
      id: 'e',
      category: EmergingCategory.syntheticOpioids,
      titles: const {'en': 'TEST'},
      sourceIds: const ['s'],
      date: DateTime.utc(2025),
      evidenceType: EvidenceType.peerReviewed,
      status: ScientificStatus.needsReview,
    );
    expect(
      KnowledgeJson.emerging(
        KnowledgeJson.emergingFrom(KnowledgeJson.emerging(e)),
      ),
      KnowledgeJson.emerging(e),
    );
    const topic = KnowledgeTopic(
      id: 'k',
      area: KnowledgeArea.forensicMedicine,
      names: {'en': 'TEST'},
      forensicMedicineTopic: ForensicMedicineTopic.livorMortis,
    );
    expect(
      KnowledgeJson.topicFrom(KnowledgeJson.topic(topic)).forensicMedicineTopic,
      ForensicMedicineTopic.livorMortis,
    );
  });

  test('noma’lum enum yoki yetishmayotgan maydon — FormatException', () {
    final j = KnowledgeJson.recipe(recipe)..['domain'] = 'nope';
    expect(() => KnowledgeJson.recipeFrom(j), throwsFormatException);
    final k = KnowledgeJson.recipe(recipe)..remove('reagent_id');
    expect(() => KnowledgeJson.recipeFrom(k), throwsFormatException);
    final v = KnowledgeJson.recipe(recipe)
      ..['temperature'] = {'value': 4, 'unit': '°C'};
    expect(() => KnowledgeJson.recipeFrom(v), throwsFormatException);
  });

  group('ReviewRegressionGuard (FE027)', () {
    Claim claim(ScientificStatus s, {Object? v = 1, int version = 1}) => Claim(
      claimId: 'c1',
      entityType: EntityType.substance,
      entityId: 'x',
      field: 'f',
      value: {'v': v},
      domain: ContentDomain.tox,
      declaredStatus: s,
      evidenceLevel: EvidenceLevel.b,
      version: version,
    );
    ContentBundle b(List<Claim> c) =>
        ContentBundle(channel: BundleChannel.development, claims: c);

    test('reviewed → needs_review jimgina — xato', () {
      final r = ReviewRegressionGuard.compare(
        b([claim(ScientificStatus.reviewed)]),
        b([claim(ScientificStatus.needsReview)]),
      );
      expect(r.hasCode(RuleCodes.silentReviewRegression), isTrue);
    });

    test('reviewed yozuv yo‘qolsa — xato', () {
      expect(
        ReviewRegressionGuard.compare(
          b([claim(ScientificStatus.verified)]),
          b(const []),
        ).isValid,
        isFalse,
      );
    });

    test('versiya oshirilmay mazmun o‘zgarsa — xato', () {
      expect(
        ReviewRegressionGuard.compare(
          b([claim(ScientificStatus.reviewed)]),
          b([claim(ScientificStatus.reviewed, v: 2)]),
        ).isValid,
        isFalse,
      );
    });

    test('aniq OUTDATED yoki o‘zgarishsiz — ruxsat', () {
      expect(
        ReviewRegressionGuard.compare(
          b([claim(ScientificStatus.reviewed)]),
          b([claim(ScientificStatus.outdated)]),
        ).isValid,
        isTrue,
      );
      expect(
        ReviewRegressionGuard.compare(
          b([claim(ScientificStatus.reviewed)]),
          b([claim(ScientificStatus.reviewed)]),
        ).isValid,
        isTrue,
      );
    });

    test('needs_review yozuvlar erkin o‘zgaradi', () {
      expect(
        ReviewRegressionGuard.compare(
          b([claim(ScientificStatus.needsReview)]),
          b(const []),
        ).isValid,
        isTrue,
      );
    });
  });
}
