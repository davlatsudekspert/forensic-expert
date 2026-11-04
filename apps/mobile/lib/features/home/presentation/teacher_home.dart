import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/brand_mark.dart';

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

/// Banner «USTOZ MINBARI»: chapda emblema (shaffof PNG), o‘ngda nom va shior.
/// Radius 20, oltin chegara. Poydevor — brend ko‘k (`FeBrand`); qora temada
/// sahifa fonidan ajralib turishi uchun bannerga xos bitta qiymat. Matn —
/// `FeBrand.ivory`, chiziq/chegara — `FeBrand.goldOnDark` (ikkala temada ham
/// to‘q fon ustida o‘qiladi).
class UstozMinbariBanner extends StatelessWidget {
  const UstozMinbariBanner({super.key});

  /// Qora temadagi banner poydevori (maket #101D2D).
  static const _darkBase = Color(0xFF101D2D);
  static const _emblemAspect = 1194 / 998;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final b = Theme.of(context).brightness;
    final dark = b == Brightness.dark;
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);
    final screenW = MediaQuery.sizeOf(context).width;
    final title = (screenW * 0.064).clamp(21.0, 27.0);
    return Semantics(
      container: true,
      header: true,
      label: l.teacherBannerSemantics,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, box) {
            final emblemW = (box.maxWidth * 0.30).clamp(96.0, 118.0);
            return DecoratedBox(
              key: const Key('ustoz.banner'),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FeRadius.card),
                border: Border.all(
                  color: FeBrand.goldOnDark.withValues(alpha: 0.55),
                ),
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.3,
                  colors: [
                    dark ? const Color(0xFF172940) : FeBrand.navyLifted,
                    dark ? _darkBase : FeBrand.navy,
                  ],
                  stops: const [0, 0.6],
                ),
                boxShadow: FeShadow.card(b),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  FeSpace.xs + 2,
                  FeSpace.xs + 2,
                  FeSpace.md - 2,
                  FeSpace.xs + 2,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: emblemW,
                      height: emblemW / _emblemAspect,
                      child: Image.asset(
                        'assets/brand/ustoz_minbari_emblem.png',
                        key: const Key('ustoz.emblem'),
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                    const SizedBox(width: FeSpace.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.teacherBannerTitle,
                            maxLines: 2,
                            textScaler: scaler,
                            style: t.headlineSmall?.copyWith(
                              color: FeBrand.ivory,
                              fontSize: title,
                              height: 1.12,
                              letterSpacing: 0.04 * title,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 36,
                            height: 2,
                            decoration: BoxDecoration(
                              color: FeBrand.goldOnDark,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l.teacherBannerTagline,
                            textScaler: scaler,
                            style: t.bodyMedium?.copyWith(
                              color: FeBrand.ivory.withValues(alpha: 0.8),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
