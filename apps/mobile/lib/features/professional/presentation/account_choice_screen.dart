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
import '../../onboarding/presentation/onboarding_progress.dart';
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l.actionBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.mode),
        ),
        title: const OnboardingProgress(step: OnboardingSteps.total),
      ),
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.only(top: FeSpace.sm, bottom: FeSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.accentContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.accentBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(FeSpace.sm),
                      child: Icon(
                        Icons.check_rounded,
                        size: 28,
                        color: c.accent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FeSpace.md),
              Semantics(
                header: true,
                child: Text(l.accountReadyTitle, style: t.headlineSmall),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                l.accountReadyBody,
                style: t.bodyLarge?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.xl),
              FilledButton(
                key: const Key('account.skip'),
                onPressed: () => context.go(Routes.home),
                child: Text(l.accountStartNow),
              ),
              const SizedBox(height: FeSpace.sm),
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
                icon: const Icon(Icons.mail_outline),
                label: Text(l.accountCreateOrSignIn),
              ),
              const SizedBox(height: FeSpace.md),
              if (!configured)
                FeNote(
                  key: const Key('account.unavailable'),
                  icon: Icons.cloud_off_outlined,
                  text: l.accountCloudUnavailable,
                )
              else
                FeNote(
                  key: const Key('account.benefits'),
                  icon: Icons.info_outline,
                  text: l.accountBenefitsNote,
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
