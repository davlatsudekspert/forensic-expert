import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../placeholder/presentation/in_development_view.dart';

/// Kalkulyatorlar katalogi — PHASE 4 da `fe_calc_engine` reyestri bilan to‘ldiriladi.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).toolsTitle)),
    body: const SafeArea(
      child: InDevelopmentView(icon: Icons.calculate_outlined),
    ),
  );
}
