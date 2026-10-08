import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/publications.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/publications/publication_models.dart';
import '../publication_strings.dart';
import 'my_publications_screen.dart' show PublicationTimeline;
import 'publication_widgets.dart';
import 'publications_screen.dart' show disciplineLabel;

/// Moderatsiya navbati — faqat identity_admin yoki publication_moderator
/// (server `moderation_queue` boshqalarga rad etadi). Tugmalar faqat ruxsat
/// etilgan keyingi holatlar uchun; server baribir tekshiradi.
class ModerationQueueScreen extends ConsumerWidget {
  const ModerationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(moderationQueueProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.pubModeration),
        actions: [
          IconButton(
            key: const Key('moderation.refresh'),
            tooltip: l.pubReload,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(moderationQueueProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (data) {
          AsyncData(:final value?) => _Queue(q: value),
          AsyncData() || AsyncError() => FeEmptyState(
            key: const Key('moderation.forbidden'),
            icon: Icons.admin_panel_settings_outlined,
            body: l.pubForbidden,
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Queue extends ConsumerWidget {
  const _Queue({required this.q});

  final ModerationQueue q;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return ListView(
      key: const Key('moderation.queue'),
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: FeSpace.sm),
              FeBanner(icon: Icons.info_outline, text: l.pubIntro),
              const SizedBox(height: FeSpace.sm),
              if (q.items.isEmpty)
                FeEmptyState(
                  key: const Key('moderation.empty'),
                  icon: Icons.inbox_outlined,
                  body: l.pubQueueEmpty,
                ),
              for (final p in q.items) _QueueItem(p: p),
              if (q.reports.isNotEmpty) ...[
                FeSectionHeader(l.pubReports(q.reports.length)),
                for (final r in q.reports)
                  ListTile(
                    key: Key('moderation.report.${r.publicationId}'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.flag_outlined),
                    title: Text(r.title),
                    subtitle: Text(
                      [
                        l.pubReason(r.reason),
                        if (r.details != null) r.details!,
                      ].join(' · '),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ),
              ],
              const SizedBox(height: FeSpace.xl),
            ],
          ),
        ),
      ],
    );
  }
}

class _QueueItem extends ConsumerWidget {
  const _QueueItem({required this.p});

  final Publication p;

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    PublicationStatus to,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final comment = await showDialog<String>(
      context: context,
      builder: (_) => _CommentDialog(
        title: l.pubMoveTo(l.pubStatus(to)),
        required: PublicationTransitions.commentRequired(to),
      ),
    );
    if (comment == null) return;
    final r = await ref
        .read(publicationServiceProvider)
        .moderate(p.id, to, comment.isEmpty ? null : comment);
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (r) {
          ModerationResult.done => l.pubModerationDone,
          ModerationResult.forbiddenOwn => l.pubOwnArticle,
          ModerationResult.invalidTransition => l.pubInvalidTransition,
          ModerationResult.commentRequired => l.pubCommentRequired,
          ModerationResult.failed => l.pubActionFailed,
        }),
      ),
    );
    if (r == ModerationResult.done) {
      ref.invalidate(moderationQueueProvider);
      ref.invalidate(publishedPublicationsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final next = PublicationTransitions.next(
      p.status,
      PublicationActor.moderator,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: FeCard(
        key: Key('moderation.item.${p.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PublicationStatusBadge(p.status),
            const SizedBox(height: FeSpace.xxs),
            Text(p.title, style: t.titleSmall),
            Text(
              [
                if (p.disciplineCode != null)
                  disciplineLabel(l, p.disciplineCode),
                l.pubLang(p.language),
                l.pubVersion(p.version),
              ].join(' · '),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
            if (p.abstract.isNotEmpty) ...[
              const SizedBox(height: FeSpace.xxs),
              Text(p.abstract, style: t.bodySmall),
            ],
            if (p.events.isNotEmpty) PublicationTimeline(events: p.events),
            const SizedBox(height: FeSpace.xs),
            if (p.own)
              FeBanner(
                key: Key('moderation.own.${p.id}'),
                icon: Icons.person_off_outlined,
                tone: FeBannerTone.warning,
                text: l.pubOwnArticle,
              )
            else
              Wrap(
                spacing: FeSpace.xs,
                runSpacing: FeSpace.xs,
                children: [
                  for (final to in next)
                    OutlinedButton.icon(
                      key: Key('moderation.action.${p.id}.${to.wire}'),
                      onPressed: () => _move(context, ref, to),
                      icon: Icon(to.icon, size: 18),
                      label: Text(l.pubStatus(to)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CommentDialog extends StatefulWidget {
  const _CommentDialog({required this.title, required this.required});

  final String title;
  final bool required;

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ok = !widget.required || _c.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('moderation.comment'),
        controller: _c,
        maxLines: 4,
        maxLength: 4000,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: l.pubCommentLabel,
          helperText: widget.required ? l.pubRequired : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.pubCancel),
        ),
        FilledButton(
          key: const Key('moderation.confirm'),
          onPressed: ok
              ? () => Navigator.of(context).pop(_c.text.trim())
              : null,
          child: Text(l.pubConfirm),
        ),
      ],
    );
  }
}
