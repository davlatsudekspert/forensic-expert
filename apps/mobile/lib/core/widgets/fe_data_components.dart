import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../design/tokens.dart';

/// PHASE 4 dizayn tizimi qo‘shimchalari: bo‘lim kartochkasi, dalil darajasi
/// belgisi, ma’lumot jadvali, skeleton va oflayn holat.
///
/// Qoidalar: ma’no faqat rangga tayanmaydi (ikonka + matn), raqamlar
/// tabular shriftda, animatsiya yo‘q (reduced motion uchun xavfsiz).

/// Sarlavhali bo‘lim kartochkasi.
class FeSectionCard extends StatelessWidget {
  const FeSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(FeRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: c.accent),
                  const SizedBox(width: FeSpace.xs),
                ],
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title, style: t.titleSmall),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: FeSpace.xs),
            child,
          ],
        ),
      ),
    );
  }
}

/// Dalil darajasi (A–E) belgisi: harf + izoh, rangga tayanmaydi.
class EvidenceLevelBadge extends StatelessWidget {
  const EvidenceLevelBadge({super.key, required this.level, this.label});

  /// `A` … `E`.
  final String level;

  /// Ekran o‘quvchisi va ko‘rinadigan matn (masalan «Evidence level B»).
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final strong = level == 'A' || level == 'B';
    return Semantics(
      label: label ?? level,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FeRadius.sm),
          border: Border.all(color: strong ? c.accent : c.borderStrong),
        ),
        child: Text(
          label ?? level,
          style: t.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: strong ? c.accent : c.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Ikki ustunli ma’lumot jadvali (nom — qiymat). Qiymatlar tabular raqamlarda.
class FeDataTable extends StatelessWidget {
  const FeDataTable({super.key, required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Table(
      columnWidths: const {0: FlexColumnWidth(3), 1: IntrinsicColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final (i, (k, v)) in rows.indexed)
          TableRow(
            decoration: BoxDecoration(
              border: i == 0 ? null : Border(top: BorderSide(color: c.border)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
                child: Text(k, style: t.bodyMedium),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: FeSpace.sm,
                  top: FeSpace.xs,
                  bottom: FeSpace.xs,
                ),
                child: Text(
                  v,
                  textAlign: TextAlign.end,
                  style: FeThemeBuilder.numeric(t.bodyMedium!),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Bibliografik / attribution metadata: yorliq ustida, qiymat ostida
/// (uzun matnlar 320 dp va katta shriftda so‘z ichida bo‘linmaydi).
class FeMetaList extends StatelessWidget {
  const FeMetaList({super.key, required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (k, v)) in rows.indexed)
          MergeSemantics(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : Border(top: BorderSide(color: c.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    k,
                    style: t.labelMedium?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.xxs),
                  SelectableText(v, style: t.bodyMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Yuklanish skeleti — statik (animatsiyasiz), ekran o‘quvchisiga
/// «yuklanmoqda» deb e’lon qilinadi.
class FeSkeleton extends StatelessWidget {
  const FeSkeleton({super.key, this.lines = 3, required this.semanticLabel});

  final int lines;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: FractionallySizedBox(
                widthFactor: i == lines - 1 ? 0.6 : 1,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: c.surfaceSunken,
                    borderRadius: BorderRadius.circular(FeRadius.sm),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Oflayn holat belgisi (kontent qurilmada; tarmoq shart emas).
class FeOfflineChip extends StatelessWidget {
  const FeOfflineChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.offline_pin_outlined, size: 16, color: c.accent),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label, style: t.labelSmall?.copyWith(color: c.accent)),
        ),
      ],
    );
  }
}
