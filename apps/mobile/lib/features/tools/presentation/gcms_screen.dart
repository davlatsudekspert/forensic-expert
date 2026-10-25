import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/instruments.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/instruments/gcms_content.dart';

/// «GC-MS apparat sxemasi»: original sinf sxemasi (fotosurat emas, aniq model
/// emas) + 10 ta raqamlangan qism, ishlash tamoyili va natija. Sarlavha ostidagi
/// «sxematik tasvir» izohi rasm bilan birga doim ko‘rinadi.
class GcMsScreen extends ConsumerWidget {
  const GcMsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final content = ref.watch(gcMsProvider);
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.gcmsTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('gcms.list'),
          children: [
            FeContentFrame(
              child: content.when(
                loading: () => FeListSkeleton(semanticLabel: l.gcmsTitle),
                error: (_, _) => FeEmptyState(
                  icon: Icons.biotech_outlined,
                  body: l.gcmsUnavailable,
                ),
                data: (g) => g == null
                    ? FeEmptyState(
                        icon: Icons.biotech_outlined,
                        body: l.gcmsUnavailable,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: FeSpace.sm),
                          Text(g.title.of(lang), style: t.titleLarge),
                          const SizedBox(height: FeSpace.xs),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: StatusChip(
                              key: const Key('gcms.reviewPending'),
                              icon: Icons.hourglass_empty,
                              label: l.gcmsReviewPending,
                              color: c.warning,
                            ),
                          ),
                          const SizedBox(height: FeSpace.sm),
                          _SchematicCard(content: g, lang: lang),
                          const SizedBox(height: FeSpace.sm),
                          _PartsPanel(content: g, lang: lang),
                          if (g.tasks.isNotEmpty) ...[
                            FeSectionHeader(l.gcmsUsedFor),
                            for (final x in g.tasks)
                              Text(x.of(lang), style: t.bodyMedium),
                            const SizedBox(height: FeSpace.xs),
                            Text(
                              l.gcmsSourceLine(
                                [
                                  g.source.title,
                                  g.source.publisher,
                                ].where((s) => s.isNotEmpty).join(', '),
                              ),
                              key: const Key('gcms.source'),
                              style: t.bodySmall?.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                            if (g.source.url.isNotEmpty)
                              SelectableText(
                                g.source.url,
                                style: t.bodySmall?.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                          ],
                          const SizedBox(height: FeSpace.xl),
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

/// Rasm (och «qog‘oz» fonda, ikkala mavzuda o‘qiladi) + doim ko‘rinadigan izoh.
class _SchematicCard extends StatelessWidget {
  const _SchematicCard({required this.content, required this.lang});

  final GcMsContent content;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('gcms.schematic'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            image: true,
            button: true,
            label: content.alt.of(lang),
            hint: l.gcmsZoomHint,
            child: GestureDetector(
              key: const Key('gcms.image'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => GcMsViewer(content: content, lang: lang),
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(FeRadius.md),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
                      child: Image.asset(
                        gcMsImage1200,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                    PositionedDirectional(
                      end: 6,
                      bottom: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.surfaceRaised.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(FeRadius.sm),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.zoom_out_map,
                            size: 18,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            content.caption.of(lang),
            key: const Key('gcms.caption'),
            style: t.labelLarge,
          ),
          const SizedBox(height: 2),
          Text(
            content.note.of(lang),
            key: const Key('gcms.note'),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PartsPanel extends StatelessWidget {
  const _PartsPanel({required this.content, required this.lang});

  final GcMsContent content;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('gcms.panel'),
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(l.gcmsPanelTitle, style: t.titleSmall),
          tilePadding: const EdgeInsets.symmetric(horizontal: FeSpace.md),
          childrenPadding: const EdgeInsets.fromLTRB(
            FeSpace.md,
            0,
            FeSpace.md,
            FeSpace.md,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in content.parts)
              Padding(
                key: Key('gcms.part.${p.number}'),
                padding: const EdgeInsets.only(bottom: FeSpace.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.accentContainer,
                        borderRadius: BorderRadius.circular(FeRadius.pill),
                      ),
                      child: SizedBox.square(
                        dimension: 28,
                        child: Center(
                          child: Text(
                            '${p.number}',
                            style: t.labelLarge?.copyWith(
                              color: c.onAccentContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: FeSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name.of(lang), style: t.titleSmall),
                          Text(
                            p.function.of(lang),
                            style: t.bodyMedium?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Text(l.gcmsPrinciple, style: t.titleSmall),
            const SizedBox(height: 2),
            Text(content.principle.of(lang), style: t.bodyMedium),
            const SizedBox(height: FeSpace.sm),
            Text(l.gcmsResult, style: t.titleSmall),
            const SizedBox(height: 2),
            Text(content.result.of(lang), style: t.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// To‘liq ekran: pinch-zoom/pan; izoh va «model emas» eslatmasi bu yerda ham doim
/// ko‘rinadi.
class GcMsViewer extends StatelessWidget {
  const GcMsViewer({super.key, required this.content, required this.lang});

  final GcMsContent content;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: FeAppBarTitle(content.title.of(lang)),
        leading: IconButton(
          key: const Key('gcms.close'),
          tooltip: l.gcmsClose,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ColoredBox(
                color: const Color(0xFFFFFFFF),
                child: InteractiveViewer(
                  key: const Key('gcms.zoom'),
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: Semantics(
                      image: true,
                      label: content.alt.of(lang),
                      child: Image.asset(
                        gcMsImage1200,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(FeSpace.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(content.caption.of(lang), style: t.labelLarge),
                  Text(
                    content.note.of(lang),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
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
