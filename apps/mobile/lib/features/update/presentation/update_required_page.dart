import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/brand_mark.dart';

/// To‘liq ekranli to‘siq sahifa: ilova versiyasi serverda ruxsat etilgan
/// eng kam versiyadan eski. Undan o‘tish yo‘li yo‘q — faqat do‘kon.
/// [onUpdate] `null` bo‘lsa (iOS’da havola yo‘q) tugma o‘rniga matn ko‘rsatiladi.
class UpdateRequiredPage extends StatelessWidget {
  const UpdateRequiredPage({super.key, required this.onUpdate});

  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        key: const Key('update.required'),
        backgroundColor: c.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(size: 88),
                    const SizedBox(height: 24),
                    Text(
                      l.updReqTitle,
                      key: const Key('update.title'),
                      textAlign: TextAlign.center,
                      style: t.headlineSmall?.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.updReqBody,
                      textAlign: TextAlign.center,
                      style: t.bodyLarge?.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    if (onUpdate != null)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: const Key('update.button'),
                          onPressed: onUpdate,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: Text(l.updReqButton),
                        ),
                      )
                    else
                      Text(
                        l.updReqStoreHint,
                        key: const Key('update.hint'),
                        textAlign: TextAlign.center,
                        style: t.titleMedium?.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
