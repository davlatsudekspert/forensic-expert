import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';

/// «How will you use Forensic Expert?» — dashboard’ni moslashtiradi.
class ModeScreen extends ConsumerWidget {
  const ModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;

    Future<void> choose(UserMode mode) async {
      await ref.read(settingsControllerProvider.notifier).setUserMode(mode);
      if (context.mounted) context.go(Routes.home);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l.actionBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.disclaimer),
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
                child: Text(l.modeTitle, style: t.headlineSmall),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                l.modeSubtitle,
                style: t.bodyMedium?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.lg),
              ModeOptionCard(
                key: const Key('mode.professional'),
                icon: Icons.biotech_outlined,
                title: l.modeProfessional,
                description: l.modeProfessionalDescription,
                onTap: () => choose(UserMode.professional),
              ),
              const SizedBox(height: FeSpace.sm),
              ModeOptionCard(
                key: const Key('mode.student'),
                icon: Icons.school_outlined,
                title: l.modeStudent,
                description: l.modeStudentDescription,
                onTap: () => choose(UserMode.student),
              ),
              const SizedBox(height: FeSpace.sm),
              ModeOptionCard(
                key: const Key('mode.research'),
                icon: Icons.menu_book_outlined,
                title: l.modeResearch,
                description: l.modeResearchDescription,
                onTap: () => choose(UserMode.research),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModeOptionCard extends StatelessWidget {
  const ModeOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          side: BorderSide(
            color: selected ? c.accent : c.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(FeSpace.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: c.accent, size: 28),
                const SizedBox(width: FeSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: t.titleMedium),
                      const SizedBox(height: FeSpace.xxs),
                      Text(
                        description,
                        style: t.bodyMedium?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                ExcludeSemantics(
                  child: Icon(Icons.chevron_right, color: c.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
