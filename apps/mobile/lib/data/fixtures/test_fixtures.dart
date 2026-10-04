// ============================================================================
// TEST DATA — PHASE 2 UI prototipi uchun fixture’lar.
//
// * Bu fayldagi hech bir yozuv ilmiy fakt emas. Faqat NOMLAR (EN/RU/UZ) va
//   aniq «placeholder» matnlar bor: konsentratsiya, formula, metabolit
//   ro‘yxati yoki manba iqtiboslari YO‘Q.
// * Barcha ID’lar `TEST-` bilan boshlanadi va `isTestData: true`.
// * UI har bir shunday yozuvni «TEST DATA» belgisi bilan ko‘rsatadi.
// * Production yig‘mada `FeFlags.showTestFixtures = false` bo‘lishi
//   RELEASE GATE (PROGRESS.md, RG-12).
// * Tarjimalar reviewer tomonidan tasdiqlanmagan.
// ============================================================================

import 'package:fe_content_schema/fe_content_schema.dart';

import '../../domain/learn/learn_models.dart';
import '../../domain/library/library_models.dart';

LocalizedText _t(String en, String ru, String uz) =>
    LocalizedText({'en': en, 'ru': ru, 'uz': uz});

LibraryEntry _e(
  String id,
  LibrarySection section,
  LocalizedText name, {
  List<String> synonyms = const [],
}) => LibraryEntry(
  id: id,
  section: section,
  name: name,
  synonyms: synonyms,
  status: ScientificStatus.needsReview,
  isTestData: true,
);

final testLibraryEntries = <LibraryEntry>[
  // Moddalar — faqat nomlar (pilot ro‘yxatidan, docs/06).
  _e(
    'TEST-SUB-ETOH',
    LibrarySection.substances,
    _t('Ethanol', 'Этанол', 'Etanol'),
    synonyms: ['Ethyl alcohol', 'Этиловый спирт', 'Etil spirti'],
  ),
  _e(
    'TEST-SUB-METH',
    LibrarySection.substances,
    _t('Methamphetamine', 'Метамфетамин', 'Metamfetamin'),
  ),
  _e(
    'TEST-SUB-MORPH',
    LibrarySection.substances,
    _t('Morphine', 'Морфин', 'Morfin'),
  ),
  _e(
    'TEST-SUB-FENT',
    LibrarySection.substances,
    _t('Fentanyl', 'Фентанил', 'Fentanil'),
  ),
  _e(
    'TEST-SUB-TRAM',
    LibrarySection.substances,
    _t('Tramadol', 'Трамадол', 'Tramadol'),
  ),
  _e(
    'TEST-SUB-COC',
    LibrarySection.substances,
    _t('Cocaine', 'Кокаин', 'Kokain'),
  ),
  _e(
    'TEST-SUB-ALPR',
    LibrarySection.substances,
    _t('Alprazolam', 'Алпразолам', 'Alprazolam'),
  ),
  _e(
    'TEST-SUB-PHENAZ',
    LibrarySection.substances,
    _t('Phenazepam', 'Феназепам', 'Fenazepam'),
  ),
  _e(
    'TEST-SUB-PARA',
    LibrarySection.substances,
    _t('Paracetamol', 'Парацетамол', 'Paratsetamol'),
    synonyms: ['Acetaminophen'],
  ),
  _e(
    'TEST-SUB-CO',
    LibrarySection.substances,
    _t('Carbon monoxide', 'Угарный газ', 'Is gazi'),
  ),
  // Analitik usullar — nomlar.
  _e(
    'TEST-METHOD-GCMS',
    LibrarySection.methods,
    _t('GC-MS', 'ГХ-МС', 'GX-MS'),
    synonyms: ['Gas chromatography–mass spectrometry'],
  ),
  _e(
    'TEST-METHOD-LCMSMS',
    LibrarySection.methods,
    _t('LC-MS/MS', 'ВЭЖХ-МС/МС', 'SX-MS/MS'),
  ),
  _e(
    'TEST-METHOD-HSGC',
    LibrarySection.methods,
    _t('Headspace GC-FID', 'Парофазная ГХ-ПИД', 'Bug‘ fazali GX-AID'),
  ),
  _e(
    'TEST-METHOD-IA',
    LibrarySection.methods,
    _t('Immunoassay', 'Иммуноанализ', 'Immunotahlil'),
  ),
  // Namunalar — nomlar.
  _e(
    'TEST-SPEC-FEMORAL',
    LibrarySection.specimens,
    _t('Femoral blood', 'Бедренная кровь', 'Son venasi qoni'),
  ),
  _e(
    'TEST-SPEC-URINE',
    LibrarySection.specimens,
    _t('Urine', 'Моча', 'Siydik'),
  ),
  _e(
    'TEST-SPEC-VITREOUS',
    LibrarySection.specimens,
    _t('Vitreous humour', 'Стекловидное тело', 'Ko‘zning shishasimon tanasi'),
  ),
  // Manbalar — HAQIQIY NASHR EMAS (to‘qilgan iqtibos yaratilmaydi).
  _e(
    'TEST-REF-A',
    LibrarySection.references,
    _t(
      'TEST REFERENCE A — placeholder, not a real publication',
      'ТЕСТОВЫЙ ИСТОЧНИК A — заглушка, не реальная публикация',
      'TEST MANBA A — namuna, haqiqiy nashr emas',
    ),
  ),
  _e(
    'TEST-REF-B',
    LibrarySection.references,
    _t(
      'TEST REFERENCE B — placeholder, not a real publication',
      'ТЕСТОВЫЙ ИСТОЧНИК B — заглушка, не реальная публикация',
      'TEST MANBA B — namuna, haqiqiy nashr emas',
    ),
  ),
  // Glossariy — faqat terminlar.
  _e(
    'TEST-GLOSS-PMR',
    LibrarySection.glossary,
    _t(
      'Postmortem redistribution',
      'Посмертное перераспределение',
      'O‘limdan keyingi qayta taqsimlanish',
    ),
  ),
  _e(
    'TEST-GLOSS-MATRIX',
    LibrarySection.glossary,
    _t('Biological matrix', 'Биологическая матрица', 'Biologik matritsa'),
  ),
  _e(
    'TEST-GLOSS-COC',
    LibrarySection.glossary,
    _t(
      'Chain of custody',
      'Цепочка хранения доказательств',
      'Ashyoviy dalillarni saqlash zanjiri',
    ),
  ),
];

final testCourses = <Course>[
  Course(
    id: 'TEST-COURSE-TOX',
    title: _t(
      'TEST COURSE — Forensic toxicology basics (placeholder)',
      'ТЕСТОВЫЙ КУРС — основы судебной токсикологии (заглушка)',
      'TEST KURS — sud toksikologiyasi asoslari (namuna)',
    ),
    isTestData: true,
    lessons: [
      Lesson(
        id: 'TEST-L1',
        title: _t(
          'TEST LESSON 1 — placeholder',
          'ТЕСТОВЫЙ УРОК 1 — заглушка',
          'TEST DARS 1 — namuna',
        ),
      ),
      Lesson(
        id: 'TEST-L2',
        title: _t(
          'TEST LESSON 2 — placeholder',
          'ТЕСТОВЫЙ УРОК 2 — заглушка',
          'TEST DARS 2 — namuna',
        ),
      ),
      Lesson(
        id: 'TEST-L3',
        title: _t(
          'TEST LESSON 3 — placeholder',
          'ТЕСТОВЫЙ УРОК 3 — заглушка',
          'TEST DARS 3 — namuna',
        ),
      ),
    ],
  ),
  Course(
    id: 'TEST-COURSE-FM',
    title: _t(
      'TEST COURSE — Postmortem changes (placeholder)',
      'ТЕСТОВЫЙ КУРС — посмертные изменения (заглушка)',
      'TEST KURS — o‘limdan keyingi o‘zgarishlar (namuna)',
    ),
    isTestData: true,
    lessons: [
      Lesson(
        id: 'TEST-L4',
        title: _t(
          'TEST LESSON 1 — placeholder',
          'ТЕСТОВЫЙ УРОК 1 — заглушка',
          'TEST DARS 1 — namuna',
        ),
      ),
    ],
  ),
];

final testQuiz = <QuizQuestion>[
  QuizQuestion(
    id: 'TEST-Q1',
    stem: _t(
      'TEST QUESTION — placeholder. Which option is marked correct in this fixture?',
      'ТЕСТОВЫЙ ВОПРОС — заглушка. Какой вариант отмечен верным в этом наборе?',
      'TEST SAVOL — namuna. Ushbu to‘plamda qaysi variant to‘g‘ri deb belgilangan?',
    ),
    options: [
      _t('Option A (fixture)', 'Вариант A (тест)', 'A variant (test)'),
      _t(
        'Option B (fixture, marked correct)',
        'Вариант B (тест, отмечен верным)',
        'B variant (test, to‘g‘ri deb belgilangan)',
      ),
      _t('Option C (fixture)', 'Вариант C (тест)', 'C variant (test)'),
    ],
    correctIndex: 1,
    explanation: _t(
      'TEST EXPLANATION — placeholder. Real explanations will cite reviewed sources.',
      'ТЕСТОВОЕ ПОЯСНЕНИЕ — заглушка. Реальные пояснения будут ссылаться на проверенные источники.',
      'TEST IZOH — namuna. Haqiqiy izohlar tekshirilgan manbalarga havola beradi.',
    ),
    isTestData: true,
  ),
];

final testFlashcards = <Flashcard>[
  Flashcard(
    id: 'TEST-FC1',
    front: _t(
      'TEST CARD — front placeholder',
      'ТЕСТОВАЯ КАРТОЧКА — лицевая сторона',
      'TEST KARTOCHKA — old tomoni',
    ),
    back: _t(
      'TEST CARD — back placeholder',
      'ТЕСТОВАЯ КАРТОЧКА — обратная сторона',
      'TEST KARTOCHKA — orqa tomoni',
    ),
    isTestData: true,
  ),
];

final testCases = <CaseStudy>[
  CaseStudy(
    id: 'TEST-CASE-1',
    title: _t(
      'TEST CASE — placeholder scenario',
      'ТЕСТОВЫЙ СЛУЧАЙ — сценарий-заглушка',
      'TEST HOLAT — namunaviy ssenariy',
    ),
    isTestData: true,
  ),
];

class FixtureLibraryRepository implements LibraryRepository {
  const FixtureLibraryRepository();

  @override
  List<LibraryEntry> entries(LibrarySection section) => [
    for (final e in testLibraryEntries)
      if (e.section == section) e,
  ];

  @override
  LibraryEntry? byId(String id) {
    for (final e in testLibraryEntries) {
      if (e.id == id) return e;
    }
    return null;
  }
}

class FixtureLearnRepository implements LearnRepository {
  const FixtureLearnRepository();

  @override
  List<Course> courses() => testCourses;

  @override
  List<QuizQuestion> quiz() => testQuiz;

  @override
  List<Flashcard> flashcards() => testFlashcards;

  @override
  List<CaseStudy> cases() => testCases;
}

/// Bo‘sh repozitoriylar — production’da fixture’lar o‘chirilganda.
class EmptyLibraryRepository implements LibraryRepository {
  const EmptyLibraryRepository();

  @override
  List<LibraryEntry> entries(LibrarySection section) => const [];

  @override
  LibraryEntry? byId(String id) => null;
}

class EmptyLearnRepository implements LearnRepository {
  const EmptyLearnRepository();

  @override
  List<Course> courses() => const [];

  @override
  List<QuizQuestion> quiz() => const [];

  @override
  List<Flashcard> flashcards() => const [];

  @override
  List<CaseStudy> cases() => const [];
}
