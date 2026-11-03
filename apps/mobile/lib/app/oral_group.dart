import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/oral_group/fake_oral_group_service.dart';
import '../domain/class_quiz/class_quiz_models.dart';
import '../domain/oral_group/oral_group_models.dart';
import '../domain/ports/oral_group_ports.dart';
import 'providers.dart';

/// Demo uchun xotiradagi “server” (ma’lumot faqat shu qurilmada). Demo
/// foydalanuvchi ustoz hisoblanadi, o‘z imtihoniga ham qo‘shila oladi va
/// har yangi imtihonga 3 ta “DEMO” talaba qo‘shiladi.
final oralGroupDemoBackendProvider = Provider<FakeOralGroupBackend>(
  (ref) => FakeOralGroupBackend(
    teachers: {'demo-user'},
    allowSelfJoin: true,
    demoBots: 3,
  ),
);

/// Bootstrap’da Supabase sozlangan bo‘lsa [SupabaseOralGroupService] bilan
/// almashtiriladi; aks holda DEMO (Fake) adapter ishlaydi.
final oralGroupServiceProvider = Provider<OralGroupService>(
  (ref) => FakeOralGroupService(
    ref.watch(oralGroupDemoBackendProvider),
    userId: 'demo-user',
  ),
);

/// Polling oralig‘i: ekran ko‘rinib turganda har 3 s (testlarda qisqartiriladi).
final oralGroupPollIntervalProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 3),
);

/// Soat (testlarda almashtiriladi) — tayyorgarlik sanog‘i uchun.
final oralGroupClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final oralGroupMySessionsProvider =
    FutureProvider.autoDispose<ClassResult<List<OralGroupSession>>>(
      (ref) => ref.watch(oralGroupServiceProvider).mySessions(),
    );

Stream<ClassResult<T>> _poll<T>(
  Duration interval,
  Future<ClassResult<T>> Function() fetch,
) async* {
  while (true) {
    try {
      yield await fetch();
    } on Object {
      yield ClassResult<T>.fail(ClassFailure.server);
    }
    await Future<void>.delayed(interval);
  }
}

/// Ustoz: sessiya, biletlar va talabalar (har ~3 s).
final oralGroupTeacherStateProvider = StreamProvider.autoDispose
    .family<ClassResult<OralGroupTeacherState>, String>((ref, id) {
      final svc = ref.watch(oralGroupServiceProvider);
      return _poll(
        ref.watch(oralGroupPollIntervalProvider),
        () => svc.teacherState(id),
      );
    });

/// Talaba holati va uni olgan qurilma vaqti (serverdan soat farqini
/// tuzatish uchun).
@immutable
class OralGroupSnap {
  const OralGroupSnap(this.state, this.fetchedAt);

  final OralGroupMyState state;
  final DateTime fetchedAt;
}

/// Talaba: o‘z bileti va holati (har ~3 s).
final oralGroupMyStateProvider = StreamProvider.autoDispose
    .family<ClassResult<OralGroupSnap>, String>((ref, id) {
      final svc = ref.watch(oralGroupServiceProvider);
      final clock = ref.watch(oralGroupClockProvider);
      return _poll(ref.watch(oralGroupPollIntervalProvider), () async {
        final r = await svc.myState(id);
        final v = r.value;
        return v == null
            ? ClassResult<OralGroupSnap>.fail(r.failure!)
            : ClassResult.ok(OralGroupSnap(v, clock()));
      });
    });

/// Oxirgi imtihon xotirasi (bootstrap’da diskka almashtiriladi).
final oralResumeStoreProvider = Provider<OralResumeStore>(
  (ref) => InMemoryOralResumeStore(),
);

/// Joriy foydalanuvchining oxirgi imtihoni (boshqa foydalanuvchiniki — `null`).
final oralResumeProvider = NotifierProvider<OralResumeNotifier, OralResume?>(
  OralResumeNotifier.new,
);

class OralResumeNotifier extends Notifier<OralResume?> {
  String get _user => ref.read(authStateProvider).userId ?? '';

  @override
  OralResume? build() {
    final r = ref.read(oralResumeStoreProvider).load();
    return r != null && r.userKey == _user ? r : null;
  }

  Future<void> remember(String code, String sessionId) async {
    final r = OralResume(userKey: _user, code: code, sessionId: sessionId);
    state = r;
    await ref.read(oralResumeStoreProvider).save(r);
  }

  Future<void> clear() async {
    state = null;
    await ref.read(oralResumeStoreProvider).save(null);
  }
}
