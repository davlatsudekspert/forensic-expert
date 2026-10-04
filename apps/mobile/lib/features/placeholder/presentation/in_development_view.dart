import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';

/// Hali qurilmagan bo‘limlar uchun bir xil holat. Ilmiy kontent
/// ko‘rsatilmaydi — faqat bo‘lim keyinroq paydo bo‘lishi aytiladi.
class InDevelopmentView extends StatelessWidget {
  const InDevelopmentView({super.key, this.icon = Icons.construction_outlined});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeScrollableBody(
      padding: const EdgeInsets.symmetric(vertical: FeSpace.xl),
      child: Column(
        children: [
          Icon(icon, size: 40, color: c.textSecondary),
          const SizedBox(height: FeSpace.md),
          Semantics(
            header: true,
            child: Text(
              l.inDevelopmentTitle,
              style: t.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            l.inDevelopmentBody,
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Modul sahifasi (PHASE 1 — placeholder).
class ModulePlaceholderScreen extends StatelessWidget {
  const ModulePlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: const SafeArea(child: InDevelopmentView()),
  );
}
