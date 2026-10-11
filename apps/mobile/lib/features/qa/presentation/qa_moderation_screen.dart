import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/account.dart';
import '../../../app/qa.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/qa/qa_models.dart';
import '../qa_strings.dart';
import 'qa_widgets.dart';

/// Admin moderatsiya navbati: tekshiruvdagi savollar va javoblar, hamda
/// to‘xtatilgan belgilar. Vakolat serverda tekshiriladi — bu ekran faqat
/// ko‘rinishni boshqaradi.
class QaModerationScreen extends ConsumerStatefulWidget {
  const QaModerationScreen({super.key});

  @override
  ConsumerState<QaModerationScreen> createState() => _QaModerationScreenState();
}

class _QaModerationScreenState extends ConsumerState<QaModerationScreen> {
  String? _message;

  Future<void> _act(
    QaModerationAction action,
    QaTargetType target,
    String id,
  ) async {
    final l = AppLocalizations.of(context);
    final ok = await ref
        .read(qaServiceProvider)
        .moderate(action: action, target: target, id: id);
    if (!mounted) return;
    setState(() => _message = ok ? l.qaActionDone : l.qaActionFailed);
    ref.invalidate(qaModerationQueueProvider);
    ref.invalidate(qaFeedProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAdmin = ref.watch(serverAccessProvider).value?.isAdmin ?? false;
    final async = ref.watch(qaModerationQueueProvider);
    return QaGate(
      title: l.qaModerationTitle,
      child: Scaffold(
        appBar: AppBar(title: Text(l.qaModerationTitle)),
        body: SafeArea(
          child: !isAdmin
              ? FeEmptyState(
                  key: const Key('qa.moderation.adminOnly'),
                  icon: Icons.lock_outline,
                  body: l.qaAdminOnly,
                )
              : switch (async) {
                  AsyncData(value: final q?) => _body(context, l, q),
                  AsyncData() || AsyncError() => FeEmptyState(
                    key: const Key('qa.moderation.failed'),
                    icon: Icons.cloud_off_outlined,
                    body: l.qaLoadFailed,
                  ),
                  _ => const Center(child: CircularProgressIndicator()),
                },
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l,
    QaModerationQueue queue,
  ) {
    if (queue.isEmpty) {
      return FeEmptyState(
        key: const Key('qa.moderation.empty'),
        icon: Icons.inbox_outlined,
        body: l.qaModerationEmpty,
      );
    }
    return ListView(
      key: const Key('qa.moderation'),
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_message != null) ...[
                const SizedBox(height: FeSpace.sm),
                Text(_message!, key: const Key('qa.moderation.message')),
              ],
              if (queue.questions.isNotEmpty) ...[
                FeSectionHeader(l.qaModerationQuestions),
                for (final p in queue.questions) ...[
                  _FlaggedCard(
                    post: p,
                    target: QaTargetType.question,
                    onAction: _act,
                    allowPin: true,
                  ),
                  const SizedBox(height: FeSpace.xs),
                ],
              ],
              if (queue.answers.isNotEmpty) ...[
                FeSectionHeader(l.qaModerationAnswers),
                for (final p in queue.answers) ...[
                  _FlaggedCard(
                    post: p,
                    target: QaTargetType.answer,
                    onAction: _act,
                    allowPin: false,
                  ),
                  const SizedBox(height: FeSpace.xs),
                ],
              ],
              if (queue.suspended.isNotEmpty) ...[
                FeSectionHeader(l.qaModerationSuspended),
                for (final s in queue.suspended) ...[
                  _SuspendedCard(profile: s, onAction: _act),
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

typedef _Act = Future<void> Function(
  QaModerationAction action,
  QaTargetType target,
  String id,
);

class _FlaggedCard extends StatelessWidget {
  const _FlaggedCard({
    required this.post,
    required this.target,
    required this.onAction,
    required this.allowPin,
  });

  final QaFlaggedPost post;
  final QaTargetType target;
  final _Act onAction;
  final bool allowPin;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: Key('qa.moderation.${post.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xxs,
            children: [
              QaPostStatusChip(post.status),
              if (post.reports > 0)
                StatusChip(
                  icon: Icons.flag_outlined,
                  label: l.qaReportsCount(post.reports),
                  color: c.danger,
                ),
            ],
          ),
          const SizedBox(height: FeSpace.xxs),
          if (post.title case final title?)
            if (title.isNotEmpty) Text(title, style: t.titleSmall),
          Text(post.body, style: t.bodySmall),
          if (post.flags.isNotEmpty) ...[
            const SizedBox(height: FeSpace.xs),
            QaFlagsNotice(post.flags),
          ],
          const SizedBox(height: FeSpace.xs),
          Wrap(
            spacing: FeSpace.xs,
            children: [
              FilledButton(
                key: Key('qa.moderation.publish.${post.id}'),
                onPressed: () =>
                    onAction(QaModerationAction.publish, target, post.id),
                child: Text(l.qaActionPublish),
              ),
              OutlinedButton(
                key: Key('qa.moderation.remove.${post.id}'),
                onPressed: () =>
                    onAction(QaModerationAction.remove, target, post.id),
                child: Text(l.qaActionRemove),
              ),
              if (allowPin)
                TextButton(
                  key: Key('qa.moderation.pin.${post.id}'),
                  onPressed: () =>
                      onAction(QaModerationAction.pin, target, post.id),
                  child: Text(l.qaActionPin),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuspendedCard extends StatelessWidget {
  const _SuspendedCard({required this.profile, required this.onAction});

  final QaSuspendedProfile profile;
  final _Act onAction;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: Key('qa.moderation.user.${profile.userId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ism va email yo‘q — serverda ham saqlanmaydi.
          Text(
            [
              if (profile.role case final r?) l.qaRole(r),
              ?profile.countryCode,
            ].join(' · '),
            style: t.titleSmall,
          ),
          if (l.qaReasonText(profile.reason) case final reason?)
            Text(reason, style: t.bodySmall),
          const SizedBox(height: FeSpace.xs),
          Wrap(
            spacing: FeSpace.xs,
            children: [
              FilledButton(
                key: Key('qa.moderation.reinstate.${profile.userId}'),
                onPressed: () => onAction(
                  QaModerationAction.reinstate,
                  QaTargetType.user,
                  profile.userId,
                ),
                child: Text(l.qaActionReinstate),
              ),
              OutlinedButton(
                key: Key('qa.moderation.suspend.${profile.userId}'),
                onPressed: () => onAction(
                  QaModerationAction.suspend,
                  QaTargetType.user,
                  profile.userId,
                ),
                child: Text(l.qaActionSuspend),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
