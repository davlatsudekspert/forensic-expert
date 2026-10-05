import 'package:flutter/material.dart';

import '../design/theme.dart';

part 'brand_emblem.g.dart';

/// Optik soddalashtirish darajalari (`design/brand/tools/generate_brand.py`).
///
/// * [full] — qalqon, Asklepiy tayog‘i va ilon, tarozi, barmoq izi,
///   xromatogramma, bo‘lingan tashqi halqa (≥ 96 px);
/// * [icon] — qalqon + tayoq/ilon + tarozi (41–95 px);
/// * [small] — qalqon + tayoq/ilon (≤ 40 px).
enum BrandTier { full, icon, small }

/// Brend belgisi — **«Shield of Evidence»** (original vektor emblema).
///
/// Geometriya yagona manbadan generatsiya qilinadi (SVG, PNG, launcher
/// ikonlari va shu painter bir xil). Oltin faqat emblemada cheklangan
/// aksent sifatida. Belgi dekorativ — ekran o‘quvchisidan yashirilgan,
/// brend nomi alohida matn sifatida o‘qiladi.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72, this.onDark = false, this.tier});

  final double size;

  /// To‘q fon ustida (splash, navy banner) — to‘q palitra.
  final bool onDark;

  /// Majburiy daraja; berilmasa o‘lchamdan tanlanadi.
  final BrandTier? tier;

  static BrandTier tierFor(double size) => size <= 40
      ? BrandTier.small
      : size < 96
      ? BrandTier.icon
      : BrandTier.full;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final dark = onDark || Theme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: BrandEmblemPainter(
            tier: tier ?? tierFor(size),
            ink: dark ? const Color(0xFFE8EDF4) : c.brand,
            gold: dark ? const Color(0xFFC9A75E) : const Color(0xFF9C7A33),
            accent: dark ? const Color(0xFF4CC9D6) : c.accent,
            fill: dark ? const Color(0xFF15284D) : Colors.white,
          ),
        ),
      ),
    );
  }
}

enum _Role { ink, gold, accent, fill }

class _Op {
  const _Op.m(this.x1, this.y1) : cmd = 'M', x2 = 0, y2 = 0, x3 = 0, y3 = 0;
  const _Op.l(this.x1, this.y1) : cmd = 'L', x2 = 0, y2 = 0, x3 = 0, y3 = 0;
  const _Op.c(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3) : cmd = 'C';
  const _Op.z() : cmd = 'Z', x1 = 0, y1 = 0, x2 = 0, y2 = 0, x3 = 0, y3 = 0;

  final String cmd;
  final double x1, y1, x2, y2, x3, y3;
}

class _El {
  const _El(
    this.role,
    this.width, {
    required this.ops,
    this.fill = false,
    this.halo = 0,
  });

  final _Role role;
  final double width;
  final bool fill;
  final double halo;
  final List<_Op> ops;

  Path toPath() {
    final p = Path();
    for (final o in ops) {
      switch (o.cmd) {
        case 'M':
          p.moveTo(o.x1, o.y1);
        case 'L':
          p.lineTo(o.x1, o.y1);
        case 'C':
          p.cubicTo(o.x1, o.y1, o.x2, o.y2, o.x3, o.y3);
        default:
          p.close();
      }
    }
    return p;
  }
}

/// 100×100 grid painter (SVG bilan aynan bir xil geometriya).
class BrandEmblemPainter extends CustomPainter {
  const BrandEmblemPainter({
    required this.tier,
    required this.ink,
    required this.gold,
    required this.accent,
    required this.fill,
  });

  final BrandTier tier;
  final Color ink;
  final Color gold;
  final Color accent;
  final Color fill;

  /// Darajadagi elementlar soni (testlar uchun).
  static int elementCount(BrandTier tier) => _emblemTiers[tier]!.length;

  Color _color(_Role r) => switch (r) {
    _Role.ink => ink,
    _Role.gold => gold,
    _Role.accent => accent,
    _Role.fill => fill,
  };

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.shortestSide / 100);
    for (final e in _emblemTiers[tier]!) {
      final path = e.toPath();
      final paint = Paint()
        ..isAntiAlias = true
        ..color = _color(e.role);
      if (e.fill) {
        canvas.drawPath(path, paint..style = PaintingStyle.fill);
        continue;
      }
      final stroke = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      if (e.halo > 0) {
        canvas.drawPath(
          path,
          stroke
            ..color = fill
            ..strokeWidth = e.width + e.halo,
        );
      }
      canvas.drawPath(
        path,
        stroke
          ..color = _color(e.role)
          ..strokeWidth = e.width,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(BrandEmblemPainter old) =>
      old.tier != tier ||
      old.ink != ink ||
      old.gold != gold ||
      old.accent != accent ||
      old.fill != fill;
}
