import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/qa/qa_models.dart';

/// Tasdiqlash hujjatini tanlash.
///
/// Tanlangan fayl **diskka ko‘chirilmaydi va keshlanmaydi**: baytlar faqat
/// ekran ochiq turgan vaqtda xotirada bo‘ladi va so‘rov tugashi bilan
/// yo‘qoladi.
abstract interface class QaDocumentPicker {
  /// `null` — foydalanuvchi bekor qildi.
  Future<QaDocument?> pick();
}

final qaDocumentPickerProvider = Provider<QaDocumentPicker>(
  (ref) => const SystemQaDocumentPicker(),
);

/// Turni baytlardan aniqlaydi — kengaytmaga ishonilmaydi.
String? sniffDocumentMime(Uint8List b) {
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
  if (b.length > 12 &&
      b[0] == 0x52 &&
      b[1] == 0x49 &&
      b[2] == 0x46 &&
      b[3] == 0x46 &&
      b[8] == 0x57 &&
      b[9] == 0x45 &&
      b[10] == 0x42 &&
      b[11] == 0x50) {
    return 'image/webp';
  }
  if (b.length > 4 &&
      b[0] == 0x25 &&
      b[1] == 0x50 &&
      b[2] == 0x44 &&
      b[3] == 0x46) {
    return 'application/pdf';
  }
  return null;
}

/// Tizim fayl tanlagichi (Android SAF / iOS Document Picker).
class SystemQaDocumentPicker implements QaDocumentPicker {
  const SystemQaDocumentPicker();

  /// Format nomlari tarjima qilinmaydi.
  static const _group = XTypeGroup(
    label: 'JPEG / PNG / WebP / PDF',
    extensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    mimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'],
    uniformTypeIdentifiers: [
      'public.jpeg',
      'public.png',
      'org.webmproject.webp',
      'com.adobe.pdf',
    ],
  );

  @override
  Future<QaDocument?> pick() async {
    final file = await openFile(acceptedTypeGroups: const [_group]);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final mime = sniffDocumentMime(bytes);
    // Turi aniqlanmasa ham qaytariladi: ekran `isAllowed` bo‘yicha xabar
    // beradi, shunda foydalanuvchi nimani tanlaganini biladi.
    return QaDocument(
      bytes: bytes,
      mimeType: mime ?? 'application/octet-stream',
    );
  }
}
