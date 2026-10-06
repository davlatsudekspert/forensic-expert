import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/user_data.dart';
import '../../core/design/theme.dart';
import '../../core/design/tokens.dart';
import '../../core/l10n/generated/app_localizations.dart';

/// Saralanganlarga qo‘shish / olib tashlash (lokal): yengil «saqlandi»
/// animatsiyasi (reduced motion’da yo‘q), haptik va qisqa tasdiq.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final isFav = ref.watch(
      userDataProvider.select((d) => d.favorites.contains(id)),
    );
    final duration = FeMotion.of(context, FeMotion.standard);
    return IconButton(
      key: Key('favorite.$id'),
      tooltip: isFav ? l.favoriteRemove : l.favoriteAdd,
      isSelected: isFav,
      icon: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (child, a) => ScaleTransition(
          scale: Tween(
            begin: 0.6,
            end: 1.0,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
          child: FadeTransition(opacity: a, child: child),
        ),
        child: Icon(
          isFav ? Icons.star : Icons.star_border,
          key: ValueKey(isFav),
          color: isFav ? FeTheme.of(context).accent : null,
        ),
      ),
      onPressed: () async {
        final messenger = ScaffoldMessenger.maybeOf(context);
        await ref.read(userDataProvider.notifier).toggleFavorite(id);
        unawaited(HapticFeedback.selectionClick());
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(isFav ? l.savedRemoved : l.savedAdded),
            ),
          );
      },
    );
  }
}
