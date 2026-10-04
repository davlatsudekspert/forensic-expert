import 'package:flutter/material.dart';

import '../design/theme.dart';

/// Brend belgisi — **PROTOTIP** («Ridge Spectrum», A3 «Nested Peaks»).
///
/// Yakuniy logo egasining tasdig‘isiz qulflanmaydi
/// (`design/logo/LOGO_PROTOTYPES.md`). Geometriya
/// `design/logo/tools/generate_prototypes.py` dagi A3 variantiga aynan mos
/// (100×100 grid). Belgi dekorativ — ekran o‘quvchisi uchun yashirilgan,
/// brend nomi alohida matn sifatida o‘qiladi.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _NestedPeaksPainter(
            ridge: c.brand,
            accent: c.accent,
            small: size <= 64,
          ),
        ),
      ),
    );
  }
}

class _NestedPeaksPainter extends CustomPainter {
  _NestedPeaksPainter({
    required this.ridge,
    required this.accent,
    required this.small,
  });

  final Color ridge;
  final Color accent;
  final bool small;

  static Path _bell(
    double cx,
    double base,
    double w,
    double h, [
    double k1 = 0.42,
    double k2 = 0.30,
  ]) {
    return Path()
      ..moveTo(cx - w, base)
      ..cubicTo(cx - w * k1, base, cx - w * k2, base - h, cx, base - h)
      ..cubicTo(cx + w * k2, base - h, cx + w * k1, base, cx + w, base);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    const base = 76.0;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = small ? 8 : 5
      ..strokeCap = StrokeCap.butt
      ..color = ridge;
    final ridges = small
        ? [_bell(50, base, 38, 50)]
        : [_bell(50, base, 40, 52), _bell(50, base, 28, 41)];
    for (final p in ridges) {
      canvas.drawPath(p, stroke);
    }
    canvas.drawLine(const Offset(8, base), const Offset(92, base), stroke);
    final accentPath = small
        ? _bell(50, base, 16, 32, 0.30, 0.18)
        : _bell(50, base, 15, 29, 0.30, 0.16);
    canvas.drawPath(accentPath, stroke..color = accent);
  }

  @override
  bool shouldRepaint(_NestedPeaksPainter old) =>
      old.ridge != ridge || old.accent != accent || old.small != small;
}
