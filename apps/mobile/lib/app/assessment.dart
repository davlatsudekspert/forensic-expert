import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/assessment/assessment_models.dart';

/// Rasmiy og‘zaki imtihon savollari paketi (ilovaga qo‘shilgan, oflayn).
const assessmentAsset = 'assets/content/assessment/assessment_v1.json';

final assessmentLoaderProvider = Provider<Future<String> Function()>(
  (ref) =>
      () => rootBundle.loadString(assessmentAsset),
);

final assessmentProvider = FutureProvider<AssessmentBundle>((ref) async {
  try {
    final text = await ref.watch(assessmentLoaderProvider)();
    return AssessmentBundle.fromJson(
      (jsonDecode(text) as Map).cast<String, Object?>(),
    );
  } on Object {
    // Buzilgan yoki yo‘q paket — bo‘sh bo‘lim (soxta kontent yo‘q).
    return AssessmentBundle.empty;
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
