import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../class_quiz/presentation/teacher_panel_screen.dart'
    show watchIsTeacher;

/// Dars oxiridagi test tugmasi (egasi qarori, 2026-10-24): jonli taxallusli
/// «Sinfda test» emas, **Guruh testi**.
///
/// 1) asosiy (ajratilgan) tugma — «Guruhga test berish»: guruh → savol soni,
///    vaqt, muddat → QR + kod ([Routes.groupLessonTest]);
/// 2) «O‘zim yechib ko‘rish» — shu qurilmada, serverga hech narsa yuborilmaydi.
/// «Sinfda test» (jonli, taxallusli) Ustoz panelida qoladi.
Future<void> showTopicTestChoice(
  BuildContext context,
  WidgetRef ref,
  String topicId,
) async {
  final l = AppLocalizations.of(context);
  // Ustoz roli bo‘lmasa guruh testi berib bo‘lmaydi — darhol o‘zi yechadi.
  if (!watchIsTeacher(ref)) {
    await context.push<void>(Routes.groupPractice(topicId));
    return;
  }
  final choice = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (c) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: FeSpace.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.grpChoiceTitle, style: Theme.of(c).textTheme.titleMedium),
            const SizedBox(height: FeSpace.sm),
            FilledButton.icon(
              key: const Key('grp.choice.group'),
              onPressed: () => c.pop(1),
              icon: const Icon(Icons.groups_outlined),
              label: Text(l.grpLessonGroupTest),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FeSpace.xs,
                FeSpace.xxs,
                FeSpace.xs,
                FeSpace.sm,
              ),
              child: Text(
                l.grpLessonGroupTestHint,
                style: Theme.of(c).textTheme.bodySmall,
              ),
            ),
            OutlinedButton.icon(
              key: const Key('grp.choice.self'),
              onPressed: () => c.pop(2),
              icon: const Icon(Icons.person_outline),
              label: Text(l.grpChoiceSelf),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FeSpace.xs,
                FeSpace.xxs,
                FeSpace.xs,
                FeSpace.md,
              ),
              child: Text(
                l.grpChoiceSelfHint,
                style: Theme.of(c).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (!context.mounted || choice == null) return;
  switch (choice) {
    case 1:
      await context.push<void>(Routes.groupLessonTest(topicId));
    case 2:
      await context.push<void>(Routes.groupPractice(topicId));
  }
}
