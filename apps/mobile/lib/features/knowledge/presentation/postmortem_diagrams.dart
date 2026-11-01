import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';

/// Murdaning ilk o‘zgarishlari sxemalari (egasi talabi, 2026-11-01):
/// murda dog‘lari, murda qotishi, murdaning sovishi.
///
/// Barcha raqamlar bitta manbadan: G‘iyosov Z.A. Sud tibbiyoti: darslik.
/// Toshkent: Global Books, 2018 — 224 (sovish), 225–226 (qotish),
/// 227–228 (murda dog‘lari) betlar. Sxema — o‘quv tasviri, aniq holat
/// uchun o‘lim vaqtini hisoblash vositasi emas.
abstract final class PostmortemDiagrams {
  static const _book =
      'G‘iyosov Z.A. Sud tibbiyoti: darslik. Toshkent: Global Books, 2018';

  /// Bilim yozuvi uchun sxema (yo‘q bo‘lsa — `null`).
  static Widget? forEntity(String id) => switch (id) {
    'fm-livor-mortis' => const _LivorDiagram(),
    'fm-rigor-mortis' => const _RigorDiagram(),
    'fm-algor-mortis' => const _AlgorDiagram(),
    _ => null,
  };
}

/// Sxema kartasi: sarlavha, chizma, izoh va manba.
class _DiagramCard extends StatelessWidget {
  const _DiagramCard({
    required this.id,
    required this.child,
    required this.pages,
    this.note,
  });

  final String id;
  final Widget child;
  final String pages;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.pmdTitle),
        FeCard(
          key: Key('pmd.$id'),
          padding: const EdgeInsets.all(FeSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              child,
              if (note != null) ...[
                const SizedBox(height: FeSpace.sm),
                Text(
                  note!,
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ],
              const SizedBox(height: FeSpace.sm),
              Text(
                '${l.pmdSourceLabel}: ${PostmortemDiagrams._book}, $pages',
                key: Key('pmd.$id.source'),
                style: t.labelSmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Vaqt o‘qi (soat) va unda chiziqlar. Belgilar teng oraliqda turadi;
/// qiymat ular orasida chiziqli joylashadi (qisqa va uzun muddatlar bir
/// sxemada sig‘ishi uchun).
class _Band {
  const _Band(this.label, this.from, this.to, this.color, {this.fadeTo});

  final String label;
  final double from;
  final double to;
  final Color color;

  /// Oxiri noaniq (masalan, 8–12 soat): `to` dan `fadeTo` gacha so‘nadi.
  final double? fadeTo;
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.ticks, required this.bands, this.tickLabel});

  final List<double> ticks;
  final List<_Band> bands;
  final String Function(double)? tickLabel;

  double _x(double v, double w) {
    if (v <= ticks.first) return 0;
    if (v >= ticks.last) return w;
    final seg = w / (ticks.length - 1);
    for (var i = 0; i < ticks.length - 1; i++) {
      final a = ticks[i], b = ticks[i + 1];
      if (v <= b) return seg * (i + (v - a) / (b - a));
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    // Birlik faqat oxirgi belgida — belgilar bir-biriga tegmaydi.
    String label(double h) {
      final custom = tickLabel?.call(h);
      if (custom != null) return custom;
      final n = h % 1 == 0 ? '${h.toInt()}' : '$h';
      return h == ticks.last ? '$n ${l.pmdHoursShort}' : n;
    }

    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final b in bands) ...[
              Text(b.label, style: t.labelMedium),
              const SizedBox(height: 2),
              SizedBox(
                height: 14,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.border.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _x(b.from, w),
                      width: (_x(b.fadeTo ?? b.to, w) - _x(b.from, w)).clamp(
                        4.0,
                        w,
                      ),
                      top: 0,
                      bottom: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          gradient: LinearGradient(
                            colors: [
                              b.color,
                              b.color,
                              if (b.fadeTo != null)
                                b.color.withValues(alpha: 0),
                            ],
                            stops: b.fadeTo == null
                                ? const [0, 1]
                                : [
                                    0,
                                    ((_x(b.to, w) - _x(b.from, w)) /
                                            (_x(b.fadeTo!, w) - _x(b.from, w)))
                                        .clamp(0.0, 1.0),
                                    1,
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FeSpace.xs),
            ],
            SizedBox(
              height: 16,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final (i, h) in ticks.indexed)
                    Positioned(
                      left: i == 0
                          ? 0
                          : i == ticks.length - 1
                          ? null
                          : _x(h, w) - 20,
                      right: i == ticks.length - 1 ? 0 : null,
                      width: i == 0 || i == ticks.length - 1 ? null : 40,
                      child: Text(
                        label(h),
                        textAlign: i == 0
                            ? TextAlign.left
                            : i == ticks.length - 1
                            ? TextAlign.right
                            : TextAlign.center,
                        style: t.labelSmall?.copyWith(color: c.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LivorDiagram extends StatelessWidget {
  const _LivorDiagram();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    Widget swatch(Color color, String text) => Padding(
      padding: const EdgeInsets.only(top: FeSpace.xxs),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: FeSpace.xs),
          Expanded(child: Text(text, style: t.bodySmall)),
        ],
      ),
    );
    return _DiagramCard(
      id: 'livor',
      pages: '227–228-betlar',
      note: l.pmdLivorNote,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Timeline(
            ticks: const [0, 2, 8, 12, 24, 36],
            bands: [
              _Band(
                '${l.pmdLivorHypostasis}: 1,5–2 → 8–12 ${l.pmdHoursShort} · '
                '${l.pmdPressVanish}',
                1.5,
                8,
                const Color(0xFF6B5B95),
                fadeTo: 12,
              ),
              _Band(
                '${l.pmdLivorStasis}: 12–24 ${l.pmdHoursShort} · '
                '${l.pmdPressPale}',
                12,
                24,
                const Color(0xFF8E4B6A),
              ),
              _Band(
                '${l.pmdLivorImbibition}: > 24 ${l.pmdHoursShort} · '
                '${l.pmdPressFixed}',
                24,
                36,
                const Color(0xFF6E3B3B),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.sm),
          Text(l.pmdLivorColors, style: t.labelMedium),
          swatch(const Color(0xFFE5737F), l.pmdLivorCo),
          swatch(const Color(0xFFB0283F), l.pmdLivorCn),
          swatch(const Color(0xFF7A4A2E), l.pmdLivorMethb),
        ],
      ),
    );
  }
}

class _RigorDiagram extends StatelessWidget {
  const _RigorDiagram();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    String tick(double h) =>
        h >= 72 ? '${(h / 24).round()} ${l.pmdDaysShort}' : '${h.toInt()}';
    return _DiagramCard(
      id: 'rigor',
      pages: '225–226-betlar',
      note: l.pmdRigorOrder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Timeline(
            ticks: const [0, 3, 16, 24, 36, 72, 168],
            tickLabel: tick,
            bands: [
              _Band(
                '${l.pmdRigorGrowth}: 1–3 → 12–16 ${l.pmdHoursShort}',
                1,
                16,
                const Color(0xFF2E8C86),
              ),
              _Band(
                '${l.pmdRigorMax}: 24 ${l.pmdHoursShort}',
                16,
                36,
                const Color(0xFF0B1B2B),
              ),
              _Band(
                '${l.pmdRigorResolve}: 36 ${l.pmdHoursShort} → 3–7 '
                '${l.pmdDaysShort}',
                36,
                72,
                const Color(0xFFB08A3E),
                fadeTo: 168,
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          Text(l.pmdRigorFacts, style: t.bodySmall),
        ],
      ),
    );
  }
}

class _AlgorDiagram extends StatelessWidget {
  const _AlgorDiagram();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return _DiagramCard(
      id: 'algor',
      pages: '224-bet',
      note: l.pmdAlgorNote,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.pmdAlgorRate, style: t.bodyMedium),
          const SizedBox(height: FeSpace.sm),
          Text(l.pmdAlgorEquals, style: t.labelMedium),
          const SizedBox(height: FeSpace.xs),
          _Timeline(
            ticks: const [0, 8, 16, 19, 25],
            bands: [
              _Band(
                '${l.pmdAlgorAxilla}: 16 ${l.pmdHoursShort}',
                0,
                16,
                const Color(0xFF2E8C86),
              ),
              _Band(
                '${l.pmdAlgorRectum}: 19 ${l.pmdHoursShort}',
                0,
                19,
                const Color(0xFF1F5E7A),
              ),
              _Band(
                '${l.pmdAlgorLiver}: 25 ${l.pmdHoursShort}',
                0,
                25,
                const Color(0xFF0B1B2B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
