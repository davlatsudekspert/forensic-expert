import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

const _std = Source(
  sourceId: 'STD',
  sourceType: SourceType.standard,
  title: 's',
  tier: SourceTier.tier1,
  evidenceLevel: EvidenceLevel.a,
  licenseMode: SourceLicenseMode.citeOnly,
);
const _paper = Source(
  sourceId: 'P',
  sourceType: SourceType.journalArticle,
  title: 'p',
  tier: SourceTier.tier2,
  evidenceLevel: EvidenceLevel.b,
  licenseMode: SourceLicenseMode.openReuse,
);

MethodRecord _m(MethodEvidenceType? ev, List<String> src) => MethodRecord(
  id: 'M',
  kind: MethodKind.scientificMethod,
  titles: const {'en': 'm'},
  status: ScientificStatus.needsReview,
  sourceIds: src,
  evidenceType: ev,
);

Set<String> _codes(ContentBundle b) => {
  for (final i in const ContentValidator().validate(b).issues) i.code,
};

void main() {
  test('metod dalil turi: standart deb belgilash rasmiy manbasiz — FE042', () {
    ContentBundle b(MethodRecord m) => ContentBundle(
      channel: BundleChannel.development,
      sources: const [_std, _paper],
      methods: [m],
    );
    expect(
      _m(null, const []).effectiveEvidenceType,
      MethodEvidenceType.educationalSummary,
    );
    expect(
      _codes(b(_m(MethodEvidenceType.internationalStandard, const ['P']))),
      contains(RuleCodes.methodEvidenceType),
    );
    expect(
      _codes(b(_m(MethodEvidenceType.publishedValidatedMethod, const []))),
      contains(RuleCodes.methodEvidenceType),
    );
    expect(
      _codes(b(_m(MethodEvidenceType.internationalStandard, const ['STD']))),
      isNot(contains(RuleCodes.methodEvidenceType)),
    );
  });

  test('reagent: yangi maydonlar JSON orqali saqlanadi; manbasiz — FE018', () {
    const r = SolutionRecipe(
      id: 'R',
      reagentId: 'reagent-x',
      names: {'en': 'x'},
      domain: ContentDomain.lab,
      status: ScientificStatus.needsReview,
      ph: SourcedValue(value: 7.4, unit: 'pH', sourceId: 'P'),
      solvent: SourcedNote(text: 'water', sourceId: 'P'),
      ppe: [SourcedNote(text: 'gloves', sourceId: 'P')],
      ingredients: [Ingredient(name: 'a', amount: 1, unit: 'g', grade: 'AR')],
      calculatorIds: ['tool.lab.molarity'],
    );
    final back = KnowledgeJson.recipeFrom(KnowledgeJson.recipe(r));
    expect(back.ph!.value, 7.4);
    expect(back.solvent!.text, 'water');
    expect(back.ppe.single.text, 'gloves');
    expect(back.ingredients.single.grade, 'AR');
    expect(back.calculatorIds, ['tool.lab.molarity']);
    expect(
      _codes(
        const ContentBundle(
          channel: BundleChannel.development,
          sources: [_paper],
          recipes: [r],
        ),
      ),
      contains(RuleCodes.recipeWithoutSource),
    );
  });

  test(
    'ekspress test: interferensiya va aniqlash oynasi manbaga bog‘langan',
    () {
      const t = ScreeningTest(
        id: 'S',
        names: {'en': 's'},
        analyte: 'a',
        specimen: 'urine',
        principle: 'immunoassay',
        confirmatoryMethodIds: ['method-gcms'],
        limitations: [SourcedNote(text: 'l', sourceId: 'P')],
        status: ScientificStatus.needsReview,
        sourceIds: ['P'],
        interferences: [SourcedNote(text: 'i', sourceId: 'UNKNOWN')],
        detectionWindow: SourcedNote(text: 'context', sourceId: 'P'),
      );
      final back = KnowledgeJson.screeningFrom(KnowledgeJson.screening(t));
      expect(back.detectionWindow!.text, 'context');
      expect(
        _codes(
          const ContentBundle(
            channel: BundleChannel.development,
            sources: [_paper],
            screeningTests: [t],
          ),
        ),
        contains(RuleCodes.unsourcedValue),
      );
    },
  );

  test('mavzu fani JSON orqali', () {
    const t = KnowledgeTopic(
      id: 'gen-x',
      area: KnowledgeArea.laboratory,
      names: {'en': 'x'},
      discipline: ForensicDiscipline.forensicGenetics,
    );
    expect(
      KnowledgeJson.topicFrom(KnowledgeJson.topic(t)).discipline,
      ForensicDiscipline.forensicGenetics,
    );
  });
}
