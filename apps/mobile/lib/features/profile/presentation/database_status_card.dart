import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../core/widgets/fe_data_components.dart';
import '../../../domain/library/library_models.dart';
import '../../library/presentation/source_detail_screen.dart';

/// Oflayn baza holati (Profil → Ilova haqida): paket versiyasi, ilmiy va yurisdiksiya komponent
/// versiyalari, maxfiylik eslatmasi. Sun’iy statistika yo‘q.
class DatabaseStatusCard extends ConsumerWidget {
  const DatabaseStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final status = ref.watch(contentStatusProvider);
    final versions = ref.watch(legalCatalogProvider).componentVersions;
    final secondary = t.bodySmall?.copyWith(color: c.textSecondary);
    // Haqiqiy sonlar (oflayn bazadan); HUMAN VERIFIED — faqat inson
    // ko‘rib chiqqan claim’lar (fixture/AI/avtomatik tekshiruv emas).
    final review = ref.watch(provenanceIndexProvider).review;
    final substances = ref
        .watch(libraryRepositoryProvider)
        .entries(LibrarySection.substances)
        .length;
    final sources = ref.watch(sourceIndexProvider).length;
    final lines = status.when(
      data: (s) => s.isInstalled
          ? [
              Text(
                l.homeDbPack(s.packVersion!),
                key: const Key('about.db.pack'),
                style: FeThemeBuilder.numeric(t.bodySmall!)
                    .copyWith(color: c.textPrimary),
              ),
              if (versions['scientific'] case final v?)
                Text(l.homeDbScientific(v), style: secondary),
              if (versions['jurisdiction'] case final v?)
                Text(l.homeDbJurisdiction(v), style: secondary),
              if (review.total > 0) ...[
                const SizedBox(height: FeSpace.sm),
                _StatGrid(
                  key: const Key('about.db.counts'),
                  stats: [
                    (substances, l.homeStatSubstances, false),
                    (sources, l.homeStatSources, false),
                    (review.total, l.homeStatClaims, false),
                    // 0 bo‘lsa ko‘rsatilmaydi (urg‘u bo‘sh raqamga emas).
                    if (review.humanVerified > 0)
                      (review.humanVerified, l.homeStatHumanVerified, true),
                  ],
                ),
                const SizedBox(height: FeSpace.xs),
                Text(
                  l.homeStatPolicy,
                  key: const Key('about.db.humanVerified'),
                  style: secondary,
                ),
              ],
            ]
          : [Text(l.homeDbNotInstalled, style: secondary)],
      loading: () => [FeSkeleton(lines: 2, semanticLabel: l.homeDbLoading)],
      error: (_, _) => [Text(l.homeDbNotInstalled, style: secondary)],
    );
    return FeCard(
      key: const Key('about.database'),
      padding: const EdgeInsets.all(FeSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dataset_outlined, color: c.accent, size: 22),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(l.homeDbTitle, style: t.titleSmall),
                ),
              ),
              Icon(Icons.offline_pin_outlined, size: 18, color: c.verified),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          ...lines,
          const SizedBox(height: FeSpace.xs),
          Text(l.homeDbOffline, style: secondary),
        ],
      ),
    );
  }
}

/// Ilmiy baza raqamlari — katta tabular raqam + kichik yorliq.
class _StatGrid extends StatelessWidget {
  const _StatGrid({super.key, required this.stats});

  /// (qiymat, yorliq, alohida ta’kid — «inson tasdiqlagan»).
  final List<(int, String, bool)> stats;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, box) {
        final cols =
            box.maxWidth >= 340 &&
                MediaQuery.textScalerOf(context).scale(1) < 1.6
            ? 4
            : 2;
        final w = (box.maxWidth - FeSpace.xs * (cols - 1)) / cols;
        return Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final (value, label, emphasis) in stats)
              SizedBox(
                width: w,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: emphasis ? c.accentContainer : c.surface,
                    borderRadius: BorderRadius.circular(FeRadius.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FeSpace.xs,
                      vertical: FeSpace.sm,
                    ),
                    child: Semantics(
                      label: [label, '$value'].join(': '),
                      excludeSemantics: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$value',
                            style: FeThemeBuilder.figures(t.titleLarge!)
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: emphasis
                                      ? c.onAccentContainer
                                      : c.textPrimary,
                                ),
                          ),
                          Text(
                            label,
                            maxLines: 2,
                            style: t.labelSmall?.copyWith(
                              color: emphasis
                                  ? c.onAccentContainer
                                  : c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
