import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/evidence/provenance_models.dart';
import '../../../domain/evidence/substance_analysis.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../legal/presentation/instrument_title.dart';
import '../../legal/presentation/jurisdiction_screens.dart';
import '../../library/presentation/content_entry_sections.dart';
import 'localized_content.dart';
import 'provenance_widgets.dart';

Widget _page({
  required Key key,
  required String title,
  required List<Widget> children,
}) => Scaffold(
  appBar: AppBar(title: Text(title)),
  body: SafeArea(
    child: ListView(
      key: key,
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: FeSpace.sm),
              ...children,
              const SizedBox(height: FeSpace.lg),
            ],
          ),
        ),
      ],
    ),
  ),
);

/// Barcha ochiq «EVIDENCE CONFLICT» yozuvlari.
class ConflictsScreen extends ConsumerWidget {
  const ConflictsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final index = ref.watch(provenanceIndexProvider);
    return _page(
      key: const Key('conflicts.list'),
      title: l.conflictsTitle,
      children: [
        FeBanner(icon: Icons.compare_arrows, text: l.conflictsIntro),
        const SizedBox(height: FeSpace.sm),
        if (index.conflicts.isEmpty)
          FeEmptyState(
            icon: Icons.inventory_2_outlined,
            body: l.knowledgeEmpty,
          ),
        for (final k in index.conflicts)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: FeCard(
              key: Key('conflicts.${k.id}'),
              padding: const EdgeInsets.all(FeSpace.sm),
              onTap: () => context.push(Routes.conflict(k.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(l.conflictKindLabel(k.kind), style: t.labelLarge),
                  LocalizedInlineText(
                    kind: ContentTextKind.conflictQuestion,
                    id: k.id,
                    source: k.question,
                    style: t.bodyMedium,
                  ),
                  Text(
                    k.state == EvidenceConflictState.open
                        ? l.conflictStateOpen
                        : l.conflictStateResolved,
                    style: t.bodySmall?.copyWith(color: c.warning),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Bitta ziddiyat: savol, tur, manbalar nima deydi va claim’lar yonma-yon.
class ConflictDetailScreen extends ConsumerWidget {
  const ConflictDetailScreen({super.key, required this.conflictId});

  final String conflictId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final index = ref.watch(provenanceIndexProvider);
    final k = index.conflict(conflictId);
    if (k == null) {
      return _page(
        key: const Key('conflict.missing'),
        title: l.conflictsTitle,
        children: [
          FeEmptyState(
            icon: Icons.inventory_2_outlined,
            body: l.knowledgeEmpty,
          ),
        ],
      );
    }
    return _page(
      key: Key('conflict.$conflictId'),
      title: l.conflictsTitle,
      children: [
        FeBanner(
          icon: Icons.compare_arrows,
          text: l.conflictKindLabel(k.kind),
          tone: FeBannerTone.warning,
        ),
        FeSectionHeader(l.conflictQuestion),
        LocalizedContentText(
          kind: ContentTextKind.conflictQuestion,
          id: k.id,
          source: k.question,
          style: t.bodyMedium,
        ),
        FeSectionHeader(l.conflictNoteLabel),
        LocalizedContentText(
          kind: ContentTextKind.conflictNote,
          id: k.id,
          source: k.note,
          style: t.bodySmall,
        ),
        const SizedBox(height: FeSpace.xs),
        Text(
          k.state == EvidenceConflictState.open
              ? l.conflictStateOpen
              : l.conflictStateResolved,
          key: const Key('conflict.state'),
          style: t.bodySmall?.copyWith(color: c.warning),
        ),
        FeSectionHeader(l.conflictStatements),
        for (final id in k.claimIds)
          if (index.claimsById[id] case final claim?)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (claim.strictContext != null)
                    StrictContextTable(claim: claim),
                  const SizedBox(height: FeSpace.xxs),
                  ClaimCard(claim: claim),
                ],
              ),
            ),
      ],
    );
  }
}

/// Namunalar ro‘yxati.
class SpecimensScreen extends ConsumerWidget {
  const SpecimensScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final index = ref.watch(provenanceIndexProvider);
    return _page(
      key: const Key('specimens.list'),
      title: l.specimensTitle,
      children: [
        FeBanner(icon: Icons.water_drop_outlined, text: l.specimensIntro),
        const SizedBox(height: FeSpace.sm),
        if (index.specimens.isEmpty)
          FeEmptyState(
            icon: Icons.inventory_2_outlined,
            body: l.knowledgeEmpty,
          ),
        for (final s in index.specimens)
          ListTile(
            key: Key('specimens.${s.id}'),
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.water_drop_outlined, color: c.accent),
            title: Text(s.names.resolve(lang)),
            subtitle: Text(
              '${l.specimenCategoryLabel(s.category)}${FeGlyphs.middleDot}'
              '${l.specimenRecords(index.claimsAbout(s.id).length + index.claimsMeasuredIn(s.id).length)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.specimen(s.id)),
          ),
      ],
    );
  }
}

class SpecimenDetailScreen extends ConsumerWidget {
  const SpecimenDetailScreen({super.key, required this.specimenId});

  final String specimenId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final index = ref.watch(provenanceIndexProvider);
    final library = ref.watch(libraryRepositoryProvider);
    final s = index.specimen(specimenId);
    final about = index.claimsAbout(specimenId);
    final measured = index.claimsMeasuredIn(specimenId);
    // Teskari ro‘yxat: shu namunada (manbada qiymat bilan) tahlil qilingan
    // moddalar — `measured_in` bog‘lanishlaridan.
    final substances = [
      for (final id in substancesMeasuredIn(
        ref.watch(evidenceDataProvider),
        specimenId,
      ))
        (id, library.byId(id)?.name.resolve(lang) ?? id),
    ]..sort((a, b) => a.$2.toLowerCase().compareTo(b.$2.toLowerCase()));
    return _page(
      key: Key('specimen.$specimenId'),
      title: s?.names.resolve(lang) ?? specimenId,
      children: [
        if (s != null)
          Text(l.specimenCategoryLabel(s.category), style: t.bodySmall),
        FeSectionHeader(l.specimenSubstancesTitle),
        if (substances.isEmpty)
          FeEmptyState(
            key: Key('specimen.substances.none.$specimenId'),
            icon: Icons.inventory_2_outlined,
            body: l.specimenSubstancesNone,
            compact: true,
          )
        else ...[
          Text(
            l.specimenSubstancesNote,
            style: t.bodySmall?.copyWith(
              color: FeTheme.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          Wrap(
            key: Key('specimen.substances.$specimenId'),
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xxs,
            children: [
              for (final (id, name) in substances)
                ActionChip(
                  key: Key('specimen.substance.$specimenId.$id'),
                  avatar: const Icon(Icons.science_outlined, size: 18),
                  label: Text(name),
                  onPressed: () => context.push(Routes.libraryEntry(id)),
                ),
            ],
          ),
        ],
        FeSectionHeader(l.specimenAbout),
        if (about.isEmpty)
          FeEmptyState(
            icon: Icons.inventory_2_outlined,
            body: l.specimenNoClaims,
            compact: true,
          ),
        for (final claim in about)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: ClaimCard(claim: claim),
          ),
        FeSectionHeader(l.specimenMeasured),
        if (measured.isNotEmpty)
          FeBanner(
            icon: Icons.warning_amber_rounded,
            text: l.concentrationNotThreshold,
            tone: FeBannerTone.critical,
          ),
        if (measured.isEmpty)
          FeEmptyState(
            icon: Icons.inventory_2_outlined,
            body: l.specimenNoClaims,
            compact: true,
          ),
        for (final claim in measured) ...[
          const SizedBox(height: FeSpace.xs),
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              library.byId(claim.entityId ?? '')?.name.resolve(lang) ??
                  claim.entityId ??
                  '',
              style: t.titleSmall,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.libraryEntry(claim.entityId!)),
          ),
          StrictContextTable(claim: claim),
          const SizedBox(height: FeSpace.xxs),
          ClaimCard(claim: claim),
        ],
      ],
    );
  }
}

/// Bilim zanjiri: modda → metabolit → namuna → skrining → tasdiqlovchi metod
/// → reagent → tadqiqot → standart → huquqiy holat. Har bir qirra asosi bilan.
class KnowledgeChainScreen extends ConsumerWidget {
  const KnowledgeChainScreen({super.key, required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final ev = ref.watch(evidenceDataProvider);
    final index = ref.watch(provenanceIndexProvider);
    final library = ref.watch(libraryRepositoryProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final resolver = ref.watch(jurisdictionResolverProvider);
    String nameOf(String id) =>
        library.byId(id)?.name.resolve(lang) ??
        knowledge.byId(id)?.name.resolve(lang) ??
        index.specimen(id)?.names.resolve(lang) ??
        index.standard(id)?.designation ??
        id;

    // Moddaning o‘zi va uning kutubxonadagi metabolitlari bitta zanjirda.
    final mets = index.metabolitesOf(entityId);
    final members = {
      entityId,
      for (final m in mets)
        if (m.metaboliteId != null) m.metaboliteId!,
    };
    List<(String, String)> edges(LinkRelation rel, Iterable<String> from) => [
      for (final id in from)
        for (final x in ev.linksFrom(id))
          if (x.relation == rel) (x.toId, x.basis),
    ];
    final specimens = edges(LinkRelation.measuredIn, members);
    final screening = edges(LinkRelation.screenedBy, members);
    final screeningIds = {for (final (id, _) in screening) id};
    final confirm = [
      ...edges(LinkRelation.confirmedBy, screeningIds),
      ...edges(LinkRelation.analysedBy, [entityId]),
    ];
    final methodIds = {for (final (id, _) in confirm) id};
    final reagents = [
      for (final m in methodIds)
        for (final x in ev.linksTo(m))
          if (x.relation == LinkRelation.usedIn) (x.fromId, x.basis),
    ];
    final standards = [
      for (final m in methodIds)
        for (final x in ev.linksTo(m))
          if (x.relation == LinkRelation.standardFor) (x.fromId, x.basis),
    ];
    final legal = edges(LinkRelation.legalStatus, [entityId]);
    final research = ev.researchFor(entityId);

    Widget step(
      String title,
      List<(String, String)> items, {
      String Function(String id)? route,
      String Function(String id)? label,
    }) {
      final seen = <String>{};
      final unique = [
        for (final e in items)
          if (e case (final id, _) when seen.add(id)) e,
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FeSectionHeader(title),
          if (unique.isEmpty)
            Text(
              l.chainNone,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          for (final (id, basis) in unique)
            ListTile(
              key: Key('chain.$entityId.$id'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(label?.call(id) ?? nameOf(id)),
              subtitle: Text(
                l.chainBasis(basis),
                style: FeThemeBuilder.numeric(t.labelSmall!)
                    .copyWith(color: c.textSecondary),
              ),
              trailing: route == null ? null : const Icon(Icons.chevron_right),
              onTap: () {
                final claim = index.claimsById[basis];
                if (claim != null) {
                  showProvenanceSheet(context, claim);
                } else if (route != null) {
                  context.push(route(id));
                }
              },
            ),
        ],
      );
    }

    String ruleLabel(String ruleId) {
      for (final i in resolver.instruments) {
        if (ruleId.startsWith('R-${i.jurisdictionId}-')) {
          return '${i.jurisdictionId}${FeGlyphs.middleDot}'
              '${instrumentTitleOf(i, lang).text}';
        }
      }
      return ruleId;
    }

    return _page(
      key: Key('chain.$entityId'),
      title: l.chainTitle,
      children: [
        Text(nameOf(entityId), style: t.titleMedium),
        const SizedBox(height: FeSpace.xs),
        FeBanner(icon: Icons.account_tree_outlined, text: l.chainIntro),
        FeSectionHeader(l.chainMetabolites),
        if (mets.isEmpty)
          Text(
            l.chainNone,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        for (final m in mets)
          ListTile(
            key: Key('chain.$entityId.${m.id}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: LocalizedInlineText(
              kind: ContentTextKind.metaboliteName,
              id: m.id,
              source: m.metaboliteName,
            ),
            subtitle: Text(
              '${l.metaboliteKindLabel(m.kind)}${FeGlyphs.middleDot}'
              '${l.chainBasis(m.basisClaimId)}',
              style: t.labelSmall?.copyWith(color: c.textSecondary),
            ),
            onTap: () {
              final claim = index.claimsById[m.basisClaimId];
              if (claim != null) showProvenanceSheet(context, claim);
            },
          ),
        step(l.chainSpecimens, specimens, route: Routes.specimen),
        step(l.chainScreening, screening, route: Routes.knowledgeEntry),
        step(l.chainConfirmation, confirm, route: Routes.knowledgeEntry),
        step(l.chainReagents, reagents, route: Routes.knowledgeEntry),
        FeSectionHeader(l.chainResearch),
        Text(
          research.isEmpty
              ? l.chainNone
              : l.chainResearchCount(research.length),
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        if (research.isNotEmpty)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => context.push(Routes.researchFor(entityId)),
              child: Text(l.researchMore(research.length)),
            ),
          ),
        step(
          l.chainStandards,
          standards,
          route: (_) => Routes.libraryStandards,
        ),
        step(l.chainLegal, legal, label: ruleLabel),
      ],
    );
  }
}

/// Ilmiy tekshiruv holati — bazadagi haqiqiy yozuvlardan.
class ReviewStatusScreen extends ConsumerWidget {
  const ReviewStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final r = ref.watch(provenanceIndexProvider).review;
    Widget metric(String key, String label, int n, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: FeSpace.xxs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: t.bodyMedium)),
          Text(
            '$n',
            key: Key('review.$key'),
            style: FeThemeBuilder.numeric(t.titleMedium!)
                .copyWith(color: color),
          ),
        ],
      ),
    );
    return _page(
      key: const Key('review.status'),
      title: l.reviewTitle,
      children: [
        FeBanner(
          icon: Icons.pending_outlined,
          text: l.provNotVerified,
          tone: FeBannerTone.review,
        ),
        const SizedBox(height: FeSpace.sm),
        FeCard(
          padding: const EdgeInsets.all(FeSpace.sm),
          child: Column(
            children: [
              metric('humanVerified', l.reviewHumanVerified, r.humanVerified),
              metric('reviewed', l.reviewReviewed, r.reviewed),
              metric(
                'awaiting',
                l.reviewAwaiting,
                r.claimsByStatus[ScientificStatus.needsReview] ?? 0,
              ),
              metric(
                'retracted',
                l.reviewRetracted,
                r.claimsByLifecycle[ClaimLifecycle.retracted] ?? 0,
                color: c.danger,
              ),
              metric('conflicts', l.reviewOpenConflicts, r.openConflicts),
              metric('actions', l.reviewActions, r.reviewActions),
              metric('reviewers', l.reviewReviewers, r.reviewers),
            ],
          ),
        ),
        const SizedBox(height: FeSpace.sm),
        Text(
          l.reviewExplain,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        FeSectionHeader(l.reviewRolesTitle),
        for (final role in ReviewerRole.values)
          ListTile(
            key: Key('review.role.${role.code}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              role.approvableDomains.isEmpty
                  ? Icons.flag_outlined
                  : Icons.how_to_reg_outlined,
              color: c.accent,
            ),
            title: Text(l.roleLabel(role)),
            subtitle: Text(
              role.approvableDomains.isEmpty
                  ? l.reviewRoleFlagOnly
                  : l.reviewRoleApprove,
            ),
          ),
        FeSectionHeader(l.reviewActionsList),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xxs,
          children: [
            for (final a in ReviewActionType.values)
              Chip(label: Text(a.code), visualDensity: VisualDensity.compact),
          ],
        ),
      ],
    );
  }
}

/// Standartlar katalogi kartochkasi (faqat metadata).
class StandardCatalogueTile extends StatelessWidget {
  const StandardCatalogueTile({super.key, required this.standard});

  final StandardView standard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final s = standard;
    final muted = t.bodySmall?.copyWith(color: c.textSecondary);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('standards.catalogue.${s.id}'),
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(s.designation, style: t.titleSmall),
            TranslatedTitle(
              kind: ContentTextKind.standardTitle,
              id: s.id,
              title: s.title,
              style: t.bodyMedium,
            ),
            Text(
              [
                s.publisher,
                if (s.year != null) s.year!,
                if (s.edition != null) s.edition!,
              ].join(FeGlyphs.middleDot),
              style: muted,
            ),
            Wrap(
              spacing: FeSpace.xs,
              runSpacing: FeSpace.xxs,
              children: [
                StatusChip(
                  icon: s.status == StandardStatus.superseded
                      ? Icons.history
                      : s.status == StandardStatus.proposed
                      ? Icons.edit_note
                      : Icons.check_circle_outline,
                  label: l.standardStatusLabel(s),
                  color: s.status == StandardStatus.current
                      ? c.textSecondary
                      : c.warning,
                ),
                StatusChip(
                  icon: Icons.copyright_outlined,
                  label: l.reuseLabel(s.reuse),
                  color: s.reuse == ReuseStatus.licenseRequired
                      ? c.warning
                      : c.textSecondary,
                ),
                StatusChip(
                  icon: Icons.description_outlined,
                  label: l.documentKindLabel(s.documentKind),
                  color: c.textSecondary,
                ),
              ],
            ),
            Text(l.stdTextNotReproduced, style: muted),
            Text(
              l.stdVerifiedFrom(feDate(context, s.verifiedAt)),
              style: muted,
            ),
            if (s.note != null)
              LocalizedContentText(
                kind: ContentTextKind.standardNote,
                id: s.id,
                source: s.note!,
                style: muted,
              ),
            if (s.url != null)
              SelectableText(
                s.url!,
                style: FeThemeBuilder.numeric(t.bodySmall!)
                    .copyWith(color: c.accent),
              ),
          ],
        ),
      ),
    );
  }
}

/// Metod yozuvi turi: nashr etilgan ilmiy metod — laboratoriya SOP emas.
bool isPublishedScientificMethod(KnowledgeEntry r) =>
    r.method?.kind == MethodKind.scientificMethod;
