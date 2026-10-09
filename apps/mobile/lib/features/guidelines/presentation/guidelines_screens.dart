import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/account.dart';
import '../../../app/guidelines.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/evidence/citation_format.dart';
import '../../../domain/guidelines/guideline_models.dart';
import '../../evidence/presentation/citation_sheet.dart';
import '../../support/presentation/support_widgets.dart' show ReportErrorMenu;
import '../../tools/tool_strings.dart';
import 'practice_catalog_screen.dart';

extension GuidelineAreaL10n on GuidelineArea {
  String label(AppLocalizations l) => switch (this) {
    GuidelineArea.forensicMedicine => l.guidelineAreaForensicMedicine,
    GuidelineArea.forensicChemistry => l.guidelineAreaForensicChemistry,
    GuidelineArea.forensicHistology => l.guidelineAreaForensicHistology,
    GuidelineArea.forensicBiology => l.guidelineAreaForensicBiology,
    GuidelineArea.medicalCriminalistics => l.guidelineAreaMedicalCriminalistics,
    GuidelineArea.other => l.guidelineAreaOther,
  };

  IconData get icon => switch (this) {
    GuidelineArea.forensicMedicine => Icons.local_hospital_outlined,
    GuidelineArea.forensicChemistry => Icons.science_outlined,
    GuidelineArea.forensicHistology => Icons.biotech_outlined,
    GuidelineArea.forensicBiology => Icons.bloodtype_outlined,
    GuidelineArea.medicalCriminalistics => Icons.fingerprint,
    GuidelineArea.other => Icons.category_outlined,
  };
}

String languageName(AppLocalizations l, String code) => switch (code) {
  'ru' => l.languageNameRu,
  'en' => l.languageNameEn,
  _ => l.languageNameUz,
};

/// «Yo‘riqnomalar» — fanlar bo‘yicha mustaqil ilmiy-amaliy kartalar.
/// Admin uchun qo‘shimcha: qurilmadagi yopiq amaliyot kodlari katalogi.
class GuidelinesScreen extends ConsumerStatefulWidget {
  const GuidelinesScreen({super.key});

  @override
  ConsumerState<GuidelinesScreen> createState() => _GuidelinesScreenState();
}

class _GuidelinesScreenState extends ConsumerState<GuidelinesScreen> {
  static const _normalizer = SearchNormalizer();
  String _query = '';

  bool _matches(GuidelineCard c) {
    final q = _normalizer.searchKey(_query);
    if (q.isEmpty) return true;
    return c.searchTerms.any((t) => _normalizer.searchKey(t).contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final bundle = ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty;
    final isAdmin = ref.watch(serverAccessProvider).value?.isAdmin ?? false;
    final cards = bundle.cards.where(_matches).toList();
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.guidelinesTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(
                    key: const Key('guidelines.intro'),
                    icon: Icons.info_outline,
                    text: l.guidelinesIntro,
                  ),
                  const SizedBox(height: FeSpace.sm),
                  TextField(
                    key: const Key('guidelines.search'),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l.guidelinesSearchHint,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: FeSpace.sm),
                    const RestrictedCatalogEntry(),
                  ],
                  if (_query.isNotEmpty && cards.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: FeSpace.lg),
                      child: Text(
                        l.guidelinesNoResults,
                        key: const Key('guidelines.noResults'),
                        textAlign: TextAlign.center,
                        style: t.bodyMedium?.copyWith(color: c.textSecondary),
                      ),
                    ),
                  for (final area in GuidelineArea.values) ...[
                    if (_query.isEmpty || cards.any((x) => x.area == area)) ...[
                      FeSectionHeader(area.label(l)),
                      ..._areaCards(context, area, cards, lang, l),
                    ],
                  ],
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _areaCards(
    BuildContext context,
    GuidelineArea area,
    List<GuidelineCard> cards,
    String lang,
    AppLocalizations l,
  ) {
    final list = cards.where((x) => x.area == area).toList();
    final c = FeTheme.of(context);
    final bundle = ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty;
    if (list.isEmpty) {
      return [
        Text(
          l.guidelinesEmptyArea,
          key: Key('guidelines.empty.${area.name}'),
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: c.textSecondary),
        ),
      ];
    }
    return [
      for (final card in list)
        Padding(
          padding: const EdgeInsets.only(bottom: FeSpace.xs),
          child: FeCard(
            key: Key('guidelines.card.${card.id}'),
            onTap: () => context.push(Routes.guideline(card.id)),
            child: Row(
              children: [
                Icon(area.icon, color: c.accent),
                const SizedBox(width: FeSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title.of(lang),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: FeSpace.xxs),
                      Wrap(
                        spacing: FeSpace.xs,
                        runSpacing: FeSpace.xxs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ReviewStatusBadge(status: card.status, compact: true),
                          Text(
                            l.rdGuidelineMeta(
                              card.sections.length,
                              l.rdSourcesCount(
                                bundle.referencesOf(card).length,
                              ),
                            ),
                            key: Key('guidelines.meta.${card.id}'),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.textSecondary),
              ],
            ),
          ),
        ),
    ];
  }
}

/// Bitta yo‘riqnoma: bo‘limlar, iqtiboslar [n], manbalar ro‘yxati.
class GuidelineDetailScreen extends ConsumerStatefulWidget {
  const GuidelineDetailScreen({super.key, required this.cardId});

  final String cardId;

  @override
  ConsumerState<GuidelineDetailScreen> createState() =>
      _GuidelineDetailScreenState();
}

/// Uzun yo‘riqnoma: «Shu sahifada» qatori bo‘limlar va adabiyotlarga
/// bir bosishda olib boradi (matn devori ichida adashmaslik uchun).
class _GuidelineDetailScreenState extends ConsumerState<GuidelineDetailScreen> {
  final _anchors = <String, GlobalKey>{};

  GlobalKey _anchor(String id) => _anchors.putIfAbsent(id, GlobalKey.new);

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
    final cardId = widget.cardId;
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final bundle = ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty;
    final card = bundle.byId(cardId);
    if (card == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final refs = bundle.referencesOf(card);
    final index = {for (var i = 0; i < refs.length; i++) refs[i].key: i + 1};
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final title = card.title.pick(lang);
    final translation = card.translationFor(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.guidelinesTitle),
        actions: [
          ReportErrorMenu(entityId: 'guideline:${card.id}', title: title.text),
        ],
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('guideline.detail'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  Semantics(
                    header: true,
                    // Katta shriftda (2x) sarlavha so‘zlari harf bo‘yicha
                    // bo‘linmasin: sarlavha shkalasi cheklanadi (u baribir
                    // asosiy matndan katta qoladi).
                    child: Text(
                      title.text,
                      style: t.headlineSmall,
                      textScaler: MediaQuery.textScalerOf(context)
                          .clamp(maxScaleFactor: 1.3),
                    ),
                  ),
                  const SizedBox(height: FeSpace.xs),
                  Wrap(
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ReviewStatusBadge(status: card.status),
                      Text(
                        card.area.label(l),
                        style: t.labelMedium?.copyWith(color: c.textSecondary),
                      ),
                      if (card.updated != null)
                        Text(
                          l.guidelineUpdated(feDate(context, card.updated!)),
                          style: t.labelMedium?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(
                    icon: Icons.menu_book_outlined,
                    text: l.guidelineIndependentNote,
                  ),
                  if (bundle.citesYuldashevMaterial(card)) ...[
                    const SizedBox(height: FeSpace.xs),
                    FeBanner(
                      key: const Key('guideline.toksAttribution'),
                      icon: Icons.school_outlined,
                      text: l.guidelineToksAttribution,
                    ),
                  ],
                  if (title.isFallback) ...[
                    const SizedBox(height: FeSpace.xs),
                    FeBanner(
                      key: const Key('guideline.fallback'),
                      icon: Icons.translate,
                      tone: FeBannerTone.warning,
                      text: l.guidelineFallbackLanguage(
                        languageName(l, title.lang),
                      ),
                    ),
                  ] else if (translation ==
                      GuidelineTranslationStatus.draft) ...[
                    const SizedBox(height: FeSpace.xs),
                    FeBanner(
                      key: const Key('guideline.draftTranslation'),
                      icon: Icons.translate,
                      tone: FeBannerTone.warning,
                      text: l.guidelineTranslationDraft,
                    ),
                  ],
                  if (card.sections.length > 1 || refs.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: FeSpace.md,
                        bottom: FeSpace.xs,
                      ),
                      child: Semantics(
                        header: true,
                        child: Text(
                          l.detailOnThisPage,
                          style: t.labelLarge?.copyWith(color: c.textSecondary),
                        ),
                      ),
                    ),
                    // Bir qator (gorizontal) — uzun sarlavhalar qisqartiriladi,
                    // to‘liq nomi bo‘lim sarlavhasida.
                    SingleChildScrollView(
                      key: const Key('guideline.index'),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: FeSpace.xs,
                        children: [
                          if (refs.isNotEmpty)
                            ActionChip(
                              key: const Key('guideline.index.refs'),
                              avatar: const Icon(
                                Icons.format_quote_outlined,
                                size: 16,
                              ),
                              label: Text(
                                '${l.guidelineReferences} · ${refs.length}',
                              ),
                              tooltip: l.rdJumpTo,
                              onPressed: () => _jump('refs'),
                            ),
                          for (final (i, s) in card.sections.indexed)
                            ActionChip(
                              key: Key('guideline.index.$i'),
                              label: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 200,
                                ),
                                child: Text(
                                  s.title.of(lang),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              tooltip: s.title.of(lang),
                              onPressed: () => _jump('s$i'),
                            ),
                        ],
                      ),
                    ),
                  ],
                  for (final (i, s) in card.sections.indexed) ...[
                    KeyedSubtree(
                      key: _anchor('s$i'),
                      child: FeSectionHeader(s.title.of(lang)),
                    ),
                    SelectableText(
                      numberCitations(s.body.of(lang), s.citations, index),
                      style: t.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ],
                  if (card.relatedToolIds.isNotEmpty) ...[
                    FeSectionHeader(l.guidelineRelatedTools),
                    for (final id in card.relatedToolIds)
                      if (ToolsCatalog.byId(id) case final tool?)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.calculate_outlined,
                            color: c.accent,
                          ),
                          title: Text(l.toolName(tool)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.tool(tool.id)),
                        ),
                  ],
                  if (refs.isNotEmpty) ...[
                    KeyedSubtree(
                      key: _anchor('refs'),
                      child: FeSectionHeader(
                        l.guidelineReferences,
                        actionLabel: l.citeAllSources,
                        onAction: () => showCitationSheet(context, [
                          for (final r in refs)
                            CitationData.fromGuidelineReference(r),
                        ], asList: true),
                      ),
                    ),
                    for (var i = 0; i < refs.length; i++)
                      _ReferenceTile(number: i + 1, reference: refs[i]),
                  ],
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

String _bracket(int n) => '[$n]';

final _inlineCitation = RegExp(r'\[([A-Za-z0-9_.,\s-]+)\]');

/// Matn ichidagi `[kalit]` / `[k1, k2]` iqtiboslarini manbalar ro‘yxatidagi
/// raqamlarga almashtiradi. Matnda iqtibos bo‘lmasa — bo‘lim oxiriga
/// qo‘shadi. Noma’lum kalitlar o‘zgarishsiz qoladi (yashirilmaydi).
String numberCitations(
  String body,
  List<String> citations,
  Map<String, int> index,
) {
  var inline = false;
  final out = body.replaceAllMapped(_inlineCitation, (m) {
    final keys = m[1]!.split(',').map((e) => e.trim()).toList();
    if (keys.any((k) => index[k] == null)) return m[0]!;
    inline = true;
    return keys.map((k) => _bracket(index[k]!)).join();
  });
  if (inline || citations.isEmpty) return out;
  final tail = [
    for (final k in citations)
      if (index[k] != null) _bracket(index[k]!),
  ].join();
  return tail.isEmpty ? out : '$out $tail';
}

class _ReferenceTile extends StatelessWidget {
  const _ReferenceTile({required this.number, required this.reference});

  final int number;
  final GuidelineReference reference;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final link = reference.link;
    final ids = [
      if (reference.doi != null) 'DOI ${reference.doi}',
      if (reference.pmid != null) 'PMID ${reference.pmid}',
    ].join(' · ');
    return Padding(
      key: Key('guideline.ref.${reference.key}'),
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Text(_bracket(number), style: t.bodySmall),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(reference.citation, style: t.bodySmall),
                if (ids.isNotEmpty) Text(ids, style: t.labelSmall),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (link != null)
                      TextButton.icon(
                        onPressed: () => launchUrl(
                          link,
                          mode: LaunchMode.externalApplication,
                        ),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(l.guidelineOpenReference),
                      ),
                    CiteButton(
                      key: Key('guideline.cite.${reference.key}'),
                      citation: CitationData.fromGuidelineReference(reference),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
