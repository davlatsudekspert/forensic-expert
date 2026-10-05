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
import '../../../core/layout/responsive.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../core/widgets/fe_data_components.dart';
import '../../../domain/jurisdiction/jurisdiction_catalog.dart';

/// Global yurisdiksiya qatlami (PHASE 6).
///
/// Uch qatlam hech qachon aralashtirilmaydi: Global Scientific Core,
/// xalqaro standartlar/metodlar va davlat qonuni/protseduralari. Kontent
/// bo‘lmagan yurisdiksiya uchun boshqa davlat qonuni fallback sifatida
/// KO‘RSATILMAYDI.

extension DocumentKindL10n on AppLocalizations {
  String legalFieldLabel(LegalRecordField f) => switch (f) {
    LegalRecordField.officialTitle => lfOfficialTitle,
    LegalRecordField.originalTitle => lfOriginalTitle,
    LegalRecordField.authority => instrAuthority,
    LegalRecordField.documentNumber => instrNumber,
    LegalRecordField.articleSection => lfArticle,
    LegalRecordField.officialUrl => lfOfficialUrl,
    LegalRecordField.publicationDate => instrPublished,
    LegalRecordField.effectiveDate => instrEffectiveFrom,
    LegalRecordField.version => instrVersion,
    LegalRecordField.status => instrLegalStatus,
    LegalRecordField.lastChecked => instrLastVerified,
    LegalRecordField.language => instrLanguage,
    LegalRecordField.translationStatus => instrTranslation,
    LegalRecordField.reviewStatus => lfReviewStatus,
  };

  String legalDomainLabel(LegalDomain d) => switch (d) {
    LegalDomain.expertStatus => ldExpertStatus,
    LegalDomain.evidenceHandling => ldEvidenceHandling,
    LegalDomain.chainOfCustody => ldChainOfCustody,
    LegalDomain.specimenCollection => ldSpecimenCollection,
    LegalDomain.deathInvestigation => ldDeathInvestigation,
    LegalDomain.autopsy => ldAutopsy,
    LegalDomain.toxicology => ldToxicology,
    LegalDomain.alcoholDriving => ldAlcoholDriving,
    LegalDomain.controlledSubstances => ldControlledSubstances,
    LegalDomain.reporting => ldReporting,
    LegalDomain.laboratoryStandards => ldLaboratoryStandards,
    LegalDomain.retentionStorage => ldRetentionStorage,
    LegalDomain.testimony => ldTestimony,
    LegalDomain.qualityAccreditation => ldQualityAccreditation,
  };

  String documentKindLabel(DocumentKind k) => switch (k) {
    DocumentKind.law => docKindLaw,
    DocumentKind.regulation => docKindRegulation,
    DocumentKind.standard => docKindStandard,
    DocumentKind.guideline => docKindGuideline,
    DocumentKind.method => docKindMethod,
    DocumentKind.sop => docKindSop,
    DocumentKind.scientificArticle => docKindArticle,
    DocumentKind.officialDocument => docKindOfficial,
  };

  String bindingLabel(BindingNature b) => switch (b) {
    BindingNature.legallyBinding => bindingLegal,
    BindingNature.voluntaryUnlessAdopted => bindingVoluntary,
    BindingNature.advisory => bindingAdvisory,
    BindingNature.institutional => bindingInstitutional,
    BindingNature.scientificEvidence => bindingScientific,
  };

  String legalStatusLabel(InstrumentLegalStatus s) => switch (s) {
    InstrumentLegalStatus.inForce => legalStatusInForce,
    InstrumentLegalStatus.amended => legalStatusAmended,
    InstrumentLegalStatus.superseded => legalStatusSuperseded,
    InstrumentLegalStatus.repealed => legalStatusRepealed,
  };
}

/// Yurisdiksiyaning **o‘zida** (ajdodlarisiz) rasmiy hujjat bormi.
bool hasOwnContent(JurisdictionResolver r, String id) =>
    r.instruments.any((i) => i.jurisdictionId == id);

class JurisdictionHubScreen extends ConsumerWidget {
  const JurisdictionHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final resolver = ref.watch(jurisdictionResolverProvider);
    final id = ref.watch(
      settingsControllerProvider.select((s) => s.jurisdictionId),
    );
    final current = resolver.byId(id);
    final withContent =
        {for (final i in resolver.instruments) i.jurisdictionId}
            .map(resolver.byId)
            .whereType<Jurisdiction>()
            .toList()
          ..sort((a, b) => a.name(lang).compareTo(b.name(lang)));

    return Scaffold(
      appBar: AppBar(title: Text(l.jurisdictionsTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('jurisdictions.hub'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(icon: Icons.public, text: l.jurisdictionGlobalWorks),
                  FeSectionHeader(l.jurisdictionCurrent),
                  FeCard(
                    key: const Key('jurisdictions.current'),
                    padding: const EdgeInsets.all(FeSpace.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _IsoCode(current?.iso3166 ?? current?.id ?? id),
                            const SizedBox(width: FeSpace.sm),
                            Expanded(
                              child: Text(
                                current?.name(lang) ?? id,
                                style: t.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: FeSpace.xs),
                        _Coverage(
                          has: id == JurisdictionCatalog.internationalId
                              ? resolver.instruments.isNotEmpty
                              : hasOwnContent(resolver, id),
                        ),
                        const SizedBox(height: FeSpace.sm),
                        Wrap(
                          spacing: FeSpace.xs,
                          runSpacing: FeSpace.xs,
                          children: [
                            FilledButton.tonal(
                              key: const Key('jurisdictions.change'),
                              onPressed: () =>
                                  context.push(Routes.jurisdictionSelect),
                              child: Text(l.homeChange),
                            ),
                            OutlinedButton(
                              key: const Key('jurisdictions.details'),
                              onPressed: () =>
                                  context.push(Routes.jurisdiction(id)),
                              child: Text(l.jurisdictionViewDetails),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FeSectionHeader(l.jurisdictionLayersTitle),
                  for (final (icon, text) in [
                    (Icons.science_outlined, l.layerGlobalCore),
                    (Icons.rule_folder_outlined, l.layerIntlStandards),
                    (Icons.account_balance_outlined, l.layerCountryLaw),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, size: 20, color: c.accent),
                          const SizedBox(width: FeSpace.sm),
                          Expanded(child: Text(text, style: t.bodyMedium)),
                        ],
                      ),
                    ),
                  ListTile(
                    key: const Key('jurisdictions.compare'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.compare_arrows),
                    title: Text(l.compareTitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(Routes.compare),
                  ),
                  FeSectionHeader(l.jurisdictionWithContent),
                  for (final j in withContent)
                    ListTile(
                      key: Key('jurisdictions.withContent.${j.id}'),
                      contentPadding: EdgeInsets.zero,
                      leading: _IsoCode(j.iso3166 ?? j.id),
                      title: Text(j.name(lang)),
                      subtitle: Text(
                        l.jurisdictionPilotContent,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.jurisdiction(j.id)),
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

class _IsoCode extends StatelessWidget {
  const _IsoCode(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 40),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FeRadius.sm),
        border: Border.all(color: c.borderStrong),
      ),
      child: Text(
        code,
        textAlign: TextAlign.center,
        style: FeThemeBuilder.numeric(Theme.of(context).textTheme.labelMedium!)
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Coverage extends StatelessWidget {
  const _Coverage({required this.has});

  final bool has;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return Row(
      children: [
        Icon(
          has ? Icons.pending_outlined : Icons.do_not_disturb_on_outlined,
          size: 16,
          color: has ? c.warning : c.textSecondary,
        ),
        const SizedBox(width: FeSpace.xxs),
        Flexible(
          child: Text(
            has ? l.jurisdictionPilotContent : l.jurisdictionNoContentShort,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: has ? c.warning : c.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Yurisdiksiya tanlash: qidiruv, global, kontentli va barcha ISO
/// davlatlari (A–Z). Bayroq ishlatilmaydi — ISO kod + nom.
class JurisdictionSelectScreen extends ConsumerStatefulWidget {
  const JurisdictionSelectScreen({super.key});

  @override
  ConsumerState<JurisdictionSelectScreen> createState() =>
      _JurisdictionSelectState();
}

class _JurisdictionSelectState extends ConsumerState<JurisdictionSelectScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final resolver = ref.watch(jurisdictionResolverProvider);
    final current = ref.watch(settingsControllerProvider).jurisdictionId;
    final q = _q.trim().toLowerCase();
    bool match(Jurisdiction j) =>
        q.isEmpty ||
        j.id.toLowerCase() == q ||
        j.names.values.any((n) => n.toLowerCase().contains(q));

    final all = resolver.jurisdictions.where(match).toList();
    final global = [
      for (final j in all)
        if (j.level == JurisdictionLevel.international ||
            j.level == JurisdictionLevel.supranational)
          j,
    ];
    final countries = [
      for (final j in all)
        if (j.level == JurisdictionLevel.country) j,
    ]..sort((a, b) => a.name(lang).compareTo(b.name(lang)));
    final withContent = [
      for (final j in countries)
        if (hasOwnContent(resolver, j.id)) j,
    ];

    Widget tile(Jurisdiction j, {String section = ''}) {
      final selected = j.id == current;
      final has = j.id == JurisdictionCatalog.internationalId
          ? resolver.instruments.isNotEmpty
          : hasOwnContent(resolver, j.id);
      return ListTile(
        key: Key('picker.jurisdiction.$section${j.id}'),
        contentPadding: EdgeInsets.zero,
        leading: _IsoCode(j.iso3166 ?? j.id),
        title: Text(j.name(lang)),
        subtitle: Text(
          has ? l.jurisdictionPilotContent : l.jurisdictionNoContentShort,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        selected: selected,
        trailing: selected ? const Icon(Icons.check) : null,
        onTap: () async {
          final notifier = ref.read(settingsControllerProvider.notifier);
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(Routes.jurisdictions);
          }
          await notifier.setJurisdiction(j.id);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsJurisdiction)),
      body: SafeArea(
        // 249 davlat — lazy ro‘yxat (faqat ko‘rinadigan qatorlar quriladi).
        child: CustomScrollView(
          key: const Key('jurisdictions.select'),
          slivers: [
            SliverToBoxAdapter(
              child: FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      icon: Icons.layers_outlined,
                      text: l.jurisdictionPickerIntro,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      key: const Key('jurisdictions.search'),
                      onChanged: (v) => setState(() => _q = v),
                      decoration: InputDecoration(
                        hintText: l.jurisdictionSearchHint,
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                      ),
                    ),
                    if (global.isNotEmpty) ...[
                      FeSectionHeader(l.jurisdictionGroupGlobal),
                      for (final j in global) tile(j),
                    ],
                    if (withContent.isNotEmpty && q.isEmpty) ...[
                      FeSectionHeader(l.jurisdictionWithContent),
                      for (final j in withContent) tile(j, section: 'content.'),
                    ],
                    FeSectionHeader(l.jurisdictionGroupCountries),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: countries.length,
              itemBuilder: (context, i) =>
                  FeContentFrame(child: tile(countries[i])),
            ),
            SliverToBoxAdapter(
              child: FeContentFrame(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: FeSpace.sm,
                    bottom: FeSpace.xl,
                  ),
                  child: Text(
                    l.jurisdictionCountryNames,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yurisdiksiya sahifasi: qo‘llanish zanjiri, xalqaro qatlam va shu
/// yurisdiksiyaning o‘z hujjatlari — har biri to‘liq metadata bilan.
class JurisdictionDetailScreen extends ConsumerWidget {
  const JurisdictionDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final resolver = ref.watch(jurisdictionResolverProvider);
    final j = resolver.byId(id);
    final chain = resolver.chainOf(id);
    final own = [
      for (final i in resolver.instruments)
        if (i.jurisdictionId != JurisdictionCatalog.internationalId &&
            chain.any((x) => x.id == i.jurisdictionId))
          i,
    ];
    final intl = [
      for (final i in resolver.instruments)
        if (i.jurisdictionId == JurisdictionCatalog.internationalId) i,
    ];
    final isIntl = id == JurisdictionCatalog.internationalId;

    return Scaffold(
      appBar: AppBar(title: Text(j?.name(lang) ?? id)),
      body: SafeArea(
        child: ListView(
          key: Key('jurisdictionDetail.$id'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  Row(
                    children: [
                      _IsoCode(j?.iso3166 ?? id),
                      const SizedBox(width: FeSpace.sm),
                      Expanded(
                        child: Text(
                          l.jurisdictionChain(
                            chain.map((x) => x.name(lang)).join(' → '),
                          ),
                          style: t.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  if (!isIntl) ...[
                    FeSectionHeader(l.jurisdictionOwnLayer),
                    if (own.isEmpty)
                      FeBanner(
                        key: const Key('jurisdiction.notVerified'),
                        icon: Icons.do_not_disturb_on_outlined,
                        text: l.jurisdictionNotVerified,
                        tone: FeBannerTone.warning,
                      )
                    else
                      for (final i in own) InstrumentCard(instrument: i),
                  ],
                  if (!isIntl) ...[
                    // PHASE 10: huquqiy domenlar — har biri bo‘yicha shu
                    // yurisdiksiyada yozuv bor-yo‘qligi (yo‘q = tasdiqlangan
                    // kontent yo‘q; boshqa davlat bilan to‘ldirilmaydi).
                    FeSectionHeader(l.legalDomainsTitle),
                    for (final d in LegalDomain.values)
                      () {
                        final n = [
                          for (final r in resolver.rules)
                            if (legalDomainOf(r) == d &&
                                own.any((i) => i.id == r.instrumentId))
                              r,
                        ].length;
                        return ListTile(
                          key: Key('jurisdiction.domain.${d.name}'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            n > 0
                                ? Icons.description_outlined
                                : Icons.remove_circle_outline,
                            color: n > 0 ? c.accent : c.textSecondary,
                          ),
                          title: Text(l.legalDomainLabel(d)),
                          subtitle: Text(
                            n > 0
                                ? l.legalDomainRecords(n)
                                : l.legalDomainNoContent,
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        );
                      }(),
                  ],
                  FeSectionHeader(l.jurisdictionIntlLayer),
                  if (intl.isEmpty)
                    FeBanner(
                      icon: Icons.do_not_disturb_on_outlined,
                      text: l.jurisdictionNotVerified,
                      tone: FeBannerTone.warning,
                    )
                  else
                    for (final i in intl) InstrumentCard(instrument: i),
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

/// Rasmiy hujjat kartochkasi — barcha jurisdiction maydonlari.
class InstrumentCard extends ConsumerWidget {
  const InstrumentCard({super.key, required this.instrument});

  final JurisdictionalInstrument instrument;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final catalog = ref.watch(legalCatalogProvider);
    final i = instrument;
    final kind = documentKindOfInstrument(i.type);
    final source = catalog.instrumentSources[i.id];
    final authority = i.authorityId == null
        ? null
        : catalog.authorities[i.authorityId]?.resolve(lang);
    String date(DateTime d) => feDate(context, d);
    final rows = <(String, String)>[
      if (i.officialReference != null) (l.instrNumber, i.officialReference!),
      if (authority != null) (l.instrAuthority, authority),
      if (i.publicationDate != null)
        (l.instrPublished, date(i.publicationDate!)),
      (l.instrEffectiveFrom, date(i.effectiveFrom)),
      if (i.effectiveTo != null) (l.instrEffectiveTo, date(i.effectiveTo!)),
      if (i.lastAmendedAt != null) (l.instrAmended, date(i.lastAmendedAt!)),
      (l.instrVersion, i.version),
      (l.instrLegalStatus, l.legalStatusLabel(i.legalStatus)),
      if (i.language != null) (l.instrLanguage, i.language!),
      (
        l.instrTranslation,
        switch (i.translationStatus) {
          null => l.translationNone,
          TranslationStatus.machineDraft => l.detailTranslationDraft,
          TranslationStatus.translated => l.statusNeedsReview,
          TranslationStatus.reviewed => l.statusReviewed,
        },
      ),
      if (i.lastVerifiedAt != null)
        (l.instrLastVerified, date(i.lastVerifiedAt!)),
      if (source != null) (l.instrSource, source.title),
      // PHASE 10: asl tildagi rasmiy sarlavha.
      if (i.language != null &&
          i.language != lang &&
          (i.titles[i.language] ?? '').isNotEmpty)
        (l.instrOriginalTitle, i.titles[i.language]!),
    ];
    final missing = LegalRecordCompleteness.missing(
      i,
      source: source == null
          ? null
          : Source(
              sourceId: source.sourceId,
              sourceType: SourceType.legislation,
              title: source.title,
              tier: SourceTier.tier1,
              evidenceLevel: EvidenceLevel.a,
              licenseMode: SourceLicenseMode.citeOnly,
              officialUrl: source.url,
            ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: FeCard(
        key: Key('instrument.${i.id}'),
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: FeSpace.sm,
              runSpacing: FeSpace.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l.documentKindLabel(kind),
                  key: Key('instrument.kind.${i.id}'),
                  style: t.labelSmall?.copyWith(
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                    color: c.accent,
                  ),
                ),
                ReviewStatusBadge(status: i.status),
              ],
            ),
            const SizedBox(height: FeSpace.xxs),
            Text(i.titles[lang] ?? i.titles['en'] ?? i.id, style: t.titleSmall),
            Text(
              l.bindingLabel(kind.binding),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: FeSpace.xs),
            FeMetaList(rows: rows),
            if (missing.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: FeSpace.xs),
                child: FeBanner(
                  key: Key('instrument.missing.${i.id}'),
                  icon: Icons.rule_outlined,
                  tone: FeBannerTone.warning,
                  text: l.legalMissingFields(
                    [for (final f in missing) l.legalFieldLabel(f)].join(', '),
                  ),
                ),
              ),
            if (source?.url case final url?)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  icon: const Icon(Icons.link),
                  label: Text(l.researchCopyLink),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.researchLinkCopied)),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
