import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';

/// «Hamkasbingizni taklif qiling» — Profil va Home’dagi sokin kirish nuqtasi
/// (reklama banneri emas: oddiy karta, nozik oltin aksent).
class InviteColleagueCard extends StatelessWidget {
  const InviteColleagueCard({super.key, this.compact = false});

  /// Home uchun ixchamroq ko‘rinish.
  final bool compact;

  static const gold = Color(0xFFC9A75E);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return FeCard(
      semanticLabel: l.referralTitle,
      padding: EdgeInsets.symmetric(
        horizontal: FeSpace.md,
        vertical: compact ? FeSpace.sm : FeSpace.md,
      ),
      onTap: () => context.push(Routes.referral),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: gold.withValues(alpha: dark ? 0.18 : 0.14),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.group_add_outlined,
                size: 22,
                color: dark ? gold : const Color(0xFF8A6A2B),
              ),
            ),
          ),
          const SizedBox(width: FeSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.referralTitle,
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  compact ? l.homeInviteHint : l.referralProfileRowHint,
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: c.textSecondary),
        ],
      ),
    );
  }
}
