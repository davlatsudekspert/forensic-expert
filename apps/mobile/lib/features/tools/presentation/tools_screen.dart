import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../tool_strings.dart';
import 'tool_tile.dart';

/// Vositalar katalogi: Sud tibbiyoti · Toksikologiya · Laboratoriya ·
/// Birlik konversiyalari.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.toolsTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.toolsSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  const ToolsReviewNote(),
                  const SizedBox(height: FeSpace.sm),
                  FeCard(
                    key: const Key('tools.casebook'),
                    onTap: () => context.push(Routes.casebook),
                    child: Row(
                      children: [
                        Icon(Icons.menu_book_outlined, color: c.accent),
                        const SizedBox(width: FeSpace.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.casebookTitle,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                l.casebookTileHint,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: c.textSecondary),
                      ],
                    ),
                  ),
                  for (final category in ToolCategory.values) ...[
                    FeSectionHeader(l.toolCategoryName(category)),
                    for (final tool in ToolsCatalog.inCategory(category))
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.xs),
                        child: ToolTile(tool: tool),
                      ),
                  ],
                  const SizedBox(height: FeSpace.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
