import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/brand_mark.dart';
import 'panel_banner.dart';

/// Ustoz bosh sahifasi («Ustoz minbari», egasi qarori, 2026-11-04) uchun
/// alohida vidjetlar. FAQAT `UserMode.teacher`: Talaba va Mutaxassis
/// ekranlari bu yerdagi hech narsaga bog‘liq emas.

/// Sarlavha: logotip, nom va shior. Qo‘ng‘iroqcha yo‘q (egasi qarori).
class TeacherHomeHeader extends StatelessWidget {
  const TeacherHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: FeContentFrame(
          child: Padding(
            padding: const EdgeInsets.only(top: FeSpace.sm),
            child: Row(
              key: const Key('home.header'),
              children: [
                const BrandMark(size: 44),
                const SizedBox(width: FeSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l.appTitle,
                          maxLines: 1,
                          style: t.titleMedium?.copyWith(
                            color: c.textPrimary,
                            letterSpacing: 1.6,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l.appTagline,
                          maxLines: 1,
                          style: t.labelMedium?.copyWith(
                            color: c.accent,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner «USTOZ MINBARI»: Talaba banneri bilan bir xil [PanelBanner] dizayni
/// (oq/qora mavzuga mos). Emblema — shaffof PNG, to‘rt tomonida bo‘sh joy bilan.
class UstozMinbariBanner extends StatelessWidget {
  const UstozMinbariBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PanelBanner(
      key: const Key('ustoz.banner'),
      title: l.teacherBannerTitle,
      tagline: l.teacherBannerTagline,
      upperCase: true,
      emblem: const PanelEmblem(
        asset: 'assets/brand/ustoz_minbari_emblem.png',
        key: Key('ustoz.emblem'),
      ),
    );
  }
}
