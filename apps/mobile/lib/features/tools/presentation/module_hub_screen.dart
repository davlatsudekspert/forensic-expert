import 'package:flutter/material.dart';

import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../placeholder/presentation/in_development_view.dart';
import 'tool_tile.dart';

/// Modul sahifasi (Sud tibbiyoti, Toksikologiya, Laboratoriya):
/// shu bo‘lim vositalari + ma’lumotnoma (hali ishlab chiqilmoqda).
class ModuleHubScreen extends StatelessWidget {
  const ModuleHubScreen({
    super.key,
    required this.title,
    required this.category,
  });

  final String title;
  final ToolCategory? category;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tools = category == null
        ? const <ToolEntry>[]
        : ToolsCatalog.inCategory(category!);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (tools.isNotEmpty) ...[
                    FeSectionHeader(
                      l.moduleHubTools,
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                    ),
                    for (final t in tools)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.xs),
                        child: ToolTile(tool: t),
                      ),
                  ],
                  FeSectionHeader(l.moduleHubReference),
                  const AvailabilityStateView(
                    kind: AvailabilityKind.noReviewedData,
                    icon: Icons.menu_book_outlined,
                    embedded: true,
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
