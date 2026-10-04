import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/library/library_models.dart';
import '../../placeholder/presentation/in_development_view.dart';

extension LibrarySectionL10n on LibrarySection {
  String label(AppLocalizations l) => switch (this) {
    LibrarySection.substances => l.librarySubstances,
    LibrarySection.methods => l.libraryMethods,
    LibrarySection.specimens => l.librarySpecimens,
    LibrarySection.references => l.libraryReferences,
    LibrarySection.glossary => l.libraryGlossary,
  };

  IconData get icon => switch (this) {
    LibrarySection.substances => Icons.hub_outlined,
    LibrarySection.methods => Icons.biotech_outlined,
    LibrarySection.specimens => Icons.water_drop_outlined,
    LibrarySection.references => Icons.menu_book_outlined,
    LibrarySection.glossary => Icons.translate,
  };
}

enum _StatusFilter { all, verified, reviewed, needsReview }

/// Ilmiy ma’lumotnoma markazi: bo‘limlar, filtr va bo‘lim ichida qidiruv.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibrarySection _section = LibrarySection.substances;
  _StatusFilter _status = _StatusFilter.all;
  String _filter = '';
  static const _normalizer = SearchNormalizer();

  bool _matches(LibraryEntry e) {
    final okStatus = switch (_status) {
      _StatusFilter.all => true,
      _StatusFilter.verified => e.status == ScientificStatus.verified,
      _StatusFilter.reviewed => e.status == ScientificStatus.reviewed,
      _StatusFilter.needsReview => e.status == ScientificStatus.needsReview,
    };
    if (!okStatus) return false;
    final key = _normalizer.searchKey(_filter);
    if (key.isEmpty) return true;
    return [
      ...e.name.values.values,
      ...e.synonyms,
    ].any((n) => _normalizer.searchKey(n).contains(key));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final repo = ref.watch(libraryRepositoryProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final all = repo.entries(_section);
    final entries = all.where(_matches).toList();

    String statusLabel(_StatusFilter s) => switch (s) {
      _StatusFilter.all => l.filterAll,
      _StatusFilter.verified => l.statusVerified,
      _StatusFilter.reviewed => l.statusReviewed,
      _StatusFilter.needsReview => l.statusNeedsReview,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.libraryTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final s in LibrarySection.values)
                          Padding(
                            padding: const EdgeInsets.only(right: FeSpace.xs),
                            child: ChoiceChip(
                              key: Key('library.section.${s.name}'),
                              avatar: Icon(s.icon, size: 18),
                              label: Text(s.label(l)),
                              selected: _section == s,
                              onSelected: (_) => setState(() => _section = s),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  TextField(
                    key: const Key('library.filter'),
                    onChanged: (v) => setState(() => _filter = v),
                    decoration: InputDecoration(
                      hintText: l.libraryFilterHint,
                      prefixIcon: const Icon(Icons.filter_list),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: FeSpace.xs),
                  Wrap(
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xxs,
                    children: [
                      for (final s in _StatusFilter.values)
                        FilterChip(
                          key: Key('library.status.${s.name}'),
                          label: Text(statusLabel(s)),
                          selected: _status == s,
                          onSelected: (_) => setState(() => _status = s),
                        ),
                    ],
                  ),
                  FeSectionHeader(_section.label(l)),
                  if (all.isEmpty)
                    const InDevelopmentView(
                      icon: Icons.local_library_outlined,
                      embedded: true,
                    )
                  else if (entries.isEmpty)
                    FeEmptyState(
                      icon: Icons.filter_alt_off_outlined,
                      body: l.libraryEmptyFiltered,
                    )
                  else
                    for (final e in entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.xs),
                        child: FeCard(
                          key: Key('library.entry.${e.id}'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: FeSpace.md,
                            vertical: FeSpace.sm,
                          ),
                          onTap: () => context.go(Routes.libraryEntry(e.id)),
                          child: Row(
                            children: [
                              Icon(_section.icon, color: c.accent),
                              const SizedBox(width: FeSpace.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.name.resolve(lang),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const SizedBox(height: FeSpace.xxs),
                                    Wrap(
                                      spacing: FeSpace.xs,
                                      runSpacing: FeSpace.xxs,
                                      children: [
                                        ReviewStatusBadge(status: e.status),
                                        if (e.isTestData) const TestDataBadge(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ExcludeSemantics(
                                child: Icon(
                                  Icons.chevron_right,
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
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
