import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';

/// Kalkulyator holati — uch alohida o‘lchov:
/// A. hisoblash moduli (avtomatik dasturiy testlar — ilmiy ekspertiza emas),
/// B. formula manbasi (ilmiy tekshiruv holati),
/// C. talqin (kontekstga bog‘liq, professional baho).
/// Deterministik hisob ilmiy da’vo bilan bir xil «tekshiruv kerak» deb
/// ko‘rsatilmaydi; dasturiy test inson tasdig‘i deb ham ko‘rsatilmaydi.
class CalculatorStatusPanel extends StatelessWidget {
  const CalculatorStatusPanel({
    super.key,
    required this.engineId,
    required this.engineVersion,
    this.referenceStatus = ScientificStatus.needsReview,
  });

  final String engineId;
  final String engineVersion;
  final ScientificStatus referenceStatus;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    Widget row(String label, Widget value) => Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.labelMedium?.copyWith(color: c.textSecondary)),
          const SizedBox(height: 2),
          value,
        ],
      ),
    );
    return FeCard(
      key: const Key('calc.statusPanel'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            l.calcEngineLabel,
            Row(
              key: const Key('calc.status.engine'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.memory_outlined, size: 16, color: c.accent),
                const SizedBox(width: FeSpace.xs),
                Expanded(child: Text(l.calcEngineTested, style: t.bodySmall)),
              ],
            ),
          ),
          row(
            l.calcReferenceLabel,
            ReviewStatusBadge(
              key: const Key('calc.status.reference'),
              status: referenceStatus,
              compact: true,
            ),
          ),
          row(
            l.calcInterpretationLabel,
            Text(
              l.calcInterpretationValue,
              key: const Key('calc.status.interpretation'),
              style: t.bodySmall,
            ),
          ),
          Text(
            '$engineId · v$engineVersion',
            style: FeThemeBuilder.numeric(
              t.labelSmall!,
            ).copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
