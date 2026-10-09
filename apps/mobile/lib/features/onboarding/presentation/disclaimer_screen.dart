import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/settings_controller.dart';
import 'onboarding_progress.dart';

/// Ilmiy ogohlantirish. Onboarding’da — uchta qisqa band va «To‘liq
/// matn» (yig‘ilgan); Profil’dan faqat o‘qish rejimida — to‘liq matn
/// ([readOnly]). Mazmun bir xil: qisqartma faqat o‘qishni yengillashtiradi.
class DisclaimerScreen extends ConsumerWidget {
  const DisclaimerScreen({super.key, this.readOnly = false});

  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;

    final fullText = [
      Text(l.disclaimerBody, style: t.bodyLarge),
      const SizedBox(height: FeSpace.md),
      Text(
        l.disclaimerNoConclusions,
        style: t.bodyMedium?.copyWith(color: c.textSecondary),
      ),
      const SizedBox(height: FeSpace.md),
      Text(
        l.disclaimerConsult,
        style: t.bodyMedium?.copyWith(color: c.textSecondary),
      ),
    ];

    if (readOnly) {
      return Scaffold(
        appBar: AppBar(title: Text(l.disclaimerTitle)),
        body: SafeArea(
          child: FeScrollableBody(
            padding: const EdgeInsets.symmetric(vertical: FeSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Emblem(),
                const SizedBox(height: FeSpace.lg),
                ...fullText,
              ],
            ),
          ),
        ),
      );
    }

    final points = [
      (Icons.menu_book_outlined, l.disclaimerPointReference),
      (Icons.science_outlined, l.disclaimerPointLab),
      (Icons.medical_services_outlined, l.disclaimerPointMedical),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l.actionBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.language),
        ),
        title: const OnboardingProgress(step: 2),
      ),
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.only(top: FeSpace.sm, bottom: FeSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Emblem(alignStart: true),
              const SizedBox(height: FeSpace.md),
              Text(
                l.disclaimerTitle,
                style: t.labelLarge?.copyWith(color: c.accent),
              ),
              const SizedBox(height: FeSpace.xxs),
              Semantics(
                header: true,
                child: Text(l.disclaimerIntroTitle, style: t.headlineSmall),
              ),
              const SizedBox(height: FeSpace.lg),
              for (final (icon, text) in points)
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 22, color: c.accent),
                      const SizedBox(width: FeSpace.sm),
                      Expanded(child: Text(text, style: t.bodyLarge)),
                    ],
                  ),
                ),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: const Key('disclaimer.fullText'),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: FeSpace.sm),
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  title: Text(
                    l.disclaimerFullText,
                    style: t.titleSmall?.copyWith(color: c.textSecondary),
                  ),
                  children: fullText,
                ),
              ),
              const SizedBox(height: FeSpace.lg),
              FilledButton(
                key: const Key('disclaimer.accept'),
                onPressed: () async {
                  await ref
                      .read(settingsControllerProvider.notifier)
                      .acceptDisclaimer();
                  if (context.mounted) context.go(Routes.mode);
                },
                child: Text(l.disclaimerAccept),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Oltin halqadagi kolba — sokin ilmiy belgi.
class _Emblem extends StatelessWidget {
  const _Emblem({this.alignStart = false});

  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final emblem = DecoratedBox(
      decoration: BoxDecoration(
        color: c.accentContainer,
        shape: BoxShape.circle,
        border: Border.all(color: c.accentBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Icon(Icons.science_outlined, size: 28, color: c.accent),
      ),
    );
    return ExcludeSemantics(
      child: Align(
        alignment: alignStart
            ? AlignmentDirectional.centerStart
            : Alignment.center,
        child: emblem,
      ),
    );
  }
}
