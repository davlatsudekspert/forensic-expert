import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';

/// Global Search ekrani — PHASE 1 skeleti.
///
/// Qidiruv dvigateli (`fe_search_core` + `fe_database` FTS5) tayyor va
/// test qilingan, lekin tekshirilgan kontent paketi hali yo‘q. PHASE 3 da
/// `SearchIndex` provayderi shu ekranga ulanadi.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: FeSpace.md),
          child: TextField(
            key: const Key('search.field'),
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l.searchHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: FeScrollableBody(
          padding: const EdgeInsets.symmetric(vertical: FeSpace.xl),
          child: Column(
            children: [
              Icon(Icons.travel_explore, size: 40, color: c.textSecondary),
              const SizedBox(height: FeSpace.md),
              Text(
                l.searchUnavailable,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
