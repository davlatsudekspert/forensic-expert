import 'dart:async';

import 'package:fe_content_schema/fe_content_schema.dart'
    show ForensicDiscipline, KnowledgeArea;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../core/perf/navigation_timing.dart';
import '../core/settings/app_settings.dart';
import '../core/settings/settings_controller.dart';
import '../domain/catalog/tools_catalog.dart';
import '../domain/class_groups/class_groups_models.dart';
import '../domain/class_quiz/class_quiz_models.dart';
import '../domain/knowledge/knowledge_models.dart';
import '../domain/learn/study_models.dart' show StudyQuizMode;
import '../domain/library/library_models.dart';
import '../domain/moderation/moderation_models.dart';
import '../domain/plan/plan_models.dart' show Plan;
import '../domain/publications/publication_models.dart';
import '../domain/referral/referral_models.dart';
import '../domain/support/support_models.dart';
import '../features/account/presentation/auth_screens.dart';
import '../features/admin/presentation/admin_plans_screen.dart';
import '../features/admin/presentation/admin_screen.dart';
import '../features/admin/presentation/admin_support_screens.dart';
import '../features/admin/presentation/admin_verification_screens.dart';
import '../features/ai/presentation/ai_screen.dart';
import '../features/assessment/presentation/assessment_screens.dart';
import '../features/casebook/presentation/casebook_screens.dart';
import '../features/class_groups/presentation/assign_test_screen.dart';
import '../features/class_groups/presentation/group_detail_screen.dart';
import '../features/class_groups/presentation/groups_screens.dart';
import '../features/class_groups/presentation/lesson_group_test_screen.dart';
import '../features/class_groups/presentation/mixed_test_screen.dart';
import '../features/class_groups/presentation/teacher_live_screens.dart';
import '../features/class_groups/presentation/test_screens.dart';
import '../features/class_quiz/presentation/class_quiz_host_screen.dart';
import '../features/class_quiz/presentation/class_quiz_hub_screen.dart';
import '../features/class_quiz/presentation/class_quiz_play_screen.dart';
import '../features/class_quiz/presentation/teacher_panel_screen.dart';
import '../features/court_prep/presentation/court_prep_screens.dart';
import '../features/disciplines/presentation/disciplines_screens.dart';
import '../features/evidence/presentation/provenance_screens.dart';
import '../features/evidence/presentation/research_screens.dart';
import '../features/evidence/presentation/scientific_image.dart';
import '../features/glossary/presentation/glossary_screens.dart';
import '../features/guidelines/presentation/guidelines_screens.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/search_screen.dart';
import '../features/knowledge/presentation/knowledge_detail_screen.dart';
import '../features/knowledge/presentation/knowledge_list_screen.dart';
import '../features/learn/presentation/learn_screens.dart';
import '../features/learn/presentation/study_screens.dart';
import '../features/legal/presentation/compare_screen.dart';
import '../features/legal/presentation/jurisdiction_screens.dart';
import '../features/lessons/presentation/lesson_viewer_screen.dart';
import '../features/lessons/presentation/lessons_list_screen.dart';
import '../features/library/presentation/entry_detail_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/library/presentation/source_detail_screen.dart';
import '../features/library/presentation/sources_list_screen.dart';
import '../features/moderation/presentation/admin_reports_screen.dart';
import '../features/moderation/presentation/blocked_authors_screen.dart';
import '../features/moderation/presentation/community_terms_screen.dart';
import '../features/moderation/presentation/report_screen.dart';
import '../features/onboarding/presentation/disclaimer_screen.dart';
import '../features/onboarding/presentation/language_screen.dart';
import '../features/onboarding/presentation/mode_screen.dart';
import '../features/placeholder/presentation/not_found_screen.dart';
import '../features/pro/presentation/analysis_plan_screen.dart';
import '../features/pro/presentation/pro_gate.dart'
    show CasebookGate, CourtPrepGate, StudentTestGate;
import '../features/pro/presentation/pro_screen.dart';
import '../features/pro/presentation/pro_search_screen.dart';
import '../features/professional/presentation/account_choice_screen.dart';
import '../features/professional/presentation/profile_edit_screen.dart';
import '../features/professional/presentation/review_section.dart';
import '../features/professional/presentation/verification_screens.dart';
import '../features/profile/presentation/legal_screens.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/settings_pickers.dart';
import '../features/profile/presentation/sources_authors_screen.dart';
import '../features/publications/presentation/moderation_queue_screen.dart';
import '../features/publications/presentation/my_publications_screen.dart';
import '../features/publications/presentation/publications_screen.dart';
import '../features/publications/presentation/submit_publication_screen.dart';
import '../features/qa/presentation/qa_ask_screen.dart';
import '../features/qa/presentation/qa_feed_screen.dart';
import '../features/qa/presentation/qa_mine_screen.dart';
import '../features/qa/presentation/qa_moderation_screen.dart';
import '../features/qa/presentation/qa_question_screen.dart';
import '../features/qa/presentation/qa_rules_screen.dart';
import '../features/qa/presentation/qa_verify_screen.dart';
import '../features/referral/presentation/referral_screen.dart';
import '../features/shell/presentation/app_shell.dart';
import '../features/support/presentation/support_screens.dart';
import '../features/tools/presentation/module_hub_screen.dart';
import '../features/tools/presentation/tool_detail_screen.dart';
import '../features/tools/presentation/tools_screen.dart';
import 'class_groups.dart';
import 'class_quiz.dart';
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

/// Kutilayotgan guruh taklifi: onboarding tugagan bo‘lsa — qo‘shilish
/// sahifasi (sof funksiya — alohida test qilinadi). [invite] `null` yoki
/// onboarding tugamagan bo‘lsa — `null` (onboarding o‘z yo‘lida davom etadi,
/// taklif diskda kutadi).
String? pendingGroupInviteRedirect(
  AppSettings s,
  String location,
  GroupInvite? invite,
) {
  if (invite == null || requiredOnboardingStep(s) != null) return null;
  if (location != Routes.home) return null;
  return Routes.groupJoinWith(invite.code, assignmentId: invite.assignmentId);
}

class _SettingsListenable extends ChangeNotifier {
  _SettingsListenable(Ref ref) {
    ref.listen(settingsControllerProvider, (_, _) => notifyListeners());
  }
}

/// «Birinchi qadamlar»: qaysi bo‘lim ochilganini faqat lokal belgilaydi.
String? firstStepFor(String location) {
  if (location == Routes.disciplines ||
      location.startsWith('/home/disciplines/') ||
      location.startsWith('/home/module/') ||
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

  late final GoRouter router;

  // Onboarding tugagach (yoki havola ilova ochiq turganda kelsa) Asosiy
  // sahifaga kelindi: kutilayotgan taklif BIR MARTA qo‘shilish sahifasini
  // ochadi — keyingi kadrda, Asosiy chizilgandan keyin.
  void openPendingGroupInvite() {
    SchedulerBinding.instance
      ..addPostFrameCallback((_) {
        final here = router.routerDelegate.currentConfiguration.uri.path;
        final settings = ref.read(settingsControllerProvider);
        final pending = ref.read(pendingGroupInviteProvider);
        if (pendingGroupInviteRedirect(settings, here, pending) == null) {
          return;
        }
        final inv = ref
            .read(pendingGroupInviteProvider.notifier)
            .takeAutoOpen();
        if (inv == null) return;
        unawaited(
          router.push<void>(
            Routes.groupJoinWith(inv.code, assignmentId: inv.assignmentId),
          ),
        );
      })
      ..scheduleFrame();
  }

  router = GoRouter(
    navigatorKey: rootKey,
    initialLocation:
        requiredOnboardingStep(ref.read(settingsControllerProvider)) ??
        Routes.home,
    refreshListenable: refresh,
    observers: [NavigationTimingObserver()],
    // Noma’lum yoki eskirgan havola — tushunarli sahifa va Home tugmasi.
    errorBuilder: (c, s) => const NotFoundScreen(),
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
      // Sinf havolasi (QR / deep link): kod xotirada saqlanadi, so‘ng
      // qo‘shilish ekrani (kirish kerak bo‘lsa — o‘sha ekranda so‘raladi).
      if (state.uri.path.startsWith(Routes.joinPrefix)) {
        final code = ClassCode.extract(state.uri);
        if (code != null) {
          ref.read(pendingClassCodeProvider.notifier).remember(code);
          final target = Routes.classJoinWith(code);
          return onboardingRedirect(settings, target) ?? target;
        }
        return onboardingRedirect(settings, Routes.classQuiz) ??
            Routes.classQuiz;
      }
      // Guruh QR havolasi (`/g/<KOD>?a=<test>`): taklif DISKDA saqlanadi —
      // yangi o‘rnatilgan ilovada onboarding/ro‘yxatdan o‘tish davomida
      // yo‘qolmaydi. Avval Asosiy sahifa (yoki onboarding) chiziladi, so‘ng
      // qo‘shilish sahifasi ustiga ochiladi (openPendingGroupInvite):
      // shell hech qachon chizilmagan bo‘lsa, keyingi `go` nested
      // navigator’da Hero o‘tishini o‘lchamsiz boshlaydi.
      if (state.uri.path.startsWith(Routes.groupLinkPrefix)) {
        final inv = GroupCode.fromUri(state.uri);
        if (inv != null) {
          ref.read(pendingGroupInviteProvider.notifier).remember(inv);
          // Bir xil manzil (Asosiy → Asosiy) delegate’ni xabardor qilmaydi.
          openPendingGroupInvite();
        }
        return onboardingRedirect(settings, Routes.home) ??
            (inv == null ? Routes.groups : Routes.home);
      }
      // Rejim chegaralari (egasi qarori, 2026-10-24): Ustoz paneli va natijalar
      // faqat «Ustoz» rejimida; «Darslar» Talabaga yo‘q (Mutaxassis — faqat
      // ochiq «Apparatlar» kursi, server o‘zi cheklaydi). To‘g‘ridan-to‘g‘ri
      // havola ham Asosiyga qaytaradi.
      final loc = state.matchedLocation;
      final mode = settings.userMode;
      if (mode != null &&
          mode != UserMode.teacher &&
          (loc == Routes.teacher || loc == Routes.teacherResults)) {
        return Routes.home;
      }
      if (mode == UserMode.student &&
          (loc == Routes.lessons || loc.startsWith('${Routes.lessons}/'))) {
        return Routes.home;
      }
      // «Bilim va malakani baholash» — Mutaxassis va Ustoz uchun (talabaga yo‘q).
      if (mode == UserMode.student &&
          (loc == Routes.assessment ||
              loc.startsWith('${Routes.assessment}/'))) {
        return Routes.home;
      }
      _recordFirstStep(ref, loc);
      return onboardingRedirect(settings, loc);
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
      // Faqat moslik uchun: redirect har doim qo‘shilish ekraniga yo‘naltiradi.
      GoRoute(
        path: '${Routes.joinPrefix}:code',
        builder: (c, s) => const SizedBox.shrink(),
      ),
      // Faqat moslik uchun: redirect guruh taklifini qayta ishlaydi.
      GoRoute(
        path: '${Routes.groupLinkPrefix}:code',
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
                    builder: (c, s) => SearchScreen(
                      initialQuery: s.uri.queryParameters['q'],
                      initialDiscipline: ForensicDiscipline.fromCode(
                        s.uri.queryParameters['d'] ?? '',
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'pro',
                        builder: (c, s) => ProSearchScreen(
                          initialText: s.uri.queryParameters['q'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'teacher',
                    builder: (c, s) => const TeacherPanelScreen(),
                    routes: [
                      GoRoute(
                        path: 'results',
                        builder: (c, s) => const TeacherResultsScreen(),
                      ),
                      GoRoute(
                        path: 'lessons',
                        builder: (c, s) => const LessonsListScreen(),
                        routes: [
                          GoRoute(
                            path: ':id',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => LessonViewerScreen(
                              topicId: s.pathParameters['id']!,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                      GoRoute(
                        path: 'class',
                        builder: (c, s) => const ClassQuizHubScreen(),
                        routes: [
                          GoRoute(
                            path: 'new',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => ClassCreateScreen(
                              initialTopicId: s.uri.queryParameters['topic'],
                            ),
                          ),
                          GoRoute(
                            path: 'join',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => StudentTestGate(
                              child: ClassJoinScreen(
                                initialCode: s.uri.queryParameters['code'],
                              ),
                            ),
                          ),
                          GoRoute(
                            path: 'scan',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => const ClassScanScreen(),
                          ),
                          GoRoute(
                            path: 'host/:id',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => ClassHostScreen(
                              sessionId: s.pathParameters['id']!,
                            ),
                          ),
                          GoRoute(
                            path: 'play/:id',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => StudentTestGate(
                              child: ClassPlayScreen(
                                sessionId: s.pathParameters['id']!,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // «Ustoz–talaba testi»: guruhlar va mavzu testlari.
                      GoRoute(
                        path: 'groups',
                        builder: (c, s) => const GroupsHomeScreen(),
                        routes: [
                          GoRoute(
                            path: 'new',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => const GroupCreateScreen(),
                          ),
                          GoRoute(
                            path: 'join',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => StudentTestGate(
                              child: GroupJoinScreen(
                                initialCode: s.uri.queryParameters['code'],
                                assignmentId: s.uri.queryParameters['a'],
                              ),
                            ),
                          ),
                          GoRoute(
                            path: 'scan',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => const GroupScanScreen(),
                          ),
                          GoRoute(
                            path: 'lesson/:topic',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => LessonGroupTestScreen(
                              topicId: s.pathParameters['topic']!,
                            ),
                          ),
                          GoRoute(
                            path: 'practice/:topic',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => StudentTestGate(
                              child: GroupTestScreen(
                                groupId: '',
                                assignmentId: '',
                                practiceTopicId: s.pathParameters['topic'],
                              ),
                            ),
                          ),
                          GoRoute(
                            path: ':gid',
                            builder: (c, s) => GroupDetailScreen(
                              groupId: s.pathParameters['gid']!,
                            ),
                            routes: [
                              GoRoute(
                                path: 'assign',
                                parentNavigatorKey: rootKey,
                                builder: (c, s) => AssignTestScreen(
                                  groupId: s.pathParameters['gid']!,
                                  initialTopicId:
                                      s.uri.queryParameters['topic'],
                                ),
                              ),
                              GoRoute(
                                path: 'mixed',
                                parentNavigatorKey: rootKey,
                                builder: (c, s) => MixedTestScreen(
                                  groupId: s.pathParameters['gid']!,
                                ),
                              ),
                              GoRoute(
                                path: 'a/:aid',
                                builder: (c, s) => TeacherAssignmentScreen(
                                  groupId: s.pathParameters['gid']!,
                                  assignmentId: s.pathParameters['aid']!,
                                ),
                                routes: [
                                  GoRoute(
                                    path: 'board',
                                    parentNavigatorKey: rootKey,
                                    builder: (c, s) => GroupBoardScreen(
                                      groupId: s.pathParameters['gid']!,
                                      assignmentId: s.pathParameters['aid']!,
                                    ),
                                  ),
                                  GoRoute(
                                    path: 'preview',
                                    parentNavigatorKey: rootKey,
                                    builder: (c, s) => GroupTestScreen(
                                      groupId: s.pathParameters['gid']!,
                                      assignmentId: s.pathParameters['aid']!,
                                      preview: true,
                                    ),
                                  ),
                                ],
                              ),
                              GoRoute(
                                path: 't/:aid',
                                parentNavigatorKey: rootKey,
                                builder: (c, s) => StudentTestGate(
                                  child: GroupTestScreen(
                                    groupId: s.pathParameters['gid']!,
                                    assignmentId: s.pathParameters['aid']!,
                                  ),
                                ),
                              ),
                              GoRoute(
                                path: 'r/:aid',
                                parentNavigatorKey: rootKey,
                                builder: (c, s) => GroupResultScreen(
                                  groupId: s.pathParameters['gid']!,
                                  assignmentId: s.pathParameters['aid']!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'study',
                        builder: (c, s) => const StudyHubScreen(),
                        routes: [
                          GoRoute(
                            path: ':deck/cards',
                            builder: (c, s) => StudyFlashcardsScreen(
                              deckId: s.pathParameters['deck']!,
                            ),
                          ),
                          GoRoute(
                            path: ':deck/quiz',
                            builder: (c, s) => StudyQuizScreen(
                              deckId: s.pathParameters['deck']!,
                              mode: s.uri.queryParameters['mode'] == 'exam'
                                  ? StudyQuizMode.exam
                                  : StudyQuizMode.practice,
                            ),
                          ),
                        ],
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
                    builder: (c, s) => switch (KnowledgeKind.values
                        .asNameMap()[s.pathParameters['kind']]) {
                      final kind? => KnowledgeListScreen(kind: kind),
                      null => const NotFoundScreen(),
                    },
                  ),
                  GoRoute(
                    path: 'entry/:id',
                    builder: (c, s) =>
                        KnowledgeDetailScreen(entryId: s.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'area/:area',
                    builder: (c, s) => switch (KnowledgeArea.values
                        .asNameMap()[s.pathParameters['area']]) {
                      final area? => AreaHubScreen(area: area),
                      null => const NotFoundScreen(),
                    },
                  ),
                  // Qidiruv natijalari Home tabida ochiladi (tab
                  // almashmaydi, «Back» natijalarga qaytaradi) — boshqa
                  // tablardagi ekranlarning o‘zi qayta ishlatiladi.
                  GoRoute(
                    path: 'substance/:id',
                    builder: (c, s) =>
                        EntryDetailScreen(entryId: s.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'plan',
                        builder: (c, s) => AnalysisPlanScreen(
                          entityId: s.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'tool/:id',
                    builder: (c, s) =>
                        ToolDetailScreen(toolId: s.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'guideline/:id',
                    builder: (c, s) =>
                        GuidelineDetailScreen(cardId: s.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'specimen/:id',
                    builder: (c, s) => SpecimenDetailScreen(
                      specimenId: s.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'glossary/:id',
                    builder: (c, s) => GlossaryTermScreen(
                      termId: s.pathParameters['id']!,
                      inHome: true,
                    ),
                  ),
                  GoRoute(
                    path: 'standards',
                    builder: (c, s) => const StandardsScreen(),
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
                  GoRoute(
                    path: 'casebook',
                    builder: (c, s) =>
                        const CasebookGate(child: CasebookScreen()),
                    routes: [
                      GoRoute(
                        path: 'entry/:id',
                        builder: (c, s) => CasebookGate(
                          child: CasebookEntryScreen(
                            entryId: s.pathParameters['id']!,
                          ),
                        ),
                      ),
                    ],
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
                    builder: (c, s) => switch (LibrarySection.values
                        .asNameMap()[s.pathParameters['section']]) {
                      final section? => LibrarySectionScreen(section: section),
                      null => const NotFoundScreen(),
                    },
                  ),
                  GoRoute(
                    path: 'sources',
                    builder: (c, s) => const SourcesListScreen(),
                  ),
                  GoRoute(
                    path: 'standards',
                    builder: (c, s) => const StandardsScreen(),
                  ),
                  GoRoute(
                    path: 'glossary',
                    builder: (c, s) => const GlossaryScreen(),
                    routes: [
                      GoRoute(
                        path: 'term/:id',
                        builder: (c, s) =>
                            GlossaryTermScreen(termId: s.pathParameters['id']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'guidelines',
                    builder: (c, s) => const GuidelinesScreen(),
                    routes: [
                      GoRoute(
                        path: 'card/:id',
                        builder: (c, s) => GuidelineDetailScreen(
                          cardId: s.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'assessment',
                    builder: (c, s) => const AssessmentHubScreen(),
                    routes: [
                      GoRoute(
                        path: ':spec',
                        builder: (c, s) => AssessmentSpecialtyScreen(
                          specialtyId: s.pathParameters['spec']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'test',
                            builder: (c, s) => AssessmentTestScreen(
                              specialtyId: s.pathParameters['spec']!,
                            ),
                          ),
                          GoRoute(
                            path: 'q/:id',
                            builder: (c, s) => AssessmentQuestionScreen(
                              specialtyId: s.pathParameters['spec']!,
                              questionId: s.pathParameters['id']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'court-prep',
                    builder: (c, s) =>
                        const CourtPrepGate(child: CourtPrepScreen()),
                    routes: [
                      GoRoute(
                        path: 'practice',
                        builder: (c, s) =>
                            const CourtPrepGate(child: CourtPracticeScreen()),
                      ),
                      GoRoute(
                        path: 'principles',
                        builder: (c, s) =>
                            const CourtPrepGate(child: CourtPrinciplesScreen()),
                      ),
                      GoRoute(
                        path: 'drill',
                        builder: (c, s) =>
                            const CourtPrepGate(child: CourtDrillScreen()),
                      ),
                      GoRoute(
                        path: 'stats',
                        builder: (c, s) =>
                            const CourtPrepGate(child: CourtStatsScreen()),
                      ),
                      GoRoute(
                        path: 'simulator',
                        builder: (c, s) =>
                            const CourtPrepGate(child: CourtSimulatorScreen()),
                        routes: [
                          GoRoute(
                            path: ':id',
                            builder: (c, s) => CourtPrepGate(
                              child: CourtScenarioScreen(
                                scenarioId: s.pathParameters['id']!,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'topic/:id',
                        builder: (c, s) => CourtPrepGate(
                          child: CourtTopicScreen(
                            topicId: s.pathParameters['id']!,
                          ),
                        ),
                      ),
                      GoRoute(
                        path: 'q/:id',
                        builder: (c, s) => CourtPrepGate(
                          child: CourtQuestionScreen(
                            questionId: s.pathParameters['id']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'publications',
                    builder: (c, s) => const PublicationsScreen(),
                    routes: [
                      GoRoute(
                        path: 'item/:id',
                        builder: (c, s) => PublicationDetailScreen(
                          publicationId: s.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'submit',
                        builder: (c, s) => SubmitPublicationScreen(
                          initial: s.extra is Publication
                              ? s.extra! as Publication
                              : null,
                        ),
                      ),
                      GoRoute(
                        path: 'mine',
                        builder: (c, s) => const MyPublicationsScreen(),
                      ),
                      GoRoute(
                        path: 'moderation',
                        builder: (c, s) => const ModerationQueueScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'qa',
                    builder: (c, s) => const QaFeedScreen(),
                    routes: [
                      GoRoute(
                        path: 'q/:id',
                        builder: (c, s) => QaQuestionScreen(
                          questionId: s.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'ask',
                        builder: (c, s) => const QaAskScreen(),
                      ),
                      GoRoute(
                        path: 'rules',
                        builder: (c, s) => const QaRulesScreen(),
                      ),
                      GoRoute(
                        path: 'mine',
                        builder: (c, s) => const QaMineScreen(),
                      ),
                      GoRoute(
                        path: 'verify',
                        builder: (c, s) => const QaVerifyScreen(),
                      ),
                      GoRoute(
                        path: 'moderation',
                        builder: (c, s) => const QaModerationScreen(),
                      ),
                      GoRoute(
                        path: 'terms',
                        builder: (c, s) => const CommunityTermsScreen(),
                      ),
                      GoRoute(
                        path: 'blocked',
                        builder: (c, s) => const BlockedAuthorsScreen(),
                      ),
                    ],
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
              GoRoute(
                path: Routes.ai,
                builder: (c, s) =>
                    AiScreen(initialQuestion: s.uri.queryParameters['q']),
              ),
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
                    routes: [
                      GoRoute(
                        path: 'inbox',
                        parentNavigatorKey: rootKey,
                        builder: (c, s) => const AdminInboxScreen(),
                        routes: [
                          GoRoute(
                            path: ':id',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => AdminThreadScreen(
                              threadId: s.pathParameters['id']!,
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'users',
                        parentNavigatorKey: rootKey,
                        builder: (c, s) => const AdminUsersScreen(),
                      ),
                      GoRoute(
                        path: 'audit',
                        parentNavigatorKey: rootKey,
                        builder: (c, s) => const AdminAuditScreen(),
                      ),
                      GoRoute(
                        path: 'plans',
                        parentNavigatorKey: rootKey,
                        builder: (c, s) => const AdminPlansScreen(),
                      ),
                      GoRoute(
                        path: 'reports',
                        parentNavigatorKey: rootKey,
                        builder: (c, s) => const AdminReportsScreen(),
                      ),
                      GoRoute(
                        path: 'verifications',
                        parentNavigatorKey: rootKey,
                        builder: (c, s) => const AdminVerificationsScreen(),
                        routes: [
                          GoRoute(
                            path: ':id',
                            parentNavigatorKey: rootKey,
                            builder: (c, s) => AdminVerificationDetailScreen(
                              applicantId: s.pathParameters['id']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'report',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) {
                      final q = s.uri.queryParameters;
                      return ReportScreen(
                        initialKind: q['kind'] == null
                            ? null
                            : ReportKind.fromWire(q['kind']),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'support',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => const SupportListScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        parentNavigatorKey: rootKey,
                        builder: (c, s) {
                          final q = s.uri.queryParameters;
                          return NewSupportThreadScreen(
                            initialCategory: q['category'] == null
                                ? null
                                : SupportCategory.fromWire(q['category']),
                            relatedEntity: switch (q['entity']) {
                              final e? when e.isNotEmpty =>
                                sanitizeRelatedEntity(e),
                              _ => null,
                            },
                            relatedTitle: q['title'],
                          );
                        },
                      ),
                      GoRoute(
                        path: 'thread/:id',
                        parentNavigatorKey: rootKey,
                        builder: (c, s) => SupportThreadScreen(
                          threadId: s.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'pro',
                    parentNavigatorKey: rootKey,
                    builder: (c, s) => ProScreen(
                      plan: Plan.fromWire(s.uri.queryParameters['plan']),
                    ),
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
                    routes: [
                      GoRoute(
                        path: 'sources',
                        parentNavigatorKey: rootKey,
                        builder: (c, s) => const SourcesAuthorsScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  router.routerDelegate.addListener(openPendingGroupInvite);
  ref.onDispose(
    () => router.routerDelegate.removeListener(openPendingGroupInvite),
  );
  ref.onDispose(router.dispose);
  return router;
});
