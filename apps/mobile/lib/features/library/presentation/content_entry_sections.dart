import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../core/widgets/fe_data_components.dart';
import '../../../domain/library/library_models.dart';
import '../../../domain/ports/billing_ports.dart';
import '../../evidence/presentation/provenance_widgets.dart';
import '../../evidence/presentation/research_screens.dart';
import '../../evidence/presentation/scientific_image.dart';
import '../../evidence/presentation/source_quote.dart';
import '../../legal/presentation/legal_rule_card.dart';
import 'substance_analysis_section.dart';

/// Kontent paketidan kelgan yozuv uchun bo‘limlar.
///
/// Paywall qoidasi: nomlar, ogohlantirishlar, provenance va **manbalar**
/// hech qachon yopilmaydi. Lifetime’siz faqat ilmiy tafsilotlar va
/// yurisdiksiya qatlami yopiladi.
class ContentEntryBody extends ConsumerStatefulWidget {
  const ContentEntryBody({super.key, required this.entry});

  final LibraryEntry entry;

  @override
  ConsumerState<ContentEntryBody> createState() => _ContentEntryBodyState();
}

/// Progressive disclosure: «Shu sahifada» indeksi va manbasiz bo‘limlar
/// bitta ixcham qatorda — cheksiz matn devori o‘rniga.
class _ContentEntryBodyState extends ConsumerState<ContentEntryBody> {
  final _anchors = <String, GlobalKey>{};

  GlobalKey _anchor(String id) => _anchors.putIfAbsent(id, GlobalKey.new);

  Widget _section(String id, String title) =>
      KeyedSubtree(key: _anchor(id), child: FeSectionHeader(title));

  void _jump(String id) {
    final ctx = _anchors[id]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final l = AppLocalizations.of(context);
    final d = entry.details!;
    final unlocked =
        entry.access == EntryAccess.free ||
        AccessPolicy.unlocks(
          ProductFeature.substanceLibrary,
          ref.watch(accessProvider),
        );

    final scientificFields = [
      ('identity', l.detailIdentity),
      ('metabolites', l.detailMetabolites),
      ('metabolism_note', l.detailMetabolismNote),
      ('biomarker', l.detailBiomarker),
      ('transformation_product', l.detailTransformationProduct),
    ];
    final presentFields = {for (final c in d.claims) c.field};
    final hasSpecimens = ref
        .watch(evidenceDataProvider)
        .linksFrom(entry.id)
        .any((x) => x.relation == LinkRelation.measuredIn);
    final emptySections = [
      (Icons.category_outlined, l.detailClass),
      if (!presentFields.contains('metabolites') &&
          !presentFields.contains('metabolism_note'))
        (Icons.account_tree_outlined, l.detailMetabolites),
      if (!hasSpecimens) (Icons.water_drop_outlined, l.detailSpecimens),
      if (!presentFields.contains('analytical_method'))
        (Icons.biotech_outlined, l.detailMethods),
      if (!presentFields.contains('reported_concentration'))
        (Icons.show_chart, l.detailConcentrations),
      (Icons.psychology_alt_outlined, l.detailInterpretation),
      (Icons.ac_unit, l.detailStability),
      (Icons.compare_arrows, l.detailInterferences),
    ];

    final hasStructure = ref
        .watch(evidenceDataProvider)
        .imagesFor(entry.id)
        .any((m) => m.kind == ImageKind.chemicalStructure);
    final isSubstance = entry.section == LibrarySection.substances;
    final index = <(String, String)>[
      if (unlocked && isSubstance) ('analysis', l.analysisTitle),
      if (hasStructure) ('structure', l.detailStructure),
      if (unlocked) ...[
        for (final (field, title) in scientificFields)
          if (presentFields.contains(field)) (field, title),
        if (presentFields.contains('analytical_method'))
          ('analytical_method', l.detailAnalyticalMethods),
        if (presentFields.contains('reported_concentration'))
          ('reported_concentration', l.detailReportedConcentrations),
        ('jurisdiction', l.detailJurisdictionShort),
      ],
      ('related', l.detailRelated),
      ('sources', l.detailReferences),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProvenanceCard(entry: entry),
        FeSectionHeader(l.detailOnThisPage),
        SingleChildScrollView(
          key: const Key('entry.index'),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (id, title) in index)
                Padding(
                  padding: const EdgeInsets.only(right: FeSpace.xs),
                  child: ActionChip(
                    key: Key('entry.index.$id'),
                    label: Text(title),
                    onPressed: () => _jump(id),
                  ),
                ),
            ],
          ),
        ),
        // «Tahlil» — biologik ob’ektlarda qanday tahlil qilinadi (yuqorida,
        // to‘g‘ridan-to‘g‘ri ko‘rinadi). Ilmiy tafsilot: paywall qoidasi
        // boshqa ilmiy bo‘limlar bilan bir xil.
        if (unlocked && isSubstance) ...[
          _section('analysis', l.analysisTitle),
          SubstanceAnalysisSection(entityId: entry.id),
        ],
        // Struktura — identifikatsiya (paywall ortida emas).
        for (final im
            in ref
                .watch(evidenceDataProvider)
                .imagesFor(entry.id)
                .where((m) => m.kind == ImageKind.chemicalStructure)) ...[
          _section('structure', l.detailStructure),
          ScientificImageCard(meta: im),
        ],
        if (!unlocked) ...[
          const SizedBox(height: FeSpace.md),
          const LockedContentCard(key: Key('entry.locked')),
        ] else ...[
          FeSectionHeader(l.detailLayerScientific),
          FeBanner(
            key: const Key('entry.layer.scientific'),
            icon: Icons.public,
            text: l.detailLayerScientificNote,
          ),
          for (final (field, title) in scientificFields)
            if (d.claims.any((c) => c.field == field)) ...[
              _section(field, title),
              for (final claim in d.claims.where((c) => c.field == field))
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  child: ClaimCard(claim: claim),
                ),
            ],
          if (presentFields.contains('analytical_method')) ...[
            _section('analytical_method', l.detailAnalyticalMethods),
            for (final claim in d.claims.where(
              (c) => c.field == 'analytical_method',
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: FeSpace.xs),
                child: ClaimCard(claim: claim),
              ),
          ],
          if (presentFields.contains('reported_concentration')) ...[
            _section('reported_concentration', l.detailReportedConcentrations),
            FeBanner(
              key: const Key('entry.concentration.notThreshold'),
              icon: Icons.warning_amber_rounded,
              text: l.concentrationNotThreshold,
              tone: FeBannerTone.critical,
            ),
            const SizedBox(height: FeSpace.xs),
            for (final claim in d.claims.where(
              (c) => c.field == 'reported_concentration',
            ))
              _ConcentrationClaim(claim: claim),
          ],
          if (emptySections.isNotEmpty) ...[
            _section('not_sourced', l.detailNotYetSourced),
            FeCard(
              key: const Key('entry.notSourced'),
              padding: const EdgeInsets.all(FeSpace.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [for (final (_, title) in emptySections) title]
                        .join(FeGlyphs.middleDot),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    l.detailNoContentYet,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: FeTheme.of(context).textSecondary),
                  ),
                  if (!presentFields.contains('reported_concentration')) ...[
                    const SizedBox(height: FeSpace.xs),
                    FeBanner(
                      icon: Icons.gavel_outlined,
                      text: l.detailConcentrationsNote,
                      tone: FeBannerTone.warning,
                    ),
                  ],
                ],
              ),
            ),
          ],
          SubstanceProvenanceSections(entityId: entry.id),
          KeyedSubtree(
            key: _anchor('jurisdiction'),
            child: _ContentJurisdictionLayer(entry: entry),
          ),
        ],
        KeyedSubtree(
          key: _anchor('related'),
          child: RelatedSection(entityId: entry.id),
        ),
        _section('sources', l.detailReferences),
        if (d.allSources.isEmpty)
          Text(
            l.noReliableSource,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: FeTheme.of(context).textSecondary),
          ),
        for (final s in d.allSources)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: SourceTile(source: s),
          ),
      ],
    );
  }
}

/// Xabar qilingan konsentratsiya: namuna va kontekst chiplari + asl jumla.
class _ConcentrationClaim extends StatelessWidget {
  const _ConcentrationClaim({required this.claim});

  final ClaimView claim;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final specimens = [
      for (final s in (claim.value['specimen'] as List? ?? const [])) '$s',
    ];
    final context0 = claim.value['context'] as String?;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (claim.strictContext == null)
            Wrap(
              spacing: FeSpace.xs,
              runSpacing: FeSpace.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(l.concentrationSpecimen, style: t.labelMedium),
                for (final s in specimens)
                  StatusChip(
                    icon: Icons.water_drop_outlined,
                    label: s,
                    color: c.textSecondary,
                  ),
              ],
            ),
          if (claim.strictContext != null)
            StrictContextTable(claim: claim)
          else if (context0 != null)
            Text(
              l.concentrationContext(context0),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          const SizedBox(height: FeSpace.xxs),
          ClaimCard(claim: claim),
        ],
      ),
    );
  }
}

/// Lifetime’ga taklif — soxta shoshirish yoki chegirmasiz.
class LockedContentCard extends StatelessWidget {
  const LockedContentCard({super.key});

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
              Icon(Icons.lock_outline, color: c.accent),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(l.lockedTitle, style: t.titleSmall),
                ),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            l.lockedBody,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.sm),
          FilledButton(
            key: const Key('locked.unlock'),
            onPressed: () => context.push(Routes.purchase),
            child: Text(l.purchaseCta),
          ),
        ],
      ),
    );
  }
}

class _ProvenanceCard extends StatelessWidget {
  const _ProvenanceCard({required this.entry});

  final LibraryEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final d = entry.details!;
    final reviews = d.claims.fold<int>(0, (a, x) => a + x.reviewCount);
    final draft = d.translationStatus.values.any((s) => s != 'reviewed');
    Widget row(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Wrap(
        spacing: FeSpace.xs,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(label, style: t.bodySmall?.copyWith(color: c.textSecondary)),
          value,
        ],
      ),
    );
    return FeCard(
      key: const Key('entry.provenance'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(l.detailProvenance, style: t.titleSmall),
          ),
          const SizedBox(height: FeSpace.xxs),
          row(l.detailEvidenceStatus, ReviewStatusBadge(status: entry.status)),
          row(
            l.detailReviewerStatus,
            Text(
              reviews == 0
                  ? l.detailReviewsNone
                  : l.detailReviewsCount(reviews),
              key: const Key('entry.reviewStatus'),
              style: t.bodySmall,
            ),
          ),
          if (draft)
            row(
              '',
              Text(
                l.detailTranslationDraft,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

class ClaimCard extends StatelessWidget {
  const ClaimCard({super.key, required this.claim});

  final ClaimView claim;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final excerpt = claim.excerpt;
    final source = claim.sources.isEmpty ? null : claim.sources.first;

    final identityRows = claim.field == 'identity'
        ? [
            ('PubChem CID', '${claim.value['pubchem_cid']}'),
            (l.detailMolecularFormula, '${claim.value['molecular_formula']}'),
            (l.detailMolecularWeight, '${claim.value['molecular_weight']}'),
            ('InChIKey', '${claim.value['inchikey']}'),
            (l.detailIupac, '${claim.value['iupac_name']}'),
          ]
        : const <(String, String)>[];

    return FeCard(
      key: Key('claim.${claim.claimId}'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClaimLifecycleBanners(claim: claim),
          ClaimMeta(status: claim.status, level: claim.evidenceLevel),
          const SizedBox(height: FeSpace.xs),
          for (final (k, v) in identityRows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Wrap(
                spacing: FeSpace.xs,
                children: [
                  Text(k, style: t.bodySmall?.copyWith(color: c.textSecondary)),
                  SelectableText(
                    v,
                    style: FeThemeBuilder.numeric(t.bodySmall!),
                  ),
                ],
              ),
            ),
          if (claim.items.isNotEmpty && claim.field != 'identity')
            Wrap(
              spacing: FeSpace.xs,
              runSpacing: FeSpace.xxs,
              children: [
                for (final i in claim.items)
                  Chip(label: Text(i), visualDensity: VisualDensity.compact),
              ],
            ),
          if (claim.field != 'identity') ...[
            const SizedBox(height: FeSpace.xs),
            if (excerpt != null)
              DecoratedBox(
                key: Key('claim.excerpt.${claim.claimId}'),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: c.accent, width: 3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: FeSpace.sm),
                  child: SourceQuote(
                    target: TextTranslationTarget.claimExcerpt,
                    id: claim.claimId,
                    text: excerpt,
                    label: l.detailExcerpt,
                  ),
                ),
              )
            else
              Text(
                l.detailExcerptWithheld,
                key: Key('claim.withheld.${claim.claimId}'),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
          ],
          if (source != null) ...[
            const SizedBox(height: FeSpace.xs),
            Text(
              [
                source.title,
                if (source.journal != null) source.journal!,
                if (source.year != null) '${source.year}',
                if (source.locator != null)
                  localizedSectionRef(l, source.locator!),
              ].join(' · '),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
          ProvenanceButton(claim: claim),
        ],
      ),
    );
  }
}

/// Manba kartochkasi — DOI/URL tanlab nusxalanadi (offline; brauzer
/// plagini yo‘q).
class SourceTile extends StatelessWidget {
  const SourceTile({super.key, required this.source, this.linkToDetail = true});

  final SourceView source;

  /// Bosilganda manba sahifasiga (bog‘langan yozuvlar) o‘tadi.
  final bool linkToDetail;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final link = source.doi != null
        ? 'https://doi.org/${source.doi}'
        : source.url;
    String date(DateTime d) => feDate(context, d);
    return FeCard(
      key: Key('source.${source.sourceId}'),
      padding: const EdgeInsets.all(FeSpace.sm),
      onTap: linkToDetail
          ? () => context.push(Routes.source(source.sourceId))
          : null,
      semanticLabel: linkToDetail ? l.sourceOpenDetails : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  source.title,
                  style: t.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                  locale: const Locale('en'),
                ),
              ),
              if (linkToDetail)
                Icon(Icons.chevron_right, size: 20, color: c.textSecondary),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            [
              if (source.organization != null) source.organization!,
              if (source.journal != null) source.journal!,
              if (source.year != null) '${source.year}',
              if (source.edition != null) source.edition!,
            ].join(' · '),
            style: t.bodySmall?.copyWith(
              color: c.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: FeSpace.xxs),
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xxs,
            children: [
              StatusChip(
                icon: Icons.layers_outlined,
                label: l.detailEvidenceLevel(source.evidenceLevel),
                color: c.textSecondary,
              ),
              if (source.identifierVerified)
                StatusChip(
                  icon: Icons.fact_check_outlined,
                  label: l.detailIdentifierVerified,
                  color: c.textSecondary,
                ),
            ],
          ),
          if (source.pmid != null)
            SelectableText(
              l.sourcePmid(source.pmid!),
              style: FeThemeBuilder.numeric(t.bodySmall!)
                  .copyWith(color: c.textSecondary),
            ),
          if (source.accessedDate != null)
            Text(
              l.detailSourceAccessed(date(source.accessedDate!)),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          if (link != null)
            Row(
              children: [
                Expanded(
                  // Uzun havola o‘rniga faqat domen; to‘liq havola nusxalanadi.
                  child: Text(
                    source.doi != null
                        ? 'DOI ${source.doi}'
                        : Uri.tryParse(link)?.host.replaceFirst('www.', '') ??
                              link,
                    style: t.bodySmall?.copyWith(color: c.accent),
                    semanticsLabel: link,
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () => Clipboard.setData(ClipboardData(text: link)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Yurisdiksiya qatlami — kontent paketidagi qoidalar (ilmiy dalildan
/// alohida). Tanlangan yurisdiksiya zanjiri (masalan `UZ → INT`) bo‘yicha.
class _ContentJurisdictionLayer extends ConsumerWidget {
  const _ContentJurisdictionLayer({required this.entry});

  final LibraryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final selectedId = ref.watch(settingsControllerProvider).jurisdictionId;
    final resolver = ref.watch(jurisdictionResolverProvider);
    final view =
        resolver.view(
          jurisdictionId: selectedId,
          subjectType: 'substance',
          subjectId: entry.id,
          at: DateTime.now(),
          includeUnreviewed: ref.watch(showUnreviewedLegalProvider),
        ) ??
        resolver.view(
          jurisdictionId: internationalJurisdictionId,
          subjectType: 'substance',
          subjectId: entry.id,
          at: DateTime.now(),
          includeUnreviewed: ref.watch(showUnreviewedLegalProvider),
        )!;
    final selected = view.jurisdiction;
    final rules = view.rules;
    final hasNational = [for (final (_, i) in rules) i.jurisdictionId]
        .any((id) => id != internationalJurisdictionId);
    final hasTopic = [for (final (r, _) in rules) r.topicKey]
        .any((k) => k != null);

    return Column(
      key: const Key('entry.layer.jurisdiction'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(
          l.detailLayerJurisdiction(selected.name(lang)),
          actionLabel: l.detailChangeJurisdiction,
          onAction: () => context.push(Routes.profileJurisdiction),
        ),
        Text(l.detailLegalStatus, style: t.titleSmall),
        const SizedBox(height: FeSpace.xxs),
        for (final (rule, instrument) in rules)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: LegalRuleCard(
              rule: rule,
              instrument: instrument,
              overrides: [
                for (final (o, oi) in view.overridden)
                  if (o.topicKey == rule.topicKey)
                    resolver.byId(oi.jurisdictionId),
              ].nonNulls.firstOrNull,
            ),
          ),
        if (rules.isEmpty)
          FeEmptyState(
            icon: Icons.gavel_outlined,
            body: l.jurisdictionNoContent,
            compact: true,
          ),
        if (selected.id != internationalJurisdictionId && !hasNational)
          FeEmptyState(
            key: const Key('legal.noNational'),
            icon: Icons.flag_outlined,
            body: l.legalNoNational(selected.name(lang)),
            compact: true,
          ),
        FeBanner(icon: Icons.info_outline, text: l.legalNotInListNote),
        if (hasTopic)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const Key('legal.openCompare'),
              icon: const Icon(Icons.compare_arrows),
              label: Text(l.legalOpenCompare),
              onPressed: () => context.push(Routes.compare),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: FeSpace.xs, bottom: 4),
          child: Text(l.detailNationalMethods, style: t.titleSmall),
        ),
        FeEmptyState(
          icon: Icons.rule_folder_outlined,
          body: l.jurisdictionNoContent,
          compact: true,
        ),
      ],
    );
  }
}

/// «Bepul demo» yoki «Lifetime» belgisi (ikonka + matn, faqat rangga
/// tayanmaydi).
class AccessBadge extends ConsumerWidget {
  const AccessBadge({super.key, required this.access, this.compact = false});

  final EntryAccess access;

  /// Ro‘yxat uchun ixcham ko‘rinish (kichik belgi va xira matn).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final unlocked = AccessPolicy.unlocks(
      ProductFeature.substanceLibrary,
      ref.watch(accessProvider),
    );
    if (compact) {
      final free = access == EntryAccess.free;
      final label = free ? l.freeDemoBadge : l.lockedBadge;
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: Row(
          key: Key(free ? 'badge.freeDemo' : 'badge.lifetime'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              free
                  ? Icons.lock_open_outlined
                  : unlocked
                  ? Icons.workspace_premium_outlined
                  : Icons.lock_outline,
              size: 13,
              color: free ? c.accent : c.textSecondary,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: c.textSecondary),
              ),
            ),
          ],
        ),
      );
    }
    if (access == EntryAccess.free) {
      return StatusChip(
        key: const Key('badge.freeDemo'),
        icon: Icons.lock_open_outlined,
        label: l.freeDemoBadge,
        color: c.accent,
      );
    }
    return StatusChip(
      key: const Key('badge.lifetime'),
      icon: unlocked ? Icons.workspace_premium_outlined : Icons.lock_outline,
      label: l.lockedBadge,
      color: c.textSecondary,
    );
  }
}

/// Claim holati + dalil darajasi — bitta ixcham qator.
class ClaimMeta extends StatelessWidget {
  const ClaimMeta({super.key, required this.status, required this.level});

  final ScientificStatus status;
  final String level;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final (label, color, icon) = switch (status) {
      ScientificStatus.verified => (
        l.statusVerified,
        c.verified,
        Icons.verified_outlined,
      ),
      ScientificStatus.reviewed => (
        l.statusReviewed,
        c.reviewed,
        Icons.fact_check_outlined,
      ),
      ScientificStatus.outdated => (
        l.statusOutdated,
        c.outdated,
        Icons.history,
      ),
      ScientificStatus.rejected => (l.statusNeedsReview, c.danger, Icons.block),
      _ => (l.statusNeedsReview, c.accent, Icons.pending_outlined),
    };
    return EvidenceMetaLine(
      statusLabel: label,
      statusIcon: icon,
      statusColor: color,
      level: level,
      levelLabel: l.detailEvidenceLevel(level),
    );
  }
}
