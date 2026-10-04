import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/settings_controller.dart';

/// Ilmiy ogohlantirish. Onboarding’da tasdiqlanadi; Profil’dan faqat
/// o‘qish rejimida ochiladi ([readOnly]).
class DisclaimerScreen extends ConsumerWidget {
  const DisclaimerScreen({super.key, this.readOnly = false});

  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.disclaimerTitle),
        automaticallyImplyLeading: readOnly,
        leading: readOnly
            ? null
            : IconButton(
                tooltip: l.actionBack,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(Routes.language),
              ),
      ),
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.symmetric(vertical: FeSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.science_outlined, size: 40, color: c.accent),
              const SizedBox(height: FeSpace.md),
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
              const SizedBox(height: FeSpace.xl),
              if (!readOnly)
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
