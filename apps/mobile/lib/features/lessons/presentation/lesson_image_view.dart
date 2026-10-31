import 'package:flutter/material.dart';

import '../../../app/fe_client_headers.dart';
import '../../../core/design/theme.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/lessons/lesson_models.dart';

/// Faqat testlar uchun: rasm manbasini almashtirish (tarmoqsiz).
@visibleForTesting
ImageProvider Function(String url)? lessonImageProviderOverride;

ImageProvider _provider(String url) =>
    (lessonImageProviderOverride ?? _networkImage)(url);

ImageProvider _networkImage(String url) =>
    NetworkImage(url, headers: feHeadersForUrl(url));

/// Rasm (raster) + yuklanish/xato holati + caption va kichik litsenziya
/// qatori. Bosilganda — to‘liq ekran. Xato/oflayn: ikonka + «Rasm
/// yuklanmadi» (crash yo‘q).
class LessonImageView extends StatelessWidget {
  const LessonImageView({
    super.key,
    required this.image,
    required this.width,
    required this.height,
    this.captionSize = 18,
    this.creditSize = 14,
    this.captionLines = 2,
    this.creditLines = 2,
    this.textColor,
    this.mutedColor,
  });

  final LessonImage image;
  final double width;

  /// Faqat rasm maydoni balandligi (matn pastiga qo‘shiladi).
  final double height;
  final double captionSize;
  final double creditSize;
  final int captionLines;
  final int creditLines;
  final Color? textColor;
  final Color? mutedColor;

  static const double gap = 8;
  static const double creditGap = 4;
  static const double captionLh = 1.3;
  static const double creditLh = 1.25;

  /// Blokning to‘liq balandligi — kanvas o‘lchovi shundan foydalanadi.
  static double totalHeight(
    LessonImage image, {
    required double height,
    double captionSize = 18,
    double creditSize = 14,
    int captionLines = 2,
    int creditLines = 2,
  }) {
    var h = height;
    if (image.caption.isNotEmpty) {
      h += gap + captionLines * captionSize * captionLh;
    }
    if (image.credit.isNotEmpty) {
      h += creditGap + creditLines * creditSize * creditLh;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final fg = textColor ?? c.textPrimary;
    final muted = mutedColor ?? c.textSecondary;
    final radius = BorderRadius.circular(8);
    final placeholder = Container(
      key: const Key('lesson.image.failed'),
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: radius,
        border: Border.all(color: c.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: (height * 0.22).clamp(24.0, 56.0),
            color: muted,
          ),
          const SizedBox(height: 6),
          Text(
            l.lessonImageFailed,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: captionSize, color: muted),
          ),
        ],
      ),
    );
    final picture = Semantics(
      image: true,
      button: true,
      label: image.caption.isEmpty ? l.lessonImageZoom : image.caption,
      hint: l.lessonImageZoom,
      child: ClipRRect(
        borderRadius: radius,
        child: ColoredBox(
          color: c.surfaceSunken,
          child: Image(
            key: const Key('lesson.image.picture'),
            image: _provider(image.url),
            width: width,
            height: height,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            loadingBuilder: (ctx, child, progress) => progress == null
                ? child
                : SizedBox(
                    width: width,
                    height: height,
                    child: const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  ),
            errorBuilder: (ctx, e, s) => placeholder,
          ),
        ),
      ),
    );
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: width,
            height: height,
            child: GestureDetector(
              key: const Key('lesson.image.tap'),
              behavior: HitTestBehavior.opaque,
              onTap: () => showLessonImageFullscreen(context, image),
              child: picture,
            ),
          ),
          if (image.caption.isNotEmpty) ...[
            const SizedBox(height: gap),
            SizedBox(
              height: captionLines * captionSize * captionLh,
              child: Text(
                image.caption,
                key: const Key('lesson.image.caption'),
                maxLines: captionLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: captionSize,
                  height: captionLh,
                  color: fg,
                ),
              ),
            ),
          ],
          if (image.credit.isNotEmpty) ...[
            const SizedBox(height: creditGap),
            SizedBox(
              height: creditLines * creditSize * creditLh,
              child: Semantics(
                label: l.lessonImageCredit(image.credit),
                excludeSemantics: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.copyright_outlined,
                      size: creditSize * 1.1,
                      color: muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        image.credit,
                        key: const Key('lesson.image.credit'),
                        maxLines: creditLines,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: creditSize,
                          height: creditLh,
                          color: muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// To‘liq ekran: pinch-zoom (`InteractiveViewer`), yopish tugmasi. Proyektorda
/// ham ishlaydi (dialog ildiz navigatorda).
Future<void> showLessonImageFullscreen(
  BuildContext context,
  LessonImage image,
) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: AppLocalizations.of(context).lessonImageClose,
    barrierColor: Colors.black,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (ctx, _, _) => _FullscreenImage(image: image),
  );
}

class _FullscreenImage extends StatelessWidget {
  const _FullscreenImage({required this.image});

  final LessonImage image;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      key: const Key('lesson.image.fullscreen'),
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                key: const Key('lesson.image.viewer'),
                minScale: 1,
                maxScale: 6,
                child: Center(
                  child: Image(
                    image: _provider(image.url),
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, e, s) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.broken_image_outlined,
                          size: 56,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.lessonImageFailed,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (image.caption.isNotEmpty || image.credit.isNotEmpty)
              Positioned(
                left: 16,
                right: 72,
                bottom: 12,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (image.caption.isNotEmpty)
                            Text(
                              image.caption,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          if (image.credit.isNotEmpty)
                            Text(
                              l.lessonImageCredit(image.credit),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                key: const Key('lesson.image.close'),
                tooltip: l.lessonImageClose,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
