// ============================================================================
// TEST DATA — terminologiya fixture’i (faqat qidiruv testlari uchun).
//
// Bu yerda faqat NOMLAR bor (EN/RU/UZ yozilishi) — hech qanday ilmiy qiymat,
// konsentratsiya yoki da’vo yo‘q. Tarjimalar reviewer tomonidan
// tasdiqlanmagan; ular faqat normalizatsiya va moslash algoritmini sinash
// uchun ishlatiladi. Production terminologiyasi content pipeline orqali,
// `i18n:*` review bilan keladi.
// ============================================================================

import 'package:fe_search_core/fe_search_core.dart';

const _s = SearchCategory.substance;

SearchTerm _t(
  String id,
  String term,
  TermKind kind, [
  String? lang,
  SearchCategory category = _s,
]) => SearchTerm(
  entityId: id,
  category: category,
  term: term,
  kind: kind,
  lang: lang,
);

final terminologyTestData = <SearchTerm>[
  // TEST-SUB-METH
  _t('TEST-SUB-METH', 'methamphetamine', TermKind.canonical),
  _t('TEST-SUB-METH', 'Methamphetamine', TermKind.localized, 'en'),
  _t('TEST-SUB-METH', 'Метамфетамин', TermKind.localized, 'ru'),
  _t('TEST-SUB-METH', 'Metamfetamin', TermKind.localized, 'uz'),
  _t('TEST-SUB-METH', 'N-methylamphetamine', TermKind.synonym, 'en'),
  // TEST-SUB-AMPH (prefix-raqib: "amfetamin" metamfetaminni bosib ketmasligi kerak)
  _t('TEST-SUB-AMPH', 'amphetamine', TermKind.canonical),
  _t('TEST-SUB-AMPH', 'Амфетамин', TermKind.localized, 'ru'),
  _t('TEST-SUB-AMPH', 'Amfetamin', TermKind.localized, 'uz'),
  // TEST-SUB-MORPH
  _t('TEST-SUB-MORPH', 'morphine', TermKind.canonical),
  _t('TEST-SUB-MORPH', 'Морфин', TermKind.localized, 'ru'),
  _t('TEST-SUB-MORPH', 'Morfin', TermKind.localized, 'uz'),
  // TEST-SUB-ETOH
  _t('TEST-SUB-ETOH', 'ethanol', TermKind.canonical),
  _t('TEST-SUB-ETOH', 'Этанол', TermKind.localized, 'ru'),
  _t('TEST-SUB-ETOH', 'Etanol', TermKind.localized, 'uz'),
  _t('TEST-SUB-ETOH', 'Ethyl alcohol', TermKind.synonym, 'en'),
  _t('TEST-SUB-ETOH', 'Этиловый спирт', TermKind.synonym, 'ru'),
  _t('TEST-SUB-ETOH', 'Etil spirti', TermKind.synonym, 'uz'),
  // TEST-SUB-PARA
  _t('TEST-SUB-PARA', 'paracetamol', TermKind.canonical),
  _t('TEST-SUB-PARA', 'Acetaminophen', TermKind.synonym, 'en'),
  _t('TEST-SUB-PARA', 'Парацетамол', TermKind.localized, 'ru'),
  _t('TEST-SUB-PARA', 'Paratsetamol', TermKind.localized, 'uz'),
  // TEST-SUB-FENT
  _t('TEST-SUB-FENT', 'fentanyl', TermKind.canonical),
  _t('TEST-SUB-FENT', 'Фентанил', TermKind.localized, 'ru'),
  _t('TEST-SUB-FENT', 'Fentanil', TermKind.localized, 'uz'),
  // TEST-SUB-COC
  _t('TEST-SUB-COC', 'cocaine', TermKind.canonical),
  _t('TEST-SUB-COC', 'Кокаин', TermKind.localized, 'ru'),
  _t('TEST-SUB-COC', 'Kokain', TermKind.localized, 'uz'),
  // TEST-SUB-CO (gaz; formula termini)
  _t('TEST-SUB-CO', 'carbon monoxide', TermKind.canonical),
  _t('TEST-SUB-CO', 'Угарный газ', TermKind.localized, 'ru'),
  _t('TEST-SUB-CO', 'Is gazi', TermKind.localized, 'uz'),
  // Metod va kalkulyator — kategoriyalash testi uchun
  _t(
    'TEST-METHOD-GCMS',
    'GC-MS',
    TermKind.canonical,
    null,
    SearchCategory.method,
  ),
  _t(
    'TEST-METHOD-GCMS',
    'Gas chromatography–mass spectrometry',
    TermKind.synonym,
    'en',
    SearchCategory.method,
  ),
  _t(
    'TEST-METHOD-GCMS',
    'Газовая хромато-масс-спектрометрия',
    TermKind.synonym,
    'ru',
    SearchCategory.method,
  ),
  _t(
    'TEST-CALC-C1V1',
    'Dilution C1V1 = C2V2',
    TermKind.canonical,
    null,
    SearchCategory.calculator,
  ),
  _t(
    'TEST-CALC-C1V1',
    'Eritish',
    TermKind.localized,
    'uz',
    SearchCategory.calculator,
  ),
  _t(
    'TEST-CALC-C1V1',
    'Разведение',
    TermKind.localized,
    'ru',
    SearchCategory.calculator,
  ),
  _t(
    'TEST-METAB-THC',
    'THC-COOH',
    TermKind.canonical,
    null,
    SearchCategory.metabolite,
  ),
  // Glossary — o‘zbek apostrofi testi
  _t(
    'TEST-GLOSS-DEATH',
    'O‘lim vaqti',
    TermKind.localized,
    'uz',
    SearchCategory.glossary,
  ),
  _t(
    'TEST-GLOSS-DEATH',
    'Давность смерти',
    TermKind.localized,
    'ru',
    SearchCategory.glossary,
  ),
  _t(
    'TEST-GLOSS-DEATH',
    'Time since death',
    TermKind.localized,
    'en',
    SearchCategory.glossary,
  ),
];
