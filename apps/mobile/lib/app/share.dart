import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Tizimning ulashish oynasi (Android/iOS share sheet). Kontaktlarga ruxsat
/// so‘ralmaydi, ilova kimga yuborilganini bilmaydi.
abstract interface class ShareService {
  Future<void> shareText(String text, {String? subject, Rect? origin});
}

class NativeShareService implements ShareService {
  const NativeShareService();

  @override
  Future<void> shareText(String text, {String? subject, Rect? origin}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: subject, sharePositionOrigin: origin),
    );
  }
}

final shareServiceProvider = Provider<ShareService>(
  (ref) => const NativeShareService(),
);

/// iPad’da share sheet uchun langar (tugma joylashuvi).
Rect? shareOriginOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}
