import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/account.dart';
import '../../../app/routes.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';

/// Admin marshrutlari darvozasi. UI faqat server `my_access.is_admin`
/// bo‘lsa ochiladi; server baribir har bir RPC’da identity_admin’ni
/// tekshiradi (bu darvoza qulaylik, xavfsizlik chegarasi emas).
class AdminGate extends ConsumerWidget {
  const AdminGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(serverAccessProvider);
    return switch (access) {
      AsyncData(:final value) when value.isAdmin => child,
      AsyncLoading() => Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(FeSpace.md),
          child: FeListSkeleton(
            rows: 3,
            semanticLabel: AppLocalizations.of(context).loadingContent,
          ),
        ),
      ),
      _ => const NotAuthorizedScreen(),
    };
  }
}

class NotAuthorizedScreen extends StatelessWidget {
  const NotAuthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.admNotAuthorizedTitle)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(FeSpace.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FeEmptyState(
                  key: const Key('admin.forbidden'),
                  icon: Icons.admin_panel_settings_outlined,
                  title: l.admNotAuthorizedTitle,
                  body: l.admNotAuthorized,
                ),
                FilledButton(
                  key: const Key('admin.backToProfile'),
                  onPressed: () => context.go(Routes.profile),
                  child: Text(l.admBackToProfile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
