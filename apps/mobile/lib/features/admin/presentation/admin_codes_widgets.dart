import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';

/// Kodni almashish buferiga nusxalaydi va xabar beradi.
Future<void> copyCodes(BuildContext context, List<String> codes) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  await Clipboard.setData(ClipboardData(text: codes.join('\n')));
  messenger.showSnackBar(SnackBar(content: Text(l.instCopied)));
}

/// Yangi yaratilgan kodlar (institut yoki sovg‘a): tartib raqami, kod,
/// nusxalash tugmasi. Kodlar ekranda ochiq — faqat admin ko‘radi.
class CreatedCodesView extends StatelessWidget {
  const CreatedCodesView({
    super.key,
    required this.codes,
    this.keyPrefix = 'codes',
  });

  final List<String> codes;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      key: Key('$keyPrefix.view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.instCodesTitle),
        FeBanner(
          icon: Icons.lock_outline,
          text: l.instCodesNote,
          tone: FeBannerTone.warning,
        ),
        const SizedBox(height: FeSpace.xs),
        OutlinedButton.icon(
          key: Key('$keyPrefix.copyAll'),
          onPressed: () => copyCodes(context, codes),
          icon: const Icon(Icons.copy_all_outlined),
          label: Text(l.instCopyAll),
        ),
        for (var i = 0; i < codes.length; i++)
          ListTile(
            key: Key('$keyPrefix.row.${i + 1}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Text((i + 1).toString(), style: t.bodyMedium),
            title: SelectableText(
              codes[i],
              style: FeThemeBuilder.numeric(t.titleSmall!),
            ),
            trailing: IconButton(
              key: Key('$keyPrefix.copy.${i + 1}'),
              tooltip: l.instCopy,
              icon: Icon(Icons.copy_outlined, color: c.textSecondary),
              onPressed: () => copyCodes(context, [codes[i]]),
            ),
          ),
      ],
    );
  }
}
