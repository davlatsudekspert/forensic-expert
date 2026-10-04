import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../core/widgets/fe_data_components.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../../domain/library/library_models.dart';
import '../../common/favorite_button.dart';
import '../../evidence/evidence_strings.dart';
import '../../evidence/presentation/research_screens.dart';
import '../../evidence/presentation/scientific_image.dart';
import '../../library/presentation/content_entry_sections.dart';
import '../knowledge_strings.dart';

/// Bilim yozuvi sahifasi.
///
/// Paywall qoidasi: nom, status, ogohlantirishlar, **cheklovlar va xavfsizlik**
/// (cheklov, cross-reactivity, xavflar, «skrining ≠ tasdiqlash»), provenance
/// va manbalar hech qachon yopilmaydi. Lifetime’siz faqat tuzilgan
/// tafsilotlar va boshqa claim’lar yopiladi.
class KnowledgeDetailScreen extends ConsumerWidget {
  const KnowledgeDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final e = ref.watch(knowledgeRepositoryProvider).byId(entryId);
    if (e == null) {
      return Scaffold(
        appBar: AppBar(),
        body: FeEmptyState(icon: Icons.inbox_outlined, body: l.knowledgeEmpty),
      );
    }
    final unlocked =
        e.access == EntryAccess.free || ref.watch(accessProvider).hasFullAccess;
    // Bir xil manba jumlasi sahifada bir marta: claim (status va dalil
    // darajasi bilan) tuzilgan izohdan ustun; retsept qadami esa claim’dan.
    final recipeSteps = {
      for (final st in e.recipe?.steps ?? const <PreparationStep>[])
        _norm(st.text),
    };
    final claims = [
      for (final x in e.claims)
        if (x.excerpt == null || !recipeSteps.contains(_norm(x.excerpt!))) x,
    ];
    final claimExcerpts = {
      for (final x in claims)
        if (x.excerpt != null) _norm(x.excerpt!),
    };
    final safetyClaims = [
      for (final x in claims)
        if (safetyClaimFields.contains(x.field)) x,
    ];
    final otherClaims = [
      for (final x in claims)
        if (!safetyClaimFields.contains(x.field)) x,
    ];
    final safetyNotes =
        <(String, SourcedNote)>[
          if (e.screening case final s?) ...[
            for (final n in s.limitations) (l.screeningLimitations, n),
            for (final n in s.crossReactivity) (l.screeningCrossReactivity, n),
            for (final n in s.falsePositive) (l.screeningFalsePositive, n),
            for (final n in s.falseNegative) (l.screeningFalseNegative, n),
          ],
          if (e.recipe case final r?)
            for (final n in r.hazards) (l.reagentHazards, n),
        ].where((x) {
          final (_, note) = x;
          return !claimExcerpts.contains(_norm(note.text));
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(e.name.resolve(lang)),
        actions: [FavoriteButton(id: e.id)],
      ),
      body: SafeArea(
        child: ListView(
          key: Key('knowledgeDetail.${e.id}'),
          padding: const EdgeInsets.symmetric(vertical: FeSpace.sm),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (e.isTestData) ...[
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TestDataBadge(),
                    ),
                    const SizedBox(height: FeSpace.xs),
                  ],
                  if (e.status != ScientificStatus.verified) ...[
                    const UnverifiedBanner(),
                    const SizedBox(height: FeSpace.sm),
                  ],
                  if (e.kind == KnowledgeKind.screeningTest) ...[
                    FeBanner(
                      key: const Key('screening.banner'),
                      icon: Icons.report_gmailerrorred_outlined,
                      text: l.screeningBanner,
                      tone: FeBannerTone.warning,
                    ),
                    const SizedBox(height: FeSpace.sm),
                  ],
                  if (e.area == KnowledgeArea.histology) ...[
                    FeBanner(
                      key: const Key('histology.noDiagnosis'),
                      icon: Icons.biotech_outlined,
                      text: l.histologyNote,
                      tone: FeBannerTone.warning,
                    ),
                    const SizedBox(height: FeSpace.sm),
                  ],
                  _Header(entry: e),
                  if (safetyClaims.isNotEmpty || safetyNotes.isNotEmpty) ...[
                    FeSectionHeader(l.knowledgeSafety),
                    for (final (label, n) in safetyNotes)
                      _NoteCard(label: label, note: n, entry: e),
                    for (final x in safetyClaims)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.xs),
                        child: ClaimCard(claim: x),
                      ),
                  ],
                  if (!unlocked) ...[
                    const SizedBox(height: FeSpace.md),
                    const LockedContentCard(key: Key('knowledge.locked')),
                  ] else ...[
                    if (e.recipe case final r?)
                      _RecipeSection(recipe: r, entry: e),
                    if (e.screening case final s?)
                      _ScreeningSection(test: s, entry: e),
                    if (e.method case final m?) _MethodSection(method: m),
                    if (e.emerging case final x?) _EmergingSection(issue: x),
                    if (otherClaims.isNotEmpty) ...[
                      FeSectionHeader(l.knowledgeStatements),
                      for (final x in otherClaims)
                        Padding(
                          padding: const EdgeInsets.only(bottom: FeSpace.xs),
                          child: ClaimCard(claim: x),
                        ),
                    ],
                  ],
                  ScientificImageGallery(entityId: e.id),
                  RelatedSection(entityId: e.id),
                  FeSectionHeader(l.knowledgeSources),
                  if (e.allSources.isEmpty)
                    Text(
                      l.knowledgeNotInSource,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  for (final s in e.allSources)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                      child: SourceTile(source: s),
                    ),
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.entry});

  final KnowledgeEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final reviews = entry.claims.fold<int>(0, (a, x) => a + x.reviewCount);
    return FeCard(
      key: const Key('knowledge.provenance'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xxs,
            children: [
              ReviewStatusBadge(status: entry.status),
              AccessBadge(access: entry.access),
              StatusChip(
                icon: Icons.category_outlined,
                label: entry.method != null
                    ? l.methodKindTitle(entry.method!.kind)
                    : l.knowledgeKindTitle(entry.kind),
                color: c.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xxs),
          Text(
            reviews == 0 ? l.detailReviewsNone : l.detailReviewsCount(reviews),
            style: t.bodySmall,
          ),
          Text(
            l.detailVersionValue(entry.version, entry.packVersion ?? '—'),
            style: FeThemeBuilder.numeric(t.bodySmall!)
                .copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Manbadan kelgan qiymat yoki «manbada yo‘q» (hech qachon taxmin emas).
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    this.text,
    this.value,
    this.note,
    required this.entry,
  });

  final String label;
  final String? text;
  final SourcedValue? value;
  final SourcedNote? note;
  final KnowledgeEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final sourceId = value?.sourceId ?? note?.sourceId;
    final shown =
        text ??
        (value == null ? null : '${value!.value} ${value!.unit}') ??
        note?.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.labelMedium?.copyWith(color: c.textSecondary)),
          Text(
            shown ?? l.knowledgeNotInSource,
            style: shown == null
                ? t.bodySmall?.copyWith(color: c.textSecondary)
                : (value != null
                      ? FeThemeBuilder.numeric(t.bodyMedium!)
                      : t.bodyMedium),
          ),
          if (sourceId != null)
            Text(
              l.knowledgeSourceRef(
                entry.sourceById(sourceId)?.title ?? sourceId,
              ),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.label,
    required this.note,
    required this.entry,
  });

  final String label;
  final SourcedNote note;
  final KnowledgeEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: t.labelMedium?.copyWith(color: c.textSecondary)),
            const SizedBox(height: 2),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: c.accent, width: 3)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: FeSpace.sm),
                child: Text(
                  note.text,
                  locale: const Locale('en'),
                  style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l.knowledgeSourceRef(
                [
                  entry.sourceById(note.sourceId)?.title ?? note.sourceId,
                  if (note.locator != null) '§ ${note.locator}',
                ].join(' · '),
              ),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeSection extends StatelessWidget {
  const _RecipeSection({required this.recipe, required this.entry});

  final SolutionRecipe recipe;
  final KnowledgeEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final r = recipe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.reagentPreparation),
        if (!r.hasPreparationData)
          FeCard(
            key: const Key('reagent.noRecipe'),
            padding: const EdgeInsets.all(FeSpace.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.do_not_disturb_alt_outlined, color: c.warning),
                    const SizedBox(width: FeSpace.xs),
                    Expanded(
                      child: Text(l.reagentNoRecipe, style: t.bodyMedium),
                    ),
                  ],
                ),
              ],
            ),
          )
        else ...[
          Text(l.reagentIngredients, style: t.titleSmall),
          const SizedBox(height: FeSpace.xxs),
          FeDataTable(
            key: const Key('reagent.ingredients'),
            rows: [
              for (final i in r.ingredients) (i.name, '${i.amount} ${i.unit}'),
            ],
          ),
          const SizedBox(height: FeSpace.sm),
          _Field(
            label: l.reagentFinalVolume,
            value: r.finalVolume,
            entry: entry,
          ),
          Text(l.reagentSteps, style: t.titleSmall),
          if (!r.orderExplicitInSource)
            Text(
              l.reagentOrderNotStated,
              key: const Key('reagent.orderNotStated'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          for (final (i, s) in r.steps.indexed)
            Padding(
              padding: const EdgeInsets.only(top: FeSpace.xxs),
              child: Text(
                r.orderExplicitInSource
                    ? '${s.order ?? i + 1}. ${s.text}'
                    : '${FeGlyphs.bullet}${s.text}',
                style: t.bodyMedium,
              ),
            ),
          const SizedBox(height: FeSpace.sm),
          _Field(label: l.reagentStorage, note: r.storage, entry: entry),
          _Field(
            label: l.reagentTemperature,
            value: r.temperature,
            entry: entry,
          ),
          _Field(label: l.reagentStability, note: r.stability, entry: entry),
          _Field(
            label: l.reagentDisposal,
            note: r.disposalReference,
            entry: entry,
          ),
          _Field(label: l.reagentQc, note: r.qcRequirement, entry: entry),
        ],
        const SizedBox(height: FeSpace.xs),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            key: const Key('reagent.openCalculator'),
            icon: const Icon(Icons.calculate_outlined),
            label: Text(l.reagentOpenCalculator),
            onPressed: () => context.push(Routes.tool('tool.lab.solution')),
          ),
        ),
      ],
    );
  }
}

class _ScreeningSection extends ConsumerWidget {
  const _ScreeningSection({required this.test, required this.entry});

  final ScreeningTest test;
  final KnowledgeEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(knowledgeRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.knowledgeDetails),
        _Field(label: l.screeningAnalyte, text: test.analyte, entry: entry),
        _Field(label: l.screeningSpecimen, text: test.specimen, entry: entry),
        _Field(label: l.screeningPrinciple, text: test.principle, entry: entry),
        _Field(label: l.screeningCutoff, value: test.cutoff, entry: entry),
        _Field(
          label: l.screeningSensitivity,
          value: test.sensitivity,
          entry: entry,
        ),
        _Field(
          label: l.screeningSpecificity,
          value: test.specificity,
          entry: entry,
        ),
        FeSectionHeader(l.screeningConfirmatory),
        for (final id in test.confirmatoryMethodIds)
          ListTile(
            key: Key('screening.confirm.$id'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.verified_outlined),
            title: Text(repo.byId(id)?.name.resolve(lang) ?? id),
            trailing: const Icon(Icons.chevron_right),
            onTap: repo.byId(id) == null
                ? null
                : () => context.push(Routes.knowledgeEntry(id)),
          ),
      ],
    );
  }
}

class _MethodSection extends ConsumerWidget {
  const _MethodSection({required this.method});

  final MethodRecord method;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final resolver = ref.watch(jurisdictionResolverProvider);
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.labelMedium?.copyWith(color: c.textSecondary)),
          Text(value, style: t.bodyMedium),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.knowledgeDetails),
        if (method.organization != null)
          row(l.methodOrganization, method.organization!),
        if (method.jurisdictionId != null)
          row(
            l.methodJurisdiction,
            resolver.byId(method.jurisdictionId!)?.name(lang) ??
                method.jurisdictionId!,
          ),
        if (method.techniques.isNotEmpty)
          row(
            l.methodTechniques,
            method.techniques.map(l.techniqueName).join(', '),
          ),
        if (method.documentVersion != null)
          row(l.methodDocumentVersion, method.documentVersion!),
        for (final s in method.sections.entries)
          row(l.methodSectionName(s.key), s.value),
      ],
    );
  }
}

class _EmergingSection extends StatelessWidget {
  const _EmergingSection({required this.issue});

  final EmergingIssue issue;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.knowledgeDetails),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xxs,
          children: [
            StatusChip(
              icon: Icons.label_outline,
              label: l.emergingCategoryName(issue.category),
              color: c.textSecondary,
            ),
            StatusChip(
              icon: Icons.fact_check_outlined,
              label: l.evidenceTypeName(issue.evidenceType),
              color: c.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: FeSpace.xs),
        if (issue.date != null)
          Text(
            l.emergingDate(
              MaterialLocalizations.of(context).formatMediumDate(issue.date!),
            ),
            style: t.bodySmall,
          ),
        if (issue.scopeJurisdictionId == null)
          Text(l.emergingScopeGlobal, style: t.bodySmall),
      ],
    );
  }
}

String _norm(String t) =>
    t.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
