/// Darslar akademik tuzilmasi (egasi, 2026-11-07): 1) Sud tibbiyoti (Bioetika
/// birinchi bo‘lim + 4 fakultet + ichki bob «Sud-tibbiy toksikologiya»),
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

  /// Mutaxassis rejimidagi kurslar: «Apparatlar bilan ishlash» va
  /// Sud-kimyoviy ekspertiza ma’ruzalari (egasi, 2026-11-07).
  static const professionalCourses = {toxChem, forensicToxChapter, devices};

  static const subjects = <LessonSubject>[
    // Bioetika — Sud tibbiyoti ichida, birinchi bo‘lim (egasi, 2026-11-07:
    // darsliklarda, jumladan G‘iyosov kitobida ham shu tartib).
    LessonSubject(
      id: LessonSubjectId.forensic,
      sortOrder: 2,
      courses: [bioethics, medicine, pediatrics, dentistry, prevention],
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

  /// Kurs tartibi (fan tartibi, so‘ng fan ichidagi o‘rni); noma’lum kurs
  /// oxirida, o‘z tartibini saqlaydi. Tarjima nomi/alifboga bog‘liq emas.
  static int orderOf(String course) {
    for (final s in subjects) {
      final i = s.allCourses.indexOf(course);
      if (i >= 0) return s.sortOrder * 100 + i;
    }
    return 100000;
  }

  /// Kurs nomlari ro‘yxatini akademik tartibga soladi (barqaror).
  static List<T> sortByCourse<T>(Iterable<T> items, String Function(T) course) {
    final list = items.toList();
    final idx = {for (var i = 0; i < list.length; i++) list[i]: i};
    list.sort((a, b) {
      final c = orderOf(course(a)).compareTo(orderOf(course(b)));
      return c != 0 ? c : idx[a]!.compareTo(idx[b]!);
    });
    return list;
  }

  /// Kursni fanga bog‘laydi (noma’lum yangi kurs — null).
  static LessonSubject? subjectOf(String course) {
    for (final s in subjects) {
      if (s.allCourses.contains(course)) return s;
    }
    return null;
  }
}
