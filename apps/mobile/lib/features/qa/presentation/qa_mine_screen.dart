import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/qa.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/qa/qa_models.dart';
import 'qa_widgets.dart';

/// «Mening savollarim va javoblarim» — holati bilan (tekshiruvda bo‘lgani
/// ham ko‘rinadi, shunda foydalanuvchi nima bo‘lganini biladi).
class QaMineScreen extends ConsumerWidget {
  const QaMineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(qaMineProvider);
    return QaGate(
      title: l.qaMineTitle,
      child: Scaffold(
        appBar: AppBar(title: Text(l.qaMineTitle)),
        body: SafeArea(
          child: switch (async) {
            AsyncData(value: final mine?) => _body(context, l, mine),
            AsyncData() || AsyncError() => FeEmptyState(
              key: const Key('qa.mine.failed'),
              icon: Icons.cloud_off_outlined,
              body: l.qaLoadFailed,
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l, QaMine mine) {
    if (mine.questions.isEmpty && mine.answers.isEmpty) {
      return FeEmptyState(
        key: const Key('qa.mine.empty'),
        icon: Icons.forum_outlined,
        body: l.qaMineEmpty,
      );
    }
    return ListView(
      key: const Key('qa.mine'),
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (mine.questions.isNotEmpty) ...[
                FeSectionHeader(l.qaMineQuestions),
                for (final q in mine.questions) ...[
                  _MineCard(
                    item: q,
                    title: q.title ?? '',
                    subtitle: l.qaAnswersCount(q.answerCount),
                    onTap: () => context.push(Routes.qaQuestion(q.id)),
                  ),
                  const SizedBox(height: FeSpace.xs),
                ],
              ],
              if (mine.answers.isNotEmpty) ...[
                FeSectionHeader(l.qaMineAnswers),
                for (final a in mine.answers) ...[
                  _MineCard(
                    item: a,
                    title: l.qaScore(a.score),
                    subtitle: '',
                    onTap: a.questionId == null
                        ? null
                        : () => context.push(Routes.qaQuestion(a.questionId!)),
                  ),
                  const SizedBox(height: FeSpace.xs),
                ],
              ],
              const SizedBox(height: FeSpace.xxl),
            ],
          ),
        ),
      ],
    );
  }
}

class _MineCard extends StatelessWidget {
  const _MineCard({
    required this.item,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final QaMineItem item;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: Key('qa.mine.${item.id}'),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QaPostStatusChip(item.status),
          const SizedBox(height: FeSpace.xxs),
          if (title.isNotEmpty) Text(title, style: t.titleSmall),
          Wrap(
            spacing: FeSpace.xs,
            children: [
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: t.labelSmall?.copyWith(color: c.textSecondary),
                ),
              if (item.createdAt case final date?)
                Text(
                  feDate(context, date),
                  style: t.labelSmall?.copyWith(color: c.textSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
