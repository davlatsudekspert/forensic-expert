import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/share.dart';
import '../../core/l10n/generated/app_localizations.dart';

/// Tizim share sheet’i orqali ommaviy ilmiy ma’lumotni ulashish.
class ShareButton extends ConsumerWidget {
  const ShareButton({super.key, required this.text, this.subject});

  /// Ulashiladigan matn (bosilganda quriladi).
  final String Function(AppLocalizations l) text;
  final String? subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return IconButton(
      key: const Key('share.record'),
      tooltip: l.shareAction,
      icon: const Icon(Icons.ios_share_rounded),
      onPressed: () => ref
          .read(shareServiceProvider)
          .shareText(text(l), subject: subject, origin: shareOriginOf(context)),
    );
  }
}
