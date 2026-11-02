import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/catalog.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/catalog.dart';
import '../../../domain/teacher_card/teacher_card.dart';
import '../../teacher_card/presentation/teacher_card_widgets.dart';

/// «Ustozlar va mutaxassislar» katalogi (egasi so‘rovi, 2026-11-02):
/// yorliqlar, qidiruv, eng ko‘p yulduzcha olganlar tepada. Faqat hisobga
/// kirganlar ko‘radi va yulduzcha bosadi; katalogda faqat roziligi borlar.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _search = TextEditingController();
  String _query = '';

  /// Bosilgan yulduzchalar (server javobi) — ro‘yxat qayta yuklanmasdan.
  final _local = <String, (bool, int)>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _toggle(CatalogEntry e) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final r = await ref.read(catalogServiceProvider).toggleStar(e.id);
    if (!mounted) return;
    if (r.ok) {
      setState(() => _local[e.id] = r.value!);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l.catStarFailed)));
    }
  }

  CatalogEntry _merged(CatalogEntry e) => switch (_local[e.id]) {
    (final on, final n) => e.copyWith(starred: on, stars: n),
    null => e,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final signedIn = ref.watch(authStateProvider).signedIn;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: FeAppBarTitle(l.catTitle),
          bottom: TabBar(
            tabs: [
              Tab(key: const Key('cat.tab.teacher'), text: l.catTabTeachers),
              Tab(key: const Key('cat.tab.expert'), text: l.catTabExperts),
            ],
          ),
        ),
        body: SafeArea(
          child: !signedIn
              ? Center(
                  child: FeContentFrame(
                    child: FeEmptyState(
                      key: const Key('cat.signIn'),
                      icon: Icons.lock_outline,
                      body: l.catSignIn,
                      actionLabel: l.classSignInAction,
                      onAction: () => context.push(Routes.accountSignIn),
                    ),
                  ),
                )
              : Column(
                  children: [
                    FeContentFrame(
                      child: Padding(
                        padding: const EdgeInsets.only(top: FeSpace.sm),
                        child: TextField(
                          key: const Key('cat.search'),
                          controller: _search,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (v) => setState(() => _query = v.trim()),
                          decoration: InputDecoration(
                            hintText: l.catSearch,
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          for (final kind in CatalogKind.values)
                            _CatalogList(
                              kind: kind,
                              query: _query,
                              merged: _merged,
                              onStar: _toggle,
                            ),
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

class _CatalogList extends ConsumerWidget {
  const _CatalogList({
    required this.kind,
    required this.query,
    required this.merged,
    required this.onStar,
  });

  final CatalogKind kind;
  final String query;
  final CatalogEntry Function(CatalogEntry) merged;
  final Future<void> Function(CatalogEntry) onStar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(catalogListProvider((kind, query)));
    return switch (data) {
      AsyncData(:final value) when value.ok && value.value!.isNotEmpty =>
        ListView(
          key: Key('cat.list.${kind.wire}'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  for (final e in value.value!.map(merged))
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.sm),
                      child: _EntryCard(entry: e, onStar: () => onStar(e)),
                    ),
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      AsyncData(:final value) when value.ok => ListView(
        children: [
          FeContentFrame(
            child: FeEmptyState(
              key: Key('cat.empty.${kind.wire}'),
              icon: kind == CatalogKind.teacher
                  ? Icons.school_outlined
                  : Icons.verified_user_outlined,
              body: kind == CatalogKind.teacher
                  ? l.catEmptyTeachers
                  : l.catEmptyExperts,
            ),
          ),
        ],
      ),
      AsyncData() || AsyncError() => ListView(
        children: [
          FeContentFrame(
            child: FeEmptyState(
              key: const Key('cat.error'),
              icon: Icons.cloud_off_outlined,
              body: l.catLoadFailed,
              actionLabel: l.admTestsRefresh,
              onAction: () =>
                  ref.invalidate(catalogListProvider((kind, query))),
            ),
          ),
        ],
      ),
      _ => FeContentFrame(
        child: FeListSkeleton(rows: 4, semanticLabel: l.loadingContent),
      ),
    };
  }
}

/// Yulduzcha tugmasi: «⭐ 12»; o‘z yozuvida — faqat son.
class CatalogStarButton extends StatelessWidget {
  const CatalogStarButton({
    super.key,
    required this.entry,
    required this.onTap,
    this.large = false,
  });

  final CatalogEntry entry;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final on = entry.starred;
    const gold = Color(0xFFE0A100);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          on ? Icons.star_rounded : Icons.star_outline_rounded,
          color: on || entry.mine ? gold : c.textSecondary,
          size: large ? 28 : 24,
        ),
        const SizedBox(width: FeSpace.xxs),
        Text(
          entry.stars.toString(),
          style: (large ? t.titleMedium : t.titleSmall)?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
    if (entry.mine) {
      return Semantics(
        label: l.catStarsCount(entry.stars),
        child: Padding(padding: const EdgeInsets.all(FeSpace.xs), child: child),
      );
    }
    return Semantics(
      button: true,
      toggled: on,
      label: on ? l.catUnstar : l.catStar,
      child: InkWell(
        key: Key('cat.star.${entry.id}'),
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: FeTouch.minTarget),
          padding: const EdgeInsets.symmetric(horizontal: FeSpace.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: on ? gold.withValues(alpha: 0.15) : null,
            border: Border.all(color: on ? gold : c.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.onStar});

  final CatalogEntry entry;
  final Future<void> Function() onStar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: Key('cat.item.${entry.id}'),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _EntrySheet(entry: entry, onStar: onStar),
      ),
      child: Row(
        children: [
          TeacherPhoto(name: entry.name, path: entry.photoPath, size: 56),
          const SizedBox(width: FeSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: t.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.subtitle.isNotEmpty)
                  Text(
                    entry.subtitle,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (entry.category case final cat?
                    when cat != TeacherCategory.none)
                  Text(
                    teacherCategoryName(l, cat),
                    style: t.labelMedium?.copyWith(color: c.accent),
                  ),
              ],
            ),
          ),
          const SizedBox(width: FeSpace.xs),
          CatalogStarButton(entry: entry, onTap: onStar),
        ],
      ),
    );
  }
}

/// To‘liq ko‘rinish: profil boshi uslubida + katta yulduzcha tugmasi.
class _EntrySheet extends StatefulWidget {
  const _EntrySheet({required this.entry, required this.onStar});

  final CatalogEntry entry;
  final Future<void> Function() onStar;

  @override
  State<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends State<_EntrySheet> {
  late CatalogEntry _e = widget.entry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          FeSpace.md,
          0,
          FeSpace.md,
          FeSpace.lg,
        ),
        child: Column(
          children: [
            TeacherCardView(card: _e.toCard()),
            const SizedBox(height: FeSpace.md),
            CatalogStarButton(
              key: const Key('cat.sheetStar'),
              entry: _e,
              large: true,
              onTap: () async {
                await widget.onStar();
                if (!mounted) return;
                setState(
                  () => _e = _e.copyWith(
                    starred: !_e.starred,
                    stars: _e.stars + (_e.starred ? -1 : 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
