import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/moderation.dart';
import '../../../app/qa.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../qa/presentation/qa_widgets.dart';
import 'moderation_widgets.dart';

/// Bloklangan mualliflar: faqat belgi va sana — kimligi ko‘rsatilmaydi
/// (server ham mijozga bermaydi). Blokdan chiqarish mumkin.
class BlockedAuthorsScreen extends ConsumerWidget {
  const BlockedAuthorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final data = ref.watch(myBlocksProvider);
    return QaGate(
      title: l.blkTitle,
      child: Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.blkTitle)),
        body: SafeArea(
          child: switch (data) {
            AsyncData(:final value?) when value.isEmpty => ListView(
              children: [
                FeContentFrame(
                  child: FeEmptyState(
                    key: const Key('blocked.empty'),
                    icon: Icons.block,
                    body: l.blkEmpty,
                  ),
                ),
              ],
            ),
            AsyncData(:final value?) => ListView(
              key: const Key('blocked.list'),
              children: [
                FeContentFrame(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: FeSpace.sm),
                      FeBanner(icon: Icons.info_outline, text: l.blkIntro),
                      const SizedBox(height: FeSpace.sm),
                      for (final b in value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: FeSpace.xs),
                          child: FeCard(
                            key: Key('blocked.item.${b.id}'),
                            padding: const EdgeInsets.all(FeSpace.sm),
                            child: Row(
                              children: [
                                Icon(Icons.block, color: c.textSecondary),
                                const SizedBox(width: FeSpace.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(l.blkItem, style: t.titleSmall),
                                      if (b.createdAt case final d?)
                                        Text(
                                          l.blkSince(
                                            feDate(context, d.toLocal()),
                                          ),
                                          style: t.bodySmall?.copyWith(
                                            color: c.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  key: Key('blocked.unblock.${b.id}'),
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    final ok = await ref
                                        .read(moderationServiceProvider)
                                        .unblock(b.id);
                                    ref.invalidate(myBlocksProvider);
                                    ref.invalidate(qaFeedProvider);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok ? l.blkUnblocked : l.blkFailed,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(l.blkUnblock),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SupportContactLine(),
                      const SizedBox(height: FeSpace.xl),
                    ],
                  ),
                ),
              ],
            ),
            AsyncLoading() => Padding(
              padding: const EdgeInsets.all(FeSpace.md),
              child: FeListSkeleton(rows: 3, semanticLabel: l.loadingContent),
            ),
            _ => FeEmptyState(
              key: const Key('blocked.failed'),
              icon: Icons.cloud_off_outlined,
              body: l.blkFailed,
            ),
          },
        ),
      ),
    );
  }
}
