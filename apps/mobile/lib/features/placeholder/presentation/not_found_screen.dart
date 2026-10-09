import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';

/// Noma’lum yoki eskirgan havola: tushunarli matn va Home’ga qaytish.
/// (Router `errorBuilder` va noto‘g‘ri yo‘l parametrlari uchun.)
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('router.notFound'),
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(FeSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FeEmptyState(
                  icon: Icons.link_off,
                  title: l.notFoundTitle,
                  body: l.notFoundBody,
                ),
                const SizedBox(height: FeSpace.md),
                FilledButton.icon(
                  key: const Key('router.notFound.home'),
                  onPressed: () => context.go(Routes.home),
                  icon: const Icon(Icons.home_outlined),
                  label: Text(l.notFoundHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
