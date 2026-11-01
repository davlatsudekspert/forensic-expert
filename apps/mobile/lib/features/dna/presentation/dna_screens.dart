import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/dna.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/fe_localizations_delegate.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/dna/dna.dart';

/// Kontent asli o‘zbekcha — yangi alifbo yoqilgan bo‘lsa o‘giriladi.
String _u(String s) => uzDisplay('uz', s);

/// ru/en interfeysda: «matn hozircha o‘zbekcha — tarjima kutilmoqda».
Widget? _pending(BuildContext context) {
  if (Localizations.localeOf(context).languageCode == 'uz') return null;
  return FeBanner(
    key: const Key('dna.translationPending'),
    icon: Icons.translate,
    text: AppLocalizations.of(context).dnaPendingTranslation,
  );
}

/// DNK bo‘limi bosh sahifasi: banner, kirish, mavzular, sudda so‘roq,
/// apparatlar.
class DnaHubScreen extends ConsumerWidget {
  const DnaHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final b = ref.watch(dnaProvider).value ?? DnaBundle.empty;
    final pending = _pending(context);
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.dnaTitle)),
      body: ListView(
        key: const Key('dna.hub'),
        padding: const EdgeInsets.only(bottom: FeSpace.xl),
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FeSpace.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(FeRadius.lg),
                  child: AspectRatio(
                    aspectRatio: 3 / 2,
                    child: ColoredBox(
                      color: const Color(0xFFF4EFE6),
                      child: Image.asset(
                        'assets/images/instruments/dna_banner.webp',
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FeSpace.sm),
                Text(l.dnaSubtitle, style: t.titleMedium),
                const SizedBox(height: FeSpace.xs),
                Text(
                  l.dnaIntro,
                  style: t.bodyMedium?.copyWith(color: c.textSecondary),
                ),
                if (pending != null) ...[
                  const SizedBox(height: FeSpace.sm),
                  pending,
                ],
                if (b.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: FeSpace.lg),
                    child: FeEmptyState(
                      icon: Icons.biotech_outlined,
                      body: l.equipEmpty,
                    ),
                  )
                else ...[
                  FeSectionHeader(l.dnaTopics),
                  for (final tp in b.topics)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                      child: FeCard(
                        key: Key('dna.topic.${tp.id}'),
                        padding: const EdgeInsets.all(FeSpace.sm),
                        onTap: () => context.push(Routes.dnaTopic(tp.id)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_u(tp.title), style: t.titleSmall),
                                  const SizedBox(height: 2),
                                  Text(
                                    l.dnaStatementCount(tp.statements.length),
                                    style: t.bodySmall?.copyWith(
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: c.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  if (b.court.isNotEmpty) ...[
                    FeSectionHeader(l.dnaCourt),
                    FeCard(
                      key: const Key('dna.court'),
                      padding: const EdgeInsets.all(FeSpace.sm),
                      onTap: () => context.push(Routes.dnaCourt),
                      child: Row(
                        children: [
                          Icon(Icons.gavel_outlined, color: c.accent),
                          const SizedBox(width: FeSpace.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.dnaCourtIntro, style: t.bodyMedium),
                                const SizedBox(height: 2),
                                Text(
                                  l.dnaCourtCount(b.court.length),
                                  style: t.bodySmall?.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: c.textSecondary),
                        ],
                      ),
                    ),
                  ],
                  FeSectionHeader(l.dnaEquipment),
                  FeCard(
                    key: const Key('dna.equipment'),
                    padding: const EdgeInsets.all(FeSpace.sm),
                    onTap: () => context.push(Routes.equipmentGroup('lab')),
                    child: Row(
                      children: [
                        for (final (i, id) in const [
                          'dna_thermocycler',
                          'dna_genetic_analyzer',
                          'dna_laminar',
                        ].indexed) ...[
                          if (i > 0) const SizedBox(width: FeSpace.xs),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(FeRadius.md),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  'assets/images/instruments/$id.webp',
                                  fit: BoxFit.cover,
                                  excludeFromSemantics: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: FeSpace.xs),
                  Text(
                    l.equipIllustrationNote,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mavzu: manbali bayonlar ro‘yxati; har birida manba va «Asl matn».
class DnaTopicScreen extends ConsumerWidget {
  const DnaTopicScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final b = ref.watch(dnaProvider).value ?? DnaBundle.empty;
    final tp = b.topic(id);
    final pending = _pending(context);
    return Scaffold(
      appBar: AppBar(
        title: FeAppBarTitle(tp == null ? l.dnaTitle : _u(tp.title)),
      ),
      body: tp == null
          ? FeEmptyState(icon: Icons.biotech_outlined, body: l.equipEmpty)
          : ListView(
              key: Key('dna.topicView.$id'),
              padding: const EdgeInsets.only(bottom: FeSpace.xl),
              children: [
                FeContentFrame(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: FeSpace.sm),
                      if (pending != null) ...[
                        pending,
                        const SizedBox(height: FeSpace.sm),
                      ],
                      for (final g in tp.images) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(FeRadius.md),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 320),
                            child: Image.asset(
                              g.image,
                              fit: BoxFit.contain,
                              semanticLabel: _u(g.caption),
                            ),
                          ),
                        ),
                        const SizedBox(height: FeSpace.xxs),
                        Text(
                          _u(g.caption),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: FeSpace.sm),
                      ],
                      if (tp.images.isNotEmpty) ...[
                        Text(
                          l.equipIllustrationNote,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: FeSpace.sm),
                      ],
                      for (final (i, s) in tp.statements.indexed)
                        _StatementCard(
                          key: Key('dna.statement.$id.$i'),
                          text: s.uz,
                          quote: s.quote,
                          source: s.source,
                          locator: s.locator,
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Sudda so‘roq: savol → javob → ekspert aytmaydigan narsa → manba.
class DnaCourtScreen extends ConsumerWidget {
  const DnaCourtScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final b = ref.watch(dnaProvider).value ?? DnaBundle.empty;
    final pending = _pending(context);
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.dnaCourt)),
      body: ListView(
        key: const Key('dna.courtView'),
        padding: const EdgeInsets.only(bottom: FeSpace.xl),
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FeSpace.sm),
                Text(
                  l.dnaCourtIntro,
                  style: t.bodyMedium?.copyWith(color: c.textSecondary),
                ),
                if (pending != null) ...[
                  const SizedBox(height: FeSpace.sm),
                  pending,
                ],
                const SizedBox(height: FeSpace.sm),
                for (final (i, q) in b.court.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: FeSpace.sm),
                    child: FeCard(
                      key: Key('dna.q.$i'),
                      padding: const EdgeInsets.all(FeSpace.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l.dnaQuestionNumbered(i + 1, _u(q.q)),
                            style: t.titleSmall,
                          ),
                          const SizedBox(height: FeSpace.xs),
                          Text(
                            l.dnaAnswer,
                            style: t.labelMedium?.copyWith(color: c.accent),
                          ),
                          Text(_u(q.answer), style: t.bodyMedium),
                          if (q.boundary.isNotEmpty) ...[
                            const SizedBox(height: FeSpace.xs),
                            Text(
                              l.dnaBoundary,
                              style: t.labelMedium?.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                            Text(_u(q.boundary), style: t.bodyMedium),
                          ],
                          const SizedBox(height: FeSpace.xs),
                          _SourceLine(source: q.source, locator: q.locator),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatementCard extends StatelessWidget {
  const _StatementCard({
    super.key,
    required this.text,
    required this.quote,
    required this.source,
    required this.locator,
  });

  final String text;
  final String quote;
  final DnaSource source;
  final String locator;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: FeCard(
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_u(text), style: t.bodyLarge),
            const SizedBox(height: FeSpace.xs),
            _SourceLine(source: source, locator: locator),
            if (quote.isNotEmpty)
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  dense: true,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: FeSpace.xs),
                  expandedAlignment: AlignmentDirectional.centerStart,
                  title: Text(
                    l.dnaQuote,
                    style: t.labelMedium?.copyWith(color: c.textSecondary),
                  ),
                  children: [
                    // Asl iqtibos — dalil: o‘zgartirilmaydi, o‘z tilida.
                    Text(
                      '«$quote»',
                      style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.source, required this.locator});

  final DnaSource source;
  final String locator;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final parts = [
      source.citation,
      locator,
      if (source.doi.isNotEmpty) 'DOI ${source.doi}',
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.menu_book_outlined, size: 14, color: c.accent),
        ),
        const SizedBox(width: FeSpace.xs),
        Expanded(
          child: Text(
            parts.join(' · '),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}
