// TEST DATA — barcha yozuvlar sun’iy (TEST-). Ilmiy fakt emas.
import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

import 'fixtures/test_data.dart';

/// Retsept kengaytmalari (2026-10-09): variantlar, raqamsiz miqdor,
/// asl matn (egasi ruxsati) va machine_draft tarjimalar.
const _owner = Source(
  sourceId: 'TEST-SRC-OWNER',
  sourceType: SourceType.report,
  title: 'TEST DATA — owner compilation',
  tier: SourceTier.tier3,
  evidenceLevel: EvidenceLevel.c,
  licenseMode: SourceLicenseMode.licenseRequired,
  licenseAgreementId: 'TEST-OWNER-PERMISSION',
  isTestData: true,
);
const _citeOnly = Source(
  sourceId: 'TEST-SRC-CITE',
  sourceType: SourceType.book,
  title: 'TEST DATA — cite-only textbook',
  tier: SourceTier.tier2,
  evidenceLevel: EvidenceLevel.c,
  licenseMode: SourceLicenseMode.citeOnly,
  isTestData: true,
);

void main() {
  const validator = ContentValidator();

  ContentBundle bundle(SolutionRecipe r) => ContentBundle(
    channel: BundleChannel.test,
    sources: const [testSourceOpen, _owner, _citeOnly],
    claims: const [],
    citations: const [],
    reviewers: const [],
    reviews: const [],
    recipes: [r],
  );

  SolutionRecipe recipe({
    List<Ingredient> ingredients = const [
      Ingredient(
        name: 'TEST-A',
        amount: 8,
        unit: 'g',
        names: {'uz': 'TEST-A uz', 'ru': 'TEST-A ru', 'en': 'TEST-A'},
      ),
      Ingredient(
        name: 'TEST water',
        amount: 100,
        unit: 'mL',
        makeUpTo: true,
        names: {'uz': 'suv', 'ru': 'вода', 'en': 'water'},
      ),
      Ingredient(
        name: 'TEST starch',
        amount: null,
        unit: null,
        quantityNote: {'uz': 'oz miqdor', 'ru': 'немного', 'en': 'a little'},
      ),
    ],
    List<PreparationStep> steps = const [
      PreparationStep(
        text: 'TEST step',
        order: 1,
        texts: {'uz': 'TEST qadam', 'ru': 'TEST шаг', 'en': 'TEST step'},
      ),
    ],
    List<RecipeVariant> variants = const [],
    String? original = 'TEST оригинал',
    String originalSource = 'TEST-SRC-OWNER',
    List<String> sources = const ['TEST-SRC-OWNER', 'TEST-SRC-CITE'],
    String? translationStatus = 'machine_draft',
  }) => SolutionRecipe(
    id: 'TEST-RECIPE-X',
    reagentId: 'TEST-REAGENT-X',
    names: const {'en': 'TEST reagent'},
    domain: ContentDomain.lab,
    status: ScientificStatus.needsReview,
    ingredients: ingredients,
    steps: steps,
    orderExplicitInSource: true,
    variants: variants,
    sourceIds: sources,
    originalText: original,
    originalLanguage: 'ru',
    originalSourceId: originalSource,
    translationStatus: translationStatus,
    synonyms: const ['TEST-syn'],
    hazards: const [
      SourcedNote(
        text: 'TEST hazard',
        sourceId: 'TEST-SRC-OPEN',
        kind: 'ghs',
        texts: {'uz': 'TEST xavf', 'ru': 'TEST опасность', 'en': 'TEST hazard'},
      ),
    ],
    isTestData: true,
  );

  test('to‘liq kengaytirilgan retsept — xatosiz', () {
    final r = validator.validate(bundle(recipe()));
    expect(r.issues, isEmpty, reason: r.issues.join('\n'));
  });

  test('FE022: raqam ham, izoh ham yo‘q ingrediyent rad etiladi', () {
    final r = validator.validate(
      bundle(
        recipe(
          ingredients: const [Ingredient(name: 'X', amount: null, unit: null)],
        ),
      ),
    );
    expect(r.hasCode(RuleCodes.unsourcedValue), isTrue);
  });

  test('FE022: birliksiz miqdor va noto‘g‘ri oraliq rad etiladi', () {
    expect(
      validator
          .validate(
            bundle(
              recipe(
                ingredients: const [
                  Ingredient(name: 'X', amount: 1, unit: null),
                ],
              ),
            ),
          )
          .hasCode(RuleCodes.unsourcedValue),
      isTrue,
    );
    expect(
      validator
          .validate(
            bundle(
              recipe(
                ingredients: const [
                  Ingredient(name: 'X', amount: 15, unit: 'mL', amountMax: 10),
                ],
              ),
            ),
          )
          .hasCode(RuleCodes.unsourcedValue),
      isTrue,
    );
  });

  test('FE025: asl matn faqat ruxsatli manbadan (ochiq yoki shartnoma)', () {
    final bad = validator.validate(
      bundle(recipe(originalSource: 'TEST-SRC-CITE')),
    );
    expect(bad.hasCode(RuleCodes.textLicense), isTrue);
    // Egasi ruxsati (license_agreement_id) — ruxsat beradi.
    expect(validator.validate(bundle(recipe())).isValid, isTrue);
  });

  test('asl matn manbasi retsept manbalari ichida bo‘lishi shart', () {
    final r = validator.validate(
      bundle(recipe(sources: const ['TEST-SRC-CITE'])),
    );
    expect(r.hasCode(RuleCodes.unsourcedValue), isTrue);
  });

  test('FE043: tarjima qilingan matn machine_draft deb belgilanishi shart', () {
    final r = validator.validate(bundle(recipe(translationStatus: null)));
    expect(r.hasCode(RuleCodes.textTranslationInvalid), isTrue);
    final r2 = validator.validate(
      bundle(recipe(translationStatus: 'reviewed')),
    );
    expect(r2.hasCode(RuleCodes.textTranslationInvalid), isTrue);
  });

  test('variantlar: noma’lum variant va begona manba rad etiladi', () {
    final unknown = validator.validate(
      bundle(
        recipe(
          steps: const [PreparationStep(text: 'T', order: 1, variant: 'z')],
          variants: const [RecipeVariant(id: 'a', sourceId: 'TEST-SRC-OWNER')],
        ),
      ),
    );
    expect(unknown.hasCode(RuleCodes.unsourcedValue), isTrue);
    final foreign = validator.validate(
      bundle(
        recipe(
          variants: const [RecipeVariant(id: 'a', sourceId: 'TEST-SRC-OPEN')],
        ),
      ),
    );
    expect(foreign.hasCode(RuleCodes.unsourcedValue), isTrue);
  });

  test('JSON: yangi maydonlar yo‘qolmasdan qaytadi', () {
    final r = recipe(
      variants: const [
        RecipeVariant(
          id: 'a',
          labels: {'uz': 'a) usul', 'en': 'a) method'},
          sourceId: 'TEST-SRC-OWNER',
        ),
      ],
      ingredients: const [
        Ingredient(
          name: 'TEST water',
          amount: 10,
          amountMax: 15,
          unit: 'mL',
          makeUpTo: true,
          variant: 'a',
          names: {'uz': 'suv'},
          quantityNote: {'en': 'note'},
        ),
      ],
      steps: const [
        PreparationStep(
          text: 'T',
          order: 1,
          variant: 'a',
          texts: {'uz': 'qadam'},
        ),
      ],
    );
    final back = KnowledgeJson.recipeFrom(KnowledgeJson.recipe(r));
    expect(back.originalText, 'TEST оригинал');
    expect(back.originalLanguage, 'ru');
    expect(back.originalSourceId, 'TEST-SRC-OWNER');
    expect(back.translationStatus, 'machine_draft');
    expect(back.synonyms, ['TEST-syn']);
    expect(back.variants.single.labels['uz'], 'a) usul');
    expect(back.variants.single.sourceId, 'TEST-SRC-OWNER');
    final i = back.ingredients.single;
    expect(
      [i.amount, i.amountMax, i.unit, i.makeUpTo, i.variant],
      [10, 15, 'mL', true, 'a'],
    );
    expect(i.displayName('uz'), 'suv');
    expect(i.displayName('ru'), 'TEST water');
    expect(i.quantityNote['en'], 'note');
    expect(back.steps.single.resolve('uz'), 'qadam');
    expect(back.steps.single.variant, 'a');
    expect(back.hazards.single.kind, 'ghs');
    expect(back.hazards.single.resolve('ru'), 'TEST опасность');
    // Raqamsiz miqdor JSON’da null bo‘lib qoladi (taxmin yo‘q).
    final none = KnowledgeJson.recipeFrom(KnowledgeJson.recipe(recipe()))
        .ingredients
        .last;
    expect(none.amount, isNull);
    expect(none.quantityNote['uz'], 'oz miqdor');
  });
}
