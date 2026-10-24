import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_quiz.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';
import '../../../domain/plan/plan_models.dart';
import '../../pro/presentation/pro_gate.dart';
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'class_quiz_widgets.dart';

/// Ustoz roli serverda bormi (demo’da — demo foydalanuvchi ustoz).
/// Yuklanayotganda yoki xatoda — `false` (UI qulayligi; xavfsizlik chegarasi
/// serverdagi 403).
bool watchIsTeacher(WidgetRef ref) =>
    ref.watch(classIsTeacherProvider).value ?? false;

/// «Ustoz paneli» — Asosiydan 1 bosishda. Ichida uchta katta, oddiy amal:
/// test o‘tkazish (mavzu → kod/QR), natijalar va CSV, sinfga qo‘shilish
/// (talaba). Mavjud «Sinfda test» oqimi qayta ishlatiladi — yangi backend yo‘q.
class TeacherPanelScreen extends ConsumerWidget {
  const TeacherPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final svc = ref.watch(classQuizServiceProvider);
    final teacher = watchIsTeacher(ref);
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.teacherPanelTitle)),
      body: ListView(
        key: const Key('teacher.panel'),
        padding: EdgeInsets.only(
          top: FeSpace.xs,
          bottom: FeSpace.lg + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ClassDemoBanner(),
                Text(
                  l.teacherPanelIntro,
                  style: t.bodyMedium?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: FeSpace.md),
                if (!svc.isConfigured)
                  FeNote(
                    key: const Key('teacher.notConfigured'),
                    icon: Icons.cloud_off_outlined,
                    text: l.classErrNotConfigured,
                  )
                else ...[
                  if (teacher) ...[
                    TeacherActionTile(
                      key: const Key('teacher.lessons'),
                      icon: Icons.slideshow_rounded,
                      title: l.lessonsTitle,
                      body: l.lessonsTeacherBody,
                      primary: true,
                      onTap: () => context.push(Routes.lessons),
                    ),
                    const SizedBox(height: FeSpace.sm),
                  ],
                  TeacherActionTile(
                    key: const Key('teacher.run'),
                    icon: Icons.play_circle_outline_rounded,
                    title: l.teacherRunTitle,
                    body: teacher ? l.teacherRunBody : l.teacherRoleNeeded,
                    primary: true,
                    onTap: teacher ? () => context.push(Routes.classNew) : null,
                  ),
                  const SizedBox(height: FeSpace.sm),
                  // «Ustoz–talaba testi»: jonli testdan alohida — guruh va
                  // muddatli mavzu testi (talaba o‘z vaqtida yechadi).
                  TeacherActionTile(
                    key: const Key('teacher.groups'),
                    icon: Icons.assignment_outlined,
                    title: l.grpTitle,
                    body: teacher ? l.grpTeacherTileBody : l.grpStudentTileBody,
                    primary: teacher,
                    onTap: () => context.push(Routes.groups),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  TeacherActionTile(
                    key: const Key('teacher.results'),
                    icon: Icons.insights_outlined,
                    title: l.teacherResultsTitle,
                    body: teacher ? l.teacherResultsBody : l.teacherRoleNeeded,
                    onTap: teacher
                        ? () => context.push(Routes.teacherResults)
                        : null,
                  ),
                  const SizedBox(height: FeSpace.sm),
                  TeacherActionTile(
                    key: const Key('teacher.join'),
                    icon: Icons.qr_code_2_rounded,
                    title: l.teacherJoinTitle,
                    body: l.teacherJoinBody,
                    onTap: () => context.push(Routes.classQuiz),
                  ),
                  if (!teacher) ...[
                    const SizedBox(height: FeSpace.md),
                    FeNote(
                      key: const Key('teacher.notTeacherNote'),
                      icon: Icons.school_outlined,
                      text: l.classNotTeacherNote,
                    ),
                  ],
                  const SizedBox(height: FeSpace.md),
                  FeNote(
                    icon: Icons.privacy_tip_outlined,
                    text: l.classPrivacyNote,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Katta, oddiy amal plitasi: ikonka, sarlavha, bir qator izoh, strelka.
/// `onTap == null` — amal bu rol uchun yopiq (sababi izohda yoziladi).
class TeacherActionTile extends StatelessWidget {
  const TeacherActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;

  /// Asosiy amal — oltin tonal fon.
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final enabled = onTap != null;
    final gold = primary && enabled;
    final fg = gold ? c.onAccentContainer : c.textPrimary;
    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: FeCard(
        color: gold ? c.accentContainer : null,
        onTap: onTap,
        semanticLabel: '$title. $body',
        padding: const EdgeInsets.all(FeSpace.md),
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: gold ? c.surfaceRaised : c.accentContainer,
                    borderRadius: BorderRadius.circular(FeRadius.md),
                    border: Border.all(color: c.accentBorder),
                  ),
                  child: SizedBox.square(
                    dimension: 52,
                    child: Icon(icon, color: c.accent, size: 28),
                  ),
                ),
                const SizedBox(width: FeSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: t.titleMedium?.copyWith(
                          color: fg,
                          fontSize: 18,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: t.bodySmall?.copyWith(
                          color: gold ? c.onAccentContainer : c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (enabled) ...[
                  const SizedBox(width: FeSpace.xs),
                  Icon(Icons.chevron_right, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ustoz natijalari: o‘tkazilgan sinflar ro‘yxati; tugaganida — CSV tugmasi
/// shu yerda (bitta bosish), qator bosilsa — reyting va tafsilot.
class TeacherResultsScreen extends ConsumerWidget {
  const TeacherResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final async = ref.watch(classMySessionsProvider);
    final sessions = async.value?.value ?? const <ClassSessionInfo>[];
    final failure = async.value?.failure;
    return ClassTeacherGate(
      child: Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.teacherResultsTitle)),
        body: ListView(
          key: const Key('teacher.resultsList'),
          padding: EdgeInsets.only(
            top: FeSpace.xs,
            bottom: FeSpace.lg + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ClassDemoBanner(),
                  if (async.isLoading && async.value == null)
                    FeListSkeleton(semanticLabel: l.teacherResultsTitle)
                  else if (failure != null)
                    FeNote(
                      key: const Key('teacher.resultsError'),
                      icon: Icons.cloud_off_outlined,
                      text: classFailureText(l, failure),
                    )
                  else if (sessions.isEmpty)
                    FeEmptyState(
                      key: const Key('teacher.resultsEmpty'),
                      icon: Icons.insights_outlined,
                      body: l.teacherResultsEmpty,
                      actionLabel: l.teacherRunTitle,
                      actionIcon: Icons.play_circle_outline_rounded,
                      onAction: () => context.push(Routes.classNew),
                    )
                  else
                    for (final s in sessions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.sm),
                        child: FeCard(
                          key: Key('teacher.session.${s.id}'),
                          onTap: () => context.push(Routes.classHost(s.id)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    s.status == ClassSessionStatus.finished
                                        ? Icons.check_circle_outline
                                        : Icons.podcasts,
                                    color: c.accent,
                                  ),
                                  const SizedBox(width: FeSpace.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(s.topicTitle, style: t.titleSmall),
                                        Text(
                                          l.classSessionLine(
                                            ClassCode.display(s.code),
                                            switch (s.status) {
                                              ClassSessionStatus.lobby =>
                                                l.classStatusLobby,
                                              ClassSessionStatus.running =>
                                                l.classStatusRunning,
                                              ClassSessionStatus.finished =>
                                                l.classStatusFinished,
                                            },
                                          ),
                                          style: t.bodySmall?.copyWith(
                                            color: c.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: c.textSecondary,
                                  ),
                                ],
                              ),
                              if (s.status == ClassSessionStatus.finished) ...[
                                const SizedBox(height: FeSpace.sm),
                                OutlinedButton.icon(
                                  key: Key('teacher.csv.${s.id}'),
                                  onPressed: () =>
                                      exportClassResultsCsv(context, ref, s),
                                  icon: const ProIcon(
                                    feature: ProFeature.resultsCsv,
                                    icon: Icons.ios_share,
                                  ),
                                  label: Text(l.classExportCsv),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
