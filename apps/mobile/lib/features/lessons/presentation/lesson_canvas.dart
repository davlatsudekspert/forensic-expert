import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/lessons/lesson_models.dart';
import 'lesson_slide_view.dart';

/// Proyektor/taqdimot kanvasi: har bir sahifa qat’iy 1280×720 «dizayn»
/// kanvasida chiziladi va ekranga bir xil nisbatda (16:9, chetlari bo‘sh)
/// kattalashtiriladi/kichraytiriladi. Kanvas ichida tizim matn masshtabi
/// qo‘llanmaydi; asosiy matn o‘lchami [TextPainter] bilan o‘lchab tanlanadi
/// ([bodySizes] dan sig‘adigan eng kattasi). Uzun slaydlar oldindan
/// [buildLessonPages] da davom sahifalariga bo‘linadi (shu o‘lchov bilan),
/// shuning uchun hech bir sahifa kichraytirilmaydi va kesilmaydi.
abstract final class LessonCanvasMetrics {
  static const double width = 1280;
  static const double height = 720;
  static const double padX = 64;
  static const double padTop = 44;
  static const double padBottom = 28;
  static const double contentW = width - 2 * padX;
  static const double innerH = height - padTop - padBottom;

  /// Asosiy matn nomzodlari (dizayn px), kattasidan boshlab.
  static const bodySizes = [34.0, 32.0, 30.0, 28.0, 26.0, 24.0];

  /// Eng kichik ruxsat etilgan asosiy matn.
  static const double minBody = 24;

  /// Uzun slayd shu o‘lchamda bo‘linadi (bo‘lingan sahifalar ≥ 26 px).
  static const double packBody = 26;

  static const double sourceSize = 18;
  static const double sourceLh = 1.3;
  static const double footerGap = 14;
  static const double trailingGap = 16;
  static const double counterW = 120;
  static const double actionW = 440;
  static const double actionH = 96;
  static const double sideGap = 40;
  static const double flowMaxW = 760;
  static const double bodyLh = 1.35;
  static const double titleLh = 1.2;
  static const double cellLh = 1.25;

  static double titleSize(double body) => body * 1.3;
  static double titleGap(double body) => body * 0.7;
  static double bulletGap(double body) => body * 0.5;
  static double markerW(double body) => body * 0.9;
  static double diagramGap(double body) => body * 0.6;
  static double cellPad(double body) => body * 0.45;
  static double captionSize(double body) => math.max(18, body * 0.75);
  static double iconSize(double body) => body * 0.85;
}

/// Kanvas matn uslubi: o‘lchov va chizish bir xil uslubdan foydalanadi
/// (`inherit: false` — atrofdagi DefaultTextStyle aralashmaydi).
TextStyle lessonCanvasText(
  double size, {
  double height = LessonCanvasMetrics.bodyLh,
  FontWeight weight = FontWeight.w400,
  FontStyle style = FontStyle.normal,
  Color color = const Color(0xFF000000),
}) => TextStyle(
  inherit: false,
  fontFamily: FeFonts.sans,
  fontSize: size,
  height: height,
  fontWeight: weight,
  fontStyle: style,
  color: color,
  letterSpacing: 0,
  textBaseline: TextBaseline.alphabetic,
);

/// Matn balandligini o‘lchaydi (kesh bilan).
class LessonCanvasMeasurer {
  final _cache = <String, double>{};

  double text(String t, TextStyle s, double width, {bool icon = false}) {
    final key =
        '${s.fontSize}|${s.fontWeight?.value}|${s.height}|${s.fontStyle?.index}'
        '|${width.toStringAsFixed(2)}|$icon|$t';
    final hit = _cache[key];
    if (hit != null) return hit;
    final iconSize = LessonCanvasMetrics.iconSize(s.fontSize ?? 14);
    final tp = TextPainter(
      text: TextSpan(
        style: s,
        children: [
          TextSpan(text: t),
          if (icon) const WidgetSpan(child: SizedBox.shrink()),
        ],
      ),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    );
    if (icon) {
      tp.setPlaceholderDimensions([
        PlaceholderDimensions(
          size: Size(iconSize + 6, iconSize),
          alignment: PlaceholderAlignment.middle,
        ),
      ]);
    }
    tp.layout(maxWidth: math.max(1, width));
    final h = tp.height;
    tp.dispose();
    return _cache[key] = h;
  }

  /// Eng uzun so‘z kengligi (jadval ustunining minimal kengligi uchun).
  double longestWord(Iterable<String> cells, TextStyle s) {
    var best = 0.0;
    for (final c in cells) {
      for (final w in c.split(RegExp(r'\s+'))) {
        if (w.isEmpty) continue;
        final key = 'w|${s.fontSize}|${s.fontWeight?.value}|$w';
        var v = _cache[key];
        if (v == null) {
          final tp = TextPainter(
            text: TextSpan(text: w, style: s),
            textDirection: TextDirection.ltr,
            textScaler: TextScaler.noScaling,
          )..layout();
          v = _cache[key] = tp.width;
          tp.dispose();
        }
        if (v > best) best = v;
      }
    }
    return best;
  }
}

/// Jadval ustunlari kengligi: har ustun kamida eng uzun so‘ziga teng, qolgan
/// joy matn hajmiga mutanosib taqsimlanadi. Chizish ham shu qiymatlardan.
List<double> lessonTableColumns(
  LessonDiagram d,
  double body,
  double width,
  LessonCanvasMeasurer m,
) {
  final n = d.header.length;
  if (n == 0) return const [];
  final pad = LessonCanvasMetrics.cellPad(body) * 2;
  final mins = <double>[];
  final weights = <double>[];
  for (var j = 0; j < n; j++) {
    final cells = [for (final r in d.rows) r[j]];
    final lw = math.max(
      m.longestWord([
        d.header[j],
      ], lessonCanvasText(body, weight: FontWeight.w700)),
      m.longestWord(cells, lessonCanvasText(body)),
    );
    mins.add(math.min(lw + pad + 1, width / n));
    weights.add(
      math
          .max(
            4,
            d.header[j].length + cells.fold<int>(0, (a, c) => a + c.length),
          )
          .toDouble(),
    );
  }
  final minSum = mins.fold<double>(0, (a, b) => a + b);
  final free = width - minSum;
  final wSum = weights.fold<double>(0, (a, b) => a + b);
  return [for (var j = 0; j < n; j++) mins[j] + free * weights[j] / wSum];
}

/// Sahifa joylashuvi: tanlangan asosiy matn o‘lchami va sig‘ishi.
@immutable
class LessonCanvasFit {
  const LessonCanvasFit(this.body, this.fits, this.height);

  final double body;

  /// `false` — hatto [LessonCanvasMetrics.minBody] da ham sig‘madi (juda
  /// uzun bitta band/jadval qatori): faqat shunda butunligicha kichraytiriladi.
  final bool fits;

  /// [body] dagi kontent balandligi (dizayn px).
  final double height;
}

/// O‘lchov: [LessonCanvas] chizadigan joylashuvning aynan o‘zi.
abstract final class LessonCanvasLayout {
  static bool _side(LessonPage p) =>
      p.diagram?.kind == LessonDiagramKind.flow && p.bullets.isNotEmpty;

  static double bulletsW(LessonPage p) => _side(p)
      ? (LessonCanvasMetrics.contentW - LessonCanvasMetrics.sideGap) * 0.6
      : LessonCanvasMetrics.contentW;

  static double diagramW(LessonPage p) {
    if (_side(p)) {
      return LessonCanvasMetrics.contentW -
          LessonCanvasMetrics.sideGap -
          bulletsW(p);
    }
    return p.diagram?.kind == LessonDiagramKind.flow
        ? LessonCanvasMetrics.flowMaxW
        : LessonCanvasMetrics.contentW;
  }

  static bool hasMarker(LessonPage p) => p.kind != LessonPageKind.references;

  static double bulletsHeight(
    LessonPage p,
    double body,
    LessonCanvasMeasurer m,
  ) {
    if (p.bullets.isEmpty) return 0;
    final w = bulletsW(p);
    final mw = hasMarker(p) ? LessonCanvasMetrics.markerW(body) : 0.0;
    final s = lessonCanvasText(body);
    final markerH = hasMarker(p)
        ? m.text('•', lessonCanvasText(body, weight: FontWeight.w700), mw)
        : 0.0;
    var h = 0.0;
    for (final b in p.bullets) {
      final th = m.text(b.text, s, w - mw, icon: b.uncertain);
      h += math.max(th, markerH) + LessonCanvasMetrics.bulletGap(body);
    }
    return h;
  }

  static double diagramHeight(
    LessonPage p,
    double body,
    LessonCanvasMeasurer m,
  ) {
    final d = p.diagram;
    if (d == null) return 0;
    final w = diagramW(p);
    var h = 0.0;
    switch (d.kind) {
      case LessonDiagramKind.table:
        final cols = lessonTableColumns(d, body, w, m);
        final pad = LessonCanvasMetrics.cellPad(body);
        double row(List<String> cells, FontWeight wt) {
          var best = 0.0;
          for (var j = 0; j < cells.length; j++) {
            final th = m.text(
              cells[j],
              lessonCanvasText(
                body,
                height: LessonCanvasMetrics.cellLh,
                weight: wt,
              ),
              cols[j] - 2 * pad,
            );
            if (th > best) best = th;
          }
          return best + 2 * pad;
        }

        h += row(d.header, FontWeight.w700);
        for (final r in d.rows) {
          h += row(r, FontWeight.w400);
        }
      case LessonDiagramKind.flow:
        final nodes = d.nodes.take(6).toList();
        final s = lessonCanvasText(
          body,
          height: LessonCanvasMetrics.cellLh,
          weight: FontWeight.w600,
        );
        for (var i = 0; i < nodes.length; i++) {
          h += m.text(nodes[i], s, w - 2 * body * 0.7) + body;
          if (i < nodes.length - 1) h += body * 1.3;
        }
    }
    if (d.caption.isNotEmpty) {
      h +=
          FeSpace.xs +
          m.text(
            d.caption,
            lessonCanvasText(
              LessonCanvasMetrics.captionSize(body),
              height: 1.3,
              style: FontStyle.italic,
            ),
            w,
          );
    }
    return h;
  }

  static double bodyHeight(LessonPage p, double body, LessonCanvasMeasurer m) {
    final b = bulletsHeight(p, body, m);
    final d = diagramHeight(p, body, m);
    if (_side(p)) return math.max(b, d);
    if (b > 0 && d > 0) return b + LessonCanvasMetrics.diagramGap(body) + d;
    return b + d;
  }

  static double trailingW({required bool counter, required bool action}) =>
      action
      ? LessonCanvasMetrics.actionW
      : counter
      ? LessonCanvasMetrics.counterW
      : 0;

  static double sourceW({required bool counter, required bool action}) {
    final t = trailingW(counter: counter, action: action);
    return LessonCanvasMetrics.contentW -
        (t > 0 ? t + LessonCanvasMetrics.trailingGap : 0);
  }

  static double footerHeight(
    String src,
    LessonCanvasMeasurer m, {
    required bool counter,
    required bool action,
  }) {
    final sh = src.isEmpty
        ? 0.0
        : m.text(
            src,
            lessonCanvasText(
              LessonCanvasMetrics.sourceSize,
              height: LessonCanvasMetrics.sourceLh,
            ),
            sourceW(counter: counter, action: action),
          );
    final th = action
        ? LessonCanvasMetrics.actionH
        : counter
        ? LessonCanvasMetrics.sourceSize * LessonCanvasMetrics.sourceLh
        : 0.0;
    final f = math.max(sh, th);
    return f > 0 ? f + LessonCanvasMetrics.footerGap : 0;
  }

  /// Butun kontent balandligi (dizayn px).
  static double height(
    LessonPage p,
    double body,
    String src,
    LessonCanvasMeasurer m, {
    bool counter = true,
    bool action = false,
  }) {
    final title = m.text(
      p.title,
      lessonCanvasText(
        LessonCanvasMetrics.titleSize(body),
        height: LessonCanvasMetrics.titleLh,
        weight: FontWeight.w700,
      ),
      LessonCanvasMetrics.contentW,
    );
    final b = bodyHeight(p, body, m);
    return title +
        (b > 0 ? LessonCanvasMetrics.titleGap(body) + b : 0) +
        footerHeight(src, m, counter: counter, action: action);
  }

  static bool fitsAt(
    LessonPage p,
    double body,
    String src,
    LessonCanvasMeasurer m, {
    bool counter = true,
    bool action = false,
  }) =>
      height(p, body, src, m, counter: counter, action: action) <=
      LessonCanvasMetrics.innerH;

  /// [LessonCanvasMetrics.bodySizes] dan sig‘adigan eng kattasi.
  static LessonCanvasFit pick(
    LessonPage p,
    String src,
    LessonCanvasMeasurer m, {
    bool counter = true,
    bool action = false,
  }) {
    for (final s in LessonCanvasMetrics.bodySizes) {
      final h = height(p, s, src, m, counter: counter, action: action);
      if (h <= LessonCanvasMetrics.innerH) return LessonCanvasFit(s, true, h);
    }
    const s = LessonCanvasMetrics.minBody;
    return LessonCanvasFit(
      s,
      false,
      height(p, s, src, m, counter: counter, action: action),
    );
  }
}

/// Kanvasdagi kontent (testlar tanlangan o‘lchamni shu yerdan o‘qiydi).
class LessonCanvasContent extends StatelessWidget {
  const LessonCanvasContent({
    super.key,
    required this.page,
    required this.body,
    required this.source,
    this.counter,
    this.action,
  });

  final LessonPage page;

  /// Tanlangan asosiy matn o‘lchami (dizayn px).
  final double body;
  final String source;
  final String? counter;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final m = LessonCanvasMeasurer();
    final bullets = page.bullets.isEmpty
        ? null
        : SizedBox(
            width: LessonCanvasLayout.bulletsW(page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final b in page.bullets)
                  _CanvasBullet(
                    bullet: b,
                    body: body,
                    marker: LessonCanvasLayout.hasMarker(page),
                    color: c.textPrimary,
                    dot: c.accent,
                    warn: c.warning,
                    uncertainLabel: l.lessonViewerUncertain,
                  ),
              ],
            ),
          );
    final diagram = page.diagram == null
        ? null
        : _CanvasDiagram(
            diagram: page.diagram!,
            body: body,
            width: LessonCanvasLayout.diagramW(page),
            measurer: m,
          );
    final Widget? main;
    if (bullets != null && diagram != null) {
      main = page.diagram!.kind == LessonDiagramKind.flow
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bullets,
                const SizedBox(width: LessonCanvasMetrics.sideGap),
                diagram,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bullets,
                SizedBox(height: LessonCanvasMetrics.diagramGap(body)),
                diagram,
              ],
            );
    } else {
      main =
          bullets ??
          (diagram == null
              ? null
              : Align(alignment: Alignment.topCenter, child: diagram));
    }
    final hasFooter = source.isNotEmpty || counter != null || action != null;
    final srcStyle = lessonCanvasText(
      LessonCanvasMetrics.sourceSize,
      height: LessonCanvasMetrics.sourceLh,
      color: c.textSecondary,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                page.title,
                style: lessonCanvasText(
                  LessonCanvasMetrics.titleSize(body),
                  height: LessonCanvasMetrics.titleLh,
                  weight: FontWeight.w700,
                  color: c.accent,
                ),
              ),
            ),
            if (main != null) ...[
              SizedBox(height: LessonCanvasMetrics.titleGap(body)),
              main,
            ],
          ],
        ),
        if (hasFooter)
          Padding(
            padding: const EdgeInsets.only(top: LessonCanvasMetrics.footerGap),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: source.isEmpty
                      ? const SizedBox.shrink()
                      : Text(
                          source,
                          key: const Key('lesson.source'),
                          style: srcStyle,
                        ),
                ),
                if (action != null) ...[
                  const SizedBox(width: LessonCanvasMetrics.trailingGap),
                  SizedBox(
                    width: LessonCanvasMetrics.actionW,
                    height: LessonCanvasMetrics.actionH,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomRight,
                        child: action,
                      ),
                    ),
                  ),
                ] else if (counter != null) ...[
                  const SizedBox(width: LessonCanvasMetrics.trailingGap),
                  SizedBox(
                    width: LessonCanvasMetrics.counterW,
                    child: Text(
                      counter!,
                      key: const Key('lesson.counter'),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      style: srcStyle,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// 1280×720 kanvas, ekranga bir xil nisbatda (16:9, chetlari bo‘sh).
class LessonCanvas extends StatelessWidget {
  const LessonCanvas({
    super.key,
    required this.page,
    this.counter,
    this.action,
  });

  final LessonPage page;

  /// «3 / 12» (kanvas pastki o‘ng burchagida).
  final String? counter;

  /// Oxirgi sahifadagi tugma (test boshlash) — pastki o‘ng burchakda.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final src = lessonSourceLine(l, page.sources);
    final fit = LessonCanvasLayout.pick(
      page,
      src,
      LessonCanvasMeasurer(),
      counter: counter != null,
      action: action != null,
    );
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: FittedBox(
          child: SizedBox(
            width: LessonCanvasMetrics.width,
            height: LessonCanvasMetrics.height,
            // Kanvas — «rasm»: tizim matn masshtabi uni buzmaydi; butun kanvas
            // ekranga mutanosib kattalashadi.
            child: MediaQuery.withNoTextScaling(
              child: ClipRect(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LessonCanvasMetrics.padX,
                    LessonCanvasMetrics.padTop,
                    LessonCanvasMetrics.padX,
                    LessonCanvasMetrics.padBottom,
                  ),
                  // Xavfsizlik: o‘lchov sig‘adi desa masshtab 1.0; faqat
                  // bo‘linmaydigan juda uzun element bo‘lsa kichraytiriladi
                  // (hech qachon kesilmaydi).
                  child: FittedBox(
                    key: const Key('lesson.projectorFit'),
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      key: const Key('lesson.canvasContent'),
                      width: LessonCanvasMetrics.contentW,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: LessonCanvasMetrics.innerH,
                        ),
                        child: LessonCanvasContent(
                          page: page,
                          body: fit.body,
                          source: src,
                          counter: counter,
                          action: action,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CanvasBullet extends StatelessWidget {
  const _CanvasBullet({
    required this.bullet,
    required this.body,
    required this.marker,
    required this.color,
    required this.dot,
    required this.warn,
    required this.uncertainLabel,
  });

  final LessonBullet bullet;
  final double body;
  final bool marker;
  final Color color;
  final Color dot;
  final Color warn;
  final String uncertainLabel;

  @override
  Widget build(BuildContext context) {
    final icon = LessonCanvasMetrics.iconSize(body);
    return Padding(
      padding: EdgeInsets.only(bottom: LessonCanvasMetrics.bulletGap(body)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (marker)
            SizedBox(
              width: LessonCanvasMetrics.markerW(body),
              child: Text(
                '•',
                style: lessonCanvasText(
                  body,
                  weight: FontWeight.w700,
                  color: dot,
                ),
              ),
            ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: bullet.text),
                  if (bullet.uncertain)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Tooltip(
                          message: uncertainLabel,
                          child: Semantics(
                            label: uncertainLabel,
                            child: Icon(
                              Icons.help_outline_rounded,
                              key: const Key('lesson.uncertain'),
                              size: icon,
                              color: warn,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              style: lessonCanvasText(body, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _CanvasDiagram extends StatelessWidget {
  const _CanvasDiagram({
    required this.diagram,
    required this.body,
    required this.width,
    required this.measurer,
  });

  final LessonDiagram diagram;
  final double body;
  final double width;
  final LessonCanvasMeasurer measurer;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final Widget main;
    switch (diagram.kind) {
      case LessonDiagramKind.table:
        final cols = lessonTableColumns(diagram, body, width, measurer);
        final pad = LessonCanvasMetrics.cellPad(body);
        Widget cell(String t, Color color, FontWeight w) => Padding(
          padding: EdgeInsets.all(pad),
          child: Text(
            t,
            style: lessonCanvasText(
              body,
              height: LessonCanvasMetrics.cellLh,
              weight: w,
              color: color,
            ),
          ),
        );
        main = ClipRRect(
          borderRadius: BorderRadius.circular(FeRadius.md),
          child: Table(
            key: const Key('lesson.diagram.table'),
            columnWidths: {
              for (var j = 0; j < cols.length; j++)
                j: FixedColumnWidth(cols[j]),
            },
            border: TableBorder.all(color: c.border),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(color: c.brand),
                children: [
                  for (final h in diagram.header)
                    cell(h, c.textOnBrand, FontWeight.w700),
                ],
              ),
              for (var i = 0; i < diagram.rows.length; i++)
                TableRow(
                  decoration: BoxDecoration(
                    color: i.isEven ? c.surfaceRaised : c.surfaceSunken,
                  ),
                  children: [
                    for (final t in diagram.rows[i])
                      cell(t, c.textPrimary, FontWeight.w400),
                  ],
                ),
            ],
          ),
        );
      case LessonDiagramKind.flow:
        final nodes = diagram.nodes.take(6).toList();
        main = Column(
          key: const Key('lesson.diagram.flow'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < nodes.length; i++) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.brand,
                  borderRadius: BorderRadius.circular(FeRadius.md),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: body * 0.7,
                    vertical: body * 0.5,
                  ),
                  child: Text(
                    nodes[i],
                    textAlign: TextAlign.center,
                    style: lessonCanvasText(
                      body,
                      height: LessonCanvasMetrics.cellLh,
                      weight: FontWeight.w600,
                      color: c.textOnBrand,
                    ),
                  ),
                ),
              ),
              if (i < nodes.length - 1)
                Icon(
                  Icons.arrow_downward_rounded,
                  color: c.accent,
                  size: body * 1.3,
                ),
            ],
          ],
        );
    }
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          main,
          if (diagram.caption.isNotEmpty) ...[
            const SizedBox(height: FeSpace.xs),
            Text(
              diagram.caption,
              style: lessonCanvasText(
                LessonCanvasMetrics.captionSize(body),
                height: 1.3,
                style: FontStyle.italic,
                color: c.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
