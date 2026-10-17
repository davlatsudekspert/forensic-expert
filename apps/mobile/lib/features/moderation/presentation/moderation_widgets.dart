import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_info.dart';
import '../../../app/moderation.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';

/// Ko‘rinadigan aloqa (Apple 1.2): email — bosilsa pochta ilovasi ochiladi.
class SupportContactLine extends StatelessWidget {
  const SupportContactLine({super.key});

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).admxOpenFailed;
    var ok = false;
    try {
      ok = await launchUrl(
        Uri(scheme: 'mailto', path: AppInfo.supportEmail),
        mode: LaunchMode.externalApplication,
      );
    } on Object {
      ok = false;
    }
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return InkWell(
      key: const Key('contact.line'),
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mail_outline, size: 18, color: c.accent),
            const SizedBox(width: FeSpace.xs),
            Flexible(
              child: Text(
                l.contactLine(AppInfo.supportEmail),
                style: t.bodySmall?.copyWith(color: c.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hamjamiyat qoidalari qabul qilinganini ta’minlaydi (yozishdan oldin).
///
/// Server ulanmagan yoki foydalanuvchi kirmagan bo‘lsa — bloklamaydi
/// (yozishning o‘zi baribir ishlamaydi). Aks holda qoidalar ekrani ochiladi
/// va qabul qilinsagina `true` qaytadi. Serverning o‘zi ham qabulsiz yangi
/// savol/javobni rad etadi (trigger `qa_terms_required`).
Future<bool> ensureCommunityTerms(BuildContext context, WidgetRef ref) async {
  final svc = ref.read(moderationServiceProvider);
  if (!svc.isConfigured || !ref.read(authStateProvider).signedIn) return true;
  if (await svc.communityTermsAccepted() == true) return true;
  if (!context.mounted) return false;
  final accepted = await context.push<bool>(Routes.qaTerms);
  ref.invalidate(communityTermsProvider);
  return accepted == true;
}
