import 'package:forensic_expert/app/routes.dart';

/// Barcha asosiy ekranlar (onboarding’dan tashqari) — a11y, kichik ekran
/// va offline testlari shu ro‘yxat bo‘yicha yuradi. PHASE 1 + PHASE 2.
const shellScreens = <String>[
  Routes.home,
  Routes.search,
  '/home/module/toxicology',
  Routes.tools,
  Routes.library,
  Routes.ai,
  Routes.profile,
  Routes.profileLanguage,
  Routes.profileMode,
  Routes.profileDisclaimer,
  // PHASE 2
  Routes.learn,
  Routes.quiz,
  Routes.flashcards,
  Routes.study,
  '/tools/tool/tool.lab.dilution',
  Routes.forensicMedicine,
  '/library/entry/TEST-SUB-ETOH',
  Routes.purchase,
  Routes.privacy,
  Routes.terms,
  Routes.about,
  Routes.profileJurisdiction,
  // PHASE 4 (TEST fixture’lar bilan; pilot paket alohida testlarda)
  Routes.biochemistry,
  '/home/knowledge/reagent',
  '/home/knowledge/screeningTest',
  '/home/knowledge/method',
  '/home/knowledge/emergingIssue',
  '/home/entry/TEST-REAGENT-1',
  '/home/entry/TEST-SCREEN-1',
  '/home/entry/TEST-METHOD-nationalMethod',
  Routes.compare,
  Routes.exam,
  '/tools/tool/tool.lab.solution',
  // Ro‘yxatdan o‘tish, professional tasdiqlash, taqriz.
  Routes.welcomeAccount,
  Routes.welcomeProfile,
  Routes.profileEdit,
  Routes.verification,
  Routes.verificationDocuments,
  Routes.reviewDashboard,
  '/home/module/laboratory',
];

const onboardingScreens = <String>[
  Routes.language,
  Routes.disclaimer,
  Routes.mode,
];
