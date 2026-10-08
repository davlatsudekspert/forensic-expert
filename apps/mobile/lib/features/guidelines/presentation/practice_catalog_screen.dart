import 'package:fe_search_core/fe_search_core.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/guidelines.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/guidelines/guideline_models.dart';
import '../../../domain/guidelines/practice_catalog.dart';

const _jsonExt = 'json';
const _jsonType = 'JSON';

/// Admin uchun: qurilmadagi yopiq katalog holati, import va o‘chirish.
class RestrictedCatalogEntry extends ConsumerWidget {
  const RestrictedCatalogEntry({super.key});

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: _jsonType, extensions: [_jsonExt]),
      ],
    );
    if (file == null) return;
    try {
      final cat = await importPracticeCatalog(
        ref.read(practiceCatalogStoreProvider),
        await file.readAsString(),
      );
      ref.invalidate(practiceCatalogProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l.restrictedCatalogImported(cat.records.length)),
        ),
      );
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(l.restrictedCatalogInvalid)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final catalog = ref.watch(practiceCatalogProvider).value;
    return FeCard(
      key: const Key('guidelines.restricted'),
      onTap: catalog == null
          ? null
          : () => context.push(Routes.practiceCatalog),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: c.accent),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: Text(l.restrictedCatalogTitle, style: t.titleSmall),
              ),
              if (catalog != null)
                Icon(Icons.chevron_right, color: c.textSecondary),
            ],
          ),
          const SizedBox(height: FeSpace.xxs),
          Text(
            catalog == null
                ? l.restrictedCatalogEmpty
                : '${catalog.source.title} · '
                      '${l.restrictedCatalogRecords(catalog.records.length)}',
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Wrap(
              spacing: FeSpace.xs,
              children: [
                TextButton.icon(
                  key: const Key('guidelines.restricted.import'),
                  onPressed: () => _import(context, ref),
                  icon: const Icon(Icons.file_open_outlined, size: 18),
                  label: Text(l.restrictedCatalogImport),
                ),
                if (catalog != null)
                  TextButton.icon(
                    key: const Key('guidelines.restricted.remove'),
                    onPressed: () async {
                      await ref.read(practiceCatalogStoreProvider).clear();
                      ref.invalidate(practiceCatalogProvider);
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(l.restrictedCatalogRemove),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Yopiq katalog ro‘yxati: uch tilli qidiruv va bo‘lim filtri.
class PracticeCatalogScreen extends ConsumerStatefulWidget {
  const PracticeCatalogScreen({super.key});

  @override
  ConsumerState<PracticeCatalogScreen> createState() =>
      _PracticeCatalogScreenState();
}

class _PracticeCatalogScreenState extends ConsumerState<PracticeCatalogScreen> {
  static const _normalizer = SearchNormalizer();
  String _query = '';
  String? _section;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final catalog = ref.watch(practiceCatalogProvider).value;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    if (catalog == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.restrictedCatalogTitle)),
        body: const SizedBox.shrink(),
      );
    }
    final q = _normalizer.searchKey(_query);
    final records = [
      for (final r in catalog.records)
        if ((_section == null || r.section == _section) &&
            (q.isEmpty ||
                catalog
                    .searchTermsOf(r)
                    .any((s) => _normalizer.searchKey(s).contains(q))))
          r,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.restrictedCatalogTitle)),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      icon: Icons.lock_outline,
                      tone: FeBannerTone.warning,
                      text: l.restrictedCatalogNote,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      key: const Key('practice.search'),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l.restrictedCatalogSearchHint,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    Wrap(
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xs,
                      children: [
                        for (final s in catalog.sections)
                          FilterChip(
                            label: Text(l.restrictedCatalogSection(s)),
                            selected: _section == s,
                            onSelected: (v) =>
                                setState(() => _section = v ? s : null),
                          ),
                      ],
                    ),
                    const SizedBox(height: FeSpace.xs),
                    Text(
                      l.restrictedCatalogRecords(records.length),
                      key: const Key('practice.count'),
                      style: t.labelMedium?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: records.length,
              itemBuilder: (context, i) {
                final r = records[i];
                return FeContentFrame(
                  child: ListTile(
                    key: Key('practice.${r.code}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(r.title.of(lang)),
                    subtitle: Text(
                      [r.code, _pages(l, r)].whereType<String>().join(' · '),
                      style: t.bodySmall,
                    ),
                    onTap: () => _showRecord(context, catalog, r, lang),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static String? _pages(AppLocalizations l, PracticeRecord r) {
    if (r.pageStart == null) return null;
    if (r.pageEnd == null || r.pageEnd == r.pageStart) {
      return l.restrictedCatalogPage('${r.pageStart}');
    }
    return l.restrictedCatalogPages('${r.pageStart}', '${r.pageEnd}');
  }

  void _showRecord(
    BuildContext context,
    PracticeCatalog catalog,
    PracticeRecord r,
    String lang,
  ) {
    final l = AppLocalizations.of(context);
    final cards = ref.read(guidelinesProvider).value ?? GuidelineBundle.empty;
    final normative = {for (final n in catalog.normative) n.sourceId: n};
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final t = Theme.of(ctx).textTheme;
        final c = FeTheme.of(ctx);
        final title = r.title.pick(lang);
        return SafeArea(
          child: ListView(
            key: const Key('practice.sheet'),
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              FeSpace.md,
              0,
              FeSpace.md,
              FeSpace.lg,
            ),
            children: [
              Text(title.text, style: t.titleMedium),
              const SizedBox(height: FeSpace.xs),
              Text(
                [r.code, _pages(l, r)].whereType<String>().join(' · '),
                style: t.bodySmall,
              ),
              if (r.codeWasNormalized)
                Text(
                  l.restrictedCatalogCodeOriginal(r.codeOriginal),
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              if (lang != 'uz' &&
                  !title.isFallback &&
                  r.titleTranslationStatus == GuidelineTranslationStatus.draft)
                Text(
                  l.restrictedCatalogTitleDraft,
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              Text(
                '${catalog.source.title}'
                '${catalog.source.year == null ? '' : ', ${catalog.source.year}'}',
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              if (r.independentCards.isNotEmpty) ...[
                FeSectionHeader(l.restrictedCatalogLinkedCards),
                for (final id in r.independentCards)
                  if (cards.byId(id) case final card?)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.menu_book_outlined, color: c.accent),
                      title: Text(card.title.of(lang)),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        context.push(Routes.guideline(card.id));
                      },
                    ),
              ],
              if (r.relatedNormative.isNotEmpty) ...[
                FeSectionHeader(l.restrictedCatalogNormative),
                for (final id in r.relatedNormative)
                  if (normative[id] case final n?)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                      child: Text(n.title, style: t.bodySmall),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }
}
