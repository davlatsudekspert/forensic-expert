import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/plan.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../core/widgets/score_grade.dart';
import '../../../domain/admin/admin_class_tests.dart';
import '../../../domain/grading/grade_scale.dart';
import '../../../domain/ports/plan_ports.dart';
import 'admin_gate.dart';

/// Admin: o‘tkazilgan testlar ro‘yxati (qidiruv bo‘yicha).
final adminClassTestsProvider = FutureProvider.autoDispose
    .family<PlanResult<List<AdminClassTest>>, String>(
      (ref, q) => ref.watch(adminPlanServiceProvider).classTests(query: q),
    );

/// Bitta test natijalari.
final adminClassTestDetailProvider = FutureProvider.autoDispose
    .family<PlanResult<List<AdminClassTestResult>>, AdminClassTest>(
      (ref, t) =>
          ref.watch(adminPlanServiceProvider).classTestDetail(t.kind, t.id),
    );

String _when(BuildContext context, DateTime? at) {
  if (at == null) return '';
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  return '${feDate(context, at)}, $hh:$mm';
}

/// «O‘tkazilgan testlar»: sana, ustoz, guruh, mavzu, qatnashganlar,
/// o‘rtacha ball (100) va baho. Server faqat identity_admin’ga beradi.
class AdminClassTestsScreen extends ConsumerStatefulWidget {
  const AdminClassTestsScreen({super.key});

  @override
  ConsumerState<AdminClassTestsScreen> createState() =>
      _AdminClassTestsScreenState();
}

class _AdminClassTestsScreenState extends ConsumerState<AdminClassTestsScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(adminClassTestsProvider(_query));
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(
          title: FeAppBarTitle(l.admTestsTitle),
          actions: [
            IconButton(
              key: const Key('adminTests.refresh'),
              tooltip: l.admTestsRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(adminClassTestsProvider(_query)),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            key: const Key('adminTests.list'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      key: const Key('adminTests.search'),
                      controller: _search,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) => setState(() => _query = v.trim()),
                      decoration: InputDecoration(
                        hintText: l.admTestsSearch,
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    switch (data) {
                      AsyncData(:final value) when value.ok =>
                        value.value!.isEmpty
                            ? FeEmptyState(
                                key: const Key('adminTests.empty'),
                                compact: true,
                                icon: Icons.quiz_outlined,
                                body: l.admTestsEmpty,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final t in value.value!)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: FeSpace.sm,
                                      ),
                                      child: _TestCard(test: t),
                                    ),
                                ],
                              ),
                      AsyncData(:final value) => FeEmptyState(
                        key: const Key('adminTests.error'),
                        compact: true,
                        icon: Icons.cloud_off_outlined,
                        body: value.failure == PlanFailure.forbidden
                            ? l.admNotAuthorized
                            : l.admProError,
                        actionLabel: l.admTestsRefresh,
                        onAction: () =>
                            ref.invalidate(adminClassTestsProvider(_query)),
                      ),
                      AsyncError() => FeEmptyState(
                        key: const Key('adminTests.error'),
                        compact: true,
                        icon: Icons.cloud_off_outlined,
                        body: l.admProError,
                      ),
                      _ => FeListSkeleton(
                        rows: 4,
                        semanticLabel: l.loadingContent,
                      ),
                    },
                    const SizedBox(height: FeSpace.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  const _TestCard({required this.test});

  final AdminClassTest test;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final live = test.kind == AdminClassTestKind.live;
    final avg = test.avgScore100;
    return FeCard(
      key: Key('adminTests.item.${test.id}'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AdminClassTestDetailScreen(test: test),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                live ? Icons.bolt_outlined : Icons.groups_outlined,
                size: 18,
                color: c.accent,
              ),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Text(
                  live ? l.admTestsKindLive : l.admTestsKindAssignment,
                  style: t.labelLarge?.copyWith(color: c.accent),
                ),
              ),
              Text(
                _when(context, test.at),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            test.topicTitle,
            style: t.titleSmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: FeSpace.xxs),
          Text(
            l.admTestsTeacher(test.teacherName),
            style: t.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (test.groupName case final g?)
            Text(l.admTestsGroup(g), style: t.bodyMedium),
          if (test.code case final code? when live)
            Text(l.admTestsCode(code), style: t.bodySmall),
          const SizedBox(height: FeSpace.xs),
          Wrap(
            spacing: FeSpace.sm,
            runSpacing: FeSpace.xxs,
            children: [
              Text(
                l.admTestsQuestions(test.questionCount),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              Text(
                live
                    ? l.admTestsJoined(test.participants)
                    : l.admTestsFinished(test.finished, test.participants),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xxs),
          Text(
            avg == null
                ? l.admTestsNoAvg
                : l.admTestsAvg(
                    GradeScale.format((avg * 10).round()),
                    pfGradeText(l, GradeScale.gradeOf(avg)),
                  ),
            key: Key('adminTests.avg.${test.id}'),
            style: t.titleSmall?.copyWith(
              color: avg == null ? c.textSecondary : c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bitta test: talabalar laqabi, ball (100) va baho.
class AdminClassTestDetailScreen extends ConsumerWidget {
  const AdminClassTestDetailScreen({super.key, required this.test});

  final AdminClassTest test;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final data = ref.watch(adminClassTestDetailProvider(test));
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.admTestsResultsTitle)),
        body: SafeArea(
          child: ListView(
            key: const Key('adminTests.detail'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    Text(test.topicTitle, style: t.titleMedium),
                    const SizedBox(height: FeSpace.xxs),
                    Text(
                      l.admTestsTeacher(test.teacherName),
                      style: t.bodyMedium,
                    ),
                    if (test.groupName case final g?)
                      Text(l.admTestsGroup(g), style: t.bodyMedium),
                    Text(
                      _when(context, test.at),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                    FeSectionHeader(l.admTestsResultsTitle),
                    switch (data) {
                      AsyncData(:final value) when value.ok =>
                        value.value!.isEmpty
                            ? FeEmptyState(
                                key: const Key('adminTests.detailEmpty'),
                                compact: true,
                                icon: Icons.person_off_outlined,
                                body: l.admTestsNoStudents,
                              )
                            : FeCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: FeSpace.md,
                                  vertical: FeSpace.xs,
                                ),
                                child: Column(
                                  children: [
                                    for (final (i, r)
                                        in value.value!.indexed) ...[
                                      if (i > 0) const Divider(height: 1),
                                      _ResultRow(index: i, row: r),
                                    ],
                                  ],
                                ),
                              ),
                      AsyncData() || AsyncError() => FeEmptyState(
                        key: const Key('adminTests.detailError'),
                        compact: true,
                        icon: Icons.cloud_off_outlined,
                        body: l.admProError,
                      ),
                      _ => FeListSkeleton(
                        rows: 5,
                        semanticLabel: l.loadingContent,
                      ),
                    },
                    const SizedBox(height: FeSpace.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.index, required this.row});

  final int index;
  final AdminClassTestResult row;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final r = row.done ? GradeScale.of(row.correct!, row.total!) : null;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: FeTouch.minTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text((index + 1).toString(), style: t.bodySmall),
            ),
            Expanded(
              flex: 4,
              child: Text(
                row.nickname,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: FeSpace.xs),
            Expanded(
              flex: 5,
              child: Text(
                r == null
                    ? l.admTestsNotDone
                    : l.scoringRowLine(r.text, pfGradeText(l, r.grade)),
                key: r == null ? null : Key('adminTests.row.$index'),
                textAlign: TextAlign.end,
                style: r == null
                    ? t.bodySmall?.copyWith(color: c.textSecondary)
                    : t.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
