import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../library/presentation/content_entry_sections.dart';

/// Ro‘yxatdagi bilim yozuvi: nom, status, kirish darajasi, TEST belgisi.
class KnowledgeTile extends StatelessWidget {
  const KnowledgeTile({super.key, required this.entry, this.subtitle});

  final KnowledgeEntry entry;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('knowledge.${entry.id}'),
        onTap: () => context.push(Routes.knowledgeEntry(entry.id)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.name.resolve(lang), style: t.titleSmall),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                  const SizedBox(height: FeSpace.xxs),
                  Wrap(
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xxs,
                    children: [
                      ReviewStatusBadge(status: entry.status),
                      AccessBadge(access: entry.access),
                      if (entry.isTestData) const TestDataBadge(),
                    ],
                  ),
                ],
              ),
            ),
            ExcludeSemantics(
              child: Icon(Icons.chevron_right, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
