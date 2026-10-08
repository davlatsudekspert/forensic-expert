import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/user_data.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';

/// Birinchi foydalanishdagi sokin yo‘l-yo‘riq: 5 ta foydali amal. Uzun
/// tutorial, ball yoki «streak» yo‘q; holat faqat qurilmada saqlanadi.
/// Hammasi bajarilsa yoki yashirilsa — karta ko‘rinmaydi.
class FirstStepsCard extends ConsumerWidget {
  const FirstStepsCard({super.key});

  static const hiddenMilestone = 'hidden';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final data = ref.watch(userDataProvider);
    if (data.milestones.contains(hiddenMilestone)) {
      return const SizedBox.shrink();
    }
    final m = data.milestones.toSet();
    final steps = <(String, IconData, String, bool, String)>[
      (
        'search',
        Icons.search,
        l.firstStepsSearch,
        data.recentSearches.isNotEmpty,
        Routes.search,
      ),
      (
        'discipline',
        Icons.category_outlined,
        l.firstStepsDiscipline,
        m.contains('discipline'),
        Routes.disciplines,
      ),
      (
        'source',
        Icons.menu_book_outlined,
        l.firstStepsSource,
        m.contains('source'),
        Routes.research,
      ),
      (
        'ai',
        Icons.auto_awesome_outlined,
        l.firstStepsAi,
        m.contains('ai'),
        Routes.ai,
      ),
      (
        'save',
        Icons.star_border,
        l.firstStepsSave,
        data.favorites.isNotEmpty,
        Routes.library,
      ),
    ];
    final done = steps.where((s) => s.$4).length;
    if (done == steps.length) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm),
      child: FeCard(
        key: const Key('home.firstSteps'),
        padding: const EdgeInsets.fromLTRB(
          FeSpace.md,
          FeSpace.sm,
          FeSpace.xs,
          FeSpace.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l.firstStepsTitle,
                      style: t.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('home.firstSteps.hide'),
                  tooltip: l.firstStepsHide,
                  icon: Icon(Icons.close, size: 20, color: c.textSecondary),
                  onPressed: () => ref
                      .read(userDataProvider.notifier)
                      .recordMilestone(hiddenMilestone),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: FeSpace.sm),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: done / steps.length),
                        duration: FeMotion.of(context, FeMotion.standard),
                        builder: (context, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 4,
                          color: c.accent,
                          backgroundColor: c.border,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: FeSpace.sm),
                  Flexible(
                    child: Text(
                      l.firstStepsProgress(done, steps.length),
                      key: const Key('home.firstSteps.progress'),
                      textAlign: TextAlign.end,
                      style: t.labelSmall?.copyWith(color: c.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FeSpace.xxs),
            for (final (id, icon, label, isDone, route) in steps)
              InkWell(
                key: Key('home.firstSteps.$id'),
                borderRadius: BorderRadius.circular(FeRadius.sm),
                onTap: () => route == Routes.ai || route == Routes.library
                    ? context.go(route)
                    : context.push(route),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: FeTouch.minTarget,
                  ),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: FeMotion.of(context, FeMotion.standard),
                        child: Icon(
                          isDone ? Icons.check_circle : icon,
                          key: ValueKey(isDone),
                          size: 20,
                          color: isDone ? c.verified : c.textSecondary,
                        ),
                      ),
                      const SizedBox(width: FeSpace.sm),
                      Expanded(
                        child: Text(
                          label,
                          style: t.bodyMedium?.copyWith(
                            color: isDone ? c.textSecondary : c.textPrimary,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: c.textSecondary,
                          ),
                        ),
                      ),
                      if (!isDone)
                        Padding(
                          padding: const EdgeInsets.only(right: FeSpace.xs),
                          child: Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: c.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
