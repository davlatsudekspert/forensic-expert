import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/referral.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../../domain/library/library_models.dart';
import '../../../domain/ports/billing_ports.dart';
import '../../../domain/professional/review_models.dart';
import '../../../domain/referral/share_text.dart';
import '../../common/favorite_button.dart';
import '../../common/share_button.dart';
import '../../common/view_recorder.dart';
import '../../evidence/evidence_strings.dart';
import '../../evidence/presentation/research_screens.dart';
import '../../evidence/presentation/scientific_image.dart';
import '../../evidence/presentation/source_quote.dart';
import '../../library/presentation/content_entry_sections.dart';
import '../../professional/presentation/review_section.dart';
import '../../support/presentation/support_widgets.dart' show ReportErrorMenu;
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
        e.access == EntryAccess.free ||
        AccessPolicy.unlocks(
          ProductFeature.verifiedReferences,
          ref.watch(accessProvider),
        );
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
    // (yorliq, izoh, tarjima ID — `entity_note` `<entity>#<maydon>#<i>`)
    final safetyNotes =
        <(String, SourcedNote, String)>[
          if (e.screening case final s?) ...[
            for (final (i, n) in s.limitations.indexed)
              (l.screeningLimitations, n, '${e.id}#limitations#$i'),
            for (final (i, n) in s.crossReactivity.indexed)
              (l.screeningCrossReactivity, n, '${e.id}#cross_reactivity#$i'),
            for (final (i, n) in s.falsePositive.indexed)
              (l.screeningFalsePositive, n, '${e.id}#false_positive#$i'),
            for (final (i, n) in s.falseNegative.indexed)
              (l.screeningFalseNegative, n, '${e.id}#false_negative#$i'),
          ],
          if (e.recipe case final r?)
            for (final (i, n) in r.hazards.indexed)
              (l.reagentHazards, n, '${e.id}#hazards#$i'),
        ].where((x) {
          final (_, note, _) = x;
          return !claimExcerpts.contains(_norm(note.text));
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(e.name.resolve(lang)),
        actions: [
          ShareButton(
            text: (l) => recordShareText(
              title: e.name.resolve(lang),
              sources: e.allSources,
              sourcesLabel: l.shareSourcesLabel,
              footer: l.shareFooter,
              appLink: ref.read(referralLinksProvider).recordLink(e.id),
            ),
          ),
          FavoriteButton(id: e.id),
          ReportErrorMenu(
            entityId: 'knowledge:${e.id}',
            title: e.name.resolve(lang),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          key: Key('knowledgeDetail.${e.id}'),
          padding: const EdgeInsets.symmetric(vertical: FeSpace.sm),
          children: [
            ViewRecorder(id: e.id),
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
                      tone: FeBannerTone.critical,
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
                    if (e.recipe?.hazards.isNotEmpty ?? false) ...[
                      FeBanner(
                        key: const Key('reagent.hazardBanner'),
                        icon: Icons.warning_amber_rounded,
                        text: l.reagentHazardBanner(e.recipe!.hazards.length),
                        tone: FeBannerTone.critical,
                      ),
                      const SizedBox(height: FeSpace.xs),
                    ],
                    for (final (label, n, trId) in safetyNotes)
                      _NoteCard(label: label, note: n, entry: e, trId: trId),
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
                  if (unlocked) TemplateCoverageCard(entry: e),
                  FeSectionHeader(l.knowledgeSources),
                  if (e.allSources.isEmpty)
                    Text(
                      l.noReliableSource,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  for (final s in e.allSources)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                      child: SourceTile(source: s),
                    ),
                  ProfessionalReviewSection(
                    recordId: e.id,
                    kind: reviewKindForKnowledge(e.kind, e.area),
                    risk: e.kind == KnowledgeKind.reagent
                        ? RiskLevel.high
                        : RiskLevel.standard,
                    sourceCount: e.allSources.length,
                    identifiersVerified: identifiersVerified(e.allSources),
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
        ],
      ),
    );
  }
}

/// Manbadan kelgan qiymat yoki «manbada yo‘q» (hech qachon taxmin emas).
class _Field extends ConsumerWidget {
  const _Field({
    required this.label,
    this.text,
    this.value,
    this.note,
    this.trId,
    required this.entry,
  });

  final String label;
  final String? text;
  final SourcedValue? value;
  final SourcedNote? note;

  /// Manbadan olingan matn uchun tarjima ID’si (`screening_field` —
  /// [text] uchun, `entity_note` — tilga moslanmagan [note] uchun).
  final String? trId;
  final KnowledgeEntry entry;

  /// Pipeline’ning inglizcha «manbada ko‘rsatilmagan» belgisi.
  static const _notInSource = 'not specified in source';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final sourceId = value?.sourceId ?? note?.sourceId;
    final translations = ref.watch(contentTranslationsProvider);
    // Manbadan olingan matn (raqamli qiymat emas): UI tilida bo‘lmasa —
    // tarjima yoki asl + «asl tili» yorlig‘i.
    LocalizedContent? sourced;
    final raw =
        text ?? (note != null && note!.texts.isEmpty ? note!.text : null);
    if (raw != null && raw.trim().toLowerCase() != _notInSource) {
      sourced = trId == null
          ? LocalizedContent.original(
              raw,
              originalLang: 'en',
              requestedLang: lang,
            )
          : translations.resolve(
              text != null
                  ? ContentTextKind.screeningField
                  : ContentTextKind.entityNote,
              trId!,
              source: raw,
              lang: lang,
            );
    } else if (note != null && note!.texts.isNotEmpty) {
      // Retsept izohlari (machine_draft, banner bilan): UI tilida yo‘q
      // bo‘lsa — fallback ochiq belgilanadi.
      sourced = resolveLocalizedMap(
        note!.texts,
        lang: lang,
        originalLang: note!.texts.containsKey('en') ? 'en' : null,
        fallbackText: note!.text,
      );
      if (!sourced.missingTranslation) sourced = null;
    }
    final shown = raw != null && raw.trim().toLowerCase() == _notInSource
        ? null
        : text ??
              (value == null ? null : '${value!.value} ${value!.unit}') ??
              note?.resolve(lang);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.labelMedium?.copyWith(color: c.textSecondary)),
          if (sourced != null &&
              (sourced.isTranslation || sourced.missingTranslation))
            LocalizedInlineView(content: sourced, style: t.bodyMedium)
          else
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
    required this.trId,
  });

  final String label;
  final SourcedNote note;
  final KnowledgeEntry entry;

  /// `entity_note` tarjima ID’si.
  final String trId;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    // Retsept xavf izohlari tilga moslangan (machine_draft) va GHS / umumiy
    // tavsiya sifatida ajratiladi; boshqa izohlar — asl (inglizcha) iqtibos.
    final localized = note.texts.isNotEmpty;
    final hazard = note.kind == 'ghs' || note.kind == 'general';
    final shownLabel = switch (note.kind) {
      'ghs' => l.reagentHazardGhs,
      'general' => l.reagentHazardGeneral,
      _ => label,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: hazard ? Key('reagent.hazard.${note.kind}') : null,
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (hazard) ...[
                  Icon(
                    note.kind == 'ghs'
                        ? Icons.warning_amber_rounded
                        : Icons.health_and_safety_outlined,
                    size: 18,
                    color: note.kind == 'ghs' ? c.danger : c.warning,
                  ),
                  const SizedBox(width: FeSpace.xxs),
                ],
                Expanded(
                  child: Text(
                    shownLabel,
                    style: t.labelMedium?.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: note.kind == 'ghs' ? c.danger : c.accent,
                    width: 3,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: FeSpace.sm),
                child: localized
                    ? Text(note.resolve(lang), style: t.bodyMedium)
                    // Manbadan asl izoh: tarjima birinchi, asl «Asl matn».
                    : LocalizedContentText(
                        kind: ContentTextKind.entityNote,
                        id: trId,
                        source: note.text,
                        quote: true,
                        style: t.bodySmall,
                      ),
              ),
            ),
            // Ilovaning umumiy tavsiyasi — ilmiy manba emas; ichki ID
            // ko‘rsatilmaydi (yorliq «ilova izohi» deydi).
            if (note.kind != 'general') ...[
              const SizedBox(height: 2),
              Text(
                l.knowledgeSourceRef(
                  [
                    entry.sourceById(note.sourceId)?.title ?? note.sourceId,
                    if (note.locator != null)
                      localizedSectionRef(l, note.locator!),
                  ].join(' · '),
                ),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
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
    final lang = Localizations.localeOf(context).languageCode;
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
          if (r.originalSourceId != null)
            Text(
              l.reagentRecipeSource(
                entry.sourceById(r.originalSourceId!)?.title ??
                    r.originalSourceId!,
              ),
              key: const Key('reagent.recipeSource'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          if (r.translationStatus == 'machine_draft') ...[
            const SizedBox(height: FeSpace.xxs),
            FeBanner(
              key: const Key('reagent.machineDraft'),
              icon: Icons.translate,
              text: l.reagentMachineDraft,
              tone: FeBannerTone.warning,
            ),
          ],
          const SizedBox(height: FeSpace.xs),
          for (final g in _variantGroups(r)) ...[
            if (g.variant != null) ...[
              const SizedBox(height: FeSpace.xs),
              Text(
                l.reagentVariant(
                  resolveLocalizedMap(
                    g.variant!.labels,
                    lang: lang,
                    fallbackText: g.variant!.id,
                  ).text,
                ),
                key: Key('reagent.variant.${g.variant!.id}'),
                style: t.titleMedium,
              ),
              if (g.variant!.sourceId != null &&
                  g.variant!.sourceId != r.originalSourceId)
                Text(
                  l.reagentRecipeSource(
                    entry.sourceById(g.variant!.sourceId!)?.title ??
                        g.variant!.sourceId!,
                  ),
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
            ],
            if (g.ingredients.isNotEmpty) ...[
              const SizedBox(height: FeSpace.xxs),
              Text(l.reagentIngredients, style: t.titleSmall),
              const SizedBox(height: FeSpace.xxs),
              _IngredientTable(
                key: Key('reagent.ingredients${g.keySuffix}'),
                ingredients: g.ingredients,
              ),
            ],
            if (g.steps.isNotEmpty) ...[
              const SizedBox(height: FeSpace.sm),
              Text(l.reagentSteps, style: t.titleSmall),
              if (g.steps.every((s) => s.order == null))
                Text(
                  l.reagentOrderNotStated,
                  key: Key('reagent.orderNotStated${g.keySuffix}'),
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              for (final s in g.steps)
                Padding(
                  padding: const EdgeInsets.only(top: FeSpace.xxs),
                  child: Text(
                    s.order != null
                        ? '${s.order}. ${s.resolve(lang)}'
                        : '${FeGlyphs.bullet}${s.resolve(lang)}',
                    style: t.bodyMedium,
                  ),
                ),
            ],
          ],
          const SizedBox(height: FeSpace.sm),
          _Field(
            label: l.reagentFinalVolume,
            value: r.finalVolume,
            entry: entry,
          ),
          for (final n in r.notes.where((n) => n.kind == 'purpose'))
            _Field(label: l.reagentPurpose, note: n, entry: entry),
          for (final n in r.notes.where((n) => n.kind == 'info'))
            _Field(label: l.reagentNote, note: n, entry: entry),
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
          // PHASE 8: to‘liq shablon — manbasiz maydon «manbali emas».
          _Field(
            label: l.reagentConcentration,
            value: r.concentration,
            entry: entry,
          ),
          _Field(label: l.reagentSolvent, note: r.solvent, entry: entry),
          _Field(label: l.reagentPh, value: r.ph, entry: entry),
          _Field(label: l.reagentExpiry, note: r.expiry, entry: entry),
          // GHS/umumiy xavf izohlari sahifa boshidagi «Xavfsizlik» bo‘limida
          // (har doim ochiq); bu yerda faqat turi berilmagan izohlar.
          for (final h in r.hazards.where((h) => h.kind == null))
            _Field(label: l.reagentHazards, note: h, entry: entry),
          for (final p in r.ppe)
            _Field(label: l.reagentPpe, note: p, entry: entry),
          if (r.notes.any((n) => n.kind == 'ambiguity'))
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: FeCard(
                key: const Key('reagent.ambiguities'),
                padding: const EdgeInsets.all(FeSpace.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.rule_folder_outlined,
                          size: 18,
                          color: c.warning,
                        ),
                        const SizedBox(width: FeSpace.xxs),
                        Expanded(
                          child: Text(l.reagentAmbiguity, style: t.titleSmall),
                        ),
                      ],
                    ),
                    for (final n in r.notes.where((n) => n.kind == 'ambiguity'))
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.xxs),
                        child: Text(
                          '${FeGlyphs.bullet}${n.resolve(lang)}',
                          style: t.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (r.originalText case final original?)
            FeCard(
              key: const Key('reagent.originalText'),
              padding: EdgeInsets.zero,
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: const Key('reagent.originalText.tile'),
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: FeSpace.sm,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(
                    FeSpace.sm,
                    0,
                    FeSpace.sm,
                    FeSpace.sm,
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(l.reagentOriginalText, style: t.titleSmall),
                  subtitle: Text(
                    l.reagentOriginalHint,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  children: [
                    SelectableText(
                      original,
                      key: const Key('reagent.originalText.body'),
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
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

/// Retsept varianti bo‘yicha guruh (variantsiz retsept — bitta guruh).
typedef _VariantGroup = ({
  RecipeVariant? variant,
  List<Ingredient> ingredients,
  List<PreparationStep> steps,
  String keySuffix,
});

List<_VariantGroup> _variantGroups(SolutionRecipe r) {
  if (r.variants.isEmpty) {
    return [
      (
        variant: null,
        ingredients: r.ingredients,
        steps: r.steps,
        keySuffix: '',
      ),
    ];
  }
  return [
    for (final v in r.variants)
      (
        variant: v,
        ingredients: [
          for (final i in r.ingredients)
            if (i.variant == v.id) i,
        ],
        steps: [
          for (final s in r.steps)
            if (s.variant == v.id) s,
        ],
        keySuffix: '.${v.id}',
      ),
  ];
}

/// Ingrediyent miqdori: «8 g», «10–15 ml», «100 ml gacha» yoki manbadagi
/// raqamsiz izoh. Raqam o‘zgartirilmaydi — faqat o‘nlik ajratkich tilga mos.
String ingredientAmountText(Ingredient i, String lang, AppLocalizations l) {
  String n(num x) {
    final s = x == x.roundToDouble() ? x.toInt().toString() : x.toString();
    return lang == 'en' ? s : s.replaceAll('.', ',');
  }

  final note = i.quantityNote.isEmpty
      ? null
      : resolveLocalizedMap(i.quantityNote, lang: lang).text;
  final a = i.amount;
  if (a == null) return note ?? FeGlyphs.emDash;
  final value = i.amountMax == null ? n(a) : '${n(a)}–${n(i.amountMax!)}';
  final unit = switch (i.unit) {
    'g' => l.reagentUnitG,
    'mL' => l.reagentUnitMl,
    'L' => l.reagentUnitL,
    'drop' => null,
    final u? => u,
    null => '',
  };
  final qty = unit == null
      ? l.reagentDropsAmount((i.amountMax ?? a).round(), value)
      : (unit.isEmpty ? value : '$value $unit');
  final shown = i.makeUpTo ? l.reagentMakeUpTo(qty) : qty;
  return note == null ? shown : '$shown ($note)';
}

class _IngredientTable extends StatelessWidget {
  const _IngredientTable({super.key, required this.ingredients});

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (idx, i) in ingredients.indexed)
          DecoratedBox(
            decoration: BoxDecoration(
              border: idx == 0
                  ? null
                  : Border(top: BorderSide(color: c.border)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(i.displayName(lang), style: t.bodyMedium),
                  ),
                  const SizedBox(width: FeSpace.sm),
                  Expanded(
                    flex: 2,
                    child: Text(
                      ingredientAmountText(i, lang, l),
                      textAlign: TextAlign.end,
                      style: FeThemeBuilder.numeric(t.bodyMedium!),
                    ),
                  ),
                ],
              ),
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
        _Field(
          label: l.screeningAnalyte,
          text: test.analyte,
          trId: '${entry.id}#analyte',
          entry: entry,
        ),
        _Field(
          label: l.screeningSpecimen,
          text: test.specimen,
          trId: '${entry.id}#specimen',
          entry: entry,
        ),
        _Field(
          label: l.screeningPrinciple,
          text: test.principle,
          trId: '${entry.id}#principle',
          entry: entry,
        ),
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
        _Field(
          label: l.screeningResultType,
          note: test.resultType,
          trId: '${entry.id}#result_type',
          entry: entry,
        ),
        _Field(
          label: l.screeningDetectionWindow,
          note: test.detectionWindow,
          trId: '${entry.id}#detection_window',
          entry: entry,
        ),
        for (final (i, n) in test.interferences.indexed)
          _Field(
            label: l.screeningInterference,
            note: n,
            trId: '${entry.id}#interferences#$i',
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
        // Chip o‘z o‘lchamida (ustun bo‘ylab cho‘zilmaydi).
        Padding(
          padding: const EdgeInsets.only(bottom: FeSpace.xs),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: StatusChip(
              key: const Key('method.evidenceType'),
              icon: Icons.description_outlined,
              label: l.methodEvidenceTypeLabel(method.effectiveEvidenceType),
              color: c.textSecondary,
            ),
          ),
        ),
        if (method.effectiveEvidenceType ==
            MethodEvidenceType.educationalSummary) ...[
          FeBanner(
            key: const Key('method.publishedNote'),
            icon: Icons.science_outlined,
            text: l.methodPublishedNote,
            tone: FeBannerTone.warning,
          ),
          const SizedBox(height: FeSpace.xs),
        ],
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
            l.emergingDate(feDate(context, issue.date!)),
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

/// Kontent shabloni qamrovi: qaysi bo‘limlarda manbali ma’lumot bor va
/// qaysilari hali manbasiz. Bo‘sh bo‘limlar to‘qilmaydi — bitta qator.
class TemplateCoverageCard extends ConsumerWidget {
  const TemplateCoverageCard({super.key, required this.entry});

  final KnowledgeEntry entry;

  static TemplateKind? kindOf(KnowledgeEntry e) => switch (e.kind) {
    KnowledgeKind.reagent => TemplateKind.reagent,
    KnowledgeKind.screeningTest => TemplateKind.rapidTest,
    KnowledgeKind.method => TemplateKind.method,
    KnowledgeKind.topic when e.area == KnowledgeArea.biochemistry =>
      TemplateKind.biomarker,
    KnowledgeKind.topic => TemplateKind.forensicMedicineTopic,
    _ => null,
  };

  static bool _structural(KnowledgeEntry e, String code) {
    final r = e.recipe;
    final t = e.screening;
    return switch (code) {
      'composition' => r != null && r.ingredients.isNotEmpty,
      'preparation' => r != null && r.steps.isNotEmpty,
      'storage_stability' =>
        r != null &&
            (r.storage != null || r.stability != null || r.temperature != null),
      'safety' => r != null && r.hazards.isNotEmpty,
      'disposal' => r?.disposalReference != null,
      'qc' => r?.qcRequirement != null,
      'technology' => t != null && t.principle.isNotEmpty,
      'target_specimen' => t != null && t.analyte.isNotEmpty,
      'cutoff' => t?.cutoff != null,
      'performance' => t?.sensitivity != null || t?.specificity != null,
      'cross_reactivity' => t != null && t.crossReactivity.isNotEmpty,
      'false_results' =>
        t != null && (t.falsePositive.isNotEmpty || t.falseNegative.isNotEmpty),
      'limitations' => t != null && t.limitations.isNotEmpty,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = kindOf(entry);
    if (kind == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final ev = ref.watch(evidenceDataProvider);
    final fields = {for (final x in entry.claims) x.field};
    final relations = {
      for (final x in ev.linksFrom(entry.id)) x.relation,
      for (final x in ev.linksTo(entry.id)) x.relation,
    };
    final sections = ContentTemplates.of(kind);
    final filled = [
      for (final s in sections)
        if (s.claimFields.any(fields.contains) ||
            s.relations.any(relations.contains) ||
            (s.structural && _structural(entry, s.code)))
          s,
    ];
    final missing = [
      for (final s in sections)
        if (!filled.contains(s)) l.templateSectionName(s.code),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm),
      child: FeCard(
        key: const Key('knowledge.templateCoverage'),
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.templateCoverage(filled.length, sections.length),
              style: t.titleSmall,
            ),
            if (missing.isNotEmpty) ...[
              const SizedBox(height: FeSpace.xxs),
              Text(
                '${l.detailNotYetSourced}: ${missing.join(FeGlyphs.middleDot)}',
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
