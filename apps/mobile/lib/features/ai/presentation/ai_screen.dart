import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../domain/ports/ai_ports.dart';

/// Forensic AI — PHASE 1: real AI ulanmagan. PII ogohlantirishi doimiy.
class AiScreen extends ConsumerWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final availability = ref.watch(aiAssistantProvider).availability;

    return Scaffold(
      appBar: AppBar(title: Text(l.moduleAi)),
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.symmetric(vertical: FeSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Doimiy PII ogohlantirishi (18-bo‘lim).
              Semantics(
                container: true,
                child: DecoratedBox(
                  key: const Key('ai.piiWarning'),
                  decoration: BoxDecoration(
                    color: c.warningContainer,
                    borderRadius: BorderRadius.circular(FeRadius.sm),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(FeSpace.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.privacy_tip_outlined,
                          color: c.onWarningContainer,
                        ),
                        const SizedBox(width: FeSpace.xs),
                        Expanded(
                          child: Text(
                            l.aiPiiWarning,
                            style: t.bodyMedium?.copyWith(
                              color: c.onWarningContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FeSpace.xl),
              if (availability != AiAvailability.available) ...[
                Icon(
                  Icons.auto_awesome_outlined,
                  size: 40,
                  color: c.textSecondary,
                ),
                const SizedBox(height: FeSpace.md),
                Semantics(
                  header: true,
                  child: Text(
                    l.aiNotConnectedTitle,
                    textAlign: TextAlign.center,
                    style: t.titleMedium,
                  ),
                ),
                const SizedBox(height: FeSpace.xs),
                Text(
                  l.aiNotConnectedBody,
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(color: c.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
