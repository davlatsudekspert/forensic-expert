import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/support/support_models.dart';
import '../../support/support_strings.dart';

/// Kenglikka qarab ustunlar soni (telefon 2, keng telefon 3, planshet 4).
int adminColumns(BoxConstraints box, BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(1);
  if (scale >= 1.6) return 2;
  if (box.maxWidth >= 860) return 4;
  if (box.maxWidth >= 520) return 3;
  return 2;
}

/// Statistika kartalari to‘ri.
class AdminStatGrid extends StatelessWidget {
  const AdminStatGrid({super.key, required this.items});

  final List<(IconData, String, String)> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final cols = adminColumns(box, context);
        const gap = FeSpace.xs;
        final w = (box.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (icon, value, label) in items)
              SizedBox(
                width: w,
                child: FeCard(
                  padding: const EdgeInsets.all(FeSpace.sm),
                  semanticLabel: '$label: $value',
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, size: 18, color: c.accent),
                        const SizedBox(height: FeSpace.xxs),
                        Text(
                          value,
                          style: FeThemeBuilder.numeric(t.headlineSmall!)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.labelSmall?.copyWith(color: c.textSecondary),
                        ),
                      ],
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

/// Bo‘lim kirish plitkasi (inbox, foydalanuvchilar, jurnal, moderatsiya).
class AdminNavTile extends StatelessWidget {
  const AdminNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.hint,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String title;
  final String hint;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return FeCard(
      padding: const EdgeInsets.all(FeSpace.sm),
      onTap: onTap,
      semanticLabel: '$title. $hint',
      child: ExcludeSemantics(
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.accentContainer,
                borderRadius: BorderRadius.circular(FeRadius.sm),
              ),
              child: Padding(
                padding: const EdgeInsets.all(FeSpace.xs),
                child: Icon(icon, color: c.onAccentContainer),
              ),
            ),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.titleSmall),
                  Text(
                    hint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$badge',
                  style: t.labelSmall?.copyWith(
                    color: c.onAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Icon(Icons.chevron_right, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// 14 kunlik ustunli diagramma: ro‘yxatdan o‘tish va AI savollari
/// (fl_chart’siz — oddiy vidjetlar; rang + afsona + semantik matn).
class AdminDailyChart extends StatelessWidget {
  const AdminDailyChart({super.key, required this.daily});

  final List<({String day, int signups, int ai})> daily;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final maxV = daily.fold<int>(
      1,
      (m, d) => [m, d.signups, d.ai].reduce((a, b) => a > b ? a : b),
    );
    final summary = daily
        .map((d) => '${d.day}: ${d.signups} / ${d.ai}')
        .join('; ');
    Widget legend(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: t.labelSmall),
      ],
    );
    return FeCard(
      key: const Key('admin.chart'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.admChart14d, style: t.titleSmall),
          const SizedBox(height: FeSpace.xxs),
          Wrap(
            spacing: FeSpace.sm,
            children: [
              legend(c.accent, l.admChartSignups),
              legend(c.reviewed, l.admChartAi),
            ],
          ),
          const SizedBox(height: FeSpace.sm),
          Semantics(
            label: [l.admChart14d, summary].join('. '),
            excludeSemantics: true,
            child: SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final d in daily)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _bar(d.signups / maxV, c.accent),
                                  const SizedBox(width: 1),
                                  _bar(d.ai / maxV, c.reviewed),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              d.day.length >= 10 ? d.day.substring(8) : d.day,
                              style: FeThemeBuilder.numeric(
                                t.labelSmall!,
                              ).copyWith(fontSize: 9, color: c.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _bar(double f, Color color) => Expanded(
    child: FractionallySizedBox(
      heightFactor: f <= 0 ? 0.02 : f.clamp(0.02, 1.0),
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: f <= 0 ? color.withValues(alpha: 0.25) : color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ),
    ),
  );
}

/// Turkumlar bo‘yicha gorizontal ustunlar.
class AdminCategoryBars extends StatelessWidget {
  const AdminCategoryBars({super.key, required this.counts});

  final Map<SupportCategory, int> counts;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final maxV = counts.values.fold<int>(1, (m, v) => v > m ? v : m);
    return FeCard(
      key: const Key('admin.categories'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.admByCategory, style: t.titleSmall),
          const SizedBox(height: FeSpace.xs),
          for (final cat in SupportCategory.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Semantics(
                label: [
                  l.supCategoryLabel(cat),
                  '${counts[cat] ?? 0}',
                ].join(': '),
                excludeSemantics: true,
                child: Row(
                  children: [
                    Icon(cat.icon, size: 16, color: c.textSecondary),
                    const SizedBox(width: FeSpace.xs),
                    SizedBox(
                      width: 128,
                      child: Text(
                        l.supCategoryLabel(cat),
                        style: t.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: ((counts[cat] ?? 0) / maxV).clamp(
                          0.01,
                          1.0,
                        ),
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: c.accent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: FeSpace.xs),
                    Text(
                      '${counts[cat] ?? 0}',
                      style: FeThemeBuilder.numeric(t.bodySmall!),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
