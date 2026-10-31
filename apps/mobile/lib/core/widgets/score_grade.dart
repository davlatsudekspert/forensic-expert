import 'package:flutter/material.dart';

import '../../domain/grading/grade_scale.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../l10n/generated/app_localizations.dart';

/// Baho matni: «5», «4», «3» yoki «Minimal o‘tish balidan past».
String pfGradeText(AppLocalizations l, PfGrade g) =>
    g.value?.toString() ?? l.scoringGradeBelowMin;

/// «Taxminiy baho» tushuntirishi (ekranda BIR marta ko‘rsatiladi).
String scoreApproxNote(AppLocalizations l) =>
    l.scoringApproxNote(GradeScale.minPass.toStringAsFixed(1));

/// Talaba natijasi bloki: «Ball (100)» + «Taxminiy baho (2026-2027 tartibi
/// bo‘yicha)». Ball = to‘g‘ri / jami × 100 ([GradeScale]).
class ScoreGradeBlock extends StatelessWidget {
  const ScoreGradeBlock({
    super.key,
    required this.correct,
    required this.total,
    this.showNote = true,
    this.keyPrefix = 'score100',
  });

  final int correct;
  final int total;

  /// Taxminiy baho izohi (ekranda bir marta).
  final bool showNote;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final r = GradeScale.of(correct, total);
    final g = r.grade;
    return Column(
      key: Key('$keyPrefix.block'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.scoringScore100Label,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        Text(
          r.text,
          key: Key('$keyPrefix.value'),
          style: t.displaySmall?.copyWith(
            color: c.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: FeSpace.xs),
        Text(
          l.scoringGradeApproxTitle(GradeScale.academicYear),
          key: Key('$keyPrefix.gradeTitle'),
          textAlign: TextAlign.center,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        Text(
          pfGradeText(l, g),
          key: Key('$keyPrefix.grade'),
          textAlign: TextAlign.center,
          style: (g.passed ? t.headlineSmall : t.titleMedium)?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (showNote) ...[
          const SizedBox(height: FeSpace.xs),
          Text(
            scoreApproxNote(l),
            key: Key('$keyPrefix.note'),
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// Ustoz natijalari qatori uchun bir qator: «Ball (100): 86.7 · Baho: 4».
class ScoreGradeLine extends StatelessWidget {
  const ScoreGradeLine({
    super.key,
    required this.correct,
    required this.total,
    this.style,
  });

  final int correct;
  final int total;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final r = GradeScale.of(correct, total);
    return Text(
      l.scoringRowLine(r.text, pfGradeText(l, r.grade)),
      style:
          style ??
          Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: c.textSecondary),
    );
  }
}
