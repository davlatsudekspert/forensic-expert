import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/settings/settings_controller.dart';
import '../domain/assessment/assessment_models.dart';
import '../domain/assessment/assessment_test_stats.dart';
import '../domain/assessment/oral_exam.dart';
import 'providers.dart' show uiLanguageCode;

/// Rasmiy og‘zaki imtihon savollari paketi (ilovaga qo‘shilgan, oflayn).
const assessmentAsset = 'assets/content/assessment/assessment_v1.json';

final assessmentLoaderProvider = Provider<Future<String> Function()>(
  (ref) =>
      () => rootBundle.loadString(assessmentAsset),
);

/// Testlar interfeys tilida (ru/en bo‘lsa; yo‘q matn — o‘zbekcha).
final assessmentLangProvider = Provider<String>(
  (ref) => uiLanguageCode(
    ref.watch(settingsControllerProvider.select((s) => s.locale)),
  ),
);

final assessmentProvider = FutureProvider<AssessmentBundle>((ref) async {
  final lang = ref.watch(assessmentLangProvider);
  try {
    final text = await ref.watch(assessmentLoaderProvider)();
    return AssessmentBundle.fromJson(
      (jsonDecode(text) as Map).cast<String, Object?>(),
      lang: lang,
    );
  } on Object {
    // Buzilgan yoki yo‘q paket — bo‘sh bo‘lim (soxta kontent yo‘q).
    return AssessmentBundle.empty;
  }
});

/// Og‘zaki javoblar (mutaxassislik bo‘yicha alohida asset, oflayn).
String oralAsset(String specialtyId) =>
    'assets/content/assessment/oral_$specialtyId.json';

final oralLoaderProvider = Provider<Future<String> Function(String)>(
  (ref) =>
      (id) => rootBundle.loadString(oralAsset(id)),
);

const oralSpecialties = ['sud_tib', 'pat_anat', 'sud_kimyo'];

final oralAnswersProvider = FutureProvider.family<OralAnswers, String>((
  ref,
  specialtyId,
) async {
  try {
    final text = await ref.watch(oralLoaderProvider)(specialtyId);
    return OralAnswers.fromJson(
      (jsonDecode(text) as Map).cast<String, Object?>(),
    );
  } on Object {
    // Javoblar paketi yo‘q yoki buzilgan — savollar «tez kunda» holatida.
    return OralAnswers.empty;
  }
});

/// Bootstrap’da SharedPreferences bilan override qilinadi (faqat lokal).
final assessmentProgressStoreProvider = Provider<AssessmentProgressStore>(
  (ref) => InMemoryAssessmentProgressStore(),
);

final assessmentProgressProvider =
    NotifierProvider<AssessmentProgressController, Set<String>>(
      AssessmentProgressController.new,
    );

class AssessmentProgressController extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.read(assessmentProgressStoreProvider).load();

  Future<void> toggle(String questionId) async {
    final next = {...state};
    if (!next.add(questionId)) next.remove(questionId);
    state = next;
    await ref.read(assessmentProgressStoreProvider).save(next);
  }

  Future<void> clear() async {
    state = const {};
    await ref.read(assessmentProgressStoreProvider).save(const {});
  }
}

/// Bootstrap’da SharedPreferences bilan override qilinadi (faqat lokal).
final assessmentTestStatsStoreProvider = Provider<AssessmentTestStatsStore>(
  (ref) => InMemoryAssessmentTestStatsStore(),
);

final assessmentTestStatsProvider =
    NotifierProvider<AssessmentTestStatsController, AssessmentTestStats>(
      AssessmentTestStatsController.new,
    );

class AssessmentTestStatsController extends Notifier<AssessmentTestStats> {
  @override
  AssessmentTestStats build() =>
      ref.read(assessmentTestStatsStoreProvider).load();

  Future<void> _set(AssessmentTestStats next) async {
    state = next;
    await ref.read(assessmentTestStatsStoreProvider).save(next);
  }

  Future<void> recordAnswer(
    String spec,
    String id, {
    required bool isCorrect,
    bool inMistakesMode = false,
  }) => _set(
    state.recordAnswer(
      spec,
      id,
      isCorrect: isCorrect,
      inMistakesMode: inMistakesMode,
    ),
  );

  Future<void> recordBlock(String spec, int block, int score) =>
      _set(state.recordBlock(spec, block, score));
}

/// Bootstrap’da SharedPreferences bilan override qilinadi (faqat lokal).
final oralExamStoreProvider = Provider<OralExamStore>(
  (ref) => InMemoryOralExamStore(),
);

/// Test uchun aniq bilet chiqarish imkoni.
final oralExamRandomProvider = Provider<math.Random>((ref) => math.Random());

@immutable
class OralExamState {
  const OralExamState({
    required this.data,
    this.spec = '',
    this.cat = '',
    this.questionIds = const [],
    this.scores = const [],
    this.name = '',
    this.poolReset = false,
    this.savedTotal,
  });

  final OralExamData data;
  final String spec;
  final String cat;

  /// Joriy bilet (bo‘sh — hali chiqarilmagan).
  final List<String> questionIds;

  /// Har savol uchun ball; `null` — hali qo‘yilmagan.
  final List<int?> scores;
  final String name;

  /// Oxirgi chiqarishda savollar aylanishi qaytadan boshlandi.
  final bool poolReset;

  /// Oxirgi saqlangan natija (ekranda bir marta ko‘rsatiladi).
  final int? savedTotal;

  bool get hasTicket => questionIds.isNotEmpty;
  bool get allScored => hasTicket && scores.every((x) => x != null);
  int get total => scores.fold(0, (a, b) => a + (b ?? 0));

  OralExamState copyWith({
    OralExamData? data,
    String? spec,
    String? cat,
    List<String>? questionIds,
    List<int?>? scores,
    String? name,
    bool? poolReset,
    Object? savedTotal = _keep,
  }) => OralExamState(
    data: data ?? this.data,
    spec: spec ?? this.spec,
    cat: cat ?? this.cat,
    questionIds: questionIds ?? this.questionIds,
    scores: scores ?? this.scores,
    name: name ?? this.name,
    poolReset: poolReset ?? this.poolReset,
    savedTotal: identical(savedTotal, _keep)
        ? this.savedTotal
        : savedTotal as int?,
  );
}

const Object _keep = Object();

final oralExamProvider = NotifierProvider<OralExamController, OralExamState>(
  OralExamController.new,
);

class OralExamController extends Notifier<OralExamState> {
  @override
  OralExamState build() =>
      OralExamState(data: ref.read(oralExamStoreProvider).load());

  Future<void> _persist(OralExamData d) async {
    await ref.read(oralExamStoreProvider).save(d);
  }

  /// Yangi bilet: ishlatilmagan savollardan; chiqarilgan savollar darhol
  /// «ishlatilgan» deb belgilanadi (keyingi talabaga takrorlanmaydi).
  Future<void> draw(String spec, String cat, List<String> pool) async {
    final r = drawOralTicket(
      pool: pool,
      used: state.data.usedFor(spec, cat),
      rng: ref.read(oralExamRandomProvider),
    );
    if (r.ids.isEmpty) return;
    final base = r.reset ? <String>{} : state.data.usedFor(spec, cat);
    final data = state.data.withUsed(spec, cat, {...base, ...r.ids});
    state = OralExamState(
      data: data,
      spec: spec,
      cat: cat,
      questionIds: r.ids,
      scores: List<int?>.filled(r.ids.length, null),
      name: '',
      poolReset: r.reset,
    );
    await _persist(data);
  }

  void setScore(int i, int v) {
    if (i < 0 || i >= state.scores.length) return;
    final next = [...state.scores];
    next[i] = v.clamp(0, oralExamMaxPerQuestion);
    state = state.copyWith(scores: next, savedTotal: null);
  }

  void setName(String v) => state = state.copyWith(name: v);

  /// Natijani tarixga yozadi va bilet maydonini bo‘shatadi.
  Future<int?> finish() async {
    if (!state.allScored) return null;
    final r = OralExamResult(
      atMs: DateTime.now().millisecondsSinceEpoch,
      spec: state.spec,
      cat: state.cat,
      name: state.name.trim(),
      questionIds: state.questionIds,
      scores: [for (final x in state.scores) x ?? 0],
    );
    final data = state.data.withResult(r);
    state = OralExamState(
      data: data,
      spec: state.spec,
      cat: state.cat,
      savedTotal: r.total,
    );
    await _persist(data);
    return r.total;
  }

  /// Savollar aylanishini boshidan boshlash (tarix saqlanadi).
  Future<void> resetPool(String spec, String cat) async {
    final data = state.data.withUsed(spec, cat, const {});
    state = state.copyWith(data: data);
    await _persist(data);
  }

  Future<void> clearHistory() async {
    final data = state.data.withoutHistory();
    state = state.copyWith(data: data);
    await _persist(data);
  }
}
