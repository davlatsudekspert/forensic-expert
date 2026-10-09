import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/glossary.dart';
import '../../../app/guidelines.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/glossary/glossary.dart';
import '../../../domain/guidelines/guideline_models.dart';
import '../../../domain/library/library_models.dart';
import '../../guidelines/presentation/guidelines_screens.dart'
    show languageName;

extension ScientificTermKindL10n on ScientificTermKind {
  String label(AppLocalizations l) => switch (this) {
    ScientificTermKind.term => l.glossaryKindTerm,
    ScientificTermKind.abbreviation => l.glossaryKindAbbreviation,
    ScientificTermKind.identifier => l.glossaryKindIdentifier,
    ScientificTermKind.formula => l.glossaryKindFormula,
  };
}

/// Joriy sahifa Home tabi ichidami (havolalar shu tabda ochilsin).
bool _inHomeTab(BuildContext context) {
  try {
    return GoRouterState.of(context).uri.path.startsWith('/home');
  } on Object {
    return false;
  }
}

String _cardRoute(String id, {required bool inHome}) =>
    inHome ? Routes.homeGuideline(id) : Routes.guideline(id);

/// «Ilmiy lug‘at» — atamalar joriy tilda, ostida qolgan ikki til; filtr
/// uchala tilda ishlaydi.
class GlossaryScreen extends ConsumerStatefulWidget {
  const GlossaryScreen({super.key});

  @override
  ConsumerState<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends ConsumerState<GlossaryScreen> {
  final _filter = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final glossary = ref.watch(glossaryProvider);
    final terms = glossary.list(lang, query: _query);
    // Kutubxonadagi lug‘at maqolalari (eski «Glossariy» bo‘limi) — shu
    // yagona «Ilmiy lug‘at» ichida, filtr ularga ham qo‘llanadi.
    final q = _query.trim().toLowerCase();
    final articles = [
      for (final e
          in ref
              .watch(libraryRepositoryProvider)
              .entries(LibrarySection.glossary))
        if (q.isEmpty ||
            e.name.values.values.any((v) => v.toLowerCase().contains(q)))
          e,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.glossaryTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('glossary.list'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  Text(
                    l.glossaryIntro,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  TextField(
                    key: const Key('glossary.filter'),
                    controller: _filter,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l.glossaryFilterHint,
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l.searchClearQuery,
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() {
                                _filter.clear();
                                _query = '';
                              }),
                            ),
                    ),
                  ),
                  const SizedBox(height: FeSpace.xs),
                  Text(
                    l.libraryCount(terms.length),
                    key: const Key('glossary.count'),
                    style: t.labelSmall?.copyWith(color: c.textSecondary),
                  ),
                  if (terms.isEmpty && articles.isEmpty)
                    FeEmptyState(
                      key: const Key('glossary.empty'),
                      icon: Icons.search_off,
                      body: l.glossaryEmpty,
                    ),
                  for (final term in terms)
                    _GlossaryTile(
                      term: term,
                      lang: lang,
                      onTap: () => context.push(Routes.glossaryTerm(term.id)),
                    ),
                  if (articles.isNotEmpty) ...[
                    FeSectionHeader(l.glossaryLibraryArticles),
                    for (final e in articles)
                      ListTile(
                        key: Key('glossary.article.${e.id}'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(e.name.resolve(lang), style: t.titleSmall),
                        trailing: ExcludeSemantics(
                          child: Icon(
                            Icons.chevron_right,
                            color: c.textSecondary,
                          ),
                        ),
                        onTap: () => context.push(Routes.libraryEntry(e.id)),
                      ),
                  ],
                  const SizedBox(height: FeSpace.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlossaryTile extends StatelessWidget {
  const _GlossaryTile({
    required this.term,
    required this.lang,
    required this.onTap,
  });

  final GlossaryTerm term;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final others = term.othersFor(lang);
    return InkWell(
      key: Key('glossary.term.${term.id}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(term.textIn(lang), style: t.titleSmall),
                  for (final (code, text) in others)
                    Text(
                      '${code.toUpperCase()}  $text',
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                ],
              ),
            ),
            ExcludeSemantics(
              child: Icon(Icons.chevron_right, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bitta atama sahifasi (lug‘atdan yoki global qidiruvdan).
class GlossaryTermScreen extends ConsumerWidget {
  const GlossaryTermScreen({
    super.key,
    required this.termId,
    this.inHome = false,
  });

  final String termId;

  /// Home tabi ichida ochilgan (qidiruvdan) — karta havolalari ham shu tabda.
  final bool inHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final term = ref.watch(glossaryProvider).byId(termId);
    return Scaffold(
      appBar: AppBar(title: Text(l.glossaryTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('glossary.detail'),
          children: [
            FeContentFrame(
              child: term == null
                  ? FeEmptyState(icon: Icons.search_off, body: l.glossaryEmpty)
                  : Padding(
                      padding: const EdgeInsets.only(top: FeSpace.sm),
                      child: GlossaryTermBody(
                        term: term,
                        onOpenCard: (id) =>
                            context.push(_cardRoute(id, inHome: inHome)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Atama: uch tilda, tarjima holati (mashina tarjimasi — aniq belgi bilan)
/// va atama ishlatilgan yo‘riqnoma kartalari.
class GlossaryTermBody extends ConsumerWidget {
  const GlossaryTermBody({
    super.key,
    required this.term,
    required this.onOpenCard,
  });

  final GlossaryTerm term;
  final ValueChanged<String> onOpenCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final bundle = ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty;
    final tr = term.translation;
    final origLang = tr.originalLang;
    final showOriginal =
        term.note == null &&
        tr.original.trim().isNotEmpty &&
        tr.original != term.textIn(origLang);
    final translated = tr.status.values.contains(TranslationStatus.translated);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            term.textIn(lang),
            key: const Key('glossary.detail.title'),
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
            if (term.hasMachineDraft)
              StatusChip(
                key: const Key('glossary.badge.machineDraft'),
                icon: Icons.translate,
                label: l.glossaryMachineDraft,
                color: c.warning,
              )
            else if (term.isReviewed)
              StatusChip(
                key: const Key('glossary.badge.reviewed'),
                icon: Icons.verified_outlined,
                label: l.glossaryStatusReviewed,
                color: c.reviewed,
              )
            else if (translated)
              StatusChip(
                key: const Key('glossary.badge.translated'),
                icon: Icons.translate,
                label: l.glossaryStatusTranslated,
                color: c.textSecondary,
              ),
            if (term.kind != ScientificTermKind.term)
              Text(
                term.kind.label(l),
                style: t.labelMedium?.copyWith(color: c.textSecondary),
              ),
          ],
        ),
        if (term.hasMachineDraft) ...[
          const SizedBox(height: FeSpace.sm),
          FeBanner(
            key: const Key('glossary.machineDraftNote'),
            icon: Icons.translate,
            tone: FeBannerTone.warning,
            text: l.glossaryMachineDraftNote,
          ),
        ],
        if (term.explanationIn(lang) case final note?) ...[
          FeSectionHeader(l.glossaryShortExplanation),
          Text(
            note,
            key: const Key('glossary.explanation'),
            style: t.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
        const SizedBox(height: FeSpace.sm),
        for (final code in GlossaryTerm.languages)
          Padding(
            key: Key('glossary.lang.$code'),
            padding: const EdgeInsets.only(bottom: FeSpace.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageName(l, code),
                  style: t.labelMedium?.copyWith(color: c.textSecondary),
                ),
                SelectableText(
                  term.textIn(code),
                  style: t.bodyLarge?.copyWith(
                    fontWeight: code == lang ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
        if (showOriginal)
          Text(
            l.glossaryOriginal(languageName(l, origLang), tr.original),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        FeSectionHeader(l.glossaryUsedIn),
        if (term.cardIds.isEmpty)
          Text(
            l.glossaryNoCards,
            key: const Key('glossary.noCards'),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        for (final id in term.cardIds)
          if (bundle.byId(id) case final card?)
            ListTile(
              key: Key('glossary.card.$id'),
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.assignment_outlined, color: c.accent),
              title: Text(card.title.of(lang)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpenCard(id),
            ),
        const SizedBox(height: FeSpace.lg),
      ],
    );
  }
}

/// Atama varag‘i (yo‘riqnoma kartasidagi «Atamalar» bo‘limidan).
Future<void> showGlossaryTermSheet(
  BuildContext context,
  GlossaryTerm term, {
  bool? inHome,
}) {
  final home = inHome ?? _inHomeTab(context);
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheet).height * 0.85,
        ),
        child: SingleChildScrollView(
          key: const Key('glossary.sheet'),
          padding: const EdgeInsets.fromLTRB(
            FeSpace.md,
            0,
            FeSpace.md,
            FeSpace.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              GlossaryTermBody(
                term: term,
                onOpenCard: (id) {
                  Navigator.of(sheet).pop();
                  context.push(_cardRoute(id, inHome: home));
                },
              ),
              if (!home)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    key: const Key('glossary.sheet.open'),
                    icon: const Icon(Icons.translate, size: 18),
                    label: Text(l.glossaryOpenInGlossary),
                    onPressed: () {
                      Navigator.of(sheet).pop();
                      context.push(Routes.glossaryTerm(term.id));
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Yo‘riqnoma kartasidagi ixcham «Atamalar» bo‘limi: bosilganda atama
/// varag‘i (uch til, tarjima holati) ochiladi.
class GuidelineTermsSection extends ConsumerWidget {
  const GuidelineTermsSection({super.key, required this.terms});

  final List<GlossaryTerm> terms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      key: const Key('guideline.terms'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.guidelineTermsHint,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.xs),
        // Tor ekran / katta shriftda uzun atama chip’dan chiqib ketmaydi.
        LayoutBuilder(
          builder: (context, box) => Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xs,
            children: [
              for (final term in terms)
                ActionChip(
                  key: Key('guideline.term.${term.id}'),
                  label: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: (box.maxWidth - 40).clamp(80, 480),
                    ),
                    child: Text(
                      term.textIn(lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onPressed: () => showGlossaryTermSheet(context, term),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
