import 'dart:typed_data';

import '../student_card/student_card.dart';

/// «Talaba kartasi» xizmati. Ruxsat, ko‘rinish (visible, yashirishlar),
/// matn filtri va hajm qarorlari serverda; mijoz faqat so‘raydi.
abstract interface class StudentCardService {
  bool get isConfigured;

  /// Talabaning o‘z kartasi (`null` — hali yaratilmagan).
  Future<StudentCardResult<StudentCard?>> mine();

  /// Saqlash: yangi rasmni yuklaydi, kartani yozadi, almashtirilgan eski
  /// rasmni o‘chiradi. [previous] — hozirgi saqlangan karta.
  Future<StudentCardResult<StudentCard>> save(
    StudentCardDraft draft, {
    StudentCard? previous,
  });

  /// Kartani va rasmini o‘chiradi.
  Future<StudentCardResult<void>> delete();

  /// Guruh a’zolarining ko‘rinadigan kartalari (guruh a’zosi yoki ustozi).
  Future<StudentCardResult<StudentGroupCards>> forGroup(String groupId);

  /// Kartani FAQAT o‘zim uchun yashirish / qaytarish.
  Future<StudentCardResult<void>> hideForMe(
    String studentId, {
    bool hide = true,
  });

  /// Guruh ustozi: kartani shu guruh uchun yashirish / qaytarish.
  Future<StudentCardResult<void>> hideInGroup(
    String groupId,
    String studentId, {
    bool hide = true,
    String? reason,
  });

  /// Karta rasmi baytlari (`null` — yo‘q / ruxsat yo‘q).
  Future<Uint8List?> image(String path);
}

/// Backend ulanmagan: karta bo‘limi ko‘rinmaydi.
class UnconfiguredStudentCardService implements StudentCardService {
  const UnconfiguredStudentCardService();

  @override
  bool get isConfigured => false;

  static const _off = StudentCardFailure.notConfigured;

  @override
  Future<StudentCardResult<StudentCard?>> mine() async =>
      const StudentCardResult.fail(_off);

  @override
  Future<StudentCardResult<StudentCard>> save(
    StudentCardDraft draft, {
    StudentCard? previous,
  }) async => const StudentCardResult.fail(_off);

  @override
  Future<StudentCardResult<void>> delete() async =>
      const StudentCardResult.fail(_off);

  @override
  Future<StudentCardResult<StudentGroupCards>> forGroup(String groupId) async =>
      const StudentCardResult.fail(_off);

  @override
  Future<StudentCardResult<void>> hideForMe(
    String studentId, {
    bool hide = true,
  }) async => const StudentCardResult.fail(_off);

  @override
  Future<StudentCardResult<void>> hideInGroup(
    String groupId,
    String studentId, {
    bool hide = true,
    String? reason,
  }) async => const StudentCardResult.fail(_off);

  @override
  Future<Uint8List?> image(String path) async => null;
}
