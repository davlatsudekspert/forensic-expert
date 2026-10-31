import 'dart:typed_data';

import '../teacher_card/teacher_card.dart';

/// «Ustoz kartasi» xizmati. Ruxsat, ko‘rinish (visible), havola va hajm
/// qarorlari serverda; mijoz faqat so‘raydi.
abstract interface class TeacherCardService {
  bool get isConfigured;

  /// Ustozning o‘z kartasi (`null` — hali yaratilmagan).
  Future<TeacherCardResult<TeacherCard?>> mine();

  /// Saqlash: yangi rasm/logotipni yuklaydi, kartani yozadi, almashtirilgan
  /// eski fayllarni o‘chiradi. [previous] — hozirgi saqlangan karta.
  Future<TeacherCardResult<TeacherCard>> save(
    TeacherCardDraft draft, {
    TeacherCard? previous,
  });

  /// Kartani va rasmlarini o‘chiradi.
  Future<TeacherCardResult<void>> delete();

  /// Guruh sahifasi (talaba ko‘rinishi): `null` — karta yo‘q yoki ustoz
  /// talabalarga ko‘rsatmaydi.
  Future<TeacherCardResult<TeacherCard?>> forGroup(String groupId);

  /// Karta rasmi baytlari (`null` — yo‘q / ruxsat yo‘q).
  Future<Uint8List?> image(String path);
}

/// Backend ulanmagan (release’da Supabase sozlanmasa): karta bo‘limi
/// ko‘rinmaydi.
class UnconfiguredTeacherCardService implements TeacherCardService {
  const UnconfiguredTeacherCardService();

  @override
  bool get isConfigured => false;

  static const _off = TeacherCardFailure.notConfigured;

  @override
  Future<TeacherCardResult<TeacherCard?>> mine() async =>
      const TeacherCardResult.fail(_off);

  @override
  Future<TeacherCardResult<TeacherCard>> save(
    TeacherCardDraft draft, {
    TeacherCard? previous,
  }) async => const TeacherCardResult.fail(_off);

  @override
  Future<TeacherCardResult<void>> delete() async =>
      const TeacherCardResult.fail(_off);

  @override
  Future<TeacherCardResult<TeacherCard?>> forGroup(String groupId) async =>
      const TeacherCardResult.fail(_off);

  @override
  Future<Uint8List?> image(String path) async => null;
}
