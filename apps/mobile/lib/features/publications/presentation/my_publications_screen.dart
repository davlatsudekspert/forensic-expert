import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/publications.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/publications/publication_models.dart';
import '../publication_strings.dart';
import 'publication_widgets.dart';
import 'publications_screen.dart' show disciplineLabel;

/// Muallifning o‘z maqolalari: holat belgisi, holat tarixi va moderator izohi.
class MyPublicationsScreen extends ConsumerWidget {
  const MyPublicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final signedIn = ref.watch(authStateProvider).signedIn;
    final data = ref.watch(myPublicationsProvider);
    return PublicationsGate(
      title: l.pubMine,
      child: Scaffold(
        appBar: AppBar(title: Text(l.pubMine)),
        body: SafeArea(
          child: !signedIn
              ? const Center(child: PublicationsSignInPrompt())
              : switch (data) {
                  AsyncData(:final value?) when value.isEmpty => FeEmptyState(
                    key: const Key('mine.empty'),
                    icon: Icons.article_outlined,
                    body: l.pubMineEmpty,
                  ),
                  AsyncData(:final value?) => ListView(
                    key: const Key('mine.list'),
                    children: [
                      FeContentFrame(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: FeSpace.sm),
                            const PublicationNotice(),
                            const SizedBox(height: FeSpace.sm),
                            for (final p in value) _MineCard(p: p),
                            const SizedBox(height: FeSpace.xl),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AsyncLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  _ => FeEmptyState(
                    key: const Key('mine.error'),
                    icon: Icons.cloud_off_outlined,
                    body: l.pubLoadFailed,
                  ),
                },
        ),
      ),
    );
  }
}

class _MineCard extends StatelessWidget {
  const _MineCard({required this.p});

  final Publication p;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final comment = p.lastComment;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: FeCard(
        key: Key('mine.item.${p.id}'),
        onTap: p.status == PublicationStatus.published
            ? () => context.push(Routes.publication(p.id))
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PublicationStatusBadge(p.status),
            const SizedBox(height: FeSpace.xxs),
            Text(p.title.isEmpty ? '—' : p.title, style: t.titleSmall),
            if (p.disciplineCode != null)
              Text(
                disciplineLabel(l, p.disciplineCode),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            if (comment != null) ...[
              const SizedBox(height: FeSpace.xs),
              FeBanner(
                icon: Icons.comment_outlined,
                tone: FeBannerTone.review,
                text: '${l.pubModeratorComment}: $comment',
              ),
            ],
            if (p.events.isNotEmpty) ...[
              const SizedBox(height: FeSpace.xs),
              Text(l.pubTimeline, style: t.labelMedium),
              PublicationTimeline(events: p.events),
            ],
            if (p.status.authorEditable)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  key: Key('mine.edit.${p.id}'),
                  onPressed: () =>
                      context.push(Routes.publicationSubmit, extra: p),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l.pubEdit),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Holat tarixi (har bir o‘tish serverdagi publication_events’dan).
class PublicationTimeline extends StatelessWidget {
  const PublicationTimeline({super.key, required this.events});

  final List<PublicationEvent> events;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Column(
      key: const Key('publication.timeline'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in events)
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xxs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(e.to.icon, size: 16, color: e.to.color(c)),
                const SizedBox(width: FeSpace.xs),
                Expanded(
                  child: Text(
                    [
                      l.pubStatus(e.to),
                      if (e.at != null) feDate(context, e.at!.toLocal()),
                    ].join(' · '),
                    style: t.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
