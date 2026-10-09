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
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/library/library_models.dart';
import '../../../domain/professional/review_models.dart';
import '../../../domain/referral/share_text.dart';
import '../../common/favorite_button.dart';
import '../../common/share_button.dart';
import '../../common/view_recorder.dart';
import '../../professional/presentation/review_section.dart';
import '../../support/presentation/support_widgets.dart' show ReportErrorMenu;
import 'content_entry_sections.dart';
import 'library_screen.dart';

/// Kutubxona yozuvi kartochkasi.
///
/// Moddalar uchun kelajakdagi to‘liq tuzilma (Nomlar, Sinf, Metabolitlar,
/// Namunalar, Usullar, Konsentratsiyalar, Talqin, Barqarorlik,
/// Interferensiyalar, Manbalar, Dalil holati, Oxirgi tekshiruv) hozirdan
/// ko‘rsatiladi. Hozircha **har bir bo‘lim — aniq belgilangan placeholder**.
class EntryDetailScreen extends ConsumerWidget {
  const EntryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final entry = ref.watch(libraryRepositoryProvider).byId(entryId);
    if (entry == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final isSubstance = entry.section == LibrarySection.substances;

    final sections = isSubstance
        ? [
            (Icons.category_outlined, l.detailClass),
            (Icons.account_tree_outlined, l.detailMetabolites),
            (Icons.water_drop_outlined, l.detailSpecimens),
            (Icons.biotech_outlined, l.detailMethods),
            (Icons.show_chart, l.detailConcentrations),
            (Icons.psychology_alt_outlined, l.detailInterpretation),
            (Icons.ac_unit, l.detailStability),
            (Icons.compare_arrows, l.detailInterferences),
          ]
        : <(IconData, String)>[];

    final names = <Widget>[
      FeSectionHeader(l.detailNames),
      for (final code in const ['en', 'ru', 'uz'])
        if (entry.name.values[code] != null)
          _KeyValue(
            label: code.toUpperCase(),
            value: Text(
              entry.name.values[code]!,
              locale: Locale(code),
              style: t.bodyMedium,
            ),
          ),
      for (final s in entry.synonyms)
        _KeyValue(
          label: '≈',
          value: Text(s, style: t.bodyMedium),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.name.resolve(lang)),
        actions: [
          ShareButton(
            text: (l) => recordShareText(
              title: entry.name.resolve(lang),
              sources: entry.details?.allSources ?? const [],
              sourcesLabel: l.shareSourcesLabel,
              footer: l.shareFooter,
              appLink: ref.read(referralLinksProvider).recordLink(entry.id),
            ),
          ),
          FavoriteButton(id: entry.id),
          ReportErrorMenu(
            entityId: '${isSubstance ? 'substance' : 'entry'}:${entry.id}',
            title: entry.name.resolve(lang),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ViewRecorder(id: entry.id),
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(entry.section.icon, size: 18, color: c.accent),
                      Text(entry.section.label(l), style: t.labelLarge),
                      if (entry.isTestData) const TestDataBadge(),
                      if (entry.details != null)
                        AccessBadge(access: entry.access),
                    ],
                  ),
                  const SizedBox(height: FeSpace.sm),
                  if (entry.status != ScientificStatus.verified)
                    const UnverifiedBanner(),
                  if (entry.details == null) ...[
                    FeSectionHeader(l.detailEvidenceStatus),
                    _KeyValue(
                      label: l.detailEvidenceStatus,
                      value: ReviewStatusBadge(status: entry.status),
                    ),
                    _KeyValue(
                      label: l.detailLastReviewed,
                      value: Text(
                        entry.lastReviewed == null
                            ? l.detailNotReviewed
                            : feDate(context, entry.lastReviewed!),
                        style: t.bodyMedium,
                      ),
                    ),
                  ],
                  if (entry.details != null)
                    // Kontent paketi yozuvi: «Qisqacha» → nomlar → …
                    ContentEntryBody(entry: entry, names: names)
                  else ...[
                    ...names,
                    if (isSubstance) ...[
                      FeSectionHeader(l.detailLayerScientific),
                      FeBanner(
                        key: const Key('entry.layer.scientific'),
                        icon: Icons.public,
                        text: l.detailLayerScientificNote,
                      ),
                    ],
                    for (final (icon, title) in sections) ...[
                      FeSectionHeader(title),
                      if (title == l.detailConcentrations) ...[
                        FeBanner(
                          icon: Icons.gavel_outlined,
                          text: l.detailConcentrationsNote,
                          tone: FeBannerTone.warning,
                        ),
                        const SizedBox(height: FeSpace.xs),
                      ],
                      _Placeholder(icon: icon),
                    ],
                    if (isSubstance) _JurisdictionLayer(subjectId: entry.id),
                    FeSectionHeader(l.detailReferences),
                    OutlinedButton.icon(
                      key: const Key('entry.sources'),
                      icon: const Icon(Icons.format_quote_outlined),
                      label: Text(l.sourcesButton),
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (_) => _SourcesSheet(entry: entry),
                      ),
                    ),
                  ],
                  if (entry.details case final d?)
                    ProfessionalReviewSection(
                      recordId: entry.id,
                      kind: switch (entry.section) {
                        LibrarySection.substances =>
                          ReviewSubjectKind.substance,
                        LibrarySection.methods => ReviewSubjectKind.method,
                        LibrarySection.specimens => ReviewSubjectKind.claim,
                        LibrarySection.references ||
                        LibrarySection.glossary => ReviewSubjectKind.reference,
                      },
                      risk: isSubstance ? RiskLevel.high : RiskLevel.standard,
                      sourceCount: d.allSources.length,
                      identifiersVerified: identifiersVerified(d.allSources),
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

/// Yurisdiksiya qatlami — ilmiy dalillardan **alohida** blok.
///
/// Faqat review’dan o‘tgan va bugun kuchda bo‘lgan qoidalar ko‘rsatiladi
/// ([JurisdictionResolver]). Hozir qoidalar yuklanmagan — halol bo‘sh holat.
class _JurisdictionLayer extends ConsumerWidget {
  const _JurisdictionLayer({required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final id = ref.watch(settingsControllerProvider).jurisdictionId;
    final resolver = ref.watch(jurisdictionResolverProvider);
    final view =
        resolver.view(
          jurisdictionId: id,
          subjectType: 'substance',
          subjectId: subjectId,
          at: DateTime.now(),
        ) ??
        resolver.view(
          jurisdictionId: internationalJurisdictionId,
          subjectType: 'substance',
          subjectId: subjectId,
          at: DateTime.now(),
        )!;
    final isInternational = view.jurisdiction.id == internationalJurisdictionId;
    return Column(
      key: const Key('entry.layer.jurisdiction'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(
          l.detailLayerJurisdiction(view.jurisdiction.name(lang)),
          actionLabel: l.detailChangeJurisdiction,
          onAction: () => context.push(Routes.profileJurisdiction),
        ),
        if (isInternational) ...[
          FeBanner(
            icon: Icons.info_outline,
            text: l.jurisdictionInternationalHint,
          ),
          const SizedBox(height: FeSpace.xs),
        ],
        for (final (icon, title) in [
          (Icons.gavel_outlined, l.detailLegalStatus),
          (Icons.rule_folder_outlined, l.detailNationalMethods),
        ]) ...[
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xs, bottom: 4),
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
          if (view.rules.isEmpty)
            FeEmptyState(
              icon: icon,
              body: l.jurisdictionNoContent,
              compact: true,
            ),
        ],
      ],
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FeSpace.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: c.textSecondary),
            ),
          ),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: value),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(FeRadius.sm),
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Row(
          children: [
            Icon(icon, size: 18, color: c.textSecondary),
            const SizedBox(width: FeSpace.xs),
            Expanded(
              child: Text(
                AppLocalizations.of(context).detailPlaceholder,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: c.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourcesSheet extends StatelessWidget {
  const _SourcesSheet({required this.entry});

  final LibraryEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FeSpace.md,
          0,
          FeSpace.md,
          FeSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l.sourcesButton,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: FeSpace.sm),
            FeEmptyState(
              icon: Icons.format_quote_outlined,
              body: l.sourcesNone,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}
