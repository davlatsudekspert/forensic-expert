import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../domain/teacher_card/teacher_card.dart';

/// Rasmni 1 MB gacha siqadi: PNG qilib qayta kodlaydi va kerak bo‘lsa
/// kattaroq tomonini 512 → 384 → 256 → 160 px gacha kichraytiradi.
/// Sig‘masa yoki rasm o‘qilmasa — `null`.
Future<Uint8List?> fitTeacherImage(
  Uint8List src, {
  int maxBytes = TeacherCardLimits.imageBytes,
  List<int> sides = const [512, 384, 256, 160],
}) async {
  try {
    final probe = await ui.instantiateImageCodec(src);
    final frame = (await probe.getNextFrame()).image;
    final w = frame.width;
    final h = frame.height;
    frame.dispose();
    probe.dispose();
    for (final side in sides) {
      final big = w >= h ? w : h;
      final scale = big > side ? side / big : 1.0;
      final tw = (w * scale).round().clamp(1, 4096);
      final th = (h * scale).round().clamp(1, 4096);
      final codec = await ui.instantiateImageCodec(
        src,
        targetWidth: tw,
        targetHeight: th,
      );
      final img = (await codec.getNextFrame()).image;
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      img.dispose();
      codec.dispose();
      if (data == null) return null;
      final out = data.buffer.asUint8List();
      if (out.length <= maxBytes) return out;
    }
  } on Object {
    return null;
  }
  return null;
}
