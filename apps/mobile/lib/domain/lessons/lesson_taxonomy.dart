/// Darslar akademik tuzilmasi (egasi, 2026-11-07): 1) Bioetika (mustaqil fan),
/// 2) Sud tibbiyoti (4 fakultet + ichki bob «Sud-tibbiy toksikologiya»),
/// 3) Farmatsiya fakulteti — Toksikologik kimyo. Tartib `sortOrder` bilan,
/// tarjima qilingan nomga yoki alifboga bog‘liq emas. [course] — serverdagi
/// barqaror kurs nomi (identifikator), ekranda tilga qarab ko‘rsatiladi.
library;

enum LessonSubjectId { bioethics, forensic, pharmacy, devices }

class LessonSubject {
  const LessonSubject({
    required this.id,
    required this.sortOrder,
    required this.courses,
    this.chapter,
  });

  final LessonSubjectId id;
  final int sortOrder;

  /// Shu fan ichidagi kurslar (fakultetlar) tartibda.
  final List<String> courses;

  /// Fakultet emas, ichki bob sifatida ko‘rsatiladigan kurs.
  final String? chapter;

  /// Fan ichida bitta kurs bo‘lsa — to‘g‘ridan-to‘g‘ri mavzular ochiladi.
  bool get isLeaf => chapter == null && courses.length == 1;

  /// Fandagi barcha kurs nomlari (bob bilan).
  List<String> get allCourses => [...courses, ?chapter];
}

abstract final class LessonTaxonomy {
  static const bioethics = 'Bioetika';
  static const medicine = 'Davolash ishi fakulteti';
  static const pediatrics = 'Pediatriya fakulteti';
  static const dentistry = 'Stomatologiya fakulteti';
  static const prevention = 'Tibbiy profilaktika fakulteti';
  static const forensicToxChapter = 'Sud-tibbiy toksikologiya';
  static const toxChem = 'Toksikologik kimyo';
  static const devices = 'Apparatlar bilan ishlash';

  static const subjects = <LessonSubject>[
    LessonSubject(
      id: LessonSubjectId.bioethics,
      sortOrder: 1,
      courses: [bioethics],
    ),
    LessonSubject(
      id: LessonSubjectId.forensic,
      sortOrder: 2,
      courses: [medicine, pediatrics, dentistry, prevention],
      chapter: forensicToxChapter,
    ),
    LessonSubject(
      id: LessonSubjectId.pharmacy,
      sortOrder: 3,
      courses: [toxChem],
    ),
    LessonSubject(
      id: LessonSubjectId.devices,
      sortOrder: 4,
      courses: [devices],
    ),
  ];

  /// Kursni fanga bog‘laydi (noma’lum yangi kurs — null).
  static LessonSubject? subjectOf(String course) {
    for (final s in subjects) {
      if (s.allCourses.contains(course)) return s;
    }
    return null;
  }
}
