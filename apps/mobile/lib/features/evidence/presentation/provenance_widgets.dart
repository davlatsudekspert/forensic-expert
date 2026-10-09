import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/account.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/evidence/provenance_models.dart';
import '../../../domain/library/library_models.dart';
import 'source_quote.dart';

/// PHASE 7 yorliqlari (enum → lokal matn).
extension ProvenanceStrings on AppLocalizations {
  String tierLabel(SourceHierarchy h) => switch (h) {
    SourceHierarchy.a => provTierA,
    SourceHierarchy.b => provTierB,
    SourceHierarchy.c => provTierC,
  };

  String reuseLabel(ReuseStatus r) => switch (r) {
    ReuseStatus.openReuse => reuseOpen,
    ReuseStatus.citeOnly => reuseCiteOnly,
    ReuseStatus.nonCommercial => reuseNonCommercial,
    ReuseStatus.licenseRequired => reuseLicenseRequired,
    ReuseStatus.lookupOnly => reuseLookup,
    ReuseStatus.unknown => reuseUnknown,
  };

  String sourceLifecycleLabel(SourceLifecycle s) => switch (s) {
    SourceLifecycle.current => srcLifecycleCurrent,
    SourceLifecycle.retracted => srcLifecycleRetracted,
    SourceLifecycle.superseded => srcLifecycleSuperseded,
    SourceLifecycle.withdrawn => srcLifecycleWithdrawn,
  };

  String lifecycleLabel(ClaimLifecycle s) => switch (s) {
    ClaimLifecycle.current => lcCurrent,
    ClaimLifecycle.needsReview => lcNeedsReview,
    ClaimLifecycle.outdated => lcOutdated,
    ClaimLifecycle.superseded => lcSuperseded,
    ClaimLifecycle.retracted => lcRetracted,
    ClaimLifecycle.rejected => lcRejected,
  };

  String roleLabel(ReviewerRole r) => switch (r) {
    ReviewerRole.forensicToxicology => roleForensicToxicology,
    ReviewerRole.forensicMedicine => roleForensicMedicine,
    ReviewerRole.laboratoryAnalytical => roleLaboratory,
    ReviewerRole.forensicBiochemistry => roleBiochemistry,
    ReviewerRole.legalJurisdiction => roleLegal,
    ReviewerRole.translation => roleTranslation,
    ReviewerRole.scientificEditor => roleEditor,
  };

  String conflictKindLabel(ConflictKind k) => switch (k) {
    ConflictKind.directContradiction => conflictKindDirect,
    ConflictKind.contextDependent => conflictKindContext,
    ConflictKind.valueOverlap => conflictKindOverlap,
    ConflictKind.inconsistentCharacterisation => conflictKindCharacterisation,
  };

  String metaboliteKindLabel(MetaboliteRelationKind k) => switch (k) {
    MetaboliteRelationKind.metabolite => metKindMetabolite,
    MetaboliteRelationKind.activeMetabolite => metKindActive,
    MetaboliteRelationKind.inactiveMetabolite => metKindInactive,
    MetaboliteRelationKind.marker => metKindMarker,
    MetaboliteRelationKind.artifact => metKindArtifact,
  };

  String specimenCategoryLabel(String c) => switch (c) {
    'tissue' => specimenCatTissue,
    'keratinous' => specimenCatKeratinous,
    'content' => specimenCatContent,
    _ => specimenCatFluid,
  };

  String standardStatusLabel(StandardView s) => switch (s.status) {
    StandardStatus.current => stdStatusCurrent,
    StandardStatus.proposed => stdStatusProposed,
    StandardStatus.superseded => stdStatusSuperseded(s.supersededBy ?? ''),
    StandardStatus.withdrawn => stdStatusWithdrawn,
    StandardStatus.unknown => stdStatusUnknown,
  };
}

/// Claim domeni → kerakli reviewer roli (review paketlari bilan bir xil).
ReviewerRole requiredRoleFor(ClaimView claim) {
  final e = claim.entityId ?? '';
  if (e.startsWith('bio-')) return ReviewerRole.forensicBiochemistry;
  if (claim.field == 'analytical_method') {
    return ReviewerRole.laboratoryAnalytical;
  }
  if (e.startsWith('fm-') || e.startsWith('his-')) {
    return ReviewerRole.forensicMedicine;
  }
  if (e.startsWith('method-')) return ReviewerRole.laboratoryAnalytical;
  return ReviewerRole.forensicToxicology;
}

/// Claim ustidagi ogohlantirishlar: manba retraksiyasi / almashtirilishi /
/// eskirganlik va «EVIDENCE CONFLICT».
class ClaimLifecycleBanners extends StatelessWidget {
  const ClaimLifecycleBanners({super.key, required this.claim});

  final ClaimView claim;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final banners = <Widget>[
      if (claim.lifecycle == ClaimLifecycle.retracted)
        FeBanner(
          key: Key('claim.retracted.${claim.claimId}'),
          icon: Icons.report_outlined,
          text: l.bannerRetracted,
          tone: FeBannerTone.critical,
        ),
      if (claim.lifecycle == ClaimLifecycle.superseded)
        FeBanner(
          key: Key('claim.superseded.${claim.claimId}'),
          icon: Icons.history,
          text: l.bannerSuperseded,
          tone: FeBannerTone.warning,
        ),
      if (claim.lifecycle == ClaimLifecycle.outdated)
        FeBanner(
          icon: Icons.history,
          text: l.bannerOutdated,
          tone: FeBannerTone.warning,
        ),
      for (final id in claim.conflictIds)
        Semantics(
          button: true,
          child: InkWell(
            key: Key('claim.conflict.${claim.claimId}.$id'),
            onTap: () => context.push(Routes.conflict(id)),
            child: FeBanner(
              icon: Icons.compare_arrows,
              text: l.bannerConflict,
              tone: FeBannerTone.warning,
            ),
          ),
        ),
    ];
    if (banners.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: FeSpace.xxs,
        children: banners,
      ),
    );
  }
}

/// «Bu ma’lumot qayerdan?» — bir bosishda to‘liq provenance.
class ProvenanceButton extends StatelessWidget {
  const ProvenanceButton({super.key, required this.claim});

  final ClaimView claim;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        key: Key('claim.provenance.${claim.claimId}'),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          // Kamida 48 dp bosish maydoni (a11y).
          minimumSize: const Size(48, 48),
        ),
        icon: const Icon(Icons.travel_explore, size: 18),
        label: Text(l.provWhereFrom),
        onPressed: () => showProvenanceSheet(context, claim),
      ),
    );
  }
}

Future<void> showProvenanceSheet(BuildContext context, ClaimView claim) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, controller) =>
            ProvenanceSheet(claim: claim, controller: controller),
      ),
    );

class ProvenanceSheet extends ConsumerWidget {
  const ProvenanceSheet({super.key, required this.claim, this.controller});

  final ClaimView claim;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final index = ref.watch(provenanceIndexProvider);
    // Ichki yozuv ID’si faqat admin uchun (oddiy foydalanuvchiga keraksiz).
    final isAdmin = ref.watch(serverAccessProvider).value?.isAdmin ?? false;
    final verified = claim.status == ScientificStatus.verified;
    final role = requiredRoleFor(claim);
    final location = claim.value['section'] as String?;
    Widget label(String s) => Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm, bottom: FeSpace.xxs),
      child: Semantics(header: true, child: Text(s, style: t.titleSmall)),
    );
    Widget line(String s, {Color? color, Key? key}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        s,
        key: key,
        style: t.bodySmall?.copyWith(color: color ?? c.textSecondary),
      ),
    );

    return ListView(
      key: const Key('provenance.sheet'),
      controller: controller,
      padding: const EdgeInsets.fromLTRB(FeSpace.md, 0, FeSpace.md, FeSpace.lg),
      children: [
        Text(l.provSheetTitle, style: t.titleMedium),
        const SizedBox(height: FeSpace.xs),
        FeBanner(
          key: const Key('provenance.verification'),
          icon: verified ? Icons.verified_outlined : Icons.pending_outlined,
          text: verified ? l.provHumanVerified : l.provNotVerified,
          tone: verified ? FeBannerTone.info : FeBannerTone.review,
        ),
        const SizedBox(height: FeSpace.xs),
        ClaimLifecycleBanners(claim: claim),
        label(l.provStatement),
        if (claim.excerpt != null)
          SourceQuote(
            target: TextTranslationTarget.claimExcerpt,
            id: claim.claimId,
            text: claim.excerpt!,
            large: true,
          )
        else
          line(l.detailExcerptWithheld),
        if (location != null)
          line(l.provLocation(localizedSectionName(l, location))),
        line(
          '${l.provLifecycle}: ${l.lifecycleLabel(claim.lifecycle)}',
          key: const Key('provenance.lifecycle'),
          color: claim.lifecycle == ClaimLifecycle.retracted
              ? c.danger
              : c.textSecondary,
        ),
        if (isAdmin) line(l.provClaimId(claim.claimId, claim.version)),
        line(l.provRequiredRole(l.roleLabel(role))),
        line(l.provReviewsRecorded(claim.reviewCount)),
        for (final s in claim.sources) ...[
          label(l.provSource),
          _SourceProvenanceBlock(source: s),
        ],
        for (final id in claim.conflictIds)
          if (index.conflict(id) case final k?) ...[
            label(l.conflictsTitle),
            _ConflictSummary(conflict: k),
          ],
      ],
    );
  }
}

class _SourceProvenanceBlock extends StatelessWidget {
  const _SourceProvenanceBlock({required this.source});

  final SourceView source;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final link = source.doi != null
        ? 'https://doi.org/${source.doi}'
        : source.url;
    final muted = t.bodySmall?.copyWith(color: c.textSecondary);
    return FeCard(
      key: Key('provenance.source.${source.sourceId}'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(source.title, style: t.bodyMedium, locale: const Locale('en')),
          Text(
            [
              if (source.organization != null) source.organization!,
              if (source.journal != null) source.journal!,
              if (source.year != null) '${source.year}',
              if (source.locator != null)
                localizedSectionRef(l, source.locator!),
            ].join(FeGlyphs.middleDot),
            style: muted,
          ),
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xxs,
            children: [
              if (source.hierarchy != null)
                StatusChip(
                  icon: Icons.account_tree_outlined,
                  label: l.tierLabel(source.hierarchy!),
                  color: c.textSecondary,
                ),
              StatusChip(
                icon: Icons.copyright_outlined,
                label: l.reuseLabel(source.reuseStatus),
                color: source.reuseStatus == ReuseStatus.licenseRequired
                    ? c.warning
                    : c.textSecondary,
              ),
              StatusChip(
                key: Key('provenance.sourceLifecycle.${source.sourceId}'),
                icon: source.isRetracted
                    ? Icons.report_outlined
                    : Icons.check_circle_outline,
                label: l.sourceLifecycleLabel(source.lifecycle),
                color: source.isRetracted ? c.danger : c.textSecondary,
              ),
              StatusChip(
                icon: Icons.layers_outlined,
                label: l.detailEvidenceLevel(source.evidenceLevel),
                color: c.textSecondary,
              ),
            ],
          ),
          if (source.lifecycleBasis != null &&
              source.lifecycle != SourceLifecycle.current)
            Text(source.lifecycleBasis!, style: muted),
          if (source.lifecycleCheckedAt != null)
            Text(
              l.provCheckedOn(feDate(context, source.lifecycleCheckedAt!)),
              style: muted,
            ),
          if (source.sourceVersion != null)
            Text(l.provSourceVersion(source.sourceVersion!), style: muted),
          if (source.accessedDate != null)
            Text(
              l.detailSourceAccessed(feDate(context, source.accessedDate!)),
              style: muted,
            ),
          if (source.sha256 != null) ...[
            Text(l.provArchiveHash, style: muted),
            SelectableText(
              source.sha256!,
              style: FeThemeBuilder.numeric(t.labelSmall!),
            ),
          ],
          if (source.pmid != null)
            SelectableText(
              'PMID ${source.pmid}',
              style: FeThemeBuilder.numeric(t.bodySmall!),
            ),
          if (link != null)
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    link,
                    style: FeThemeBuilder.numeric(t.bodySmall!)
                        .copyWith(color: c.accent),
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

class _ConflictSummary extends StatelessWidget {
  const _ConflictSummary({required this.conflict});

  final ConflictView conflict;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      padding: const EdgeInsets.all(FeSpace.sm),
      onTap: () => context.push(Routes.conflict(conflict.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Text(l.conflictKindLabel(conflict.kind), style: t.labelLarge),
          Text(
            conflict.question,
            locale: const Locale('en'),
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Konsentratsiya dalili kartasi: modda, qiymat, namuna, tirik/o‘limdan
/// keyin, manba turi, holat/tadqiqot konteksti, metod, birga ta’sir,
/// cheklovlar, dalil darajasi, tekshiruv holati va manba. Faqat manbada
/// aytilgani; kuratsiya qilinmagan maydon «Ma’lumot mavjud emas», manbada
/// aytilmagani «manbada ko‘rsatilmagan». Har kartada: qiymat universal
/// chegara EMAS (konsentratsiya ≠ universal chegara).
class StrictContextTable extends ConsumerWidget {
  const StrictContextTable({super.key, required this.claim});

  final ClaimView claim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctx = claim.strictContext;
    if (ctx == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final index = ref.watch(provenanceIndexProvider);
    final library = ref.watch(libraryRepositoryProvider);
    const ns = StrictConcentrationContext.notStated;
    final auto = ctx['curation'] == 'auto_minimal';
    final na = l.concNotAvailable;

    String value(String key) {
      if (auto) return na;
      final v = ctx[key];
      if (v == null || v == ns) return l.ctxNotStated;
      return switch ('$key:$v') {
        'sampling:postmortem' => l.ctxPostmortem,
        'sampling:antemortem' => l.ctxAntemortem,
        'sampling:mixed' || 'subject_state:mixed' => l.ctxMixed,
        'subject_state:deceased' => l.ctxDeceased,
        'subject_state:living' => l.ctxLiving,
        'reporting:primary' => l.ctxPrimary,
        'reporting:secondary_citation' => l.ctxSecondary,
        'reporting:not_assessed' => l.ctxNotAssessed,
        _ => '$v',
      };
    }

    String livingPostmortem() {
      if (auto) return na;
      final parts = [
        for (final k in ['subject_state', 'sampling'])
          if (ctx[k] != null && ctx[k] != ns) value(k),
      ];
      return parts.isEmpty ? l.ctxNotStated : parts.join(' · ');
    }

    String studyContext() {
      if (auto) return na;
      final parts = [
        for (final k in ['case_type', 'population', 'study_size'])
          if (ctx[k] != null && ctx[k] != ns) value(k),
      ];
      return parts.isEmpty ? l.ctxNotStated : parts.join(' · ');
    }

    final section = switch (claim.value['section']) {
      'CASE' => l.concSectionCase,
      'ABSTRACT' => l.concSectionAbstract,
      'INTRO' => l.concSectionIntro,
      'RESULTS' => l.concSectionResults,
      'DISCUSS' => l.concSectionDiscussion,
      _ => na,
    };
    final specimens = [
      for (final s in (ctx['specimen'] as List? ?? const []))
        index.specimen('$s')?.names.resolve(lang) ?? '$s',
    ];
    final substance = claim.entityId == null
        ? na
        : library.byId(claim.entityId!)?.name.resolve(lang) ?? na;
    final source = claim.sources.isEmpty ? na : claim.sources.first.title;
    final limitations = [
      for (final x in (ctx['limitations'] as List? ?? const [])) '$x',
    ];

    // (sarlavha, qiymat, manba matni — asl tilda qoladi)
    final rows = <(String, String, bool)>[
      (l.concSubstance, substance, false),
      (l.concValue, l.concValueInQuote, false),
      (l.ctxSpecimen, specimens.isEmpty ? na : specimens.join(', '), false),
      (l.concLivingPostmortem, livingPostmortem(), false),
      (l.concSourceType, section, false),
      (l.concStudyContext, studyContext(), true),
      (l.ctxMethod, value('analytical_method'), true),
      (l.ctxCoIntoxicants, value('co_intoxicants'), true),
      if (!auto) (l.ctxTiming, value('timing'), true),
      if (!auto) (l.ctxReporting, value('reporting'), false),
      (l.concEvidenceLevel, claim.evidenceLevel, false),
      (l.concSource, source, true),
    ];
    bool missing(String v) => v == na || v == l.ctxNotStated;

    return FeCard(
      key: Key('claim.context.${claim.claimId}'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: FeSpace.xxs,
        children: [
          Text(l.concTitle, style: t.labelLarge),
          FeBanner(
            key: Key('claim.concWarning.${claim.claimId}'),
            icon: Icons.warning_amber_rounded,
            text: l.concWarning,
            tone: FeBannerTone.critical,
          ),
          if (auto)
            Text(
              l.ctxAutoMinimal,
              key: Key('claim.contextUnavailable.${claim.claimId}'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          for (final (k, v, sourceText) in rows)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(
                spacing: FeSpace.xs,
                children: [
                  Text(k, style: t.bodySmall?.copyWith(color: c.textSecondary)),
                  Text(
                    v,
                    // Manbadan olingan matn asl tilda qoladi.
                    locale: sourceText && !missing(v)
                        ? const Locale('en')
                        : null,
                    style: t.bodySmall?.copyWith(
                      color: missing(v) ? c.textSecondary : null,
                      fontStyle: missing(v) ? FontStyle.italic : null,
                      fontWeight: missing(v) ? null : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Wrap(
            spacing: FeSpace.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.concReviewStatus,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              ReviewStatusBadge(status: claim.status, compact: true),
            ],
          ),
          Text(
            l.ctxLimitations,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          if (limitations.isEmpty)
            Text(
              auto ? na : l.ctxNotStated,
              style: t.bodySmall?.copyWith(
                color: c.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            for (final x in limitations)
              Text(
                '${FeGlyphs.bullet} $x',
                locale: const Locale('en'),
                style: t.bodySmall,
              ),
        ],
      ),
    );
  }
}

/// Modda sahifasi: manbali metabolit munosabatlari va bilim zanjiriga havola.
/// Namunalar va skrining testlari «Tahlil» bo‘limida
/// (`SubstanceAnalysisSection`) ko‘rsatiladi.
class SubstanceProvenanceSections extends ConsumerWidget {
  const SubstanceProvenanceSections({super.key, required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final index = ref.watch(provenanceIndexProvider);
    final ev = ref.watch(evidenceDataProvider);
    final library = ref.watch(libraryRepositoryProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final mets = index.metabolitesOf(entityId);
    final parents = index.parentsOf(entityId);
    // Namuna / skrining bog‘lanishlari «Tahlil» bo‘limida; bu yerda faqat
    // bilim zanjiri havolasi uchun.
    final hasGraph = ev
        .linksFrom(entityId)
        .any(
          (x) =>
              x.relation == LinkRelation.measuredIn ||
              x.relation == LinkRelation.screenedBy,
        );
    String nameOf(String id) =>
        library.byId(id)?.name.resolve(lang) ??
        knowledge.byId(id)?.name.resolve(lang) ??
        index.specimen(id)?.names.resolve(lang) ??
        id;

    Widget metaboliteTile(MetaboliteRelation m, {bool parent = false}) {
      final targetId = parent ? m.parentId : m.metaboliteId;
      final name = parent ? nameOf(m.parentId) : m.metaboliteName;
      return ListTile(
        key: Key('metabolite.${m.id}'),
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.subdirectory_arrow_right, color: c.accent),
        title: Text(
          parent ? l.metParentOf(name) : name,
          locale: parent ? null : const Locale('en'),
        ),
        subtitle: Text(
          '${l.metaboliteKindLabel(m.kind)}'
          '${FeGlyphs.middleDot}${l.chainBasis(m.basisClaimId)}',
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        trailing: targetId != null && library.byId(targetId) != null
            ? const Icon(Icons.chevron_right)
            : null,
        onTap: () {
          final claim = index.claimsById[m.basisClaimId];
          if (targetId != null && library.byId(targetId) != null) {
            context.push(Routes.libraryEntry(targetId));
          } else if (claim != null) {
            showProvenanceSheet(context, claim);
          }
        },
      );
    }

    final hasAny = mets.isNotEmpty || parents.isNotEmpty || hasGraph;
    return Column(
      key: Key('substance.p7.$entityId'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mets.isNotEmpty || parents.isNotEmpty) ...[
          FeSectionHeader(l.metRelationsTitle),
          for (final m in parents) metaboliteTile(m, parent: true),
          for (final m in mets) metaboliteTile(m),
          Text(
            l.metRoleNote,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
        if (hasAny)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: Key('chain.open.$entityId'),
              icon: const Icon(Icons.account_tree_outlined),
              label: Text(l.chainOpen),
              onPressed: () => context.push(Routes.chain(entityId)),
            ),
          ),
      ],
    );
  }
}
