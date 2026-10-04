import 'package:flutter/material.dart';

import '../design/theme.dart';
import 'brand_mark_r2.g.dart';

/// Brend belgisi — **R2 «Integrated Peak»** (egasi tanlagan yo‘nalish).
///
/// Asimmetrik xromatografik cho‘qqi (EMG, «tailing»), integrallangan maydon
/// va drop-line. Geometriya `design/logo/refined/svg/R2-*.svg` dan dasturiy
/// olingan (`brand_mark_r2.g.dart`).
///
/// **Yuridik holat:** trademark tekshiruvi tugamaguncha brend «tasdiqlangan»
/// EMAS (RELEASE GATE RG-06). Belgi dekorativ — ekran o‘quvchisi uchun
/// yashirilgan, brend nomi alohida matn sifatida o‘qiladi.
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
          painter: IntegratedPeakPainter(
            ink: c.brand,
            accent: c.accent,
            small: size <= 40,
          ),
        ),
      ),
    );
  }
}

/// R2 painter (100×100 grid). `small` — ≤ 40 px uchun optik soddalashtirilgan
/// variant (qalinroq chiziqlar, injection belgisisiz), SVG `icon-small` bilan bir xil.
class IntegratedPeakPainter extends CustomPainter {
  const IntegratedPeakPainter({
    required this.ink,
    required this.accent,
    this.small = false,
  });

  final Color ink;
  final Color accent;
  final bool small;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide / 100;
    canvas
      ..save()
      ..scale(unit);
    // Light/dark SVG: markaz atrofida 0.95652 (katta) / 1.0 (small).
    final k = small ? 1.0 : 0.95652;
    canvas
      ..translate(50, 50)
      ..scale(k)
      ..translate(-50, -50);

    final peak = small ? r2PeakSmall : r2PeakLarge;
    final area = small ? r2AreaSmall : r2AreaLarge;
    final drop = small ? r2DropSmall : r2DropLarge;
    final baseY = peak.first.dy;
    final stroke = small ? 9.5 : 6.5;
    final dropWidth = small ? 7.6 : 5.2;

    // 1) Integrallangan maydon; katta variantda kontur atrofida bo‘shliq
    //    (SVG mask: 11.7 qalinlikdagi chiziqlar maydondan qirqiladi).
    final areaPath = Path()..addPolygon(area, true);
    final fill = Paint()..color = accent;
    if (small) {
      canvas.drawPath(areaPath, fill);
    } else {
      canvas.saveLayer(const Rect.fromLTWH(-50, -50, 200, 200), Paint());
      canvas.drawPath(areaPath, fill);
      final cut = Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas
        ..drawPath(Path()..addPolygon(peak, false), cut)
        ..drawLine(Offset(8, baseY), Offset(92, baseY), cut)
        ..drawLine(drop.$1, Offset(drop.$1.dx, 72), cut)
        ..restore();
    }

    // 2) Cho‘qqi konturi va bazaviy chiziq.
    final line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawPath(
        Path()..addPolygon(peak, false),
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..drawLine(Offset(8, baseY), Offset(92, baseY), line);

    // 3) Drop-line (integrallash chegarasi) va injection belgisi.
    canvas.drawLine(
      drop.$1,
      drop.$2,
      Paint()
        ..color = accent
        ..strokeWidth = dropWidth,
    );
    if (!small) {
      canvas.drawLine(
        Offset(12, baseY),
        Offset(12, baseY - 8),
        Paint()
          ..color = ink
          ..strokeWidth = 5.2,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(IntegratedPeakPainter old) =>
      old.ink != ink || old.accent != accent || old.small != small;
}
