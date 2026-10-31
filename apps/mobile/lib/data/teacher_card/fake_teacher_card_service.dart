import 'dart:typed_data';

import '../../domain/ports/teacher_card_ports.dart';
import '../../domain/teacher_card/teacher_card.dart';

/// Test/demo «server»: server qoidalarining xotiradagi nusxasi (rol, visible,
/// guruh a’zoligi, admin yashirishi, havola/hajm tekshiruvi).
class FakeTeacherCardBackend {
  FakeTeacherCardBackend({required this.isTeacher, required this.teacherOf});

  /// Ustoz roli (serverda — account_roles).
  final bool Function(String uid) isTeacher;

  /// Guruh egasi-ustoz id si — faqat [uid] guruh egasi/a’zosi bo‘lsa.
  final String? Function(String uid, String groupId) teacherOf;

  final cards = <String, TeacherCard>{};
  final files = <String, Uint8List>{};
  final hidden = <String>{};
  var _seq = 0;

  String newPath(String uid, String kind, Uint8List bytes) {
    _seq++;
    final ext = TeacherImageKind.of(bytes)?.ext ?? 'png';
    final n = _seq.toRadixString(16).padLeft(12, '0');
    return '$uid/$kind-00000000-0000-4000-8000-$n.$ext';
  }
}

class FakeTeacherCardService implements TeacherCardService {
  FakeTeacherCardService(this.backend, {required this.userIdOf});

  final FakeTeacherCardBackend backend;
  final String? Function() userIdOf;

  /// Chaqiruvlar jurnali (testlar uchun).
  final calls = <String>[];

  @override
  bool get isConfigured => true;

  @override
  Future<TeacherCardResult<TeacherCard?>> mine() async {
    calls.add('mine');
    final uid = userIdOf();
    if (uid == null) {
      return const TeacherCardResult.fail(TeacherCardFailure.notSignedIn);
    }
    final c = backend.cards[uid];
    return TeacherCardResult.ok(
      c == null
          ? null
          : TeacherCard(
              teacherId: c.teacherId,
              displayName: c.displayName,
              workplace: c.workplace,
              bio: c.bio,
              photoPath: c.photoPath,
              logoPath: c.logoPath,
              socials: c.socials,
              visible: c.visible,
              hiddenByAdmin: backend.hidden.contains(uid),
            ),
    );
  }

  @override
  Future<TeacherCardResult<TeacherCard>> save(
    TeacherCardDraft draft, {
    TeacherCard? previous,
  }) async {
    calls.add('save');
    final uid = userIdOf();
    if (uid == null) {
      return const TeacherCardResult.fail(TeacherCardFailure.notSignedIn);
    }
    if (!backend.isTeacher(uid)) {
      return const TeacherCardResult.fail(TeacherCardFailure.forbidden);
    }
    final err = draft.error;
    if (err != null) {
      return TeacherCardResult.fail(switch (err) {
        TeacherCardDraftError.name => TeacherCardFailure.invalidName,
        TeacherCardDraftError.workplace => TeacherCardFailure.invalidWorkplace,
        TeacherCardDraftError.bio => TeacherCardFailure.invalidBio,
        TeacherCardDraftError.image => TeacherCardFailure.imageTooLarge,
        TeacherCardDraftError.social => TeacherCardFailure.invalidSocial,
      });
    }
    if (draft.visible && backend.hidden.contains(uid)) {
      return const TeacherCardResult.fail(TeacherCardFailure.hiddenByAdmin);
    }
    final old = backend.cards[uid];
    String? photo = draft.removePhoto ? null : old?.photoPath;
    String? logo = draft.removeLogo ? null : old?.logoPath;
    if (draft.photo != null) {
      photo = backend.newPath(uid, 'photo', draft.photo!);
      backend.files[photo] = draft.photo!;
    }
    if (draft.logo != null) {
      logo = backend.newPath(uid, 'logo', draft.logo!);
      backend.files[logo] = draft.logo!;
    }
    for (final p in [old?.photoPath, old?.logoPath]) {
      if (p != null && p != photo && p != logo) backend.files.remove(p);
    }
    final saved = TeacherCard(
      teacherId: uid,
      displayName: draft.displayName.trim(),
      workplace: draft.workplace.trim(),
      bio: draft.bio.trim(),
      photoPath: photo,
      logoPath: logo,
      socials: draft.socials,
      visible: draft.visible,
    );
    backend.cards[uid] = saved;
    return TeacherCardResult.ok(saved);
  }

  @override
  Future<TeacherCardResult<void>> delete() async {
    calls.add('delete');
    final uid = userIdOf();
    if (uid == null) {
      return const TeacherCardResult.fail(TeacherCardFailure.notSignedIn);
    }
    final c = backend.cards.remove(uid);
    for (final p in [c?.photoPath, c?.logoPath]) {
      if (p != null) backend.files.remove(p);
    }
    return const TeacherCardResult.ok(null);
  }

  @override
  Future<TeacherCardResult<TeacherCard?>> forGroup(String groupId) async {
    calls.add('forGroup');
    final uid = userIdOf();
    if (uid == null) {
      return const TeacherCardResult.fail(TeacherCardFailure.notSignedIn);
    }
    final teacher = backend.teacherOf(uid, groupId);
    if (teacher == null) {
      return const TeacherCardResult.fail(TeacherCardFailure.forbidden);
    }
    final c = backend.cards[teacher];
    if (c == null ||
        !c.visible ||
        backend.hidden.contains(teacher) ||
        !backend.isTeacher(teacher)) {
      return const TeacherCardResult.ok(null);
    }
    // Talabaga ichki maydonlar berilmaydi.
    return TeacherCardResult.ok(
      TeacherCard(
        teacherId: c.teacherId,
        displayName: c.displayName,
        workplace: c.workplace,
        bio: c.bio,
        photoPath: c.photoPath,
        logoPath: c.logoPath,
        socials: c.socials,
      ),
    );
  }

  @override
  Future<Uint8List?> image(String path) async {
    calls.add('image');
    return backend.files[path];
  }
}
