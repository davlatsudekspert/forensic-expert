import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../l10n/generated/app_localizations.dart';
import 'fe_components.dart';

/// Pro qulf kartasi: qulf belgisi + bir jumla foyda + «Pro bilan ochish».
/// Funksiya yashirilmaydi — o‘z joyida ko‘rinadi, lekin qulfli (egasi qarori,
/// 2026-10-24). Xavfsizlik, manba va provenance uchun hech qachon
/// ishlatilmaydi.
class ProLockCard extends StatelessWidget {
  const ProLockCard({
    super.key,
    required this.benefit,
    required this.planName,
    required this.onUnlock,
    this.compact = false,
  });

  /// Bir jumla foyda («Barcha 211 prezentatsiya»).
  final String benefit;

  /// Reja nomi («Ustoz Pro»).
  final String planName;
  final VoidCallback onUnlock;

  /// Ro‘yxat ichidagi ixcham ko‘rinish (tugmasiz — kartaning o‘zi bosiladi).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final icon = DecoratedBox(
      decoration: BoxDecoration(
        color: c.accentContainer,
        shape: BoxShape.circle,
        border: Border.all(color: c.accentBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FeSpace.xs + 2),
        child: Icon(Icons.lock_outline, size: 20, color: c.accent),
      ),
    );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(planName, style: t.labelSmall?.copyWith(color: c.accent)),
        const SizedBox(height: 2),
        Text(benefit, style: t.titleSmall),
      ],
    );
    return FeCard(
      onTap: compact ? onUnlock : null,
      semanticLabel: '${l.proUnlock}. $planName. $benefit',
      child: compact
          ? Row(
              children: [
                icon,
                const SizedBox(width: FeSpace.sm),
                Expanded(child: text),
                Icon(Icons.chevron_right, color: c.textSecondary),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    icon,
                    const SizedBox(width: FeSpace.sm),
                    Expanded(child: text),
                  ],
                ),
                const SizedBox(height: FeSpace.sm),
                FilledButton.icon(
                  key: const Key('pro.lock.unlock'),
                  onPressed: onUnlock,
                  icon: const Icon(Icons.workspace_premium_outlined, size: 20),
                  label: Text(l.proUnlock),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, FeTouch.minTarget),
                  ),
                ),
              ],
            ),
    );
  }
}
