import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../domain/lessons/lesson_models.dart';

/// «+» belgisi (reaksiya sxemasi) — foydalanuvchi matni emas.
const _plusSign = '+';

/// Diagramma v2 turlari: `steps`, `compare`, `tree`, `facts`, `reaction`,
/// `cycle` (`docs/lessons/DECK_SPEC_V2.md`). Proyektor kanvasi ([size] katta,
/// [TextScaler.noScaling]) va telefon ([size] kichik, tizim masshtabi) uchun
/// bitta joylashuv: balandlik shu yerda o‘lchanadi ([heightOf]) va aynan shu
/// o‘lchamlar bilan chiziladi, shuning uchun kanvas sahifalari kesilmaydi.
bool lessonIsRichDiagram(LessonDiagramKind k) =>
    k != LessonDiagramKind.table && k != LessonDiagramKind.flow;

class LessonRichDiagram extends StatelessWidget {
  const LessonRichDiagram({
    super.key,
    required this.diagram,
    required this.size,
    this.width,
    this.minCaption = 12,
  });

  final LessonDiagram diagram;

  /// Asosiy matn o‘lchami (px).
  final double size;

  /// `null` bo‘lsa — ota-ona kengligi.
  final double? width;
  final double minCaption;

  /// Diagramma balandligi (kanvas sig‘ish hisobi uchun).
  static double heightOf(
    LessonDiagram d, {
    required double size,
    required double width,
    TextScaler scaler = TextScaler.noScaling,
    double minCaption = 12,
  }) => _Plan(
    d: d,
    s: size,
    w: width,
    sc: scaler,
    p: _Pal.dummy,
    minCap: minCaption,
  ).build().h;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final sc = MediaQuery.textScalerOf(context);
    Widget make(double w) {
      final plan = _Plan(
        d: diagram,
        s: size,
        w: w,
        sc: sc,
        p: _Pal.from(c),
        minCap: minCaption,
      ).build();
      return SizedBox(
        key: Key('lesson.diagram.${diagram.kind.name}'),
        width: w,
        height: plan.h,
        child: plan.w,
      );
    }

    final w = width;
    if (w != null) return make(w);
    return LayoutBuilder(builder: (context, box) => make(box.maxWidth));
  }
}

class _Pal {
  const _Pal({
    required this.text,
    required this.text2,
    required this.border,
    required this.line,
    required this.brand,
    required this.onBrand,
    required this.raised,
    required this.sunken,
    required this.accent,
    required this.accentBox,
    required this.onAccentBox,
  });

  factory _Pal.from(FeColorTokens c) => _Pal(
    text: c.textPrimary,
    text2: c.textSecondary,
    border: c.border,
    line: c.borderStrong,
    brand: c.brand,
    onBrand: c.textOnBrand,
    raised: c.surfaceRaised,
    sunken: c.surfaceSunken,
    accent: c.accent,
    accentBox: c.accentContainer,
    onAccentBox: c.onAccentContainer,
  );

  static const dummy = _Pal(
    text: Color(0xFF000000),
    text2: Color(0xFF000000),
    border: Color(0xFF000000),
    line: Color(0xFF000000),
    brand: Color(0xFF000000),
    onBrand: Color(0xFF000000),
    raised: Color(0xFF000000),
    sunken: Color(0xFF000000),
    accent: Color(0xFF000000),
    accentBox: Color(0xFF000000),
    onAccentBox: Color(0xFF000000),
  );

  final Color text, text2, border, line, brand, onBrand, raised, sunken;
  final Color accent, accentBox, onAccentBox;
}

/// Balandligi ma’lum blok.
class _Blk {
  const _Blk(this.h, this.w);
  final double h;
  final Widget w;
}

class _Plan {
  _Plan({
    required this.d,
    required this.s,
    required this.w,
    required this.sc,
    required this.p,
    required this.minCap,
  });

  final LessonDiagram d;
  final double s;
  final double w;
  final TextScaler sc;
  final _Pal p;
  final double minCap;

  bool get compact => w < 560;
  double get pad => s * 0.55;
  double get gap => s * 0.6;

  TextStyle t(
    double size,
    Color color, {
    FontWeight weight = FontWeight.w400,
    double height = 1.25,
    bool italic = false,
  }) => TextStyle(
    inherit: false,
    fontFamily: FeFonts.sans,
    fontSize: size,
    height: height,
    fontWeight: weight,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    color: color,
    letterSpacing: 0,
    textBaseline: TextBaseline.alphabetic,
  );

  double mh(String text, TextStyle st, double width) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: st),
      textDirection: TextDirection.ltr,
      textScaler: sc,
    )..layout(maxWidth: math.max(1, width));
    final h = tp.height;
    tp.dispose();
    return h;
  }

  _Blk build() {
    final _Blk main;
    switch (d.kind) {
      case LessonDiagramKind.steps:
        main = _steps();
      case LessonDiagramKind.compare:
        main = _compare();
      case LessonDiagramKind.tree:
        main = _tree();
      case LessonDiagramKind.facts:
        main = _facts();
      case LessonDiagramKind.reaction:
        main = _reaction();
      case LessonDiagramKind.cycle:
        main = _cycle();
      case LessonDiagramKind.table:
      case LessonDiagramKind.flow:
        main = const _Blk(0, SizedBox.shrink());
    }
    if (d.caption.isEmpty) return main;
    final cs = t(math.max(minCap, s * 0.8), p.text2, height: 1.3, italic: true);
    final ch = mh(d.caption, cs, w);
    final g = s * 0.45;
    return _Blk(
      main.h + g + ch,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: main.h, child: main.w),
          SizedBox(height: g),
          Text(d.caption, style: cs),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- yordam

  /// Karta foni (chegarasiz — chegara [edge] bilan ustidan chiziladi va
  /// joylashuvni o‘zgartirmaydi, shuning uchun o‘lchov aniq qoladi).
  BoxDecoration card({Color? fill, double r = 14}) => BoxDecoration(
    color: fill ?? p.raised,
    borderRadius: BorderRadius.circular(r),
  );

  BoxDecoration edge({Color? line, double r = 14}) => BoxDecoration(
    borderRadius: BorderRadius.circular(r),
    border: Border.all(color: line ?? p.border, width: 1.5),
  );

  Widget badge(int n, double dia) => Container(
    width: dia,
    height: dia,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: p.brand, shape: BoxShape.circle),
    child: Text(
      '$n',
      style: t(dia * 0.55, p.onBrand, weight: FontWeight.w700, height: 1),
    ),
  );

  /// Kataklar to‘ri: qator balandligi — eng baland katak.
  _Blk grid(
    List<_Blk Function(double cellW)> cells,
    int cols, {
    double? gridW,
    double? colGap,
  }) {
    final gw = gridW ?? w;
    final cg = colGap ?? gap;
    final cellW = (gw - (cols - 1) * cg) / cols;
    final blocks = [for (final c in cells) c(cellW)];
    final rows = <Widget>[];
    var total = 0.0;
    for (var i = 0; i < blocks.length; i += cols) {
      final row = blocks.sublist(i, math.min(i + cols, blocks.length));
      final rh = row.fold<double>(0, (a, b) => math.max(a, b.h));
      if (rows.isNotEmpty) {
        rows.add(SizedBox(height: gap));
        total += gap;
      }
      total += rh;
      rows.add(
        SizedBox(
          height: rh,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < row.length; j++) ...[
                if (j > 0) SizedBox(width: cg),
                SizedBox(width: cellW, child: row[j].w),
              ],
            ],
          ),
        ),
      );
    }
    return _Blk(
      total,
      Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: gw,
          height: total,
          child: Column(children: rows),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- steps

  _Blk _steps() {
    final items = d.steps;
    final cols = compact || items.length <= 3 ? 1 : 2;
    final badgeD = s * 1.5;
    final ts = t(s, p.text, weight: FontWeight.w700);
    final xs = t(s * 0.9, p.text2, height: 1.3);
    return grid([
      for (var i = 0; i < items.length; i++)
        (cw) {
          final tw = cw - 2 * pad - badgeD - gap;
          final th = mh(items[i].title, ts, tw);
          final xh = items[i].text.isEmpty
              ? 0.0
              : mh(items[i].text, xs, tw) + s * 0.2;
          final h = 2 * pad + math.max(badgeD, th + xh);
          return _Blk(
            h,
            Container(
              padding: EdgeInsets.all(pad),
              decoration: card(),
              foregroundDecoration: edge(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  badge(i + 1, badgeD),
                  SizedBox(width: gap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].title, style: ts),
                        if (items[i].text.isNotEmpty) ...[
                          SizedBox(height: s * 0.2),
                          Text(items[i].text, style: xs),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
    ], cols);
  }

  // --------------------------------------------------------------- compare

  _Blk _compare() {
    final cs = d.columns;
    final cols = compact ? 1 : cs.length;
    final hs = t(s, p.onBrand, weight: FontWeight.w700);
    final its = t(s * 0.9, p.text, height: 1.3);
    final dot = s * 0.9;
    final ig = s * 0.35;
    return grid([
      for (final col in cs)
        (cw) {
          final hh = mh(col.title, hs, cw - 2 * pad) + pad * 1.2;
          var ih = pad;
          for (final it in col.items) {
            ih += mh(it, its, cw - 2 * pad - dot) + ig;
          }
          ih += pad - ig;
          return _Blk(
            hh + ih,
            Container(
              decoration: card(),
              foregroundDecoration: edge(),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: hh,
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    alignment: Alignment.centerLeft,
                    color: p.brand,
                    child: Text(col.title, style: hs),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < col.items.length; i++) ...[
                          if (i > 0) SizedBox(height: ig),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: dot,
                                child: Text(
                                  '•',
                                  style: t(
                                    s * 0.9,
                                    p.accent,
                                    weight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              Expanded(child: Text(col.items[i], style: its)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
    ], cols);
  }

  // ------------------------------------------------------------------ tree

  _Blk _tree() {
    final kids = d.children;
    final n = kids.length;
    final cols = compact ? 1 : (n <= 3 ? n : (n == 4 ? 2 : 3));
    final rs = t(s * 1.1, p.onBrand, weight: FontWeight.w700);
    final rootW = math.min(w, compact ? w : w * 0.6);
    final rh = mh(d.root, rs, rootW - 2 * pad) + pad * 1.2;
    final conn = s * 1.1;
    final ls = t(s, p.text, weight: FontWeight.w700);
    final is_ = t(s * 0.85, p.text2, height: 1.3);
    final g = grid([
      for (final k in kids)
        (cw) {
          final lh = mh(k.label, ls, cw - 2 * pad);
          var ih = 0.0;
          for (final it in k.items) {
            ih += mh(it, is_, cw - 2 * pad) + s * 0.25;
          }
          final h = 2 * pad + lh + ih;
          return _Blk(
            h,
            Container(
              padding: EdgeInsets.all(pad),
              decoration: card(),
              foregroundDecoration: edge(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(k.label, style: ls),
                  for (final it in k.items) ...[
                    SizedBox(height: s * 0.25),
                    Text(it, style: is_),
                  ],
                ],
              ),
            ),
          );
        },
    ], cols);
    final cellW = (w - (cols - 1) * gap) / cols;
    final centers = [
      for (var i = 0; i < math.min(cols, n); i++) i * (cellW + gap) + cellW / 2,
    ];
    return _Blk(
      rh + conn + g.h,
      Column(
        children: [
          Container(
            width: rootW,
            height: rh,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: pad),
            decoration: BoxDecoration(
              color: p.brand,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(d.root, textAlign: TextAlign.center, style: rs),
          ),
          SizedBox(
            width: w,
            height: conn,
            child: CustomPaint(painter: _TreeLinks(centers, w / 2, p.line)),
          ),
          SizedBox(height: g.h, child: g.w),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- facts

  _Blk _facts() {
    final f = d.facts;
    final n = f.length;
    final cols = compact ? math.min(2, n) : (n <= 3 ? n : (n == 4 ? 2 : 3));
    final gw = n == 1 ? math.min(w, s * 16) : w;
    final ls = t(s * 0.75, p.text2, weight: FontWeight.w500, height: 1.25);
    final us = t(s * 0.8, p.text2, height: 1.2);
    TextStyle vs(String v) => t(
      v.length <= 5 ? s * 2.0 : (v.length <= 9 ? s * 1.5 : s * 1.15),
      p.accent,
      weight: FontWeight.w700,
      height: 1.15,
    );
    return grid(
      [
        for (final x in f)
          (cw) {
            final iw = cw - 2 * pad;
            final lh = mh(x.label, ls, iw);
            final vh = mh(x.value, vs(x.value), iw);
            final uh = x.unit.isEmpty ? 0.0 : mh(x.unit, us, iw);
            return _Blk(
              2 * pad + lh + s * 0.3 + vh + uh,
              Container(
                padding: EdgeInsets.all(pad),
                decoration: card(),
                foregroundDecoration: edge(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(x.label, textAlign: TextAlign.center, style: ls),
                    SizedBox(height: s * 0.3),
                    Text(
                      x.value,
                      textAlign: TextAlign.center,
                      style: vs(x.value),
                    ),
                    if (x.unit.isNotEmpty)
                      Text(x.unit, textAlign: TextAlign.center, style: us),
                  ],
                ),
              ),
            );
          },
      ],
      cols,
      gridW: gw,
    );
  }

  // -------------------------------------------------------------- reaction

  _Blk _reaction() {
    final bs = t(s * 0.95, p.text, weight: FontWeight.w600, height: 1.25);
    final ps = t(s * 0.95, p.onAccentBox, weight: FontWeight.w700);
    final plus = t(s * 1.2, p.accent, weight: FontWeight.w700, height: 1);
    final plusH = s * 1.2 + s * 0.3;
    final cs = t(s * 0.75, p.text2, height: 1.25);

    _Blk side(List<String> items, double cw, {required bool product}) {
      final st = product ? ps : bs;
      var h = 0.0;
      final kids = <Widget>[];
      for (var i = 0; i < items.length; i++) {
        if (i > 0) {
          h += plusH;
          kids.add(
            SizedBox(
              height: plusH,
              child: Center(child: Text(_plusSign, style: plus)),
            ),
          );
        }
        final bh = mh(items[i], st, cw - 2 * pad) + pad * 1.4;
        h += bh;
        kids.add(
          Container(
            height: bh,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: pad),
            decoration: card(fill: product ? p.accentBox : p.raised),
            foregroundDecoration: edge(line: product ? p.accent : p.border),
            child: Text(items[i], textAlign: TextAlign.center, style: st),
          ),
        );
      }
      return _Blk(
        h,
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: kids),
      );
    }

    // Kuzatuv (rang/cho‘kma) belgisi.
    final os = t(s * 0.9, p.text, height: 1.3);
    final ic = s * 1.2;
    _Blk obs() {
      final tw = w - 2 * pad - ic - gap;
      final th = mh(d.observation, os, tw);
      final h = 2 * pad + math.max(ic, th);
      return _Blk(
        h,
        Container(
          padding: EdgeInsets.all(pad),
          decoration: card(fill: p.sunken),
          foregroundDecoration: edge(line: p.accent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.visibility_outlined, size: ic, color: p.accent),
              SizedBox(width: gap),
              Expanded(child: Text(d.observation, style: os)),
            ],
          ),
        ),
      );
    }

    final hasObs = d.observation.isNotEmpty;
    final hasCond = d.conditions.isNotEmpty;
    if (compact) {
      final r = side(d.reagents, w, product: false);
      final pr = side(d.products, w, product: true);
      final cw = w - s * 1.8 - gap;
      final ch = hasCond ? mh(d.conditions, cs, cw) : 0.0;
      final ah = math.max(s * 1.8, ch) + s * 0.4;
      final o = hasObs ? obs() : null;
      return _Blk(
        r.h + ah + pr.h + (o == null ? 0 : gap + o.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: r.h, child: r.w),
            SizedBox(
              height: ah,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: s * 1.8,
                    color: p.accent,
                  ),
                  if (hasCond) ...[
                    SizedBox(width: gap),
                    SizedBox(
                      width: cw,
                      child: Text(d.conditions, style: cs),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: pr.h, child: pr.w),
            if (o != null) ...[
              SizedBox(height: gap),
              SizedBox(height: o.h, child: o.w),
            ],
          ],
        ),
      );
    }
    final arrowW = w * 0.2;
    final sideW = (w - arrowW - 2 * gap) / 2;
    final r = side(d.reagents, sideW, product: false);
    final pr = side(d.products, sideW, product: true);
    final ch = hasCond ? mh(d.conditions, cs, arrowW) : 0.0;
    final arrowH = s * 2.2;
    final ah = ch + (hasCond ? s * 0.2 : 0) + arrowH;
    final rowH = math.max(r.h, math.max(pr.h, ah));
    final o = hasObs ? obs() : null;
    Widget centered(_Blk b) => SizedBox(
      width: sideW,
      height: rowH,
      child: Center(
        child: SizedBox(height: b.h, child: b.w),
      ),
    );
    return _Blk(
      rowH + (o == null ? 0 : gap + o.h),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: rowH,
            child: Row(
              children: [
                centered(r),
                SizedBox(width: gap),
                SizedBox(
                  width: arrowW,
                  height: rowH,
                  child: Center(
                    child: SizedBox(
                      height: ah,
                      child: Column(
                        children: [
                          if (hasCond) ...[
                            Text(
                              d.conditions,
                              textAlign: TextAlign.center,
                              style: cs,
                            ),
                            SizedBox(height: s * 0.2),
                          ],
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: arrowH,
                            color: p.accent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: gap),
                centered(pr),
              ],
            ),
          ),
          if (o != null) ...[
            SizedBox(height: gap),
            SizedBox(height: o.h, child: o.w),
          ],
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- cycle

  _Blk _cycle() {
    final nodes = d.nodes;
    final n = nodes.length;
    final badgeD = s * 1.4;
    final ns = t(s * 0.95, p.text, weight: FontWeight.w600);

    Widget nodeCard(int i, double cw, double h) => Container(
      width: cw,
      height: h,
      padding: EdgeInsets.symmetric(horizontal: pad),
      decoration: card(),
      foregroundDecoration: edge(),
      child: Row(
        children: [
          badge(i + 1, badgeD),
          SizedBox(width: gap * 0.8),
          Expanded(child: Text(nodes[i], style: ns)),
        ],
      ),
    );

    double nodeH(double cw) {
      var h = badgeD;
      for (final x in nodes) {
        h = math.max(h, mh(x, ns, cw - 2 * pad - badgeD - gap * 0.8));
      }
      return h + 2 * pad;
    }

    if (compact) {
      final nh = nodeH(w);
      final ah = s * 1.5;
      final kids = <Widget>[];
      for (var i = 0; i < n; i++) {
        kids.add(nodeCard(i, w, nh));
        kids.add(
          SizedBox(
            height: ah,
            child: Icon(
              i == n - 1 ? Icons.replay_rounded : Icons.arrow_downward_rounded,
              size: s * 1.2,
              color: p.accent,
            ),
          ),
        );
      }
      return _Blk(n * (nh + ah), Column(children: kids));
    }

    final k = (n + 1) ~/ 2;
    final m = n - k;
    final gapX = math.max(s * 2.2, 56.0);
    final gapY = math.max(s * 2.0, 56.0);
    final cw = (w - (k - 1) * gapX) / k;
    final nh = nodeH(cw);
    final off = (k - m) / 2;
    final pos = <Offset>[];
    for (var i = 0; i < n; i++) {
      if (i < k) {
        pos.add(Offset(i * (cw + gapX), 0));
      } else {
        final j = i - k;
        pos.add(Offset((off + (m - 1 - j)) * (cw + gapX), nh + gapY));
      }
    }
    final total = 2 * nh + gapY;
    final rects = [for (final o in pos) o & Size(cw, nh)];
    return _Blk(
      total,
      SizedBox(
        width: w,
        height: total,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _CycleArrows(rects, p.accent, s)),
            ),
            for (var i = 0; i < n; i++)
              Positioned(
                left: pos[i].dx,
                top: pos[i].dy,
                child: nodeCard(i, cw, nh),
              ),
          ],
        ),
      ),
    );
  }
}

class _TreeLinks extends CustomPainter {
  _TreeLinks(this.centers, this.rootX, this.color);

  final List<double> centers;
  final double rootX;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final mid = size.height / 2;
    canvas.drawLine(Offset(rootX, 0), Offset(rootX, mid), paint);
    final lo = math.min(rootX, centers.first);
    final hi = math.max(rootX, centers.last);
    canvas.drawLine(Offset(lo, mid), Offset(hi, mid), paint);
    for (final x in centers) {
      canvas.drawLine(Offset(x, mid), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_TreeLinks old) =>
      old.color != color ||
      old.rootX != rootX ||
      !listEquals(old.centers, centers);
}

class _CycleArrows extends CustomPainter {
  _CycleArrows(this.rects, this.color, this.s);

  final List<Rect> rects;
  final Color color;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = math.max(2.5, s * 0.1)
      ..strokeCap = StrokeCap.round;
    final n = rects.length;
    final head = math.max(10.0, s * 0.45);
    for (var i = 0; i < n; i++) {
      final a = rects[i];
      final b = rects[(i + 1) % n];
      final d = b.center - a.center;
      if (d.distance == 0) continue;
      double edge(Rect r) {
        final tx = d.dx == 0 ? double.infinity : (r.width / 2) / d.dx.abs();
        final ty = d.dy == 0 ? double.infinity : (r.height / 2) / d.dy.abs();
        return math.min(tx, ty);
      }

      final u = d / d.distance;
      final start = a.center + d * edge(a) + u * 6;
      final end = b.center - d * edge(b) - u * 6;
      if ((end - start).distance < head) continue;
      final shaft = end - u * head * 0.8;
      canvas.drawLine(start, shaft, paint);
      final nrm = Offset(-u.dy, u.dx);
      final path = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(
          end.dx - u.dx * head + nrm.dx * head * 0.5,
          end.dy - u.dy * head + nrm.dy * head * 0.5,
        )
        ..lineTo(
          end.dx - u.dx * head - nrm.dx * head * 0.5,
          end.dy - u.dy * head - nrm.dy * head * 0.5,
        )
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_CycleArrows old) =>
      old.color != color || old.s != s || !listEquals(old.rects, rects);
}
