import 'dart:typed_data';

import '../../domain/ports/student_card_ports.dart';
import '../../domain/student_card/student_card.dart';
import '../../domain/teacher_card/teacher_card.dart' show TeacherImageKind;

/// Test/demo guruhi: ustoz va a’zolar (`memberId` → `userId`).
class FakeStudentGroup {
  FakeStudentGroup({required this.teacherId, required this.members});

  final String teacherId;
  final Map<String, String> members;
}

/// Test/demo «server»: server qoidalarining xotiradagi nusxasi (ko‘rinish
/// matritsasi, «o‘zim uchun yashirish», ustoz moderatsiyasi, admin yashirishi,
/// matn filtri).
class FakeStudentCardBackend {
  FakeStudentCardBackend({Map<String, FakeStudentGroup>? groups})
    : groups = groups ?? {};

  final Map<String, FakeStudentGroup> groups;
  final cards = <String, StudentCard>{};
  final files = <String, Uint8List>{};
  final adminHidden = <String>{};

  /// viewer → yashirgan talabalar.
  final hides = <String, Set<String>>{};

  /// guruh → ustoz yashirgan talabalar.
  final groupHides = <String, Set<String>>{};
  var _seq = 0;

  String newPath(String uid, Uint8List bytes) {
    _seq++;
    final ext = TeacherImageKind.of(bytes)?.ext ?? 'png';
    final n = _seq.toRadixString(16).padLeft(12, '0');
    return '$uid/photo-00000000-0000-4000-8000-$n.$ext';
  }

  bool isTeacherOf(String viewer, String student) => groups.values.any(
    (g) => g.teacherId == viewer && g.members.containsValue(student),
  );

  bool related(String viewer, String student) =>
      viewer != student &&
      (isTeacherOf(viewer, student) ||
          groups.values.any(
            (g) =>
                g.members.containsValue(viewer) &&
                g.members.containsValue(student),
          ));

  bool _groupmate(String viewer, String student) =>
      viewer != student &&
      groups.entries.any(
        (e) =>
            e.value.members.containsValue(viewer) &&
            e.value.members.containsValue(student) &&
            !(groupHides[e.key]?.contains(student) ?? false),
      );

  bool isPublic(StudentCard c) =>
      c.visible && !adminHidden.contains(c.studentId);

  bool visibleTo(String viewer, StudentCard c) =>
      viewer != c.studentId &&
      isPublic(c) &&
      !(hides[viewer]?.contains(c.studentId) ?? false) &&
      (isTeacherOf(viewer, c.studentId) || _groupmate(viewer, c.studentId));
}

class FakeStudentCardService implements StudentCardService {
  FakeStudentCardService(this.backend, {required this.userIdOf});

  final FakeStudentCardBackend backend;
  final String? Function() userIdOf;

  /// Chaqiruvlar jurnali (testlar uchun).
  final calls = <String>[];

  @override
  bool get isConfigured => true;

  @override
  Future<StudentCardResult<StudentCard?>> mine() async {
    calls.add('mine');
    final uid = userIdOf();
    if (uid == null) {
      return const StudentCardResult.fail(StudentCardFailure.notSignedIn);
    }
    final c = backend.cards[uid];
    if (c == null) return const StudentCardResult.ok(null);
    return StudentCardResult.ok(
      StudentCard(
        studentId: c.studentId,
        displayName: c.displayName,
        bio: c.bio,
        photoPath: c.photoPath,
        visible: c.visible,
        hiddenByAdmin: backend.adminHidden.contains(uid),
        hiddenInGroups: backend.groupHides.values
            .where((s) => s.contains(uid))
            .length,
      ),
    );
  }

  @override
  Future<StudentCardResult<StudentCard>> save(
    StudentCardDraft draft, {
    StudentCard? previous,
  }) async {
    calls.add('save');
    final uid = userIdOf();
    if (uid == null) {
      return const StudentCardResult.fail(StudentCardFailure.notSignedIn);
    }
    final err = draft.error;
    if (err != null) {
      return StudentCardResult.fail(StudentCardFailure.fromDraft(err));
    }
    if (draft.visible && backend.adminHidden.contains(uid)) {
      return const StudentCardResult.fail(StudentCardFailure.hiddenByAdmin);
    }
    final old = backend.cards[uid];
    String? photo = draft.removePhoto ? null : old?.photoPath;
    if (draft.photo != null) {
      photo = backend.newPath(uid, draft.photo!);
      backend.files[photo] = draft.photo!;
    }
    final oldPhoto = old?.photoPath;
    if (oldPhoto != null && oldPhoto != photo) backend.files.remove(oldPhoto);
    final saved = StudentCard(
      studentId: uid,
      displayName: draft.displayName.trim(),
      bio: draft.bio.trim(),
      photoPath: photo,
      visible: draft.visible,
    );
    backend.cards[uid] = saved;
    return StudentCardResult.ok(saved);
  }

  @override
  Future<StudentCardResult<void>> delete() async {
    calls.add('delete');
    final uid = userIdOf();
    if (uid == null) {
      return const StudentCardResult.fail(StudentCardFailure.notSignedIn);
    }
    final c = backend.cards.remove(uid);
    final p = c?.photoPath;
    if (p != null) backend.files.remove(p);
    return const StudentCardResult.ok(null);
  }

  @override
  Future<StudentCardResult<StudentGroupCards>> forGroup(String groupId) async {
    calls.add('forGroup');
    final uid = userIdOf();
    if (uid == null) {
      return const StudentCardResult.fail(StudentCardFailure.notSignedIn);
    }
    final g = backend.groups[groupId];
    if (g == null || !(g.teacherId == uid || g.members.containsValue(uid))) {
      return const StudentCardResult.fail(StudentCardFailure.forbidden);
    }
    final teacher = g.teacherId == uid;
    final shown = <StudentCard>[];
    final hidden = <String>[];
    final entries = g.members.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    for (final e in entries) {
      final c = backend.cards[e.value];
      if (c == null || c.studentId == uid || !backend.isPublic(c)) continue;
      final ghid = backend.groupHides[groupId]?.contains(c.studentId) ?? false;
      if (!teacher && ghid) continue;
      if (backend.hides[uid]?.contains(c.studentId) ?? false) {
        hidden.add(c.studentId);
        continue;
      }
      shown.add(
        StudentCard(
          studentId: c.studentId,
          displayName: c.displayName,
          bio: c.bio,
          photoPath: c.photoPath,
          groupHidden: teacher && ghid,
          memberId: teacher ? e.key : null,
        ),
      );
    }
    shown.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
    return StudentCardResult.ok(
      StudentGroupCards(cards: shown.take(200).toList(), hiddenIds: hidden),
    );
  }

  @override
  Future<StudentCardResult<void>> hideForMe(
    String studentId, {
    bool hide = true,
  }) async {
    calls.add(hide ? 'hideForMe' : 'unhideForMe');
    final uid = userIdOf();
    if (uid == null) {
      return const StudentCardResult.fail(StudentCardFailure.notSignedIn);
    }
    if (hide) {
      if (!backend.related(uid, studentId)) {
        return const StudentCardResult.fail(StudentCardFailure.forbidden);
      }
      backend.hides.putIfAbsent(uid, () => {}).add(studentId);
    } else {
      backend.hides[uid]?.remove(studentId);
    }
    return const StudentCardResult.ok(null);
  }

  @override
  Future<StudentCardResult<void>> hideInGroup(
    String groupId,
    String studentId, {
    bool hide = true,
    String? reason,
  }) async {
    calls.add(hide ? 'groupHide' : 'groupUnhide');
    final uid = userIdOf();
    if (uid == null) {
      return const StudentCardResult.fail(StudentCardFailure.notSignedIn);
    }
    final g = backend.groups[groupId];
    if (g == null || g.teacherId != uid) {
      return const StudentCardResult.fail(StudentCardFailure.forbidden);
    }
    if (!g.members.containsValue(studentId)) {
      return const StudentCardResult.fail(StudentCardFailure.notFound);
    }
    final s = backend.groupHides.putIfAbsent(groupId, () => {});
    hide ? s.add(studentId) : s.remove(studentId);
    return const StudentCardResult.ok(null);
  }

  @override
  Future<Uint8List?> image(String path) async {
    calls.add('image');
    return backend.files[path];
  }
}
