import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';

/// Onboarding qadamlari: til → ogohlantirish → rejim → hisob.
abstract final class OnboardingSteps {
  static const total = 4;
}

/// Sokin qadam ko‘rsatkichi: ingichka oltin chiziqlar + «Qadam 2 / 4».
/// Foydalanuvchi qancha qolganini darhol ko‘radi (onboarding qisqa).
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({super.key, required this.step});

  /// 1 dan boshlanadi.
  final int step;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final label = l.onbStep(step, OnboardingSteps.total);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        key: const Key('onboarding.progress'),
        children: [
          for (var i = 1; i <= OnboardingSteps.total; i++) ...[
            if (i > 1) const SizedBox(width: FeSpace.xxs),
            Expanded(
              child: AnimatedContainer(
                duration: FeMotion.of(context, FeMotion.standard),
                height: 3,
                decoration: BoxDecoration(
                  color: i <= step ? c.accent : c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
          const SizedBox(width: FeSpace.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
