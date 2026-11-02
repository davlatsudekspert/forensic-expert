import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/catalog.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/catalog/catalog.dart';

/// «Katalogda ko‘rsatish» roziligi (DEFAULT o‘chiq) + yig‘ilgan yulduzchalar.
/// Ustoz profili boshida ([CatalogKind.teacher]) va tasdiqlangan mutaxassis
/// profilida ([CatalogKind.expert]).
class CatalogVisibilityTile extends ConsumerStatefulWidget {
  const CatalogVisibilityTile({super.key, required this.kind});

  final CatalogKind kind;

  @override
  ConsumerState<CatalogVisibilityTile> createState() =>
      _CatalogVisibilityTileState();
}

class _CatalogVisibilityTileState extends ConsumerState<CatalogVisibilityTile> {
  bool? _on;
  bool _busy = false;

  Future<void> _set(bool v) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _on = v;
    });
    final r = await ref.read(catalogServiceProvider).setVisible(widget.kind, v);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!r.ok) {
      setState(() => _on = !v);
      messenger.showSnackBar(SnackBar(content: Text(l.catVisibleFailed)));
    } else {
      ref.invalidate(catalogMeProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(catalogServiceProvider).isConfigured) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final me = ref.watch(catalogMeProvider).value ?? CatalogMe.empty;
    final server = widget.kind == CatalogKind.teacher
        ? me.teacherCatalog
        : me.expertCatalog;
    final on = _on ?? server;
    return Column(
      key: Key('catalog.visibility.${widget.kind.wire}'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFE0A100), size: 22),
            const SizedBox(width: FeSpace.xxs),
            Text(
              l.catStarsCount(me.stars),
              key: const Key('catalog.myStars'),
              style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SwitchListTile(
          key: Key('catalog.toggle.${widget.kind.wire}'),
          contentPadding: EdgeInsets.zero,
          value: on,
          onChanged: _busy ? null : _set,
          title: Text(
            widget.kind == CatalogKind.teacher
                ? l.catShowMeTeachers
                : l.catShowMeExperts,
          ),
          subtitle: Text(
            l.catShowMeHint,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ),
        if (widget.kind == CatalogKind.expert && !me.expertVerified)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l.catExpertUnverifiedHint,
              key: const Key('catalog.unverifiedHint'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
      ],
    );
  }
}
