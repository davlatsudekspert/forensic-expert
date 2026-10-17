import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../data/class_quiz/fake_class_quiz_service.dart';
import '../domain/class_quiz/class_quiz_models.dart';
import '../domain/ports/class_quiz_ports.dart';
import 'providers.dart';

/// Demo uchun xotiradagi “server” (ma’lumot faqat shu qurilmada). Demo
/// foydalanuvchi ustoz hisoblanadi; sinfga 3 ta “DEMO” ishtirokchi qo‘shiladi.
final classQuizDemoBackendProvider = Provider<FakeClassQuizBackend>(
  (ref) => FakeClassQuizBackend(
    teachers: {'demo-user'},
    allowSelfJoin: true,
    demoBots: 3,
  ),
);

/// Bootstrap’da Supabase sozlangan bo‘lsa [SupabaseClassQuizService] bilan
/// almashtiriladi; aks holda DEMO (Fake) adapter ishlaydi.
final classQuizServiceProvider = Provider<ClassQuizService>(
  (ref) => FakeClassQuizService(
    ref.watch(classQuizDemoBackendProvider),
    userId: 'demo-user',
  ),
);

/// Polling oralig‘i (testlarda qisqartiriladi).
final classQuizPollIntervalProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);

/// Shu qurilmada QR skaner mumkinmi (kamera: faqat Android/iOS).
final classScannerAvailableProvider = Provider<bool>(
  (ref) =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS),
);

/// Variantlarni aralashtirish uchun barqaror talaba kaliti (hisob id’si).
final classStudentKeyProvider = Provider<String>(
  (ref) => ref.watch(authStateProvider).userId ?? 'demo-user',
);

/// Ustoz roli — faqat serverdan. UI shu bilan ko‘rsatiladi; xavfsizlik chegarasi
/// serverdagi 403.
final classQuizMeProvider =
    FutureProvider.autoDispose<ClassResult<ClassQuizMe>>((ref) {
      ref.watch(authStateProvider.select((s) => s.userId));
      return ref.watch(classQuizServiceProvider).me();
    });

final classTopicsProvider =
    FutureProvider.autoDispose<ClassResult<List<ClassTopic>>>(
      (ref) => ref.watch(classQuizServiceProvider).topics(),
    );

final classMySessionsProvider =
    FutureProvider.autoDispose<ClassResult<List<ClassSessionInfo>>>(
      (ref) => ref.watch(classQuizServiceProvider).mySessions(),
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

/// Ustoz paneli: har ~2 s serverdan jonli agregatlar.
final classDashboardProvider = StreamProvider.autoDispose
    .family<ClassResult<ClassDashboard>, String>((ref, id) {
      final svc = ref.watch(classQuizServiceProvider);
      return _poll(
        ref.watch(classQuizPollIntervalProvider),
        () => svc.dashboard(id),
      );
    });

/// Talaba holati: har ~2 s.
final classStudentStateProvider = StreamProvider.autoDispose
    .family<ClassResult<ClassStudentState>, String>((ref, id) {
      final svc = ref.watch(classQuizServiceProvider);
      return _poll(
        ref.watch(classQuizPollIntervalProvider),
        () => svc.state(id),
      );
    });

final classMyResultsProvider = FutureProvider.autoDispose
    .family<ClassResult<ClassMyResults>, String>(
      (ref, id) => ref.watch(classQuizServiceProvider).myResults(id),
    );

/// Deep link yoki QR orqali kelgan, hali ishlatilmagan sinf kodi (xotirada).
final pendingClassCodeProvider = NotifierProvider<PendingClassCode, String?>(
  PendingClassCode.new,
);

class PendingClassCode extends Notifier<String?> {
  @override
  String? build() => null;

  /// Noto‘g‘ri formatli kod e’tiborsiz qoldiriladi.
  bool remember(String raw) {
    final c = ClassCode.normalize(raw);
    if (c == null) return false;
    state = c;
    return true;
  }

  void clear() => state = null;
}

/// Hozir qo‘shilgan sinf (ilova ochiq turganda “Davom etish” uchun).
final classActiveJoinProvider =
    NotifierProvider<ClassActiveJoin, ClassJoinInfo?>(ClassActiveJoin.new);

class ClassActiveJoin extends Notifier<ClassJoinInfo?> {
  @override
  ClassJoinInfo? build() => null;

  void set(ClassJoinInfo? v) => state = v;
}

/// QR havolasi: hozircha faqat ilova ichidagi sxema
/// (`forensicexpert://app/join/<kod>`). Ommaviy domen (universal link) egasi
/// domen tayyorlagach qo‘shiladi — qarang docs/CLASS_QUIZ.md.
final classJoinLinkProvider = Provider.family<Uri, String>(
  (ref, code) => ClassCode.joinLink(code),
);

/// Natijani fayl sifatida ulashish (tizim ulashish oynasi: “Fayllarga saqlash”
/// ham shu yerda). Testlarda almashtiriladi.
abstract interface class ClassFileShare {
  Future<void> shareCsv({
    required String fileName,
    required String content,
    String? subject,
  });
}

class NativeClassFileShare implements ClassFileShare {
  const NativeClassFileShare();

  @override
  Future<void> shareCsv({
    required String fileName,
    required String content,
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(content)),
            mimeType: 'text/csv',
            name: fileName,
          ),
        ],
        fileNameOverrides: [fileName],
        subject: subject,
      ),
    );
  }
}

final classFileShareProvider = Provider<ClassFileShare>(
  (ref) => const NativeClassFileShare(),
);
