import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/fe_localizations_delegate.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';

/// Amaliy misol: dori moddasini miqdoriy aniqlash, sxema va diagrammalar
/// bilan (egasi talabi, 2026-11-02). Matn asli o‘zbekcha, JSON paketda;
/// har band manbaga (`src` — `sources` ro‘yxatidagi indeks) bog‘langan.
const workedExampleIds = ['tropicamide_uv', 'phenobarbital_blood_uv'];

final workedExampleLoaderProvider =
    Provider<Future<String> Function(String id)>(
      (ref) =>
          (id) =>
              rootBundle.loadString('assets/content/worked_examples/$id.json'),
    );

final workedExampleProvider =
    FutureProvider.family<Map<String, Object?>?, String>((ref, id) async {
      if (!workedExampleIds.contains(id)) return null;
      try {
        final text = await ref.watch(workedExampleLoaderProvider)(id);
        return (jsonDecode(text) as Map).cast<String, Object?>();
      } on Object {
        return null;
      }
    });

String _s(Object? v) => v is String ? v : '';
List<Map<String, Object?>> _maps(Object? v) => [
  if (v is List)
    for (final x in v)
      if (x is Map) x.cast<String, Object?>(),
];
List<String> _strs(Object? v) => [
  if (v is List)
    for (final x in v)
      if (x is String) x,
];
double _d(Object? v) => v is num ? v.toDouble() : 0;

class WorkedExampleScreen extends ConsumerWidget {
  const WorkedExampleScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final async = ref.watch(workedExampleProvider(id));
    final d = async.value;
    if (d == null) {
      return Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.weHeader)),
        body: Center(
          child: async.isLoading
              ? const CircularProgressIndicator()
              : Text(l.equipEmpty),
        ),
      );
    }
    String u(String s) => uzDisplay('uz', s);
    final sources = _maps(d['sources']);
    String ref0(Object? src) {
      final i = src is int ? src : -1;
      if (i < 0 || i >= sources.length) return '';
      return '[${i + 1}]';
    }

    Widget sectionBody(Map<String, Object?> s) {
      switch (_s(s['kind'])) {
        case 'facts':
          return Wrap(
            spacing: FeSpace.sm,
            runSpacing: FeSpace.sm,
            children: [
              for (final f in _maps(s['items']))
                Container(
                  constraints: const BoxConstraints(minWidth: 150),
                  padding: const EdgeInsets.all(FeSpace.sm),
                  decoration: BoxDecoration(
                    color: c.accentContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(FeRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _s(f['value']),
                        style: t.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${u(_s(f['label']))} ${ref0(f['src'])}',
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
            ],
          );
        case 'flow':
          final nodes = _strs(s['nodes']);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, n) in nodes.indexed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FeSpace.md,
                    vertical: FeSpace.sm,
                  ),
                  decoration: BoxDecoration(
                    color: i == nodes.length - 1
                        ? c.accentContainer
                        : c.surface,
                    border: Border.all(color: c.border),
                    borderRadius: BorderRadius.circular(FeRadius.md),
                  ),
                  child: Text(u(n), style: t.bodyMedium),
                ),
                if (i < nodes.length - 1)
                  Icon(Icons.arrow_downward, size: 18, color: c.accent),
              ],
              const SizedBox(height: FeSpace.xs),
              Text(
                '${u(_s(s['caption']))} ${ref0(s['src'])}',
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          );
        case 'steps':
          return Column(
            children: [
              for (final (i, x) in _maps(s['items']).indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: FeSpace.sm),
                        decoration: BoxDecoration(
                          color: c.accentContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Text((i + 1).toString(), style: t.labelMedium),
                      ),
                      Expanded(
                        child: Text(
                          '${u(_s(x['text']))} ${ref0(x['src'])}',
                          style: t.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        case 'bullets':
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final x in _maps(s['items']))
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  child: Text(
                    '• ${u(_s(x['text']))} ${ref0(x['src'])}',
                    style: t.bodyMedium,
                  ),
                ),
            ],
          );
        case 'calibration':
          final eps = _d(s['epsilon']);
          final m = _d(s['molar_mass']);
          final direct = _d(s['slope_per_unit']);
          final slope = direct > 0 ? direct : (m == 0 ? 0.0 : eps / m / 1000);
          final pts = [
            for (final p in (s['points'] as List? ?? const []))
              if (p is num) p.toDouble(),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: CustomPaint(
                  key: const Key('worked.calibration'),
                  painter: _CalibrationPainter(
                    points: pts,
                    slope: slope,
                    line: c.accent,
                    grid: c.border,
                    text: c.textSecondary,
                    xLabel: _s(s['x_label']),
                    yLabel: _s(s['y_label']),
                    style: t.labelSmall ?? const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                '${u(_s(s['note']))} ${ref0(s['src'])}',
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          );
        case 'spectra':
          final range = [
            for (final x in (s['range'] as List? ?? const [220, 300]))
              if (x is num) x.toDouble(),
          ];
          final curves = _maps(s['curves']);
          final colors = [c.accent, const Color(0xFFC0392B), c.textSecondary];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: CustomPaint(
                  key: const Key('worked.spectra'),
                  painter: _SpectraPainter(
                    from: range.isEmpty ? 220 : range.first,
                    to: range.length < 2 ? 300 : range[1],
                    curves: [
                      for (final cv in curves)
                        (
                          base: _d(cv['base']),
                          peaks: [
                            for (final pk in _maps(cv['peaks']))
                              (
                                nm: _d(pk['nm']),
                                h: _d(pk['h']),
                                w: _d(pk['w']),
                              ),
                          ],
                        ),
                    ],
                    colors: colors,
                    markers: [
                      for (final x in (s['markers'] as List? ?? const []))
                        if (x is num) x.toDouble(),
                    ],
                    grid: c.border,
                    text: c.textSecondary,
                    style: t.labelSmall ?? const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: FeSpace.xs),
              for (final (i, cv) in curves.indexed)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 3,
                        color: colors[i % colors.length],
                      ),
                      const SizedBox(width: FeSpace.xs),
                      Expanded(
                        child: Text(u(_s(cv['label'])), style: t.bodySmall),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: FeSpace.xs),
              Text(
                '${u(_s(s['note']))} ${ref0(s['src'])}',
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          );
        case 'calc':
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(FeSpace.md),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(FeRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (i, x) in _strs(s['lines']).indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${i + 1}) ${u(x)}',
                          style: t.bodyMedium?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                u(_s(s['note'])),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          );
      }
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.weHeader)),
      body: ListView(
        key: Key('worked.$id'),
        padding: EdgeInsets.only(
          bottom: FeSpace.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FeSpace.md),
                Text(u(_s(d['title'])), style: t.headlineSmall),
                const SizedBox(height: FeSpace.sm),
                if (lang != 'uz') ...[
                  FeBanner(icon: Icons.translate, text: l.trPendingTranslation),
                  const SizedBox(height: FeSpace.sm),
                ],
                Text(u(_s(d['intro'])), style: t.bodyLarge),
                for (final s in _maps(d['sections'])) ...[
                  FeSectionHeader(u(_s(s['title']))),
                  sectionBody(s),
                ],
                FeSectionHeader(l.equipSources),
                for (final (i, s) in sources.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: FeSpace.xs),
                    child: Text(
                      '[${i + 1}] ${_s(s['author'])}. ${_s(s['title'])}. '
                      '${_s(s['page'])}'
                      '${_s(s['doi']).isEmpty ? '' : ' · DOI ${_s(s['doi'])}'}',
                      key: const Key('worked.source'),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalibrationPainter extends CustomPainter {
  _CalibrationPainter({
    required this.points,
    required this.slope,
    required this.line,
    required this.grid,
    required this.text,
    required this.xLabel,
    required this.yLabel,
    required this.style,
  });

  final List<double> points;
  final double slope;
  final Color line;
  final Color grid;
  final Color text;
  final String xLabel;
  final String yLabel;
  final TextStyle style;

  void _t(Canvas c, String s, Offset at, {bool center = true}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: style.copyWith(color: text),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, at - Offset(center ? tp.width / 2 : 0, 0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || slope <= 0) return;
    const left = 34.0;
    const top = 16.0;
    final bottom = size.height - 26;
    final right = size.width - 8;
    final maxX = points.reduce(math.max);
    final maxY = (maxX * slope * 1.1).clamp(0.1, 10.0);
    double px(double x) => left + x / maxX * (right - left);
    double py(double y) => bottom - y / maxY * (bottom - top);
    final g = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), g);
    canvas.drawLine(const Offset(left, top), Offset(left, bottom), g);
    for (final x in points) {
      _t(canvas, x.toStringAsFixed(0), Offset(px(x), bottom + 4));
    }
    for (final y in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      if (y > maxY) continue;
      final yy = py(y);
      canvas.drawLine(Offset(left - 3, yy), Offset(left, yy), g);
      _t(canvas, y.toStringAsFixed(2), Offset(2, yy - 7), center: false);
    }
    _t(canvas, yLabel, const Offset(left + 4, 0), center: false);
    _t(canvas, xLabel, Offset(right - 24, bottom + 14), center: false);
    canvas.drawLine(
      Offset(px(0), py(0)),
      Offset(px(maxX), py(maxX * slope)),
      Paint()
        ..color = line
        ..strokeWidth = 2.2,
    );
    for (final x in points) {
      final o = Offset(px(x), py(x * slope));
      canvas.drawCircle(o, 4, Paint()..color = line);
      _t(canvas, (x * slope).toStringAsFixed(3), o + const Offset(-18, -18));
    }
  }

  @override
  bool shouldRepaint(_CalibrationPainter old) =>
      old.points != points || old.slope != slope || old.line != line;
}

typedef _Peak = ({double nm, double h, double w});
typedef _Curve = ({double base, List<_Peak> peaks});

class _SpectraPainter extends CustomPainter {
  _SpectraPainter({
    required this.from,
    required this.to,
    required this.curves,
    required this.colors,
    required this.markers,
    required this.grid,
    required this.text,
    required this.style,
  });

  final double from;
  final double to;
  final List<_Curve> curves;
  final List<Color> colors;
  final List<double> markers;
  final Color grid;
  final Color text;
  final TextStyle style;

  double _a(_Curve cv, double x) {
    var y = cv.base;
    for (final p in cv.peaks) {
      final w = p.w <= 0 ? 10 : p.w;
      y += p.h * math.exp(-math.pow(x - p.nm, 2) / (2 * w * w));
    }
    return y;
  }

  void _t(Canvas c, String s, Offset at) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: style.copyWith(color: text),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, at - Offset(tp.width / 2, 0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (to <= from) return;
    const left = 6.0;
    const top = 14.0;
    final bottom = size.height - 22;
    final right = size.width - 6;
    double px(double nm) => left + (nm - from) / (to - from) * (right - left);
    double py(double a) => bottom - a.clamp(0.0, 1.0) * (bottom - top);
    final g = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), g);
    final step = (to - from) <= 100 ? 20.0 : 50.0;
    for (var nm = (from / step).ceil() * step; nm <= to; nm += step) {
      canvas.drawLine(Offset(px(nm), bottom), Offset(px(nm), bottom + 3), g);
      _t(canvas, nm.toStringAsFixed(0), Offset(px(nm), bottom + 4));
    }
    final dash = Paint()
      ..color = text
      ..strokeWidth = 1;
    for (final m in markers) {
      final x = px(m);
      for (var y = top; y < bottom; y += 6) {
        canvas.drawLine(Offset(x, y), Offset(x, math.min(y + 3, bottom)), dash);
      }
      _t(canvas, m.toStringAsFixed(0), Offset(x, 0));
    }
    for (final (i, cv) in curves.indexed) {
      final path = Path();
      for (var nm = from; nm <= to; nm += 0.5) {
        final o = Offset(px(nm), py(_a(cv, nm)));
        nm == from ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colors[i % colors.length]
          ..strokeWidth = 2.4
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_SpectraPainter old) =>
      old.curves != curves || old.from != from || old.to != to;
}
