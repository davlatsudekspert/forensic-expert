import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_groups.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_groups/class_groups_models.dart';
import '../../class_quiz/presentation/class_quiz_widgets.dart' show ClassQr;
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'group_widgets.dart';

/// Katta sarlavha AppBar’ga o‘tadigan nuqta (px).
const double kGroupTitleCollapseAt = 56;

/// Sarlavha ko‘rinishi faqat ro‘yxat chegarasi ICHIDAGI pozitsiyadan
/// hisoblanadi: iOS bounce (overscroll) uni o‘zgartirmaydi va sarlavha
/// layout balandligini o‘zgartirmaydi (AppBar balandligi doimiy) — shuning
/// uchun kontent «qaytib tushmaydi».
bool groupTitleCollapsed(ScrollMetrics m) =>
    m.pixels.clamp(m.minScrollExtent, m.maxScrollExtent) >
    kGroupTitleCollapseAt;

/// Guruh sahifasi. Ustoz: taklif QR/kodi, «Mavzu testi berish», testlar va
/// a’zolar. Talaba: o‘z taxallusi va testlari (holati bilan).
class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailState();
}

class _GroupDetailState extends ConsumerState<GroupDetailScreen> {
  final _collapsed = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _collapsed.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
      _collapsed.value = groupTitleCollapsed(n.metrics);
    }
    return false;
  }

  Future<void> _remove(GroupDetail d, GroupMember m) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.grpRemoveTitle),
        content: Text(l.grpRemoveBody(m.nickname)),
        actions: [
          TextButton(onPressed: () => c.pop(false), child: Text(l.grpCancel)),
          FilledButton(
            key: const Key('grp.removeYes'),
            onPressed: () => c.pop(true),
            child: Text(l.grpRemoveAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final r = await ref
        .read(classGroupsServiceProvider)
        .removeMember(d.group.id, m.id);
    if (!r.ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(groupFailureText(l, r.failure!))),
      );
    }
    ref.invalidate(groupDetailProvider(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(groupDetailProvider(widget.groupId));
    final d = async.value?.value;
    final failure = async.value?.failure;
    final t = Theme.of(context).textTheme;

    final List<Widget> body;
    if (d != null) {
      body = [
        Text(
          d.group.name,
          key: const Key('grp.largeTitle'),
          style: t.headlineSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: FeSpace.xxs),
        if (d.isTeacher)
          ..._teacher(context, l, d)
        else
          ..._student(context, l, d),
      ];
    } else if (failure != null) {
      body = [
        FeEmptyState(
          key: const Key('grp.detailError'),
          icon: failure == GroupFailure.forbidden
              ? Icons.lock_outline
              : Icons.cloud_off_outlined,
          body: groupFailureText(l, failure),
          actionLabel: l.grpRetry,
          onAction: () => ref.invalidate(groupDetailProvider(widget.groupId)),
        ),
      ];
    } else {
      body = [FeListSkeleton(semanticLabel: l.grpTitle)];
    }

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<bool>(
          valueListenable: _collapsed,
          builder: (context, collapsed, _) => AnimatedOpacity(
            key: const Key('grp.appBarTitle'),
            opacity: collapsed ? 1 : 0,
            duration: FeMotion.fast,
            child: FeAppBarTitle(d?.group.name ?? l.grpTitle),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(groupDetailProvider(widget.groupId)),
          child: ListView(
            key: const Key('grp.detailList'),
            padding: EdgeInsets.only(
              top: FeSpace.xs,
              bottom: FeSpace.xl + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [const GroupDemoBanner(), ...body],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _teacher(
    BuildContext context,
    AppLocalizations l,
    GroupDetail d,
  ) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final code = d.group.code ?? '';
    return [
      Text(
        l.grpMembersCount(d.group.memberCount, d.group.memberLimit),
        style: t.bodyMedium?.copyWith(color: c.textSecondary),
      ),
      const SizedBox(height: FeSpace.md),
      FilledButton.icon(
        key: const Key('grp.assignButton'),
        onPressed: () => context.push(Routes.groupAssign(d.group.id)),
        icon: const Icon(Icons.assignment_add),
        label: Text(l.grpAssignAction),
      ),
      const SizedBox(height: FeSpace.md),
      FeCard(
        key: const Key('grp.invitePanel'),
        child: Row(
          children: [
            ClassQr(data: GroupCode.link(code).toString(), size: 96),
            const SizedBox(width: FeSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.grpInviteTitle, style: t.titleSmall),
                  const SizedBox(height: FeSpace.xxs),
                  GroupCodeText(code: code, fontSize: 24),
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    l.grpInviteHint,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  TextButton.icon(
                    key: const Key('grp.copyCode'),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await Clipboard.setData(ClipboardData(text: code));
                      messenger.showSnackBar(
                        SnackBar(content: Text(l.grpCodeCopied)),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: Text(l.grpCopyCode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      FeSectionHeader(l.grpTestsSection),
      if (d.assignments.isEmpty)
        FeEmptyState(
          icon: Icons.assignment_outlined,
          body: l.grpTestsEmptyTeacher,
          compact: true,
        ),
      for (final a in d.assignments)
        Padding(
          padding: const EdgeInsets.only(bottom: FeSpace.xs),
          child: FeCard(
            key: Key('grp.assignment.${a.id}'),
            // Jonli panel shell ichida; guruh sahifasidan `push` — bir marta.
            onTap: () => context.push(Routes.groupAssignment(d.group.id, a.id)),
            child: Row(
              children: [
                Icon(
                  a.closed ? Icons.check_circle_outline : Icons.podcasts,
                  color: c.accent,
                ),
                const SizedBox(width: FeSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.topicTitle, style: t.titleSmall),
                      Text(
                        groupAssignmentLine(context, l, a),
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                      Text(
                        a.closed
                            ? l.grpClosedProgress(
                                a.finished,
                                d.group.memberCount,
                              )
                            : l.grpProgress(
                                a.started,
                                a.finished,
                                d.group.memberCount,
                              ),
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.textSecondary),
              ],
            ),
          ),
        ),
      FeSectionHeader(l.grpMembersSection),
      if (d.members.isEmpty)
        FeEmptyState(
          icon: Icons.groups_outlined,
          body: l.grpMembersEmpty,
          compact: true,
        ),
      for (final m in d.members)
        ListTile(
          key: Key('grp.member.${m.id}'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: Text(m.nickname),
          trailing: IconButton(
            tooltip: l.grpRemoveAction,
            icon: const Icon(Icons.person_remove_outlined),
            onPressed: () => _remove(d, m),
          ),
        ),
      const SizedBox(height: FeSpace.md),
      FeNote(icon: Icons.privacy_tip_outlined, text: l.grpPrivacyNote),
    ];
  }

  List<Widget> _student(
    BuildContext context,
    AppLocalizations l,
    GroupDetail d,
  ) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return [
      Text(
        l.grpMyNickname(d.nickname ?? ''),
        key: const Key('grp.myNickname'),
        style: t.bodyMedium?.copyWith(color: c.textSecondary),
      ),
      FeSectionHeader(l.grpTestsSection),
      if (d.assignments.isEmpty)
        FeEmptyState(
          icon: Icons.assignment_outlined,
          body: l.grpTestsEmptyStudent,
          compact: true,
        ),
      for (final a in d.assignments)
        Padding(
          padding: const EdgeInsets.only(bottom: FeSpace.xs),
          child: FeCard(
            key: Key('grp.myAssignment.${a.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(a.topicTitle, style: t.titleSmall),
                Text(
                  groupAssignmentLine(context, l, a),
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: FeSpace.xs),
                _studentAction(context, l, d, a),
              ],
            ),
          ),
        ),
      const SizedBox(height: FeSpace.md),
      OutlinedButton.icon(
        key: const Key('grp.leave'),
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: Text(l.grpLeaveTitle),
              content: Text(l.grpLeaveBody),
              actions: [
                TextButton(
                  onPressed: () => c.pop(false),
                  child: Text(l.grpCancel),
                ),
                FilledButton(
                  onPressed: () => c.pop(true),
                  child: Text(l.grpLeaveAction),
                ),
              ],
            ),
          );
          if (ok != true || !context.mounted) return;
          await ref.read(classGroupsServiceProvider).leave(d.group.id);
          ref.invalidate(groupListProvider);
          if (context.mounted) context.go(Routes.groups);
        },
        icon: const Icon(Icons.logout),
        label: Text(l.grpLeaveAction),
      ),
      const SizedBox(height: FeSpace.md),
      FeNote(icon: Icons.privacy_tip_outlined, text: l.grpPrivacyNote),
    ];
  }

  Widget _studentAction(
    BuildContext context,
    AppLocalizations l,
    GroupDetail d,
    GroupAssignment a,
  ) {
    final now = ref.read(groupNowProvider)();
    final pastDue = a.dueAt != null && !now.isBefore(a.dueAt!);
    switch (a.myState) {
      case MyTestState.finished:
        return OutlinedButton.icon(
          key: Key('grp.result.${a.id}'),
          onPressed: () => context.push(Routes.groupResult(d.group.id, a.id)),
          icon: const Icon(Icons.insights_outlined),
          label: Text(l.grpMyScore(a.myScore ?? 0, a.myTotal ?? 0)),
        );
      case MyTestState.solving:
        return FilledButton.icon(
          key: Key('grp.continue.${a.id}'),
          onPressed: () => context.push(Routes.groupTest(d.group.id, a.id)),
          icon: const Icon(Icons.play_arrow),
          label: Text(l.grpContinueTest),
        );
      case MyTestState.notStarted:
        if (a.closed || pastDue) {
          return Text(
            a.closed ? l.grpErrClosed : l.grpErrPastDue,
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        return FilledButton.icon(
          key: Key('grp.start.${a.id}'),
          onPressed: () => context.push(Routes.groupTest(d.group.id, a.id)),
          icon: const Icon(Icons.play_arrow),
          label: Text(l.grpStartTest),
        );
    }
  }
}
