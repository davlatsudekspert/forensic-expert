import 'dart:async';

import 'package:fe_content_schema/fe_content_schema.dart' show KnowledgeArea;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../core/perf/navigation_timing.dart';
import '../core/settings/app_settings.dart';
import '../core/settings/settings_controller.dart';
import '../domain/catalog/tools_catalog.dart';
import '../domain/knowledge/knowledge_models.dart';
import '../domain/library/library_models.dart';
import '../domain/referral/referral_models.dart';
import '../features/account/presentation/auth_screens.dart';
import '../features/admin/presentation/admin_screen.dart';
import '../features/ai/presentation/ai_screen.dart';
import '../features/disciplines/presentation/disciplines_screens.dart';
import '../features/evidence/presentation/provenance_screens.dart';
import '../features/evidence/presentation/research_screens.dart';
import '../features/evidence/presentation/scientific_image.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/search_screen.dart';
import '../features/knowledge/presentation/knowledge_detail_screen.dart';
import '../features/knowledge/presentation/knowledge_list_screen.dart';
import '../features/learn/presentation/learn_screens.dart';
import '../features/legal/presentation/compare_screen.dart';
import '../features/legal/presentation/jurisdiction_screens.dart';
import '../features/library/presentation/entry_detail_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/library/presentation/source_detail_screen.dart';
import '../features/onboarding/presentation/disclaimer_screen.dart';
import '../features/onboarding/presentation/language_screen.dart';
import '../features/onboarding/presentation/mode_screen.dart';
import '../features/professional/presentation/account_choice_screen.dart';
import '../features/professional/presentation/profile_edit_screen.dart';
import '../features/professional/presentation/review_section.dart';
import '../features/professional/presentation/verification_screens.dart';
import '../features/profile/presentation/legal_screens.dart';
import '../features/profile/presentation/paywall_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/settings_pickers.dart';
import '../features/referral/presentation/referral_screen.dart';
import '../features/shell/presentation/app_shell.dart';
import '../features/tools/presentation/module_hub_screen.dart';
import '../features/tools/presentation/tool_detail_screen.dart';
import '../features/tools/presentation/tools_screen.dart';
import 'referral.dart';
import 'routes.dart';
import 'user_data.dart';

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

/// «Birinchi qadamlar»: qaysi bo‘lim ochilganini faqat lokal belgilaydi.
String? firstStepFor(String location) {
  if (location.startsWith('/home/disciplines/') ||
      location.startsWith('/home/area/')) {
    return 'discipline';
  }
  if (location.startsWith('/library/source/') ||
      location.startsWith('${Routes.research}/')) {
    return 'source';
  }
  if (location == Routes.ai) return 'ai';
  return null;
}

void _recordFirstStep(Ref ref, String location) {
  final step = firstStepFor(location);
  if (step == null || ref.read(userDataProvider).milestones.contains(step)) {
    return;
  }
  // Navigatsiyadan keyin (build vaqtida provayder o‘zgartirilmaydi).
  scheduleMicrotask(
    () => ref.read(userDataProvider.notifier).recordMilestone(step),
  );
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
    redirect: (context, state) {
      final settings = ref.read(settingsControllerProvider);
      // Taklif havolasi: kod lokal saqlanadi (attribution — serverda,
      // akkaunt ochilgach), so‘ng onboarding yoki taklif sahifasi.
      if (state.uri.path.startsWith(Routes.invitePrefix)) {
        final code = ReferralLinks.extractCode(state.uri);
        if (code != null) {
          unawaited(ref.read(pendingReferralProvider.notifier).remember(code));
        }
        return onboardingRedirect(settings, Routes.referral) ?? Routes.referral;
      }
      _recordFirstStep(ref, state.matchedLocation);
      return onboardingRedirect(settings, state.matchedLocation);
    },
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
      // Faqat moslik uchun: redirect har doim taklif sahifasiga yo‘naltiradi.
      GoRoute(
        path: '${Routes.invitePrefix}:code',
        builder: (c, s) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: Routes.welcomeAccount,
        builder: (c, s) => const AccountChoiceScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (c, s) => const ProfileEditScreen(),
          ),
          GoRoute(path: 'email', builder: (c, s) => const EmailCodeScreen()),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (c, s, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (c, s) => const HomeScreen(),
                routes: [
                  // Qidiruv Home tabida: natijadan ochilgan sahifa ustiga
                  // qo‘shiladi, «Back» natijalarga qaytaradi.
                  GoRoute(
                    path: 'search',
                    builder: (c, s) =>
                        SearchScreen(initialQuery: s.uri.queryParameters['q']),
                  ),
                  GoRoute(
                    path: 'learn',
                    builder: (c, s) => const LearnScreen(),
                    routes: [
                      GoRoute(
                        path: 'quiz',
                        builder: (c, s) => const QuizScreen(),
                      ),
                      GoRoute(
                        path: 'flashcards',
                        builder: (c, s) => const FlashcardsScreen(),
                      ),
                      GoRoute(
                        path: 'exam',
                        builder: (c, s) => const ExamScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'research',
                    builder: (c, s) => ResearchLibraryScreen(
                      entityId: s.uri.queryParameters['entity'],
                    ),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (c, s) => ResearchDetailScreen(
                          researchId: s.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'image/:id',
                    builder: (c, s) =>
                        ImageViewerScreen(imageId: s.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'compare',
                    builder: (c, s) => const CompareJurisdictionsScreen(),
                  ),
                  GoRoute(
                    path: 'disciplines',
                    builder: (c, s) => const DisciplinesScreen(),
                    routes: [
                      GoRoute(
                        path: ':code',
                        builder: (c, s) =>
                            DisciplineScreen(code: s.pathParameters['code']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'jurisdictions',
                    builder: (c, s) => const JurisdictionHubScreen(),
                    routes: [
                      GoRoute(
                        path: 'select',
                        builder: (c, s) => const JurisdictionSelectScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (c, s) => JurisdictionDetailScreen(
                          id: s.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'knowledge/:kind',
                    builder: (c, s) => KnowledgeListScreen(
                      kind: KnowledgeKind.values.byName(
                        s.pathParameters['kind']!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'entry/:id',
                    builder: (c, s) =>
                        KnowledgeDetailScreen(entryId: s.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'area/:area',
                    builder: (c, s) => AreaHubScreen(
                      area: KnowledgeArea.values.byName(
                        s.pathParameters['area']!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'module/:id',
                    builder: (c, s) {
                      final module = HomeModule.values
                          .asNameMap()[s.pathParameters['id']];
                      final l = AppLocalizations.of(c);
                      return ModuleHubScreen(
                        title: module?.label(l) ?? l.appTitle,
                        category: switch (module) {
                          HomeModule.toxicology => ToolCategory.toxicology,
                          HomeModule.laboratory => ToolCategory.laboratory,
                          _ => null,
                        },
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
                routes: [
                  GoRoute(
                    path: 'tool/:id',
                    builder: (c, s) =>
                        ToolDetailScreen(toolId: s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (c, s) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: 'entry/:id',
                    builder: (c, s) =>
                        EntryDetailScreen(entryId: s.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'section/:section',
                    builder: (c, s) => LibrarySectionScreen(
                      section:
                          LibrarySection.values
                              .asNameMap()[s.pathParameters['section']] ??
                          LibrarySection.substances,
                    ),
                  ),
                  GoRoute(
                    path: 'standards',
                    builder: (c, s) => const StandardsScreen(),
                  ),
                  GoRoute(
                    path: 'conflicts',
                    builder: (c, s) => const ConflictsScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (c, s) => ConflictDetailScreen(
                          conflictId: s.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'specimens',
                    builder: (c, s) => const SpecimensScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (c, s) => SpecimenDetailScreen(
                          specimenId: s.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'source/:id',
                    builder: (c, s) =>
                        SourceDetailScreen(sourceId: s.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'chain/:id',
                    builder: (c, s) =>
                        KnowledgeChainScreen(entityId: s.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'review',
                    builder: (c, s) => const ReviewStatusScreen(),
                  ),
                ],
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
                    path: 'jurisdiction',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const JurisdictionSelectScreen(),
                  ),
                  GoRoute(
                    path: 'disclaimer',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const DisclaimerScreen(readOnly: true),
                  ),
                  GoRoute(
                    path: 'purchase',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const PaywallScreen(),
                  ),
                  GoRoute(
                    path: 'ai-disclaimer',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const LegalDocumentScreen(
                      document: LegalDocument.aiDisclaimer,
                    ),
                  ),
                  GoRoute(
                    path: 'account/sign-in',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const SignInScreen(),
                  ),
                  GoRoute(
                    path: 'account/register',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const RegisterScreen(),
                  ),
                  GoRoute(
                    path: 'account/verify',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) =>
                        VerifyEmailScreen(email: s.extra as String? ?? ''),
                  ),
                  GoRoute(
                    path: 'account/forgot',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const ForgotPasswordScreen(),
                  ),
                  GoRoute(
                    path: 'account/reset',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) =>
                        ResetPasswordScreen(email: s.extra as String? ?? ''),
                  ),
                  GoRoute(
                    path: 'account/email',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const EmailCodeScreen(),
                  ),
                  GoRoute(
                    path: 'account/delete',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const DeleteAccountScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const ProfileEditScreen(),
                  ),
                  GoRoute(
                    path: 'verification',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const VerificationScreen(),
                    routes: [
                      GoRoute(
                        path: 'documents',
                        parentNavigatorKey: rootKey,
                        builder: (c, s) => const CredentialUploadScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'reviews',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const ReviewDashboardScreen(),
                  ),
                  GoRoute(
                    path: 'admin',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const AdminScreen(),
                  ),
                  GoRoute(
                    path: 'invite',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const ReferralScreen(),
                  ),
                  GoRoute(
                    path: 'privacy',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const LegalDocumentScreen(
                      document: LegalDocument.privacy,
                    ),
                  ),
                  GoRoute(
                    path: 'terms',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const LegalDocumentScreen(
                      document: LegalDocument.terms,
                    ),
                  ),
                  GoRoute(
                    path: 'about',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const AboutScreen(),
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
