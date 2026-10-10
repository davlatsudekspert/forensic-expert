import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/pro/analysis_plan.dart';
import '../../evidence/presentation/provenance_widgets.dart';
import '../../evidence/presentation/source_quote.dart';
import '../../library/presentation/content_entry_sections.dart' show ClaimMeta;
import '../pro_strings.dart';

/// ID → joriy tildagi nom (kutubxona, bilim sohalari, namunalar).
String Function(String id) proNameResolver(WidgetRef ref, String lang) {
  final library = ref.watch(libraryRepositoryProvider);
  final knowledge = ref.watch(knowledgeRepositoryProvider);
  final index = ref.watch(provenanceIndexProvider);
  return (id) =>
      library.byId(id)?.name.resolve(lang) ??
      knowledge.byId(id)?.name.resolve(lang) ??
      index.specimen(id)?.names.resolve(lang) ??
      id;
}

/// Pullik tarif taklifi (mavjud «locked» andozasi: ikonka, sarlavha,
/// matn, tariflar tugmasi).
class ProLockedCard extends StatelessWidget {
  const ProLockedCard({
    super.key,
    required this.title,
    required this.body,
    required this.buttonKey,
  });

  final String title;
  final String body;
  final Key buttonKey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined, color: c.accent),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: t.titleSmall),
                ),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          Text(body, style: t.bodySmall?.copyWith(color: c.textSecondary)),
          const SizedBox(height: FeSpace.sm),
          FilledButton(
            key: buttonKey,
            onPressed: () => context.push(Routes.purchase),
            child: Text(l.purchaseCta),
          ),
        ],
      ),
    );
  }
}

/// Reja iqtibosi: rol yorlig‘i, iqtibos (UI tilidagi tarjima birinchi,
/// «Asl matn» orqali asl), manba + aniq joyi va holat belgisi.
class PlanQuoteTile extends ConsumerWidget {
  const PlanQuoteTile({super.key, required this.quote});

  final PlanQuote quote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final q = quote;
    final nameOf = proNameResolver(ref, lang);
    final claim = q.claimId == null
        ? null
        : ref.watch(provenanceIndexProvider).claimsById[q.claimId];
    final source = q.source;
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.planRole(q.role),
            style: t.labelMedium?.copyWith(color: c.textSecondary),
          ),
          if (q.aboutId case final about?)
            Text(
              l.planAbout(nameOf(about)),
              style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          if (q.texts.isNotEmpty)
            Text(q.texts[lang] ?? q.texts['en'] ?? q.text, style: t.bodySmall)
          else
            SourceQuote(kind: q.kind, id: q.id, text: q.text),
          const SizedBox(height: 2),
          // Manba va uning ichidagi aniq joy — iqtibos ostida.
          Text(
            source == null ? l.planNoSource : l.planSourceLine(source.title),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          if (q.locator != null)
            Text(
              l.planLocatorLine(localizedSectionRef(l, q.locator!)),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          Row(
            children: [
              // TODO(trust): «trust» agenti kiritadigan holat chipi vidjeti
              // bazaga qo‘shilgach, shu yerdagi ClaimMeta o‘rniga qo‘yiladi.
              Expanded(
                child: ClaimMeta(status: q.status, level: q.level),
              ),
              if (claim != null)
                IconButton(
                  key: Key('plan.source.${claim.claimId}'),
                  tooltip: l.analysisShowSource,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.format_quote_outlined, size: 20),
                  onPressed: () => showProvenanceSheet(context, claim),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
