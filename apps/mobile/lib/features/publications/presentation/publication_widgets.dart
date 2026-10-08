import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/publications.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/publications/publication_models.dart';
import '../publication_strings.dart';

/// Holat belgisi (rang yagona belgi emas — ikonka va matn bilan).
class PublicationStatusBadge extends StatelessWidget {
  const PublicationStatusBadge(this.status, {super.key});

  final PublicationStatus status;

  @override
  Widget build(BuildContext context) => StatusChip(
    icon: status.icon,
    label: AppLocalizations.of(context).pubStatus(status),
    color: status.color(FeTheme.of(context)),
  );
}

/// «Maqola yuborilgani uning ilmiy tasdiqlanganini bildirmaydi».
class PublicationNotice extends StatelessWidget {
  const PublicationNotice({super.key});

  @override
  Widget build(BuildContext context) => FeBanner(
    key: const Key('publication.notice'),
    icon: Icons.info_outline,
    tone: FeBannerTone.warning,
    text: AppLocalizations.of(context).pubNotVerifiedNotice,
  );
}

/// Bo‘lim bayroq (`FE_PUBLICATIONS`) yoki admin uchun ochiq; aks holda
/// «hozircha mavjud emas».
class PublicationsGate extends ConsumerWidget {
  const PublicationsGate({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(publicationsVisibleProvider)) return child;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: FeEmptyState(
          key: const Key('publications.unavailable'),
          icon: Icons.lock_clock_outlined,
          body: AppLocalizations.of(context).pubUnavailable,
        ),
      ),
    );
  }
}

/// Kirish talab qilinadigan joyda (yuborish, mening maqolalarim).
class PublicationsSignInPrompt extends StatelessWidget {
  const PublicationsSignInPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FeEmptyState(
          key: const Key('publications.signInRequired'),
          icon: Icons.login,
          body: l.pubSignInRequired,
        ),
        FilledButton(
          key: const Key('publications.signIn'),
          onPressed: () => context.push(Routes.accountSignIn),
          child: Text(l.pubSignIn),
        ),
      ],
    );
  }
}
