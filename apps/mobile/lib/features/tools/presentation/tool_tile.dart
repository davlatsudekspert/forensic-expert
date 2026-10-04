import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/ports/billing_ports.dart';
import '../../common/favorite_button.dart';
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
            : () => context.go(Routes.tool(tool.id)),
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
                        if (tool.isAvailable) ...[
                          StatusChip(
                            icon: Icons.check_circle_outline,
                            label: l.toolStatusAvailable,
                            color: c.accent,
                          ),
                          const ReviewStatusBadge(
                            status: ScientificStatus.needsReview,
                          ),
                        ] else
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
