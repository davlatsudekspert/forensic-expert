import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../core/perf/navigation_timing.dart';
import '../core/settings/app_settings.dart';
import '../core/settings/settings_controller.dart';
import '../features/ai/presentation/ai_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/search_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/onboarding/presentation/disclaimer_screen.dart';
import '../features/onboarding/presentation/language_screen.dart';
import '../features/onboarding/presentation/mode_screen.dart';
import '../features/placeholder/presentation/in_development_view.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/settings_pickers.dart';
import '../features/shell/presentation/app_shell.dart';
import '../features/tools/presentation/tools_screen.dart';
import 'routes.dart';

/// Onboarding holatiga qarab kerakli qadam (yoki `null` — tugagan).
String? requiredOnboardingStep(AppSettings s) {
  if (!s.hasLanguage) return Routes.language;
  if (!s.disclaimerAccepted) return Routes.disclaimer;
  if (s.userMode == null) return Routes.mode;
  return null;
}

/// Redirect qoidasi (sof funksiya — alohida test qilinadi).
///
/// * Til tanlanmagan bo‘lsa — **birinchi ekran til tanlash** (login yo‘q).
/// * Onboarding tugamaguncha shell’ga kirib bo‘lmaydi.
/// * Oldingi onboarding qadamlariga qaytish mumkin.
String? onboardingRedirect(AppSettings s, String location) {
  final required = requiredOnboardingStep(s);
  const steps = Routes.onboardingSteps;
  final isOnboarding = steps.contains(location);
  if (required == null) return isOnboarding ? Routes.home : null;
  if (!isOnboarding) return required;
  return steps.indexOf(location) <= steps.indexOf(required) ? null : required;
}

class _SettingsListenable extends ChangeNotifier {
  _SettingsListenable(Ref ref) {
    ref.listen(settingsControllerProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final refresh = _SettingsListenable(ref);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation:
        requiredOnboardingStep(ref.read(settingsControllerProvider)) ??
        Routes.home,
    refreshListenable: refresh,
    observers: [NavigationTimingObserver()],
    redirect: (context, state) => onboardingRedirect(
      ref.read(settingsControllerProvider),
      state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: Routes.language,
        pageBuilder: (c, s) => const NoTransitionPage(child: LanguageScreen()),
      ),
      GoRoute(
        path: Routes.disclaimer,
        builder: (c, s) => const DisclaimerScreen(),
      ),
      GoRoute(path: Routes.mode, builder: (c, s) => const ModeScreen()),
      StatefulShellRoute.indexedStack(
        builder: (c, s, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (c, s) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'search',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const SearchScreen(),
                  ),
                  GoRoute(
                    path: 'module/:id',
                    builder: (c, s) {
                      final module = HomeModule.values
                          .asNameMap()[s.pathParameters['id']];
                      final l = AppLocalizations.of(c);
                      return ModulePlaceholderScreen(
                        title: module?.label(l) ?? l.inDevelopmentTitle,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.tools,
                builder: (c, s) => const ToolsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (c, s) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.ai, builder: (c, s) => const AiScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (c, s) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'language',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const LanguagePickerScreen(),
                  ),
                  GoRoute(
                    path: 'mode',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const ModePickerScreen(),
                  ),
                  GoRoute(
                    path: 'disclaimer',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const DisclaimerScreen(readOnly: true),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
