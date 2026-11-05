import 'package:flutter/material.dart';

import '../../core/design/theme.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/fe_components.dart';

/// Kirish kartasi: ikonka | nom + izoh | [belgi] | strelka. Barcha rollarda
/// bir xil dizayn (navy/cream/gold). `onTap == null` — bosilmaydigan holat.
class EntryTile extends StatelessWidget {
  const EntryTile({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? body;

  /// Holat belgisi (masalan, «Tayyorlanmoqda»).
  final Widget? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      onTap: onTap,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.accentContainer,
              borderRadius: BorderRadius.circular(FeRadius.md),
            ),
            child: SizedBox.square(
              dimension: 44,
              child: Icon(icon, color: c.accent, size: 22),
            ),
          ),
          const SizedBox(width: FeSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleSmall),
                if (body case final b?) ...[
                  const SizedBox(height: 2),
                  Text(b, style: t.bodySmall?.copyWith(color: c.textSecondary)),
                ],
                if (badge case final bd?) ...[
                  const SizedBox(height: FeSpace.xxs),
                  bd,
                ],
              ],
            ),
          ),
          if (onTap != null) Icon(Icons.chevron_right, color: c.textSecondary),
        ],
      ),
    );
  }
}

/// Kichik holat belgisi (chip): mavjud / qisman / tayyorlanmoqda.
class StateChip extends StatelessWidget {
  const StateChip({super.key, required this.label, required this.tone});

  final String label;

  /// 0 — mavjud (oltin), 1 — qisman, 2 — tayyorlanmoqda (xira).
  final int tone;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final fg = tone == 0
        ? c.accent
        : tone == 1
        ? c.textPrimary
        : c.textSecondary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone == 0 ? c.accentContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(FeRadius.sm),
        border: Border.all(color: tone == 0 ? c.accent : c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(label, style: t.labelSmall?.copyWith(color: fg)),
      ),
    );
  }
}
