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
  '/tools/tool/tool.lab.dilution',
  '/home/module/forensicMedicine',
  '/library/entry/TEST-SUB-ETOH',
  Routes.purchase,
  Routes.privacy,
  Routes.terms,
  Routes.about,
  Routes.profileJurisdiction,
];

const onboardingScreens = <String>[
  Routes.language,
  Routes.disclaimer,
  Routes.mode,
];
