import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_groups.dart';
import '../../../app/routes.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/class_groups/class_groups_models.dart';

/// Ustoz «Mavzu testi»ni bossa — darhol o‘ziga test ochilmaydi, tanlov:
/// 1) «Guruhga topshirish» (birinchi), 2) «O‘zim yechib ko‘rish»,
/// 3) «Sinfda jonli test». Talaba uchun test guruh sahifasidan darhol ochiladi.
Future<void> showTopicTestChoice(
  BuildContext context,
  WidgetRef ref,
  String topicId,
) async {
  final l = AppLocalizations.of(context);
  final choice = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FeSpace.md),
            child: Text(
              l.grpChoiceTitle,
              style: Theme.of(c).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          ListTile(
            key: const Key('grp.choice.assign'),
            leading: const Icon(Icons.assignment_ind_outlined),
            title: Text(l.grpChoiceAssign),
            subtitle: Text(l.grpChoiceAssignHint),
            onTap: () => c.pop(1),
          ),
          ListTile(
            key: const Key('grp.choice.self'),
            leading: const Icon(Icons.person_outline),
            title: Text(l.grpChoiceSelf),
            subtitle: Text(l.grpChoiceSelfHint),
            onTap: () => c.pop(2),
          ),
          ListTile(
            key: const Key('grp.choice.live'),
            leading: const Icon(Icons.podcasts),
            title: Text(l.grpChoiceLive),
            subtitle: Text(l.grpChoiceLiveHint),
            onTap: () => c.pop(3),
          ),
          const SizedBox(height: FeSpace.sm),
        ],
      ),
    ),
  );
  if (!context.mounted || choice == null) return;
  switch (choice) {
    case 1:
      final r = await ref.read(classGroupsServiceProvider).list();
      if (!context.mounted) return;
      final groups = r.value?.teaching ?? const <GroupInfo>[];
      if (groups.isEmpty) {
        await context.push<void>(Routes.groupNew);
        return;
      }
      final gid = groups.length == 1
          ? groups.single.id
          : await showModalBottomSheet<String>(
              context: context,
              showDragHandle: true,
              builder: (c) => SafeArea(
                child: ListView(
                  key: const Key('grp.choice.groups'),
                  shrinkWrap: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FeSpace.md,
                      ),
                      child: Text(
                        l.grpChoicePickGroup,
                        style: Theme.of(c).textTheme.titleMedium,
                      ),
                    ),
                    for (final g in groups)
                      ListTile(
                        key: Key('grp.choice.group.${g.id}'),
                        leading: const Icon(Icons.groups_outlined),
                        title: Text(g.name),
                        subtitle: Text(
                          l.grpMembersCount(g.memberCount, g.memberLimit),
                        ),
                        onTap: () => c.pop(g.id),
                      ),
                  ],
                ),
              ),
            );
      if (gid == null || !context.mounted) return;
      await context.push<void>(Routes.groupAssignFor(gid, topicId));
    case 2:
      await context.push<void>(Routes.groupPractice(topicId));
    case 3:
      await context.push<void>(Routes.classNewFor(topicId));
  }
}
