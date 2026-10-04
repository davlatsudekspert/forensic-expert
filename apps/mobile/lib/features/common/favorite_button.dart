import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/user_data.dart';
import '../../core/design/theme.dart';
import '../../core/l10n/generated/app_localizations.dart';

/// Saralanganlarga qo‘shish / olib tashlash (lokal).
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final isFav = ref.watch(
      userDataProvider.select((d) => d.favorites.contains(id)),
    );
    return IconButton(
      key: Key('favorite.$id'),
      tooltip: isFav ? l.favoriteRemove : l.favoriteAdd,
      isSelected: isFav,
      icon: Icon(
        isFav ? Icons.star : Icons.star_border,
        color: isFav ? FeTheme.of(context).accent : null,
      ),
      onPressed: () => ref.read(userDataProvider.notifier).toggleFavorite(id),
    );
  }
}
