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
import '../../../core/widgets/fe_components.dart';
import '../../../domain/professional/professional_models.dart';
import '../../professional/presentation/professional_widgets.dart';
import '../../professional/professional_strings.dart';
import 'onboarding_progress.dart';

/// «FORENSIC EXPERT’dan qanday foydalanasiz?» — Talaba yoki Mutaxassis.
///
/// Bu faqat **foydalanish rejimi** (UI). Mutaxassis rejimini tanlash
/// professional maqomni tasdiqlamaydi — bu ekranda ochiq aytiladi.
class ModeScreen extends ConsumerStatefulWidget {
  const ModeScreen({super.key});

  @override
  ConsumerState<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends ConsumerState<ModeScreen> {
  UserMode? _mode;
  String? _role;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsControllerProvider);
    _mode = s.userMode;
    _role = s.declaredRole;
  }

  Future<void> _continue() async {
    final mode = _mode;
    if (mode == null) return;
    await ref
        .read(settingsControllerProvider.notifier)
        .setUserMode(mode, role: _role);
    if (mounted) context.go(Routes.welcomeAccount);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;

    final roles = switch (_mode) {
      UserMode.student => [
        for (final r in StudentRole.values) (r.name, l.studentRoleLabel(r)),
      ],
      UserMode.professional => [
        for (final r in ProfessionalRole.values)
          (r.name, l.professionalRoleLabel(r)),
      ],
      null => const <(String, String)>[],
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l.actionBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.disclaimer),
        ),
        title: const OnboardingProgress(step: 3),
      ),
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.only(top: FeSpace.sm, bottom: FeSpace.xl),
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
              FeChoiceCard(
                key: const Key('mode.student'),
                icon: Icons.school_outlined,
                title: l.modeStudent,
                description: l.modeStudentDescription,
                selected: _mode == UserMode.student,
                onTap: () => setState(() {
                  if (_mode != UserMode.student) _role = null;
                  _mode = UserMode.student;
                }),
              ),
              const SizedBox(height: FeSpace.sm),
              FeChoiceCard(
                key: const Key('mode.professional'),
                icon: Icons.biotech_outlined,
                title: l.modeProfessional,
                description: l.modeProfessionalDescription,
                selected: _mode == UserMode.professional,
                onTap: () => setState(() {
                  if (_mode != UserMode.professional) _role = null;
                  _mode = UserMode.professional;
                }),
              ),
              // Rol ixtiyoriy — yig‘ilgan holda (ekran sodda qoladi).
              if (roles.isNotEmpty) ...[
                const SizedBox(height: FeSpace.md),
                Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: ValueKey('mode.roles.$_mode'),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: FeSpace.xs),
                    initiallyExpanded: _role != null,
                    title: Text(
                      l.modeRoleExpand,
                      key: const Key('mode.roles'),
                      style: t.titleSmall,
                    ),
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Wrap(
                          spacing: FeSpace.xs,
                          runSpacing: FeSpace.xs,
                          children: [
                            for (final (id, label) in roles)
                              ChoiceChip(
                                key: Key('role.$id'),
                                label: Text(label),
                                selected: _role == id,
                                onSelected: (v) =>
                                    setState(() => _role = v ? id : null),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_mode == UserMode.professional) ...[
                const SizedBox(height: FeSpace.md),
                FeBanner(
                  key: const Key('mode.proNote'),
                  icon: Icons.verified_user_outlined,
                  text: l.modeProfessionalNotVerified,
                ),
              ],
              const SizedBox(height: FeSpace.lg),
              FilledButton(
                key: const Key('mode.continue'),
                onPressed: _mode == null ? null : _continue,
                child: Text(l.actionContinue),
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
