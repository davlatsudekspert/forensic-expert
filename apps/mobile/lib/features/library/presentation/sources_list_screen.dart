import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import 'source_detail_screen.dart';

/// «Manbalar» — oflayn bazadagi barcha manbalar (yozuvlar keltirgan),
/// sarlavha bo‘yicha. Har biri manba sahifasiga olib boradi.
class SourcesListScreen extends ConsumerStatefulWidget {
  const SourcesListScreen({super.key});

  @override
  ConsumerState<SourcesListScreen> createState() => _SourcesListScreenState();
}

class _SourcesListScreenState extends ConsumerState<SourcesListScreen> {
  static const _normalizer = SearchNormalizer();
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final key = _normalizer.searchKey(_filter);
    final all = ref.watch(sourceIndexProvider).values.toList()
      ..sort(
        (a, b) => a.source.title.toLowerCase().compareTo(
          b.source.title.toLowerCase(),
        ),
      );
    final sources = key.isEmpty
        ? all
        : [
            for (final e in all)
              if (_normalizer
                  .searchKey(
                    [
                      e.source.title,
                      ?e.source.journal,
                      ?e.source.organization,
                    ].join(' '),
                  )
                  .contains(key))
                e,
          ];
    return Scaffold(
      appBar: AppBar(title: Text(l.libraryReferences)),
      body: SafeArea(
        child: ListView(
          key: const Key('sources.list'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  TextField(
                    key: const Key('sources.filter'),
                    onChanged: (v) => setState(() => _filter = v),
                    decoration: InputDecoration(
                      hintText: l.libraryFilterHint,
                      prefixIcon: const Icon(Icons.filter_list),
                      isDense: true,
                    ),
                  ),
                  FeSectionHeader(l.libraryCount(sources.length)),
                  if (sources.isEmpty)
                    FeEmptyState(
                      icon: Icons.menu_book_outlined,
                      body: l.sourcesEmpty,
                    ),
                  for (final (e, meta) in [
                    for (final e in sources)
                      (
                        e,
                        [
                          ?(e.source.journal ?? e.source.organization),
                          if (e.source.year case final y?) '$y',
                        ].join(' · '),
                      ),
                  ])
                    ListTile(
                      key: Key('sources.item.${e.source.sourceId}'),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.menu_book_outlined, color: c.accent),
                      title: Text(e.source.title),
                      subtitle: meta.isEmpty
                          ? null
                          : Text(
                              meta,
                              style: t.bodySmall?.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.push(Routes.source(e.source.sourceId)),
                    ),
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
