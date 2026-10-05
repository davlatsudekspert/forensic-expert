import 'package:flutter/material.dart';

import '../../../app/app_info.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/fe_components.dart';

enum LegalDocument { privacy, terms, aiDisclaimer }

/// Privacy Policy / Terms of Use — QORALAMA. Yuridik tekshiruvdan keyin
/// to‘liq matn bilan almashtiriladi (RELEASE GATE RG-05).
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final (title, body) = switch (document) {
      LegalDocument.privacy => (l.privacyPolicy, l.privacySummary),
      LegalDocument.terms => (l.termsOfUse, l.disclaimerBody),
      LegalDocument.aiDisclaimer => (l.aiDisclaimerLink, l.aiDisclaimerBody),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.symmetric(vertical: FeSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FeBanner(
                key: const Key('legal.draft'),
                icon: Icons.edit_note,
                text: l.legalDraftNotice,
                tone: FeBannerTone.warning,
              ),
              const SizedBox(height: FeSpace.md),
              Text(body, style: t.bodyLarge),
              if (document == LegalDocument.terms) ...[
                const SizedBox(height: FeSpace.md),
                Text(l.disclaimerNoConclusions, style: t.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.aboutApp)),
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.symmetric(vertical: FeSpace.xl),
          child: Column(
            children: [
              const BrandMark(size: 128),
              const SizedBox(height: FeSpace.md),
              Text(l.appTitle, style: t.titleLarge?.copyWith(letterSpacing: 2)),
              Text(
                l.appTagline,
                style: t.bodyMedium?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.lg),
              Text(
                l.aboutBody,
                textAlign: TextAlign.center,
                style: t.bodyLarge,
              ),
              const SizedBox(height: FeSpace.md),
              Text(
                '${l.appVersionLabel} ${AppInfo.version} (${AppInfo.build})',
                style: FeThemeBuilder.numeric(t.bodySmall!),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                l.aboutVersions,
                textAlign: TextAlign.center,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                l.aboutTrademarkPending,
                key: const Key('about.trademark'),
                textAlign: TextAlign.center,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
