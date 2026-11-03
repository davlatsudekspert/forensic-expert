import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/assessment/oral_exam.dart';

/// Biletdagi bitta savol: matn, 0–20 ball slayderi va yopiq «Javob kaliti
/// (ustoz uchun)». Mutaxassis (baholash) va Ustoz (mavzu bo‘yicha) biletlari
/// uchun bir xil.
class OralTicketQuestionCard extends StatelessWidget {
  const OralTicketQuestionCard({
    super.key,
    required this.index,
    required this.text,
    required this.score,
    required this.onScore,
    required this.answerKey,
    this.caption,
  });

  final int index;
  final String text;

  /// `null` — hali qo‘yilmagan.
  final int? score;
  final ValueChanged<int> onScore;

  /// Kalit ochilganda ko‘rinadigan mazmun.
  final Widget answerKey;

  /// Savol ustidagi qo‘shimcha izoh (masalan, mavzu nomi).
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final scoreText = (score ?? 0).toString();
    return FeCard(
      key: Key('oral.q.$index'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            [
              l.oralExamQuestionN(index + 1),
              if (caption != null && caption!.isNotEmpty) caption!,
            ].join(' · '),
            style: t.labelMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.xxs),
          Text(text, style: t.titleMedium),
          const SizedBox(height: FeSpace.xs),
          Row(
            children: [
              Expanded(
                child: Slider(
                  key: Key('oral.slider.$index'),
                  value: (score ?? 0).toDouble(),
                  max: oralExamMaxPerQuestion.toDouble(),
                  divisions: oralExamMaxPerQuestion,
                  label: scoreText,
                  semanticFormatterCallback: (v) => l.oralExamScore(v.round()),
                  onChanged: (v) => onScore(v.round()),
                ),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  score == null ? '—' : '$score / $oralExamMaxPerQuestion',
                  key: Key('oral.score.$index'),
                  textAlign: TextAlign.end,
                  style: t.titleSmall,
                ),
              ),
            ],
          ),
          if (score == null)
            Text(
              l.oralExamUnscored,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: Key('oral.key.$index'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(l.oralExamShowKey, style: t.labelLarge),
              children: [answerKey],
            ),
          ),
        ],
      ),
    );
  }
}
