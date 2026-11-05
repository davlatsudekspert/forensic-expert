import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';

/// Talaba («Mening akademiyam») va Ustoz («USTOZ MINBARI») banneri uchun
/// BITTA umumiy dizayn: balandlik, radius, chegara, emblema qutisi, oraliq va
/// tipografiya ikkalasida bir xil. Faqat emblema, sarlavha va shior farq qiladi.
///
/// Ranglar — mavjud global mavzudan (`Theme.brightness`, [FeTheme]):
/// * oq temada: och krem/kulrang fon (`brandContainer`) + nozik oltin chegara;
/// * qora temada: to‘q ko‘k fon + oltin aksent + och matn.
class PanelBanner extends StatelessWidget {
  const PanelBanner({
    required this.title,
    required this.tagline,
    required this.emblem,
    this.upperCase = false,
    super.key,
  });

  final String title;
  final String tagline;

  /// Emblema (qutiga [emblemAspect] nisbatida joylanadi).
  final Widget emblem;

  /// Katta harfli sarlavha (USTOZ MINBARI) uchun harf oralig‘i biroz ochiladi.
  final bool upperCase;

  /// Emblema qutisining nisbati (ikkala banner uchun bir xil).
  static const emblemAspect = 1.15;
  static const double minHeight = 150;
  static const double titleSize = 26;

  static const _darkBase = Color(0xFF101D2D);
  static const _darkLift = Color(0xFF172940);

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final b = Theme.of(context).brightness;
    final dark = b == Brightness.dark;
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);
    final titleColor = dark ? FeBrand.ivory : c.textPrimary;
    final accent = dark ? FeBrand.goldOnDark : c.accent;
    final tagColor = dark
        ? FeBrand.ivory.withValues(alpha: 0.8)
        : c.textSecondary;
    // Ekran o‘qigichga sarlavha va shior matnning o‘zidan o‘qiladi (qattiq
    // yozilgan matn yo‘q); emblema semantikadan chiqarilgan.
    return Semantics(
      container: true,
      child: LayoutBuilder(
        builder: (context, box) {
          final emblemW = (box.maxWidth * 0.30).clamp(96.0, 118.0);
          return DecoratedBox(
            decoration: BoxDecoration(
              color: dark ? null : c.brandContainer,
              gradient: dark
                  ? const RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.3,
                      colors: [_darkLift, _darkBase],
                      stops: [0, 0.6],
                    )
                  : null,
              borderRadius: BorderRadius.circular(FeRadius.card),
              border: Border.all(
                color: accent.withValues(alpha: dark ? 0.55 : 0.5),
              ),
              boxShadow: FeShadow.card(b),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: minHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  FeSpace.sm,
                  FeSpace.xs + 2,
                  FeSpace.md,
                  FeSpace.xs + 2,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: emblemW,
                      height: emblemW / emblemAspect,
                      child: emblem,
                    ),
                    const SizedBox(width: FeSpace.sm),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            textScaler: scaler,
                            style: t.headlineSmall?.copyWith(
                              color: titleColor,
                              fontSize: titleSize,
                              height: 1.12,
                              letterSpacing: upperCase ? 0.8 : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 36,
                            height: 2,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tagline,
                            textScaler: scaler,
                            style: t.bodyMedium?.copyWith(
                              color: tagColor,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Banner emblemasi uchun yordamchi: shaffof PNG ni qutiga sig‘dirib, to‘rt
/// tomonidan bir xil bo‘sh joy qoldiradi (dafna matnga yopishmasin).
class PanelEmblem extends StatelessWidget {
  const PanelEmblem({required this.asset, this.inset = 0.03, super.key});

  final String asset;

  /// Quti kengligidan ulush: har tomondan bo‘sh joy.
  final double inset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => Padding(
        padding: EdgeInsets.all(box.maxWidth * inset),
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}

/// Mavjud (tasdiqlangan) Talaba emblemasi kadri: shaffof chetlari kesilgan.
class StudentEmblemFrame extends StatelessWidget {
  const StudentEmblemFrame({super.key});

  // Emblema fayli (512²) ichidagi kerakli kadr (tasdiqlangan maket).
  static const _frameAspect = 1075 / 940;
  static const _imageScale = 1.429;
  static const _shiftX = 0.206;
  static const _shiftY = 0.298;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // Kadr qutiga nisbatini saqlab sig‘adi, bir xil bo‘sh joy bilan.
        final w = box.maxWidth * 0.94;
        final h = w / _frameAspect;
        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: -_shiftX * w,
                  top: -_shiftY * h,
                  width: _imageScale * w,
                  child: Image.asset(
                    'assets/brand/student_academy_emblem.png',
                    key: const Key('student.emblem'),
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
