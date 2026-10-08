import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/ai/rag_pipeline.dart';
import '../../evidence/presentation/provenance_widgets.dart';

/// PHASE 9: RAG javobi tuzilmasi — JAVOB · MANBALAR · DALIL HOLATI ·
/// YURISDIKSIYA · CHEKLOVLAR · BOG‘LIQ YOZUVLAR. Hech bir matn to‘qilmaydi:
/// hammasi olingan bo‘laklar va ularning provenance’idan.
class RagSectionsView extends ConsumerWidget {
  const RagSectionsView({super.key, required this.answer});

  final RagAnswer answer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final library = ref.watch(libraryRepositoryProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final index = ref.watch(provenanceIndexProvider);
    String nameOf(String id) =>
        library.byId(id)?.name.resolve(lang) ??
        knowledge.byId(id)?.name.resolve(lang) ??
        index.specimen(id)?.names.resolve(lang) ??
        id;
    String limitation(String code) => switch (code) {
      'not_human_verified' => l.aiLimNotVerified,
      'evidence_conflict' => l.aiLimConflict,
      'retracted_excluded' => l.aiLimRetracted(answer.excludedRetracted),
      'mock_provider' => l.aiLimMock,
      _ => l.aiLimExpert,
    };
    final muted = t.bodySmall?.copyWith(color: c.textSecondary);
    return Column(
      key: Key('ai.rag.${answer.outcome.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.aiSectionEvidenceStatus),
        for (final e in answer.evidence)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xxs),
            child: Wrap(
              key: Key('ai.rag.evidence.${e.chunk.chunkId}'),
              spacing: FeSpace.xs,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(e.chunk.title ?? e.chunk.entityId, style: t.bodySmall),
                StatusChip(
                  icon: Icons.pending_outlined,
                  label: l.lifecycleLabel(ClaimLifecycle.fromCode(e.lifecycle)),
                  color: c.accent,
                ),
                if (e.hasConflict)
                  StatusChip(
                    icon: Icons.compare_arrows,
                    label: l.conflictsTitle,
                    color: c.warning,
                  ),
              ],
            ),
          ),
        FeSectionHeader(l.aiSectionJurisdiction),
        Text(
          answer.jurisdictionId ?? l.aiRagJurisdictionNotApplicable,
          style: muted,
        ),
        FeSectionHeader(l.aiSectionLimitations),
        for (final code in answer.limitations)
          Text(
            '${FeGlyphs.bullet} ${limitation(code)}',
            key: Key('ai.rag.limitation.$code'),
            style: t.bodySmall,
          ),
        FeSectionHeader(l.aiSectionRelated),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xxs,
          children: [
            for (final id in answer.relatedEntityIds.take(8))
              ActionChip(
                key: Key('ai.rag.related.$id'),
                label: Text(nameOf(id)),
                onPressed: () => context.push(
                  library.byId(id) != null
                      ? Routes.libraryEntry(id)
                      : Routes.knowledgeEntry(id),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
