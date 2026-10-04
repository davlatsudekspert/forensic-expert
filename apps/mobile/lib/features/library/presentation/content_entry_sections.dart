import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../core/widgets/fe_data_components.dart';
import '../../../domain/library/library_models.dart';
import '../../legal/presentation/legal_rule_card.dart';

/// Kontent paketidan kelgan yozuv uchun bo‘limlar.
///
/// Paywall qoidasi: nomlar, ogohlantirishlar, provenance va **manbalar**
/// hech qachon yopilmaydi. Lifetime’siz faqat ilmiy tafsilotlar va
/// yurisdiksiya qatlami yopiladi.
class ContentEntryBody extends ConsumerWidget {
  const ContentEntryBody({super.key, required this.entry});

  final LibraryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final d = entry.details!;
    final unlocked =
        entry.access == EntryAccess.free ||
        ref.watch(accessProvider).hasFullAccess;

    final scientificFields = [
      ('identity', l.detailIdentity),
      ('metabolites', l.detailMetabolites),
      ('metabolism_note', l.detailMetabolismNote),
      ('biomarker', l.detailBiomarker),
      ('transformation_product', l.detailTransformationProduct),
    ];
    final presentFields = {for (final c in d.claims) c.field};
    final emptySections = [
      (Icons.category_outlined, l.detailClass),
      if (!presentFields.contains('metabolites'))
        (Icons.account_tree_outlined, l.detailMetabolites),
      (Icons.water_drop_outlined, l.detailSpecimens),
      (Icons.biotech_outlined, l.detailMethods),
      (Icons.show_chart, l.detailConcentrations),
      (Icons.psychology_alt_outlined, l.detailInterpretation),
      (Icons.ac_unit, l.detailStability),
      (Icons.compare_arrows, l.detailInterferences),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProvenanceCard(entry: entry),
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
            if (d.claim(field) case final claim?) ...[
              FeSectionHeader(title),
              ClaimCard(claim: claim),
            ],
          for (final (icon, title) in emptySections) ...[
            FeSectionHeader(title),
            if (title == l.detailConcentrations) ...[
              FeBanner(
                icon: Icons.gavel_outlined,
                text: l.detailConcentrationsNote,
                tone: FeBannerTone.warning,
              ),
              const SizedBox(height: FeSpace.xs),
            ],
            FeEmptyState(icon: icon, body: l.detailNoContentYet, compact: true),
          ],
          _ContentJurisdictionLayer(entry: entry),
        ],
        FeSectionHeader(l.detailReferences),
        for (final s in d.allSources)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: SourceTile(source: s),
          ),
      ],
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
    final claimVersion = d.claims.isEmpty
        ? 1
        : d.claims.map((x) => x.version).reduce((a, b) => a > b ? a : b);
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
          row(
            l.detailVersion,
            Text(
              l.detailVersionValue(claimVersion, d.packVersion),
              style: FeThemeBuilder.numeric(t.bodySmall!),
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
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ReviewStatusBadge(status: claim.status),
              EvidenceLevelBadge(
                level: claim.evidenceLevel,
                label: l.detailEvidenceLevel(claim.evidenceLevel),
              ),
            ],
          ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.detailExcerpt,
                        style: t.labelSmall?.copyWith(color: c.textSecondary),
                      ),
                      Text(
                        excerpt,
                        locale: const Locale('en'),
                        style: t.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
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
                if (source.locator != null) '§ ${source.locator}',
              ].join(' · '),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Manba kartochkasi — DOI/URL tanlab nusxalanadi (offline; brauzer
/// plagini yo‘q).
class SourceTile extends StatelessWidget {
  const SourceTile({super.key, required this.source});

  final SourceView source;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final link = source.doi != null
        ? 'https://doi.org/${source.doi}'
        : source.url;
    String date(DateTime d) =>
        MaterialLocalizations.of(context).formatMediumDate(d);
    return FeCard(
      key: Key('source.${source.sourceId}'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(source.title, style: t.bodyMedium, locale: const Locale('en')),
          const SizedBox(height: 2),
          Text(
            [
              if (source.organization != null) source.organization!,
              if (source.journal != null) source.journal!,
              if (source.year != null) '${source.year}',
              if (source.edition != null) source.edition!,
            ].join(' · '),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
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
          if (source.accessedDate != null)
            Text(
              l.detailSourceAccessed(date(source.accessedDate!)),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
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
  const AccessBadge({super.key, required this.access});

  final EntryAccess access;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final unlocked = ref.watch(accessProvider).hasFullAccess;
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
