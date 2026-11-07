/// O‘quv dasturi (ixtisoslashtirish kursi) katalogi — sof domen modeli.
///
/// Katalog `assets/content/programs/*.json` dan o‘qiladi. Kurs davomiyligi,
/// soat, oy, hafta va sanalar modelda YO‘Q (egasi qarori, 2026-11-05).
library;

/// Mavzuning holati: haqiqiy materialga qarab (soxta holat yo‘q).
enum ProgramTopicStatus { available, partial, preparing }

/// Mavjud materialga havola (mantiqiy tur + qiymat; marshrut app qatlamida).
class ProgramLink {
  const ProgramLink(this.kind, this.value);

  /// `method` | `substances` | `lab` | `tool` | `equipment` | `knowledge` |
  /// `jurisdictions` | `lesson` (ma’ruza `topicId`: toks-NN, sud-toks-NN).
  final String kind;

  bool get isLesson => kind == 'lesson';
  final String? value;
}

class ProgramTopic {
  const ProgramTopic({
    required this.id,
    required this.number,
    required this.title,
    required this.groupId,
    required this.status,
    required this.links,
  });

  /// Barqaror identifikator (`tk-01` …), mavjud materiallarga bog‘lash uchun.
  final String id;

  /// Asl dasturdagi tartib raqami (1 dan).
  final int number;

  /// Asl hujjatdagi nom (o‘zgartirilmaydi).
  final String title;
  final String groupId;
  final ProgramTopicStatus status;
  final List<ProgramLink> links;

  /// Mavzuga mos ma’ruzalar (`topicId`), dastur tartibida.
  List<String> get lessonIds => [
    for (final l in links)
      if (l.isLesson && l.value != null) l.value!,
  ];
}

class Program {
  const Program({required this.id, required this.module, required this.topics});

  static const empty = Program(id: '', module: '', topics: []);

  final String id;

  /// Asl hujjatdagi «Modul: …» nomi.
  final String module;

  /// Asl dastur tartibida.
  final List<ProgramTopic> topics;

  /// Tematik guruhlar tartibi (birinchi uchrash bo‘yicha emas, `g1…g7`).
  List<String> get groupIds =>
      ({for (final t in topics) t.groupId}.toList()..sort());

  List<ProgramTopic> inGroup(String id) => [
    for (final t in topics)
      if (t.groupId == id) t,
  ];

  int count(ProgramTopicStatus s) => topics.where((t) => t.status == s).length;

  factory Program.fromJson(Map<String, Object?> j) {
    ProgramTopicStatus status(String? s) => switch (s) {
      'available' => ProgramTopicStatus.available,
      'partial' => ProgramTopicStatus.partial,
      _ => ProgramTopicStatus.preparing,
    };
    final topics = <ProgramTopic>[
      for (final raw in (j['topics'] as List? ?? const []))
        if (raw is Map)
          ProgramTopic(
            id: raw['id'] as String,
            number: (raw['n'] as num).toInt(),
            title: raw['title'] as String,
            groupId: raw['group'] as String,
            status: status(raw['status'] as String?),
            links: [
              for (final l in (raw['links'] as List? ?? const []))
                if (l is Map) ProgramLink(l['k'] as String, l['v'] as String?),
            ],
          ),
    ];
    return Program(
      id: j['id'] as String? ?? '',
      module: j['module'] as String? ?? '',
      topics: topics,
    );
  }
}
