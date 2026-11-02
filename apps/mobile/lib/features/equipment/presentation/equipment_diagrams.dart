import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/equipment.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/fe_localizations_delegate.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';

/// Apparat sahifasidagi sxemalar (egasi talabi, 2026-11-02):
/// spektrofotometr — COHb va Hb yutilish cho‘qqilari; GC-MS — natijani
/// (cho‘qqilarni) o‘qish sahifasiga kirish.
abstract final class EquipmentDiagrams {
  /// «Usullar» bo‘limidagi usul sahifasi uchun amaliy misollar.
  static Widget? forMethod(String id) => switch (id) {
    'method-uvvis' => const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WorkedExampleCard('phenobarbital_blood_uv'),
        WorkedExampleCard('tropicamide_uv'),
      ],
    ),
    'method-gcms' => const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_GcmsReadingCard(), WorkedExampleCard('gcms_drugs_qp2020')],
    ),
    'method-spe' => const SpeMethodCard(),
    _ => null,
  };

  static Widget? forItem(String id) => switch (id) {
    'uv_vis' => const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CohbSpectrumCard(),
        WorkedExampleCard('phenobarbital_blood_uv'),
        WorkedExampleCard('tropicamide_uv'),
      ],
    ),
    'gc_ms' => const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_GcmsReadingCard(), WorkedExampleCard('gcms_drugs_qp2020')],
    ),
    _ => null,
  };
}

/// Raqamlar manbadan: Байзолданов Т. Токсикологическая химия, 3-qism.
/// Almaty: Evero, 2021, 228–229-betlar — COHb maksimumlari 540–541 va
/// 570–571 nm, deoksigemoglobin 557 nm, izobestik nuqtalar 550, 565, 579 nm.
/// Egri chiziqlar shakli — sxema (o‘lchov emas).
class _CohbSpectrumCard extends StatelessWidget {
  const _CohbSpectrumCard();

  static const source =
      'Байзолданов Т. Токсикологическая химия, 3-qism. Almaty: Evero, 2021, '
      '228–229-betlar';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    const cohb = Color(0xFFC0392B);
    final hb = c.textPrimary;
    Widget legend(Color color, String text, {bool dashed = false}) => Padding(
      padding: const EdgeInsets.only(top: FeSpace.xxs),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 10,
            child: CustomPaint(
              painter: _LegendLine(color: color, dashed: dashed),
            ),
          ),
          const SizedBox(width: FeSpace.xs),
          Expanded(child: Text(text, style: t.bodySmall)),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.cohbSpecTitle),
        FeCard(
          key: const Key('equipment.cohbSpectrum'),
          padding: const EdgeInsets.all(FeSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: l.cohbSpecSemantics,
                child: AspectRatio(
                  aspectRatio: 1.45,
                  child: CustomPaint(
                    painter: _SpectrumPainter(
                      cohb: cohb,
                      hb: hb,
                      grid: c.border,
                      text: c.textSecondary,
                      axisLabel: l.cohbSpecAxis,
                      isoLabel: l.cohbSpecIso,
                      style: t.labelSmall ?? const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FeSpace.sm),
              legend(cohb, l.cohbSpecCohb),
              legend(hb, l.cohbSpecHb),
              legend(c.textSecondary, l.cohbSpecIsoLegend, dashed: true),
              const SizedBox(height: FeSpace.sm),
              Text(l.cohbSpecNote, style: t.bodySmall),
              const SizedBox(height: FeSpace.sm),
              Text(
                '${l.pmdSourceLabel}: $source',
                key: const Key('equipment.cohbSpectrum.source'),
                style: t.labelSmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendLine extends CustomPainter {
  const _LegendLine({required this.color, this.dashed = false});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.5;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
      return;
    }
    p.strokeWidth = 1.2;
    for (var x = 0.0; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + 3, size.width), y), p);
    }
  }

  @override
  bool shouldRepaint(_LegendLine old) =>
      old.color != color || old.dashed != dashed;
}

class _SpectrumPainter extends CustomPainter {
  _SpectrumPainter({
    required this.cohb,
    required this.hb,
    required this.grid,
    required this.text,
    required this.axisLabel,
    required this.isoLabel,
    required this.style,
  });

  final Color cohb;
  final Color hb;
  final Color grid;
  final Color text;
  final String axisLabel;
  final String isoLabel;
  final TextStyle style;

  static const _from = 500.0;
  static const _to = 600.0;

  static double _g(double x, double mu, double s) =>
      math.exp(-math.pow(x - mu, 2) / (2 * s * s));

  // Sxema: COHb — ikki cho‘qqi (541 va 571 nm), Hb — bitta keng cho‘qqi
  // (557 nm). Balandliklar nisbiy.
  static double cohbA(double x) =>
      0.2 + 0.68 * _g(x, 541, 8) + 0.7 * _g(x, 571, 8.5);
  static double hbA(double x) => 0.2 + 0.62 * _g(x, 557, 17);

  void _label(
    Canvas canvas,
    String s,
    Offset at,
    Color color, {
    bool center = true,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: style.copyWith(color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(center ? tp.width / 2 : 0, 0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    const left = 6.0;
    const top = 18.0;
    final bottom = size.height - 30;
    final w = size.width - left * 2;
    final h = bottom - top;
    double px(double nm) => left + (nm - _from) / (_to - _from) * w;
    double py(double a) => bottom - a * h;

    final axis = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, bottom), Offset(left + w, bottom), axis);
    for (final nm in [500.0, 520.0, 540.0, 560.0, 580.0, 600.0]) {
      final x = px(nm);
      canvas.drawLine(Offset(x, bottom), Offset(x, bottom + 4), axis);
      _label(canvas, '${nm.toInt()}', Offset(x, bottom + 5), text);
    }
    _label(
      canvas,
      axisLabel,
      Offset(left + w, bottom + 16),
      text,
      center: false,
    );

    // Izobestik nuqtalar: 550, 565, 579 nm.
    final iso = Paint()
      ..color = text.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    for (final nm in [550.0, 565.0, 579.0]) {
      final x = px(nm);
      for (var y = top; y < bottom; y += 6) {
        canvas.drawLine(Offset(x, y), Offset(x, math.min(y + 3, bottom)), iso);
      }
    }
    _label(canvas, isoLabel, Offset(px(565), 0), text);

    Path curve(double Function(double) f) {
      final p = Path();
      for (var nm = _from; nm <= _to; nm += 0.5) {
        final o = Offset(px(nm), py(f(nm)));
        nm == _from ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
      }
      return p;
    }

    canvas.drawPath(
      curve(hbA),
      Paint()
        ..color = hb
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      curve(cohbA),
      Paint()
        ..color = cohb
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke,
    );

    void peak(double nm, double a, Color color, String s) {
      final o = Offset(px(nm), py(a));
      canvas.drawCircle(o, 3.2, Paint()..color = color);
      _label(canvas, s, o - const Offset(0, 16), color);
    }

    peak(541, cohbA(541), cohb, '541');
    peak(571, cohbA(571), cohb, '571');
    peak(557, hbA(557), hb, '557');
  }

  @override
  bool shouldRepaint(_SpectrumPainter old) =>
      old.cohb != cohb || old.hb != hb || old.text != text;
}

/// GC-MS: xromatogramma va mass-spektr cho‘qqilarini o‘qish mashqi.
class _GcmsReadingCard extends StatelessWidget {
  const _GcmsReadingCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.gcmsPeaksTitle),
        FeCard(
          key: const Key('equipment.gcmsReading'),
          onTap: () => context.push(Routes.gcmsReading),
          padding: const EdgeInsets.all(FeSpace.md),
          child: Row(
            children: [
              Icon(Icons.stacked_line_chart, color: c.accent, size: 32),
              const SizedBox(width: FeSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.labHubReading, style: t.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      l.labHubReadingBody,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

/// Amaliy misolga kirish (masalan, tropikamidni miqdoriy aniqlash).
class WorkedExampleCard extends StatelessWidget {
  const WorkedExampleCard(this.id, {super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.weHeader),
        FeCard(
          key: Key('equipment.worked.$id'),
          onTap: () => context.push(Routes.workedExample(id)),
          padding: const EdgeInsets.all(FeSpace.md),
          child: Row(
            children: [
              Icon(Icons.science_outlined, color: c.accent, size: 32),
              const SizedBox(width: FeSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(switch (id) {
                      'tropicamide_uv' => l.weTropicamideTitle,
                      'gcms_drugs_qp2020' => l.weGcmsTitle,
                      _ => l.weBarbTitle,
                    }, style: t.titleSmall),
                    const SizedBox(height: 2),
                    Text(switch (id) {
                      'tropicamide_uv' => l.weTropicamideBody,
                      'gcms_drugs_qp2020' => l.weGcmsBody,
                      _ => l.weBarbBody,
                    }, style: t.bodySmall?.copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

/// «Qattiq fazali ekstraksiya (SPE)» usul sahifasi: bosqichlar sxemasi,
/// tartibli qadamlar va manbalar — «Asbob-uskunalar» kartochkasidagi (`spe`)
/// manbali matndan; to‘liq kartochka (qurilma, ehtiyot choralari, O‘zbekiston)
/// havola orqali ochiladi.
class SpeMethodCard extends ConsumerWidget {
  const SpeMethodCard({super.key});

  static String _u(String s) => uzDisplay('uz', s);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(equipmentProvider).value?.byId('spe');
    if (item == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final pending = Localizations.localeOf(context).languageCode != 'uz';
    return Column(
      key: const Key('method.spe'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.equipSteps),
        if (pending)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: FeBanner(
              key: const Key('method.spe.translationPending'),
              icon: Icons.translate,
              text: l.trPendingTranslation,
            ),
          ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FeRadius.lg),
                child: ColoredBox(
                  color: const Color(0xFFF7F1E8),
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.cover,
                    semanticLabel: _u(item.name),
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: FeSpace.xs),
        Text(
          l.equipSchemeNote,
          key: const Key('method.spe.note'),
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.sm),
        for (final (i, x) in item.steps.map(_u).indexed)
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
                    border: Border.all(color: c.accentBorder),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: t.labelMedium?.copyWith(
                      color: c.onAccentContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(child: Text(x, style: t.bodyMedium)),
              ],
            ),
          ),
        FeCard(
          key: const Key('method.spe.device'),
          padding: const EdgeInsets.all(FeSpace.sm),
          onTap: () => context.push(Routes.equipmentItem(item.id)),
          child: Row(
            children: [
              Icon(Icons.biotech_outlined, color: c.accent),
              const SizedBox(width: FeSpace.sm),
              Expanded(child: Text(l.methodDeviceCard, style: t.titleSmall)),
              Icon(Icons.chevron_right, color: c.textSecondary),
            ],
          ),
        ),
        FeSectionHeader(l.equipSources),
        for (final s in item.sources)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: Text(
              '${_dot(s.author)} ${_dot(s.title)} ${s.page}'
              '${s.doi.isEmpty ? '' : ' · DOI ${s.doi}'}',
              key: const Key('method.spe.source'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
      ],
    );
  }

  static String _dot(String x) => x.endsWith('.') ? x : '$x.';
}
