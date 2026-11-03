import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/assessment/oral_exam.dart';
import '../domain/class_quiz/class_quiz_models.dart' show ClassFailure;
import '../domain/lessons/lesson_models.dart';
import '../domain/lessons/lesson_oral.dart';
import 'assessment.dart' show OralExamState;
import 'lessons.dart';

/// Ustoz: mavzu bo‘yicha og‘zaki bilet. Natija va ishlatilgan savollar faqat
/// shu qurilmada (`fe.teacher.oralexam.v1`, bootstrap’da almashtiriladi).
final teacherOralStoreProvider = Provider<OralExamStore>(
  (ref) => InMemoryOralExamStore(),
);

final teacherOralRandomProvider = Provider<math.Random>((ref) => math.Random());

/// `OralExamData` ichida ustoz biletlari shu «mutaxassislik» nomi ostida.
const teacherOralSpec = 'lesson';

/// Tanlangan mavzular bo‘yicha savollar havzasi.
@immutable
class TeacherOralPool {
  const TeacherOralPool({
    required this.topics,
    required this.questions,
    this.failure,
  });

  /// Yuklangan darslar (tanlangan tartibda).
  final List<LessonDeck> topics;

  /// id → savol.
  final Map<String, LessonOralQuestion> questions;

  /// Birorta dars ham yuklanmasa — sabab.
  final ClassFailure? failure;

  Map<String, List<String>> get perTopic => {
    for (final d in topics)
      d.topicId: [
        for (final q in questions.values)
          if (q.topicId == d.topicId) q.id,
      ],
  };

  /// Tarix va sarlavha uchun: mavzular nomi.
  String get title => topics.map((d) => d.title).join(' · ');
}

/// `t` — [topicSelectionKey] (vergul bilan ajratilgan mavzu id’lari).
final teacherOralPoolProvider = FutureProvider.autoDispose
    .family<TeacherOralPool, String>((ref, key) async {
      final ids = [
        for (final x in key.split(','))
          if (x.trim().isNotEmpty) x.trim(),
      ];
      final decks = <LessonDeck>[];
      ClassFailure? failure;
      for (final id in ids) {
        final r = await ref.watch(lessonDeckProvider(id).future);
        final d = r.value;
        if (d == null) {
          failure ??= r.failure;
          continue;
        }
        decks.add(d);
      }
      final questions = <String, LessonOralQuestion>{
        for (final d in decks)
          for (final q in lessonOralQuestions(d)) q.id: q,
      };
      return TeacherOralPool(
        topics: decks,
        questions: questions,
        failure: decks.isEmpty ? failure : null,
      );
    });

final teacherOralProvider =
    NotifierProvider<TeacherOralController, OralExamState>(
      TeacherOralController.new,
    );

class TeacherOralController extends Notifier<OralExamState> {
  @override
  OralExamState build() =>
      OralExamState(data: ref.read(teacherOralStoreProvider).load());

  Future<void> _persist(OralExamData d) =>
      ref.read(teacherOralStoreProvider).save(d);

  static String _topicOf(String id) {
    final i = id.lastIndexOf('#');
    return i <= 0 ? id : id.substring(0, i);
  }

  /// Tanlangan mavzulardan yangi bilet. Chiqarilgan savollar darhol
  /// «ishlatilgan» deb belgilanadi (keyingi talabaga takrorlanmaydi).
  Future<void> draw(String key, Map<String, List<String>> perTopic) async {
    var data = state.data;
    final used = {
      for (final t in perTopic.keys) ...data.usedFor(teacherOralSpec, t),
    };
    final r = drawTopicOralTicket(
      pools: perTopic,
      used: used,
      rng: ref.read(teacherOralRandomProvider),
    );
    if (r.ids.isEmpty) return;
    for (final t in perTopic.keys) {
      final base = r.reset
          ? const <String>{}
          : data.usedFor(teacherOralSpec, t);
      data = data.withUsed(teacherOralSpec, t, {
        ...base,
        for (final id in r.ids)
          if (_topicOf(id) == t) id,
      });
    }
    state = OralExamState(
      data: data,
      spec: teacherOralSpec,
      cat: key,
      questionIds: r.ids,
      scores: List<int?>.filled(r.ids.length, null),
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

  /// Natijani tarixga yozadi; bilet maydoni bo‘shaydi.
  Future<int?> finish(String title) async {
    if (!state.allScored) return null;
    final r = OralExamResult(
      atMs: DateTime.now().millisecondsSinceEpoch,
      spec: teacherOralSpec,
      cat: state.cat,
      name: state.name.trim(),
      questionIds: state.questionIds,
      scores: [for (final x in state.scores) x ?? 0],
      title: title,
    );
    final data = state.data.withResult(r);
    state = OralExamState(
      data: data,
      spec: teacherOralSpec,
      cat: state.cat,
      savedTotal: r.total,
    );
    await _persist(data);
    return r.total;
  }

  /// Tanlangan mavzular savollarini boshidan boshlash (tarix saqlanadi).
  Future<void> resetPool(Iterable<String> topicIds) async {
    var data = state.data;
    for (final t in topicIds) {
      data = data.withUsed(teacherOralSpec, t, const {});
    }
    state = state.copyWith(data: data);
    await _persist(data);
  }

  Future<void> clearHistory() async {
    final data = state.data.withoutHistory();
    state = state.copyWith(data: data);
    await _persist(data);
  }
}
