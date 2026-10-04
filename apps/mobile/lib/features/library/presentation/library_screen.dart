import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../placeholder/presentation/in_development_view.dart';

/// Kutubxona — PHASE 5 da tekshirilgan kontent paketi bilan to‘ldiriladi.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).libraryTitle)),
    body: const SafeArea(
      child: InDevelopmentView(icon: Icons.local_library_outlined),
    ),
  );
}
