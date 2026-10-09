import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/support/support_models.dart';

/// Rasm tanlash natijasi: rasm yoki rad etish sababi.
sealed class PickedImage {
  const PickedImage();
}

class PickedImageOk extends PickedImage {
  const PickedImageOk(this.attachment);
  final SupportAttachment attachment;
}

enum PickedImageError { wrongType, tooLarge }

class PickedImageRejected extends PickedImage {
  const PickedImageRejected(this.error);
  final PickedImageError error;
}

/// Skrinshot tanlagich (testlarda almashtiriladi).
abstract interface class SupportImagePicker {
  /// `null` — foydalanuvchi bekor qildi.
  Future<PickedImage?> pick();
}

final supportImagePickerProvider = Provider<SupportImagePicker>(
  (ref) => const SystemSupportImagePicker(),
);

/// Turini baytlardan aniqlaydi (kengaytmaga ishonilmaydi).
String? sniffImageMime(Uint8List b) {
  if (b.length > 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
    return 'image/jpeg';
  }
  if (b.length > 8 &&
      b[0] == 0x89 &&
      b[1] == 0x50 &&
      b[2] == 0x4E &&
      b[3] == 0x47) {
    return 'image/png';
  }
  return null;
}

/// Tizim fayl tanlagichi (Android SAF / iOS Document Picker) — ruxsat
/// so‘ralmaydi. Faqat JPEG/PNG. 1 MB dan katta rasm eni 1600 px gacha
/// kichraytiriladi (PNG; kichikroq chiqsa ishlatiladi), so‘ng 5 MB chegarasi.
class SystemSupportImagePicker implements SupportImagePicker {
  const SystemSupportImagePicker();

  /// Tizim dialogidagi fayl turi nomi (format nomlari — tarjima qilinmaydi).
  static const _typeLabel = 'JPEG / PNG';
  static const _group = XTypeGroup(
    label: _typeLabel,
    extensions: ['jpg', 'jpeg', 'png'],
    mimeTypes: ['image/jpeg', 'image/png'],
    uniformTypeIdentifiers: ['public.jpeg', 'public.png'],
  );

  @override
  Future<PickedImage?> pick() async {
    final f = await openFile(acceptedTypeGroups: const [_group]);
    if (f == null) return null;
    var bytes = await f.readAsBytes();
    var mime = sniffImageMime(bytes);
    if (mime == null) {
      return const PickedImageRejected(PickedImageError.wrongType);
    }
    if (bytes.length > 1024 * 1024) {
      final smaller = await _downscale(bytes);
      if (smaller != null && smaller.length < bytes.length) {
        bytes = smaller;
        mime = 'image/png';
      }
    }
    if (bytes.length > SupportLimits.attachmentBytes) {
      return const PickedImageRejected(PickedImageError.tooLarge);
    }
    return PickedImageOk(SupportAttachment(bytes: bytes, mimeType: mime));
  }

  static Future<Uint8List?> _downscale(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 1600,
        allowUpscaling: false,
      );
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      frame.image.dispose();
      return data?.buffer.asUint8List();
    } on Exception {
      return null;
    }
  }
}
