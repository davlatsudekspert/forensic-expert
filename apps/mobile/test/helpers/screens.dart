import 'package:forensic_expert/app/routes.dart';

/// Barcha PHASE 1 ekranlari (onboarding’dan tashqari) — a11y va kichik
/// ekran testlari shu ro‘yxat bo‘yicha yuradi.
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
];

const onboardingScreens = <String>[
  Routes.language,
  Routes.disclaimer,
  Routes.mode,
];
