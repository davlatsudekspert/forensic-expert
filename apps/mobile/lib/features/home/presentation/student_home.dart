import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/dna.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/fe_components.dart';
import '../daily_question.dart';
import '../workbench.dart';
import 'home_desks.dart' show DailyQuestionCard;
import 'panel_banner.dart';

/// Talaba bosh sahifasi («Mening akademiyam», egasi qarori, 2026-11-04) uchun
/// alohida vidjetlar. FAQAT `UserMode.student`: Ustoz va Mutaxassis ekranlari
/// ulashilgan vidjetlardan (`home_desks.dart`) foydalanishda davom etadi va
/// bu yerdagi hech narsaga bog‘liq emas.

/// Tor ekranda ikki ustun sig‘maydi: kenglik < 300 dp yoki matn ×1.6+.
bool _singleColumn(BuildContext context, double width) =>
    width < 300 || MediaQuery.textScalerOf(context).scale(1) >= 1.6;

/// Sarlavha: logotip, nom va shior. Qo‘ng‘iroqcha yo‘q (egasi qarori).
class StudentHomeHeader extends StatelessWidget {
  const StudentHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: FeContentFrame(
          child: Padding(
            padding: const EdgeInsets.only(top: FeSpace.sm),
            child: Row(
              key: const Key('home.header'),
              children: [
                const BrandMark(size: 44),
                const SizedBox(width: FeSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l.appTitle,
                          maxLines: 1,
                          style: t.titleMedium?.copyWith(
                            color: c.textPrimary,
                            letterSpacing: 1.6,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l.appTagline,
                          maxLines: 1,
                          style: t.labelMedium?.copyWith(
                            color: c.accent,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner: «Mening akademiyam» + «Bugun nimani o‘rganamiz?». Ustoz banneri
/// bilan bir xil [PanelBanner] dizayni (oq/qora mavzuga mos).
class StudentAcademyBanner extends StatelessWidget {
  const StudentAcademyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PanelBanner(
      key: const Key('student.banner'),
      title: l.studentDeskTitle,
      tagline: l.homeGreetingStudent,
      emblem: const StudentEmblemFrame(),
    );
  }
}

/// «Bugungi savol»: mavjud [DailyQuestionCard] (savol, javob, manba, izoh
/// mexanizmi o‘zgarishsiz), faqat oltin chegarali ko‘rinishda. Strelka —
/// savolning to‘liq izohi va mashqi ochiladigan mavjud ekranga o‘tadi.
class StudentDailyQuestion extends ConsumerWidget {
  const StudentDailyQuestion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final question = ref.watch(dailyQuestionProvider(lang));
    if (question == null) return const SizedBox.shrink();
    final c = FeTheme.of(context);
    final theme = Theme.of(context);
    final fe = theme.extension<FeTheme>()!;
    // Karta o‘zgarmaydi: faqat chegara rangi shu bo‘lim ichida oltin.
    final gold = Theme(
      data: theme.copyWith(
        extensions: [
          fe.copyWith(
            colors: _withBorder(c, c.accent),
            highContrast: fe.highContrast,
          ),
        ],
      ),
      child: DailyQuestionCard(
        key: ValueKey('daily.q.${question.item.id}'),
        question: question,
      ),
    );
    return Stack(
      children: [
        gold,
        PositionedDirectional(
          top: 6,
          end: 8,
          child: Semantics(
            button: true,
            label: l.dailyQuestionExplain,
            excludeSemantics: true,
            child: InkResponse(
              key: const Key('student.dailyQuestion.open'),
              radius: 22,
              onTap: () => context.push(Routes.studyQuiz(question.item.deckId)),
              child: SizedBox.square(
                dimension: 36,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.accent,
                  ),
                  child: Icon(Icons.arrow_forward, size: 18, color: c.onAccent),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static FeColorTokens _withBorder(FeColorTokens c, Color border) =>
      FeColorTokens(
        background: c.background,
        surface: c.surface,
        surfaceRaised: c.surfaceRaised,
        surfaceSunken: c.surfaceSunken,
        border: border,
        borderStrong: c.borderStrong,
        textPrimary: c.textPrimary,
        textSecondary: c.textSecondary,
        textOnBrand: c.textOnBrand,
        brand: c.brand,
        brandContainer: c.brandContainer,
        accent: c.accent,
        onAccent: c.onAccent,
        accentContainer: c.accentContainer,
        onAccentContainer: c.onAccentContainer,
        accentBorder: c.accentBorder,
        verified: c.verified,
        reviewed: c.reviewed,
        warning: c.warning,
        warningContainer: c.warningContainer,
        onWarningContainer: c.onWarningContainer,
        outdated: c.outdated,
        danger: c.danger,
        focusRing: c.focusRing,
      );
}

/// «O‘quv mashg‘ulotlari»: 2×2 teng balandlikdagi to‘rt karta (Barcha
/// mavzular, Testlar va kartochkalar, Imtihon rejimi, Guruhim). Nomlar,
/// marshrutlar va ikonka ranglari — mavjud `Workbench.studentCards`.
class StudentLearnGrid extends StatelessWidget {
  const StudentLearnGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Workbench.studentCards;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _singleColumn(context, constraints.maxWidth) ? 1 : 2;
        const gap = FeSpace.sm;
        return Column(
          children: [
            for (var i = 0; i < items.length; i += columns)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i + columns < items.length ? gap : 0,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var j = 0; j < columns; j++) ...[
                        if (j > 0) const SizedBox(width: gap),
                        Expanded(
                          child: i + j < items.length
                              ? _LearnCard(item: items[i + j])
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LearnCard extends StatelessWidget {
  const _LearnCard({required this.item});

  final WorkbenchItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final b = Theme.of(context).brightness;
    return gateWorkbenchItem(
      context,
      item.id,
      FeCard(
        key: item.key,
        padding: const EdgeInsets.all(FeSpace.md - 2),
        onTap: () =>
            item.isTab ? context.go(item.route) : context.push(item.route),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: item.hue.bg(b),
                borderRadius: BorderRadius.circular(FeRadius.md),
              ),
              child: SizedBox.square(
                dimension: 44,
                child: Icon(item.icon, color: item.hue.fg(b), size: 24),
              ),
            ),
            const SizedBox(height: FeSpace.sm),
            Text(
              item.title(l),
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.body(l),
              style: t.bodySmall?.copyWith(color: c.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// «Ilmiy va amaliy bo‘limlar»: gorizontal aylantiriladigan 3 karta (DNK
/// ekspertizasi, Virtual autopsiya, Asbob-uskunalar) va nozik sahifa
/// indikatori. Asl rasmlar kesilmaydi va cho‘zilmaydi. Ekran chetigacha
/// ochiq — shu sababli `FeContentFrame` ichiga qo‘yilmaydi.
class StudentScienceCarousel extends ConsumerStatefulWidget {
  const StudentScienceCarousel({super.key});

  @override
  ConsumerState<StudentScienceCarousel> createState() =>
      _StudentScienceCarouselState();
}

class _StudentScienceCarouselState
    extends ConsumerState<StudentScienceCarousel> {
  static const _cardWidth = 152.0;
  static const _gap = FeSpace.sm;

  final _controller = ScrollController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _controller.position.maxScrollExtent;
    final count = _count;
    var page = 0;
    if (max > 0 && count > 1) {
      page = (_controller.offset / max * (count - 1)).round().clamp(
        0,
        count - 1,
      );
    }
    if (page != _page) setState(() => _page = page);
  }

  int get _count =>
      _items(!(ref.read(dnaProvider).value?.isEmpty ?? true)).length;

  // (kalit, rasm, rasmning o‘z foni, nomi, marshrut)
  List<_ScienceItem> _items(bool hasDna) {
    final l = AppLocalizations.of(context);
    return [
      if (hasDna)
        _ScienceItem(
          'home.new.dna',
          'dna_banner',
          const Color(0xFFFEF2E8),
          l.dnaTitle,
          Routes.dna,
          Alignment.centerRight,
        ),
      _ScienceItem(
        'home.new.virtopsy',
        'virtopsy',
        const Color(0xFFF2EAE3),
        l.homeNewVirtopsy,
        Routes.equipmentItem('virtopsy'),
        Alignment.center,
      ),
      _ScienceItem(
        'home.new.equipment',
        'gc_ms',
        const Color(0xFFFAF0E6),
        l.equipTitle,
        Routes.equipment,
        Alignment.center,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final hasDna = !(ref.watch(dnaProvider).value?.isEmpty ?? true);
    final items = _items(hasDna);
    final width = MediaQuery.sizeOf(context).width;
    final g = FeBreakpoints.gutter(context);
    final side =
        g + (width - FeBreakpoints.maxContentWidth).clamp(0.0, 1e6) / 2;
    return Column(
      key: const Key('home.new'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          key: const Key('student.science.scroll'),
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsetsDirectional.fromSTEB(side, FeSpace.xxs, side, 6),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, it) in items.indexed) ...[
                  if (i > 0) const SizedBox(width: _gap),
                  SizedBox(
                    width: _cardWidth,
                    child: FeCard(
                      key: Key(it.key),
                      padding: EdgeInsets.zero,
                      onTap: () => context.push(it.route),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 1.2,
                            child: ColoredBox(
                              color: it.matte,
                              child: Image.asset(
                                'assets/images/instruments/${it.image}.webp',
                                fit: BoxFit.contain,
                                alignment: it.alignment,
                                excludeFromSemantics: true,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              FeSpace.sm - 2,
                              FeSpace.sm - 2,
                              FeSpace.sm - 2,
                              FeSpace.sm,
                            ),
                            child: Text(
                              it.title,
                              style: t.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: FeSpace.xs),
        ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < items.length; i++)
                AnimatedContainer(
                  duration: FeMotion.of(context, FeMotion.fast),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i == _page
                        ? c.accent
                        : c.textSecondary.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScienceItem {
  const _ScienceItem(
    this.key,
    this.image,
    this.matte,
    this.title,
    this.route,
    this.alignment,
  );

  final String key;
  final String image;

  /// Rasmning o‘z foni (rasm kesilmasligi uchun `contain`; chetlari shu rangda).
  final Color matte;
  final String title;
  final String route;
  final Alignment alignment;
}
