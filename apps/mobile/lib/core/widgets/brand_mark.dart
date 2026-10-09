import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../l10n/generated/app_localizations.dart';

/// Emblema darajalari (optik soddalashtirish).
///
/// * [full] — qalqon, Asklepiy tayog‘i va ilon, DNK spirali, tarozi
///   (≥ 57 dp: splash, kirish, About, til ekrani);
/// * [small] — qalqon + tayoq/ilon, DNK va tarozisiz (≤ 56 dp: Home
///   sarlavhasi, AppBar, paywall) — kichik o‘lchamda «loyqa» bo‘lmaydi.
enum BrandTier { full, small }

/// Brend emblemasi — egasi bergan premium logotipdan olingan qalqon
/// (`design/brand/tools/generate_brand.py`, manba:
/// `design/brand/source/logo_original.webp`).
///
/// Assetlar kvadrat, shaffof fonli, @1x/@2x/@3x — hech qachon
/// cho‘zilmaydi ([BoxFit.contain]). Yorug‘ va qorong‘i variant alohida:
/// qorong‘ida qalqon ichi biroz ochroq navy — grafit fonda yo‘qolmaydi.
/// Belgi dekorativ — ekran o‘quvchisidan yashirilgan, brend nomi alohida
/// matn sifatida o‘qiladi.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72, this.onDark = false, this.tier});

  final double size;

  /// To‘q fon ustida (yorug‘ mavzuda ham) — qorong‘i variant.
  final bool onDark;

  /// Majburiy daraja; berilmasa o‘lchamdan tanlanadi.
  final BrandTier? tier;

  /// Shu o‘lchamgacha (dp) soddalashtirilgan variant.
  static const smallMax = 56.0;

  static BrandTier tierFor(double size) =>
      size <= smallMax ? BrandTier.small : BrandTier.full;

  static String assetFor(BrandTier tier, {required bool dark}) =>
      'assets/brand/emblem_${tier.name}_${dark ? 'dark' : 'light'}.png';

  /// Barcha emblema variantlari (oldindan yuklash, testlar).
  static List<String> get allAssets => [
    for (final t in BrandTier.values)
      for (final d in [false, true]) assetFor(t, dark: d),
  ];

  /// Birinchi kadrda belgi «paydo bo‘lib qolmasligi» uchun.
  static Future<void> precache(BuildContext context) => Future.wait([
    for (final a in allAssets) precacheImage(AssetImage(a), context),
  ]);

  @override
  Widget build(BuildContext context) {
    final dark = onDark || Theme.of(context).brightness == Brightness.dark;
    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        assetFor(tier ?? tierFor(size), dark: dark),
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        excludeFromSemantics: true,
      ),
    );
  }
}

/// Emblema + «FORENSIC EXPERT» wordmark (+ ixtiyoriy tagline) lockup’i.
///
/// Wordmark — jonli matn (Source Serif 4): har o‘lchamda tiniq, tilga
/// moslashadi (tagline ARB’dan). Ranglar logotipdan: navy so‘z, oltin
/// «EXPERT» yon chiziqlar bilan. Qorong‘ida navy o‘rniga fil suyagi.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.markSize = 112, this.showTagline = true});

  /// Emblema balandligi (dp). Wordmark shunga mutanosib.
  final double markSize;

  /// Tagline faqat yetarlicha katta joyda (splash, til ekrani).
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final words = l.appTitle.split(' ');
    final first = words.first;
    final rest = words.skip(1).join(' ');
    final word = (markSize * 0.27).clamp(22.0, 40.0);
    final gold = dark ? FeBrand.goldOnDark : FeBrand.goldOnLight;
    final rule = Container(height: 1.2, color: gold.withValues(alpha: 0.85));
    return Semantics(
      container: true,
      header: true,
      label: showTagline ? '${l.appTitle}. ${l.appTagline}' : l.appTitle,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandMark(size: markSize),
            SizedBox(height: markSize * 0.12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                first,
                maxLines: 1,
                // Wordmark — logotip qismi: shrift masshtabi bilan
                // kattalashmaydi (nom Semantics yorlig‘ida o‘qiladi).
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  fontFamily: FeFonts.serif,
                  fontWeight: FontWeight.w600,
                  fontSize: word,
                  height: 1.0,
                  letterSpacing: word * 0.06,
                  color: dark ? FeBrand.ivory : FeBrand.navy,
                ),
              ),
            ),
            if (rest.isNotEmpty) ...[
              SizedBox(height: word * 0.2),
              SizedBox(
                width: word * 7.2,
                child: Row(
                  children: [
                    Expanded(child: rule),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: word * 0.35),
                      child: Text(
                        rest,
                        maxLines: 1,
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          fontFamily: FeFonts.serif,
                          fontWeight: FontWeight.w600,
                          fontSize: word * 0.62,
                          height: 1.0,
                          letterSpacing: word * 0.62 * 0.28,
                          color: gold,
                        ),
                      ),
                    ),
                    Expanded(child: rule),
                  ],
                ),
              ),
            ],
            if (showTagline) ...[
              SizedBox(height: word * 0.42),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l.appTagline.toUpperCase(),
                  maxLines: 1,
                  textScaler: MediaQuery.textScalerOf(context)
                      .clamp(maxScaleFactor: 1.3),
                  style: TextStyle(
                    fontFamily: FeFonts.sans,
                    fontWeight: FontWeight.w500,
                    fontSize: (word * 0.36).clamp(11.0, 14.0),
                    letterSpacing: 2.2,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
