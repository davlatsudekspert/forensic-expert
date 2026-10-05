import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import 'professional_widgets.dart';

/// Onboarding’dan keyin: hisobsiz davom etish (asosiy) yoki hisob.
///
/// Oflayn ilmiy ma’lumotlar va kalkulyatorlar hisobsiz ishlaydi. Hisob
/// faqat bulut funksiyalari uchun kerak. Server ulanmagan bo‘lsa — buni
/// ochiq aytamiz, ishlamaydigan tugma ko‘rsatilmaydi.
class AccountChoiceScreen extends ConsumerWidget {
  const AccountChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final configured = ref.watch(authRepositoryProvider).isConfigured;
    final cloudFeatures = [
      (Icons.verified_user_outlined, l.accountNeedVerification),
      (Icons.rate_review_outlined, l.accountNeedReviews),
      (Icons.sync, l.accountNeedSync),
      (Icons.workspace_premium_outlined, l.accountNeedSubscriptions),
      (Icons.auto_awesome_outlined, l.accountNeedCloudAi),
      (Icons.apartment_outlined, l.accountNeedInstitution),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l.actionBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.mode),
        ),
      ),
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.only(bottom: FeSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(l.accountChoiceTitle, style: t.headlineSmall),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                l.accountChoiceSubtitle,
                style: t.bodyMedium?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.lg),
              FilledButton.icon(
                key: const Key('account.skip'),
                onPressed: () => context.go(Routes.home),
                icon: const Icon(Icons.offline_bolt_outlined),
                label: Text(l.accountContinueWithout),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                l.accountContinueWithoutNote,
                textAlign: TextAlign.center,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.md),
              OutlinedButton.icon(
                key: const Key('account.create'),
                onPressed: configured
                    ? () async {
                        final ok = await context.push<bool>(
                          Routes.welcomeEmailCode,
                        );
                        if (ok == true && context.mounted) {
                          context.go(Routes.home);
                        }
                      }
                    : null,
                icon: const Icon(Icons.person_add_alt),
                label: Text(l.accountCreateOrSignIn),
              ),
              if (!configured) ...[
                const SizedBox(height: FeSpace.xs),
                FeNote(
                  key: const Key('account.unavailable'),
                  icon: Icons.cloud_off_outlined,
                  text: l.accountCloudUnavailable,
                ),
              ],
              const SizedBox(height: FeSpace.lg),
              Text(l.accountNeededFor, style: t.titleSmall),
              const SizedBox(height: FeSpace.xs),
              for (final (icon, text) in cloudFeatures)
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  child: FeNote(icon: icon, text: text),
                ),
              const SizedBox(height: FeSpace.md),
              TextButton.icon(
                key: const Key('account.fillProfile'),
                onPressed: () => context.push(Routes.welcomeProfile),
                icon: const Icon(Icons.badge_outlined),
                label: Text(l.accountFillProfile),
              ),
              Text(
                l.profileLocalOnlyNote,
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

/// Bulut xizmati holati (profil, tasdiqlash, taqriz ekranlarida).
class CloudUnavailableNote extends StatelessWidget {
  const CloudUnavailableNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) =>
      FeBanner(icon: Icons.cloud_off_outlined, text: text);
}
