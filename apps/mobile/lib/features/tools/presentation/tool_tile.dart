import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/ports/billing_ports.dart';
import '../../common/favorite_button.dart';
import '../../professional/presentation/professional_widgets.dart';
import '../tool_strings.dart';

/// Vosita kartochkasi: nom, qisqa vazifa, holat va favorite.
class ToolTile extends ConsumerWidget {
  const ToolTile({super.key, required this.tool, this.showFavorite = true});

  final ToolEntry tool;
  final bool showFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locked =
        tool.isAvailable &&
        !AccessPolicy.isToolUnlocked(tool.id, ref.watch(accessProvider));
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Card(
      key: Key('tool.${tool.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: locked
            ? () => context.push(Routes.purchase)
            : () => context.push(Routes.tool(tool.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FeSpace.md,
            FeSpace.sm,
            FeSpace.xxs,
            FeSpace.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  tool.isAvailable
                      ? Icons.calculate_outlined
                      : Icons.schedule_outlined,
                  color: tool.isAvailable ? c.accent : c.textSecondary,
                ),
              ),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.toolName(tool), style: t.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      l.toolDescription(tool),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                    if (locked || !tool.isAvailable) ...[
                      const SizedBox(height: FeSpace.xs),
                      Wrap(
                        spacing: FeSpace.xs,
                        runSpacing: FeSpace.xxs,
                        children: [
                          if (locked)
                            StatusChip(
                              key: Key('tool.locked.${tool.id}'),
                              icon: Icons.lock_outline,
                              label: l.lockedBadge,
                              color: c.textSecondary,
                            ),
                          // Modul/formula holati har plitkada takrorlanmaydi —
                          // ro‘yxat ustida bitta [ToolsReviewNote]; to‘liq
                          // holat vosita sahifasida.
                          if (!tool.isAvailable)
                            StatusChip(
                              icon: Icons.schedule_outlined,
                              label: tool.plannedRelease == null
                                  ? l.toolStatusPlanned
                                  : '${l.toolStatusPlanned} · ${tool.plannedRelease}',
                              color: c.textSecondary,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (showFavorite) FavoriteButton(id: tool.id),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vositalar ro‘yxati ustidagi yagona eslatma: hisoblash modullari dasturiy
/// sinovdan o‘tgan, formulalar manbasi esa hali ekspert tasdiqlamagan.
class ToolsReviewNote extends StatelessWidget {
  const ToolsReviewNote({super.key});

  @override
  Widget build(BuildContext context) => FeNote(
    key: const Key('tools.reviewNote'),
    icon: Icons.fact_check_outlined,
    text: AppLocalizations.of(context).toolsReviewNote,
  );
}
