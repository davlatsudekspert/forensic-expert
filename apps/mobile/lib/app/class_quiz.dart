import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/class_quiz/class_quiz_bank.dart';
import '../data/class_quiz/fake_class_quiz_service.dart';
import '../domain/class_quiz/class_quiz_models.dart';
import '../domain/ports/class_quiz_ports.dart';
import 'providers.dart';

export '../data/class_quiz/class_quiz_bank.dart'
    show ClassQuizBank, ClassQuizBankGroup, ClassQuizBankTopicMeta;
export '../data/class_quiz/class_quiz_demo_bank.dart'
    show ClassBankQuestion, ClassBankTopic;

/// Savollar banki assetini o‘qish (testlarda almashtiriladi).
/// `rootBundle.load` + utf8 (loadString katta fayl uchun alohida isolate
/// ishlatadi — widget testlarida soxta vaqt ichida osilib qoladi).
final classQuizBankLoaderProvider = Provider<Future<String> Function()>(
  (ref) => () async {
    final data = await rootBundle.load(classQuizBankAsset);
    return utf8.decode(data.buffer.asUint8List());
  },
);

/// Savollar banki: mavzular kurs/fan guruhlari va uch tildagi nomlari bilan
/// (server mavzulari ham shu ID’lar bo‘yicha guruhlanadi). O‘qib bo‘lmasa —
/// bo‘sh bank (to‘qilmaydi).
final classQuizBankProvider = FutureProvider<ClassQuizBank>((ref) async {
  try {
    return ClassQuizBank.parse(await ref.watch(classQuizBankLoaderProvider)());
  } on Object {
    return ClassQuizBank.empty;
  }
});

/// Demo uchun xotiradagi “server” (ma’lumot faqat shu qurilmada). Demo
/// foydalanuvchi ustoz hisoblanadi; sinfga 3 ta “DEMO” ishtirokchi qo‘shiladi.
/// Mavzular — ilovadagi haqiqiy savollar banki; «DEMO: oddiy savollar»
/// to‘plami faqat debug/test yig‘masida (release’da ko‘rinmaydi).
final classQuizDemoBackendProvider = Provider<FakeClassQuizBackend>((ref) {
  final load = ref.watch(classQuizBankLoaderProvider);
  return FakeClassQuizBackend(
    teachers: {'demo-user'},
    allowSelfJoin: true,
    demoBots: 3,
    topics: classQuizLocalTopics(
      ClassQuizBank.empty,
      includeDemo: !kReleaseMode,
    ),
    topicLoader: () async => ClassQuizBank.parse(await load()).variants,
  );
});

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

/// Ustoz roli — faqat serverdan. UI shu bilan ko‘rsatiladi; xavfsizlik chegarasi
/// serverdagi 403.
final classQuizMeProvider =
    FutureProvider.autoDispose<ClassResult<ClassQuizMe>>((ref) {
      ref.watch(authStateProvider.select((s) => s.userId));
      return ref.watch(classQuizServiceProvider).me();
    });

/// Asosiy sahifa va «Ustoz paneli» uchun: ustoz roli bormi. Keep-alive (tab
/// almashganda qayta so‘ralmaydi), xato/tarmoqsizlikda — `false` (qayta
/// urinish taymerlari yo‘q). Faqat UI qulayligi; chegara — serverdagi 403.
final classIsTeacherProvider = FutureProvider<bool>((ref) async {
  ref.watch(authStateProvider.select((s) => s.userId));
  try {
    final r = await ref.watch(classQuizServiceProvider).me();
    return r.value?.isTeacher ?? false;
  } on Object {
    return false;
  }
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

/// «Qiyin savollar» muhokamasi: variantlar, to‘g‘ri javob, izoh, manba
/// (faqat ustoz, sessiya tugagach). Bir marta yuklanadi.
final classHardestDetailProvider = FutureProvider.autoDispose
    .family<ClassResult<List<ClassHardDetail>>, String>(
      (ref, id) => ref.watch(classQuizServiceProvider).hardestDetail(id),
    );

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

/// Proyektor ekrani ochiq turganda ekranni o‘chirmaslik (testlarda no-op).
abstract interface class ClassScreenAwake {
  Future<void> enable();
  Future<void> disable();
}

class WakelockClassScreenAwake implements ClassScreenAwake {
  const WakelockClassScreenAwake();

  @override
  Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } on Object {
      // Qo‘llab-quvvatlanmaydigan platforma/test: e’tiborsiz.
    }
  }

  @override
  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } on Object {
      // yuqoridagi kabi.
    }
  }
}

final classScreenAwakeProvider = Provider<ClassScreenAwake>(
  (ref) => const WakelockClassScreenAwake(),
);

/// Ustoz ekrani yo‘nalishini boshqarish (testlarda almashtiriladi).
abstract interface class ClassOrientationControl {
  Future<void> landscape();

  /// Ilova standarti: ilova `setPreferredOrientations` chaqirmaydi, shuning
  /// uchun bo‘sh ro‘yxat — platforma manifestidagi (Info.plist/Manifest)
  /// yo‘nalishlarga qaytish.
  Future<void> restore();
}

class SystemClassOrientationControl implements ClassOrientationControl {
  const SystemClassOrientationControl();

  @override
  Future<void> landscape() async {
    try {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } on Object {
      // e’tiborsiz.
    }
  }

  @override
  Future<void> restore() async {
    try {
      await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[]);
    } on Object {
      // e’tiborsiz.
    }
  }
}

final classOrientationControlProvider = Provider<ClassOrientationControl>(
  (ref) => const SystemClassOrientationControl(),
);

/// «Gorizontal holatga o‘tamizmi?» so‘rovi faqat telefonda (Android/iOS).
final classLandscapePromptEnabledProvider = Provider<bool>(
  (ref) =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS),
);
