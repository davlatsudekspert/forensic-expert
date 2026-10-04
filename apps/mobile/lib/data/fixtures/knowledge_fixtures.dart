// ============================================================================
// TEST DATA — PHASE 4 bilim sohalari UI’si uchun fixture’lar.
//
// * Hech biri ilmiy fakt EMAS. Ingredient nomlari, miqdorlar, harorat va
//   tartib — sintetik placeholder («TEST component A», 10 mL …) bo‘lib,
//   faqat UI to‘liq retsept holatini qanday ko‘rsatishini sinash uchun.
// * Barcha ID’lar `TEST-` bilan boshlanadi, `isTestData: true`.
// * Faqat `FE_TEST_FIXTURES=true` (testlar, preview) — RELEASE GATE RG-12.
// ============================================================================

import 'package:fe_content_schema/fe_content_schema.dart';

import '../../domain/knowledge/knowledge_models.dart';
import '../../domain/library/library_models.dart';

LocalizedText _t(String en, String ru, String uz) =>
    LocalizedText({'en': en, 'ru': ru, 'uz': uz});

const _src = 'TEST-SRC-1';

const _testSource = SourceView(
  sourceId: _src,
  title: 'TEST SOURCE — not a real publication',
  sourceType: 'report',
  evidenceLevel: 'E',
  licenseMode: 'citeOnly',
  identifierVerified: false,
);

const _testRecipe = SolutionRecipe(
  id: 'TEST-RECIPE-1',
  reagentId: 'TEST-REAGENT-1',
  names: {'en': 'TEST reagent'},
  domain: ContentDomain.lab,
  status: ScientificStatus.needsReview,
  ingredients: [
    Ingredient(name: 'TEST component A', amount: 10, unit: 'mL'),
    Ingredient(name: 'TEST component B', amount: 1, unit: 'g'),
  ],
  finalVolume: SourcedValue(value: 100, unit: 'mL', sourceId: _src),
  steps: [
    PreparationStep(text: 'TEST step one', order: 1),
    PreparationStep(text: 'TEST step two', order: 2),
  ],
  orderExplicitInSource: true,
  storage: SourcedNote(text: 'TEST storage note', sourceId: _src),
  temperature: SourcedValue(value: 20, unit: '°C', sourceId: _src),
  hazards: [SourcedNote(text: 'TEST hazard note', sourceId: _src)],
  sourceIds: [_src],
  isTestData: true,
);

final testKnowledgeEntries = <KnowledgeEntry>[
  KnowledgeEntry(
    id: 'TEST-REAGENT-1',
    kind: KnowledgeKind.reagent,
    area: KnowledgeArea.reagents,
    name: _t('TEST reagent', 'ТЕСТ реактив', 'TEST reagent'),
    status: ScientificStatus.needsReview,
    access: EntryAccess.free,
    isTestData: true,
    claims: const [],
    sources: const [_testSource],
    recipe: _testRecipe,
  ),
  KnowledgeEntry(
    id: 'TEST-SCREEN-1',
    kind: KnowledgeKind.screeningTest,
    area: KnowledgeArea.screening,
    name: _t('TEST screening test', 'ТЕСТ скрининг', 'TEST skrining'),
    status: ScientificStatus.needsReview,
    access: EntryAccess.free,
    isTestData: true,
    claims: const [],
    sources: const [_testSource],
    screening: const ScreeningTest(
      id: 'TEST-SCREEN-1',
      names: {'en': 'TEST screening test'},
      analyte: 'TEST analyte',
      specimen: 'TEST specimen',
      principle: 'TEST principle',
      confirmatoryMethodIds: ['TEST-METHOD-SCI'],
      limitations: [SourcedNote(text: 'TEST limitation', sourceId: _src)],
      status: ScientificStatus.needsReview,
      sourceIds: [_src],
      isTestData: true,
    ),
  ),
  for (final (kind, org, jur) in const [
    (MethodKind.scientificMethod, null, null),
    (MethodKind.internationalStandard, 'TEST organization', null),
    (MethodKind.nationalMethod, 'TEST national body', 'UZ'),
    (MethodKind.institutionalSop, 'TEST institute', null),
  ])
    KnowledgeEntry(
      id: 'TEST-METHOD-${kind.name}',
      kind: KnowledgeKind.method,
      area: KnowledgeArea.methods,
      name: _t('TEST method (${kind.name})', 'ТЕСТ метод', 'TEST metod'),
      status: ScientificStatus.needsReview,
      access: EntryAccess.free,
      isTestData: true,
      claims: const [],
      sources: const [_testSource],
      method: MethodRecord(
        id: 'TEST-METHOD-${kind.name}',
        kind: kind,
        titles: const {'en': 'TEST method'},
        organization: org,
        jurisdictionId: jur,
        status: ScientificStatus.needsReview,
        sourceIds: const [_src],
        isTestData: true,
      ),
    ),
  KnowledgeEntry(
    id: 'TEST-TOPIC-FM',
    kind: KnowledgeKind.topic,
    area: KnowledgeArea.forensicMedicine,
    name: _t('TEST topic', 'ТЕСТ тема', 'TEST mavzu'),
    status: ScientificStatus.needsReview,
    access: EntryAccess.free,
    isTestData: true,
    claims: const [],
    sources: const [_testSource],
    forensicMedicineTopic: ForensicMedicineTopic.livorMortis,
  ),
];

class FixtureKnowledgeRepository extends ListKnowledgeRepository {
  FixtureKnowledgeRepository() : super(testKnowledgeEntries);
}
