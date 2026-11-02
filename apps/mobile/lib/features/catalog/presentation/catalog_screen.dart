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
import '../../../core/settings/app_settings.dart' show UserMode;
import '../../../core/settings/settings_controller.dart';
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
    final mode = ref.watch(
      settingsControllerProvider.select((s) => s.userMode),
    );
    // Ikkala yorliq hammaga; rejimga qarab o‘z bo‘limi birinchi ochiladi
    // (Mutaxassis → «Mutaxassislar»), egasi, 2026-11-02.
    const kinds = CatalogKind.values;
    return DefaultTabController(
      key: ValueKey(mode),
      length: kinds.length,
      initialIndex: mode == UserMode.professional ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: FeAppBarTitle(l.catTitle),
          bottom: kinds.length < 2
              ? null
              : TabBar(
                  tabs: [
                    Tab(
                      key: const Key('cat.tab.teacher'),
                      text: l.catTabTeachers,
                    ),
                    Tab(
                      key: const Key('cat.tab.expert'),
                      text: l.catTabExperts,
                    ),
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
                      child: kinds.length < 2
                          ? _CatalogList(
                              kind: kinds.single,
                              query: _query,
                              merged: _merged,
                              onStar: _toggle,
                            )
                          : TabBarView(
                              children: [
                                for (final kind in kinds)
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                _NameWithBadge(
                  name: entry.name,
                  verified: entry.verified,
                  style: t.titleSmall,
                ),
                if (entry.founder)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: FeSpace.xxs),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FounderBadge(compact: true),
                    ),
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

/// To‘liq ko‘rinish (premium, sokin): to‘q brend sarlavha nozik oltin
/// halqalar bilan, katta rasm, ism, ish joyi, toifa, ma’lumot, tarmoqlar va
/// pastda yulduzcha. Bo‘sh maydonlar ko‘rsatilmaydi (egasi, 2026-11-02).
class _EntrySheet extends StatefulWidget {
  const _EntrySheet({required this.entry, required this.onStar});

  final CatalogEntry entry;
  final Future<void> Function() onStar;

  @override
  State<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends State<_EntrySheet> {
  late CatalogEntry _e = widget.entry;

  Future<void> _toggle() async {
    await widget.onStar();
    if (!mounted) return;
    setState(
      () => _e = _e.copyWith(
        starred: !_e.starred,
        stars: _e.stars + (_e.starred ? -1 : 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    const photo = 116.0;
    const band = 132.0;
    final card = _e.toCard();
    final cat = _e.category;
    final hasCat = cat != null && cat != TeacherCategory.none;
    final hasSocials = _e.socials.isNotEmpty;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        key: const Key('cat.sheet'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: band + photo / 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: FeSpace.md,
                    right: FeSpace.md,
                    top: 0,
                    height: band,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(FeRadius.card),
                      child: TeacherCoverLayer(
                        path: _e.coverPath,
                        fallback: DecoratedBox(
                          decoration: const BoxDecoration(
                            // Har ikki mavzuda bir xil to‘q «muhr» rangi.
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1C2433), Color(0xFF0E1219)],
                            ),
                          ),
                          child: CustomPaint(
                            painter: _RingsPainter(c.accent),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: band - photo / 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.surface,
                          border: Border.all(
                            color: c.accent.withValues(alpha: 0.85),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Color(0x1F000000), blurRadius: 16),
                          ],
                        ),
                        child: TeacherPhoto(
                          name: _e.name,
                          path: _e.photoPath,
                          size: photo - 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FeSpace.lg,
                FeSpace.md,
                FeSpace.lg,
                FeSpace.lg,
              ),
              child: Column(
                children: [
                  Text(
                    (_e.kind == CatalogKind.teacher
                            ? l.modeTeacher
                            : l.modeProfessional)
                        .toUpperCase(),
                    style: t.labelSmall?.copyWith(
                      color: c.accent,
                      letterSpacing: 2.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: FeSpace.xs),
                  _NameWithBadge(
                    name: _e.name,
                    verified: _e.verified,
                    nameKey: const Key('cat.sheetName'),
                    style: t.headlineSmall?.copyWith(height: 1.15),
                    textAlign: TextAlign.center,
                    iconSize: 22,
                  ),
                  if (_e.founder) ...[
                    const SizedBox(height: FeSpace.xs),
                    const FounderBadge(),
                  ],
                  if (_e.subtitle.isNotEmpty) ...[
                    const SizedBox(height: FeSpace.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.apartment_outlined,
                            size: 18,
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(width: FeSpace.xxs),
                        Flexible(
                          child: Text(
                            _e.subtitle,
                            textAlign: TextAlign.center,
                            style: t.bodyMedium?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (hasCat) ...[
                    const SizedBox(height: FeSpace.sm),
                    Container(
                      key: const Key('cat.sheetCategory'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: FeSpace.sm,
                        vertical: FeSpace.xxs,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: c.accent.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        teacherCategoryName(l, cat),
                        style: t.labelLarge?.copyWith(color: c.accent),
                      ),
                    ),
                  ],
                  const SizedBox(height: FeSpace.md),
                  _HairlineDivider(color: c.accent),
                  if (_e.bio.isNotEmpty) ...[
                    const SizedBox(height: FeSpace.md),
                    Text(
                      _e.bio,
                      key: const Key('cat.sheetBio'),
                      textAlign: TextAlign.center,
                      style: t.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ],
                  if (hasSocials) ...[
                    const SizedBox(height: FeSpace.md),
                    TeacherSocialRow(card: card),
                  ],
                  const SizedBox(height: FeSpace.lg),
                  CatalogStarButton(
                    key: const Key('cat.sheetStar'),
                    entry: _e,
                    large: true,
                    onTap: _toggle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ism + (tasdiqlangan bo‘lsa) kichik belgi. Belgi ism bilan bir qatorda
/// qoladi (uzun ismda ham), semantikada «Tasdiqlangan mutaxassis».
class _NameWithBadge extends StatelessWidget {
  const _NameWithBadge({
    required this.name,
    required this.verified,
    required this.style,
    this.nameKey,
    this.textAlign = TextAlign.start,
    this.iconSize = 17,
  });

  final String name;
  final bool verified;
  final TextStyle? style;
  final Key? nameKey;
  static const maxLines = 3;
  final TextAlign textAlign;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      name,
      key: nameKey,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
    if (!verified) return text;
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    // Belgi ismning oxirgi so‘zidan keyin darhol turadi (uzun ism bo‘lsa ham
    // ism bilan birga ko‘chadi).
    return Text.rich(
      TextSpan(
        text: name,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: FeSpace.xxs),
              child: Tooltip(
                message: l.catVerifiedExpert,
                child: Semantics(
                  label: l.catVerifiedExpert,
                  image: true,
                  child: ExcludeSemantics(
                    child: Icon(
                      Icons.verified,
                      key: const Key('cat.verifiedBadge'),
                      size: iconSize,
                      color: c.accent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      key: nameKey,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Markazda kichik oltin romb bilan ikki tomonga ingichka chiziq.
class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(height: 1, color: color.withValues(alpha: 0.25)),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FeSpace.sm),
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 6,
              height: 6,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ),
        line,
      ],
    );
  }
}

/// Sarlavhadagi nozik konsentrik halqalar (bosh sahifa uslubida).
class _RingsPainter extends CustomPainter {
  const _RingsPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.18);
    final center = Offset(size.width * 0.86, size.height * 0.1);
    for (var r = 36.0; r < size.width; r += 30) {
      canvas.drawCircle(center, r, p);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.color != color;
}
