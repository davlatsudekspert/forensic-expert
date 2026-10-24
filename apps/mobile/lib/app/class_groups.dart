import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/class_groups/fake_class_groups_service.dart';
import '../domain/class_groups/class_groups_models.dart';
import '../domain/class_quiz/class_quiz_models.dart'
    show ClassFailure, ClassHardDetail, ClassResult;
import '../domain/ports/class_groups_ports.dart';
import 'class_quiz.dart';
import 'providers.dart';

/// Demo (xotiradagi) «server»: ma’lumot faqat shu qurilmada. Kirish SHART
/// (anonim yo‘q); demo’da kirgan har bir hisob ustoz hisoblanadi, chunki rol
/// faqat serverda beriladi. Mavzular — «Sinfda test» bilan bir xil bank.
final classGroupsDemoBackendProvider = Provider<FakeClassGroupsBackend>((ref) {
  final quiz = ref.watch(classQuizDemoBackendProvider);
  return FakeClassGroupsBackend(
    topics: () async {
      await quiz.ensureLoaded();
      return quiz.topics;
    },
    isTeacher: (_) => true,
    demoStudents: 3,
  );
});

/// Bootstrap’da Supabase sozlangan bo‘lsa [SupabaseClassGroupsService] bilan
/// almashtiriladi; aks holda DEMO adapter.
final classGroupsServiceProvider = Provider<ClassGroupsService>((ref) {
  final backend = ref.watch(classGroupsDemoBackendProvider);
  return FakeClassGroupsService(
    backend,
    userIdOf: () {
      final s = ref.read(authStateProvider);
      return s.signedIn ? s.userId : null;
    },
  );
});

/// Ustoz paneli / katta ekran yangilanish oralig‘i (testlarda qisqartiriladi).
final groupPollIntervalProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 3),
);

/// Qurilma soati (testlarda almashtiriladi). Hisoblar baribir server
/// soatiga tuzatiladi ([GroupClock]).
final groupNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final groupListProvider = FutureProvider.autoDispose<GroupCall<GroupList>>((
  ref,
) {
  ref.watch(authStateProvider.select((s) => s.userId));
  return ref.watch(classGroupsServiceProvider).list();
});

final groupDetailProvider = FutureProvider.autoDispose
    .family<GroupCall<GroupDetail>, String>((ref, id) {
      ref.watch(authStateProvider.select((s) => s.userId));
      return ref.watch(classGroupsServiceProvider).detail(id);
    });

/// Ustoz jonli paneli va katta ekran: har ~3 s serverdan.
final groupBoardProvider = StreamProvider.autoDispose
    .family<GroupCall<GroupBoard>, String>((ref, id) async* {
      final svc = ref.watch(classGroupsServiceProvider);
      final interval = ref.watch(groupPollIntervalProvider);
      while (true) {
        try {
          yield await svc.board(id);
        } on Object {
          yield const GroupCall.fail(GroupFailure.server);
        }
        await Future<void>.delayed(interval);
      }
    });

/// Guruh testi «Qiyin savollar» muhokamasi (bir marta yuklanadi). Natija
/// «Sinfda test» muhokama sahifasi bilan bir xil turda ([ClassResult]).
final groupHardestDetailProvider = FutureProvider.autoDispose
    .family<ClassResult<List<ClassHardDetail>>, String>((ref, id) async {
      final r = await ref.watch(classGroupsServiceProvider).hardestDetail(id);
      final v = r.value;
      if (v != null) return ClassResult.ok(v);
      return ClassResult.fail(switch (r.failure!) {
        GroupFailure.notConfigured => ClassFailure.notConfigured,
        GroupFailure.notSignedIn => ClassFailure.notSignedIn,
        GroupFailure.offline => ClassFailure.offline,
        GroupFailure.forbidden => ClassFailure.forbidden,
        _ => ClassFailure.server,
      });
    });

final groupResultProvider = FutureProvider.autoDispose
    .family<GroupCall<GroupTestResult>, String>(
      (ref, id) => ref.watch(classGroupsServiceProvider).result(id),
    );

final pendingGroupInviteStoreProvider = Provider<PendingGroupInviteStore>(
  (ref) => InMemoryPendingGroupInviteStore(),
);

/// QR / havola orqali kelgan taklif. Diskda saqlanadi: yangi o‘rnatilgan
/// ilovada onboarding va ro‘yxatdan o‘tish davomida yo‘qolmaydi; oxirida
/// qo‘shilish sahifasi o‘zi ochiladi ([PendingGroupInvite.takeAutoOpen]).
final pendingGroupInviteProvider =
    NotifierProvider<PendingGroupInvite, GroupInvite?>(PendingGroupInvite.new);

class PendingGroupInvite extends Notifier<GroupInvite?> {
  /// Havoladan kelgandan keyin qo‘shilish sahifasi hali avtomatik ochilmagan.
  bool _autoOpen = false;

  @override
  GroupInvite? build() => ref.read(pendingGroupInviteStoreProvider).read();

  void remember(GroupInvite invite, {bool autoOpen = true}) {
    state = invite;
    _autoOpen = autoOpen || _autoOpen;
    unawaited(ref.read(pendingGroupInviteStoreProvider).write(invite));
  }

  /// Bir martalik: onboarding/kirish tugagach qo‘shilish sahifasini ochish
  /// kerakmi (sahifadan qaytgan foydalanuvchi qayta yo‘naltirilmaydi).
  GroupInvite? takeAutoOpen() {
    if (!_autoOpen || state == null) return null;
    _autoOpen = false;
    return state;
  }

  /// Kirgandan keyin yana bir marta ochish (kirish oynasi boshqa sahifaga
  /// olib ketgan bo‘lsa).
  void reopenAfterSignIn() {
    if (state != null) _autoOpen = true;
  }

  void clear() {
    state = null;
    _autoOpen = false;
    unawaited(ref.read(pendingGroupInviteStoreProvider).write(null));
  }
}
