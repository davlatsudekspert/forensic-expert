import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/casebook.dart';
import '../../../app/guidelines.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../app/search_service.dart';
import '../../../app/share.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/casebook/casebook_models.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/guidelines/guideline_models.dart';
import '../../tools/tool_strings.dart';
import 'casebook_blocks.dart';

/// «Ekspert ish daftari» ro‘yxati. Yozuvlar faqat qurilmada.
class CasebookScreen extends ConsumerWidget {
  const CasebookScreen({super.key});

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.casebookClearTitle),
        content: Text(l.casebookClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.casebookCancel),
          ),
          FilledButton(
            key: const Key('casebook.clearConfirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.casebookDeleteConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(casebookProvider.notifier).clearAll();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.casebookCleared)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final entries = ref.watch(casebookProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.casebookTitle),
        actions: [
          if (entries.isNotEmpty)
            PopupMenuButton<String>(
              key: const Key('casebook.menu'),
              onSelected: (_) => _clearAll(context, ref),
              itemBuilder: (_) => [
                PopupMenuItem(
                  key: const Key('casebook.clearAll'),
                  value: 'clear',
                  child: Text(l.casebookClearAll),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('casebook.new'),
        onPressed: () => context.push(Routes.casebookEntry('new')),
        icon: const Icon(Icons.add),
        label: Text(l.casebookNewEntry),
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('casebook.list'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(
                    key: const Key('casebook.privacy'),
                    icon: Icons.lock_outline,
                    text: l.casebookPrivacyBanner,
                  ),
                  if (entries.isEmpty)
                    FeEmptyState(
                      key: const Key('casebook.empty'),
                      icon: Icons.menu_book_outlined,
                      title: l.casebookEmptyTitle,
                      body: l.casebookEmptyBody,
                    )
                  else ...[
                    FeSectionHeader(l.casebookCount(entries.length)),
                    for (final e in entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.xs),
                        child: FeCard(
                          key: Key('casebook.entry.${e.id}'),
                          onTap: () => context.push(Routes.casebookEntry(e.id)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.title.isEmpty ? l.casebookUntitled : e.title,
                                style: t.titleSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  feDate(context, e.date),
                                  if (e.caseRef.isNotEmpty) e.caseRef,
                                  if (e.blocks.isNotEmpty)
                                    l.casebookBlockCount(e.blocks.length),
                                ].join(FeGlyphs.middleDot),
                                style: t.bodySmall?.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                  // FAB yozuvlarni yopib qo‘ymasligi uchun.
                  const SizedBox(height: 88),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bitta yozuv: tahrirlash, bog‘lanishlar, manbali bloklar, eksport.
/// [entryId] == `new` — hali saqlanmagan yangi yozuv.
class CasebookEntryScreen extends ConsumerStatefulWidget {
  const CasebookEntryScreen({super.key, required this.entryId});

  final String entryId;

  @override
  ConsumerState<CasebookEntryScreen> createState() =>
      _CasebookEntryScreenState();
}

class _CasebookEntryScreenState extends ConsumerState<CasebookEntryScreen> {
  final _title = TextEditingController();
  final _caseRef = TextEditingController();
  final _body = TextEditingController();
  late DateTime _date;
  List<CasebookLink> _links = [];
  String? _id;
  bool _dirty = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    if (widget.entryId != 'new') _id = widget.entryId;
  }

  @override
  void dispose() {
    _title.dispose();
    _caseRef.dispose();
    _body.dispose();
    super.dispose();
  }

  void _load(CasebookEntry e) {
    _title.text = e.title;
    _caseRef.text = e.caseRef;
    _body.text = e.body;
    _date = e.date;
    _links = [...e.links];
    _loaded = true;
  }

  void _touch() => setState(() => _dirty = true);

  CasebookEntry _current() {
    final base = _id == null
        ? null
        : ref.read(casebookProvider.notifier).byId(_id!);
    final now = DateTime.now();
    return (base ??
            CasebookEntry(
              id: _id ?? '',
              title: '',
              date: _date,
              createdAt: now,
              updatedAt: now,
            ))
        .copyWith(
          title: _title.text.trim(),
          caseRef: _caseRef.text.trim(),
          date: _date,
          body: _body.text,
          links: _links,
        );
  }

  bool get _isBlankNew =>
      _id == null &&
      _title.text.trim().isEmpty &&
      _caseRef.text.trim().isEmpty &&
      _body.text.trim().isEmpty &&
      _links.isEmpty;

  /// Saqlaydi (yangi bo‘lsa yaratadi) va yozuv ID’sini qaytaradi.
  Future<String?> _save() async {
    final ctrl = ref.read(casebookProvider.notifier);
    if (_id == null) {
      if (_isBlankNew) return null;
      _id = await ctrl.create(
        title: _title.text,
        caseRef: _caseRef.text,
        date: _date,
        body: _body.text,
        links: _links,
      );
    } else if (ctrl.byId(_id!) != null) {
      await ctrl.update(_current());
    }
    _dirty = false;
    return _id;
  }

  Future<void> _saveWithMessage() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await _save();
    if (!mounted) return;
    setState(() {});
    messenger.showSnackBar(SnackBar(content: Text(l.casebookSaved)));
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      _date = d;
      _touch();
    }
  }

  Future<void> _addLink() async {
    final link = await showModalBottomSheet<CasebookLink>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _LinkPicker(),
    );
    if (link != null && !_links.contains(link)) {
      _links = [..._links, link];
      _touch();
    }
  }

  Future<void> _addBlock() async {
    final bundle = ref.read(guidelinesProvider).value ?? GuidelineBundle.empty;
    final pick = await showModalBottomSheet<(GuidelineCard, GuidelineSection)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BlockPicker(bundle: bundle),
    );
    if (pick == null || !mounted) return;
    final id = await _save() ?? await _forceCreate();
    if (id == null || !mounted) return;
    final lang = Localizations.localeOf(context).languageCode;
    final ctrl = ref.read(casebookProvider.notifier);
    await ctrl.addBlock(
      id,
      casebookBlockFromSection(
        bundle: bundle,
        card: pick.$1,
        section: pick.$2,
        lang: lang,
        id: ctrl.newId(),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<String?> _forceCreate() async {
    _id = await ref
        .read(casebookProvider.notifier)
        .create(date: _date, links: _links);
    return _id;
  }

  String _exportText() =>
      CasebookExporter.text(_current(), casebookExportLabels(context));

  Future<void> _share() async {
    final l = AppLocalizations.of(context);
    final box = context.findRenderObject();
    final text = _exportText();
    final subject = _title.text.trim().isEmpty
        ? l.casebookUntitled
        : _title.text.trim();
    await ref
        .read(shareServiceProvider)
        .shareText(
          text,
          subject: subject,
          origin: box is RenderBox && box.hasSize
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        );
  }

  Future<void> _copy() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: _exportText()));
    messenger.showSnackBar(SnackBar(content: Text(l.casebookCopied)));
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.casebookDeleteEntryTitle),
        content: Text(l.casebookDeleteEntryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.casebookCancel),
          ),
          FilledButton(
            key: const Key('casebook.deleteConfirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.casebookDeleteConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _dirty = false;
    if (_id != null) await ref.read(casebookProvider.notifier).delete(_id!);
    if (mounted) context.pop();
  }

  void _openLink(CasebookLink k) {
    context.push(switch (k.kind) {
      CasebookLinkKind.guideline => Routes.homeGuideline(k.id),
      CasebookLinkKind.tool => Routes.homeTool(k.id),
      CasebookLinkKind.substance => Routes.homeSubstance(k.id),
      CasebookLinkKind.knowledge => Routes.knowledgeEntry(k.id),
      CasebookLinkKind.research => Routes.researchEntry(k.id),
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final entries = ref.watch(casebookProvider);
    // Yo‘riqnoma paketi (blok tanlash uchun) oldindan yuklansin.
    ref.watch(guidelinesProvider);
    CasebookEntry? stored;
    if (_id != null) {
      for (final e in entries) {
        if (e.id == _id) stored = e;
      }
    }
    if (_id != null && stored == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.casebookTitle)),
        body: FeEmptyState(
          key: const Key('casebook.notFound'),
          icon: Icons.menu_book_outlined,
          body: l.casebookNotFound,
        ),
      );
    }
    if (!_loaded && stored != null) _load(stored);
    final blocks = stored?.blocks ?? const <CasebookBlock>[];

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _dirty) _save();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.casebookTitle),
          actions: [
            IconButton(
              key: const Key('casebook.share'),
              tooltip: l.casebookShare,
              icon: const Icon(Icons.ios_share),
              onPressed: _share,
            ),
            IconButton(
              key: const Key('casebook.copy'),
              tooltip: l.casebookCopy,
              icon: const Icon(Icons.copy_outlined),
              onPressed: _copy,
            ),
            if (_id != null)
              IconButton(
                key: const Key('casebook.delete'),
                tooltip: l.casebookDeleteEntry,
                icon: const Icon(Icons.delete_outline),
                onPressed: _delete,
              ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            key: const Key('casebook.entryView'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      icon: Icons.lock_outline,
                      text: l.casebookPrivacyBanner,
                    ),
                    const SizedBox(height: FeSpace.md),
                    TextField(
                      key: const Key('casebook.field.title'),
                      controller: _title,
                      onChanged: (_) => _touch(),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: l.casebookEntryTitleField,
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      key: const Key('casebook.field.caseRef'),
                      controller: _caseRef,
                      onChanged: (_) => _touch(),
                      decoration: InputDecoration(
                        labelText: l.casebookCaseRefField,
                        helperText: l.casebookCaseRefHint,
                        helperMaxLines: 2,
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    OutlinedButton.icon(
                      key: const Key('casebook.field.date'),
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                        '${l.casebookDateField}: '
                        '${feDate(context, _date)}',
                      ),
                      onPressed: _pickDate,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      key: const Key('casebook.field.body'),
                      controller: _body,
                      onChanged: (_) => _touch(),
                      minLines: 5,
                      maxLines: 14,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: l.casebookBodyField,
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    FilledButton.icon(
                      key: const Key('casebook.save'),
                      icon: const Icon(Icons.save_outlined),
                      label: Text(l.casebookSave),
                      onPressed: _saveWithMessage,
                    ),
                    FeSectionHeader(l.casebookLinksTitle),
                    if (_links.isEmpty)
                      FeEmptyState(
                        icon: Icons.link,
                        body: l.casebookLinksEmpty,
                        compact: true,
                      )
                    else
                      Wrap(
                        spacing: FeSpace.xs,
                        runSpacing: FeSpace.xs,
                        children: [
                          for (final k in _links)
                            InputChip(
                              key: Key('casebook.link.${k.id}'),
                              avatar: Icon(_linkIcon(k.kind), size: 18),
                              label: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 240,
                                ),
                                child: Text(
                                  k.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              deleteButtonTooltipMessage: l.casebookLinkRemove,
                              onPressed: () => _openLink(k),
                              onDeleted: () {
                                _links = [
                                  for (final x in _links)
                                    if (x != k) x,
                                ];
                                _touch();
                              },
                            ),
                        ],
                      ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        key: const Key('casebook.addLink'),
                        icon: const Icon(Icons.add_link),
                        label: Text(l.casebookAddLink),
                        onPressed: _addLink,
                      ),
                    ),
                    FeSectionHeader(l.casebookBlocksTitle),
                    if (blocks.isEmpty)
                      FeEmptyState(
                        key: const Key('casebook.blocksEmpty'),
                        icon: Icons.format_quote_outlined,
                        body: l.casebookBlocksEmpty,
                        compact: true,
                      ),
                    for (final (i, b) in blocks.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.sm),
                        child: _BlockCard(
                          key: Key('casebook.block.$i'),
                          block: b,
                          onRemove: () async {
                            await ref
                                .read(casebookProvider.notifier)
                                .removeBlock(_id!, b.id);
                            if (mounted) setState(() {});
                          },
                        ),
                      ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        key: const Key('casebook.addBlock'),
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: Text(l.casebookAddBlock),
                        onPressed: _addBlock,
                      ),
                    ),
                    const SizedBox(height: FeSpace.xl),
                    Text(
                      l.casebookExportDisclaimer,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: FeSpace.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _linkIcon(CasebookLinkKind k) => switch (k) {
  CasebookLinkKind.substance => Icons.hub_outlined,
  CasebookLinkKind.knowledge => Icons.biotech_outlined,
  CasebookLinkKind.guideline => Icons.assignment_outlined,
  CasebookLinkKind.tool => Icons.calculate_outlined,
  CasebookLinkKind.research => Icons.menu_book_outlined,
};

/// Ko‘chirilgan blok: matn, tur, manba va aniq joyi, iqtiboslar.
class _BlockCard extends StatelessWidget {
  const _BlockCard({super.key, required this.block, required this.onRemove});

  final CasebookBlock block;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final origin = [
      if (block.originTitle != null)
        '${l.casebookSourceLabel}: ${block.originTitle}',
      if (block.sectionTitle != null)
        '${l.casebookLocationLabel}: ${block.sectionTitle}',
    ].join(FeGlyphs.middleDot);
    return FeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  block.kind.label(l),
                  style: t.labelLarge?.copyWith(color: c.accent),
                ),
              ),
              IconButton(
                key: const Key('casebook.block.remove'),
                tooltip: l.casebookBlockRemove,
                icon: const Icon(Icons.close),
                onPressed: onRemove,
              ),
            ],
          ),
          if (block.isAiUnverified)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: FeBanner(
                key: const Key('casebook.block.aiUnverified'),
                icon: Icons.smart_toy_outlined,
                tone: FeBannerTone.warning,
                text: l.casebookAiUnverified,
              ),
            ),
          SelectableText(
            block.text,
            style: t.bodyMedium?.copyWith(height: 1.5),
          ),
          if (origin.isNotEmpty) ...[
            const SizedBox(height: FeSpace.xs),
            Text(origin, style: t.bodySmall?.copyWith(color: c.textSecondary)),
          ],
          if (block.citations.isNotEmpty) ...[
            const SizedBox(height: FeSpace.xs),
            Text(l.casebookSourcesLabel, style: t.labelMedium),
            for (final (n, cit) in block.citations.indexed)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '[${n + 1}] ${cit.text}'
                  '${cit.pages != null && !cit.text.contains(cit.pages!) ? ' ${l.casebookPagesLabel} ${cit.pages}' : ''}',
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Cheklov/ehtiyot bo‘limlari ro‘yxati (yo‘riqnoma kartalaridan).
class _BlockPicker extends StatefulWidget {
  const _BlockPicker({required this.bundle});

  final GuidelineBundle bundle;

  @override
  State<_BlockPicker> createState() => _BlockPickerState();
}

class _BlockPickerState extends State<_BlockPicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final q = _q.trim().toLowerCase();
    final items = <(GuidelineCard, GuidelineSection)>[
      for (final card in widget.bundle.cards)
        for (final s in card.sections)
          if (isCasebookSection(s) &&
              (q.isEmpty ||
                  card.title.of(lang).toLowerCase().contains(q) ||
                  s.body.of(lang).toLowerCase().contains(q)))
            (card, s),
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: FeSpace.md),
              child: Text(l.casebookPickerTitle, style: t.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.all(FeSpace.md),
              child: TextField(
                key: const Key('casebook.picker.search'),
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: l.casebookPickerSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? FeEmptyState(
                      icon: Icons.search_off,
                      body: l.casebookPickerEmpty,
                    )
                  : ListView.builder(
                      key: const Key('casebook.picker.list'),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) {
                        final (card, s) = items[i];
                        return ListTile(
                          key: Key('casebook.pick.${card.id}.${s.key}'),
                          isThreeLine: true,
                          title: Text(
                            card.title.of(lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title.of(lang),
                                style: t.labelMedium?.copyWith(color: c.accent),
                              ),
                              Text(
                                s.body.of(lang),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          onTap: () => Navigator.of(ctx).pop((card, s)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ilova obyektini qidirib bog‘lash (lokal qidiruv, oflayn).
class _LinkPicker extends ConsumerStatefulWidget {
  const _LinkPicker();

  @override
  ConsumerState<_LinkPicker> createState() => _LinkPickerState();
}

class _LinkPickerState extends ConsumerState<_LinkPicker> {
  String _q = '';
  List<CasebookLink> _results = const [];

  Future<void> _run(String q) async {
    setState(() => _q = q);
    if (q.trim().length < 2) {
      setState(() => _results = const []);
      return;
    }
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final r = await ref.read(searchServiceProvider).search(q, lang: lang);
    if (!mounted || q != _q) return;
    final library = ref.read(libraryRepositoryProvider);
    final knowledge = ref.read(knowledgeRepositoryProvider);
    final evidence = ref.read(evidenceDataProvider);
    final guidelines =
        ref.read(guidelinesProvider).value ?? GuidelineBundle.empty;
    final out = <CasebookLink>[];
    final seen = <String>{};
    CasebookLink? resolve(SearchGroup g, String id) {
      switch (g) {
        case SearchGroup.guidelines:
          final card = guidelines.byId(id);
          return card == null
              ? null
              : CasebookLink(
                  kind: CasebookLinkKind.guideline,
                  id: id,
                  label: card.title.of(lang),
                );
        case SearchGroup.tools:
          final tool = ToolsCatalog.byId(id);
          return tool == null
              ? null
              : CasebookLink(
                  kind: CasebookLinkKind.tool,
                  id: id,
                  label: l.toolName(tool),
                );
        case SearchGroup.references:
          final res = evidence.researchById(id);
          return res == null
              ? null
              : CasebookLink(
                  kind: CasebookLinkKind.research,
                  id: id,
                  label: res.title,
                );
        case SearchGroup.substances ||
            SearchGroup.methods ||
            SearchGroup.topics ||
            SearchGroup.reagents ||
            SearchGroup.screening:
          if (knowledge.byId(id) case final k?) {
            return CasebookLink(
              kind: CasebookLinkKind.knowledge,
              id: id,
              label: k.name.resolve(lang),
            );
          }
          if (library.byId(id) case final e?) {
            return CasebookLink(
              kind: CasebookLinkKind.substance,
              id: id,
              label: e.name.resolve(lang),
            );
          }
          return null;
        default:
          return null;
      }
    }

    for (final g in SearchGroup.values) {
      for (final hit in r.groups[g] ?? const <SearchHit>[]) {
        final link = resolve(g, hit.entityId);
        if (link != null && seen.add('${link.kind.name}:${link.id}')) {
          out.add(link);
        }
      }
    }
    setState(() => _results = out.take(40).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    ref.watch(guidelinesProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: FeSpace.md),
              child: Text(l.casebookAddLink, style: t.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.all(FeSpace.md),
              child: TextField(
                key: const Key('casebook.linkSearch'),
                autofocus: true,
                onChanged: _run,
                decoration: InputDecoration(
                  hintText: l.casebookLinkSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: _results.isEmpty
                  ? (_q.trim().length >= 2
                        ? FeEmptyState(
                            icon: Icons.search_off,
                            body: l.casebookLinkNoResults,
                          )
                        : const SizedBox.shrink())
                  : ListView.builder(
                      key: const Key('casebook.linkResults'),
                      itemCount: _results.length,
                      itemBuilder: (ctx, i) {
                        final k = _results[i];
                        return ListTile(
                          key: Key('casebook.linkResult.${k.id}'),
                          leading: Icon(_linkIcon(k.kind)),
                          title: Text(
                            k.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.of(ctx).pop(k),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
